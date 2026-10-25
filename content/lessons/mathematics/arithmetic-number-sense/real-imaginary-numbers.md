---
_id: "lesson-arithmetic-number-sense-real-imaginary-numbers"
title: "Real and Imaginary Number Systems"
summary: "Classify common number sets and solve basic problems with imaginary and complex numbers."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 10
isActive: true
---
## Core Concept

Numbers can be grouped into number sets.

In this lesson, **natural numbers** are the positive counting numbers $1,2,3,\dots$. Some definitions also include $0$, so follow the convention given in the question.

**Whole numbers** are $0,1,2,3,\dots$.

**Integers** include whole numbers and their negatives: $\dots,-2,-1,0,1,2,\dots$.

**Rational numbers** can be written as $\dfrac{p}{q}$, where $p$ and $q$ are integers and $q\ne0$. Their decimal forms end or repeat.

**Irrational numbers** are real numbers that cannot be written as such an integer ratio. Their decimal forms do not end or repeat. Examples include $\pi$ and $\sqrt{2}$.

Rational and irrational numbers together make up the **real numbers**.

<!-- FIGURE: {"kind": "concept-diagram", "type": "nested-boxes", "boxes": ["Natural Numbers", "Whole Numbers", "Integers", "Rational Numbers", "Irrational Numbers", "Real Numbers"], "semanticsLabel": "A nested boxes diagram showing Natural Numbers inside Whole Numbers, Integers, Rational Numbers, with Irrational Numbers beside them inside Real Numbers."} -->

No real number squares to $-1$. The **imaginary unit** $i$ is defined by:

$$i^2=-1$$

It is also written as $i=\sqrt{-1}$ when square roots are extended to complex numbers. For a positive real number $k$, write $\sqrt{-k}=i\sqrt{k}$.

A **complex number** has the form $a+bi$, where $a$ and $b$ are real numbers. The number $a$ is the **real part**, and $b$ is the **imaginary part**.

If $b=0$, the number is real. If $a=0$ and $b\ne0$, it is purely imaginary.

### Powers of $i$

The powers of $i$ repeat every $4$ powers:

$$i^1=i$$

$$i^2=-1$$

$$i^3=-i$$

$$i^4=1$$

Then the same pattern starts again. For a large positive exponent, divide the exponent by $4$ and use the remainder to find its place in the cycle. A remainder of $0$ matches $i^4=1$.

### Multiplying Complex Numbers

Multiply each term in the first complex number by each term in the second. Then replace $i^2$ with $-1$. Add the real terms together and the $i$ terms together.

For letters $a,b,c,d$ that stand for real numbers, this gives:

$$(a+bi)(c+di)=ac+adi+bci+bdi^2$$

After using $i^2=-1$, the product is:

$$(ac-bd)+(ad+bc)i$$

### Conjugates and Division

The **conjugate** of $a+bi$ is $a-bi$. The real part stays the same, while the sign of the $i$ term changes.

When a complex number is multiplied by its conjugate, the $i$ terms cancel. Using $i^2=-1$ gives a real product:

$$(a+bi)(a-bi)=a^2+b^2$$

To divide by a nonzero complex number $c+di$, multiply the numerator and denominator by its conjugate $c-di$:

$$\dfrac{a+bi}{c+di}\times\dfrac{c-di}{c-di}$$

The second fraction equals $1$, so the value does not change. The denominator becomes $c^2+d^2$, which is real. Finish by dividing each term in the numerator by that real denominator.

The divisor must not be $0$.

## Mnemonics & Memory Aids

> Powers of $i$: $i,-1,-i,1$, then repeat.

Under the convention used in this lesson, each set below is contained in the next:

> Natural, Whole, Integer, Rational, Real.

Irrational numbers are also real, but they are not rational.

## Examples

### #1: Classifying Number Sets

Using this lesson's convention that natural numbers begin at $1$, which statement is false?

A) Every integer is rational.
B) Zero is a natural number.
C) Every irrational number is real.
D) A repeating nonterminating decimal is rational.

**Solution:**

1. Every integer $n$ can be written as $\dfrac{n}{1}$, so A is true.
2. Natural numbers begin at $1$ under this lesson's convention, so B is false.
3. Irrational numbers are real, so C is true.
4. A repeating decimal can be written as a fraction, so D is true.
5. The answer is B.

### #2: Simplifying Large Powers of $i$

"Evaluate" means find the final number answer.

Evaluate $i^{143}+i^{2024}$.

**Solution:**

1. Divide $143$ by $4$. The remainder is $3$.

$$143=4(35)+3$$

$$i^{143}=i^3=-i$$

2. Divide $2024$ by $4$. The remainder is $0$.

$$2024=4(506)$$

$$i^{2024}=1$$

3. Add the two results.

$$i^{143}+i^{2024}=-i+1=1-i$$

### #3: Multiplying Complex Numbers

What is $(3-4i)(2+5i)$?

**Solution:**

1. Multiply each term in the first number by each term in the second.

$$(3-4i)(2+5i)=6+15i-8i-20i^2$$

2. Replace $i^2$ with $-1$ and add matching terms.

$$6+15i-8i-20(-1)=26+7i$$

### #4: Dividing Complex Numbers

"Express" means write an equal answer in the form asked for.

Express $\dfrac{2+3i}{1-i}$ in standard form $a+bi$.

**Solution:**

1. The conjugate of $1-i$ is $1+i$. Multiply the numerator and denominator by $1+i$.

$$\dfrac{2+3i}{1-i}\times\dfrac{1+i}{1+i}$$

2. Multiply the numerator and use $i^2=-1$.

$$(2+3i)(1+i)=2+5i+3i^2$$

$$2+5i+3(-1)=-1+5i$$

3. Multiply the denominator.

$$(1-i)(1+i)=1-i^2=2$$

4. Divide both terms in the numerator by $2$.

$$\dfrac{-1+5i}{2}=-\dfrac{1}{2}+\dfrac{5}{2}i$$

## Speed Tricks & Shortcuts

- **Large powers of $i$.** Divide the exponent by $4$. Use only the remainder to find the answer in the repeating cycle.
- **Write a conjugate quickly.** Keep the real part and change only the sign of the $i$ term. For example, the conjugate of $3+4i$ is $3-4i$.
- **Check standard form.** Write the final complex-number answer as a real part plus an $i$ part, such as $a+bi$.

## Traps to Watch For

### #1: Multiplying Square Roots of Negative Real Numbers

> Rewrite negative square roots using $i$ before multiplying them.

For nonnegative real numbers $a$ and $b$, the rule $\sqrt{a}\sqrt{b}=\sqrt{ab}$ works. If both numbers under the square roots are negative, using that rule can give the wrong sign.

For example:

$$\sqrt{-4}\sqrt{-9}=(2i)(3i)=6i^2=-6$$

Multiplying the numbers under the roots first would give $\sqrt{36}=6$. That is the wrong answer here.

### #2: Natural Number Convention

> Whether $0$ is a natural number depends on the convention used.

This lesson uses $1,2,3,\dots$ as the natural numbers and $0,1,2,3,\dots$ as the whole numbers. If a question gives a different definition, use that definition.

### #3: Dividing by Zero

> A conjugate does not make division by $0$ valid.

The denominator in a complex-number division problem must be nonzero. If the divisor equals $0$, the quotient is undefined.
