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

A **truth table** lists every possible combination of truth values for those letters. For two propositions $P$ and $Q$, there are $4$ unique pairs, with none missing and none repeated:

- $(T, T)$
- $(T, F)$
- $(F, T)$
- $(F, F)$

Suppose a student writes rows $(T, T)$, $(F, T)$, $(T, F)$, and $(F, T)$. Row $2$ and row $4$ repeat $(F, T)$, leaving $(F, F)$ out, so replace the repeated row $4$ with $(F, F)$.

:::pair #missing-table-case
Right: check that all $4$ distinct pairs $(T, T)$, $(T, F)$, $(F, T)$, and $(F, F)$ appear once each.
Wrong: see $4$ rows and **Keep every row as written.**
Having $4$ rows is not enough if two rows repeat the same pair. Check each pair against the $4$ combinations.
:::

:::check
A list for $P$ and $Q$ shows $(T, T)$, $(T, F)$, $(T, F)$, and $(F, F)$. Which pair is missing?
:::answer
The answer is **$(F, T)$**. The pair $(T, F)$ appeared twice and took the place of $(F, T)$.
:::

### The And Rule

A **connective** joins statements or changes a truth value. The **and** connective (written $\land$) is true only when both statements are true.

"Evaluate" means find the truth value ($T$ or $F$) of a logical expression. Check $P \land Q$ for all $4$ pairs:

$$T \land T = T,\quad T \land F = F$$

$$F \land T = F,\quad F \land F = F$$

:::pair #one-true-for-and
Right: when $P=T$ and $Q=F$, $(P \land Q, P \lor Q)$ equals **$(F, T)$**.
Wrong: when $P=T$ and $Q=F$, $(P \land Q, P \lor Q)$ equals **$(T, T)$**.
One true input makes **or** true, never **and**. For **and**, even a single $F$ makes the whole expression $F$.
:::

:::check
If $P$ is false and $Q$ is true, evaluate $P \land Q$.
:::answer
The answer is **$F$** (false). Both parts must be true for **and** to be true, and $P$ is false.
:::

### The Inclusive Or Rule

The **inclusive or** connective (written $\lor$) is true whenever at least one statement is true. It is also true when both statements are true, and false only when both are false.

Check $P \lor Q$ for all $4$ pairs:

$$T \lor T = T,\quad T \lor F = T$$

$$F \lor T = T,\quad F \lor F = F$$

:::why
Why is $T \lor T = T$ in logic? Everyday speech often uses "or" to mean only one choice, like soup or salad. In formal logic, "or" means "at least one," so both true still counts as $T$.
:::

:::pair #exclusive-or-mistake
Right: when $P=T$ and $Q=T$, $(P \land Q, P \lor Q)$ equals **$(T, T)$**.
Wrong: when $P=T$ and $Q=T$, $(P \land Q, P \lor Q)$ equals **$(T, F)$**.
The wrong pair treats **or** as exclusive when both inputs are true. Inclusive **or** stays $T$ when both $P$ and $Q$ are $T$.
:::

:::check
Which pair $(P, Q)$ makes inclusive $P \lor Q$ false?
:::answer
The answer is **$(F, F)$**. Inclusive **or** is false only when both inputs are false.
:::

## Examples

### #1: Building an And Truth Table

List the truth values of $P \land Q$ across all four combinations of $P$ and $Q$.

**Solution:**

1. List the $4$ unique pairs for $(P, Q)$: $(T, T)$, $(T, F)$, $(F, T)$, and $(F, F)$.
2. Apply the **and** rule to each pair: true only when both inputs are $T$.

- Row $1$: $T \land T = T$
- Row $2$: $T \land F = F$
- Row $3$: $F \land T = F$
- Row $4$: $F \land F = F$

The column of values for $P \land Q$ is $T, F, F, F$.

**Check:** Only one row has two $T$ inputs, so only one row can give $T$ for **and**.

### #2: Evaluating an Or Statement

If $P$ is false and $Q$ is true, evaluate $P \lor Q$.

**Solution:**

1. Substitute $P=F$ and $Q=T$ into $P \lor Q$ and apply the inclusive **or** rule (at least one input is true, $Q=T$):

$$P \lor Q = F \lor T = T$$

The value of $P \lor Q$ is $T$ (true).

**Check:** An **or** statement is false only when both parts are $F$. Since $Q$ is $T$, the result must be $T$.

### #3: Unknown Input with Inclusive Or

$P$ is true and $Q$ is not known. Evaluate inclusive $P \lor Q$ for all possible values of $Q$.

**Solution:**

1. $Q$ can only be $T$ or $F$, so test both cases.
2. Case $1$ ($Q=T$): $T \lor T = T$.

:::try
Finish the last step: evaluate $P \lor Q$ in Case $2$ when $Q=F$, then state what happens for either value of $Q$.
:::answer
The answer is **$T$ (true) for either value of $Q$**. When $Q=F$, $T \lor F = T$ because $P$ is already $T$.

**Check:** Inclusive **or** needs just one $T$ input, so knowing $P=T$ settles the result without knowing $Q$.
:::

## Speed Tricks & Shortcuts

With **and**, one $F$ settles the answer as $F$ right away. With inclusive **or**, one $T$ settles the answer as $T$ right away, even if the second statement is unknown.

## Traps to Watch For

:::checklist
- Checking a $4$-row truth table: make sure all $4$ distinct pairs $(T, T)$, $(T, F)$, $(F, T)$, and $(F, F)$ appear once with no repeats. {#missing-table-case}
- Seeing one true input in an **and** statement: require both parts to be $T$, so $T \land F = F$. {#one-true-for-and}
- Seeing two true inputs in an inclusive **or** statement: keep the result $T$, so $T \lor T = T$. {#exclusive-or-mistake}
:::
