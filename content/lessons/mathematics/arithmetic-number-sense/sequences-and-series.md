---
_id: "lesson-arithmetic-number-sense-sequences-and-series"
title: "Sequences and Series (Arithmetic, Geometric, Fibonacci, Harmonic)"
summary: "This lesson teaches you how to find patterns, missing terms, and sums in different number lists."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **sequence** is just a list of numbers that follow a specific rule. Each number in the list is called a **term**. A **series** is what you get when you add all those numbers together.

College entrance exams will test you on $4$ main types of sequences.

1. **Arithmetic** sequence. You add or subtract the same number every time to get the next term. This jump is called the **common difference** or $d$.

2. **Geometric** sequence. You multiply or divide by the same number every time. This multiplier is called the **common ratio** or $r$.

3. **Fibonacci** sequence. You add the last two numbers to get the next number. The classic example is $1, 1, 2, 3, 5, 8$.

4. **Harmonic** sequence. If you take an arithmetic sequence and flip all the numbers upside down into fractions, it becomes harmonic.



## Examples

### #1: Finding a Far Term in an Arithmetic Sequence

What is the $25^{\text{th}}$ term of the sequence $4, 7, 10, 13, \dots$?

**Solution:**

1. Find the pattern. The numbers are jumping up by $3$. So, our common difference $d$ is $3$.
2. Identify the first term. Our first term $a_1$ is $4$.
3. Use the arithmetic term formula. The formula is:


$$a_n = a_1 + (n - 1)d$$


4. Plug in our numbers. We want the $25^{\text{th}}$ term, so $n$ is $25$.


$$a_{25} = 4 + (25 - 1)(3)$$

$$a_{25} = 4 + (24)(3)$$

$$a_{25} = 4 + 72$$

$$a_{25} = 76$$

### #2: Arithmetic Series in a Word Problem

A theater has $20$ seats in the first row, $24$ seats in the second row, and $28$ seats in the third row. If there are exactly $15$ rows in total, what is the seating capacity of the theater?

**Solution:**

1. Spot the sequence. The seats go $20, 24, 28$. This is arithmetic. The jump $d$ is $4$. The first term $a_1$ is $20$. The number of rows $n$ is $15$.
2. Notice the question type. "Seating capacity" means total seats. We need the sum of all rows.
3. Use the arithmetic series formula.


$$S_n = \dfrac{n}{2} [2(a_1) + (n - 1)d]$$


4. Plug in the numbers and solve carefully.


$$S_{15} = \dfrac{15}{2} [2(20) + (15 - 1)(4)]$$

$$S_{15} = \dfrac{15}{2} [40 + (14)(4)]$$

$$S_{15} = \dfrac{15}{2} [40 + 56]$$

$$S_{15} = \dfrac{15}{2} [96]$$


5. Divide $96$ by $2$ first to make the math easier.


$$S_{15} = 15 \times 48$$

$$S_{15} = 720$$

### #3: Geometric Sequence with Alternating Signs

Find the $8^{\text{th}}$ term of the geometric sequence $3, -6, 12, -24, \dots$

**Solution:**

1. Find the common ratio $r$. To get from $3$ to $-6$, you multiply by $-2$. Let us check the next one. $-6$ times $-2$ is $12$. It works! So, $r = -2$. The first term $a_1$ is $3$.
2. Use the geometric term formula.


$$a_n = a_1 \times r^{n-1}$$


3. Plug in the numbers. We want the $8^{\text{th}}$ term, so $n = 8$.


$$a_8 = 3 \times (-2)^{8-1}$$

$$a_8 = 3 \times (-2)^7$$


4. Calculate $-2$ to the $7^{\text{th}}$ power. An odd power keeps the negative sign. $2^7$ is $128$. So, it is $-128$.


$$a_8 = 3 \times -128$$

$$a_8 = -384$$

### #4: Evaluating an Infinite Geometric Series

Evaluate the sum of the infinite geometric series: $18 + 6 + 2 + \dfrac{2}{3} + \dots$

**Solution:**

1. Find the ratio $r$. To get from $18$ to $6$, you divide by $3$. In math, dividing by $3$ is the same as multiplying by $\dfrac{1}{3}$. So, $r = \dfrac{1}{3}$. The first term $a_1$ is $18$.
2. Use the infinite sum formula. You can only use this if the numbers are getting smaller over time. Since $18, 6, 2$ are shrinking, we can use it.


$$S = \dfrac{a_1}{1 - r}$$


3. Plug the numbers into the formula.


$$S = \dfrac{18}{1 - \dfrac{1}{3}}$$

$$S = \dfrac{18}{\dfrac{2}{3}}$$


4. Divide the fractions. To divide by a fraction, you flip it and multiply.


$$S = 18 \times \dfrac{3}{2}$$

$$S = 9 \times 3$$

$$S = 27$$

### #5: Finding a Missing Term in a Harmonic Sequence

Find the $6^{\text{th}}$ term of the harmonic sequence $\dfrac{1}{2}, \dfrac{1}{5}, \dfrac{1}{8}, \dots$

**Solution:**

1. Do the handstand. Flip all the fractions upside down to make a normal arithmetic sequence. The new list is $2, 5, 8, \dots$
2. Find the rule for this new list. It jumps up by $3$ every time. So, $d = 3$.
3. Find the $6^{\text{th}}$ term of this new list.


$$a_6 = 2 + (6 - 1)(3)$$

$$a_6 = 2 + (5)(3)$$

$$a_6 = 2 + 15$$

$$a_6 = 17$$


4. Flip it back. The number $17$ is the arithmetic answer. The harmonic answer must be flipped upside down. The final answer is $\dfrac{1}{17}$.

### #6: Fibonacci Sequence with Variables

If $x, y, z$ are three consecutive terms in a Fibonacci sequence, and $x = 2a+1$ and $y = 3a-2$, what is $z$ in terms of $a$?

**Solution:**

1. Remember the Fibonacci rule. The rule is simply that adding two numbers gives you the next number. So, $x + y = z$.
2. Substitute the expressions given in the problem.


$$z = (2a + 1) + (3a - 2)$$


3. Combine like terms. Add the $a$ parts together, and add the plain numbers together.


$$z = 2a + 3a + 1 - 2$$

$$z = 5a - 1$$

## Speed Tricks & Shortcuts

**The Number of Terms Trick.** If you have an arithmetic sequence and want to know how many terms are in it, do not list them all out. Use this fast formula:

$$n = \dfrac{\text{Last} - \text{First}}{\text{Difference}} + 1$$



Subtract the first number from the last number, divide by your jump amount, and then add $1$.

**The Middle Term Average Trick.** If you need to find the sum of a short arithmetic sequence with an odd number of terms, just find the middle number and multiply it by the total number of terms. For $5, 10, 15, 20, 25$, the middle is $15$. There are $5$ terms. The sum is simply $15 \times 5 = 75$.

## Traps to Watch For

### #1: Term vs. Sum Confusion

Students often use the $a_n$ formula when the exam actually wants the $S_n$ formula.

> Always circle the word "term" or "sum" in the test question before you write a single formula.

### #2: The Unflipped Harmonic Answer

When solving harmonic sequences, test-makers will always put the arithmetic answer as Choice A. If you get $17$, you will see $17$ in the choices.

> A harmonic answer must always be flipped back into a fraction at the very end!

### #3: The Fake Infinite Sum

The formula for an infinite geometric series only works if the numbers are shrinking toward zero. This means the ratio $r$ must be a fraction between $-1$ and $1$.

> You cannot find an infinite sum if the numbers are getting bigger! If $r$ is $2$, the sum is infinite, and the formula will give you a fake answer.
