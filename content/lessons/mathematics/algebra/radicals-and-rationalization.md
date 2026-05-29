---
_id: "lesson-algebra-radicals-and-rationalization"
title: "Radicals and Rationalization"
summary: "Learn how to simplify roots and remove them from the bottom of fractions."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 10
isActive: true
---
## Core Concept

A **radical** is just a root. The most common one is the square root. Its symbol is $\sqrt{x}$.

The number inside the root is the **radicand**. The small number outside is the **index**. If there is no index, it is a $2$.

To simplify a root, we take out pairs of the same number. If a number has no pair, it stays inside.

**Rationalization** means cleaning up a fraction. In math, we never leave a root at the bottom of a fraction.

To remove a root from the bottom, we multiply the top and bottom by a special number. This makes the bottom a whole number.

College entrance exams love this topic. They want to see if you know the secret rules of roots.

## Mnemonics & Memory Aids

When simplifying square roots, think of a jailbreak.

> "Outside pairs step out, singles stay inside."

For every pair of identical numbers inside, one gets to escape outside. The other disappears. Any number without a pair is trapped inside.

When you multiply or divide roots, remember this rule.

> "Outside with outside, inside with inside."

You can only multiply normal numbers with normal numbers. You can only multiply roots with roots. Never mix them.

When you have a root plus or minus a number at the bottom of a fraction, use a **conjugate**. A conjugate is the same expression but with the middle sign changed.

> "To clear the floor, flip the core."

## Examples

### #1: Simplifying Radicals

Simplify the radical expression $\sqrt{72x^3y^4}$.

1. Break down $72$ into prime numbers. It is $2 \cdot 2 \cdot 2 \cdot 3 \cdot 3$.
2. Break down the letters. $x^3$ is $x \cdot x \cdot x$. $y^4$ is $y \cdot y \cdot y \cdot y$.
3. Look for pairs. We have a pair of $2$s and a pair of $3$s.
4. We also have one pair of $x$s and two pairs of $y$s.
5. Bring one of each pair outside.

$$2 \cdot 3 \cdot x \cdot y \cdot y$$


6. Multiply the outside parts. This gives $6xy^2$.
7. Look at what is left inside. One $2$ and one $x$ had no pairs.
8. Put them back inside the root. The final answer is:

$$6xy^2\sqrt{2x}$$



### #2: Adding and Subtracting Radicals

Find the exact value of the expression $3\sqrt{20} - \sqrt{45} + 2\sqrt{5}$.

1. You can only add roots if the insides are exactly the same. Right now, they are different.
2. Simplify $\sqrt{20}$. It is $\sqrt{4 \cdot 5}$, which becomes $2\sqrt{5}$.
3. Multiply it by the $3$ outside. This makes $6\sqrt{5}$.
4. Simplify $\sqrt{45}$. It is $\sqrt{9 \cdot 5}$, which becomes $3\sqrt{5}$.
5. Now rewrite the whole problem.

$$6\sqrt{5} - 3\sqrt{5} + 2\sqrt{5}$$


6. Treat $\sqrt{5}$ like a letter $x$. Just add and subtract the numbers outside.
7. $6 - 3 + 2 = 5$. The final answer is:

$$5\sqrt{5}$$



### #3: Rationalizing a Simple Denominator

Rationalize the denominator of the fraction $\dfrac{10}{\sqrt{5x}}$.

1. We cannot leave $\sqrt{5x}$ at the bottom.
2. Multiply the top and bottom by $\sqrt{5x}$.

$$\dfrac{10}{\sqrt{5x}} \cdot \dfrac{\sqrt{5x}}{\sqrt{5x}}$$


3. Multiply the tops. This gives $10\sqrt{5x}$.
4. Multiply the bottoms. $\sqrt{5x} \cdot \sqrt{5x}$ is just $5x$. The root disappears.

$$\dfrac{10\sqrt{5x}}{5x}$$


5. Simplify the fraction. $10$ divided by $5$ is $2$. The final answer is:

$$\dfrac{2\sqrt{5x}}{x}$$



### #4: Rationalizing with a Binomial

Simplify the expression $\dfrac{4}{3 - \sqrt{5}}$ by rationalizing the denominator.

1. The bottom has two parts. We must use the conjugate.
2. The conjugate of $3 - \sqrt{5}$ is $3 + \sqrt{5}$.
3. Multiply the top and bottom by $3 + \sqrt{5}$.
4. For the top, distribute the $4$.

$$4(3 + \sqrt{5}) = 12 + 4\sqrt{5}$$


5. For the bottom, multiply the first terms and the last terms. The middle terms cancel out.

$$3 \cdot 3 = 9$$


$$\sqrt{5} \cdot \sqrt{5} = 5$$


$$9 - 5 = 4$$


6. Put the new top over the new bottom.

$$\dfrac{12 + 4\sqrt{5}}{4}$$


7. Divide both top numbers by $4$. The final answer is:

$$3 + \sqrt{5}$$



### #5: Rationalizing Higher Roots

Rationalize the denominator of the expression $\dfrac{2}{\sqrt[3]{4x}}$.

1. This is a cube root. We need groups of three to escape, not pairs.
2. Break down the bottom. $4x$ is $2 \cdot 2 \cdot x$.
3. To make a group of three, we need one more $2$ and two more $x$s.
4. This means we must multiply by $\sqrt[3]{2x^2}$.
5. Multiply the top and bottom by this new root.
6. The top becomes:

$$2\sqrt[3]{2x^2}$$


7. The bottom becomes a perfect cube. It turns into $2x$.

$$\dfrac{2\sqrt[3]{2x^2}}{2x}$$


8. Cancel the $2$ on top and bottom. The final answer is:

$$\dfrac{\sqrt[3]{2x^2}}{x}$$



## Speed Tricks & Shortcuts

1. When dividing a normal number by a square root, use the "Half and Attach" trick.

If you have $\dfrac{x}{\sqrt{y}}$, just write $\dfrac{x \sqrt{y}}{y}$.

For example, $\dfrac{10}{\sqrt{2}}$. Just divide $10$ by $2$ to get $5$. Then attach $\sqrt{2}$. The answer is $5\sqrt{2}$. This saves a lot of time.

2. Many CETs have infinite repeating roots. They look like this:


$$\sqrt{20 + \sqrt{20 + \dots}}$$

Do not use a long formula to solve this. Just find two numbers that multiply to $20$. They must be one digit apart.

For $20$, the numbers are $4$ and $5$. If the sign in the problem is a plus, the answer is the bigger number. So, the answer is $5$.

If the sign is a minus, the answer is the smaller number.

## Traps to Watch For

### #1: Adding Insides

Many students see $\sqrt{9} + \sqrt{16}$ and write $\sqrt{25}$. This is dead wrong.

> Never add or subtract the insides of two different roots.

You must solve them separately. $\sqrt{9}$ is $3$. $\sqrt{16}$ is $4$. The real answer is $7$.

### #2: Expanding Conjugates the Long Way

When multiplying a conjugate like $(x + \sqrt{y})(x - \sqrt{y})$, students waste time doing the full FOIL method.

> For conjugates, just square the first, square the last, and subtract.

The middle parts always cancel out to zero. Skip them to save time.

### #3: The Plus-Minus Confusion

Students think $\sqrt{25}$ equals $\pm 5$.

> "The square root symbol only gives the positive answer."

If an exam asks for $\sqrt{25}$, the answer is just $5$. You only use $\pm 5$ if you see an equation like $x^2 = 25$ and you put the root there yourself.

### #4: Cube Root Rationalization Trap

To fix $\dfrac{1}{\sqrt[3]{x}}$, students multiply by $\sqrt[3]{x}$.

> "For cube roots, you need three of a kind, not two."

Multiplying by just one more gives you two $x$s inside. They are still trapped. You must multiply by $\sqrt[3]{x^2}$ to get three of them.
