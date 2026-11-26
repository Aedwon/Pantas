---
_id: "lesson-logical-verbal-reasoning-sequence-earlier-terms"
title: "Rules Using Earlier Terms"
summary: "Build a term from earlier terms."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 3
partCount: 4
ordering: 9
keyPoints:
  - "Build a term from earlier terms."
  - "Continue a Fibonacci addition pattern."
---
## Core Concept

### Using Earlier Terms

A **recurrence** builds each new term from two or more earlier terms, instead of adding a fixed number or multiplying by a ratio. For example, each term might be the product or sum of the two or three terms right before it.

Check the rule starting at the first term that has enough earlier terms, and verify every term after it.

1. Check $1, 1, 2, 4, 7, \ldots$ where each term after the first three adds the three terms before it.
2. Term $4$: $1+1+2=4$.
3. Term $5$: $1+2+4=7$.
4. Next term: add the three terms right before the gap, $2+4+7=13$.

:::why
Why test every later term? In $1, 1, 2, 4, 7$, the start $1, 1, 2$ looks like adding two terms, and $2, 4$ looks like doubling, but both guesses fail at $7$.
:::

:::pair #too-few-earlier-terms
Right: for the three-term sum $1, 1, 2, 4, 7, \ldots$, add all three preceding terms: $2+4+7=13$.
Wrong: add only the last two terms: $4+7=11$.
Two-term addition is more common, so it is easy to use by habit. Check whether the rule uses two earlier terms or three.
:::

:::check
Each term after the first two is twice the previous term minus the one before that. Find the next term in $2, 5, 8, 11, \ldots$
:::answer
The answer is $14$. Twice $11$ minus $8$ is $22-8=14$.
:::

### Fibonacci Addition Pattern

In a **Fibonacci pattern**, each term after the first two is the sum of the two terms directly before it. Different sequences can start with different numbers and still use this rule.

1. Check $1, 1, 2, 3, 5, 8, \ldots$
2. Verify each step: $1+1=2$, $1+2=3$, $2+3=5$, and $3+5=8$.
3. Add the last two shown terms: $5+8=13$.

:::pair #double-last-term
Right: for $1, 1, 2, 3, 5, 8, \ldots$, add the last two terms: $5+8=13$.
Wrong: double the last term: $8\times2=16$.
Doubling works on $1$ to $2$ early on, so it can look tempting. Always test the doubling guess on $3, 5, 8$ before using it.
:::

:::pair #skip-to-next-blank
Right: stop at the first missing term after $8$: $5+8=13$.
Wrong: keep adding one step too far: $8+13=21$.
When a pattern is easy to continue in your head, it is easy to jump past the first blank. Check which position the question asks for.
:::

:::check
Find the next term in this Fibonacci-type sequence: $2, 4, 6, 10, 16, \ldots$
:::answer
The answer is $26$. Add the last two shown terms: $10+16=26$.
:::

## Examples

### #1: Product of Earlier Terms

Find the next term in the sequence: $1, 2, 2, 4, 8, 32, \ldots$

**Solution:**

1. Check terms $3$ and $4$ as products of two prior terms:

$$\text{Term 3}=1\times2=2,\quad \text{Term 4}=2\times2=4$$

2. Check terms $5$ and $6$:

$$\text{Term 5}=2\times4=8,\quad \text{Term 6}=4\times8=32$$

3. Multiply $8$ and $32$ for term $7$:

$$\text{Term 7}=8\times32=256$$

The next term is $256$.

**Check:** Estimate $8\times30=240$ plus $8\times2=16$, which gives $256$.

### #2: Fibonacci Pattern

Find the next term in the sequence: $1, 1, 2, 3, 5, 8, \ldots$

**Solution:**

1. Check terms $3$ to $6$ as sums of two prior terms:

$$\text{Term 3}=1+1=2,\quad \text{Term 4}=1+2=3$$

$$\text{Term 5}=2+3=5,\quad \text{Term 6}=3+5=8$$

2. Add $5$ and $8$ for term $7$:

$$\text{Term 7}=5+8=13$$

The next term is $13$.

**Check:** Subtract $8$ from $13$: $13-8=5$, which matches the term before $8$.

### #3: Three-Term Addition Pattern

Each term after the first three is the sum of the three terms directly before it. Find the next term: $2, 3, 4, 9, 16, \ldots$

**Solution:**

1. Verify terms $4$ and $5$ by adding three prior terms:

$$\text{Term 4}=2+3+4=9$$

$$\text{Term 5}=3+4+9=16$$

2. Pick the three terms directly before the blank: $4$, $9$, and $16$.

:::try
Finish the last step: add those three terms to find the sixth term.
:::answer
The answer is $29$. Add the last three terms: $4+9+16=29$.

**Check:** Subtract the last two terms back from $29$: $29-16-9=4$, which matches the third-to-last term.
:::

## Traps to Watch For

:::checklist
- Counting how many earlier terms a rule uses: verify on every shown term, so a three-term rule on $1, 1, 2, 4, 7$ gives $2+4+7=13$, not $11$. {#too-few-earlier-terms}
- Doubling the final term by mistake: test your rule on the middle terms too, so $1, 1, 2, 3, 5, 8$ gives $13$, not $16$. {#double-last-term}
- Adding one step past the blank: match the exact position asked, so the term after $8$ is $13$, not $21$. {#skip-to-next-blank}
:::
