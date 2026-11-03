---
_id: "lesson-algebra-sets-and-set-notation"
title: "Sets and Set Notation (Unions, Intersections, Subsets, Venn Diagrams)"
summary: "Write sets and their symbols, test subsets, count elements, and solve overlap problems with Venn diagrams."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **set** is a collection of distinct objects. The objects are called **elements**. A set is written with curly braces:

$$A=\{1,2,3\}$$

The order of the elements does not matter. A repeated element counts once, so $\{1,2,2,3\}$ is the same set as $\{1,2,3\}$. Two sets are **equal** when they have exactly the same elements.

### Membership and the empty set

The symbol $\in$ means "is an element of". The symbol $\notin$ means "is not an element of". For $A=\{1,2,3\}$, we write $2\in A$ and $5\notin A$.

The **empty set** has no elements. It is written $\varnothing$ or $\{\ \}$. The set $\{0\}$ is not empty, because it has one element, the number $0$. The set $\{\varnothing\}$ is not empty either, because its one element is the empty set.

### Cardinality

The **cardinality** of a finite set is the number of elements in it. It is written with vertical bars: $|A|$. For $A=\{1,2,3\}$, we have $|A|=3$. For the empty set, $|\varnothing|=0$.

### Universal set and subsets

A **universal set** $U$ holds all the elements under consideration in one problem. The sets in the problem are taken from $U$.

Set $B$ is a **subset** of set $A$ when every element of $B$ is also in $A$. We write $B\subseteq A$. If $B$ is a subset of $A$ but not equal to $A$, then $B$ is a **proper subset**, written $B\subset A$. Some books use $\subset$ for any subset, so check the book's meaning.

Two facts follow from the meaning. Every set is a subset of itself. The empty set is a subset of every set, because it has no element that could fail to be in the other set.

Do not mix up $\in$ and $\subseteq$. The symbol $\in$ links an element to a set. The symbol $\subseteq$ links a set to a set. For $A=\{1,2,3\}$, $2\in A$ is true and $\{2\}\subseteq A$ is true. Writing $2\subseteq A$ is not correct.

A set with $n$ elements has $2^n$ subsets. This count includes the empty set and the set itself. Each element is either in a subset or out of it, which gives $2$ choices per element.

### Union, intersection, complement and difference

The **union** $A\cup B$ contains the elements that are in $A$, in $B$, or in both.

The **intersection** $A\cap B$ contains the elements that are in both sets. If $A\cap B=\varnothing$, the sets are **disjoint**.

The **complement** of $A$ is written $A'$. It contains the elements of $U$ that are not in $A$. It depends on the universal set that the problem states.

The **difference** $A-B$ contains the elements that are in $A$ but not in $B$. Some books write it $A\setminus B$. It is not the same as $B-A$ in general. Also, $A-B$ is the same set as $A\cap B'$.

### Counting with two sets

The union counts each element once. Adding $|A|$ and $|B|$ counts the elements of $A\cap B$ twice, so we subtract them once:

$$|A\cup B|=|A|+|B|-|A\cap B|$$

This gives the number in at least one of the two sets. It equals $|U|$ only when every element of $U$ is in $A$ or $B$. Otherwise some elements are in neither set, and

$$|U|=|A\cup B|+\text{(number in neither)}.$$

The difference has its own count:

$$|A-B|=|A|-|A\cap B|$$

### Counting with three sets

For three sets, add the three sets, subtract the three pair overlaps, and add back the triple overlap:

$$|A\cup B\cup C|=|A|+|B|+|C|-|A\cap B|-|B\cap C|-|A\cap C|+|A\cap B\cap C|$$

Many problems are easier with a **Venn diagram**. It draws each set as a circle inside a rectangle for $U$. Each part of the picture is one region. The next sections show how to fill the regions.

## Mnemonics & Memory Aids

> The symbol $\cup$ looks like the letter U, for union. The other symbol, $\cap$, is the intersection.

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

### #2: Using Complements and Unions

Let $U=\{1,2,3,4,5,6\}$, $A=\{1,2,3\}$ and $B=\{3,4,5\}$. Find $(A\cup B)'$ relative to $U$.

**Solution:**

1. Find the union.

$$A\cup B=\{1,2,3,4,5\}$$

2. The element of $U$ outside that union is $6$.

$$(A\cup B)'=\{6\}$$

### #3: Membership and Subsets

Let $A=\{2,4,6,8\}$, $B=\{2,4\}$ and $C=\{4,6,10\}$. Decide whether each statement is true or false: (a) $6\in A$, (b) $B\subseteq A$, (c) $C\subseteq A$, (d) $\{8\}\subseteq A$, (e) $\varnothing\subseteq C$, (f) $A\subseteq A$.

**Solution:**

1. (a) is true. The number $6$ is an element of $A$.
2. (b) is true. The elements $2$ and $4$ are both in $A$.
3. (c) is false. The element $10$ is in $C$ but not in $A$.
4. (d) is true. The one element of $\{8\}$ is in $A$.
5. (e) is true. The empty set is a subset of every set.
6. (f) is true. Every set is a subset of itself.

Statement (f) is true, but $A\subset A$ would be false, because a proper subset must be different from $A$.

### #4: Cardinality and Number of Subsets

Let $S=\{a,b,c,a,b\}$. Find $|S|$, then list all subsets of $S$.

**Solution:**

1. The repeats count once, so $S=\{a,b,c\}$ and $|S|=3$.
2. List the subsets by size. Size $0$ is the empty set. Size $1$ gives three sets. Size $2$ gives three sets. Size $3$ gives one set.

$$\varnothing,\ \{a\},\ \{b\},\ \{c\},\ \{a,b\},\ \{a,c\},\ \{b,c\},\ \{a,b,c\}$$

3. Count them: $1+3+3+1=8$. This matches $2^3=8$.

A set with $3$ elements has $8$ subsets and $7$ proper subsets.

### #5: Two-Circle Venn Diagram Word Problem

In a class of $40$ students, $25$ are enrolled in Chemistry, $18$ in Physics, and $8$ in both. How many are enrolled in neither?

<!-- FIGURE: {"kind": "concept-diagram", "type": "venn", "sets": ["Chemistry", "Physics"], "regions": {"left": "17", "overlap": "8", "right": "10", "outside": "5", "total": "40"}, "semanticsLabel": "A two-circle Venn diagram showing 17 in Chemistry only, 8 in both, 10 in Physics only, and 5 outside."} -->

**Solution:**

1. Chemistry only:

$$25-8=17$$

2. Physics only:

$$18-8=10$$

3. In at least one of the two subjects:

$$17+8+10=35$$

4. Neither:

$$40-35=5$$

The formula gives the same result: $|C\cup P|=25+18-8=35$, and $40-35=5$.

### #6: Finding the Overlap

Each of $50$ students joined at least one club, either Music or Sports. There are $30$ in Music and $28$ in Sports. How many joined both?

**Solution:**

1. Everyone is in at least one club, so $|M\cup S|=50$.
2. Use the union formula and solve for the overlap.

$$|M\cap S|=|M|+|S|-|M\cup S|$$

$$|M\cap S|=30+28-50=8$$

Eight students joined both clubs.

### #7: Three-Circle Venn Diagram Word Problem

A survey of $100$ college applicants found that $45$ preferred Engineering, $40$ Business, and $35$ Computer Science. Also, $15$ preferred both Engineering and Business, $10$ both Business and Computer Science, $12$ both Engineering and Computer Science, and $5$ all three. Assume each stated pairwise count includes those who preferred all three. How many applicants preferred exactly one program?

<!-- FIGURE: {"kind": "concept-diagram", "type": "venn", "sets": ["Engineering", "Business", "Computer Science"], "center": "5", "overlaps": {"ab": "10", "bc": "5", "ca": "7"}, "singleRegions": {"a": "23", "b": "20", "c": "18"}, "semanticsLabel": "A three-circle Venn diagram showing 5 in the center, pairwise-only overlaps 10, 5, and 7, and single-program regions 23, 20, and 18."} -->

**Solution:**

1. Pairwise-only regions are:

$$15-5=10$$

$$10-5=5$$

$$12-5=7$$

2. Exactly Engineering:

$$45-10-7-5=23$$

3. Exactly Business:

$$40-10-5-5=20$$

4. Exactly Computer Science:

$$35-7-5-5=18$$

5. Exactly one program:

$$23+20+18=61$$

As a check, the three-set formula gives $45+40+35-15-10-12+5=88$ applicants in at least one program. The other $12$ applicants preferred none of the three.

## Speed Tricks & Shortcuts

For a two-set problem, find the overlap first. Subtract it from each set to get the "only" regions. Then add the three parts.

For a three-set problem, work from the inside out: the center first, then the pair-only regions, then the single-set regions, then the outside.

If the problem says everyone in $U$ is in $A$ or $B$, then $|U|=|A\cup B|$. In that case the overlap is $|A\cap B|=|A|+|B|-|U|$. Without that statement, the outside region may not be empty, so use the number in neither set.

To count the subsets of a set with $n$ elements, use $2^n$. To count the proper subsets, use $2^n-1$.

## Traps to Watch For

### #1: Reading "And" vs. Inclusive "Or"

> "And" usually points to the intersection, and "or" usually points to the union.

In set language, "or" is inclusive: it includes elements in both sets. Everyday sentences can be less clear, so use the meaning the problem states.

### #2: Forgetting the Neither Region

> Elements outside all the circles can still belong to $U$.

Subtract the union from the total to find them. The result can be $0$, but check it instead of assuming it.

### #3: Double Counting the Overlap

> "$20$ take Math" usually includes students who also take another subject.

Unless the problem says "only Math", the count includes the overlap. Take the overlap out before you add the separate regions.

### #4: Mixing Up $\in$ and $\subseteq$

> An element belongs to a set. A set is a subset of a set.

For $A=\{1,2,3\}$, $1\in A$ and $\{1\}\subseteq A$ are correct. The statement $1\subseteq A$ is not.

### #5: Empty Sets That Are Not Empty

> $\{0\}$ and $\{\varnothing\}$ each have one element.

Their cardinality is $1$, not $0$. Only a set with no elements at all is empty.

### #6: Reversing a Difference

> $A-B$ and $B-A$ are usually different sets.

They are equal only when both are empty, which happens when $A=B$. In Example 1, $X-Y=\{1,7\}$ and $Y-X=\{2,8\}$. Read the order of the sets before you list elements.
