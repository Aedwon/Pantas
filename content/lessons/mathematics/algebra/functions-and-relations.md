---
_id: "lesson-algebra-functions-and-relations"
title: "Functions and Relations"
summary: "Tell functions from relations, find domain and range, combine and compose functions, and build and check inverse functions."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A **relation** is a set of ordered pairs $(x,y)$. The first number is the **input** and the second is the **output**. A **function** is a relation in which every input has exactly one output.

Think of a function as a machine. You drop in one input, and one output comes out.

So $\{(1,2),(2,3),(3,3)\}$ is a function. Different inputs may share an output. But $\{(1,2),(1,5),(3,4)\}$ is not a function, because input $1$ has two outputs.

The symbol $f(x)$ is read "f of x". It means the output of the function $f$ when the input is $x$.

On the $xy$-plane, use the **vertical line test**. A graph with $x$ as the input shows $y$ as a function of $x$ when every vertical line meets it at most once. A vertical line that misses the graph is fine: that $x$ is simply not an input.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "vertical-line-test", "semanticsLabel": "Two graphs comparing a vertical line test on a regular parabola and a sideways parabola."} -->

### Domain and Range

The **domain** is the set of allowed inputs. The **range** is the set of outputs that the function actually produces from those inputs.

Unless a problem says otherwise, the domain is all real numbers that give a real output. So you leave out inputs that make the rule undefined:

- a denominator equal to $0$;
- an even root (a square root, fourth root, and so on) of a negative number;
- a logarithm whose input is $0$ or negative (the lesson on exponents and logarithms teaches logarithms);
- any restriction the problem states, or that comes from combining functions.

Odd roots, such as cube roots, accept negative numbers. A square root of $0$ is fine.

Domains and ranges are often written as **intervals**. A square bracket includes the end number and a round bracket leaves it out. So $[2,\infty)$ means all $x\ge2$, and $(-\infty,3)$ means all $x<3$.

The symbol $\infty$ means the numbers go on without end, so it always gets a round bracket. The symbol $\cup$ means "together with", so $[-1,2)\cup(2,\infty)$ is two pieces joined.

To find the range from a rule and a stated domain, find which outputs the rule reaches. For a straight line that is not horizontal, the smallest and largest outputs come from the two ends of the domain. A line that is not horizontal never gives the same output twice. So if an end is left out, as in $2x+1$ on $1<x\le4$, the output at that end is left out too, and the range is $(3,9]$.

A horizontal line, such as $y=3$, gives the same output for every input. Its range is just $\{3\}$.

If the domain has no end on one side, the range of a line that is not horizontal also has no end on one side. A rising line keeps the same side, so $2x+1$ on $x\ge0$ gives $[1,\infty)$. A falling line flips the side, so $-2x+1$ on $x\ge0$ gives $(-\infty,1]$.

For a parabola (the curve of $y=ax^2+bx+c$ with $a\ne0$), also check the **turning point**. This is the point where the curve stops falling and starts rising, or the reverse.

For $y=a(x-h)^2+k$ it is at $x=h$, with output $k$. For $y=ax^2+bx+c$ it is at $x=-\dfrac{b}{2a}$. Use it only if it lies inside the domain.

A parabola can give the same output twice. So a left-out end's output is left out only if no included input gives it. For $y=x^2$ on $-2<x\le2$, the left-out end gives $4$, but $x=2$ also gives $4$, so the range is $[0,4]$.

### Function Evaluation

"Evaluate" means find the final number answer. To evaluate $f(3)$, put $3$ in place of every $x$ in the rule and calculate. Use brackets around a negative input.

### Combining Functions

Two functions can be added, subtracted, multiplied, or divided. Do it output by output:

$$(f+g)(x)=f(x)+g(x)$$

$$(f-g)(x)=f(x)-g(x)$$

$$(f\cdot g)(x)=f(x)\cdot g(x)$$

$$\left(\dfrac{f}{g}\right)(x)=\dfrac{f(x)}{g(x)}$$

The new function needs both $f(x)$ and $g(x)$ to exist. So its domain is the inputs that are in the domain of $f$ and also in the domain of $g$. For division, also remove every $x$ where $g(x)=0$.

### Composition

Composition means feeding the output of one function into another. The notation $(f\circ g)(x)$ means $f(g(x))$, so $g$ is applied first. This is different from the product $f\cdot g$.

An input $x$ is in the domain of $f\circ g$ when it is in the domain of $g$, and $g(x)$ is in the domain of $f$.

### Inverse Functions

An inverse function undoes a function. If $f(2)=7$ and $f$ has an inverse function, then $f^{-1}(7)=2$.

A function is **one-to-one** when different inputs always give different outputs. A function has an inverse function on a given domain exactly when it is one-to-one on that domain. For a graph on the $xy$-plane, the **horizontal line test** checks this: every horizontal line meets the graph at most once.

<!-- ILLUSTRATION: two small xy graphs side by side; left, y = x^2 for all real x with the horizontal line y = 4 crossing at (-2, 4) and (2, 4), labeled "not one-to-one"; right, y = x^3 with the horizontal line y = 4 crossing once, labeled "one-to-one" -->

A straight line $f(x)=ax+b$ with $a\ne0$ is one-to-one. A constant function ($f(x)=b$, so $a=0$) is not.

To find an inverse:

1. Write $y=f(x)$.
2. Swap $x$ and $y$.
3. Solve for $y$. That $y$ is $f^{-1}(x)$.

The domain of $f^{-1}$ is the range of $f$, and the range of $f^{-1}$ is the domain of $f$.

If $f$ is not one-to-one, you can cut its domain down to a piece where it is. For $f(x)=x^2$, the piece $x\ge0$ works. Step $3$ can then give two branches, with a plus sign and a minus sign.

Keep the branch whose outputs match the cut-down domain, because they are the inputs of $f$.

To check that $g$ is the inverse of $f$, test both compositions:

$$f(g(x))=x\quad\text{and}\quad g(f(x))=x$$

The first must hold for every $x$ in the domain of $g$. The second must hold for every $x$ in the domain of $f$.

## Examples

### #1: Spotting the Function

Which relation is a function?

$A=\{(1,4),(2,5),(3,4)\}$

$B=\{(1,4),(1,5),(2,6)\}$

**Solution:**

1. In $A$, each input has exactly one output. Input $1$ and input $3$ share the output $4$, which is allowed. So $A$ is a function.
2. In $B$, input $1$ has two different outputs, $4$ and $5$. So $B$ is not a function.
3. The answer is $A$.

### #2: Finding the Domain

Find the domain of $f(x)=\dfrac{5}{x-3}$, $g(x)=\sqrt{x-2}$, and $h(x)=\dfrac{1}{\sqrt{x+3}}$.

**Solution:**

1. For $f$, the denominator must not be $0$.

$$x-3\ne0\quad\Rightarrow\quad x\ne3$$

So the domain is all real numbers except $3$.

2. For $g$, the number under the root must be $0$ or positive.

$$x-2\ge0\quad\Rightarrow\quad x\ge2$$

So the domain is $[2,\infty)$.

3. For $h$, the root must exist and also must not be $0$, because it is in the denominator. So the number under it must be positive.

$$x+3>0\quad\Rightarrow\quad x>-3$$

So the domain is $(-3,\infty)$.

### #3: Finding the Range

Find the range of $f(x)=2x+1$ on the domain $[1,4]$. Then find the range of $h(x)=(x-2)^2+1$ on the domain $[0,5]$.

**Solution:**

1. The line $f$ goes up as $x$ goes up, so the ends of the domain give the ends of the range.

$$f(1)=3\qquad f(4)=9$$

So the range is $[3,9]$.

2. The curve $h$ is a parabola written as $(x-2)^2+1$, so its turning point is at $x=2$. That is inside $[0,5]$. There $h(2)=1$, the smallest output.
3. Check the two ends of the domain.

$$h(0)=4+1=5\qquad h(5)=9+1=10$$

The largest output is $10$. So the range is $[1,10]$.

### #4: Evaluating with a Negative Input

If $f(x)=2x^2-3x+1$, find $f(-2)$.

**Solution:**

$$f(-2)=2(-2)^2-3(-2)+1$$

$$=2(4)+6+1=15$$

### #5: Combining Functions and Their Domain

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

### #6: Composition at a Number

If $f(x)=2x+1$ and $g(x)=x^2-3$, find $(f\circ g)(2)$ and $(g\circ f)(2)$.

**Solution:**

1. For $(f\circ g)(2)$, apply $g$ first.

$$g(2)=1$$

$$f(1)=3$$

So $(f\circ g)(2)=3$.

2. For $(g\circ f)(2)$, apply $f$ first.

$$f(2)=5$$

$$g(5)=22$$

So $(g\circ f)(2)=22$.

The two answers differ here. In general, $f\circ g$ and $g\circ f$ are different functions, though for some pairs they happen to match.

### #7: Domain of a Composition

Let $f(x)=\sqrt{x}$ and $g(x)=x^2-4$. Find $(f\circ g)(x)$ and its domain.

**Solution:**

1. Put $g(x)$ inside $f$.

$$(f\circ g)(x)=\sqrt{x^2-4}$$

2. The domain of $g$ is all real numbers, so $g$ adds no limit.
3. The domain of $f$ is $x\ge0$, so $g(x)$ must be $0$ or positive.

$$x^2-4\ge0$$

$$(x-2)(x+2)\ge0$$

4. The product is $0$ or positive when both factors are $0$ or positive, or both are $0$ or negative. That gives $x\ge2$ or $x\le-2$.

The domain is $(-\infty,-2]\cup[2,\infty)$.

### #8: Finding the Inverse of a Line

Find the inverse of $f(x)=\dfrac{2x-3}{5}$.

**Solution:**

1. The function is $f(x)=\dfrac{2}{5}x-\dfrac{3}{5}$, a line with $a=\dfrac{2}{5}\ne0$, so it is one-to-one and has an inverse. Write $y=\dfrac{2x-3}{5}$ and swap $x$ and $y$.

$$x=\dfrac{2y-3}{5}$$

2. Solve for $y$.

$$5x=2y-3$$

$$5x+3=2y$$

$$y=\dfrac{5x+3}{2}$$

3. Therefore:

$$f^{-1}(x)=\dfrac{5x+3}{2}$$

A quick check: $f(4)=1$ and $f^{-1}(1)=4$.

### #9: Verifying an Inverse

Which of $g(x)=\dfrac{x-6}{3}$ and $h(x)=\dfrac{x+6}{3}$ is the inverse of $f(x)=3x-6$?

**Solution:**

1. Test $g$ with the first composition.

$$f(g(x))=3\cdot\dfrac{x-6}{3}-6=x-6-6=x-12$$

This is not $x$, so $g$ is not the inverse.

2. Test $h$ with $f(h(x))$.

$$f(h(x))=3\cdot\dfrac{x+6}{3}-6=x+6-6=x$$

3. Test $h$ with $h(f(x))$.

$$h(f(x))=\dfrac{(3x-6)+6}{3}=\dfrac{3x}{3}=x$$

Both compositions give $x$. The answer is $h$.

### #10: Restricting a Domain to Get an Inverse

Let $f(x)=(x-2)^2+1$ with domain $x\ge2$. Find $f^{-1}(x)$ and its domain.

<!-- ILLUSTRATION: xy graph of y = (x-2)^2 + 1 for x >= 2 only, a solid curve starting at the closed dot (2, 1) and rising to the right through (3, 2); the left half of the parabola is dashed and labeled "removed" -->

**Solution:**

1. On the whole real line $f$ is not one-to-one, since $f(1)=f(3)$. On $x\ge2$, the graph only goes up, so it is one-to-one.
2. Write $y=(x-2)^2+1$ and swap $x$ and $y$.

$$x=(y-2)^2+1$$

3. Solve for $y$.

$$(y-2)^2=x-1$$

$$y-2=\pm\sqrt{x-1}$$

4. The outputs of $f^{-1}$ are the inputs of $f$, which are $x\ge2$. So $y\ge2$, which needs the plus sign.

$$f^{-1}(x)=2+\sqrt{x-1}$$

5. The domain of $f^{-1}$ is the range of $f$. Since $f(2)=1$ is the smallest output, the range is $[1,\infty)$. This matches $x-1\ge0$.
6. Check: $f(3)=2$ and $f^{-1}(2)=2+\sqrt{1}=3$.

## Speed Tricks & Shortcuts

One input-output check can **disprove** a claimed inverse, but one matching pair does not prove it. To prove it, check both compositions, $f(g(x))=x$ and $g(f(x))=x$, as in Example $9$.

For a domain question, scan first for denominators, even roots, and logarithms. Then see whether the problem adds any other limit.

For a composition at a number, such as $(f\circ g)(2)$, find $g(2)$ first and feed that value into $f$. Find the formula for the composition only when you need the whole function or its domain.

To find a range on an interval, test the two end values. Round-bracket the output of a left-out end only if no included input gives that output.

If the function is a parabola, also test its turning point when it lies inside the interval. The ends alone are enough when the function steadily rises or steadily falls on the interval.

## Traps to Watch For

### #1: Thinking $f^{-1}(x)$ Is a Reciprocal

> The symbol $f^{-1}(x)$ means the inverse function, not $\dfrac{1}{f(x)}$.

The reciprocal is written $\dfrac{1}{f(x)}$ or $(f(x))^{-1}$. For $f(x)=2x$, the inverse is $\dfrac{x}{2}$, but the reciprocal is $\dfrac{1}{2x}$.

### #2: Repeated Outputs Are Allowed

> A function may give the same output for many inputs, but never two outputs for one input.

Repeated outputs only mean the function is not one-to-one. It can still be a function. It just has no inverse function on that domain.

### #3: Mixing Up Composition Order

> In $(f\circ g)(x)=f(g(x))$, the function written last is applied first.

Applying the functions in the wrong order gives a different answer in most cases. Example $6$ shows this.

### #4: Missing a Domain Restriction

> Check every part of the rule, not just the first limit you spot.

For $f(x)=\dfrac{\sqrt{x+1}}{x-2}$, both limits matter:

$$x+1\ge0\quad\text{and}\quad x\ne2$$

The domain is $[-1,2)\cup(2,\infty)$.

### #5: Simplifying Before Finding the Domain

> Find the domain from the rule as given, not from the simplified form.

Take $f(x)=\dfrac{x^2-4}{x-2}$. After cancelling, it looks like $x+2$, but $x=2$ is still not allowed in $f$. The domain is all real numbers except $2$, and the output $4$ is never produced.

### #6: Taking a Plus-or-Minus Branch Without Checking

> An inverse of a restricted function keeps only the branch that matches the restricted domain.

For $f(x)=x^2$ with $x\ge0$, the inverse is $\sqrt{x}$. Writing $\pm\sqrt{x}$ gives two outputs for each positive input, so it is not a function. If the domain were $x\le0$, the right branch would be $-\sqrt{x}$.
