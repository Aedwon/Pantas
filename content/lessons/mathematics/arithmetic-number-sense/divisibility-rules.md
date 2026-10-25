---
_id: "lesson-arithmetic-number-sense-divisibility-rules"
title: "Divisibility Rules"
summary: "Use divisibility rules to test integers quickly without full long division."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 10
isActive: true
---
## Core Concept

An integer is **divisible** by a nonzero integer when division leaves no remainder. Divisibility rules let you test many numbers by checking only some digits or by combining digits in a simple way.

### Rules for $2$, $4$, and $8$

A number is divisible by $2$ when its last digit is even: $0$, $2$, $4$, $6$, or $8$.

A number is divisible by $4$ when the number formed by its last $2$ digits is divisible by $4$.

A number is divisible by $8$ when the number formed by its last $3$ digits is divisible by $8$.

### Rules for $3$ and $9$

A number is divisible by $3$ when the sum of its digits is divisible by $3$.

A number is divisible by $9$ when the sum of its digits is divisible by $9$.

### Rules for $5$ and $10$

A number is divisible by $5$ when its last digit is $0$ or $5$.

A number is divisible by $10$ when its last digit is $0$.

### Rule for $6$

A number is divisible by $6$ when it is divisible by both $2$ and $3$.

### Rule for $7$

Remove the last digit and double it. Subtract that doubled value from the remaining leading digits.

The original number is divisible by $7$ exactly when the result is divisible by $7$. You may repeat the process until the result is easy to test.

For $203$, remove $3$ and double it to get $6$.

$$20-6=14$$

Since $14$ is divisible by $7$, $203$ is also divisible by $7$.

### Rule for $11$

Add the digits in alternating positions into two groups. Subtract the smaller total from the larger total, or take the difference in either order.

If the difference is $0$ or a multiple of $11$, the original number is divisible by $11$.

### Combining Coprime Factors

Two integers are **relatively prime**, also called **coprime**, when their only common positive factor is $1$.

If $a$ and $b$ are relatively prime, then a number is divisible by $ab$ exactly when it is divisible by both $a$ and $b$.

For example, $8$ and $9$ are relatively prime. A number is divisible by $72$ exactly when it is divisible by both $8$ and $9$ because:

$$8\times9=72$$

This split does not work in the same way when the chosen factors share a common factor.

## Mnemonics & Memory Aids

For $2$, $4$, and $8$, remember that the test stays at the end of the number. Check the last digit, then the last $2$ digits, then the last $3$ digits.

For $3$ and $9$, add the digits. Then test the sum.

## Examples

### #1: Finding a Missing Digit

If the five-digit number $57x81$ is divisible by $9$, what is the value of the digit $x$?

**Solution:**

1. Use the rule for $9$. Add the digits.

$$5+7+x+8+1=21+x$$

2. Since $x$ is a digit from $0$ to $9$, the sum ranges from $21$ to $30$.
3. The only multiple of $9$ in that range is $27$.

$$21+x=27$$

4. Solve for $x$.

$$x=6$$

### #2: Composite Divisibility

A shipping company packs exactly $6$ books per box. Which inventory count can be packed with no books left over?

* A) $24,532$
* B) $24,534$
* C) $24,536$
* D) $24,538$

**Solution:**

1. A number divisible by $6$ must be divisible by both $2$ and $3$.
2. All four choices are even, so each choice passes the rule for $2$.
3. Check the digit sums.

$$2+4+5+3+2=16$$

$$2+4+5+3+4=18$$

$$2+4+5+3+6=20$$

$$2+4+5+3+8=22$$

4. Only $18$ is divisible by $3$. The answer is B.

### #3: Rule of $11$ Edge Case

The six-digit number $3a42b1$ is divisible by $11$. If $a=5$, what is the value of $b$?

**Solution:**

1. Substitute $a=5$. The number is $3542b1$.
2. Add alternating digits.

$$3+4+b=7+b$$

$$5+2+1=8$$

3. Find the difference.

$$(7+b)-8=b-1$$

4. Since $b$ is a digit, $b-1$ ranges from $-1$ to $8$. The only multiple of $11$ in that range is $0$.

$$b-1=0$$

5. Solve for $b$.

$$b=1$$

### #4: Combining Divisibility Tests

The five-digit number $5X34Y$ is a multiple of $72$. Find $X+Y$.

**Solution:**

1. Since $72=8\times9$ and $8$ and $9$ are relatively prime, the number must be divisible by both $8$ and $9$.
2. Test the last three digits for divisibility by $8$. The only value of $Y$ that makes $34Y$ divisible by $8$ is $4$.

$$344\div8=43$$

3. The number is now $5X344$. Apply the rule for $9$.

$$5+X+3+4+4=16+X$$

4. The only multiple of $9$ from $16$ through $25$ is $18$.

$$16+X=18$$

$$X=2$$

5. Add the digits found.

$$X+Y=2+4=6$$

## Speed Tricks & Shortcuts

### Cast Out Nines

When testing divisibility by $3$ or $9$, you can remove groups of digits whose sum is a multiple of $9$. This keeps the same result for the divisibility test.

For $945,712$, remove $9$, then $4+5$, then $7+2$. Only $1$ remains.

Since $1$ is not divisible by $3$ or $9$, the original number is divisible by neither $3$ nor $9$.

### Coprime Split

For a large composite divisor, look for relatively prime factors with easy divisibility rules.

To test divisibility by $36$, you may test divisibility by $4$ and $9$ because:

$$4\times9=36$$

The factors $4$ and $9$ are relatively prime.

## Traps to Watch For

### #1: Splitting a Composite Divisor Incorrectly

> Two tests are not enough if the chosen factors share a common factor.

Divisibility by both $4$ and $6$ does not by itself prove divisibility by $24$. Testing $3$ and $8$ works because those factors are relatively prime and their product is $24$.

### #2: Forgetting the Zero Exception

> Every nonzero integer divides $0$, but division by $0$ is undefined.

For the rule of $11$, a difference of $0$ passes the test because $0$ is a multiple of $11$.

### #3: Rule of $4$ Addition Mistake

> Do not add the last two digits for the rule of $4$.

For $5,116$, look at $16$. Since $16$ is divisible by $4$, $5,116$ is also divisible by $4$.
