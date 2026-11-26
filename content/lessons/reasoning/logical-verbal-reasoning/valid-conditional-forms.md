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

Let $P$, $Q$, and $R$ stand for whole statements. **"If $P$, then $Q$"** ($P \to Q$) means whenever **condition** $P$ happens, **result** $Q$ happens. **Evaluate** means judge what follows from the premises.

Two conditional forms are valid:

- **Modus ponens** (confirming condition): If $P$, then $Q$; $P$; so $Q$.
- **Modus tollens** (denying result): If $P$, then $Q$; not $Q$; so not $P$.

Examples:

- Modus ponens: "If metal is heated ($P$), it expands ($Q$). This bar was heated ($P$). So it expanded ($Q$)."
- Modus tollens: "If a shape is a triangle ($P$), it has $3$ sides ($Q$). This shape lacks $3$ sides (not $Q$). So it is not a triangle (not $P$)."

:::why
Why does "not $Q$" force "not $P$"? If $P$ were true, the rule guarantees $Q$ would be true. Since $Q$ is false, $P$ cannot be true.
:::

:::pair #real-world-doubt
Right: under "If the alarm works under these conditions, it rings during a fire; it did not ring," conclude **Valid: result denied**
Wrong: call it **Invalid: another cause is possible** because real alarms fail
Treat every stated rule as strict while testing validity. Do not add outside exceptions.
:::

:::check
If a card is red, it goes in Box $1$. This card is not in Box $1$. What must be true?
:::answer
The answer is **This card is not red.** By modus tollens, denying the result ($Q$) forces denying the condition ($P$).
:::

### Conditional Chains

A **conditional chain** links rules forward: if $P \to Q$ and $Q \to R$, then $P \to R$.

Modus tollens also runs backward: if not $R$, then not $Q$, so not $P$.

Trace two links:

- Rule $1$: If a parcel is scanned ($P$), arrival is logged ($Q$).
- Rule $2$: If logged ($Q$), receipt is acknowledged ($R$).
- Forward ($P \to R$): **A scanned parcel is acknowledged.**
- Backward (not $R \to$ not $P$): Not acknowledged means not logged, so not scanned.

:::pair #reverse-chain
Right: from $P \to Q \to R$, conclude **a scanned parcel is acknowledged** ($P \to R$)
Wrong: conclude **every acknowledged parcel was scanned** ($R \to P$)
Arrows point one way only. Never flip $P \to R$ to $R \to P$.
:::

:::check
If it rains, the road gets wet. If the road gets wet, traffic slows. Traffic did not slow. What must be true?
:::answer
The answer is **The road did not get wet, and it did not rain.** Modus tollens steps backward through both links.
:::

### Disjunctive Syllogism

A **disjunctive syllogism** starts with "either-or" and rules out one side:

1. Either $P$ or $Q$.
2. Not $P$.
3. Therefore, $Q$.

Even if "or" allows both options to hold, ruling out one still forces the other.

Trace: "The key is in Desk $1$ ($P$) or Desk $2$ ($Q$). Not in Desk $1$ (not $P$). So **in Desk $2$ ($Q$)**."

:::pair #rule-out-both
Right: if a file is in the cabinet or the vault, and not in the cabinet, **the original is in the vault**
Wrong: conclude **the original is in neither place**
"Or" guarantees at least one option holds. Ruling out one forces the other.
:::

:::check
Either the meeting is on Monday or on Tuesday. It is not on Tuesday. What must be true?
:::answer
The answer is **The meeting is on Monday.** Ruling out Tuesday leaves Monday as the remaining option.
:::

## Examples

### #1: Modus Ponens

If a permit is approved, the office sends a notice. The permit was approved. Therefore, the office sent a notice. Is the argument valid?

**Solution:**

1. Rule: Approved ($P$) $\to$ Notice sent ($Q$).
2. Premise $2$ confirms $P$.
3. By modus ponens, $Q$ follows. The argument is **valid**.

**Check:** Confirming $P$ moves forward along the arrow to $Q$.

### #2: Modus Tollens

If the alarm is working under these conditions, it rings during a fire. It did not ring during the fire. Therefore, it was not working under those conditions. Evaluate this argument.

<!-- ILLUSTRATION: a circle labeled Alarms working properly under these conditions inside a larger circle labeled Alarms that ring during a fire, with the tested alarm shown outside the larger circle -->

**Solution:**

1. Rule: Working ($P$) $\to$ Rings ($Q$).
2. Premise $2$ denies $Q$ (did not ring).
3. By modus tollens, not $P$ follows. The argument is **valid**.

**Check:** Sitting outside the outer *Rings* circle forces sitting outside the inner *Working* circle.

### #3: Disjunctive Syllogism

Either the document is in Cabinet A or in Cabinet B. It is not in Cabinet A. Therefore, it is in Cabinet B. Is the argument valid?

<!-- ILLUSTRATION: two overlapping circles labeled Cabinet A and Cabinet B, with the Cabinet A region crossed out and a document icon placed in Cabinet B -->

**Solution:**

1. Premise $1$: Cabinet A ($P$) or Cabinet B ($Q$).
2. Premise $2$: not Cabinet A (not $P$).
3. By disjunctive syllogism, Cabinet B ($Q$) follows. The argument is **valid**.

**Check:** Crossing out Cabinet A leaves only Cabinet B.

### #4: Conditional Chain

If records are complete, the application is reviewed. If reviewed, a decision is sent. The records are complete. What must follow?

**Solution:**

1. Chain: Complete ($P$) $\to$ Reviewed ($Q$) $\to$ Decision sent ($R$).
2. Fact: Complete ($P$) is true.

:::try
Finish the last step: follow the arrows from $P$ through $Q$ to state what follows.
:::answer
The answer is **A decision is sent.** $P$ forces $Q$, and $Q$ forces $R$.

**Check:** Arrows run from $P$ to $R$, never backward from $R$ to $P$.
:::

## Speed Tricks & Shortcuts

**Follow arrows one way.** Write $P \to Q \to R$. Jump forward from $P$, or backward with "not" from *not $R$*.

## Traps to Watch For

:::checklist
- A strict "if-then" premise: accept it as given without adding real-world doubts. {#real-world-doubt}
- Chain $P \to Q \to R$: move forward from $P$, or backward with "not" from *not $R$*, never $R \to P$. {#reverse-chain}
- "Either $P$ or $Q$" with one ruled out: the remaining option is forced, never neither. {#rule-out-both}
:::
