---
_id: "lesson-statistics-and-probability-measures-of-central-tendency"
title: "Measures of Central Tendency (Mean, Median, Mode)"
summary: "How to find the mean, median, and mode of a data set and when each one best describes the center."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 11
isActive: true
---
## Core Concept

A **measure of central tendency** is a value used to describe the center or typical location of a data set. Three common measures are the mean, median, and mode.

The **mean** (arithmetic average) is found by adding all values and dividing by the number of values.

$$\text{mean}=\dfrac{\text{sum of values}}{\text{number of values}}$$

The **median** is the middle value after sorting the data from smallest to largest. With an odd number of values, it is the single middle value. With an even number, it is the mean of the two middle values.

The **mode** is any value whose frequency is highest in the data set. A set may have one mode or several modes when multiple values tie for the highest frequency. In many introductory problems, a set in which every value occurs once is described as having no mode.

Which measure best represents the center depends on the data and the purpose. The mean uses every numerical value and is sensitive to extreme values. The median depends mainly on order, so an extreme value's exact magnitude has much less effect on it. For a strongly skewed data set or one with extreme outliers, the median is often a better description of a typical center.

## Examples

### #1: Mean

Find the mean of $4,7,8,10,11$.

**Solution:**
1. Add the values.

$$4+7+8+10+11=40$$

2. Divide by the $5$ values.

$$\dfrac{40}{5}=8$$

3. The mean is $8$.

### #2: Median of an Even-Sized Set

Find the median of $15,3,9,7,11,5$.

**Solution:**
1. Sort the data: $3,5,7,9,11,15$.
2. The two middle values are $7$ and $9$.
3. Average them.

$$\dfrac{7+9}{2}=8$$

4. The median is $8$.

### #3: Mode

Find the mode of $2,4,4,5,7,7,7,9$ and describe the mode of $1,2,3,4$ using the convention in this lesson.

**Solution:**
1. In the first set, $7$ occurs three times, more than any other value, so the mode is $7$.
2. In the second set, every value occurs once. Under the common introductory convention used here, the set is described as having no mode.

### #4: Working Backwards from the Mean

After four quizzes, Mia's mean score is $85$. Her first three scores were $80$, $88$, and $90$. What was her fourth score?

**Solution:**
1. Four quizzes with mean $85$ have total score:

$$4\times85=340$$

2. The known scores total:

$$80+88+90=258$$

3. Subtract.

$$340-258=82$$

4. The fourth score was $82$. Check: $(258+82)/4=85$.

### #5: Weighted Mean

A student earns $90$ in a $3$-unit subject, $85$ in a $2$-unit subject, and $80$ in a $5$-unit subject. Find the weighted mean grade.

**Solution:**
1. Multiply each value by its weight.

$$90(3)=270\qquad85(2)=170\qquad80(5)=400$$

2. Add the weighted values.

$$270+170+400=840$$

3. Divide by the total weight $3+2+5=10$.

$$\dfrac{840}{10}=84$$

4. The weighted mean is $84$.

## Speed Tricks & Shortcuts

For a mean of nearby numbers, a convenient reference value can reduce arithmetic. If you choose $8$ for $4,7,8,10,11$, the deviations are $-4,-1,0,+2,+3$, which sum to $0$, so the mean is exactly $8$.

If one new value is added to a data set and the mean stays unchanged, that new value must equal the old mean. If the new value is above the old mean, the new mean rises; if it is below, the new mean falls.

For backwards-mean problems, first recover the total with `mean × count`, then subtract the values already known.

## Traps to Watch For

### #1: Median Without Sorting

> Sort before identifying the middle position.

The middle entries in the original written order do not determine the median unless the data are already ordered.

### #2: Outliers and the Mean

> Extreme values can pull the mean much more than the median.

For $20,22,25,26,300$, the mean is $78.6$ while the median is $25$. The median is usually the more representative center for this strongly skewed example.

### #3: Weighted Values Need Weighted Averaging

> When weights or units are part of the problem, use them in both the numerator and denominator.

A plain mean of the listed grades gives each course equal influence and does not match a unit-weighted average.

### #4: Modes Depend on Frequency

> A mode is a value tied for the highest frequency.

A data set can have more than one mode. Do not invent the value $0$ when no value repeats, and do not discard a second value when two values share the highest frequency.
