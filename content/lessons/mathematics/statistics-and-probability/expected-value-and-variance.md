---
_id: "lesson-statistics-and-probability-expected-value-and-variance"
title: "Expected Value and Variance"
summary: "Use a probability table to find the mean and spread of a random variable."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 6
partCount: 6
ordering: 0
keyPoints:
  - "Compute expected value from a probability table."
  - "Compute variance for a discrete random variable."
---
## Core Concept

### Mean and variance of a random variable

A **random variable** $X$ is a number whose value depends on chance, such as the score on one spin of a game wheel. A **discrete** random variable takes separate values that you can list.

A **probability table** lists each value $x$ with its probability $P(x)$, the chance that $X$ equals $x$. Each probability is at least $0$ and at most $1$. Together they add up to $1$.

The **mean** of $X$, also called the **expected value** $E(X)$, is the long-run average. Multiply each value by its probability, then add.

$$E(X)=\sum x\cdot P(x)$$

The mean may not be one of the listed values. For one roll of a fair die, $E(X)=3.5$.

The **variance** of $X$ is the average squared distance from $E(X)$. Multiply each squared value by its probability, add, then subtract $[E(X)]^2$.

$$\text{Var}(X)=\sum x^2\cdot P(x)-[E(X)]^2$$

The standard deviation is $\sqrt{\text{Var}(X)}$.

## Examples

### #1: Mean and Variance from a Probability Table

A game gives a score $X$ with this probability table, shown as a list. Find $E(X)$, $\text{Var}(X)$ and the standard deviation.

- $P(0)=0.1$
- $P(1)=0.3$
- $P(2)=0.4$
- $P(3)=0.2$

**Solution:**
1. Each probability is at least $0$ and at most $1$, and $0.1+0.3+0.4+0.2=1$, so the table is valid.
2. Multiply each value by its probability and add.

$$E(X)=0(0.1)+1(0.3)+2(0.4)+3(0.2)=1.7$$

3. Multiply each squared value by its probability and add.

$$\sum x^2\cdot P(x)=0(0.1)+1(0.3)+4(0.4)+9(0.2)=3.7$$

4. Subtract the square of the mean.

$$\text{Var}(X)=3.7-(1.7)^2=3.7-2.89=0.81$$

5. Take the square root.

$$\sqrt{0.81}=0.9$$
