# Question generator Phase 2: app and server plan

Date: November 28, 2026. Lead: question generator lead (Opus 5.5, fresh session), reporting to the
operations manager. Policy read at `origin/main` 3ce9b32ca (`AGENTS.md`, `WORKFLOW.md`,
`SUBAGENTS.md`, `docs/workflow/process-improvement.md`, the Nov 27 PSHS-NCE resume handoff).
Velocity row: E-214 (this build; replaces E-127, which was logged only on this branch and never
started). Status: plan only. Nothing in Phase 2 is built. Building starts only after the manager
has this path and says go.

Controlling documents, in order: spec `docs/superpowers/specs/2026-11-17-question-generator-design.md`
(Part A approved Nov 17, Revision 1); decision log `docs/superpowers/decisions/2026-11-17-question-generator-log.md`;
the Phase 1 plan `docs/superpowers/plans/2026-11-17-question-generator.md` (Part 3 formats, Phase 2
tasks 2.1 to 2.9); the code map and binding lead rulings L1 to L10
`docs/superpowers/verification/question-generator/p2-map.md` (Nov 21). This plan replaces the Phase 1
plan's Phase 2 section where they differ. Part A of the spec is unchanged.

## 1. What changed since the Nov 21 map

- The app opened to the public on Nov 28, 12:05 AM Manila. Real students now have answers, review
  state and synced devices, and installed web clients built from older main heads exist. L7 (old
  clients must not break) and acceptance B10.4 and B10.5 (no regression, carry-over) are now about
  live accounts, not testers.
- Main moved 1,010 commits past the map's base 0172e8dfb. Study Drift is still schema 26 and content
  Drift still 11 (checked on `origin/main` 8a26ed3b7). Files the families own that changed since:
  `functions/src/contentUpload.ts` (+256 lines: exam summary documents, batch retry),
  `tools/upload_content/` (upload budget check), `functions/src/_examContent*.ts`,
  `lib/features/mock_exam/presentation/*`, `lib/features/quiz/presentation/quiz_page.dart`,
  `functions/src/studyObservations.ts`, question reports, payments. Each family re-reads its files on
  the new base before writing; the map's line numbers are stale.
- Phase 1 final state (Nov 28 review): 28 approved types, 2,094 variants. Both held types stay held
  this cycle (section 9). Phase 1 merges to main before Phase 2 code starts.
- Pace (Aedwon, Nov 28: "obviously i want you to slow down"): this lane runs at most 1 Claude worker
  at a time; Codex runs only through `codex-pick`, one run at a time across all lanes, account b only.
  On Nov 28 account b showed 48% weekly used, reset Dec 4.

## 2. Global constraints (binding on every family)

- No UI change. Figure-choice tiles already exist on main (150afa3ce); this build only fills their
  fields. A worker that finds a screen file must change stops and reports.
- L1 to L10 in the map are binding. L4 replaces plan Task 2.4: served state is derived from answer
  records that already sync; the local review row keeps `servedVariantsJson` as a cache only;
  `fsrs_cards` gains no field.
- Tests first, failing for the expected reason, per `SUBAGENTS.md` Part 3. Schema bump and migration
  in the same commit; confirm the current value first (26 study, 11 content) and stop if it differs.
- Generated files are regenerated, never hand-edited (`*.g.dart`, `*.freezed.dart`,
  `functions/src/generated/pantas_core.js`).
- Files only with the Edit or Write tool. Bash for plain read-only commands, existing tools with plain
  arguments, and git. No heredocs, redirection to files, `sed -i` or scripts (the project hook
  enforces this for Claude; briefs say it for Codex). Every `codex-pick exec` closes its input
  (`< /dev/null`).
- Rule 7: no run against a hosted project without a written count of its reads, writes and egress
  added to that project's use for the day; staging budget 40,000 reads and 16,000 writes per day
  across lanes. Every upload-tool run counts 1,500 reads; at most 3 runs per project per item.
- Loop cap: each family gets at most 2 independent full reviews. A family that fails its second
  stops and goes to the manager with options and costs.
- Rule 9: this build adds one stored item about a student, the variant index on each answer. It is
  study data of the kind already collected (which question, which choice), not a new category. The
  lead states this in the handoff so the manager can confirm no privacy email is needed.
- No staging or prod deploy by this lane. The integrator deploys; prod waits for Aedwon's "ship it".
- Commits explain why and carry no AI attribution.

## 3. Branch and base

1. Phase 1 (`gen/question-generator-r1`) merges to main first (handoff in the Nov 28 decision log).
2. This branch, `gen/question-generator-app-r1`, then merges `origin/main` (it holds only the map,
   briefs and this plan beyond the Phase 1 merge). Expected conflicts are the append-only logs; take
   the union. Every family worktree branches from that merge.
3. Hosted CI runs the full check set on the pull request into main (`WORKFLOW.md`).

## 4. D-P1: which generated types serve PSHS-NCE

Ruling (manager, rule 4, Nov 28; launch log on main): A for practice and review now. Types take exam
tags at export from their sources' current file tags, plus `pshs-nce` for the 8 lessons that have
PSHS-NCE questions (about 1 h, in F1). Reserved: the PSHS-NCE mock. Four-choice types stay out of
the PSHS-NCE mock and do not count toward the "+90 abstract" pool until the PSHS-NCE content lane
confirms the exam format and pool count, decided before Phase 3. B stays the fallback.

What the ruling adds to the families: F4 (native Mock sampling) and F6 (server Mock assembly) leave
type rows out of a `pshs-nce` mock, behind one switch the later decision flips; a test on each side
proves a PSHS-NCE mock paper holds no type id while PSHS-NCE practice does. About 1 h more.

The options as put to the manager:

D-P1. Which generated types serve PSHS-NCE. Today all 28 types carry the exams `acet, ustet,
dost-sei, cse-pro`. None carries `pshs-nce`, so after Phase 2 a PSHS-NCE student would get no
generated types at all. The PSHS-NCE abstract questions on `content/pshs-nce-r1` sit in the same 8
lessons as the types but use 5 choices; the types use 4. Also, the live source files now tag
`acet, dost-sei, cse-pro, dlsucet` (no `ustet`), so the types' tags have drifted from their sources.

- A (recommended): types take their exams from their sources' current file tags at export, plus
  `pshs-nce` for every type whose lesson has PSHS-NCE questions (all 8 lessons today). PSHS-NCE
  students get the 28 types in practice, review and the mock with 4 choices beside 5-choice singles.
  Cost: about 1 h (an export rule and a test; no type file edit, so no re-approval). Limit: mixed
  choice counts in the PSHS-NCE abstract test.
- B: A, plus a fifth choice per type for PSHS-NCE (a fifth named mistake per type, regenerate,
  checker, blind solve, audit). Cost: about 2 to 3 days of Codex and review, and a new audit round
  for every type. Puts the early-January date at risk.
- C: types stay off PSHS-NCE. Phase 2 meets the pricing gate's wording but gives PSHS-NCE students
  nothing from it.

This is the manager's ruling, or Aedwon's if the manager reserves it. It also settles whether the
types count toward the PSHS-NCE abstract pool of 150 questions per test (the content plan's "+90
abstract"). Under A, each type serves a new version in each of the three planned mock attempts, so
the lead's view is that each type counts as one question toward the pool; the PSHS-NCE content lead
should confirm when that lane resumes.

## 5. What this lane needs from the paused lanes

Phase 2 code depends on neither paused lane. Phase 3 (PSHS-NCE on prod) depends on these pieces:

From PSHS-NCE content (paused):
- The exam roster fix (`tools/pshs-nce-export-roster` ecaf38861, tests never run). Without a
  PSHS-NCE exam entry in the export, nothing tagged `pshs-nce` reaches students, types included.
  Latest date without slipping Dec 17: merged to main by Dec 10, so the Phase 3 release root
  (cut about Dec 11) carries it into the Dec 12 staging run.
- The exam format and pool count for the reserved mock question (D-P1). Not on the Dec 17 path:
  types stay out of the PSHS-NCE mock until it is answered. Needed before the PSHS-NCE mock file
  ships, which is that lane's own date.
- Nothing else. The `-pshs` question files stay singles; no type is built from them this cycle.

From under-13 (paused):
- No code dependency. Shared-file watch only: `firestore.rules`, `functions/src/index.ts`, the study
  Drift schema (both branches at 26; whichever lands second takes the next number), and
  `deleteUserData` (this build adds no new per-user document under L4, so it needs no deletion
  change; the Answers family confirms).
- The sale itself needs under-13 accounts, PSHS-NCE content and this build together.

## 6. Families

Each family: one worktree, one builder, tests first, focused checks, then one independent review.
Builder choice per family is in section 7. File lists are starting points from the map, re-read on
the new base; a needed file outside the list is reported, not silently touched.

### Wave 1 (in sequence under the pace limit, in this order)

F1. Export and upload (plan Task 2.1, L1, L2, L7). Files: `tools/build_content_export/`,
`tools/build_content_seed/seed_writer.dart`, `tools/build_content_package/`,
`tools/upload_content/upload_content.mjs`, `functions/src/contentUpload.ts`, their tests.
- One logical record per enabled type feeds both adapters. Native: a type row with `_id`, references
  and portable text, plus the variant payload in protected storage. Web: the type row joins the
  question set of its lesson; one Free variant document at `content/variants/items/{typeId}`; Pro
  notes at `contentPro/{typeId}` keyed by `variantIndex` and source-order choice position.
- Active state computed once (L2) and written explicitly on web upserts. Test both directions on
  both adapters.
- Rendered values per variant (L1). Free variant document under 200 KB, enforced at export; record
  the largest real size. Test that a Free read never receives a note.
- Old clients (L7): a test runs current-main client parsing against the new export; if an old
  client would show a type row as a question, rows carry a form old clients skip. Record the result.
- Exam tags per D-P1, behind one function so the ruling changes one line.
- The upload budget check and summary batching on main stay intact; their tests pass.

F2. Content resolve (plan Task 2.2, L3, L6). Files: `lib/core/storage/domain/` (new
`resolve_variant.dart`, `choose_variant.dart`), `lib/core/content/` tables, parser, mirror, cache,
service, `question_set_mapper.dart`, `lib/core/content/repos/question_repo.dart`,
`lib/core/storage/data/repos/content_repository.dart`.
- `resolveVariant` and `chooseVariant` as L3 signatures, pure Dart, VM and JS byte fixtures.
- Content Drift 11 to 12 if variant records live in Drift (map section 8); fresh and migrated
  databases tested, and the protected package install checks the new user version.
- Persist the three figure-choice fields on the web mirror, native parser and both hydration paths
  (map section 3 gap).
- Choice order for type rows seeds by `'$questionId#$variantIndex'`; singles unchanged. Test the key
  reaches every position across one type's list.
- L6: a type with no variant document or an index outside its list is never shown.

F3. Answers and review cache (plan Task 2.3, L4, L5). Files: `lib/core/storage/domain/attempt.dart`,
`review_state.dart`, the review table, `app_database.dart` (study schema 26 to 27), quiz session
and outcome codecs, `submit_answer.dart`, `complete_quiz.dart`, `complete_assessment.dart`,
`mock_answer_recorder.dart`, `mock_session_snapshot.dart`.
- `variantIndex` (nullable) on attempt items, Mock answer maps, active session state and web study
  observations. Old JSON reads unchanged.
- `servedVariantsJson` cache column, default `{}`, rebuilt from answers on migration and after pull.
- L5 pinning: chosen at serve time, kept through resume and retry, counted served only on submit.
- Migration test from schema 26 with existing rows.

### Wave 2

F4. Selection (plan Task 2.5). Every serve route in map section 4 calls `chooseVariant` for type ids
and resolves before display: Today and review, Practice (never met first, then the 7-day rule, then
fewer answers), Drill (never met first), in-lesson quiz (one per key point, never met first inside
it), Retake (a new variant of each missed type), Quick Quiz, assessment, native Mock. Roadmap,
scheduling, mastery, follow-ups and "why you miss" keep their logic. Past-answer screens resolve the
answered `variantIndex`.

F5. Sync (L4, reduced plan Task 2.4). The attempt and Mock mappers carry `variantIndex` inside the
existing JSON. After a pull, rebuild the served cache. Tests: two devices serve different indexes
offline and both see the union after sync; an offline device never picks an index the other served
before the last sync; an old-client rewrite of a review document loses no served state.

F6. Server (plan Task 2.6, server half; L8, L9). Files: `functions/src/_answers.ts`,
`ingestSession.ts`, `serverReviews.ts`, `mock.ts`, `mockAnswers.ts`, `content.ts`,
`_contentCeiling.ts`, `roadmap.ts`, `_answerTotals.ts`, `sessionDiagnosis.ts`, `server_dart/`,
the regenerated `pantas_core.js`, fixtures, `firestore.rules` only if a document needs it.
- Answers keep `variantIndex`; ingestion rejects an index outside `0..variantCount-1`.
- `getContent` delivers the variant kind, counted in the per-account and global delivery limits;
  Pro notes joined by `variantIndex`.
- Mock papers pin the index. Diagnosis looks up notes by variant, not only by choice id.
- Regenerate `pantas_core.js`; `server_dart/build.sh --check` byte comparison passes; fixtures
  cover each new bridge operation.

### Wave 3

F7. Carry-over alias (B3.9, plan Task 2.6 app half). Old ids in `mergedQuestions` map to (type id,
index) at read time for attempts, review state, answer totals, roadmap completion, metrics and
diagnosis, on device and server. The type takes the review state of the most recently answered
merged question; answered merged indexes count as served. Rollback (`enabled: false`) restores the
old ids untouched. Tests on copies of real account shapes (test data only; logs are public).

F8. List use (plan Task 2.8). `tool/generator/bin/list_use.dart`, offline fixture tests only. Prints
per type the highest share of its list any student has used; flags over 70%. Hosted reads only on
demand in the manager's sweep, after a rule 7 count.

F9. Free-tier count (plan Task 2.7). Lead plus one reader. Per student per day: extra reads (variant
documents, review items), stored bytes, egress; both projects together; the staging run's count
written before any staging step.

## 7. Who builds and reviews

- Builders: Codex GPT 6.2 Sol at low effort through `codex-pick` for F1, F6 and F8 (TypeScript,
  tools, server Dart); a Sonnet 5.5 worker for F2, F3, F4, F5 and F7 (app Dart), one at a time.
  If Codex has no room, a Sonnet worker takes the next family instead of waiting.
- Reviewers: the other vendor from the builder. Codex GPT 6.2 Sol high reviews the Sonnet families;
  a Sonnet reviewer, then the lead, reviews the Codex families. At most 2 full reviews per family.
- The lead reviews every diff against this plan's file lists, runs the family's focused checks
  itself, commits, and pushes. Workers stage and commit nothing.
- For each Agent-tool worker, the lead also starts a background wait on its result and registers it,
  so a finished worker is never left idle (Nov 26 entry).

## 8. Verification

Per family: its own tests failing first, then `flutter analyze` on touched paths, `dart format`,
and for server work `npm run build && node --test test/*.test.mjs` and the emulator suite from
`functions/`.

Combined, before the integrator handoff: the full check set on hosted CI on the pull request
(analyze, format, layering, attribution, full test suite, web build, functions plain and emulator,
`dart run tool/checks/run_checks.dart`); `server_dart/build.sh --check`; then one combined
independent review of the whole diff.

Phase 3 acceptance (staging, by the lead after the integrator deploys): spec B10.1 to B10.9 with
scripted test accounts; B10.4 and B10.5 on copies of real account shapes; before and after daily
new-question counts for the merged lessons; the old-client check on a build of the current prod
main head.

## 9. Phase 1 held types (lead rulings, Nov 28)

- series-fill-ray-dots stays held this cycle. Its index 0 must equal live figure-series 0018, whose
  "full" distractor cannot be the literal sum the new accumulate-fill rule computes (three-quarters
  plus one-half). A capped sum would reproduce it, but that is another rule change and another
  audit round for one question. The live question stays a single.
- matrix-ray-intersection stays held this cycle. Its Nov 28 audit (audit-h2) found six Blockers, each a further competing
  rule after the held2 fixes, as every earlier read did. Under the loop cap it gets no further fix
  round in this cycle. The live question figure-matrices 0009 stays a single.
- The held2 library and checker improvements still merge: they only add rules, and all 28 active
  types pass with them.

## 10. Estimate and dates

| Step | Wall (target) | Lead active |
|---|---|---|
| Phase 1 merge to main (integrator) | Nov 29 to Dec 1 | 0.5 h |
| Wave 1: F1, F2, F3 | Nov 30 to Dec 4 | 5 h |
| Wave 2: F4, F5, F6 | Dec 4 to Dec 9 | 5 h |
| Wave 3: F7, F8, F9 | Dec 8 to Dec 10 | 3 h |
| Combined CI, review, integrator handoff | Dec 10 to Dec 11 | 1.5 h |
| Phase 2 total (E-214) | about 9 working days | about 15 h |
| Phase 3: staging acceptance, prod on "ship it" | Dec 12 to Dec 17 | separate row at start |

Reasons for the wall time: families run one after another, not in parallel (one Claude worker, one
Codex run across lanes), and each needs a review round. Past Codex-built rows ran at 0.1 to 0.3 of
their estimates, but those ran several workers at once; this one cannot. Uncertain: Codex room
before the Dec 4 reset, the old-client result in F1, and the carry-over tests on real account
shapes.

## 11. Can Phase 2 be live by early January?

Yes, with about three weeks of margin, if three things hold: the families run without a third
review round, the integrator has a slot for the main merge and the deploys around Dec 11 to 17, and
Codex or Claude room lets one family run at a time. By the Dec 8 go/no-go, waves 1 and 2 should be
built and reviewed and the Phase 3 date firm. The generator is not the riskiest sale item; PSHS-NCE
content and under-13 accounts are, and both are paused.

## 12. Risks

- Old installed web clients meeting type rows (L7). Mitigation: F1's old-client test, release order
  app and functions first, then content with types enabled.
- A defect in answer recording on live accounts. Mitigation: B10.4 and B10.5 on real account
  shapes before prod; rollback by `enabled: false` and a content upload; nothing deleted.
- Collisions with other lanes on `contentUpload.ts`, the upload tool and Mock pages, all of which
  changed this week. Mitigation: rebase each family on the newest main before its review.
- Free tier: variant documents add delivered documents and reads on web. F9 counts before staging.
