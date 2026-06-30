# Reading Comprehension Question Generation, Content Plan

> **How to work this plan.** One subtopic at a time, in order. Write the passage, then its
> questions, then validate. Never batch several subtopics before validating.
>
> **Required reading before row 1:** `SUBAGENTS.md` Part 4, `AGENTS.md`,
> `docs/content/question-blueprints/reading-comprehension.md`, and
> `docs/superpowers/specs/2026-08-03-passage-based-questions-design.md`.
>
> **Follow the plan. Do not redesign.** If a lesson named in a row does not exist, or the
> validator rejects something its message does not explain, **stop and say so**.

**Goal:** Author, validate and commit passages and questions for all 13 Reading Comprehension
subtopics across Comprehension Skills and Text Types.

**Why this plan exists.** Reading comprehension was deferred out of
`2026-07-20-question-generation-language-proficiency.md` to "its own future plan", which was
never written. Aedwon ruled on 3 August that **v1 ships with reading comprehension.** All
three topics sit at zero questions today.

**Source lessons already exist:** 13 files under `content/lessons/reading-comprehension/`,
verified 3 August.

---

## BLOCKED until the pipeline lands

**Do not start this plan until `docs/superpowers/plans/2026-08-03-passage-pipeline.md` has
been executed and merged.**

Nothing in this project models a passage today. The importer accepts a stem, choices, an
explanation and a figure, and it will reject a `passages:` block outright. The pipeline plan
adds the table, the column, the YAML format and the four validation rules this plan writes
against.

**Check before starting:**

```bash
grep -n "passages" tools/import_questions/converter.dart
```

**If that returns nothing, stop and say the pipeline has not landed.** Do not work around it
by putting the passage in every stem: the spec rejects that in Section 2, for three stated
reasons.

---

## Global Constraints

- **Work only inside your worktree.**
- **Write only under `content/questions/reading-comprehension/`.**
- **Passages are original prose. Never copy a published text.** Not a news article, not a
  textbook paragraph, not a poem. The copyright position on this project does not cover
  borrowed prose.
- **150 to 400 words per passage, 4 to 8 questions each.** The validator enforces both.
  Poetry is the one exception, 40 to 120 words, and only where a row says so. **A poem must
  declare `form: poetry` on the passage to get that range.** A passage with no `form` is prose
  and is held to the 150 floor.
- **Never make the correct answer the longest choice.** This is the constraint most easily
  broken without noticing, because a correct answer written to be unambiguous naturally grows
  longer than a distractor written to be wrong. **Check it per question, not per file.** A
  student who can pick the longest option and score has not read the passage, which defeats
  the entire section.
- **Write the passage first, then the questions.** The reverse produces a passage bent to fit
  its answers and it reads like one.
- **American spelling. No em dashes**, in the passage body as much as in a stem.
- **No shouty caps, no "delve", no "it is important to note".** `tools/audit/sweep_ai_tells.py`
  hunts these phrases in lessons and they give away a passage just as fast.
- **Never make the correct answer the longest choice.**
- **Leave `approved:` unset.** Question Studio sets it and Aedwon approves by hand.
- **Never generate an image.** `visual-media` describes its visual in prose.
- **Do not tick a Done box, do not run Question Studio, and do not commit** unless the
  dispatching instruction says to.

## The Generation Procedure, applied to every row

- [ ] **Step 1: Read the source lesson**

`content/lessons/reading-comprehension/<topic>/<subtopic>.md`. Note what skill it teaches and
what it warns against.

- [ ] **Step 2: Write the passage**

Original prose, on a subject a Filipino senior high student has a reason to care about: a
barangay dispute, a sari-sari store's margins, a river cleanup, a remittance letter, a jeepney
driver under a modernization program.

**It must have a point.** A reader who finished it should be able to say what that point was.
A paragraph assembled to hold four answers is the most obvious tell of generated content.

**Count the words before writing a single question.** Outside 150 to 400 and the validator
rejects the file.

- [ ] **Step 3: Write 4 to 8 questions against it**

Archetypes from the blueprint. **Ramp within the set**: a detail question, then a main idea,
then an inference.

- [ ] **Step 4: Validate, before writing another file**

```bash
dart run tools/import_questions/import_questions.dart --root content/questions >/dev/null 2>&1; echo "exit: $?"
```

Exit code 0. The validator rejects an orphaned question, a set below 4 or above 8, a body
outside the word range, and a passage with no questions.

**Always redirect the validator's output.** It prints the full converted JSON of every
question under `--root`, which is **2.8 MB** across the whole corpus. Ingesting that on every
run is the single largest avoidable cost in a content dispatch. Check the exit code, not the
dump, and scope `--root` to your own subject directory:

```bash
dart run tools/import_questions/import_questions.dart \
  --root content/questions/<your subject dir> >/dev/null 2>&1; echo "exit: $?"
```

**Read the output only when the exit code is non-zero**, and then drop the redirect so the
error message is visible.


- [ ] **Step 5: Re-read the passage cold**

Read it as a student would, without looking at the questions. **If you cannot state its point
in one sentence, rewrite it.** This is the step that separates a passage from a container.

## Definition of Done, per subtopic

- One or more passages, each 150 to 400 words, each with 4 to 8 questions.
- Every question answerable **from the passage alone**. Outside knowledge never helps.
- Distractors drawn from the blueprint's ranked sources, with at least one being a true detail
  from the passage that is too small to be the answer.
- The correct answer is not the longest choice anywhere in the file.
- `approved:` unset. Validator exit 0.

---

## Manifest, Comprehension Skills

Topic slug `comprehension-skills`. Exams for all rows: `[upcat, acet, dlsucet, ustet]`.
File path: `content/questions/reading-comprehension/comprehension-skills/<slug>.yaml`.

| Done | Subtopic slug | Primary archetype | Passages |
|---|---|---|---|
| [ ] | `main-idea` | `main-idea` | 3 |
| [ ] | `noting-specific-details` | `noting-specific-details` | 3 |
| [ ] | `inferencing-and-conclusions` | `inferencing-and-conclusions` | 3 |
| [ ] | `authors-purpose-tone-pov` | `authors-purpose-tone-pov` | 3 |
| [ ] | `context-clues-in-passages` | `context-clues-in-passages` | 2 |
| [ ] | `fact-vs-opinion` | `fact-vs-opinion` | 2 |
| [ ] | `sequencing-of-events` | `sequencing-of-events` | 2 |
| [ ] | `choosing-a-title` | `choosing-a-title` | 2 |

**`sequencing-of-events` needs a passage that is not chronological.** A text that narrates in
order turns the item into a reading-speed test.

**`context-clues-in-passages` needs a word whose ordinary meaning differs from its meaning in
the passage**, or the item tests vocabulary rather than comprehension.

## Manifest, Text Types

Topic slug `text-types`. Exams for all rows: `[upcat, acet, dlsucet, ustet]`.
File path: `content/questions/reading-comprehension/text-types/<slug>.yaml`.

**The passage is the specimen here.** Each row needs passages written *in* the form it names,
and the register must genuinely differ between them.

| Done | Subtopic slug | Primary archetypes | Passages | Note |
|---|---|---|---|---|
| [ ] | `essays-editorials-articles` | `identify-text-type`, `feature-of-form` | 3 | One of each: a news report, an editorial, a personal essay. They must not read alike. |
| [ ] | `speeches` | `purpose-of-device`, `feature-of-form` | 2 | Repetition and direct address are the devices worth asking about. |
| [ ] | `poetry` | `purpose-of-device`, `feature-of-form` | 3 | **40 to 120 words**, and the passage must carry `form: poetry`. Without that line the validator holds it to the 150 prose floor. |
| [ ] | `short-stories-and-novels` | `feature-of-form`, `inferencing-and-conclusions` | 2 | An excerpt-shaped original, not a summary of a story. |
| [ ] | `visual-media` | `purpose-of-device` | 2 | **Describe the infographic or poster in prose.** Never generate an image. |

---

## Suggested order

Comprehension Skills first, all eight rows, because the archetypes are the exam's staples and
the passages are ordinary prose. Text Types second: it needs five distinct registers and
poetry needs a different word budget, so it is the harder authoring job.

## Self-Review, before reporting

- Every row you attempted has a file, and every file validates.
- You re-read every passage cold and could state its point in one sentence.
- `grep -c '—'` returns 0 for every file you wrote.
- No `approved:` appears anywhere.
- No passage is copied from any published source.
- No file outside `content/questions/reading-comprehension/` changed.
- Report per file: the passage count, the word count of each, the question count, and the
  validator's **pasted** exit code.
