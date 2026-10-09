import asyncio
import json
import os
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import boto3
import duckdb
import psycopg
from botocore.config import Config
from botocore.exceptions import ClientError
from dotenv import load_dotenv
from openai import (
    AsyncOpenAI,
    AuthenticationError,
    BadRequestError,
)
from psycopg.types.json import Jsonb
from tavily import AsyncTavilyClient
from tavily.errors import BadRequestError as TavilyBadRequestError
from tavily.errors import (
    ForbiddenError,
    InvalidAPIKeyError,
    MissingAPIKeyError,
    UsageLimitExceededError,
)


def main():
    load_dotenv()
    run()


def run():
    fsq_token = os.environ["FSQ_TOKEN"]
    tavily_key = os.environ["TAVILY_KEY"]
    nebius_key = os.environ["NEBIUS_KEY"]
    bucket = os.environ["S3_BUCKET"]
    user = os.environ["PG_USER"]
    password = os.environ["PG_PASSWORD"]
    host = os.environ["PG_HOST"]
    port = os.environ["PG_PORT"]
    name = os.environ["PG_NAME"]

    data_dir = Path(__file__).resolve().parent.parent / "data"
    data_dir.mkdir(parents=True, exist_ok=True)

    district = ["Sham Shui Po District"]
    locality_zh = {
        "mei foo": "美孚",
        "lai chi kok": "荔枝角",
        "cheung sha wan": "長沙灣",
        "sham shui po": "深水埗",
        "shek kip mei": "石硤尾",
        "yau yat tsuen": "又一村",
        "tai wo ping": "大窩坪",
        "stonecutters island": "昂船洲",
    }

    with duckdb.connect(data_dir / "hk.db") as con:
        parquet = data_dir / "hk.parquet"
        if not parquet.exists():
            save_places(con, fsq_token)
            filter_restaurants(con, district, parquet)
            con.sql(f"""
                SELECT COUNT(*) AS n, district
                FROM '{parquet}'
                GROUP BY district
                ORDER BY n DESC;
            """).show()

        limit = None
        rows = con.execute(f"""
            SELECT fsq_place_id, name, locality, district_zh, address
            FROM '{parquet}'
        """).fetchall()
        if limit:
            rows = rows[:limit]

        load_rows = con.execute(f"""
            SELECT fsq_place_id, name, address, locality, district,
                latitude, longitude, fsq_category_labels
            FROM '{parquet}'
        """).fetchall()
        if limit:
            load_rows = load_rows[:limit]

    s3 = boto3.client("s3", config=Config(max_pool_connections=32))
    done_sources = existing_ids(s3, bucket, "sources/")

    tavily = AsyncTavilyClient(tavily_key)
    asyncio.run(fetch_sources(s3, bucket, tavily, rows, done_sources, locality_zh))

    nebius = AsyncOpenAI(
        base_url="https://api.tokenfactory.us-central1.nebius.com/v1/",
        api_key=nebius_key,
    )

    with open("nebius/prompt.md") as f:
        prompt = f.read()
    with open("nebius/schema.json") as f:
        schema = json.load(f)

    prompt = (
        prompt + "\n\n ### Schema" + json.dumps(schema, ensure_ascii=False, indent=2)
    )

    done_sources = existing_ids(s3, bucket, "sources/")
    done_profiles = existing_ids(s3, bucket, "profiles/")
    asyncio.run(
        write_profiles(
            s3, bucket, nebius, prompt, schema, rows, done_sources, done_profiles
        )
    )

    profiles = build_profiles(s3, bucket, load_rows, locality_zh)

    db = f"postgres://{user}:{password}@{host}:{port}/{name}?sslmode=disable"
    with psycopg.connect(db) as conn:
        save_profiles(conn, profiles)


def save_places(con, token):
    con.execute(f"""
        INSTALL httpfs;
        LOAD httpfs;

        CREATE SECRET iceberg_secret (
            TYPE ICEBERG,
            TOKEN '{token}'
        );

        ATTACH 'places' AS fsq (
            TYPE iceberg,
            SECRET iceberg_secret,
            ENDPOINT 'https://catalog.h3-hub.foursquare.com/iceberg'
        );
    """)

    con.execute("""
        INSTALL spatial;
        LOAD spatial;

        CREATE OR REPLACE TABLE districts AS
        SELECT *
        FROM ST_Read('https://www.had.gov.hk/psi/hong-kong-administrative-boundaries/hksar_18_district_boundary.json');
    """)

    # bbox filters before download
    long_min, lat_min, long_max, lat_max = con.execute("""
        SELECT
            ST_XMin(g),
            ST_YMin(g),
            ST_XMax(g),
            ST_YMax(g)
        FROM (
            SELECT ST_Extent(ST_Union_Agg(geom)) AS g
            FROM districts
        );
    """).fetchone()

    con.execute(
        """
        CREATE OR REPLACE TABLE places AS
        SELECT * EXCLUDE(geom)
        FROM fsq.datasets.places_os AS p
        WHERE
            p.longitude BETWEEN $1 AND $2
            AND p.latitude BETWEEN $3 AND $4
            AND ST_Within(
                ST_Point(p.longitude, p.latitude),
                (SELECT ST_Union_Agg(geom) FROM districts)
            );
        """,
        [long_min, long_max, lat_min, lat_max],
    )


def filter_restaurants(con, districts, out):
    con.execute(
        """
        COPY (
            SELECT
                p.*,
                d.district AS district,
                d."地區" AS district_zh
            FROM places AS p
            JOIN districts AS d
                ON ST_Within(ST_Point(p.longitude, p.latitude), d.geom)
            WHERE list_contains($1, d.district)
            AND len(list_filter(
                fsq_category_labels,
                lambda x : starts_with(x, 'Dining and Drinking')
                    AND split_part(x, ' > ', 2) NOT IN (
                        'Bar', 'Winery', 'Vineyard', 'Brewery', 'Distillery'
                    )
            )) > 0
            AND NOT EXISTS (
                SELECT 1
                FROM places c
                WHERE c.name = p.name
                GROUP BY name
                HAVING COUNT(*) >= 10
            )
            AND date_closed IS NULL
            AND unresolved_flags IS NULL
            ) TO $2;
        """,
        [districts, str(out)],
    )


def existing_ids(s3, bucket, prefix):
    ids = set()
    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            ids.add(obj["Key"].removeprefix(prefix).removesuffix(".json"))
    return ids


def normalize_locality(locality, transl):
    if not locality:
        return None
    loc = locality.strip().strip(",").lower()
    loc = loc.removesuffix(", hong kong").removesuffix(" district")
    if loc in transl:
        return loc
    for en, zh in transl.items():
        if loc == zh or loc == zh + "區":
            return en
    return None


def bucket_upload(s3, bucket, key, data):
    try:
        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=json.dumps(data, ensure_ascii=False, indent=2).encode("utf-8"),
        )
    except ClientError as e:
        print(f"failed to upload {key}: {e}")
        return False

    return True


def bucket_download(s3, bucket, key):
    obj = s3.get_object(Bucket=bucket, Key=key)
    return json.loads(obj["Body"].read())


def bucket_download_all(s3, bucket, prefix, ids):
    ids = list(ids)
    with ThreadPoolExecutor(max_workers=32) as pool:
        data = pool.map(
            lambda id: bucket_download(s3, bucket, f"{prefix}{id}.json"), ids
        )
    return dict(zip(ids, data))


async def fetch_source(s3, bucket, tavily, sem, row, transl):
    id, name, local, dist, _ = row

    key = normalize_locality(local, transl)
    local_clean = transl[key] if key else dist
    query = f"{name} {local_clean}"

    async with sem:
        resp = None
        for attempt in range(5):
            try:
                resp = await tavily.search(
                    query=query,
                    include_answer="advanced",
                    search_depth="basic",
                    max_results=20,
                    include_published_date=True,
                    include_images=True,
                    include_image_descriptions=True,
                    include_usage=True,
                    chunks_per_source=5,
                )
                break

            except (
                UsageLimitExceededError,
                ForbiddenError,
                TavilyBadRequestError,
                InvalidAPIKeyError,
                MissingAPIKeyError,
            ):
                raise

            except Exception as e:
                if attempt == 4:
                    print(f"failed to get sources for {id}: {e}")
                    resp = None
                    break
                await asyncio.sleep(2**attempt)

    if resp is None:
        return

    ok = await asyncio.to_thread(bucket_upload, s3, bucket, f"sources/{id}.json", resp)
    if ok:
        print(f"wrote: {id}.json to {bucket}")


async def fetch_sources(s3, bucket, client, rows, done, transl):
    sem = asyncio.Semaphore(10)

    tasks = [
        fetch_source(s3, bucket, client, sem, row, transl)
        for row in rows
        if row[0] not in done
    ]
    await asyncio.gather(*tasks)


def build_payload(s3, bucket, row):
    id, name, locality, district, address = row

    try:
        data = bucket_download(s3, bucket, f"sources/{id}.json")
    except ClientError:
        return None

    lines = [f"NAME: {name}"]
    area = locality or district
    if area:
        lines.append(f"AREA: {area}")
    if address:
        lines.append(f"ADDRESS: {address}")

    lines.append("")
    lines.append("SOURCES:")

    n = 0
    for res in data["results"]:
        url = res.get("url") or ""
        content = res.get("content") or ""
        if not content:
            continue

        title = res.get("title") or ""
        # tavily repeats the title
        if content.startswith(f"Title: {title}"):
            content = content[len(f"Title: {title}") :].lstrip()

        n += 1
        if n > 1:
            lines.append("")
        lines.append(f"[{n}] {title}")
        lines.append(url)
        lines.append(content)
        if res.get("published_date"):
            lines.append(f"({res['published_date']})")

    if n == 0:
        return None

    return "\n".join(lines)


async def write_profile(s3, bucket, client, sem, prompt, schema, row):
    id = row[0]

    payload = await asyncio.to_thread(build_payload, s3, bucket, row)
    if payload is None:
        return

    async with sem:
        resp = None
        for attempt in range(5):
            try:
                resp = await client.chat.completions.create(
                    model="nvidia/Nemotron-3-Ultra-550b-a55b",
                    messages=[
                        {"role": "system", "content": prompt},
                        {"role": "user", "content": payload},
                    ],
                    max_tokens=32000,
                    temperature=0.2,
                    response_format={"type": "json_schema", "json_schema": schema},
                )
                break

            except (AuthenticationError, BadRequestError):
                raise

            except Exception as e:
                if attempt == 4:
                    print(f"failed to write profile for {id}: {e}")
                    resp = None
                    break
                await asyncio.sleep(2**attempt)

        if resp is None:
            return

        msg = resp.choices[0].message
        if msg.refusal:
            print(f"refused profile: {id}")
            return

        try:
            data = json.loads(msg.content)
        except json.JSONDecodeError:
            print(f"failed to decode json: {id}")
            return

        if resp.choices[0].finish_reason == "length":
            print(f"truncated profile: {id}")
            return

        ok = await asyncio.to_thread(
            bucket_upload, s3, bucket, f"profiles/{id}.json", data
        )
        if ok:
            print(f"wrote: profiles/{id}.json")


async def write_profiles(
    s3, bucket, client, prompt, schema, rows, done_sources, done_profiles
):
    sem = asyncio.Semaphore(10)

    tasks = [
        write_profile(s3, bucket, client, sem, prompt, schema, row)
        for row in rows
        if row[0] in done_sources and row[0] not in done_profiles
    ]

    await asyncio.gather(*tasks)


def build_profiles(s3, bucket, rows, transl):
    done = existing_ids(s3, bucket, "profiles/")
    results = bucket_download_all(s3, bucket, "profiles/", done)

    profiles = []
    for id, name, address, locality, district, lat, lon, labels in rows:
        profile = results.get(id)
        if profile is None or not profile["is_match"]:
            continue

        dining = next((l for l in labels if l.startswith("Dining and Drinking")), None)
        category = dining.split(" > ")[-1]

        key = normalize_locality(locality, transl)
        area = key.title() if key else district.removesuffix(" District")

        profiles.append(
            (
                id,
                name,
                category,
                address or "",
                area,
                Jsonb(profile["answers"]),
                profile["price_level"],
                lat,
                lon,
            )
        )

    return profiles


def save_profiles(conn, profiles):
    conn.cursor().executemany(
        """
        INSERT INTO restaurants
            (fsq_id, name, category, address, area, answers, price_level, lat, lon)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (fsq_id) DO UPDATE SET
            name = EXCLUDED.name,
            category = EXCLUDED.category,
            address = EXCLUDED.address,
            area = EXCLUDED.area,
            answers = EXCLUDED.answers,
            price_level = EXCLUDED.price_level,
            lat = EXCLUDED.lat,
            lon = EXCLUDED.lon
        """,
        profiles,
    )


if __name__ == "__main__":
    main()
