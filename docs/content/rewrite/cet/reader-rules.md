# CET pilot: rules for every reader

Plan: `docs/superpowers/plans/2026-11-03-cet-content-pilot.md`. Pilot table: `docs/content/rewrite/cet/pilot.json`.

You read a rewritten lesson of the Pantas exam review app and report what is wrong with it. You write no lesson text and
you change no lesson file. Sonnet writes and Opus reads. A model never reads its own writing.

## Read first

Read these once, in full, from `origin/main` with `git show origin/main:<path>`:

- `docs/content/lesson-style-guide.md`
- `docs/content/content-checklist.md`
- `docs/content/source-policy.md`
- `AGENTS.md` (the voice and maths rules)

Then, for each lesson: its brief at `docs/content/rewrite/cet/briefs/<lesson-id>.md`, then the lesson file as rewritten.
Also read `docs/content/rewrite/cet/writer-rules.md`, because the lead rulings in it bind the reader too.

## What to do

1. Read the lesson in full and do a full independent read first, before you open any earlier read file.
2. Judge it against every rule of the checklist that applies to lessons.
3. Check every fact. For anything hard to remember, check an official source before you call it right or wrong. Solve each
   worked example yourself from its question alone, then compare with the lesson's solution.
4. Check the lesson against its brief: the thin, named-only and absent items the writer was to teach (by evidence class),
   and the rule that no case another tagged exam needs was removed.
5. Then check the previous round's read file for this lesson (`reads/round-N/`, N one lower than yours). Confirm each
   earlier finding is fixed, wrong, or still open.
6. Compare the lesson with the base: `git show 7032eec5:<path>`. Report correct, needed teaching that was cut.
7. Report findings. A finding is a rule that fails, with an exact quote.
8. Do not raise a Major for polish. Raise a Major only for a rule that fails and harms the student. A clean verdict is
   valid. Do not search for a finding to fill the file.

## Lead rulings that bind the reader

- **L18 for CETs.** Raise L18 only for a case named in the accepted requirements for a tagged CET at official or
  curriculum class, or a standard application of a skill in the lesson's goal. Do not raise L18 for a case you only
  imagine an exam might use. Changing only numbers or nouns is not a new case.
- **Evidence classes.** A weak-only item need not be taught. An item of class unknown must be neither taught nor
  claimed. A sentence that says a specific exam tests something, without a source, is a finding.
- **Length and splits.** A lesson takes the length the teaching needs, with no padding. Over
  about 3,000 words, the lesson is a split candidate. Report it as a note, and do not ask for a split to be applied.
- **Severity follows the checklist.** Do not invent stricter rules and do not excuse a clear breach.

## Output

Write one JSON file per lesson to `docs/content/rewrite/cet/reads/round-N/<lesson-id>.json`, where N is the round. Output
exactly this shape and nothing else in the file:

```json
{
  "lesson": "lesson-chemistry-stoichiometry",
  "round": 1,
  "reader": "opus",
  "verdict": "clean",
  "findings": [
    {"rule": "B01", "severity": "Major", "quote": "text copied exactly from the lesson", "problem": "what is wrong and why", "source": "the official source or the checklist row that decides it"}
  ],
  "goodQuotesChecked": 0
}
```

- `lesson` is the frontmatter `_id`. `round` is an integer. `reader` is `opus`.
- `verdict` is one of `clean`, `minor`, `major`, `blocker`. It is the highest severity among the findings: `clean` when
  there are none, `minor` when the worst is Minor, `major` when the worst is Major, `blocker` when any is a Blocker.
- Every finding quotes the lesson exactly: at least 8 characters, copied character for character from the lesson, with no
  paraphrase and no ellipsis. A bare heading is not a quote. Where something is missing, quote the place where it was
  needed.
- `rule` is the checklist id (for example B01, L18). `severity` is the checklist severity for that rule: Blocker, Major or
  Minor. Use the checklist's own rule for "Major if a step is skipped, otherwise Minor" cases.
- `problem` says what breaks the rule and why, in at least 20 characters. `source` names what decides it: a checklist
  row, an official document, or the brief.
- `goodQuotesChecked` is an integer: how many exact quotes in your file you re-checked against the lesson text, character
  for character, before you saved it. Every finding quote must be counted. Do not count a quote you did not re-check.
- An empty `findings` list is valid and means the verdict is `clean`.
- Use `[]` for no findings and `""` for an empty text, never `null`.

Do not fix anything. Do not suggest rewritten text. Report the finding and stop.
