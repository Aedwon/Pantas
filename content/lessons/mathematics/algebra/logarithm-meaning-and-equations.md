---
_id: "lesson-algebra-logarithm-meaning-and-equations"
title: "Logarithm Meaning and Equations"
summary: "Read a logarithm as an exponent and solve for its argument."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 3
partCount: 4
ordering: 8
keyPoints:
  - "Evaluate logarithms using their exponential form."
  - "Check logarithm conditions when solving for an argument."
---
## Core Concept

A **logarithm** asks which exponent gives a number. For $b>0$, $b\ne1$, and $x>0$:

$$\log_b(x)=y\quad\Longleftrightarrow\quad b^y=x$$

The **argument** is the expression inside the logarithm. In $\log_2(8)$, the base is $2$ and the argument is $8$. Its value is $3$ because $2^3=8$.

Exponential powers and logarithms with the same allowed base undo each other:

$$b^{\log_b x}=x\qquad(x>0)$$

$$\log_b(b^x)=x$$

## Examples

### #1: Finding a Basic Logarithm

Evaluate $\log_3(81)$.

**Solution:**

1. Let $x$ be the logarithm's value. Rewrite it as a power equation.

$$3^x=81$$

2. Write $81$ as a power of $3$.

$$3^4=81$$

3. The required exponent is $4$.

$$\log_3(81)=4$$

### #2: Finding an Unknown Logarithm Argument

Solve $\log_2(x-1)=3$.

**Solution:**

1. The argument $x-1$ must be positive.

$$x-1>0\quad\Rightarrow\quad x>1$$

2. Rewrite the equation in exponential form.

$$x-1=2^3=8$$

3. Add $1$.

$$x=9$$

4. Check the argument and the original equation.

$$9-1=8>0$$

$$\log_2(8)=3$$

## Speed Tricks & Shortcuts

To check a logarithm answer, turn it back into a power. For example, $\log_5(25)=2$ checks because $5^2=25$.

## Traps to Watch For

### #1: Missing Logarithm Conditions

> Real logarithms need an allowed base and a positive argument.

The base must satisfy $b>0$ and $b\ne1$. Check the original argument after solving an equation, since a zero or negative argument cannot be used.
