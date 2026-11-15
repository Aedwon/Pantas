---
_id: "lesson-algebra-polynomial-synthetic-division"
title: "Polynomials (Synthetic Division)"
summary: "Use the zero of a linear divisor in synthetic division."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 7
partCount: 9
ordering: 19
keyPoints:
  - "Use the zero of a linear divisor in synthetic division."
---
## Core Concept

The **dividend** is what you divide. The **divisor** is what you divide by. The **quotient** is the answer before any leftover part, called the **remainder**.

**Synthetic division** is a shorter method for division by $x-c$. It tracks coefficients instead of writing each power of $x$. Write the dividend's coefficients from highest power to lowest, including zeros for missing powers.

Bring down the first coefficient. Multiply it by $c$, then add to the next coefficient. Repeat the multiply-and-add steps until you reach the last coefficient.

The last result is the remainder. The earlier results are the quotient's coefficients, from highest power to lowest.

When the dividend has degree at least $1$, the quotient's degree is one less than the dividend's degree. A cubic dividend gives a quadratic quotient. For a constant dividend, the quotient is $0$ and the remainder is that constant.

## Examples

### #1: Synthetic Division

Use synthetic division to divide $x^3-4x^2+x+6$ by $x-3$.

**Solution:**

1. Use $c=3$. List the coefficients from highest power to lowest: $1,-4,1,6$.
2. Bring down $1$. Multiply by $3$ and add to the next coefficient.

$$-4+3(1)=-1$$

3. Multiply that result by $3$ and add to the next coefficient.

$$1+3(-1)=-2$$

4. Repeat for the last coefficient.

$$6+3(-2)=0$$

5. The results before the last number are $1,-1,-2$. The dividend has degree $3$, so these are the coefficients of $x^2$, $x$, and the constant.

$$Q(x)=x^2-x-2$$

6. The last number is the remainder.

$$R(x)=0$$

## Speed Tricks & Shortcuts

Synthetic division can be faster for a divisor $x-c$. Include a $0$ for every missing power so each coefficient stays in its proper place.

## Traps to Watch For

### #1: Synthetic-Division Sign

> For $x-c$, use $c$ in synthetic division.

The divisor $x-5$ uses $5$. The divisor $x+5=x-(-5)$ uses $-5$. Using the wrong sign means you divide by a different expression.
