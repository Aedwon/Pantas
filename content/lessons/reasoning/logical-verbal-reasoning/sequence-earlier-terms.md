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

### Rules Using Earlier Terms

A **recurrence** builds a new term from earlier terms. For example, each new term might be the product of the two terms before it. A product is the result of multiplication.

Check the rule from the first place where enough earlier terms are given. Test it on every later term before using it to continue the list. Do not accept a rule just because it works once.

The **Fibonacci pattern** is a recurrence that adds the two terms before each new term. In $1,1,2,3,5,\ldots$, the sum of $1$ and $1$ gives $2$. Then $1+2=3$, and $2+3=5$.

To continue this pattern, add the two most recent terms. A list can use this same addition rule with different starting terms.

## Examples

### #1: Earlier-Term Recurrence

Find the intended next term: $1,2,2,4,8,32,\ldots$

**Solution:**

1. Test whether each term is the product of the two terms before it. Start at the third term.

$$1\times2=2,\quad 2\times2=4$$

2. Check the remaining shown terms.

$$2\times4=8,\quad 4\times8=32$$

3. The rule works throughout. Multiply the last two shown terms.

$$8\times32=256$$

The next term is $256$.

### #2: Fibonacci Recurrence

Find the intended next term: $1,1,2,3,5,8,\ldots$

**Solution:**

1. Each term after the first two is the sum of the two terms before it. Check the later terms.

$$2+3=5,\quad 3+5=8$$

2. Add the last two shown terms.

$$5+8=13$$

The next term is $13$.

## Traps to Watch For

### #1: Stopping After One Match

> A rule that works once may fail later.

Check every shown move where the rule applies. In a recurrence, start where enough earlier terms are available. One failed check means you need another rule.

### #2: Using Only the Last Term

> A recurrence may need the last two terms.

Adding the most recent difference may fail when each new term comes from two earlier terms. Check the same earlier-term rule throughout the list.
