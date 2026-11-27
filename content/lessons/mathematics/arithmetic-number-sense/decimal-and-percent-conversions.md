---
_id: "lesson-arithmetic-number-sense-decimal-and-percent-conversions"
title: "Decimal and Percent Conversions"
summary: "Convert a terminating decimal to a fraction."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 6
ordering: 15
keyPoints:
  - 'Convert a terminating decimal to a fraction.'
  - 'Convert a percentage to a decimal or fraction.'
---
## Core Concept

### Terminating Decimals to Fractions

Fractions, decimals, and percentages show the same amount in different ways. A **fraction** shows division: the top number is the **numerator**, and the bottom number is the **denominator** (which cannot be $0$).

A **decimal** uses place value based on $10$. After the decimal point, the places are tenths, hundredths, thousandths, ten-thousandths, and so on.

A **terminating decimal** stops after a fixed number of decimal places. To convert it to a fraction:

1. Count every digit after the decimal point. Use $10$ for $1$ place, $100$ for $2$, $1,000$ for $3$, $10,000$ for $4$, adding one zero per place.
2. Put all digits of the number (including any whole digit before the point) over that power of $10$.
3. **Simplify** the fraction: divide both numerator and denominator by common factors greater than $1$ until no common factor remains.

Write $0.05$, $0.35$, and $1.25$ as fractions, then divide top and bottom by their largest common factor:

$$0.05=\dfrac{5}{100}$$

$$\dfrac{5}{100}=\dfrac{1}{20}$$

$$0.35=\dfrac{35}{100}$$

$$\dfrac{35}{100}=\dfrac{7}{20}$$

$$1.25=\dfrac{125}{100}$$

$$\dfrac{125}{100}=\dfrac{5}{4}$$

This method works for terminating decimals only, not for decimals whose digits repeat forever.

:::pair #drop-whole-part
Right: $1.275=\dfrac{1,275}{1,000}=\dfrac{51}{40}$
Wrong: $1.275=\dfrac{275}{1,000}=\dfrac{11}{40}$
The wrong line converted only $.275$ and dropped the whole $1$ before the decimal point. Keep every digit in the numerator.
:::

:::pair #wrong-place-count
Right: $0.0625$ has $4$ decimal places, so $0.0625=\dfrac{625}{10,000}=\dfrac{1}{16}$
Wrong: $0.0625=\dfrac{625}{1,000}=\dfrac{5}{8}$
The zero right after the decimal point still takes one place. Count all $4$ places after the point so the denominator is $10,000$, not $1,000$.
:::

:::check
Write $3.06$ as a fraction in simplest form.
:::answer
The answer is $\dfrac{153}{50}$. Keep every digit, including the $3$ before the point and the $0$ after it: two decimal places give $\dfrac{306}{100}$. Dividing top and bottom by $2$ gives $\dfrac{153}{50}$.
:::

### Percentages to Decimals and Fractions

A **percentage** means "per hundred" or "out of $100$." The symbol $\%$ means percent.

- Percent to decimal: divide by $100$ (move the decimal point $2$ places left).
- Decimal to percent: multiply by $100$ (move the decimal point $2$ places right) and attach $\%$.
- Percent to fraction: write the percent number over $100$ and simplify. If the percent has a decimal point, change it to a decimal first and use the steps above.

$$p\%=\dfrac{p}{100}$$

Write $5\%$ as a decimal:

$$5\%=5\div 100=0.05$$

Write $0.045$ as a percent:

$$0.045\times 100\%=4.5\%$$

Write $40\%$ as a fraction in simplest form:

$$40\%=\dfrac{40}{100}$$

$$\dfrac{40}{100}=\dfrac{2}{5}$$

:::why
Why does dividing by $100$ move the decimal point two places left? Each place left divides by $10$, so two places divide by $10\times 10=100$.
:::

:::pair #one-place-shift
Right: $2.5\%=2.5\div 100=0.025$
Wrong: $2.5\%=0.25$
Moving the decimal point only $1$ place left divides by $10$, not $100$. Shift $2$ places left and add a leading zero when needed.
:::

## Examples

"Express" means write the same value in the form named by the question.

### #1: Decimal to Fraction

Express $0.125$ as a fraction in its simplest form.

**Solution:**

1. Count the digits after the decimal point: there are $3$ places, so use $1,000$ as the denominator.

$$0.125=\dfrac{125}{1,000}$$

2. Divide both top and bottom by $25$.

$$\dfrac{125}{1,000}=\dfrac{5}{40}$$

3. Divide both top and bottom by $5$.

$$\dfrac{5}{40}=\dfrac{1}{8}$$

The answer is $\dfrac{1}{8}$.

### #2: Percent to Decimal and Fraction

Express $45\%$ as a decimal and as a fraction in simplest form.

**Solution:**

1. Divide $45$ by $100$ to get the decimal, moving the point $2$ places left.

$$45\div 100=0.45$$

2. Write $45\%$ as a fraction over $100$.

$$45\%=\dfrac{45}{100}$$

:::try
Finish the last step: simplify $\dfrac{45}{100}$ to lowest terms.
:::answer
The answer is $\dfrac{9}{20}$. Divide both $45$ and $100$ by $5$.
:::

## Traps to Watch For

:::checklist
- Converting a decimal greater than $1$ to a fraction: keep the whole digits before the point in the numerator, so $1.275=\dfrac{1,275}{1,000}$. {#drop-whole-part}
- Leading zeros right after the decimal point: count every decimal place, so $0.0625$ goes over $10,000$. {#wrong-place-count}
- Changing a percent to a decimal: move the decimal point $2$ places left, so $2.5\%=0.025$. {#one-place-shift}
:::
