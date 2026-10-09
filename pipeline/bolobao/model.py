import asyncio
import json
import logging
from typing import Any, TypedDict

from botocore.exceptions import ClientError
from mypy_boto3_s3 import S3Client
from openai import (
    APIConnectionError,
    APITimeoutError,
    AsyncOpenAI,
    InternalServerError,
    RateLimitError,
)
from openai.types.shared_params.response_format_json_schema import (
    JSONSchema,
    ResponseFormatJSONSchema,
)

from bolobao import areas, bucket
from bolobao.places import Place

log = logging.getLogger(__name__)


class Answer(TypedDict):
    prompt: str
    text: str
    source_url: str


class Output(TypedDict):
    is_match: bool
    match_evidence: str | None
    answers: list[Answer]
    price_level: int | None


def compose(place: Place, sources: dict[str, Any]) -> str | None:
    lines = [f"NAME: {place.name}", f"AREA: {areas.en(place)}"]
    if place.address:
        lines.append(f"ADDRESS: {place.address}")

    lines += ["", "SOURCES:"]

    n = 0
    for res in sources["results"]:
        content = res.get("content") or ""
        if not content:
            continue

        title = res.get("title") or ""
        content = content.removeprefix(f"Title: {title}").lstrip()

        n += 1
        if n > 1:
            lines.append("")
        lines += [f"[{n}] {title}", res.get("url") or "", content]
        if res.get("published_date"):
            lines.append(f"({res['published_date']})")

    return "\n".join(lines) if n else None


async def enrich(
    bucket_name: str,
    s3: S3Client,
    nebius: AsyncOpenAI,
    sem: asyncio.Semaphore,
    system: str,
    schema: JSONSchema,
    place: Place,
):
    try:
        sources = await asyncio.to_thread(
            bucket.get_json, bucket_name, s3, f"sources/{place.id}.json"
        )
    except ClientError:
        return

    message = compose(place, sources)
    if message is None:
        out: Output = {
            "is_match": False,
            "match_evidence": "no usable sources",
            "answers": [],
            "price_level": None,
        }
        await _save(bucket_name, s3, place, out)
        log.info("skipped %s: no usable sources", place.id)
        return

    resp_format: ResponseFormatJSONSchema = {
        "type": "json_schema",
        "json_schema": schema,
    }

    resp = None
    async with sem:
        for attempt in range(5):
            try:
                resp = await nebius.chat.completions.create(
                    model="nvidia/Nemotron-3-Ultra-550b-a55b",
                    messages=[
                        {"role": "system", "content": system},
                        {"role": "user", "content": message},
                    ],
                    max_tokens=32000,
                    temperature=0.2,
                    response_format=resp_format,
                )
                break
            except (
                RateLimitError,
                APITimeoutError,
                APIConnectionError,
                InternalServerError,
            ) as e:
                if attempt == 4:
                    log.warning("failed to enrich %s: %s", place.id, e)
                    return
                await asyncio.sleep(2**attempt)

    if resp is None:
        return

    choice = resp.choices[0]
    if choice.finish_reason == "length":
        log.warning("truncated: %s", place.id)
        return
    if choice.message.refusal or choice.message.content is None:
        log.warning("refused: %s", place.id)
        return

    try:
        output: Output = json.loads(choice.message.content)
    except json.JSONDecodeError:
        log.warning("bad json: %s", place.id)
        return

    await _save(bucket_name, s3, place, output)


async def enrich_many(
    bucket_name: str,
    s3: S3Client,
    nebius: AsyncOpenAI,
    system: str,
    schema: JSONSchema,
    places: list[Place],
):
    sourced = bucket.list_ids(bucket_name, s3, "sources/")
    done = bucket.list_ids(bucket_name, s3, "profiles/")
    sem = asyncio.Semaphore(10)

    tasks = [
        enrich(bucket_name, s3, nebius, sem, system, schema, place)
        for place in places
        if place.id in sourced and place.id not in done
    ]
    log.info("enriching %d places", len(tasks))
    await asyncio.gather(*tasks)


async def _save(bucket_name: str, s3: S3Client, place: Place, output: Output):
    key = f"profiles/{place.id}.json"
    if await asyncio.to_thread(bucket.put_json, bucket_name, s3, key, output):
        log.info("wrote %s", key)
