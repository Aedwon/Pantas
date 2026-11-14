---
_id: "lesson-logical-verbal-reasoning-sequence-positions-and-operations"
title: "Separate Positions and Alternating Operations"
summary: "Follow separate odd-position and even-position rules."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 2
partCount: 4
ordering: 302
keyPoints:
  - "Follow separate odd-position and even-position rules."
  - "Track a repeating cycle of operations."
---

## Core Concept

Example #8 in the original lesson is Example #2 here.

### Separate Rules by Position

In an **interleaved pattern**, odd positions follow one rule and even positions follow another. Odd and even describe the positions, not the values of the terms.

Label the positions $1,2,3,4,5,6,\ldots$. Read positions $1,3,5,\ldots$ as one list and positions $2,4,6,\ldots$ as another. Keep this rule only if both smaller lists have clear patterns.

Next, find which list contains the missing position. Use that list's rule to find the missing term. This approach helps when the moves between neighboring terms do not form a clear pattern.

### Alternating Operations

With **alternating operations**, the move switches back and forth. For example, a rule may multiply by $2$, then add $2$, and repeat.

Write the operation between each pair of terms. Check that the same cycle works through the whole list. Then apply the next operation in the cycle.

Unlike an interleaved pattern, this rule works directly from each term to the next. Try it when neighboring terms show a repeating set of moves.

## Examples

### #1: Interleaved Odd and Even Positions

Find the intended next term: $2,9,4,12,6,15,\ldots$

**Solution:**

1. Read the odd positions as one list: $2,4,6$. They increase by $2$.
2. Read the even positions as another list: $9,12,15$. They increase by $3$.
3. The missing term is at position $7$. This is an odd position, so continue the odd-position list.

$$6+2=8$$

The next term is $8$. Adding $3$ to $15$ would continue the even-position list, but the missing position is odd.

### #2: Alternating Operations

Find the intended next term: $3,6,8,16,18,36,\ldots$

**Solution:**

1. Check the moves from the start.

$$3\times2=6,\quad 6+2=8$$

$$8\times2=16,\quad 16+2=18$$

$$18\times2=36$$

2. The moves repeat: multiply by $2$, then add $2$. The last move was multiplication, so add next.

$$36+2=38$$

The next term is $38$.

## Traps to Watch For

### #1: Splitting by Value Instead of Position

> Odd and even positions are different from odd and even numbers.

In $2,9,4,12,6,15,\ldots$, the odd-position list is $2,4,6$. Grouping the odd values together would give the wrong lists. Label positions before splitting.

### #2: Repeating the Wrong Operation

> An alternating rule needs the correct next move.

After a multiplication step, the cycle may call for addition. Repeating the last operation in Example #8 would give $72$. Track the full cycle before continuing.
