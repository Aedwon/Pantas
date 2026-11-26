---
_id: "lesson-clerical-ability-terminal-digit-filing-order"
title: "Terminal-Digit Filing Order"
summary: "Start with the rightmost group only under a terminal-digit rule."
subject: "subject-reasoning"
topic: "topic-clerical-ability"
isActive: true
part: 6
partCount: 6
ordering: 9
keyPoints:
  - "Start with the rightmost group only under a terminal-digit rule."
  - "Compare the remaining groups in the order stated by the task."
---
## Core Concept

### Starting with the Rightmost Group

In **terminal-digit filing**, "terminal" means the end. Under a terminal-digit rule, always compare the **rightmost group** of digits first, as a whole number.

Use terminal-digit filing only when the task states it. In ordinary whole-number filing, compare full numeric values; compare digit by digit from the left only on equally padded fixed-length keys.

Compare $\text{01-99-02}$ and $\text{12-44-03}$ in ascending terminal-digit order:

- Rightmost group of $\text{01-99-02}$: $02$.
- Rightmost group of $\text{12-44-03}$: $03$.
- Since $02 < 03$, **$\text{01-99-02}$** comes first.

:::why
Why sort from the right end at all? In big registries, consecutive new files share the same starting digits on the left. Sorting by the last two digits puts one file in each of the $100$ sections ($00$ through $99$) over each complete cycle of $100$ consecutive identifiers instead of crowding one shelf.
:::

:::pair #leftmost-first
Right: in ascending terminal-digit order, $\text{04-80-12}$ comes before $\text{01-01-13}$ ($12 < 13$)
Wrong: $\text{01-01-13}$ comes first because $01$ is smallest on the left
Starting from the left uses ordinary numeric order, not terminal-digit order. Under a terminal-digit rule, always check the rightmost group first.
:::

:::check
In ascending terminal-digit filing, which file comes first: $\text{08-50-24}$ or $\text{72-10-19}$?
:::answer
The answer is **$\text{72-10-19}$**. Its rightmost group $19$ is smaller than $24$.
:::

### Checking the Remaining Groups in Stated Order

When two files tie on the rightmost group, move to the second group named by the task. Move to the third group only if both earlier groups tie. Compare every group as a whole number.

Watch the exact order stated in the question:

- Some systems check **rightmost first, middle second, leftmost last**.
- Other systems check **rightmost first, leftmost second, middle last**.

Sort $\text{09-02-12}$, $\text{04-90-12}$, and $\text{04-80-12}$ when the rule checks rightmost first, leftmost second, and middle last (ascending):

- Step $1$ (rightmost): all three end in $12$ (tie).
- Step $2$ (leftmost, stated second): $04 < 09$, so both $04$ files beat $\text{09-02-12}$.
- Step $3$ (middle, stated last): for the two $04$ files, $80 < 90$, so $\text{04-80-12}$ comes before $\text{04-90-12}$.
- Order: **$\text{04-80-12}$**, **$\text{04-90-12}$**, **$\text{09-02-12}$**.

:::pair #wrong-secondary-order
Right: when the rule checks leftmost second, $\text{04-80-12}$ comes before $\text{09-02-12}$ ($04 < 09$)
Wrong: $\text{09-02-12}$ comes first because middle group $02 < 80$
Do not assume the middle group always goes second. Read the question to see which group breaks rightmost ties first.
:::

:::check
A system compares rightmost group first, middle group second, and leftmost group last, all ascending. Between $\text{55-14-07}$ and $\text{12-30-07}$, which comes first?
:::answer
The answer is **$\text{55-14-07}$**. Both end in $07$, and the middle group $14$ is smaller than $30$.
:::

## Examples

### #1: Rightmost, Then Middle, Then Leftmost

A filing system compares the rightmost group first, then the middle group, then the leftmost group. Each group uses ascending numeric order. Arrange $\text{12-44-03}$, $\text{98-10-03}$, $\text{05-10-03}$, and $\text{01-99-02}$ in filing order.

**Solution:**

1. Compare rightmost groups: $\text{01-99-02}$ ends in $02$, while the other three end in $03$. So $\text{01-99-02}$ comes first.
2. Compare middle groups (stated second) for the three $03$ files: $10 < 44$, so $\text{12-44-03}$ goes last.
3. Compare leftmost groups for $\text{98-10-03}$ and $\text{05-10-03}$: $05 < 98$, so $\text{05-10-03}$ comes before $\text{98-10-03}$.
4. The order is $\text{01-99-02}$, $\text{05-10-03}$, $\text{98-10-03}$, $\text{12-44-03}$.

**Check:** Read the rightmost groups ($02, 03, 03, 03$), then middle groups on the $03$ tie ($10, 10, 44$), then leftmost on the $10\text{-}03$ tie ($05, 98$).

### #2: Rightmost, Then Leftmost, Then Middle

A terminal-digit system compares the rightmost group first, the leftmost group second, and the middle group last, each in ascending order. Which file comes first: $\text{06-85-15}$, $\text{11-05-15}$, $\text{02-01-16}$, or $\text{06-70-15}$?

**Solution:**

1. Compare rightmost groups: $15 < 16$, so drop $\text{02-01-16}$.
2. Compare leftmost groups (stated second) for the three $15$ files: $06 < 11$, so drop $\text{11-05-15}$.

:::try
Finish the last step: compare the middle groups of $\text{06-85-15}$ and $\text{06-70-15}$ to pick which file comes first.
:::answer
The answer is **$\text{06-70-15}$**. Both end in $15$ and start with $06$, and middle group $70$ is smaller than $85$.

**Check:** $\text{02-01-16}$ has the smallest left and middle numbers ($02$ and $01$), yet goes last because its rightmost group ($16$) is largest; among the $15$ files, $06 < 11$ and $70 < 85$ confirm $\text{06-70-15}$ is first.
:::

## Traps to Watch For

:::checklist
- Under a terminal-digit rule: always start with the rightmost group, never the leftmost group. {#leftmost-first}
- After the rightmost group ties: follow the exact order stated for the middle and leftmost groups. {#wrong-secondary-order}
- No terminal-digit rule in the question: compare ordinary whole numbers by full numeric value (or left to right on equally padded fixed-length keys). {#starting-with-the-rightmost-group}
:::
