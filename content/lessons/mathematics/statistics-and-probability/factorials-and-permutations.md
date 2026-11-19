---
_id: "lesson-statistics-and-probability-factorials-and-permutations"
title: "Factorials and Permutations"
summary: "Count arrangements of distinct objects."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 2
partCount: 5
ordering: 16
keyPoints:
  - "Use factorials to count arrangements of all objects."
  - "Count ordered selections of some objects."
---
## Core Concept

The formulas below count objects that can be told apart from one another. We call such objects **distinct**.

### Factorial

For a whole number $n\ge1$, the **factorial** of $n$ is the product of all whole numbers from $n$ down to $1$:

$$n!=n(n-1)(n-2)\cdots2\cdot1$$

For example, $4!=4\times3\times2\times1=24$. We define $0!=1$ so that the formulas below still work when no objects are left over.

### Permutations

A **permutation** is an ordered selection: the same objects in a different order count as a different outcome. To choose and arrange $r$ of $n$ distinct objects, with no object used twice, there are $n$ choices for the first place, then $n-1$ for the second, and so on for $r$ places.

Multiplying these gives:

$$P(n,r)=\dfrac{n!}{(n-r)!}$$

where $0\le r\le n$. The right side is the product of $r$ factors that start at $n$ and go down by $1$ each time. For example:

$$P(7,3)=7\times6\times5=210$$

Two boundary cases check the formula. Arranging all $n$ objects gives $P(n,n)=\dfrac{n!}{0!}=n!$. Choosing none gives $P(n,0)=1$, one way to arrange nothing.

To arrange all objects in a row when some are identical, start with $n!$. Divide by the factorial of each identical group's size because swapping identical objects leaves the row the same.

If only rotations count as the same around a table, fix one person and arrange the remaining $n-1$ people in order around the table. This gives $(n-1)!$ for $n$ distinct people.

To keep people together, count them as one unit. Arrange the units, then multiply by the number of orders inside the unit. If they must stay apart, subtract the count where they are together from the count of all arrangements.

## Examples

### #1: Permutation

A shelf has room for $3$ books. In how many ways can you arrange $3$ books chosen from $5$ different books?

**Solution:**
The positions on the shelf are in order, so a different order is a different arrangement.

$$P(5,3)=5\times4\times3=60$$

There are $60$ arrangements.

### #2: Arranging All the Objects

In how many ways can $5$ different students line up in a row for a photo?

**Solution:**
1. All $5$ students are used, so $r=n=5$.

$$P(5,5)=\dfrac{5!}{0!}=5!$$

2. Multiply the factors of $5!$.

$$5\times4\times3\times2\times1=120$$

3. There are $120$ ways to line up.

## Traps to Watch For

### #1: Forgetting $0!=1$

> Zero factorial is defined as $1$, not $0$.

This keeps $C(n,n)=1$ and $P(n,n)=n!$ correct. If $0!$ were $0$, both formulas would divide by zero.
