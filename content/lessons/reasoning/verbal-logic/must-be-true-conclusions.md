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

**Infer** means draw a conclusion forced by the given premises. **Must be true** means no case can obey every premise while making the conclusion false. Never add outside guesses.

Watch what a one-way rule states:

- **One required step:** Passing an ethics exam is *one* required condition, and Maria passed. She met that ethics-exam requirement, not necessarily *every* requirement or final hiring.
- **Conditional promise:** Promising a bonus to completers does not prove anyone can complete it.
- **Observed result:** "If heavy rain, move indoors" plus "moved indoors" does not prove heavy rain occurred, since another cause could move it indoors.

:::pair #one-requirement-to-all
Right: from one required condition met, conclude **Maria has met the ethics-exam requirement.**
Wrong: Maria has met every hiring requirement.
Passing one required exam finishes only that single requirement, not unmentioned hiring steps. Stick strictly to what the premise covers.
:::

:::check
"If the fire alarm sounds, everyone leaves the building. The fire alarm sounded at $10$ a.m." Must everyone have left the building?
:::answer
The answer is **yes**. The rule runs from the alarm to leaving, and the alarm did sound, so the result follows.
:::

### Reading "All" Without Reversing It

**All** or **every** applies to $100\%$ of the named group, yet says nothing about anyone outside that group and never runs backward:

- "All supervisors hold a master's degree" plus "Elena is not a supervisor" leaves Elena's degree status undetermined.
- Watch exact cutoffs: "above $80\%$" excludes $80\%$ itself and says nothing about $79\%$.

:::why
Why does "All $A$ are $B$" tell us nothing outside $A$? Picture $A$ inside a larger group $B$. Someone outside $A$ could sit in the outer part of $B$ or completely outside $B$. Both obey the rule.
:::

:::pair #reverse-or-deny-rule
Right: from "All department supervisors must hold a master's degree" and "Elena is not a department supervisor," conclude **Elena's degree status is undetermined.**
Wrong: Elena definitely lacks a master's degree.
Being outside the supervisor group does not deny the degree. The rule places no limit on non-supervisors.
:::

:::check
"All riders taller than $120$ cm are let in. Rico is $130$ cm." Must a rider exactly $120$ cm be allowed in?
:::answer
The answer is **no**. The rule covers heights strictly *above* $120$ cm, leaving $120$ cm outside the guarantee.
:::

### Reading "Some" Without Adding Exceptions

In formal logic, **some** means *at least one*, which allows *all*.

- **"Some $A$ are $B$"** forces **"Some $B$ are $A$"** (the shared member belongs to both).
- It **never** forces "Some $A$ are not $B$" or "All $B$ are $A$."

What follows: "Some inspectors are certified auditors."

1. At least $1$ person is both inspector and certified auditor.
2. That proves **Some auditors are inspectors.**
3. Every inspector could be an auditor, so "some inspectors are not auditors" is not forced.

:::pair #some-means-some-not
Right: from "Some inspectors are certified auditors," conclude **Some auditors are inspectors.**
Wrong: Some inspectors are not auditors.
Everyday speech hints "only some," yet logic's *some* allows *all*. Never add an unstated exception.
:::

:::check
"Some books on the top shelf are dictionaries." Must at least one book on the top shelf not be a dictionary?
:::answer
The answer is **no**. *Some* means at least one, so every book on that shelf could be a dictionary.
:::

## Examples

### #1: Following an "Only" Rule

An agency permits only licensed engineers to approve building plans. Mark approved Project A in full compliance with that rule. Which conclusion follows?

(A) Every licensed engineer approved Project A.
(B) Mark owns the building in Project A.
(C) Mark is a licensed engineer.

**Solution:**

1. Read "only licensed engineers": valid approver $\to$ licensed engineer.
2. Mark validly approved Project A.
3. Drop (A): eligibility does not force every other engineer to approve.
4. Drop (B): ownership is unstated.
5. Choose **(C)**: Mark must be a licensed engineer.

**Check:** If Mark were not a licensed engineer, his approval would break the compliance premise.

### #2: Combining a Cutoff with a Score

Statement: "All candidates who score above $80\%$ pass the exam. Juan scored $85\%$." What is certain?

**Solution:**

1. Rule: score $> 80\% \to$ pass.
2. Check Juan: $85\% > 80\%$, so Juan meets the cutoff.
3. Conclusion: **Juan passed the examination.**

**Check:** Plugging Juan's $85\%$ into "score $> 80\% \to$ pass" satisfies the rule directly ($85 > 80$), proving he passed.

### #3: Combining "Every" and "Some"

Every specimen in an exhibit tray is cataloged. Some specimens in the tray are shells. What must also be true?

(A) Some cataloged shells are not in the exhibit tray.

(B) At least one specimen in the tray is not a shell.

(C) Some cataloged specimens are shells.

**Solution:**

1. Premise $1$: every specimen in the tray is cataloged.
2. Premise $2$: at least $1$ specimen in the tray is a shell.
3. Drop (B): *some* allows all specimens in the tray to be shells.

:::try
Finish the last step: compare (A) and (C) against the two premises.
:::answer
The answer is **(C) Some cataloged specimens are shells.** Since that shell sits in the tray, Premise $1$ forces it to be cataloged too, giving at least one cataloged shell. Choice (A) names shells outside the tray, which the premises never mention.

**Check:** Picture a tray holding only cataloged shells, with nothing cataloged elsewhere: both premises hold, (A) and (B) fail, and (C) holds.
:::

## Speed Tricks & Shortcuts

**Try to break the choice.** Keep every premise true and try to picture one simple counter-case where the choice fails.

## Traps to Watch For

:::checklist
- One stated requirement met: conclude only that step, never all requirements. {#one-requirement-to-all}
- Outside an *all* group (or after the result): leave status undetermined. {#reverse-or-deny-rule}
- Seeing *some*: read it as *at least one* (allowing *all*), never *some not*. {#some-means-some-not}
:::
