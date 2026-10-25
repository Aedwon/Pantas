---
_id: "lesson-arithmetic-number-sense-prime-factorization-gcf-lcm"
title: "Prime Factorization, GCF, and LCM"
summary: "Use prime factors to find GCF and LCM for equal groups, repeating events, and same-remainder problems."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 10
isActive: true
---
## Core Concept

A **prime number** is an integer greater than $1$ with exactly two positive factors: $1$ and itself. Examples include $2, 3, 5, 7,$ and $11$.

A **composite number** is an integer greater than $1$ with more than two positive factors. For example, $12$ is composite because it has factors besides $1$ and $12$.

**Prime factorization** means writing an integer greater than $1$ as a product of prime numbers. Keep factoring until every factor is prime.

**GCF** stands for Greatest Common Factor. For positive integers, it is the greatest positive integer that divides all the given numbers.

**LCM** stands for Least Common Multiple. For positive integers, it is the least positive integer that is a multiple of all the given numbers.

To find the GCF with prime powers, factor each number. Keep only prime factors shared by every number, then use the smallest exponent for each shared prime.

To find the LCM, factor each number. Use every prime factor that appears, then use the largest exponent for each prime.

Use the GCF when a problem asks for the greatest number of equal groups or the greatest equal size with nothing left over. Use the LCM when events repeat and you need the first time they happen together again.

For a same-remainder problem, subtract the common remainder first. The remainder must be less than every divisor. The remaining part must be divisible by each divisor, so an LCM can describe the repeating values.

## Examples

### #1: Basic Prime Factorization

Which of the following represents the prime factorization of $360$?

- A. $2^2\times3^2\times5$
- B. $2^3\times3^2\times5$
- C. $2^3\times3^3\times5$
- D. $2^2\times3^3\times5$

**Solution:**

1. Divide by prime factors until only primes remain.

$$360=2\times180$$

$$180=2\times90$$

$$90=2\times45$$

$$45=3\times15$$

$$15=3\times5$$

2. Count repeated prime factors.

$$360=2^3\times3^2\times5$$

3. The correct answer is B.

### #2: Equal Groups Word Problem

A relief operations team has $84$ cans of sardines, $126$ packs of noodles, and $210$ kilos of rice. They want to pack these into the greatest possible number of identical relief bags with no items left over. How many bags can they make?

**Solution:**

1. Find the GCF of the three quantities.

$$84=2^2\times3\times7$$

$$126=2\times3^2\times7$$

$$210=2\times3\times5\times7$$

2. The shared prime factors with the smallest exponents are $2$, $3$, and $7$.

$$\text{GCF}=2\times3\times7=42$$

3. They can make $42$ identical bags.

### #3: Repeating Schedule Word Problem

Three campus shuttles depart from the main gate at exactly $7{:}00$ am. Shuttle A completes its route every $15$ minutes, Shuttle B every $20$ minutes, and Shuttle C every $25$ minutes. At what time will all three depart together again?

**Solution:**

1. Find the LCM of the three route times.

$$15=3\times5$$

$$20=2^2\times5$$

$$25=5^2$$

2. Use every prime factor with its largest exponent.

$$\text{LCM}=2^2\times3\times5^2$$

$$\text{LCM}=300\text{ minutes}$$

3. Convert $300$ minutes to hours.

$$300\div60=5$$

4. Add $5$ hours to $7{:}00$ am. The next common departure is at $12{:}00$ pm.

### #4: Same Remainder Problem

What is the smallest integer greater than $10$ that leaves a remainder of $3$ when divided by $6$, $8$, and $10$?

**Solution:**

1. Subtract the common remainder $3$. The result must be divisible by $6$, $8$, and $10$.
2. Find their LCM.

$$6=2\times3$$

$$8=2^3$$

$$10=2\times5$$

3. Use every prime factor with its largest exponent.

$$\text{LCM}=2^3\times3\times5=120$$

4. Numbers with the required remainder have the form $120k+3$ for integers $k$. The case $k=0$ gives $3$, which is not greater than $10$.
5. Use $k=1$.

$$120+3=123$$

6. The answer is $123$.

## Speed Tricks & Shortcuts

**Prime-factor comparison.**
For several numbers, factor each number and compare exponents. The GCF uses only primes shared by every number, with the smallest exponent. The LCM uses every prime that appears, with the largest exponent.

A common continuous-division mistake is to divide only by primes common to every row. That method can fail for $3$ or more numbers if you then multiply the remaining bottom row.

For example, $6$, $10$, and $15$ have no prime common to all three. Their LCM is $30$, not $6\times10\times15$.

**Product Formula for Two Positive Integers.**
For two positive integers $a$ and $b$:

$$\text{GCF}\times\text{LCM}=a\times b$$

This shortcut applies to two positive integers. If the two numbers and their GCF are known, you can find the LCM without repeating the full factorization.

## Traps to Watch For

### #1: Thinking $1$ Is Prime

> Do not count $1$ as a prime number.

The number $1$ has only one positive factor. A prime number has exactly two positive factors.

### #2: Incomplete Factorization

> Stop only when every factor is prime.

For example, $12=4\times3$ is not yet a prime factorization because $4$ is composite. Continue with $4=2\times2$.

### #3: Confusing Smallest and Largest Exponents

> GCF uses the smallest shared exponents. LCM uses the largest exponents that appear.

Using the wrong exponent can make the GCF too large or the LCM too small. Check whether the result really divides every number or is a multiple of every number.

## When to List Multiples

Listing multiples works well for small numbers. For larger values, prime factorization is often more systematic and makes the GCF and LCM conditions clear.
