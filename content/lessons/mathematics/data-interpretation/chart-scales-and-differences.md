---
_id: "lesson-data-interpretation-chart-scales-and-differences"
title: "Reading Chart Scales and Differences"
summary: "Read chart scales and subtract values to find a difference."
subject: "subject-mathematics"
topic: "topic-data-interpretation"
isActive: true
part: 2
partCount: 3
ordering: 2
keyPoints:
  - "Read axis labels and tick steps to find a chart value."
  - "Subtract chart values to find a difference."
---
## Core Concept

### Finding the Value of One Tick Mark

Bar charts and line charts show numbers along an axis marked with **tick marks**. Often only major ticks carry numbers, while smaller unlabeled ticks sit evenly between them.

Never guess a bar height or point by eye. Count the spaces to find the size of one tick step first:

$$\text{One tick step}=\dfrac{\text{gap between labeled ticks}}{\text{number of spaces}}$$

Suppose a vertical axis is labeled every $100$ units, and there are $5$ equal spaces from $0$ to $100$.

$$\dfrac{100}{5}=20$$

Each small tick step is $20$ units. If a bar sits $2$ small ticks above $400$:

$$400+2\times20=440$$

Also read the unit on the axis label, such as "in hundreds" or "in thousands." Multiply your chart reading by that unit before reporting the final answer. Suppose an axis says "Visitors, in hundreds" and a bar reaches $2.4$.

$$2.4\times100=240$$

The bar represents $240$ visitors.

:::pair #ignore-axis-unit
Right: $2.4\times100=240\text{ visitors}$
Wrong: $2.4\text{ visitors}$
The wrong reading copied the number off the axis and ignored the "in hundreds" label. Always multiply the axis reading by its stated unit.
:::

:::check
A chart axis is labeled every $50$ units, with $5$ equal spaces between labeled ticks. What is one tick step, and what value is $3$ ticks above $150$?
:::answer
One tick step is $10$ units, and the value is $180$. Divide $\dfrac{50}{5}=10$, then add $150+3\times10=180$.
:::

### Subtracting Values Across a Reference Line

To find a difference between two bars or points, read each value carefully using the tick step, then subtract the smaller value from the larger one unless a signed change is requested.

Watch carefully when one reading sits above a labeled line and the other sits below it. Suppose a line chart shows reservoir volume in thousands of liters, with tick steps of $5$. Monday's point is $2$ ticks above $40$, and Friday's point is $1$ tick below $40$.

1. Find Monday's reading:

$$40+2\times5=50$$

2. Find Friday's reading:

$$40-5=35$$

3. Subtract to find the drop in chart units, then multiply by $1,000$:

$$50-35=15$$

$$15\times1,000=15,000$$

The volume decreased by $15,000$ liters.

:::why
Why add the $2$ ticks above $40$ and the $1$ tick below $40$? Moving from $35$ up to $40$ takes $1$ tick step, and moving from $40$ up to $50$ takes $2$ more steps. That makes $2+1=3$ steps total, and $3\times5=15$ thousand liters.
:::

:::pair #subtract-ticks-wrong-side
Right: $2+1=3\text{ intervals}$, giving $3\times5=15\text{ thousand}=15,000\text{ liters}$
Wrong: $2-1=1\text{ interval}$, giving $1\times5=5\text{ thousand}=5,000\text{ liters}$
The wrong line subtracted the tick counts instead of adding them. When two points lie on opposite sides of a reference line like $40$, add their distances from that line.
:::

:::pair #add-instead-of-subtract-chart
Right: $3.5-2.5=1\text{ hundred}=100\text{ applications}$
Wrong: $3.5+2.5=6\text{ hundreds}=600\text{ applications}$
When a question asks "how many more" or "decrease," subtract the two readings instead of adding them.
:::

:::check
A bar chart reports applications in hundreds, with tick steps of $0.5$. Office A reaches $1$ tick above $3$, and Office B reaches $1$ tick below $3$. How many more applications did Office A process than Office B?
:::answer
The answer is $100$ applications. Office A is $3+0.5=3.5$, Office B is $3-0.5=2.5$, and $(3.5-2.5)\times100=100$.
:::

## Examples

### #1: Reading a Chart Scale and Finding a Difference

<!-- ILLUSTRATION: bar chart titled "Factory Output" with x-axis labels Factory A and Factory B, y-axis labeled "Units produced" from 0 to 500, labeled every 100 with smaller tick marks every 20; Factory A bar reaches 440 and Factory B bar reaches 320 -->

Use the bar chart. How many more units did Factory A produce than Factory B?

**Solution:**

1. Check the axis scale. Labeled ticks increase by $100$ units, and each small tick mark is $20$ units.
2. Read Factory A: the bar is $2$ small ticks above $400$.

$$400+2\times20=440$$

3. Read Factory B: the bar is $1$ small tick above $300$.

$$300+20=320$$

:::try
Finish the last step: subtract Factory B's units from Factory A's units.
:::answer
The answer is $120$ more units. Subtract $440-320=120$.

**Check:** Count the $20$-unit tick steps from $320$ up to $440$: $4$ steps reach $400$ and $2$ more reach $440$, making $6$ steps total, and $6\times20=120$ units.
:::

## Speed Tricks & Shortcuts

Find the value of one small tick and check the axis unit once at the start. Use that same scale for every reading on the chart instead of re-counting from zero each time.

## Traps to Watch For

:::checklist
- Axis labeled "in hundreds" or "in thousands": multiply your bar reading by that unit before answering. {#ignore-axis-unit}
- Two values on opposite sides of a labeled line: add their distances from that line to get the full difference. {#subtract-ticks-wrong-side}
- Asked "how many more" or "by how much": subtract the two chart values, never add them. {#add-instead-of-subtract-chart}
:::
