import asyncio
import json
import logging
from datetime import datetime
from typing import Any, TypedDict
from zoneinfo import ZoneInfo

from botocore.exceptions import ClientError
from mypy_boto3_s3 import S3Client
from openai import AsyncOpenAI
from openai.types.shared_params.response_format_json_schema import JSONSchema

from bolobao import areas, bucket, model, sources
from bolobao.model import Answer, Output
from bolobao.places import Place

PREFIX = f"verdicts/v10/{model.VERSION}/"

log = logging.getLogger(__name__)


class Check(TypedDict):
    prompt: str
    about_this_place: bool
    reason: str
    supported: bool


class Checks(TypedDict):
    namesakes: str
    answers: list[Check]
    price_reason: str
    price_supported: bool
    closed_reason: str
    closed: bool


class Rating(TypedDict):
    usable_reason: str
    usable: bool
    score: int


class Verdict(TypedDict):
    namesakes: str
    answers: list[Check]
    price_reason: str
    price_supported: bool
    closed_reason: str
    closed: bool
    usable_reason: str
    usable: bool
    score: float


def compose(place: Place, sources: dict[str, Any], output: Output) -> str | None:
    base = model.compose(place, sources)
    if base is None:
        return None

    composed = {"answers": output["answers"], "price_level": output["price_level"]}
    return (
        f"TODAY: {_today()}\n{base}"
        f"\n\nOUTPUT:\n{json.dumps(composed, ensure_ascii=False, indent=2)}"
    )


def compose_card(place: Place, output: Output) -> str:
    lines = [
        f"TODAY: {_today()}",
        f"NAME: {place.name}",
        f"AREA: {areas.en(place)}",
    ]
    if place.address:
        lines.append(f"ADDRESS: {place.address}")

    composed = {"answers": output["answers"], "price_level": output["price_level"]}
    lines += ["", "OUTPUT:", json.dumps(composed, ensure_ascii=False, indent=2)]
    return "\n".join(lines)


async def review(
    bucket_name: str,
    s3: S3Client,
    nebius: AsyncOpenAI,
    sem: asyncio.Semaphore,
    check_system: str,
    check_schema: JSONSchema,
    rate_system: str,
    rate_schema: JSONSchema,
    place: Place,
):
    try:
        output: Output = await asyncio.to_thread(
            bucket.get_json, bucket_name, s3, f"{model.PREFIX}{place.id}.json"
        )
    except ClientError:
        return

    if not output["is_match"]:
        return

    try:
        found = await asyncio.to_thread(
            bucket.get_json, bucket_name, s3, f"{sources.PREFIX}{place.id}.json"
        )
    except ClientError:
        return

    message = compose(place, found, output)
    if message is None:
        return

    async with sem:
        results = await asyncio.gather(
            *(
                _check(nebius, check_system, check_schema, message, place, output)
                for _ in range(3)
            )
        )
        checks = [c for c in results if c is not None]
        if len(checks) < 3:
            log.warning("not enough checks: %s (%d)", place.id, len(checks))
            return

        kept = _supported_answers(checks, output)
        if not kept:
            ratings: list[Rating] = [
                {"usable_reason": "No supported answers.", "usable": False, "score": 1}
            ] * 3
        else:
            shown: Output = {**output, "answers": kept}
            card = compose_card(place, shown)
            rated = await asyncio.gather(
                *(
                    _rate(nebius, rate_system, rate_schema, card, place)
                    for _ in range(3)
                )
            )
            ratings = [r for r in rated if r is not None]
            if len(ratings) < 3:
                log.warning("not enough ratings: %s (%d)", place.id, len(ratings))
                return

    verdict = _combine(checks, ratings)
    await _save(bucket_name, s3, place, verdict)


async def review_many(
    bucket_name: str,
    s3: S3Client,
    nebius: AsyncOpenAI,
    check_system: str,
    check_schema: JSONSchema,
    rate_system: str,
    rate_schema: JSONSchema,
    places: list[Place],
):
    enriched = bucket.list_ids(bucket_name, s3, model.PREFIX)
    done = bucket.list_ids(bucket_name, s3, PREFIX)
    sem = asyncio.Semaphore(10)

    tasks = [
        review(
            bucket_name,
            s3,
            nebius,
            sem,
            check_system,
            check_schema,
            rate_system,
            rate_schema,
            place,
        )
        for place in places
        if place.id in enriched and place.id not in done
    ]
    log.info("reviewing up to %d places", len(tasks))
    await asyncio.gather(*tasks)


async def _check(
    nebius: AsyncOpenAI,
    system: str,
    schema: JSONSchema,
    message: str,
    place: Place,
    output: Output,
) -> Checks | None:
    for attempt in range(3):
        result = await model.complete(
            nebius,
            "nvidia/nemotron-3-super-120b-a12b",
            system,
            schema,
            message,
            place.id,
            temperature=1.0,
            top_p=0.95,
        )
        if result is None:
            return None

        checks: Checks = result
        if _covers(checks, output):
            return checks

        log.warning(
            "checks don't match answers: %s (attempt %d): judged %s, written %s",
            place.id,
            attempt + 1,
            sorted(c["prompt"] for c in checks["answers"]),
            sorted(a["prompt"] for a in output["answers"]),
        )
    return None


async def _rate(
    nebius: AsyncOpenAI,
    system: str,
    schema: JSONSchema,
    card: str,
    place: Place,
) -> Rating | None:
    return await model.complete(
        nebius,
        "nvidia/nemotron-3-super-120b-a12b",
        system,
        schema,
        card,
        place.id,
        temperature=1.0,
        top_p=0.95,
    )


def _supported_answers(checks: list[Checks], output: Output) -> list[Answer]:
    kept = []
    for a in output["answers"]:
        votes = [
            next(c for c in run["answers"] if c["prompt"] == a["prompt"])["supported"]
            for run in checks
        ]
        if _majority(votes):
            kept.append(a)
    return kept


def _combine(checks: list[Checks], ratings: list[Rating]) -> Verdict:
    answers: list[Check] = []
    for first in checks[0]["answers"]:
        votes = [
            next(c for c in run["answers"] if c["prompt"] == first["prompt"])
            for run in checks
        ]
        supported = _majority([v["supported"] for v in votes])
        agreeing = next(v for v in votes if v["supported"] == supported)
        answers.append(
            {
                "prompt": first["prompt"],
                "about_this_place": _majority([v["about_this_place"] for v in votes]),
                "reason": agreeing["reason"],
                "supported": supported,
            }
        )

    price_supported = _majority([c["price_supported"] for c in checks])
    price_from = next(c for c in checks if c["price_supported"] == price_supported)

    closed = _majority([c["closed"] for c in checks])
    closed_from = next(c for c in checks if c["closed"] == closed)

    usable = _majority([r["usable"] for r in ratings])
    usable_from = next(r for r in ratings if r["usable"] == usable)

    return {
        "namesakes": checks[0]["namesakes"],
        "answers": answers,
        "price_reason": price_from["price_reason"],
        "price_supported": price_supported,
        "closed_reason": closed_from["closed_reason"],
        "closed": closed,
        "usable_reason": usable_from["usable_reason"],
        "usable": usable,
        "score": round(sum(r["score"] for r in ratings) / len(ratings), 1),
    }


def _majority(votes: list[bool]) -> bool:
    return sum(votes) * 2 > len(votes)


def _covers(checks: Checks, output: Output) -> bool:
    judged = sorted(c["prompt"] for c in checks["answers"])
    written = sorted(a["prompt"] for a in output["answers"])
    return judged == written


def _today() -> str:
    return datetime.now(ZoneInfo("Asia/Hong_Kong")).date().isoformat()


async def _save(bucket_name: str, s3: S3Client, place: Place, verdict: Verdict):
    key = f"{PREFIX}{place.id}.json"
    if await asyncio.to_thread(bucket.put_json, bucket_name, s3, key, verdict):
        log.info("wrote %s", key)
