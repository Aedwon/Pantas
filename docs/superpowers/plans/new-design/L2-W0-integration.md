# L2 W0: integration (question-qa-r2 merge and baseline)

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 24ce4a98.
Parent: `docs/superpowers/2026-10-05-engineering-restart-strategy.md` (B2, B4).
Spec: `docs/superpowers/specs/2026-10-05-new-design-amendment-design.md` (approved Oct 5).
Traceability rows: every row with workstream `W0` in `traceability.md`.

## 1. Purpose and scope

Bring the approved question QA round into `integration/new-design-r1` so every later workstream
builds on the content and data layer that will ship, and fix the content contracts every other
workstream consumes.

In scope:
- Merge `origin/content/question-qa-r2` (765c5dc0) into `integration/new-design-r1` (1f79d880).
  The merge base is 1f79d880, so this is a fast-forward of 214 commits.
- Rebuild the generated content outputs from the merged content: the dev seed (`assets/seed/v1.json`)
  and the protected content package (`content.db`, manifest, detached signature, next release
  sequence).
- Full required checks on the merged result; record the new baseline.
- Confirm data facts other plans depend on (section 4).

Out of scope: any application code change; content edits (the content track owns content); the
content coverage audit (separate track); the 134 questions the QA round flagged for Aedwon (content
track; their state is carried as-is).

Correction to strategy B1 (recorded in the decision record, Oct 6): question-qa-r2 changes no
application code. Its 328 changed files are question YAML (158 files), audit ledgers under
`docs/content/audit/question-qa-r2/`, one importer rule (`tools/import_questions/converter.dart`:
every wrong choice needs a non-empty rationale), its tests, and one test fixture.

## 2. Inputs

- Branch facts above, checked October 6 with `git diff --stat` against the merge base.
- Restart log: pause lifted for "merging the question-qa-r2 code" (Oct 5).
- `docs/content-key-access.md`: key access is not permission to rebuild the package; a rebuild
  changes artifact identity and invalidates affected stage evidence.
- Release-first cuts (Oct 1) and the E09 to E14 plans: content identity proofs (CP-T5) are redone in
  W5 on the new package.
- Traceability: G-a-18, G-b-11, G-b-12, G-b-13, G-c-28, G-g-21, G-h-27 and amendment B3 (recorded-only
  data).

## 3. Contracts owned

| Contract | Definition |
|---|---|
| Question file format | YAML per lesson at `content/questions/<subject>/<topic>/<lesson>.yaml`; `meta` has `subject`, `topic`, `subtopic`, `exams`; each question has `id`, `type`, `difficulty`, `stem`, `choices` (one `correct: true`; every other choice has a non-empty `rationale`), `explanation`; optional `passage`, `figure`, `shortLabel`. As enforced by `tools/import_questions` at the merged commit. |
| Lesson id on questions | `meta.subtopic` equals the lesson slug (lesson file `content/lessons/<subject>/<topic>/<lesson>.md`). A question's lesson is its file's subtopic. This settles amendment spec B5's open item: the lesson-scoped in-lesson quiz (W4c) keys on it. Checked Oct 6 on 765c5dc0: 158 question files, 158 lesson files, every question path matches a lesson path. W0 repeats the check on the merged tree. |
| Content package | Format v2 manifest, release sequence incremented by one from the shipped package, detached Ed25519 signature with key id `content-signing-v1`, built with `tools/build_content_package` and checked with `tools/verify_content_package`. |
| Data layer | Drift schema version 25 at the merged commit. No workstream changes it without a level 2 amendment naming the new version and its migration (SUBAGENTS Part 3). |
| Recorded-only data | Attempts keep per-answer response time and session timing; mistake tags keep `misread`, `slipped`, `unknown`, `other` plus optional text; mock review keeps blank reasons. Consumers delete widgets, never these writes or columns. |
| Offline posture | The rules in `2026-08-03-offline-and-network-posture-design.md` Sections 3, 5, 7 stay in force (no connectivity banner, no blocking spinner on local data, last entitlement stands on network failure). |

Contracts consumed: none.

## 4. Behavior

No student-visible change beyond the content itself: more questions (all 158 lessons have at least
20 active questions per the QA round) and corrected answer keys. Free and Pro rules unchanged.
No placeholder figures.

## 5. Motion

None.

## 6. Acceptance

Automated, on the merged and regenerated tree:
- `dart run build_runner build --delete-conflicting-outputs` exit 0.
- `flutter analyze`: only the known `onReorder` info (bookmarks sheet), which W2 removes.
- `dart format --output=none --set-exit-if-changed lib test` exit 0.
- `dart run tool/check_layering.dart` and `dart run tool/check_no_ai_attribution.dart` exit 0.
- `flutter test` all green (baseline was 3,403; expect more from the merged tests).
- Content gates from SUBAGENTS Part 4 over the whole corpus: validator 0, em dash 0, approved 0,
  noexams 0.
- `tools/verify_content_package` exit 0 on the new package; manifest release sequence is one above
  the previous package.
- `functions` tests (`node --test`) run once and recorded; they were not run in the Oct 5 baseline.

Aedwon: nothing visual. He authorizes the package rebuild (section 7).

## 7. Risks and stop conditions

- **Signing authorization.** Rebuilding the package uses the signing seed. Per
  `docs/content-key-access.md` this needs Aedwon's explicit permission. It is requested together
  with the start of level 4. Without it, W0 stops after the merge and the dev seed; the protected
  package rebuild waits.
- A merge that is not a fast-forward (the integration branch moved): stop and report.
- Schema version not 25 after the merge: stop.
- Any validator error, or an answer key change found outside the QA ledgers: stop and report to the
  content track; do not edit content.
- A failing test unrelated to content: stop (SUBAGENTS Part 6).
- Seed assets are gitignored; never commit them.

## 8. Files and directories

May touch: the integration branch history (the fast-forward), `assets/seed/*` (generated, not
committed), the build output directory, and the verification record in
`docs/superpowers/plans/new-design/` (L3 evidence section). No `lib/` or `test/` edits.

## 9. Order and parallelism

First workstream in level 4. W1 and W3 start only after W0's checks pass and the new baseline SHA
is recorded.
