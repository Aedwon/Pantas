---
_id: "lesson-arithmetic-number-sense-simple-interest"
title: "Simple Interest"
summary: "Calculate interest on the original principal."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 4
partCount: 5
ordering: 40
keyPoints:
  - "Use simple interest with matching rate and time units."
---
## Core Concept

### Simple Interest on the Original Principal

**Interest** is money paid for the use of money. A borrower pays interest, while a saver or investor earns interest.

The **principal** is the starting amount of money. The **rate** is the percentage charged or earned over a stated time period. **Per annum** means per year.

**Simple interest** is calculated only on a fixed principal, never on earlier interest. For a period when the principal stays the same and the rate is annual, use:

$$I=PRT$$

Here $I$ is the interest, $P$ is the principal, $R$ is the annual interest rate written as a decimal, and $T$ is the time in years. To write a decimal rate as a percent, multiply by $100\%$: $0.07\times100\%=7\%$. With no payment during the period, find the total amount $A$ repaid or earned by adding the principal and the interest:

$$A=P+I$$

Find the interest and the total repayment on a loan of Php $10,000$ at $5\%$ simple interest per annum for $3$ years. First change $5\%$ to a decimal: $5\%=0.05$.

$$I=10,000\times0.05\times3$$

$$10,000\times0.05=500$$

$$500\times3=1,500$$

The interest is Php $1,500$. Add the principal to find the total repayment:

$$A=10,000+1,500=11,500$$

The total amount to repay is Php $11,500$.

If a payment covers the interest first, only the rest of the payment reduces the principal. Find the principal left on a Php $18,000$ loan at $6\%$ for $1$ year after a Php $4,000$ payment:

$$I=18,000\times0.06=1,080$$

$$4,000-1,080=2,920$$

$$18,000-2,920=15,080$$

Php $15,080$ of principal is left.

:::why
Why does simple interest grow by the same amount every year? Each year charges $5\%$ of the original Php $10,000$, which is Php $500$. Over $3$ years you pay $500+500+500=1,500$.
:::

Find the total to repay on a Php $50,000$ loan at $5\%$ for $1.5$ years.

:::pair #interest-instead-of-total
Right: $I=50,000\times0.05\times1.5=3,750$, so the total to repay is $50,000+3,750=\text{Php }53,750$
Wrong: $\text{Total to repay}=\text{Php }3,750$
Php $3,750$ is only the interest. When a question asks for the total amount to repay or the final balance, add the original principal back in.
:::

### Matching the Time Unit to the Rate

The time unit in $T$ must match the time period of the rate $R$. When the rate is annual and the time is given in months, divide the months by $12$ to convert to years.

$$T=\dfrac{\text{months}}{12}$$

For example, $9$ months is $\dfrac{9}{12}=0.75$ year, and $15$ months is $\dfrac{15}{12}=1.25$ years.

Find the interest on a loan of Php $15,000$ at $8\%$ simple annual interest for $9$ months.

$$T=\dfrac{9}{12}=0.75$$

$$I=15,000\times0.08\times0.75$$

$$15,000\times0.08=1,200$$

$$1,200\times0.75=900$$

The interest for $9$ months is Php $900$.

:::pair #months-as-years
Right: $9\text{ months}=\dfrac{9}{12}=0.75\text{ year}$, so $I=15,000\times0.08\times0.75=\text{Php }900$
Wrong: $I=15,000\times0.08\times9=\text{Php }10,800$
The wrong line plugged $9$ months in as $9$ years. Because the $8\%$ rate is per year, convert months to years first.
:::

:::pair #months-as-decimal-years
Right: $15\text{ months}=\dfrac{15}{12}=1.25\text{ years}$, giving total $\text{Php }53,750$ on $\text{Php }50,000$ at $6\%$
Wrong: $15\text{ months}=1.5\text{ years}$, giving total $\text{Php }54,500$
A year has $12$ months, not $10$. Divide $15$ by $12$ to get $1.25$, not $1.5$.
:::

:::check
A loan of Php $34,000$ has a $7\%$ simple annual interest rate. After $9$ months, a payment of Php $6,000$ covers the interest first, and the rest reduces the principal. How much principal is left?
:::answer
The answer is Php $29,785$. The interest is $34,000\times0.07\times0.75=1,785$. The payment left over is $6,000-1,785=4,215$, so the principal is $34,000-4,215=29,785$.
:::

## Examples

### #1: Finding Simple Interest Time

How many years will it take for an investment of Php $15,000$ to earn Php $4,500$ in simple interest at $6\%$ per annum?

**Solution:**

1. Write the simple-interest formula.

$$I=PRT$$

2. Substitute $I=4,500$, $P=15,000$, and $R=0.06$.

$$4,500=15,000\times0.06\times T$$

3. Multiply $15,000$ by $0.06$.

$$4,500=900T$$

4. Divide both sides by $900$.

$$T=\dfrac{4,500}{900}=5$$

It will take $5$ years.

### #2: Finding the Annual Rate from Months

An investor places Php $25,000$ in a fund. After $18$ months, the investment is worth Php $26,500$. What annual simple interest rate did the investment earn?

**Solution:**

1. Subtract the original principal from the final value to find the interest earned.

$$I=26,500-25,000=1,500$$

2. Convert $18$ months into years by dividing by $12$.

$$T=\dfrac{18}{12}=1.5$$

3. Substitute $I=1,500$, $P=25,000$, and $T=1.5$ into $I=PRT$.

$$1,500=25,000\times R\times1.5$$

4. Multiply $25,000$ by $1.5$.

$$1,500=37,500R$$

:::try
Finish the last step: divide $1,500$ by $37,500$ and write the rate as a percent.
:::answer
The answer is $4\%$. Divide $R=\dfrac{1,500}{37,500}=0.04$, which is $4\%$.
:::

## Traps to Watch For

:::checklist
- Time given in months with an annual rate: divide months by $12$ to get years, never plug months straight in. {#months-as-years}
- Over $12$ months, such as $15$ months: divide $15\div12=1.25$ years, not $1.5$ years. {#months-as-decimal-years}
- Asked for total repayment vs. interest alone: add the original principal to interest for total repayment. {#interest-instead-of-total}
:::
