---
_id: "lesson-algebra-functions-and-relations"
title: "Functions and Relations"
summary: "What functions are, how to find their domain and range, and how to evaluate, combine, and reverse them."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 13
isActive: true
---
## Core Concept

A **relation** is any set of ordered pairs $(x, y)$. It connects inputs to outputs.

A **function** is a special relation with one strict rule: every input $x$ gets exactly one output $y$.

Think of a function like a vending machine. Press button $A1$ and you always get the same snack. If pressing $A1$ sometimes gave chips and sometimes gave soda, the machine would be broken. That broken machine is a relation that is not a function.

So $\{(1, 2), (2, 3), (3, 3)\}$ is a function. Two different inputs may share an output. But $\{(1, 2), (1, 5), (3, 4)\}$ is not a function, because the input $1$ has two different outputs.

On a graph, use the **vertical line test**. If any vertical line crosses the graph more than once, it is not a function.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "vertical-line-test", "semanticsLabel": "Two graphs comparing a vertical line test on a regular parabola and a sideways parabola."} -->

### Domain and Range

The **domain** is the set of all allowed inputs ($x$ values). The **range** is the set of all possible outputs ($y$ values).

Most of the time, the domain is "all real numbers". You only remove values in two danger cases:

- **Division**: the denominator cannot be $0$.
- **Even roots**: the inside of a square root cannot be negative.

### Function Evaluation and Composition

**Evaluating** $f(3)$ means replacing every $x$ in the rule with $3$, then computing.

**Composition** means putting one function inside another. The symbol $(f \circ g)(x)$ means $f(g(x))$: do $g$ first, then feed its answer into $f$. Work from the inside out.

### Inverse Functions

The **inverse function** $f^{-1}$ undoes what $f$ does. If $f(2) = 7$, then $f^{-1}(7) = 2$. To find it: swap $x$ and $y$ in the equation, then solve for $y$ again.

A function only has an inverse function if it passes the **horizontal line test**: no horizontal line crosses its graph twice.

## Examples

### #1: Spotting the Function

Which of these relations is a function? Relation $A = \{(1, 4), (2, 5), (3, 4)\}$ or Relation $B = \{(1, 4), (1, 5), (2, 6)\}$?

**Solution:**
Check each input. An input may appear only once.

1. In Relation $A$, the inputs are $1$, $2$, and $3$. No input repeats. It does not matter that the output $4$ appears twice. Relation $A$ is a function.
2. In Relation $B$, the input $1$ appears twice, once going to $4$ and once going to $5$. One button gives two snacks. Relation $B$ is not a function.
3. The answer is Relation $A$.

### #2: Finding the Domain

Find the domain of $f(x) = \dfrac{5}{x - 3}$ and the domain of $g(x) = \sqrt{x - 2}$.

**Solution:**
Look for the two danger cases.

1. For $f(x)$, the denominator cannot be $0$. Set it equal to $0$ to find the forbidden value.

$$x - 3 = 0$$

$$x = 3$$

2. The domain of $f$ is all real numbers except $3$.
3. For $g(x)$, the inside of the square root must be $0$ or bigger.

$$x - 2 \geq 0$$

$$x \geq 2$$

4. The domain of $g$ is all real numbers greater than or equal to $2$.

### #3: Evaluating with a Negative Input

If $f(x) = 2x^2 - 3x + 1$, find $f(-2)$.

**Solution:**
Swap every $x$ for $-2$. Put the negative number in parentheses.

1. Substitute carefully.

$$f(-2) = 2(-2)^2 - 3(-2) + 1$$

2. Do the exponent first. $(-2)^2 = 4$.

$$f(-2) = 2(4) - 3(-2) + 1$$

3. Multiply. Note that $-3$ times $-2$ is $+6$.

$$f(-2) = 8 + 6 + 1$$

4. Add.

$$f(-2) = 15$$

### #4: Composition of Functions

If $f(x) = 2x + 1$ and $g(x) = x^2 - 3$, find $(f \circ g)(2)$ and $(g \circ f)(2)$.

**Solution:**
Work from the inside out.

1. For $(f \circ g)(2)$, do $g$ first.

$$g(2) = 2^2 - 3 = 1$$

2. Feed that answer into $f$.

$$f(1) = 2(1) + 1 = 3$$

3. So $(f \circ g)(2) = 3$.
4. For $(g \circ f)(2)$, do $f$ first.

$$f(2) = 2(2) + 1 = 5$$

5. Feed that answer into $g$.

$$g(5) = 5^2 - 3 = 22$$

6. So $(g \circ f)(2) = 22$. The order changed the answer completely. Composition is not reversible.

### #5: Finding an Inverse Function

Find the inverse of $f(x) = \dfrac{2x - 3}{5}$.

**Solution:**
Write $f(x)$ as $y$, swap $x$ and $y$, then solve for $y$.

1. Start with the equation.

$$y = \dfrac{2x - 3}{5}$$

2. Swap $x$ and $y$.

$$x = \dfrac{2y - 3}{5}$$

3. Multiply both sides by $5$.

$$5x = 2y - 3$$

4. Add $3$ to both sides.

$$5x + 3 = 2y$$

5. Divide by $2$.

$$y = \dfrac{5x + 3}{2}$$

6. So $f^{-1}(x) = \dfrac{5x + 3}{2}$. Quick check: $f(4) = \dfrac{8 - 3}{5} = 1$, and $f^{-1}(1) = \dfrac{5 + 3}{2} = 4$. It undoes $f$ perfectly.

## Speed Tricks & Shortcuts

To check if two functions are inverses, you do not need to redo the algebra. Pick an easy number. If $f(4) = 1$, then the inverse must send $1$ back to $4$. If it does not, they are not inverses.

For domain questions in multiple choice, do not solve anything at first. Just scan the function for the two danger signs: a denominator with $x$ in it, or an even root with $x$ inside. No danger signs means the domain is all real numbers, and you are done in five seconds.

For composition like $(f \circ g)(2)$ with a specific number, never build the full formula $f(g(x))$. Just compute $g(2)$, then plug that single number into $f$. It is faster and safer.

## Traps to Watch For

### #1: Thinking $f^{-1}(x)$ Is a Reciprocal

> $f^{-1}(x)$ means the inverse function, not $\dfrac{1}{f(x)}$.

The raised $-1$ on a function name is special notation. It means "the undo function". If $f(x) = 2x$, then $f^{-1}(x) = \dfrac{x}{2}$, not $\dfrac{1}{2x}$. Test-makers put the reciprocal in the choices every time.

### #2: Repeated Outputs Are Fine

> A function can repeat outputs. It cannot repeat inputs with different outputs.

Students see $\{(1, 4), (2, 4), (3, 4)\}$ and say "not a function" because $4$ repeats. Wrong. Every input still has exactly one output, so it is a function. Only a repeated input with different outputs breaks the rule.

### #3: Mixing Up the Order in Composition

> $(f \circ g)(x)$ means $g$ goes first.

The symbol reads left to right, but the work happens right to left, from the inside out. In Example $4$, $(f \circ g)(2) = 3$ but $(g \circ f)(2) = 22$. The wrong order is always one of the answer choices.

### #4: Missing Half the Domain Rules

> Check for both division by zero and negative square roots.

For $f(x) = \dfrac{\sqrt{x + 1}}{x - 2}$, you need $x + 1 \geq 0$ and $x - 2 \neq 0$. So the domain is $x \geq -1$ except $x = 2$. Students who check only one condition pick the incomplete choice.
