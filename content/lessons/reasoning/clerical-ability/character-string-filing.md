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

Find the order of $\text{PR-207}$, $\text{PR-21}$, and $\text{PS-105}$, compared character by character in ascending order:

- Position $1$: all start with $P$ (tie).
- Position $2$: $R$ comes before $S$, so $\text{PS-105}$ first differs here and goes last.
- $\text{PR-207}$ and $\text{PR-21}$ match at positions $3$ ("-") and $4$ ($2$).
- Position $5$: $0$ comes before $1$, so $\text{PR-207}$ goes first.
- Order: **$\text{PR-207}$**, **$\text{PR-21}$**, **$\text{PS-105}$**.

:::pair #whole-number-in-string
Right: in character-string order, $\text{PR-207}$ comes before $\text{PR-21}$
Wrong: $\text{PR-21}$ comes before $\text{PR-207}$ because $21 < 207$
Comparing $21$ with $207$ mixes in whole-number order. Under a character-string rule, look one digit at a time after $\text{PR-2}$: $0$ comes before $1$.
:::

### When One String Starts Another

Sometimes two codes match until the shorter one runs out of characters. In these questions, the **shorter code comes first** in that case (nothing comes before something).

Find the order of $\text{M-40}$, $\text{M-5}$, and $\text{M-4}$, character by character, with the shorter code first when one begins the other:

- Positions $1$ and $2$: all three codes start with $\text{M-}$ (tie).
- Position $3$: $\text{M-4}$ and $\text{M-40}$ have $4$, and $\text{M-5}$ has $5$. Since $4 < 5$, $\text{M-5}$ goes last.
- $\text{M-4}$ ends after position $3$, while $\text{M-40}$ continues with $0$, so $\text{M-4}$ is first.
- Order: **$\text{M-4}$**, **$\text{M-40}$**, **$\text{M-5}$**.

:::pair #longer-prefix-first
Right: $\text{M-4}$, then $\text{M-40}$, then $\text{M-5}$
Wrong: $\text{M-40}$, then $\text{M-4}$, then $\text{M-5}$
$\text{M-4}$ is the exact beginning of $\text{M-40}$, so the shorter code goes first.
:::

:::why
Why does $\text{M-40}$ come before $\text{M-5}$ even though $\text{M-40}$ is longer? Position $3$ ($4$ vs. $5$) already broke the tie between $\text{M-40}$ and $\text{M-5}$. Under this rule, length decides only when one code is the exact start of the other.
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
- Multi-digit numbers in a code, like $\text{PR-207}$ and $\text{PR-21}$: compare one digit at a time ($0 < 1$). {#whole-number-in-string}
- One code is the exact start of another, like $\text{M-4}$ and $\text{M-40}$: the shorter code goes first. {#longer-prefix-first}
:::
