---
_id: "lesson-algebra-set-membership-and-operations"
title: "Set Membership and Operations"
summary: "Find unions, intersections, and complements, and use De Morgan's laws."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 2
ordering: 1
keyPoints:
  - "Find unions, intersections, and complements."
  - "Apply De Morgan's laws."
---
## Core Concept

A **set** is a collection of distinct objects called **elements**. Sets are commonly written with curly braces, for example:

$$A=\{1,2,3\}.$$

A **universal set** $U$ specifies the elements under consideration in a particular problem. If every element of $B$ is also an element of $A$, then $B$ is a subset of $A$.

The **union** $A\cup B$ contains elements that are in $A$, in $B$, or in both. The **intersection** $A\cap B$ contains only elements common to both sets. The **complement** of $A$ depends on the stated universal set and contains elements of $U$ that are not in $A$.

The prime mark means complement: $A'$ is the complement of $A$.

De Morgan's laws say $(A\cup B)'=A'\cap B'$ and $(A\cap B)'=A'\cup B'$, with all complements taken in the same universal set. Being outside the union means being outside both sets. Being outside the intersection means being outside at least one set.

Venn diagrams show these relationships visually.

## Mnemonics & Memory Aids

> Union ($\cup$): combine membership from either set.

> Intersection ($\cap$): keep what the sets have in common.

> Complement: everything in the stated universal set that is outside the set being complemented.

## Examples

### #1: Basic Set Operations

Given $X=\{1,3,5,7\}$ and $Y=\{2,3,5,8\}$, find $X\cap Y$.

**Solution:**

The elements appearing in both sets are $3$ and $5$.

$$X\cap Y=\{3,5\}$$

### #2: Using Complements and Unions

Let $U=\{1,2,3,4,5,6\}$, $A=\{1,2,3\}$, and $B=\{3,4,5\}$. Find $(A\cup B)'$ relative to $U$.

**Solution:**

Find the union first:

$$A\cup B=\{1,2,3,4,5\}$$

The only element of $U$ outside that union is $6$.

$$(A\cup B)'=\{6\}$$

## Traps to Watch For

### #1: Reading "And" vs. Inclusive "Or"

In standard set language, "and" corresponds to intersection, while inclusive "or" corresponds to union. Natural-language questions can be ambiguous, so use the problem's stated definitions when needed.
