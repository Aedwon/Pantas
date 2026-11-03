# CET pilot: rules for every writer

Plan: `docs/superpowers/plans/2026-11-03-cet-content-pilot.md`. Spec: `docs/superpowers/specs/2026-11-03-cet-content-design.md`.
Pilot table: `docs/content/rewrite/cet/pilot.json`.

You rewrite lessons of the Pantas exam review app so they meet the current content standards. The lessons serve
UPCAT, DCAT, USTET and ACET students, and the same lessons are shared with other exams. Each lesson has a brief at
`docs/content/rewrite/cet/briefs/<lesson-id>.md`. You write the whole lesson file and check it with the script below.

## Read first

Read these once, in full, from `origin/main` with `git show origin/main:<path>`:

- `docs/content/lesson-style-guide.md`
- `docs/content/content-checklist.md`
- `docs/content/source-policy.md`
- `AGENTS.md` (the voice and maths rules)

Then, for each lesson: its brief, then the current lesson file.

## Scope and isolation

- Change only the lesson files you own. Do not touch any other lesson, any question file, any tag, any CSE lesson, any app
  code, or any file under `docs/content/rewrite/cet/`.
- Do not stage, commit or push. The lead commits.
- Do not run a build, `flutter pub get`, or any test suite. Disk and CPU are limited.
- Sonnet writes and Opus reads. A model never reads its own writing. Do not review your own output as a reader would.

## Rules for the rewrite

1. **Teach the audit's gaps by evidence class.** The brief lists thin, named-only and absent items with the evidence class
   the audit gives. Teach items of class official or curriculum. Teach weak-only items only where they add little length.
   Do not teach an item of class unknown and do not claim it. No sentence says that a specific exam tests something
   unless the brief or an official source says so.
2. **Meet every lesson rule of the checklist.** There is no separate audit and triage for this pilot. You are responsible
   for the lesson standards, not only for the brief. Fix any rule your reading of the current lesson shows is broken.
3. **Never remove a case that another tagged exam needs.** The brief lists the audit's tagged exams. A rewrite may add
   cases. It may not take away a case or fact that any tagged exam uses.
4. **Split and reorder candidates are not applied.** The pilot makes no splits. If the brief marks a candidate, record it
   in your report and leave the lesson one lesson. If the lesson runs over about 3,000 words, report it as a split
   candidate and make no split.
5. **Length.** A lesson takes the length the teaching needs, with no padding. The check counts
   whitespace-separated words for the whole file. Over about 3,000 words, report the lesson as a split candidate and make
   no split.
6. **Frontmatter.** Keep the `_id` line exactly as it is. Keep every frontmatter key in the same order. Change `title` or
   `summary` only when the new content needs it. Keep `estimatedMinutes` from 8 to 15.
7. **Figures.** Where a figure would help the student, add one marker on its own line, as one line:
   `<!-- ILLUSTRATION: what to draw, with the exact labels and values from the lesson -->`
   Do not draw anything and do not add images or links. Keep the markers that are already there unless the figure no
   longer fits.
8. **Language of the teaching text.** Plain English a Grade 5 student can read: short sentences, one to three sentences in
   a paragraph. Filipino-language lessons use simple Filipino at the same standard. Example questions use realistic exam
   wording, not Grade 5 wording.
9. **Style.** No em dashes: use a comma or a colon. American spelling: practice, color, behavior, analyze. Write "points",
   never "marks", and "questions", never "cards". Never write FSRS, stability, retention, retrievability or algorithm in
   student text.
10. **Maths.** Write maths between single dollar signs, as in `$x^2$`. Write `\dfrac` for a fraction, never `\frac`. The one
    exception is a fraction inside another fraction, which uses `\frac`.
11. **Facts.** Never invent a fact or a figure. If you cannot confirm a hard-to-remember fact, leave it out. Check facts
    against official sources and record nothing you did not confirm. A claim about what an exam covers needs a source.
12. **Whole file.** Write the whole lesson file each time, from the first `---` line to the last line. Do not write a
    patch, a summary or a comment about your changes into the file.

## Lead rulings for this pilot

1. **L18 (example coverage) for CETs.** "Exam-relevant" means a case named in the accepted requirements for a tagged CET at
   official or curriculum class, or a standard application of a skill in the lesson's goal. Do not add a case only
   because an exam might use it.
2. **Tagged exams.** The brief lists the audit's tags, as the audit writes them. The audit's tags decide which exams a
   lesson serves. Do not remove a case another tagged exam needs.
3. **Splits.** The pilot makes no splits (rule 4 above).
4. **Stoichiometry.** The audit's split candidate for stoichiometry is recorded in its brief but is not applied.

## Check the lesson

After each full write, run from the worktree root:

```bash
python3 -I tools/content_rewrite/check_cet_lesson.py content/lessons/<subject>/<topic>/<slug>.md
```

It compares the lesson with the base revision and prints reasons, notes and the word count. Over 3,000 words it
also prints a split-candidate note, which is not a failure. Exit 0 means no reason. Fix every reason and write again until it exits 0. A note is for you to judge, not a failure. The
check does not prove the lesson is right. It only blocks the mechanical failures.

## Report, per lesson

- Words before and after.
- Figure markers added.
- Facts you could not confirm and removed.
- Whether the lesson is a split candidate, and why.
- Any brief item you did not teach, and why (for example, class unknown).

## Rules added after round 1

Round 1: all 15 lessons had a Blocker or Major (6 Blockers, 83 Majors). Worked answers were correct. The main causes were terms used without a meaning (L25), cases taught but not worked (L18), and teaching cut to fit a word limit.

1. **Meanings come first.** Every term a student needs is explained in plain words on first use, or the lesson names the prerequisite lesson. Never cut a meaning, a step or a required case to save words. Cut repeated teaching, extra traps and near-duplicate examples first.
2. **No false absolutes.** Before writing "only", "always", "never", "every" or "all", test the statement against the lesson's own later sections and against an exception you know of.
3. **Keep what the base lesson taught correctly** unless the brief or a rule says to drop it. Compare with the base before you finish.
4. **Word every shortcut and trap with its limit**, so it cannot be applied where it fails.
5. **Round 2 and later:** fix every open Blocker and Major in the read file for your lesson, and any Minor in text you edit. If the finding is wrong, leave the text and report why, with a source.
6. **The 1,700-word limit was a lead error.** It is removed. Teaching cut for it should be restored from the base (`git show 7032eec5:<path>`) wherever the checklist needs it. Do not cut correct, needed teaching for length. If the lesson passes about 3,000 words, report it as a split candidate and make no split.
