---
_id: "lesson-arithmetic-number-sense-real-imaginary-numbers"
title: "Real and Imaginary Number Systems"
summary: "How to sort numbers into their correct families and how to solve problems with imaginary numbers."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
estimatedMinutes: 8
isActive: true
---
## Core Concept

Numbers belong to different groups. Think of them as boxes inside bigger boxes.

**Natural numbers** are counting numbers: $1$, $2$, $3$, and so on.

**Whole numbers** add the number $0$ to the natural numbers.

**Integers** add negative whole numbers. Examples are $-2$, $-1$, $0$, $1$, and $2$.

**Rational numbers** are numbers you can write as a fraction. This includes decimals that stop. It also includes decimals that repeat a pattern.

**Irrational numbers** are weird numbers that never stop and never repeat. Examples are $\pi$ and $\sqrt{2}$.

Put all rational and irrational numbers together. You get the **Real numbers**. This is the biggest box of normal numbers.

<!-- ILLUSTRATION: nested boxes diagram, smallest box labeled Natural Numbers inside a bigger box labeled Whole Numbers inside a bigger box labeled Integers inside a bigger box labeled Rational Numbers, with a separate Irrational Numbers box, both joined together inside the biggest outer box labeled Real Numbers -->

But what happens if you take the square root of a negative number? There is no real number for $\sqrt{-1}$.

This is an **Imaginary number**. We call it $i$. By definition, $i = \sqrt{-1}$.

A **Complex number** mixes a real number and an imaginary number. It is written in the form $a + bi$. The letter $a$ is the real part. The $bi$ is the imaginary part.

College entrance exams love to test if you know which box a number belongs in. They also test if you can multiply or divide the imaginary number $i$.

## Mnemonics & Memory Aids

You must memorize the order of number families from smallest to biggest. Use this sentence:

> **N**ever **W**alk **I**nto **R**eal **R**hinos.

This stands for **N**atural, **W**hole, **I**nteger, **R**ational, **R**eal.

The powers of $i$ repeat in a cycle of four. You must memorize these four values.

> **I** **w**on, **I** **w**on! But the middle two are negative.

The cycle is $i$, $1$, $i$, $1$. Make the middle two negative. The final cycle is $i$, $-1$, $-i$, $1$.

* $i^1 = i$
* $i^2 = -1$
* $i^3 = -i$
* $i^4 = 1$

## Examples

### #1: Classifying Number Sets

Which of the following statements regarding number systems is false?
A) Every integer is a rational number.
B) The number zero is considered a natural number.
C) All irrational numbers are real numbers.
D) A repeating non-terminating decimal is a rational number.

**Solution:**

1. Look at choice A. Integers like $5$ can be written as fractions like $\dfrac{5}{1}$. This is true.
2. Look at choice B. Natural numbers are counting numbers. You start counting from $1$. Zero is a whole number, not a natural number. This is false.
3. Look at choice C. Real numbers include all rational and irrational numbers. This is true.
4. Look at choice D. Decimals that repeat forever can be turned into fractions. This is true.
5. The false statement is choice B.

### #2: Simplifying Large Powers of $i$

Evaluate the expression $i^{143} + i^{2024}$.

**Solution:**

1. The powers of $i$ repeat every $4$ steps. Divide the exponent by $4$ to find the remainder.
2. For $143$, divide by $4$. You get $35$ with a remainder of $3$.
3. This means $i^{143}$ is the same as $i^3$. From our memory trick, $i^3 = -i$.
4. For $2024$, divide by $4$. It divides perfectly. The remainder is $0$.
5. A remainder of $0$ means it is the last step in the cycle. So, $i^{2024} = i^4 = 1$.
6. Add them together. The answer is $1 - i$.

### #3: Multiplying Complex Numbers

What is the product of $(3 - 4i)$ and $(2 + 5i)$?

**Solution:**

1. Use the FOIL method. FOIL means multiply the First, Outer, Inner, and Last terms.
2. Multiply the First terms: $3 \times 2 = 6$.
3. Multiply the Outer terms: $3 \times 5i = 15i$.
4. Multiply the Inner terms: $-4i \times 2 = -8i$.
5. Multiply the Last terms: $-4i \times 5i = -20i^2$.
6. Add them all up:

$$6 + 15i - 8i - 20i^2$$


7. Combine the $i$ terms: $15i - 8i = 7i$.
8. Remember that $i^2 = -1$. Change $-20i^2$ to $-20(-1)$, which is $+20$.
9. Add the real numbers: $6 + 20 = 26$.
10. The final answer is $26 + 7i$.

### #4: Dividing Complex Numbers

Express the quotient $\dfrac{2 + 3i}{1 - i}$ in the standard form $a + bi$.

**Solution:**

1. You cannot leave an imaginary number in the bottom of a fraction.
2. You must multiply the top and bottom by the **conjugate** of the bottom. A conjugate just changes the plus or minus sign in the middle.
3. The bottom is $1 - i$. Its conjugate is $1 + i$.
4. Multiply the top parts:

$$(2 + 3i)(1 + i)$$


$$= 2 + 2i + 3i + 3i^2$$


5. Change $3i^2$ to $-3$. The top becomes $2 + 5i - 3$. This simplifies to $-1 + 5i$.
6. Multiply the bottom parts:

$$(1 - i)(1 + i)$$


$$= 1^2 - i^2$$


7. Change $i^2$ to $-1$. The bottom becomes $1 - (-1)$, which is $2$.
8. Put the top over the bottom:

$$\dfrac{-1 + 5i}{2}$$


9. Split it into two fractions. The final answer is $-\dfrac{1}{2} + \dfrac{5}{2}i$.

## Speed Tricks & Shortcuts

1. When dividing a large exponent by $4$, you only need to look at the last two digits. For $i^{1997}$, just divide $97$ by $4$. The remainder is $1$. So, $i^{1997} = i^1 = i$. This saves you a lot of time.

2. When multiplying a complex number by its conjugate, use a fast shortcut. Do not use full FOIL. Just square the real part and square the imaginary number part, then add them.


$$(a + bi)(a - bi) = a^2 + b^2$$

For example, $(3 + 4i)(3 - 4i)$ is just $3^2 + 4^2$. This equals $9 + 16$, which is $25$.

## Traps to Watch For

### #1: The Negative Root Trap

> Always pull out the $i$ before multiplying square roots!

If you multiply $\sqrt{-4} \times \sqrt{-9}$, do not say it is $\sqrt{36} = 6$. This is completely wrong. You must change them to $2i$ and $3i$ first. Then multiply them to get $6i^2$. Because $i^2 = -1$, the real answer is $-6$.

### #2: The Zero Trap

> Zero is a whole number, but it is not a natural number.

Many students think natural numbers start at $0$. They start at $1$. Do not fall for this trap on True/False questions. Zero is the only whole number that is not a natural number.
