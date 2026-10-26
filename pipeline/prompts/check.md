# Checking Restaurant Outputs

Provided are a Hong Kong restaurant's name and location details, an output of the restaurant written by a model, and the web search sources the output was written from.

The sources are usually written in Traditional Chinese. The output is written in English, with some dish names in Chinese. Make sure everything you write is in English.
The sources are given in full below. Each starts with a number in brackets, a title, its URL, then its text. Find an answer's source by matching its URL. Do not try to visit any URL.
Addresses may appear in English or Chinese. The same address in either language is the same address.
A source's title and URL count as part of the source, including any address or area in them.
Sham Shui Po includes Cheung Sha Wan, Lai Chi Kok, Shek Kip Mei, Mei Foo, Nam Cheong and Yau Yat Chuen. A source naming any of these is in this area.

Your task is to check every answer in the output against its source, and check whether the restaurant is still open.

Do this by answering the questions below, in order.

## 1. Is every answer supported by its source?

First, read all the sources and list every address they give for a restaurant with this name, other than the one above. Write them in namesakes, or "none".

The answers are only the items in the answers list. price_level is not an answer; check it only in price_reason and price_supported.

Then, for every answer, find the source its URL points to. If the URL does not appear in the sources, the answer is not supported. Otherwise, check in this order:

1. Is the source about this restaurant? Write the result in about_this_place.
   - If it gives an address that differs from the one above, or names a street or area outside this restaurant's area, it is about a different branch or a restaurant with the same name. It is not about this restaurant.
   - If it gives no address and points nowhere else, it is about this restaurant.
2. Does the source actually say this? An answer that adds to, exaggerates or reverses what the source says is not supported.

If about_this_place is false, supported is false.

Review counts, ratings and platform metadata are not support. Only what a person wrote about the restaurant counts.
For each answer, say in one line which part of the source supports it, or why it is not supported.

Also check price_level. It is supported if the sources state a price level or range that maps to it: $ = 1, $$ = 2, $$$ = 3, $$$$ = 4; under HK$50 = 1, HK$51-100 = 2, HK$101-200 = 3, over HK$200 = 4. An open-ended band takes the level its upper bound falls in. If sources disagree, the majority decides. A null price_level is always supported.

## 2. Is the restaurant still open?

Check whether any source about this restaurant says it has closed, closed permanently, or moved away from this address.
Only count sources about this restaurant at this address, following the same rules as above.
If no source says so, it is open.

## Response

Make sure your response is one JSON object, matching the provided schema.
