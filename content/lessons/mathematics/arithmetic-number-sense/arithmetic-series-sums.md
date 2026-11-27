---
_id: "lesson-arithmetic-number-sense-arithmetic-series-sums"
title: "Arithmetic Series Sums"
summary: "Find the sum of an arithmetic series."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 4
partCount: 9
ordering: 31
keyPoints:
  - 'Find the sum of an arithmetic series.'
  - 'Use the middle-term average for an odd number of terms.'
---
## Core Concept

A **sequence** is an ordered list of numbers called **terms**. A **series** is a sum of terms from a sequence. Here $n$ is the number of terms, and $a_n$ is the term in position $n$, counting from $1$. The symbol $S_n$ means the sum of the first $n$ terms, $a_1$ is the first term, and $d$ is the common difference.

### Sum Using First and Last Terms

Look at the arithmetic series $4+7+10+13+16+19$. Pair the outside terms moving inward:

$$4+19=23$$

$$7+16=23$$

$$10+13=23$$

In this arithmetic series, every pair has the same sum, $23$. There are $6$ terms, which make $\dfrac{6}{2}=3$ pairs, so the sum is $3\times23=69$.

<!-- ILLUSTRATION: Six boxes in a row hold the terms 4, 7, 10, 13, 16 and 19. Three nested brackets under the row join the outside pairs moving inward: 10 + 13 = 23 for the inner pair, 7 + 16 = 23 for the middle pair, and 4 + 19 = 23 for the outer pair. Below them, "3 pairs × 23 = 69" gives the total. -->

For an arithmetic series with $n$ terms, the sum is:

$$S_n=\dfrac{n}{2}(a_1+a_n)$$

:::why
Why does every outside-in pair give the same sum? Moving one step inward from the left adds $d$, and moving one step inward from the right subtracts $d$, so those two changes cancel.
:::

:::pair #omit-divide-by-two
Right: $S_{10}=\dfrac{10}{2}(4+31)=5(35)=175$
Wrong: $S_{10}=10(4+31)=350$
Each pair holds two terms, so $10$ terms make $\dfrac{10}{2}=5$ pairs, not $10$ pairs.
:::

### Sum Using the Common Difference

When the last term $a_n$ is not given, replace $a_n$ with $a_1+(n-1)d$ to get the second form:

$$S_n=\dfrac{n}{2}\left[2a_1+(n-1)d\right]$$

Find the sum of the first $10$ terms of $4,7,10,13,\dots$. Here $a_1=4$, $d=3$, and $n=10$.

1. Double the first term.

$$2a_1=2(4)=8$$

2. Multiply $n-1=9$ by $d=3$.

$$9\times3=27$$

3. Add those two parts.

$$8+27=35$$

4. Halve $n$.

$$\dfrac{10}{2}=5$$

5. Multiply by the bracket.

$$S_{10}=5(35)=175$$

:::pair #wrong-step-count-in-sum
Right: $a_{10}=4+9(3)=31$, then $S_{10}=5(4+31)=175$
Wrong: $a_{10}=4+10(3)=34$, then $S_{10}=5(4+34)=190$
Using $10$ steps instead of $9$ makes the tenth term one step too large.
:::

### Middle-Term Average for Odd Counts

When a finite arithmetic sequence has an odd number of terms, the middle term equals the average of all the terms. It is also the average of the first and last terms. Multiply that middle term by the number of terms $n$:

$$S_n=n\times(\text{middle term})$$

For $5,10,15,20,25$, there are $n=5$ terms and the middle term is $15$.

$$S_5=5\times15=75$$

:::pair #extra-half-on-middle-term
Right: For $7$ terms with middle term $12$, $S_7=7\times12=84$.
Wrong: For $7$ terms with middle term $12$, $S_7=\dfrac{7}{2}\times12=42$.
The middle term is already the average of the sequence, so do not multiply by $\dfrac{1}{2}$ again.
:::

:::check
An arithmetic sequence has $11$ terms. Its first term is $6$ and its last term is $46$. What is its sum?
:::answer
The answer is $286$. The middle term is the average of the first and last terms: $\dfrac{6+46}{2}=26$. Then $S_{11}=11\times26=286$.
:::

## Examples

### #1: Arithmetic Series in a Word Problem

Find the total seats in a theater. The first row has $20$ seats, the second has $24$, and the third has $28$. Each row has $4$ more seats than the row before it. There are $15$ rows.

**Solution:**

1. List what you know: $a_1=20$, $d=4$, and $n=15$.

2. Use the sum formula with $d$. Double $a_1$ and multiply $n-1=14$ by $d=4$.

$$2(20)=40$$

$$14\times4=56$$

3. Add inside the brackets.

$$40+56=96$$

4. Halve $96$.

$$\dfrac{96}{2}=48$$

5. Multiply by $n=15$.

$$S_{15}=15\times48=720$$

The theater has $720$ seats.

### #2: Finding a Term From a Sum Formula

Find the sixth term of a sequence whose sum of the first $n$ terms is $S_n=n^2+4n$.

**Solution:**

1. $S_6$ is the sum of the first $6$ terms, and $S_5$ is the sum of the first $5$ terms. Subtracting $S_5$ from $S_6$ leaves only the sixth term $a_6$.

2. Compute $S_6$.

$$6^2=36$$

$$4(6)=24$$

$$S_6=36+24=60$$

3. Compute $S_5$.

$$5^2=25$$

$$4(5)=20$$

$$S_5=25+20=45$$

:::try
Finish the last step: find $a_6=S_6-S_5$.
:::answer
The answer is $15$. Subtract the two sums: $a_6=60-45=15$.
:::

## Traps to Watch For

:::checklist
- Using $S_n=\dfrac{n}{2}(a_1+a_n)$: divide $n$ by $2$, so $S_{10}=\dfrac{10}{2}(4+31)=175$. {#omit-divide-by-two}
- Using $S_n=\dfrac{n}{2}\left[2a_1+(n-1)d\right]$: use $n-1$ steps inside the bracket, not $n$. {#wrong-step-count-in-sum}
- Using the middle-term shortcut for an odd count: multiply $n\times\text{middle term}$ without dividing by $2$ ($7\times12=84$). {#extra-half-on-middle-term}
:::
