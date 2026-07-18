# Question audit

**10 August 2026.** The first mechanical pass over `content/questions`. The
existing sweeps read `content/lessons` only; **2,401 questions across 158 files had
never been swept by anything.**

Regenerate with `python3 tools/audit/run_all.py`. Findings land in
`sweep-results.tsv` beside this file.

---

## What this pass can and cannot say

**Mechanical only.** Every finding below is something a machine can be certain of:
a duplicate, a count, a length, a flag. **Whether an answer is right is a judgment
pass and is not attempted here.**

**A sample was read by hand, not the corpus.** Three questions were worked through
end to end: a jeepney fare, a work-energy calculation and a markup problem. All
three were correct, including the fare's round-up convention, which is how jeepney
fares actually work. **Three is not a claim about 2,369.**

---

## Headline: nothing enforces approval, and half the corpus already claims it

**1,259 questions carry `approved: true`.** They sit in 81 of the 158 files, and
the flag has been written by the generator since 20 July.

**Nothing reads it.** `grep -rn "approved"` finds no hit in the seed builder, the
importer, or anywhere in `lib/`. **A question reaches a student whether the flag is
there, absent, or false.**

So the launch checklist's "approve the 2,369 questions, every one with `approved:`
unset by design" is **wrong twice**: over half are already marked approved, and
approving the rest would change nothing about what ships.

**This is the one finding here that changes what to do next.** Either:

| | Cost |
|---|---|
| **Make the seed skip unapproved questions** | The seed shrinks to whatever has really been reviewed, and the review becomes a real gate. Some subjects may empty |
| **Drop the flag** | Honest about what is happening today, and the review becomes a process rather than a field |
| **Leave it** | The field reads as a record of review and is not one. **Worst of the three** |

**Recommended: the first.** A flag that gates nothing is worse than no flag, because
it will be believed.

---

## Important: the correct answer is often the longest by far

**403 questions**, 17% of the corpus, where the correct choice is more than half
again longer than the longest distractor. A student can pick the longest without
reading the question.

| Subject | Flagged | Of |
|---|---|---|
| Science | 193 | 777 |
| Language Proficiency | 104 | 319 |
| Reasoning | 82 | 244 |
| Mathematics | 24 | 713 |
| **Reading Comprehension** | **0** | 192 |
| **General Information** | **0** | 156 |

**Reading Comprehension is zero because it was already fixed**, in the revision pass
of 4 August that rewrote 120 questions for exactly this. **The remedy exists and was
applied to one subject.** Nothing has been done for the other four.

A worked example, from Modifiers:

> Correct: *"Covered in cheese is misplaced, making it sound like the customer is
> covered in cheese; it should read The waiter served the customer the pasta covered
> in cheese."* (150 characters)
>
> Distractors: *"There is no error in this sentence."*, *"Served should be changed to
> serves."*, *"The sentence needs a comma after 'pasta.'"* (30 to 40 characters)

The fix is to lengthen the distractors, not to shorten the answer: an explanation
that has to be short stops explaining.

---

## Important: 20 stems repeat word for word inside one subtopic

Grammar drill formats reuse their instruction and vary the sentences, so
*"Choose the sentence with no misplaced or dangling modifier"* appears twice in
Modifiers with different choices.

**Not wrong, and it is the same words on screen twice in one sitting.** Worth
varying the instruction where the drill is otherwise identical.

## Important: 15 questions carry five choices

All in `language-proficiency/language-application/error-identification.yaml`, where
the fifth is the "no error" option that error-identification formats traditionally
carry. **Probably deliberate.** Flagged because the rest of the corpus is four and
nothing says which is intended.

---

## Not defects, recorded so the next sweep does not re-raise them

- **The correct choice is authored first in 152 of 158 files.** It never reaches a
  student that way: `orderChoicesFor` reshuffles from the question id when the app
  reads a question, and scoring compares ids rather than positions. **It matters only
  if that ordering is ever removed.**
- **137 stems end without a question mark, colon or period.** Nearly all are drill
  instructions that read correctly. Left as polish.
- **"marks" appears in the corpus and is fine**: quotation marks, a store that marks
  up a price, hallmarks. The ban is on the score sense, and the sweep now tests for
  that rather than for the word.

---

## What an earlier version of this sweep got wrong

**Its first run reported 32 blockers that were its own fault.** Reading Comprehension
files carry a `passages:` block whose bodies indent exactly like a stem, so the
parser read passages as questions with no answer, no stem and no explanation.

Worth recording because the failure mode is general: **a sweep that does not
understand one file shape reports that shape as broken content**, and the numbers
look serious enough to act on.
