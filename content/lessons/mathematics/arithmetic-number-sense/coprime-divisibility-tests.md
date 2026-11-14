---
_id: "lesson-arithmetic-number-sense-coprime-divisibility-tests"
title: "Coprime Divisibility Tests"
summary: "Combine tests only when the factors are coprime."
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

### Combining Coprime Factors

Two positive integers are **relatively prime**, or **coprime**, when their only common positive factor is $1$.

If $a$ and $b$ are coprime, a number is divisible by $ab$ exactly when it is divisible by both $a$ and $b$. Here, $ab$ means $a\times b$.

For example, $8$ and $9$ have no common factor greater than $1$. Since $8\times9=72$, passing both tests proves divisibility by $72$.

The factors need not be prime numbers themselves. But they must be coprime for this product test to work. Shared factors can make the two tests check some of the same factors twice.

## Examples

### #1: Combining Divisibility Tests

The five-digit number $5X34Y$ is a multiple of $72$. Find $X+Y$.

**Solution:**

1. Since $72=8\times9$ and the factors are coprime, test divisibility by both $8$ and $9$.
2. The last $3$ digits range from $340$ to $349$. The only multiple of $8$ in that range is $344$.

$$344\div8=43$$

3. Thus $Y=4$. Apply the rule for $9$ to $5X344$.

$$5+X+3+4+4=16+X$$

4. The only multiple of $9$ from $16$ through $25$ is $18$.

$$16+X=18$$

$$X=2$$

5. Add the two digits.

$$X+Y=2+4=6$$

## Speed Tricks & Shortcuts

### Coprime Split

Look for coprime factors with easy tests. To test divisibility by $36$, test $4$ and $9$ because $4\times9=36$ and they are coprime.

## Traps to Watch For

### #1: Splitting a Divisor Incorrectly

> Shared factors can make a product test fail.

The number $12$ is divisible by both $4$ and $6$, but not by $24$. To test $24$, use the coprime factors $3$ and $8$.
