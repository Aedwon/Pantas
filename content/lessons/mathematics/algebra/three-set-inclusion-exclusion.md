---
_id: "lesson-algebra-three-set-inclusion-exclusion"
title: "Three-Set Inclusion-Exclusion"
summary: "Find a three-set union and check the total against the separate regions."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 1
partCount: 1
ordering: 6
keyPoints:
  - "Find a three-set union and check the total against the separate regions."
---
## Core Concept

### Counting with three sets

For three sets, add the three sets, subtract the three pair overlaps, and add back the triple overlap:

$$|A\cup B\cup C|=|A|+|B|+|C|-|A\cap B|-|B\cap C|-|A\cap C|+|A\cap B\cap C|$$

Many problems are easier with a **Venn diagram**. It draws each set as a circle inside a rectangle for $U$. Each part of the picture is one region. The next sections show how to fill the regions.

For a three-set problem, work from the inside out: the center first, then the pair-only regions, then the single-set regions, then the outside.

## Examples

### #1: Three-Circle Venn Diagram Word Problem

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
