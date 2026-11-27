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

- $3$ and $8$ are coprime: the factors of $3$ are $1,3$, and of $8$ are $1,2,4,8$. They share only $1$.
- $4$ and $6$ are **not** coprime: both divide by $2$.

### Combining Coprime Factors

If $a$ and $b$ are coprime positive integers, a number is divisible by $ab$ exactly when it passes the test for $a$ **and** the test for $b$.
For example, $8$ and $9$ are coprime and $8\times9=72$, so passing both proves divisibility by $72$. The factors need not be prime.

If the factors share a factor, passing both tests does not prove divisibility by their product. For example, $4\times6=24$. The number $12$ passes both $4$ and $6$, even though $12$ is not divisible by $24$.

<!-- ILLUSTRATION: Two rows of prime tiles. The number 4 is the tiles 2 and 2. The number 6 is the tiles 2 and 3. The first 2 tile in each row is the shared factor 2 and is outlined in both rows. Below the rows: the tiles needed for both are 2 x 2 x 3 = 12, so passing the tests for 4 and 6 only proves divisibility by 12. Testing 24 needs 2 x 2 x 2 x 3. -->

:::pair #overlapping-factors
Right: test $24$ using $3$ and $8$, which are coprime
Wrong: test $24$ using $4$ and $6$, because $4\times6=24$
Factors $4$ and $6$ share the factor $2$. Passing both tests only guarantees divisibility by $12$, not $24$.
:::

:::why
Why do overlapping factors fail? When you test $4$ and $6$, the shared factor $2$ is checked twice instead of giving you another factor of $2$. The smallest positive number passing both $4$ and $6$ is their least common multiple, $12$, not $24$.
:::

:::check
What is the smallest positive number that passes the tests for $6$ and $10$ but is not divisible by $60$?
:::answer
The answer is $30$. The factors $6$ and $10$ share the factor $2$, so a number passes both tests exactly when it is a multiple of $30$. The smallest is $30$, and $30$ is not divisible by $60$.
:::

### Testing Two Unknown Digits

With two missing digits $x$ and $y$, a divisor with a last-digit factor ($4$, $5$, $8$, or $10$) lets you test that factor first when $y$ is in the digits it reads and $x$ is not. That limits $y$ to a few choices. Then, for each valid $y$, test the other coprime factor with its own rule, such as digit sums for $3$ or $9$ or alternating sums for $11$, to find $x$.

Find $x$ and $y$ in $32x1y$, a multiple of $45$. Since $45=5\times9$ and $5,9$ are coprime, test $5$ first, then $9$.

1. By the rule for $5$, $y$ can only be $0$ or $5$.

2. Test $y=0$ with the rule for $9$. Since $x$ is a digit, the digit sum is from $6$ to $15$. The only multiple of $9$ there is $9$.

$$3+2+x+1+0=6+x=9$$

$$x=9-6=3$$

3. Test $y=5$ with the rule for $9$. Since $x$ is a digit, the digit sum is from $11$ to $20$. The only multiple of $9$ there is $18$.

$$3+2+x+1+5=11+x=18$$

$$x=18-11=7$$

So $(x,y)$ is $(3,0)$ or $(7,5)$.

If the range holds two multiples of $9$, keep both. In $5x31$, $9+x$ is from $9$ to $18$, so $x=0$ or $9$.

For $99=9\times11$, find $a$ and $b$ if $2a6,3b5$ is a multiple of $99$. The $11$ difference is from $-9$ to $9$, so it must be $0$ and $a=b$.

$$(2+6+b)-(a+3+5)=b-a=0$$

The digit sum $16+2a$ is even and at most $34$, so it is $18$ and $a=b=1$.

$$2+a+6+3+a+5=16+2a=18$$

:::pair #pass-only-one-test
Right: in $3a4,5b2$, divisible by $99$, check both $9$ and $11$
Wrong: pick $a=4,b=9$ in $3a4,5b2$ because $3+4+4+5+9+2=27$ passes $9$
In $344,592$, the alternating sum is $(3+4+9)-(4+5+2)=5$, which fails $11$.
:::

:::pair #stop-at-first-case
Right: in $32x1y$, test both $y=0$ and $y=5$ when finding the largest product or sum
Wrong: stop after testing $y=0$ and report $x\times y=0$
The ending $0$ gives $3\times0=0$, but $y=5$ gives $7\times5=35$.
:::

## Examples

### #1: Finding Two Missing Digits for $72$

The five-digit number $5x34y$ is a multiple of $72$. Find $x+y$.

**Solution:**

1. Split $72$ into coprime factors: $72=8\times9$. Test $8$ first, then $9$.
2. The last $3$ digits form $34y$, from $340$ to $349$. Divide by $8$: $344\div8=43$ is the only multiple of $8$ in that range, so $y=4$.
3. Substitute $y=4$ into $5x34y$ to get $5x344$, then apply the rule for $9$. Since $x$ is from $0$ to $9$, the digit sum goes from $16$ to $25$. The only multiple of $9$ in that range is $18$.

$$5+x+3+4+4=16+x=18$$

4. Solve for $x$.

$$x=18-16=2$$

5. Add the two digits.

$$x+y=2+4=6$$

### #2: Checking Every Case for a Maximum

The five-digit number $74x3y$ is divisible by $36$. What is the greatest possible value of $x+y$?

**Solution:**

1. Split $36$ into coprime factors: $36=4\times9$. Test $4$ first, then $9$.
2. For divisibility by $4$, the last $2$ digits $3y$ must divide by $4$. The multiples of $4$ from $30$ to $39$ are $32$ and $36$, so $y=2$ or $y=6$.
3. First case ($y=2$): add the digits of $74x32$. Since $x$ is a digit, the sum is from $16$ to $25$. The only multiple of $9$ there is $18$.

$$7+4+x+3+2=16+x=18$$

$$x=18-16=2$$

With $y=2$, the sum is $x+y=2+2=4$.

4. Second case ($y=6$): add the digits of $74x36$. The sum is from $20$ to $29$. The only multiple of $9$ there is $27$.

$$7+4+x+3+6=20+x=27$$

$$x=27-20=7$$

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

For $88=8\times11$, find $y$ if $561,1y6$ is a multiple of $88$. The multiples of $8$ from $106$ to $196$ that end in $6$ are $136$ and $176$, so $y=3$ or $7$. The $11$ difference is $(5+1+3)-(6+1+6)=-4$ for $y=3$ and $(5+1+7)-(6+1+6)=0$ for $y=7$. So $y=7$.

## Traps to Watch For

:::checklist
- Splitting a composite divisor: pick two factors that share only $1$, such as $3$ and $8$ for $24$. {#overlapping-factors}
- Testing a divisor with coprime factors: verify both factor tests. {#pass-only-one-test}
- Finding a largest or smallest sum or product of missing digits: test every valid ending. {#stop-at-first-case}
:::
