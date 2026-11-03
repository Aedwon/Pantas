---
_id: "lesson-algebra-systems-of-equations"
title: "Systems of Linear and Non-Linear Equations (Substitution, Elimination, Graphing)"
summary: "How to find the values that make two equations true at the same time, by substitution, elimination, or graphing."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 14
isActive: true
---
## Core Concept

An **equation** says that two expressions are equal. A **variable** is a letter, like $x$ or $y$, that stands for an unknown number. A **system of equations** is a group of two or more equations that share the same variables.

To solve the system means to find the values that make all the equations true at the same time. With two variables, a solution is an **ordered pair** $(x, y)$: the $x$ value first, then the $y$ value. The pair is also a point on the coordinate plane.

Think of it like finding a meeting place. Each equation is a road. The solution is the spot where the roads cross.

There are three main ways to solve a system.

### Substitution

**Substitution** means solving one equation for one variable, then putting that expression into the other equation. To substitute means to replace a letter with something equal to it.

Use it when one equation already has a lonely variable, like $y = x + 1$. After you find one variable, put its value back into either equation to find the other.

### Elimination

**Elimination** means adding or subtracting the equations so that one variable disappears. Add and subtract the whole equations: left side with left side, right side with right side. This is allowed because you are adding equal amounts to equal amounts.

A **coefficient** is the number multiplied by a variable. In $2x + 3y = 12$, the coefficients are $2$ and $3$.

- If the coefficients of one variable are opposites, like $+3y$ and $-3y$, add the equations.
- If they are equal, like $+10y$ and $+10y$, subtract the equations.
- If they are neither, multiply a whole equation by a nonzero number first. Multiply every term, including the number on the right side. Choose the number that makes the coefficients match.

### Graphing

**Graphing** means drawing both equations as graphs on the same coordinate plane. A point on a graph makes its equation true. So a point on both graphs makes both equations true, and that crossing point is the solution.

To draw a line, you need two points. Two easy ones are the **intercepts**: the $x$-intercept is where the line crosses the $x$-axis ($y = 0$), and the $y$-intercept is where it crosses the $y$-axis ($x = 0$).

Some lines do not give two intercepts. The line $y = 2x$ passes through the origin, so both intercepts are $(0, 0)$. The lines $y = 3$ and $x = 3$ have only one intercept each.

For these lines, pick another $x$ value and find its $y$ value to get a second point.

If the line is not vertical, you can also rewrite the equation as $y = mx + b$. Here $m$ is the **slope**, how many units the line goes up (or down, if negative) for each $1$ unit to the right.

The number $b$ is the $y$-intercept. A vertical line, like $x = 3$, has no slope and cannot be written this way.

The steps are:

1. Draw both graphs on the same plane.
2. Read the coordinates of the crossing point.
3. Check the pair in both original equations.

Reading a graph is exact only when the crossing sits clearly on grid lines. If the lines cross between grid lines, the reading is only an estimate, so use substitution or elimination to get the exact answer.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "system", "points": [[3, 4]], "formula": "Crossing at (3, 4)", "semanticsLabel": "A coordinate graph with two lines intersecting at the point (3, 4)."} -->

### How many solutions?

Two lines can be related in three ways, so a linear system of two equations in two variables has one of three outcomes.

- **One solution**: the lines cross at exactly one point. If neither line is vertical, their slopes are different.
- **No solution**: the lines are parallel, so they never touch. Two parallel lines that are not vertical have the same slope but different $y$-intercepts. Two vertical lines, like $x = 1$ and $x = 2$, are also parallel.
- **Infinitely many solutions**: both equations describe the same line. Every point on the line is a solution.

You can often tell from the equations. If one equation is the other multiplied by a nonzero number on every term, including the right side, it is the same line. If the left sides match this way but the right sides do not, the lines are parallel.

### Non-linear systems

A **non-linear system** has at least one equation whose graph is not a straight line. One example is a **parabola**, the U-shaped graph of an equation like $y = x^2 - 4$.

A curve can meet a line in more places than another line can. A line can cross a parabola at two points, touch it at one point, or miss it. So a non-linear system can have no solution, one, two, or more.

A curve can meet a line in even more places. The curve $y = x^3$ and the line $y = x$ meet at three points: $(-1, -1)$, $(0, 0)$ and $(1, 1)$.

CETs like to hide systems inside word problems. If a problem gives two facts about two unknown amounts, it is a system in disguise.

## Examples

### #1: Substitution

Solve the system: $y = x + 1$ and $x + y = 7$.

**Solution:**
The first equation already tells us what $y$ is. So we replace $y$ with $x + 1$ in the second equation.

1. Replace $y$ in the second equation.

$$x + (x + 1) = 7$$

2. Combine the like terms. These are terms with the same variable, like $x$ and $x$.

$$2x + 1 = 7$$

3. Subtract $1$ from both sides, then divide by $2$.

$$2x = 6$$

$$x = 3$$

4. Find $y$ using the first equation.

$$y = 3 + 1 = 4$$

5. The solution is $x = 3$ and $y = 4$, or the point $(3, 4)$. Check: $4 = 3 + 1$ is true, and $3 + 4 = 7$ is true.

### #2: Elimination by Adding

Solve the system: $2x + 3y = 12$ and $4x - 3y = 6$.

**Solution:**
The $y$ terms are $+3y$ and $-3y$. They are opposites, so adding the equations cancels them.

1. Add the two equations, left side plus left side, right side plus right side.

$$(2x + 3y) + (4x - 3y) = 12 + 6$$

2. The $3y$ and $-3y$ cancel.

$$6x = 18$$

3. Divide both sides by $6$.

$$x = 3$$

4. Substitute $x = 3$ into the first equation.

$$2(3) + 3y = 12$$

$$3y = 6$$

$$y = 2$$

5. The solution is $(3, 2)$. Check: $2(3) + 3(2) = 12$ and $4(3) - 3(2) = 6$. Both are true.

### #3: Elimination with Multiplication

Solve the system: $3x + 2y = 16$ and $2x + 5y = 18$.

**Solution:**
No variable has equal or opposite coefficients, so multiply first. We make both $y$ coefficients equal to $10$, the smallest number that both $2$ and $5$ divide into.

1. Multiply the first equation by $5$. Every term changes.

$$15x + 10y = 80$$

2. Multiply the second equation by $2$.

$$4x + 10y = 36$$

3. Both have $+10y$, so subtract the second equation from the first. Subtract every term.

$$(15x + 10y) - (4x + 10y) = 80 - 36$$

$$11x = 44$$

4. Divide both sides by $11$.

$$x = 4$$

5. Substitute $x = 4$ into $3x + 2y = 16$.

$$3(4) + 2y = 16$$

$$2y = 4$$

$$y = 2$$

6. The solution is $(4, 2)$. Check: $3(4) + 2(2) = 16$ and $2(4) + 5(2) = 18$. Both are true.

### #4: Solving by Graphing

Solve by graphing: $x + y = 5$ and $y = 2x - 1$.

**Solution:**
Find two points for each line, plot them, and draw each line.

1. For $x + y = 5$, find the intercepts. When $x = 0$, $y = 5$. When $y = 0$, $x = 5$. Plot $(0, 5)$ and $(5, 0)$.

2. For $y = 2x - 1$, the $y$-intercept is $-1$ and the slope is $2$. Plot $(0, -1)$, then go right $1$ and up $2$ to plot $(1, 1)$. Going again gives $(2, 3)$.

3. Draw both lines. They cross at $(2, 3)$.

4. Check in both equations.

$$2 + 3 = 5 \qquad 3 = 2(2) - 1$$

Both are true, so the solution is $(2, 3)$.

<!-- ILLUSTRATION: coordinate plane, x and y from -2 to 6; line x + y = 5 through (0, 5) and (5, 0); line y = 2x - 1 through (0, -1), (1, 1) and (2, 3); the two lines cross at the labeled point (2, 3) -->

### #5: One, No, or Infinitely Many Solutions

What happens when you solve each system?

(a) $2x + y = 5$ and $2x + y = 9$

(b) $2x + y = 5$ and $4x + 2y = 10$

**Solution:**
Try elimination on each one.

1. For (a), the coefficients of both variables match, so subtract.

$$(2x + y) - (2x + y) = 5 - 9$$

$$0 = -4$$

2. This is false for every $x$ and $y$. So (a) has no solution. Written as $y = -2x + 5$ and $y = -2x + 9$, the lines have the same slope $-2$ but different $y$-intercepts. They are parallel.

3. For (b), multiply the first equation by $2$. Every term changes.

$$4x + 2y = 10$$

4. This is the second equation exactly. Subtracting the equations gives $0 = 0$, which is always true. So (b) has infinitely many solutions: every point on the line.

5. Examples of solutions of (b) are $(0, 5)$ and $(1, 3)$. Check $(1, 3)$: $2(1) + 3 = 5$ and $4(1) + 2(3) = 10$. Both are true.

<!-- ILLUSTRATION: coordinate plane with two parallel lines y = -2x + 5 and y = -2x + 9, y-intercepts labeled 5 and 9, no crossing -->

### #6: A System Hiding in a Word Problem

A movie house sold $50$ tickets. Adult tickets cost $100$ pesos and child tickets cost $60$ pesos. The total sales were $4{,}200$ pesos. How many adult tickets were sold?

**Solution:**
There are two facts and two unknowns. Let $a$ be the number of adult tickets and $c$ the number of child tickets.

1. The ticket count gives the first equation.

$$a + c = 50$$

2. The money gives the second equation.

$$100a + 60c = 4200$$

3. From the first equation, $c = 50 - a$. Substitute this into the money equation.

$$100a + 60(50 - a) = 4200$$

4. Distribute the $60$.

$$100a + 3000 - 60a = 4200$$

5. Combine like terms and solve.

$$40a = 1200$$

$$a = 30$$

6. There were $30$ adult tickets, so $c = 20$. Check: $30 + 20 = 50$ tickets, and $100(30) + 60(20) = 3000 + 1200 = 4200$ pesos. Both are true.

### #7: A Line Meets a Parabola

Solve the non-linear system: $y = x^2 - 4$ and $y = 3x - 6$.

**Solution:**
Both equations equal $y$, so their right sides are equal to each other.

1. Set the two right sides equal.

$$x^2 - 4 = 3x - 6$$

2. Move everything to one side to get a **quadratic equation**. This is an equation whose highest power of the variable is $x^2$.

$$x^2 - 3x + 2 = 0$$

3. Factor the quadratic. To **factor** means to write it as a product of brackets. To find the brackets, look for two numbers that multiply to $2$ and add to $-3$. These are $-1$ and $-2$, so the quadratic is $(x - 1)(x - 2)$. The Quadratic Equations lesson teaches this in full.

$$(x - 1)(x - 2) = 0$$

4. If a product is zero, one of its factors is zero. So $x - 1 = 0$ or $x - 2 = 0$, which gives $x = 1$ or $x = 2$. These two values are the **roots** of the quadratic. Find $y$ for each using $y = 3x - 6$.

$$x = 1: \quad y = 3(1) - 6 = -3$$

$$x = 2: \quad y = 3(2) - 6 = 0$$

5. There are two solutions: $(1, -3)$ and $(2, 0)$.

6. Check both in $y = x^2 - 4$: $1 - 4 = -3$ and $4 - 4 = 0$. Both are true.

<!-- FIGURE: {"kind": "coordinate-graph", "type": "system", "points": [[1, -3], [2, 0]], "formula": "y = x^2 - 4 and y = 3x - 6", "semanticsLabel": "A coordinate graph of a parabola and a line intersecting at (1, -3) and (2, 0)."} -->

### #8: A Line That Touches or Misses the Parabola

How many solutions does each system have?

(a) $y = x^2 - 4$ and $y = -4$

(b) $y = x^2 - 4$ and $y = -5$

**Solution:**
Set the right sides equal in each system.

1. For (a), $x^2 - 4 = -4$, so $x^2 = 0$ and $x = 0$. The line touches the parabola at one point, $(0, -4)$. Check: $0 - 4 = -4$.

2. For (b), $x^2 - 4 = -5$, so $x^2 = -1$. A **real number** is any number on the number line, such as $-3$, $0.5$ or $2$. A real number squared is never negative, so there is no real $x$.

3. The line $y = -5$ passes below the lowest point of the parabola, which is $(0, -4)$. So (b) has no solution.

<!-- ILLUSTRATION: coordinate plane with parabola y = x^2 - 4 with lowest point (0, -4); horizontal line y = -4 touching it at (0, -4); horizontal line y = -5 below it, not touching -->

## Speed Tricks & Shortcuts

Sometimes the question asks for $x + y$, not for $x$ and $y$ separately. Try adding or subtracting the equations first. This works when the sum or difference gives the same multiple of the target.

For example, $3x + y = 10$ and $x + 3y = 6$. Add them:

$$4x + 4y = 16$$

Divide everything by $4$.

$$x + y = 4$$

Subtracting gives $2x - 2y = 4$, so $x - y = 2$. The solution is $(3, 1)$, and indeed $3 + 1 = 4$ and $3 - 1 = 2$. If the sum does not give equal coefficients, as in $2x + y$ and $x + 3y$, solve the system in the usual way.

To choose a method, look at the equations. Substitution is quick when a variable has coefficient $1$ or is already alone. Elimination is quick when the coefficients line up, or can be matched with one multiplication.

To count solutions of a linear system, compare the equations as in the Core Concept. Same line means infinitely many solutions. Parallel means none.

## Traps to Watch For

### #1: Stopping at $x$

> Find the variable the question asks for, then re-read the question.

Many students solve for $x$, see their $x$ value among the choices, and stop. But the question may ask for $y$, for $x + y$, or for the product $xy$. A wrong choice built from the plain $x$ value is an easy bait.

### #2: Sign Mistakes When Subtracting Equations

> Subtracting an equation means subtracting every term, signs included.

When you subtract $4x + 10y = 36$ from $15x + 10y = 80$, the right side is $80 - 36$. The left side needs the same care: $15x - 4x$ and $10y - 10y$. If the second equation had $-10y$, subtracting would turn it into $+10y$, and a missed sign changes the answer.

### #3: Multiplying Only Part of an Equation

> When you multiply an equation, multiply both sides, every term.

To scale $3x + 2y = 16$ by $5$, write $15x + 10y = 80$. If you leave the $16$ unchanged, the new equation is no longer equal to the old one. The answer then comes out wrong.

### #4: Parallel Lines Pretending to Have an Answer

> If every variable vanishes, check the statement that is left.

Subtract $2x + y = 9$ from $2x + y = 5$ and you get $0 = -4$. This is false, so the lines are parallel and the answer is "no solution", not $0$ and not $-4$.

If the leftover statement is true, like $0 = 0$, the equations describe the same line. Then there are infinitely many solutions.

### #5: Finding Only One Point on a Curve

> A line can hit a parabola twice. Check how many solutions there are.

In a non-linear system, students may find one root, compute one point, and stop. The quadratic in Example #7 had two roots (solutions), so there were two crossing points.

If the question asks for "the solutions" or "the sum of the $x$ values", use every root that gives a real point. A line may also touch the parabola once or miss it, as in Example #8.
