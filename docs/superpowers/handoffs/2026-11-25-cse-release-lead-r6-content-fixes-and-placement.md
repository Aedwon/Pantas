# CSE release lead r6: CSE content fixes and wide button placement shipped

Written Nov 25, about 03:25 UTC (11:25 AM Manila) by the CSE release lead r6 (integrator). Read this instead of the r6 thread. Earlier notes: `2026-11-25-cse-release-lead-r4-ui-ship.md`. Policy read from main 173fd0909, refreshed through b045b8ff6.

## Current prod

- Web: build 2087787726-0cb9232baafd, Hosting 665e971038f5a874, Worker 0c35b309-e3a0-457a-8703-9ffbace16ee7, from main 143e1ce66. Rollback: Hosting f3854d6641dc1dfa, Worker 1826b9f9-0042-4d77-ade3-74e6fb8f81ec.
- Content root: `content/cse-key-fixes-r1` 498874194 (on GitHub) plus main's `content/mock/acet.yaml`, `content/exams/custom_subject_tiers.json`, `content/illustrations/sources/pantas.yaml`. Export with main's tools from a root that is main's tree with this content folder swapped in (the export reads other repo files). Rollback: upload d97de9415 plus the same three files, or write back the 49 saved documents in `Pantas-private/releases/2026-11-25-cse-content-fixes/prod_content_backup.json`.

## Shipped by r6 (launch log entries on main)

1. 00:18 UTC, CSE content fixes (E-160): the 19 still-applying Blocker and Major findings from the Codex b audits (list with sources: `docs/superpowers/plans/2026-11-25-cse-content-fixes-r6.md`). 10 questions re-solved independently and approved in the ledger; CSE Professional mock 150 test items plus 20 unscored (CSC Advisory No. 19, s. 2026); 8 lesson findings, also carried into their retired parent lessons. PR #126 put the same mock numbers and tests on main.
2. 03:16 UTC, wide button placement (E-158 from the UX lead, integrated as E-161, PR #127).

## Lessons for the next content ship

- Main's lesson checks include split coverage: a retired parent lesson's examples and traps must match its parts exactly, so a fix to a part's example goes into the parent too. Codex's fix run did not run this check (the content branch lacks `tool/content`); run main's `tool/content/lesson_checks.dart --root <content>` yourself.
- `lesson_checks` also caps teaching words at 450.
- Gate output starts with "Running build hooks..."; strip it before using it as an ids file for `approve.dart`.
- Local widget tests need `assets/seed/content.db` (main.yml "Build the content asset") and empty `content.manifest.json` and `.sig` files (setup-app action).

## Parked or open (for the manager)

- Backlog C11: the audits' CSE Minor (about 68) and Unsure (about 14) findings; trigger "re-check against prod before public launch".
- From the UX lead: wide full-width single buttons outside the pair scan; `router_settings_test` hang when bundled (root cause unknown).
- From r4, still open: held UI looks waiting on board picks, the service worker build-mix gap, ENT-06 review items, pulley (1,1) figure branch.
- Rule 7: after the content ship the live check still showed prod 5,700 reads for the quota day (metrics lag). Confirm actual use at the next daily sweep.

## Process

- Main had unresolved stash conflict markers in `docs/workflow/process-improvement.md`; r6 removed them (both entries kept) in 23c82fdf6, and the UX lead did the same on its branch.
- r6 wrongly flagged the note editor's 8 px gap as a phone change; it sits in the wide-only layout. Caught before any edit shipped.

## Branches and worktrees

Merged and removable (deleting needs the usual cleanup check): `fix/cse-pro-mock-150`, `qa/button-placement-integrate-r1`, `ux/button-placement-r1` (UX lead's), `qa/cse-content-fixes-r1`. Worktree `qa-cse-content-fixes-r1-e2be285e666bb7e9` holds generated files only. `cse-key-fixes-r1` (branch `content/cse-key-fixes-r1`) is the prod content root: keep it.
