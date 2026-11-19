---
_id: "lesson-statistics-and-probability-sample-variance-and-standard-deviation"
title: "Sample Variance and Standard Deviation"
summary: "Find spread when the data are a sample."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 3
partCount: 6
ordering: 7
keyPoints:
  - "Distinguish samples from populations."
  - "Compute sample variance and standard deviation."
---
## Core Concept

### Population and sample

A **population** is the whole group you want to describe. A **sample** is a smaller part of that group, used to learn about it.

A number that describes a population is a **parameter**. A number computed from a sample is a **statistic**. The sample mean is a statistic that estimates the population mean.

### Sample variance and standard deviation

For a sample of $n$ values with sample mean $\bar{x}$:

$$s^2=\dfrac{\sum (x-\bar{x})^2}{n-1}$$

$$s=\sqrt{s^2}$$

The squared distances from the values to their own sample mean add up to no more than the squared distances to the true mean, and usually less. Dividing by $n-1$ instead of $n$ corrects for this, so $s^2$ estimates the population variance better.

A sample of one value has $n-1=0$, so $s^2$ is not defined. For the same values, if they are not all equal, the sample variance is larger than the population variance. If they are all equal, both are $0$.

## Examples

### #1: Population or Sample?

A teacher records the quiz scores of all $35$ students in her class to describe that class. A principal records the scores of $30$ students picked from the $1{,}200$ students of the school to estimate the school's average. For each, is the group a population or a sample? Is the mean a parameter or a statistic?

**Solution:**
1. The teacher describes only her class and has every score. Her $35$ scores are a population, and her mean is a parameter.
2. The principal wants to learn about all $1{,}200$ students but has only $30$ scores. Her scores are a sample, and her mean is a statistic.
3. Variance and standard deviation use $N$ for the teacher's data and $n-1$ for the principal's data.

### #2: Sample Variance and Standard Deviation

A sample has the values $3,7,7,7$. Find the sample variance and sample standard deviation.

**Solution:**
1. Find the sample mean.

$$\bar{x}=\dfrac{3+7+7+7}{4}=\dfrac{24}{4}=6$$

2. The deviations are $-3,1,1,1$. They add up to $0$.
3. The squared deviations are $9,1,1,1$. Their sum is $12$.
4. This is a sample with $n=4$, so divide by $n-1=3$.

$$s^2=\dfrac{12}{3}=4$$

5. Take the square root.

$$s=\sqrt{4}=2$$

If the same four values were a whole population, the variance would be $\dfrac{12}{4}=3$.

## Traps to Watch For

### #1: Using the Wrong Denominator

> Divide by $N$ for a population and by $n-1$ for a sample.

Check whether the listed data are the whole group being described or a sample from a larger group. The problem should say which, directly or by its wording.
