import asyncio
import csv
import logging
import os
import sys
from pathlib import Path

import boto3
import duckdb
from botocore.config import Config
from dotenv import load_dotenv
from openai import AsyncOpenAI

from bolobao import bucket, judge, places, prompts


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

    ids = set(sys.argv[1:])
    with open(here / "golden.csv") as f:
        golden = {}
        for row in csv.DictReader(f):
            if row["actual_usable"] and (not ids or row["fsq_id"] in ids):
                golden[row["fsq_id"]] = row

    with duckdb.connect() as con:
        gold_places = [
            p
            for p in places.load(con, pipeline.parent / "data" / places_key)
            if p.id in golden
        ]

    check_system, check_schema = prompts.load("check")
    rate_system, rate_schema = prompts.load("rate")

    s3 = boto3.client("s3", config=Config(max_pool_connections=32))
    nebius = AsyncOpenAI(
        base_url="https://api.tokenfactory.us-central1.nebius.com/v1/",
        api_key=nebius_key,
    )
    asyncio.run(
        judge.review_many(
            bucket_name,
            s3,
            nebius,
            check_system,
            check_schema,
            rate_system,
            rate_schema,
            gold_places,
        )
    )

    done = bucket.list_ids(bucket_name, s3, judge.PREFIX)
    found = [i for i in golden if i in done]
    verdicts = bucket.get_json_many(bucket_name, s3, judge.PREFIX, found)

    report(golden, verdicts)


def report(golden: dict[str, dict[str, str]], verdicts: dict[str, judge.Verdict]):
    agree_yes = agree_no = too_loose = too_strict = 0
    wrong = []
    for fsq_id, verdict in verdicts.items():
        row = golden[fsq_id]
        gold = row["actual_usable"] == "TRUE"
        judged = verdict["usable"]
        if gold and judged:
            agree_yes += 1
        elif not gold and not judged:
            agree_no += 1
        elif judged:
            too_loose += 1
            wrong.append((row, verdict))
        else:
            too_strict += 1
            wrong.append((row, verdict))

    n = len(verdicts)
    agree = agree_yes + agree_no
    yes = agree_yes + too_strict

    print(f"\njudged {n} of {len(golden)} ({judge.PREFIX})\n")
    print("              judged usable  judged not")
    print(f"gold usable   {agree_yes:>13}  {too_strict:>10}")
    print(f"gold not      {too_loose:>13}  {agree_no:>10}\n")
    print(f"agreement    {agree / n:>4.0%}  ({agree}/{n})")
    print(f"always-yes   {yes / n:>4.0%}  ({yes}/{n}, the baseline to beat)")
    print(f"too loose    {too_loose:>4}  (judged usable, gold not)")
    print(f"too strict   {too_strict:>4}  (judged not, gold usable)")

    print("\ndisagreements")
    for row, verdict in wrong:
        gold = "usable" if row["actual_usable"] == "TRUE" else "not usable"
        judged = "usable" if verdict["usable"] else "not usable"
        print(f"\n{row['name']} {row['fsq_id']}")
        print(f"gold:   {gold} ({row['notes'] or 'no notes'})")
        print(f"judged: {judged}, score {verdict['score']}")
        print(f"reason: {verdict['usable_reason']}")


if __name__ == "__main__":
    main()
