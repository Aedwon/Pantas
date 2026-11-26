---
_id: "lesson-arithmetic-number-sense-discounted-prices"
title: "Discounted Prices"
summary: "Apply discounts to the correct price."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 5
ordering: 37
keyPoints:
  - "Find a price after a discount."
  - "Apply successive discounts in order."
---
## Core Concept

### What a Percent Means

**Percent** means "out of $100$". So $20\%$ means $20$ out of every $100$.

To change a percent to a decimal, divide by $100$. That moves the decimal point two places to the left.

Change $20\%$, $5\%$, and $12.5\%$ to decimals:

$$20\%=0.20$$

$$5\%=0.05$$

$$12.5\%=0.125$$

:::check
Write $35\%$ as a decimal.
:::answer
The answer is $0.35$. Divide $35$ by $100$: move the decimal point two places to the left.
:::

### Finding the Discount

A **discount** is money taken off a price. The **listed price** is the price before the discount.

Some questions call it the original price or the marked price. The discount rate is a percent of the listed price.

$$\text{Discount}=\text{Listed price}\times\text{Discount rate}$$

Find the $25\%$ discount on a Php $800$ bag:

$$\text{Discount}=800\times0.25=200$$

The discount is Php $200$.

:::check
A shirt is listed at Php $500$ with a $20\%$ discount. How much is the discount?
:::answer
The answer is Php $100$. Multiply the listed price by the rate: $500\times0.20=100$.
:::

### Finding the Price After a Discount

There are two ways. Both give the same answer.

**Way $1$: subtract the Php $200$ discount from Php $800$:**

$$\text{Price}=800-200=600$$

**Way $2$: find the percent you still pay from $100\%$, then multiply by Php $800$:**

$$\text{Percent paid}=100\%-25\%=75\%$$

$$\text{Price}=800\times0.75=600$$

<!-- ILLUSTRATION: a horizontal bar labeled "Php 800 = 100%", split into a shaded left part "25%, discount, Php 200" and a right part "75%, you pay, Php 600" -->

:::pair #price-not-discount
Right: price after the discount $=$ Php $600$
Wrong: price after the discount $=$ Php $200$
Php $200$ is the money taken off. The question asks what you pay.
:::

:::why
Why do both ways agree? The $25\%$ you take off and the $75\%$ you keep make up the whole $100\%$. Way $2$ just skips finding the Php $200$ first.
:::

Way $2$ takes one step instead of two. It saves even more time when there are two discounts.

:::check
A jacket is listed at Php $1,200$ with a $15\%$ discount. What do you pay?
:::answer
The answer is Php $1,020$. You still pay $100\%-15\%=85\%$, and $1,200\times0.85=1,020$.
:::

### Two Discounts in a Row

**Successive discounts** are discounts taken one after another. The second discount is a percent of the new, lower price, not of the listed price.

1. Find the price after the first discount.
2. Take the second discount from that new price.

Find the final price of a Php $1,000$ item after $20\%$ and $10\%$ off:

:::pair #successive-discounts
Right: $1,000\times0.80=800$, then $800\times0.90=720$
Wrong: $20\%+10\%=30\%$, then $1,000\times0.70=700$
The wrong way takes the $10\%$ from Php $1,000$. The second discount comes from Php $800$. In the same way, two $20\%$ discounts make $36\%$, not $40\%$.
:::

:::why
Why is the total discount less than $30\%$? The second $10\%$ is taken from Php $800$, so it is only Php $80$, not Php $100$. The total discount is $200+80=280$, which is $28\%$ of Php $1,000$.
:::

:::check
A Php $2,000$ watch gets successive discounts of $10\%$ and $20\%$. What is the final price?
:::answer
The answer is Php $1,440$. First take $10\%$ off: $2,000\times0.90=1,800$. Then take $20\%$ off the new price: $1,800\times0.80=1,440$.
:::

## Examples

### #1: Basic Discount

A pair of shoes originally priced at Php $1,500$ is on sale for $20\%$ off. What is the final selling price of the shoes?

**Solution:**

1. Find the percent you still pay.

$$\text{Percent paid}=100\%-20\%=80\%$$

2. Change $80\%$ to a decimal.

$$80\%=0.80$$

3. Multiply the original price by that decimal.

$$\text{Final price}=1,500\times0.80=1,200$$

The final selling price is Php $1,200$.

**Check:** Use Way $1$. The discount is $1,500\times0.20=300$, and $1,500-300=1,200$. Both ways agree.

### #2: Successive Discounts

A laptop listed at Php $30,000$ is given successive trade discounts of $20\%$ and $15\%$. What is the net price of the laptop?

The **net price** is the price after every discount.

**Solution:**

1. First discount: you still pay $100\%-20\%=80\%$ of the listed price.

$$\text{After }20\%\text{ off}=30,000\times0.80=24,000$$

2. Second discount: you still pay $100\%-15\%=85\%$ of the new price, Php $24,000$.

:::try
Finish the last step: find $85\%$ of Php $24,000$.
:::answer
The answer is Php $20,400$. Multiply $24,000\times0.85=20,400$.

**Check:** The total discount is $30,000-20,400=9,600$. That is $\dfrac{9,600}{30,000}=0.32$, or $32\%$. It is less than $20\%+15\%=35\%$, as it should be.
:::

## Speed Tricks & Shortcuts

For two successive discounts of $a\%$ and $b\%$, the single discount percent that does the same job is:

$$\text{Total discount percent}=a+b-\dfrac{ab}{100}$$

The last part, $\dfrac{ab}{100}$, is why the total is less than $a+b$. The second discount comes off a lower price, so it takes off less money.

Find the single discount percent for $20\%$ and $10\%$ off:

$$\text{Total discount percent}=20+10-\dfrac{20\times10}{100}=28\%$$

## Traps to Watch For

:::checklist
- Two discounts in a row: take the second one from the new price, so $1,000\times0.80\times0.90=720$, a $28\%$ total. {#successive-discounts}
- Asked for the price, not the discount: subtract the discount, or multiply by the percent you still pay, so $800\times0.75=600$. {#price-not-discount}
:::
