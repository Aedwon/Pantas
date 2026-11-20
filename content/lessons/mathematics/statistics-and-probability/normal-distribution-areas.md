---
_id: "lesson-statistics-and-probability-normal-distribution-areas"
title: "Normal Distribution Areas"
summary: "Turn a value into a z-score and use the area under a bell curve to find its probability."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 1
partCount: 1
ordering: 24
keyPoints:
  - "Use cumulative areas to find probabilities."
  - "Use the shape of the normal curve and the 68-95-99.7 rule."
  - "Convert between a value and its z-score."
  - "Read and use areas from a standard normal table."
---
## Core Concept

### Probability is area under the curve

A probability distribution shows where values are likely to fall. For a measurement that can vary without gaps, like time, the area under its curve gives the chance of falling in a range. The whole area is $1$.

The **cumulative distribution function** $F(x)$ gives the area from the far left up to $x$. It tells you the chance of getting $x$ or less. For the area to the right, use $1-F(x)$. For the area between $a$ and $b$, with $a<b$, use $F(b)-F(a)$. You take away the area before $a$.

<!-- ILLUSTRATION: normal curve with the area to the left of x shaded and labeled F(x) -->

A **normal distribution** has a bell-shaped curve. The mean is at the center, where the curve is highest. The two sides are mirror images. About $68\%$, $95\%$, and $99.7\%$ of the area lies within $1$, $2$, and $3$ standard deviations of the mean, in that order. Each band goes the same distance to the left and right.

### Find the z-score, then read the left area

A **z-score** tells you how many standard deviations a value is from the mean. Subtract the mean $\mu$ from the value $x$. Then divide by the standard deviation $\sigma$.

$$z=\dfrac{x-\mu}{\sigma}$$

A value below the mean has a negative z-score. To go back to the original value, use $x=\mu+z\sigma$.

The **standard normal curve** has mean $0$ and standard deviation $1$. Changing to z-scores keeps the same areas. In a left-area table, the row gives the signed z-score through the tenths place. The column gives the hundredths digit. Where they meet, you get the area to the left of that z-score.

## Examples

### #1: Find the Chance of Finishing by a Set Time

Finishing times follow a normal distribution with a mean of $40$ minutes and a standard deviation of $8$ minutes. Find the chance of finishing in $50$ minutes or less.

**Solution:** The z-score is $\dfrac{50-40}{8}=1.25$. Read row $1.2$ and column $0.05$ in the left-area table. The entry is $0.8944$, so the chance is about $89.44\%$.

### #2: Find One Tail

Find the share of values more than two standard deviations above the mean of a normal distribution.

**Solution:** About $95\%$ lies in the middle band. That leaves about $5\%$ outside it. The two tails have equal areas, so the upper tail holds about $2.5\%$.

## Traps to Watch For

### #1: Reading the Wrong Area

Check the table heading. Some tables give the area from $0$ to $z$. The table used here gives the whole area to the left of $z$.
