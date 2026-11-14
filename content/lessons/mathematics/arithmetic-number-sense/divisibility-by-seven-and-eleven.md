---
_id: "lesson-arithmetic-number-sense-divisibility-by-seven-and-eleven"
title: "Divisibility by Seven and Eleven"
summary: "Reduce a number to test divisibility by 7 or 11."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 4
ordering: 703
keyPoints:
  - "Use the double-and-subtract test for 7."
  - "Use alternating digit sums for 11, including zero differences."
---
## Core Concept

### Rule for $7$

Remove the last digit and double it. Subtract that doubled value from the number formed by the remaining digits.

The original number is divisible by $7$ exactly when the result is divisible by $7$. You may repeat the test. A result of $0$ or a negative multiple of $7$ also passes.

### Rule for $11$

Add the digits in alternating positions into two groups. Find the difference between the two totals.

If the difference is $0$ or a multiple of $11$, the original number is divisible by $11$. Either subtraction order works.

The original lesson's Example #6 is Example #2 here.

## Examples

### #1: Testing for $7$

Is $203$ divisible by $7$?

**Solution:**

1. Double the last digit.

$$2\times3=6$$

2. Subtract from the remaining number.

$$20-6=14$$

3. Check whether the result is a multiple of $7$.

$$14=7\times2$$

4. The result passes, so $203$ is divisible by $7$.

### #2: A Zero Difference for $11$

The six-digit number $3a42b1$ is divisible by $11$. If $a=5$, what is the value of $b$?

**Solution:**

1. Substitute $a=5$. The number is $3542b1$.
2. Add alternating digits.

$$3+4+b=7+b$$

$$5+2+1=8$$

3. Subtract the totals.

$$(7+b)-8=b-1$$

4. Since $b$ is a digit, $b-1$ ranges from $-1$ to $8$. Only $0$ in this range is a multiple of $11$.

$$b-1=0$$

$$b=1$$

## Traps to Watch For

### #1: Forgetting Zero

> Every nonzero integer divides $0$, but division by $0$ is undefined.

A difference of $0$ passes the test for $11$. Rejecting that difference would give the wrong missing digit in Example #6.
