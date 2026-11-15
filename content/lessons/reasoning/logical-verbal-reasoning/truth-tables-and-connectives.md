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

**Propositional logic** studies statements that are either true or false. A **proposition** is a statement with one truth value, true or false. Letters such as $P$, $Q$, and $R$ stand for propositions.

A **truth table** lists all possible truth values for the propositions in a logical statement. It shows the truth value of the full statement for each case. We use $T$ for true and $F$ for false.

To make a truth table, first list every possible set of truth values. For $P$ and $Q$, the pairs are $(T,T)$, $(T,F)$, $(F,T)$, and $(F,F)$. Then find the full statement's truth value for each pair.

A **connective** joins statements or changes a statement's truth value. The following symbols show which rule to use.

**And** (conjunction, symbol $\land$) is true only when both statements are true. So $P \land Q$ is false if either statement is false.

**Or** (disjunction, symbol $\lor$) is true when at least one statement is true. This includes the case where both statements are true. It is false only when both statements are false.

## Examples

### #1: Building an And Truth Table

Build the complete truth table for $P \land Q$.

Here, "build" means list every case and find its result.

**Solution:**

1. List all possible pairs of truth values: $(T,T)$, $(T,F)$, $(F,T)$, and $(F,F)$.
2. Use the rule for and. The result is true only when both values are true.
3. Find the result for each pair.

$$T \land T=T$$

$$T \land F=F$$

$$F \land T=F$$

$$F \land F=F$$

Each line gives one case of the complete truth table for $P \land Q$.

### #2: Evaluating an Or Statement

If $P$ is false and $Q$ is true, what is the truth value of $P \lor Q$?

**Solution:**

Or is true when at least one statement is true.

$$F \lor T=T$$

Since $Q$ is true, $P \lor Q$ is true.

## Speed Tricks & Shortcuts

For and, one false value is enough to make the result false. For or, one true value is enough to make the result true. Once you know that value, you do not need to check the other statement.

## Traps to Watch For

### #1: Mixing Up And and Or

> And needs both statements to be true. Or needs at least one statement to be true.

Using the and rule for an or statement can give a false answer when one statement is true. Using the or rule for an and statement can give a true answer when one statement is false. Check the symbol before choosing a rule.
