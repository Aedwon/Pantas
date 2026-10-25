---
_id: "lesson-arithmetic-number-sense-prime-factorization-gcf-lcm"
title: "Prime Factorization, GCF, and LCM"
summary: "Use prime factors to find GCF and LCM for equal groups, repeating events, and same-remainder problems."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **factor** divides a number with no remainder. A positive **multiple** of a number is the result of multiplying it by a positive integer.

A **prime number** is an integer greater than $1$ with exactly two positive factors: $1$ and itself. Examples include $2$, $3$, $5$, $7$, and $11$.

A **composite number** is an integer greater than $1$ with more than two positive factors. For example, $12$ has factors besides $1$ and $12$. The number $1$ is neither prime nor composite.

### Prime Powers

**Prime factorization** means writing an integer greater than $1$ as a product of prime numbers. Divide by a prime factor, then factor the result. Keep going until every factor is prime.

An **exponent** tells how many times to use a number as a factor. In $2^3$, the base is $2$ and the exponent is $3$.

$$2^3=2\times2\times2=8$$

A **prime power** has a prime number as its base. Powers let you write repeated prime factors in a shorter form.

### GCF and LCM

**GCF** stands for greatest common factor. For positive integers, it is the greatest positive integer that divides all the given numbers.

**LCM** stands for least common multiple. For positive integers, it is the least positive integer that is a multiple of all the given numbers.

To find the GCF, factor each number into primes. Keep only primes shared by every number. Use the smallest exponent for each shared prime, then multiply.

The smallest exponent gives the number of copies that all the numbers contain. If no prime is shared by every number, the GCF is $1$.

To find the LCM, use every prime that appears in any factorization. Use the largest exponent for each prime, then multiply. This gives enough copies of each prime for every given number to divide the result.

For two positive integers $a$ and $b$, you can also use:

$$\text{GCF}\times\text{LCM}=a\times b$$

This product rule applies to two numbers. Do not apply it to a group of three or more numbers.

### Choosing the Method

Use the GCF for the greatest possible number of identical groups with nothing left over. Each group must receive the same amount of each item. The GCF can also give the greatest equal piece size when cutting lengths with no waste.

Use the LCM when events repeat at fixed intervals and you need their next shared time. This assumes the events start together and keep the stated intervals.

### Same-Remainder Problems

A **remainder** is the amount left after division into whole groups. In division by a positive integer, the remainder is at least $0$ and less than the divisor.

If a number leaves the same remainder $r$ for several divisors, subtract $r$. The result must be divisible by every divisor.

Let $L$ be the LCM of the divisors. All numbers with that common remainder have the form:

$$N=Lk+r$$

Here, $k$ is an integer. For positive divisors and a valid nonnegative remainder, use $k=0,1,2,\ldots$ to list the nonnegative answers. The dots mean the list continues.

Check any size condition in the question. The value $k=0$ gives $N=r$, so adding the remainder to the LCM is not always the smallest allowed answer.

## Examples

### #1: Basic Prime Factorization

Which of the following represents the prime factorization of $360$?

- A. $2^2\times3^2\times5$
- B. $2^3\times3^2\times5$
- C. $2^3\times3^3\times5$
- D. $2^2\times3^3\times5$

**Solution:**

1. Divide repeatedly by $2$ while the result is even.

$$360=2\times180$$

$$180=2\times90$$

$$90=2\times45$$

2. Factor the remaining $45$.

$$45=3\times15$$

$$15=3\times5$$

3. Count the repeated primes. There are $3$ factors of $2$, $2$ factors of $3$, and $1$ factor of $5$.

$$360=2^3\times3^2\times5$$

4. The correct answer is B.

### #2: Equal Groups Word Problem

A relief team has $84$ cans of sardines, $126$ packs of noodles, and $210$ kilograms of rice. It will divide all supplies among the greatest possible number of identical relief bags. Each bag must contain whole cans, whole packs, and a whole number of kilograms of rice. How many bags can it make?

**Solution:**

1. The number of bags must divide each quantity exactly. Find the GCF using prime factorizations.

$$84=2^2\times3\times7$$

$$126=2\times3^2\times7$$

$$210=2\times3\times5\times7$$

2. The shared primes are $2$, $3$, and $7$. Each has a smallest exponent of $1$.

$$\text{GCF}=2\times3\times7=42$$

3. Check the amount in each bag.

$$84\div42=2\text{ cans}$$

$$126\div42=3\text{ packs}$$

$$210\div42=5\text{ kilograms}$$

4. The team can make $42$ identical bags with nothing left over.

### #3: Repeating Schedule Word Problem

Three campus shuttles depart together at $7{:}00$ am. They continue to depart at fixed intervals: Shuttle A every $15$ minutes, Shuttle B every $20$ minutes, and Shuttle C every $25$ minutes. At what time will all three next depart together?

**Solution:**

1. Find the LCM of the intervals.

$$15=3\times5$$

$$20=2^2\times5$$

$$25=5^2$$

2. Use each prime with its largest exponent.

$$\text{LCM}=2^2\times3\times5^2$$

$$\text{LCM}=300\text{ minutes}$$

3. There are $60$ minutes in an hour. Convert the time.

$$300\div60=5\text{ hours}$$

4. Add $5$ hours to $7{:}00$ am. The next shared departure is at $12{:}00$ pm.

### #4: Same Remainder Problem

What is the smallest integer greater than $10$ that leaves a remainder of $3$ when divided by $6$, $8$, and $10$?

**Solution:**

1. The remainder $3$ is less than every divisor. Subtracting $3$ from the unknown number must leave a common multiple of the divisors.
2. Factor the divisors.

$$6=2\times3$$

$$8=2^3$$

$$10=2\times5$$

3. Find the LCM with the largest prime exponents.

$$\text{LCM}=2^3\times3\times5$$

$$\text{LCM}=120$$

4. Use the form $N=Lk+r$.

$$N=120k+3$$

5. The value $k=0$ gives $3$, which is not greater than $10$. The next value, $k=1$, gives:

$$N=120+3=123$$

6. Check the remainders.

$$123=6\times20+3$$

$$123=8\times15+3$$

$$123=10\times12+3$$

7. The smallest allowed number is $123$.

### #5: Using the Product Rule

Two positive integers are $18$ and $24$. Their GCF is $6$. What is their LCM?

**Solution:**

1. Use the product rule for two positive integers.

$$6\times\text{LCM}=18\times24$$

2. Divide by the GCF.

$$\text{LCM}=\dfrac{18\times24}{6}$$

$$\text{LCM}=72$$

## Speed Tricks & Shortcuts

### Compare Prime Powers

Write each number's prime factors in the same order. This makes shared primes and different exponents easier to compare.

A common division shortcut uses only primes that divide every number in a row. For $3$ or more numbers, multiplying those primes and the final row can give the wrong LCM.

For example, $6$, $10$, and $15$ share no prime across all three numbers. Multiplying the unchanged row gives $900$. Their LCM is only $30$ because each number divides $30$ exactly.

### Use a Known GCF

For two positive integers, divide their product by the known GCF to find the LCM. Example #5 uses this shortcut. Keep prime factorization as your method for larger groups.

### List Small Multiples

Listing multiples can be quick for small numbers. The positive multiples of $4$ begin $4$, $8$, $12$. Those of $6$ begin $6$, $12$, $18$.

The first shared value is $12$, so their LCM is $12$. For larger numbers, comparing prime powers often takes fewer steps.

## Traps to Watch For

### #1: Thinking $1$ Is Prime

> A prime number has exactly two positive factors.

The number $1$ has only one positive factor. Including it as a prime factor does not meet the definition of prime factorization.

### #2: Incomplete Factorization

> Stop only when every factor is prime.

The expression $12=4\times3$ is not a prime factorization because $4$ is composite. Continue with $4=2\times2$.

### #3: Confusing Smallest and Largest Exponents

> GCF uses the smallest shared exponents. LCM uses the largest exponents present.

The wrong exponent can make the GCF too large or the LCM too small. Check that the GCF divides every given number and that every given number divides the LCM.

### #4: Ignoring a Size Condition

> A same-remainder answer must also meet the stated limit.

The number $3$ leaves remainder $3$ when divided by $6$, $8$, or $10$. It still fails Example #4 because that question requires a number greater than $10$.
