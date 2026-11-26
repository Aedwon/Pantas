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

In "If $P$, then $Q$," $P$ is the **condition** (after *if*) and $Q$ is the **result** (after *then*).

**Affirming the consequent** flips the rule backward:

1. If $P$, then $Q$.
2. $Q$ is true (result confirmed).
3. Therefore, $P$ is true.

This form is **invalid**, because $Q$ can happen from another cause.

Test: "If a card is valid ($P$), entry is allowed ($Q$)."

- Suppose a visitor has an **invalid card, entry allowed** (for example, a guard signed them in).
- This obeys the rule, because the rule only promises entry for valid cards. It does not ban every other way in.
- Seeing "entry allowed" ($Q$) does not prove the card is valid ($P$).

:::pair #confirm-result-trap
Right: "If a student studies hard, they pass; Maria passed; therefore she studied hard" is **Invalid: result confirmed**
Wrong: call it **Valid: condition confirmed**
Passing is the result ($Q$), not the condition ($P$) after *if*. Confirming $Q$ runs the arrow backward and fails.
:::

:::check
"If a student lives in Baguio, they live in Luzon. Ana lives in Luzon. Therefore, Ana lives in Baguio." Is this argument valid?
:::answer
The answer is **no (invalid)**. Living in Luzon is the result ($Q$); Ana could live in another city in Luzon, such as Manila or Clark.
:::

### Denying the Antecedent

**Denying the antecedent** cancels the condition and assumes the result cancels too:

1. If $P$, then $Q$.
2. Not $P$ (condition denied).
3. Therefore, not $Q$.

This form is **invalid**, because $Q$ can still happen another way when $P$ does not happen.

Test: "If it rains ($P$), the ground gets wet ($Q$). It did not rain (not $P$). Therefore, the ground is not wet (not $Q$)."

- Premise $1$ does not say rain is the *only* cause of wet ground.
- Someone could water the lawn with a hose, leaving the ground wet with no rain.
- Verdict: the argument is **invalid**.

:::why
Why does "not $Q \to$ not $P$" work while "not $P \to$ not $Q$" fails? Picture $P$ as one door into room $Q$. If room $Q$ is empty (not $Q$), nobody walked through door $P$ (not $P$). If nobody used door $P$ (not $P$), someone could still enter through another door.
:::

:::pair #deny-condition-trap
Right: "If it rains, the ground gets wet; it did not rain; therefore the ground is not wet" is **Invalid: condition denied**
Wrong: call it **Valid: result denied**, or say a premise was contradicted
Premise $2$ denies *rain* (the condition after *if*), not *wet ground* (the result), leaving another cause open. Also accept "it did not rain" as a given premise when testing validity instead of treating it as contradicting Premise $1$.
:::

:::check
"If a store has a sale, the line is long. Today there is no sale. Therefore, the line is not long." Is this argument valid?
:::answer
The answer is **no (invalid)**. Denying the condition ("no sale") leaves other causes open, such as a holiday rush.
:::

## Examples

### #1: Affirming the Consequent

If a student studies hard, they will pass the exam. Maria passed the exam. Therefore, Maria studied hard. Is the argument valid?

<!-- ILLUSTRATION: a circle labeled Students who study hard inside a larger circle labeled Students who pass, with Maria shown in the larger circle but outside the smaller circle -->

**Solution:**

1. Rule: Studies hard ($P$) $\to$ Passes ($Q$).
2. Premise $2$ ("Maria passed") confirms the result $Q$, not $P$.
3. Maria could pass for another reason, such as prior knowledge.
4. Confirming $Q$ does not force $P$, so the argument is **invalid**.

**Check:** In the diagram, Maria sits inside *Students who pass* yet outside *Students who study hard*.

### #2: Denying the Antecedent

If Leo takes the bus, he will arrive by noon. Leo did not take the bus. Therefore, Leo will not arrive by noon. Is the argument valid?

**Solution:**

1. Rule: Takes the bus ($P$) $\to$ Arrives by noon ($Q$).
2. Premise $2$ ("did not take the bus") denies the condition $P$ (not $P$).
3. Leo could walk or take a train and still arrive by noon.
4. Denying $P$ does not force not $Q$, so the argument is **invalid**.

**Check:** Test the case "Leo took a train and arrived by noon": both premises hold (no bus ride broke the bus rule, and he did not take the bus), while the conclusion ("will not arrive by noon") fails.

### #3: Finding a Counterexample

Given "If a pass is stamped, boarding is allowed," which situation obeys the rule while showing allowed boarding does not guarantee a stamped pass?

- Option $1$: Stamped pass, boarding allowed
- Option $2$: Unstamped pass, boarding forbidden
- Option $3$: Stamped pass, boarding forbidden
- Option $4$: Unstamped pass, boarding allowed

**Solution:**

1. Drop Option $3$: a stamped pass with forbidden boarding breaks the original rule.
2. Drop Option $1$: it has a stamped pass, so it cannot show boarding allowed *without* a stamped pass.
3. Drop Option $2$: boarding is forbidden there, so it cannot show boarding allowed without a stamped pass.

:::try
Finish the last step: check the remaining option and explain why it obeys the rule while breaking the reverse claim.
:::answer
The answer is **Option $4$: Unstamped pass, boarding allowed**. Because the pass is unstamped, the rule makes no promise, while showing allowed boarding without a stamped pass.

**Check:** In Option $4$, the unstamped pass leaves "if stamped, then allowed" unbroken (true), while allowing boarding with an unstamped pass breaks "if allowed, then stamped" (false).
:::

## Speed Tricks & Shortcuts

**Test validity before truth.** Pretend the premises are true and look for one everyday exception where the conclusion fails. Check real-world truth only afterward.

## Traps to Watch For

:::checklist
- Result $Q$ confirmed ($Q \to P$): invalid (affirming the consequent), since $Q$ can have another cause. {#confirm-result-trap}
- Condition $P$ denied (not $P \to$ not $Q$): invalid (denying the antecedent), since $Q$ can happen another way. {#deny-condition-trap}
:::
