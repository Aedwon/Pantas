---
_id: "lesson-arithmetic-number-sense-infinite-geometric-series"
title: "Infinite Geometric Series"
summary: "Find the sum of a convergent infinite geometric series."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 7
partCount: 9
ordering: 34
keyPoints:
  - 'Find the sum of a convergent infinite geometric series.'
  - 'Check whether an infinite geometric series diverges.'
---
## Core Concept

### When an Infinite Geometric Series Converges

An **infinite series** keeps adding terms forever without stopping. It **converges** when the running total gets closer and closer to one finite number. It **diverges** when the running total does not settle toward any finite sum.

Look at $1+\dfrac{1}{2}+\dfrac{1}{4}+\dfrac{1}{8}+\dots$, where the common ratio is $r=\dfrac{1}{2}$. Watch the running totals grow:

$$1$$

$$1+\dfrac{1}{2}=\dfrac{3}{2}=1.5$$

$$1.5+\dfrac{1}{4}=1.75$$

$$1.75+\dfrac{1}{8}=1.875$$

Each new term cuts the gap to $2$ in half, so the running total approaches $2$.

The symbol $|r|$ means the absolute value of $r$, or its distance from $0$. For an infinite geometric series with a nonzero first term $a_1$:

- If $|r|<1$, the terms shrink toward $0$, so the series **converges** to one finite sum. For example, $16-8+4-2+\dots$ has $r=\dfrac{-8}{16}=-\dfrac{1}{2}$, and $\left|-\dfrac{1}{2}\right|=\dfrac{1}{2}<1$.
- If $|r|\ge1$, the terms do not shrink toward $0$, so the series **diverges** (no finite sum). For example, $2+6+18+54+\dots$ has $r=3$, and $|3|=3\ge1$.

If $a_1=0$, every term is $0$, so the series converges to $0$ for any ratio $r$.

:::pair #alternating-signs-diverge
Right: $16-8+4-2+\dots$ converges because $r=-\dfrac{1}{2}$ and $\left|-\dfrac{1}{2}\right|=\dfrac{1}{2}<1$.
Wrong: $5-5+5-5+\dots$ converges because its signs alternate.
Alternating signs do not guarantee convergence. In $5-5+5-5+\dots$, $r=-1$, so $|r|=1$ and the running total bounces between $5$ and $0$ forever.
:::

### Finding the Infinite Sum

In exam questions, **evaluate** means find the final number answer. To **simplify** means write an expression in a simpler form. When $|r|<1$, the infinite sum $S_\infty$ is:

$$S_\infty=\dfrac{a_1}{1-r}$$

Evaluate $12+4+\dfrac{4}{3}+\dfrac{4}{9}+\dots$ from $a_1$ and $r$.

1. Identify $a_1=12$ and find $r$.

$$r=\dfrac{4}{12}=\dfrac{1}{3}$$

Since $\left|\dfrac{1}{3}\right|<1$, the series converges.

2. Subtract $r$ from $1$ in the denominator.

$$1-\dfrac{1}{3}=\dfrac{2}{3}$$

3. Divide $a_1=12$ by $\dfrac{2}{3}$, which means multiplying by its reciprocal $\dfrac{3}{2}$.

$$S_\infty=12\div\dfrac{2}{3}$$

$$S_\infty=12\times\dfrac{3}{2}$$

$$S_\infty=18$$

Watch the signs closely when $r$ is negative. For $16-8+4-2+\dots$, $a_1=16$ and $r=-\dfrac{1}{2}$. Subtracting a negative in $1-r$ turns into addition, so $1-\left(-\dfrac{1}{2}\right)$ becomes $1+\dfrac{1}{2}$:

$$1+\dfrac{1}{2}=\dfrac{3}{2}$$

$$S_\infty=16\div\dfrac{3}{2}$$

$$S_\infty=16\times\dfrac{2}{3}$$

$$S_\infty=\dfrac{32}{3}$$

:::why
Why does $S_n=\dfrac{a_1(1-r^n)}{1-r}$, the sum of the first $n$ terms, simplify to $\dfrac{a_1}{1-r}$? When $|r|<1$, multiplying $r$ by itself over and over shrinks $r^n$ toward $0$, so $1-r^n$ approaches $1$.
:::

:::pair #add-ratio-in-denominator
Right: $12\div\left(1-\dfrac{1}{3}\right)=12\div\dfrac{2}{3}=18$
Wrong: $12\div\left(1+\dfrac{1}{3}\right)=12\div\dfrac{4}{3}=9$
Subtract $r$ from $1$ to get $1-r$. Adding $r$ to $1$ makes the denominator too large and shrinks the sum to $9$.
:::

:::pair #divide-by-ratio-only
Right: $12\div\left(1-\dfrac{1}{3}\right)=18$
Wrong: $12\div\dfrac{1}{3}=36$
Do not divide $a_1$ by $r$ alone. Subtract $r$ from $1$ first.
:::

:::check
Evaluate the infinite geometric series $\dfrac{3}{5}+\dfrac{3}{10}+\dfrac{3}{20}+\dots$.
:::answer
The answer is $\dfrac{6}{5}$. Here $a_1=\dfrac{3}{5}$ and $r=\dfrac{3}{10}\div\dfrac{3}{5}=\dfrac{1}{2}$, so $S_\infty=\dfrac{3}{5}\div\dfrac{1}{2}=\dfrac{6}{5}$.
:::

## Examples

### #1: Evaluating an Infinite Geometric Series

Evaluate the infinite geometric series $18+6+2+\dfrac{2}{3}+\dots$ from $a_1$ and $r$.

**Solution:**

1. Read $a_1=18$ and divide the second term by the first to find $r$.

$$r=\dfrac{6}{18}=\dfrac{1}{3}$$

Since $\left|\dfrac{1}{3}\right|<1$, the series converges.

2. Subtract $r$ from $1$ to get the denominator.

$$1-\dfrac{1}{3}=\dfrac{2}{3}$$

3. Divide $a_1=18$ by $\dfrac{2}{3}$.

$$S_\infty=18\div\dfrac{2}{3}$$

$$S_\infty=18\times\dfrac{3}{2}$$

$$S_\infty=27$$

The sum is $27$.

### #2: Testing an Infinite Geometric Series

Decide from $r$ whether the infinite geometric series $3+6+12+24+\dots$ has a finite sum.

**Solution:**

1. Read $a_1=3$ and divide the second term by the first to find $r$.

$$r=\dfrac{6}{3}=2$$

2. Check the convergence test $|r|<1$.

:::try
Finish the last step: compare $|r|$ with $1$ and decide whether the series has a finite sum.
:::answer
The answer is no, it does not have a finite sum. Here $|r|=|2|=2$, which is not less than $1$, so the series diverges.
:::

## Traps to Watch For

:::checklist
- Before using $S_\infty=\dfrac{a_1}{1-r}$ (including alternating series): when $a_1\neq 0$, check $|r|<1$ first, because nonzero series with $|r|\ge 1$ diverge. {#when-an-infinite-geometric-series-converges}
- Finding the denominator of $S_\infty$: subtract $r$ from $1$ to get $1-r$, not add $r$ ($12\div\left(1-\dfrac{1}{3}\right)=18$). {#add-ratio-in-denominator}
- Applying $S_\infty=\dfrac{a_1}{1-r}$: divide by $1-r$, not by $r$ alone. {#divide-by-ratio-only}
:::
