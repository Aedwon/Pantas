# Stage 0 step 2: kept-work inventory (read-only)

Policy revision read: origin/main 6d508d70. One `git fetch origin` run first.
Integration target (INT): origin/integration/new-design-r1 1f79d880. Main: origin/main 6d508d70. QA: origin/content/question-qa-r2 765c5dc0.

Method: "contained" means every commit is an ancestor of INT or main, or has an equal patch (git cherry). Where a dirty file or an old commit was not patch-equal, I compared file content against INT directly. Snapshots of every dirty worktree (tracked diffs, untracked files) and stash 0's spec are saved in `snapshots/` next to this file, so any DISCARD below is recoverable.

Totals (rows, where a row may group several refs): KEEP 6, DISCARD 30, ASK 7. See the Summary table at the end.

---

## Not triaged (active tracks, state only)

| Item | Tip | Date | State |
|---|---|---|---|
| worktree docs/content-coverage-audit-r1 | 401968b6 | 2026-10-05 | 1 untracked file (docs/content/exam-format-profiles.md). 48 commits not in main, local equals origin. |
| worktree integration/new-design-r1 | 1f79d880 | 2026-10-01 | Clean. Equals web/roadmap-engine-r1. |
| worktree web/roadmap-engine-r1 | 1f79d880 | 2026-10-01 | Clean. |
| content/question-qa-r2 | 765c5dc0 | 2026-10-03 | Clean worktree. 214 commits not in INT or main. Local equals origin. Merge base with INT is 1f79d880. |
| content/question-qa-r2-math, -other, -science | 0e9cca17, 25b4e45f, 1e40ca47 | 2026-10-03 | Clean worktrees. Each is fully contained in question-qa-r2 (0 commits ahead). Local equals origin. |

---

## A. Worktrees (main checkout is clean on main 6d508d70, nothing to inventory)

| Name | Tip | Last commit | Dirty files | Unique work and INT comparison | Rec |
|---|---|---|---|---|---|
| Pantas-wt-beta-final-verification-r1 (web/beta-final-verification-r1) | 21f40b68 | 2026-09-01 | 38 modified (lib/app, core/auth, core/sync tests, mock_exam, dev_demo_switch) | Tip is contained. The uncommitted 612+/422- diff is an analyzer and format repair pass on the 1 Sep beta state: import sorting, line wraps, lint ignore comments, small test tidy-ups. INT already carries the repaired versions: lib/app/firebase_bootstrap.dart has the one_member_abstracts ignore, lib/core/dev/dev_demo_switch.dart is formatted, lib/app/router.dart has no mock_review_page import. 11 of 38 files are byte-identical to INT. The other 27 differ because INT is later (for example mock_start_route.dart was rewritten). This uncommitted work exists nowhere else, but it is clearly superseded. | DISCARD (snapshot saved) |
| Pantas-wt-web-e04-content-protection-r1 (web/e04-content-protection-r1) | 8d556f6a | 2026-09-07 | 10 modified, 1 rename, 13 untracked (content_package_manifest, content_signing_keys, tools/build_content_package, tools/verify_content_package, tests) | Tip is contained. The uncommitted work is an early draft of signed content package build and verify tooling. INT has the finished version: commit 1844f746 "complete protected install migration" adds lib/core/content/security/{content_package_manifest,content_package_verifier,content_signing_keys,content_key_store}.dart, tools/build_content_package/build_content_package.dart, tools/verify_content_package/verify_content_package.dart and tools/build_content_export/historical_v1.json (the same rename). Draft files differ from INT because INT's are later and larger. Exists nowhere else, but clearly superseded. | DISCARD (snapshot saved, minus the 300k-line JSON) |
| Pantas-wt-qlp5-physical-r1 (detached) | 9f7a2da1 | 2026-09-15 | 12 modified, 10 untracked temp files | Tip is contained in INT. The 12 modified files are the quiz launch performance work: batched topic queries in content_repository, prepared-next-question in quiz_controller, assessment selector, custom-track assessment completion. 7 are byte-identical to INT and INT has the same functions (selectionRowsByTopics, markQuestionPrepared). The rest are old-base differences (INT has the newer code) plus three throwaway Android flavors (qlp5, e09fresh, e09verify) and a /plan route that the roadmap work replaced. The 10 untracked files are physical-phone benchmark harnesses: 6 integration_test/release/*_temp.dart, test_driver/ (2 drivers), tools/local/ (3 Python runners), lib/core/ui/components/qlp5_probe_temp.dart, lib/main_cp5_keyloss_temp.dart. These exist nowhere else. | ASK: tracked changes are safe to drop. Untracked harness is throwaway by name but is the only phone-timing tooling; it could feed W5 phone checks (E09 #22 to #28) if wanted. |
| Pantas-wt-web-release-e2e-firebase-r1 (web/release-e2e-firebase-r1) | 5e69e73f | 2026-09-06 | 4 untracked sources (plus functions/node_modules, regenerable) | Tip contained (equals release-e2e-mock-r1). Untracked: integration_test/release/firebase_conflict_isolation_e2e_test.dart (218 lines), firebase_sync_roundtrip_e2e_test.dart (138), support/firebase_emulator_harness.dart (402), test/tool/release_e2e_firebase_contract_test.dart (130). Emulator-based sync end-to-end tests. None exist in INT (INT's integration_test/release has only delete_local_data, qlp5 rehearsal and support helpers). | KEEP, W5 (E10 to E14 release checks; retarget to new screens) |
| Pantas-wt-web-release-e2e-mock-r1 (web/release-e2e-mock-r1) | 5e69e73f | 2026-09-06 | 1 untracked | integration_test/release/mock_resume_e2e_test.dart (184 lines): mock exam resume end-to-end test. Not in INT. Mock routes change in W4e. | KEEP, W5 |
| Pantas-wt-web-release-e2e-quiz-delete-r1 (web/release-e2e-quiz-delete-r1) | a8c98f6a | 2026-09-07 | 1 untracked | Branch commit is patch-contained in INT. Untracked integration_test/release/quiz_state_e2e_test.dart (343 lines): quiz state and local-data delete end-to-end test. Not in INT. | KEEP, W5 |
| Pantas-wt-web-release-e2e-shipping-r1 (web/release-e2e-shipping-r1) | 60808974 | 2026-09-06 | 1 untracked | integration_test/release/shipping_cold_start_e2e_test.dart (365 lines): cold start of the shipping build. Not in INT. | KEEP, W5 |
| Pantas-wt-a11y-inline-math-sentence-r1 (codex/a11y-inline-math-sentence-r1; also origin) | b58639aa | 2026-09-23 | 1 modified (test/core/ui/components/math_accessibility_test.dart, +70/-4) | Branch carries a test commit and a merge. INT already has the behavior (lib/core/ui/components/inline_math_text.dart has the sentence Semantics with excludeSemantics) and the sentence regex tests. The dirty diff adds extra assertions: no duplicate focus node for inline formulas, painted-height check. Uncommitted, exists nowhere else. Not obviously superseded. | ASK (lean KEEP as a note for W2 math rendering accessibility tests; 70 lines) |
| Pantas-wt-android-release-swiftpm-r1 (codex/android-release-swiftpm-r1) | 3561a7de | 2026-08-28 | pubspec.lock only (meta 1.18.0, test_api 0.7.11) | Tip contained. Lockfile drift from a local `pub get`. Same change sits in stash 0. | DISCARD (generated drift) |
| Pantas-wt-rc-be-verify-r2 (detached) | e9f9ad65 | 2026-09-04 | ios Package.resolved (removes csqlite pin) | Tip contained in INT. Xcode-generated file edit. | DISCARD |
| Pantas-wt-beta-integration-r1 (beta/integration-r1) | 0f69e79c | 2026-09-04 | clean | Tip contained in INT. Combined beta candidate (RevenueCat repair + mock resume repair), all in INT. | DISCARD |
| Pantas-wt-mock-resume-correctness-r1 (codex/mock-resume-correctness-r1, local only) | 7a05a297 | 2026-09-05 | clean | One doc commit: a 92-line checkpoint recording the mock resume candidate. The code repair itself is in INT. The doc is process history. | DISCARD |
| Pantas-wt-web-e09-product-defects-repair-r1 (web/e09-product-defects-repair-r1, local only) | 537e5f07 | 2026-09-10 | clean | 1 commit, patch present in INT (git cherry shows no unique patch). | DISCARD |
| Pantas-wt-web-e09-product-defects-repair-r2 (local only) | e3eb3062 | 2026-09-11 | clean | 1 commit, patch present in INT. | DISCARD |
| .claude/worktrees/lesson-illus-w4verify (codex/lesson-illus-w4verify, local only) | 9704a1bd | 2026-08-22 | 1 modified (docs/content/audit/sweep-results.tsv, regenerated), 5 untracked (tools/audit/review_w4.py, review_w4_2.py, w4_figures.json, w4_summary.txt, w4_summary2.txt) | Tip contained. Untracked files are one-off scratch dumps and scripts used to eyeball Wave 4 lesson figures (for example the spring and stability figure descriptions). The lesson illustration work was finished and approved in INT (fdda8766 final visual approvals, 5305008f pass 3 repairs). Exists nowhere else but is throwaway analysis. | DISCARD (snapshot saved) |
| .claude/worktrees/lesson-illus-w5a (local only) | 24627abd | 2026-08-22 | clean | 3 commits: strict founder metadata and Commons-only upload checks, purge of invalid open-A assets. INT has later equivalents (for example e6a7949f "restrict Wikimedia uploads to Commons"). 16 of 19 files identical to INT. | DISCARD |
| .claude/worktrees/lesson-illus-w5b (local only) | 2861a8c4 | 2026-08-22 | clean | 2 commits pruning invalid open-B assets. 21 of 22 files identical to INT. | DISCARD |
| .claude/worktrees/lesson-illus-w5verify (local only) | ea839f03 | 2026-08-22 | clean | Merge of w5a, w5b and the Commons-only fix. Fix is in INT as e6a7949f. | DISCARD |
| .claude/worktrees/m7 (wt-m7) | 33f678c3 | 2026-08-13 | 1 modified (content/questions/mathematics/geometry/basic-geometric-concepts.yaml, +166) | Adds answer rationales to geometry questions. INT already has 45 rationales in that file (11-line difference), and question-qa-r2 has 60 and rewrites them. Exists nowhere else but clearly superseded by QA r2. | DISCARD (snapshot saved) |

---

## B. Branches with commits not contained in INT or main

Branches that have a worktree above are not repeated except where they share a tip name. "Local+origin" means both refs exist at the same tip unless noted. Local-only refs are marked.

### B1. Real or possibly unique work

| Name | Tip | Last commit | Unique work | INT comparison | Rec |
|---|---|---|---|---|---|
| web/beta-salvage-assessment-cache-r1 (local+origin) | 57d52478 | 2026-08-31 | 2 commits, 5 lines in assessment_page.dart: after finishing a custom assessment, also invalidate countForExamProvider, sessionPanelProvider and todayInputsProvider so the Today and Quiz panels refresh. The same hunk sits in stash 1. | INT lib/features/assessment/presentation/assessment_page.dart lines 113 and 114 invalidate only the two assessment providers. The fix is not in INT. Those providers still exist in INT (storage.dart, quiz/presentation/today_providers.dart). | KEEP, W4d (Quiz tab). Carry as a 5-line note; confirm the bug after the tab is rebuilt. |
| backup/pre-attribution-rewrite (local only) | 89725d03 | 2026-10-05 | 12 docs commits from 4 to 5 Oct (pricing, giveaways, short public ID, Clarity handoff, restart plan). Every patch is in main, so no content is lost. | Contained in main by patch, not by ancestry; it is the pre-rewrite copy of those commits (author rewrite). | ASK: delete only after you confirm the attribution rewrite is final. |
| web/beta-consolidation-planning-r1 (local+origin) | 532e17fe | 2026-09-07 | 15 docs commits, 1950 lines: beta consolidation plan, preservation ledger, release hardening continuation, E2E repair wave checkpoint, decision log. | None of the new files exist in INT or main. Process history from the pre-restart beta effort, superseded by the restart strategy. | ASK (history only; DISCARD is probably safe but it is the one record of the beta preservation audit). |
| web/ios-physical-qa-enablement-r1 (origin only) | ff0400fd | 2026-09-15 | 2 commits: approved design (about 400 lines) and decision log for making one physical iPhone a dev and QA device. Implementation not started. | Not in INT or main. Not named in W0 to W5. | ASK (belongs to W5 phone checks only if iOS QA stays in scope). |
| web/landing-design-contract-r1 (origin only) | 1308a900 | 2026-09-01 | 6 docs commits: landing page product context, design contract (Quiet Editorial), frontend workflow, IA decision (coaching journey backbone), hero direction. | Not in INT or main. Public marketing site, separate from the app and from W0 to W5. Visual rules there predate the new design. | ASK (not in any W workstream; keep the narrative and IA decisions, visual part likely superseded). |
| web/lesson-illus-visual-review-ledger (origin only) | 030fcb8a | 2026-08-25 | 14 commits, 4 docs (441 lines): per-figure visual review ledgers for passes 1 to 4. | docs/content/illustrations/visual-review-ledger*.md do not exist in INT. The outcomes are applied in INT (pass 3 repairs, final approvals). | ASK (review record only; DISCARD is probably safe). |

### B2. Contained by patch or superseded (DISCARD)

| Name(s) | Tip | Last commit | What it was | Why safe |
|---|---|---|---|---|
| codex/a11y-w1-mock-progress, -onboarding-settings, -shared-harness, -study-quiz (local+origin) | 548937a7, 6bec0ca1, 0d0ccd96, 79a05ffa | 2026-08-27 to 28 | One accessibility commit each. | git cherry shows every patch is in INT. |
| web/e09-issue25-zero-content-exams-r2, web/e09-issue26-carryover-sheet-r1 (local+origin) | 99628137, b284457b | 2026-09-14, 15 | E09 defect fixes. | Patch-equal commits are in INT (cherry shows no unique patch). |
| web/release-e2e-firestore-reset-r1 (local+origin) | 4fe4d07a | 2026-09-07 | Release E2E Firestore reset helper. | Patch in INT. |
| origin/content/static-question-pipeline | 42fec462 | 2026-07-31 | 627 commits of the old question pipeline. | Every patch in INT and main. |
| origin/wt-content02c | ee653b72 | 2026-08-11 | 1246 commits, old content branch. | Every patch in INT and main. |
| origin/codex/lesson-illus-w4-commons-four, origin/web/lesson-illus-w8-audit-gates | 478f887c, dabdfae2 | 2026-08-23 | Illustration wave commits. | Patch in INT. |
| track-a-salvage (local+origin) | efd38190 | 2026-08-10 | Custom-track storage migration at schema version 20 (track_scope_local_table, custom_track_migration_test) and a dispatch log note. | INT has the same files at schemaVersion 25 (lib/core/storage/data/app_database.dart line 77), including tables/track_scope_local_table.dart and the migration test. |
| web/beta-salvage-science-s4-r1 (local+origin) | f8ef0517 | 2026-08-31 | 42 rationales for characteristics-of-life.yaml. | INT and main already have 42 rationales in that file. question-qa-r2 has 60. |
| wt-m7 (local+origin, tip 33f678c3, 2026-08-13), wt-m8 (local+origin, tip b63818aa, 2026-09-23) | as listed | | Rationales for 4 precalculus files (limits, derivatives, integrals, conic sections). | INT has 42 rationales in each; wt-m8 is within 4 to 11 lines of INT. question-qa-r2 has 60 and supersedes. |
| docs/ssot-development-checkpoint-2026-09-07 (origin only) | 77d5944d | 2026-09-07 | 7 Sept SSOT checkpoint and ordered beta plan. | Both files exist in INT with later edits (b0f736a4 and others). |
| web/e03-e14-contract-correction-r1 and web/e04-protected-install-migration-r3 (local+origin, same tip) | b19cee3c | 2026-09-08 | 27 files of 3-line "E04 R3 branch/stop marker" docs. | Noise. The real E04 R3 plan, spec and decision log are in INT under docs/superpowers. |
| Lesson illustration waves: codex/lesson-illus-r1-original-figure-repairs (e06b4d44), -r2-format-only (41bbdc09), -w1-strategy-contract (c386c5a2), -w2-original-code-a (0e573d4d, 35 commits), -w2-original-code-b (d96e96e2, 20), -w3-figure-registry (4331dd6b) (local+origin) | as listed | 2026-08-22 to 23 | Intermediate waves of the lesson figure work (strategy, code, registry, factual repairs). | INT has the finished product: merge 45aaf05a and fdda8766, pass 3 repair set 5305008f, audit migration fix e752b345. The last commits in these branches (for example Kepler geometry, moon phase, pH reference, chemical bonding prose) touch files INT has since changed. Spot-checked: INT figure files are later versions. |
| codex/lesson-illus-v2-reverify, codex/lesson-illus-v4-final-local (local+origin) | 89e01d86, 73fddd7e | 2026-08-23 | 23 and 13 commits of orchestrator logs and verification evidence (.web-orchestrator/results). | Evidence output only; no product code. |
| web/lesson-illus-w10-{biology,chemistry,earth,energy,mechanics,reading}-fixes, w11-{biology,chemistry,earth,energy,mechanics}-fixes (local+origin where noted) | 359928c2, 29b55af0, f9e09ff3, 2eb757ee, ad4304d0, b77afa9a, 84a5089c, 76103556, 95d427e1, 13af640c, 63f82fb3 | 2026-08-24 | One visual-review fix commit per figure family. w10-reading and all w11 are exactly in INT. w10-biology, -chemistry, -earth, -energy, -mechanics are superseded: INT's 5305008f (2026-08-25, "finish pass 3 repair set") rewrote the same figure files. | Superseded. |
| web/lesson-illus-w7-preview-ci-only, w7-review-ci-only, v3-pro-verify-ci-only, w8-integration-ci-only, w8-audit-gates-ci, w8-audit-gates-ci-red, w8-review-ui, w8-review-ui-ci-only (origin only) | 04bfa3a4, 8e6a7fb2, 8e25acdf, e04774f7, 7c4185ec, 9fce5ecc, 4c32e599, 46c71f54 | 2026-08-23 | Disposable CI workflows and red-test scaffolding; w8-review-ui is the author review UI, 4 of 5 files identical in INT. | Throwaway CI. Review UI work is in INT. |

---

## C. Stashes

| Name | Commit | Date | Files | What it is | INT comparison | Rec |
|---|---|---|---|---|---|---|
| stash@{0} "Local edits saved before remote reconciliation 2026-09-14" | ad71ad51 | 2026-09-14 | docs/superpowers/specs/2026-09-06-quiz-loading-performance-design.md (new, 543 lines, stored as an untracked file in the stash), pubspec.lock | The only copy of the 6 Sept spec "Daily quiz loading on lower-end Android" (balanced scope, lower-end phones as acceptance platform). pubspec.lock part is the same trivial meta/test_api bump as in the swiftpm worktree. | INT's SSOT checkpoint (line 117) and the E03 execution spec (line 23) both say this spec file is absent from every branch. The E03 spec replaced it for scope, but the original text exists only here. | KEEP (the spec, as a record; feeds W5 phone checks and performance acceptance). Lock change: DISCARD. Copy saved to snapshots/stash0-quiz-loading-performance-design.md. |
| stash@{1} "WIP on main: 6035765b fix(ui): prevent setState during build when switching wheel modes" | c4655ca5 | 2026-08-18 | 34 files: settings_bar, settings_value_row, mock_session_page (+93), mock_session_controller, custom_mock_setup_page, assessment_page, quiz_page, 10 settings pages, mock tests, ios xcconfig and Info.plist, tools/pro, tools/demo | Aug 18 WIP: back-chevron and centered title in the settings bar, Ink chevrons, end-part-early wording, mock question body hydration, submitted-state snapshot, assessment cache invalidation. | Almost all is in INT: 19 of 34 files are byte-identical or reverse-apply, and INT has settings_bar backLabel and BackChevron, mock_session_page _QuestionBody and the "minutes left in this part" wording, MockSessionPaused snapshot handling. The Ink-style chevron parts are pre-October styling and superseded. The only piece not in INT is the 5-line assessment cache invalidation (same as web/beta-salvage-assessment-cache-r1). | DISCARD (the one unique hunk is kept via web/beta-salvage-assessment-cache-r1) |
| stash@{2} "On wt-content02c: content02 uncommitted tail" | c749bf89 | 2026-08-11 | 68 test files plus 7 untracked Python fix scripts (fix_all*.py, fix_companions.py, fix_tests*.py) | Mechanical test repairs after a schema change: adds `schemaVersion`, `updatedAt`, `ordering` to Companion.insert calls; uses the old package name `cse_cet_reviewer`. | INT's tests use `package:pantas`, schema version 25, and the current Companion shapes (checked test/features/quiz/presentation/scoped_content_test.dart). The stash targets a schema and package name that no longer exist. | DISCARD |

---

## Not checked:

- Whether any untracked or dirty state exists in worktrees that `git worktree list` does not show (for example prunable or locked entries). Only the 29 listed worktrees were read.
- The 5 `refs/codex/turn-diffs/checkpoints/*` refs. They are not branches or tags; I did not inspect them.
- Gitignored files in worktrees (build output, node_modules). Only untracked non-ignored files were read. functions/node_modules in the release-e2e-firebase worktree is regenerable.
- Binary and generated content beyond file-level comparison: lesson figure PNG assets and the 300k-line historical_v1.json were compared by file identity or size only, not line by line.
- Whether the Dart code in KEEP items still compiles or passes against INT. No build, analyze or test was run (read-only).
- Whether the assessment cache invalidation bug still reproduces on INT. I confirmed only that the fix lines are absent and the providers exist.
- Lesson-illustration intermediate waves (w2-a, w2-b, w1, w3, r1, r2) were judged superseded from INT's later commits and sampled file diffs, not from a full per-commit proof. Reverse-apply tests were inconclusive for them because later commits edited the same lines. Branch tips are recoverable by SHA if you disagree.
- Remote branches deleted earlier today: not re-verified; I used only the cleanup log.
- Origin branches that exist only as copies of local branches were treated as the same item as the local branch (same tip). Local versus origin drift was checked: none, except local-only refs listed above.

## Summary table

| Rec | Count | Rows |
|---|---|---|
| KEEP | 6 | release-e2e firebase, mock, quiz-delete, shipping (W5); web/beta-salvage-assessment-cache-r1 (W4d); stash 0 spec (W5) |
| ASK | 7 | qlp5-physical (untracked harness), a11y-inline-math-sentence-r1, backup/pre-attribution-rewrite, web/beta-consolidation-planning-r1, web/ios-physical-qa-enablement-r1, web/landing-design-contract-r1, web/lesson-illus-visual-review-ledger |
| DISCARD | 30 | 13 worktree rows (beta-final-verification, e04-content-protection, android-release-swiftpm, rc-be-verify, beta-integration, mock-resume, e09-repair r1 and r2, w4verify, w5a, w5b, w5verify, m7), 15 branch rows in B2 (about 75 refs), stashes 1 and 2 |
