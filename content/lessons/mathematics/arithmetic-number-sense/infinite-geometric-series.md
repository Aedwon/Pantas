---
_id: "lesson-arithmetic-number-sense-infinite-geometric-series"
title: "Infinite Geometric Series"
summary: "Find the sum of a convergent infinite geometric series."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 7
partCount: 9
ordering: 807
keyPoints:
  - 'Find the sum of a convergent infinite geometric series.'
  - 'Check whether an infinite geometric series diverges.'
---
## Core Concept

An infinite series keeps adding terms without stopping. It **converges** if the running total gets closer and closer to one finite number. For example, $1+\dfrac{1}{2}+\dfrac{1}{4}+\dots$ has running totals $1,\dfrac{3}{2},\dfrac{7}{4},\dots$, which approach $2$.

The symbol $S_\infty$ means that finite sum of an infinite series. The symbol $|r|$ means the absolute value of $r$, which is its distance from $0$.

For an infinite geometric series with a nonzero first term, a finite sum exists only when $|r|<1$. The terms then shrink toward $0$, and the running total approaches:

$$S_\infty=\dfrac{a_1}{1-r}$$

If $|r|\ge1$ and the first term is nonzero, the series **diverges**. This means its running total does not approach a finite sum. If every term is $0$, the sum is simply $0$.

In exam questions, **evaluate** means find the final number answer.

## Examples

### #1: Evaluating an Infinite Geometric Series

Evaluate the infinite geometric series $18+6+2+\dfrac{2}{3}+\dots$.

**Solution:**

1. The common ratio is $r=\dfrac{1}{3}$. Since $|r|<1$, the series converges.
2. Use the infinite geometric-series formula.

$$S_\infty=\dfrac{18}{1-\frac{1}{3}}$$

3. Subtract in the denominator, then divide.

$$S_\infty=18\times\dfrac{3}{2}=27$$

### #2: An Infinite Geometric Series That Diverges

Does the infinite geometric series $3+6+12+24+\dots$ have a finite sum?

**Solution:**

1. The common ratio is $r=2$.
2. The first term is nonzero and $|r|\ge1$, so the series diverges. It does not have a finite sum.

## Traps to Watch For

### #1: Using the Infinite Sum Formula When the Series Diverges

> Check $|r|<1$ before using the infinite geometric-series sum formula.

For a nonzero first term, $|r|\ge1$ means the series has no finite sum. Using $S_\infty=\dfrac{a_1}{1-r}$ anyway can give a number that is not a valid sum.
