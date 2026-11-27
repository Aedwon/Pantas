---
_id: "lesson-data-interpretation-averages-and-pie-chart-shares"
title: "Finding Averages and Pie Chart Shares"
summary: "Use a full set of values or a full total to find averages and pie chart shares."
subject: "subject-mathematics"
topic: "topic-data-interpretation"
isActive: true
part: 3
partCount: 3
ordering: 3
keyPoints:
  - "Add the recorded values and divide by their count to find an average."
  - "Use a pie slice percentage and the full total to find its amount."
---
## Core Concept

### Finding an Average Across Recorded Values

An **average**, or arithmetic mean, gives one balanced number for a set of values. To find it, add all recorded values and divide by how many values you added.

$$\text{Average}=\dfrac{\text{sum of values}}{\text{number of values}}$$

Count every recorded period in the group, including any period whose value is $0$. Zero adds nothing to the sum, yet that recorded period still counts in the denominator.

An office records $0$ admissions in January, $12$ in February, and $18$ in March. Find the monthly average.

$$0+12+18=30$$

There are $3$ recorded months, so divide by $3$:

$$\dfrac{30}{3}=10$$

The average is $10$ admissions per month.

:::why
Why does the $0$ month still count in the denominator? Zero means no admissions happened during a full recorded month. Spreading $30$ admissions over all $3$ months gives $10$ per month, not $15$.
:::

:::pair #skip-zero-in-average
Right: $\dfrac{0+12+18}{3}=\dfrac{30}{3}=10$
Wrong: $\dfrac{12+18}{2}=\dfrac{30}{2}=15$
The wrong line skipped January because its count was $0$. Include every recorded period when counting how many values to divide by.
:::

Four quarters earn $6$, $8$, $5$, and $9$ million pesos. Find the average.

:::pair #total-instead-of-average
Right: $\text{Average}=\dfrac{6+8+5+9}{4}=\dfrac{28}{4}=7\text{ million pesos}$
Wrong: $\text{Average}=6+8+5+9=28\text{ million pesos}$
$28$ million pesos is the four-quarter total, not the average. Check whether the question asks for a total or an average, and divide once by the count of quarters.
:::

:::check
A stall sells $0$ items on Monday, $9$ on Tuesday, $13$ on Wednesday, and $26$ on Thursday. How many more items than the daily average did it sell on Thursday?
:::answer
The answer is $14$ items. The sum is $0+9+13+26=48$ over $4$ days, so the average is $\dfrac{48}{4}=12$, and $26-12=14$.
:::

### Finding a Pie Chart Slice Amount

A pie chart shows how one whole total is split into parts. All slices in the circle together equal $100\%$. To find a slice amount, use the full pie as the total, not one slice as a separate whole.

When a slice gives a percentage and you know the total amount for the full pie, write the percentage as a decimal, then find the slice amount with:

$$\text{Part}=\text{share as a decimal}\times\text{total}$$

If one slice has no percentage printed on it, add the percentages of the other slices and subtract from $100\%$ first.

A $480,000$-peso fund gives $45\%$ to personnel, $30\%$ to maintenance, and the rest to supplies. Find the supplies amount.

1. Add the two known slices.

$$45\%+30\%=75\%$$

2. Subtract it from $100\%$ for the supplies share.

$$100\%-75\%=25\%$$

3. Write $25\%$ as the decimal $0.25$, then multiply by the total fund.

$$0.25\times480,000=120,000$$

Supplies receives $120,000$ pesos.

:::pair #sum-instead-of-remaining-slice
Right: $100\%-45\%-30\%=25\%$, giving $0.25\times480,000=120,000\text{ pesos}$
Wrong: $45\%+30\%=75\%$, giving $0.75\times480,000=360,000\text{ pesos}$
The wrong line stopped after adding the known slices. Subtract that $75\%$ from $100\%$ to find the remaining slice for supplies.
:::

When the total is known and a question asks how much larger one slice is than another on the same pie chart, subtract the two percentages first, then multiply once by the total.

On a $200,000$-peso pie, one slice is $40\%$ and another is $25\%$. The first slice is larger by:

$$40\%-25\%=15\%$$

$$0.15\times200,000=30,000$$

The first slice is $30,000$ pesos larger.

## Examples

### #1: Finding an Average Across Months

<!-- ILLUSTRATION: table titled "Monthly Revenue" with columns Month 1, Month 2, Month 3 and one row labeled "Revenue, pesos" with values 40,000, 50,000, 60,000 -->

Use the table. Find the average monthly revenue.

**Solution:**

1. Add the three monthly revenue amounts.

$$40,000+50,000+60,000=150,000$$

2. Divide the sum by $3$, the number of months added.

$$\dfrac{150,000}{3}=50,000$$

The average monthly revenue is $50,000$ pesos.

### #2: Reading a Pie Chart

<!-- ILLUSTRATION: pie chart titled "Training Budget" with slices Materials 35%, Venue 30%, Travel 20%, Other 15%, and a note below the chart that the total budget is 200,000 pesos -->

Use the pie chart. How much of the training budget is for Materials?

**Solution:**

1. Check that all slices belong to the same $100\%$ whole: $35\%+30\%+20\%+15\%=100\%$. Materials is $35\%$ of the $200,000$-peso budget.
2. Write $35\%$ as a fraction, then as a decimal.

$$35\%=\dfrac{35}{100}$$

$$\dfrac{35}{100}=0.35$$

:::try
Finish the last step: multiply $0.35$ by the $200,000$-peso total budget.
:::answer
The answer is $70,000$ pesos. Multiply $0.35\times200,000=70,000$.
:::

## Traps to Watch For

:::checklist
- A recorded period with a value of $0$: include that period in the count when dividing for the average. {#skip-zero-in-average}
- Finding a pie chart slice amount: use the full $100\%$ circle as the total, never one slice as a separate whole. {#finding-a-pie-chart-slice-amount}
- Finding an unlabeled "remaining" pie slice: subtract all listed slices from $100\%$ before multiplying by the total. {#sum-instead-of-remaining-slice}
:::
