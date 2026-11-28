---
_id: "lesson-logical-verbal-reasoning-sequence-letter-patterns"
title: "Letter Patterns"
summary: "Use alphabet positions and wraparound."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 4
partCount: 4
ordering: 10
keyPoints:
  - "Use alphabet positions and wraparound."
  - "Recognize word-group and spelling patterns."
---
## Core Concept

### Alphabet Positions

To solve a letter sequence with jumps, convert each letter to its English alphabet number from $A=1$ through $Z=26$. Solve the number pattern, then turn the answer back into a letter.

1. Find the next letter in $A, C, E, G, \ldots$
2. Write the positions: $A=1$, $C=3$, $E=5$, $G=7$.
3. Each position increases by $2$: $7+2=9$.
4. Position $9$ is **$I$**.

:::pair #off-by-one-position
Right: under $A=1$ through $Z=26$, position $21$ is **$U$**.
Wrong: position $21$ is **$V$**.
If you count from $A=0$, position $21$ gives $V$. Here $A=1$, so $T=20$ and $U=21$.
:::

### Wraparound Patterns

A **wraparound pattern** keeps moving past $Z$ ($26$) by looping straight back to $A$ ($1$). When an addition goes past $26$, subtract $26$.

1. Find the next letter in $W, Z, C, F, \ldots$
2. Convert to numbers: $W=23$, $Z=26$, $C=3$, $F=6$.
3. Test $+3$ at each step: $23+3=26$ ($Z$), $26+3=29$ and $29-26=3$ ($C$), and $3+3=6$ ($F$).
4. Continue from $F$: $6+3=9$, which is **$I$**.

:::why
Why subtract $26$ when passing $Z$? There are $26$ letters in the cycle, so position $27$ lands back on $1$ ($A$), $28$ on $2$ ($B$), and $29$ on $3$ ($C$).
:::

:::pair #wraparound-miscount
Right: moving $3$ letters forward from $F$ ($6$) reaches $I$ ($9$).
Wrong: moving from $F$ lands on **$H$** or **$J$**.
Counting $F$ itself as move $1$ stops after two moves at $H$, and counting one move too many reaches $J$ after four. Count the moves after $F$: $G$ ($1$), $H$ ($2$), $I$ ($3$).
:::

:::check
Using wraparound after $Z$, find the next letter in $S, X, C, H, \ldots$
:::answer
The answer is **$M$**. The positions are $19, 24, 3, 8$ ($24+5=29$, and $29-26=3$). Each step adds $5$, so $8+5=13$, which is $M$.
:::

### Word-Group and Spelling Patterns

Some letter sequences use the first letters of words in a known order, such as months of the year, days of the week, or number words.

Do not force alphabet positions when a word-group rule fits the shown terms cleanly.

1. Find the next letter in $J, F, M, A, M, J, J, \ldots$
2. Read the initials as calendar months: January, February, March, April, May, June, July.
3. The $8$th month is August, so the next letter is **$A$**.

:::pair #force-letter-jump
Right: after $J$ (June) and $J$ (July) in $J, F, M, A, M, J, J, \ldots$, the next letter is **$A$** (August).
Wrong: the next letter is **$J$**.
Seeing two $J$s in a row looks like a repeating letter rule, but the list follows calendar months from January. Check the full word sequence.
:::

## Examples

### #1: Letter Positions

Find the next letter: $B, D, G, K, \ldots$

**Solution:**

1. Convert letters to positions ($A=1$ to $Z=26$): $B=2$, $D=4$, $G=7$, $K=11$.

2. Find the jumps between $2, 4, 7, 11$:

$$4-2=2,\quad 7-4=3,\quad 11-7=4$$

3. Jumps grow by $1$; add $5$ to $K=11$:

$$\text{Next}=11+5=16$$

4. Position $16$ is $P$.

The next letter is **$P$**.

### #2: Spelling Pattern

Find the next letter: $O, T, T, F, F, S, S, E, \ldots$

**Solution:**

1. Read the letters as the starting letters of counting words: One, Two, Three, Four, Five, Six, Seven, Eight.
2. The next counting word is Nine, which starts with $N$.

The next letter is **$N$**.

### #3: Word-Group Pattern

Find the next letter: $M, T, W, T, F, S, \ldots$

**Solution:**

1. Read the letters as the starting letters of the days of the week: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday.
2. The next day is Sunday, which starts with $S$.

The next letter is **$S$**.

### #4: Wraparound Letter Pattern

Find the next letter in this cyclic alphabet sequence: $X, Z, B, D, \ldots$

**Solution:**

1. Convert each letter to its position: $X=24$, $Z=26$, $B=2$, $D=4$.
2. Check each move: $24+2=26$ ($Z$), $26+2=28 \to 28-26=2$ ($B$), and $2+2=4$ ($D$).

:::try
Finish the last step: find the next letter.
:::answer
The answer is **$F$**. Each move adds $2$, so $4+2=6$, and the $6$th letter is $F$.
:::

## Speed Tricks & Shortcuts

Memorize five anchor positions to find letters faster without counting from $A$: $E=5$, $J=10$, $O=15$, $T=20$, and $Y=25$. For position $16$, jump straight to $O=15$ and step forward one to $P$.

## Traps to Watch For

:::checklist
- Converting numbers back to letters: anchor at $A=1$ and $T=20$, so position $21$ is $U$, not $V$. {#off-by-one-position}
- Counting letter moves: count the moves after the current letter, so $+3$ from $F$ reaches $I$, not $H$ or $J$. {#wraparound-miscount}
- Repeating letters in a word list: check months, days, or number words before guessing a letter pattern, so $J, F, M, A, M, J, J$ goes to $A$. {#force-letter-jump}
:::
