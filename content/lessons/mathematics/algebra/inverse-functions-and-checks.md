---
_id: "lesson-algebra-inverse-functions-and-checks"
title: "Inverse Functions and Checks"
summary: "Find an inverse function and check when it exists."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 3
partCount: 3
ordering: 55
keyPoints:
  - "Find an inverse by reversing the input-output pairing."
  - "Use one-to-one behavior and compositions to check inverse functions."
---
## Core Concept

An inverse function reverses the input-output pairing. If $f(2)=7$ and $f$ is invertible on the domain being used, then $f^{-1}(7)=2$.

A function has an inverse **function** on a given domain only when it is one-to-one on that domain. For real graphs, the horizontal line test checks this: every horizontal line must intersect the graph at most once.

A function that is not one-to-one on its full domain can sometimes be restricted to a smaller domain where it becomes one-to-one.

## Examples

### #1: Finding an Inverse Function

Find the inverse of $f(x)=\dfrac{2x-3}{5}$.

**Solution:**

1. Write $y=\dfrac{2x-3}{5}$ and interchange $x$ and $y$.

$$x=\dfrac{2y-3}{5}$$

2. Solve for $y$.

$$5x=2y-3$$

$$5x+3=2y$$

$$y=\dfrac{5x+3}{2}$$

3. Therefore:

$$f^{-1}(x)=\dfrac{5x+3}{2}$$

A check gives $f(4)=1$ and $f^{-1}(1)=4$.

## Speed Tricks & Shortcuts

A single input-output check can **disprove** a claimed inverse if it fails, but one matching pair is not enough to prove two functions are inverses for every input. To verify inverse functions generally, check the compositions on their domains:

$$f(f^{-1}(x))=x$$

and

$$f^{-1}(f(x))=x.$$

## Traps to Watch For

### #1: Thinking $f^{-1}(x)$ Is a Reciprocal

> $f^{-1}(x)$ denotes an inverse function, not $\dfrac{1}{f(x)}$.
