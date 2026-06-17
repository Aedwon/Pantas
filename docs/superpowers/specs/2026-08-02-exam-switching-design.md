# Switching exams, and whether earlier work counts

**Date:** 2 August 2026
**Status:** Approved by Aedwon
**Decision log:** `docs/superpowers/decisions/2026-08-02-onboarding-name-and-date-log.md`
**Amends:** `2026-07-25-onboarding-polish.md` Task 4, `2026-07-30-progress-tab-design.md`
**Depends on:** the Settings → Exam page, which Task 4 of the polish plan builds

---

## Problem

A large number of students sit more than one exam. A DOST Scholarship taker very often
also sits UPCAT. Today the app has no answer for this: `selected_exam_id` is a single
device preference, the Settings screen that would change it was never built, and nothing
decides what happens to the work already done.

## What already works, established from the code rather than assumed

Two of the three things you would expect to migrate do not need migrating.

- **`review_state_local` is keyed by `questionId` alone.** There is no exam column, so
  every piece of FSRS scheduling built while studying DOST already applies to UPCAT.
- **`Questions.examIdsJson` is a list.** A question can already belong to DOST and UPCAT
  simultaneously, in the content model as it stands.

What is genuinely exam-scoped: `selected_exam_id`, `assessment_results_local` keyed by
`examId`, and `attempts_local.examId`, which records the context an attempt happened in.

**So there is nothing to copy or move.** This spec is about what the figures count, not
about relocating data.

## Scope

Switching from one exam to another, and whether work done under the previous exam counts
toward the new one.

**Explicitly out of scope: studying two exams at once.** See Deferred.

---

## Section 1: One exam at a time

Aedwon's reasoning, and it settles the shape: **focus, and mock fidelity.** A mock has to
feel like sitting the actual exam, and a paper assembled from two exams' blueprints is not
any exam anyone sits.

So switching is a replacement, not an addition. There is one selected exam, always.

---

## Section 2: Nothing is deleted, ever

Switching from DOST to UPCAT leaves the DOST assessment, every DOST attempt and all FSRS
state exactly where they are. Switching back in January costs nothing and loses nothing.

**This is the third time this rule has been set today**, after the custom track's subject
narrowing and the flag table. It is the same rule and it should read as one: **Pantas
filters, it does not purge.**

---

## Section 3: The mock cooldown does not reset

**A switch must not grant a new mock.** Otherwise a Free user moves DOST to UPCAT and back
whenever they want another paper, which is the same hole the custom track's mocks had.

The cooldown is computed per student, from the most recent terminal `submittedAt`, and it
is unaffected by which exam is selected. The Quiz spec's tier table reads "One every 14
days per track"; **"per track" is corrected here to per student**, because per track is
the exploit.

---

## Section 4: Carried-over progress

### It is a filter, not a migration

Nothing is copied. The attempts exist with their original `examId`, and the question is
only whether the new exam's figures count them. **So the choice is reversible, instantly
and losslessly**, which is why it can be offered as a prompt and then left in Settings.

**"Migrate" never appears in the UI.** It is engineer-speak, it sounds irreversible, and
it sounds dangerous. The word is "carry over".

### What counts as carryable

An attempt counts toward the new exam only if **the question it was on lists the new exam
in `examIdsJson`**. Work on a question that is not in the new exam's pool is never counted
under any setting. No new storage: the join already exists.

### The prompt, shown on switch

> **You're not starting from zero**
>
> 412 of the questions you've answered are also on UPCAT. We'll count them toward your
> UPCAT progress so you can pick up where you are, not where you started.
>
> [ Count them ]
> Start my numbers fresh
>
> Either way, we'll keep scheduling your reviews around what you already know.

The count is measured from the student's own attempts, so it is a figure the app is
permitted to print under Section 1 of `2026-07-30-progress-tab-design.md`.

**Default is to count them.** It is the truthful position: knowledge does not reset
because a student changed what they are applying for, and FSRS has always behaved this way
without complaint.

### The Settings row

On the Settings → Exam page:

> **Carry over progress**
> Answers from your other exams count toward this one.        [ on ]

Changeable at any time. A student who chose "start fresh" in November and regrets it in
January flips one switch.

### The scoreboard, not the schedule

**The choice governs figures and history. It never governs scheduling.**

| Surface | Respects the choice |
|---|---|
| Progress figures and tables | yes |
| Home stats band | yes |
| Weakest areas | yes |
| Today's session, and every due date | **no** |
| The flagged list | no, flags are question-level and not exam-scoped |

If "start fresh" reset FSRS, the app would re-ask 412 questions the student demonstrably
knows. Nobody wants that, including the person who just tapped it. They asked for clean
numbers, not for the work again.

**This produces one coherent but surprising state**, and it is why the prompt states the
rule rather than letting it be discovered: with "start fresh" on, Progress can report 0
answered while today's session serves questions that are not due for months.

---

## Section 5: The assessment after a switch

`assessment_results_local` is keyed by `examId`, which is correct: a UPCAT assessment is
not a DOST assessment, because the topic mix differs.

So after switching, the new exam has no assessment, and the Quiz tab's session panel shows
its "no assessment taken" state as specified in `2026-07-28-quiz-tab-design.md` Section 1.
**This is right and needs no special case.** The student is being asked to establish where
they stand on the new exam's material, which is a different question from the old one.

Carried-over progress does not substitute for it and does not suppress the prompt.

---

## Section 6: Amendments to other specs

1. **`2026-07-25-onboarding-polish.md` Task 4** builds the Settings → Exam page. It gains
   the switch prompt and the "Carry over progress" row.
2. **`2026-07-28-quiz-tab-design.md`** tier table: "One every 14 days per track" becomes
   per student, per Section 3.
3. **`2026-07-30-progress-tab-design.md`.** Every figure on the tab is filtered by the
   carry-over setting. The tab gains no new control; the switch lives in Settings.

---

## Deferred, with reasons

- **Studying two exams at once.** A student sitting DOST and UPCAT four weeks apart wants
  two live dates and two countdowns. It collides with nearly every central assumption in
  the app: Home's single countdown, Progress's single exam, the session's single topic
  queue, and the custom track's single track. It is a change to the idea that a student
  has one exam, and it deserves its own session rather than a subsection here. Aedwon
  chose one at a time deliberately, for focus and mock fidelity, so this is a considered
  deferral and not an oversight.
- **Merging two assessments.** Only meaningful if two exams are live at once.

## Open

Nothing.

## Verification

- Switching exams deletes nothing, verified by switching back and finding the old
  assessment intact.
- Switching does not make a mock available to a Free user inside 14 days.
- With carry-over off, Progress reports zero while today's session still respects existing
  due dates.
- An attempt on a question not listing the new exam in `examIdsJson` is never counted,
  under either setting.
- The word "migrate" appears in no user-facing string.
