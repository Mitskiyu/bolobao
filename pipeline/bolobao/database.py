import logging
from typing import NamedTuple

import psycopg
from psycopg.types.json import Jsonb

from bolobao import areas
from bolobao.judge import Verdict
from bolobao.model import Output
from bolobao.places import Place


class Restaurant(NamedTuple):
    fsq_id: str
    name: str
    category: str
    address: str
    area: str
    locality: str
    district: str
    district_zh: str
    labels: list[str]
    lat: float
    lon: float


class Profile(NamedTuple):
    fsq_id: str
    answers: Jsonb
    price_level: int | None
    score: float


log = logging.getLogger(__name__)


def restaurants(places: list[Place]) -> list[Restaurant]:
    out: list[Restaurant] = []

    for place in places:
        dining = next(
            (l for l in place.labels if l.startswith("Dining and Drinking")), None
        )
        if dining is None:
            continue

        out.append(
            Restaurant(
                fsq_id=place.id,
                name=place.name,
                category=dining.split(" > ")[-1],
                address=place.address or "",
                area=areas.en(place),
                locality=place.locality or "",
                district=place.district,
                district_zh=place.district_zh,
                labels=place.labels,
                lat=place.lat,
                lon=place.lon,
            )
        )

    return out


def profiles(
    places: list[Place], outputs: dict[str, Output], verdicts: dict[str, Verdict]
) -> list[Profile]:
    out: list[Profile] = []

    for place in places:
        output = outputs.get(place.id)
        verdict = verdicts.get(place.id)
        if output is None or not output["is_match"] or verdict is None:
            continue
        if not verdict["usable"] or verdict["closed"]:
            continue

        supported = {c["prompt"] for c in verdict["answers"] if c["supported"]}
        answers = [a for a in output["answers"] if a["prompt"] in supported]
        if not answers:
            continue

        out.append(
            Profile(
                fsq_id=place.id,
                answers=Jsonb(answers),
                price_level=output["price_level"]
                if verdict["price_supported"]
                else None,
                score=verdict["score"],
            )
        )

    return out


def upsert_restaurants(conn: psycopg.Connection, restaurants: list[Restaurant]):
    log.info("upserting %d restaurants", len(restaurants))
    cur = conn.cursor()
    cur.executemany(
        """
        INSERT INTO restaurants
            (fsq_id, name, category, address, area, locality, district,
            district_zh, labels, lat, lon)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (fsq_id) DO UPDATE SET
            name = EXCLUDED.name,
            category = EXCLUDED.category,
            address = EXCLUDED.address,
            area = EXCLUDED.area,
            locality = EXCLUDED.locality,
            district = EXCLUDED.district,
            district_zh = EXCLUDED.district_zh,
            labels = EXCLUDED.labels,
            lat = EXCLUDED.lat,
            lon = EXCLUDED.lon
        WHERE (restaurants.name, restaurants.category, restaurants.address,
            restaurants.area, restaurants.locality, restaurants.district,
            restaurants.district_zh, restaurants.labels, restaurants.lat,
            restaurants.lon)
        IS DISTINCT FROM
            (EXCLUDED.name, EXCLUDED.category, EXCLUDED.address,
            EXCLUDED.area, EXCLUDED.locality, EXCLUDED.district,
            EXCLUDED.district_zh, EXCLUDED.labels, EXCLUDED.lat,
            EXCLUDED.lon)
        """,
        restaurants,
    )

    log.info("changed %d restaurants", cur.rowcount)


def upsert_profiles(conn: psycopg.Connection, profiles: list[Profile]):
    log.info("upserting %d profiles", len(profiles))
    cur = conn.cursor()
    cur.executemany(
        """
        INSERT INTO restaurant_profiles
            (restaurant_id, answers, price_level, score)
        SELECT id, %(answers)s, %(price_level)s, %(score)s
        FROM restaurants
        WHERE fsq_id = %(fsq_id)s
        ON CONFLICT (restaurant_id) DO UPDATE SET
            answers = EXCLUDED.answers,
            price_level = EXCLUDED.price_level,
            score = EXCLUDED.score
        WHERE (restaurant_profiles.answers, restaurant_profiles.price_level,
            restaurant_profiles.score)
        IS DISTINCT FROM
            (EXCLUDED.answers, EXCLUDED.price_level, EXCLUDED.score)
        """,
        [p._asdict() for p in profiles],
    )

    log.info("changed %d profiles", cur.rowcount)
