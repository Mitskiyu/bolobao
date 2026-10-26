import json
from pathlib import Path
from string import capwords

from bolobao.places import Place

AREA_ZH: dict[str, dict[str, str]] = json.loads(
    (Path(__file__).parent / "areas.json").read_text()
)
DISTRICTS = list(AREA_ZH)


def zh(place: Place) -> str:
    key = _normalize(place)
    return AREA_ZH[place.district][key] if key else place.district_zh


def en(place: Place) -> str:
    key = _normalize(place)
    return capwords(key) if key else place.district.removesuffix(" District")


def _normalize(place: Place) -> str | None:
    if not place.locality:
        return None

    loc = place.locality.strip().strip(",").lower()
    loc = loc.split(",")[0].strip().removesuffix(" district")

    areas = AREA_ZH.get(place.district, {})
    if loc in areas:
        return loc

    for english, chinese in areas.items():
        if loc in (chinese, chinese + "區"):
            return english

    return None
