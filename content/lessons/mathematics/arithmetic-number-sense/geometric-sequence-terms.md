---
_id: "lesson-arithmetic-number-sense-geometric-sequence-terms"
title: "Geometric Sequence Terms"
summary: "Identify a geometric sequence and its common ratio."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 5
partCount: 9
ordering: 32
keyPoints:
  - 'Identify a geometric sequence and its common ratio.'
  - 'Find a term using the common ratio.'
---
## Core Concept

A **sequence** is an ordered list of numbers called **terms**. A **series** is a sum of terms from a sequence. As before, $a_1$ is the first term, $a_n$ is the $n^{\text{th}}$ term, and $n$ is the position of a term, counting from $1$.

### Identifying a Geometric Sequence and Ratio

A **geometric sequence** multiplies each term by the same constant number to make the next term. That multiplier is the **common ratio** $r$. Divide any term by the nonzero term right before it to find $r$, and check more than one pair so you are sure the ratio stays constant.

Check the sequence $3,6,12,24,48,\dots$.

$$6\div3=2$$

$$12\div6=2$$

$$24\div12=2$$

Each quotient is $2$, so the sequence is geometric with $r=2$.

A geometric sequence can shrink when $r$ is a fraction between $0$ and $1$, or switch signs when $r$ is negative. Check $81,27,9,3,\dots$:

$$27\div81=\dfrac{1}{3}$$

$$9\div27=\dfrac{1}{3}$$

Here $r=\dfrac{1}{3}$. In a geometric sequence with nonzero terms, consecutive ratios match, so any three consecutive terms $a_1,a_2,a_3$ satisfy $\dfrac{a_2}{a_1}=\dfrac{a_3}{a_2}$, or $a_2^2=a_1a_3$. Find the middle term $x$ in $4,x,36$:

$$x^2=4\times36$$

$$x^2=144$$

So $x=12$, or $x=-12$ if negative terms are allowed.

:::pair #check-only-first-difference
Right: For $3,6,12,24,\dots$, $6\div3=2$ and $12\div6=2$, so it is geometric with ratio $2$.
Wrong: For $3,6,12,24,\dots$, $6-3=3$, so it is arithmetic with difference $3$.
The first jump is $+3$, but the next jump is $12-6=6$. Check at least two consecutive pairs before naming the type.
:::

:::pair #confuse-first-term-with-ratio
Right: $r=\dfrac{6}{3}=2$
Wrong: $r=a_1=3$
The number $3$ is the first term $a_1$, not the multiplier. Divide a term by the term before it to get $r=2$.
:::

### Finding Any Geometric Term

Starting from $a_1$, each step multiplies by $r$ one more time. Reaching position $n$ takes $n-1$ multiplications by $r$:

$$a_n=a_1r^{n-1}$$

For terms after the first, this formula also works when $r=0$: every term after $a_1$ is $0$.

Find the sixth term of the geometric sequence with $a_1=3$ and $r=2$.

1. Subtract $1$ from $n=6$ to find the exponent.

$$n-1=6-1=5$$

2. Raise $r=2$ to the fifth power.

$$2^5=32$$

3. Multiply by $a_1=3$.

$$a_6=3\times32=96$$

Find the fifth term of $81,27,9,3,\dots$, where $a_1=81$ and $r=\dfrac{1}{3}$.

$$5-1=4$$

$$\left(\dfrac{1}{3}\right)^4=\dfrac{1}{81}$$

$$a_5=81\times\dfrac{1}{81}=1$$

:::why
Why is the exponent $n-1$ instead of $n$? You start at $a_1$ with $0$ multiplications by $r$, so $a_2$ multiplies once ($r^1$), $a_3$ multiplies twice ($r^2$), and $a_6$ multiplies five times ($r^5$).
:::

:::pair #wrong-exponent-on-ratio
Right: $a_6=3(2^{6-1})=3(2^5)=96$
Wrong: $a_6=3(2^6)=3(64)=192$
Using exponent $6$ multiplies by $2$ one extra time. Use exponent $n-1=5$.
:::

:::check
A geometric sequence has $a_1=2$ and $a_2=10$. What is its fourth term?
:::answer
The answer is $250$. The ratio is $r=10\div2=5$, so $a_4=2(5^3)=2(125)=250$.
:::

## Examples

In exam questions, **evaluate** means find the final number answer.

### #1: Geometric Sequence with Alternating Signs

Find the $8^{\text{th}}$ term of the geometric sequence $3,-6,12,-24,\dots$.

**Solution:**

1. Read $a_1=3$ and divide the second term by the first to find $r$.

$$r=\dfrac{-6}{3}=-2$$

Check with the next pair.

$$\dfrac{12}{-6}=-2$$

2. Find the exponent for the $8^{\text{th}}$ term.

$$n-1=8-1=7$$

3. Evaluate $(-2)^7$. An odd power of a negative number is negative.

$$(-2)^7=-128$$

:::try
Finish the last step: multiply $a_1=3$ by $(-2)^7=-128$.
:::answer
The answer is $-384$. Multiplying $3\times(-128)$ gives $-384$.
:::

## Traps to Watch For

:::checklist
- Checking if a sequence is arithmetic or geometric: test at least two consecutive pairs ($6\div3=2$ and $12\div6=2$). {#check-only-first-difference}
- Finding the common ratio $r$: divide a term by the term before it instead of copying $a_1$ ($r=6\div3=2$). {#confuse-first-term-with-ratio}
- Finding the $n^{\text{th}}$ geometric term: raise $r$ to $n-1$, not $n$ ($a_6=3\times2^5=96$). {#wrong-exponent-on-ratio}
:::
