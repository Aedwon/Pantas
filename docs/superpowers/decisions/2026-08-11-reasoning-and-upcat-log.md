# Reasoning leaves UPCAT

**11 August 2026.** Raised while writing the UPCAT blueprint, settled by
measurement rather than opinion.

## What was put to him

UP lists four UPCAT subtests: Language Proficiency, Reading Comprehension,
Science, Mathematics. The seed carries five, adding Reasoning.

**The content already agreed with UP.** Not one of Reasoning's 64 seeded
questions is tagged `exam_upcat`; they carry `exam_acet`, `exam_ustet`,
`exam_dost_sei`, `exam_cse_pro` and `exam_cse_sub`.

**The cost of leaving it:** a UPCAT student's Study tab lists Reasoning with 3
topics and 14 lessons and **zero questions they can be asked**. They can read
all fourteen and never be quizzed once, and Performance shows the subject as
unmeasurable forever because there is nothing to measure.

| Option | Cost |
|---|---|
| **Drop it from UPCAT** | 14 lessons leave the UPCAT student's Study tab. They stay authored |
| Tag the 64 for UPCAT too | Puts questions on a paper UP does not say it tests |
| Leave it | A subject that can be read and never practised, and a permanent hole in Progress |

**Recommended: drop it.**

## What he chose

**Aedwon:** *"drop reasoning from upcat"*

## The consequence that has to be handled with it

**Dropping the subject from `tools/lesson_author/outline.json` would strand the
content, not relocate it.** Reasoning's **244 authored questions** are generated
into the seed today *because* the outline places them under UPCAT. Remove the
entry and both generators skip the whole folder, exactly as they already skip
General Information, and 244 questions join the 248 that reach no student.

**So this is two changes, not one:**

1. Reasoning stops being a UPCAT subject.
2. Reasoning's content moves to an exam that actually tests it. **CSE
   Professional is the only candidate that is active**, and the CSE tagging
   pass of 4 August already put `cse-pro` on much of this material.

**If step 2 is not done, do not do step 1.** Parking 244 questions to fix a
presentation problem is a worse trade than the problem.
