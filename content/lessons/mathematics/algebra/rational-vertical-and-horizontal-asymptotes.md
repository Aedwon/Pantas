---
_id: "lesson-algebra-rational-vertical-and-horizontal-asymptotes"
title: "Rational Functions (Vertical and Horizontal Asymptotes)"
summary: "Find vertical asymptotes after cancellation."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 3
partCount: 8
ordering: 10.03
keyPoints:
  - "Find vertical asymptotes after cancellation."
  - "Compare degrees to find horizontal asymptotes."
---
## Core Concept

A **rational function** is one polynomial divided by another:

$$f(x)=\dfrac{P(x)}{Q(x)},\qquad Q(x)\ne0$$

The domain leaves out every input that makes the original denominator $0$. The **degree** of a nonzero polynomial is its highest exponent. Its **leading coefficient** is the number multiplying its highest-power term.

An **asymptote** is a line a graph gets closer to in a certain direction. First cancel common factors to study the simpler graph shape. One useful factoring rule is:

$$a^2-b^2=(a-b)(a+b)$$

If a factor remains in the denominator after cancellation, its real zero gives a **vertical asymptote**. Near that input, the graph rises or falls without bound. A partly canceled factor can still give a vertical asymptote.

Compare degrees after cancellation to find what happens far to the left and right:

- A lower numerator degree gives the horizontal asymptote $y=0$.
- Equal degrees give a horizontal asymptote at the ratio of the leading coefficients.
- A numerator degree exactly $1$ greater gives a **slant asymptote**, a diagonal line the graph approaches far away.
- A numerator degree more than $1$ greater gives no horizontal or slant asymptote. Division gives a curved polynomial part instead.

## Examples

### #1: Vertical and Horizontal Asymptotes

Find the vertical and horizontal asymptotes of $f(x)=\dfrac{x+1}{x-2}$.

**Solution:**

1. No factor cancels. Find the denominator's zero.

$$x-2=0\quad\Rightarrow\quad x=2$$

2. The vertical asymptote is $x=2$. The degrees are equal, so divide the leading coefficients.

$$y=\dfrac{1}{1}=1$$

3. The horizontal asymptote is $y=1$.

<!-- ILLUSTRATION: coordinate graph of y=(x+1)/(x-2), with dashed asymptotes x=2 and y=1, labeled points (-1,0), (0,-1/2), and (3,4), and both branches -->

### #2: Lower Numerator Degree

Find the horizontal asymptote of $f(x)=\dfrac{2}{x^2+1}$.

**Solution:**

1. The numerator has degree $0$, and the denominator has degree $2$.
2. The numerator degree is lower, so the horizontal asymptote is $y=0$.
