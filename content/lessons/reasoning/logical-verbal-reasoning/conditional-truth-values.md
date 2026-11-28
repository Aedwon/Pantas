---
_id: "lesson-logical-verbal-reasoning-conditional-truth-values"
title: "Conditional Truth Values"
summary: "Identify the only false conditional case."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 2
partCount: 3
ordering: 12
keyPoints:
  - "Identify the only false conditional case."
---
## Core Concept

### If-Then Statements

An **if-then** statement (or **conditional**) is written $P \rightarrow Q$ and read "if $P$, then $Q$." Here $P$ is the **if-part** and $Q$ is the **then-part**. In logic, its truth value depends only on the values of $P$ and $Q$.

Think of $P \rightarrow Q$ as a promise: "If you clean your room ($P$), you get ice cream ($Q$)." The promise is broken only when you clean your room ($P=T$) and still do not get ice cream ($Q=F$).

Find the value of $P \rightarrow Q$ for all $4$ cases ("Evaluate" means find the truth value of a statement):

$$T \rightarrow T = T,\quad T \rightarrow F = F$$

$$F \rightarrow T = T,\quad F \rightarrow F = T$$

The only false case is $T \rightarrow F$ (room cleaned, no ice cream: promise broken). A false if-part keeps the promise unbroken, so $F \rightarrow T$ and $F \rightarrow F$ equal $T$.

:::why
Why is a conditional $T$ whenever its if-part is $F$? A promise says only what happens when the condition $P$ holds. When $P$ does not happen, the rule cannot be broken.
:::

:::pair #false-if-gives-false
Right: when $P=F$ and $Q=F$, $(P \rightarrow Q, Q \rightarrow P)$ equals **$(T, T)$**.
Wrong: when $P=F$ and $Q=F$, $(P \rightarrow Q, Q \rightarrow P)$ equals **$(F, F)$**.
It is tempting to mark $F \rightarrow F$ as false because both inputs are false. In these tables only $T \rightarrow F$ is false, so a false if-part gives $T$.
:::

:::check
A school rule says, "If a pupil is late ($P$), the pupil gets a note ($Q$)." On Monday, $P \rightarrow Q$ was false. What happened on Monday?
:::answer
The answer is **A pupil was late and got no note.** A conditional is false only when the if-part is $T$ and the then-part is $F$.
:::

### Swapping the Direction

Order matters in $P \rightarrow Q$ and $Q \rightarrow P$, because they swap which letter is the if-part.

Find $P \rightarrow Q$ and $Q \rightarrow P$ when $P=T$ and $Q=F$:

1. $P \rightarrow Q = T \rightarrow F = F$.
2. $Q \rightarrow P = F \rightarrow T = T$.

:::pair #reversed-conditional-values
Right: when $P=T$ and $Q=F$, $(P \rightarrow Q, Q \rightarrow P)$ equals **$(F, T)$**.
Wrong: when $P=T$ and $Q=F$, $(P \rightarrow Q, Q \rightarrow P)$ equals **$(T, F)$**.
The wrong answer swaps the two directions. The if-part is the letter before the arrow.
:::

## Examples

### #1: Both Parts True

Rule: "If it is Sunday ($P$), the shop is closed ($Q$)." Find $P \rightarrow Q$ and $Q \rightarrow P$, in that order, when it is Sunday and the shop is closed.

**Solution:**

1. Both statements are true, so $P=T$ and $Q=T$.
2. Substitute into $P \rightarrow Q$ and $Q \rightarrow P$:

$$(P \rightarrow Q) = (T \rightarrow T) = T$$

$$(Q \rightarrow P) = (T \rightarrow T) = T$$

The ordered results are $(T, T)$.

### #2: A False If-Part in the Reverse Direction

Rule: "If a student scores above $90$ ($P$), the student gets a medal ($Q$)." Find $P \rightarrow Q$ and $Q \rightarrow P$, in that order, for Dan, who scored $85$ and got a medal.

**Solution:**

1. Dan did not score above $90$, so $P=F$. He got a medal, so $Q=T$.
2. Substitute into $P \rightarrow Q$ and $Q \rightarrow P$:

$$(P \rightarrow Q) = (F \rightarrow T) = T$$

$$(Q \rightarrow P) = (T \rightarrow F) = F$$

The ordered results are $(T, F)$.

### #3: Full Conditional Column

Find the truth values of $Q \rightarrow P$ across all four combinations of $(P, Q)$: $(T, T)$, $(T, F)$, $(F, T)$, and $(F, F)$.

**Solution:**

1. Row $1$ $(T, T)$: $Q \rightarrow P$ is $T \rightarrow T = T$.
2. Row $2$ $(T, F)$: the if-part $Q$ is false, so $F \rightarrow T = T$.

:::try
Finish the last step: find $Q \rightarrow P$ in rows $3$ $(F, T)$ and $4$ $(F, F)$, then write all four values in order.
:::answer
The answer is **$T, T, F, T$**. Row $3$ gives $Q \rightarrow P = T \rightarrow F = F$, the one false case. Row $4$ gives $F \rightarrow F = T$.
:::

## Speed Tricks & Shortcuts

To find $X \rightarrow Y$, ask one question: "Is $X=T$ and $Y=F$?" If yes, the answer is $F$. In every other case, the answer is $T$.

## Traps to Watch For

:::checklist
- False if-part: the conditional is $T$, so $F \rightarrow F = T$ and $F \rightarrow T = T$. {#false-if-gives-false}
- Reversed arrows: find the letter before the arrow first, then only $T \rightarrow F$ is $F$. {#reversed-conditional-values}
:::
