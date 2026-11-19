---
_id: "lesson-statistics-and-probability-counting-choices-in-stages"
title: "Counting Choices in Stages"
summary: "Multiply stage counts with or without reuse."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 1
partCount: 5
ordering: 15
keyPoints:
  - "Multiply the counts for successive choices."
  - "Allow or forbid reuse as the problem states."
---
## Core Concept

Combinatorics counts the possible outcomes of a situation without listing each one. An **outcome** is one complete result, such as one outfit or one team.

### Fundamental Counting Principle

Some outcomes are built in stages, such as choosing a shirt and then choosing pants. Suppose the first stage can be done in $m$ ways. Suppose the second stage can be done in $n$ ways, whichever first choice was made. Then the two stages together give $mn$ outcomes.

Choosing one of $4$ shirts and one of $3$ pairs of pants gives:

$$4\times3=12$$

outfits.

<!-- FIGURE: {"kind": "concept-diagram", "type": "tree", "root": "Outfits", "branches": [{"name": "Shirt 1", "leaves": 3}, {"name": "Shirt 2", "leaves": 3}, {"name": "Shirt 3", "leaves": 3}, {"name": "Shirt 4", "leaves": 3}], "totalLeaves": 12, "semanticsLabel": "A tree diagram with 4 shirt branches each splitting into 3 pants branches for a total of 12 leaf outfits."} -->

The same rule extends to any number of stages: multiply the number of ways at each stage. Use it when one outcome needs a choice at every stage, that is, a choice at stage one and a choice at stage two and so on.

### Repetition and Roles

The formulas above never use the same object twice. If a problem allows reuse, go back to the counting principle. With $n$ choices at each of $r$ positions and reuse allowed, there are $n^r$ ordered outcomes.

## Examples

### #1: Counting Principle

A canteen offers $4$ sandwiches, $3$ drinks, and $2$ desserts. How many different meals consisting of one sandwich, one drink, and one dessert are possible?

**Solution:**
Each sandwich can be paired with each drink and each dessert, so multiply the three counts.

$$4\times3\times2=24$$

There are $24$ possible meals.

### #2: Repetition and No Repetition

How many $4$-digit PIN codes use four different decimal digits? Treat a leading zero as allowed because these are codes, not four-digit integers. How many codes are there if digits may repeat?

**Solution:**
1. With no repeats, there are $10$ choices for the first position. Each later position has one fewer choice, because the used digits are removed.

$$10\times9\times8\times7=5040$$

2. If digits may repeat, each of the $4$ positions has $10$ choices.

$$10^4=10000$$

3. There are $5040$ codes with different digits and $10000$ codes if repeats are allowed.

## Traps to Watch For

### #1: Repetition and Role Rules Must Be Read, Not Assumed

> Check the problem for whether an object may be reused and whether one person may hold two roles.

A code may allow repeated digits, and a selection problem may forbid repeats. In Example #7, if one person could hold both offices, the count would be $10\times10=100$ instead of $90$. If a problem about roles says nothing about repeats, use the default: different roles go to different people.
