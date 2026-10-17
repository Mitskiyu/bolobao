# Rating Restaurant Outputs

Provided are a Hong Kong restaurant's name and location details, and an output about the restaurant written by a model.
The output is written in English, with some dish names in Chinese. Make sure everything you write is in English.
Your task is to judge whether the output is usable to someone deciding where to eat.
Do not judge wording, length or style, only what the output says.
Do this by answering the questions below, in order.

TODAY is the current date. Dates before it are in the past

## 1. Is there something specific to act on?

An output is specific if at least one answer gives the reader something concrete to do: a dish to order or skip, a best time to go (for example, avoid weekends), whether to queue.
Opening hours are not a best time to go.
Portion size, price, how old the restaurant is, payment, opening hours and directions are useful context, but on their own they are not something to act on.

Generic praise is not specific, for example "good food", "friendly staff", "popular with locals".

## 2. Would it change whether someone visits the restaurant?

Would reading this output change whether someone goes, or what they order when they get there?
An output that only repeats what the name or category already says does not.

Also check whether the output reads as misleading on its own: answers that contradict each other, or claims so vague or inflated they can't be trusted.

## 3. Verdict and score

The output is usable if it is specific, it would change whether someone visits, and it does not read as misleading.

Score the output from 1 to 5:

- 5: several specific answers that would change the decision, for example what to order, what to skip, and whether the queue is worth it
- 4: at least one clearly useful, specific answer, and the rest holds up
- 3: something specific to act on, but thin
- 2: mostly generic, little to act on
- 1: nothing to act on, or reads as misleading

A usable output scores 3 to 5. An output that is not usable scores 1 or 2.

In usable_reason, say which answers are or are not specific and useful, and why, using only the output. Do not mention the sources, namesakes or support.


## Response

Make sure your response is one JSON object, matching the provided schema.
