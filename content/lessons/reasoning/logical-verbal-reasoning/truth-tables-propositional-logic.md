---
_id: "lesson-logical-verbal-reasoning-truth-tables-propositional-logic"
title: "Truth Tables and Propositional Logic"
summary: "Read and make truth tables for negation, conjunction, disjunction, conditionals, and combined statements."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
estimatedMinutes: 11
isActive: true
---

## Core Concept

**Propositional logic** studies statements that are either true or false. A **proposition** is a statement with one truth value, true or false. Letters such as $P$, $Q$, and $R$ stand for propositions.

A **truth table** lists all possible truth values for the propositions in a logical statement. It shows the truth value of the full statement for each case. We use $T$ for true and $F$ for false.

To make a truth table, first list every possible set of truth values. For $P$ and $Q$, the pairs are $(T,T)$, $(T,F)$, $(F,T)$, and $(F,F)$. Then find the full statement's truth value for each pair.

A **connective** joins statements or changes a statement's truth value. The following symbols show which rule to use.

**Not** (negation, symbol $\neg$) flips a statement's truth value. If $P$ is true, $\neg P$ is false. If $P$ is false, $\neg P$ is true.

**And** (conjunction, symbol $\land$) is true only when both statements are true. So $P \land Q$ is false if either statement is false.

**Or** (disjunction, symbol $\lor$) is true when at least one statement is true. This includes the case where both statements are true. It is false only when both statements are false.

**If...then** (conditional, symbol $\rightarrow$) is written as $P \rightarrow Q$. Read it as "if $P$, then $Q$." It is false only when $P$ is true and $Q$ is false.

Think of a conditional as a promise: if $P$ happens, then $Q$ happens. The promise is broken only when $P$ happens but $Q$ does not. If $P$ is false, the conditional is true whether $Q$ is true or false.

**Evaluate** means find the final truth value. For a combined expression, work inside parentheses first. Then use the rule for the connective outside the parentheses.

If a part begins with $\neg$, flip that part's truth value before joining it to another part. Parentheses show how much of the expression the negation changes. For example, $\neg(P \land Q)$ flips the result of the whole and statement.

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

### #2: Evaluating a Negation

If $P$ is false, what is the truth value of $\neg P$?

**Solution:**

Negation flips false to true.

$$\neg F=T$$

So $\neg P$ is true.

### #3: Evaluating an Or Statement

If $P$ is false and $Q$ is true, what is the truth value of $P \lor Q$?

**Solution:**

Or is true when at least one statement is true.

$$F \lor T=T$$

Since $Q$ is true, $P \lor Q$ is true.

### #4: Evaluating a Conditional Statement

If $P$ is false and $Q$ is false, what is the truth value of $P \rightarrow Q$?

**Solution:**

A conditional is false only when its if-part is true and its then-part is false. Here, the if-part is false.

$$F \rightarrow F=T$$

So $P \rightarrow Q$ is true.

### #5: Finding the False Conditional Case

If $P$ is true and $Q$ is false, what is the truth value of $P \rightarrow Q$?

**Solution:**

The if-part is true, but the then-part is false. This is the only pair that makes a conditional false.

$$T \rightarrow F=F$$

### #6: Combining Connectives

If $P$ is true, $Q$ is false, and $R$ is true, evaluate $(P \land Q) \lor R$.

**Solution:**

1. Find the value inside the parentheses first.

$$T \land F=F$$

2. Replace $P \land Q$ with its truth value. Then use the or rule.

$$F \lor T=T$$

The full expression is true.

### #7: Negating a Grouped Statement

If $P$ is true and $Q$ is false, evaluate $\neg(P \land Q)$.

**Solution:**

1. Find the value of the and statement inside the parentheses.

$$T \land F=F$$

2. Negate that result.

$$\neg F=T$$

The full expression is true. The negation changes the result of the grouped statement.

## Speed Tricks & Shortcuts

For and, one false value is enough to make the result false. For or, one true value is enough to make the result true. Once you know that value, you do not need to check the other statement.

For a conditional, check for the one false case: a true if-part followed by a false then-part. Every other pair gives a true conditional.

These shortcuts apply to the statements joined by that connective. In a combined expression, find any inner values needed to use the outer rule. If a negation applies to the whole result, flip that result at the end.

## Traps to Watch For

### #1: Treating a Conditional Like Everyday Speech

> $P \rightarrow Q$ is false only when $P$ is true and $Q$ is false.

Formal logic gives a conditional a truth value even when its if-part is false. In that case, the conditional is true. Do not choose false just because the condition did not happen.

### #2: Mixing Up And and Or

> And needs both statements to be true. Or needs at least one statement to be true.

Using the and rule for an or statement can give a false answer when one statement is true. Using the or rule for an and statement can give a true answer when one statement is false. Check the symbol before choosing a rule.

### #3: Ignoring Parentheses

> Find the value inside parentheses before combining it with the rest.

Changing the grouping can change the answer. For $P=F$, $Q=T$, and $R=T$, $(P \land Q) \lor R$ is true. But $P \land (Q \lor R)$ is false.

### #4: Flipping the Wrong Part

> A negation before parentheses changes the value of the whole group.

In $\neg(P \land Q)$, find the and result, then flip it. Flipping only $P$ would answer a different question. Follow the parentheses to see what the negation covers.
