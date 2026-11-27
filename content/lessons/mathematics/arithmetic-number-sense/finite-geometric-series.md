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

The symbol $a_1$ means the first term, $a_n$ is the $n^{\text{th}}$ term, $r$ is the common ratio, $n$ is the number of terms being added, and $S_n$ is the sum of the first $n$ terms.

### Sum When the Ratio Is Not One

Add the first $4$ terms of $2,6,18,54,\dots$. Direct addition gives $2+6+18+54=80$.

When $n$ is large, listing every term takes too long. When $r\ne1$, one formula adds all $n$ terms at once:

$$S_n=\dfrac{a_1(1-r^n)}{1-r}$$

If $r>1$, flipping both subtractions to $\dfrac{a_1(r^n-1)}{r-1}$ gives the exact same value and keeps both top and bottom positive.

Test the formula on $2,6,18,54,\dots$ with $a_1=2$, $r=3$, and $n=4$.

1. Compute $r^n$.

$$3^4=81$$

2. Subtract $1$ from $81$ and from $3$.

$$81-1=80,\quad3-1=2$$

3. Multiply by $a_1=2$ and divide by $2$.

$$S_4=\dfrac{2(80)}{2}=80$$

:::why
Why does this formula work? Multiply the sum $S_n$ by $r$ and subtract that new line from $S_n$. Every middle term cancels in pairs, leaving $(1-r)S_n=a_1(1-r^n)$, and dividing by $1-r$ gives $S_n$.
:::

:::pair #omit-sum-denominator
Right: $S_5=\dfrac{5(3^5-1)}{3-1}=\dfrac{5(242)}{2}=605$
Wrong: $S_5=5(3^5-1)=1,210$
Leaving out $r-1=2$ in the denominator doubles the real sum. Always keep $1-r$ (or $r-1$) underneath.
:::

:::pair #report-last-term-not-sum
Right: $S_5=5+15+45+135+405=605$
Wrong: $a_5=5(3^4)=405$
$405$ is only the fifth term, not the sum of all five terms. Check whether the question asks for a term or a sum.
:::

:::check
Find the sum of the first $4$ terms of the geometric sequence $5,10,20,40,\dots$.
:::answer
The answer is $75$. Here $a_1=5$, $r=2$, and $n=4$, so $S_4=\dfrac{5(2^4-1)}{2-1}=5(15)=75$.
:::

### Sum When the Ratio Is One

You cannot use $\dfrac{a_1(1-r^n)}{1-r}$ when $r=1$ because $1-1=0$ in the denominator, and division by $0$ is undefined.

When $r=1$, multiplying by $1$ never changes a number, so every term in the sequence equals $a_1$. Adding $n$ copies of $a_1$ is simply multiplication:

$$S_n=na_1$$

Suppose a geometric sequence has $6$ terms with $a_1=12$ and $r=1$. Every term is $12$, so:

$$S_6=6(12)=72$$

Notice that the same idea works if a question asks for the sum of only the last $5$ terms when $r=1$. Suppose a geometric sequence has $12$ terms, a first term of $18$, and $r=1$. Every term is $18$, and only $5$ of those terms are requested, so the sum of the last $5$ terms is $5\times18=90$, not $12\times18=216$.

:::pair #add-count-instead-of-multiply
Right: The sum of $5$ terms of $18$ is $5\times18=90$.
Wrong: The sum of $5$ terms of $18$ is $5+18=23$.
Adding $5$ equal terms of $18$ means multiplying $5\times18$, not adding $5+18$.
:::

:::check
A geometric sequence has $9$ terms, a first term of $7$, and a common ratio of $1$. What is the sum of its middle $3$ terms?
:::answer
The answer is $21$. Because $r=1$, every term is $7$, so the middle $3$ terms (the $4$th, $5$th and $6$th) sum to $3\times7=21$.

**Check:** All $9$ terms sum to $63$. Remove the first $3$ and the last $3$ terms ($6\times7=42$): $63-42=21$.
:::

## Examples

### #1: Finite Geometric Series

Find the sum of the first $6$ terms of the geometric sequence $3,6,12,24,\dots$.

**Solution:**

1. Read $a_1=3$, $r=\dfrac{6}{3}=2$, and $n=6$.

2. Since $r\ne1$, use the finite geometric-series formula. Start with the power $2^6$.

$$2^6=64$$

3. Subtract inside the parentheses and denominator.

$$1-64=-63,\quad1-2=-1$$

4. Multiply by $a_1=3$ and divide by $-1$.

$$S_6=\dfrac{3(-63)}{-1}=\dfrac{-189}{-1}=189$$

The sum is $189$.

**Check:** List all $6$ terms and add them directly: $3+6+12+24+48+96$. Pair or add left to right: $9+12=21$, $21+24=45$, $45+48=93$, $93+96=189$. Both agree.

### #2: Finite Geometric Series with $r=1$

A geometric series has $8$ terms, and every term is $5$. What is the sum?

**Solution:**

1. Since every term is the same nonzero number $5$, the common ratio is $r=\dfrac{5}{5}=1$.

2. With $r=1$, use $S_n=na_1$ where $n=8$ and $a_1=5$.

:::try
Finish the last step: compute $S_8=8(5)$.
:::answer
The answer is $40$. Multiplying $8\times5$ gives $40$.

**Check:** Add eight copies of $5$: $5+5+5+5+5+5+5+5=40$. That matches $8\times5=40$.
:::

## Traps to Watch For

:::checklist
- Using the finite sum formula when $r\ne1$: always divide by $1-r$ (or $r-1$), so $S_5=\dfrac{5(3^5-1)}{3-1}=605$. {#omit-sum-denominator}
- Asked for a sum of $n$ terms: add all $n$ terms instead of stopping at $a_n$ ($S_5=605$, not $a_5=405$). {#report-last-term-not-sum}
- Adding $n$ equal terms when $r=1$: multiply $n\times a_1$, not $n+a_1$ ($5\times18=90$). {#add-count-instead-of-multiply}
:::
