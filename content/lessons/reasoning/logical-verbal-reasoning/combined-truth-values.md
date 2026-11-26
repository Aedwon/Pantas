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

**Not** (negation, symbol $\neg$) flips a statement's truth value. If $P$ is $T$, then $\neg P$ is $F$. If $P$ is $F$, then $\neg P$ is $T$.

"Evaluate" means find the truth value of an expression. Apply one negation at a time when two appear in a row:

$$\neg F = T,\quad \neg T = F$$

So starting with $P = F$, $\neg P = T$ and $\neg\neg P = \neg T = F$.

:::pair #skip-second-negation
Right: if $P=F$, then $(\neg P, \neg\neg P)$ equals **$(T, F)$**.
Wrong: if $P=F$, then $(\neg P, \neg\neg P)$ equals **$(T, T)$**.
The wrong line flips $P$ once and stops. Each $\neg$ flips the value once, so two $\neg$ signs return to the starting value $F$.
:::

:::check
If $P$ is true, evaluate $\neg P$ and $\neg\neg P$, in that order.
:::answer
The answer is **$(F, T)$**. The first $\neg$ flips $T$ to $F$, and the second flips $F$ back to $T$.
:::

### Working Inside Out with Parentheses

Evaluate inside parentheses first, replace the group with $T$ or $F$, then apply the outer connective. Compare $(P \land Q) \lor R$ and $P \land (Q \lor R)$ when $P=F$, $Q=T$, and $R=T$:

1. $(P \land Q) \lor R$: $(F \land T) \lor T = F \lor T = T$.
2. $P \land (Q \lor R)$: $F \land (T \lor T) = F \land T = F$.

:::pair #ignore-parentheses
Right: with $P=F$, $Q=T$, and $R=T$, $(P \land Q) \lor R$ and $P \land (Q \lor R)$ give **$(T, F)$**.
Wrong: both expressions give **$(F, F)$**.
Ignoring parentheses gives both expressions the second expression's outer $\land$ with $P=F$. In the first expression, $(P \land Q)$ is evaluated first and joined by an outer $\lor$ with $R=T$, making the full result $T$.
:::

:::check
If $P$ is false, $Q$ is true, and $R$ is false, evaluate $(P \lor Q) \land R$.
:::answer
The answer is **$F$**. Inside parentheses, $F \lor T = T$; outside, $T \land F = F$.
:::

### Negating a Whole Group

Parentheses also show how much a $\neg$ sign covers. In $\neg(P \land Q)$, evaluate $P \land Q$ first and flip the whole result; in $(\neg P) \land Q$, flip only $P$ first.

Test $P=F$ and $Q=F$:

1. For $\neg(P \land Q)$: inside gives $F \land F = F$, then $\neg F = T$.
2. For $(\neg P) \land Q$: flip $P$ to $\neg F = T$, then compute $T \land F = F$.

:::why
Why do $\neg(P \land Q)$ and $(\neg P) \land Q$ differ? Think of parentheses as a box around one value. A $\neg$ outside the box flips the box's single result, while a $\neg$ inside flips only the letter beside it.
:::

:::pair #negate-wrong-scope
Right: with $P=F$ and $Q=F$, $\neg(P \land Q)$ and $(\neg P) \land Q$ give **$(T, F)$**.
Wrong: they give **$(T, T)$**.
The wrong line flipped both $P$ and $Q$ in $(\neg P) \land Q$. The $\neg$ sits inside $(\neg P)$ only, so $Q$ stays $F$, making $T \land F = F$.
:::

:::check
With $P$ true and $Q$ true, evaluate $\neg(P \lor Q)$.
:::answer
The answer is **$F$**. Inside parentheses, $T \lor T = T$, and negating that result gives $\neg T = F$.
:::

## Examples

### #1: Evaluating a Negation

If $P$ is false, evaluate $\neg P$ and $\neg\neg P$, in that order.

**Solution:**

1. Negate $P=F$ once.

$$\neg F = T$$

2. Negate that result once more.

$$\neg T = F$$

The ordered results are $(T, F)$.

**Check:** Double negation always returns the original value ($F$), while single negation flips it ($T$).

### #2: Combining Connectives

If $P$ is true, $Q$ is false, and $R$ is true, evaluate $(P \land Q) \lor R$.

**Solution:**

1. Evaluate inside parentheses first: $T \land F = F$.
2. Replace $(P \land Q)$ with $F$ and apply the outer **or**: $F \lor T = T$.

The full expression is $T$ (true).

**Check:** Since $R=T$ sits on an outer **or**, it forces the whole expression to $T$.

### #3: Negating a Grouped Statement

If $P$ is true and $Q$ is false, evaluate $\neg(P \land Q)$.

**Solution:**

1. Evaluate inside parentheses first: $T \land F = F$.
2. Apply the outer $\neg$ to that result: $\neg F = T$.

The full expression is $T$ (true).

**Check:** One false part ($Q=F$) makes the inner **and** ($T \land F$) false, so the outer $\neg$ flips that $F$ to $T$.

### #4: Multi-Group Expression

If $P$ is true, $Q$ is false, and $R$ is false, evaluate the first group, the second group, and the full expression $(P \rightarrow Q) \lor (\neg Q \land R)$, in that order.

**Solution:**

1. First group $(P \rightarrow Q)$: $T \rightarrow F = F$.
2. In the second group $(\neg Q \land R)$, negate $Q=F$ first: $\neg Q = T$.
3. Join $\neg Q = T$ with $R=F$: $T \land F = F$.

:::try
Finish the last step: join both group results with the outer $\lor$ and state all three values in order.
:::answer
The answer is **$F, F, F$**. The outer **or** combines $F \lor F = F$.

**Check:** Both $(P \rightarrow Q)$ and $(\neg Q \land R)$ evaluate to $F$, and $F \lor F$ forces the outer **or** to $F$.
:::

## Speed Tricks & Shortcuts

Replace each inner parentheses group with a single $T$ or $F$ directly on paper as you work outward. If one $\neg$ sits outside the entire expression, solve the whole inside first and flip once at the very end.

## Traps to Watch For

:::checklist
- Double negation $\neg\neg P$: apply each $\neg$ in order so two flips return the original value. {#skip-second-negation}
- Nested groups like $(P \land Q) \lor R$ vs $P \land (Q \lor R)$: solve inside parentheses before checking the outer connective. {#ignore-parentheses}
- Negation scope $\neg(P \land Q)$ vs $(\neg P) \land Q$: an outside $\neg$ flips one value, the result of the entire group, while an inside $\neg$ flips only the single letter beside it. {#negate-wrong-scope}
:::
