---
_id: "lesson-arithmetic-number-sense-divisibility-rules"
title: "Divisibility Rules"
summary: "Learn how to quickly check whether an integer is divisible by another integer without doing full long division."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 8
isActive: true
---
## Core Concept

An integer is **divisible** by a nonzero integer if the quotient is an integer, so there is no remainder.

Divisibility rules let you test many numbers by examining only some digits or by combining their digits in a specific way.

## Mnemonics & Memory Aids

### Group $2, 4, 8$

> "For $2, 4,$ and $8$, just look at the gate."

The "gate" means the last digits of the number.

* **Rule for $2$:** The last digit must be even ($0, 2, 4, 6, 8$).
* **Rule for $4$:** The number formed by the last $2$ digits must be divisible by $4$.
* **Rule for $8$:** The number formed by the last $3$ digits must be divisible by $8$.

### Group $3, 9$

> "For $3$ and $9$, sum the line."

* **Rule for $3$:** If the sum of the digits is divisible by $3$, the whole number is divisible by $3$.
* **Rule for $9$:** If the sum of the digits is divisible by $9$, the whole number is divisible by $9$.

### Group $5, 10$

* **Rule for $5$:** The last digit must be $5$ or $0$.
* **Rule for $10$:** The last digit must be $0$.

### For Number $6$

A number is divisible by $6$ when it is divisible by both $2$ and $3$.

### For Number $7$

Remove the last digit, double that digit, and subtract the doubled value from the remaining leading digits. The original number is divisible by $7$ exactly when the result is divisible by $7$. You can repeat the process until the result is easy to recognize.

For example, for $203$: remove $3$, double it to get $6$, and compute $20 - 6 = 14$. Since $14$ is divisible by $7$, so is $203$.

### For Number $11$

Add the digits in alternating positions into two groups, then subtract the two totals. If the difference is $0$ or a multiple of $11$, the original number is divisible by $11$.

## Examples

### #1: Finding a Missing Digit

If the five-digit number $57x81$ is divisible by $9$, what is the value of the digit $x$?

**Solution:**

1. Use the rule for $9$. Add the digits.

$$5 + 7 + x + 8 + 1 = 21 + x$$

2. Since $x$ is a digit from $0$ to $9$, $21+x$ ranges from $21$ to $30$.
3. The only multiple of $9$ in that range is $27$.

$$21 + x = 27$$

$$x = 6$$

### #2: Composite Divisibility

A shipping company packs exactly $6$ books per box. Which inventory count can be packed with no books left over?

* A) $24,532$
* B) $24,534$
* C) $24,536$
* D) $24,538$

**Solution:**

1. A number divisible by $6$ must be divisible by both $2$ and $3$.
2. All four choices are even, so all pass the rule for $2$.
3. Check the digit sums for divisibility by $3$.

* A) $2 + 4 + 5 + 3 + 2 = 16$
* B) $2 + 4 + 5 + 3 + 4 = 18$
* C) $2 + 4 + 5 + 3 + 6 = 20$
* D) $2 + 4 + 5 + 3 + 8 = 22$

4. Only $18$ is divisible by $3$, so the answer is B.

### #3: Rule of $11$ Edge Case

The six-digit number $3a42b1$ is divisible by $11$. If $a = 5$, what is the value of $b$?

**Solution:**

1. Substitute $a=5$. The number is $3542b1$.
2. Add alternating digits.

$$3 + 4 + b = 7 + b$$

$$5 + 2 + 1 = 8$$

3. Their difference is:

$$(7+b)-8=b-1$$

4. Because $b$ is a digit, $b-1$ ranges from $-1$ to $8$. The only multiple of $11$ in that range is $0$.

$$b-1=0$$

$$b=1$$

### #4: Combining Divisibility Tests

The five-digit number $5X34Y$ is a multiple of $72$. Find $X + Y$.

**Solution:**

1. Since $72 = 8 \times 9$ and $8$ and $9$ are relatively prime, the number must be divisible by both $8$ and $9$.
2. Use the rule for $8$ on the last three digits, $34Y$. Among the possible ending digits, $344$ is divisible by $8$, so $Y=4$.
3. The number is now $5X344$. Apply the rule for $9$:

$$5 + X + 3 + 4 + 4 = 16 + X$$

4. The only multiple of $9$ from $16$ through $25$ is $18$.

$$16 + X = 18$$

$$X = 2$$

5. Therefore:

$$X+Y=2+4=6$$

## Speed Tricks & Shortcuts

**Cast Out Nines.**
When checking divisibility by $3$ or $9$, you can ignore any group of digits whose sum is a multiple of $9$ because removing such a group does not change the digit sum modulo $9$.

For $945,712$, remove $9$, then $4+5$, then $7+2$. Only $1$ remains, so the original digit sum is congruent to $1$ modulo $9$ and the number is divisible by neither $3$ nor $9$.

**Relatively Prime Split.**
If $a$ and $b$ are relatively prime, then an integer is divisible by $ab$ exactly when it is divisible by both $a$ and $b$. For example, to test divisibility by $36$, test divisibility by $4$ and $9$.

## Traps to Watch For

### #1: Splitting a composite divisor incorrectly

Testing divisibility by two factors that share a common factor may not be enough to prove divisibility by their product. For example, divisibility by both $4$ and $6$ does not by itself guarantee divisibility by $24$. Testing $3$ and $8$ works because they are relatively prime and $3 \times 8 = 24$.

### #2: Forgetting the zero exception

> Every nonzero integer divides $0$, but division by $0$ is undefined.

For the rule of $11$, a difference of $0$ passes the test because $0$ is a multiple of $11$.

### #3: Rule of $4$ addition mistake

> Do not add the last two digits for the rule of $4$.

For $5,116$, look at $16$. Since $16$ is divisible by $4$, so is $5,116$.
