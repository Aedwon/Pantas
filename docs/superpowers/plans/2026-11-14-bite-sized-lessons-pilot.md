# Bite-sized lessons: implementation plan through the pilot

Spec: `docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md` (fcdd7a250). Read it in full
first; this plan does not repeat its rules.
Rulings: launch log, "Bite-sized lessons decisions" (Fable 5.2 under Aedwon's delegation, Nov 14):
balanced scope; label "Part 2 of 3 · 4 questions" with every typed-in minute removed, including
"minutes left"; pilot Philippine Constitution plus CSE Data Interpretation on staging; lead approves
after a separate re-solve plus a Codex audit sample, workers stop approving in Question Studio,
every Constitution and RA 6713 question is checked against the law text; legacy questions kept until
their subject is split, anything new, moved or edited blocked, and after the pilot the subjects with
no approved questions go first; separate lessons.
Policy revision: `origin/main` 292beb559. Velocity row: E-051 (this plan and the mockup).
Scope of this plan: Step 0 (code) and Step 1 (pilot) of spec B5, up to Aedwon's pilot check and the
pilot's prod release. The other subjects get their own plan after the pilot.

## Global constraints

- Every dispatch includes the startup instruction (`docs/workflow/startup.md`) and the policy
  revision. Workers read AGENTS.md, WORKFLOW.md and SUBAGENTS.md from main first.
- UI work never goes to Codex. Codex runs only through `codex-pick`, one job at a time across all
  lanes unless `codex-pick --status` shows room for each; size each run to one 5-hour window, and
  have it write its result file as it goes.
- Every Chromium or Chrome launch passes `--use-mock-keychain` and `--password-store=basic`.
- Failing-first tests for every code task (SUBAGENTS Part 3). Workers stage nothing; the lead commits.
- No commit carries an AI or Co-Authored-By trailer.
- App code merges and deploys go through the integrator lead (DS4 release candidate). Each prod release
  needs Aedwon's "ship it". Server content uploads before hosting.
- No figure is invented. The UI shows only real part numbers and real question counts.
- The repository is public: no tester data in any file.

## Branches

| Branch | From | Holds |
|---|---|---|
| `web/bite-sized-r1` | `origin/main` | All Step 0 code: tools, checks, exporter, uploader, server, app |
| `mockup/bite-sized-label` | `origin/main` | The mockup only; never merged |
| `content/bite-sized-pilot` | `origin/content/cse-rewrite-r1` 1ca8dfd (verify the head first) | Pilot lessons, question tags, ledger, verification records |

Gate tools always run from the `web/bite-sized-r1` worktree against a content root
(`--root <content worktree>/content`). The content branch does not merge main's tools.

## Collisions to check before dispatch

- `lib/features/home/application/home_today.dart`: the E-043 (update at once) and E-044 (Home
  "Continue Lesson") lanes touch Home. Ask the integrator which is in flight before T8; rebase after.
- `functions/src/roadmap.ts`, `studyInsights.ts`, `studyObservations.ts`: check the security lanes
  (E-047 to E-050, `security/r2-signin-mail`, `web/security-caps-r1`) for open changes before T7.
- `tools/upload_content/upload_content.mjs`: check the security lanes before T4.

## Tasks

Estimates are wall time including review and CI. The lead reviews every result before the next task
that depends on it.

### T0. Verify the open facts (Haiku 5.5 reader, 30 min)

Report, with file and line: when a stored roadmap day is rebuilt after content changes; what the
lesson page shows for an unknown id; where notes are stored and how they are keyed; whether CET exams
are selectable in prod; what `content/lesson-prerequisites.json` and `content/question-gap-tags.json`
key on, on the content branch; whether `content/cse-rewrite-r1` moved past 1ca8dfd; which tests cover
`upload_content.mjs`. Any surprise goes to the lead before T5.

### T1. Question hash and ledger library (Codex Sol, 1 h)

Files: `tool/content/question_hash.dart`, `tool/content/ledger.dart`, tests under
`test/tool/content/`.
- Canonical form and SHA-256 per spec B6 (stem, each choice's text, correct flag, rationale,
  explanation, passage, figure, figureSpec, file `meta.exams`, resolved lesson). Key order, whitespace
  and YAML quoting must not change the hash; any listed field change must.
- Ledger read and write: `content/question-ledger/legacy.json`, `approved.json` (id to hash and
  evidence path).
- Tests: stability under reformatting; change of each field changes the hash; `keyPoint` and
  `approved` do not.

### T2. Approval gate (Codex Sol, 1 h 30 min)

Files: `tool/checks/content_approval_check.dart`, `tool/content/content_gate.dart` (CLI:
`--root <content dir>`, exit 1 with failing ids), registration in `tool/checks/run_checks.dart`,
tests with bad samples under `test/tool/checks/`.
- A question ships only if its hash equals its approved hash or its legacy hash (spec B6 items 3-4).
- The legacy file's SHA-256 must be in a pinned set in the check source. Two entries: main's
  `content/` and the pilot content root. Generated by T3 at a recorded revision.
- A subject with any `part:` lesson has no question on legacy status.
- Excluded from shipping only what the exporter already excludes (figure-pending, inactive). The gate
  never drops a question; it fails.
- Tests fail first on: a new unapproved question; an edited legacy question; a moved legacy question;
  an edited approved question; a changed legacy file; a split subject with a legacy question.

### T3. Approve and freeze tools (Codex Sol, 45 min)

Files: `tool/content/approve.dart`, `tool/content/freeze_legacy.dart`, tests.
- `freeze_legacy.dart --root <dir>` writes `legacy.json` for every shipping question not approved
  today, and prints its SHA-256 for T2's pinned set. Run once on main's `content/` at the code branch
  base and once on the pilot root at 1ca8dfd (or the head T0 finds). Record both revisions and hashes
  in the plan's run log.
- `approve.dart --root <dir> --ids <file> --evidence <path>` writes `approved.json` and sets
  `approved: true` in the YAML for display. `--moved` accepts only when the lesson is the sole change
  and an approval or a verified legacy solve exists.
- Lead-only use is a rule in this plan and in SUBAGENTS (T11), not a technical lock.

### T4. Exporter and uploader call the gate (Codex Sol, 1 h)

Files: `tools/build_content_export/build_content_export.dart`, `tools/upload_content/upload_content.mjs`,
their tests.
- The exporter runs the gate on its source root before writing; failure exits non-zero.
- The uploader runs `dart run tool/content/content_gate.dart --root <its --root>` before any write, in
  dry run and live, and refuses on failure. `--skip-invalid` does not bypass it. The pinned legacy
  hashes come from the check source, never from the root.
- Tests: uploader refuses in dry run, live (emulator or stubbed writer) and with `--skip-invalid`.

### T5. Content model through export, seed, catalog and server (Codex Sol, 2 h, two runs)

T5a, files: `build_content_export.dart`, `lib/core/content/tables/content_lessons.dart`,
`lib/core/content/content_database.dart` (schemaVersion 10 to 11 with its migration in the same
commit; confirm 10 first), the seed writer, tests.
T5b, files: `functions/src/contentUpload.ts`, `functions/src/_examContent.ts`, catalog build, tests.
- Lesson fields: `part`, `partCount`, `keyPoints`, `status`, `replacedBy`, `ordering`; computed
  `quizSize` (spec B3). Question fields: `lesson`, `keyPoint`.
- A question's lesson is `lesson:` when present, else today's subtopic rule; a retired lesson resolves
  through `replacedBy[0]`. Same rule in Dart and TypeScript, one shared fixture
  (`test/fixtures/content/lesson_resolution_cases.json`, read by both test suites).
- Server lesson docs store `status` and `ordering`; the catalog carries retired lessons with status;
  `_examContent.ts` lists active lessons only and orders by `ordering`.
- Build fails on a `replacedBy` cycle, a retired lesson that replaces nothing, or a link to a retired
  lesson in `lesson-prerequisites.json`.
- No-op proof: export of today's content is byte-identical except the new columns' defaults.

### T6. Size, nothing-dropped and pool checks (Codex Sol, 1 h 15 min)

Files: `tool/checks/lesson_size_check.dart`, `tool/checks/lesson_split_coverage_check.dart`,
`tool/checks/lesson_pool_check.dart`, registration, bad-sample tests. Each takes a content root like
the gate. Numbers and rules: spec B3 and B6. Bad samples: today's Bill of Rights marked as a part;
a fixture split missing one example; a key point with no question for one exam.

### T7. Credit rule (Codex Sol, 1 h 30 min)

Files: a pure function in `lib/features/lesson/domain/` (name chosen by the builder), its use in
`lesson_progress_repository.dart` reads, `build_study_map.dart`, `read_then_quiz_signal.dart`,
`coverage_breadth_signal.dart`, `roadmap_inputs_reader.dart` (excluded lessons too);
`functions/src/studyInsights.ts`, `roadmap.ts`, `customTracks.ts`, `studyObservations.ts`
(`recordLessonRead` accepts a retired id). Shared fixture
`test/fixtures/content/lesson_credit_cases.json` read by Dart and Functions tests.
Cases (spec B12): read original; read one part; read all parts; excluded original; rollback merge with
all and some parts read; cycle rejected. Reads are never written by this rule.

### T8. Retired-id lookup and safe removal (Codex Sol, 1 h 15 min)

Files: `lib/core/content/repos/lesson_repo.dart` (`findById` resolves a retired id to
`replacedBy[0]`), `bookmark_providers.dart`, `completed_quiz_provider.dart`,
`lib/features/home/application/home_today.dart` (a missing or retired planned lesson rebuilds the day
instead of throwing at :118 and :122), the reader position clamp, and the web content mirror
(`content_mirror.dart`) honoring `status`. Tests for each. Check the Home collision first.

### T9. Quiz size picker (Codex Sol, 45 min)

Files: `lib/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart`,
`lib/features/quiz/domain/picker/inline_lesson_picker.dart`, tests. Replace both literal 5s with the
lesson's `quizSize` (5 when absent). One question per key point first, fresh before seen, then the
rest of the pool. Return `shown = min(size, pool)`; expose it for the UI.

### T10. UI, after the mockup ruling (Sonnet 5.5, 3 h)

Ruled Nov 14 (launch log, "Bite-sized label board ruling"): Option 1 everywhere, topic-end card untouched, chevrons untouched, undrawn surfaces get label changes only, pull-up kept. Build 1:1 to that ruling and the board's Option 1 frames. Board: "Bite-sized Lesson Labels"
(https://claude.ai/artifact/Ub27VuHxHfeKrsRXgVfLuo) has a Fable ruling relayed by the manager. The
board offers row layouts 1 to 3 (label as a second line; second line on phone and trailing on wide
web; parts grouped under the original lesson) and ending options A ("6 lessons left") and B (no
line). It was built from Pantas Web (W_Study, SD_Search, HM_LessonsPanel, RD_TopicShort,
RD_Contents) and Pantas Redesign (ST_TopicOpen, RD_Contents, ST_Search, HE_ManyLessons, RD_End),
with dark values from DK_Home, DK_Study and DK_Reader. Known departures to resolve in the ruling:
web chevrons drawn on every row (approved: hover only); web contents dropdown, phone ending and the
phone quiz screen not drawn (no approved artboard); the phone next-part action keeps the approved
pull-up gesture; the 440-wide Home drawer and 520-wide ending list fall back to Option 1 under
Option 2. Nobody has viewed the board yet. Build 1:1 to the chosen option on every surface the board covers; next-part action; quiz
count. Review by a separate Claude worker comparing golden sheets with the board.

Facts from the golden renders (`mockup/bite-sized-label` 7e0fa87fb, reference only, never merged):
- Minutes are drawn at the surfaces in spec B1 plus `home_today_screen.dart:918` and `:928` and
  `home_today_checklist.dart:340` and `:584`; `plan_provider.dart:549` passes the value on.
- No screen draws a summed "minutes left" line today; `minutesLeftToRead` and the "about N minutes of
  material" text exist only in code. Remove that code; there is no visual change.
- There is no separate quiz intro. The "Quiz yourself, N questions" button in `reader_gap.dart` is
  hard-coded to 5; it shows `shown` from T9.
- A trailing label crowds phone rows (titles wrap and break mid-word); the board's layout options
  exist for that reason.

Then remove `estimatedMinutes` reads, the summed-minutes code, and the field from the export and the
content files in the same release.

### T11. Policy text (lead, 15 min, docs-only on main)

Update SUBAGENTS.md Part 4 step 4 and `docs/content/question-authoring-runbook.md` step 6: workers do
not approve; the lead approves with `approve.dart` after an independent re-solve. Quote the ruling.

### T12. Step 0 verification and handoff (Haiku 5.5 checks, lead, 1 h 30 min)

Full set on hosted CI for `web/bite-sized-r1`: `flutter test`, `flutter analyze`, `dart format`,
layering, attribution, `run_checks.dart`, Functions tests, web build, journeys. Locally: gate, size,
coverage and pool checks pass on main's `content/` and on the pilot root at its frozen revision (no
split yet). Hand the branch to the integrator for merge, staging, and prod after "ship it".

### T13. Split plans (Sonnet 5.5, 1 h 30 min; lead review 45 min)

On `content/bite-sized-pilot`. Data Interpretation (2 lessons) first, then the Constitution (10).
Per lesson: parts in order, each part's idea, key points, the examples and traps it takes, word
estimate, question-to-part-and-key-point map, pool gaps per exam, outline rows, prerequisite link
changes. Cut along the existing `###` subsections. The lead approves each plan before T14.

### T14. Rewrite into parts (Sonnet 5.5, 2 h 30 min)

New part files; originals get only `status: retired` and `replacedBy`; explicit `ordering` for the
topic; `tools/lesson_author/outline.json` rows; `lesson-prerequisites.json` updates. Gates: size,
nothing-dropped, `python3 tools/audit/run_all.py` with no rising AI-tell count, em dash 0.

### T15. Re-tag (deterministic script, Haiku 5.5 runs it, 30 min)

Script `tool/content/retag.dart` (written in T3's run or a short Codex Sol run) applies the approved
map: adds `lesson:` and `keyPoint:`, changes nothing else. Validator exit 0; pool check shows gaps only
where T13 said.

### T16. Pool gaps (Sonnet 5.5, two separate authors for every item, 1 h 30 min)

New questions only for key points without coverage. Constitution items cite the Article and Section;
two authors write independently and a third worker compares keys. SUBAGENTS Part 4 content rules
apply. `approved:` is not set by authors.

### T17. Answer verification (Sonnet 5.5, never an author, 3 h)

All 240 pilot questions plus T16's. Math: solve from the stem alone. Constitution: check each key
against the official text of the 1987 Constitution (Official Gazette), quoting the Article and Section.
Output per id: agree or disagree, with the quote or working. The lead rules on every disagreement;
Fable 5.2 high for hard cases. Record in `docs/content/verification/bite-sized-pilot.md`.

### T18. Approve and audit (lead 30 min; Codex GPT 6 Astra high, read-only, 1 h 30 min)

Lead runs `approve.dart` for agreed ids (`--moved` where only the lesson changed and a verified solve
exists). Audit: all disagreements, a 20% random sample of the rest, every new item, the law-text
quotes for the sampled Constitution items, the split diffs, and gate output. Findings return to T17
or T14. The pilot ends with zero pilot questions on legacy status.

### T19. Staging, rollback rehearsal, pilot check (integrator and lead, 1 h 30 min plus Aedwon)

All gates and the pool check pass on the pilot root. The integrator uploads the pilot content to
staging (Step 0 code already live there). The lead runs the rollback script once on staging, checks
credit and Home, then re-applies the split. Aedwon judges the pilot in the app on staging. Changes go
back to T13 or T14. Prod upload after his "ship it".

## Dependencies

| Task | Needs |
|---|---|
| T1 | T0 |
| T2, T3 | T1 |
| T4 | T2 |
| T5 | T0, T1 |
| T6 | T5 |
| T7, T8, T9 | T5 |
| T10 | Mockup ruling, T9 |
| T12 | T1 to T11 |
| T13 | T0 (can start alongside T1) |
| T14 | T13, T6 |
| T15 | T14, T5 |
| T16 | T15 |
| T17 | T15, T16 |
| T18 | T17, T3 |
| T19 | T12 shipped to staging, T18 |

Codex tasks run one at a time: T1, T2, T3, T4, T5a, T5b, T6, T7, T8, T9. Content tasks T13 to T17 run
on Claude workers in parallel with them.

## Estimate

| Part | Wall |
|---|---|
| Step 0 code, T0 to T9 and T11 | 12 h 30 min (Codex serial, each with a separate Sol review) |
| UI, T10 | 3 h after the ruling |
| Step 0 verification and handoff, T12 | 1 h 30 min |
| Pilot content, T13 to T18 | 11 h (overlaps the code work) |
| Staging and rehearsal, T19 | 1 h 30 min |
| Total through the pilot on staging | about 22 to 30 h wall, about 10 h of lead time; waits for the mockup ruling, the integrator and Aedwon not included |

Uncertainty: Codex limits can stall the serial chain; the Constitution law-text checks are new work
with no logged precedent.

## Stop conditions

SUBAGENTS Part 6 applies. Also stop and report when: the content branch head differs from the frozen
revision without a recorded reason; a split cannot meet B3 without cutting content; a legal key
disagrees with the law text and no source settles it; the content DB schemaVersion is not 10; a
collision lane has open changes on a file a task needs.

## Run log

Append here as tasks finish: revision, command, result, and the frozen legacy hashes.

- Nov 14: mockup. A golden-render prototype was built first (`mockup/bite-sized-label` 7e0fa87fb,
  `+30: All tests passed!`), but written rule 3 in `docs/workflow/process-improvement.md` requires
  decision boards in Claude Design. The lead's brief caused the miss and caught it before anything
  was shown. The renders stay as a reference for current content only; the decision board is the
  Claude Design artifact above.
- Nov 14: paused after the board (Aedwon: "don't do too many at once, mind my 5-hour limits").
- Nov 14: T0 done (Codex GPT 6.1 Sol, read-only, policy 2bfd34cb4). Findings:
  1. Stored roadmap days rebuild only when their digest changes; the digest hashes the seed version,
     topic scope, exclusions, settings, assessment and mock count, not lesson ids
     (`roadmap_providers.dart:365`, `roadmap_inputs_reader.dart:33`, `:269`). T8 adds the active lesson
     set to the digest.
  2. A missing lesson id shows "Lesson not found." on native and web (`lesson_page.dart:461`, `:590`).
  3. Quiz notes live in `attempts_local.itemsJson`, keyed by attempt and question id; mock notes by
     question id. No lesson-keyed notes.
  4. All six CET exams are enabled in `content/exams/catalog.json`; the content branch has no
     `content/exams`. Live prod selection was not queried.
  5. On the content branch, `lesson-prerequisites.json` maps lesson id to prerequisite lesson ids;
     `question-gap-tags.json` maps question id and wrong-choice text to a lesson id. T5 resolves both.
  6. Exporter tests: `test/tool/build_content_export_test.dart`,
     `test/tools/build_content_export_links_test.dart`; uploader contract test
     `test/core/content/remote/server_catalog_contract_test.dart` (skipped without compiled
     Functions). No workflow runs the uploader's node tests; T4 adds the gate test to CI.
  7. The content branch's tools differ from main's and it has no uploader; uploads use main's tools
     against the content root, as planned.
  8. The web content mirror never evicts a ready lesson (`content_mirror.dart:157`, `:423`); T8 makes it
     honor `status`.
- Lead ruling (gate, within B6): the legacy freeze records every question shipping at freeze time,
  including those marked `approved: true` in YAML (flagged `yamlApproved`), because no YAML approval
  was tied to a verified solve. Real approval records come only from `approve.dart` after an
  independent solve, and the split-subject rule forces them before any subject is split.
