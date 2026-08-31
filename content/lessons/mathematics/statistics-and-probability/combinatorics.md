---
_id: "lesson-statistics-and-probability-combinatorics"
title: "Combinatorics"
summary: "How to count arrangements and selections using the counting principle, permutations, and combinations."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 13
isActive: true
---
## Core Concept

Combinatorics counts possible outcomes without listing each one individually.

For a nonnegative integer $n$, **factorial** is defined by:

$$n!=n(n-1)(n-2)\cdots2\cdot1$$

with the special definition $0!=1$.

### Fundamental Counting Principle

If one stage can be completed in $m$ ways and, for each such choice, a second stage can be completed in $n$ ways, then the two-stage process has $mn$ possible outcomes.

Choosing one of $4$ shirts and then one of $3$ pairs of pants gives:

$$4\times3=12$$

outfits.

<!-- FIGURE: {"kind": "concept-diagram", "type": "tree", "root": "Outfits", "branches": [{"name": "Shirt 1", "leaves": 3}, {"name": "Shirt 2", "leaves": 3}, {"name": "Shirt 3", "leaves": 3}, {"name": "Shirt 4", "leaves": 3}], "totalLeaves": 12, "semanticsLabel": "A tree diagram with 4 shirt branches each splitting into 3 pants branches for a total of 12 leaf outfits."} -->

### Permutations

A **permutation** is an ordered selection. For $n$ distinct objects, the number of ways to choose and arrange $r$ of them without repetition is:

$$P(n,r)=\dfrac{n!}{(n-r)!}$$

where $0\le r\le n$. For example:

$$P(7,3)=7\times6\times5=210$$

### Combinations

A **combination** is an unordered selection. For $n$ distinct objects, the number of ways to choose $r$ without repetition when order does not matter is:

$$C(n,r)=\dfrac{n!}{r!(n-r)!}$$

A useful decision question is: if the same selected objects appear in a different order, does that create a different outcome? If yes, use an ordered count such as a permutation. If no, use a combination.

## Examples

### #1: Counting Principle

A canteen offers $4$ sandwiches, $3$ drinks, and $2$ desserts. How many different meals consisting of one sandwich, one drink, and one dessert are possible?

**Solution:**
Each sandwich choice can be paired with every drink and dessert choice.

$$4\times3\times2=24$$

There are $24$ possible meals.

### #2: No Repetition Allowed

How many $4$-digit PIN codes use four different decimal digits? Treat leading zero as allowed because these are codes, not four-digit integers.

**Solution:**
There are $10$ choices for the first position, then $9$, $8$, and $7$ choices as used digits are removed.

$$10\times9\times8\times7=5040$$

There are $5040$ such codes. If repetition were allowed, there would be $10^4=10000$ codes.

### #3: Permutation

A shelf has room for $3$ books. In how many ways can you arrange $3$ books chosen from $5$ different books?

**Solution:**
The positions are ordered.

$$P(5,3)=5\times4\times3=60$$

There are $60$ arrangements.

### #4: Combination

A teacher must pick $3$ students from a class of $8$ to form a quiz team, with no assigned roles. How many different teams are possible?

**Solution:**
Order does not matter.

$$C(8,3)=\dfrac{8!}{3!5!}=\dfrac{8\times7\times6}{3\times2\times1}=56$$

There are $56$ possible teams.

### #5: Ordered Roles vs. Unordered Team

From a club of $10$ members, assume no person may hold both roles. (a) In how many ways can a president and a vice president be chosen? (b) In how many ways can a $2$-member committee with no roles be chosen?

**Solution:**
1. President and vice president are different roles, so order matters.

$$10\times9=90$$

2. For a two-person committee, selecting Ana then Ben is the same committee as selecting Ben then Ana, so order does not matter.

$$C(10,2)=\dfrac{10\times9}{2}=45$$

3. Answers: $90$ ordered officer assignments and $45$ unordered committees.

## Speed Tricks & Shortcuts

Avoid expanding more of a factorial than needed. For example:

$$C(8,3)=\dfrac{8\times7\times6}{3\times2\times1}=56$$

The symmetry rule:

$$C(n,r)=C(n,n-r)$$

means choosing $8$ objects from $10$ is equivalent in count to choosing the $2$ objects left out.

Words such as "arrange," "ranking," or named distinct positions usually indicate that order matters. Words such as "committee" or "team" often indicate an unordered selection, **unless** the problem assigns different roles within the group.

## Traps to Watch For

### #1: Counting an Unordered Group as Ordered

> If swapping the selected objects creates no new outcome, an ordered count overcounts.

For a two-person committee with no roles, Ana-Ben and Ben-Ana describe the same committee.

### #2: Adding Instead of Multiplying Sequential Choices

> When every choice from one stage can be paired with every choice from the next stage, multiply the counts.

An either-or situation may instead require addition, so model what an outcome consists of before choosing an operation.

### #3: Forgetting $0!=1$

> Zero factorial is defined as $1$.

This keeps formulas such as $C(n,n)=1$ and $P(n,n)=n!$ consistent.

### #4: Repetition and Role Rules Must Be Read, Not Assumed

> Determine whether an object may be reused and whether one person may occupy multiple roles from the problem statement.

A code may allow repeated digits; a selection problem may forbid repeats; and organizational rules determine whether the same person may hold two positions. Those assumptions change the count, so state or infer them only from the problem's conditions.
