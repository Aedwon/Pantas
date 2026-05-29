---
_id: "lesson-algebra-quadratic-equations"
title: "Quadratic Equations"
summary: "This lesson teaches you how to solve quadratic equations and find their roots quickly."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 8
isActive: true
---
## Core Concept

A quadratic equation is a math sentence where the highest power of $x$ is $2$. You will see an $x^2$ in the problem. The answers you get are called **roots** or **solutions**. Finding these answers is a very big part of the UPCAT and DOST exams.

### Standard Form

Before you solve, the equation must look like this:

$$ax^2 + bx + c = 0$$

The letters $a$, $b$, and $c$ are just numbers. The number $a$ can never be $0$. If $a$ is $0$, the $x^2$ disappears. Then it becomes a straight line, not a curve.

### Factoring

This is the fastest way to find the answers. You break the long equation into two small parts. You look for two special numbers.

These two numbers must multiply to make $c$. They must also add up to make $b$. If your equation is $x^2 + 5x + 6 = 0$, the numbers are $2$ and $3$.

### Completing the Square

Sometimes, factoring does not work. You can force the equation to become a perfect square instead. A **perfect square** is a number made by multiplying a number by itself.

To do this, you take half of $b$ and multiply it by itself. Then, you add this new number to both sides of the equation. This takes a lot of time. Only use this method if the exam asks for it directly.

### Quadratic Formula and Discriminant

This is your backup tool. It always works when factoring is too hard. You just put your numbers into this formula:

$$x = \dfrac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$

The part inside the square root is called the **discriminant**. It is $b^2 - 4ac$. This small piece tells you what kind of answers you will get.

If it is more than $0$, you get two real answers. If it is exactly $0$, you get one real answer. If it is less than $0$, you get two imaginary answers. **Imaginary** means the number is not on the normal number line.

## Mnemonics & Memory Aids

Memorizing the big formula can be hard. Think of a short story to remember all the signs and letters.

> A negative boy ($-b$) could not decide ($\pm$) to go to a radical party ($\sqrt{\quad}$). Inside, the boy was square ($b^2$) and lost four awesome cats ($-4ac$). The whole thing was over at 2 AM ($/2a$).

To remember what the discriminant tells you, use this short rhyme:

> Positive is Two, Zero is One, Negative is None.

## Examples

### #1: Basic Factoring

Find the roots of the equation $x^2 - 8x + 15 = 0$.

1. Look at $c$, which is $15$. Look at $b$, which is $-8$.
2. Find two numbers that multiply to $15$ and add to $-8$. These numbers are $-3$ and $-5$.
3. Write the parts like this:

$$(x - 3)(x - 5) = 0$$


4. Set each part to $0$ and solve. The roots are $x = 3$ and $x = 5$.

### #2: Leading Coefficient Greater Than 1

What are the solutions to the quadratic equation $2x^2 + 7x + 3 = 0$?

1. Multiply $a$ ($2$) by $c$ ($3$). The answer is $6$.
2. Find two numbers that multiply to $6$ and add to $b$ ($7$). These numbers are $6$ and $1$.
3. Split the middle part ($7x$) using these two numbers.

$$2x^2 + 6x + 1x + 3 = 0$$


4. Group them into two pairs and take out the common parts.

$$2x(x + 3) + 1(x + 3) = 0$$


$$(2x + 1)(x + 3) = 0$$


5. Solve for $x$. The roots are $x = -1/2$ and $x = -3$.

### #3: Nature of the Roots

For what values of $k$ will the equation $x^2 + kx + 9 = 0$ possess exactly one real root?

1. The phrase "exactly one real root" is a clue. It means the discriminant ($b^2 - 4ac$) must be $0$.
2. Find your letters. Here, $a = 1$, $b = k$, and $c = 9$.
3. Put them into the discriminant formula.

$$k^2 - 4(1)(9) = 0$$


4. Multiply the numbers on the right.

$$k^2 - 36 = 0$$


5. Move $36$ to the other side.

$$k^2 = 36$$


6. Take the square root of both sides. The answers are $k = 6$ and $k = -6$.

### #4: Sum and Product of Roots

If $r_1$ and $r_2$ are the roots of the equation $3x^2 - 12x + 7 = 0$, what is the exact value of $\dfrac{1}{r_1} + \dfrac{1}{r_2}$?

1. Do not use the big formula to find the actual roots. The answers will be ugly fractions. It will waste your time.
2. First, combine the two fractions into one. The common bottom part is $r_1 \times r_2$. The top part becomes $r_1 + r_2$.

$$\dfrac{r_1 + r_2}{r_1 r_2}$$


3. The top part is just the sum of the roots. The shortcut for the sum is $-b/a$.

$$\text{Sum} = \dfrac{-(-12)}{3} = 4$$


4. The bottom part is the product of the roots. The shortcut for the product is $c/a$.

$$\text{Product} = \dfrac{7}{3}$$


5. Divide the sum by the product.

$$\dfrac{4}{7/3}$$


6. Flip the bottom fraction and multiply. The final answer is $12/7$.

## Speed Tricks & Shortcuts

Never find the actual roots if the exam only asks for their sum or product. Use Vieta's formulas instead. They are super fast shortcuts.

The sum of the roots is always $-b/a$. The product of the roots is always $c/a$. Memorize these two tiny fractions.

You can also guess the signs of the roots by looking at $c$. If $c$ is a positive number, both roots will have the exact same sign. If $c$ is a negative number, one root is positive and the other is negative.

## Traps to Watch For

### #1: Not Setting to Zero First

> Before doing any math, make sure one side of the equals sign is $0$.

Test-makers will give you equations like $x^2 - 5x = 6$. Students will try to factor the left side right away. This is wrong. You must move the $6$ to the left side first to make it $x^2 - 5x - 6 = 0$.

### #2: Forgetting the Plus-Minus

> Every positive number has two square roots, not one.

If you solve $x^2 = 25$, the answer is not just $x = 5$. The answer is $x = 5$ and $x = -5$. The exam will put $5$ as Choice A to trick you into stopping early.

### #3: Canceling x

> Never divide both sides by $x$. You will lose an answer.

If you have $x^2 = 4x$, do not cross out an $x$ on both sides to get $x = 4$. Instead, move everything to one side to get $x^2 - 4x = 0$. Then factor it as $x(x - 4) = 0$. This shows the true answers are $x = 0$ and $x = 4$.
