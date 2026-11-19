---
_id: "lesson-statistics-and-probability-population-variance-and-standard-deviation"
title: "Population Variance and Standard Deviation"
summary: "Find spread from squared deviations from the mean."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 2
partCount: 6
ordering: 0
keyPoints:
  - "Use squared deviations to find population variance."
  - "Convert between variance and standard deviation."
---
## Core Concept

### Deviation

A **deviation** is a value minus the mean: $x-\text{mean}$. A value above the mean has a positive deviation. A value below the mean has a negative deviation.

The deviations from the mean always add up to $0$. So their plain average cannot measure spread. Variance squares each deviation first, so none of them cancel.

### Population variance and standard deviation

For a population of $N$ values with mean $\mu$:

$$\sigma^2=\dfrac{\sum (x-\mu)^2}{N}$$

$$\sigma=\sqrt{\sigma^2}$$

Here $\sum$ means "add up all of these". The **variance** $\sigma^2$ is the average squared deviation. The **standard deviation** $\sigma$ is its nonnegative square root.

## Examples

### #1: Population Variance and Standard Deviation

Treat the complete data set $2,4,4,4,5,5,7,9$ as a population. Find its variance and standard deviation.

**Solution:**
1. Find the mean.

$$\mu=\dfrac{2+4+4+4+5+5+7+9}{8}=\dfrac{40}{8}=5$$

2. The deviations are $-3,-1,-1,-1,0,0,2,4$. They add up to $0$.
3. The squared deviations are $9,1,1,1,0,0,4,16$. Their sum is $32$.
4. The data are the whole population, so divide by $N=8$.

$$\sigma^2=\dfrac{32}{8}=4$$

5. Take the square root.

$$\sigma=\sqrt{4}=2$$

### #2: Zero Spread

Find the standard deviation of the population $6,6,6,6$.

**Solution:**
1. The mean is $6$, so every deviation is $0$.
2. Every squared deviation is $0$, so the variance is $0$.
3. The standard deviation is $0$.

If the values are not all equal, at least one deviation is not $0$, so the standard deviation is greater than $0$. A sample of two or more values that are all equal also has $s=0$.

## Speed Tricks & Shortcuts

When you compute by hand, add the deviations before squaring. If the mean is exact, the sum must be $0$, so any other sum means you should recheck the mean or a subtraction. A mean you rounded gives a sum slightly off $0$.

To change between variance and standard deviation, square or take the nonnegative square root. Use the sample or the population version for both, not a mix.

## Traps to Watch For

### #1: Averaging Raw Deviations

> The deviations from the mean add up to $0$, so square them first.

A zero average deviation does not mean zero spread. Raw deviations cancel out, so their average cannot measure spread. Squaring them first avoids this.

### #2: Giving Variance as Standard Deviation

> Variance is in squared units. Standard deviation is its square root.

If the variance is $4$, the standard deviation is $2$, not $4$.
