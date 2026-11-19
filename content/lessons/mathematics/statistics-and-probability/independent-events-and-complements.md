---
_id: "lesson-statistics-and-probability-independent-events-and-complements"
title: "Independent Events and Complements"
summary: "Multiply independent chances and use the chance of none."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 2
partCount: 4
ordering: 0
keyPoints:
  - "Multiply probabilities of independent events."
  - "Use the complement to find a probability."
---
## Core Concept

The **complement** of event $A$ means that $A$ does not happen. We write it as $A^c$.

$$P(A^c)=1-P(A)$$

This rule helps with "at least one" questions. Find the chance of "none" and subtract it from $1$.

**Independent events** do not change each other's probabilities. For independent events:

$$P(A\text{ and }B)=P(A)P(B)$$

## Examples

### #1: Independent Events

A fair coin is tossed and a fair die is rolled independently. Find the probability of getting a head and a $6$.

**Solution:**
1. The chance of a head is $\dfrac12$. The chance of a $6$ is $\dfrac16$.
2. Multiply because the events are independent.

$$P=\dfrac12\times\dfrac16=\dfrac1{12}$$

### #2: At Least One Head

A fair coin is tossed independently $3$ times. Find the probability of getting at least one head.

**Solution:**
1. The complement is no heads, which means $3$ tails.

$$P(\text{no heads})=\left(\dfrac12\right)^3=\dfrac18$$

2. Subtract from $1$.

$$P(\text{at least one head})=1-\dfrac18$$

$$P(\text{at least one head})=\dfrac78$$

## Speed Tricks & Shortcuts

For "at least one," check whether "none" is easier to count. Find that chance and subtract it from $1$.

## Traps to Watch For

### #1: The Gambler's Fallacy

> Earlier independent results do not make a result due.

A fair coin's next head chance stays $\dfrac12$, even after several tails. It does not become greater just because no head has appeared.
