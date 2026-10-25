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

A **measure of central tendency** is a value that describes the center or typical value of a data set. Three common measures are the mean, median, and mode.

The **mean** is the arithmetic average. Add all values, then divide by the number of values.

$$\text{mean}=\dfrac{\text{sum of values}}{\text{number of values}}$$

The **median** is the middle value after the data are sorted from smallest to largest. With an odd number of values, use the one middle value. With an even number, find the mean of the two middle values.

A **mode** is a value that appears most often. A set can have more than one mode if values tie for the highest frequency. In many basic problems, a set in which every value appears once is said to have no mode.

The best measure depends on the data. The mean uses every value, so one very large or very small value can pull it away from most of the data.

The median mainly depends on the order of the values. One extreme value may change a lot without moving the median much. For data with a strong outlier, the median often gives a better typical center.

A **weight** tells how much a value counts in an average. A larger weight gives that value more effect on the result. A **weighted mean** uses the weights instead of counting every listed value equally.

$$\text{weighted mean}=\dfrac{\text{sum of }(\text{value}\times\text{weight})}{\text{sum of weights}}$$

## Examples

### #1: Mean

Find the mean of $4,7,8,10,11$.

**Solution:**
1. Add the values.

$$4+7+8+10+11=40$$

2. Divide by the $5$ values.

$$\dfrac{40}{5}=8$$

3. The mean is $8$.

### #2: Median

Find the median of (a) $15,3,9,7,11,5$ and (b) $12,4,9,7,20$.

**Solution:**
1. Sort the first set.

$$3,5,7,9,11,15$$

2. It has $6$ values, so use the mean of the two middle values, $7$ and $9$.

$$\dfrac{7+9}{2}=8$$

3. The first median is $8$.
4. Sort the second set.

$$4,7,9,12,20$$

5. It has $5$ values, so the one middle value is $9$. The second median is $9$.

### #3: Mode

Find the mode of each set: (a) $2,4,4,5,7,7,7,9$, (b) $1,2,2,3,3,4$, and (c) $5,6,7,8$.

**Solution:**
1. In set (a), $7$ appears $3$ times, more than any other value. The mode is $7$.
2. In set (b), $2$ and $3$ each appear $2$ times, which is the highest frequency. The modes are $2$ and $3$.
3. In set (c), every value appears once. Under the basic convention used here, the set has no mode.

### #4: Working Backwards from the Mean

After $4$ quizzes, Mia's mean score is $85$. Her first $3$ scores were $80$, $88$, and $90$. What was her fourth score?

**Solution:**
1. Find the total score needed for $4$ quizzes.

$$4\times85=340$$

2. Add the known scores.

$$80+88+90=258$$

3. Subtract the known total from the needed total.

$$340-258=82$$

4. The fourth score was $82$.
5. Check the mean.

$$\dfrac{258+82}{4}=85$$

### #5: Weighted Mean

A student earns $90$ in a $3$-unit subject, $85$ in a $2$-unit subject, and $80$ in a $5$-unit subject. Find the weighted mean grade.

**Solution:**
1. Each subject's units are its weight. Multiply each grade by its weight.

$$90(3)=270$$

$$85(2)=170$$

$$80(5)=400$$

2. Add the weighted values.

$$270+170+400=840$$

3. Add the weights.

$$3+2+5=10$$

4. Divide the weighted total by the total weight.

$$\dfrac{840}{10}=84$$

5. The weighted mean is $84$.

### #6: Choosing Mean or Median With an Outlier

The amounts, in pesos, spent by $5$ customers are $20,22,25,26,300$. Find the mean and median. Which one better shows a typical amount for this data set?

**Solution:**
1. Find the mean.

$$\dfrac{20+22+25+26+300}{5}=\dfrac{393}{5}=78.6$$

2. The values are already sorted. The middle value is $25$, so the median is $25$.
3. The value $300$ is much larger than the other $4$ values. It pulls the mean up.
4. The median of $25$ is closer to the group from $20$ to $26$, so the median better shows a typical amount here.

## Speed Tricks & Shortcuts

For nearby numbers, you can compare each value with an easy middle number. A **deviation** here means how far a value is above or below that chosen number.

For $4,7,8,10,11$, choose $8$. The deviations are $-4,-1,0,+2,+3$. They add to $0$, so the mean is $8$.

If one new value is added and the mean stays the same, the new value must equal the old mean. A value above the old mean raises the new mean, while a value below it lowers the new mean.

For backwards-mean problems, first find the total with:

$$\text{total}=\text{mean}\times\text{number of values}$$

Then subtract the values you already know.

## Traps to Watch For

### #1: Median Without Sorting

> Sort the values before choosing the middle.

The middle entries in the written order are not the median unless the data are already sorted.

### #2: Letting an Outlier Pull the Center

> A very large or very small value can pull the mean far from most values.

For $20,22,25,26,300$, the mean is $78.6$ and the median is $25$. The median better represents the typical value in this set.

### #3: Ignoring Weights

> A larger weight must make a value count more in the average.

A plain mean of $90,85,$ and $80$ gives each subject equal weight. It does not match a unit-weighted mean when the subjects have different units.

### #4: Missing a Second Mode

> Every value tied for the highest frequency is a mode.

If $2$ and $3$ each occur more often than every other value, both are modes. Do not keep only one of them.
