---
_id: "lesson-algebra-absolute-value-transformations"
title: "Absolute Value (Graph Transformations)"
summary: "Find the vertex and range after shifts."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 6
partCount: 8
ordering: 62
keyPoints:
  - "Find the vertex and range after shifts."
  - "Describe stretches, compressions, and reflections."
---
## Core Concept

**Absolute value**, written $|x|$, means the distance of $x$ from $0$. The bars tell you to take that distance, so the result cannot be negative.

$$|x|=\begin{cases}x,&x\ge0\\-x,&x<0\end{cases}$$

For example, $|-4|=-(-4)=4$. The graph of $y=|x|$ is a V with vertex $(0,0)$.

A transformed absolute-value function has the form:

$$f(x)=a|x-h|+k,\qquad a\ne0$$

Its vertex is $(h,k)$. Replacing $x$ with $x-h$ moves the vertex to input $h$. Adding $k$ moves every output up when $k>0$, or down when $k<0$.

The size $|a|$ changes how far outputs lie from the vertex height. If $|a|>1$, the V stretches vertically and becomes narrower. If $0<|a|<1$, it compresses vertically and becomes wider.

A negative $a$ also reflects the V across the $x$-axis before the vertical shift. The V then opens downward.

## Examples

### #1: Absolute-Value Transformation

Describe the graph of $f(x)=-2|x-3|+1$ from the basic graph $y=|x|$.

**Solution:**

1. The expression $x-3$ shifts the graph right by $3$. The added $1$ shifts it up by $1$.
2. The factor has size $2$, so the graph stretches vertically by $2$ and becomes narrower.
3. The negative factor reflects the V across the $x$-axis before the upward shift. The graph opens downward with vertex $(3,1)$.

<!-- ILLUSTRATION: coordinate graph of y=-2|x-3|+1 with vertex (3,1), points (2,-1) and (4,-1), opening downward, alongside dashed y=|x| for comparison -->

### #2: A Wider Absolute-Value Graph

Describe the graph of $g(x)=\dfrac{1}{2}|x+2|-3$.

**Solution:**

1. Write $x+2$ as $x-(-2)$. The graph shifts left by $2$ and down by $3$, giving vertex $(-2,-3)$.
2. The positive factor $\dfrac{1}{2}$ makes the V wider. It still opens upward.

<!-- ILLUSTRATION: coordinate graph of y=(1/2)|x+2|-3 on -6<=x<=4 and -4<=y<=4, with labeled vertex (-2,-3) and points (-4,-2) and (0,-2), alongside dashed y=|x| for comparison, and both axes labeled -->
