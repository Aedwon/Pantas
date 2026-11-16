---
_id: "lesson-algebra-set-membership-and-operations"
title: "Set Membership and Operations"
summary: "Use subsets, unions, intersections, and complements to describe set membership."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 2
ordering: 1
keyPoints:
  - "Identify set elements and subsets."
  - "Find unions, intersections, and complements."
---
## Core Concept

A **set** is a collection of distinct objects called **elements**. Sets are commonly written with curly braces, for example:

$$A=\{1,2,3\}.$$

The symbol $\in$ means "is an element of". The symbol $\notin$ means "is not an element of". For $A=\{1,2,3\}$, we write $2\in A$ and $5\notin A$.

Set $B$ is a **subset** of set $A$ when every element of $B$ is also in $A$. We write $B\subseteq A$. If $B$ is a subset of $A$ but not equal to $A$, then $B$ is a **proper subset**, written $B\subset A$. Some books use $\subset$ for any subset, so check the book's meaning.

Do not mix up $\in$ and $\subseteq$. The symbol $\in$ links an element to a set. The symbol $\subseteq$ links a set to a set. For $A=\{1,2,3\}$, $2\in A$ is true and $\{2\}\subseteq A$ is true. Writing $2\subseteq A$ is not correct.

The **empty set** has no elements. It is written $\varnothing$ or $\{\ \}$. The set $\{0\}$ is not empty, because it has one element, the number $0$. The set $\{\varnothing\}$ is not empty either, because its one element is the empty set.

Two facts follow from the meaning. Every set is a subset of itself. The empty set is a subset of every set, because it has no element that could fail to be in the other set.

A set with $n$ elements has $2^n$ subsets. This count includes the empty set and the set itself. Each element is either in a subset or out of it, which gives $2$ choices per element.

A **universal set** $U$ specifies the elements under consideration in a particular problem. If every element of $B$ is also an element of $A$, then $B$ is a subset of $A$.

The **union** $A\cup B$ contains elements that are in $A$, in $B$, or in both. The **intersection** $A\cap B$ contains only elements common to both sets. The **complement** of $A$ depends on the stated universal set and contains elements of $U$ that are not in $A$.

The prime mark means complement: $A'$ is the complement of $A$.

De Morgan's laws say $(A\cup B)'=A'\cap B'$ and $(A\cap B)'=A'\cup B'$, with all complements taken in the same universal set. Being outside the union means being outside both sets. Being outside the intersection means being outside at least one set.

Venn diagrams show these relationships visually.

Set-builder notation lists a rule instead of every element: $\{x\in\mathbb Z\mid -2\le x\le3\}$ means all integers from $-2$ through $3$. The symbol $\mathbb Z$ means the integers, and the bar means "such that." For $a>0$, the condition $x^2<a^2$ means $-a<x<a$, so $x^2<9$ gives $-3<x<3$.

The **difference** $A-B$ contains the elements that are in $A$ but not in $B$. Some books write it $A\setminus B$. It is not the same as $B-A$ in general. Also, $A-B$ is the same set as $A\cap B'$.

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

$$A\cup B=\{1,2,3,4,5\}$$

The only element of $U$ outside that union is $6$.

$$(A\cup B)'=\{6\}$$

## Traps to Watch For

### #1: Reading "And" vs. Inclusive "Or"

In standard set language, "and" corresponds to intersection, while inclusive "or" corresponds to union. Natural-language questions can be ambiguous, so use the problem's stated definitions when needed.
