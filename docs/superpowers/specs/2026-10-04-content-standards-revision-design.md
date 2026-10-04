# Content standards revision

Date: October 4, 2026
Status: Approved by Aedwon on October 4, 2026. Implementation in progress.
Decision record: `docs/superpowers/decisions/2026-10-01-question-explanations-log.md`
on branch `docs/content-coverage-audit-r1`, entries dated October 4, 2026.

## For Aedwon to approve

### Why this comes first

Pantas will audit its whole corpus and then run an automated pipeline that
checks and edits lessons and questions. Both need one current, checkable
standard. Today the standards are spread across four guides, still assume
English-only content, and have no rules for sources, learning goals, or how a
multiple-choice question should be built. This revision fixes that before the
coverage audit starts. Agreed order: standards, then the coverage audit, then
the pipeline.

### What changes

1. **Filipino-language content.** Lessons that teach Filipino grammar,
   vocabulary, or reading are written in simple Filipino. A hard grammar term
   gets a short English gloss the first time it appears. Example sentences and
   quiz items are in Filipino. Spelling and usage follow the national
   language commission's published rules. No reliable reading-level formula
   exists for Filipino, so readability is judged by rules (short sentences,
   common words, one idea per sentence) and by a student-level reader check,
   the same way English lessons are judged today.
2. **Sources.** Every fact that is easy to misremember must be checked against
   a source, and the source is recorded. A fixed order decides which source
   wins when they disagree: the exam organizer first, then the Philippine
   curriculum, then standard references for the subject, then other reputable
   sources. If a fact cannot be confirmed, it is left out. Sources are kept in
   the content audit records, not in the lesson text students see.
3. **Learning goals.** Each lesson records what a student should be able to do
   after it and which exam requirement that serves. This is an authoring and
   audit note only. Students do not see it, and the app does not change.
4. **How questions are built.** The current question rules stay: realistic
   exam wording, wrong choices based on real mistakes, solving before
   explaining, and a note on every wrong choice. Three additions:
   - **A format profile for each exam.** Each profile records how that exam's
     items look: number of choices, item types such as error identification,
     whether "none of the above" or negative questions appear, and the
     language of each part. Each entry states its evidence and how confident
     it is. Where an exam publishes nothing, Philippine teacher-training
     (DepEd) conventions apply and the gap is stated. The coverage audit's
     first step builds the profiles; this revision defines their shape.
     Authors and judges check "realistic" against the profile. Civil Service
     Professional and Subprofessional get their own profiles.
   - **No answer-giving clues.** The correct answer is not the longest or most
     detailed choice by habit. Its position varies across a lesson's set. No
     choice can be ruled out by grammar or wording alone. Choices share a
     similar form and length.
   - **A blind-solve check.** Someone other than the author answers the
     question without seeing the key. If they pick a different answer, the
     question is treated as ambiguous or wrong until fixed.

   Rules such as whether "none of the above" is allowed come from each exam's
   profile, not from a blanket ban.
5. **One checklist.** Every rule from the lesson and question guides becomes a
   pass-or-fail line with a severity:
   - **Blocker:** wrong fact, wrong or ambiguous answer, or required content
     missing.
   - **Major:** breaks a rule in a way that hurts learning, such as a skipped
     solution step, an implausible wrong choice, or prose above the reading
     level.
   - **Minor:** style or formatting.

   Content passes only with no blockers and no majors. Authors use the
   checklist before submitting. The later pipeline's judges use the same
   checklist, so authors and judges cannot apply different rules.
6. **Runbooks brought up to date.** The lesson and question runbooks describe
   the current process. The old table that maps topics to exams becomes
   provisional until the coverage audit replaces it with checked tags.

### What does not change

Existing rules stay: the Grade 5 teaching benchmark, realistic exam language in
questions, the explanation and wrong-choice note rules, fraction formatting, no
em dashes, American spelling, and at least 20 active questions per lesson. No
lesson or question is edited by this work. No app code changes.

### Where the standards live

The revised guides land on main, where the current guides already live, so
every branch and worker reads one version. Older copies on content branches are
not the standard. Merging to main needs your approval of this spec; this is a
documentation change and does not lift the application-code freeze.

### Effort and completion

Balanced scope, chosen by you: about 3 to 4 hours of agent work, a rough
estimate. It is complete when the guides contain the six changes above, the
checklist covers every rule in the guides with a severity, nothing in the
guides contradicts `AGENTS.md`, and the revised documents are on main.

## Agent reference, not the approval section

### Identity

- Policy: main `96e4d0b2fe53c4c0a45fdce0d055c5bec7e0340a`.
- Base for the revision: main's `docs/content/` at that commit. The copies on
  `content/question-qa-r2` (`765c5dc0`) predate the September 25 and October 1
  revisions and are not the baseline.
- Working branch: `docs/content-standards-r1`.

### Files

- `docs/content/lesson-style-guide.md`: Filipino-language section; learning
  goal requirement; pointer to the checklist.
- `docs/content/question-style-guide.md`: answer-clue rules, blind-solve
  requirement, pointer to the format profiles; Filipino items; pointer to the
  checklist.
- New `docs/content/exam-format-profiles.md`: profile shape for each named
  exam, entries marked unknown until the coverage audit fills them.
- `docs/content/lesson-authoring-runbook.md` and
  `docs/content/question-authoring-runbook.md`: current process, source
  recording, checklist step; mark the topic-to-exam table provisional pending
  the coverage audit's tags; note that CSE levels are tagged separately.
- New `docs/content/source-policy.md`: hierarchy and record format.
- New `docs/content/content-checklist.md`: every rule as one checkable line
  with an id, scope (lesson, question, both), severity, and how to check it.

Do not add fields to lesson frontmatter or question YAML. The importer and the
Sanity documents must not change. Learning goals and source records live in the
existing audit record area under `docs/content/audit/`, keyed by lesson id.

### Evidence for decisions made by the agent

- Item-writing rules: the clue and form rules draw on Haladyna, Downing, and
  Rodriguez (2002), "A Review of Multiple-Choice Item-Writing Guidelines for
  Classroom Assessment," Applied Measurement in Education 15(3), 309 to 334
  (https://eric.ed.gov/?id=EJ660246), and DepEd test-construction guidance,
  which agrees on homogeneous options of similar length, one main idea per
  stem, a complete stem, and four or five options
  (https://www.deped.gov.ph/wp-content/uploads/2016/06/DO_s2016_55-3.pdf).
  Aedwon questioned whether general research fits Philippine exams, so
  format rules (option count, "none of the above", negative stems, item
  types) are not universal: they come from per-exam format profiles. Evidence
  on actual Philippine exam formats is thin. UP's admissions pages do not
  currently link official verbal sample tests, and Civil Service samples found
  online are unofficial reviewers (one shows "none of the above"). Profiles
  must label such evidence as weak.
- Answer clues: "correct answer is the longest or most complete" is a classic
  cue in the guidelines above. The claim that AI writers tend toward it is
  based on general experience, not a cited study; the pipeline pilot measures
  it on Pantas questions.
- Format profile shape, in `docs/content/exam-format-profiles.md`: one section
  per exam with entries for choice count, item types per subtest, "none of
  the above" and "all of the above" use, negative stems, language per subtest,
  and timing where it affects item length; each entry has its source, date
  checked, and confidence (official, strong secondary, weak, unknown). This
  revision creates the shape with every entry marked unknown; the coverage
  audit fills it.
- Blind solve: a checklist line, severity blocker on disagreement with the
  key. Authors cannot satisfy it themselves; it is run by a separate solver
  (a reviewer now, a judge in the later pipeline).
- Filipino readability: English formulas misjudge Filipino text (SMOG and Fry
  studies), and Filipino-specific models are research prototypes, not
  deployable checks (Imperial and Ong, 2021, https://arxiv.org/pdf/2110.00157).
  Therefore no numeric readability threshold; use rule-based and reader-based
  judgment. Evidence strength: moderate.
- Filipino orthography: Komisyon sa Wikang Filipino publications
  (Ortograpiyang Pambansa) as the top language source. Confirm the current
  edition during implementation.
- Source hierarchy: organizer publications define what is tested; the DepEd
  curriculum defines prior knowledge and terms students already know; subject
  references (for example, IUPAC for chemical naming, CODATA for constants)
  settle facts. This is standard practice rather than a studied result; state
  that in the source policy.

### Checks

- Every rule in both style guides maps to exactly one checklist line, and
  every checklist line cites the guide section it comes from.
- No contradiction with `AGENTS.md` voice, figure, and maths rules.
- No em dashes, American spelling, attribution check passes.
- Readback of all changed files after writing.

### Boundaries

No content edits, no importer or schema change, no app code, no Google Doc
change. Publication of content and the coverage audit need their own
authorization. Merge to main only after Aedwon approves this spec and the
completed documents pass the checks above.
