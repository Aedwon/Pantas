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

An **if-then** statement (or **conditional**) is written $P \rightarrow Q$ and read "if $P$, then $Q$." Here $P$ is the **if-part** and $Q$ is the **then-part**.

Think of $P \rightarrow Q$ as a promise: "If you clean your room ($P$), you get ice cream ($Q$)." The promise is broken only when you clean your room ($P=T$) and still do not get ice cream ($Q=F$).

Look at all $4$ cases for $P \rightarrow Q$ ("Evaluate" means find the truth value of a statement):

$$T \rightarrow T = T,\quad T \rightarrow F = F$$

$$F \rightarrow T = T,\quad F \rightarrow F = T$$

The only false case is $T \rightarrow F$ (room cleaned, no ice cream: promise broken). Every false if-part keeps the promise unbroken, so both $F \rightarrow T$ and $F \rightarrow F$ equal $T$.

:::why
Why is a conditional $T$ whenever its if-part is $F$? A promise says only what happens when the condition $P$ holds. When $P$ does not happen, the rule cannot be broken.
:::

:::pair #false-if-gives-false
Right: when $P=F$ and $Q=F$, $(P \rightarrow Q, Q \rightarrow P)$ equals **$(T, T)$**.
Wrong: when $P=F$ and $Q=F$, $(P \rightarrow Q, Q \rightarrow P)$ equals **$(F, F)$**.
It is tempting to mark $F \rightarrow F$ as false because both inputs are false. Always check for the one false case ($T \rightarrow F$); every false if-part gives $T$.
:::

:::check
If $P$ is false and $Q$ is true, evaluate $P \rightarrow Q$.
:::answer
The answer is **$T$** (true). The if-part $P$ is false, so $F \rightarrow T = T$.
:::

### Swapping the Direction

Order matters in $P \rightarrow Q$ and $Q \rightarrow P$, because they swap which letter is the if-part.

Compare $P \rightarrow Q$ and $Q \rightarrow P$ with $P=T$, $Q=F$:

1. $P \rightarrow Q = T \rightarrow F = F$.
2. $Q \rightarrow P = F \rightarrow T = T$.

:::pair #reversed-conditional-values
Right: when $P=T$ and $Q=F$, $(P \rightarrow Q, Q \rightarrow P)$ equals **$(F, T)$**.
Wrong: when $P=T$ and $Q=F$, $(P \rightarrow Q, Q \rightarrow P)$ equals **$(T, F)$**.
The wrong answer swaps the two directions. Always look at the letter sitting right before the arrow to find the if-part.
:::

:::check
With $P$ false and $Q$ true, evaluate $P \rightarrow Q$ and $Q \rightarrow P$, in that order.
:::answer
The answer is **$(T, F)$**. $P \rightarrow Q$ is $F \rightarrow T = T$, while $Q \rightarrow P$ is $T \rightarrow F = F$.
:::

## Examples

### #1: Evaluating a Conditional with False Parts

With $P$ false and $Q$ false, evaluate $P \rightarrow Q$ and $Q \rightarrow P$, in that order.

**Solution:**

1. Substitute $P=F$ and $Q=F$ into $P \rightarrow Q$ and $Q \rightarrow P$:

$$(P \rightarrow Q) = (F \rightarrow F) = T$$

$$(Q \rightarrow P) = (F \rightarrow F) = T$$

The ordered results are $(T, T)$.

**Check:** Neither expression has $T \rightarrow F$, the only false case, so both must be $T$.

### #2: Finding the False Conditional Case

With $P$ true and $Q$ false, evaluate $P \rightarrow Q$ and $Q \rightarrow P$, in that order.

**Solution:**

1. Substitute $P=T$ and $Q=F$ into $P \rightarrow Q$ and $Q \rightarrow P$:

$$(P \rightarrow Q) = (T \rightarrow F) = F$$

$$(Q \rightarrow P) = (F \rightarrow T) = T$$

The ordered results are $(F, T)$.

**Check:** Check the arrow direction on each one: $P \rightarrow Q$ starts at $T$ and ends at $F$ (broken promise), while $Q \rightarrow P$ starts at $F$ (never triggered).

### #3: Full Conditional Column

Find the truth values of $P \rightarrow Q$ across all four combinations of $(P, Q)$: $(T, T)$, $(T, F)$, $(F, T)$, and $(F, F)$.

**Solution:**

1. Row $1$ $(T, T)$: true if-part and true then-part give $T \rightarrow T = T$.
2. Row $2$ $(T, F)$: true if-part and false then-part give the one false case, $T \rightarrow F = F$.

:::try
Finish the last step: evaluate rows $3$ $(F, T)$ and $4$ $(F, F)$, then write all four values in order.
:::answer
The answer is **$T, F, T, T$**. Both $(F, T)$ and $(F, F)$ have a false if-part, so both give $T$.

**Check:** Out of the $4$ rows, exactly $1$ row is $F$ (row $2$, $T \rightarrow F$) and the other $3$ rows are $T$.
:::

## Speed Tricks & Shortcuts

To evaluate any conditional $X \rightarrow Y$, ask just one question: "Is $X=T$ and $Y=F$?" If yes, the answer is $F$; in every other case, the answer is $T$.

## Traps to Watch For

:::checklist
- A conditional with a false if-part: remember only $T \rightarrow F$ is false, so $F \rightarrow F = T$ and $F \rightarrow T = T$. {#false-if-gives-false}
- Reversed arrows $P \rightarrow Q$ and $Q \rightarrow P$: check which letter sits before the arrow before applying $T \rightarrow F = F$. {#reversed-conditional-values}
:::
