import asyncio
import logging
import os
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from dataclasses import dataclass
from typing import Any, Literal

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError
from dotenv import load_dotenv
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from mypy_boto3_s3 import S3Client
from openai import AsyncOpenAI
from openai.types.shared_params.response_format_json_schema import JSONSchema
from psycopg_pool import ConnectionPool
from pydantic import BaseModel
from tavily import AsyncTavilyClient

from bolobao import bucket, database, judge, model, prompts, sources
from bolobao.judge import Verdict
from bolobao.model import Output
from bolobao.places import Place

log = logging.getLogger(__name__)


@dataclass(frozen=True, kw_only=True, slots=True)
class Deps:
    bucket_name: str
    s3: S3Client
    tavily: AsyncTavilyClient
    nebius: AsyncOpenAI
    pool: ConnectionPool
    enrich: tuple[str, JSONSchema]
    check: tuple[str, JSONSchema]
    rate: tuple[str, JSONSchema]


Phase = Literal["read", "wrote", "checked", "done", "refused", "failed"]


class Event(BaseModel):
    phase: Phase


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    load_dotenv()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )
    logging.getLogger("botocore").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpx2").setLevel(logging.WARNING)

    app.state.deps = Deps(
        bucket_name=os.environ["S3_BUCKET"],
        s3=boto3.client("s3", config=Config(max_pool_connections=32)),
        tavily=AsyncTavilyClient(os.environ["TAVILY_KEY"]),
        nebius=AsyncOpenAI(
            base_url="https://api.tokenfactory.us-central1.nebius.com/v1/",
            api_key=os.environ["NEBIUS_KEY"],
        ),
        pool=ConnectionPool(
            kwargs={
                "user": os.environ["PG_USER"],
                "password": os.environ["PG_PASSWORD"],
                "host": os.environ["PG_HOST"],
                "port": os.environ["PG_PORT"],
                "dbname": os.environ["PG_NAME"],
            },
            max_size=5,
        ),
        enrich=prompts.load("enrich"),
        check=prompts.load("check"),
        rate=prompts.load("rate"),
    )

    yield


app = FastAPI(lifespan=lifespan)


@app.post("/profiles/{fsq_id}", response_class=StreamingResponse)
async def create_profile(fsq_id: str, request: Request):
    deps: Deps = request.app.state.deps
    sem = asyncio.Semaphore(1)

    try:
        place = await asyncio.to_thread(load_place, deps.pool, fsq_id)
        if place is None:
            yield event("failed")
            return

        if await load_json(deps, f"{sources.PREFIX}{fsq_id}.json") is None:
            await sources.fetch(deps.bucket_name, deps.s3, deps.tavily, sem, place)

        yield event("read")

        output_key = f"{model.PREFIX}{fsq_id}.json"
        output: Output | None = await load_json(deps, output_key)
        if output is None:
            await model.enrich(
                deps.bucket_name, deps.s3, deps.nebius, sem, *deps.enrich, place
            )
            output = await load_json(deps, output_key)

        if output is None:
            yield event("failed")
            return

        if not output["is_match"]:
            yield event("refused")
            return

        yield event("wrote")

        verdict_key = f"{judge.PREFIX}{fsq_id}.json"
        verdict: Verdict | None = await load_json(deps, verdict_key)
        if verdict is None:
            await judge.review(
                deps.bucket_name,
                deps.s3,
                deps.nebius,
                sem,
                *deps.check,
                *deps.rate,
                place,
            )
            verdict = await load_json(deps, verdict_key)

        if verdict is None:
            yield event("failed")
            return

        yield event("checked")

        profiles = database.profiles([place], {fsq_id: output}, {fsq_id: verdict})
        if not profiles:
            yield event("refused")
            return

        await asyncio.to_thread(save_profiles, deps.pool, profiles)
        yield event("done")

    except Exception:
        log.exception("failed to create profile for %s", fsq_id)
        yield event("failed")


def event(phase: Phase) -> str:
    return f"data: {Event(phase=phase).model_dump_json()}\n\n"


async def load_json(deps: Deps, key: str) -> Any:
    try:
        return await asyncio.to_thread(bucket.get_json, deps.bucket_name, deps.s3, key)
    except ClientError:
        return None


def load_place(pool: ConnectionPool, fsq_id: str) -> Place | None:
    with pool.connection() as con:
        return database.get_place(con, fsq_id)


def save_profiles(pool: ConnectionPool, profiles: list[database.Profile]):
    with pool.connection() as con:
        database.upsert_profiles(con, profiles)
