---
_id: "lesson-physics-significant-figures-and-rounding"
title: "Significant Figures and Rounding"
summary: "Count significant digits and round measured results."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 6
partCount: 7
ordering: 6
keyPoints:
  - "Count significant figures and round a result for the operation used."
---
## Core Concept

### Significant Figures

A measured number carries only as many digits as the instrument can give. **Significant figures** are the digits that carry meaning in a measured number. The counting rules:

- Every nonzero digit counts.
- A zero between two nonzero digits counts: $1005$ has $4$ significant figures and $2.05$ has $3$.
- A zero at the start of a number does not count: $0.0042$ has $2$ significant figures.
- A zero at the end counts if the number has a decimal point: $2.50$ has $3$, and $1200.$ has $4$. In $1200$ with no decimal point, the zeros are unclear. Scientific notation settles it: $1.2 \times 10^3$ has $2$ and $1.200 \times 10^3$ has $4$.

Exact numbers have unlimited significant figures. These are counted numbers (such as $12$ eggs) and defined values (such as $100\ \text{cm} = 1\ \text{m}$).

Two rounding rules for results:

- When you multiply or divide, keep as many significant figures as the measured number with the fewest.
- When you add or subtract, keep as many decimal places as the measured number with the fewest decimal places.

Round once, at the end of the whole calculation, not after every step. The examples below treat given values as exact unless the question says they are measured.

## Examples

### #1: Significant Figures in a Calculation

A metal plate is measured to be $4.2\ \text{cm}$ long and $3.15\ \text{cm}$ wide. Find its area, using the significant figures of the measurements. Then add two measured masses, $12.11\ \text{g}$ and $0.3\ \text{g}$, and round the sum correctly.

**Solution:**
The area is a multiplication. The sum is an addition. Each has its own rule.

1. Multiply length by width.

$$4.2 \times 3.15 = 13.23\ \text{cm}^2$$

2. Here $4.2$ has $2$ significant figures and $3.15$ has $3$. Keep $2$ significant figures: the area is $13\ \text{cm}^2$.
3. Add the masses.

$$12.11 + 0.3 = 12.41\ \text{g}$$

4. Here $12.11$ has $2$ decimal places and $0.3$ has $1$. Keep $1$ decimal place: the sum is $12.4\ \text{g}$.

## Traps to Watch For

### #1: Mixing Up the Significant-Figure Rules

> The rule depends on the operation: significant figures for multiplying and dividing, decimal places for adding and subtracting.

A sum like $12.11 + 0.3$ is rounded to one decimal place, giving $12.4$, even though $0.3$ has just one significant figure. Zeros also need care: leading zeros do not count, but the trailing zero in $2.50$ does. Defined values, like $100\ \text{cm}$ in a meter, are exact and do not limit the answer.
