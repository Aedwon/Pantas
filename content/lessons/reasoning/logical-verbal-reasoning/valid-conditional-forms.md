---
_id: "lesson-logical-verbal-reasoning-valid-conditional-forms"
title: "Valid Conditional Forms"
summary: "Use modus ponens and modus tollens."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 2
partCount: 3
ordering: 2
keyPoints:
  - "Use modus ponens and modus tollens."
  - "Follow a conditional chain."
  - "Use disjunctive syllogism."
---

## Core Concept

### Modus Ponens and Modus Tollens

Let $P$, $Q$, and $R$ stand for whole statements. **"If $P$, then $Q$"** ($P \to Q$), also worded "$Q$ if $P$," says that when **condition** $P$ holds, **result** $Q$ holds. **Evaluate** means judge what follows. This lesson covers the valid forms built on if-then and either-or statements.

Two conditional forms are valid:

- **Modus ponens** (confirming condition): If $P$, then $Q$; $P$; so $Q$.
- **Modus tollens** (denying result): If $P$, then $Q$; not $Q$; so not $P$.

Find what follows in each argument:

- Modus ponens: "If metal is heated ($P$), it expands ($Q$). This bar was heated ($P$). So it expanded ($Q$)."
- Modus tollens: "If a shape is a triangle ($P$), it has $3$ sides ($Q$). This shape lacks $3$ sides (not $Q$). So it is not a triangle (not $P$)."

:::why
Why does "not $Q$" force "not $P$"? If $P$ were true, the rule guarantees $Q$ would be true. Since $Q$ is false, $P$ cannot be true.
:::

:::pair #real-world-doubt
Right: "If the pump works under these conditions, it fills the tank; the tank stayed empty; therefore the pump was not working under those conditions" is **Valid: result denied**
Wrong: call it **Invalid: another cause is possible**, imagining a working pump that leaves the tank empty because of a leak
While testing validity, treat each stated rule as strict. Do not add outside exceptions.
:::

:::check
The gate accepts a ticket if it is stamped. This ticket was not accepted. What must be true about it?
:::answer
The answer is **This ticket is not stamped.** "The gate accepts a ticket if it is stamped" means "if stamped ($P$), accepted ($Q$)." Not accepted is not $Q$, so modus tollens gives not $P$.
:::

### Conditional Chains

A **conditional chain** links rules forward: if $P \to Q$ and $Q \to R$, then $P \to R$.

Modus tollens also runs backward: if not $R$, then not $Q$, so not $P$.

Find what follows from two linked rules:

- Rule $1$: If a parcel is scanned ($P$), arrival is logged ($Q$).
- Rule $2$: If logged ($Q$), receipt is acknowledged ($R$).
- Forward ($P \to R$): **A scanned parcel is acknowledged.**
- Backward, step $1$: not acknowledged (not $R$) means not logged (not $Q$).
- Backward, step $2$: not logged (not $Q$) means not scanned (not $P$).

:::pair #reverse-chain
Right: from $P \to Q \to R$, conclude **a scanned parcel is acknowledged** ($P \to R$)
Wrong: conclude **every acknowledged parcel was scanned** ($R \to P$)
The rule $P \to R$ does not give $R \to P$. To work backward, deny the result to rule out its condition.
:::

### Disjunctive Syllogism

A **disjunctive syllogism** starts with "either-or" and rules out one side:

1. Either $P$ or $Q$.
2. Not $P$.
3. Therefore, $Q$.

Even if "or" allows both options to hold, ruling out one still forces the other.

Find where the key is: "The key is in Desk $1$ ($P$) or Desk $2$ ($Q$). It is not in Desk $1$ (not $P$). So it is **in Desk $2$ ($Q$)**."

:::pair #rule-out-both
Right: if the original document is in the cabinet or the vault, and not in the cabinet, **the original document is in the vault**
Wrong: conclude **the original document is in neither place**
"Or" guarantees at least one option holds. Ruling out one forces the other.
:::

## Examples

### #1: Modus Ponens

Decide whether this argument is valid: "If a permit is approved, the office sends a notice. The permit was approved. Therefore, the office sent a notice."

**Solution:**

1. Rule: Approved ($P$) $\to$ Notice sent ($Q$).
2. Premise $2$ confirms $P$.
3. By modus ponens, $Q$ follows. The argument is **valid**.

### #2: Modus Tollens

Decide whether this argument is valid: "If the alarm is working under these conditions, it rings during a fire. It did not ring during the fire. Therefore, it was not working under those conditions."

<!-- ILLUSTRATION: a circle labeled Alarms working under these conditions inside a larger circle labeled Alarms that ring during a fire, with the tested alarm shown outside the larger circle -->

**Solution:**

1. Rule: Working ($P$) $\to$ Rings ($Q$).
2. Premise $2$ denies $Q$ (did not ring).
3. By modus tollens, not $P$ follows. The argument is **valid**.

### #3: Disjunctive Syllogism

Decide whether this argument is valid: "Either the document is in Cabinet A or in Cabinet B. It is not in Cabinet A. Therefore, it is in Cabinet B."

<!-- ILLUSTRATION: two overlapping circles labeled Cabinet A and Cabinet B, with the Cabinet A region crossed out and a document icon placed in Cabinet B -->

**Solution:**

1. Premise $1$: Cabinet A ($P$) or Cabinet B ($Q$).
2. Premise $2$: not Cabinet A (not $P$).
3. By disjunctive syllogism, Cabinet B ($Q$) follows. The argument is **valid**.

### #4: Conditional Chain

Find what must follow: "If records are complete, the application is reviewed. If reviewed, a decision is sent. The application was not reviewed."

**Solution:**

1. Chain: Complete ($P$) $\to$ Reviewed ($Q$) $\to$ Decision sent ($R$).
2. Fact: Reviewed ($Q$) is false.

:::try
Finish the last step: decide what the fact forces about $P$ and about $R$.
:::answer
The answer is **The records are not complete.** Not $Q$ forces not $P$. Nothing is forced about $R$.
:::

## Speed Tricks & Shortcuts

**Follow each rule forward, or work backward by denying its result.** Write $P \to Q \to R$. Jump forward from $P$, or backward from *not $R$*.

## Traps to Watch For

:::checklist
- Strict if-then rule: use it as given, with no outside doubts. {#real-world-doubt}
- Chain $P \to Q \to R$: go forward from $P$, or backward from *not $R$*. Do not flip it to $R \to P$. {#reverse-chain}
- Either-or with one side ruled out: the other side holds. {#rule-out-both}
:::
