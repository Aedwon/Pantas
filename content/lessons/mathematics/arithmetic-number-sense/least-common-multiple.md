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

### Finding the LCM with Prime Powers

**LCM** stands for least common multiple. For positive integers, it is the smallest positive integer that is a multiple of every given number.

To find the LCM from prime factorizations:

1. Include **every** prime that appears in any of the numbers.
2. Pick the **largest** exponent for each prime.
3. Multiply those prime powers together.

Try finding the LCM of $24$ and $36$:

$$24=2^3\times 3^1$$

$$36=2^2\times 3^2$$

Both $2$ and $3$ appear. For $2$, the largest exponent is $3$. For $3$, the largest exponent is $2$.

$$\text{LCM}=2^3\times 3^2=8\times 9=72$$

:::why
Why does the LCM need the largest exponent of every prime? Every given number must divide the LCM cleanly. Using $2^3$ supplies enough $2$s for $24$, and using $3^2$ supplies enough $3$s for $36$.
:::

:::pair #lcm-product-trap
Right: the LCM of $24$ and $36$ is $2^3\times 3^2=72$
Wrong: the LCM of $24$ and $36$ is $24\times 36=864$
Multiplying the two numbers repeats their shared factors. You get a common multiple, not the smallest common multiple.
:::

:::pair #lcm-gcf-swap
Right: the LCM of $24$ and $36$ is $72$
Wrong: the LCM of $24$ and $36$ is $12$
The wrong line used the smaller exponents, which gives the GCF ($12$), not the LCM. Check that every original number divides your LCM.
:::

:::check
Find the LCM of $12=2^2\times 3$ and $18=2\times 3^2$.
:::answer
The answer is $36$. Use the largest power of each prime: $2^2\times 3^2=4\times 9=36$.
:::

### Repeating Schedules

Use the LCM when events start together and repeat at fixed intervals, and you need their next shared time.

<!-- FIGURE WANTED: two parallel timelines from 0 to 60 minutes; top bar marks 15, 30, 45, 60; bottom bar marks 20, 40, 60; vertical teal dashed line at 60 labeled "LCM = 60 min" -->

For example, if one jeepney returns every $15$ minutes and another every $20$ minutes, they next meet at the LCM of $15$ and $20$, which is $60$ minutes. Check the time window carefully to see whether the starting time counts.

:::check
Two bells ring together at $8{:}00$ AM. One rings every $10$ minutes and the other every $15$ minutes. When do they next ring together?
:::answer
The answer is $8{:}30$ AM. Since $10=2\times 5$ and $15=3\times 5$, their LCM is $2\times 3\times 5=30$ minutes.
:::

### The Product Rule for Two Numbers

For any two positive integers $a$ and $b$, their GCF and LCM satisfy:

$$\text{GCF}\times\text{LCM}=a\times b$$

This rule works for **two** numbers only. Do not apply it to three or more numbers.

Suppose two numbers have GCF $6$ and LCM $72$, and one number is $18$. Let $b$ be the other number.

$$6\times 72=18\times b$$

$$b=\dfrac{6\times 72}{18}=\dfrac{432}{18}=24$$

:::pair #product-rule-missing
Right: if GCF $=14$, LCM $=420$, and one number is $70$, the other is $\dfrac{14\times 420}{70}=84$
Wrong: if GCF $=14$, LCM $=420$, and one number is $70$, the other is $\dfrac{420}{70}=6$
Dividing the LCM by $70$ drops the GCF ($14$). Remember that the product of both numbers equals $\text{GCF}\times\text{LCM}$, not LCM alone.
:::

:::check
Two numbers have GCF $5$ and LCM $60$. If one number is $15$, what is the other number?
:::answer
The answer is $20$. Multiply $\text{GCF}\times\text{LCM}=5\times 60=300$, then divide $300\div 15=20$.
:::

## Examples

### #1: Repeating Schedule Word Problem

Three campus shuttles depart together at $7{:}00$ AM. They continue to depart at fixed intervals: Shuttle A every $15$ minutes, Shuttle B every $20$ minutes, and Shuttle C every $25$ minutes. At what time will all three next depart together?

**Solution:**

1. Find the LCM of the three intervals. Factor each into primes.

$$15=3\times 5$$

$$20=2^2\times 5$$

$$25=5^2$$

2. Multiply every prime with its largest exponent.

$$\text{LCM}=2^2\times 3\times 5^2=4\times 3\times 25=300\text{ minutes}$$

3. Convert minutes to hours by dividing by $60$.

$$300\div 60=5\text{ hours}$$

4. Add $5$ hours to $7{:}00$ AM.

The next shared departure is at $12{:}00$ PM.

**Check:** In $300$ minutes, Shuttle A makes $300\div 15=20$ trips, Shuttle B makes $300\div 20=15$ trips, and Shuttle C makes $300\div 25=12$ trips. Since $20, 15,$ and $12$ share no factor greater than $1$, $12{:}00$ PM is the first return together.

### #2: Using the Product Rule

Two positive integers are $16$ and $20$, and their GCF is $4$. What is their LCM?

**Solution:**

1. Use the product rule for two positive integers.

$$4\times\text{LCM}=16\times 20$$

2. Divide both sides by $4$ to isolate the LCM.

$$\text{LCM}=\dfrac{16\times 20}{4}=4\times 20$$

:::try
Finish the last step: multiply $4\times 20$ to find the LCM.
:::answer
The answer is $80$. Multiply $4\times 20=80$.

**Check:** Factor both numbers: $16=2^4$ and $20=2^2\times 5$. Taking the largest prime powers gives $2^4\times 5=16\times 5=80$, which matches.
:::

## Speed Tricks & Shortcuts

For small numbers, list multiples of the largest number until the others divide one evenly. For $4$ and $6$, check $6$, then $12$: since $4$ divides $12$, the LCM is $12$.

When finding the LCM of $3$ or more numbers, watch for shared primes even when no single prime divides every number. For $6, 10,$ and $15$, no prime divides all three, yet $6=2\times 3$, $10=2\times 5$, and $15=3\times 5$ share primes in pairs. Taking the largest power of each prime gives $2\times 3\times 5=30$, whereas multiplying $6\times 10\times 15=900$ repeats every shared prime.

## Traps to Watch For

:::checklist
- Multiplying the given numbers to find the LCM: use the largest exponent of each prime instead, so $24$ and $36$ give $72$, not $864$. {#lcm-product-trap}
- Confusing smallest and largest exponents: GCF uses smaller shared powers ($12$), while LCM uses largest powers ($72$). {#lcm-gcf-swap}
- Finding a missing number from GCF and LCM: multiply GCF times LCM before dividing by the known number. {#product-rule-missing}
:::
