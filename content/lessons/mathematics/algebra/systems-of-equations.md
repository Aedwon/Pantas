---
_id: "lesson-algebra-systems-of-equations"
title: "Systems of Linear and Non-Linear Equations (Substitution, Elimination, Graphing)"
summary: "This lesson teaches you how to find the values that make two equations true at the same time."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **system of equations** is a group of two or more equations that share the same variables. To "solve the system" means to find the values that make ALL the equations true at the same time.

Think of it like finding a meeting place. Each equation is a road. The solution is the exact spot where the roads cross.

There are three main ways to solve a system.

**Substitution** means solving one equation for one variable, then swapping it into the other equation. Use this when one equation already has a lonely variable, like $y = x + 1$.

**Elimination** means adding or subtracting the equations to make one variable disappear. Use this when the equations line up nicely, like $2x + 3y = 12$ and $4x - 3y = 6$.

**Graphing** means drawing both equations as lines. The solution is the point where the lines cross.

<!-- ILLUSTRATION: two straight lines crossing at a single labeled point (3, 4) on a coordinate plane -->

A system of two lines can have three outcomes:

- **One solution**: the lines cross at exactly one point.
- **No solution**: the lines are parallel. They never touch.
- **Infinite solutions**: both equations are secretly the same line.

A **non-linear system** has at least one equation that is not a straight line, like a parabola from $y = x^2 - 4$. A line can cross a parabola at two points, so these systems can have two solutions.

CETs love systems because they can hide them inside word problems. If a problem gives you two facts about two unknown things, it is a system in disguise.

## Examples

### #1: Substitution

Solve the system: $y = x + 1$ and $x + y = 7$.

**Solution:**
The first equation already tells us what $y$ is. So we substitute, which means we swap $y$ for $x + 1$ in the second equation.

1. Replace $y$ in the second equation.

$$x + (x + 1) = 7$$

2. Combine the like terms.

$$2x + 1 = 7$$

3. Subtract $1$ from both sides, then divide by $2$.

$$2x = 6$$

$$x = 3$$

4. Now find $y$ using the first equation.

$$y = 3 + 1 = 4$$

5. The solution is $x = 3$ and $y = 4$, or the point $(3, 4)$.

### #2: Elimination by Adding

Solve the system: $2x + 3y = 12$ and $4x - 3y = 6$.

**Solution:**
Look at the $y$ terms: $+3y$ and $-3y$. They are opposites. If we add the equations, the $y$ terms cancel out.

1. Add the two equations together, left side plus left side, right side plus right side.

$$(2x + 3y) + (4x - 3y) = 12 + 6$$

2. The $3y$ and $-3y$ cancel each other.

$$6x = 18$$

3. Divide both sides by $6$.

$$x = 3$$

4. Substitute $x = 3$ into the first equation.

$$2(3) + 3y = 12$$

$$6 + 3y = 12$$

$$3y = 6$$

$$y = 2$$

5. The solution is $(3, 2)$. Check it in the second equation: $4(3) - 3(2) = 12 - 6 = 6$. Correct.

### #3: Elimination with Multiplication

Solve the system: $3x + 2y = 16$ and $2x + 5y = 18$.

**Solution:**
Nothing cancels yet. We must multiply first to make matching terms. Let us make the $y$ terms match by turning both into $10y$.

1. Multiply the first equation by $5$.

$$15x + 10y = 80$$

2. Multiply the second equation by $2$.

$$4x + 10y = 36$$

3. Both have $+10y$, so we subtract the second from the first.

$$(15x + 10y) - (4x + 10y) = 80 - 36$$

$$11x = 44$$

4. Divide both sides by $11$.

$$x = 4$$

5. Substitute $x = 4$ into $3x + 2y = 16$.

$$3(4) + 2y = 16$$

$$2y = 4$$

$$y = 2$$

6. The solution is $(4, 2)$. Check: $2(4) + 5(2) = 8 + 10 = 18$. Correct.

### #4: A System Hiding in a Word Problem

A movie house sold $50$ tickets. Adult tickets cost $100$ pesos and child tickets cost $60$ pesos. The total sales were $4{,}200$ pesos. How many adult tickets were sold?

**Solution:**
Two facts, two unknowns. Let $a$ be adult tickets and $c$ be child tickets.

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

6. There were $30$ adult tickets. Check: $30 + 20 = 50$ tickets, and $100(30) + 60(20) = 3000 + 1200 = 4200$ pesos. Correct.

### #5: A Line Meets a Parabola

Solve the non-linear system: $y = x^2 - 4$ and $y = 3x - 6$.

**Solution:**
Both equations equal $y$, so we can set them equal to each other.

1. Set the two right sides equal.

$$x^2 - 4 = 3x - 6$$

2. Move everything to one side to get a quadratic equation.

$$x^2 - 3x + 2 = 0$$

3. Factor the quadratic.

$$(x - 1)(x - 2) = 0$$

4. So $x = 1$ or $x = 2$. Find $y$ for each using $y = 3x - 6$.

$$x = 1: \quad y = 3(1) - 6 = -3$$

$$x = 2: \quad y = 3(2) - 6 = 0$$

5. There are TWO solutions: $(1, -3)$ and $(2, 0)$. The line cuts through the parabola twice.

<!-- ILLUSTRATION: parabola y = x^2 - 4 crossed by the line y = 3x - 6 at labeled points (1, -3) and (2, 0) -->

## Speed Tricks & Shortcuts

Sometimes the test asks for $x + y$, not $x$ and $y$ separately. Do not solve the whole system! Try adding the equations first.

For example: $3x + y = 10$ and $x + 3y = 6$. Add them:

$$4x + 4y = 16$$

Divide everything by $4$:

$$x + y = 4$$

Done in two steps. Always read what the question actually asks before you start solving.

Another quick check: to know how many solutions a linear system has, compare the equations. If one equation is just the other multiplied by a number, there are infinite solutions. If only the left sides match that way but the right sides do not, the lines are parallel and there is no solution.

## Traps to Watch For

### #1: Stopping at $x$

> Find BOTH variables, then re-read the question.

Many students solve for $x$, see their $x$ value in the choices, and shade it. But the question may ask for $y$, or for $x + y$, or for the product $xy$. The test-makers always put the plain $x$ value in the choices as bait.

### #2: Sign Mistakes When Subtracting Equations

> Subtracting an equation means subtracting EVERY term, signs included.

When you subtract $4x + 10y = 36$ from $15x + 10y = 80$, students often write $80 - 36$ correctly but forget to subtract on the left side properly. Distribute the minus sign to every term: $15x - 4x$ and $10y - 10y$. One missed sign flips the whole answer.

### #3: Parallel Lines Pretending to Have an Answer

> If both variables vanish and you get a false statement, there is no solution.

Try solving $2x + y = 5$ and $2x + y = 9$ by subtraction. You get $0 = -4$, which is false. That means the lines are parallel and never cross. The answer is "no solution", not $0$ and not $-4$. If you instead get a true statement like $0 = 0$, the two equations are the same line and there are infinitely many solutions.

### #4: Finding Only One Point on a Curve

> A line can hit a parabola twice. Find all solutions.

In non-linear systems, students find $x = 1$, compute one point, and stop. But the quadratic had two roots. If the question asks for "the solutions" or "the sum of the $x$ values", you need both crossing points.
