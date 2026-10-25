---
_id: "lesson-logical-verbal-reasoning-truth-tables-propositional-logic"
title: "Truth Tables and Propositional Logic"
summary: "Build and read truth tables for negation, conjunction, disjunction, conditionals, and combined logical statements."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
estimatedMinutes: 11
isActive: true
---

## Core Concept

**Propositional logic** studies statements that are either true or false. A **proposition** is a statement with one truth value, true or false.

A **truth table** lists all possible truth values for the propositions in a logical statement. It shows the truth value of the full statement for each case.

**not** (negation, symbol $\neg$) flips a statement's truth value. If $P$ is true, $\neg P$ is false. If $P$ is false, $\neg P$ is true.

**and** (conjunction, symbol $\land$) is true only when both statements are true. So $P \land Q$ is false if either statement is false.

**or** (disjunction, symbol $\lor$) is true when at least one statement is true. This includes the case where both statements are true. It is false only when both statements are false.

**if...then** (conditional, symbol $\rightarrow$) is written as $P \rightarrow Q$ and read as "if $P$, then $Q$." It is false only when $P$ is true and $Q$ is false.

Think of a conditional as a promise: if $P$ happens, then $Q$ happens. The promise is broken only when $P$ happens but $Q$ does not. If $P$ is false, the conditional is true no matter whether $Q$ is true or false.

For a combined expression, work inside parentheses first. Then evaluate the connective outside the parentheses.

**Evaluate** means find the final truth value.

## Examples

### #1: Building an AND Truth Table

Build the complete truth table for $P \land Q$.

**Solution:**
1. List all four possible pairs of truth values: $(T,T)$, $(T,F)$, $(F,T)$, and $(F,F)$.
2. Use the rule for and. The result is true only when both values are true.
3. Evaluate each pair: $T \land T=T$, $T \land F=F$, $F \land T=F$, and $F \land F=F$.

These four results give the complete truth table for $P \land Q$.

### #2: Evaluating a Negation

If $P$ is false, what is the truth value of $\neg P$?

**Solution:**

Negation flips the truth value. Since $P$ is false, $\neg P$ is true.

### #3: Evaluating an OR Statement

If $P$ is false and $Q$ is true, what is the truth value of $P \lor Q$?

**Solution:**

Or is true when at least one statement is true. Since $Q$ is true, $P \lor Q$ is true.

### #4: Evaluating a Conditional Statement

If $P$ is false and $Q$ is false, what is the truth value of $P \rightarrow Q$?

**Solution:**

A conditional is false only when $P$ is true and $Q$ is false. Here, $P$ is false, so $P \rightarrow Q$ is true.

### #5: Combining Connectives

If $P$ is true, $Q$ is false, and $R$ is true, evaluate $(P \land Q) \lor R$.

**Solution:**
1. Evaluate the expression inside the parentheses first: $T \land F=F$.
2. Replace $P \land Q$ with its truth value, then evaluate the or statement: $F \lor T=T$.

The full expression is true.

## Speed Tricks & Shortcuts

For and, one false value is enough to make the result false. For or, one true value is enough to make the result true.

For a conditional, remember the one false case: a true if-part followed by a false then-part. Every other pair gives a true conditional.

For combined expressions, solve inside parentheses first. Then work outward until you reach the final truth value.

## Traps to Watch For

### #1: Treating a Conditional Like Everyday Speech

> $P \rightarrow Q$ is false only when $P$ is true and $Q$ is false.

Formal logic always gives a conditional a truth value. If $P$ is false, the conditional is true, so choosing false just because the condition did not happen is an error.

### #2: Mixing Up AND and OR

> And needs both statements to be true. Or needs at least one statement to be true.

A question may tempt you to use the and rule for an or statement, or the or rule for an and statement. That can turn a true result into a false one, or a false result into a true one.

### #3: Ignoring Parentheses

> Evaluate the expression inside parentheses before combining it with the rest.

Changing the grouping can change the answer. For $P=F$, $Q=T$, and $R=T$, $(P \land Q) \lor R$ is true, but $P \land (Q \lor R)$ is false.
