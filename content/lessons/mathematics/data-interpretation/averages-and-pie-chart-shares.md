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

Suppose an office records $0$ admissions in January, $12$ in February, and $18$ in March.

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

:::pair #total-instead-of-average
Right: $\text{Average}=\dfrac{6+8+5+9}{4}=\dfrac{28}{4}=7\text{ million pesos}$
Wrong: $\text{Average}=6+8+5+9=28\text{ million pesos}$
$28$ million pesos is the four-quarter total, not the average. Check whether the question asks for a total or an average, and divide once by the count of quarters.
:::

:::check
Four quarters list Licenses revenue of $6$, $8$, $5$, and $9$ million pesos. What is the average quarterly Licenses revenue?
:::answer
The answer is $7$ million pesos. Add $6+8+5+9=28$, then divide $\dfrac{28}{4}=7$.
:::

### Finding a Pie Chart Slice Amount

A pie chart shows how one whole total is split into parts. All slices in the circle together equal $100\%$. Use the full pie as the total, never one slice as a separate whole.

When a slice gives a percentage and you know the total amount for the full pie, find the slice amount with:

$$\text{Part}=\dfrac{\text{percent}}{100}\times\text{total}$$

If one slice has no percentage printed on it, add the percentages of the other slices and subtract from $100\%$ first.

Suppose a $480,000$-peso fund gives $45\%$ to personnel, $30\%$ to maintenance, and the rest to supplies.

1. Subtract the known slices from $100\%$ to get the supplies share:

$$100\%-45\%-30\%=25\%$$

2. Multiply $25\%$ (or $0.25$) by the total fund:

$$\dfrac{25}{100}\times480,000=120,000$$

Supplies receives $120,000$ pesos.

:::pair #sum-instead-of-remaining-slice
Right: $100\%-45\%-30\%=25\%$, giving $0.25\times480,000=120,000\text{ pesos}$
Wrong: $45\%+30\%=75\%$, giving $0.75\times480,000=360,000\text{ pesos}$
The wrong line stopped after adding the known slices. Subtract that $75\%$ from $100\%$ to find the remaining slice for supplies.
:::

When a question asks how much larger one slice is than another on the same pie chart, subtract the two percentages first, then multiply once by the total.

:::check
A $360,000$-peso budget gives $40\%$ to equipment and $25\%$ to training. How much more is allocated to equipment than to training?
:::answer
The answer is $54,000$ pesos. The slice difference is $40\%-25\%=15\%$, and $\dfrac{15}{100}\times360,000=54,000$.
:::

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

**Check:** The three numbers go up by the same step ($40,000$, $50,000$, $60,000$), so the middle number $50,000$ must be the average.

### #2: Reading a Pie Chart

<!-- ILLUSTRATION: pie chart titled "Training Budget" with slices Materials 35%, Venue 30%, Travel 20%, Other 15%, and a note below the chart that the total budget is 200,000 pesos -->

Use the pie chart. How much of the training budget is for Materials?

**Solution:**

1. Check that all slices belong to the same $100\%$ whole: $35\%+30\%+20\%+15\%=100\%$. Materials is $35\%$ of the $200,000$-peso budget.
2. Convert $35\%$ to a fraction out of $100$.

$$35\%=\dfrac{35}{100}=0.35$$

:::try
Finish the last step: multiply $0.35$ by the $200,000$-peso total budget.
:::answer
The answer is $70,000$ pesos. Multiply $0.35\times200,000=70,000$.

**Check:** Ten percent of $200,000$ is $20,000$. So $30\%$ is $3\times20,000=60,000$ and $5\%$ is $10,000$, giving $60,000+10,000=70,000$ pesos.
:::

## Traps to Watch For

:::checklist
- A recorded period with a value of $0$: include that period in the count when dividing for the average. {#skip-zero-in-average}
- Finding a pie chart slice amount: use the full $100\%$ circle as the total, never one slice as a separate whole. {#finding-a-pie-chart-slice-amount}
- Finding an unlabeled "remaining" pie slice: subtract all listed slices from $100\%$ before multiplying by the total. {#sum-instead-of-remaining-slice}
:::
