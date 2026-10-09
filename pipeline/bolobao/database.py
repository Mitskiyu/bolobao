from typing import NamedTuple

import psycopg
from psycopg.types.json import Jsonb

from bolobao import areas
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


def rows(places: list[Place], results: dict[str, Output]) -> list[Row]:
    out: list[Row] = []

    for place in places:
        result = results.get(place.id)
        if result is None or not result["is_match"]:
            continue

        dining = next(
            (l for l in place.labels if l.startswith("Dining and Drinking")), None
        )
        if dining is None:
            continue

        out.append(
            Row(
                fsq_id=place.id,
                name=place.name,
                category=dining.split(" > ")[-1],
                address=place.address or "",
                area=areas.en(place),
                answers=Jsonb(result["answers"]),
                price_level=result["price_level"],
                lat=place.lat,
                lon=place.lon,
            )
        )

    return out


def upsert(conn: psycopg.Connection, rows: list[Row]):
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
        WHERE (restaurants.name, restaurants.category, restaurants.address, restaurants.area,
            restaurants.answers, restaurants.price_level, restaurants.lat, restaurants.lon)
        IS DISTINCT FROM
            (EXCLUDED.name, EXCLUDED.category, EXCLUDED.address, EXCLUDED.area,
            EXCLUDED.answers, EXCLUDED.price_level, EXCLUDED.lat, EXCLUDED.lon)
        """,
        rows,
    )
