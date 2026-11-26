---
_id: "lesson-verbal-logic-compound-assumptions"
title: "Compound Assumptions"
summary: "Negate compound statements by testing their parts."
subject: "subject-reasoning"
topic: "topic-verbal-logic"
isActive: true
part: 3
partCount: 8
ordering: 3
keyPoints:
  - "Negate compound statements by testing their parts."
---

## Core Concept

### Negating an And Statement

A **compound statement** joins parts with *and* or *or*. In logic, **or** is inclusive: one part, the other, or both.

An **and** claim holds only when both parts hold; it fails if *either* fails:

- **"$A$ and $B$"** negates to **"Not $A$ or not $B$."**

Negate: "The loading gate is open and the delivery vehicle is available."

1. Parts: gate is open; vehicle is available.
2. Negate each: gate is closed; vehicle is unavailable.
3. Join with **or**: **The gate is closed or the vehicle is unavailable.**

:::why
Why does *and* turn into *or* when negated? If the gate is closed while the vehicle is ready, dispatch still stops. Both parts do not need to fail together.
:::

:::pair #negate-and-with-and
Right: negating "The loading gate is open and the delivery vehicle is available" gives **The gate is closed or the vehicle is unavailable.**
Wrong: The gate is closed and the vehicle is unavailable.
Requiring both failures misses one-part breaks. One failed part already breaks *and*.
:::

:::check
Rice passes only if its seal is intact and its code is legible. With a torn seal and clear code, does it pass?
:::answer
The answer is **no**. An *and* rule requires both parts, so one torn seal makes the sack fail.
:::

### Negating an Or Statement

An **inclusive or** holds if $A$, $B$, or both hold; it fails only when *both* fail:

- **"$A$ or $B$"** negates to **"Neither $A$ nor $B$."**

Negate: "The request was submitted online or delivered in person."

1. Options: submitted online; delivered in person.
2. Delivered in person alone keeps the notice true.
3. Exact negation: **It was neither submitted online nor delivered in person.**

:::pair #negate-or-with-or
Right: negating "The request was submitted online or delivered in person" gives **It was neither submitted online nor delivered in person.**
Wrong: It was not submitted online, or it was not delivered in person.
Keeping *or* leaves one option true (such as in-person delivery). An *or* claim fails only when *both* fail.
:::

:::check
"The water came from the barrel or cistern (or both)." If false, what holds?
:::answer
The answer is **The sample came from neither source.** Ruling out one source or ruling out a mix still leaves *or* true.
:::

### Negating Combined Parts Inside And/Or

When *at least one* sits inside *and*, flip the outer connector and negate both parts.

Negate: "The station has a working battery and at least one of its two memory cards has room."

1. Flip **and** to **or**.
2. Negate Part $1$: "the station has no working battery."
3. Negate Part $2$ (*at least one* $\to$ zero): "neither card has room."
4. Result: **The station has no working battery or neither card has room.**

:::pair #mix-at-least-one-part
Right: negating "the station has a working battery and at least one of its two memory cards has room" gives **The station has no working battery or neither card has room.**
Wrong: The battery fails or at least one memory card is full.
With a good battery, one full card, and one card with room, the original still holds. Negate "at least one has room" to "neither has room."
:::

:::check
What is the negation of "The backup generator starts or at least one of the two solar batteries is charged"?
:::answer
The answer is **The backup generator does not start, and neither solar battery is charged.** Flip *or* to *and*, and negate "at least one is charged" to "neither is charged."
:::

## Examples

### #1: Testing an And Assumption

Argument: "The office will send every form through its scanner and network today, submitting all forms today." Negate "The scanner works and the network is available" and explain.

**Solution:**

1. Split the parts: scanner works; network is available.
2. Flip *and* to *or* and negate both parts: **the scanner does not work or the network is not available**.
3. If either fails, forms cannot finish both steps, so the reason fails.

**Check:** Either a broken scanner alone or a down network alone stops submissions today.

### #2: Testing an And Claim with One Part False

A claim says a footbridge crosses the creek and meets the school path. It crosses the creek yet ends at a fenced lot with no path access. What follows?

**Solution:**

1. Connector: **and** (crosses creek *and* connects to path).
2. Check parts: crossing holds; path access fails.
3. One failed link makes the *and* claim false.

**Check:** Failing one required link already falsifies an *and* claim without disproving the crossing.

### #3: Negating a Nested Compound Assumption

A buoy report assumes, "The radio transmitter is active, and at least one of the two depth sensors is calibrated." Which is the exact negation?

(A) The radio transmitter is off, and both depth sensors are uncalibrated.
(B) The radio transmitter is off, or at least one depth sensor is uncalibrated.
(C) The radio transmitter is off, or neither depth sensor is calibrated.

**Solution:**

1. Flip **and** to **or**, ruling out (A).
2. Negate "radio transmitter is active" to "radio transmitter is off."

:::try
Finish the last step: negate "at least one of the two depth sensors is calibrated" and choose (B) or (C).
:::answer
The answer is **(C) The radio transmitter is off, or neither depth sensor is calibrated.** "At least one calibrated" becomes false only when zero sensors are calibrated (*neither*), while (B) leaves the other sensor calibrated.

**Check:** With an active transmitter, one calibrated sensor, and one uncalibrated sensor, the original holds and (C) is false, whereas (B) would wrongly mark it false.
:::

## Speed Tricks & Shortcuts

**Flip the connector and negate every part.** *And* flips to *or*; *or* flips to *neither-nor*.

## Traps to Watch For

:::checklist
- Negating an *and* claim: use *or* so one failure breaks the claim. {#negate-and-with-and}
- Negating an *or* claim: use *neither-nor* so both options must fail. {#negate-or-with-or}
- *At least one* inside a compound claim: negate it to *neither* or *none*. {#mix-at-least-one-part}
:::
