<p align="center">
  <img src="ios/Assets.xcassets/bolobao-transparent.imageset/bolobao-transparent.png" alt="Bolobao" width="128">
</p>
<h1 align="center">Bolobao</h1>
<p align="center">
  Swipe on Hong Kong restaurant profiles, based on what people actually wrote about each place
  <br />
  <a href="https://testflight.apple.com/join/5qfRfknx"><img src="https://img.shields.io/badge/TestFlight-0D96F6?logo=apple&logoColor=white" alt="TestFlight"></a>
</p>

## About

Bolobao reads what people wrote about Hong Kong restaurants, mostly in Chinese, works out which shop each source is about, and writes a short English profile you can swipe through. Every line is checked against its source before it reaches the app.

All models are NVIDIA Nemotron, running on Nebius Token Factory: Nemotron 3 Ultra writes the profiles, Nemotron 3 Super judges them, and Nemotron 3.5 Super VL picks the photos. The backend is hosted on Nebius AI Cloud.

## How it works

The steps run in order, in the pipeline or in real time when you add a place in the app.

- Places (Foursquare OS Places)
    - Lists the restaurants in Hong Kong
- Search (Tavily)
    - Finds what people wrote about each place
- Write (Nemotron 3 Ultra)
    - Turns the sources into a short English profile
- Judge (Nemotron 3 Super)
    - Checks each line against its source and drops what isn't supported
    - Rates what's left and keeps only useful profiles
- Photos (Nemotron 3.5 Super VL)
    - Picks a photo from the search results

## Development

```
# env + postgres
cp .env.example .env # fill in required fields
docker compose up -d

# api
go tool goose up
go tool air

# pipeline (python 3.14 + uv)
cd pipeline && uv run main.py
cd pipeline && uv run fastapi dev server.py

# ios
cp ios/Local.xcconfig.example ios/Local.xcconfig # set api url
# build & run in xcode
```
