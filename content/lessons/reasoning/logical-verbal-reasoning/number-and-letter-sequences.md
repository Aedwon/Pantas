---
_id: "lesson-logical-verbal-reasoning-number-and-letter-sequences"
title: "Number and Letter Sequences"
summary: "Learn how to identify the pattern in a number or letter sequence and predict the next term."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
estimatedMinutes: 10
isActive: true
---
## Core Concept

**Sequence** questions give you a series of numbers or letters following a hidden rule, and ask you to find the next term (or a missing term). The key skill is testing the sequence against a checklist of common pattern types until one fits all the given terms.

Common number sequence patterns:

- **Arithmetic (constant difference)**: add or subtract the same number each time. $2, 5, 8, 11, \ldots$ (add $3$ each time).
- **Geometric (constant ratio)**: multiply or divide by the same number each time. $3, 6, 12, 24, \ldots$ (multiply by $2$ each time).
- **Changing difference**: the amount added or subtracted itself changes in a pattern. $1, 2, 4, 7, 11, \ldots$ (add $1$, then $2$, then $3$, then $4$).
- **Alternating/combined pattern**: two interleaved sequences, or an alternating operation. $1, 10, 3, 8, 5, 6, \ldots$ (odd positions increase by $2$: $1, 3, 5$; even positions decrease by $2$: $10, 8, 6$).
- **Fibonacci-style**: each term is the sum of the two terms before it. $1, 1, 2, 3, 5, 8, \ldots$

For letter sequences, convert letters to their alphabet position numbers ($A=1, B=2, \ldots Z=26$) to reveal a hidden number pattern, then convert back to letters.

<!-- ILLUSTRATION: a number line showing the sequence 2, 5, 8, 11 with "+3" labeled above each gap between consecutive terms, illustrating a constant-difference arithmetic pattern -->

## Examples

### #1: Arithmetic Sequence

Find the next term: $4, 9, 14, 19, \ldots$

**Solution:**
1. Check the difference between consecutive terms: $9 - 4 = 5$, $14 - 9 = 5$, $19 - 14 = 5$.
2. The pattern adds $5$ each time.
3. Next term: $19 + 5 = 24$.

### #2: Geometric Sequence

Find the next term: $2, 6, 18, 54, \ldots$

**Solution:**
1. Check the ratio between consecutive terms: $6 \div 2 = 3$, $18 \div 6 = 3$, $54 \div 18 = 3$.
2. The pattern multiplies by $3$ each time.
3. Next term: $54 \times 3 = 162$.

### #3: Changing Difference Pattern

Find the next term: $2, 3, 5, 8, 12, \ldots$

**Solution:**
1. Check the differences between terms: $3 - 2 = 1$, $5 - 3 = 2$, $8 - 5 = 3$, $12 - 8 = 4$.
2. The differences themselves increase by $1$ each time: $1, 2, 3, 4, \ldots$, so the next difference should be $5$.
3. Next term: $12 + 5 = 17$.

### #4: Letter Sequence Using Alphabet Positions

Find the next letter: $B, D, G, K, \ldots$

**Solution:**
1. Convert each letter to its alphabet position: $B = 2$, $D = 4$, $G = 7$, $K = 11$.
2. Check the differences: $4 - 2 = 2$, $7 - 4 = 3$, $11 - 7 = 4$.
3. The differences increase by $1$ each time ($2, 3, 4, \ldots$), so the next difference should be $5$.
4. Next number: $11 + 5 = 16$, which corresponds to the letter $P$.

## Speed Tricks & Shortcuts

**Always compute the differences between consecutive terms first.** If the differences are constant, you have an arithmetic sequence. If the differences themselves form a simple pattern (increasing by $1$, doubling, etc.), you likely have a changing-difference sequence.

**If differences do not reveal a pattern, try ratios instead** (dividing each term by the previous one), which reveals geometric sequences.

**For sequences that seem to jump around unpredictably, check for an alternating pattern** by splitting the sequence into two separate sub-sequences (odd positions and even positions) and analyzing each one separately.

**For letter sequences, immediately convert to numbers** using alphabet positions: this turns an unfamiliar letter puzzle into a familiar number pattern problem.

## Traps to Watch For

### #1: Assuming Every Sequence Is Simple Arithmetic

> Always check the differences are truly constant before assuming a simple arithmetic pattern: a changing difference pattern can look similar at first glance.

$2, 3, 5, 8, 12$ might tempt you to guess "add $3$" after seeing an early gap, but checking all the differences reveals they are actually increasing ($1, 2, 3, 4$), not constant.

### #2: Stopping After Checking Only Two Terms

> Confirm a suspected pattern against at least three consecutive gaps (or more) before committing to it: two terms alone can match multiple different possible patterns.

A pattern that seems to "add $2$" between the first two terms might actually be a more complex pattern that only reveals itself by the third or fourth term.

### #3: Forgetting to Convert Back to a Letter

> After solving a letter sequence using alphabet position numbers, always convert your final numeric answer back into its corresponding letter before selecting it as your final answer.

Solving that the next number is $16$ is not the final answer if the question asks for a letter: remember to state the final answer as $P$ (the 16th letter), not the number $16$ itself.
