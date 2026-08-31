# Question QA R1 — Language Proficiency closeout

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Closeout date:** 25 August 2026

## Scope

This closeout covers all original authored/static Language Proficiency questions present at the R1 base. Review was item-by-item for answer validity, uniqueness, rationale correctness, difficulty plausibility, lesson conformity, and whether a visual was required.

## Result

- Original questions reviewed: **319 / 319**
- Verified unchanged: **217**
- Corrected: **102**
- Retired: **0**
- Visual status: **319 TEXT SUFFICIENT**

Per-item status is stored in four continuation ledgers under `docs/content/audit/question-qa-r1-status-language/`:

- `grammar-a.tsv` — 83 items
- `grammar-b.tsv` — 89 items
- `application.tsv` — 45 items
- `vocabulary.tsv` — 102 items

The four partitions total exactly 319 original Language Proficiency items. Correction evidence and lesson conflicts are documented in `docs/content/audit/question-qa-r1-source-ledger-language.md`.

## Major defect classes corrected

- wrong keyed error segments;
- multiple defensible answers caused by hidden context;
- singular `they` treated as categorically wrong;
- collective-noun agreement presented without dialect/register scope;
- past perfect presented as mandatory whenever one past event occurred earlier;
- negative concord described as logically cancelling into a positive;
- subjective concision preferences presented as objective grammar errors;
- modifier scope and attachment contradictions;
- nonparallel repairs that introduced new grammatical or semantic errors;
- affect/effect descriptions presented as exceptionless part-of-speech rules;
- variant-sensitive Filipino spelling treated as universally wrong;
- ambiguous metaphor/personification classifications;
- overconfident morphology/etymology shortcuts;
- incidental factual errors inside language passages.

## Lesson dependencies

The corrected question bank intentionally does not inherit known defects from older lesson text. Follow-up lesson remediation is needed for at least:

1. `grammar-and-structure/tenses-and-voice.md` — earlier-past/past-perfect overgeneralization.
2. `grammar-and-structure/redundancy-and-double-negatives.md` — negative-concord and categorical-redundancy claims.
3. `grammar-and-structure/modifiers.md` — rigid scope claims for `only`.
4. `grammar-and-structure/parallelism.md` — semantically weak correlative example.
5. `grammar-and-structure/subject-verb-agreement.md` — collective-noun agreement needs variety/register qualification.
6. `grammar-and-structure/pronoun-antecedent-agreement.md` — traditional-formal singular-pronoun framing conflicts with current accepted singular `they` usage.
7. `grammar-and-structure/punctuation-and-capitalization.md` — trailing `because` clause guidance needs correction.
8. `vocabulary/confusing-words.md` — affect/effect is presented as an absolute noun/verb split.
9. `vocabulary/root-words-prefixes-suffixes.md` — false `ben-` analysis for `benign` and imprecise `inflammable` explanation.
10. `vocabulary/spelling-rules.md` — i/e mnemonic overstatement and categorical treatment of Filipino spelling variants.
11. `vocabulary/idioms-and-figures-of-speech.md` — “idioms are never literal” and ambiguous engine-roar classification.
12. `vocabulary/synonyms-and-antonyms.md` — prefix/test-taking heuristics need qualification.

These lesson issues are not blockers to the corrected question keys themselves, but they must be reconciled before treating lesson/question conformity as fully clean.

## Validation constraint

This pass was performed through repository inspection and direct GitHub edits. GitHub Actions were not used, and this environment did not execute Flutter/Dart/local validation commands. No Sanity writes were performed and `main` was not modified.
