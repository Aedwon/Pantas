---
_id: "lesson-logical-verbal-reasoning-truth-tables-propositional-logic"
title: "Truth Tables and Propositional Logic"
summary: "Learn how to build and read truth tables for logical connectives like AND, OR, NOT, and IF...THEN."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
estimatedMinutes: 11
isActive: true
---
## Core Concept

**Propositional logic** studies how simple true/false statements (called **propositions**) combine using logical connectives. A **truth table** lists every possible combination of true (T) and false (F) values for the statements involved, showing the resulting truth value of the combined statement in each case.

**not** (negation, symbol $\neg$): flips a statement's truth value. If $P$ is true, $\neg P$ is false, and vice versa.

**and** (conjunction, symbol $\land$): "$P \land Q$" is true only when both $P$ and $Q$ are true. It is false in every other case.

**or** (disjunction, symbol $\lor$): "$P \lor Q$" is true when at least one of $P$ or $Q$ is true (including when both are true). It is false only when both are false.

**if...then** (conditional, symbol $\rightarrow$): "$P \rightarrow Q$" (read "if $P$ then $Q$") is false only in the one case where $P$ is true but $Q$ is false. In every other case (including when $P$ is false), the conditional is considered true.

| $P$ | $Q$ | NOT ($\neg P$) | AND ($P \land Q$) | OR ($P \lor Q$) | IF...THEN ($P \rightarrow Q$) |
| --- | --- | --- | --- | --- | --- |
| T | T | F | T | T | T |
| T | F | F | F | T | F |
| F | T | T | F | T | T |
| F | F | T | F | F | T |

The conditional's truth table often surprises students: "$P \rightarrow Q$" is true whenever $P$ is false, no matter what $Q$ is. This reflects the idea that a conditional promise is only broken when the condition happens ($P$ is true) but the promised result does not ($Q$ is false); if the condition never happens, the promise cannot be broken.

## Examples

### #1: Building an AND Truth Table

Build the complete truth table for "$P \land Q$."

**Solution:**
1. List all four possible combinations of $P$ and $Q$: (T,T), (T,F), (F,T), (F,F).
2. Apply the rule: And is true only when both are true.
3. (T,T) → true. (T,F) → false. (F,T) → false. (F,F) → false.

### #2: Evaluating an OR Statement

If $P$ is false and $Q$ is true, what is the truth value of "$P \lor Q$"?

**Solution:**
1. Or is true when at least one of the two statements is true.
2. Here, $Q$ is true (even though $P$ is false).
3. "$P \lor Q$" is true.

### #3: Evaluating a Conditional Statement

If $P$ is false and $Q$ is false, what is the truth value of "$P \rightarrow Q$"?

**Solution:**
1. The conditional "$P \rightarrow Q$" is false only in the specific case where $P$ is true and $Q$ is false.
2. Here, $P$ is false, so this specific "broken promise" case does not apply.
3. "$P \rightarrow Q$" is true (since $P$ is false, the conditional is automatically considered true, regardless of $Q$'s value).

### #4: Combining Connectives

If $P$ is true, $Q$ is false, and $R$ is true, evaluate "$(P \land Q) \lor R$."

**Solution:**
1. First evaluate the inner expression, "$P \land Q$": $P$ is true, $Q$ is false, so and requires both true. This is false.
2. Now evaluate the full expression: "$(P \land Q) \lor R$" becomes "false $\lor$ R," and $R$ is true.
3. Or is true when at least one side is true, so the full expression is true.

## Speed Tricks & Shortcuts

**Memorize each connective with one key phrase**: And needs "both true" to be true; or needs "at least one true" to be true; the conditional is "only false when the if-part is true but the then-part is false."

**For the conditional specifically, remember: "false leading anywhere is automatically true."** If the "if" part ($P$) is false, the whole conditional statement is true, no matter what the "then" part says.

**For combined expressions, always solve the innermost parentheses first**, exactly like order of operations in math, then work outward to the final connective.

## Traps to Watch For

### #1: Assuming the Conditional Behaves Like Everyday "Because" Statements

> "$P \rightarrow Q$" is only false in one specific case: $P$ true and $Q$ false. In every other combination, including when $P$ is false, the conditional is considered true.

Everyday intuition might suggest that "if $P$ is false, we can't say anything about the conditional," but formal propositional logic always assigns a definite truth value (true, in this case) to a conditional whose "if" part is false.

### #2: Confusing AND and OR's True Cases

> And requires both statements to be true. Or requires only at least one to be true.

Mixing these up is one of the most common truth-table errors; anchor them by remembering and is the stricter connective (harder to satisfy), while or is more lenient (easier to satisfy).

### #3: Evaluating Combined Expressions in the Wrong Order

> Just like arithmetic order of operations, evaluate the innermost parentheses first, then work outward to the connective joining the larger expression.

Evaluating "$(P \land Q) \lor R$" by mistakenly combining $Q$ and $R$ first (ignoring the parentheses grouping $P$ and $Q$ together) produces an incorrect final truth value.
