# Picking Restaurant Photos

Provided are a Hong Kong restaurant's name and location details, then images numbered from 1. Each image comes with the title of the web page it was found on, a short description of the image written by the search engine, and its size in pixels.

The images come from a web search for the restaurant's name, so some belong to other restaurants (namesakes, other branches, lists of many restaurants) and some are not useful.
Make sure everything you write is in English.

Your task is to pick the cover photo for this restaurant's profile in a food app. The photo should show the place.

Do this by answering the questions below, in order.

## 1. Which images are this restaurant?

Use the sign in the photo (it may be in Chinese), the page title and the description.
The description is a hint and may be wrong. If the sign in the photo disagrees with it, trust the sign.
A description that names this restaurant, together with a photo that fits it, is enough to tie the image to this restaurant, even if the sign is hard to read.
An image showing a different restaurant's name on a sign is not this restaurant.
A page title or description that names a different branch, area or address means the image is not this restaurant, even if the name matches.
If you can't tell whether an image is this restaurant, prefer an image you can tie to it.

## 2. Which images are usable?

Reject:
- Ads and promo graphics: delivery app product shots, images with big promotional text or banners, price tags, collages.
  Small captions, speech bubbles or stickers are fine when the place or the food is clearly the main subject.
- Menus, price lists, maps, logos, screenshots, video thumbnails with text overlays.
- Blurry, dark or low-quality photos.
- Photos where people are the main subject.
- Big watermarks. A small corner watermark is fine.
- Food that looks unappetising.

## 3. Which usable image is best?

Best first:
1. The storefront or entrance of this restaurant, sign visible.
2. The inside of this restaurant: the dining room, the counter, the atmosphere.
3. A natural, appetising photo of a dish from this restaurant.

Within the same level, prefer the sharper, better-lit, better-framed photo.

The app shows the photo in a wide box, about 5:3, cropped from the center.
A tall photo only keeps its middle band. It is still a good pick if the part that matters, such as the sign or entrance, is in that middle band. It is a bad pick if the middle band is only ceiling, floor or sky.
Do not prefer a photo only because it is wide.

If no image is usable, answer -1. A wrong or ugly photo is worse than no photo.

## Response

Write the reason first, in one or two sentences, then the image number.
Make sure your response is one JSON object, matching the provided schema.
