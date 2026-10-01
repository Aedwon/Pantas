# Question explanations, wrong-choice notes and the question audit

Date: 1 October 2026.

## The rule

> "okay let's change that
> 1. it explains why the correct answer is correct (maybe a solution or something if solving is involved)
> 2. (Pro gated) if they got it right, it should explain why other choices are distractors and they might get tricked [this is only upon request by the user]
> 3. (Pro gated) if they answered wrong, it should first explain how to get the right answer, and then explain that their choice was a distractor, and upon request they can show why other choices are wrong similar to #2
>
> so like this is a system to increase the value of using Pro."

Lead additions, all accepted ("yes the shared explanation should only say why the correct answer
is correct and its solution", "yes", "yes exactly"):

1. The shared explanation (Free and Pro) no longer discusses any wrong choice; that moved to the
   Pro notes. Existing explanations are reworked to match.
2. Every wrong-choice note has a fixed shape: the mistake it catches, why it looks right, one
   check to avoid it next time.
3. What a Free student sees beside a miss beyond the explanation (for example a Pro teaser) is a
   design decision for Claude Design.

> "yes please do the necessary changes even to the guidelines to ensure future question
> generations follow this consistently"

**Before:** the explanation said why the answer is right and why the main distractor is wrong;
Pro saw the note for the picked choice only after a miss (quiz-tab decision, 28 July, "Add why
yours was wrong"). The style guide had no rule for the notes; 27 wrong choices lacked one.

**Unchanged:** Free sees the answer and the explanation everywhere, including the mock review
(28 July).

**Changed in this commit:** `AGENTS.md` voice rules, `docs/content/question-style-guide.md`
(explanation, required wrong-choice note and its shape, notes written to read both to the student
who picked it and in a list, no position-dependent choices because the app shuffles, ids never
renumbered, at least 20 active questions per lesson), the authoring runbook step 4, a note on each
subject blueprint, and the UI brief's Free and Pro rows for the answer reveal and review screens.
The app's reveal still shows only the picked choice's note after a miss; the on-request list of
every note is built with the UI round from Aedwon's Claude Design screens.

## Question audit and expansion

> "can you please have codex do a thorough quality audit on all the questions in the entire
> corpus? then as have it add more questions per lesson ... can we do like at least 20 per lesson?"

> "you don't need to audit its output, once codex confirms it's done then just report to me that
> it's done"

> "you may invoke codex 6.1 Sol High for this, you can run things in parallel but make sure they
> don't touch each other's work. you can run 3 at a time"

State at the start (seed on `web/roadmap-engine-r1`): 2,361 active questions, 161 active lessons,
average 14.7 per lesson, 155 lessons under 20. The three CSE vocabulary lessons (two placeholder
questions, no lesson link) are a separately scoped exam and are left out. About 1,030 questions
passed an earlier QA round (r1), mostly Mathematics and Language; this pass covers all.

Execution: Codex edits the question YAML on a content branch cut from `web/roadmap-engine-r1`,
three subject groups at a time, each in its own directory, and the importer then requires a note
on every wrong choice. Per Aedwon, the lead does not review Codex's output.

Release consequence: the protected content package (`assets/seed/content.db`, manifest,
signature) must be rebuilt and re-signed with the content signing key after this lands, so the
E09 package hashes change. Phone checks already wait for the UI connection.
