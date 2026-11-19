---
_id: "lesson-statistics-and-probability-conditional-probability-and-replacement"
title: "Conditional Probability and Replacement"
summary: "Find the chance of a later event given an earlier one."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 3
partCount: 4
ordering: 22
keyPoints:
  - "Find a conditional chance and use it in a product."
  - "Decide which counts change when drawing with or without replacement."
---
## Core Concept

### "And": Multiplication Rule

The notation $P(B\mid A)$ reads as "the probability of $B$ given $A$." It means the chance of $B$ when we know $A$ happened. If $A$ has a chance greater than $0$:

$$P(A\text{ and }B)=P(A)P(B\mid A)$$

**Dependent events** can change each other's probabilities. Drawing **without replacement** means the item stays out. The counts change before the next draw.

Drawing **with replacement** means the item is put back before the next draw. The original counts return. If the items are mixed and drawn the same way each time, each draw has the same chances.

## Examples

### #1: Without Replacement

A bag holds $5$ red and $3$ blue marbles. Two marbles are drawn at random one after another without replacement. Find the probability that both are red.

**Solution:**
1. The first draw has $5$ red marbles out of $8$.

$$P(R_1)=\dfrac58$$

2. If the first is red, $4$ red marbles remain out of $7$. Here $R_1$ and $R_2$ mean red on the first and second draws.

$$P(R_2\mid R_1)=\dfrac47$$

3. Multiply the first chance by the chance after that red draw.

$$P(\text{both red})=\dfrac58\times\dfrac47$$

$$P(\text{both red})=\dfrac5{14}$$

### #2: With Replacement

A bag holds $5$ red and $3$ blue marbles. One marble is drawn at random, returned, and mixed into the bag before a second random draw. Find the probability that both draws are red.

**Solution:**
1. The chance of red on the first draw is $\dfrac58$.
2. Returning the marble restores $5$ red marbles out of $8$. The second red chance is again $\dfrac58$.
3. Multiply the two chances.

$$P(\text{both red})=\dfrac58\times\dfrac58$$

$$P(\text{both red})=\dfrac{25}{64}$$

## Traps to Watch For

### #1: Forgetting the Sampling Rule

> Check whether the item is returned before the next draw.

After a red marble stays out, the next red chance is $\dfrac47$. If it is returned and mixed in, the chance stays $\dfrac58$. Using the same counts without checking gives the wrong product.
