---
_id: "lesson-algebra-quadratic-methods-and-root-properties"
title: "Quadratic Methods and Root Properties"
summary: "Use square completion, the quadratic formula, and root relationships."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 2
partCount: 2
ordering: 28
keyPoints:
  - "Complete the square while keeping both sides equal."
  - "Use the quadratic formula and discriminant to find or describe roots."
  - "Use the sum and product of roots."
---
## Core Concept

### Completing the Square

Completing the square works for any quadratic. First isolate or normalize the quadratic and linear terms so the coefficient of $x^2$ is $1$. For an expression

$$x^2+px,$$

add

$$\left(\dfrac{p}{2}\right)^2$$

to create a perfect-square trinomial. In an equation, preserve equality by making the corresponding change to both sides.



### Quadratic Formula and Discriminant

For $ax^2+bx+c=0$ with $a\ne0$:

$$x=\dfrac{-b\pm\sqrt{b^2-4ac}}{2a}$$

The **discriminant** is:

$$D=b^2-4ac$$

For real coefficients:

- If $D>0$, there are two distinct real roots.
- If $D=0$, there is one repeated real root.
- If $D<0$, there are two non-real complex-conjugate roots.

If a problem asks only for the sum or product of the roots of $ax^2+bx+c=0$, Vieta's formulas give:

$$r_1+r_2=-\dfrac{b}{a}$$

$$r_1r_2=\dfrac{c}{a}$$

For **real** roots, the sign of the product $\dfrac{c}{a}$ helps describe their signs. A positive product means the two nonzero real roots have the same sign; a negative product means they have opposite signs. Looking at $c$ alone is not enough when $a$ may be negative.

## Mnemonics & Memory Aids

For the discriminant, remember:

> Positive: two distinct real roots. Zero: one repeated real root. Negative: no real roots.

"No real roots" does not mean no solutions in the complex-number system.

## Examples

### #1: Nature of the Roots

For what values of $k$ does $x^2+kx+9=0$ have exactly one real root?

**Solution:**

A repeated real root requires $D=0$.

$$k^2-4(1)(9)=0$$

$$k^2=36$$

$$k=6\quad\text{or}\quad k=-6$$

### #2: Sum and Product of Roots

If $r_1$ and $r_2$ are the roots of $3x^2-12x+7=0$, find $\dfrac1{r_1}+\dfrac1{r_2}$.

**Solution:**

By Vieta's formulas:

$$r_1+r_2=-\dfrac{b}{a}=4$$

and

$$r_1r_2=\dfrac{c}{a}=\dfrac73.$$

Since the product is nonzero:

$$\dfrac1{r_1}+\dfrac1{r_2}=\dfrac{r_1+r_2}{r_1r_2}=\dfrac{4}{7/3}=\dfrac{12}{7}$$

## Traps to Watch For

### #1: Forgetting Both Square-Root Solutions

If $x^2=25$, then:

$$x=\pm5.$$

By contrast, the principal square-root symbol $\sqrt{25}$ by itself equals $5$.
