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

**Not** (negation, symbol $\neg$) flips a statement's truth value. If $P$ is true, $\neg P$ is false. If $P$ is false, $\neg P$ is true.

**Evaluate** means find the final truth value. For a combined expression, work inside parentheses first. Then use the rule for the connective outside the parentheses.

If a part begins with $\neg$, flip that part's truth value before joining it to another part. Parentheses show how much of the expression the negation changes. For example, $\neg(P \land Q)$ flips the result of the whole and statement.

## Examples

### #1: Evaluating a Negation

If $P$ is false, what is the truth value of $\neg P$?

**Solution:**

Negation flips false to true.

$$\neg F=T$$

So $\neg P$ is true.

### #2: Combining Connectives

If $P$ is true, $Q$ is false, and $R$ is true, evaluate $(P \land Q) \lor R$.

**Solution:**

1. Find the value inside the parentheses first.

$$T \land F=F$$

2. Replace $P \land Q$ with its truth value. Then use the or rule.

$$F \lor T=T$$

The full expression is true.

### #3: Negating a Grouped Statement

If $P$ is true and $Q$ is false, evaluate $\neg(P \land Q)$.

**Solution:**

1. Find the value of the and statement inside the parentheses.

$$T \land F=F$$

2. Negate that result.

$$\neg F=T$$

The full expression is true. The negation changes the result of the grouped statement.

## Speed Tricks & Shortcuts

These shortcuts apply to the statements joined by that connective. In a combined expression, find any inner values needed to use the outer rule. If a negation applies to the whole result, flip that result at the end.

## Traps to Watch For

### #1: Ignoring Parentheses

> Find the value inside parentheses before combining it with the rest.

Changing the grouping can change the answer. For $P=F$, $Q=T$, and $R=T$, $(P \land Q) \lor R$ is true. But $P \land (Q \lor R)$ is false.

### #2: Flipping the Wrong Part

> A negation before parentheses changes the value of the whole group.

In $\neg(P \land Q)$, find the and result, then flip it. Flipping only $P$ would answer a different question. Follow the parentheses to see what the negation covers.
