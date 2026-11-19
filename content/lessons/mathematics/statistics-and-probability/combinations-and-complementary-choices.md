---
_id: "lesson-statistics-and-probability-combinations-and-complementary-choices"
title: "Combinations and Complementary Choices"
summary: "Count unordered groups by choosing who stays or who goes."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 3
partCount: 5
ordering: 17
keyPoints:
  - "Count unordered selections."
  - "Use the symmetry of choosing and leaving out."
---
## Core Concept

### Combinations

A **combination** is an unordered selection: the same objects in a different order are the same outcome. A permutation counts each group of $r$ objects once for every order it can be arranged in, and there are $r!$ such orders.

So the number of groups is the permutation count divided by $r!$:

$$C(n,r)=\dfrac{n!}{r!(n-r)!}$$

This holds for $0\le r\le n$, for distinct objects used at most once. For example, $C(n,n)=1$ and $C(n,0)=1$: there is one way to take everything and one way to take nothing. Both need $0!=1$.

Choosing $r$ objects to take is the same as choosing the $n-r$ objects to leave. So $C(n,r)=C(n,n-r)$ for $0\le r\le n$.

## Examples

### #1: Combination

A teacher must pick $3$ students from a class of $8$ to form a quiz team, with no assigned roles. How many different teams are possible?

**Solution:**
The order of choosing does not change the team, so use a combination.

$$C(8,3)=\dfrac{8!}{3!5!}=\dfrac{8\times7\times6}{3\times2\times1}=56$$

There are $56$ possible teams.

### #2: Choosing the Ones Left Out

From $12$ students, a teacher picks $10$ to join a field trip. How many different groups of $10$ can go?

**Solution:**
1. Choosing the $10$ who go is the same as choosing the $2$ who stay. Each group of $10$ matches exactly one group of $2$, so $C(12,10)=C(12,2)$.
2. Work with the smaller number.

$$C(12,2)=\dfrac{12\times11}{2\times1}=66$$

3. There are $66$ possible groups.

## Speed Tricks & Shortcuts

To find $C(n,r)$ for $r\ge1$, write $r$ factors from $n$ downward on top and $r!$ on the bottom. This avoids expanding the full factorials:

$$C(8,3)=\dfrac{8\times7\times6}{3\times2\times1}=56$$

The symmetry rule is:

$$C(n,r)=C(n,n-r)$$

It holds for $0\le r\le n$. Choosing $r$ objects is the same as choosing the $n-r$ objects left out. When $r$ is more than half of $n$, calculate with $n-r$ instead.

## Traps to Watch For

### #1: Counting an Unordered Group as Ordered

> If swapping the selected objects creates no new outcome, an ordered count is too large.

For a two-person committee with no roles, Ana-Ben and Ben-Ana are the same committee. The ordered count $90$ in Example #7 is twice the committee count $45$.
