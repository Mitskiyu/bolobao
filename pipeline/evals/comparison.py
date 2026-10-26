import asyncio
import csv
import logging
import math
import os
import re
from pathlib import Path

import boto3
import duckdb
from botocore.config import Config
from dotenv import load_dotenv
from mypy_boto3_s3 import S3Client
from openai import AsyncOpenAI
from openai.types.shared_params.response_format_json_schema import JSONSchema

from bolobao import bucket, judge, model, places, prompts
from bolobao.judge import Verdict
from bolobao.model import Output

OLD = "v1"


def main():
    load_dotenv()
    nebius_key = os.environ["NEBIUS_KEY"]
    bucket_name = os.environ["S3_BUCKET"]
    places_key = os.environ["PLACES_KEY"]

    here = Path(__file__).resolve().parent
    pipeline = here.parent

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    logging.getLogger("botocore").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpx2").setLevel(logging.WARNING)

    with open(here / "golden.csv") as f:
        golden = {row["fsq_id"]: row for row in csv.DictReader(f)}

    with duckdb.connect() as con:
        gold_places = [
            p
            for p in places.load(con, pipeline.parent / "data" / places_key)
            if p.id in golden
        ]

    enrich_system, enrich_schema = prompts.load("enrich")
    check_system, check_schema = prompts.load("check")
    rate_system, rate_schema = prompts.load("rate")

    s3 = boto3.client("s3", config=Config(max_pool_connections=32))
    nebius = AsyncOpenAI(
        base_url="https://api.tokenfactory.us-central1.nebius.com/v1/",
        api_key=nebius_key,
    )

    asyncio.run(
        run(
            bucket_name,
            s3,
            nebius,
            enrich_system,
            enrich_schema,
            check_system,
            check_schema,
            rate_system,
            rate_schema,
            gold_places,
        )
    )

    old = fetch(bucket_name, s3, golden, f"outputs/{OLD}/", f"verdicts/v9/{OLD}/")
    new = fetch(bucket_name, s3, golden, model.PREFIX, judge.PREFIX)

    report(golden, old, new)


async def run(
    bucket_name: str,
    s3: S3Client,
    nebius: AsyncOpenAI,
    enrich_system: str,
    enrich_schema: JSONSchema,
    check_system: str,
    check_schema: JSONSchema,
    rate_system: str,
    rate_schema: JSONSchema,
    gold_places: list[places.Place],
):
    await model.enrich_many(
        bucket_name, s3, nebius, enrich_system, enrich_schema, gold_places
    )
    await judge.review_many(
        bucket_name,
        s3,
        nebius,
        check_system,
        check_schema,
        rate_system,
        rate_schema,
        gold_places,
    )


def fetch(bucket_name, s3, golden, outputs_prefix, verdicts_prefix):
    out_ids = [
        i for i in golden if i in bucket.list_ids(bucket_name, s3, outputs_prefix)
    ]
    ver_ids = [
        i for i in golden if i in bucket.list_ids(bucket_name, s3, verdicts_prefix)
    ]
    outputs: dict[str, Output] = bucket.get_json_many(
        bucket_name, s3, outputs_prefix, out_ids
    )
    verdicts: dict[str, Verdict] = bucket.get_json_many(
        bucket_name, s3, verdicts_prefix, ver_ids
    )
    return outputs, verdicts


def should_match(row: dict[str, str]) -> bool:
    notes = row["notes"]
    return (
        row["actual_match"] == "TRUE"
        and not notes.startswith("closed")
        and "not a restaurant" not in notes
    )


def score(golden, outputs, verdicts) -> tuple[dict[str, float | int], dict[str, int]]:
    right = wrong_match = missed = 0
    shown = usable = 0
    scores: list[float] = []
    answers = unsupported = long = dashes = 0
    words = 0
    good: dict[str, int] = {}

    for fsq_id, row in golden.items():
        output = outputs.get(fsq_id)
        matched = bool(output and output["is_match"])
        expected = should_match(row)

        if matched == expected:
            right += 1
        elif matched:
            wrong_match += 1
        else:
            missed += 1

        verdict = verdicts.get(fsq_id)
        good[fsq_id] = int(matched and expected and bool(verdict and verdict["usable"]))

        if not matched or output is None:
            continue
        shown += 1

        if verdict:
            usable += verdict["usable"]
            scores.append(verdict["score"])
            answers += len(verdict["answers"])
            unsupported += sum(not c["supported"] for c in verdict["answers"])

        for a in output["answers"]:
            text = a["text"]
            n = len(text.split())
            words += n
            long += n > 10
            dashes += bool(re.search(r"[—–;]", text))

    total = sum(len(outputs[i]["answers"]) for i in outputs if outputs[i]["is_match"])
    stats = {
        "identity right": right,
        "wrong match": wrong_match,
        "missed": missed,
        "shown": shown,
        "usable": usable,
        "good cards": sum(good.values()),
        "avg score": round(sum(scores) / len(scores), 2) if scores else 0,
        "unsupported": f"{unsupported}/{answers}",
        "avg words": round(words / total, 1) if total else 0,
        "over 10 words": long,
        "dashes": dashes,
    }
    return stats, good


def report(golden, old, new):
    old_stats, old_good = score(golden, *old)
    new_stats, new_good = score(golden, *new)

    print(f"\n{len(golden)} gold places, {OLD} vs {model.VERSION}\n")
    print(f"{'':<16}{OLD:>10}{model.VERSION:>10}")
    for key in old_stats:
        print(f"{key:<16}{old_stats[key]!s:>10}{new_stats[key]!s:>10}")

    diffs = [new_good[i] - old_good[i] for i in golden]
    n = len(diffs)
    mean = sum(diffs) / n
    sd = math.sqrt(sum((d - mean) ** 2 for d in diffs) / (n - 1))
    margin = 1.96 * sd / math.sqrt(n)
    wins = sum(d > 0 for d in diffs)
    losses = sum(d < 0 for d in diffs)

    print(
        f"\ngood cards, paired: {wins} better, {losses} worse, {n - wins - losses} same"
    )
    print(
        f"difference per place: {mean:+.2f} (95% CI {mean - margin:+.2f} to {mean + margin:+.2f})"
    )
    if mean - margin > 0:
        print(f"verdict: {model.VERSION} is better")
    elif mean + margin < 0:
        print(f"verdict: {OLD} is better")
    else:
        print("verdict: no clear difference")

    names = {i: golden[i]["name"] for i in golden}
    changed = [i for i in golden if diffs[list(golden).index(i)] != 0]
    if changed:
        print("\nchanged")
        for i in changed:
            sign = "better" if new_good[i] > old_good[i] else "worse"
            print(f"{sign}: {names[i]} {i}")


if __name__ == "__main__":
    main()
