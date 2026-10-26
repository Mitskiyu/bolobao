from bolobao.places import Place

DISTRICTS = [
    "Central and Western District",
    "Wan Chai District",
    "Eastern District",
    "Southern District",
    "Yau Tsim Mong District",
    "Sham Shui Po District",
    "Kowloon City District",
    "Wong Tai Sin District",
    "Kwun Tong District",
    "Kwai Tsing District",
    "Tsuen Wan District",
    "Tuen Mun District",
    "Yuen Long District",
    "North District",
    "Tai Po District",
    "Sha Tin District",
    "Sai Kung District",
    "Islands District",
]

AREA_ZH = {
    "mei foo": "美孚",
    "lai chi kok": "荔枝角",
    "cheung sha wan": "長沙灣",
    "sham shui po": "深水埗",
    "shek kip mei": "石硤尾",
    "yau yat tsuen": "又一村",
    "tai wo ping": "大窩坪",
    "stonecutters island": "昂船洲",
}


def zh(place: Place) -> str:
    key = _normalize(place.locality)
    return AREA_ZH[key] if key else place.district_zh


def en(place: Place) -> str:
    key = _normalize(place.locality)
    return key.title() if key else place.district.removesuffix(" District")


def _normalize(locality: str | None) -> str | None:
    if not locality:
        return None

    loc = locality.strip().strip(",").lower()
    loc = loc.removesuffix(", hong kong").removesuffix(" district")
    if loc in AREA_ZH:
        return loc

    for english, chinese in AREA_ZH.items():
        if loc == english or loc == chinese + "區":
            return english

    return None
