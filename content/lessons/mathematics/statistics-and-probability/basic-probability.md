---
_id: "lesson-statistics-and-probability-basic-probability"
title: "Basic Probability (Independent vs. Dependent Events, Mutually Exclusive Events)"
summary: "How to compute probabilities for single and combined events, with and without replacement."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 13
isActive: true
---
## Core Concept

The **probability** of an event measures how likely it is, from $0$ (impossible) to $1$ (certain). When all elementary outcomes in the sample space are equally likely:

$$P(\text{event})=\dfrac{\text{favorable outcomes}}{\text{total outcomes}}$$

A fair die has $6$ equally likely faces, $3$ of them even, so $P(\text{even})=\dfrac{3}{6}=\dfrac12$.

The **complement rule** handles the event "not $A$":

$$P(A^c)=1-P(A)$$

This is especially useful for "at least one" questions when the complementary event "none" is easier to calculate.

For two events, use the general multiplication and addition rules first.

### "And": multiplication rule

For any events $A$ and $B$ with the needed conditional probability defined:

$$P(A\text{ and }B)=P(A)\,P(B\mid A)$$

- **Independent events**: knowing that $A$ happened does not change the probability of $B$, so $P(B\mid A)=P(B)$ and:

$$P(A\text{ and }B)=P(A)P(B)$$

- **Dependent events**: use the updated conditional probability. For example, drawing without replacement changes the contents before the second draw.

### "Or": addition rule

For any two events:

$$P(A\text{ or }B)=P(A)+P(B)-P(A\text{ and }B)$$

- **Mutually exclusive events** have no shared outcomes, so $P(A\text{ and }B)=0$ and the rule reduces to simple addition.
- If the events overlap, subtract the intersection once so it is not double-counted.

A useful reminder is: "and" often leads to multiplication and "or" often leads to addition, but first check dependence and overlap so you use the correct form of the rule.

## Examples

### #1: A Single Event

A fair die is rolled once. Find the probability of rolling a number greater than $4$.

**Solution:**
1. The favorable outcomes are $5$ and $6$: $2$ outcomes out of $6$.

$$P=\dfrac26=\dfrac13$$

### #2: Two Dice

Two fair dice are rolled. Find the probability that the sum is $7$.

**Solution:**
The $36$ ordered pairs are equally likely.

1. Pairs summing to $7$: $(1,6),(2,5),(3,4),(4,3),(5,2),(6,1)$.
2. There are $6$ favorable pairs.

$$P=\dfrac6{36}=\dfrac16$$

### #3: Independent Events

A fair coin is tossed and a fair die is rolled. Find the probability of getting a head and a $6$.

**Solution:**
The events are independent.

$$P=\dfrac12\times\dfrac16=\dfrac1{12}$$

### #4: Dependent Events (No Replacement)

A bag holds $5$ red and $3$ blue marbles. Two marbles are drawn one after another **without replacement**. Find the probability that both are red.

**Solution:**
The first draw changes the composition of the bag.

1. First red:

$$P(R_1)=\dfrac58$$

2. Given that the first marble was red, $4$ red marbles remain among $7$ total:

$$P(R_2\mid R_1)=\dfrac47$$

3. Multiply.

$$P(R_1\cap R_2)=\dfrac58\times\dfrac47=\dfrac5{14}$$

### #5: Mutually Exclusive vs. Overlapping "Or"

From a standard $52$-card deck, one card is drawn. Find (a) $P(\text{king or queen})$ and (b) $P(\text{king or heart})$.

**Solution:**
1. A card cannot be both a king and a queen, so the events are mutually exclusive.

$$\dfrac4{52}+\dfrac4{52}=\dfrac2{13}$$

2. A card can be both a king and a heart: the king of hearts. Subtract that overlap once.

$$\dfrac4{52}+\dfrac{13}{52}-\dfrac1{52}=\dfrac4{13}$$

### #6: "At Least One" via the Complement

A fair coin is tossed $3$ times. Find the probability of getting at least one head.

**Solution:**
The complement of "at least one head" is "no heads".

1. Three independent tails:

$$P(\text{no heads})=\left(\dfrac12\right)^3=\dfrac18$$

2. Subtract from $1$.

$$P(\text{at least one head})=1-\dfrac18=\dfrac78$$

## Speed Tricks & Shortcuts

For "at least one" questions, check whether the complement is a single simple event such as "none." If so, computing the complement and subtracting from $1$ is usually shorter than listing every successful case.

Useful standard-deck facts: $52$ cards, $4$ suits of $13$, $26$ red and $26$ black, $12$ face cards, and $4$ cards of each rank.

Use bounds as a check: every probability lies from $0$ to $1$. Also, $P(A\cup B)$ cannot be smaller than either $P(A)$ or $P(B)$, while $P(A\cap B)$ cannot be larger than either one.

## Traps to Watch For

### #1: Double-Counting the Overlap

> For overlapping events, the addition rule subtracts the intersection once.

For king-or-heart, simply adding $4/52+13/52$ counts the king of hearts twice.

### #2: Ignoring Conditional Probability

> For dependent events, the second probability may change after the first event.

Without replacement, after drawing one red marble from $5$ red and $3$ blue, the next red probability is $4/7$, not $5/8$. Merely saying "one after another" does not by itself create dependence; the sampling rule matters.

### #3: The Gambler's Fallacy

> Independent trials do not become "due" because of previous outcomes.

For independent tosses of a fair coin, the probability of a head on the next toss remains $1/2$ regardless of the preceding sequence.

### #4: Probabilities Beyond the Limits

> A probability cannot be negative or exceed $1$.

If a calculation produces a value outside $[0,1]$, recheck the setup, especially overlap or conditional-probability handling.
