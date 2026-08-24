---
_id: "lesson-arithmetic-number-sense-prime-factorization-gcf-lcm"
title: "Prime Factorization, GCF, and LCM"
summary: "Learn how to use prime factors to solve GCF and LCM problems."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 8
isActive: true
---
## Core Concept

A **prime number** is an integer greater than $1$ with exactly two positive factors: $1$ and itself. Examples include $2, 3, 5, 7,$ and $11$.

**Prime factorization** means writing an integer greater than $1$ as a product of prime numbers.

**GCF** stands for Greatest Common Factor. For positive integers, it is the greatest positive integer that divides all the given numbers.

**LCM** stands for Least Common Multiple. For positive integers, it is the least positive integer that is a multiple of all the given numbers.

## Mnemonics & Memory Aids

When using prime factorizations:

> **P.I.G.** for GCF: **P**ick **I**dentical bases, **G**et the lowest exponent.

> **A.L.L.** for LCM: Take **A**ll prime bases and use the **L**argest exponent for each.

These are memory aids, not definitions. In word problems, decide whether the situation asks for a greatest common grouping size/count or a least common repeating interval.

## Examples

### #1: Basic Prime Factorization

Which of the following represents the prime factorization of $360$?

A) $2^2 \times 3^2 \times 5$
B) $2^3 \times 3^2 \times 5$
C) $2^3 \times 3^3 \times 5$
D) $2^2 \times 3^3 \times 5$

**Solution:**

Divide repeatedly by primes:

$$360 = 2 \times 180 = 2^2 \times 90 = 2^3 \times 45 = 2^3 \times 3^2 \times 5.$$

The correct answer is B.

### #2: GCF and LCM with Variables

Find the greatest common factor and the least common multiple of $12x^3y^2$ and $18xy^4$, assuming the variables represent nonzero quantities for the LCM expression.

**Solution:**

1. Factor the coefficients.

$$12=2^2\times3$$

$$18=2\times3^2$$

2. For the GCF, use each shared factor to the smaller exponent.

$$\text{GCF}=2^1\times3^1\times x^1\times y^2=6xy^2$$

3. For the LCM, use each factor to the larger exponent.

$$\text{LCM}=2^2\times3^2\times x^3\times y^4=36x^3y^4$$

### #3: Equal Groups Word Problem

A relief operations team has $84$ cans of sardines, $126$ packs of noodles, and $210$ kilos of rice. They want to pack these into the greatest possible number of identical relief bags with no items left over. How many bags can they make?

**Solution:**

1. Find the GCF of the three quantities.

$$84=2^2\times3\times7$$

$$126=2\times3^2\times7$$

$$210=2\times3\times5\times7$$

2. The shared prime factors with the lowest exponents are $2$, $3$, and $7$.

$$\text{GCF}=2\times3\times7=42$$

3. They can make $42$ identical bags.

### #4: Repeating Schedule Word Problem

Three campus shuttles depart from the main gate at exactly $7{:}00$ am. Shuttle A completes its route every $15$ minutes, Shuttle B every $20$ minutes, and Shuttle C every $25$ minutes. At what time will all three depart together again?

**Solution:**

1. Find the LCM of the three route times.

$$15=3\times5$$

$$20=2^2\times5$$

$$25=5^2$$

2. Use the largest exponent of each prime.

$$\text{LCM}=2^2\times3\times5^2=300\text{ minutes}$$

3. $300$ minutes is $5$ hours, so the next common departure is at $12{:}00$ pm.

### #5: Same Remainder Problem

What is the smallest integer greater than $10$ that leaves a remainder of $3$ when divided by $6$, $8$, and $10$?

**Solution:**

1. If a number leaves remainder $3$ in each division, subtract $3$. The result must be divisible by $6$, $8$, and $10$.
2. Find the LCM.

$$6=2\times3,\qquad 8=2^3,\qquad 10=2\times5$$

$$\text{LCM}=2^3\times3\times5=120$$

3. The solutions have the form $120k+3$ for integers $k$. The case $k=0$ gives $3$, but the question requires a number greater than $10$.
4. Use $k=1$:

$$120+3=123$$

5. The answer is $123$.

## Speed Tricks & Shortcuts

**Prime-factor table.**
For several numbers, prime-factor each number and compare exponents. The GCF uses only primes shared by every number, with the smallest exponent. The LCM uses every prime that appears, with the largest exponent.

This avoids a common error in a "continuous division" shortcut: dividing only by primes common to all rows and then multiplying the remaining bottom row does **not** always produce the LCM for three or more numbers. For example, $6$, $10$, and $15$ have no prime common to all three, yet their LCM is $30$, not $6\times10\times15$.

**Product Formula for Two Positive Integers.**
For two positive integers $a$ and $b$:

$$\gcd(a,b)\times\operatorname{lcm}(a,b)=ab$$

So if two numbers and their GCF are known, the LCM can be found without repeating the full factorization.

## Traps to Watch For

### #1: Thinking $1$ is Prime

The number $1$ is not prime because it has only one positive factor. A prime number has exactly two positive factors.

### #2: Incomplete Factorization

If a factor is still composite, continue factoring it. For example, $12=4\times3$ is not yet a prime factorization because $4=2\times2$.

### #3: Confusing Lowest and Highest Exponents

For the GCF, use the **lowest** exponent among factors shared by all expressions. For the LCM, use the **highest** exponent of every prime factor that appears.

## When to List Multiples

Listing multiples works well for small numbers. For larger values, prime factorization is often more systematic and makes both the GCF and LCM conditions explicit.
