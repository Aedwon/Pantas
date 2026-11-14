---
_id: "lesson-arithmetic-number-sense-same-remainder-numbers"
title: "Same-Remainder Numbers"
summary: "Use the LCM to find numbers with a common remainder."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 4
partCount: 4
ordering: 404
keyPoints:
  - "Write same-remainder numbers using the LCM."
  - "Check the remainder and the stated size condition."
---
## Core Concept

### Same-Remainder Problems

A **remainder** is the amount left after division into whole groups. In division by a positive integer, the remainder is at least $0$ and less than the divisor.

If a number leaves the same remainder $r$ for several divisors, subtract $r$. The result must be divisible by every divisor.

Let $L$ be the LCM of the divisors. All numbers with that common remainder have the form:

$$N=Lk+r$$

Here, $k$ is an integer. For positive divisors and a valid nonnegative remainder, use $k=0,1,2,\ldots$ to list the nonnegative answers. The dots mean the list continues.

Check any size condition in the question. The value $k=0$ gives $N=r$, so adding the remainder to the LCM is not always the smallest allowed answer.

The original lesson's Example #4 is Example #1 here.

## Examples

### #1: Same Remainder Problem

What is the smallest integer greater than $10$ that leaves a remainder of $3$ when divided by $6$, $8$, and $10$?

**Solution:**

1. The remainder $3$ is less than every divisor. Subtracting $3$ from the unknown number must leave a common multiple of the divisors.
2. Factor the divisors.

$$6=2\times3$$

$$8=2^3$$

$$10=2\times5$$

3. Find the LCM with the largest prime exponents.

$$\text{LCM}=2^3\times3\times5$$

$$\text{LCM}=120$$

4. Use the form $N=Lk+r$.

$$N=120k+3$$

5. The value $k=0$ gives $3$, which is not greater than $10$. The next value, $k=1$, gives:

$$N=120+3=123$$

6. Check the remainders.

$$123=6\times20+3$$

$$123=8\times15+3$$

$$123=10\times12+3$$

7. The smallest allowed number is $123$.

## Traps to Watch For

### #1: Ignoring a Size Condition

> A same-remainder answer must also meet the stated limit.

The number $3$ leaves remainder $3$ when divided by $6$, $8$, or $10$. It still fails Example #4 because that question requires a number greater than $10$.
