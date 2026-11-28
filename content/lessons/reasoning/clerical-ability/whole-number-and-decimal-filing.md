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

In these questions, ordinary whole-number file keys are compared by their **full number values**, not by the leftmost digit.

Find the ascending numeric order of $20$, $4$, $21$, and $5$:

- The one-digit numbers $4$ and $5$ are less than the two-digit numbers $20$ and $21$.
- For $4$ and $5$, the ones place decides: $4 < 5$.
- For $20$ and $21$, the tens digits tie, so the ones place decides: $0 < 1$.
- Order: $4 < 5 < 20 < 21$.

**Leading zeros** are zeros at the start of a number, such as $005$ or $0389$. They may stay printed on the folder, but they do not change the number's value. As numbers, $005$, $05$, and $5$ all equal five.

:::pair #text-sort-numbers
Right: $2, 3, 10, 11$
Wrong: $10, 11, 2, 3$
Putting $10$ before $2$ compares the first digit ($1$ vs. $2$) as text. Ordinary whole numbers are compared by full numeric value.
:::

:::pair #leading-zero-size
Right: $007 = 07 = 7$ (equal values)
Wrong: $007$ is greatest because it has three digits
Extra zeros on the left change how wide the label looks, not its value. When comparing whole numbers, ignore leading zeros.
:::

### Decimal Filing Order

In these questions, for **decimal numbers**, compare the **whole-number parts** (left of the decimal point) first. If the whole-number parts differ, the smaller whole part comes first in ascending order, no matter how small the decimal part looks.

If the whole-number parts match, add **trailing zeros** at the right end of shorter decimals so every number has the same number of decimal places. Adding zeros at the right end of a decimal does not change its value. Then compare from left to right.

Find the ascending decimal order of $5.004$, $5.040$, $5.06$, and $5.3$:

- Whole-number parts all tie at $5$.
- Match decimal places to $3$ digits after the point: $5.004$, $5.040$, $5.060$, $5.300$.
- Tenths: only $5.300$ has a $3$. The others have $0$, so $5.300$ is last.
- Hundredths of the other three: $0 < 4 < 6$, so $5.004 < 5.040 < 5.060$.
- Order: $5.004 < 5.040 < 5.06 < 5.3$.

:::why
Why does adding zeros at the right end keep a decimal the same, while adding zeros right after the point changes it? In $5.3$, the $3$ sits in the tenths place, so $5.3 = 5.300$. In $5.004$, the two zeros push $4$ into the thousandths place, which is much smaller than $3$ tenths.
:::

:::pair #decimal-as-integer
Right: $7.008 < 7.020 < 7.09 < 7.1$
Wrong: $7.1$ is smallest because $1 < 8 < 9 < 20$
The wrong move reads the written digits $1$ and $008$ as the whole numbers $1$ and $8$. Line up decimal places with trailing zeros before comparing.
:::

:::check
Arrange these decimal quantities in ascending order: $15.9$, $9.75$, and $15.08$.
:::answer
The answer is $9.75, 15.08, 15.9$. The whole parts $9 < 15$ put $9.75$ first. The two $15$ entries tie on the whole part, so write $15.90$ and $15.08$. The tenths are $9$ and $0$, so $15.08$ files before $15.9$.
:::

## Examples

### #1: Ascending Whole-Number Order

Arrange file numbers $0452$, $0389$, $0401$, and $0395$ in ascending numerical order.

**Solution:**

1. Drop the leading zeros in your head to read each full value: $452$, $389$, $401$, $395$.
2. Compare the hundreds digits: $389$ and $395$ have $3$, and $401$ and $452$ have $4$, so the $300$s come first.
3. Within the $300$s, the tens digits give $8 < 9$, so $389 < 395$.
4. Within the $400$s, the tens digits give $0 < 5$, so $401 < 452$.
5. Keep the printed leading zeros in the answer: $0389, 0395, 0401, 0452$.

### #2: Decimals with Different Whole Parts

In decimal numeric filing, which number should be placed first in ascending order: $614.90$, $615.02$, $614.30$, or $614.07$?

**Solution:**

1. Compare the whole-number parts first: $614$ is smaller than $615$, so drop $615.02$.
2. Compare the tenths digits of the $614$ entries: $9$, $3$, and $0$.
3. Since $0 < 3 < 9$, the first number is $614.07$.

### #3: Comparing Decimal Lengths

These entries are decimal quantities: $8.35$, $8.3$, $8.305$, and $8.4$. Arrange them in ascending order.

**Solution:**

1. All four entries share the same whole-number part, $8$.
2. Add trailing zeros so every entry has three decimal places: $8.350$, $8.300$, $8.305$, and $8.400$.

:::try
Finish the last step: order the four decimals from smallest to largest, keeping their original written forms.
:::answer
The answer is $8.3, 8.305, 8.35, 8.4$. Tenths: $8.400$ has $4$ and the others have $3$, so $8.4$ is last. Hundredths: $8.350$ has $5$ and $8.300$ and $8.305$ have $0$, so $8.35$ comes after them. Thousandths: $0 < 5$, so $8.3$ comes before $8.305$.
:::

## Traps to Watch For

:::checklist
- Whole numbers of different lengths, such as $2$ and $10$: compare full values ($2 < 10$), not first digits. {#text-sort-numbers}
- Leading zeros like $007$ vs. $7$: leading zeros do not change the number's value. {#leading-zero-size}
- Decimals of different lengths, such as $7.1$ and $7.008$: add trailing zeros ($7.100$ vs. $7.008$) before comparing. {#decimal-as-integer}
:::
