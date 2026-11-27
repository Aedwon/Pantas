---
_id: "lesson-arithmetic-number-sense-imaginary-unit-and-powers"
title: "Imaginary Unit and Powers"
summary: "Identify the real and imaginary parts of a complex number."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 2
partCount: 3
ordering: 5
keyPoints:
  - "Identify the real and imaginary parts of a complex number."
  - "Use the repeating cycle of powers of i."
  - "Rewrite negative square roots using i before multiplying."
---
## Core Concept

### The Imaginary Unit and Complex Numbers

No real number squares to $-1$. The **imaginary unit** $i$ is defined by:

$$i^2=-1$$

For any positive real number $k$, write $\sqrt{-k}=i\sqrt{k}$. For example, $\sqrt{-9}=3i$ and $\sqrt{-16}=4i$.

A **complex number** has standard form $a+bi$, where $a$ and $b$ are real numbers. Here $a$ is the **real part**, and $b$ is the **imaginary part**.

If $b=0$, the number is real, so every real number has form $a+0i$. If $a=0$ and $b\ne 0$, it is **purely imaginary**.

To add or subtract complex numbers, combine real parts and $i$ terms separately. Subtract $6-3i$ from $10+2i$ (flip both signs in the second group):

$$(10+2i)-(6-3i)=10+2i-6+3i$$

$$10+2i-6+3i=4+5i$$

:::pair #imaginary-part-coefficient
Right: in $3-4i$, the imaginary part is $-4$.
Wrong: in $3-4i$, the imaginary part is $-4i$.
In $a+bi$, the imaginary part $b$ is only the real coefficient in front of $i$, with its sign. Do not include $i$ itself.
:::

### The Four-Step Cycle of Powers of i

In exam questions, **evaluate** means find the final number answer. The powers of $i$ repeat every $4$ steps:

$$i^1=i,\qquad i^2=-1,\qquad i^3=-i,\qquad i^4=1$$

After $i^4$, the pattern starts over at $i$. For any larger positive whole-number exponent, divide the whole exponent by $4$ and use the remainder: remainder $1$ gives $i$, $2$ gives $-1$, $3$ gives $-i$, and $0$ gives $1$.

<!-- ILLUSTRATION: Four boxes in a loop, read clockwise from the top left: i^1 = i (remainder 1), i^2 = -1 (remainder 2), i^3 = -i (remainder 3), and i^4 = 1 (remainder 0). Arrows run from each box to the next, and a last arrow runs from the i^4 box back to the i^1 box, so the powers repeat every 4 steps. -->

Find $i^{57}$. Divide $57$ by $4$:

$$57=4(14)+1$$

The remainder is $1$, so:

$$i^{57}=i^1$$

$$i^1=i$$

:::why
Why do groups of $4$ powers disappear? Since $i^4=1$, every four factors multiply to $1$: $i^{57}=(i^4)^{14}\cdot i^1=1^{14}\cdot i=i$.
:::

:::pair #last-digit-power-of-i
Right: to find $i^{57}$, $57=4(14)+1$, so $i^{57}=i^1=i$
Wrong: to find $i^{57}$, last digit $7=4(1)+3$, so $i^{57}=i^3=-i$
Do not divide only the last digit by $4$. Because $10$ does not divide evenly by $4$, the tens digit changes the remainder. Divide the whole exponent by $4$.
:::

:::check
Evaluate $2i^{43}+1$ and write the answer as $a+bi$.
:::answer
The answer is $1-2i$. Since $43=4(10)+3$, $i^{43}=i^3=-i$, so $2(-i)+1=1-2i$.
:::

### Multiplying Square Roots of Negatives

For nonnegative real numbers, $\sqrt{a}\cdot\sqrt{b}=\sqrt{ab}$. That rule fails when both numbers under the square root are negative. Rewrite each negative square root with $i$ before multiplying or dividing.

Find $\sqrt{-4}\cdot\sqrt{-9}$:

$$\sqrt{-4}=2i,\qquad\sqrt{-9}=3i$$

$$\sqrt{-4}\cdot\sqrt{-9}=(2i)(3i)$$

$$(2i)(3i)=6i^2$$

$$6i^2=6(-1)=-6$$

:::pair #negative-root-product
Right: $\dfrac{\sqrt{-36}\cdot\sqrt{-4}}{\sqrt{-16}}=\dfrac{(6i)(2i)}{4i}=\dfrac{-12}{4i}=\dfrac{-3}{i}=\dfrac{-3i}{i^2}=3i$
Wrong: $\dfrac{\sqrt{-36}\cdot\sqrt{-4}}{\sqrt{-16}}=\dfrac{6\cdot 2}{4}=3$
Do not drop the minus signs inside negative roots or use $\sqrt{ab}$ before pulling out $i$. Write each negative root in $i$ form first.
:::

## Mnemonics & Memory Aids

> Powers of $i$: $i,-1,-i,1$, then repeat.

## Examples

### #1: Simplifying Large Powers of i

Evaluate $i^{143}+i^{2024}$.

**Solution:**

1. Divide $143$ by $4$. The remainder is $3$.

$$143=4(35)+3$$

$$i^{143}=i^3$$

$$i^3=-i$$

2. Divide $2024$ by $4$. The remainder is $0$.

$$2024=4(506)$$

$$i^{2024}=i^4$$

$$i^4=1$$

3. Add the two results and write in $a+bi$ form.

$$i^{143}+i^{2024}=-i+1$$

$$-i+1=1-i$$

The answer is $1-i$.

### #2: Multiplying and Dividing Negative Square Roots

"Simplify" means write an equal expression in a simpler form.

Simplify $\dfrac{\sqrt{-16}\cdot\sqrt{-9}}{\sqrt{-4}}$.

**Solution:**

1. Rewrite every negative square root using $i$.

$$\sqrt{-16}=4i,\qquad\sqrt{-9}=3i,\qquad\sqrt{-4}=2i$$

2. Multiply the numerator and replace $i^2$ with $-1$.

$$(4i)(3i)=12i^2$$

$$12i^2=-12$$

3. Divide by the denominator $2i$.

$$\dfrac{-12}{2i}=\dfrac{-6}{i}$$

:::try
Finish the last step: multiply top and bottom of $\dfrac{-6}{i}$ by $i$ and replace $i^2$ with $-1$.
:::answer
The answer is $6i$. Multiplying top and bottom by $i$ gives $\dfrac{-6i}{i^2}=\dfrac{-6i}{-1}=6i$.
:::

## Speed Tricks & Shortcuts

Any four consecutive powers of $i$ add to $0$, because $i+(-1)+(-i)+1=0$. For $i+i^2+\dots+i^{10}$, the first $8$ terms make two groups of four, which add to $0$. The leftover terms are $i^9+i^{10}=i+(-1)=-1+i$. Also, $\dfrac{1}{i}=-i$, since $i(-i)=-i^2=1$.

## Traps to Watch For

:::checklist
- Imaginary part of $a+bi$: read only the real coefficient $b$ with its sign, without $i$. {#imaginary-part-coefficient}
- Large powers of $i$: divide the whole exponent by $4$, not just the last digit. {#last-digit-power-of-i}
- Square roots of negatives: rewrite with $i$ before multiplying or dividing. {#negative-root-product}
:::
