---
_id: "lesson-algebra-functions-domain-and-range"
title: "Functions, Domain, and Range"
summary: "Identify functions and find their allowed inputs and outputs."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 3
ordering: 51
keyPoints:
  - "Identify functions from input-output pairs or the vertical line test."
  - "Find domain restrictions and the range of a function."
---
## Core Concept

A **relation** is a set of ordered pairs $(x,y)$. A **function** is a relation in which every input has exactly one output.

So $\{(1,2),(2,3),(3,3)\}$ is a function. Different inputs may share an output. But $\{(1,2),(1,5),(3,4)\}$ is not a function because input $1$ has two outputs.

On a graph, use the **vertical line test**: a graph represents a function of $x$ when every vertical line intersects it at most once.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "vertical-line-test", "semanticsLabel": "Two graphs comparing a vertical line test on a regular parabola and a sideways parabola."} -->

### Domain and Range

The **domain** is the set of allowed inputs. The **range** is the set of outputs produced by those inputs.

To find a real-valued domain, exclude inputs that make the expression undefined. Common examples include:

- a denominator equal to $0$;
- an even root with a negative radicand;
- a logarithm whose argument is $0$ or negative;
- any additional restrictions stated by the problem or created by composing functions.

Do not assume those are the only possible restrictions. The domain is determined by the full definition of the function.

In interval notation, brackets include an endpoint and parentheses leave it out. The symbol $\cup$ joins intervals by including numbers in either one, and $\infty$ means the interval goes on without end and always takes a parenthesis.

## Examples

### #1: Spotting the Function

Which relation is a function?

$A=\{(1,4),(2,5),(3,4)\}$

$B=\{(1,4),(1,5),(2,6)\}$

**Solution:**

1. In $A$, each input has exactly one output, so $A$ is a function.
2. In $B$, input $1$ has two different outputs, so $B$ is not a function.
3. The answer is $A$.

### #2: Finding the Domain

Find the domain of $f(x)=\dfrac{5}{x-3}$ and $g(x)=\sqrt{x-2}$.

**Solution:**

1. For $f$, require the denominator to be nonzero.

$$x-3\ne0$$

$$x\ne3$$

So the domain is all real numbers except $3$.

2. For $g$, require the square-root radicand to be nonnegative.

$$x-2\ge0$$

$$x\ge2$$

So the domain is $[2,\infty)$.

## Speed Tricks & Shortcuts

For domain questions, scan first for common restrictions such as denominators, even roots, and logarithms, then check whether the full function definition adds any other restrictions.

## Traps to Watch For

### #1: Repeated Outputs Are Allowed

A function can assign the same output to several different inputs. What it cannot do is assign two different outputs to the same input.

### #2: Missing a Domain Restriction

For

$$f(x)=\dfrac{\sqrt{x+1}}{x-2},$$

both conditions matter:

$$x+1\ge0$$

and

$$x\ne2.$$

The domain is $[-1,2)\cup(2,\infty)$.
