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

A **character string** is a row of letters, digits, or symbols, such as $\text{PR-207}$ or $\text{A-10}$. This lesson covers codes filed one character at a time.

Under a character-string rule:

1. Start at the leftmost character of each code.
2. Compare one character at a time from left to right.
3. Stop at the first spot where the characters differ.
4. Put those characters in the order the task states. In these questions, that is $A$ to $Z$ for letters and $0$ to $9$ for digits.

Do not read a group of digits as one whole number under this rule. Compare each digit by itself.

Find the order of $\text{WK-318}$, $\text{WK-32}$, and $\text{WL-140}$, compared character by character in ascending order:

- Position $1$: all start with $W$ (tie).
- Position $2$: $K$ comes before $L$, so $\text{WL-140}$ first differs here and goes last.
- $\text{WK-318}$ and $\text{WK-32}$ match at positions $3$ ("-") and $4$ ($3$).
- Position $5$: $1$ comes before $2$, so $\text{WK-318}$ goes first.
- Order: **$\text{WK-318}$**, **$\text{WK-32}$**, **$\text{WL-140}$**.

:::pair #whole-number-in-string
Right: in character-string order, $\text{PR-207}$ comes before $\text{PR-21}$
Wrong: $\text{PR-21}$ comes before $\text{PR-207}$ because $21 < 207$
Comparing $21$ with $207$ mixes in whole-number order. Under a character-string rule, look one digit at a time after $\text{PR-2}$: $0$ comes before $1$.
:::

### When One String Starts Another

Sometimes two codes match until the shorter one runs out of characters. In these questions, the **shorter code comes first** in that case (nothing comes before something).

Find the order of $\text{B-70}$, $\text{B-8}$, and $\text{B-7}$, character by character, with the shorter code first when one begins the other:

- Positions $1$ and $2$: all three codes start with $\text{B-}$ (tie).
- Position $3$: $\text{B-7}$ and $\text{B-70}$ have $7$, and $\text{B-8}$ has $8$. Since $7 < 8$, $\text{B-8}$ goes last.
- $\text{B-7}$ ends after position $3$, while $\text{B-70}$ continues with $0$, so $\text{B-7}$ is first.
- Order: **$\text{B-7}$**, **$\text{B-70}$**, **$\text{B-8}$**.

:::pair #longer-prefix-first
Right: $\text{M-4}$, then $\text{M-40}$, then $\text{M-5}$
Wrong: $\text{M-40}$, then $\text{M-4}$, then $\text{M-5}$
$\text{M-4}$ is the exact beginning of $\text{M-40}$, so the shorter code goes first.
:::

:::why
Why does $\text{B-70}$ come before $\text{B-8}$ even though $\text{B-70}$ is longer? Position $3$ ($7$ vs. $8$) already broke the tie between $\text{B-70}$ and $\text{B-8}$. Under this rule, length decides only when one code is the exact start of the other.
:::

:::check
Arrange $\text{KD-60}$, $\text{KD-6}$, $\text{KB-7}$, and $\text{KD-59}$ in ascending order, one character at a time. When one code begins another, the shorter code goes first.
:::answer
The answer is **$\text{KB-7}$, $\text{KD-59}$, $\text{KD-6}$, $\text{KD-60}$**. Position $2$ puts $B$ before $D$. Among the $\text{KD-}$ codes, position $4$ puts $5$ before $6$. Then $\text{KD-6}$ ends before $\text{KD-60}$.
:::

## Examples

### #1: Two Codes with Different Digit Lengths

Find which code comes first, $\text{A-10}$ or $\text{A-2}$, when a filing system compares codes as character strings from left to right with digits in ascending order.

**Solution:**

1. Position $1$: both start with $A$ (tie).
2. Position $2$: both have "-" (tie).
3. Position $3$: compare $1$ and $2$. Since $1$ comes before $2$, $\text{A-10}$ comes first.

### #2: Four Codes with a Shared Start

Find the order of $\text{T-185}$, $\text{T-186}$, $\text{T-17}$, and $\text{T-2}$ when reference codes are filed character by character from left to right in ascending order.

**Solution:**

1. Positions $1$ and $2$: all four codes start with $\text{T-}$ (tie).
2. Position $3$: $\text{T-2}$ has $2$ and the other three have $1$, so $\text{T-2}$ goes last.
3. Position $4$: $\text{T-17}$ has $7$, while $\text{T-185}$ and $\text{T-186}$ have $8$. Since $7 < 8$, $\text{T-17}$ is first of the three.
4. $\text{T-185}$ and $\text{T-186}$ tie through position $4$, so they first differ at position $5$.

:::try
Finish the last step: compare position $5$ of $\text{T-185}$ and $\text{T-186}$, then write the full order.
:::answer
The answer is **$\text{T-17}$, $\text{T-185}$, $\text{T-186}$, $\text{T-2}$**. At position $5$, $5$ comes before $6$.
:::

## Traps to Watch For

:::checklist
- If the rule is character-string order, compare multi-digit numbers one digit at a time: $\text{PR-207}$ before $\text{PR-21}$ ($0 < 1$). {#whole-number-in-string}
- If the question says a shorter code goes first, put $\text{M-4}$ before $\text{M-40}$, because $\text{M-4}$ is the exact start of $\text{M-40}$. {#longer-prefix-first}
:::
