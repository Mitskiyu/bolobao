import logging
from typing import NamedTuple

import psycopg
from psycopg.types.json import Jsonb

from bolobao import areas
from bolobao.judge import Verdict
from bolobao.model import Output
from bolobao.places import Place


class Row(NamedTuple):
    fsq_id: str
    name: str
    category: str
    address: str
    area: str
    answers: Jsonb
    price_level: int | None
    lat: float
    lon: float
    score: float


log = logging.getLogger(__name__)


def rows(
    places: list[Place], outputs: dict[str, Output], verdicts: dict[str, Verdict]
) -> list[Row]:
    out: list[Row] = []

    for place in places:
        output = outputs.get(place.id)
        verdict = verdicts.get(place.id)
        if output is None or not output["is_match"] or verdict is None:
            continue
        if not verdict["usable"] or verdict["closed"]:
            continue

        dining = next(
            (l for l in place.labels if l.startswith("Dining and Drinking")), None
        )
        if dining is None:
            continue

        supported = {c["prompt"] for c in verdict["answers"] if c["supported"]}
        answers = [a for a in output["answers"] if a["prompt"] in supported]
        if not answers:
            continue

        out.append(
            Row(
                fsq_id=place.id,
                name=place.name,
                category=dining.split(" > ")[-1],
                address=place.address or "",
                area=areas.en(place),
                answers=Jsonb(answers),
                price_level=output["price_level"]
                if verdict["price_supported"]
                else None,
                lat=place.lat,
                lon=place.lon,
                score=verdict["score"],
            )
        )

    return out


def upsert(conn: psycopg.Connection, rows: list[Row]):
    log.info("upserting %d restaurants", len(rows))
    cur = conn.cursor()
    cur.executemany(
        """
        INSERT INTO restaurants
            (fsq_id, name, category, address, area, answers, price_level, lat, lon, score)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (fsq_id) DO UPDATE SET
            name = EXCLUDED.name,
            category = EXCLUDED.category,
            address = EXCLUDED.address,
            area = EXCLUDED.area,
            answers = EXCLUDED.answers,
            price_level = EXCLUDED.price_level,
            lat = EXCLUDED.lat,
            lon = EXCLUDED.lon,
            score = EXCLUDED.score
        WHERE (restaurants.name, restaurants.category, restaurants.address, restaurants.area,
            restaurants.answers, restaurants.price_level, restaurants.lat, restaurants.lon,
            restaurants.score)
        IS DISTINCT FROM
            (EXCLUDED.name, EXCLUDED.category, EXCLUDED.address, EXCLUDED.area,
            EXCLUDED.answers, EXCLUDED.price_level, EXCLUDED.lat, EXCLUDED.lon,
            EXCLUDED.score)
        """,
        rows,
    )

    log.info("changed %d restaurants", cur.rowcount)
