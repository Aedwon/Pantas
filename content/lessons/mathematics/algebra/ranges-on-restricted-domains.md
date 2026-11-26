---
_id: "lesson-algebra-ranges-on-restricted-domains"
title: "Ranges on Restricted Domains"
summary: "Find the range of a linear function with open, closed, or unbounded domain ends."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 52
keyPoints:
  - "Find the range of a linear function with open, closed, or unbounded domain ends."
  - "Check a quadratic\u2019s turning point and see whether excluded ends have outputs attained elsewhere."
---
## Core Concept

To find the range from a rule and a stated domain, find which outputs the rule reaches. For a straight line that is not horizontal, the smallest and largest outputs come from the two ends of the domain.

A line that is not horizontal never gives the same output twice. So if an end is left out, as in $2x+1$ on $1<x\le4$, the output at that end is left out too, and the range is $(3,9]$.

A horizontal line, such as $y=3$, gives the same output for every input. Its range is just $\{3\}$.

If the domain has no end on one side, the range of a line that is not horizontal also has no end on one side. A rising line keeps the same side, so $2x+1$ on $x\ge0$ gives $[1,\infty)$. A falling line flips the side, so $-2x+1$ on $x\ge0$ gives $(-\infty,1]$.

For a parabola (the curve of $y=ax^2+bx+c$ with $a\ne0$), also check the **turning point**. This is the point where the curve stops falling and starts rising, or the reverse.

For $y=a(x-h)^2+k$ it is at $x=h$, with output $k$. For $y=ax^2+bx+c$ it is at $x=-\dfrac{b}{2a}$. Use it only if it lies inside the domain.

When the domain is all real numbers, the sign of $a$ decides the range. If $a>0$, the parabola opens up, so the turning point gives the least output and the range goes from that output up. If $a<0$, it opens down, so the turning point gives the greatest output and the range goes from that output down.

For example, $y=x^2-4x+5$ has $-\dfrac{b}{2a}=2$, and the output there is $1$. Since $a=1>0$, the range is $[1,\infty)$. The lesson Types of Functions (Linear, Quadratic, Rational, Absolute Value, Exponential, Logarithmic, Piecewise) teaches how $a$ sets the opening direction.

A parabola can give the same output twice. So a left-out end's output is left out only if no included input gives it. For $y=x^2$ on $-2<x\le2$, the left-out end gives $4$, but $x=2$ also gives $4$, so the range is $[0,4]$.

## Speed Tricks & Shortcuts

To find a range on an interval, test the two end values. Round-bracket the output of a left-out end only if no included input gives that output.

If the function is a parabola, also test its turning point when it lies inside the interval. The ends alone are enough when the function steadily rises or steadily falls on the interval.

## Examples

### #1: Finding the Range

Find the range of $f(x)=2x+1$ on the domain $[1,4]$. Then find the range of $h(x)=(x-2)^2+1$ on the domain $[0,5]$.

**Solution:**

1. The line $f$ goes up as $x$ goes up, so the ends of the domain give the ends of the range.

$$f(1)=2(1)+1=3\qquad f(4)=2(4)+1=9$$

So the range is $[3,9]$.

2. The curve $h$ is a parabola written as $(x-2)^2+1$, so its turning point is at $x=2$. That is inside $[0,5]$. There $h(2)=1$. Since $a=1>0$, the parabola opens up, so $1$ is the smallest output.
3. Check the two ends of the domain.

$$h(0)=(0-2)^2+1=5\qquad h(5)=(5-2)^2+1=10$$

The largest output is $10$. So the range is $[1,10]$.
