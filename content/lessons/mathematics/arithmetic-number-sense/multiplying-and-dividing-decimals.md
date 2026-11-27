---
_id: "lesson-arithmetic-number-sense-multiplying-and-dividing-decimals"
title: "Multiplying and Dividing Decimals"
summary: "Multiply decimals by counting places, and divide by shifting both decimal points."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 4
partCount: 6
ordering: 18
keyPoints:
  - 'Multiply decimals using the total decimal places.'
  - 'Divide decimals by moving both decimal points equally.'
---
## Core Concept

### Multiplying Decimals

When you multiply two decimals, ignore the decimal points at first. Multiply the digits as whole numbers. Then count all the digits after the decimal point in both factors, and put that same count of decimal places in your answer.

Find $2.4\times0.35$. Multiply without the points first.

$$24\times35=840$$

Count the decimal places in both factors. The number $2.4$ has $1$ place, and $0.35$ has $2$ places. Together, that is $1+2=3$ places.

Start at the right end of $840$ and count $3$ places left.

$$2.4\times0.35=0.840$$

$$0.840=0.84$$

:::pair #count-both-decimal-places
Right: $2.4\times0.35=0.84$
Wrong: $2.4\times0.35=8.4$
The wrong answer used only $2$ decimal places instead of $3$. Count the decimal places in both factors and add those counts together.
:::

Keep any trailing zeros in the whole-number product until after you place the decimal point. If you run out of digits while counting left, fill the empty spots with zeros on the left.

Find $0.16\times0.05$. First multiply the whole numbers.

$$16\times5=80$$

The factors have $2+2=4$ decimal places in all. Count $4$ places left from the right end of $80$. You need two extra zeros on the left.

$$0.16\times0.05=0.0080$$

$$0.0080=0.008$$

:::pair #extra-leading-zero
Right: $0.16\times0.05=0.008$
Wrong: $0.16\times0.05=0.0008$
The wrong answer put one too many zeros after the decimal point. Keep the $0$ in $80$ when you count $4$ places from the right, and drop trailing zeros only at the end.
:::

:::why
Why does counting decimal places work? Writing $0.16=\dfrac{16}{100}$ and $0.05=\dfrac{5}{100}$ gives $\dfrac{16\times5}{100\times100}=\dfrac{80}{10,000}$. Dividing by $10,000$ shifts the point $4$ places left.
:::

### Dividing by a Decimal

In a division problem, the **dividend** is the number being divided. The **divisor** is the number you divide by. The **quotient** is the answer.

To divide by a nonzero decimal, turn the divisor into a whole number first.

1. Move the divisor's decimal point right until it reaches the end of the number.
2. Move the dividend's decimal point the exact same number of places right. Add zeros on the right of the dividend if you need extra places.
3. Divide as usual, keeping the decimal point lined up above the dividend.

Find $0.72\div0.015$. The divisor $0.015$ needs $3$ places right to become $15$. Move the point $3$ places right in $0.72$ as well, adding one zero at the end.

$$0.72\div0.015=720\div15$$

$$720\div15=48$$

<!-- ILLUSTRATION: two stacked number cards. The top card shows 0.72 and the bottom card shows 0.015, with a division sign between them. Three curved hop arrows move the decimal point 3 places right on 0.015 to give 15. Three curved hop arrows move the decimal point 3 places right on 0.72, with one highlighted 0 added at the end, to give 720. Below, 720 ÷ 15 = 48. Both points move the same number of places. -->

When the quotient is not a whole number, the point in the answer sits directly above the point in the dividend. Find $7.5\div0.2$. Moving both points $1$ place right gives:

$$7.5\div0.2=75\div2$$

Write $75$ as $75.0$ and divide. The number $2$ goes into $7$ three times and into $15$ seven times, with $1$ left. Put the point in the answer above the point in $75.0$. Then $2$ goes into $10$ five times.

$$75\div2=37.5$$

Never divide by $0$. An expression such as $4.8\div0$ has no answer and is **undefined**.

:::why
Why does moving both points give the same answer? Shifting both points $3$ places right multiplies both numbers by $1,000$. Writing $\dfrac{0.72}{0.015}\times\dfrac{1,000}{1,000}=\dfrac{720}{15}$ multiplies by $1$, so the value does not change.
:::

:::check
Find $0.5\times0.35$, then divide that product by $0.007$.
:::answer
The answer is $25$. First $5\times35=175$ with $1+2=3$ places gives $0.175$. Then move both points $3$ places right: $0.175\div0.007=175\div7=25$.
:::

## Examples

### #1: Area with Small Decimals

Find the area of a rectangular metal plate that measures $0.64$ meter by $0.075$ meter, in square meters.

**Solution:**

1. Multiply the length and width without decimal points.

$$64\times75=4,800$$

2. Count the total decimal places in both factors. The number $0.64$ has $2$ places, and $0.075$ has $3$ places.

$$2+3=5$$

3. Count $5$ places left from the right end of $4,800$, adding one zero on the left.

$$0.64\times0.075=0.04800$$

4. Drop the trailing zeros after the decimal point.

$$0.04800=0.048$$

The area is $0.048$ square meter.

### #2: Cutting Equal Lengths

A roll of wire is $5.4$ meters long. Find how many pieces of length $0.15$ meter can be cut from the roll.

**Solution:**

1. Divide the total length $5.4$ by the length of one piece, $0.15$.

2. The divisor $0.15$ needs $2$ decimal places right to become the whole number $15$. Move the decimal point in $5.4$ the same $2$ places right by adding a zero.

$$5.4\div0.15=540\div15$$

:::try
Finish the last step: divide $540$ by $15$.
:::answer
The answer is $36$ pieces. Divide $540\div15=36$.
:::

## Speed Tricks & Shortcuts

When dividing decimals, you can also turn a simple decimal into a fraction. For example, $0.25=\dfrac{1}{4}$ and $0.125=\dfrac{1}{8}$. Dividing by $0.125$ is the same as multiplying by $8$.

## Traps to Watch For

:::checklist
- Multiplying two decimals: add the decimal-place counts from both factors before placing the point. {#count-both-decimal-places}
- Leading zeros in a small product: keep trailing zeros in the whole-number product while counting left, then drop them at the end. {#extra-leading-zero}
- Dividing by a decimal: move both decimal points the same number of places right until the divisor is a whole number. {#dividing-by-a-decimal}
:::
