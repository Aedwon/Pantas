---
_id: "lesson-arithmetic-number-sense-complex-products-and-quotients"
title: "Complex Products and Quotients"
summary: "Multiply complex numbers and replace the square of i with negative one."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 3
ordering: 203
keyPoints:
  - "Multiply complex numbers and replace the square of i with negative one."
  - "Use a conjugate to divide by a nonzero complex number."
---
## Core Concept

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

## Examples

### #1: Multiplying Complex Numbers

What is $(3-4i)(2+5i)$?

**Solution:**

1. Multiply each term in the first number by each term in the second.

$$(3-4i)(2+5i)=6+15i-8i-20i^2$$

2. Replace $i^2$ with $-1$ and add matching terms.

$$6+15i-8i-20(-1)=26+7i$$

### #2: Dividing Complex Numbers

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

- **Write a conjugate quickly.** Keep the real part and change only the sign of the $i$ term. For example, the conjugate of $3+4i$ is $3-4i$.
- **Check standard form.** Write the final complex-number answer as a real part plus an $i$ part, such as $a+bi$.

## Traps to Watch For

### #1: Dividing by Zero

> A conjugate does not make division by $0$ valid.

The denominator in a complex-number division problem must be nonzero. If the divisor equals $0$, the quotient is undefined.
