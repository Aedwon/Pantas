---
_id: "lesson-arithmetic-number-sense-repeating-units-digits"
title: "Repeating Units Digits"
summary: "Use digit cycles to find the units digit of a power or sum."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 5
ordering: 0
keyPoints:
  - "Find the cycle of units digits, then use the exponent's remainder."
---
## Core Concept

### Repeating Units Digits

The **units digit** is the last digit of a whole number. A **power** means repeated multiplication: $7^3$ means $7\times7\times7$. The small raised number, called the **exponent**, tells how many copies to multiply.

The **base** is the number being repeatedly multiplied. In $7^3$, the base is $7$. For a whole-number base and a positive whole-number exponent, you can find the units digit without finding the whole power. Multiply the current units digit by the base, then keep just the new units digit. Digits to its left do not change that result.

A **cycle** is a group that repeats in the same order. Start with the first power and keep going until its units digit returns. From that point, the same multiplication gives the same following digits.

Divide the exponent by the cycle length. The **remainder** is what is left after making complete groups. A nonzero remainder gives the position in the cycle; a remainder of $0$ means use the last position.

This method starts at exponent $1$. For a nonzero base raised to exponent $0$, the value is $1$ instead.

The units digit of a sum depends only on the units digits of the numbers added.

For example, $27+38=65$: add $7+8=15$ and keep the last digit, $5$.

## Examples

### #1: The Last Digit of a Power

What is the units digit of $7^{46}$? What about $7^{48}$?

**Solution:**

1. Build the cycle from the first power. Keep only the units digit after each multiplication.

$7^1=7$

$7\times7=49$

$9\times7=63$

$3\times7=21$

$1\times7=7$

2. The units digits repeat as $7,9,3,1$. The cycle length is $4$.

3. Divide the first exponent by $4$.

$46=4\times11+2$

4. The remainder is $2$. Use the second digit in the cycle. The units digit of $7^{46}$ is $9$.

5. Check the other exponent.

$48=4\times12+0$

The remainder is $0$, so use the fourth digit. The units digit of $7^{48}$ is $1$.

## Speed Tricks & Shortcuts

### Keep Just the Last Digit

When finding a power's units digit, discard the other digits after each multiplication. If the base ends in $0$, $1$, $5$, or $6$, its positive whole-number powers keep that same last digit. Multiplying that last digit by itself confirms the repeating step.

## Traps to Watch For

### #1: A Zero Remainder

> A remainder of $0$ means the last position in the cycle.

It does not mean the units digit is $0$. In the power example, a complete cycle ends at $1$.
