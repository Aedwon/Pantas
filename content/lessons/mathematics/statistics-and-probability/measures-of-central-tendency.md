---
_id: "lesson-statistics-and-probability-measures-of-central-tendency"
title: "Measures of Central Tendency (Mean, Median, Mode)"
summary: "How to find and choose the mean, median, mode, and weighted mean of a data set."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 13
isActive: true
---
## Core Concept

A **measure of central tendency** gives the center or typical value of a group of data. Three common measures are mean, median, and mode.

### Mean, Median, and Mode

The **mean** is the arithmetic average. Add all values, then divide by the number of values.

$$\text{mean}=\dfrac{\text{sum of values}}{\text{number of values}}$$

You can also work backward from a mean. Multiply the mean by the number of values to find their total.

$$\text{total}=\text{mean}\times\text{count}$$

Subtract the total of the known values to find a missing value.

The **median** is the middle value after sorting from smallest to largest. With an odd count, use the one middle value. With an even count, average the two middle values.

If the two middle values are $a$ and $b$:

$$\text{median}=\dfrac{a+b}{2}$$

A **mode** is a value that appears most often. Its **frequency** is how many times it appears. Values tied for the highest frequency are all modes.

In the basic convention used here, a set with every value appearing once has no mode.

### Choosing a Center

The mean uses every value. One very large or very small value can pull it away from most of the group. Such an unusual value is called an **outlier**.

The median depends on the order. An outlier can become much larger without changing the middle value. For data with a strong outlier, the median often gives a better typical center.

The mode shows what appears most often. It can also work for names or categories, such as the most common shoe color. A mean cannot be found for color names.

### Weighted Mean

A **weight** tells how much a value counts in an average. A weight of $3$ makes a value count like $3$ copies of that value. Larger weights give values more effect on the result.

A **weighted mean** uses these weights instead of counting every listed value equally. Multiply each value by its weight, then add the products. Call that total $T$.

Add all the weights and call their total $W$. Divide the weighted total by the total weight:

$$\text{weighted mean}=\dfrac{T}{W}$$

For this method, weights are not negative and their total is greater than $0$. If all weights are equal, the result is the ordinary mean.

## Examples

### #1: Mean

Find the mean of $4,7,8,10,11$.

**Solution:**
1. Add the values.

$$4+7+8+10+11=40$$

2. Divide by the $5$ values.

$$\dfrac{40}{5}=8$$

3. The mean is $8$.

### #2: Median With Even and Odd Counts

Find the median of (a) $15,3,9,7,11,5$ and (b) $12,4,9,7,20$.

**Solution:**
1. Sort the first set.

$$3,5,7,9,11,15$$

2. It has $6$ values. Average the middle values, $7$ and $9$.

$$\dfrac{7+9}{2}=8$$

3. The first median is $8$. Now sort the second set.

$$4,7,9,12,20$$

4. There are $5$ values. The one middle value is $9$, so the second median is $9$.

### #3: One Mode, Tied Modes, and No Mode

Find the mode of each set: (a) $2,4,4,5,7,7,7,9$, (b) $1,2,2,3,3,4$, and (c) $5,6,7,8$.

**Solution:**
1. In set (a), $7$ appears $3$ times. No other value appears as often. The mode is $7$.
2. In set (b), $2$ and $3$ each appear $2$ times. Both have the highest frequency, so the modes are $2$ and $3$.
3. In set (c), every value appears once. Under the basic convention used here, there is no mode.

### #4: Working Backward from the Mean

After $4$ quizzes, Mia's mean score is $85$ points. Her first $3$ scores were $80$, $88$, and $90$ points. What was her fourth score?

**Solution:**
1. Find the total needed for $4$ quizzes.

$$4\times85=340$$

2. Add the known scores.

$$80+88+90=258$$

3. Subtract the known total.

$$340-258=82$$

4. The fourth score was $82$ points. Check the mean.

$$\dfrac{258+82}{4}=85$$

### #5: Weighted Mean

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

### #6: Choosing a Center With an Outlier

The amounts, in pesos, spent by $5$ customers are $20,22,25,26,300$. Find the mean and median. Which better shows a typical amount for this group?

**Solution:**
1. Add the amounts.

$$20+22+25+26+300=393$$

2. Divide by the number of customers.

$$\text{mean}=\dfrac{393}{5}=78.6$$

3. The amounts are already sorted. The middle value is $25$, so the median is $25$ pesos.
4. The outlier, $300$ pesos, pulls the mean up to $78.6$ pesos. The other $4$ amounts are only $20$ to $26$ pesos.
5. The median of $25$ pesos better shows a typical amount here. It is close to most of the amounts.

## Speed Tricks & Shortcuts

For nearby numbers, choose an easy number near the middle. A **deviation** means how far a value is above or below that chosen number. Use a negative sign for below and a positive sign for above.

For $4,7,8,10,11$, choose $8$. The deviations are $-4,-1,0,+2,+3$. They add to $0$, so the values balance around $8$ and their mean is $8$.

If the deviations do not add to $0$, divide their total by the count. Add that result to the chosen number to get the mean.

If one new value is added and the mean stays the same, that value equals the old mean. A value above the old mean raises it. A value below lowers it.

For a missing-value problem, find the required total first. Then subtract the total of the known values.

## Traps to Watch For

### #1: Median Without Sorting

> Sort the values before choosing the middle.

The middle entry in the written order may give a wrong answer. The median uses the order from smallest to largest.

### #2: Letting an Outlier Pull the Center

> A very large or very small value can pull the mean away from most values.

For $20,22,25,26,300$, the mean is $78.6$ and the median is $25$. Choosing the mean as the typical amount here places it far above most of the group.

### #3: Ignoring Weights

> A larger weight makes a value count more in the average.

The plain mean of $90,85,$ and $80$ is $85$. It gives each subject equal weight, so it does not answer the unit-weighted question, whose answer is $84$.

### #4: Missing a Second Mode

> Every value tied for the highest frequency is a mode.

If $2$ and $3$ each occur more often than all other values, both are modes. Giving only $2$ leaves out another correct mode.
