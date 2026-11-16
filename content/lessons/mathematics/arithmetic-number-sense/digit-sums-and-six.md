---
_id: "lesson-arithmetic-number-sense-digit-sums-and-six"
title: "Digit Sums and Six"
summary: "Use digit sums to test divisibility."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 2
partCount: 4
ordering: 25
keyPoints:
  - "Use digit sums to test 3 and 9."
  - "Combine the 2 and 3 tests to test 6."
---
## Core Concept

### Rules for $3$ and $9$

Add the digits to test divisibility by $3$. If their sum is divisible by $3$, so is the original number.

For $9$, the digit sum must be divisible by $9$. You may add the digits of the sum again if that makes the test easier.

### Rule for $6$

Divisibility by $6$ requires passing both the $2$ and $3$ tests. Passing just one test is not enough.

## Mnemonics & Memory Aids

For $3$ and $9$, add the digits and test the sum.

## Examples

### #1: Finding a Missing Digit

If the five-digit number $57x81$ is divisible by $9$, what is the value of the digit $x$?

**Solution:**

1. Add the digits.

$$5+7+x+8+1=21+x$$

2. A digit ranges from $0$ to $9$, so the sum ranges from $21$ to $30$. The only multiple of $9$ in that range is $27$.

$$21+x=27$$

3. Subtract $21$.

$$x=6$$

### #2: Composite Divisibility

A shipping company packs exactly $6$ books per box. Which inventory count can be packed with no books left over?

- A) $24,532$
- B) $24,534$
- C) $24,536$
- D) $24,538$

**Solution:**

1. A number divisible by $6$ must pass the tests for $2$ and $3$. All four choices are even, so each passes the test for $2$.
2. Check the digit sums in choice order.

$$2+4+5+3+2=16$$

$$2+4+5+3+4=18$$

$$2+4+5+3+6=20$$

$$2+4+5+3+8=22$$

3. Only $18$ is divisible by $3$. The answer is B, $24,534$.

## Speed Tricks & Shortcuts

### Cast Out Nines

When testing divisibility by $3$ or $9$, you may skip groups of digits whose sum is a multiple of $9$. Each skipped group adds a multiple of both $3$ and $9$ to the total. Removing it does not change whether the digit sum passes either test.

For $945,712$, skip $9$, then $4+5$, then $7+2$. Only $1$ remains.

Since $1$ is divisible by neither $3$ nor $9$, the original number passes neither test.
