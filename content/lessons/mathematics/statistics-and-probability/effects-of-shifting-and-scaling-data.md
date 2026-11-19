---
_id: "lesson-statistics-and-probability-effects-of-shifting-and-scaling-data"
title: "Effects of Shifting and Scaling Data"
summary: "Find what happens to the mean and spread when every value changes."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 5
partCount: 6
ordering: 9
keyPoints:
  - "Find the effect of a shift or scale on spread."
  - "Find the effect on the mean."
---
## Core Concept

### Shifting and scaling the data

Suppose each value $x$ becomes $ax+b$, where $a$ and $b$ are numbers. Then the following hold, where $|a|$ is $a$ without its sign (so $|-3|=3$):

- The new mean is $a\cdot\text{(old mean)}+b$.
- The new standard deviation is $|a|$ times the old one.
- The new variance is $a^2$ times the old one.
- The new range is $|a|$ times the old one.

The number $b$ moves every value the same distance, so the spread does not change. The number $a$ stretches the distances between values. A negative $a$ flips the data, but distances are never negative, so $|a|$ is used.

## Examples

### #1: Shifting and Scaling the Data

A data set has mean $70$, standard deviation $6$, and variance $36$. Find the new mean and standard deviation if each score is (a) increased by $5$, (b) multiplied by $2$, (c) multiplied by $-3$.

**Solution:**
1. For (a), use $a=1$ and $b=5$. The mean becomes $70+5=75$. The standard deviation stays $6$.
2. For (b), use $a=2$. The mean becomes $2\times70=140$.

$$\text{new SD}=|2|\times6=12$$

3. For (c), use $a=-3$. The mean becomes $-3\times70=-210$.

$$\text{new SD}=|-3|\times6=18$$

4. The new variance in (c) is $(-3)^2\times36=324$, and $\sqrt{324}=18$ agrees with step 3.

## Speed Tricks & Shortcuts

For $ax+b$, ignore $b$ for spread and use $|a|$ for standard deviation. Use $a^2$ for variance.

## Traps to Watch For

### #1: Forgetting the Absolute Value When Scaling

> The new standard deviation is $|a|$ times the old one.

Multiplying by a negative number never gives a negative standard deviation. Standard deviation is never below $0$.
