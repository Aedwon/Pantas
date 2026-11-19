---
_id: "lesson-statistics-and-probability-adding-counts-with-overlap"
title: "Adding Counts With Overlap"
summary: "Count outcomes in either group and subtract any overlap."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 5
partCount: 5
ordering: 0
keyPoints:
  - "Add separate groups of outcomes."
  - "Subtract outcomes counted in both groups."
---
## Core Concept

### Adding Separate Groups

Sometimes an outcome comes from one group or from another group, not from both. If no outcome belongs to both groups, add the two counts.

If some outcomes belong to both groups, adding counts those outcomes twice. Subtract the number of outcomes that belong to both:

$$\text{outcomes in group A or group B}=\text{A}+\text{B}-\text{both}$$

If no outcome is in both groups, "both" is $0$ and the rule is plain addition.

<!-- ILLUSTRATION: two overlapping circles labeled "Basketball: 12 students" and "Volleyball: 9 students", with the overlap labeled "Both: 5 students" and a question mark labeled "Students in at least one sport" -->

## Examples

### #1: Adding Separate Groups

A club has $5$ boys and $4$ girls. How many committees of $3$ members are made of all boys or all girls?

**Solution:**
1. A committee cannot be all boys and all girls at the same time, so the two groups share no committee. Add the counts.

$$C(5,3)+C(4,3)=10+4$$

2. Add.

$$10+4=14$$

3. There are $14$ such committees.

### #2: Groups That Overlap

In a class, $12$ students play basketball and $9$ play volleyball. Of these, $5$ students play both sports. How many students play at least one of the two sports?

**Solution:**
1. The $5$ students who play both are counted in the $12$ and again in the $9$. Adding $12+9$ counts them twice.
2. Subtract them once.

$$12+9-5=16$$

3. Sixteen students play at least one sport.

## Traps to Watch For

### #1: Adding When You Should Multiply, or the Reverse

> Multiply when one outcome needs a choice at every stage. Add when one outcome comes from just one of several separate groups.

Choosing a sandwich and a drink needs both choices, so multiply. Choosing a sandwich or a drink as a single item adds the counts, if no item is in both groups. Decide what one outcome looks like before choosing an operation.

### #2: Adding Overlapping Groups Without Subtracting

> If some outcomes belong to both groups, adding the two counts counts them twice.

In Example #10, $12+9=21$ is too large, because $5$ students are in both groups. Subtract the overlap once to get $16$.
