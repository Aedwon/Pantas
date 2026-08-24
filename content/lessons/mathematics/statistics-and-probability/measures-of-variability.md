---
_id: "lesson-statistics-and-probability-measures-of-variability"
title: "Measures of Variability (Range, Variance, Standard Deviation)"
summary: "How to measure how spread out a data set is using range, variance, and standard deviation."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 11
isActive: true
---
## Core Concept

Two data sets can have the same mean and very different spreads. **Measures of variability** describe how dispersed the values are.

The **range** is:

$$\text{range}=\text{maximum}-\text{minimum}$$

**Variance** and **standard deviation** use deviations from the mean. The exact denominator depends on whether the data represent an entire population or a sample used to estimate a larger population.

### Population variance and standard deviation

For a population of $N$ values with mean $\mu$:

$$\sigma^2=\dfrac{\sum (x-\mu)^2}{N}$$

$$\sigma=\sqrt{\sigma^2}$$

### Sample variance and standard deviation

For a sample of $n$ values with sample mean $\bar{x}$:

$$s^2=\dfrac{\sum (x-\bar{x})^2}{n-1}$$

$$s=\sqrt{s^2}$$

The standard deviation is in the same units as the original data; variance is in squared units. A smaller standard deviation means the observations are, in this sense, more tightly clustered around the mean. A larger one means greater spread around the mean.

Raw deviations from their own arithmetic mean sum to $0$. Squaring them prevents positive and negative deviations from cancelling in the variance calculation.

## Examples

### #1: Range

Find the range of $4,8,15,16,23,42$.

**Solution:**
1. Maximum $=42$, minimum $=4$.

$$42-4=38$$

2. The range is $38$.

### #2: Population Variance and Standard Deviation

Treat the complete data set $2,4,4,4,5,5,7,9$ as the population of interest. Find its population variance and population standard deviation.

**Solution:**
1. The population mean is:

$$\mu=\dfrac{40}{8}=5$$

2. Deviations: $-3,-1,-1,-1,0,0,2,4$.
3. Squared deviations: $9,1,1,1,0,0,4,16$, whose sum is $32$.
4. Because these eight values are the entire population being described, divide by $N=8$.

$$\sigma^2=\dfrac{32}{8}=4$$

5. Take the square root.

$$\sigma=2$$

If the same eight values were instead treated as a sample from a larger population, the sample variance would divide by $n-1=7$ instead.

### #3: Zero Spread

Find the standard deviation of $6,6,6,6$.

**Solution:**
1. Every value equals the mean, so every deviation is $0$.
2. Whether treated as a population or a nontrivial sample, all squared deviations are $0$.
3. The standard deviation is therefore $0$.

A standard deviation of $0$ occurs exactly when all observations are identical.

### #4: Comparing Consistency

Two archers each have a mean score of $8$ per shot. Ana's scores have a standard deviation of $0.5$; Bella's have a standard deviation of $2.1$. Which archer has scores that are more tightly clustered around the mean? Can you determine from these two statistics alone which archer is more likely to score exactly $10$?

**Solution:**
1. Ana has the smaller standard deviation, so her scores are more tightly clustered around the common mean of $8$.
2. Mean and standard deviation alone do **not** determine the full distribution of scores. Different distributions can share the same mean and standard deviation while assigning different probabilities to an exact score such as $10$.
3. Therefore, the information given supports the conclusion that Ana is more consistent in spread, but it is insufficient to say which archer is more likely to score exactly $10$.

### #5: Shifting and Scaling the Data

A data set has mean $70$ and standard deviation $6$. Every score is increased by $5$. What are the new mean and standard deviation? What if every score is instead multiplied by $2$?

**Solution:**
1. Adding $5$ to every value raises the mean by $5$.

$$\text{new mean}=75$$

2. Adding a constant leaves all deviations from the mean unchanged, so the standard deviation stays $6$.
3. Multiplying every value by $2$ doubles both the mean and the magnitude of every deviation.

$$\text{new mean}=140\qquad\text{new SD}=12$$

4. More generally, if every value is transformed by $Y=aX+b$, then the mean becomes $a\mu+b$ (or $a\bar{x}+b$) and the standard deviation becomes $|a|$ times the original standard deviation.

## Speed Tricks & Shortcuts

For hand calculations, check that deviations from the calculated mean sum to $0$ before squaring. If they do not, recheck the mean or subtraction.

For questions about which data set is more tightly clustered around the mean, compare standard deviations when the values are in the same units and context. A smaller SD means less spread around that mean.

Variance and standard deviation convert by squaring or taking the nonnegative square root, provided you keep straight whether the quantity is the sample version ($s^2,s$) or population version ($\sigma^2,\sigma$).

## Traps to Watch For

### #1: Using the Wrong Denominator

> Population variance divides by $N$; sample variance divides by $n-1$.

A problem should tell you, directly or by context, whether the listed data are the complete population being described or a sample used to estimate a population.

### #2: Averaging Raw Deviations

> Deviations from the arithmetic mean sum to zero; variance uses squared deviations.

A zero average raw deviation does not mean the data have zero spread.

### #3: Reporting Variance as Standard Deviation

> Variance is in squared units; standard deviation is its nonnegative square root and uses the original units.

If the population variance is $4$, the population standard deviation is $2$.

### #4: Range Uses Only the Extremes

> Range depends only on the maximum and minimum.

Two data sets can have the same range and very different distributions among their interior values.

### #5: Standard Deviation Does Not Determine Exact Probabilities

> A mean and standard deviation summarize location and spread; they do not specify the entire distribution.

Without additional distribution information or assumptions, a larger SD does not by itself prove that a particular exact extreme value is more likely.
