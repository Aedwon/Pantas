---
_id: "lesson-data-interpretation-percentage-change"
title: "Finding Percentage Change"
summary: "Compare a change with its original value to find the percentage change."
subject: "subject-mathematics"
topic: "topic-data-interpretation"
isActive: true
part: 1
partCount: 4
ordering: 4
keyPoints:
  - "Find the signed change and divide by the positive original value."
  - "Recognize that ordinary percentage change from zero is not defined."
---
## Core Concept

### Measuring Change from the Original Value

**Percentage change** compares how much a number went up or down against where it started. Always divide by the **original** value, never the new value.

$$\text{Change}=\text{new}-\text{original}$$

$$\text{Percent change}=\dfrac{\text{change}}{\text{original}}\times100\%$$

When the original value is positive, a positive answer means an increase and a negative answer means a decrease.

Suppose Product A revenue grows from $40$ million pesos in $2024$ to $50$ million pesos in $2025$.

1. Find the change (new minus original):

$$50-40=10$$

2. Divide by the original $2024$ value ($40$), not $50$:

$$\dfrac{10}{40}=0.25$$

3. Multiply by $100\%$ to write as a percent:

$$0.25\times100\%=25\%$$

Product A increased by $25\%$.

<!-- FIGURE WANTED: two-step arrow diagram starting at 100, top curved arrow right to 80 labeled "-20 (-20% of 100)", bottom curved arrow right from 80 back to 100 labeled "+20 (+25% of 80)" -->

:::why
The drop starts from $100$, so $\dfrac{-20}{100}=-20\%$. The rise back up starts from $80$, so $\dfrac{20}{80}=25\%$. Each starting number sets the percent size.
:::

:::pair #divide-by-new-value
Right: $\dfrac{50-40}{40}\times100\%=\dfrac{10}{40}\times100\%=25\%$
Wrong: $\dfrac{50-40}{50}\times100\%=\dfrac{10}{50}\times100\%=20\%$
The wrong line divided by the new value ($50$) instead of the original value ($40$). Always put the earlier starting number in the denominator.
:::

:::pair #label-change-as-percent
Right: $50-40=10$, then $\dfrac{10}{40}\times100\%=25\%$
Wrong: $50-40=10\%$
The wrong answer put a percent sign directly on the raw difference of $10$. A difference must be divided by the original value before it becomes a percent.
:::

When a question combines two categories (for example, $20$ rising to $28$, up $40\%$, and $30$ rising to $36$, up $20\%$), add to get the original total and the new total first:

$$\text{Original total}=20+30=50$$

$$\text{New total}=28+36=64$$

Then find the change and divide by the original total:

$$64-50=14$$

$$\dfrac{14}{50}\times100\%=28\%$$

Averaging the two separate rates gives $\dfrac{40\%+20\%}{2}=30\%$, which is wrong because the larger category ($30$) grew more slowly than the smaller category ($20$).

:::check
A fund rises from $60$ thousand pesos to $69$ thousand pesos. What is the percentage increase?
:::answer
The answer is $15\%$. The change is $69-60=9$, and dividing by the original $60$ gives $\dfrac{9}{60}\times100\%=15\%$.
:::

### When the Original Value Is Zero

If the starting value is $0$, the formula tries to divide by $0$. You can never divide by $0$, so ordinary percentage change is **undefined**.

Report the actual change in counts or pesos instead, unless the question states a special rule.

Suppose an office has $0$ volunteers in January and $12$ volunteers in February.

$$\text{Change}=12-0=12$$

Because the original value is $0$, $\dfrac{12}{0}$ is undefined. You cannot report a percentage increase.

:::pair #percent-from-zero
Right: Undefined, because the starting count is $0$
Wrong: The percentage increase is $100\%$
Going from $0$ to $12$ is not $100\%$. Doubling a nonzero number gives $100\%$ growth, whereas dividing by $0$ has no value.
:::

:::check
Weekly sales go from $0$ units to $15$ units. Can you compute an ordinary percentage increase?
:::answer
No, it is undefined. Because the starting value is $0$, dividing by $0$ is not allowed.
:::

## Examples

### #1: Percentage Increase

An agency budget increased from $50$ million pesos in $2020$ to $65$ million pesos in $2021$. Find the percentage increase.

**Solution:**

1. Find the change (new minus original).

$$65-50=15$$

2. Divide the change by the original $2020$ budget ($50$).

$$\dfrac{15}{50}=0.30$$

3. Multiply by $100\%$ to convert to percent.

$$0.30\times100\%=30\%$$

The budget increased by $30\%$.

**Check:** Find $30\%$ of the original $50$ million: $50\times0.30=15$. Adding $50+15=65$ million pesos, which matches $2021$.

### #2: Percentage Decrease

A supply cost fell from $80,000$ pesos to $68,000$ pesos. Find the signed percentage change.

**Solution:**

1. Find the signed change (new minus original).

$$68,000-80,000=-12,000$$

2. Divide by the original cost ($80,000$).

$$\dfrac{-12,000}{80,000}=-0.15$$

:::try
Finish the last step: multiply $-0.15$ by $100\%$ to write the signed percentage change.
:::answer
The answer is $-15\%$, meaning a $15\%$ decrease. Multiply $-0.15\times100\%=-15\%$.

**Check:** Ten percent of $80,000$ is $8,000$, and $5\%$ is $4,000$, so $15\%$ is $8,000+4,000=12,000$. Taking $12,000$ off $80,000$ leaves $68,000$, which matches.
:::

## Traps to Watch For

:::checklist
- Choosing the denominator: divide the change by the original value, never the new value. {#divide-by-new-value}
- Finding a raw difference like $10$: divide by the starting value before writing a percent sign. {#label-change-as-percent}
- Original value equal to $0$: ordinary percentage change is undefined because division by $0$ is not allowed. {#percent-from-zero}
:::
