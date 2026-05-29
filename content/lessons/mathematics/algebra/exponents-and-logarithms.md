---
_id: "lesson-algebra-exponents-and-logarithms"
title: "Laws of Exponents and Logarithms"
summary: "This lesson teaches you the exact rules for combining and shrinking numbers with exponents and logarithms."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 10
isActive: true
---
## Core Concept

Exponents are a fast way to write repeated multiplication. If you see $2^3$, it means you multiply the number $2$ by itself $3$ times. That means $2 \times 2 \times 2$, which is $8$.

A logarithm is just the exact opposite of an exponent. It asks a simple question to find a missing power. If you see $\log_2(8)$, it asks, "What power do I need to put on $2$ to get $8$?" The answer is $3$.

College entrance exams love these two topics. Exams will give you a long, messy math problem filled with letters and numbers. Your job is to use specific laws to shrink that mess down into a tiny, clean answer.

## Mnemonics & Memory Aids

Use the made-up word MADSPM to remember your exponent rules. It tells you exactly what to do with the little exponents when you see different math operations.

> **MADSPM**: **M**ultiply bases to **A**dd, **D**ivide to **S**ubtract, **P**ower to **M**ultiply.

To convert a logarithm back into a normal exponent, use the Circle Rule. You visually draw a circle starting from the tiny bottom number.

> **Circle Rule**. Start at the base, cross the equals sign to get your exponent, and loop back inside the log for your answer. $\log_2(8) = 3$ becomes $2^3 = 8$.

To remember the laws for logarithms, just remember that logarithms pull math down $1$ level of difficulty.

> Logarithms bring math down $1$ level. An Exponent drops down to become Multiplication. Multiplication drops down to Addition. Division drops down to Subtraction.

## Examples

### #1: Simplifying terms with the same base

Simplify the following expression:


$$\dfrac{(x^3 y^2)(x^4 y^{-1})}{x^2 y^3}$$

**Solution:**

$1$. Use the MADSPM rule for the top part. When you multiply the big letter bases, you add their tiny exponents.
$2$. For $x$, add $3$ and $4$ to get $7$. For $y$, add $2$ and $-1$ to get $1$.


$$\dfrac{x^7 y^1}{x^2 y^3}$$


$3$. Now use the MADSPM rule for division. When you divide bases, you subtract the bottom exponent from the top exponent.
$4$. For $x$, subtract $2$ from $7$ to get $5$. For $y$, subtract $3$ from $1$ to get $-2$.


$$x^5 y^{-2}$$


$5$. A negative exponent means the letter belongs on the bottom of a fraction. Move $y$ down.


$$\dfrac{x^5}{y^2}$$

### #2: Negative and fractional exponents

Evaluate the following expression:


$$8^{-\dfrac{2}{3}}$$

**Solution:**

$1$. Handle the negative sign first. A negative exponent flips the whole number upside down under a $1$.


$$\dfrac{1}{8^{\dfrac{2}{3}}}$$


$2$. A fraction in an exponent means you take a root. The bottom number is the root type. The top number is the power.

$3$. The bottom number is $3$. This means you take the cube root of $8$. The cube root of $8$ is $2$.


$$\dfrac{1}{2^2}$$


$4$. The top number is $2$. This means you square the number $2$. The final answer is $1$ over $4$.


$$\dfrac{1}{4}$$

### #3: Finding the value of a basic logarithm

Evaluate the value of the following logarithmic expression:


$$\log_3(81)$$

**Solution:**

$1$. Use the Circle Rule. Set the problem equal to an unknown letter, like $x$.


$$\log_3(81) = x$$


$2$. The base is $3$. Cross the equals sign to grab the $x$ as your exponent, and loop back to the $81$ as your answer.


$$3^x = 81$$


$3$. Ask yourself, "How many times do I multiply $3$ by itself to get $81$?"
$4$. Multiply $3 \times 3 \times 3 \times 3$ to get $81$. You need $4$ of them.
$5$. The answer is $4$.

### #4: Condensing logarithmic expressions

Express the following as a single logarithm:


$$2\log(x) + \log(y) - 3\log(z)$$

**Solution:**

$1$. Use the reverse log rules. First, push the big numbers in the very front back up to become exponents.


$$\log(x^2) + \log(y) - \log(z^3)$$


$2$. Next, look at the addition sign. Addition condenses back up a level into multiplication. Combine the first $2$ parts.


$$\log(x^2 y) - \log(z^3)$$


$3$. Finally, look at the subtraction sign. Subtraction condenses back up a level into division. Combine everything together.


$$\log( \dfrac{x^2 y}{z^3} )$$

### #5: Equations where the unknown is an exponent

Find the value of $x$ that satisfies the equation:


$$4^{2x-1} = 8^{x+1}$$

**Solution:**

$1$. You cannot solve this until the big base numbers match perfectly. Change both bases to the number $2$.
$2$. The number $4$ is $2^2$. The number $8$ is $2^3$.


$$(2^2)^{2x-1} = (2^3)^{x+1}$$


$3$. Use the MADSPM rule. When a power is raised to another power, you multiply them. Distribute the outside numbers inside.


$$2^{4x-2} = 2^{3x+3}$$


$4$. Since the big bases match now, you can drop them entirely. Just set the top exponents equal to each other.


$$4x - 2 = 3x + 3$$


$5$. Move the letters to $1$ side and the normal numbers to the other. Subtract $3x$ from $4x$, and add $2$ to $3$.


$$x = 5$$

### #6: Finding logarithms in terms of given variables

If $\log_{10}(2) = a$ and $\log_{10}(3) = b$, express $\log_{10}(12)$ in terms of variables $a$ and $b$.

**Solution:**

$1$. You need to break the number $12$ down into small pieces that match your clues. Your clues only use the numbers $2$ and $3$.
$2$. Find a way to make $12$ using only $2$ and $3$. You know that $4 \times 3$ is $12$. And $4$ is just $2^2$.


$$\log_{10}(2^2 \times 3)$$


$3$. Use your log rules to pull this apart. Multiplication breaks apart and drops down into addition.


$$\log_{10}(2^2) + \log_{10}(3)$$


$4$. Use another log rule to bring the tiny exponent of $2$ down to the very front.


$$2\log_{10}(2) + \log_{10}(3)$$


$5$. Now swap out the logs for your letters. Replace the log of $2$ with $a$. Replace the log of $3$ with $b$.


$$2a + b$$

## Speed Tricks & Shortcuts

When dealing with negative exponents in fractions, never overthink them. If a piece has a negative exponent, just cross it out and write it on the other side of the fraction line with a positive exponent. Top goes to bottom, and bottom goes to top.

If you see a logarithm matching the big base of its own exponent, they instantly destroy each other. For example, $5^{\log_5(x)}$ just becomes $x$. You do not need to do any actual math.

The exact same destruction happens in reverse. If you see $\log_7(7^x)$, the log and the big base $7$ cancel out instantly. The answer is simply $x$.

## Traps to Watch For

### The Multiplication Trap

> Do not multiply the exponents when you multiply the big base numbers. Add them!

Many students see $x^2 \times x^3$ and think the answer is $x^6$. This is completely wrong. You must add the exponents together to get $x^5$.

### The Distributive Trap

> Never pass an exponent inside parentheses if there is a plus or minus sign.

If you see $(x + y)^2$, it does not equal $x^2 + y^2$. This is a huge trap on the exam! You have to write it out $2$ times as $(x + y)(x + y)$ and multiply everything out properly.

### The Log Addition Trap

> You cannot break apart a logarithm that has addition hiding inside its parentheses.

If the exam asks you to expand $\log(x + y)$, leave it alone. There is absolutely no rule for breaking apart addition inside a logarithm. Test makers will offer $\log(x) + \log(y)$ as a trick choice. Do not pick it.

### The Invisible Base Trap

> An empty base on a logarithm always means the base is the number $10$.

Sometimes an exam gives you $\log(100)$ with no tiny base number at the bottom. Students get stuck trying to find it. If it is blank, always write a $10$ there so you can solve the problem.
