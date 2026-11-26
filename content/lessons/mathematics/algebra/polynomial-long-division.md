---
_id: "lesson-algebra-polynomial-long-division"
title: "Polynomials (Long Division)"
summary: "Use long division and check the quotient and remainder."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 6
partCount: 9
ordering: 25
keyPoints:
  - "Use long division and check the quotient and remainder."
---
## Core Concept

The **dividend** is what you divide. The **divisor** is what you divide by. The **quotient** is the answer before any leftover part, called the **remainder**.

The **leading term** is the nonzero term with the highest power after like terms are combined. For example, the leading term of $2x^3+3x^2-5x+6$ is $2x^3$.

Polynomial long division works with any nonzero polynomial divisor. Write terms from highest power to lowest, and put a $0$ coefficient in place of a missing power.

1. Divide the leading term of the current expression by the leading term of the divisor.
2. Write that result as the next quotient term.
3. Multiply the entire divisor by that quotient term.
4. Subtract the product and bring down the next dividend term.
5. Repeat until the remainder is $0$ or has lower degree than the divisor.

Each subtraction removes the highest-power term still being divided. The result follows this rule:

$$P(x)=D(x)Q(x)+R(x)$$

Here, $P$ is the dividend, $D$ is the divisor, $Q$ is the quotient, and $R$ is the remainder. If the dividend already has lower degree than the divisor, the quotient is $0$ and the dividend is the remainder.

## Examples

### #1: Polynomial Long Division

Divide $2x^3+3x^2-5x+6$ by $x+2$.

**Solution:**

1. Divide the leading terms to get the first quotient term.

$$\dfrac{2x^3}{x}=2x^2$$

2. Multiply the divisor by $2x^2$, then subtract.

$$(2x^3+3x^2)-(2x^3+4x^2)=-x^2$$

3. Bring down $-5x$. Divide the new leading terms.

$$\dfrac{-x^2}{x}=-x$$

4. Multiply the divisor by $-x$, then subtract.

$$(-x^2-5x)-(-x^2-2x)=-3x$$

5. Bring down $+6$. Divide the new leading terms.

$$\dfrac{-3x}{x}=-3$$

6. Multiply the divisor by $-3$, then subtract.

$$(-3x+6)-(-3x-6)=12$$

7. The constant remainder has lower degree than $x+2$, so stop. Read the quotient and remainder.

$$Q(x)=2x^2-x-3$$

$$R(x)=12$$

8. Check by multiplying the quotient by the divisor and adding the remainder.

$$(x+2)(2x^2-x-3)+12=2x^3+3x^2-5x+6$$
