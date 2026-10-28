import asyncio
import logging
import os
from pathlib import Path

import boto3
import duckdb
import psycopg
from botocore.config import Config
from dotenv import load_dotenv
from mypy_boto3_s3 import S3Client
from openai import AsyncOpenAI
from tavily import AsyncTavilyClient

from bolobao import (
    areas,
    bucket,
    database,
    judge,
    model,
    photos,
    places,
    prompts,
    sources,
)

log = logging.getLogger(__name__)


async def main():
    load_dotenv()

    fsq_token = os.environ["FSQ_TOKEN"]
    tavily_key = os.environ["TAVILY_KEY"]
    nebius_key = os.environ["NEBIUS_KEY"]
    bucket_name = os.environ["S3_BUCKET"]
    photos_bucket = os.environ["S3_BUCKET_PHOTOS"]
    user = os.environ["PG_USER"]
    password = os.environ["PG_PASSWORD"]
    host = os.environ["PG_HOST"]
    port = os.environ["PG_PORT"]
    name = os.environ["PG_NAME"]
    places_key = os.environ["SHAM_SHUI_PO_PLACES_KEY"]
    hk_places_key = os.environ["HK_PLACES_KEY"]

    here = Path(__file__).resolve().parent
    data_dir = here.parent / "data"
    data_dir.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    logging.getLogger("botocore").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpx2").setLevel(logging.WARNING)

    s3 = boto3.client("s3", config=Config(max_pool_connections=32))
    parquet = snapshot(
        bucket_name, s3, fsq_token, data_dir, places_key, ["Sham Shui Po District"]
    )
    hk_parquet = snapshot(
        bucket_name, s3, fsq_token, data_dir, hk_places_key, areas.DISTRICTS
    )

    with duckdb.connect() as con:
        all_places = places.load(con, parquet)
        hk_places = places.load(con, hk_parquet)

    tavily = AsyncTavilyClient(tavily_key)
    await sources.fetch_many(bucket_name, s3, tavily, all_places)

    enrich_system, enrich_schema = prompts.load("enrich")
    check_system, check_schema = prompts.load("check")
    rate_system, rate_schema = prompts.load("rate")
    photo_system, photo_schema = prompts.load("photo")

    nebius = AsyncOpenAI(
        base_url="https://api.tokenfactory.nebius.com/v1/",
        api_key=nebius_key,
    )
    await model.enrich_many(
        bucket_name, s3, nebius, enrich_system, enrich_schema, all_places
    )
    await judge.review_many(
        bucket_name,
        s3,
        nebius,
        check_system,
        check_schema,
        rate_system,
        rate_schema,
        all_places,
    )

    enriched = bucket.list_ids(bucket_name, s3, model.PREFIX)
    outputs = bucket.get_json_many(bucket_name, s3, model.PREFIX, list(enriched))

    judged = bucket.list_ids(bucket_name, s3, judge.PREFIX)
    verdicts = bucket.get_json_many(bucket_name, s3, judge.PREFIX, list(judged))

    unique = list({p.id: p for p in hk_places + all_places}.values())
    deck = {p.fsq_id for p in database.profiles(unique, outputs, verdicts)}

    await photos.pick_many(
        bucket_name,
        photos_bucket,
        s3,
        nebius,
        photo_system,
        photo_schema,
        [p for p in unique if p.id in deck],
    )

    with psycopg.connect(
        user=user, password=password, host=host, port=port, dbname=name
    ) as con:
        database.upsert_restaurants(con, database.restaurants(unique))
        database.upsert_profiles(con, database.profiles(unique, outputs, verdicts))


def snapshot(
    bucket_name: str,
    s3: S3Client,
    fsq_token: str,
    data_dir: Path,
    key: str,
    districts: list[str],
) -> Path:
    parquet = data_dir / key
    parquet.parent.mkdir(parents=True, exist_ok=True)

    if parquet.exists():
        log.info("using local %s", parquet)
    elif bucket.get_file(bucket_name, s3, key, parquet):
        log.info("downloaded %s", key)
    else:
        log.warning("no %s snapshot found, rebuilding from fsq", key)
        with duckdb.connect() as con:
            places.download(con, fsq_token)
            places.export(con, districts, parquet)
        s3.upload_file(str(parquet), bucket_name, key)
        log.info("uploaded %s", key)

    return parquet


if __name__ == "__main__":
    asyncio.run(main())
