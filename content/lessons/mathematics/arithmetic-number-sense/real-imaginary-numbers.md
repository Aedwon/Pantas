---
_id: "lesson-arithmetic-number-sense-real-imaginary-numbers"
title: "Real and Imaginary Number Systems"
summary: "Classify common number sets and solve basic problems with imaginary and complex numbers."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 8
isActive: true
---
## Core Concept

Numbers can be classified into nested sets.

In this lesson, **natural numbers** means the positive counting numbers $1,2,3,\dots$. Some textbooks instead include $0$ in the natural numbers, so always follow the convention stated in a problem.

**Whole numbers** are $0,1,2,3,\dots$.

**Integers** include the whole numbers and their negatives: $\dots,-2,-1,0,1,2,\dots$.

**Rational numbers** can be written as $\dfrac{p}{q}$ where $p$ and $q$ are integers and $q\ne0$. Their decimal expansions terminate or repeat.

**Irrational numbers** are real numbers that cannot be written as such an integer ratio. Their decimal expansions do not terminate or repeat. Examples include $\pi$ and $\sqrt{2}$.

Together, rational and irrational numbers make up the **real numbers**.

<!-- FIGURE: {"kind": "concept-diagram", "type": "nested-boxes", "boxes": ["Natural Numbers", "Whole Numbers", "Integers", "Rational Numbers", "Irrational Numbers", "Real Numbers"], "semanticsLabel": "A nested boxes diagram showing Natural Numbers inside Whole Numbers, Integers, Rational Numbers, with Irrational Numbers beside them inside Real Numbers."} -->

No real number squares to $-1$. The imaginary unit $i$ is defined by:

$$i^2=-1,$$

and is commonly written as $i=\sqrt{-1}$ when extending square roots into the complex number system.

A **complex number** has the form $a+bi$, where $a$ and $b$ are real numbers. The number $a$ is the **real part**, and $b$ is the **imaginary part**. If $b=0$, the complex number is real. If $a=0$ and $b\ne0$, it is purely imaginary.

## Mnemonics & Memory Aids

Under the convention used in this lesson, the common nesting is:

> Natural $\subset$ Whole $\subset$ Integer $\subset$ Rational $\subset$ Real.

Irrational numbers are also real but are not rational.

The powers of $i$ repeat every four powers:

* $i^1=i$
* $i^2=-1$
* $i^3=-i$
* $i^4=1$

## Examples

### #1: Classifying Number Sets

Using this lesson's convention that natural numbers begin at $1$, which statement is false?

A) Every integer is rational.
B) Zero is a natural number.
C) Every irrational number is real.
D) A repeating nonterminating decimal is rational.

**Solution:**

1. Every integer $n$ can be written as $\dfrac{n}{1}$, so A is true.
2. Under the convention stated in this lesson, natural numbers begin at $1$, so B is false.
3. Irrational numbers are a subset of the real numbers, so C is true.
4. A repeating decimal can be represented as a fraction, so D is true.
5. The answer is B.

### #2: Simplifying Large Powers of $i$

Evaluate $i^{143}+i^{2024}$.

**Solution:**

1. Reduce each exponent modulo $4$.
2. $143$ leaves remainder $3$, so $i^{143}=i^3=-i$.
3. $2024$ leaves remainder $0$, so $i^{2024}=1$.
4. Therefore:

$$i^{143}+i^{2024}=1-i$$

### #3: Multiplying Complex Numbers

What is $(3-4i)(2+5i)$?

**Solution:**

1. Expand.

$$(3-4i)(2+5i)=6+15i-8i-20i^2$$

2. Since $i^2=-1$:

$$6+7i+20=26+7i$$

### #4: Dividing Complex Numbers

Express $\dfrac{2+3i}{1-i}$ in standard form $a+bi$.

**Solution:**

1. Multiply numerator and denominator by the conjugate $1+i$ so the denominator becomes real.

$$\dfrac{2+3i}{1-i}\times\dfrac{1+i}{1+i}$$

2. Expand the numerator.

$$(2+3i)(1+i)=2+5i+3i^2=-1+5i$$

3. Expand the denominator.

$$(1-i)(1+i)=1-i^2=2$$

4. Therefore:

$$\dfrac{-1+5i}{2}=-\dfrac{1}{2}+\dfrac{5}{2}i$$

## Speed Tricks & Shortcuts

1. Powers of $i$ depend only on the exponent modulo $4$. For example, $1997$ leaves remainder $1$ when divided by $4$, so $i^{1997}=i$.

2. A complex number times its conjugate gives a real nonnegative value:

$$(a+bi)(a-bi)=a^2+b^2.$$

For example:

$$(3+4i)(3-4i)=3^2+4^2=25.$$

## Traps to Watch For

### #1: Multiplying Square Roots of Negative Real Numbers

> Rewrite negative square roots using $i$ before applying ordinary radical-product rules.

For principal square roots in the complex numbers:

$$\sqrt{-4}\sqrt{-9}=(2i)(3i)=6i^2=-6,$$

so the real-number identity $\sqrt{a}\sqrt{b}=\sqrt{ab}$ cannot be applied blindly when both radicands are negative.

### #2: Natural Number Convention

> Whether $0$ is included in the natural numbers depends on convention.

This lesson uses natural numbers $1,2,3,\dots$ and whole numbers $0,1,2,3,\dots$. If a question defines a different convention, follow that definition.
