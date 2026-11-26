---
_id: "lesson-arithmetic-number-sense-coprime-divisibility-tests"
title: "Coprime Divisibility Tests"
summary: "Combine tests for coprime factors to check divisibility by larger numbers."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 4
partCount: 4
ordering: 27
keyPoints:
  - "Combine coprime factors to test a product."
---
## Core Concept

### What Coprime Means

Two positive integers are **relatively prime**, or **coprime**, when their only common positive factor is $1$.

- $3$ and $8$ are coprime: factors of $3$ are $1,3$; factors of $8$ are $1,2,4,8$. Their only shared factor is $1$.
- $4$ and $6$ are **not** coprime: both divide by $2$, so they share a factor larger than $1$.

:::check
Are $9$ and $11$ coprime? Are $3$ and $6$ coprime?
:::answer
The answer is yes for $9$ and $11$ (only $1$ divides both), and no for $3$ and $6$ (both divide by $3$).
:::

### Combining Coprime Factors

If $a$ and $b$ are coprime, a number is divisible by $ab$ exactly when it passes the test for $a$ **and** the test for $b$. Here $ab$ means $a\times b$.

For example, $8$ and $9$ are coprime and $8\times9=72$. Passing both $8$ and $9$ proves a number is divisible by $72$.

The two factors do not have to be prime numbers themselves, as long as they are coprime. If the two factors share a common factor larger than $1$, combining their tests fails.

For example, $4\times6=24$, yet testing $4$ and $6$ does not test $24$. The number $12$ passes both $4$ and $6$, even though $12$ is not divisible by $24$. To test $24$, use $3$ and $8$, which are coprime.

:::pair #overlapping-factors
Right: test $24$ using $3$ and $8$, which are coprime
Wrong: test $24$ using $4$ and $6$, because $4\times6=24$
Factors $4$ and $6$ share the factor $2$. Passing both tests only guarantees divisibility by $12$, not $24$.
:::

:::why
Why do overlapping factors fail? When you test $4$ and $6$, the shared factor $2$ is checked twice instead of giving you another factor of $2$. The smallest number passing both $4$ and $6$ is their least common multiple, $12$, not $24$.
:::

:::check
Which pair of factors proves divisibility by $45$: $3$ and $15$, or $5$ and $9$?
:::answer
The answer is $5$ and $9$. Both $3$ and $15$ share the factor $3$, while $5$ and $9$ share only $1$.
:::

### Testing Two Unknown Digits

When a number has two missing digits $x$ and $y$, always start with the last-digit test ($4$, $5$, $8$, or $10$). It limits the ending digit $y$ to just one or two choices. Then test each valid $y$ with the digit-sum or alternating-sum test ($3$, $9$, or $11$) to find $x$.

Try finding the missing digits in $32x1y$ if it is divisible by $45$. Since $45=5\times9$ and $5,9$ are coprime, test $5$ first, then $9$.

1. By the rule for $5$, $y$ can only be $0$ or $5$.

$$y=0\text{ or }y=5$$

2. Test $y=0$ with the rule for $9$. Add the digits:

$$3+2+x+1+0=6+x$$

The multiple of $9$ gives $6+x=9$, so $x=3$.

3. Test $y=5$ with the rule for $9$. Add the digits:

$$3+2+x+1+5=11+x$$

The multiple of $9$ gives $11+x=18$, so $x=7$.

Both $(3,0)$ and $(7,5)$ pass both tests.

:::pair #pass-only-one-test
Right: check both $9$ and $11$ when testing $99$
Wrong: pick $a=4,b=9$ in $3a4,5b2$ because $3+4+4+5+9+2=27$ passes $9$
Passing one factor test is not enough. In $344,592$, the alternating sum is $(3+4+9)-(4+5+2)=5$, which fails $11$.
:::

:::pair #stop-at-first-case
Right: test both $y=0$ and $y=5$ when finding the largest product or sum
Wrong: stop after testing $y=0$ and report $x\times y=0$
The ending $0$ often gives a smaller answer than $5$ or $8$. Check every valid ending before choosing the greatest or least value.
:::

:::check
If $21x4y$ is divisible by $45$ and $y=5$, what is $x$?
:::answer
The answer is $x=6$. The digit sum is $2+1+x+4+5=12+x$, and the only multiple of $9$ from $12$ to $21$ is $18$, so $x=6$.
:::

## Examples

### #1: Finding Two Missing Digits for $72$

The five-digit number $5x34y$ is a multiple of $72$. Find $x+y$.

**Solution:**

1. Split $72$ into coprime factors: $72=8\times9$. Test $8$ first, then $9$.
2. The last $3$ digits form $34y$, from $340$ to $349$. Divide by $8$: $344\div8=43$ is the only multiple of $8$ in that range, so $y=4$.
3. Substitute $y=4$ into $5x34y$ to get $5x344$, then apply the rule for $9$.

$$5+x+3+4+4=16+x$$

4. Since $x$ is from $0$ to $9$, $16+x$ goes from $16$ to $25$. The only multiple of $9$ in that range is $18$.

$$16+x=18$$

$$x=2$$

5. Add the two digits.

$$x+y=2+4=6$$

The sum is $6$.

**Check:** Put $x=2$ and $y=4$ into $52,344$. Divide directly: $52,344\div72=727$ with no remainder.

### #2: Checking Every Case for a Maximum

The five-digit number $74x3y$ is divisible by $36$. What is the greatest possible value of $x+y$?

**Solution:**

1. Split $36$ into coprime factors: $36=4\times9$. Test $4$ first, then $9$.
2. For divisibility by $4$, the last $2$ digits $3y$ must divide by $4$. The multiples of $4$ from $30$ to $39$ are $32$ and $36$, so $y=2$ or $y=6$.
3. First case ($y=2$): add the digits of $74x32$.

$$7+4+x+3+2=16+x$$

The only multiple of $9$ from $16$ to $25$ is $18$, so $x=2$, giving $x+y=2+2=4$.

4. Second case ($y=6$): add the digits of $74x36$.

$$7+4+x+3+6=20+x$$

The only multiple of $9$ from $20$ to $29$ is $27$, so $x=7$.

:::try
Finish the last step: find $x+y$ for the second case and compare it with the first case to pick the greatest sum.
:::answer
The answer is $13$. In the second case, $x+y=7+6=13$, which is greater than $4$ from the first case.

**Check:** Test $74,736$ directly: $74,736\div36=2,076$ with no remainder. The smaller case $74,232\div36=2,062$ also passes, confirming $13$ is the greatest sum.
:::

## Speed Tricks & Shortcuts

### Common Coprime Splits

- $12=3\times4$
- $18=2\times9$
- $24=3\times8$
- $30=3\times10$
- $36=4\times9$
- $45=5\times9$
- $72=8\times9$
- $88=8\times11$
- $99=9\times11$

## Traps to Watch For

:::checklist
- Splitting a composite divisor: pick two factors that share only $1$, such as $3$ and $8$ for $24$. {#overlapping-factors}
- Testing a composite number: verify both coprime factor tests, never stop after passing just one. {#pass-only-one-test}
- Finding a maximum or minimum digit sum: test every valid ending digit before picking the answer. {#stop-at-first-case}
:::
