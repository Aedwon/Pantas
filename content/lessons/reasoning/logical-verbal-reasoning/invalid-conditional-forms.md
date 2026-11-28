---
_id: "lesson-logical-verbal-reasoning-invalid-conditional-forms"
title: "Invalid Conditional Forms"
summary: "Recognize affirming the consequent."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 3
partCount: 3
ordering: 3
keyPoints:
  - "Recognize affirming the consequent."
  - "Recognize denying the antecedent."
---

## Core Concept

### Affirming the Consequent

In "If $P$, then $Q$," $P$ is the **condition** (after *if*) and $Q$ is the **result** (after *then*). A form is **invalid** when its premises can be true while its conclusion is false. This lesson covers two invalid forms.

**Affirming the consequent** flips the rule backward:

1. If $P$, then $Q$.
2. $Q$ is true (result confirmed).
3. Therefore, $P$ is true.

This form is invalid, because $Q$ can have another cause.

Decide whether allowed entry proves a valid card. Rule: "If a card is valid ($P$), entry is allowed ($Q$)."

- Suppose a visitor has an **invalid card, entry allowed** (a guard signed them in).
- This obeys the rule, which promises entry for valid cards without banning other ways in.
- Seeing "entry allowed" ($Q$) does not prove a valid card ($P$), so the argument is **invalid**.

:::pair #confirm-result-trap
Right: "If a driver speeds, the driver gets a ticket; Ana got a ticket; therefore she sped" is **Invalid: result confirmed**
Wrong: call it **Valid: condition confirmed**
A ticket is the result ($Q$), not the condition ($P$) after *if*. Confirming $Q$ runs the arrow backward and fails.
:::

### Denying the Antecedent

**Denying the antecedent** cancels the condition and assumes the result cancels too:

1. If $P$, then $Q$.
2. Not $P$ (condition denied).
3. Therefore, not $Q$.

This form is invalid, because $Q$ can still happen another way when $P$ does not happen.

Decide whether "it did not rain" proves the ground is not wet. Rule: "If it rains ($P$), the ground gets wet ($Q$)."

- Premise $1$ does not say rain is the *only* cause of wet ground.
- A hose can wet the ground with no rain.
- Verdict: **invalid**.

:::why
Why does "not $Q \to$ not $P$" work while "not $P \to$ not $Q$" fails? Take the rule "If someone uses door $P$, the entry log lists them." A name missing from the log (not $Q$) means that person did not use door $P$ (not $P$). But someone who skipped door $P$ (not $P$) can still be in the log, because they signed in at another door.
:::

:::pair #deny-condition-trap
Right: "If it rains, the ground gets wet; it did not rain; therefore the ground is not wet" is **Invalid: condition denied**
Wrong: call it **Valid: result denied**, or reject the given fact "it did not rain" as a contradicted premise
Premise $2$ denies *rain* (the condition), not *wet ground* (the result), so another cause stays open. Accept both premises as given; the verdict comes from the form.
:::

:::check
"If a clinic is open, its door is unlocked. The door is locked. Therefore, the clinic is not open." Is this argument valid?
:::answer
The answer is **yes (valid)**. This denies the result ($Q$), not the condition. An open clinic would have an unlocked door, so a locked door rules it out.
:::

## Examples

### #1: Affirming the Consequent

Decide whether this argument is valid: "If a student studies hard, they will pass the exam. Maria passed the exam. Therefore, Maria studied hard."

<!-- ILLUSTRATION: a circle labeled Students who study hard inside a larger circle labeled Students who pass, with Maria shown in the larger circle but outside the smaller circle -->

**Solution:**

1. Rule: Studies hard ($P$) $\to$ Passes ($Q$).
2. Premise $2$ ("Maria passed") confirms the result $Q$, not $P$.
3. Maria could pass for another reason, such as prior knowledge.
4. Confirming $Q$ does not force $P$, so the argument is **invalid**.

### #2: Denying the Antecedent

Decide whether this argument is valid: "If Leo takes the bus, he will arrive by noon. Leo did not take the bus. Therefore, Leo will not arrive by noon."

**Solution:**

1. Rule: Takes the bus ($P$) $\to$ Arrives by noon ($Q$).
2. Premise $2$ ("did not take the bus") denies the condition $P$ (not $P$).
3. Leo could walk or take a train and still arrive by noon.
4. Denying $P$ does not force not $Q$, so the argument is **invalid**.

### #3: Finding a Counterexample

Find the case that obeys the rule yet breaks the guard's claim. Rule: "If a pass is stamped ($P$), boarding is allowed ($Q$)." The guard claims "Everyone allowed to board has a stamped pass," which runs the rule backward: $Q \to P$.

- Option $1$: Stamped pass, boarding allowed
- Option $2$: Unstamped pass, boarding forbidden
- Option $3$: Stamped pass, boarding forbidden
- Option $4$: Unstamped pass, boarding allowed

**Solution:**

1. Drop Option $3$: a stamped pass with forbidden boarding breaks the original rule.
2. Drop Option $1$: boarding is allowed and the pass is stamped, so the claim holds.

:::try
Finish the last step: test Options $2$ and $4$ and pick the answer.
:::answer
The answer is **Option $4$: Unstamped pass, boarding allowed**. Option $2$ forbids boarding, so the claim says nothing about it. In Option $4$ boarding is allowed ($Q$) without a stamp (not $P$), which breaks $Q \to P$ and still obeys the rule.
:::

## Speed Tricks & Shortcuts

**Test validity before truth.** Find one case where every premise is true and the conclusion is false. Check real-world truth only afterward.

## Traps to Watch For

:::checklist
- Result $Q$ confirmed, so $P$: invalid, since $Q$ can have another cause. {#confirm-result-trap}
- Condition $P$ denied, so not $Q$: invalid, since $Q$ can happen another way. {#deny-condition-trap}
:::
