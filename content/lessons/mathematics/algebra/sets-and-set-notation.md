---
_id: "lesson-algebra-sets-and-set-notation"
title: "Sets and Set Notation (Unions, Intersections, Subsets, Venn Diagrams)"
summary: "How to group items into sets, read set symbols, and solve overlap puzzles using Venn diagrams."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 10
isActive: true
---
## Core Concept

A **set** is just a group of things. We call the things inside it **elements**. We write sets using curly braces.


$$A = \{ 1, 2, 3 \}$$


This means set $A$ has the numbers $1$, $2$, and $3$. Exam makers love sets because they test your logic. They want to see if you can find what different groups share.

The **Universal Set**, written as $U$, is the big box holding everything. A **subset** is a smaller group inside a bigger group. If every item in set $B$ is also in set $A$, then $B$ is a subset of $A$.

We combine sets in two main ways. The **Union** puts everything from both sets together into one big group. The **Intersection** takes only the items that both sets share. We also use **Venn diagrams**. These are overlapping circles that give us a picture of how sets mix.

## Mnemonics & Memory Aids

Here are simple ways to remember the symbols on exam day.

> For Union ($\cup$), think of a cup holding everything together. It looks like a "U" for "Unite."

> For Intersection ($\cap$), think of a bridge between two towns. It looks like an "n" for what they have "iN common."

> For Subset ($\subset$), think of a big mouth eating the smaller set. It looks like a "C" for "Contained in."

> For Complement ($A'$), think of the little mark as a stop sign. It means "Everything except A."

## Examples

### #1: Basic Set Operations

Given the sets $X = \{ 1, 3, 5, 7 \}$ and $Y = \{ 2, 3, 5, 8 \}$, determine the elements of $X \cap Y$.

**Solution:**

1. The symbol $\cap$ means intersection.
2. We need to find the items that live inside both sets at the same time.
3. Look at set $X$. Look at set $Y$.
4. The numbers $3$ and $5$ are inside both of them.
5. The answer is $\{ 3, 5 \}$.

### #2: Using Complements and Unions

Let the universal set $U = \{ 1, 2, 3, 4, 5, 6 \}$. If $A = \{ 1, 2, 3 \}$ and $B = \{ 3, 4, 5 \}$, find the set $(A \cup B)'$.

**Solution:**

1. First, solve what is inside the parentheses. Find $A \cup B$.
2. The symbol $\cup$ means union. Put everything from $A$ and $B$ together in one list.
3. We get $\{ 1, 2, 3, 4, 5 \}$. Do not write the number $3$ twice.
4. The little mark $'$ means complement. This means we want everything in $U$ that is not in our new list.
5. The only number in $U$ left over is $6$.
6. The answer is $\{ 6 \}$.

### #3: Two-Circle Venn Diagram Word Problem

In a class of $40$ students, $25$ students are enrolled in Chemistry, $18$ are enrolled in Physics, and $8$ are enrolled in both subjects. How many students are enrolled in neither Chemistry nor Physics?

<!-- FIGURE: {"kind": "concept-diagram", "type": "venn", "sets": ["Chemistry", "Physics"], "regions": {"left": "17", "overlap": "8", "right": "10", "outside": "5", "total": "40"}, "semanticsLabel": "A two-circle Venn diagram showing 17 in Chemistry only, 8 in both, 10 in Physics only, and 5 outside."} -->


**Solution:**

1. Draw two overlapping circles. One for Chemistry and one for Physics.
2. Always start in the exact middle. Put $8$ in the overlap part.
3. Now, find Chemistry only. The whole Chemistry circle is $25$. Subtract the $8$ we already placed.

$$25 - 8 = 17$$


4. Next, find Physics only. The whole Physics circle is $18$. Subtract the $8$ in the overlap.

$$18 - 8 = 10$$


5. Add everyone inside the circles together.

$$17 + 8 + 10 = 35$$


6. There are $40$ students total. Subtract the $35$ we just counted to find who is outside the circles.

$$40 - 35 = 5$$


7. The answer is $5$ students.

### #4: Three-Circle Venn Diagram Word Problem

A survey of $100$ college applicants revealed the following preferences for their degree programs: $45$ preferred Engineering, $40$ preferred Business, and $35$ preferred Computer Science. Furthermore, $15$ preferred both Engineering and Business, $10$ preferred both Business and Computer Science, $12$ preferred both Engineering and Computer Science, and $5$ preferred all three programs. How many applicants preferred exactly one degree program?

<!-- FIGURE: {"kind": "concept-diagram", "type": "venn", "sets": ["Engineering", "Business", "Computer Science"], "center": "5", "overlaps": {"ab": "10", "bc": "5", "ca": "7"}, "singleRegions": {"a": "filled", "b": "filled", "c": "filled"}, "semanticsLabel": "A three-circle Venn diagram showing overlaps of Engineering, Business, and Computer Science with 5 in the center."} -->


**Solution:**

1. We have three circles. Always start in the very center overlap. Put $5$ there.
2. Now work outward to the two-subject overlaps.
3. Both Engineering and Business is $15$. Subtract the $5$ in the center. That leaves $10$.
4. Both Business and Computer Science is $10$. Subtract $5$. That leaves $5$.
5. Both Engineering and Computer Science is $12$. Subtract $5$. That leaves $7$.
6. Next, find the people who want only one subject.
7. Engineering total is $45$. Subtract the three pieces already sitting inside its circle.

$$45 - 10 - 5 - 7 = 23$$


8. Business total is $40$. Subtract its pieces.

$$40 - 10 - 5 - 5 = 20$$


9. Computer Science total is $35$. Subtract its pieces.

$$35 - 7 - 5 - 5 = 18$$


10. The question asks for people who prefer exactly one program. Add these three single parts.

$$23 + 20 + 18 = 61$$


11. The answer is $61$ applicants.

## Speed Tricks & Shortcuts

For two-circle problems, you do not always need a drawing. Use the **Overlap Formula**.


$$Total = Group A + Group B - Overlap$$

If you add the total of the first group and the total of the second group, you count the shared people twice. Subtract the overlap once to fix this.

If a problem gives you the total people, the number in group $A$, and the number in group $B$, you can find the overlap fast. Add $A$ and $B$, then subtract the total people.

For three-circle problems, always work from the inside out. Start at the very center overlap. Then do the two-circle overlaps. Finally, do the outer single pieces.

## Traps to Watch For

### #1: Misreading "And" vs. "Or"

Exam makers try to confuse you with basic words. "And" means intersection. "Or" means union.

> If the test says "A and B", find the overlap ($\cap$). If it says "A or B", find the total of both groups combined ($\cup$).

### #2: Forgetting the "Neither" Group

Sometimes, not everything belongs inside a circle. There might be items outside the circles but still inside the universal box.

> Always check if the items in your circles add up to the universal total. The missing number is your "neither" group.

### #3: Double Counting the Overlap

If a problem says "$20$ students take Math", this includes the students taking Math and Science. It does not mean "$20$ students take only Math."

> Unless the test specifically uses the word "only," you must subtract the overlap from the total group size.
