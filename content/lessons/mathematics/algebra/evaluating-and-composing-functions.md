---
_id: "lesson-algebra-evaluating-and-composing-functions"
title: "Evaluating and Composing Functions"
summary: "Evaluate function values and apply functions in the correct order."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 2
partCount: 3
ordering: 53
keyPoints:
  - "Evaluate a function at a given input."
  - "Compose functions in order and check the composition domain."
---
## Core Concept

Evaluating $f(3)$ means using $3$ as the input and calculating the corresponding output.

An input can also be an expression. If $f(x)=2x+3$, replace $x$ with the whole group $x+1$. This gives $f(x+1)=2(x+1)+3=2x+5$. To find $f(x+1)-f(x)$, subtract the whole output $(2x+3)$. The difference is $(2x+5)-(2x+3)=2$.

Composition means feeding the output of one function into another. The notation $(f\circ g)(x)$ means $f(g(x))$, so $g$ is applied first. The input must also belong to the domain of the composition: it must be valid for $g$, and $g(x)$ must be valid for $f$.

## Examples

### #1: Evaluating with a Negative Input

If $f(x)=2x^2-3x+1$, find $f(-2)$.

**Solution:**

Substitute $x=-2$ into $f(x)$:

$$f(-2)=2(-2)^2-3(-2)+1=2(4)+6+1=15$$

### #2: Composition of Functions

If $f(x)=2x+1$ and $g(x)=x^2-3$, find $(f\circ g)(2)$ and $(g\circ f)(2)$.

**Solution:**

1. For $(f\circ g)(2)$:

$$g(2)=1$$

$$f(1)=3$$

So $(f\circ g)(2)=3$.

2. For $(g\circ f)(2)$:

$$f(2)=5$$

$$g(5)=22$$

So $(g\circ f)(2)=22$.

Composition is not generally commutative.

## Speed Tricks & Shortcuts

For a numerical composition such as $(f\circ g)(2)$, it is often efficient to compute $g(2)$ first and then feed that value into $f$.

## Traps to Watch For

### #1: Mixing Up Composition Order

$$(f\circ g)(x)=f(g(x)),$$

so $g$ is applied first.
