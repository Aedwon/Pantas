# Note B: what Pro actually buys at the answer reveal

> **How to work this plan.** One file at a time. Commit after each file.
>
> **Required reading before you start:** `AGENTS.md` in full, then Section 2 of
> `docs/superpowers/specs/2026-08-02-pro-entitlement-consolidation-design.md`,
> then Section 3 of `docs/superpowers/specs/2026-07-28-quiz-tab-design.md`, which
> draws the two notes.
>
> **Follow the plan. Do not redesign.** If a question makes the rules impossible,
> **skip it, and list it in your report.** A wrong note is worse than a missing
> one, because a missing one draws nothing.

**Goal:** Give every wrong choice in one subject a note B.

**Why:** the reveal has two notes. Note A, the question's explanation, is free.
**Note B is written on the choice the student picked and is the whole of what Pro
adds at that moment.** The corpus has none, so on 13 August 2026 a Pro subscriber
saw exactly what a free one saw on all 2,369 questions. The pipeline carries the
field now. The content is what is missing.

---

## The shape

In the YAML, on a choice, beside `text`:

```yaml
    choices:
      - text: Chloroplast
        correct: true
      - text: Mitochondrion
        rationale: |
          You picked the organelle that spends energy rather than the one
          that makes it. Mitochondria release energy from food that already
          exists. Photosynthesis is where that food comes from.
```

**Only wrong choices get one.** The correct choice already has note A.

---

## The rules, all of them checkable

1. **Address the student.** It is the "what you picked" note. Use "you". A note
   written in the abstract is note A again.
2. **Name the specific misconception that leads to this choice**, not the general
   topic. "You picked the organelle that spends energy" beats "Mitochondria are
   the powerhouse of the cell".
3. **Never name a letter or a position.** Choices are reshuffled per student, so
   "option B" is wrong on somebody's screen.
4. **Never repeat note A.** If your note would restate the explanation, write the
   misconception instead or skip the choice.
5. **40 to 400 characters.** Under 40 says nothing. Over 400 is a lesson, and
   this is set as a marginal note in 13.5px type.
6. **Grade-5-simple English. Short sentences. American spelling. No em dashes.**
7. **Never invent a figure.** No percentages, no "most students", no counts.
8. **Do not touch anything else in the file.** Not the stem, not the choices, not
   note A, not the ids.

**A distractor that is simply a different number** gets a note about the step that
produces it: "You added before multiplying. The order matters here." That is the
most common shape in Mathematics and it is the useful one.

---

## The check you must run

After each file:

```bash
python3 tools/audit/sweep_note_b.py
```

**Every `blocker` line about a file you touched must be gone before you commit
it.** `important` lines are yours to judge and to report.

You may also run one test file. **Never run `flutter test` with no arguments,
`flutter analyze`, or `dart run build_runner`.**

---

## Scope for this run

**Your subject is named in the dispatch prompt. Do that subject and stop.**

| Subject | Files | Questions |
|---|---|---|
| general-information | 12 | 156 |
| reasoning | 17 | 244 |
| reading-comprehension | 13 | 192 |
| language-proficiency | 19 | 319 |
| mathematics | 46 | 713 |
| science | 51 | 777 |

- [ ] **Step 1: Read one file end to end.**
- [ ] **Step 2: Write a rationale on every wrong choice in it.**
- [ ] **Step 3: Run the sweep and clear every blocker for that file.**
- [ ] **Step 4: Commit that file alone**, with a message naming the file and the
      count of notes added.
- [ ] **Step 5: Next file.**

**If you run short of time, stop after a committed file.** A subject half done in
whole files is useful. A file half done is not.

---

## What to report

- Files finished, and the number of notes in each.
- **Every question you skipped and why.** This is the most useful part of your
  report: it is where the corpus is weak.
- The sweep output after your last commit.
- **Anything you found wrong with a question itself**: a wrong answer, two right
  answers, a distractor that is also correct. **Do not fix those.** Report them.
  A judgment pass on correctness is a separate job with a separate reviewer.
