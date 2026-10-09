import asyncio
import logging

from mypy_boto3_s3 import S3Client
from tavily import AsyncTavilyClient
from tavily.errors import BadRequestError as TavilyBadRequestError
from tavily.errors import (
    ForbiddenError,
    InvalidAPIKeyError,
    MissingAPIKeyError,
    UsageLimitExceededError,
)

from bolobao import areas, bucket
from bolobao.places import Place

log = logging.getLogger(__name__)


async def fetch(
    bucket_name: str,
    s3: S3Client,
    tavily: AsyncTavilyClient,
    sem: asyncio.Semaphore,
    place: Place,
):
    area = areas.zh(place)
    query = f"{place.name} {area}"

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

            except Exception as e:  # noqa: BLE001
                if attempt == 4:
                    log.warning(f"failed to get sources for {place.id}: {e}")
                    resp = None
                    break
                await asyncio.sleep(2**attempt)

    if resp is None:
        return

    key = f"sources/{place.id}.json"
    if await asyncio.to_thread(bucket.put_json, bucket_name, s3, key, resp):
        log.info("wrote %s", key)


async def fetch_many(
    bucket_name: str,
    s3: S3Client,
    tavily: AsyncTavilyClient,
    places: list[Place],
):
    done = bucket.list_ids(bucket_name, s3, "sources/")
    sem = asyncio.Semaphore(10)

    tasks = [
        fetch(bucket_name, s3, tavily, sem, place)
        for place in places
        if place.id not in done
    ]
    log.info("fetching sources for %d places", len(tasks))
    await asyncio.gather(*tasks)
