# Math lessons for the question generator: report

November 16, 2026 (UTC). Lead: math for generator lane. Branch `content/math-for-generator-r1`. Nothing uploaded to staging or prod.

## Result

- **CSE:** 54 live math lessons (41 arithmetic, 7 data interpretation, 6 Algebra word-problem parts). Prod root `content/bite-sized-cse-algebra-r1` 88f38e698. Nothing written.
- **CET:** 121 active math lessons on this branch. Algebra is the 49 live parts; the five CET-rewritten Algebra parents stay retired and their 35 extra skills are listed as gaps, not added. Audit complete: all 18 rewritten lessons or their replacement parts audited by Astra; 32 findings fixed and checked; 311 questions read against their current lessons, 32 findings fixed and checked; no wrong key found.
- **PSHS-NCE:** 3 new lessons, 20 questions each (5 choices). Source: the official PSHS NCE reviewer (2024) and 2015 sample. 12 existing lessons teach the sample's other item types.

Lists: `lesson-lists.md`. Source: `pshs-nce-source.md`.

## Open items

1. **Merge before any CET ship:** this branch took only math paths from the prod root. `content/lesson-prerequisites.json`, `content/question-gap-tags.json`, the question ledger, mocks and the audit tool change are not reconciled, and the science, reading and reasoning files of the paused CET rewrite still conflict with the prod root (about 25 files).
2. **35 CET-level Algebra skills** taught by the retired CET rewrites but by no part (`astra/results/*.json`, `gaps`). Adding them is new writing; not done.
3. **PSHS-NCE has no exam in the export** (`exam-pshs-nce` is referenced by the 3 new question files only). The 12 existing lessons' question files are not tagged for it. Both are generator or exam setup work, not approved here.
4. **Item 2024-11's key** (dot-grid areas) is unverified; the scan is too faint.
5. Figures: the new lessons carry ILLUSTRATION markers only; the figure phase stays paused.
