---
_id: "lesson-statistics-and-probability-combinatorics"
title: "Combinatorics"
summary: "This lesson teaches you how to count arrangements and selections using the counting principle, permutations, and combinations."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 13
isActive: true
---
## Core Concept

Combinatorics is the art of counting WITHOUT listing. Three tools handle nearly every exam question.

First, know the **factorial**: $n!$ means multiply all whole numbers from $n$ down to $1$. So $5! = 5 \times 4 \times 3 \times 2 \times 1 = 120$. Special rule: $0! = 1$.

### Fundamental Counting Principle

If one task can be done in $m$ ways and a second task in $n$ ways, the two together can be done in $m \times n$ ways. Choices in a SEQUENCE multiply.

Choosing a shirt ($4$ options) and pants ($3$ options) gives $4 \times 3 = 12$ outfits. Every branch of the first choice sprouts all the branches of the second.

<!-- ILLUSTRATION: tree diagram with 4 shirt branches each splitting into 3 pants branches, 12 leaf outfits -->

### Permutations

A **permutation** is an arrangement where ORDER MATTERS: gold-silver-bronze, seating in a row, officer positions. The number of ways to arrange $r$ items chosen from $n$ different items:

$$P(n, r) = \dfrac{n!}{(n - r)!}$$

In practice: multiply $r$ falling numbers starting at $n$. So $P(7, 3) = 7 \times 6 \times 5 = 210$.

### Combinations

A **combination** is a selection where order does NOT matter: a committee, a fruit basket, a hand of cards. Choosing the same people in a different order is the same committee.

$$C(n, r) = \dfrac{n!}{r!(n - r)!}$$

A combination is a permutation DIVIDED by $r!$, to erase the orderings you no longer care about.

The exam decision: ask "if I swap two chosen items, is the result different?" Yes: permutation. No: combination.

## Examples

### #1: Counting Principle

A canteen offers $4$ sandwiches, $3$ drinks, and $2$ desserts. How many different meals of one sandwich, one drink, and one dessert are possible?

**Solution:**
Three choices in sequence: multiply.

1. Multiply the options.

$$4 \times 3 \times 2 = 24$$

2. There are $24$ possible meals.

### #2: No Repetition Allowed

How many $4$-digit PIN codes use four DIFFERENT digits?

**Solution:**
Each slot has one fewer option than the last.

1. First digit: $10$ choices. Second: $9$ left. Third: $8$. Fourth: $7$.

$$10 \times 9 \times 8 \times 7 = 5040$$

2. There are $5040$ such codes. (If repeats were allowed, it would be $10^4 = 10000$.)

### #3: Permutation

A shelf has room for $3$ books. In how many ways can you arrange $3$ books chosen from $5$ different books?

**Solution:**
Left-to-right positions differ, so order matters: permutation.

1. Multiply $3$ falling numbers from $5$.

$$P(5, 3) = 5 \times 4 \times 3 = 60$$

2. There are $60$ arrangements.

### #4: Combination

A teacher must pick $3$ students from a class of $8$ to join a quiz team. How many different teams are possible?

**Solution:**
A team is a team no matter the picking order: combination.

1. Apply the formula.

$$C(8, 3) = \dfrac{8!}{3! \, 5!} = \dfrac{8 \times 7 \times 6}{3 \times 2 \times 1}$$

2. Compute.

$$\dfrac{336}{6} = 56$$

3. There are $56$ possible teams.

### #5: Order Matters vs. Order Does Not (Exam Level)

From a club of $10$ members: (a) in how many ways can a president and a vice president be chosen? (b) in how many ways can a $2$-member committee be chosen?

**Solution:**
Same numbers, different logic — this pairing is the heart of the topic.

1. For (a), the two positions are DIFFERENT jobs. Ana-president with Ben-vice differs from Ben-president with Ana-vice. Order matters.

$$10 \times 9 = 90$$

2. For (b), a committee of Ana and Ben is the same committee as Ben and Ana. Order does not matter: divide out the $2! = 2$ orderings.

$$\dfrac{90}{2} = 45$$

3. Answers: $90$ ways for officers, $45$ ways for the committee. Half as many, because each committee was counted twice as officer pairs.

## Speed Tricks & Shortcuts

Never expand full factorials. For $C(8, 3)$, write $3$ falling numbers over $3!$: $\dfrac{8 \times 7 \times 6}{6} = 56$. Cancel before multiplying and the arithmetic stays tiny.

Use the mirror rule: $C(n, r) = C(n, n - r)$. Choosing $8$ from $10$ equals choosing the $2$ left behind: $C(10, 8) = C(10, 2) = 45$. Always count the smaller side.

Keywords sort the problems fast: "arrange", "order", "line up", "ranking", "officers" scream permutation; "choose", "select", "committee", "group", "team" scream combination.

## Traps to Watch For

### #1: Permutation for a Committee

> If swapping the chosen items changes nothing, you MUST divide out the orderings.

Using $10 \times 9 = 90$ for a $2$-member committee double-counts every pair. The choices will contain both $90$ and $45$; only the division-by-$2!$ answer is right. Run the swap test before you compute anything.

### #2: Adding Instead of Multiplying

> Sequential choices MULTIPLY. Either-or choices ADD.

Choosing a sandwich AND a drink: $4 \times 3$. Choosing a sandwich OR a drink (just one item): $4 + 3$. The words "and" and "or" in the problem are the switches. Mixing them up gives answers that are wildly too small or too large.

### #3: Forgetting $0! = 1$

> Zero factorial is defined as $1$, not $0$.

The formula $C(n, n)$ needs it: choosing all $8$ from $8$ gives $\dfrac{8!}{8! \, 0!} = 1$ way, which makes sense — take everyone. If $0!$ were $0$, the formula would divide by zero. Questions test this as a quick concept check.

### #4: Repetition Rules Unread

> Check whether repeats are allowed BEFORE setting up the slots.

Digits of a code may repeat unless the problem says "distinct" or "no repetition"; people can never repeat (one person cannot fill two seats). The $10^4$ versus $10 \times 9 \times 8 \times 7$ split in Example $2$ is exactly this reading step, and both answers always appear in the choices.
