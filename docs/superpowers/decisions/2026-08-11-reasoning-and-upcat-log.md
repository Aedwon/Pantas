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

---

## Executed, later the same day

**Both parts landed together, as the entry above required.**

**What the coupling actually was.** `tools/lesson_author/outline.json` was doing
two jobs at once: defining UPCAT's subject list, and acting as the topic
registry for every authored question. A question whose topic slug the outline
did not carry was dropped by the export, which is why removing Reasoning from
the outline would have stranded its questions rather than moved them.

**The fix was to separate those jobs**, not to work around them. A subject now
declares which paper it sits on. Absent means UPCAT, which is what every entry
in the file meant before the field existed.

**So one change closed two open items:**

1. Reasoning moved to CSE Professional. UPCAT is down to the four subtests UP
   publishes, and a UPCAT student no longer sees 14 lessons they can never be
   quizzed on.
2. **General Information stopped being invisible.** Its 156 questions reach a
   student for the first time. This was UI-067, and it was the same defect
   wearing different clothes: authored content that no outline topic claimed.

**Measured, not estimated:**

| | Before | After |
|---|---|---|
| Questions in the shipped database | 2,000 | 2,216 |
| Lessons | 144 | 161 |
| Topics | 19 | 26 |

The six previously unmapped topics were General Information's four, Reasoning's
clerical ability and verbal logic, and mathematics' data interpretation.

### What I got wrong

**Two roundtrip tests asserted exit code 65 and listed the six topics as an
accepted gap.** I had read that as a deliberate guard. It was pinning the
defect: the export exits 65 precisely because it is dropping authored questions,
so the tests were holding the bug in place and would have failed if it were
fixed. They assert 0 and an empty set now, so a seventh unmapped topic turns the
build red instead of joining a list.

### The wart that stays, deliberately

Subject and topic ids still read `subj_upcat_*` and `topic_upcat_*`, including
for subjects that are no longer on UPCAT. **`track_scope_local` stores topic
ids**: a student who has hidden a topic carries that id on their device, so
renaming would silently un-hide it. The prefix is now just a namespace. Renaming
is its own migration, not a side effect of this.

### Found on the way, and still open

**`exam_dost_sei` has no exam row.** 1,160 question-to-exam rows point at it and
84 authored question files tag it. No student is affected today because there is
no DOST-SEI exam to select, but the tags dangle. **Which exams the app offers is
Aedwon's call**, so this is recorded rather than fixed.
