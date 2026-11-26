---
_id: "lesson-arithmetic-number-sense-successive-percentages-and-increases"
title: "Successive Percentages and Increases"
summary: "Apply successive percentage changes in order and tell percent of from percent more than."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 6
partCount: 6
ordering: 20
keyPoints:
  - 'Apply successive percentage changes using each new base.'
  - 'Tell percent of from percent more than.'
---
## Core Concept

### Applying Successive Percentage Changes

**Successive percentage changes** happen one after another. Each new change acts on the updated amount from the step before, never on the starting amount.

Suppose a Php $1,000$ jacket gets a $20\%$ discount, then a $10\%$ discount on the sale price.

1. Find the price after the first $20\%$ discount. You still pay $100\%-20\%=80\%$, or $0.80$.

$$1,000\times0.80=800$$

2. Take the $10\%$ discount from Php $800$. You still pay $100\%-10\%=90\%$, or $0.90$.

$$800\times0.90=720$$

The final price is Php $720$. The total price drop is $1,000-720=280$, which is $\dfrac{280}{1,000}=28\%$, not $30\%$.

:::pair #add-successive-percents
Right: $1,000\times0.80=800$, then $800\times0.90=720$
Wrong: $20\%+10\%=30\%$, so $1,000\times0.70=700$
You cannot add or subtract percents that use different bases. The second discount comes from Php $800$, not Php $1,000$.
:::

The same rule holds for increases, or a mix of increases and discounts. Suppose a Php $500$ bill adds a $10\%$ service charge ($\times1.10$) and then a $10\%$ tax ($\times1.10$) on the new total.

$$500\times1.10=550$$

$$550\times1.10=605$$

:::pair #apply-second-to-original
Right: $550\times0.10=55$, giving $550+55=605$
Wrong: $500\times0.10=50$, giving $550+50=600$
The second percent applies to the updated total of Php $550$, not the starting Php $500$.
:::

When a problem gives only percents and no starting peso amount, pick $100$ as your starting base. It makes the final percent change easy to read.

:::why
Why does a $20\%$ increase followed by a $20\%$ decrease leave less than you started with? Starting at $100$, a $20\%$ increase adds $20$ to reach $120$. Then $20\%$ of $120$ is $24$, so taking $24$ away drops you to $96$, which is $4\%$ below $100$.
:::

:::check
A price starts at $100$. It rises by $10\%$, then rises by another $20\%$. What is the final price?
:::answer
The answer is $132$. First $100\times1.10=110$, then $110\times1.20=132$.
:::

### Percent Of Versus Percent More Than

The words after a percent change the multiplier completely.

- **"$p\%$ of" a base** means multiply the base by $\dfrac{p}{100}$. So "$120\%$ of" means $1.20\times\text{base}$.
- **"$p\%$ more than" a base** means keep the full $100\%$ base and add $p\%$ of it. So "$120\%$ more than" means $(1+1.20)=2.20\times\text{base}$.

<!-- ILLUSTRATION: two horizontal bars stacked for base = 200. Top bar labeled "120% of 200": one solid block of 200 (100%) extended to 240 (120%). Bottom bar labeled "120% more than 200": one solid block of 200 (100%) plus an added block of 240 (120%), total bracketed as 440 (220%) -->

Try both phrases on a base of $200$.

First, find $120\%$ of $200$.

$$1.20\times200=240$$

Next, find $120\%$ more than $200$. Add the $240$ increase to the original $200$.

$$200+240=440$$

In multiplier form, that is $(1+1.20)\times200=2.20\times200=440$.

:::pair #percent-more-as-of
Right: "$120\%$ more than" uses multiplier $1+1.20=2.20$
Wrong: "$120\%$ more than" uses multiplier $1.20$
Multiplying by $1.20$ gives only the increase above the original amount, or $120\%$ of it. Add $1$ to include the original $100\%$ base.
:::

:::check
A town had $500$ residents last year. Its population is now $40\%$ more than last year. How many residents does it have now?
:::answer
The answer is $700$. "More than" means keep the whole $100\%$ and add $40\%$, so $500\times1.40=700$.
:::

## Examples

### #1: Equivalent Single Discount

A store applies a $20\%$ discount on a jacket, then applies an additional $25\%$ discount to the sale price. What single percentage discount is equivalent to both discounts together?

**Solution:**

1. Use $100$ to represent the original price. After a $20\%$ discount, $80\%$ remains.

$$100\times0.80=80$$

2. After a $25\%$ discount on $80$, $75\%$ of $80$ remains.

$$80\times0.75=60$$

3. Find the total drop from the starting $100$.

$$100-60=40$$

4. Divide the drop by the starting $100$ and change to a percent.

$$\dfrac{40}{100}\times100\%=40\%$$

The equivalent single discount is $40\%$.

**Check:** Notice that $20\%+25\%=45\%$, so the combined discount must be less than $45\%$. Getting $40\%$ is smaller than $45\%$, which fits.

### #2: Percent Of and Percent More Than

An office processed $200$ forms last week. This week's target is $120\%$ of last week's total, while next week's target is $120\%$ more than last week's total. How many forms are in each target?

**Solution:**

1. Both targets compare against last week's $200$ forms, so $200$ is the base for both. For this week, multiply by $1.20$.

$$1.20\times200=240$$

2. For next week, "$120\%$ more than" adds the $120\%$ increase to the base. That multiplier is $1+1.20=2.20$.

:::try
Finish the last step: find $2.20\times200$.
:::answer
The answer is $240$ forms for this week and $440$ forms for next week. Multiplying $2.20\times200=440$.

**Check:** "$120\%$ more than $200$" means the original $200$ plus an increase of $240$. Adding $200+240=440$, which matches $2.20\times200$.
:::

## Speed Tricks & Shortcuts

To reverse a successive change and find an original price, multiply the decimal factors first and then divide. If a price drops by $20\%$ ($\times0.80$) and then rises by $12\%$ ($\times1.12$), the combined multiplier is $0.80\times1.12=0.896$. Divide the final price by $0.896$ to get the original price.

## Traps to Watch For

:::checklist
- Two percentage changes in a row: multiply each step using the updated amount, never add the two percents. {#add-successive-percents}
- Applying a second percent: multiply by the new total from the first step, not the starting amount. {#apply-second-to-original}
- Seeing "$p\%$ more than": add $1$ to the decimal rate so the original $100\%$ is included. {#percent-more-as-of}
:::
