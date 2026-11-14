---
_id: "lesson-arithmetic-number-sense-finite-geometric-series"
title: "Finite Geometric Series"
summary: "Find a finite geometric sum when the ratio is not one."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 6
partCount: 9
ordering: 806
keyPoints:
  - 'Find a finite geometric sum when the ratio is not one.'
  - 'Find a finite geometric sum when the ratio is one.'
---
## Core Concept

The symbol $a_1$ means the first term. The symbol $a_n$ means the term in position $n$. When finding a sum, $n$ is the number of terms being added.

The symbol $S_n$ means the sum of the first $n$ terms. The letters $d$ and $r$ mean the common difference and common ratio.

For a finite geometric series with $r\ne1$:

$$S_n=\dfrac{a_1(1-r^n)}{1-r}$$

To see why this works, multiply the sum by $r$. Subtract this new sum from the original sum. The middle terms cancel, leaving:

$$(1-r)S_n=a_1(1-r^n)$$

If $r=1$, every term equals $a_1$. Then:

$$S_n=na_1$$

## Examples

### #1: Finite Geometric Series

Find the sum of the first $6$ terms of the geometric sequence $3,6,12,24,\dots$.

**Solution:**

1. Here $a_1=3$, $r=2$, and $n=6$.
2. Use the finite geometric-series formula.

$$S_6=\dfrac{3(1-2^6)}{1-2}$$

3. Calculate the power, then divide.

$$S_6=\dfrac{3(-63)}{-1}=189$$

4. The sum is $189$.

### #2: Finite Geometric Series with $r=1$

A geometric series has $8$ terms, and every term is $5$. What is the sum?

**Solution:**

1. Since every term is the same nonzero number, $r=1$.
2. Multiply the number of terms by the value of each term.

$$S_8=8(5)=40$$
