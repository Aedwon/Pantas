---
_id: "lesson-statistics-and-probability-measures-of-central-tendency"
title: "Measures of Central Tendency (Mean, Median, Mode)"
summary: "This lesson teaches you how to find the mean, median, and mode of a data set and when each one best describes the center."
subject: "subject-mathematics"
topic: "topic-statistics-and-probability"
estimatedMinutes: 11
isActive: true
---
## Core Concept

A **measure of central tendency** is one number that describes the CENTER of a whole data set. There are three, and each answers "what is typical?" in its own way.

The **mean** is the everyday average: add all the values, divide by how many there are.

$$\text{mean} = \dfrac{\text{sum of values}}{\text{number of values}}$$

The **median** is the MIDDLE value after sorting from smallest to largest. With an odd count, it is the exact middle number. With an even count, it is the mean of the two middle numbers.

The **mode** is the value that appears MOST OFTEN. A set can have one mode, two modes (bimodal), or no mode at all (when every value appears equally often).

Which one should describe the data? The mean uses every value, but it is easily dragged around by an **outlier** (one extreme value). The median ignores extremes, so it stays put. That is why house prices and salaries are usually reported as medians: one billionaire in the neighborhood wrecks the mean but barely touches the median.

CETs test three skills here: straight computation, working BACKWARDS from a known mean, and weighted averages of grades.

## Examples

### #1: Mean

Find the mean of $4, 7, 8, 10, 11$.

**Solution:**
Add, then divide by the count.

1. Add the values.

$$4 + 7 + 8 + 10 + 11 = 40$$

2. Divide by $5$, the number of values.

$$\dfrac{40}{5} = 8$$

3. The mean is $8$.

### #2: Median of an Even-Sized Set

Find the median of $15, 3, 9, 7, 11, 5$.

**Solution:**
Sort first. Always sort first.

1. In order: $3, 5, 7, 9, 11, 15$.
2. Six values means TWO middle numbers: the third and fourth, which are $7$ and $9$.
3. Average them.

$$\dfrac{7 + 9}{2} = 8$$

4. The median is $8$.

### #3: Mode

Find the mode of $2, 4, 4, 5, 7, 7, 7, 9$ and the mode of $1, 2, 3, 4$.

**Solution:**
Count repeats.

1. In the first set, $4$ appears twice, but $7$ appears three times.
2. The mode of the first set is $7$.
3. In the second set, every value appears exactly once. No value wins.
4. The second set has NO mode. (Not a mode of $0$ — zero is not even in the set.)

### #4: Working Backwards from the Mean

After four quizzes, Mia's average is $85$. Her first three scores were $80$, $88$, and $90$. What was her fourth score?

**Solution:**
Turn the average back into a TOTAL.

1. Four quizzes averaging $85$ means the total is:

$$4 \times 85 = 340$$

2. Add the three known scores.

$$80 + 88 + 90 = 258$$

3. Subtract to find the missing score.

$$340 - 258 = 82$$

4. Mia scored $82$. Check: $\dfrac{258 + 82}{4} = \dfrac{340}{4} = 85$. Correct.

### #5: Weighted Mean (Exam Level)

A student earns $90$ in a $3$-unit subject, $85$ in a $2$-unit subject, and $80$ in a $5$-unit subject. Find the student's weighted average grade.

**Solution:**
Bigger subjects count more. Multiply each grade by its units, then divide by the TOTAL units.

1. Multiply each grade by its weight.

$$90 \times 3 = 270 \qquad 85 \times 2 = 170 \qquad 80 \times 5 = 400$$

2. Add the products.

$$270 + 170 + 400 = 840$$

3. Divide by the total units, $3 + 2 + 5 = 10$.

$$\dfrac{840}{10} = 84$$

4. The weighted average is $84$. The plain mean of the three grades, $85$, is WRONG here, because the $5$-unit subject must pull harder.

## Speed Tricks & Shortcuts

For the mean of numbers that are close together, guess a base and average the leftovers. For $4, 7, 8, 10, 11$: guess $8$, and the differences are $-4, -1, 0, +2, +3$, which add to $0$. The differences sum to zero, so the mean is exactly $8$. Small differences are much faster than big sums.

When one value is added to a set and the mean must stay the same, the new value must EQUAL the old mean. And if a new value raises the mean, the new value is above the old mean — you can often answer "higher or lower" questions with no arithmetic at all.

Backwards-mean problems are always the same two moves: total equals mean times count, then subtract what you know.

## Traps to Watch For

### #1: Median Without Sorting

> ALWAYS sort the data before picking the middle.

The median of $15, 3, 9, 7, 11, 5$ is not "$9$ and $7$ averaged" just because they sit in the middle of the LIST. Sort first: the true middles are $7$ and $9$ only after ordering. Test-makers scramble the list so the unsorted middle gives a different, planted answer.

### #2: The Outlier Drags the Mean

> One extreme value moves the mean a lot, the median a little, and the mode not at all.

For the salaries $20, 22, 25, 26, 300$ (in thousands), the mean is $78.6$ but the median is $25$. If a question asks which measure best represents a set WITH an outlier, the answer is the median. Choosing the mean here is the intended mistake.

### #3: Weighted Grades, Unweighted Mean

> When units or weights are given, the plain average of the grades is wrong.

In Example $5$, averaging $90$, $85$, and $80$ gives $85$, and $85$ is sitting right there in the choices. If the problem mentions units, hours, or weights, every grade must be multiplied by its weight first. Divide by total WEIGHT, not by the number of grades.

### #4: "No Mode" Is Not "Mode Zero"

> A set where nothing repeats has NO mode, and a bimodal set has TWO modes.

Writing the mode of $1, 2, 3, 4$ as $0$ invents a value that is not in the data. And for $3, 3, 8, 8, 10$, the modes are $3$ AND $8$ — picking just one is incomplete. Read the choices carefully; "no mode" and "two modes" both appear as options.
