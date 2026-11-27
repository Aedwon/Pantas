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

Bar charts and line charts show numbers along an axis marked with **tick marks**. Often only major ticks carry numbers, with smaller unlabeled ticks evenly between.

When a bar or point falls between labeled ticks, do not guess its value by eye. Count the spaces to find the size of one tick step first:

$$\text{One tick step}=\dfrac{\text{gap between labeled ticks}}{\text{number of spaces}}$$

A vertical axis is labeled every $100$ units, and there are $5$ equal spaces from $0$ to $100$. Find the size of one small tick step.

$$\dfrac{100}{5}=20$$

Each small tick step is $20$ units. A bar sits $3$ small ticks above $200$. Find its value.

$$3\times20=60$$

$$200+60=260$$

If the axis label gives a unit such as "in hundreds" or "in thousands," multiply your chart reading by that unit before reporting the final answer. An axis says "Visitors, in hundreds" and a bar reaches $2.4$. Find the number of visitors.

$$2.4\times100=240$$

The bar represents $240$ visitors.

:::pair #ignore-axis-unit
Right: $2.4\times100=240\text{ visitors}$
Wrong: $2.4\text{ visitors}$
The wrong reading copied the number off the axis and ignored the "in hundreds" label. When the axis states a unit, multiply the reading by it.
:::

### Subtracting Values Across a Reference Line

To find a difference between two bars or points, read each value carefully using the tick step, then subtract the smaller value from the larger one unless a signed change is requested.

One reading may sit above a labeled line and the other below it. A line chart shows reservoir volume in thousands of liters, with tick steps of $5$. Monday's point is $2$ ticks above $40$, and Friday's point is $1$ tick below $40$. Find the drop from Monday to Friday.

1. Find Monday's reading:

$$2\times5=10$$

$$40+10=50$$

2. Find Friday's reading:

$$40-5=35$$

3. Subtract to find the drop, then multiply by $1,000$:

$$50-35=15$$

$$15\times1,000=15,000$$

<!-- ILLUSTRATION: vertical axis of reservoir volume in thousands of liters with ticks 35, 40, 45 and 50 and a line at 40; Monday's point at 50 is 2 ticks above the line and Friday's point at 35 is 1 tick below it; a bracket from Friday to Monday reads 2 + 1 = 3 ticks, 3 × 5 = 15, drop 15 thousand = 15,000 liters -->

The volume decreased by $15,000$ liters.

:::why
Why add the $2$ ticks above $40$ and the $1$ tick below $40$? Moving from $35$ up to $40$ takes $1$ tick step, and moving from $40$ up to $50$ takes $2$ more steps. That makes $2+1=3$ steps total, and $3\times5=15$ thousand liters.
:::

:::pair #subtract-ticks-wrong-side
Right: $2+1=3\text{ intervals}$, giving $3\times5=15\text{ thousand}=15,000\text{ liters}$
Wrong: $2-1=1\text{ interval}$, giving $1\times5=5\text{ thousand}=5,000\text{ liters}$
The wrong line subtracted the tick counts instead of adding them. When two points lie on opposite sides of a reference line like $40$, add their distances from that line.
:::

Office A reads $3.5$ and Office B reads $2.5$, in hundreds. How many more applications did A process?

:::pair #add-instead-of-subtract-chart
Right: $3.5-2.5=1\text{ hundred}=100\text{ applications}$
Wrong: $3.5+2.5=6\text{ hundreds}=600\text{ applications}$
When a question asks "how many more" or "decrease," subtract the two readings instead of adding them.
:::

:::check
A chart shows visitors in hundreds, labeled every $2$ with $4$ equal spaces. Bar P is $3$ small ticks above $6$, and Bar Q is $1$ small tick above $4$. How many more visitors did P have than Q?
:::answer
The answer is $300$ visitors. One tick step is $\dfrac{2}{4}=0.5$, so P is $6+3\times0.5=7.5$ and Q is $4+0.5=4.5$. The difference is $7.5-4.5=3$ hundred, which is $300$ visitors.
:::

## Examples

### #1: Reading a Chart Scale and Finding a Difference

<!-- ILLUSTRATION: bar chart titled "Factory Output" with x-axis labels Factory A and Factory B, y-axis labeled "Units produced" from 0 to 500, labeled every 100 with smaller tick marks every 20; Factory A bar reaches 440 and Factory B bar reaches 320 -->

Use the bar chart. How many more units did Factory A produce than Factory B?

**Solution:**

1. Labeled ticks are $100$ units apart with $5$ equal spaces between them. Find one small tick.

$$\dfrac{100}{5}=20$$

2. Read Factory A: the bar is $2$ small ticks above $400$.

$$2\times20=40$$

$$400+40=440$$

3. Read Factory B: the bar is $1$ small tick above $300$.

$$300+20=320$$

:::try
Finish the last step: subtract Factory B's units from Factory A's units.
:::answer
The answer is $120$ more units. Subtract $440-320=120$.
:::

## Speed Tricks & Shortcuts

Find one small tick's value and the axis unit once, then use them for every reading on that axis.

## Traps to Watch For

:::checklist
- Axis labeled "in hundreds" or "in thousands": multiply your bar reading by that unit before answering. {#ignore-axis-unit}
- Two values on opposite sides of a labeled line: add their distances from that line to get the full difference. {#subtract-ticks-wrong-side}
- Asked "how many more" or "by how much": subtract the smaller chart value from the larger, do not add them. {#add-instead-of-subtract-chart}
:::
