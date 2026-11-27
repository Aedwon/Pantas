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

To **negate** a statement means stating when it is false. Both cannot be true or both false.

When a claim uses *all*, *every*, or *no*, one exception breaks it:

- **"All $A$ are $B$"** negates to **"At least one $A$ is not $B$."**
- **"No $A$ are $B$"** negates to **"At least one $A$ is $B$."**

Negate: "No temporary employee has access to the archive."

1. The rule bars every temporary employee.
2. One with access breaks it.
3. Exact negation: **At least one temporary employee has access.**

:::why
Why stop at *at least one* instead of pushing *no* all the way to *every*? If half the temporary staff have access and half do not, both "none have access" and "every one has access" are false. *At least one* covers every case where the rule fails.
:::

:::pair #all-to-none-overnegation
Right: the negation of "No temporary employee has access to the archive" is **At least one temporary employee has access.**
Wrong: Every temporary employee has access to the archive.
Pushing *no* to *every* goes too far. One temporary employee with access already breaks the rule.
:::

:::check
"Every jar in the exhibit has a readable label." What minimum finding disproves this?
:::answer
The answer is **At least one jar does not have a readable label.** An *every* claim fails as soon as one jar fails the test (whether its label is unreadable or missing).
:::

### Negating Some Statements

In formal logic, **some** means *at least one* ($1$, several, or even all).

- **"Some $A$ are $B$"** negates to **"No $A$ are $B$."**

Negate: "Some branch offices can verify applications without contacting headquarters."

1. Holds if $1$ or more branch offices can verify.
2. "Not all" still lets $1$ verify.
3. Exact negation: **No branch office can do so.**

:::pair #some-to-not-all
Right: the negation of "Some branch offices can verify applications without contacting headquarters" is **No branch office can do so.**
Wrong: **Not all branch offices can do so.** or **Some branch offices cannot do so.**
Both wrong moves ("not all" and "some cannot") hold when Office $1$ can verify and Office $2$ cannot, leaving the original ("at least one can") true. Drop the count to zero.
:::

:::check
A treasurer assumes, "At least one receipt in the folder lacks a signature." Which finding makes that false?
:::answer
The answer is **Every receipt in the folder is signed.** Zero unsigned receipts makes "at least one lacks a signature" false.
:::

### Negating with Named Groups

Keep the starting group and property fixed. Never swap sides.

Negate: "No sample rejected at intake was listed as accepted in the final log."

1. Starting group: samples **rejected at intake**.
2. Forbidden outcome: listed as **accepted** in the final log.
3. Exact negation: **A rejected sample was listed as accepted.**

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

Argument: "Every regional office must handle online forms. We can start today because all regional offices can process them." Which statement negates that assumption?

(A) No regional office can process online forms.

(B) At least one regional office cannot process online forms.

(C) Some regional offices can process online forms.

**Solution:**

1. Spot the quantifier: *all* regional offices.
2. Drop (A): *no* goes too far when part fails.
3. Drop (C): *some* holds alongside *all*.
4. Choose **(B)**: one office unable to process forms breaks *all*.

**Check:** Under (B), that office cannot handle its own forms today, so the reason for starting today fails.

### #2: Negating a Some Assumption

A team assumes, "Some evening-shift staff hold a first-aid certificate." Which finding makes that false?

(A) Not every evening-shift staff member holds a certificate.

(B) At least one day-shift staff member holds a certificate.

(C) No evening-shift staff member holds a certificate.

**Solution:**

1. Read *some* as *at least one*.
2. Drop (A): "not every" still allows certified evening staff.
3. Drop (B): day-shift staff is the wrong group.
4. Choose **(C)**: zero certified evening staff breaks *some*.

**Check:** Choice (C) keeps the exact group (*evening-shift staff*) and drops the count to zero.

### #3: Negating a Combined Rule

A records officer assumes every form returned by a class adviser contained at least one parent signature. Which finding is the exact logical negation of that assumption (just enough to make it false)?

(A) A parent left some returned forms unsigned even though another parent signed each one.

(B) An adviser returned a form with only one parent signature.

(C) An adviser returned a form with no parent signature.

**Solution:**

1. Outer quantifier: *every* form returned by a class adviser.
2. Ask what one finding would make that *every* claim false.
3. Drop (A): another parent still signed each form.

:::try
Finish the last step: compare (B) and (C) to pick the exact negation.
:::answer
The answer is **(C) An adviser returned a form with no parent signature.** Negating "at least one signature" on one returned form gives zero parent signatures on that form. Choice (B) shows a form with one signature, which still meets "at least one."

**Check:** One form from the named group ("returned by a class adviser") with zero parent signatures breaks the *every* rule.
:::

## Speed Tricks & Shortcuts

**Pair opposites.** *All* pairs with *at least one not*; *no* pairs with *at least one*. Never jump between *all* and *no*.

## Traps to Watch For

:::checklist
- Negating *all* or *no*: stop at one exception (*at least one*) instead of jumping to the far extreme. {#all-to-none-overnegation}
- Negating *some*: drop the count to zero (*no*), never *not all*. {#some-to-not-all}
- Subject group and property: keep both fixed without swapping sides. {#flip-wrong-group}
:::
