import asyncio
import base64
import io
import logging
from dataclasses import dataclass
from typing import Any, TypedDict

import httpx
from botocore.exceptions import ClientError
from mypy_boto3_s3 import S3Client
from openai import AsyncOpenAI
from openai.types.chat import ChatCompletionContentPartParam
from openai.types.shared_params.response_format_json_schema import JSONSchema
from PIL import Image, ImageOps, UnidentifiedImageError

from bolobao import areas, bucket, model, sources
from bolobao.places import Place

VERSION = "v1"
PREFIX = f"photos/{VERSION}/"
IMAGES = f"{VERSION}/"

WIDTH = 1200
MIN_SIDE = 200

log = logging.getLogger(__name__)


@dataclass(frozen=True, kw_only=True, slots=True)
class Candidate:
    index: int
    title: str
    description: str
    url: str
    jpeg: bytes
    width: int
    height: int


class Pick(TypedDict):
    reason: str
    image: int


class Photo(TypedDict):
    index: int | None
    source_url: str | None
    reason: str


def url(photos_bucket: str, place_id: str) -> str:
    return (
        f"https://{photos_bucket}.s3.eu-central-1.amazonaws.com/{IMAGES}{place_id}.jpg"
    )


def compose(
    place: Place, cands: list[Candidate]
) -> list[ChatCompletionContentPartParam]:
    content: list[ChatCompletionContentPartParam] = [
        {
            "type": "text",
            "text": f"NAME: {place.name}\nAREA: {areas.en(place)}",
        }
    ]

    for n, cand in enumerate(cands, 1):
        b64 = base64.b64encode(cand.jpeg).decode()
        content += [
            {
                "type": "text",
                "text": f"Image {n}\npage title: {cand.title}\n"
                f"description: {cand.description}\n"
                f"size: {cand.width}x{cand.height}",
            },
            {
                "type": "image_url",
                "image_url": {"url": f"data:image/jpeg;base64,{b64}"},
            },
        ]

    return content


async def pick(
    bucket_name: str,
    photos_bucket: str,
    s3: S3Client,
    nebius: AsyncOpenAI,
    http: httpx.AsyncClient,
    sem: asyncio.Semaphore,
    system: str,
    schema: JSONSchema,
    place: Place,
):
    try:
        found = await asyncio.to_thread(
            bucket.get_json, bucket_name, s3, f"{sources.PREFIX}{place.id}.json"
        )
    except ClientError:
        return

    async with sem:
        cands = await _candidates(http, found.get("images") or [])
        if not cands:
            photo: Photo = {
                "index": None,
                "source_url": None,
                "reason": "no usable images",
            }
            await _save(bucket_name, photos_bucket, s3, place, photo, None)
            log.info("skipped %s: no usable images", place.id)
            return

        result = await model.complete(
            nebius,
            "nvidia/Nemotron-3.5-Super-VL",
            system,
            schema,
            compose(place, cands),
            place.id,
            temperature=1.0,
            top_p=0.95,
            max_tokens=8000,
        )

    if result is None:
        return

    picked: Pick = result
    n = picked["image"]
    if n == -1:
        photo = {"index": None, "source_url": None, "reason": picked["reason"]}
        await _save(bucket_name, photos_bucket, s3, place, photo, None)
        return
    if not 1 <= n <= len(cands):
        log.warning("bad image number for %s: %d of %d", place.id, n, len(cands))
        return

    cand = cands[n - 1]
    photo = {"index": cand.index, "source_url": cand.url, "reason": picked["reason"]}
    await _save(bucket_name, photos_bucket, s3, place, photo, cand.jpeg)


async def pick_many(
    bucket_name: str,
    photos_bucket: str,
    s3: S3Client,
    nebius: AsyncOpenAI,
    system: str,
    schema: JSONSchema,
    places: list[Place],
):
    done = bucket.list_ids(bucket_name, s3, PREFIX)
    sem = asyncio.Semaphore(10)

    async with httpx.AsyncClient(
        timeout=15,
        follow_redirects=True,
        headers={
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
            "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36"
        },
    ) as http:
        tasks = [
            pick(
                bucket_name, photos_bucket, s3, nebius, http, sem, system, schema, place
            )
            for place in places
            if place.id not in done
        ]
        log.info("picking photos for %d places", len(tasks))
        await asyncio.gather(*tasks)


async def _candidates(
    http: httpx.AsyncClient, images: list[dict[str, Any]]
) -> list[Candidate]:
    found = await asyncio.gather(*(_download(http, img["url"]) for img in images))

    out: list[Candidate] = []
    for i, (img, data) in enumerate(zip(images, found)):
        if data is None:
            continue

        shrunk = await asyncio.to_thread(_shrink, data)
        if shrunk is None:
            continue

        jpeg, width, height = shrunk
        out.append(
            Candidate(
                index=i,
                title=img.get("title") or "",
                description=img.get("description") or "",
                url=img["url"],
                jpeg=jpeg,
                width=width,
                height=height,
            )
        )

    return out


async def _download(http: httpx.AsyncClient, url: str) -> bytes | None:
    try:
        resp = await http.get(url)
    except httpx.HTTPError:
        return None

    kind = resp.headers.get("content-type", "").split(";")[0]
    if resp.status_code != 200 or not kind.startswith("image/"):
        return None
    return resp.content


def _shrink(data: bytes) -> tuple[bytes, int, int] | None:
    try:
        with Image.open(io.BytesIO(data)) as img:
            img = ImageOps.exif_transpose(img)
            if min(img.size) < MIN_SIDE:
                return None

            img = img.convert("RGB")
            if img.width > WIDTH:
                img = img.resize(
                    (WIDTH, round(img.height * WIDTH / img.width)),
                    Image.Resampling.LANCZOS,
                )

            out = io.BytesIO()
            img.save(out, "JPEG", quality=80, optimize=True)
            return out.getvalue(), img.width, img.height
    except (UnidentifiedImageError, OSError, ValueError):
        return None


async def _save(
    bucket_name: str,
    photos_bucket: str,
    s3: S3Client,
    place: Place,
    photo: Photo,
    jpeg: bytes | None,
):
    if jpeg is not None:
        key = f"{IMAGES}{place.id}.jpg"
        if not await asyncio.to_thread(
            bucket.put_bytes, photos_bucket, s3, key, jpeg, "image/jpeg"
        ):
            return

    key = f"{PREFIX}{place.id}.json"
    if await asyncio.to_thread(bucket.put_json, bucket_name, s3, key, photo):
        log.info("wrote %s", key)
