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

### Combining Coprime Factors

If $a$ and $b$ are coprime positive integers, a number is divisible by $ab$ exactly when it passes the test for $a$ **and** the test for $b$. Here $ab$ means $a\times b$.

For example, $8$ and $9$ are coprime and $8\times9=72$. Passing both $8$ and $9$ proves a number is divisible by $72$.

The factors need not be prime, only coprime. If the two factors share a factor larger than $1$, passing both tests does not prove divisibility by their product.

For example, $4\times6=24$, yet testing $4$ and $6$ does not test $24$. The number $12$ passes both $4$ and $6$, even though $12$ is not divisible by $24$. To test $24$, use $3$ and $8$, which are coprime.

:::pair #overlapping-factors
Right: test $24$ using $3$ and $8$, which are coprime
Wrong: test $24$ using $4$ and $6$, because $4\times6=24$
Factors $4$ and $6$ share the factor $2$. Passing both tests only guarantees divisibility by $12$, not $24$.
:::

:::why
Why do overlapping factors fail? When you test $4$ and $6$, the shared factor $2$ is checked twice instead of giving you another factor of $2$. The smallest positive number passing both $4$ and $6$ is their least common multiple, $12$, not $24$.
:::

:::check
A number passes the tests for $6$ and $10$. Must it be divisible by $60$?
:::answer
The answer is no. The factors $6$ and $10$ share the factor $2$, and $30$ passes both tests but is not divisible by $60$.
:::

### Testing Two Unknown Digits

When a number has two missing digits $x$ and $y$ and the divisor has a last-digit factor ($4$, $5$, $8$, or $10$), start with the last-digit test. It limits the ending digit $y$ to a few choices. Then test each valid $y$ with the digit-sum or alternating-sum test ($3$, $9$, or $11$) to find $x$.

Find $x$ and $y$ in $32x1y$, a multiple of $45$. Since $45=5\times9$ and $5,9$ are coprime, test $5$ first, then $9$.

1. By the rule for $5$, $y$ can only be $0$ or $5$.

$$y=0\text{ or }y=5$$

2. Test $y=0$ with the rule for $9$. Add the digits:

$$3+2+x+1+0=6+x$$

Since $x$ is a digit, $6+x$ is from $6$ to $15$. The only multiple of $9$ there is $9$.

$$6+x=9$$

$$x=3$$

3. Test $y=5$ with the rule for $9$. Add the digits:

$$3+2+x+1+5=11+x$$

Since $x$ is a digit, $11+x$ is from $11$ to $20$. The only multiple of $9$ there is $18$.

$$11+x=18$$

$$x=7$$

So $(x,y)$ is $(3,0)$ or $(7,5)$.

:::pair #pass-only-one-test
Right: in $3a4,5b2$, divisible by $99$, check both $9$ and $11$
Wrong: pick $a=4,b=9$ in $3a4,5b2$ because $3+4+4+5+9+2=27$ passes $9$
Passing one factor test is not enough. In $344,592$, the alternating sum is $(3+4+9)-(4+5+2)=5$, which fails $11$.
:::

:::pair #stop-at-first-case
Right: in $32x1y$, test both $y=0$ and $y=5$ when finding the largest product or sum
Wrong: stop after testing $y=0$ and report $x\times y=0$
The ending $0$ gives $3\times0=0$, but $y=5$ gives $7\times5=35$. Check every valid ending before choosing the greatest or least value.
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

$$x+y=2+4$$

$$x+y=6$$

The sum is $6$.

### #2: Checking Every Case for a Maximum

The five-digit number $74x3y$ is divisible by $36$. What is the greatest possible value of $x+y$?

**Solution:**

1. Split $36$ into coprime factors: $36=4\times9$. Test $4$ first, then $9$.
2. For divisibility by $4$, the last $2$ digits $3y$ must divide by $4$. The multiples of $4$ from $30$ to $39$ are $32$ and $36$, so $y=2$ or $y=6$.
3. First case ($y=2$): add the digits of $74x32$.

$$7+4+x+3+2=16+x$$

The only multiple of $9$ from $16$ to $25$ is $18$.

$$16+x=18$$

$$x=2$$

With $y=2$, the sum is $x+y=2+2=4$.

4. Second case ($y=6$): add the digits of $74x36$.

$$7+4+x+3+6=20+x$$

The only multiple of $9$ from $20$ to $29$ is $27$.

$$20+x=27$$

$$x=7$$

:::try
Finish the last step: find $x+y$ for the second case and compare it with the first case to pick the greatest sum.
:::answer
The answer is $13$. In the second case, $x+y=7+6=13$, which is greater than $4$ from the first case.
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
- Testing a divisor with coprime factors: verify both factor tests, never stop after passing just one. {#pass-only-one-test}
- Finding a largest or smallest sum or product of missing digits: test every valid ending digit first. {#stop-at-first-case}
:::
