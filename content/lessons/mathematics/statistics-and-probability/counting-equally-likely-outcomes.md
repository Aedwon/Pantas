---
_id: "lesson-statistics-and-probability-counting-equally-likely-outcomes"
title: "Counting Equally Likely Outcomes"
summary: "Count favorable outcomes in one trial or a pair of dice."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 1
partCount: 4
ordering: 0
keyPoints:
  - "Find a probability by counting equally likely outcomes."
  - "Count ordered outcomes for two dice."
---
## Core Concept

An **outcome** is one possible result. An **event** is a result or group of results we want to count. The **probability** of an event tells how likely it is.

A probability goes from $0$ (impossible) to $1$ (certain). Write $P(A)$ for the probability of event $A$. When all outcomes are equally likely:

$$P(A)=\dfrac{\text{favorable outcomes}}{\text{total outcomes}}$$

A fair die has $6$ equally likely faces. Since $3$ faces are even:

$$P(\text{even})=\dfrac36=\dfrac12$$

### Counting Two-Dice Outcomes

For two dice rolled independently, each of the first die's $6$ results can pair with all $6$ results of the second die. This gives $6\times6=36$ ordered pairs.

In $(2,5)$, the first die shows $2$ and the second shows $5$. This differs from $(5,2)$. If both dice are fair, each pair has probability $\dfrac16\times\dfrac16=\dfrac1{36}$.

## Examples

### #1: A Single Event

A fair die is rolled once. Find the probability of rolling a number greater than $4$.

**Solution:**
1. The favorable outcomes are $5$ and $6$. There are $2$ favorable outcomes out of $6$.

$$P=\dfrac26=\dfrac13$$

### #2: Two Dice

Two fair dice are rolled independently. Find the probability that the sum is $7$.

**Solution:**
1. Each of the first die's $6$ results pairs with the second die's $6$ results.

$$6\times6=36$$

2. The favorable pairs are $(1,6),(2,5),(3,4),(4,3),(5,2),(6,1)$. The first number names the first die's result. There are $6$ favorable pairs.
3. All $36$ pairs are equally likely, so divide.

$$P=\dfrac6{36}=\dfrac16$$

## Speed Tricks & Shortcuts

Use the limits as a check. Every probability must be from $0$ to $1$.

## Traps to Watch For

### #1: Probabilities Beyond the Limits

> A probability cannot be below $0$ or above $1$.

An answer outside this range signals a mistake. Check for a missed overlap or counts that should have changed.
