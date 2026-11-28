---
_id: "lesson-logical-verbal-reasoning-combined-truth-values"
title: "Combined Truth Values"
summary: "Evaluate grouped expressions from the inside out."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 3
partCount: 3
ordering: 13
keyPoints:
  - "Evaluate grouped expressions from the inside out."
  - "Evaluate negation, including a whole grouped statement."
---
## Core Concept

### Negation

**Not** (negation, symbol $\neg$) flips a statement's truth value. If $P$ is $T$, then $\neg P$ is $F$. If $P$ is $F$, then $\neg P$ is $T$. This lesson combines $\neg$, $\land$, $\lor$, and $\rightarrow$ in one expression.

"Evaluate" means find the truth value of an expression. Find $\neg P$ and $\neg\neg P$ when $P=F$, one negation at a time:

$$\neg P=\neg F=T$$

$$\neg\neg P=\neg T=F$$

:::pair #skip-second-negation
Right: if $P=F$, then $(\neg P, \neg\neg P)$ equals **$(T, F)$**.
Wrong: if $P=F$, then $(\neg P, \neg\neg P)$ equals **$(T, T)$**.
The wrong line flips $P$ once and stops. Each $\neg$ flips the value once, so two $\neg$ signs return to the starting value $F$.
:::

### Working Inside Out with Parentheses

Evaluate inside parentheses first, replace the group with $T$ or $F$, then apply the outer connective. Find the value of $(P \land Q) \lor R$ and of $P \land (Q \lor R)$ when $P=F$, $Q=T$, and $R=T$:

1. $(P \land Q) \lor R$: inside first, $F \land T = F$.
2. Then the outer **or**: $F \lor T = T$.
3. $P \land (Q \lor R)$: inside first, $T \lor T = T$.
4. Then the outer **and**: $F \land T = F$.

:::pair #ignore-parentheses
Right: with $P=F$, $Q=T$, and $R=T$, $(P \land Q) \lor R$ and $P \land (Q \lor R)$ give **$(T, F)$**.
Wrong: both expressions give **$(F, F)$**.
The wrong line moves the parentheses in the first expression and reads it as $P \land (Q \lor R)$, which gives $F$. Keep each group where it is written: $(F \land T) \lor T = F \lor T = T$.
:::

### Negating a Whole Group

A $\neg$ flips the statement that comes right after it. If another $\neg$ comes next, work from the inside out. Parentheses can make a whole group the statement to flip: in $\neg(P \land Q)$, evaluate $P \land Q$ first and flip the whole result. In $(\neg P) \land Q$, flip only $P$ first.

Find the value of $\neg(P \land Q)$ and of $(\neg P) \land Q$ when $P=F$ and $Q=F$:

1. $\neg(P \land Q)$: inside first, $F \land F = F$.
2. Then flip the group: $\neg F = T$.
3. $(\neg P) \land Q$: flip $P$ first, $\neg F = T$.
4. Then the **and**: $T \land F = F$.

:::why
Why do $\neg(P \land Q)$ and $(\neg P) \land Q$ differ? Think of parentheses as a box around one value. A $\neg$ outside the box flips the box's single result, while a $\neg$ inside flips only the letter beside it.
:::

:::pair #negate-wrong-scope
Right: with $P=F$ and $Q=F$, $\neg(P \land Q)$ and $(\neg P) \land Q$ give **$(T, F)$**.
Wrong: they give **$(T, T)$**.
The wrong line flipped both $P$ and $Q$ in $(\neg P) \land Q$. The $\neg$ sits inside $(\neg P)$ only, so $Q$ stays $F$, making $T \land F = F$.
:::

:::check
If $P$ is false, $Q$ is false, and $R$ is true, evaluate $(\neg P \lor Q) \land R$.
:::answer
The answer is **$T$**. Inside the parentheses, $\neg P = \neg F = T$, then $T \lor F = T$. Outside, $T \land T = T$.
:::

## Examples

### #1: Evaluating Repeated Negation

Find $\neg P$, $\neg\neg P$, and $\neg\neg\neg P$ when $P$ is true, in that order.

**Solution:**

1. Substitute $P=T$ and apply one $\neg$ at a time:

$$\neg P=\neg T=F$$

$$\neg\neg P=\neg F=T$$

$$\neg\neg\neg P=\neg T=F$$

The ordered results are $(F, T, F)$.

### #2: Combining Connectives

Find the value of $P \lor (Q \land R)$ when $P$ is false, $Q$ is true, and $R$ is false.

**Solution:**

1. Evaluate inside parentheses first: $Q \land R = T \land F = F$.
2. Replace $(Q \land R)$ with $F$ and apply the outer **or**: $P \lor F = F \lor F = F$.

The full expression is $F$ (false).

### #3: Negating a Grouped Statement

Find the value of $\neg(P \rightarrow Q)$ when $P$ is false and $Q$ is false.

**Solution:**

1. Evaluate inside parentheses first: $P \rightarrow Q = F \rightarrow F = T$.
2. Apply the outer $\neg$ to that result: $\neg T = F$.

The full expression is $F$ (false).

### #4: Multi-Group Expression

Find the first group, the second group, and the full expression $(P \rightarrow Q) \lor (\neg Q \land R)$ when $P$ is true, $Q$ is false, and $R$ is true, in that order.

**Solution:**

1. First group $(P \rightarrow Q)$: $T \rightarrow F = F$.
2. In the second group $(\neg Q \land R)$, negate $Q=F$ first: $\neg Q = T$.
3. Join $\neg Q = T$ with $R=T$: $T \land T = T$.

:::try
Finish the last step: join both group results with the outer $\lor$ and state all three values in order.
:::answer
The answer is **$F, T, T$**. The outer **or** combines $F \lor T = T$.
:::

## Speed Tricks & Shortcuts

Replace each inner parentheses group with a single $T$ or $F$ directly on paper as you work outward. If one $\neg$ sits outside the entire expression, solve the whole inside first and flip once at the very end.

## Traps to Watch For

:::checklist
- Double negation: apply each $\neg$ in order, so $\neg\neg F = \neg T = F$. {#skip-second-negation}
- Groups like $(P \land Q) \lor R$: solve inside the parentheses first, then the outer connective. {#ignore-parentheses}
- $\neg(P \land Q)$ versus $(\neg P) \land Q$: an outside $\neg$ flips the whole group's result, an inside $\neg$ only its letter. {#negate-wrong-scope}
:::
