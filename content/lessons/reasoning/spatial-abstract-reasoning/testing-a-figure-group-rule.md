---
_id: "lesson-spatial-abstract-reasoning-testing-a-figure-group-rule"
title: "Testing a Figure Group Rule"
summary: "Test that a rule includes every figure except one."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 3
partCount: 3
ordering: 6
keyPoints:
  - "Test that a rule includes every figure except one."
---
## Core Concept

### Testing a Rule Against Every Figure

A valid grouping rule fits **every** figure in the main group and excludes **exactly one** figure. If a rule leaves out two or more figures, reject it and test another feature.

**Orientation** means which way a figure faces. Large or turned figures stand out, so test every figure before keeping a rule.

1. Five figures A to E: A small triangle ($2$ dots), B large square ($2$ dots), C small pentagon ($2$ dots), D large hexagon ($2$ dots), E small rectangle ($3$ dots).
2. Test "has a small outline": A, C, E pass, while B and D fail ($2$ excluded). Rejected.
3. Test "contains $2$ dots": A, B, C, D pass, while only E fails ($1$ excluded). Valid.

:::why
Why must a rule leave out only one figure? Odd-one-out items need one single outlier, so a $3$-to-$2$ split gives no answer.
:::

:::pair #rule-excludes-more-than-one
Right: for $4$ two-dot figures (two small, two large) and $1$ three-dot figure, pick **Contains two dots**.
Wrong: pick **Has a small outline** because small figures stand out.
Three small figures and two large figures leave two figures out, not one. Count how many fail your rule.
:::

:::check
Four figures are shown: a small circle ($1$ dot), large square ($1$ dot), small triangle ($1$ dot), and large pentagon ($2$ dots). Why does "small outline" fail, and which rule works?
:::answer
The answer is **contains $1$ dot**. "Small outline" excludes $2$ figures (square and pentagon), while "contains $1$ dot" excludes only the pentagon.
:::

### Narrowing a Too-Broad Rule

A rule that fits the main group and also fits the odd figure leaves out **zero** figures. Narrow a too-broad rule until only the odd figure fails.

1. Look at three equilateral triangles and one rhombus.
2. "Uses only straight sides" and "at least three sides" fit all $4$ figures ($0$ excluded). Both are too broad.
3. "Three sides" fits the $3$ triangles and excludes only the $4$-sided rhombus ($1$ excluded).

:::pair #rule-too-broad
Right: for three triangles and one rhombus, narrow the rule to **Three sides**.
Wrong: pick **At least three sides** because all triangles fit it.
A rhombus has $4$ sides, which is also at least $3$. Make sure the odd figure breaks your rule.
:::

:::why
Why do phrases like "at least" or "closed boundary" trap learners? They describe the main figures accurately, yet the odd figure passes them too.
:::

:::check
Four figures are shown: a square, two rectangles, and a slanted parallelogram. "Has four sides" fits all four. What rule groups three and excludes the parallelogram?
:::answer
The answer is **four square corners** (right angles). The first three have square corners, while the slanted parallelogram does not.
:::

## Examples

### #1: Testing a First Guess

Five figures are labeled A to E. A is a small square with one dot. B is a large circle with one dot.

C is a small triangle with one dot. D is a large pentagon with one dot. E is a small hexagon with two dots.

Which figure does not belong?

<!-- ILLUSTRATION: five labeled figures in one row, A small square with 1 dot, B circle twice A's height with 1 dot, C small triangle with 1 dot, D pentagon twice A's height with 1 dot, E small hexagon with 2 dots; A C and E have equal heights, B and D have equal heights -->

**Solution:**

1. Test size first: A, C, and E are small, while B and D are large. That leaves out $2$ figures, so reject size.
2. Test dot count: A, B, C, and D each have $1$ dot, while E has $2$ dots. That leaves out only E.

The odd-one-out is **E**.

**Check:** Size catches the eye because B and D are twice as tall, yet dot count is the only tested rule that includes both large figures and excludes just one.

### #2: Choosing a Rule for Four Figures

Four figures are shown: three equilateral triangles and one rhombus. The rule "all outlines have straight sides" includes every shown figure. Which more specific rule groups exactly three and excludes one?

- A. At least three sides
- B. Three sides
- C. At least one reflection axis
- D. A closed boundary

<!-- ILLUSTRATION: four unshaded outlines in one row, three identical equilateral triangles followed by one rhombus -->

**Solution:**

1. Test each choice against all four figures.
2. Count how many figures each choice leaves out.

3. Choice B leaves out exactly one figure: the three triangles have $3$ sides and pass, while the $4$-sided rhombus fails.

The answer is **B (Three sides)**.

**Check:** Choices A ($3$ and $4$ are both at least $3$), C (triangles and rhombus all have reflection axes), and D (all $4$ shapes are closed) fit all four figures ($0$ excluded); only B leaves out exactly $1$ figure.

## Traps to Watch For

:::checklist
- A rule that excludes two or more figures: reject it and test another feature until one figure fails. {#rule-excludes-more-than-one}
- A rule that fits every figure including the outlier: narrow it until the single odd figure breaks it. {#rule-too-broad}
- Eye-catching size or tilt: test the rule on all figures before locking in an answer. {#testing-a-rule-against-every-figure}
:::
