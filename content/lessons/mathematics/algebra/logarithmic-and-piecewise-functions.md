---
_id: "lesson-algebra-logarithmic-and-piecewise-functions"
title: "Functions (Logarithmic and Piecewise)"
summary: "Evaluate logarithms and solve exponential or logarithmic equations."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 8
partCount: 8
ordering: 43
keyPoints:
  - "Evaluate logarithms and solve exponential or logarithmic equations."
  - "Choose the piecewise rule that includes the input."
---
## Core Concept

A **function** gives one output for each allowed input. The **domain** is the set of allowed inputs. The notation $f(x)$ means the output of function $f$ at input $x$.

An **exponential function** has the form $f(x)=a^x$ for $a>0$ and $a\ne1$. The variable is in the exponent. Each increase of $1$ in $x$ multiplies the output by $a$.

If $a>1$, the outputs grow as $x$ increases. If $0<a<1$, they shrink toward $0$. Equal powers of the same allowed base have equal exponents because different exponents give different outputs.

A **logarithmic function** has the form $f(x)=\log_a x$ for $a>0$, $a\ne1$, and $x>0$. A logarithm asks which exponent gives the input:

$$\log_a x=y\quad\Longleftrightarrow\quad a^y=x$$

A **piecewise function** uses different formulas for different input ranges. At a boundary, use the rule whose condition includes that input.

<!-- ILLUSTRATION: seven labeled coordinate panels: y=x on -3<=x<=3; y=x^2 on -3<=x<=3; y=1/x on -3<=x<=3 excluding 0 with asymptotes x=0 and y=0; y=|x| on -3<=x<=3; y=2^x on -3<=x<=3; y=log_2(x) on 0<x<=4 with asymptote x=0; and y=x for x<0, y=2 for x>=0 on -3<=x<=3 with open point (0,0) and filled point (0,2); label each family and both axes -->

## Examples

### #1: Exponential and Logarithmic Equations

Solve $2^{x+1}=32$, then evaluate $\log_3 81$.

**Solution:**

1. Write the right side with base $2$.

$$32=2^5$$

2. Match the exponents and subtract $1$.

$$x+1=5$$

$$x=4$$

3. For the logarithm, find the power of $3$ that gives $81$.

$$3^4=81$$

4. Write the logarithm's value.

$$\log_3 81=4$$

### #2: Evaluating a Piecewise Function

Let $f(x)=x^2$ when $x<2$, and $f(x)=3x-1$ when $x\ge2$. Find $f(2)+f(-3)$.

**Solution:**

1. The second rule includes $2$.

$$f(2)=3(2)-1=5$$

2. Since $-3<2$, use the first rule for $-3$.

$$f(-3)=(-3)^2=9$$

3. Add the results.

$$f(2)+f(-3)=5+9=14$$

## Speed Tricks & Shortcuts

For exponential equations, try writing both sides with the same base.

## Traps to Watch For

### #1: Piecewise Boundary

> Use the rule that includes the boundary input.

If the rules say $x<2$ and $x\ge2$, input $2$ uses the second rule. Using the first rule can give the wrong output.

### #2: Logarithm Domain

> A real logarithm needs a positive input.

The values $\log_2 0$ and $\log_2(-8)$ are undefined in the real numbers. Neither input can be the value of $2$ raised to a real power.
