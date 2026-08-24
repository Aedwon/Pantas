---
_id: "lesson-algebra-functions-and-relations"
title: "Functions and Relations"
summary: "Understand functions, domain and range, evaluation, composition, and inverse functions."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 13
isActive: true
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

### Function Evaluation and Composition

Evaluating $f(3)$ means using $3$ as the input and calculating the corresponding output.

Composition means feeding the output of one function into another. The notation $(f\circ g)(x)$ means $f(g(x))$, so $g$ is applied first. The input must also belong to the domain of the composition: it must be valid for $g$, and $g(x)$ must be valid for $f$.

### Inverse Functions

An inverse function reverses the input-output pairing. If $f(2)=7$ and $f$ is invertible on the domain being used, then $f^{-1}(7)=2$.

A function has an inverse **function** on a given domain only when it is one-to-one on that domain. For real graphs, the horizontal line test checks this: every horizontal line must intersect the graph at most once.

A function that is not one-to-one on its full domain can sometimes be restricted to a smaller domain where it becomes one-to-one.

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

### #3: Evaluating with a Negative Input

If $f(x)=2x^2-3x+1$, find $f(-2)$.

**Solution:**

$$f(-2)=2(-2)^2-3(-2)+1$$

$$=2(4)+6+1=15$$

### #4: Composition of Functions

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

### #5: Finding an Inverse Function

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

For domain questions, scan first for common restrictions such as denominators, even roots, and logarithms, then check whether the full function definition adds any other restrictions.

For a numerical composition such as $(f\circ g)(2)$, it is often efficient to compute $g(2)$ first and then feed that value into $f$.

## Traps to Watch For

### #1: Thinking $f^{-1}(x)$ Is a Reciprocal

> $f^{-1}(x)$ denotes an inverse function, not $\dfrac{1}{f(x)}$.

### #2: Repeated Outputs Are Allowed

A function can assign the same output to several different inputs. What it cannot do is assign two different outputs to the same input.

### #3: Mixing Up Composition Order

$$(f\circ g)(x)=f(g(x)),$$

so $g$ is applied first.

### #4: Missing a Domain Restriction

For

$$f(x)=\dfrac{\sqrt{x+1}}{x-2},$$

both conditions matter:

$$x+1\ge0$$

and

$$x\ne2.$$

The domain is $[-1,2)\cup(2,\infty)$.
