# Restaurant Outputs

Provided are web search sources and location details about a named restaurant in Hong Kong.
The sources are usually written in Traditional Chinese. Make sure everything you write is in English, except dish names as described below.
The sources are given in full below. Each starts with a number in brackets, a title, its URL, then its text. A source's title and URL count as part of the source, including any address or area in them.
Addresses may appear in English or Chinese. The same address in either language is the same address.
Your task is to write about the restaurant by answering the questions below, in order.

## 1. Is this the right restaurant?

Then decide which sources are about this restaurant:
- A source that gives a different address, or names a street or area outside this restaurant's area, is about a different branch or a restaurant with the same name. Do not use it, and do not assume two different addresses are the same place.
- A source that gives no address and points nowhere else is about this restaurant.
- One source about this restaurant at this address is enough for a match.
- If this restaurant has no address, it is a match only if the sources describe a single restaurant with this name in this area. If they describe several, it is not a match.

The DISTRICT line lists the neighbourhoods in this restaurant's district. A source naming any of them is in this area.

It is not a match if:
- no source is about this restaurant at this address
- a source about this restaurant says it has closed or moved away from this address
- the place is not a restaurant, for example a shop, market stall or trading company

If it is not a match, return the empty schema and say why in match_evidence.
Only move on if it is a match. From here on, use only sources that are about this restaurant.

## 2. What can we truthfully answer?

Answer each prompt in one short line of at most 10 words, the way someone who eats there would say it.
Keep the concrete detail: name the dish, the price or the time. A short answer that names something beats a longer one that doesn't.
  Bad: Wide variety of sushi
  Good: Two-person set with flamed salmon and crab roe chawanmushi
Review counts, photo counts, ratings and platform metadata are not evidence. Only use what a person wrote about the restaurant.
Give the URL of the source the answer came from, copied exactly.

Answer at most 5 prompts. If more than 5 fit, keep the ones that would change whether someone goes: what to order, what to skip, whether it's worth the wait, what the room is like.
If any source names a dish worth ordering, answer best_dish or what_to_order_first before anything else.
Never answer with what the restaurant does not have or do, for example "no breakfast".

Every answer must say only what its source says. Do not upgrade a claim: a dish in a list of main dishes is not a signature dish, and "liked it" is not "the best".
Never infer a dish from a cuisine type or the restaurant's name.
Never pick a dish because a source lists it first.
Use each dish in only one answer.
Give years and dates as the source states them, for example "Since 1973" or "Opened December 2025". Never work out an age or write "last year".

Writing:
- No em dashes or semicolons.
- Never mention where information came from: no "reviewer", "source", "listed", "official site", "video" or "menu".
- Never use these words, even when a source does: signature, must-try, must-eat, expertly, elegant, authentic, hidden gem. A source calling a dish its signature is still evidence for best_dish. Say what the source says about the dish instead, for example "The roast goose is smoky and crisp" or "The roast goose is excellent" if a source praises it that way.
- Dish names: always an English name first, then 「Chinese」 only if the Chinese appears verbatim in the source. Use corner brackets only, never parentheses or quotes.
  Bad: Tea Teddies 「Tea Teddies」
  Bad: Hainan chicken rice (海南雞飯)
  Bad: 素鵝
  Good: pan-fried beef noodles 「炒牛河」
  Good: Tea Teddies

Prompts:
- best_dish: A dish a source calls a signature, must-eat, recommended or famous for. If several are named, choose the one most praised across sources. If none stands out, leave it out. A dish only listed among other dishes is not enough. best_dish and what_to_order_first must be different dishes.
- what_to_order_first: The dish to start with when several are named and none is singled out.
- order_this_if_its_your_second_time: A dish worth coming back for, if you've already had the best dish.
- order_this_not_that: A source preferring one dish over another. Name both.
- what_to_skip: A dish criticised with nothing suggested in its place.
- known_for: What the restaurant is known for beyond a dish, for example a technique, recipe or reputation. One fact, not a list. If the only thing that comes up is about the room, use room_vibe instead. The restaurant's own promotional copy doesn't count.
- portion_size: How big the portions are.
- value_for_money: Whether the food justifies the price.
- worth_the_queue: Whether or not the wait was worth it.
- wait_time: How long the food took to arrive, or how long it took to be seated.
- busy: Whether the restaurant gets busy, and how much.
- need_to_book: Only if a reservation is required or strongly recommended.
- opening_hours: Only exceptional hours, for example open until midnight or from 5am. Normal hours like 11:30 to 21:00 are not exceptional.
- best_time: A time of day or day of week a source recommends.
- breakfast: Only if breakfast is served, and what.
- service: What the staff are like, for example rude or fast.
- how_old: When the restaurant or chain opened.
- cash_only: Only if the restaurant is cash only.
- share_table: Whether strangers are seated together at busy times.
- getting_there: Only if the way there is notable, for example upstairs in an industrial building, inside a market, or along the waterfront. Not MTR exits or walking times.
- spice_level: How spicy the food is, and whether there's a choice.
- drinks: What drinks are worth having.
- room_vibe: How it feels to sit in the restaurant.

## 3. How expensive is an average visit?

Price levels range from 1 to 4, per person.

- price_level: 1 = under HK$50, 2 = HK$51-100, 3 = HK$101-200, 4 = over HK$200

Symbols map directly: $ = 1, $$ = 2, $$$ = 3, $$$$ = 4.
Price ranges written as text count too: "HKD100以下" or "$51-100" means level 2, "under HK$50" means level 1, "$101-200" means level 3, "over HK$200" means level 4.
An open-ended band takes the level its upper bound falls in.
If three or more sources disagree, use the majority. If there is no clear majority, leave it null.
If no source states a price level, or two sources disagree, leave it null.

## Response

Make sure your response is one JSON object, matching the provided schema.
