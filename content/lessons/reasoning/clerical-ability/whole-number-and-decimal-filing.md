---
_id: "lesson-clerical-ability-whole-number-and-decimal-filing"
title: "Whole-Number and Decimal Filing"
summary: "Compare ordinary file numbers by their full number values."
subject: "subject-reasoning"
topic: "topic-clerical-ability"
isActive: true
part: 1
partCount: 6
ordering: 4
keyPoints:
  - "Compare ordinary file numbers by their full number values."
  - "Compare decimal numbers from left to right."
---
## Core Concept

### Whole-Number Filing Order

**Numeric filing** sorts records by numbers or number codes. A **filing key** is the part of a record used to decide its place, such as its file number.

**Ascending order** goes from smallest to largest. **Descending order** goes from largest to smallest. The symbol $<$ means "is less than."

For ordinary whole-number file keys, compare their **full number values**, not just the leftmost digit.

Sort $10$, $2$, $11$, and $3$ in ascending numeric order:

- Compare values: $2$ is less than $3$, $3$ is less than $10$, and $10$ is less than $11$.
- Order: $2 < 3 < 10 < 11$.

**Leading zeros** are zeros at the start of a number, such as $007$ or $0389$. They may stay printed on the folder, but they do not change the number's value. So $007$, $07$, and $7$ all equal seven.

:::pair #text-sort-numbers
Right: $2, 3, 10, 11$
Wrong: $10, 11, 2, 3$
Putting $10$ before $2$ compares the first digit ($1$ vs. $2$) as text. Ordinary whole numbers are compared by full numeric value.
:::

:::pair #leading-zero-size
Right: $007 = 07 = 7$ (equal values)
Wrong: $007$ is greatest because it has three digits
Extra zeros on the left change how wide the label looks, not its value. Ignore leading zeros when comparing whole numbers.
:::

:::check
In ascending consecutive numeric filing, which file number comes immediately before $5000$?
:::answer
The answer is $4999$. One consecutive step before $5000$ is $5000 - 1 = 4999$.
:::

### Decimal Filing Order

For **decimal numbers**, compare the **whole-number parts** (left of the decimal point) first. If the whole-number parts differ, the smaller whole part comes first in ascending order, no matter how small the decimal part looks.

If the whole-number parts match, add **trailing zeros** at the right end of shorter decimals so every number has the same number of decimal places. Adding zeros at the right end of a decimal does not change its value. Then compare from left to right.

Sort $7.008$, $7.020$, $7.09$, and $7.1$ in ascending decimal order:

- Whole-number parts all tie at $7$.
- Match decimal places to $3$ digits after the point: $7.008$, $7.020$, $7.090$, $7.100$.
- Compare the decimal parts: $0.008 < 0.020 < 0.090 < 0.100$.
- Order: $7.008 < 7.020 < 7.09 < 7.1$.

:::why
Why does adding zeros at the right end keep a decimal the same, while adding zeros right after the point changes it? In $7.1$, the $1$ sits in the tenths place, so $7.1 = 7.100$. In $7.008$, the two zeros push $8$ into the thousandths place, which is much smaller than $1$ tenth.
:::

:::pair #decimal-as-integer
Right: $7.008 < 7.020 < 7.09 < 7.1$
Wrong: $7.1$ is smallest because $1 < 8 < 9 < 20$
Reading digits after the point as whole numbers turns $0.100$ into $1$ and $0.008$ into $8$. Line up decimal places with trailing zeros before comparing.
:::

:::check
Arrange these decimal quantities in ascending order: $5.3$, $5.09$, and $5.25$.
:::answer
The answer is $5.09, 5.25, 5.3$. Write all three with two decimal places ($5.09$, $5.25$, $5.30$) and compare from left to right.
:::

## Examples

### #1: Ascending Whole-Number Order

Arrange file numbers $0452$, $0389$, $0401$, and $0395$ in ascending consecutive numerical order.

**Solution:**

1. Drop the leading zeros in your head to read each full value: $452$, $389$, $401$, $395$.
2. Compare the hundreds digits: $389$ and $395$ are in the $300$s, so they come before $401$ and $452$.
3. Within the $300$s, $389 < 395$. Within the $400$s, $401 < 452$.
4. Keep the printed leading zeros in the answer: $0389, 0395, 0401, 0452$.

**Check:** Each number steps up from left to right: $389 < 395 < 401 < 452$.

### #2: Decimals with Different Whole Parts

In decimal numeric filing, which number should be placed first in ascending order: $402.80$, $403.05$, $402.20$, or $402.15$?

**Solution:**

1. Compare the whole-number parts first: $402$ is smaller than $403$, so drop $403.05$.
2. Compare the decimal parts of the $402$ entries: $0.15$, $0.20$, and $0.80$.
3. Since $0.15 < 0.20 < 0.80$, the first number is $402.15$.

**Check:** Even though $.05$ in $403.05$ looks smaller than $.15$, its whole part $403$ is larger than $402$, and among the $402$ entries, $15 < 20 < 80$ hundredths confirms $402.15$ is smallest.

### #3: Comparing Decimal Lengths

These entries are decimal quantities: $12.05$, $12.1$, $12.008$, and $12.04$. Arrange them in ascending order.

**Solution:**

1. All four entries share the same whole-number part, $12$.
2. Add trailing zeros so every entry has three decimal places: $12.050$, $12.100$, $12.008$, and $12.040$.

:::try
Finish the last step: order the four decimals from smallest to largest, keeping their original written forms.
:::answer
The answer is $12.008, 12.04, 12.05, 12.1$. Comparing thousandths gives $8 < 40 < 50 < 100$.

**Check:** Look at the tenths digit right after the point: $12.1$ has $1$ tenth while the other three have $0$ tenths, so $12.1$ must be largest, and thousandths order the other three as $8 < 40 < 50$.
:::

## Traps to Watch For

:::checklist
- Whole numbers of different lengths, such as $2$ and $10$: compare full values ($2 < 10$), not first digits. {#text-sort-numbers}
- Leading zeros like $007$ vs. $7$: leading zeros do not change the number's value. {#leading-zero-size}
- Decimals of different lengths, such as $7.1$ and $7.008$: add trailing zeros ($7.100$ vs. $7.008$) before comparing. {#decimal-as-integer}
:::
