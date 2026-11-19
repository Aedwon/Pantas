---
_id: "lesson-statistics-and-probability-probability-of-either-event"
title: "Probability of Either Event"
summary: "Add probabilities and account for any overlap."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 4
partCount: 4
ordering: 0
keyPoints:
  - "Subtract overlap when counting either event."
  - "Recognize mutually exclusive events."
---
## Core Concept

### "Or": Addition Rule

"$A$ or $B$" includes either event and also includes both happening. Let $O$ stand for the probability of their overlap, where both happen.

$$O=P(A\text{ and }B)$$

$$P(A\text{ or }B)=P(A)+P(B)-O$$

Adding the two probabilities counts the shared outcomes twice. Subtract the overlap once.

**Mutually exclusive events** cannot happen together. Their overlap is $0$, so add their probabilities without subtracting anything.

## Examples

### #1: Two Types of "Or"

One card is drawn at random from a standard deck of $52$ cards. The deck has $4$ kings, $4$ queens, and $13$ hearts, including the king of hearts. Find the probability of (a) king or queen and (b) king or heart.

**Solution:**
1. A card cannot be both a king and a queen. Add their chances.

$$P(\text{king or queen})=\dfrac4{52}+\dfrac4{52}$$

$$P(\text{king or queen})=\dfrac2{13}$$

2. King and heart overlap at the king of hearts. Subtract that card once.

$$P(\text{king or heart})=\dfrac{4+13-1}{52}$$

$$P(\text{king or heart})=\dfrac4{13}$$

## Speed Tricks & Shortcuts

"And" often leads to multiplication. "Or" often leads to addition. Check whether chances change and whether events overlap before choosing a rule.

A standard deck has $52$ cards in $4$ suits of $13$. It has $26$ red cards, $26$ black cards, $12$ face cards, and $4$ cards of each rank.

## Traps to Watch For

### #1: Double-Counting the Overlap

> Subtract shared outcomes once when events overlap.

Adding the king and heart chances counts the king of hearts twice. Subtract $\dfrac1{52}$ once to avoid the wrong answer $\dfrac{17}{52}$.
