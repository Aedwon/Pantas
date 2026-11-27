---
_id: "lesson-data-interpretation-unit-rates-and-direct-proportion"
title: "Using Unit Rates and Direct Proportion"
summary: "Find a unit rate and use it to scale quantities at the same rate."
subject: "subject-mathematics"
topic: "topic-data-interpretation"
isActive: true
part: 3
partCount: 4
ordering: 6
keyPoints:
  - "Divide to find a unit rate with the correct units."
  - "Scale quantities at a constant rate using direct proportion."
---
## Core Concept

### Finding a Unit Rate with Matching Units

A **rate** compares two quantities with different units, such as pesos per envelope or pages per minute. A **unit rate** tells the amount for $1$ unit.

$$\text{Unit rate}=\dfrac{\text{total amount}}{\text{number of units}}$$

Match the order of your division to the words in the question. For "pesos per envelope," pesos go on top and total envelopes go on the bottom.

Suppose $8$ boxes of envelopes hold $25$ envelopes per box and cost $1,260$ pesos total.

1. Find the total number of envelopes first:

$$8\times25=200$$

2. Divide total pesos by total envelopes:

$$\dfrac{1,260}{200}=6.30$$

Each envelope costs $6.30$ pesos.

:::why
Why does pesos go on top for "pesos per envelope"? The word "per" means "for each $1$," so you divide by whatever unit follows "per."
:::

:::pair #wrong-unit-rate-order
Right: $\dfrac{1,260\text{ pesos}}{200\text{ envelopes}}=6.30\text{ pesos per envelope}$
Wrong: $\dfrac{200\text{ envelopes}}{1,260\text{ pesos}}\approx0.16\text{ pesos}$
The wrong line flipped the division and found envelopes per peso instead of pesos per envelope. Put the requested "per" unit in the denominator.
:::

Also make sure your time unit matches the question. If you find a rate per minute and the question asks for a rate **per hour**, multiply the per-minute rate by $60$ (since $1\text{ hour}=60\text{ minutes}$).

Suppose a scanner processes $315$ pages in $45$ minutes.

$$\dfrac{315}{45}=7\text{ pages per minute}$$

$$7\times60=420\text{ pages per hour}$$

:::pair #missing-hour-conversion
Right: $315\div45=7\text{ pages/min}$, then $7\times60=420\text{ pages/hour}$
Wrong: $315\div45=7\text{ pages/hour}$
Dividing by $45$ minutes gives pages per minute. Multiply by $60$ to convert from per minute to per hour.
:::

:::check
A machine packs bottles at a constant $12$ bottles per minute. How many bottles does it pack in $40$ minutes?
:::answer
The answer is $480$ bottles. Multiply the rate by the time: $12\times40=480$.

**Check:** Divide back: $\dfrac{480}{40}=12$ bottles per minute.
:::

### Scaling with Direct Proportion

In a **direct proportion**, two quantities move in the same direction by the same factor. When the rate stays constant, doubling one quantity doubles the other, and multiplying one quantity by $1.5$ multiplies the other by $1.5$.

You can always find the unit rate first, then multiply by the new number of units.

Suppose a pump delivers $450$ liters in $12$ minutes at a constant rate. How many liters will it deliver during two $9$-minute runs?

1. Find the total pumping time:

$$2\times9=18\text{ minutes}$$

2. Find the unit rate (liters per minute):

$$\dfrac{450}{12}=37.5$$

3. Multiply by $18$ minutes:

$$37.5\times18=675$$

The pump delivers $675$ liters.

:::pair #reverse-direct-scale
Right: $18\text{ minutes}$ is more than $12\text{ minutes}$, so $37.5\times18=675\text{ liters}$
Wrong: $450\times\dfrac{12}{18}=300\text{ liters}$
The wrong line scaled down when pumping time went up. At a constant rate, more minutes must deliver more water, not less.
:::

:::check
Seven identical pens cost $63$ pesos. At the same price per pen, how much do $12$ pens cost?
:::answer
The answer is $108$ pesos. One pen costs $\dfrac{63}{7}=9$ pesos, and $12$ pens cost $9\times12=108$ pesos.
:::

## Examples

### #1: Finding a Unit Rate

A machine packs $240$ boxes in $6$ hours at a steady rate. How many boxes does it pack per hour?

**Solution:**

1. Check the units: total boxes ($240$) and total hours ($6$) already match "boxes per hour."
2. Divide total boxes by total hours.

$$\dfrac{240}{6}=40$$

The unit rate is $40$ boxes per hour.

**Check:** Multiply $40$ boxes per hour by $6$ hours: $40\times6=240$ boxes, which matches the given total.

### #2: Scaling a Direct Proportion

Four identical notebooks cost $120$ pesos. At the same price per notebook, how much do $10$ notebooks cost?

**Solution:**

1. Divide the total cost by $4$ to find the unit rate (the price of $1$ notebook).

$$\dfrac{120}{4}=30$$

One notebook costs $30$ pesos.

:::try
Finish the last step: multiply the unit price by $10$ notebooks to find the total cost.
:::answer
The answer is $300$ pesos. Multiply $30\times10=300$.

**Check:** Ten notebooks is $2.5$ times as many as $4$ notebooks ($\dfrac{10}{4}=2.5$). Scaling $120$ pesos by $2.5$ gives $120\times2.5=300$ pesos, which matches.
:::

## Traps to Watch For

:::checklist
- Finding "amount per unit": put the quantity after "per" in the denominator, never flip the division. {#wrong-unit-rate-order}
- Given minutes when asked "per hour": find the per-minute rate first, then multiply by $60$. {#missing-hour-conversion}
- Direct proportion when units increase: total output or cost must increase by the same factor, never decrease. {#reverse-direct-scale}
:::
