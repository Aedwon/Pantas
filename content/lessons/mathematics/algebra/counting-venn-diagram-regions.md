---
_id: "lesson-algebra-counting-venn-diagram-regions"
title: "Counting Venn Diagram Regions"
summary: "Count separate regions in two-set and three-set Venn diagrams."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 2
partCount: 2
ordering: 2
keyPoints:
  - "Count two-set unions, overlaps, and neither regions."
  - "Count three-set regions from the center outward."
---
## Core Concept

The notation $|A|$ means the number of elements in set $A$.

For two finite sets, inclusion-exclusion gives:

$$|A\cup B|=|A|+|B|-|A\cap B|.$$

This counts the number in **at least one** of the two sets. It is not automatically the size of the whole universal set because some elements may belong to neither set.

If a problem also states that everyone in the universal set belongs to $A$ or $B$, then $|U|=|A\cup B|$ and the overlap can be found from:

$$|A\cap B|=|A|+|B|-|U|.$$

Without that coverage condition, you also need the number belonging to neither set.

For three-set problems, start with the center, then pairwise-only overlaps, then single-set regions.

## Examples

### #1: Two-Circle Venn Diagram Word Problem

In a class of $40$ students, $25$ are enrolled in Chemistry, $18$ in Physics, and $8$ in both. How many are enrolled in neither?

**Solution:**

1. Chemistry only:

$$25-8=17$$

2. Physics only:

$$18-8=10$$

3. In at least one of the two subjects:

$$17+8+10=35$$

4. Neither:

$$40-35=5$$

<!-- FIGURE: {"kind": "concept-diagram", "type": "venn", "sets": ["Chemistry", "Physics"], "regions": {"left": "17", "overlap": "8", "right": "10", "outside": "5", "total": "40"}, "semanticsLabel": "A two-circle Venn diagram showing 17 in Chemistry only, 8 in both, 10 in Physics only, and 5 outside."} -->

### #2: Three-Circle Venn Diagram Word Problem

A survey of $100$ college applicants found that $45$ preferred Engineering, $40$ Business, and $35$ Computer Science. Also, $15$ preferred both Engineering and Business, $10$ both Business and Computer Science, $12$ both Engineering and Computer Science, and $5$ all three. Assume each stated pairwise count includes those who preferred all three. How many applicants preferred exactly one program?

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

<!-- FIGURE: {"kind": "concept-diagram", "type": "venn", "sets": ["Engineering", "Business", "Computer Science"], "center": "5", "overlaps": {"ab": "10", "bc": "5", "ca": "7"}, "singleRegions": {"a": "23", "b": "20", "c": "18"}, "semanticsLabel": "A three-circle Venn diagram showing 5 in the center, pairwise-only overlaps 10, 5, and 7, and single-program regions 23, 20, and 18."} -->

## Traps to Watch For

### #1: Forgetting the Neither Region

Elements may be outside all displayed circles while still belonging to the universal set.

### #2: Double Counting the Overlap

A statement such as "$20$ students take Math" normally includes students who take both Math and another subject unless the problem says "only Math." Account for the overlap before counting disjoint regions.
