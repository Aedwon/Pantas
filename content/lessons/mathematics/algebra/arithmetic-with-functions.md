---
_id: "lesson-algebra-arithmetic-with-functions"
title: "Arithmetic with Functions"
summary: "Add, subtract, multiply, and divide function outputs."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 54
keyPoints:
  - "Add, subtract, multiply, and divide function outputs."
  - "Use the shared domain and exclude zeros of a divisor."
---
## Core Concept

### Combining Functions

Two functions can be added, subtracted, multiplied, or divided. Do it output by output:

$$(f+g)(x)=f(x)+g(x)$$

$$(f-g)(x)=f(x)-g(x)$$

$$(f\cdot g)(x)=f(x)\cdot g(x)$$

$$\left(\dfrac{f}{g}\right)(x)=\dfrac{f(x)}{g(x)}$$

The new function needs both $f(x)$ and $g(x)$ to exist. So its domain is the inputs that are in the domain of $f$ and also in the domain of $g$. For division, also remove every $x$ where $g(x)=0$.

## Examples

### #1: Combining Functions and Their Domain

Let $f(x)=\sqrt{x-1}$ and $g(x)=x-5$. Find $(f-g)(2)$ and $(f\cdot g)(10)$. Then find the domain of $\dfrac{f}{g}$ and the value of $\left(\dfrac{f}{g}\right)(10)$.

**Solution:**

1. Evaluate $(f-g)(2)$.

$$f(2)=1\qquad g(2)=-3$$

$$(f-g)(2)=1-(-3)=4$$

2. Evaluate $(f\cdot g)(10)$.

$$f(10)=3\qquad g(10)=5$$

$$(f\cdot g)(10)=3\cdot5=15$$

3. The domain of $f$ is $x\ge1$. The domain of $g$ is all real numbers. So both exist when $x\ge1$.
4. For division, also remove the $x$ where $g(x)=0$.

$$x-5=0\quad\Rightarrow\quad x=5$$

So the domain of $\dfrac{f}{g}$ is $[1,5)\cup(5,\infty)$.

5. Since $10$ is in that domain:

$$\left(\dfrac{f}{g}\right)(10)=\dfrac{3}{5}$$
