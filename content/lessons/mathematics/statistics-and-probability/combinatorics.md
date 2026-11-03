---
_id: "lesson-statistics-and-probability-combinatorics"
title: "Combinatorics"
summary: "How to count arrangements and selections using the counting principle, addition of separate groups, permutations, and combinations."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 14
isActive: true
---
## Core Concept

Combinatorics counts the possible outcomes of a situation without listing each one. An **outcome** is one complete result, such as one outfit or one team.

The formulas below count objects that can be told apart from one another. We call such objects **distinct**. Counting objects that repeat, such as the letters of a word with two equal letters, needs other methods that this lesson does not cover.

### Factorial

For a whole number $n\ge1$, the **factorial** of $n$ is the product of all whole numbers from $n$ down to $1$:

$$n!=n(n-1)(n-2)\cdots2\cdot1$$

For example, $4!=4\times3\times2\times1=24$. We define $0!=1$ so that the formulas below still work when no objects are left over.

### Fundamental Counting Principle

Some outcomes are built in stages, such as choosing a shirt and then choosing pants. Suppose the first stage can be done in $m$ ways. Suppose the second stage can be done in $n$ ways, whichever first choice was made. Then the two stages together give $mn$ outcomes.

Choosing one of $4$ shirts and one of $3$ pairs of pants gives:

$$4\times3=12$$

outfits.

<!-- FIGURE: {"kind": "concept-diagram", "type": "tree", "root": "Outfits", "branches": [{"name": "Shirt 1", "leaves": 3}, {"name": "Shirt 2", "leaves": 3}, {"name": "Shirt 3", "leaves": 3}, {"name": "Shirt 4", "leaves": 3}], "totalLeaves": 12, "semanticsLabel": "A tree diagram with 4 shirt branches each splitting into 3 pants branches for a total of 12 leaf outfits."} -->

The same rule extends to any number of stages: multiply the number of ways at each stage. Use it when one outcome needs a choice at every stage, that is, a choice at stage one and a choice at stage two and so on.

### Adding Separate Groups

Sometimes an outcome comes from one group or from another group, not from both. If no outcome belongs to both groups, add the two counts.

If some outcomes belong to both groups, adding counts those outcomes twice. Subtract the number of outcomes that belong to both:

$$\text{outcomes in group A or group B}=\text{A}+\text{B}-\text{both}$$

If no outcome is in both groups, "both" is $0$ and the rule is plain addition.

<!-- ILLUSTRATION: two overlapping circles labeled "Basketball: 12 students" and "Volleyball: 9 students", with the overlap labeled "Both: 5 students" and a question mark labeled "Students in at least one sport" -->

### Permutations

A **permutation** is an ordered selection: the same objects in a different order count as a different outcome. To choose and arrange $r$ of $n$ distinct objects, with no object used twice, there are $n$ choices for the first place, then $n-1$ for the second, and so on for $r$ places.

Multiplying these gives:

$$P(n,r)=\dfrac{n!}{(n-r)!}$$

where $0\le r\le n$. The right side is the product of $r$ factors that start at $n$ and go down by $1$ each time. For example:

$$P(7,3)=7\times6\times5=210$$

Two boundary cases check the formula. Arranging all $n$ objects gives $P(n,n)=\dfrac{n!}{0!}=n!$. Choosing none gives $P(n,0)=1$, one way to arrange nothing.

### Combinations

A **combination** is an unordered selection: the same objects in a different order are the same outcome. A permutation counts each group of $r$ objects once for every order it can be arranged in, and there are $r!$ such orders.

So the number of groups is the permutation count divided by $r!$:

$$C(n,r)=\dfrac{n!}{r!(n-r)!}$$

This holds for $0\le r\le n$, for distinct objects used at most once. For example, $C(n,n)=1$ and $C(n,0)=1$: there is one way to take everything and one way to take nothing. Both need $0!=1$.

### Ordered or Unordered?

Ask one question: if the same selected objects appear in a different order, is that a different outcome? If yes, use an ordered count such as a permutation. If no, use a combination.

### Repetition and Roles

The formulas above never use the same object twice. If a problem allows reuse, go back to the counting principle. With $n$ choices at each of $r$ positions and reuse allowed, there are $n^r$ ordered outcomes.

The problem must also tell you whether one person may hold two roles. If it does not allow this, the second role has one fewer choice.

## Examples

### #1: Counting Principle

A canteen offers $4$ sandwiches, $3$ drinks, and $2$ desserts. How many different meals consisting of one sandwich, one drink, and one dessert are possible?

**Solution:**
Each sandwich can be paired with each drink and each dessert, so multiply the three counts.

$$4\times3\times2=24$$

There are $24$ possible meals.

### #2: Repetition and No Repetition

How many $4$-digit PIN codes use four different decimal digits? Treat a leading zero as allowed because these are codes, not four-digit integers. How many codes are there if digits may repeat?

**Solution:**
1. With no repeats, there are $10$ choices for the first position. Each later position has one fewer choice, because the used digits are removed.

$$10\times9\times8\times7=5040$$

2. If digits may repeat, each of the $4$ positions has $10$ choices.

$$10^4=10000$$

3. There are $5040$ codes with different digits and $10000$ codes if repeats are allowed.

### #3: Permutation

A shelf has room for $3$ books. In how many ways can you arrange $3$ books chosen from $5$ different books?

**Solution:**
The positions on the shelf are in order, so a different order is a different arrangement.

$$P(5,3)=5\times4\times3=60$$

There are $60$ arrangements.

### #4: Arranging All the Objects

In how many ways can $5$ different students line up in a row for a photo?

**Solution:**
1. All $5$ students are used, so $r=n=5$.

$$P(5,5)=\dfrac{5!}{0!}=5!$$

2. Multiply the factors of $5!$.

$$5\times4\times3\times2\times1=120$$

3. There are $120$ ways to line up.

### #5: Combination

A teacher must pick $3$ students from a class of $8$ to form a quiz team, with no assigned roles. How many different teams are possible?

**Solution:**
The order of choosing does not change the team, so use a combination.

$$C(8,3)=\dfrac{8!}{3!5!}=\dfrac{8\times7\times6}{3\times2\times1}=56$$

There are $56$ possible teams.

### #6: Choosing the Ones Left Out

From $12$ students, a teacher picks $10$ to join a field trip. How many different groups of $10$ can go?

**Solution:**
1. Choosing the $10$ who go is the same as choosing the $2$ who stay. Each group of $10$ matches exactly one group of $2$, so $C(12,10)=C(12,2)$.
2. Work with the smaller number.

$$C(12,2)=\dfrac{12\times11}{2\times1}=66$$

3. There are $66$ possible groups.

### #7: Ordered Roles vs. Unordered Team

From a club of $10$ members, assume no person may hold both roles. (a) In how many ways can a president and a vice president be chosen? (b) In how many ways can a $2$-member committee with no roles be chosen?

**Solution:**
1. President and vice president are different roles, so order matters.

$$10\times9=90$$

2. For a two-person committee, choosing Ana then Ben gives the same committee as choosing Ben then Ana, so order does not matter.

$$C(10,2)=\dfrac{10\times9}{2}=45$$

3. The answers are $90$ ways to fill the two offices and $45$ possible committees.

### #8: Combinations Chosen in Stages

A club has $5$ boys and $4$ girls. How many committees of $3$ members have exactly $2$ boys and $1$ girl?

**Solution:**
1. Choose the boys and choose the girl. Both choices must be made, so multiply the counts. Order does not matter within each group.

$$C(5,2)\times C(4,1)=10\times4$$

2. Multiply.

$$10\times4=40$$

3. There are $40$ such committees.

### #9: Adding Separate Groups

A club has $5$ boys and $4$ girls. How many committees of $3$ members are made of all boys or all girls?

**Solution:**
1. A committee cannot be all boys and all girls at the same time, so the two groups share no committee. Add the counts.

$$C(5,3)+C(4,3)=10+4$$

2. Add.

$$10+4=14$$

3. There are $14$ such committees.

### #10: Groups That Overlap

In a class, $12$ students play basketball and $9$ play volleyball. Of these, $5$ students play both sports. How many students play at least one of the two sports?

**Solution:**
1. The $5$ students who play both are counted in the $12$ and again in the $9$. Adding $12+9$ counts them twice.
2. Subtract them once.

$$12+9-5=16$$

3. Sixteen students play at least one sport.

## Speed Tricks & Shortcuts

To find $C(n,r)$ for $r\ge1$, write $r$ factors from $n$ downward on top and $r!$ on the bottom. This avoids expanding the full factorials:

$$C(8,3)=\dfrac{8\times7\times6}{3\times2\times1}=56$$

The symmetry rule is:

$$C(n,r)=C(n,n-r)$$

It holds for $0\le r\le n$. Choosing $r$ objects is the same as choosing the $n-r$ objects left out. When $r$ is more than half of $n$, calculate with $n-r$ instead.

Words such as "arrange" or "ranking" and named positions usually mean order matters. Words such as "committee" or "team" often mean order does not matter, unless the problem gives different roles within the group. Then confirm with the question: does a different order make a different outcome?

## Traps to Watch For

### #1: Counting an Unordered Group as Ordered

> If swapping the selected objects creates no new outcome, an ordered count is too large.

For a two-person committee with no roles, Ana-Ben and Ben-Ana are the same committee. The ordered count $90$ in Example #7 is twice the committee count $45$.

### #2: Adding When You Should Multiply, or the Reverse

> Multiply when one outcome needs a choice at every stage. Add when one outcome comes from just one of several separate groups.

Choosing a sandwich and a drink needs both choices, so multiply. Choosing a sandwich or a drink as a single item adds the counts, if no item is in both groups. Decide what one outcome looks like before choosing an operation.

### #3: Forgetting $0!=1$

> Zero factorial is defined as $1$, not $0$.

This keeps $C(n,n)=1$ and $P(n,n)=n!$ correct. If $0!$ were $0$, both formulas would divide by zero.

### #4: Repetition and Role Rules Must Be Read, Not Assumed

> Check the problem for whether an object may be reused and whether one person may hold two roles.

A code may allow repeated digits, and a selection problem may forbid repeats. In Example #7, if one person could hold both offices, the count would be $10\times10=100$ instead of $90$. Use only what the problem states.

### #5: Adding Overlapping Groups Without Subtracting

> If some outcomes belong to both groups, adding the two counts counts them twice.

In Example #10, $12+9=21$ is too large, because $5$ students are in both groups. Subtract the overlap once to get $16$.
