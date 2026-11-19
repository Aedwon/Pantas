---
_id: "lesson-statistics-and-probability-counting-teams-and-ordered-roles"
title: "Counting Teams and Ordered Roles"
summary: "Decide where order matters when a count has several stages."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 4
partCount: 5
ordering: 18
keyPoints:
  - "Distinguish ordered roles from unordered teams."
  - "Multiply counts across selection stages."
---
## Core Concept

### Ordered or Unordered?

Ask one question: if the same selected objects appear in a different order, is that a different outcome? If yes, use an ordered count such as a permutation. If no, use a combination.

Some problems say whether one person may hold two roles. If the problem says nothing, read different roles as going to different people, so the second role has one fewer choice. If the problem allows one person to hold both, the second role keeps all $n$ choices.

## Examples

### #1: Ordered Roles vs. Unordered Team

From a club of $10$ members, assume no person may hold both roles. (a) In how many ways can a president and a vice president be chosen? (b) In how many ways can a $2$-member committee with no roles be chosen?

**Solution:**
1. President and vice president are different roles, so order matters.

$$10\times9=90$$

2. For a two-person committee, choosing Ana then Ben gives the same committee as choosing Ben then Ana, so order does not matter.

$$C(10,2)=\dfrac{10\times9}{2}=45$$

3. The answers are $90$ ways to fill the two offices and $45$ possible committees.

### #2: Combinations Chosen in Stages

A club has $5$ boys and $4$ girls. How many committees of $3$ members have exactly $2$ boys and $1$ girl?

**Solution:**
1. Choose the boys and choose the girl. Both choices must be made, so multiply the counts. Order does not matter within each group.

$$C(5,2)\times C(4,1)=10\times4$$

2. Multiply.

$$10\times4=40$$

3. There are $40$ such committees.

## Speed Tricks & Shortcuts

Words such as "arrange" or "ranking" and named positions usually mean order matters. Words such as "committee" or "team" often mean order does not matter, unless the problem gives different roles within the group. Then confirm with the question: does a different order make a different outcome?
