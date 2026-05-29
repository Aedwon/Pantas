---
_id: "lesson-precalculus-basic-calculus-limits-and-continuity"
title: "Limits and Continuity"
summary: "This lesson teaches you how to evaluate limits, handle the zero-over-zero case, and test whether a function is continuous."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
estimatedMinutes: 13
isActive: true
---
## Core Concept

A **limit** asks: as $x$ walks closer and closer to some number, what value does $f(x)$ approach? We write:

$$\lim_{x \to 2} f(x) = L$$

The limit cares about the JOURNEY, not the destination. Even if $f(2)$ is undefined or something weird, the limit can still exist, because it only watches where the outputs are HEADING.

**Step one is always direct substitution.** Plug the number in. If you get a normal value, that value is the limit. Done.

If substitution gives $\dfrac{0}{0}$, do not panic and do not answer "undefined". This is called an **indeterminate form**, and it means: simplify first. Factor, cancel the troublesome piece, then substitute again.

A **one-sided limit** approaches from one direction only: $x \to 2^-$ (from the left) or $x \to 2^+$ (from the right). The full limit exists only when BOTH sides agree.

**Limits at infinity** ask where $f(x)$ settles as $x$ grows forever. For a ratio of polynomials, compare the top and bottom degrees: same degree means the limit is the ratio of leading coefficients; bottom-heavy means $0$; top-heavy means the limit is infinite.

A function is **continuous** at $x = a$ when you can draw through it without lifting your pen. Officially, three checks:

1. $f(a)$ exists.
2. $\lim_{x \to a} f(x)$ exists.
3. They are EQUAL.

Break any one and you have a discontinuity: a hole, a jump, or a vertical asymptote.

<!-- ILLUSTRATION: three mini-graphs showing a hole (removable), a jump between two pieces, and a vertical asymptote -->

## Examples

### #1: Direct Substitution

Evaluate $\lim_{x \to 2} (3x + 1)$.

**Solution:**
Try plugging in first — it usually just works.

1. Substitute $x = 2$.

$$3(2) + 1 = 7$$

2. The limit is $7$. Polynomials are continuous everywhere, so substitution always finishes them.

### #2: The Zero-over-Zero Classic

Evaluate $\lim_{x \to 3} \dfrac{x^2 - 9}{x - 3}$.

**Solution:**
Substitution gives $\dfrac{9 - 9}{3 - 3} = \dfrac{0}{0}$: indeterminate. Factor and cancel.

1. Factor the top as a difference of squares.

$$\dfrac{(x - 3)(x + 3)}{x - 3}$$

2. Cancel the $(x - 3)$ factors.

$$x + 3$$

3. Substitute now.

$$3 + 3 = 6$$

4. The limit is $6$. The graph is the line $y = x + 3$ with a HOLE at $x = 3$, and the limit reports the height of the hole.

### #3: Factoring a Trinomial First

Evaluate $\lim_{x \to 2} \dfrac{x^2 + x - 6}{x - 2}$.

**Solution:**
Substitution gives $\dfrac{0}{0}$ again.

1. Factor the numerator.

$$x^2 + x - 6 = (x - 2)(x + 3)$$

2. Cancel the common factor.

$$\lim_{x \to 2} (x + 3)$$

3. Substitute.

$$2 + 3 = 5$$

### #4: A Limit at Infinity

Evaluate $\lim_{x \to \infty} \dfrac{3x^2 + 5}{x^2 - 2}$.

**Solution:**
Compare the degrees: both top and bottom are degree $2$.

1. Same degree means the limit is the ratio of the LEADING coefficients.

$$\dfrac{3}{1} = 3$$

2. The limit is $3$. For huge $x$, the $+5$ and $-2$ are crumbs; the $x^2$ terms run the show.

### #5: Making a Piecewise Function Continuous

A function is defined as $f(x) = x^2 + 1$ for $x < 1$, and $f(x) = x + k$ for $x \geq 1$. Find the value of $k$ that makes $f$ continuous at $x = 1$.

**Solution:**
Continuity at the seam means the two pieces must MEET there.

1. The left piece approaches:

$$1^2 + 1 = 2$$

2. The right piece at $x = 1$ gives:

$$1 + k$$

3. Set them equal.

$$1 + k = 2$$

$$k = 1$$

4. With $k = 1$, both pieces meet at the point $(1, 2)$ and the graph has no jump.

## Speed Tricks & Shortcuts

Always substitute FIRST, even when the problem looks scary. Most CET limit questions end right there. Only a $\dfrac{0}{0}$ result earns the factoring work.

For $\dfrac{0}{0}$ rational limits, the factor you cancel is always $(x - a)$ where $a$ is the number being approached. Knowing what you are hunting for makes the factoring faster: in Example $3$, the top HAD to contain $(x - 2)$.

For limits at infinity of rational functions, read only the leading terms: same degree gives the coefficient ratio, bottom degree bigger gives $0$, top degree bigger gives no finite limit. No algebra needed.

## Traps to Watch For

### #1: Declaring $\dfrac{0}{0}$ "Undefined"

> Zero over zero means SIMPLIFY MORE, not "no answer".

The indeterminate form is a yellow light, not a red one. In Example $2$ the limit exists and equals $6$. Choices like "undefined" and "does not exist" are planted for students who stop at the substitution step.

### #2: Confusing the Limit with the Function Value

> The limit can exist even where the function is undefined, and they can differ.

At a hole, $f(3)$ may not exist while the limit is a clean $6$. If the function is separately defined so that $f(3) = 10$ but nearby values head to $6$, then the limit is STILL $6$. The limit watches the neighbors, never the point itself.

### #3: Ignoring the Two Sides

> If the left and right limits disagree, the limit DOES NOT EXIST.

For a piecewise function with a jump, each side approaches a different height. Test-makers ask for the plain limit and offer both one-sided values as choices. Check both directions before answering — the correct choice may be "does not exist".

### #4: Nonzero over Zero

> $\dfrac{5}{0}$ is NOT indeterminate: the limit blows up.

If substitution gives a nonzero number over $0$, no factoring will save it: the function rockets toward infinity near a vertical asymptote, and the (finite) limit does not exist. Only the exact form $\dfrac{0}{0}$ invites simplification.
