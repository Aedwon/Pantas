---
_id: "lesson-arithmetic-number-sense-sequences-and-series"
title: "Sequences and Series (Arithmetic, Geometric, Fibonacci, Harmonic)"
summary: "Find patterns, terms, and sums in common types of number sequences."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A **sequence** is an ordered list of numbers called **terms**. A **series** is a sum of terms from a sequence. The dots in a list mean that it continues.

### Common Sequence Types

An **arithmetic sequence** has the same difference between neighboring terms. This value is the **common difference** $d$. Subtract a term from the term after it to find $d$.

A **geometric sequence** is made by multiplying each term by the same number. This number is the **common ratio** $r$. Divide a term by the nonzero term before it to find $r$.

In a **Fibonacci-type sequence**, each term after the first two is the sum of the two terms before it. For three neighboring terms $x,y,z$, where $z$ follows the first two:

$$z=x+y$$

A common Fibonacci sequence begins $1,1,2,3,5,8,\dots$. Another standard convention begins $0,1,1,2,3,5,\dots$.

The **reciprocal** of a nonzero number $x$ is $\dfrac{1}{x}$. For a fraction with nonzero numerator and denominator, switch them to take its reciprocal. For example, the reciprocal of $\dfrac{2}{3}$ is $\dfrac{3}{2}$.

In a **harmonic sequence**, the reciprocals of the terms form an arithmetic sequence. Find the pattern in those reciprocals, then take the reciprocal again to return to the original sequence. All terms of a harmonic sequence must be nonzero.

### Finding a Number Pattern

Not every number pattern belongs to one of these four types. Before choosing a formula, look at how each term changes.

Try these checks:

- Subtract neighboring terms. A constant difference means the pattern is arithmetic.
- Divide neighboring nonzero terms. A constant ratio means the pattern is geometric.
- If neither works, check whether operations alternate, such as adding and then multiplying.
- Check whether the differences form their own simple pattern.
- Check separate patterns in the odd and even positions, or in repeating groups.

Odd positions are $1,3,5,\dots$. Even positions are $2,4,6,\dots$. Read every other term to check these two groups.

A pattern rule should fit every shown step. A short list can fit more than one rule. Use the rule stated in the question, or look for a simple rule that fits the whole list and the answer choices.

### The Formulas You Need

The symbol $a_1$ means the first term. The symbol $a_n$ means the term in position $n$. When finding a sum, $n$ is the number of terms being added.

The symbol $S_n$ means the sum of the first $n$ terms. The letters $d$ and $r$ mean the common difference and common ratio.

In an arithmetic sequence, moving from the first term to position $n$ takes $n-1$ equal steps. This gives:

$$a_n=a_1+(n-1)d$$

For an arithmetic series, the average of the first and last terms is also the average of all the terms. Multiply this average by the number of terms:

$$S_n=\dfrac{n}{2}(a_1+a_n)$$

Using the arithmetic-term formula gives another form of the same sum:

$$S_n=\dfrac{n}{2}\left[2a_1+(n-1)d\right]$$

If the first term, last term, and nonzero common difference are known, count the steps and add $1$ to include the first term:

$$n=\dfrac{a_n-a_1}{d}+1$$

Use this only when the last term belongs to the sequence. The result must be a positive whole number.

In a geometric sequence, reaching position $n$ takes $n-1$ multiplications by $r$:

$$a_n=a_1r^{n-1}$$

For a finite geometric series with $r\ne1$:

$$S_n=\dfrac{a_1(1-r^n)}{1-r}$$

To see why this works, multiply the sum by $r$. Subtract this new sum from the original sum. The middle terms cancel, leaving:

$$(1-r)S_n=a_1(1-r^n)$$

If $r=1$, every term equals $a_1$. Then:

$$S_n=na_1$$

An infinite series keeps adding terms without stopping. It **converges** if the running total gets closer and closer to one finite number. For example, $1+\dfrac{1}{2}+\dfrac{1}{4}+\dots$ has running totals $1,\dfrac{3}{2},\dfrac{7}{4},\dots$, which approach $2$.

The symbol $S_\infty$ means that finite sum of an infinite series. The symbol $|r|$ means the absolute value of $r$, which is its distance from $0$.

For an infinite geometric series with a nonzero first term, a finite sum exists only when $|r|<1$. The terms then shrink toward $0$, and the running total approaches:

$$S_\infty=\dfrac{a_1}{1-r}$$

If $|r|\ge1$ and the first term is nonzero, the series **diverges**. This means its running total does not approach a finite sum. If every term is $0$, the sum is simply $0$.

In exam questions, **evaluate** means find the final number answer.

## Examples

### #1: Discovering a Number Pattern

What number most reasonably completes the sequence $2,5,10,17,26,\dots$?

**Solution:**

1. Find the differences between neighboring terms.

$$5-2=3,\quad10-5=5$$

$$17-10=7,\quad26-17=9$$

2. The differences are $3,5,7,9$. Each difference is $2$ more than the last, so the next difference is $11$.

$$26+11=37$$

3. The next number is $37$.

### #2: Alternating Operations

What number most reasonably completes the sequence $4,7,14,17,34,\dots$?

**Solution:**

1. The differences are $3,7,3,17$. They are not constant, but adding $3$ works on every other step.

$$4+3=7,\quad14+3=17$$

2. Check the steps between those additions. Both multiply by $2$.

$$7\times2=14,\quad17\times2=34$$

3. The rule alternates between adding $3$ and multiplying by $2$. The next operation is adding $3$.

$$34+3=37$$

### #3: Two Patterns in One List

What number most reasonably completes the sequence $2,20,5,18,8,16,\dots$?

**Solution:**

1. Neighboring terms do not have a constant difference or ratio. Check every other term, starting at the first position.

$$5-2=3,\quad8-5=3$$

2. Check the terms in the even positions.

$$18-20=-2,\quad16-18=-2$$

3. The odd-position terms increase by $3$. The even-position terms decrease by $2$. The next term is in an odd position.

$$8+3=11$$

### #4: Finding a Far Term in an Arithmetic Sequence

What is the $25^{\text{th}}$ term of the arithmetic sequence $4,7,10,13,\dots$?

**Solution:**

1. The first term is $a_1=4$, and the common difference is $d=3$.
2. Use the arithmetic-term formula.

$$a_{25}=4+(25-1)(3)=76$$

### #5: Arithmetic Series in a Word Problem

A theater has $20$ seats in the first row, $24$ in the second, and $28$ in the third. Each row has $4$ more seats than the row before it. If there are $15$ rows, what is the total number of seats?

**Solution:**

1. Here $a_1=20$, $d=4$, and $n=15$.
2. Use the arithmetic-series formula that contains $d$.

$$S_{15}=\dfrac{15}{2}\left[2(20)+14(4)\right]$$

3. Work out the value inside the brackets, then multiply.

$$S_{15}=\dfrac{15}{2}(96)=720$$

4. The theater has $720$ seats.

### #6: Geometric Sequence with Alternating Signs

Find the $8^{\text{th}}$ term of the geometric sequence $3,-6,12,-24,\dots$.

**Solution:**

1. The common ratio is $r=-2$, and $a_1=3$.
2. Use the geometric-term formula.

$$a_8=3(-2)^7=-384$$

### #7: Finite Geometric Series

Find the sum of the first $6$ terms of the geometric sequence $3,6,12,24,\dots$.

**Solution:**

1. Here $a_1=3$, $r=2$, and $n=6$.
2. Use the finite geometric-series formula.

$$S_6=\dfrac{3(1-2^6)}{1-2}$$

3. Calculate the power, then divide.

$$S_6=\dfrac{3(-63)}{-1}=189$$

4. The sum is $189$.

### #8: Evaluating an Infinite Geometric Series

Evaluate the infinite geometric series $18+6+2+\dfrac{2}{3}+\dots$.

**Solution:**

1. The common ratio is $r=\dfrac{1}{3}$. Since $|r|<1$, the series converges.
2. Use the infinite geometric-series formula.

$$S_\infty=\dfrac{18}{1-\frac{1}{3}}$$

3. Subtract in the denominator, then divide.

$$S_\infty=18\times\dfrac{3}{2}=27$$

### #9: Finding a Term in a Harmonic Sequence

Find the $6^{\text{th}}$ term of the harmonic sequence $\dfrac{1}{2},\dfrac{1}{5},\dfrac{1}{8},\dots$.

**Solution:**

1. Take the reciprocals. They form the arithmetic sequence $2,5,8,\dots$ with $d=3$.
2. Find the $6^{\text{th}}$ term of that arithmetic sequence.

$$a_6=2+(6-1)(3)=17$$

3. Take the reciprocal to return to the harmonic sequence. Its $6^{\text{th}}$ term is:

$$\dfrac{1}{17}$$

### #10: Fibonacci-Type Sequence with Variables

If $x,y,z$ are three consecutive terms of a Fibonacci-type sequence in that order, $x=2a+1$, and $y=3a-2$, what is $z$ in terms of $a$?

**Solution:**

1. Use the sum-of-two-terms rule.

$$z=x+y$$

2. Replace $x$ and $y$ with the given expressions.

$$z=(2a+1)+(3a-2)$$

3. Add the coefficients of $a$ and add the plain numbers.

$$z=(2+3)a+(1-2)=5a-1$$

### #11: Finite Geometric Series with $r=1$

A geometric series has $8$ terms, and every term is $5$. What is the sum?

**Solution:**

1. Since every term is the same nonzero number, $r=1$.
2. Multiply the number of terms by the value of each term.

$$S_8=8(5)=40$$

### #12: An Infinite Geometric Series That Diverges

Does the infinite geometric series $3+6+12+24+\dots$ have a finite sum?

**Solution:**

1. The common ratio is $r=2$.
2. The first term is nonzero and $|r|\ge1$, so the series diverges. It does not have a finite sum.

## Speed Tricks & Shortcuts

### Number of Terms in an Arithmetic Sequence

Subtract the first term from the last term. Divide by the nonzero common difference, then add $1$ to count the first term. Check that the result is a positive whole number.

### Middle-Term Average

For a finite arithmetic sequence with an odd number of terms, the middle term equals the average of all the terms. The sum is the middle term times the number of terms.

For $5,10,15,20,25$, the middle term is $15$ and there are $5$ terms, so the sum is $75$.

### Pattern Check

If a sequence is not arithmetic or geometric, write the differences between terms first. If those do not help, check alternating operations and separate odd-position and even-position terms.

## Traps to Watch For

### #1: Term vs. Sum Confusion

> A term and a sum are different quantities.

Use $a_n$ for one term. Use $S_n$ for the sum of the first $n$ terms. Adding terms when the question asks for one term gives a different answer.

### #2: Forgetting the Reciprocal in a Harmonic Sequence

> A harmonic sequence becomes arithmetic only after you take reciprocals.

Solve the arithmetic pattern using the reciprocals. Then take the reciprocal again to return to the harmonic sequence. In the worked example, stopping at $17$ would give the wrong answer instead of $\dfrac{1}{17}$.

### #3: Using the Infinite Sum Formula When the Series Diverges

> Check $|r|<1$ before using the infinite geometric-series sum formula.

For a nonzero first term, $|r|\ge1$ means the series has no finite sum. Using $S_\infty=\dfrac{a_1}{1-r}$ anyway can give a number that is not a valid sum.

### #4: Forcing the Wrong Pattern

> A rule must fit every shown step in the sequence.

A rule that matches only the first few terms is not enough. Check the whole given pattern before choosing the next term.
