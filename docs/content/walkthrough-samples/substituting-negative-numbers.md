---
_id: "lesson-arithmetic-number-sense-substituting-negative-numbers"
title: "Substituting Negative Numbers"
summary: "Put negative values into expressions and apply powers correctly."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 4
ordering: 3
keyPoints:
  - "Substitute a negative value inside parentheses."
  - "Tell what an exponent applies to, as in (-3)^2 and -3^2."
  - "Evaluate an expression after substituting negative values."
---
## Core Concept

### Put a Negative Value in Parentheses

To **substitute** means to replace a letter with its number. When the number is negative, put it in parentheses first. The parentheses keep the minus sign attached to its number.

If $x=-2$:

$$3x=3(-2)=-6$$

$$x^2=(-2)^2$$

$$\dfrac{12}{x}=\dfrac{12}{-2}=-6$$

Write the parentheses even when they seem extra. They cost nothing, and they stop the mistakes below.

### What an Exponent Applies To

An exponent applies only to what sits right before it. If that is a closing parenthesis, the exponent applies to everything inside the parentheses. If it is a number, the exponent applies to that number alone.

<!-- ILLUSTRATION: two side-by-side panels. Left: (-3)^2 with a teal outline around "(-3)" joined to the exponent 2, then = (-3) x (-3) = 9. Right: -3^2 with a teal outline around only "3" joined to the exponent 2, the minus sign outside it, then = -(3 x 3) = -9 -->

$$(-3)^2=(-3)\times(-3)=9$$

Here the exponent applies to $-3$, so you multiply two negatives. Same signs give a positive answer.

$$-3^2=-(3\times3)=-9$$

Here the exponent applies to $3$ only. You square $3$ to get $9$, then the minus sign in front makes it $-9$.

:::why
Why does the exponent go first in $-3^2$? Powers come before multiplying, and the minus sign in front works like multiplying by $-1$. So $-3^2$ means $-1\times3^2$, which is $-1\times9=-9$.
:::

:::pair #exponent-scope
Right: if $x=-3$, then $x^2=(-3)^2=9$
Wrong: if $x=-3$, then $x^2=-3^2=-9$
The wrong line left out the parentheses, so the exponent applied to $3$ alone.
:::

The count of negative signs tells you the sign of a power, too. A negative number to an even power is positive. To an odd power, it is negative.

$$(-2)^2=(-2)\times(-2)=4$$

$$(-2)^3=(-2)\times(-2)\times(-2)=-8$$

:::check
If $a=-4$, find $a^2$.
:::answer
The answer is $16$. Substitute with parentheses: $(-4)^2=(-4)\times(-4)=16$.
:::

:::check
If $a=-4$, find $-a^2$.
:::answer
The answer is $-16$. Substitute with parentheses: $-(-4)^2$. Square first: $(-4)^2=16$. The minus sign in front then makes it $-16$.
:::

## Examples

### #1: Two Variables, One Negative

If $x=-2$ and $y=3$, evaluate $x^2-3xy+\dfrac{12}{x}$.

**Solution:**

1. Substitute. Put $-2$ in parentheses.

$$(-2)^2-3(-2)(3)+\dfrac{12}{-2}$$

2. Do the power. The exponent applies to $-2$, so multiply two negatives.

$$(-2)^2=4$$

3. Do the product. Work out the number: $3\times2\times3=18$. There is one negative sign, which is odd, so the product is negative.

$$3(-2)(3)=-18$$

4. Do the division. The signs are different, so the answer is negative.

$$\dfrac{12}{-2}=-6$$

5. Put each answer back. Keep the signs between the parts.

$$4-(-18)+(-6)$$

6. Subtracting $-18$ is the same as adding $18$.

$$4+18+(-6)$$

:::pair #minus-before-negative
Right: $4-(-18)+(-6)=4+18+(-6)$
Wrong: $4-(-18)+(-6)=4-18+(-6)$
The wrong line kept only one minus sign. A minus sign before $-18$ makes a plus, so the wrong line ends at $-20$ instead of $16$.
:::

7. Add from left to right.

$$4+18=22$$

$$22+(-6)=16$$

The answer is $16$.

**Check:** Without parentheses, $x^2$ becomes $-2^2=-4$, and the whole expression becomes $-4+18-6=8$. If you got $8$, go back to step 1.

### #2: Two Negative Values

If $a=-3$ and $b=-1$, evaluate $2a^2-ab+b^3$.

**Solution:**

1. Substitute. Put both values in parentheses.

$$2(-3)^2-(-3)(-1)+(-1)^3$$

2. Do the powers. An even power of a negative is positive. An odd power is negative.

$$(-3)^2=9$$

$$(-1)^3=-1$$

3. Do the products. In $(-3)(-1)$ the signs are the same, so the product is positive.

$$2\times9=18$$

$$(-3)(-1)=3$$

4. Put each answer back. Keep the signs between the parts.

$$18-3+(-1)$$

:::try
Finish the last step: $18-3+(-1)$.
:::answer
The answer is $14$. First $18-3=15$. Then $15+(-1)=14$.

**Check:** $b^3$ had to be negative, because $-1$ was raised to an odd power. The middle part had to be taken away, because $ab$ is positive when both values are negative.
:::

## Traps to Watch For

:::checklist
- No parentheses on $-3^2$: square $3$ first, then keep the minus ($-9$). {#exponent-scope}
- Substituting a negative value: put it in parentheses first, so $x=-3$ gives $x^2=(-3)^2=9$. {#put-a-negative-value-in-parentheses}
- A minus sign before a negative product: the two signs make a plus, so $4-(-18)=22$. {#minus-before-negative}
:::
