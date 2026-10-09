import csv
import logging
import os
import random
from pathlib import Path

import boto3
import duckdb
from botocore.config import Config
from dotenv import load_dotenv

from bolobao import bucket, model, places, sources
from main import PLACES_KEY

log = logging.getLogger(__name__)


def main():
    load_dotenv()

    bucket_name = os.environ["S3_BUCKET"]

    here = Path(__file__).resolve().parent
    golden = here / "golden.csv"
    golden.parent.mkdir(parents=True, exist_ok=True)
    parquet = here.parent / "data" / PLACES_KEY

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    logging.getLogger("botocore").setLevel(logging.WARNING)

    if golden.exists():
        log.info("golden set exists: %s", golden)
        return

    if not parquet.exists():
        log.error("parquet not found: %s", parquet)
        return

    with duckdb.connect() as con:
        all_places = {p.id: p for p in places.load(con, parquet)}

    s3 = boto3.client("s3", config=Config(max_pool_connections=32))
    ids = sorted(bucket.list_ids(bucket_name, s3, sources.PREFIX))
    random.Random(1).shuffle(ids)

    golden_ids = ids[:50]
    outputs = bucket.get_json_many(bucket_name, s3, model.PREFIX, golden_ids)

    with open(golden, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "fsq_id",
                "name",
                "address",
                "predicted_match",
                "answers",
                "actual_match",
                "actual_usable",
                "notes",
            ]
        )

        for place_id in golden_ids:
            place = all_places[place_id]
            output = outputs[place_id]
            answers = " | ".join(
                f"{a['prompt']}: {a['text']}" for a in output["answers"]
            )
            w.writerow(
                [
                    place_id,
                    place.name,
                    place.address or "",
                    output["is_match"],
                    answers,
                    "",
                    "",
                    "",
                ]
            )

    log.info("wrote %d places to %s", len(golden_ids), golden)


if __name__ == "__main__":
    main()
