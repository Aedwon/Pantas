---
_id: "lesson-algebra-logarithm-product-quotient-and-power-laws"
title: "Logarithm Product, Quotient, and Power Laws"
summary: "Combine logarithms using product, quotient, and power laws."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 4
partCount: 4
ordering: 13
keyPoints:
  - "Condense logarithms with product, quotient, and power laws."
  - "Express logarithms in terms of given logarithm values."
---
## Core Concept

For a base $b>0$, $b\ne1$, and positive $M$ and $N$:

$$\log_b(MN)=\log_b M+\log_b N$$

$$\log_b\left(\dfrac{M}{N}\right)=\log_b M-\log_b N$$

$$\log_b(M^p)=p\log_b M$$

These rules come from the exponent rules. Multiplying powers adds their exponents, so the logarithm of a product becomes a sum.

A logarithm written as $\log(x)$ with no base shown is the **common logarithm**, with base $10$ in this lesson.

## Mnemonics & Memory Aids

For logarithms:

> Products become sums, quotients become differences, and powers move in front.

Use these reminders only under the conditions in Core Concept.

## Examples

### #1: Condensing Logarithmic Expressions

For $x>0$, $y>0$, and $z>0$, express $2\log(x)+\log(y)-3\log(z)$ as a single common logarithm.

**Solution:**

1. Use the power rule.

$$2\log(x)+\log(y)-3\log(z)=\log(x^2)+\log(y)-\log(z^3)$$

2. Use the product rule.

$$\log(x^2)+\log(y)-\log(z^3)=\log(x^2y)-\log(z^3)$$

3. Use the quotient rule.

$$\log(x^2y)-\log(z^3)=\log\left(\dfrac{x^2y}{z^3}\right)$$

### #2: Logarithms in Terms of Given Variables

If $\log_{10}(2)=a$ and $\log_{10}(3)=b$, express $\log_{10}(12)$ in terms of $a$ and $b$.

**Solution:**

1. Factor $12$.

$$12=2^2\times3$$

2. Use the product rule.

$$\log_{10}(12)=\log_{10}(2^2)+\log_{10}(3)$$

3. Move the exponent in front.

$$\log_{10}(12)=2\log_{10}(2)+\log_{10}(3)$$

4. Use the given values.

$$\log_{10}(12)=2a+b$$

## Traps to Watch For

### #1: Logarithm of a Sum

> There is no general sum rule for logarithms.

In general, $\log_b(x+y)$ cannot become $\log_b x+\log_b y$. The product rule needs multiplication inside the logarithm.
