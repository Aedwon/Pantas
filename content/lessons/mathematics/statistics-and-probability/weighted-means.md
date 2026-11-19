---
_id: "lesson-statistics-and-probability-weighted-means"
title: "Weighted Means"
summary: "Find an average when some values count more than others."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
isActive: true
part: 4
partCount: 4
ordering: 4
keyPoints:
  - "Compute a weighted mean from values and weights."
---
## Core Concept

### Weighted Mean

A **weight** tells how much a value counts in an average. A weight of $3$ makes a value count like $3$ copies of that value. Larger weights give values more effect on the result.

A **weighted mean** uses these weights instead of counting every listed value equally. Multiply each value by its weight, then add the products. Call that total $T$.

Add all the weights and call their total $W$. Divide the weighted total by the total weight:

$$\text{weighted mean}=\dfrac{T}{W}$$

For this method, weights are not negative and their total is greater than $0$. If all weights are equal, the result is the ordinary mean.

## Examples

### #1: Weighted Mean

A student's grades are $90$ in a $3$-unit subject, $85$ in a $2$-unit subject, and $80$ in a $5$-unit subject. The school weights each grade by the subject's units. Find the weighted mean grade.

**Solution:**
1. Multiply each grade by its weight. The $5$-unit subject counts more than either of the other subjects.

$$90(3)=270$$

$$85(2)=170$$

$$80(5)=400$$

2. Add these products to find $T$.

$$T=270+170+400=840$$

3. Add the weights to find $W$.

$$W=3+2+5=10$$

4. Divide the weighted total by the total weight.

$$\text{weighted mean}=\dfrac{840}{10}=84$$

5. The weighted mean grade is $84$.

## Traps to Watch For

### #1: Ignoring Weights

> A larger weight makes a value count more in the average.

The plain mean of $90,85,$ and $80$ is $85$. It gives each subject equal weight, so it does not answer the unit-weighted question, whose answer is $84$.
