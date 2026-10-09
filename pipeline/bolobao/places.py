from dataclasses import dataclass
from pathlib import Path

from duckdb import DuckDBPyConnection


@dataclass(frozen=True, kw_only=True, slots=True)
class Place:
    id: str
    name: str
    address: str | None
    locality: str | None
    district: str
    district_zh: str
    lat: float
    lon: float
    labels: list[str]


def download(con: DuckDBPyConnection, token: str):
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
    row = con.execute("""
        SELECT
            ST_XMin(g),
            ST_XMax(g),
            ST_YMin(g),
            ST_YMax(g)
        FROM (
            SELECT ST_Extent(ST_Union_Agg(geom)) AS g
            FROM districts
        );
    """).fetchone()
    if row is None:
        raise RuntimeError("no district boundaries loaded")

    long_min, long_max, lat_min, lat_max = row
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


def export(con: DuckDBPyConnection, districts: list[str], out: Path):
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


def load(con: DuckDBPyConnection, parquet: Path) -> list[Place]:
    con.execute(f"""
        SELECT
            fsq_place_id AS id, name, address, locality,
            district, district_zh,
            latitude AS lat, longitude AS lon,
            fsq_category_labels AS labels
        FROM '{parquet}'
    """)
    cols = [d[0] for d in con.description]
    return [Place(**dict(zip(cols, row))) for row in con.fetchall()]
