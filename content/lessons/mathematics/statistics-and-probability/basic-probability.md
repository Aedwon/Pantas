---
_id: "lesson-statistics-and-probability-basic-probability"
title: "Basic Probability (Independent vs. Dependent Events, Mutually Exclusive Events)"
summary: "How to compute probabilities for single and combined events, with and without replacement."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 14
isActive: true
---
## Core Concept

The **probability** of an event tells how likely it is. A probability goes from $0$ (impossible) to $1$ (certain). When all outcomes are equally likely:

$$P(\text{event})=\dfrac{\text{favorable outcomes}}{\text{total outcomes}}$$

A fair die has $6$ equally likely faces. Since $3$ faces are even:

$$P(\text{even})=\dfrac36=\dfrac12$$

The **complement** of event $A$ means that $A$ does not happen. The complement rule is:

$$P(A^c)=1-P(A)$$

This rule is useful for "at least one" questions. It may be easier to find the chance of "none" and subtract it from $1$.

### "And": multiplication rule

The notation $P(B\mid A)$ means the probability that $B$ happens after we know that $A$ happened. For two events $A$ and $B$:

$$P(A\text{ and }B)=P(A)\,P(B\mid A)$$

**Independent events** do not change each other's probabilities. If $A$ and $B$ are independent, then $P(B\mid A)=P(B)$, so:

$$P(A\text{ and }B)=P(A)P(B)$$

**Dependent events** can change each other's probabilities. Drawing an item **without replacement** means the item stays out, so the counts can change before the next draw.

Drawing **with replacement** means the item is put back before the next draw. The original counts are restored. If each draw is made the same way, the next draw has the same probabilities as the first.

### "Or": addition rule

For two events $A$ and $B$:

$$P(A\text{ or }B)=P(A)+P(B)-P(A\text{ and }B)$$

**Mutually exclusive events** cannot happen together. Their overlap is $0$, so their probabilities can be added directly.

If two events can happen together, they overlap. Subtract the overlap once so it is not counted twice.

A useful reminder is that "and" often leads to multiplication, while "or" often leads to addition. First check whether the events are dependent and whether they overlap.

## Examples

### #1: A Single Event

A fair die is rolled once. Find the probability of rolling a number greater than $4$.

**Solution:**
1. The favorable outcomes are $5$ and $6$. That is $2$ outcomes out of $6$.

$$P=\dfrac26=\dfrac13$$

### #2: Two Dice

Two fair dice are rolled. Find the probability that the sum is $7$.

**Solution:**
1. The first die has $6$ possible results, and the second die also has $6$.

$$6\times6=36$$

2. Each result can be written as an ordered pair. The first number is the first die, and the second number is the second die.
3. The pairs that sum to $7$ are $(1,6),(2,5),(3,4),(4,3),(5,2),(6,1)$. There are $6$ favorable pairs.
4. Divide the favorable pairs by all $36$ pairs.

$$P=\dfrac6{36}=\dfrac16$$

### #3: Independent Events

A fair coin is tossed and a fair die is rolled. Find the probability of getting a head and a $6$.

**Solution:**
1. The coin result does not change the die result, so the events are independent.
2. Multiply their probabilities.

$$P=\dfrac12\times\dfrac16=\dfrac1{12}$$

### #4: Dependent Events Without Replacement

A bag holds $5$ red and $3$ blue marbles. Two marbles are drawn one after another **without replacement**. Find the probability that both are red.

**Solution:**
1. The chance that the first marble is red is:

$$P(R_1)=\dfrac58$$

2. The first red marble stays out. Now $4$ red marbles remain among $7$ total.

$$P(R_2\mid R_1)=\dfrac47$$

3. Multiply the two probabilities.

$$P(R_1\cap R_2)=\dfrac58\times\dfrac47=\dfrac5{14}$$

### #5: Sampling With Replacement

A bag holds $5$ red and $3$ blue marbles. One marble is drawn, returned to the bag, and then a second marble is drawn. Find the probability that both marbles drawn are red.

**Solution:**
1. The chance of red on the first draw is:

$$\dfrac58$$

2. The first marble is returned. The bag again has $5$ red marbles out of $8$ total.

$$\dfrac58$$

3. Multiply the two probabilities.

$$\dfrac58\times\dfrac58=\dfrac{25}{64}$$

### #6: Mutually Exclusive and Overlapping "Or"

From a standard $52$-card deck, one card is drawn. Find (a) $P(\text{king or queen})$ and (b) $P(\text{king or heart})$.

**Solution:**
1. A card cannot be both a king and a queen, so the events are mutually exclusive.

$$P(\text{king or queen})=\dfrac4{52}+\dfrac4{52}=\dfrac2{13}$$

2. A card can be both a king and a heart. The king of hearts is the one-card overlap, so subtract it once.

$$P(\text{king or heart})=\dfrac4{52}+\dfrac{13}{52}-\dfrac1{52}=\dfrac4{13}$$

### #7: "At Least One" via the Complement

A fair coin is tossed $3$ times. Find the probability of getting at least one head.

**Solution:**
1. The complement of "at least one head" is "no heads." That means getting $3$ tails.

$$P(\text{no heads})=\left(\dfrac12\right)^3=\dfrac18$$

2. Subtract from $1$.

$$P(\text{at least one head})=1-\dfrac18=\dfrac78$$

## Speed Tricks & Shortcuts

For "at least one" questions, check whether "none" is easier to find. If it is, find that probability and subtract it from $1$.

Useful standard-deck facts are $52$ cards, $4$ suits of $13$, $26$ red cards, $26$ black cards, $12$ face cards, and $4$ cards of each rank.

Use the limits as a check. Every probability must be from $0$ to $1$.

## Traps to Watch For

### #1: Double-Counting the Overlap

> If two events overlap, subtract the shared outcomes once.

For king or heart, adding $\dfrac4{52}+\dfrac{13}{52}$ counts the king of hearts twice. Subtract $\dfrac1{52}$ once.

### #2: Forgetting the Sampling Rule

> Check whether an item is returned before the next draw.

Without replacement, after one red marble is removed from $5$ red and $3$ blue, the next red probability is $\dfrac47$. With replacement, the bag returns to $5$ red out of $8$, so the next red probability is again $\dfrac58$.

### #3: The Gambler's Fallacy

> Independent trials do not become "due" because of earlier results.

For independent tosses of a fair coin, the chance of a head on the next toss stays $\dfrac12$. Earlier tosses do not change it.

### #4: Probabilities Beyond the Limits

> A probability cannot be below $0$ or above $1$.

If your answer is outside $[0,1]$, check the setup again. Look for a missed overlap or a probability that should have changed.
