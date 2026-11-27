---
_id: "lesson-arithmetic-number-sense-divisibility-by-seven-and-eleven"
title: "Divisibility by Seven and Eleven"
summary: "Use double-and-subtract for 7 and alternating digit sums for 11."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 4
ordering: 26
keyPoints:
  - "Use the double-and-subtract test for 7."
  - "Use alternating digit sums for 11, including zero differences."
---
## Core Concept

### Rule for $7$

To test if a number is divisible by $7$:

1. Remove the last digit.
2. Double that removed digit.
3. Subtract the doubled amount from the number made by the remaining digits.
4. Check if the result is $0$ or a multiple of $7$ (positive or negative, such as $-7$ or $-14$).

If the result is still large, repeat the three steps on the new number.

Test $343$ for $7$. Remove the last digit $3$, leaving $34$. Double $3$ to get $6$, then subtract from $34$.

$$34-6=28$$

Since $28=7\times4$, $343$ is divisible by $7$.

:::pair #subtract-without-doubling
Right: for $343$, double $3$ first: $34-2(3)=34-6=28$
Wrong: for $343$, subtract $3$ directly: $34-3=31$
Multiply the removed last digit by $2$ before you subtract.
:::

Subtract from the digits *without* the last digit ($34-6=28$), not from the full original number ($343-6=337$).

:::why
Write the original number as $10a+b$, where $b$ is the last digit, so $10(a-2b)=10a-20b=(10a+b)-21b$. Since $21b$ is a multiple of $7$, $10a+b$ is divisible by $7$ whenever $a-2b$ is. In reverse, if $10a+b$ is divisible by $7$, then $10(a-2b)$ is too, and because $10$ has no factor of $7$, $a-2b$ must also be divisible by $7$.
:::

:::check
Use the rule for $7$ twice on $1,386$. Is $1,386$ divisible by $7$?
:::answer
The answer is yes. First, $138-2(6)=126$. Then $12-2(6)=0$, and $0$ is a multiple of $7$.
:::

### Rule for $11$

To test if a number is divisible by $11$, split the digits into two alternating groups (the first, third, fifth, and so on in one group; the second, fourth, sixth, and so on in the other).

1. Add the digits in each alternating group.
2. Subtract one group total from the other (either order works).
3. If the difference is $0$ or a multiple of $11$ (such as $11$, $-11$, or $22$), the number is divisible by $11$.

:::pair #total-sum-for-eleven
Right: for $1,221$, use alternating positions: $(1+2)-(2+1)=0$, so it passes $11$
Wrong: for $1,221$, add all digits: $1+2+2+1=6$, so it fails $11$
Total digit sums test $3$ and $9$, not $11$. Skip every other digit so odd positions ($1,3,5,\dots$) go in one group and even positions ($2,4,6,\dots$) go in the other.
:::

Test $2,728$ for $11$. Add the digits in the odd positions, then in the even positions.

$$2+2=4$$

$$7+8=15$$

Subtract the two totals.

$$4-15=-11$$

Since $-11$ is a multiple of $11$, $2,728$ passes.

<!-- ILLUSTRATION: Four digit boxes in a row for the number 2,728: 2, 7, 2, 8. An accent arc above the boxes links the 1st and 3rd digits (2 and 2) and is labeled "odd positions: 2 + 2 = 4". A gray arc below the boxes links the 2nd and 4th digits (7 and 8) and is labeled "even positions: 7 + 8 = 15". Under both, the difference is 4 - 15 = -11. -->

A difference of $0$ also passes, because $0$ is divisible by every nonzero integer.

:::pair #zero-is-divisible
Right: $0\div11=0$, so a difference of $0$ passes the test for $11$
Wrong: $0$ cannot be divided by $11$, so a difference of $0$ fails
Every nonzero integer divides $0$ evenly. Only dividing *by* $0$ is undefined.
:::

:::why
Why do the signs alternate? Each place value is a multiple of $11$ plus or minus $1$: $10=11-1$, $100=99+1$, and $1,000=1,001-1$. So a tens digit counts with a minus sign, a hundreds digit with a plus sign, and so on. The number differs from its alternating sum by a multiple of $11$. For example, $1,331$ has alternating sums $1+3=4$ and $3+1=4$, difference $4-4=0$, and $1,331=11\times121$.
:::

## Examples

### #1: Repeating the Test for $7$

Test $2,541$ for $7$, repeating the rule until the result is small.

**Solution:**

1. Remove the last digit $1$ from $2,541$ and double it.

$$2\times1=2$$

2. Subtract $2$ from the remaining digits, $254$.

$$254-2=252$$

3. Repeat on $252$. Remove the last digit $2$ and double it.

$$2\times2=4$$

4. Subtract $4$ from the remaining digits, $25$.

$$25-4=21$$

5. Check whether $21$ is a multiple of $7$.

$$21=7\times3$$

Yes, $2,541$ is divisible by $7$.

### #2: A Zero Difference for $11$

The six-digit number $3a42b1$ is divisible by $11$. If $a=5$, what is the value of $b$?

**Solution:**

1. Replace $a$ with $5$. The number is $3542b1$.
2. Add the digits in the odd positions ($3+4+b$) and in the even positions ($5+2+1$).

$$3+4+b=7+b$$

$$5+2+1=8$$

3. Subtract the second total from the first total. Since $b$ is a digit from $0$ to $9$, the difference goes from $-1$ to $8$. The only multiple of $11$ in that range is $0$.

$$(7+b)-8=b-1=0$$

:::try
Finish the last step: find $b$, then write the six-digit number.
:::answer
The answer is $354,211$, with $b=1$. Adding $1$ to both sides of $b-1=0$ gives $b=1$.
:::

## Traps to Watch For

:::checklist
- Testing for $7$: remove the last digit, double it, then subtract from the remaining digits. {#subtract-without-doubling}
- Testing for $11$: add digits in alternating positions, not all the digits together. {#total-sum-for-eleven}
- Getting a difference of $0$: count $0$ as passing, because $0$ is divisible by every nonzero integer. {#zero-is-divisible}
:::
