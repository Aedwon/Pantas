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

An **outcome** is one possible result. An **event** is a result or group of results we want to count. The **probability** of an event tells how likely it is.

A probability goes from $0$ (impossible) to $1$ (certain). Write $P(A)$ for the probability of event $A$. When all outcomes are equally likely:

$$P(A)=\dfrac{\text{favorable outcomes}}{\text{total outcomes}}$$

A fair die has $6$ equally likely faces. Since $3$ faces are even:

$$P(\text{even})=\dfrac36=\dfrac12$$

The **complement** of event $A$ means that $A$ does not happen. We write it as $A^c$.

$$P(A^c)=1-P(A)$$

This rule helps with "at least one" questions. Find the chance of "none" and subtract it from $1$.

### "And": Multiplication Rule

The notation $P(B\mid A)$ reads as "the probability of $B$ given $A$." It means the chance of $B$ when we know $A$ happened. If $A$ has a chance greater than $0$:

$$P(A\text{ and }B)=P(A)P(B\mid A)$$

**Independent events** do not change each other's probabilities. For independent events:

$$P(A\text{ and }B)=P(A)P(B)$$

**Dependent events** can change each other's probabilities. Drawing **without replacement** means the item stays out. The counts change before the next draw.

Drawing **with replacement** means the item is put back before the next draw. The original counts return. If the items are mixed and drawn the same way each time, each draw has the same chances.

### "Or": Addition Rule

"$A$ or $B$" includes either event and also includes both happening. Let $O$ stand for the probability of their overlap, where both happen.

$$O=P(A\text{ and }B)$$

$$P(A\text{ or }B)=P(A)+P(B)-O$$

Adding the two probabilities counts the shared outcomes twice. Subtract the overlap once.

**Mutually exclusive events** cannot happen together. Their overlap is $0$, so add their probabilities without subtracting anything.

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

### #3: Independent Events

A fair coin is tossed and a fair die is rolled independently. Find the probability of getting a head and a $6$.

**Solution:**
1. The chance of a head is $\dfrac12$. The chance of a $6$ is $\dfrac16$.
2. Multiply because the events are independent.

$$P=\dfrac12\times\dfrac16=\dfrac1{12}$$

### #4: Without Replacement

A bag holds $5$ red and $3$ blue marbles. Two marbles are drawn at random one after another without replacement. Find the probability that both are red.

**Solution:**
1. The first draw has $5$ red marbles out of $8$.

$$P(R_1)=\dfrac58$$

2. If the first is red, $4$ red marbles remain out of $7$. Here $R_1$ and $R_2$ mean red on the first and second draws.

$$P(R_2\mid R_1)=\dfrac47$$

3. Multiply the first chance by the chance after that red draw.

$$P(\text{both red})=\dfrac58\times\dfrac47$$

$$P(\text{both red})=\dfrac5{14}$$

### #5: With Replacement

A bag holds $5$ red and $3$ blue marbles. One marble is drawn at random, returned, and mixed into the bag before a second random draw. Find the probability that both draws are red.

**Solution:**
1. The chance of red on the first draw is $\dfrac58$.
2. Returning the marble restores $5$ red marbles out of $8$. The second red chance is again $\dfrac58$.
3. Multiply the two chances.

$$P(\text{both red})=\dfrac58\times\dfrac58$$

$$P(\text{both red})=\dfrac{25}{64}$$

### #6: Two Types of "Or"

One card is drawn at random from a standard deck of $52$ cards. The deck has $4$ kings, $4$ queens, and $13$ hearts, including the king of hearts. Find the probability of (a) king or queen and (b) king or heart.

**Solution:**
1. A card cannot be both a king and a queen. Add their chances.

$$P(\text{king or queen})=\dfrac4{52}+\dfrac4{52}$$

$$P(\text{king or queen})=\dfrac2{13}$$

2. King and heart overlap at the king of hearts. Subtract that card once.

$$P(\text{king or heart})=\dfrac{4+13-1}{52}$$

$$P(\text{king or heart})=\dfrac4{13}$$

### #7: At Least One Head

A fair coin is tossed independently $3$ times. Find the probability of getting at least one head.

**Solution:**
1. The complement is no heads, which means $3$ tails.

$$P(\text{no heads})=\left(\dfrac12\right)^3=\dfrac18$$

2. Subtract from $1$.

$$P(\text{at least one head})=1-\dfrac18$$

$$P(\text{at least one head})=\dfrac78$$

## Speed Tricks & Shortcuts

For "at least one," check whether "none" is easier to count. Find that chance and subtract it from $1$.

"And" often leads to multiplication. "Or" often leads to addition. Check whether chances change and whether events overlap before choosing a rule.

A standard deck has $52$ cards in $4$ suits of $13$. It has $26$ red cards, $26$ black cards, $12$ face cards, and $4$ cards of each rank.

Use the limits as a check. Every probability must be from $0$ to $1$.

## Traps to Watch For

### #1: Double-Counting the Overlap

> Subtract shared outcomes once when events overlap.

Adding the king and heart chances counts the king of hearts twice. Subtract $\dfrac1{52}$ once to avoid the wrong answer $\dfrac{17}{52}$.

### #2: Forgetting the Sampling Rule

> Check whether the item is returned before the next draw.

After a red marble stays out, the next red chance is $\dfrac47$. If it is returned and mixed in, the chance stays $\dfrac58$. Using the same counts without checking gives the wrong product.

### #3: The Gambler's Fallacy

> Earlier independent results do not make a result due.

A fair coin's next head chance stays $\dfrac12$, even after several tails. It does not become greater just because no head has appeared.

### #4: Probabilities Beyond the Limits

> A probability cannot be below $0$ or above $1$.

An answer outside this range signals a mistake. Check for a missed overlap or counts that should have changed.
