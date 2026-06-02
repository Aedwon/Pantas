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

The **probability** of an event measures how likely it is, from $0$ (impossible) to $1$ (certain). For equally likely outcomes:

$$P(\text{event}) = \dfrac{\text{favorable outcomes}}{\text{total outcomes}}$$

A die has $6$ faces, $3$ of them even, so $P(\text{even}) = \dfrac{3}{6} = \dfrac{1}{2}$.

The **complement** rule handles "not" and "at least" questions:

$$P(\text{not } A) = 1 - P(A)$$

Combining two events needs two questions.

**Question 1 for and (both happen): do the events affect each other?**

- **Independent events**: the first result does not change the second. Coin flips, dice rolls, draws with replacement. Multiply straight:

$$P(A \text{ and } B) = P(A) \times P(B)$$

- **Dependent events**: the first result changes the situation, like drawing cards without putting them back. Multiply, but update the second fraction to reflect what is left.

**Question 2 for or (either happens): can both happen at once?**

- **Mutually exclusive events** cannot happen together (a card cannot be a king and a queen). Just add:

$$P(A \text{ or } B) = P(A) + P(B)$$

- Overlapping events can happen together (a card can be a king and a heart). Add, then subtract the overlap so it is not counted twice:

$$P(A \text{ or } B) = P(A) + P(B) - P(A \text{ and } B)$$

Shorthand worth memorizing: And means multiply, or means add (minus any overlap).

## Examples

### #1: A Single Event

A fair die is rolled once. Find the probability of rolling a number greater than $4$.

**Solution:**
Count favorable over total.

1. Numbers greater than $4$: only $5$ and $6$, so $2$ favorable outcomes out of $6$.

$$P = \dfrac{2}{6} = \dfrac{1}{3}$$

### #2: Two Dice

Two dice are rolled. Find the probability that the sum is $7$.

**Solution:**
Two dice give $6 \times 6 = 36$ equally likely pairs.

1. List the pairs that sum to $7$: $(1,6), (2,5), (3,4), (4,3), (5,2), (6,1)$. That is $6$ pairs.
2. Divide.

$$P = \dfrac{6}{36} = \dfrac{1}{6}$$

3. Order counts in the listing: $(2,5)$ and $(5,2)$ are different rolls.

### #3: Independent Events

A coin is tossed and a die is rolled. Find the probability of getting a head and a $6$.

**Solution:**
The coin cannot influence the die: independent. Multiply.

1. Multiply the separate probabilities.

$$P = \dfrac{1}{2} \times \dfrac{1}{6} = \dfrac{1}{12}$$

### #4: Dependent Events (No Replacement)

A bag holds $5$ red and $3$ blue marbles. Two marbles are drawn one after another without replacement. Find the probability that both are red.

**Solution:**
The first draw changes the bag: dependent. Update the second fraction.

1. First draw: $5$ reds out of $8$ marbles.

$$P(\text{first red}) = \dfrac{5}{8}$$

2. After a red leaves: $4$ reds out of $7$ marbles remain.

$$P(\text{second red}) = \dfrac{4}{7}$$

3. Multiply.

$$P = \dfrac{5}{8} \times \dfrac{4}{7} = \dfrac{20}{56} = \dfrac{5}{14}$$

### #5: Mutually Exclusive vs. Overlapping "Or"

From a standard $52$-card deck, one card is drawn. Find (a) $P(\text{king or queen})$ and (b) $P(\text{king or heart})$.

**Solution:**
Part (a) has no overlap; part (b) does.

1. For (a): a card cannot be both a king and a queen — mutually exclusive. Add.

$$\dfrac{4}{52} + \dfrac{4}{52} = \dfrac{8}{52} = \dfrac{2}{13}$$

2. For (b): the king of hearts is both. Add and subtract the overlap.

$$\dfrac{4}{52} + \dfrac{13}{52} - \dfrac{1}{52} = \dfrac{16}{52} = \dfrac{4}{13}$$

### #6: "At Least One" via the Complement

A fair coin is tossed $3$ times. Find the probability of getting at least one head.

**Solution:**
"At least one" is the complement of "none".

1. The only no-head outcome is tails-tails-tails.

$$P(\text{no heads}) = \dfrac{1}{2} \times \dfrac{1}{2} \times \dfrac{1}{2} = \dfrac{1}{8}$$

2. Subtract from $1$.

$$P(\text{at least one head}) = 1 - \dfrac{1}{8} = \dfrac{7}{8}$$

## Speed Tricks & Shortcuts

The phrase "at least one" should trigger the complement instantly: compute the probability of none, subtract from $1$. Counting the "at least" cases directly means adding many branches; the complement is always one branch.

Deck facts to keep loaded: $52$ cards, $4$ suits of $13$, $26$ red and $26$ black, $12$ face cards, $4$ of each rank. Most card questions are these numbers in disguise.

Sanity bounds kill wrong choices: every probability lives between $0$ and $1$, an "or" answer is at least as big as each separate probability, and an "and" answer is at most as small as each. A glance at the choices often removes two of them.

## Traps to Watch For

### #1: Double-Counting the Overlap

> "Or" with overlapping events needs the subtraction.

For king-or-heart, adding $\dfrac{4}{52} + \dfrac{13}{52} = \dfrac{17}{52}$ counts the king of hearts twice. The planted choice $\dfrac{17}{52}$ appears every time. Before adding, ask: can one outcome satisfy both descriptions?

### #2: Ignoring the Missing Marble

> Without replacement, the second fraction must change, top and bottom.

Writing $\dfrac{5}{8} \times \dfrac{5}{8}$ for two reds treats the draws as independent. One marble is gone: the pool drops to $7$ and the reds drop to $4$. The words "without replacement" or "one after another" signal dependent events.

### #3: The Gambler's Fallacy

> A fair coin has no memory. Past flips never change the next one.

After five heads in a row, the probability of another head is still exactly $\dfrac{1}{2}$. Questions phrase this as "the coin is due for tails" — a false statement. Independent means independent, no matter how streaky the history looks.

### #4: Probabilities Beyond the Limits

> No probability is negative or greater than $1$.

If your sum of "or" probabilities exceeds $1$, you forgot an overlap or added things that should not be added. Use this as a self-check, and use it on the answer choices too: an option like $\dfrac{9}{8}$ is free to eliminate.
