# Question audit

**10 August 2026.** The first mechanical pass over `content/questions`. The
existing sweeps read `content/lessons` only; **2,369 questions across 158 files had
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

---

# The tier pass, 13 August 2026

**A different question from the ones above: does the corpus support the Free
and Pro split at all?** Nothing had asked it.

## The finding: Pro bought nothing at the answer reveal

The reveal has two notes. **Note A** is the question's explanation and both
tiers see it. **Note B** is written on the choice the student actually picked,
it appears only on a miss, and it is the whole of what Pro adds there.

**Not one question in the corpus had a note B.** All 2,369 of them. The screen
that draws it has been built since the quiz tab landed, and the pipeline threw
the field away anyway: the importer, both exporters and the content schema all
stopped at the choice's text and whether it was correct.

**So a paying student saw exactly what a free one saw, on every question.**

Fixed on the code side the same day: the column, the parser, both readers, all
three writers, and a test that follows one note from the YAML through the seed
database to the shipping repo.

## The second finding: the free note was already doing note B's job

**42 explanations named the options**, and 23 of those named them by letter.

The letters are a live defect, not only a tier one. **The app reshuffles choices
per student**, so "Choice B changes the grouping" points at whatever happens to
sit second on that student's screen.

All 23 are fixed. Each lettered paragraph became a rationale on the choice it
was about, rewritten to address the student who picked it. That is 69 notes, and
the free explanation still explains the correct answer in full.

## Where note B stands now

| Subject | Questions | With note B |
|---|---|---|
| General Information | 156 | **all** |
| Reading Comprehension | 192 | **all** |
| Language Proficiency | 319 | **all** |
| Reasoning | 244 | **all** |
| Science | 777 | 47 of 51 files |
| Mathematics | 713 | 30 of 46 files |

**6,162 choices carry note B, on 2,049 questions of 2,361.** 304 are left,
all in the last 16 Mathematics files and the last 4 Science ones.
`python3 tools/audit/note_b_todo.py` prints them and the line to run.

**The rate, measured rather than guessed:** one dispatched run authored a
subject of 12 files in a single window; another managed two files of harder
material. Expect roughly 90 to 460 notes per run depending on how mechanical the
subject is.

**One note in twenty had a wrong claim** in the run I read line by line: it said
a distractor halved a value it had doubled. The sweeps cannot catch that. **Read
them before merging.**

## Two questions that ask the same thing

Found by a dispatched run and confirmed by hand:

- `duties-and-prohibited-acts-0015` repeats `-0003`: both ask for the 45 working
  days on an annual performance report.
- `environmental-concepts-0005` repeats `-0003`: both answer Environmental
  Compliance Certificate.

`tools/audit/sweep_near_duplicates.py` now looks for this across the corpus. It
reports 53, and **most are false positives by design**: truth tables and
subject-verb drills share their wording on purpose. Read them, dismiss the
drills, keep the prose ones.

## The six lesson blockers were already fixed

Verified against the corpus on 13 August: all four "underlined" cases now say
"in bold" and the words are bold, and both Mathematics examples list their
choices. **The reports above were stale, not the corpus.** They are marked
resolved in place.


---

## The distractor-length attempt that was thrown away, 13 August

**A run fixed 129 of the 193 flagged Science questions and none of it was
kept.** It lengthened the wrong answers with adverbs rather than with content:

> "Yes: the time variable formally does not actually mathematically affect the
> final calculated power value in any given physical situation."

**A padded option is a louder tell than a long one.** The plan had banned this in
writing and the run did it anyway, which is the argument for a machine check
rather than a rule. `tools/audit/sweep_padded_choices.py` now flags any choice
carrying three or more hedge words.

**So all 403 are still flagged.** The plan is amended: a lengthened distractor
has to carry an idea a student actually believes, and if you cannot name that
belief, the distractor stays short and goes in the report.

---

## The answer-key check, 13 August

**The first mechanical check in this repository that can find a wrong answer
key.** Whether an answer is right is a judgment call, but whether a question
*contradicts itself* is not: if the explanation works through to one value and a
different choice carries the tick, one of the two is wrong.

`tools/audit/sweep_answer_key.py`. Three tests: the explanation naming a wrong
choice and never the right one, two choices that say the same thing, and an
explanation that never repeats its own answer.

### What it took to make it honest

**Five passes, and every early one lied.** It reported ninety broken keys, then
sixty-five, then thirty-two, and each batch was the checker's fault:

- `5` matched inside `15`.
- A full stop ending a sentence blocked a match, so "making it a pronoun." did
  not contain "pronoun".
- Then the same for numbers, so "all real numbers except $x = 5$." did not
  contain itself.
- Stripping apostrophes made "Its" and "Its'" the same choice, in the three
  questions whose entire subject is that apostrophe.
- Lowercasing made "We visited manila" and "we visited Manila" the same choice,
  in a capitalization question.

**Read a finding before you believe it.** That is the lesson, and it is why the
remaining six are listed here rather than fixed.

### What it found that was real

**Two reading-comprehension questions where the correct answer was the only
numeral on screen.** "33 billion pesos" among "Twenty-six billion pesos" and
"Fifty billion pesos". A student picks the odd one out without reading the
passage. Both now spell the number out, like their distractors.

### The six it still reports, all judged and none defects

- Four Mathematics questions whose answer is written one way in the choice and
  another in the explanation: "$x = 4$ or $x = -4$" against "Roots are $x = 4$
  and $x = -4$". The key is right; the wording differs.
- One Science question where the explanation says "Ribosomes" and the choice
  says "Ribosome".
- One naming question that explains the rule instead of repeating the name.

**The 1,077 `polish` lines are explanations that never repeat their own answer**,
which is normal for a well-written explanation and is why they are polish.
