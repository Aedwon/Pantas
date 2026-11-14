---
_id: "lesson-arithmetic-number-sense-least-common-multiple"
title: "Least Common Multiple"
summary: "Find common multiples for repeating events."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 4
ordering: 13
keyPoints:
  - "Find the LCM with the largest prime exponents."
  - "Use the LCM for repeating schedules."
  - "Use the GCF and LCM product rule for two numbers."
---
## Core Concept

### GCF and LCM

**LCM** stands for least common multiple. For positive integers, it is the least positive integer that is a multiple of all the given numbers.

To find the LCM, use every prime that appears in any factorization. Use the largest exponent for each prime, then multiply. This gives enough copies of each prime for every given number to divide the result.

For two positive integers $a$ and $b$, you can also use:

$$\text{GCF}\times\text{LCM}=a\times b$$

This product rule applies to two numbers. Do not apply it to a group of three or more numbers.

### Choosing the Method

Use the LCM when events repeat at fixed intervals and you need their next shared time. This assumes the events start together and keep the stated intervals.

The original lesson's Example #5 is Example #2 here.

## Examples

### #1: Repeating Schedule Word Problem

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

### #2: Using the Product Rule

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

### #1: Confusing Smallest and Largest Exponents

> GCF uses the smallest shared exponents. LCM uses the largest exponents present.

The wrong exponent can make the GCF too large or the LCM too small. Check that the GCF divides every given number and that every given number divides the LCM.
