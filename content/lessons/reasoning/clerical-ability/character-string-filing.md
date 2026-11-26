---
_id: "lesson-clerical-ability-character-string-filing"
title: "Character-String Filing"
summary: "Compare character strings one character at a time under the stated rule."
subject: "subject-reasoning"
topic: "topic-clerical-ability"
isActive: true
part: 5
partCount: 6
ordering: 8
keyPoints:
  - "Compare character strings one character at a time under the stated rule."
---
## Core Concept

### Comparing One Character at a Time

A **character string** is a row of letters, digits, or symbols, such as $\text{PR-207}$ or $\text{A-10}$.

Under a character-string rule:

1. Start at the leftmost character of each code.
2. Compare one character at a time from left to right.
3. Stop at the first spot where the characters differ.
4. Put those characters in the order stated by the task (usually $A$ to $Z$ for letters and $0$ to $9$ for digits).

Do not read a group of digits together as one whole number under this rule. Compare each single digit by itself.

Sort $\text{PR-207}$, $\text{PR-21}$, and $\text{PS-105}$ character by character in ascending order:

- Position $1$: all start with $P$ (tie).
- Position $2$: $R$ comes before $S$, so $\text{PS-105}$ goes last.
- Compare $\text{PR-207}$ and $\text{PR-21}$ at positions $3$ and $4$: "-" and $2$ both match.
- Position $5$: $0$ comes before $1$.
- Order: **$\text{PR-207}$**, **$\text{PR-21}$**, **$\text{PS-105}$**.

:::pair #whole-number-in-string
Right: in character-string order, $\text{PR-207}$ comes before $\text{PR-21}$
Wrong: $\text{PR-21}$ comes before $\text{PR-207}$ because $21 < 207$
Comparing $21$ with $207$ mixes in whole-number order. Under a character-string rule, look one digit at a time after $\text{PR-2}$: $0$ comes before $1$.
:::

:::check
An office sorts codes character by character from left to right in ascending order. Which comes first: $\text{K-48}$ or $\text{K-9}$?
:::answer
The answer is **$\text{K-48}$**. After $\text{K-}$, the next single character $4$ comes before $9$.
:::

### When One String Starts Another

Sometimes two codes match completely until the shorter one runs out of characters. Follow the rule stated in the task for shorter strings. The standard rule puts the **shorter string first** (nothing comes before something).

Sort $\text{M-40}$, $\text{M-5}$, and $\text{M-4}$ character by character, with shorter matching codes first:

- Positions $1$ and $2$: all three codes start with $\text{M-}$ (tie).
- Position $3$: $\text{M-4}$ and $\text{M-40}$ both have $4$, while $\text{M-5}$ has $5$. Since $4 < 5$, both $4$-codes come before $\text{M-5}$.
- Compare $\text{M-4}$ and $\text{M-40}$: $\text{M-4}$ ends after position $3$, while $\text{M-40}$ keeps going with $0$. Shorter code goes first.
- Order: **$\text{M-4}$**, **$\text{M-40}$**, **$\text{M-5}$**.

:::pair #longer-prefix-first
Right: $\text{M-4}$, then $\text{M-40}$, then $\text{M-5}$
Wrong: $\text{M-40}$, then $\text{M-4}$, then $\text{M-5}$
$\text{M-4}$ is the exact beginning of $\text{M-40}$, so the shorter code goes first.
:::

:::why
Why does $\text{M-40}$ come before $\text{M-5}$ even though $\text{M-40}$ is longer? Position $3$ ($4$ vs. $5$) already broke the tie between $\text{M-40}$ and $\text{M-5}$. Length only matters when one code is the exact start of the other.
:::

:::check
Under ascending character-string order where shorter matching strings come first, arrange $\text{B-30}$, $\text{B-3}$, and $\text{B-4}$.
:::answer
The answer is **$\text{B-3}$, $\text{B-30}$, $\text{B-4}$**. $\text{B-3}$ ends before $\text{B-30}$, and both have $3$ at position $3$ before $\text{B-4}$'s $4$.
:::

## Examples

### #1: Two Codes with Different Digit Lengths

A filing system compares codes as character strings from left to right. Digits use ascending order. Which comes first: $\text{A-10}$ or $\text{A-2}$?

**Solution:**

1. Position $1$: both start with $A$ (tie).
2. Position $2$: both have "-" (tie).
3. Position $3$: compare $1$ and $2$. Since $1$ comes before $2$, $\text{A-10}$ comes first.

**Check:** Do not read $10$ and $2$ as whole numbers. Stop at the first differing digit ($1$ vs. $2$), which puts $\text{A-10}$ first.

### #2: Letters, Digits, and Different Lengths Together

Reference codes are filed character by character from left to right in ascending order. If one code is the exact beginning of another, the shorter code comes first. Arrange $\text{N-7}$, $\text{N-62}$, $\text{N-6}$, and $\text{P-10}$.

**Solution:**

1. Compare position $1$: $N$ comes before $P$, so $\text{P-10}$ goes last.
2. Compare the three $\text{N-}$ codes at position $3$: $\text{N-6}$ and $\text{N-62}$ have $6$, while $\text{N-7}$ has $7$. Both $6$-codes come before $\text{N-7}$.

:::try
Finish the last step: order $\text{N-62}$ and $\text{N-6}$, then write the complete sequence from first to last.
:::answer
The answer is **$\text{N-6}$, $\text{N-62}$, $\text{N-7}$, $\text{P-10}$**. $\text{N-6}$ is the exact start of $\text{N-62}$, so the shorter code $\text{N-6}$ comes first.

**Check:** Position $1$ separates $N$ from $P$, position $3$ separates $6$ from $7$, and length separates $\text{N-6}$ from $\text{N-62}$.
:::

## Traps to Watch For

:::checklist
- Multi-digit numbers inside a character string, like $\text{PR-207}$ vs. $\text{PR-21}$: compare one digit at a time ($0 < 1$), not whole numbers. {#whole-number-in-string}
- One code is the exact start of another, like $\text{M-4}$ and $\text{M-40}$: place the shorter matching code first. {#longer-prefix-first}
:::
