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

In **terminal-digit filing**, "terminal" means the end. In these questions, a terminal-digit rule compares the **rightmost group** of digits first, as a whole number.

In these questions, terminal-digit filing applies only when the task states it. Otherwise, use the order the task names.

Find which of $\text{01-99-02}$ and $\text{12-44-03}$ comes first in ascending terminal-digit order:

- Rightmost group of $\text{01-99-02}$: $02$.
- Rightmost group of $\text{12-44-03}$: $03$.
- Since $02 < 03$, **$\text{01-99-02}$** comes first.

:::why
Why sort from the right end at all? In big registries, consecutive new files often share the same starting digits on the left. Sorting by the last two digits spreads files across the $100$ sections ($00$ through $99$) instead of crowding one shelf.
:::

:::pair #leftmost-first
Right: in ascending terminal-digit order, $\text{04-80-12}$ comes before $\text{01-01-13}$ ($12 < 13$)
Wrong: $\text{01-01-13}$ comes first because $01$ is smallest on the left
Starting from the left uses ordinary numeric order, not terminal-digit order. Under a terminal-digit rule, check the rightmost group first.
:::

### Checking the Remaining Groups in Stated Order

When two files tie on the rightmost group, move to the second group named by the task. Move to the third group only if both earlier groups tie. In these questions, each group is compared as a whole number.

Watch the exact order stated in the question:

- Some systems check **rightmost first, middle second, leftmost last**.
- Other systems check **rightmost first, leftmost second, middle last**.

Find the order of $\text{09-02-12}$, $\text{04-90-12}$, and $\text{04-80-12}$ when the rule checks rightmost first, leftmost second, and middle last (ascending):

- Step $1$ (rightmost): all three end in $12$ (tie).
- Step $2$ (leftmost, stated second): $04 < 09$, so both $04$ files beat $\text{09-02-12}$.
- Step $3$ (middle, stated last): for the two $04$ files, $80 < 90$, so $\text{04-80-12}$ comes before $\text{04-90-12}$.
- Order: **$\text{04-80-12}$**, **$\text{04-90-12}$**, **$\text{09-02-12}$**.

:::pair #wrong-secondary-order
Right: when the rule checks leftmost second, $\text{04-80-12}$ comes before $\text{09-02-12}$ ($04 < 09$)
Wrong: $\text{09-02-12}$ comes first because middle group $02 < 80$
Do not assume the middle group goes second. Read the question to see which group breaks rightmost ties first.
:::

:::check
A system compares the rightmost group first, the middle group second, and the leftmost group last, all ascending. Arrange $\text{18-60-33}$, $\text{02-70-34}$, $\text{90-25-33}$, and $\text{05-60-33}$.
:::answer
The answer is **$\text{90-25-33}$, $\text{05-60-33}$, $\text{18-60-33}$, $\text{02-70-34}$**. Rightmost $34$ puts $\text{02-70-34}$ last. Among the $33$ files, middle $25 < 60$ puts $\text{90-25-33}$ first. The two $60$ files tie, so leftmost $05 < 18$ decides.
:::

## Examples

### #1: Rightmost, Then Middle, Then Leftmost

A filing system compares the rightmost group first, then the middle group, then the leftmost group. Each group uses ascending numeric order. Arrange $\text{12-44-03}$, $\text{98-10-03}$, $\text{05-10-03}$, and $\text{01-99-02}$ in filing order.

**Solution:**

1. Compare rightmost groups: $\text{01-99-02}$ ends in $02$, while the other three end in $03$. So $\text{01-99-02}$ comes first.
2. Compare middle groups (stated second) for the three $03$ files: $10 < 44$, so $\text{12-44-03}$ goes last.
3. The other two tie on middle $10$. They first differ in the leftmost group: $05 < 98$, so $\text{05-10-03}$ comes before $\text{98-10-03}$.
4. The order is $\text{01-99-02}$, $\text{05-10-03}$, $\text{98-10-03}$, $\text{12-44-03}$.

### #2: Rightmost, Then Leftmost, Then Middle

A terminal-digit system compares the rightmost group first, the leftmost group second, and the middle group last, each in ascending order. Arrange $\text{06-85-15}$, $\text{11-05-15}$, $\text{02-01-16}$, and $\text{06-70-15}$ in filing order.

**Solution:**

1. Compare rightmost groups: $15, 15, 16, 15$. Since $15 < 16$, $\text{02-01-16}$ goes last.
2. Compare leftmost groups (stated second) for the three $15$ files: $06, 11, 06$. Since $06 < 11$, $\text{11-05-15}$ goes after the two $06$ files.

:::try
Finish the last step: compare the middle groups of the two $06$ files, then write all four files in filing order.
:::answer
The answer is **$\text{06-70-15}$, $\text{06-85-15}$, $\text{11-05-15}$, $\text{02-01-16}$**. The two $06$ files first differ in the middle group, and $70 < 85$.
:::

## Traps to Watch For

:::checklist
- Terminal-digit rule stated: start with the rightmost group, not the leftmost. {#leftmost-first}
- Rightmost groups tie: follow the stated order for the middle and leftmost groups. {#wrong-secondary-order}
- No terminal-digit rule stated: do not start from the right. Use the order the task names. {#starting-with-the-rightmost-group}
:::
