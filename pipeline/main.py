import asyncio
import json
import logging
import os
from pathlib import Path

import boto3
import duckdb
import psycopg
from botocore.config import Config
from dotenv import load_dotenv
from openai import AsyncOpenAI
from openai.types.shared_params.response_format_json_schema import JSONSchema
from tavily import AsyncTavilyClient

from bolobao import areas, bucket, database, model, places, sources

PLACES_KEY = "places/2026-09-15.parquet"

log = logging.getLogger(__name__)


def main():
    load_dotenv()

    fsq_token = os.environ["FSQ_TOKEN"]
    tavily_key = os.environ["TAVILY_KEY"]
    nebius_key = os.environ["NEBIUS_KEY"]
    bucket_name = os.environ["S3_BUCKET"]
    user = os.environ["PG_USER"]
    password = os.environ["PG_PASSWORD"]
    host = os.environ["PG_HOST"]
    port = os.environ["PG_PORT"]
    name = os.environ["PG_NAME"]

    here = Path(__file__).resolve().parent
    data_dir = here.parent / "data"
    data_dir.mkdir(parents=True, exist_ok=True)
    parquet = data_dir / PLACES_KEY
    parquet.parent.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    logging.getLogger("botocore").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpx2").setLevel(logging.WARNING)

    s3 = boto3.client("s3", config=Config(max_pool_connections=32))
    if parquet.exists():
        log.info("using local %s", parquet)
    elif bucket.get_file(bucket_name, s3, PLACES_KEY, parquet):
        log.info("downloaded %s", PLACES_KEY)
    else:
        with duckdb.connect() as con:
            places.download(con, fsq_token)
            places.export(con, areas.DISTRICTS, parquet)
        s3.upload_file(str(parquet), bucket_name, PLACES_KEY)
        log.info("uploaded %s", PLACES_KEY)

    with duckdb.connect() as con:
        all_places = places.load(con, parquet)

    tavily = AsyncTavilyClient(tavily_key)
    asyncio.run(sources.fetch_many(bucket_name, s3, tavily, all_places))

    with open(here / "schema.json") as f:
        schema: JSONSchema = json.load(f)
    with open(here / "system.md") as f:
        system = (
            f.read()
            + "\n\n### Schema\n"
            + json.dumps(schema, ensure_ascii=False, indent=2)
        )

    nebius = AsyncOpenAI(
        base_url="https://api.tokenfactory.us-central1.nebius.com/v1/",
        api_key=nebius_key,
    )
    asyncio.run(model.enrich_many(bucket_name, s3, nebius, system, schema, all_places))

    enriched = bucket.list_ids(bucket_name, s3, "profiles/")
    outputs = bucket.get_json_many(bucket_name, s3, "profiles/", list(enriched))

    with psycopg.connect(
        user=user, password=password, host=host, port=port, dbname=name
    ) as conn:
        database.upsert(conn, database.rows(all_places, outputs))


if __name__ == "__main__":
    main()
