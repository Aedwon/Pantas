---
_id: "lesson-verbal-logic-must-be-true-conclusions"
title: "Must-Be-True Conclusions"
summary: "Draw only conclusions that must follow from the premises."
subject: "subject-reasoning"
topic: "topic-verbal-logic"
isActive: true
part: 4
partCount: 8
ordering: 4
keyPoints:
  - "Draw only conclusions that must follow from the premises."
  - "Read all and some without adding facts."
---

## Core Concept

### Reading One-Way Rules and Requirements

**Infer** means draw a conclusion forced by the given premises. **Must be true** means no case can obey every premise while making the conclusion false. Never add outside guesses. This lesson covers one-way rules, *all*, and *some*.

Watch what a one-way rule states:

- **One required step:** Passing a driving test is *one* condition for a license, and Lito passed. He met that requirement, not necessarily every one or the license itself.
- **Conditional promise:** Promising a free gift to buyers who spend over $500$ pesos does not prove anyone spends that much.
- **Observed result:** "If the road floods, the school closes" plus "the school closed" does not prove the road flooded, since another cause could close it.

:::pair #one-requirement-to-all
Right: from "Passing an ethics exam is one requirement for civil service" and "Maria passed it," conclude **Maria has met the ethics-exam requirement.**
Wrong: Maria has met every hiring requirement.
Passing one required exam finishes only that single requirement, not unmentioned hiring steps.
:::

### Reading "All" Without Reversing It

**All** or **every** applies to $100\%$ of the named group. It says nothing about whether someone outside the group has the property, and it does not run backward:

- "All bus drivers hold a license" plus "Ana is not a bus driver" leaves Ana's license status undetermined.
- Watch exact cutoffs: "All riders over $60$ ride free" does not cover a $60$-year-old and says nothing about a $59$-year-old.

:::why
Why does "All $A$ are $B$" tell us nothing outside $A$? Picture $A$ inside a larger group $B$. Someone outside $A$ could sit in the outer part of $B$ or completely outside $B$. Both obey the rule.
:::

:::pair #reverse-or-deny-rule
Right: from "All department supervisors must hold a master's degree" and "Elena is not a department supervisor," conclude **Elena's degree status is undetermined.**
Wrong: Elena definitely lacks a master's degree.
Being outside the supervisor group does not deny the degree. The rule places no limit on non-supervisors.
:::

:::check
"All guards at the gate wear a badge. Rico wears a badge." Which statement must be true?

(A) Rico is a guard at the gate.

(B) Rico is not a guard at the gate.

(C) Rico may or may not be a guard at the gate.
:::answer
The answer is **(C)**. The rule runs from guard to badge, not from badge to guard. A clerk or a visitor could also wear a badge.
:::

### Reading "Some" Without Adding Exceptions

In formal logic, **some** means *at least one*, which allows *all*.

- **"Some $A$ are $B$"** forces **"Some $B$ are $A$"** (the shared member belongs to both).
- It **never** forces "Some $A$ are not $B$" or "All $B$ are $A$."

Find what follows from: "Some drivers on this route are students."

1. At least $1$ person is both a driver on this route and a student.
2. That person shows **Some students are drivers on this route.**
3. Every driver could be a student, so "some drivers are not students" is not forced.

:::pair #some-means-some-not
Right: from "Some inspectors are certified auditors," conclude **Some auditors are inspectors.**
Wrong: Some inspectors are not auditors.
Everyday speech hints "only some," yet logic's *some* allows *all*. Never add an unstated exception.
:::

## Examples

### #1: Following an "Only" Rule

Find the conclusion that follows. Only science club members may borrow the lab microscope. Dina borrowed it within that rule.

(A) Every science club member borrowed the microscope.

(B) Dina owns a microscope.

(C) Dina is a science club member.

**Solution:**

1. Read "only club members": borrower $\to$ club member.
2. Dina borrowed it within the rule.
3. Drop (A): permission does not make every member borrow it.
4. Drop (B): ownership is never stated.
5. Choose **(C)**: if Dina were not a member, her borrowing would break the rule.

### #2: Combining a Cutoff with a Score

Find what is certain. Statement: "All pupils who score at least $75$ earn a certificate. Mia scored $75$."

**Solution:**

1. Rule: score $\ge 75 \to$ certificate.
2. Check Mia: $75 \ge 75$, so Mia meets the cutoff.
3. Conclusion: **Mia earned a certificate.**

### #3: Combining "Every" and "Some"

Find what must also be true. Every book on the cart is labeled. Some books on the cart are novels.

(A) Some labeled novels are not on the cart.

(B) At least one book on the cart is not a novel.

(C) Some labeled books are novels.

**Solution:**

1. Premise $1$: every book on the cart is labeled.
2. Premise $2$: at least $1$ book on the cart is a novel.
3. Drop (B): *some* allows every book on the cart to be a novel.

:::try
Finish the last step: compare (A) and (C) against the two premises.
:::answer
The answer is **(C) Some labeled books are novels.** That novel sits on the cart, so Premise $1$ labels it, giving at least one labeled novel. Choice (A) names novels off the cart, which the premises never mention.
:::

## Speed Tricks & Shortcuts

**Try to break the choice.** Keep every premise true and try to picture one simple counter-case where the choice fails.

## Traps to Watch For

:::checklist
- One stated requirement met: conclude only that step, never all requirements. {#one-requirement-to-all}
- Outside an *all* group (or after the result): leave status undetermined. {#reverse-or-deny-rule}
- Seeing *some*: read it as *at least one* (allowing *all*), never *some not*. {#some-means-some-not}
:::
