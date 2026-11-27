---
_id: "lesson-clerical-ability-integer-subcode-filing"
title: "Integer Subcode Filing"
summary: "Compare integer subcodes as whole numbers in the stated order."
subject: "subject-reasoning"
topic: "topic-clerical-ability"
isActive: true
part: 4
partCount: 6
ordering: 7
keyPoints:
  - "Compare integer subcodes as whole numbers in the stated order."
---
## Core Concept

### Splitting Codes into Integer Subcodes

A dot (".") or hyphen ("-") inside a reference code often only divides separate parts. It is not always a decimal point or a minus sign. Read the task rule to see what the mark means.

An **integer subcode** is a whole-number part inside a larger code. Under an integer-subcode rule:

1. Split the code at the dot or hyphen.
2. Compare the first subcode as a whole number (ignore any leading zeros).
3. Move to the next subcode only when earlier parts tie.
4. If a part is a letter (such as $-A$ or $-B$), compare it alphabetically when the rule calls for it.

Compare $31.2$ and $31.015$ as integer subcodes in ascending order:

- First subcode: both are $31$ (tie).
- Second subcode as whole numbers: $2$ and $015 = 15$.
- Since $2 < 15$, **$31.2$** comes before **$31.015$**.

Now look at fixed-prefix codes that count up by $1$ in a $3$-digit integer suffix. What comes immediately after $10\text{-}099$?

- Keep the fixed prefix $10$.
- Add $1$ to the suffix $099$: $99 + 1 = 100$.
- The next code is **$10\text{-}100$**.

:::why
Why does $31.2$ come before $31.015$ as integer subcodes when $31.015$ is smaller as a decimal? In decimal math, the dot marks tenths and thousandths. Here, the system uses the dot as a divider between two whole numbers, like section $31$, folder $2$ vs. section $31$, folder $15$.
:::

:::pair #dot-as-decimal
Right: as integer subcodes, **$31.2$** comes before **$31.015$** ($2 < 15$)
Wrong: **$31.015$** comes first because $0.015 < 0.2$
The wrong move treats the dot as a decimal point. Check whether the rule calls the parts integer subcodes or decimals before comparing.
:::

:::pair #early-prefix-carry
Right: with prefix $10$ fixed and a $3$-digit suffix, the code after $10\text{-}099$ is **$10\text{-}100$**
Wrong: the code after $10\text{-}099$ is **$11\text{-}000$**
A $3$-digit suffix runs up to $999$, so adding $1$ to $099$ makes $100$ inside the suffix. It does not carry into the prefix $10$.
:::

:::check
A registry treats each part of a dotted code as an integer subcode in ascending order. Which comes last: $14.20$, $14.3$, or $14.015$?
:::answer
The answer is **$14.20$**. All three tie on $14$. The second integer subcodes are $20$, $3$, and $15$, and $20$ is the largest.
:::

## Examples

### #1: Dotted Codes as Integer Subcodes

A filing system treats each part of a dotted code as a separate integer subcode and files in ascending order. Which code comes first: $12.05$, $12.1$, or $12.008$?

**Solution:**

1. Split each code at the dot: $(12, 05)$, $(12, 1)$, and $(12, 008)$.
2. Compare the first subcode: all three are $12$ (tie).
3. Read the second subcodes as ordinary whole numbers (dropping leading zeros): $5$, $1$, and $8$.
4. Order those whole numbers: $1 < 5 < 8$.
5. The code $12.1$ comes first.

**Check:** As decimals, $12.008$ would be smallest. Because the rule says integer subcodes, $1 < 5 < 8$ puts $12.1$ first.

### #2: Hyphenated Codes with Whole-Number Parts

A filing system uses hyphens to separate parts, comparing number parts as whole numbers in ascending order and any letter suffix alphabetically. Arrange $\text{AB-5-12}$, $\text{AB-5-7-B}$, and $\text{AB-5-7-A}$.

**Solution:**

1. Compare the first part: all three begin with $\text{AB}$ (tie).
2. Compare the second part: all three have $5$ (tie).
3. Compare the third part as whole numbers: $7 < 12$, so both $7$ codes come before $\text{AB-5-12}$.
4. Compare the fourth part (letter suffix) for the two $7$ codes: $A$ comes before $B$.
5. The order is $\text{AB-5-7-A}$, $\text{AB-5-7-B}$, $\text{AB-5-12}$.

**Check:** In character order, $12$ would come before $7$, so treating $7$ and $12$ as whole numbers keeps $7$ first.

### #3: Finding a Listed Neighbor in a Drawer

A drawer holds only $44\text{-}205$, $44\text{-}240$, $44\text{-}260$, and $44\text{-}302$. Compare their integer suffixes in ascending order with prefix $44$ fixed. After inserting $44\text{-}250$, which listed record sits immediately before it?

**Solution:**

1. Check the prefixes: all codes share prefix $44$.
2. List the suffixes below $250$: $205$ and $240$ (both $260$ and $302$ are larger than $250$).

:::try
Finish the last step: between the listed codes below $44\text{-}250$, pick the one that sits immediately before $44\text{-}250$.
:::answer
The answer is **$44\text{-}240$**. Between $205$ and $240$, $240$ is closer to $250$, so $44\text{-}240$ sits right before $44\text{-}250$.

**Check:** In the drawer order $44\text{-}205, 44\text{-}240, 44\text{-}250, 44\text{-}260, 44\text{-}302$, $44\text{-}240$ is on the immediate left of $44\text{-}250$ and $44\text{-}260$ is on its right.
:::

## Traps to Watch For

:::checklist
- A dot inside a code: read whether the rule calls it an integer subcode divider ($31.2 < 31.015$) or a decimal point. {#dot-as-decimal}
- Suffix reaching $099$ in a $3$-digit integer suffix: add $1$ to get $100$ inside the suffix ($10\text{-}100$), not carry into the prefix. {#early-prefix-carry}
:::
