---
_id: "lesson-arithmetic-number-sense-real-number-sets"
title: "Real Number Sets"
summary: "Classify natural, whole, integer, rational, irrational, and real numbers."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 3
ordering: 4
keyPoints:
  - "Classify natural, whole, integer, rational, irrational, and real numbers."
  - "Use the natural-number convention given in the question."
---
## Core Concept

### Natural, Whole, and Integer Sets

Numbers belong to nested sets, like smaller boxes sitting inside larger boxes.

- **Natural numbers** are the counting numbers $1,2,3,\dots$. Some books include $0$, so always follow the rule stated in the question.
- **Whole numbers** add $0$ to the counting numbers: $0,1,2,3,\dots$. Fractions and negative numbers are not whole numbers.
- **Integers** include all whole numbers and their opposites: $\dots,-2,-1,0,1,2,\dots$.

Try sorting these three numbers: $5$, $0$, and $-4$. The number $5$ is natural, whole, and an integer.

The number $0$ is whole and an integer, not natural when natural numbers start at $1$. The number $-4$ is an integer only.

:::pair #negative-whole-number
Right: $-1$ is an integer, not a whole number.
Wrong: $-1$ is a whole number.
Whole numbers start at $0$ and never include negatives. Only $0$ is a whole number that is not in $\{1,2,3,\dots\}$.
:::

:::check
Which number in the list $-8$, $\dfrac{1}{2}$, $11$ is an integer but not a whole number?
:::answer
The answer is $-8$. It is negative, so it is an integer but not whole. The number $\dfrac{1}{2}$ is not an integer, and $11$ is whole.
:::

### Rational, Irrational, and Real Numbers

A **rational number** can be written as a fraction $\dfrac{p}{q}$ of two integers, with $q\ne 0$. Every integer $n$ equals $\dfrac{n}{1}$, so every integer is rational. Decimals that stop (like $0.75$) or repeat forever (like $0.333\dots$) are rational too.

An **irrational number** is a real number that cannot be written as an integer fraction. Its decimal goes on forever without repeating. Common examples are $\pi$ and square roots of integers that are not perfect squares, such as $\sqrt{2}$ and $\sqrt{7}$.

Rational and irrational numbers never overlap. Together, they make up all **real numbers**.

<!-- FIGURE: {"kind": "concept-diagram", "type": "nested-boxes", "boxes": ["Natural Numbers", "Whole Numbers", "Integers", "Rational Numbers", "Irrational Numbers", "Real Numbers"], "semanticsLabel": "A nested boxes diagram showing Natural Numbers inside Whole Numbers, Integers, Rational Numbers, with Irrational Numbers beside them inside Real Numbers."} -->

Try testing two roots:

$$\sqrt{9}=3=\dfrac{3}{1}$$

$$\sqrt{7}\approx 2.64575\dots$$

Because $9$ is a perfect square, $\sqrt{9}$ equals $3$, so it is rational. Because $7$ is not a perfect square, $\sqrt{7}$ never ends or repeats, so it is irrational.

Two irrational square roots can still multiply to a rational number if their product is a perfect square:

$$\sqrt{2}\times\sqrt{8}=\sqrt{16}=4$$

:::why
Why is every decimal that stops rational? Place value turns it straight into an integer fraction: $0.75=\dfrac{75}{100}=\dfrac{3}{4}$.
:::

:::pair #perfect-square-root
Right: $\sqrt{9}=3$, which is rational.
Wrong: $\sqrt{9}$ is irrational because it has a square root sign.
Simplify the square root first. A square root of an integer is irrational only when the number inside is not a perfect square.
:::

:::pair #decimal-is-irrational
Right: $0.75=\dfrac{3}{4}$, so $0.75$ is rational.
Wrong: $0.75$ is irrational because it is a decimal.
Only decimals that never end and never repeat are irrational. A decimal that stops, like $0.75$, always writes as a fraction.
:::

:::check
Is $\sqrt{25}$ rational or irrational?
:::answer
The answer is rational. Because $25$ is a perfect square, $\sqrt{25}=5=\dfrac{5}{1}$.
:::

## Mnemonics & Memory Aids

Under this lesson's convention, each set sits inside the next:

> Natural, Whole, Integer, Rational, Real.

Irrational numbers sit inside Real numbers beside Rational numbers, never inside them.

## Examples

### #1: Classifying Number Sets

Which statement is false?

A) Every integer is rational.
B) $\sqrt{49}$ is irrational.
C) Every irrational number is real.
D) A repeating nonterminating decimal is rational.

**Solution:**

1. Check A: every integer $n$ can be written as $\dfrac{n}{1}$, which is an integer fraction, so A is true.
2. Check C: real numbers consist of rational and irrational numbers together, so C is true.

:::try
Finish the last step: check statements B and D, and state which choice is the false statement.
:::answer
The answer is B. Since $49$ is a perfect square, $\sqrt{49}=7$ is rational, so B is false. Statement D is true because a repeating decimal like $0.333\dots=\dfrac{1}{3}$ can be written as an integer fraction.

**Check:** Re-read B: $\sqrt{49}=7=\dfrac{7}{1}$ is an integer fraction, so it cannot be irrational.
:::

## Traps to Watch For

:::checklist
- Natural numbers and whole numbers: follow the question's convention for $0$, and keep negatives out of whole numbers. {#negative-whole-number}
- Square roots: simplify first to check for a perfect square, so $\sqrt{9}=3$ is rational. {#perfect-square-root}
- Decimals that end or repeat: write them as fractions, so $0.75=\dfrac{3}{4}$ is rational. {#decimal-is-irrational}
:::
