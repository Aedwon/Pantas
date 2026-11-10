---
_id: "lesson-algebra-quadratic-equations"
title: "Quadratic Equations"
summary: "Solve quadratic equations and inequalities, and use the discriminant and the sum and product of roots."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **quadratic equation** in $x$ can be written in standard form:

$$ax^2+bx+c=0,$$

where $a\ne0$. A **root** of the equation is a value of $x$ that makes it true. The roots are also called the **zeros** of $ax^2+bx+c$. "Solve" and "find the roots" mean the same thing: find every such value.

A **coefficient** is the number that multiplies a variable term. In $2x^2-8x-2$, the coefficient of $x^2$ is $2$, and the coefficient of $x$ is $-8$.

### Zero-Product Property and Square Roots

If two numbers multiply to $0$, at least one of them is $0$. So if $(x-3)(x+2)=0$, then $x-3=0$ or $x+2=0$.

If $x^2=k$ and $k>0$, then $x=\pm\sqrt{k}$. The sign $\pm$ means "plus or minus", so there are two answers. If $k=0$, the only answer is $x=0$. If $k<0$, there is no real answer.

### Factoring

Factoring means writing the quadratic as a product. It works well when the numbers are friendly.

First take out any common factor. Also watch for a difference of squares: $x^2-9=(x-3)(x+3)$.

A quadratic is **monic** when $a=1$. For a monic $x^2+bx+c$, find two numbers whose product is $c$ and whose sum is $b$.

For $a\ne1$, find two numbers whose product is $ac$ and whose sum is $b$. Use them to split the middle term, then factor by grouping.

### Completing the Square

This method works for any quadratic. It turns one side into a perfect square, such as $(x+3)^2$.

1. Divide the equation by $a$ so the $x^2$ term has coefficient $1$.
2. Move the constant term to the right side.
3. Add $\left(\dfrac{p}{2}\right)^2$ to both sides, where $p$ is the coefficient of $x$.
4. Write the left side as $\left(x+\dfrac{p}{2}\right)^2$ and use square roots.

"Simplest radical form" means no perfect-square factor stays under the root. For example, write $\sqrt8$ as $2\sqrt2$.

### Quadratic Formula and Discriminant

For $ax^2+bx+c=0$ with $a\ne0$:

$$x=\dfrac{-b\pm\sqrt{b^2-4ac}}{2a}$$

The **discriminant** is the number under the square root:

$$D=b^2-4ac$$

For real coefficients, $D$ tells how many real roots there are:

- If $D>0$, there are two different real roots.
- If $D=0$, there is one repeated real root.
- If $D<0$, there are no real roots. The roots are complex numbers, which this lesson does not cover.

<!-- ILLUSTRATION: three parabolas y = ax^2 + bx + c on the same kind of axes, labeled D > 0 (crosses the x-axis at two points), D = 0 (touches the x-axis at one point), D < 0 (stays above the x-axis and never touches it) -->

### Sum and Product of Roots

Suppose the roots are $r_1$ and $r_2$. Then $ax^2+bx+c=a(x-r_1)(x-r_2)$. Multiplying out and comparing coefficients gives these formulas, called Vieta's formulas:

$$r_1+r_2=-\dfrac{b}{a}$$

$$r_1r_2=\dfrac{c}{a}$$

To build an equation from its roots, use $x^2-(r_1+r_2)x+r_1r_2=0$.

### Area of a Rectangle

The area of a rectangle is its length times its width. Word problems about area often lead to a quadratic equation.

### Quadratic Inequalities

A quadratic inequality uses $<$, $>$, $\le$ or $\ge$ instead of $=$. To solve it:

1. Move every term to one side so the other side is $0$.
2. Solve the matching equation to find the roots.
3. The roots cut the number line into parts. The expression keeps one sign in each part.
4. Test one value from each part. Keep the parts that make the inequality true.
5. Include the roots only if the sign is $\le$ or $\ge$.

Suppose the equation has two different real roots. If $a>0$, the graph is a parabola that opens up. It is below zero between the roots and above zero outside them.

If $a<0$, the parabola opens down. It is above zero between the roots and below zero outside them. If $D<0$, the parabola never touches the $x$-axis, so use the sign of $a$ (see Example #11). If $D=0$, it touches the axis at the one root and stays on one side, so the root itself needs care (see Example #13).

## Examples

### #1: Basic Factoring

Find the roots of $x^2-8x+15=0$.

**Solution:**

1. Find two numbers with product $15$ and sum $-8$: they are $-3$ and $-5$.
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

4. Apply the zero-product property.

$$x=-\dfrac12\quad\text{or}\quad x=-3$$

### #3: Completing the Square

Solve $2x^2-8x-2=0$. Leave the answer in simplest radical form.

**Solution:**

1. Divide both sides by $2$.

$$x^2-4x-1=0$$

2. Move the constant term to the right.

$$x^2-4x=1$$

3. Half of $-4$ is $-2$, and $(-2)^2=4$. Add $4$ to both sides.

$$x^2-4x+4=5$$

4. Write the left side as a square.

$$(x-2)^2=5$$

5. Take square roots of both sides.

$$x-2=\pm\sqrt5$$

$$x=2+\sqrt5\quad\text{or}\quad x=2-\sqrt5$$

### #4: Quadratic Formula

Solve $2x^2+4x-3=0$. Write each root in simplest form.

**Solution:**

1. Read the coefficients: $a=2$, $b=4$, $c=-3$.
2. Compute the discriminant.

$$D=4^2-4(2)(-3)=16+24=40$$

3. Substitute into the formula.

$$x=\dfrac{-4\pm\sqrt{40}}{4}$$

4. Simplify the radical: $\sqrt{40}=2\sqrt{10}$. Then divide the top and bottom by $2$.

$$x=\dfrac{-4\pm2\sqrt{10}}{4}=\dfrac{-2\pm\sqrt{10}}{2}$$

### #5: Nature of the Roots

For what values of $k$ does $x^2+kx+9=0$ have exactly one real root?

**Solution:**

1. One real root means a repeated root, so $D=0$.

$$k^2-4(1)(9)=0$$

2. Simplify.

$$k^2=36$$

3. Take square roots.

$$k=6\quad\text{or}\quad k=-6$$

### #6: Sum and Product of Roots

If $r_1$ and $r_2$ are the roots of $3x^2-12x+7=0$, find $\dfrac1{r_1}+\dfrac1{r_2}$.

**Solution:**

1. Find the sum and the product of the roots.

$$r_1+r_2=-\dfrac{b}{a}=-\dfrac{-12}{3}=4$$

$$r_1r_2=\dfrac{c}{a}=\dfrac73$$

2. Combine the two fractions over a common denominator.

$$\dfrac1{r_1}+\dfrac1{r_2}=\dfrac{r_1+r_2}{r_1r_2}$$

3. Substitute. The product is not $0$, so the division is allowed.

$$\dfrac{4}{\frac{7}{3}}=4\cdot\dfrac37=\dfrac{12}{7}$$

### #7: Equation From Its Roots

Write a quadratic equation with integer coefficients whose roots are $2$ and $-5$.

**Solution:**

1. Find the sum and the product.

$$r_1+r_2=2+(-5)=-3$$

$$r_1r_2=2(-5)=-10$$

2. Use $x^2-(r_1+r_2)x+r_1r_2=0$.

$$x^2+3x-10=0$$

### #8: Word Problem

The length of a rectangular lot is $3$ m more than its width. Its area is $40$ m$^2$. Find the width.

**Solution:**

1. Let $w$ be the width. The length is $w+3$, so the area gives an equation.

$$w(w+3)=40$$

2. Write it in standard form and factor.

$$w^2+3w-40=0$$

$$(w+8)(w-5)=0$$

3. The roots are $w=-8$ and $w=5$. A width cannot be negative, so reject $-8$.

The width is $5$ m. The length is $8$ m, and $5\times8=40$.

### #9: Inequality With a Closed Interval

Solve $2x^2-5x-3\le0$.

**Solution:**

1. Factor and find the roots.

$$(2x+1)(x-3)=0$$

$$x=-\dfrac12\quad\text{or}\quad x=3$$

2. Since $a=2>0$, the parabola opens up. It is below zero between the roots.
3. The sign is $\le$, so include the roots.

$$-\dfrac12\le x\le3$$

4. Check with $x=0$: $2(0)^2-5(0)-3=-3$, and $-3\le0$ is true.

<!-- ILLUSTRATION: parabola y = 2x^2 - 5x - 3 opening up, crossing the x-axis at x = -1/2 and x = 3, with the part of the curve on or below the x-axis between those two points marked -->

### #10: Inequality That Is Not Yet Set to Zero

Solve $x^2-2x>8$.

**Solution:**

1. Move every term to the left.

$$x^2-2x-8>0$$

2. Factor and find the roots.

$$(x-4)(x+2)=0$$

$$x=4\quad\text{or}\quad x=-2$$

3. Since $a=1>0$, the expression is above zero outside the roots. The sign is $>$, so do not include the roots.

$$x<-2\quad\text{or}\quad x>4$$

4. Check with $x=5$: $5^2-2(5)=15$, and $15>8$ is true.

### #11: Inequality With No Real Roots

Solve $x^2+4x+5>0$.

**Solution:**

1. Find the discriminant.

$$D=4^2-4(1)(5)=-4$$

2. Since $D<0$, the parabola never touches the $x$-axis. Since $a=1>0$, it opens up, so it stays above the axis.
3. The inequality is true for every real number $x$.

### #12: Inequality With a Negative Leading Coefficient

Solve $-x^2+x+6\ge0$.

**Solution:**

1. Factor and find the roots.

$$-(x-3)(x+2)=0$$

$$x=3\quad\text{or}\quad x=-2$$

2. Since $a=-1<0$, the parabola opens down. It is above zero between the roots.
3. The sign is $\ge$, so include the roots.

$$-2\le x\le3$$

4. Check with $x=0$: $-(0)^2+0+6=6$, and $6\ge0$ is true.

<!-- ILLUSTRATION: parabola y = -x^2 + x + 6 opening down, crossing the x-axis at x = -2 and x = 3, with the part of the curve on or above the x-axis between those two points marked -->

### #13: Inequality With a Repeated Root

Solve $x^2-2x+1>0$. Then solve $x^2-2x+1\le0$.

**Solution:**

1. Factor.

$$x^2-2x+1=(x-1)^2$$

2. A square is never negative, and it equals $0$ only at $x=1$. Here $D=0$ and $a=1>0$.
3. For $>0$, every real number works except the root.

$$x\ne1$$

4. For $\le0$, only the root works.

$$x=1$$

5. Check: $x=0$ gives $1>0$, true. $x=1$ gives $0\le0$, true.

## Speed Tricks & Shortcuts

- With integers $a$, $b$ and $c$, check whether $D$ is a perfect square. A perfect square means the quadratic factors over the integers. Otherwise go straight to the formula.
- When $a+b+c=0$, $x=1$ is a root. The product of the roots is $\dfrac{c}{a}$, so the other root is $\dfrac{c}{a}$.
- For real roots, a positive product $\dfrac{c}{a}$ means the roots have the same sign. A negative product means they have opposite signs. Look at $\dfrac{c}{a}$, not at $c$ alone, because $a$ may be negative.

## Traps to Watch For

### #1: Not Setting the Equation to Zero

> The zero-product property works only when one side is exactly $0$.

If $(x-2)(x+1)=4$, it is wrong to say $x-2=4$ or $x+1=4$. Multiply out, move $4$ to the left, then factor again.

### #2: Forgetting Both Square-Root Solutions

> A square can come from a positive or a negative number.

If $x^2=25$, then $x=\pm5$. The symbol $\sqrt{25}$ by itself equals only $5$.

### #3: Dividing by a Variable

> Dividing by an expression that could be $0$ can lose a solution.

Take $x^2=4x$. Dividing by $x$ gives only $x=4$. Instead write $x(x-4)=0$, which gives $x=0$ and $x=4$.

### #4: Losing the Sign of b in the Formula

> The formula starts with $-b$, not $b$.

If $b=-5$, then $-b=5$. Also, $b^2$ is never negative: $(-5)^2=25$, not $-25$.

### #5: Between or Outside

> Read the sign, then pick the right parts of the number line.

For $a>0$ and two roots, "less than zero" means between the roots, and "greater than zero" means outside them. For $a<0$, it is the other way around.

Writing $-2<x<4$ for $x^2-2x-8>0$ is the common mistake. Test one value to be sure.
