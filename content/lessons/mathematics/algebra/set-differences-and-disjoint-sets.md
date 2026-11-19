---
_id: "lesson-algebra-set-differences-and-disjoint-sets"
title: "Set Differences and Disjoint Sets"
summary: "Find set differences in the stated order."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 4
keyPoints:
  - "Find set differences in the stated order."
  - "Recognize disjoint sets from their empty intersection."
---
## Core Concept

If $A\cap B=\varnothing$, the sets are **disjoint**.

Set-builder notation lists a rule instead of every element: $\{x\in\mathbb Z\mid -2\le x\le3\}$ means all integers from $-2$ through $3$. The symbol $\mathbb Z$ means the integers, and the bar means "such that." For $a>0$, the condition $x^2<a^2$ means $-a<x<a$, so $x^2<9$ gives $-3<x<3$.

The **difference** $A-B$ contains the elements that are in $A$ but not in $B$. Some books write it $A\setminus B$. It is not the same as $B-A$ in general. Also, $A-B$ is the same set as $A\cap B'$.

## Examples

### #1: Basic Set Operations

Given $X=\{1,3,5,7\}$ and $Y=\{2,3,5,8\}$, find $X\cap Y$, $X\cup Y$, $X-Y$ and $Y-X$.

**Solution:**

1. The elements in both sets are $3$ and $5$.

$$X\cap Y=\{3,5\}$$

2. The union lists every element of either set, once.

$$X\cup Y=\{1,2,3,5,7,8\}$$

3. For $X-Y$, take the elements of $X$ that are not in $Y$.

$$X-Y=\{1,7\}$$

4. For $Y-X$, take the elements of $Y$ that are not in $X$.

$$Y-X=\{2,8\}$$

The two differences are not equal.

## Traps to Watch For

### #1: Reversing a Difference

> $A-B$ and $B-A$ are usually different sets.

They are equal only when both are empty, which happens when $A=B$. In Example 1, $X-Y=\{1,7\}$ and $Y-X=\{2,8\}$. Read the order of the sets before you list elements.
