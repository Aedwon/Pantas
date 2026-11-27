---
_id: "lesson-arithmetic-number-sense-finite-geometric-series"
title: "Finite Geometric Series"
summary: "Find a finite geometric sum when the ratio is not one."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 6
partCount: 9
ordering: 33
keyPoints:
  - 'Find a finite geometric sum when the ratio is not one.'
  - 'Find a finite geometric sum when the ratio is one.'
---
## Core Concept

The symbol $a_1$ means the first term, $r$ is the common ratio, $n$ is the number of terms being added, $a_n$ is the term in position $n$ (counting from $1$), and $S_n$ is the sum of the first $n$ terms.

### Sum When the Ratio Is Not One

Add the first $4$ terms of $2,6,18,54,\dots$. Direct addition gives $2+6+18+54=80$.

When $n$ is large, listing every term takes too long. When $r\ne1$, one formula adds all $n$ terms at once:

$$S_n=\dfrac{a_1(1-r^n)}{1-r}$$

If $r>1$, flipping both subtractions to $\dfrac{a_1(r^n-1)}{r-1}$ gives the same value and makes $r^n-1$ and $r-1$ positive. The sign of the sum also depends on $a_1$.

Test the flipped form on $2,6,18,54,\dots$ with $a_1=2$, $r=3$, and $n=4$.

1. Compute $r^n$.

$$3^4=81$$

2. Subtract $1$ from $81$.

$$81-1=80$$

3. Subtract $1$ from $r=3$.

$$3-1=2$$

4. Multiply $80$ by $a_1=2$.

$$2\times80=160$$

5. Divide by $2$.

$$S_4=\dfrac{160}{2}=80$$

:::why
Why does this formula work? Multiply the sum $S_n$ by $r$ and subtract that new line from $S_n$. Every middle term cancels in pairs, leaving $(1-r)S_n=a_1(1-r^n)$, and dividing by $1-r$ gives $S_n$.
:::

Take $a_1=5$, $r=3$ and $n=5$.

:::pair #omit-sum-denominator
Right: $S_5=\dfrac{5(3^5-1)}{3-1}=\dfrac{5(242)}{2}=605$
Wrong: $S_5=5(3^5-1)=1,210$
Leaving out $r-1=2$ in the denominator doubles the real sum. Pair $r-1$ with $r^n-1$ on top, or $1-r$ with $1-r^n$.
:::

:::pair #report-last-term-not-sum
Right: $S_5=5+15+45+135+405=605$
Wrong: $a_5=5(3^4)=405$
$405$ is only the fifth term, not the sum of all five terms. Check whether the question asks for a term or a sum.
:::

### Sum When the Ratio Is One

You cannot use $\dfrac{a_1(1-r^n)}{1-r}$ when $r=1$ because $1-1=0$ in the denominator, and division by $0$ is undefined.

When $r=1$, multiplying by $1$ leaves a number unchanged, so every term in the sequence equals $a_1$. Adding $n$ copies of $a_1$ is simply multiplication:

$$S_n=na_1$$

Find the sum of $6$ terms with $a_1=12$ and $r=1$. Every term is $12$.

$$S_6=6(12)=72$$

The same idea works for part of a sequence. Find the sum of the last $5$ of $12$ terms, with first term $18$ and $r=1$. Every term is $18$, and only $5$ terms are requested.

$$5\times18=90$$

The sum of all $12$ terms would be a different amount.

$$12\times18=216$$

:::pair #add-count-instead-of-multiply
Right: The sum of $5$ terms of $18$ is $5\times18=90$.
Wrong: The sum of $5$ terms of $18$ is $5+18=23$.
Adding $5$ equal terms of $18$ means multiplying $5\times18$, not adding $5+18$.
:::

:::check
A geometric sequence starts $2,8,\dots$. What is the sum of its first $5$ terms?
:::answer
The answer is $682$. The ratio is $r=8\div2=4$, which is not $1$. So $S_5=\dfrac{2(4^5-1)}{4-1}=\dfrac{2(1023)}{3}=682$.
:::

## Examples

### #1: Finite Geometric Series

Find the sum of the first $6$ terms of the geometric sequence $3,6,12,24,\dots$ from $a_1$, $r$ and $n$.

**Solution:**

1. Read $a_1=3$ and $n=6$, then find $r$.

$$r=\dfrac{6}{3}=2$$

2. Since $r\ne1$, use the finite geometric-series formula. Start with the power $2^6$.

$$2^6=64$$

3. Subtract $r^n$ from $1$.

$$1-64=-63$$

4. Subtract $r$ from $1$.

$$1-2=-1$$

5. Multiply by $a_1=3$.

$$3\times(-63)=-189$$

6. Divide by $-1$.

$$S_6=\dfrac{-189}{-1}=189$$

The sum is $189$.

### #2: Finite Geometric Series with $r=1$

Find the sum of $8$ terms when every term is $5$.

**Solution:**

1. Since every term is the same nonzero number $5$, divide $5$ by $5$ to find the common ratio.

$$r=\dfrac{5}{5}=1$$

2. With $r=1$, find the sum from $n=8$ and $a_1=5$.

:::try
Finish the last step: find $S_8$.
:::answer
The answer is $40$. Multiplying $8\times5$ gives $40$.
:::

## Traps to Watch For

:::checklist
- Using the finite sum formula when $r\ne1$: pair $r-1$ with $r^n-1$, or $1-r$ with $1-r^n$, so $S_5=\dfrac{5(3^5-1)}{3-1}=605$. {#omit-sum-denominator}
- Asked for a sum of $n$ terms: add all $n$ terms instead of stopping at $a_n$ ($S_5=605$, not $a_5=405$). {#report-last-term-not-sum}
- Adding $n$ equal terms when $r=1$: multiply $n\times a_1$, not $n+a_1$ ($5\times18=90$). {#add-count-instead-of-multiply}
:::
