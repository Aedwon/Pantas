---
_id: "lesson-algebra-set-elements-and-subsets"
title: "Set Elements and Subsets"
summary: "Read membership symbols and recognize the empty set."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 2
keyPoints:
  - "Read membership symbols and recognize the empty set."
  - "Identify subsets and proper subsets."
---
## Core Concept

The symbol $\in$ means "is an element of". The symbol $\notin$ means "is not an element of". For $A=\{1,2,3\}$, we write $2\in A$ and $5\notin A$.

Set $B$ is a **subset** of set $A$ when every element of $B$ is also in $A$. We write $B\subseteq A$. If $B$ is a subset of $A$ but not equal to $A$, then $B$ is a **proper subset**, written $B\subset A$. Some books use $\subset$ for any subset, so check the book's meaning.

Do not mix up $\in$ and $\subseteq$. The symbol $\in$ links an element to a set. The symbol $\subseteq$ links a set to a set. For $A=\{1,2,3\}$, $2\in A$ is true and $\{2\}\subseteq A$ is true. Writing $2\subseteq A$ is not correct.

The **empty set** has no elements. It is written $\varnothing$ or $\{\ \}$. The set $\{0\}$ is not empty, because it has one element, the number $0$. The set $\{\varnothing\}$ is not empty either, because its one element is the empty set.

Two facts follow from the meaning. Every set is a subset of itself. The empty set is a subset of every set, because it has no element that could fail to be in the other set.

## Examples

### #1: Membership and Subsets

Let $A=\{2,4,6,8\}$, $B=\{2,4\}$ and $C=\{4,6,10\}$. Decide whether each statement is true or false: (a) $6\in A$, (b) $B\subseteq A$, (c) $C\subseteq A$, (d) $\{8\}\subseteq A$, (e) $\varnothing\subseteq C$, (f) $A\subseteq A$.

**Solution:**

1. (a) is true. The number $6$ is an element of $A$.
2. (b) is true. The elements $2$ and $4$ are both in $A$.
3. (c) is false. The element $10$ is in $C$ but not in $A$.
4. (d) is true. The one element of $\{8\}$ is in $A$.
5. (e) is true. The empty set is a subset of every set.
6. (f) is true. Every set is a subset of itself.

Statement (f) is true, but $A\subset A$ would be false, because a proper subset must be different from $A$.

## Traps to Watch For

### #1: Mixing Up $\in$ and $\subseteq$

> An element belongs to a set. A set is a subset of a set.

For $A=\{1,2,3\}$, $1\in A$ and $\{1\}\subseteq A$ are correct. The statement $1\subseteq A$ is not.

### #2: Empty Sets That Are Not Empty

> $\{0\}$ and $\{\varnothing\}$ each have one element.

Their cardinality is $1$, not $0$. Only a set with no elements at all is empty.
