---
_id: "lesson-arithmetic-number-sense-prime-factors-and-powers"
title: "Prime Factors and Powers"
summary: "Write numbers as products of primes."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 4
ordering: 11
keyPoints:
  - "Identify prime and composite numbers."
  - "Write prime factorizations with exponents."
---
## Core Concept

### Prime and Composite Numbers

A **factor** divides a number with no remainder. A positive **multiple** of a number comes from multiplying it by $1, 2, 3$, and so on.

A **prime number** is an integer greater than $1$ with *exactly* two positive factors: $1$ and itself. The first few primes are $2, 3, 5, 7, 11, 13$.

Notice that $2$ is the only even prime. Every even number greater than $2$ also divides by $2$, so it has at least three factors.

A **composite number** is an integer greater than $1$ with more than two positive factors. For example, $12$ divides by $1, 2, 3, 4, 6,$ and $12$. Odd numbers can be composite too: $9=3\times 3$ and $21=3\times 7$.

For a whole number from $6$ to $48$, it is prime if none of $2$, $3$ and $5$ divides it. For example, none of them divides $29$, so $29$ is prime. The numbers $2$, $3$ and $5$ are prime, and $1$ is neither prime nor composite.

:::why
Why is $1$ neither prime nor composite? A prime needs two distinct positive factors, $1$ and itself. The number $1$ has only one positive factor, $1$, so it fits neither group.
:::

:::pair #one-is-not-prime
Right: the smallest prime number is $2$
Wrong: $1$ is the smallest prime
A prime must have two positive factors. Counting $1$ as prime puts an extra $1$ into prime factorizations where it does not belong.
:::

:::check
What is the smallest prime number greater than $30$?
:::answer
The answer is $31$. None of $2, 3, 5$ divides $31$, so it is prime.
:::

### Prime Factorization and Powers

**Prime factorization** means writing an integer greater than $1$ as a product of prime numbers only. Divide out small primes step by step until every leftover factor is prime.

Factor $60$ into primes. Divide by $2$ while the number is even, then move to $3$:

$$60=2\times 30$$

$$30=2\times 15$$

$$15=3\times 5$$

$$60=2\times 2\times 3\times 5$$

Now every factor ($2, 2, 3, 5$) is prime.

An **exponent** tells how many times a factor repeats. In $2^3$, the base is $2$ and the exponent is $3$:

$$2^3=2\times 2\times 2=8$$

A **prime power** has a prime number as its base. For $60$, there are two $2$s, one $3$, and one $5$:

$$60=2^2\times 3\times 5$$

<!-- ILLUSTRATION: A factor tree for 60. 60 splits into 2 and 30. 30 splits into 2 and 15. 15 splits into 3 and 5. The prime leaves 2, 2, 3 and 5 are circled, and below the tree is written 60 = 2^2 x 3 x 5. -->

Factor $72$ the same way: divide by $2$ three times to get $9$, then split $9$:

$$72=2\times 36$$

$$36=2\times 18$$

$$18=2\times 9$$

$$9=3\times 3$$

$$72=2^3\times 3^2$$

:::pair #stop-at-composite
Right: to factor $180$ into primes, $180=2^2\times 3^2\times 5$
Wrong: to factor $180$ into primes, $180=2^2\times 9\times 5$
The wrong line stopped at composite $9=3\times 3$. Keep splitting until only primes remain.
:::

## Examples

### #1: Basic Prime Factorization

Find the prime factorization of $360$.

**Solution:**

1. Divide by $2$ while the result is even.

$$360=2\times 180$$

$$180=2\times 90$$

$$90=2\times 45$$

2. Next divide $45$ by $3$.

$$45=3\times 15$$

$$15=3\times 5$$

3. Both $3$ and $5$ are prime, so stop dividing.

:::try
Finish the last step: count how many times each prime appears, and write $360$ using prime powers.
:::answer
The answer is $2^3\times 3^2\times 5$. There are three $2$s, two $3$s, and one $5$.
:::

## Traps to Watch For

:::checklist
- Listing prime numbers or prime factors: skip $1$, because $2$ is the smallest prime. {#one-is-not-prime}
- Stopping a factor tree early: keep splitting composite factors like $9$ or $35$ until every base is prime. {#stop-at-composite}
:::
