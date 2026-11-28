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

A dot (".") or hyphen ("-") inside a reference code can divide separate parts instead of marking a decimal point or a minus sign. Read the task rule to see what the mark means.

An **integer subcode** is a whole-number part inside a larger code. When a question names an integer-subcode rule, use these steps:

1. Split the code at the dot or hyphen.
2. Compare the first subcode as a whole number (ignore any leading zeros).
3. In these questions, move to the next subcode only when earlier parts tie.
4. If a part is a letter (such as $-A$ or $-B$), compare it alphabetically when the rule calls for it.

Find which of $31.2$ and $31.015$ comes first as integer subcodes in ascending order:

- First subcode: both are $31$ (tie).
- Second subcode as whole numbers: $2$ and $015 = 15$.
- Since $2 < 15$, **$31.2$** comes before **$31.015$**.

Find the code right after $10\text{-}099$ (fixed prefix, $3$-digit suffix, counting up by $1$):

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
A registry treats each part of a dotted code as an integer subcode in ascending order. Arrange $8.4.100$, $8.4.9$, and $8.04.12$.
:::answer
The answer is **$8.4.9$, $8.04.12$, $8.4.100$**. All three tie on $8$ and on the second subcode ($4$, since $04 = 4$). The third subcodes $9 < 12 < 100$ decide.
:::

## Examples

### #1: Dotted Codes as Integer Subcodes

A filing system treats each part of a dotted code as a separate integer subcode and files in ascending order. Which code comes first: $12.05$, $12.1$, or $12.008$?

**Solution:**

1. Split each code at the dot: $(12, 05)$, $(12, 1)$, and $(12, 008)$.
2. Compare the first subcode: all three are $12$ (tie).
3. The codes first differ at the second subcode. Read each as a whole number: $05 \to 5$, $1 \to 1$, and $008 \to 8$.
4. Order those whole numbers: $1 < 5 < 8$.
5. The code $12.1$ comes first.

### #2: Hyphenated Codes with Whole-Number Parts

A filing system compares number parts as whole numbers and a letter suffix alphabetically, ascending. Arrange $\text{AB-5-12}$, $\text{AB-5-7-B}$, and $\text{AB-5-7-A}$.

**Solution:**

1. Compare the first part: all three begin with $\text{AB}$ (tie).
2. Compare the second part: all three have $5$ (tie).
3. The codes first differ at the third part. As whole numbers, $7 < 12$, so both $7$ codes come before $\text{AB-5-12}$.
4. The two $7$ codes tie again, so compare the fourth part (letter suffix): $A$ comes before $B$.
5. The order is $\text{AB-5-7-A}$, $\text{AB-5-7-B}$, $\text{AB-5-12}$.

### #3: Finding a Listed Neighbor in a Drawer

A drawer holds $41\text{-}960$, $42\text{-}015$, $42\text{-}150$, and $43\text{-}002$, filed by integer subcodes in ascending order. Which listed code sits immediately before a new code $42\text{-}090$?

**Solution:**

1. Compare first subcodes: $41\text{-}960$ is before the new code ($41 < 42$), and $43\text{-}002$ is after it.
2. Two listed codes tie on $42$. Compare second subcodes as whole numbers: $015 = 15$, $090 = 90$, and $150$.
3. Since $15 < 90 < 150$, $42\text{-}015$ is before the new code and $42\text{-}150$ is after it.

:::try
Finish the last step: of the two listed codes before $42\text{-}090$, $41\text{-}960$ and $42\text{-}015$, pick the one that sits immediately before it.
:::answer
The answer is **$42\text{-}015$**. The first subcodes first differ: $41 < 42$, so $42\text{-}015$ sits closer to $42\text{-}090$ than $41\text{-}960$ does.
:::

## Traps to Watch For

:::checklist
- A dot inside a code: read whether the rule calls it an integer subcode divider ($31.2 < 31.015$) or a decimal point. {#dot-as-decimal}
- Suffix reaching $099$ in a $3$-digit integer suffix: add $1$ to get $100$ inside the suffix ($10\text{-}100$), not carry into the prefix. {#early-prefix-carry}
:::
