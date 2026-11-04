---
_id: "lesson-statistics-and-probability-measures-of-variability"
title: "Measures of Variability (Range, Variance, Standard Deviation)"
summary: "How to measure how spread out a data set is using range, variance, and standard deviation, and how shifting or scaling the data changes them."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 12
isActive: true
---
## Core Concept

Two data sets can have the same mean and very different spreads. The **mean** is the sum of the values divided by how many values there are. **Measures of variability** tell how far apart the values are.

<!-- ILLUSTRATION: two dot plots on the same number line from 0 to 10; Set A has dots at 3, 4, 5, 6, 7; Set B has dots at 1, 3, 5, 7, 9; a vertical line marks the mean 5 on both plots -->

Both sets above have mean $5$. Set B is more spread out.

### Population and sample

A **population** is the whole group you want to describe. A **sample** is a smaller part of that group, used to learn about it.

A number that describes a population is a **parameter**. A number computed from a sample is a **statistic**. The sample mean is a statistic that estimates the population mean.

### Range

The **range** is the largest value minus the smallest value.

$$\text{range}=\text{maximum}-\text{minimum}$$

The range uses only two values, so it ignores how the other values are placed. If there is only one value, or all values are equal, the range is $0$.

### Deviation

A **deviation** is a value minus the mean: $x-\text{mean}$. A value above the mean has a positive deviation. A value below the mean has a negative deviation.

The deviations from the mean always add up to $0$. So their plain average cannot measure spread. Variance squares each deviation first, so none of them cancel.

### Population variance and standard deviation

For a population of $N$ values with mean $\mu$:

$$\sigma^2=\dfrac{\sum (x-\mu)^2}{N}$$

$$\sigma=\sqrt{\sigma^2}$$

Here $\sum$ means "add up all of these". The **variance** $\sigma^2$ is the average squared deviation. The **standard deviation** $\sigma$ is its nonnegative square root.

### Sample variance and standard deviation

For a sample of $n$ values with sample mean $\bar{x}$:

$$s^2=\dfrac{\sum (x-\bar{x})^2}{n-1}$$

$$s=\sqrt{s^2}$$

A sample mean sits closer to the sample's own values than the true mean does. Dividing by $n-1$ instead of $n$ corrects for this, so $s^2$ estimates the population variance better.

A sample of one value has $n-1=0$, so $s^2$ is not defined. For the same values, if they are not all equal, the sample variance is larger than the population variance. If they are all equal, both are $0$.

### Reading the results

Variance is in squared units. Standard deviation is in the same units as the data. A smaller standard deviation means the values sit closer to the mean. A larger one means more spread.

Standard deviation compares spread only for data in the same units. A mean and a standard deviation do not give the full list of values.

### Shifting and scaling the data

Suppose each value $x$ becomes $ax+b$, where $a$ and $b$ are numbers. Then:

- The new mean is $a\cdot\text{(old mean)}+b$.
- The new standard deviation is $|a|$ times the old one.
- The new variance is $a^2$ times the old one.
- The new range is $|a|$ times the old one.

The number $b$ moves every value the same distance, so the spread does not change. The number $a$ stretches the distances between values. A negative $a$ flips the data, but distances are never negative, so $|a|$ is used.

### Mean and variance of a random variable

A **random variable** $X$ is a number whose value depends on chance, such as the score on one spin of a game wheel. A **discrete** random variable takes separate values that you can list. A **probability table** lists each value $x$ with its probability $P(x)$. The probabilities are between $0$ and $1$, and they add up to $1$.

The **mean** of $X$, also called the **expected value** $E(X)$, is the long-run average. Multiply each value by its probability, then add.

$$E(X)=\sum x\cdot P(x)$$

The mean may not be one of the listed values. For one roll of a fair die, $E(X)=3.5$.

The **variance** of $X$ is the average squared distance from $E(X)$. Multiply each squared value by its probability, add, then subtract $[E(X)]^2$.

$$\text{Var}(X)=\sum x^2\cdot P(x)-[E(X)]^2$$

The standard deviation is $\sqrt{\text{Var}(X)}$.

## Examples

### #1: Range

Find the range of $4,8,15,16,23,42$.

**Solution:**
1. The maximum is $42$ and the minimum is $4$.
2. Subtract.

$$42-4=38$$

3. The range is $38$.

### #2: Population or Sample?

A teacher records the quiz scores of all $35$ students in her class to describe that class. A principal records the scores of $30$ students picked from the $1{,}200$ students of the school to estimate the school's average. For each, is the group a population or a sample? Is the mean a parameter or a statistic?

**Solution:**
1. The teacher describes only her class and has every score. Her $35$ scores are a population, and her mean is a parameter.
2. The principal wants to learn about all $1{,}200$ students but has only $30$ scores. Her scores are a sample, and her mean is a statistic.
3. Variance and standard deviation use $N$ for the teacher's data and $n-1$ for the principal's data.

### #3: Population Variance and Standard Deviation

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

### #4: Sample Variance and Standard Deviation

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

### #5: Zero Spread

Find the standard deviation of the population $6,6,6,6$.

**Solution:**
1. The mean is $6$, so every deviation is $0$.
2. Every squared deviation is $0$, so the variance is $0$.
3. The standard deviation is $0$.

If the values are not all equal, at least one deviation is not $0$, so the standard deviation is greater than $0$. A sample of at least two equal values also has $s=0$.

### #6: Comparing Consistency

Two archers each have a mean score of $8$ per shot. Ana's scores have a standard deviation of $0.5$. Bella's have a standard deviation of $2.1$. Which archer's scores are closer to the mean? Can you tell from these numbers which archer is more likely to score exactly $10$?

**Solution:**
1. Ana has the smaller standard deviation, so her scores are closer to $8$.
2. A mean and a standard deviation do not give the full list of scores. Different sets of scores can share both numbers and still differ in how often they show $10$.
3. So the numbers show that Ana is more consistent. They do not show who is more likely to score $10$.

### #7: Shifting and Scaling the Data

A data set has mean $70$, standard deviation $6$, and variance $36$. Find the new mean and standard deviation if each score is (a) increased by $5$, (b) multiplied by $2$, (c) multiplied by $-3$.

**Solution:**
1. For (a), use $a=1$ and $b=5$. The mean becomes $70+5=75$. The standard deviation stays $6$.
2. For (b), use $a=2$. The mean becomes $2\times70=140$.

$$\text{new SD}=|2|\times6=12$$

3. For (c), use $a=-3$. The mean becomes $-3\times70=-210$.

$$\text{new SD}=|-3|\times6=18$$

4. The new variance in (c) is $(-3)^2\times36=324$, and $\sqrt{324}=18$ agrees with step 3.

### #8: Mean and Variance from a Probability Table

A game gives a score $X$ with this probability table, shown as a list. Find $E(X)$, $\text{Var}(X)$ and the standard deviation.

- $P(0)=0.1$
- $P(1)=0.3$
- $P(2)=0.4$
- $P(3)=0.2$

**Solution:**
1. The probabilities add up to $1$, so the table is valid.
2. Multiply each value by its probability and add.

$$E(X)=0(0.1)+1(0.3)+2(0.4)+3(0.2)=1.7$$

3. Multiply each squared value by its probability and add.

$$\sum x^2\cdot P(x)=0(0.1)+1(0.3)+4(0.4)+9(0.2)=3.7$$

4. Subtract the square of the mean.

$$\text{Var}(X)=3.7-(1.7)^2=3.7-2.89=0.81$$

5. Take the square root.

$$\sqrt{0.81}=0.9$$

## Speed Tricks & Shortcuts

When you compute by hand, add the deviations before squaring. If the mean is exact, the sum must be $0$. If it is not, recheck the mean or a subtraction. A mean you rounded gives a sum slightly off $0$.

To compare spread, compare standard deviations of data in the same units. The smaller one is less spread out.

To change between variance and standard deviation, square or take the nonnegative square root. Use the sample or the population version for both, not a mix.

For $ax+b$, ignore $b$ for spread and use $|a|$ for standard deviation. Use $a^2$ for variance.

## Traps to Watch For

### #1: Using the Wrong Denominator

> Divide by $N$ for a population and by $n-1$ for a sample.

Check whether the listed data are the whole group being described or a sample from a larger group. The problem should say which, directly or by its wording.

### #2: Averaging Raw Deviations

> The deviations from the mean add up to $0$, so square them first.

A zero average deviation does not mean zero spread. Raw deviations cancel out, so their average cannot measure spread. Squaring them first avoids this.

### #3: Giving Variance as Standard Deviation

> Variance is in squared units. Standard deviation is its square root.

If the variance is $4$, the standard deviation is $2$, not $4$.

### #4: Trusting the Range Too Much

> The range depends only on the largest and smallest values.

Two data sets can have the same range and different spread among the other values. For example, $0,5,5,5,10$ and $0,0,5,10,10$ both have range $10$, but the second set is more spread out.

### #5: Reading Too Much Into the Standard Deviation

> A mean and a standard deviation do not give the full list of values.

Without more information about the data, a larger standard deviation does not show that one exact value is more likely.

### #6: Forgetting the Absolute Value When Scaling

> The new standard deviation is $|a|$ times the old one.

Multiplying by a negative number never gives a negative standard deviation. Standard deviation is never below $0$.
