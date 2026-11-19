---
_id: "lesson-algebra-counting-elements-and-subsets"
title: "Counting Elements and Subsets"
summary: "Compare sets and count distinct elements."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 3
keyPoints:
  - "Compare sets and count distinct elements."
  - "List and count subsets and proper subsets."
---
## Core Concept

The order of the elements does not matter. A repeated element counts once, so $\{1,2,2,3\}$ is the same set as $\{1,2,3\}$. Two sets are **equal** when they have exactly the same elements.

The **cardinality** of a finite set is the number of elements in it. It is written with vertical bars: $|A|$. For $A=\{1,2,3\}$, we have $|A|=3$. For the empty set, $|\varnothing|=0$.

A set with $n$ elements has $2^n$ subsets. This count includes the empty set and the set itself. Each element is either in a subset or out of it, which gives $2$ choices per element.

## Speed Tricks & Shortcuts

To count the subsets of a set with $n$ elements, use $2^n$. To count the proper subsets, use $2^n-1$.

## Examples

### #1: Cardinality and Number of Subsets

Let $S=\{a,b,c,a,b\}$. Find $|S|$, then list all subsets of $S$.

**Solution:**

1. The repeats count once, so $S=\{a,b,c\}$ and $|S|=3$.
2. List the subsets by size. Size $0$ is the empty set. Size $1$ gives three sets. Size $2$ gives three sets. Size $3$ gives one set.

$$\varnothing,\ \{a\},\ \{b\},\ \{c\},\ \{a,b\},\ \{a,c\},\ \{b,c\},\ \{a,b,c\}$$

3. Count them: $1+3+3+1=8$. This matches $2^3=8$.

A set with $3$ elements has $8$ subsets and $7$ proper subsets.
