---
_id: "lesson-algebra-sets-and-set-notation"
title: "Sets and Set Notation (Unions, Intersections, Subsets, Venn Diagrams)"
summary: "Group elements into sets, use set notation, and solve overlap problems with Venn diagrams."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 10
isActive: true
---
## Core Concept

A **set** is a collection of distinct objects called **elements**. Sets are commonly written with curly braces, for example:

$$A=\{1,2,3\}.$$

A **universal set** $U$ specifies the elements under consideration in a particular problem. If every element of $B$ is also an element of $A$, then $B$ is a subset of $A$.

The **union** $A\cup B$ contains elements that are in $A$, in $B$, or in both. The **intersection** $A\cap B$ contains only elements common to both sets. The **complement** of $A$ depends on the stated universal set and contains elements of $U$ that are not in $A$.

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

$$A\cup B=\{1,2,3,4,5\}$$

The only element of $U$ outside that union is $6$.

$$(A\cup B)'=\{6\}$$

### #3: Two-Circle Venn Diagram Word Problem

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

### #4: Three-Circle Venn Diagram Word Problem

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

## Speed Tricks & Shortcuts

For two finite sets, inclusion-exclusion gives:

$$|A\cup B|=|A|+|B|-|A\cap B|.$$

This counts the number in **at least one** of the two sets. It is not automatically the size of the whole universal set because some elements may belong to neither set.

If a problem also states that everyone in the universal set belongs to $A$ or $B$, then $|U|=|A\cup B|$ and the overlap can be found from:

$$|A\cap B|=|A|+|B|-|U|.$$

Without that coverage condition, you also need the number belonging to neither set.

For three-set problems, start with the center, then pairwise-only overlaps, then single-set regions.

## Traps to Watch For

### #1: Reading "And" vs. Inclusive "Or"

In standard set language, "and" corresponds to intersection, while inclusive "or" corresponds to union. Natural-language questions can be ambiguous, so use the problem's stated definitions when needed.

### #2: Forgetting the Neither Region

Elements may be outside all displayed circles while still belonging to the universal set.

### #3: Double Counting the Overlap

A statement such as "$20$ students take Math" normally includes students who take both Math and another subject unless the problem says "only Math." Account for the overlap before counting disjoint regions.
