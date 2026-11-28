---
_id: "lesson-logical-verbal-reasoning-truth-tables-and-connectives"
title: "Truth Tables, And, and Or"
summary: "List truth-table cases."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 1
partCount: 3
ordering: 11
keyPoints:
  - "List truth-table cases."
  - "Apply the and and inclusive or rules."
---
## Core Concept

### Listing Truth-Table Cases

**Propositional logic** works with statements that are either true ($T$) or false ($F$). Each basic statement is a **proposition**, written with a letter such as $P$, $Q$, or $R$.

A **truth table** lists every possible combination of truth values for its letters, with none missing and none repeated. $n$ letters give $2^n$ rows. This lesson uses two letters, $P$ and $Q$, so there are $4$ unique pairs:

- $(T, T)$
- $(T, F)$
- $(F, T)$
- $(F, F)$

Find the missing pair in this student's list: $(T, T)$, $(F, T)$, $(T, F)$, $(F, T)$.

1. Rows $2$ and $4$ repeat $(F, T)$.
2. Compare with the $4$ pairs above: $(F, F)$ is missing.
3. Replace either repeated row with $(F, F)$.

:::pair #missing-table-case
Right: check that all $4$ distinct pairs $(T, T)$, $(T, F)$, $(F, T)$, and $(F, F)$ appear once each.
Wrong: see $4$ rows and **Keep every row as written.**
Having $4$ rows is not enough if two rows repeat the same pair. Check each pair against the $4$ combinations.
:::

### The And Rule

A **connective** joins statements or changes a truth value. The **and** connective (written $\land$) is true only when both statements are true.

"Evaluate" means find the truth value ($T$ or $F$) of a logical expression. Find $P \land Q$ for all $4$ pairs:

$$T \land T = T,\quad T \land F = F$$

$$F \land T = F,\quad F \land F = F$$

### The Inclusive Or Rule

The **inclusive or** connective (written $\lor$) is true whenever at least one statement is true. It is also true when both statements are true, and false only when both are false.

Find $P \lor Q$ for all $4$ pairs:

$$T \lor T = T,\quad T \lor F = T$$

$$F \lor T = T,\quad F \lor F = F$$

:::why
Why is $T \lor T = T$ in logic? Everyday speech often uses "or" to mean only one choice, like soup or salad. In formal logic, "or" means "at least one," so both true still counts as $T$.
:::

:::pair #one-true-for-and
Right: when $P=T$ and $Q=F$, $(P \land Q, P \lor Q)$ equals **$(F, T)$**.
Wrong: when $P=T$ and $Q=F$, $(P \land Q, P \lor Q)$ equals **$(T, T)$**.
One true input is enough for **or**, but not for **and**. For **and**, a single $F$ makes the whole expression $F$.
:::

:::pair #exclusive-or-mistake
Right: when $P=T$ and $Q=T$, $(P \land Q, P \lor Q)$ equals **$(T, T)$**.
Wrong: when $P=T$ and $Q=T$, $(P \land Q, P \lor Q)$ equals **$(T, F)$**.
The wrong pair treats **or** as exclusive when both inputs are true. Inclusive **or** stays $T$ when both $P$ and $Q$ are $T$.
:::

:::check
Joy packs a ruler and an eraser. Is "Joy packs a pen or a pencil or a ruler" true under inclusive **or**?
:::answer
The answer is **true**. Inclusive **or** is true when at least one part is true, and the ruler is packed.
:::

## Examples

### #1: Building a Two-Column Truth Table

Build one table that shows $(P \land Q, P \lor Q)$ for all four combinations of $P$ and $Q$, using the **and** and **or** rules above.

**Solution:**

1. List the $4$ unique pairs for $(P, Q)$: $(T, T)$, $(T, F)$, $(F, T)$, and $(F, F)$.
2. Put both rule results side by side in every row:

- Row $1$, input $(T, T)$: $T \land T = T$ and $T \lor T = T$, so $(T, T)$
- Row $2$, input $(T, F)$: $T \land F = F$ and $T \lor F = T$, so $(F, T)$
- Row $3$, input $(F, T)$: $F \land T = F$ and $F \lor T = T$, so $(F, T)$
- Row $4$, input $(F, F)$: $F \land F = F$ and $F \lor F = F$, so $(F, F)$

The column of pairs for $(P \land Q, P \lor Q)$ is $(T, T), (F, T), (F, T), (F, F)$.

### #2: Evaluating an Or Statement in Words

Decide whether "Rina brings a hat or an umbrella" is true when she brings an umbrella but no hat.

**Solution:**

1. Let $P$ be "Rina brings a hat" and $Q$ be "Rina brings an umbrella." Then $P=F$ and $Q=T$.
2. Substitute $P=F$ and $Q=T$ into $P \lor Q$ (inclusive **or**):

$$P \lor Q = F \lor T = T$$

The statement is true.

### #3: Unknown Input with Inclusive Or

$Q$ is false and $P$ is not known. Find $P \lor Q$ for each possible value of $P$, then say how the result compares with $P$.

**Solution:**

1. $P$ can only be $T$ or $F$, so test both cases.
2. Case $1$ ($P=T$): $T \lor F = T$.
3. Case $2$ ($P=F$): $F \lor F = F$.

:::try
Finish the last step: say how the result of $P \lor Q$ compares with $P$ in both cases.
:::answer
The answer is **the result matches $P$**: $T$ when $P=T$, and $F$ when $P=F$. With $Q=F$, no $T$ comes from $Q$, so $P$ alone decides the result.
:::

## Speed Tricks & Shortcuts

With **and**, one $F$ settles the answer as $F$ right away. With inclusive **or**, one $T$ settles the answer as $T$ right away, even if the second statement is unknown.

## Traps to Watch For

:::checklist
- A $4$-row table: each pair $(T, T)$, $(T, F)$, $(F, T)$, $(F, F)$ appears once. {#missing-table-case}
- Exactly one true input in an **and**: the other input is false, so the result is $F$, since $T \land F = F$. {#one-true-for-and}
- Two true inputs in an inclusive **or**: $T$, since $T \lor T = T$. {#exclusive-or-mistake}
:::
