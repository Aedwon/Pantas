---
_id: "lesson-arithmetic-number-sense-divisibility-rules"
title: "Divisibility Rules"
summary: "Learn how to quickly check if a large number can be divided perfectly by a smaller number without doing long division."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 8
isActive: true
---
## Core Concept

Divisibility means you can divide one number by another and get no remainder. The answer is a perfect whole number.

In college entrance exams, they will give you huge numbers. Doing long division by hand takes too much time. Time is your biggest enemy on these tests.

Divisibility rules are mathematical shortcuts. Instead of dividing, you just look at the digits or add them up. This lets you find the answer in seconds.

## Mnemonics & Memory Aids

Memorize these rules to save time on the exam. We group them by how they work.

### Group $2, 4, 8$

> "For $2, 4,$ and $8$, just look at the gate."

The "gate" means the last digits of the number. You only check the end.

* **Rule for $2$:** Check the last $1$ digit. It must be even ($0, 2, 4, 6, 8$).
* **Rule for $4$:** Check the last $2$ digits. They must form a number divisible by $4$ (like $12, 24,$ or $00$).
* **Rule for $8$:** Check the last $3$ digits. They must form a number divisible by $8$ (like $016$ or $800$).

### Group $3, 9$

> "For $3$ and $9$, sum the line."

You must add all the digits together.

* **Rule for $3$:** If the sum of the digits is divisible by $3$, the whole number is.
* **Rule for $9$:** If the sum of the digits is divisible by $9$, the whole number is.

### Group $5, 10$

Look at the very last digit.

* **Rule for $5$:** The last digit must be $5$ or $0$.
* **Rule for $10$:** The last digit must be exactly $0$.

### For Number $6$

> "Two and three hold the key."

If a number fails the test for 2 or fails the test for 3, it instantly fails for 6. Both keys must turn to open the lock.

### For Number $7$

Chop off the last digit. Double it. Subtract it from the rest of the number.

### For number $11$

This is the most common trick on the DOST and UPCAT exams.

* **Rule for $11$:** Add every alternating digit. Add the remaining digits. Subtract your two totals. If the answer is $0$ or a multiple of $11$, the number is divisible by $11$.

## Examples

### #1: Finding a Missing Digit

If the five-digit number $57,x81$ is completely divisible by $9$, what is the value of the digit $x$?

1. Use the rule for $9$. Add all the digits together.

$$5 + 7 + x + 8 + 1$$


$$21 + x$$


2. Think of the multiples of $9$. The multiples are $9, 18, 27, 36,$ and so on.
3. Our sum is already $21$. The next multiple of $9$ is $27$.
4. Find what you need to add to $21$ to get $27$.

$$21 + 6 = 27$$


5. The digit $x$ must be $6$.

### #2: Composite Divisibility

A shipping company packs exactly $6$ books per box. Which of the following total inventory counts indicates that there are no unboxed books remaining?

* A) $24,532$
* B) $24,534$
* C) $24,536$
* D) $24,538$

1. The problem asks which number is divisible by $6$.
2. The rule for $6$ is a combo. The number must pass the rule for $2$ AND the rule for $3$.
3. Check the rule for $2$. All choices end in an even number. They all pass.
4. Check the rule for $3$. Add the digits of each choice.

* A) $2 + 4 + 5 + 3 + 2 = 16$ (Not divisible by 3)
* B) $2 + 4 + 5 + 3 + 4 = 18$ (Divisible by 3)
* C) $2 + 4 + 5 + 3 + 6 = 20$ (Not divisible by 3)
* D) $2 + 4 + 5 + 3 + 8 = 22$ (Not divisible by 3)

5. Only option B passes both rules. The answer is B.

### #3: Rule of $11$ Edge Case

The six-digit number $3a42b1$ is exactly divisible by $11$. If $a = 5$, what is the value of $b$?

1. First, plug in the value of $a$. The number becomes $3542b1$.
2. Use the "Jumper" rule for $11$. Group the alternating digits.
3. Group $1$ gets the 1st, 3rd, and 5th digits from the left.

$$3 + 4 + b = 7 + b$$


4. Group $2$ gets the 2nd, 4th, and 6th digits from the left.

$$5 + 2 + 1 = 8$$


5. Subtract the two totals.

$$(7 + b) - 8$$


$$b - 1$$


6. For a number to be divisible by $11$, this final answer must be $0$ or a multiple of $11$.
7. Make the equation equal to 0 and solve.

$$b - 1 = 0$$


$$b = 1$$



### #4: Two-Variable Trap

The five-digit number $5X34Y$ is a multiple of $72$. Find the value of $X + Y$.

1. This is a classic UPCAT question. There is no standard rule for $72$. You must split it into two rules.
2. We split $72$ into $8 \times 9$. The number must be divisible by both $8$ and $9$.
3. Always start with the rule that looks at the tail. Use the rule for $8$ on the last three digits ($34Y$).
4. Test digits for $Y$ until $34Y$ divides perfectly by $8$.

$$340 \div 8 = 42.5$$


$$344 \div 8 = 43$$


5. The digit $Y$ must be $4$. Our number is now $5X344$.
6. Now use the rule for $9$. Add all the digits.

$$5 + X + 3 + 4 + 4 = 16 + X$$


7. The next multiple of $9$ after $16$ is $18$.

$$16 + X = 18$$


$$X = 2$$


8. The problem asks for the value of $X + Y$.

$$2 + 4 = 6$$



## Speed Tricks & Shortcuts

**Cast Out Nines.**
When checking the rule for $3$ or $9$, you do not have to add every single digit. You can just cross out any $9$s you see. You can also cross out any groups of digits that add up to $9$.

If you have the number $945,712$:
Cross out the $9$. Cross out $4$ and $5$ (they equal $9$). Cross out $7$ and $2$ (they equal $9$). You are only left with $1$. Since $1$ is not divisible by $3$ or $9$, the whole number is not.

**The Co-Prime Split.**
When you need to find the divisibility rule for a large number, split it into two smaller factors. These two factors must be **co-prime**. Co-prime means the two numbers share no common factors except the number $1$.

If you want the rule for $36$, split it into $4$ and $9$. Do not split it into $6$ and $6$. They share the factor $2$.

## Traps to Watch For

### #1: Splitting large numbers wrong

> Never split a big rule into two numbers that share a factor.

If a test asks if a number is divisible by $24$, students often test the rules for $4$ and $6$. This is a trap. Both $4$ and $6$ can be divided by $2$. You must test the rules for $3$ and $8$ instead.

### #2: Forgetting zero

> Zero is divisible by every number.

If you subtract the alternating sums for the Rule of $11$ and get $0$, the number is divisible. Do not think it must exactly equal $11$. $0$ is a multiple of $11$.

### #3: Rule of 4 addition mistake

> Do not just add the last two digits for the Rule of $4$.

For the rule of $3$, you add digits. For the rule of $4$, you do not. For the number $5,116$, do not add $1 + 6 = 7$. Just look at the whole number $16$. Since $16$ divides by $4$, the big number passes.
