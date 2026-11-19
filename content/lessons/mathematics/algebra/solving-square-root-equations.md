---
_id: "lesson-algebra-solving-square-root-equations"
title: "Solving Square-Root Equations"
summary: "Isolate and square one radical at a time."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 18
keyPoints:
  - "Isolate and square one radical at a time."
  - "Check candidates in the original equation."
---
## Core Concept

### Radical Equations

A **radical equation** has the unknown inside a radical. To solve it:

1. Get one radical alone on one side.
2. Raise both sides to the power equal to the index.
3. If a radical is still left, get it alone and raise both sides to the power again.
4. Solve the new equation.
5. Substitute each answer into the original equation.

Two tools help in step $4$. Squaring a binomial gives $(a+b)^2=a^2+2ab+b^2$ and $(a-b)^2=a^2-2ab+b^2$. If a product is $0$, one of its factors is $0$, so $x(x-5)=0$ gives $x=0$ or $x=5$.

For a trinomial such as $m^2-6m-7$, look for two numbers that multiply to $-7$ and add to $-6$. They are $-7$ and $1$, so it factors as $(m-7)(m+1)$. The Quadratic Equations lesson teaches factoring in full.

Step $5$ matters for square roots. Squaring turns $a=b$ into $a^2=b^2$, and that is also true when $a=-b$.

So squaring can add a false answer, called an **extraneous root**. Cubing does not add false real answers, because $a^3=b^3$ gives $a=b$ for real numbers.

## Examples

### #1: A Radical Equation with an Extraneous Root

Solve $\sqrt{x+4}+2=x$.

**Solution:**

1. Get the radical alone.

$$\sqrt{x+4}=x-2$$

2. Square both sides.

$$x+4=x^2-4x+4$$

3. Move everything to one side and factor.

$$x^2-5x=0 \quad\Rightarrow\quad x(x-5)=0$$

So $x=0$ or $x=5$.

4. Check in the original equation. For $x=5$: $\sqrt9+2=5$, which is true. For $x=0$: $\sqrt4+2=4$, but the right side is $0$. So $x=0$ is extraneous.

The solution is $x=5$.

### #2: A Radical Equation with Two Radicals

Solve $\sqrt{3m+4}-\sqrt{m+2}=2$.

**Solution:**

1. Get one radical alone, then square both sides.

$$\sqrt{3m+4}=2+\sqrt{m+2} \quad\Rightarrow\quad 3m+4=4+4\sqrt{m+2}+m+2$$

2. A radical is still left. Get it alone and square again.

$$2m-2=4\sqrt{m+2} \quad\Rightarrow\quad m-1=2\sqrt{m+2} \quad\Rightarrow\quad m^2-2m+1=4m+8$$

3. Move everything to one side and factor.

$$m^2-6m-7=0 \quad\Rightarrow\quad (m-7)(m+1)=0$$

4. Check. For $m=7$: $\sqrt{25}-\sqrt9=2$, which is true. For $m=-1$: $\sqrt1-\sqrt1=0$, not $2$. So $m=-1$ is extraneous.

The solution is $m=7$.

## Traps to Watch For

### #1: Skipping the Check in a Radical Equation

> Squaring can create answers that do not satisfy the original equation.

In Example #9, the algebra gave $x=0$ and $x=5$, but only $x=5$ works. Always substitute back into the original equation when you square both sides.
