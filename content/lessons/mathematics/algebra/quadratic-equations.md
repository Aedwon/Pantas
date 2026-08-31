---
_id: "lesson-algebra-quadratic-equations"
title: "Quadratic Equations"
summary: "Solve quadratic equations and use the discriminant to describe their roots."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 8
isActive: true
---
## Core Concept

A quadratic equation in $x$ can be written in standard form as:

$$ax^2+bx+c=0,$$

where $a\ne0$. Its solutions are called roots or zeros of the corresponding quadratic polynomial.

### Factoring

Factoring is efficient when the quadratic has convenient factors. For a monic quadratic $x^2+bx+c$, look for two numbers whose product is $c$ and whose sum is $b$. For a quadratic with $a\ne1$, use a method appropriate to the leading coefficient, such as factoring by grouping after splitting the middle term.

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

## Mnemonics & Memory Aids

For the discriminant, remember:

> Positive: two distinct real roots. Zero: one repeated real root. Negative: no real roots.

"No real roots" does not mean no solutions in the complex-number system.

## Examples

### #1: Basic Factoring

Find the roots of $x^2-8x+15=0$.

**Solution:**

1. Find two numbers with product $15$ and sum $-8$: $-3$ and $-5$.
2. Factor.

$$(x-3)(x-5)=0$$

3. Apply the zero-product property.

$$x=3\quad\text{or}\quad x=5$$

### #2: Leading Coefficient Greater Than 1

Solve $2x^2+7x+3=0$.

**Solution:**

1. Compute $ac=6$. The numbers $6$ and $1$ have product $6$ and sum $7$.
2. Split the middle term.

$$2x^2+6x+x+3=0$$

3. Factor by grouping.

$$2x(x+3)+1(x+3)=0$$

$$(2x+1)(x+3)=0$$

4. Therefore:

$$x=-\dfrac12\quad\text{or}\quad x=-3$$

### #3: Nature of the Roots

For what values of $k$ does $x^2+kx+9=0$ have exactly one real root?

**Solution:**

A repeated real root requires $D=0$.

$$k^2-4(1)(9)=0$$

$$k^2=36$$

$$k=6\quad\text{or}\quad k=-6$$

### #4: Sum and Product of Roots

If $r_1$ and $r_2$ are the roots of $3x^2-12x+7=0$, find $\dfrac1{r_1}+\dfrac1{r_2}$.

**Solution:**

By Vieta's formulas:

$$r_1+r_2=-\dfrac{b}{a}=4$$

and

$$r_1r_2=\dfrac{c}{a}=\dfrac73.$$

Since the product is nonzero:

$$\dfrac1{r_1}+\dfrac1{r_2}=\dfrac{r_1+r_2}{r_1r_2}=\dfrac{4}{7/3}=\dfrac{12}{7}$$

## Speed Tricks & Shortcuts

If a problem asks only for the sum or product of the roots of $ax^2+bx+c=0$, Vieta's formulas give:

$$r_1+r_2=-\dfrac{b}{a}$$

$$r_1r_2=\dfrac{c}{a}$$

For **real** roots, the sign of the product $\dfrac{c}{a}$ helps describe their signs. A positive product means the two nonzero real roots have the same sign; a negative product means they have opposite signs. Looking at $c$ alone is not enough when $a$ may be negative.

## Traps to Watch For

### #1: Not Setting the Equation to Zero

To use zero-product factoring, first rewrite the equation with $0$ on one side.

### #2: Forgetting Both Square-Root Solutions

If $x^2=25$, then:

$$x=\pm5.$$

By contrast, the principal square-root symbol $\sqrt{25}$ by itself equals $5$.

### #3: Dividing by a Variable

Dividing an equation by an expression that could equal $0$ can discard valid solutions. For example:

$$x^2=4x$$

should be rewritten as

$$x(x-4)=0,$$

giving both $x=0$ and $x=4$.
