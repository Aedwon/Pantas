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

Two classes can have the same average score but feel completely different: one where everyone scored near $80$, and one with scores all over the place. **Measures of variability** capture that spread.

The **range** is the quickest: biggest value minus smallest value.

$$\text{range} = \text{maximum} - \text{minimum}$$

The **variance** measures spread using every value. The recipe:

1. Find the mean.
2. Subtract the mean from each value (these are the **deviations**).
3. Square each deviation.
4. Average the squared deviations. That average is the variance.

The **standard deviation** (SD) is the square root of the variance. It undoes the squaring, so it speaks in the same units as the data. A small SD means the values huddle near the mean; a large SD means they scatter far.

Why square the deviations at all? Because raw deviations always cancel out: the negatives and positives sum to exactly $0$. Squaring makes everything positive so the spread can pile up.

CETs mostly ask three things: compute a range, compute a small variance or SD by hand, and compare two data sets ("who is more consistent?"). Consistent means small standard deviation.

## Examples

### #1: Range

Find the range of $4, 8, 15, 16, 23, 42$.

**Solution:**
Only the two extremes matter.

1. Maximum is $42$, minimum is $4$.

$$42 - 4 = 38$$

2. The range is $38$.

### #2: Variance and Standard Deviation

Find the variance and standard deviation of $2, 4, 4, 4, 5, 5, 7, 9$.

**Solution:**
Follow the recipe step by step.

1. The mean: the sum is $2 + 4 + 4 + 4 + 5 + 5 + 7 + 9 = 40$, and there are $8$ values.

$$\dfrac{40}{8} = 5$$

2. Deviations from $5$: $-3, -1, -1, -1, 0, 0, 2, 4$. (Check: they add to $0$.)
3. Square each: $9, 1, 1, 1, 0, 0, 4, 16$.
4. Average the squares.

$$\dfrac{9 + 1 + 1 + 1 + 0 + 0 + 4 + 16}{8} = \dfrac{32}{8} = 4$$

5. The variance is $4$. The standard deviation is its square root.

$$\sqrt{4} = 2$$

### #3: Zero Spread

Find the standard deviation of $6, 6, 6, 6$.

**Solution:**
Think before computing.

1. Every value equals the mean ($6$), so every deviation is $0$.
2. The squared deviations are all $0$, so the variance is $0$ and:

$$SD = 0$$

3. A standard deviation of $0$ means no spread at all: all values identical. This is the only way SD can be zero.

### #4: Who Is More Consistent?

Two archers each average $8$ points per shot. Ana's scores have a standard deviation of $0.5$; Bella's have a standard deviation of $2.1$. Who is more consistent, and who is more likely to score a $10$?

**Solution:**
Same mean, different spread.

1. Consistency means small spread. Ana's SD ($0.5$) is smaller, so ana is more consistent.
2. Scoring a $10$ means landing far above the mean of $8$. That needs a wide spread, so Bella, with the bigger SD, hits $10$ (and also $5$!) more often.
3. This is the classic CET question: low SD is steady, high SD is boom-or-bust.

### #5: Shifting and Scaling the Data

A data set has mean $70$ and standard deviation $6$. Every score is increased by $5$ points. What are the new mean and new standard deviation? What if instead every score were doubled?

**Solution:**
Shifts slide the data; scaling stretches it.

1. Adding $5$ to every value slides everything together. The mean moves with it.

$$70 + 5 = 75$$

2. But the distances between values do not change, so the standard deviation stays $6$.
3. Doubling every value stretches all distances by $2$. Both move:

$$\text{mean} = 140 \qquad SD = 12$$

4. Rule: adding a constant changes only the mean; multiplying by a constant multiplies both the mean and the SD.

## Speed Tricks & Shortcuts

Sum-check your deviations: they must add to exactly $0$ before you square. If they do not, your mean is wrong, and you just caught the error early instead of after four more steps.

For comparison questions ("more consistent", "more reliable", "steadier"), you never need to compute anything: just pick the smaller standard deviation. For "more likely to produce extreme values", pick the larger one.

Variance and SD convert instantly: SD is the square root of variance, variance is SD squared. If a problem gives one and asks for the other, it is a one-step answer hiding in word form.

## Traps to Watch For

### #1: Averaging Raw Deviations

> Deviations from the mean always sum to zero. Square them first.

Students skip the squaring, average the deviations, get $0$, and think the spread is zero. The cancellation is guaranteed by how the mean works — it proves nothing about spread. The squaring step is the whole point of variance.

### #2: Reporting Variance as SD

> Variance is in squared units; take the root for standard deviation.

In Example $2$ the variance is $4$ and the SD is $2$; both numbers sit in the choices. Read the question's last word carefully. If the data are in centimeters, variance is in square centimeters — a hint that it is not yet the SD.

### #3: Range Ignores the Middle

> The range only sees the two endpoints, never the crowd between them.

The sets $1, 50, 50, 50, 99$ and $1, 2, 3, 98, 99$ have the same range ($98$) but wildly different spreads. If a question asks which measure uses all the data, the answer is variance or standard deviation, never range.

### #4: A Negative Standard Deviation

> SD is never negative. The smallest possible value is $0$.

Squares are non-negative, and square roots of non-negatives are non-negative. Any choice offering a negative standard deviation is automatically wrong, no computation needed — a free elimination the test gives you.
