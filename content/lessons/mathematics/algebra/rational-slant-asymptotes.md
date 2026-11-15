---
_id: "lesson-algebra-rational-slant-asymptotes"
title: "Rational Functions (Slant Asymptotes)"
summary: "Use polynomial division to find a slant asymptote."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 4
partCount: 8
ordering: 10.04
keyPoints:
  - "Use polynomial division to find a slant asymptote."
  - "Explain when a graph may cross an asymptote."
---
## Core Concept

A **rational function** is one polynomial divided by another:

$$f(x)=\dfrac{P(x)}{Q(x)},\qquad Q(x)\ne0$$

Compare degrees after cancellation to find what happens far to the left and right:

- A lower numerator degree gives the horizontal asymptote $y=0$.
- Equal degrees give a horizontal asymptote at the ratio of the leading coefficients.
- A numerator degree exactly $1$ greater gives a **slant asymptote**, a diagonal line the graph approaches far away.
- A numerator degree more than $1$ greater gives no horizontal or slant asymptote. Division gives a curved polynomial part instead.

Polynomial division separates a rational function into a polynomial part and a smaller fraction:

$$\dfrac{P(x)}{Q(x)}=q(x)+\dfrac{r(x)}{Q(x)}$$

Here $q(x)$ is the quotient, or division result. The remainder $r(x)$ has degree below the denominator's degree, or is $0$. Far to the left or right, the smaller fraction gets close to $0$.

If $q(x)$ is linear, $y=q(x)$ is the slant asymptote. A graph can cross a horizontal or slant asymptote. These lines describe what happens far away.

## Examples

### #1: Slant Asymptote

Find the slant asymptote of $f(x)=\dfrac{x^2+1}{x-1}$.

**Solution:**

1. The numerator degree is exactly $1$ greater. Divide $x^2$ by $x$ to get $x$. Subtract the product $x(x-1)$ from the numerator.

$$(x^2+1)-(x^2-x)=x+1$$

2. Divide $x$ by $x$ to get $1$. Subtract the product $1(x-1)$ from what remains.

$$(x+1)-(x-1)=2$$

3. The quotient is $x+1$ and the remainder is $2$.

$$f(x)=x+1+\dfrac{2}{x-1}$$

4. Far to the left or right, the fraction gets close to $0$. The slant asymptote is $y=x+1$.

<!-- ILLUSTRATION: coordinate graph of y=(x^2+1)/(x-1) with dashed slant asymptote y=x+1 and vertical asymptote x=1, label points (0,-1), (2,5), and both axes -->
