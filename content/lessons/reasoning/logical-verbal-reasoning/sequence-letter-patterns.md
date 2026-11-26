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

1. Look at $A, C, E, G, \ldots$
2. Write the positions: $A=1$, $C=3$, $E=5$, $G=7$.
3. Each position increases by $2$: $7+2=9$.
4. Position $9$ is **$I$**.

:::pair #off-by-one-position
Right: under $A=1$ through $Z=26$, position $21$ is **$U$**.
Wrong: position $21$ is **$V$**.
Counting from $A=0$ shifts every letter up by $1$ and turns $21$ into $V$. Always start at $A=1$, so $T=20$ and $U=21$.
:::

:::check
Using $A=1$ through $Z=26$, find the next letter in $D, H, L, P, \ldots$
:::answer
The answer is **$T$**. The positions are $4, 8, 12, 16$, so add $4$ to reach position $20$, which is $T$.
:::

### Wraparound Patterns

A **wraparound pattern** keeps moving past $Z$ ($26$) by looping straight back to $A$ ($1$). Subtract $26$ whenever an addition goes past $26$.

1. Look at $W, Z, C, F, \ldots$
2. Convert to numbers: $W=23$, $Z=26$, $C=3$, $F=6$.
3. Test $+3$ at each step: $23+3=26$ ($Z$), $26+3=29$ and $29-26=3$ ($C$), and $3+3=6$ ($F$).
4. Continue from $F$: $6+3=9$, which is **$I$**.

:::why
Why subtract $26$ when passing $Z$? There are $26$ letters in the cycle, so position $27$ lands back on $1$ ($A$), $28$ on $2$ ($B$), and $29$ on $3$ ($C$).
:::

:::pair #wraparound-miscount
Right: moving $3$ letters forward from $F$ ($6$) reaches $I$ ($9$).
Wrong: moving from $F$ lands on **$H$** or **$J$**.
Counting $F$ itself as step $1$ stops early at $H$, while adding an extra step during wraparound overshoots to $J$. Count moves after $F$: $G$ ($1$), $H$ ($2$), $I$ ($3$).
:::

:::check
Using wraparound after $Z$, find the next letter in $U, X, A, D, \ldots$
:::answer
The answer is **$G$**. Each step adds $3$ ($21, 24, 1, 4$), so $4+3=7$, which is $G$.
:::

### Word-Group and Spelling Patterns

Some letter sequences use the first letters of words in a known order, such as months of the year, days of the week, or number words.

Do not force alphabet positions when a word-group rule fits every term cleanly.

1. Look at $J, F, M, A, M, J, J, \ldots$
2. Read the initials as calendar months: January, February, March, April, May, June, July.
3. The $8$th month is August, so the next letter is **$A$**.

:::pair #force-letter-jump
Right: after $J$ (June) and $J$ (July) in $J, F, M, A, M, J, J, \ldots$, the next letter is **$A$** (August).
Wrong: the next letter is **$J$**.
Seeing two $J$s in a row looks like a repeating letter rule, but the list follows calendar months from January. Always check the full word sequence.
:::

:::check
Find the next letter in $S, M, T, W, T, \ldots$
:::answer
The answer is **$F$**. These are the first letters of days from Sunday to Thursday, so Friday ($F$) comes next.
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

**Check:** Count $5$ letters after $K$: $L, M, N, O, P$. That lands on $P$.

### #2: Spelling Pattern

Find the next letter: $O, T, T, F, F, S, S, E, \ldots$

**Solution:**

1. Read the letters as the starting letters of counting words: One, Two, Three, Four, Five, Six, Seven, Eight.
2. The next counting word is Nine, which starts with $N$.

The next letter is **$N$**.

**Check:** Match each position to its number word: $1$ (One) through $8$ (Eight) match all eight letters, so $9$ (Nine) gives $N$.

### #3: Word-Group Pattern

Find the next letter: $M, T, W, T, F, S, \ldots$

**Solution:**

1. Read the letters as the starting letters of the days of the week: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday.
2. The next day is Sunday, which starts with $S$.

The next letter is **$S$**.

**Check:** Six days are listed ($M$ through $S$), leaving Sunday ($S$) as the seventh day.

### #4: Wraparound Letter Pattern

Find the next letter in this cyclic alphabet sequence: $X, Z, B, D, \ldots$

**Solution:**

1. Convert each letter to its position: $X=24$, $Z=26$, $B=2$, $D=4$.
2. Check each move: $24+2=26$ ($Z$), $26+2=28 \to 28-26=2$ ($B$), and $2+2=4$ ($D$).

:::try
Finish the last step: add $2$ to $D$ ($4$) and give the matching letter.
:::answer
The answer is **$F$**. Position $4+2=6$, and the $6$th letter is $F$.

**Check:** Count $2$ steps forward from $D$: $E$ ($1$), $F$ ($2$). Both the number sum and finger count give $F$.
:::

## Speed Tricks & Shortcuts

Memorize five anchor positions to find any letter fast without counting from $A$: $E=5$, $J=10$, $O=15$, $T=20$, and $Y=25$. For position $16$, jump straight to $O=15$ and step forward one to $P$.

## Traps to Watch For

:::checklist
- Converting numbers back to letters: anchor at $A=1$ and $T=20$, so position $21$ is $U$, not $V$. {#off-by-one-position}
- Counting steps across $Z$: count only moves after the current letter, so $+3$ from $F$ reaches $I$, not $H$ or $J$. {#wraparound-miscount}
- Repeating letters in a word list: check months, days, or number words before guessing a letter pattern, so $J, F, M, A, M, J, J$ goes to $A$. {#force-letter-jump}
:::
