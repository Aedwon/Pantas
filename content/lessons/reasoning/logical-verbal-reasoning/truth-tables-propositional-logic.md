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

**Propositional logic** studies how simple TRUE/FALSE statements (called **propositions**) combine using logical CONNECTIVES. A **truth table** lists every possible combination of true (T) and false (F) values for the statements involved, showing the resulting truth value of the combined statement in each case.

**NOT** (negation, symbol $\neg$): flips a statement's truth value. If $P$ is true, $\neg P$ is false, and vice versa.

**AND** (conjunction, symbol $\land$): "$P \land Q$" is TRUE only when BOTH $P$ AND $Q$ are true. It is false in every other case.

**OR** (disjunction, symbol $\lor$): "$P \lor Q$" is TRUE when AT LEAST ONE of $P$ or $Q$ is true (including when both are true). It is false only when BOTH are false.

**IF...THEN** (conditional, symbol $\rightarrow$): "$P \rightarrow Q$" (read "if $P$ then $Q$") is FALSE only in the ONE case where $P$ is true but $Q$ is false. In every other case (including when $P$ is false), the conditional is considered TRUE.

<!-- ILLUSTRATION: four small truth tables side by side for NOT, AND, OR, and IF-THEN, each showing all combinations of T and F for P and Q with the resulting truth value in the final column -->

The conditional's truth table often surprises students: "$P \rightarrow Q$" is TRUE whenever $P$ is FALSE, no matter what $Q$ is. This reflects the idea that a conditional promise is only BROKEN when the condition happens ($P$ is true) but the promised result does not ($Q$ is false); if the condition never happens, the promise cannot be broken.

## Examples

### #1: Building an AND Truth Table

Build the complete truth table for "$P \land Q$."

**Solution:**
1. List all four possible combinations of $P$ and $Q$: (T,T), (T,F), (F,T), (F,F).
2. Apply the rule: AND is true only when BOTH are true.
3. (T,T) → TRUE. (T,F) → FALSE. (F,T) → FALSE. (F,F) → FALSE.

### #2: Evaluating an OR Statement

If $P$ is FALSE and $Q$ is TRUE, what is the truth value of "$P \lor Q$"?

**Solution:**
1. OR is true when AT LEAST ONE of the two statements is true.
2. Here, $Q$ is true (even though $P$ is false).
3. "$P \lor Q$" is TRUE.

### #3: Evaluating a Conditional Statement

If $P$ is FALSE and $Q$ is FALSE, what is the truth value of "$P \rightarrow Q$"?

**Solution:**
1. The conditional "$P \rightarrow Q$" is FALSE only in the specific case where $P$ is true and $Q$ is false.
2. Here, $P$ is FALSE, so this specific "broken promise" case does not apply.
3. "$P \rightarrow Q$" is TRUE (since $P$ is false, the conditional is automatically considered true, regardless of $Q$'s value).

### #4: Combining Connectives

If $P$ is TRUE, $Q$ is FALSE, and $R$ is TRUE, evaluate "$(P \land Q) \lor R$."

**Solution:**
1. First evaluate the inner expression, "$P \land Q$": $P$ is true, $Q$ is false, so AND requires BOTH true — this is FALSE.
2. Now evaluate the full expression: "$(P \land Q) \lor R$" becomes "FALSE $\lor$ R," and $R$ is TRUE.
3. OR is true when at least one side is true, so the full expression is TRUE.

## Speed Tricks & Shortcuts

**Memorize each connective with ONE key phrase**: AND needs "both true" to be true; OR needs "at least one true" to be true; the conditional is "only false when the if-part is true but the then-part is false."

**For the conditional specifically, remember: "false leading anywhere is automatically true."** If the "if" part ($P$) is false, the whole conditional statement is true, no matter what the "then" part says.

**For combined expressions, always solve the INNERMOST parentheses first**, exactly like order of operations in math, then work outward to the final connective.

## Traps to Watch For

### #1: Assuming the Conditional Behaves Like Everyday "Because" Statements

> "$P \rightarrow Q$" is only FALSE in ONE specific case: $P$ TRUE and $Q$ FALSE. In every other combination, including when $P$ is FALSE, the conditional is considered TRUE.

Everyday intuition might suggest that "if $P$ is false, we can't say anything about the conditional," but formal propositional logic ALWAYS assigns a definite truth value (true, in this case) to a conditional whose "if" part is false.

### #2: Confusing AND and OR's True Cases

> AND requires BOTH statements to be true. OR requires only AT LEAST ONE to be true.

Mixing these up is one of the most common truth-table errors; anchor them by remembering AND is the STRICTER connective (harder to satisfy), while OR is more LENIENT (easier to satisfy).

### #3: Evaluating Combined Expressions in the Wrong Order

> Just like arithmetic order of operations, evaluate the innermost PARENTHESES first, then work outward to the connective joining the larger expression.

Evaluating "$(P \land Q) \lor R$" by mistakenly combining $Q$ and $R$ first (ignoring the parentheses grouping $P$ and $Q$ together) produces an incorrect final truth value.
