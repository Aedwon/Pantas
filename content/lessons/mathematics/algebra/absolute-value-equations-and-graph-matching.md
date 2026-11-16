---
_id: "lesson-algebra-absolute-value-equations-and-graph-matching"
title: "Absolute Value (Equations and Graph Matching)"
summary: "Solve absolute-value equations using both cases."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 5
partCount: 8
ordering: 40
keyPoints:
  - "Solve absolute-value equations using both cases."
  - "Match an absolute-value graph to its formula."
---
## Core Concept

### Absolute-Value Functions

**Absolute value**, written $|x|$, means the distance of $x$ from $0$. The bars tell you to take that distance, so the result cannot be negative.

$$|x|=\begin{cases}x,&x\ge0\\-x,&x<0\end{cases}$$

For example, $|-4|=-(-4)=4$. The graph of $y=|x|$ is a V with vertex $(0,0)$.

For $|u|=c$ with $c>0$, the inside value is $c$ or $-c$. Both are the same distance from $0$. If $c=0$, only $u=0$ works; if $c<0$, there is no real solution.

A transformed absolute-value function has the form:

$$f(x)=a|x-h|+k,\qquad a\ne0$$

Its vertex is $(h,k)$. Replacing $x$ with $x-h$ moves the vertex to input $h$. Adding $k$ moves every output up when $k>0$, or down when $k<0$.

A negative $a$ also reflects the V across the $x$-axis before the vertical shift. The V then opens downward.

## Examples

### #1: Absolute-Value Equation

Solve $|2x-5|=7$.

**Solution:**

1. The inside can be $7$ or $-7$. Both have distance $7$ from $0$.

$$2x-5=7\quad\text{or}\quad2x-5=-7$$

2. Add $5$ to each equation.

$$2x=12\quad\text{or}\quad2x=-2$$

3. Divide by $2$.

$$x=6\quad\text{or}\quad x=-1$$

4. Check both values in the original equation.

$$|2(6)-5|=|7|=7$$

$$|2(-1)-5|=|-7|=7$$

### #2: Matching a Graph to a Formula

A graph is a downward-opening V with vertex $(2,3)$ and passes through $(0,-1)$. Which formula matches it: $y=2|x-2|+3$, $y=-2|x+2|+3$, or $y=-2|x-2|+3$?

<!-- ILLUSTRATION: coordinate graph on -1<=x<=5 and -4<=y<=4 of a downward-opening V with labeled vertex (2,3) and labeled point (0,-1), with no equation printed -->

**Solution:**

1. The downward-opening V needs a negative factor. This removes $y=2|x-2|+3$.
2. The vertex has input $2$, so the inside must be $x-2$. This leaves $y=-2|x-2|+3$.
3. Check the given point.

$$-2|0-2|+3=-4+3=-1$$

4. The matching formula is $y=-2|x-2|+3$.

## Speed Tricks & Shortcuts

For graph matching, identify the family first. Then check the vertex, opening direction, or asymptotes. Test an easy input that belongs to the domain.

One matching point does not prove that two graphs are identical. Use the shape and the point together.

## Traps to Watch For

### #1: Impossible Absolute-Value Equation

> Absolute value cannot equal a negative number.

The equation $|u|=-3$ has no real solution. Distance from $0$ cannot be negative, so splitting it into two equations would give false answers.
