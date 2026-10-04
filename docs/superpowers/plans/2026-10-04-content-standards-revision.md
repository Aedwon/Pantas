# Content Standards Revision Implementation Plan

> **For agentic workers:** documentation-only plan, executed by the lead in one
> worktree because every task edits tightly coupled guides. Independent review
> follows `SUBAGENTS.md`. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Revise Pantas content standards so lessons and questions, including
Filipino-language content, are judged against one current, checkable standard.

**Architecture:** Extend the four existing guides in `docs/content/`, add three
small documents (source policy, exam format profiles, checklist), and leave
content, importer, schema, and app code untouched.

**Spec:** `docs/superpowers/specs/2026-10-04-content-standards-revision-design.md`,
approved by Aedwon on October 4, 2026 ("okay everything that needs my approval
looks good so far!").

## Global Constraints

- Branch `docs/content-standards-r1`, based on main `96e4d0b2`.
- No edits to lessons, questions, importer, schema, app code, or Google Docs.
- No new fields in lesson frontmatter or question YAML.
- No em dashes in new or changed text; American spelling; no AI attribution.
- Every rule keeps one wording; the checklist cites rules, it does not restate
  different versions of them.
- Merge to main after checks and independent review pass (approved in spec).

---

### Task 1: Source policy

**Files:** Create `docs/content/source-policy.md`.

- [ ] Write: which facts need a source (the runbook's existing list plus
  statutes, exam formats, Filipino grammar and orthography); the hierarchy
  (exam organizer; DepEd curriculum; subject references such as IUPAC, CODATA,
  Komisyon sa Wikang Filipino; other reputable sources), with a note that the
  order is standard practice, not a studied result; conflict rule (higher
  source wins, conflict recorded); unconfirmed facts are left out.
- [ ] Record format: reuse the existing source ledger table in
  `docs/content/audit/question-qa-r1-source-ledger.md` (item, issue or claim,
  disposition, source with URL, verification note, access date). Ledgers live
  under `docs/content/audit/`, one per audit round and subject.
- [ ] Learning goals: recorded in the same audit round's records, keyed by
  lesson id, one or two sentences each, naming the exam requirement served.

### Task 2: Exam format profiles

**Files:** Create `docs/content/exam-format-profiles.md`.

- [ ] One section each for UPCAT, DCAT, ACET, USTET, PUPCET, DOST
  undergraduate scholarship exam, SM Foundation scholarship exam, CSE
  Professional, CSE Subprofessional.
- [ ] Each section lists the same entries: choice count; item types per
  subtest; "none of the above" use; "all of the above" use; negative stems;
  language per subtest; timing where it affects item length. Each entry has
  value, source, date checked, confidence (official, strong secondary, weak,
  unknown). All values start as unknown.
- [ ] State the fallback: while an entry is unknown, DepEd test-construction
  conventions apply and the gap is reported. State that the coverage audit's
  first step fills the profiles.

### Task 3: Lesson style guide

**Files:** Modify `docs/content/lesson-style-guide.md`.

- [ ] Add "Filipino-language lessons": simple Filipino prose; short English
  gloss for a hard grammar term on first use; examples and in-lesson quiz
  items in Filipino; orthography per Komisyon sa Wikang Filipino; readability
  judged by rules (short sentences, common words, one idea per sentence) and a
  student-level reader check, with no numeric formula, and why.
- [ ] Add "Learning goal": each lesson has one recorded in the audit records
  (source policy), not in frontmatter.
- [ ] Add a pointer to the checklist and the source policy near the top.

### Task 4: Question style guide

**Files:** Modify `docs/content/question-style-guide.md`.

- [ ] Add "Exam format profiles": "realistic" is checked against the target
  exam's profile; format choices (choice count, "none of the above", negative
  stems, item types) come from the profile; unknown entries fall back to DepEd
  conventions.
- [ ] Add "No answer-giving clues": correct answer not habitually longest or
  most detailed; key position varies across a lesson's set; no choice ruled
  out by grammar or wording alone; choices share form and length.
- [ ] Add "Blind solve": a solver other than the author answers without the
  key; disagreement marks the item ambiguous or wrong until fixed.
- [ ] Add Filipino items: stems, choices, explanations, and notes for
  Filipino-language items are in simple Filipino, per the lesson guide.
- [ ] Add pointers to the checklist and source policy.

### Task 5: Runbooks

**Files:** Modify `docs/content/lesson-authoring-runbook.md`,
`docs/content/question-authoring-runbook.md`.

- [ ] Replace the English-only note with a pointer to the Filipino rules.
- [ ] Add steps: record sources and the learning goal per the source policy;
  run the checklist before submitting.
- [ ] Question runbook: mark the topic-to-exam table provisional until the
  coverage audit's tags replace it; note CSE Professional and Subprofessional
  are tagged separately once profiled; add the blind-solve step.

### Task 6: Checklist

**Files:** Create `docs/content/content-checklist.md`.

- [ ] Header: severities (blocker, major, minor) and the pass rule (no blocker,
  no major).
- [ ] One line per rule from both style guides, the source policy, and the
  format profiles: id (L-, Q-, B- prefixes for lesson, question, both), the
  rule in a few words, severity, how to check, and the guide section it cites.
- [ ] Severity mapping: wrong fact, wrong or ambiguous key, missing required
  content, blind-solve disagreement are blockers; rule breaks that hurt
  learning are major; style and formatting are minor.

### Task 7: Verify, review, record, merge

- [ ] Coverage check: list every rule heading and bullet in both style guides
  and confirm each maps to a checklist id; confirm each checklist id cites an
  existing section.
- [ ] Consistency: compare with `AGENTS.md` voice, figure, and maths rules.
- [ ] Mechanical: `grep -n "—"` on changed files returns nothing; grep for
  British spellings; `dart run tool/check_no_ai_attribution.dart` returns OK;
  revert any `pubspec.lock` side effect.
- [ ] Independent review by an agent that did not write the changes, against
  the spec. Fix findings and recheck.
- [ ] Record completion, checks, and review result in
  `docs/superpowers/decisions/2026-10-01-question-explanations-log.md` on
  `docs/content-coverage-audit-r1`, and mark the spec approved and complete.
- [ ] Commit with a why-message, fast-forward main, verify remote SHA matches,
  then remove the worktree and branch after confirming the merge.
