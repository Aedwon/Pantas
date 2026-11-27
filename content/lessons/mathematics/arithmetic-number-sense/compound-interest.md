---
_id: "lesson-arithmetic-number-sense-compound-interest"
title: "Compound Interest"
summary: "Calculate growth over compounding periods."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 5
partCount: 5
ordering: 41
keyPoints:
  - "Match the compound rate and number of periods."
  - "Use the Rule of 72 as a rough doubling estimate."
---
## Core Concept

### Compounding Interest on the New Balance

**Compound interest** adds each period's interest into the balance. The next period then earns or charges interest on that new, larger balance, instead of only on the starting principal.

Find the balance after $2$ years when Php $1,000$ earns $10\%$ interest compounded annually.

Year $1$ starts with Php $1,000$ and multiplies by $1+0.10=1.10$:

$$1,000\times1.10=1,100$$

Year $2$ starts with the new balance, Php $1,100$, and multiplies by $1.10$ again:

$$1,100\times1.10=1,210$$

Notice that Year $2$ added Php $110$ instead of Php $100$, because $10\%$ also applied to the first Php $100$ of interest.

<!-- ILLUSTRATION: two stacked two-year growth bars starting at Php 1,000, with the Php 1,000 block drawn short to save room. Top bar, Simple interest: Php 1,000 + 100 (Year 1) + 100 (Year 2) = Php 1,200. Bottom bar, Compound interest: Php 1,000 + 100 (Year 1 = Php 1,100) + 110 (Year 2, 10% of 1,100) = Php 1,210. Year 2 adds 110 instead of 100 because the 10% also applies to the first 100 of interest. -->

When the rate stays the same and no money goes in or out, writing repeated multiplication as a power gives the compound-interest formula:

$$A=P(1+r)^t$$

Here $P$ is the starting principal, $r$ is the interest rate per compounding period written as a decimal, $t$ is the total number of compounding periods, and $A$ is the final balance.

:::why
Why multiply by $1+r$ in one step? Multiplying by $1$ keeps $100\%$ of the current balance, and multiplying by $r$ adds the new interest. Combining them gives $(1+r)$ times the balance each period.
:::

:::pair #simple-instead-of-compound
Right: $1,000\times1.10=1,100$, then $1,100\times1.10=1,210$
Wrong: $1,000+100+100=1,200$
The wrong line used simple interest, adding Php $100$ each year. Compound interest calculates Year $2$ on the updated balance of Php $1,100$.
:::

### Matching Rate and Periods to Compounding Frequency

When a problem states an annual rate but compounds more than once a year, match both $r$ and $t$ to one compounding period:

- Semi-annual means $2$ periods per year.
- Quarterly means $4$ periods per year.
- Monthly means $12$ periods per year.

Divide the annual rate by the number of periods per year to find $r$. Multiply the number of years by the periods per year to find $t$.

Find the rate per period, the growth factor and the number of periods for an account that earns $8\%$ per year compounded quarterly for $1$ year:

$$\dfrac{8\%}{4}=2\%$$

$$2\%=0.02$$

$$1+0.02=1.02$$

$$1\times4=4$$

The balance formula for $1$ year is $A=P(1.02)^4$.

:::pair #wrong-quarterly-period-rate
Right: $8\%\div4=2\%=0.02$, so the factor is $1+0.02=1.02$ in $A=P(1.02)^4$
Wrong: $A=P(1.04)^4$
Dividing $8\%$ by $2$ gives a semi-annual rate, not a quarterly rate. There are $4$ quarters in a year, so divide the annual rate by $4$.
:::

:::check
Php $5,000$ earns $6\%$ per year compounded semi-annually for $1$ year. What is the balance at the end?
:::answer
The answer is Php $5,304.50$. The rate per period is $6\%\div2=3\%$, so the factor is $1.03$. There are $1\times2=2$ periods, so $A=5,000\times1.03^2=5,000\times1.0609=5,304.50$.
:::

### Estimating Doubling Time with the Rule of $72$

For **compound growth**, the **Rule of $72$** gives a quick estimate of how many years it takes an amount to double. Divide $72$ by the annual percent rate directly (use $9$ for $9\%$, not $0.09$).

$$\text{Doubling years}\approx\dfrac{72}{\text{annual percent rate}}$$

Estimate the doubling time at an annual compound rate of $8\%$:

$$72\div8=9$$

The estimate is $9$ years. At $9\%$, it takes about $72\div9=8$ years. This is a rough estimate for compound growth, not an exact value and not the simple-interest formula.

:::pair #rule-of-72-direction
Right: $72\div9=8\text{ years}$
Wrong: $9\div72=\dfrac{1}{8}\text{ year}$
The wrong line divided the rate by $72$ instead of $72$ by the rate. A single-digit percent rate should take several years to double, not a tiny fraction of a year.
:::

## Examples

### #1: Semi-Annual Compounding

An amount of Php $10,000$ is deposited into a savings account that earns an annual interest rate of $4\%$ compounded semi-annually. What is the total amount after $2$ years? Assume $1.02^4\approx1.0824$.

**Solution:**

1. Semi-annual compounding means interest is applied $2$ times a year. Divide the annual rate by $2$ to get the rate per period.

$$\dfrac{4\%}{2}=2\%$$

$$2\%=0.02$$

2. Multiply the $2$ years by $2$ periods per year to count total periods.

$$2\times2=4$$

3. Substitute $P=10,000$, $r=0.02$, and $t=4$ into $A=P(1+r)^t$.

$$A=10,000(1+0.02)^4$$

$$A=10,000(1.02)^4$$

:::try
Finish the last step: use $1.02^4\approx1.0824$ to find the total amount.
:::answer
The answer is approximately Php $10,824$. Multiply $10,000\times1.0824=10,824$.
:::

## Traps to Watch For

:::checklist
- Compound vs. simple interest: apply the period rate to the new balance each period, instead of only to the original principal. {#simple-instead-of-compound}
- Compounding more than once a year: divide the annual rate by the periods per year to find $r$. {#wrong-quarterly-period-rate}
- Rule of $72$ doubling estimate: divide $72$ by the annual percent rate, not the reverse. {#rule-of-72-direction}
:::
