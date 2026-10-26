---
_id: "lesson-arithmetic-number-sense-divisibility-rules"
title: "Divisibility Rules"
summary: "Use digit tests and coprime factors to check divisibility without long division."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 12
isActive: true
---
## Core Concept

An integer is **divisible** by a nonzero integer when division leaves no remainder. A **factor** divides a number exactly. A **multiple** is the result of multiplying an integer by another integer.

Divisibility rules let you check digits instead of doing full division. For a negative integer, test its positive value. The sign does not change whether there is a remainder of $0$.

### Rules for $2$, $4$, and $8$

For $2$, check whether the last digit is even: $0$, $2$, $4$, $6$, or $8$.

To test divisibility by $4$, use the number formed by the last $2$ digits. If that number is divisible by $4$, the whole number is too.

The test for $8$ uses the number formed by the last $3$ digits. It must be divisible by $8$. If a number has fewer digits than a test needs, test the whole number.

### Rules for $3$ and $9$

Add the digits to test divisibility by $3$. If their sum is divisible by $3$, so is the original number.

For $9$, the digit sum must be divisible by $9$. You may add the digits of the sum again if that makes the test easier.

### Rules for $5$ and $10$

A last digit of $0$ or $5$ means the number is divisible by $5$.

Only numbers ending in $0$ are divisible by $10$.

### Rule for $6$

Divisibility by $6$ requires passing both the $2$ and $3$ tests. Passing just one test is not enough.

### Rule for $7$

Remove the last digit and double it. Subtract that doubled value from the number formed by the remaining digits.

The original number is divisible by $7$ exactly when the result is divisible by $7$. You may repeat the test. A result of $0$ or a negative multiple of $7$ also passes.

### Rule for $11$

Add the digits in alternating positions into two groups. Find the difference between the two totals.

If the difference is $0$ or a multiple of $11$, the original number is divisible by $11$. Either subtraction order works.

### Combining Coprime Factors

Two positive integers are **relatively prime**, or **coprime**, when their only common positive factor is $1$.

If $a$ and $b$ are coprime, a number is divisible by $ab$ exactly when it is divisible by both $a$ and $b$. Here, $ab$ means $a\times b$.

For example, $8$ and $9$ have no common factor greater than $1$. Since $8\times9=72$, passing both tests proves divisibility by $72$.

The factors need not be prime numbers themselves. But they must be coprime for this product test to work. Shared factors can make the two tests check some of the same factors twice.

## Mnemonics & Memory Aids

For $2$, $4$, and $8$, check the end of the number: the last digit, the last $2$ digits, then the last $3$ digits.

For $3$ and $9$, add the digits and test the sum.

## Examples

### #1: Last-Digit Tests

Which of $735$ and $740$ is divisible by $5$? Which is divisible by $10$?

**Solution:**

1. The last digits are $5$ and $0$. Both numbers are divisible by $5$.
2. Only $740$ ends in $0$. Only $740$ is divisible by $10$.

### #2: Testing the Last Two Digits

Is $5,116$ divisible by $4$?

**Solution:**

1. Test the number formed by the last $2$ digits.

$$16\div4=4$$

2. The division is exact, so $5,116$ is divisible by $4$.

### #3: Testing for $7$

Is $203$ divisible by $7$?

**Solution:**

1. Double the last digit.

$$2\times3=6$$

2. Subtract from the remaining number.

$$20-6=14$$

3. Check whether the result is a multiple of $7$.

$$14=7\times2$$

4. The result passes, so $203$ is divisible by $7$.

### #4: Finding a Missing Digit

If the five-digit number $57x81$ is divisible by $9$, what is the value of the digit $x$?

**Solution:**

1. Add the digits.

$$5+7+x+8+1=21+x$$

2. A digit ranges from $0$ to $9$, so the sum ranges from $21$ to $30$. The only multiple of $9$ in that range is $27$.

$$21+x=27$$

3. Subtract $21$.

$$x=6$$

### #5: Composite Divisibility

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

### #6: A Zero Difference for $11$

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

### #7: Combining Divisibility Tests

The five-digit number $5X34Y$ is a multiple of $72$. Find $X+Y$.

**Solution:**

1. Since $72=8\times9$ and the factors are coprime, test divisibility by both $8$ and $9$.
2. The last $3$ digits range from $340$ to $349$. The only multiple of $8$ in that range is $344$.

$$344\div8=43$$

3. Thus $Y=4$. Apply the rule for $9$ to $5X344$.

$$5+X+3+4+4=16+X$$

4. The only multiple of $9$ from $16$ through $25$ is $18$.

$$16+X=18$$

$$X=2$$

5. Add the two digits.

$$X+Y=2+4=6$$

## Speed Tricks & Shortcuts

### Cast Out Nines

When testing divisibility by $3$ or $9$, you may skip groups of digits whose sum is a multiple of $9$. Each skipped group adds a multiple of both $3$ and $9$ to the total. Removing it does not change whether the digit sum passes either test.

For $945,712$, skip $9$, then $4+5$, then $7+2$. Only $1$ remains.

Since $1$ is divisible by neither $3$ nor $9$, the original number passes neither test.

### Coprime Split

Look for coprime factors with easy tests. To test divisibility by $36$, test $4$ and $9$ because $4\times9=36$ and they are coprime.

## Traps to Watch For

### #1: Splitting a Divisor Incorrectly

> Shared factors can make a product test fail.

The number $12$ is divisible by both $4$ and $6$, but not by $24$. To test $24$, use the coprime factors $3$ and $8$.

### #2: Forgetting Zero

> Every nonzero integer divides $0$, but division by $0$ is undefined.

A difference of $0$ passes the test for $11$. Rejecting that difference would give the wrong missing digit in Example #6.

### #3: Adding the Last Two Digits

> For $4$, use the number formed by the last $2$ digits.

For $5,116$, test $16$, not $1+6=7$. Adding those digits would wrongly reject the number.
