---
_id: "lesson-verbal-logic-negating-assumptions"
title: "Negating Assumptions"
summary: "Negate all, some, and no statements."
subject: "subject-reasoning"
topic: "topic-verbal-logic"
isActive: true
part: 2
partCount: 8
ordering: 2
keyPoints:
  - "Negate all, some, and no statements."
---

## Core Concept

### Negating All and No Statements

To **negate** a statement means stating exactly when it is false. A statement and its negation are never both true and never both false. This lesson covers statements with *all*, *no*, and *some*.

When a claim uses *all*, *every*, or *no*, one exception breaks it:

- **"All $A$ are $B$"** negates to **"At least one $A$ is not $B$."**
- **"No $A$ are $B$"** negates to **"At least one $A$ is $B$."**

Find the negation of: "Every locker on the second floor is locked."

1. The claim covers every second-floor locker.
2. One unlocked locker breaks it.
3. Exact negation: **At least one second-floor locker is not locked.**

:::why
Why stop at *at least one* instead of pushing to the far extreme? If half the group passes a test and half fails, both "none passed" and "all passed" are false. *At least one* covers every case where the claim fails.
:::

:::pair #all-to-none-overnegation
Right: the negation of "No temporary employee has access to the archive" is **At least one temporary employee has access.**
Wrong: Every temporary employee has access to the archive.
Pushing *no* to *every* goes too far. One temporary employee with access already breaks the rule.
:::

### Negating Some Statements

In formal logic, **some** means *at least one* ($1$, several, or even all).

- **"Some $A$ are $B$"** negates to **"No $A$ are $B$."**

Find the negation of: "Some stalls in the market sell eggs."

1. The claim holds if $1$ or more stalls sell eggs.
2. "Not all stalls sell eggs" still lets $1$ stall sell eggs, so it does not make the claim false.
3. Exact negation: **No stall in the market sells eggs.**

:::pair #some-to-not-all
Right: the negation of "Some branch offices can verify applications without contacting headquarters" is **No branch office can do so.**
Wrong: **Not all branch offices can do so.** or **Some branch offices cannot do so.**
Both wrong moves ("not all" and "some cannot") hold when Office $1$ can verify and Office $2$ cannot, leaving the original ("at least one can") true. Drop the count to zero.
:::

### Negating with Named Groups

Keep the starting group and property fixed. Never swap sides.

Find the negation of: "No parcel held at the sorting desk was marked as delivered."

1. Starting group: parcels **held at the sorting desk**.
2. Forbidden outcome: marked as **delivered**.
3. Exact negation: **A held parcel was marked as delivered.**

:::pair #flip-wrong-group
Right: the negation of "No sample rejected at intake was listed as accepted" is **A rejected sample was listed as accepted.**
Wrong: A sample accepted at intake was listed as rejected in the final log.
Swapping *rejected* and *accepted* checks the wrong starting group.
:::

:::check
Which is the negation of "Every Room 4 student passed the quiz"?

(A) At least one Room 4 student passed.

(B) At least one Room 5 student did not pass.

(C) At least one Room 4 student did not pass.
:::answer
The answer is **(C)**. *Every* negates to *at least one does not* for the same group. (A) stays true when all pass, and (B) switches to Room 5.
:::

## Examples

### #1: Negating an All Assumption

Find the negation of the assumption in this argument: "Every regional office must handle online forms. We can start today because all regional offices can process them."

(A) No regional office can process online forms.

(B) At least one regional office cannot process online forms.

(C) Some regional offices can process online forms.

**Solution:**

1. Spot the quantifier: *all* regional offices can process them.
2. Drop (A): *no* goes too far, since one failing office already breaks *all*.
3. Drop (C): "some can process forms" stays true when all can.
4. Choose **(B)**: one office unable to process forms breaks *all*.

### #2: Negating a Some Assumption

Find the finding that makes this assumption false. A team assumes, "Some evening-shift staff hold a first-aid certificate."

(A) Not every evening-shift staff member holds a certificate.

(B) At least one day-shift staff member holds a certificate.

(C) No evening-shift staff member holds a certificate.

**Solution:**

1. Read *some* as *at least one*.
2. Drop (A): "not every" still allows certified evening staff.
3. Drop (B): day-shift staff is the wrong group.
4. Choose **(C)**: zero certified evening staff breaks *some*.

### #3: Negating a Combined Rule

Find the exact negation (just enough to make the claim false). A teacher assumes every pupil who joined the field trip handed in at least one signed slip.

(A) No pupil who joined the field trip handed in a signed slip.

(B) A pupil who joined the field trip handed in only one signed slip.

(C) A pupil who joined the field trip handed in no signed slip.

**Solution:**

1. Outer quantifier: *every* pupil who joined the field trip.
2. Inner claim: *at least one* signed slip.
3. Drop (A): it says every pupil failed, but one pupil failing already breaks *every*.

:::try
Finish the last step: compare (B) and (C) to pick the exact negation.
:::answer
The answer is **(C) A pupil who joined the field trip handed in no signed slip.** Negating "at least one signed slip" for one pupil gives zero signed slips for that pupil. Choice (B) shows a pupil with one signed slip, which still meets "at least one."
:::

## Speed Tricks & Shortcuts

**Pair opposites.** *All* pairs with *at least one not*; *no* pairs with *at least one*; *some* pairs with *none*. Never jump between *all* and *no*.

## Traps to Watch For

:::checklist
- Negating *all* or *no*: stop at one exception (*at least one*), not the far extreme. {#all-to-none-overnegation}
- Negating *some*: drop the count to zero (*no*), not *not all*. {#some-to-not-all}
- Subject group and property: keep both fixed, no swapping sides. {#flip-wrong-group}
:::
