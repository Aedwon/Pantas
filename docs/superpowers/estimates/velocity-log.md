# Velocity log

Purpose. Aedwon, Nov 11, 2026: "start documenting how much time estimated for a task/feature, then document the actual implementation time where something is working on it. this way we can start calibrating your estimates for actual speed/velocity if you get what i mean".

## How to log

Every lane logs every task or feature, however small.

1. BEFORE starting, add a row with the estimate: ID, date, task, type, lane or thread, model, complexity, who estimated, and both estimates.
2. AT FINISH, fill the actuals and the ratio in the same row.
3. Rows stay. A correction adds a note below the table; never delete or rewrite a row.
4. Give the miss cause for any ratio over 1.5 or under 0.67 (scope added, CI flake, rework after review, a wait, and so on).
5. Times are UTC, written as `Mon DD HH:MM`. Estimates are for the whole task, including review.

Columns:

- **ID**: E-001, E-002, and so on. Take the next number.
- **Type**: UI fix, feature build, port/merge, docs/legal, CI/infra, or deploy. This drives the Calibration section.
- **Complexity**: minimal, balanced, or hardened, as Aedwon chose it.
- **Est. active**: the estimate of hands-on work.
- **Est. wall**: the estimate of total elapsed time, including CI waits and waits on Aedwon.
- **Actual wall**: finished minus started.
- **Actual active**: actual wall, excluding CI waits and waits on Aedwon.
- **CI wait** and **Aedwon wait**: elapsed time spent on each.
- **Ratio**: actual wall divided by est. wall. Median ratios use this.
- **Miss cause**: only when the ratio is over 1.5 or under 0.67.

## Log

| ID | Date | Task | Type | Lane / thread | Model | Complexity | Est. by | Est. active | Est. wall | Started (UTC) | Finished (UTC) | Actual wall | Actual active | CI wait | Aedwon wait | Ratio | Miss cause |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| E-001 | Nov 9 | Design system 4.0 redesign release to prod (backfilled, estimate given as stated) | feature build | DS4 lead | not recorded | not recorded | not recorded | not given | "about 85% done" at Nov 9 ~15:08, no time estimate | Nov 9 15:08 | Nov 10 16:52 (shipping started; prod deploy done 16:57) | about 26 h | not recorded | not recorded | not recorded | n/a (no time estimate) | Six added fix rounds: Staging Check Fixes picks, prod Home hotfix, desktop Pro icons, splash, wheel fix and date picker A port, final exam date picker and age step |
| E-002 | Nov 10 | Picker port r1 to staging, first estimate (backfilled, estimate given as stated) | port/merge | DS4 lead | not recorded | not recorded | lead | not given | "about an hour" | Nov 10 07:35 | Nov 10 09:03 (ready on staging) | 1 h 28 min | not recorded | about 40 min (journeys rerun stuck queued) | not recorded | 1.47 | Within range. CI queue delay added about 40 min |
| E-003 | Nov 10 | Picker port r1 to staging, re-estimate of E-002 (backfilled, estimate given as stated) | port/merge | DS4 lead | not recorded | not recorded | lead | not given | "about 40 minutes more" at 08:06 | Nov 10 08:06 | Nov 10 09:03 | 57 min | not recorded | about 40 min (same queue delay) | not recorded | 1.43 | Within range. Same queue delay. Same work as E-002, so it is excluded from the medians |
| E-004 | Nov 10 | Picker port r2 to staging (backfilled, estimate given as stated) | port/merge | DS4 lead | not recorded | not recorded | lead | not given | "about 45 minutes" | Nov 10 15:40 | Nov 10 about 16:13 (ready on staging) | about 33 min | not recorded | not recorded | not recorded | 0.73 | Within range |
| E-005 | Nov 10 | CI speed plan step 1: file split into 8 groups | CI/infra | CI speed plan, not started | n/a | not recorded | Fable 5.2 | half a day to 1 day | not given | not started | not started | | | | | | |
| E-006 | Nov 10 | CI speed plan: Android filter | CI/infra | CI speed plan, not started | n/a | not recorded | Fable 5.2 | 1 to 2 h | not given | not started | not started | | | | | | |
| E-007 | Nov 10 | CI speed plan: setup and coverage | CI/infra | CI speed plan, not started | n/a | not recorded | Fable 5.2 | 2 to 4 h | not given | not started | not started | | | | | | |
| E-008 | Nov 10 | CI speed plan: duplicate run fix | CI/infra | CI speed plan, not started | n/a | not recorded | Fable 5.2 | 30 min | not given | not started | not started | | | | | | |
| E-009 | Nov 10 | CI speed plan: slow tests and bundling | CI/infra | CI speed plan, not started | n/a | not recorded | Fable 5.2 | 1 to 1.5 days | not given | not started | not started | | | | | | |
| E-010 | Nov 10 | Ship design system 4.0 17c8b5710 to prod (functions for the guardian versions plus hosting), live checks, 15-minute watch | deploy | DS4 lead | Opus 5.5 | not recorded | not given (the estimate rule came after) | not given | not given | Nov 10 16:52 | Nov 10 17:13 | 21 min | about 6 min (gates, diff, preflight, two deploys, live check); the rest was builds and the watch | none (CI was already green) | none | n/a | |
| E-011 | Nov 11 | CI speed S0 + S1: timing harness and fresh baseline (test identities, coverage), then the file-based split into 8 groups with the partition check, verified on CI against the baseline | CI/infra | DS4 lead (Sonnet builder) | Sonnet 5.5 builder, Opus 5.5 lead | as approved | DS4 lead | 4 h | 7 h (several CI runs, one unsharded baseline run of about 45 min) | Nov 10 17:14 | Nov 10 18:32 | 1 h 18 min | about 15 min (lead review and merge) plus the builder's edits between runs | about 1 h (baseline 39 min, three sharded runs about 8 min each, merge run 9 min) | none | 0.19 | Estimate assumed slow iteration; the baseline ran 39 min and each sharded run about 8 min, and the builder needed no rework |
| E-012 | Nov 11 | CI speed S4 (twins only): stop the duplicate CI run when one commit sits on a `ds4/` branch and its `web/ds4-` mirror | CI/infra | DS4 lead (Sonnet builder) | Sonnet 5.5 builder, Opus 5.5 lead | as approved | DS4 lead | 30 min | 1 h (one CI run) | Nov 10 17:14 | Nov 10 18:32 | 1 h 18 min (landed with E-011) | about 5 min (a ruling and a comment; the trigger already ran on web/** only) | shared with E-011 | none | 1.3 |  |
| E-013 | Nov 11 | CI speed step 2: Android path filter (main, releases, Android changes) with a `ci-ok` gate (S6), Gradle build cache (S1b), one scans job and OSV on a schedule (S2 job count) | CI/infra | DS4 lead (Sonnet builder) | Sonnet 5.5 builder, Opus 5.5 lead | as approved | DS4 lead | 2 h | 3 h (three or four CI runs, including one that must skip Android and one that must run it) | Nov 10 18:34 | Nov 10 19:45 | 1 h 11 min | about 20 min (lead rulings, review, merge) plus the builder's edits | about 50 min (five runs of 8 to 11 min) | none | 0.39 | Runs took 8 to 11 min each and only one small follow-up (run everything on the release line) was needed; the estimate assumed slower runs |
| E-014 | Nov 11 | CI step 3: root-cause and fix the flaky browser journey "The last answer survives a reload" (test-side wait, checks unchanged), proven by 5 consecutive passing journey runs | CI/infra | DS4 lead (Sonnet builder) | Sonnet 5.5 builder, Opus 5.5 lead | as approved | DS4 lead | 45 min | 1 h 30 min (five journey runs of about 8 min each) | Nov 10 19:35 | Nov 10 21:14 | 1 h 39 min | about 15 min (lead review of two fixes, the five-run check, merge) plus the builder's edits | about 1 h 20 min (the first proof attempt, then five fresh runs of about 7 min, then the merge run) | none | 1.1 | A second cause (a lost click on Study days) showed up on run 4 of the first proof set; it needed its own fix and a fresh set of five runs |
| E-015 | Nov 11 | CI speed S3: incremental build_runner cache and content asset cache with one saver each (cached output proven byte-identical to a cold build), setup retry, coverage job on the Dart SDK alone, emulator and Playwright caches, test compiler cache measured | CI/infra | DS4 lead (Sonnet builder) | Sonnet 5.5 builder, Opus 5.5 lead | as approved | DS4 lead | 1 h 15 min | 2 h 30 min (a cold and a warm run per cache, the byte check, three or four CI runs of about 8 min) | Nov 10 21:07 | Nov 10 22:17 | 1 h 10 min | about 15 min (brief, review of the diff and the content-cache imports, merge) plus the builder's edits | about 55 min (cold, warm, exact-hit and probe runs of 7 to 8 min, then the merge run) | none | 0.47 | The builder proved the byte check on the first full set of runs; only one small fix (a test that read the moved action path) was needed |
| E-016 | Nov 11 | CI speed S5: slow tests (onboarding presets, read-marking dwell, content-export setUpAll blocks reuse the CI export, sync backoff delay), re-profiled until no file is over 20 s, same test identities and coverage | CI/infra | DS4 lead (Sonnet builder) | Sonnet 5.5 builder, Opus 5.5 lead | as approved | DS4 lead | 1 h 15 min | 2 h 30 min (fresh profile, several test edits, three or four CI runs of about 8 min) | Nov 10 22:19 | Nov 10 22:35 | 19 min (merge run green 22:38) | about 10 min (brief, review of three production changes, merge) plus the builder's edits | about 10 min (one CI run of 7 min) | none | 0.11 | The fixes were small injections; one CI run proved them. The step bought no CI wall time: the waits were idle time inside shards |
| E-017 | Nov 11 | CI speed S8, bundling only (manager ruling): bundle test files into fewer entry points per shard, keeping files with processes or global state outside; same tests by name, coverage, journeys; 12 groups measured only if bundling misses 5 min | CI/infra | DS4 lead (Sonnet builder) | Sonnet 5.5 builder, Opus 5.5 lead | as approved | DS4 lead | 1 h 30 min | 3 h (bundle generator, isolation audit of global state, four or five CI runs, a repeat set for new flakes) | Nov 10 22:36 | Nov 11 00:12 | 1 h 36 min | about 25 min (brief, generator review, five extra flake runs, the Java 17 fix, two merges) plus the builder's edits | about 1 h 10 min (three failing bundle runs, five runs on the final head, five more for the 10-run bar, the merge run, the Java fix runs) | none | 0.53 | Bundling hit the target on the first measured head, so 12 groups were never measured. The merge run then failed on Android for an unrelated reason (ubuntu-latest moved to Ubuntu 26 with Java 25), which cost about 15 min |
| E-018 | Nov 11 | Merge ds4/guardrails 557258e82 (8 commits, 73 behind) into web/design-system-4: resolve conflicts (CI files changed under it), keep the CI speed work, green CI with journeys read, Android cache warm check | merge | DS4 lead | Opus 5.5 lead | balanced | DS4 lead | 30 min | 1 h (conflicts in CI files, one or two CI runs of about 6 min on the release line) | Nov 11 00:15 | Nov 11 00:25 | 10 min | about 8 min (six conflicts, the lint baseline, one local lint run and one test file) | about 6 min (one CI run, 5 min 5 s) | none | 0.17 | The completion lane had already solved the one real lint rise; everything else was mechanical. (Started time corrected from 00:22: the row was committed at 00:15.) |
| E-019 | Nov 11 | Merge ds4/completion-r1 16933da89 (28 ahead, 28 behind; already contains guardrails) into web/design-system-4: keep the web/** only trigger (twin rule), resolve conflicts with the picker port and the CI speed work, green CI with journeys read | merge | DS4 lead | Opus 5.5 lead | balanced | DS4 lead | 30 min | 1 h (conflicts, lint baseline, one or two CI runs of about 5 min) | Nov 11 00:26 | Nov 11 00:32 | 6 min | about 4 min (five conflicts, all resolved by rule; lint and the icon test locally) | about 5 min (one CI run, 4 min 27 s) | none | 0.10 | The completion lane had merged guardrails and the picker ports already, so only version lines, the test limit and a count conflicted |
| E-020 | Nov 11 | CI speed S7: functions job, emulator files split across two jobs (emulator jars already cached in S3), same backend tests by name, green CI, merged | CI/infra | DS4 lead (Sonnet builder) | Sonnet 5.5 builder, Opus 5.5 lead | balanced | DS4 lead | 45 min | 1 h 30 min (split, identity check, three CI runs of about 4 min, merge) | Nov 11 00:29 | Nov 11 00:54 | 25 min (built and proven; merge held for a manager ruling) | about 5 min (brief, report review) plus the builder's edits | about 20 min (four CI runs) | none | 0.28 | Built fast; the result (114 s to 86 s on a job off the critical path, one more job per run) argued against merging, so it waits for a ruling |
| E-021 | Nov 11 | Merge ds4/privacy-batch 8f87ff594 into web/design-system-4: eight conflicts (age step and its tests, legal documents, account and Pro pages, journeys); carry the age-step legal sentences into the batch's texts (agent draft, Codex Sol High critique); green CI with journeys read; then Aedwon's look and deploy approval through the manager | merge | DS4 lead (Sonnet builder for legal draft) | Opus 5.5 lead, Sonnet 5.5, Codex GPT 6.1 Sol High | balanced | DS4 lead | 1 h 30 min | 3 h (semantic merge of the age step, the legal draft and critique, two or three CI runs; Aedwon's look not counted) | Nov 11 00:33 | | | | | | | |
| E-022 | Nov 11 | Prepare the CI files' landing on main without touching main: web/main-landing-r1 = origin/main plus a merge of web/design-system-4 (release line's code and CI, twin rule, main's newer docs), main.yml retired, CI and journeys run there, timing, test identities and coverage checked | CI/infra | DS4 lead | Opus 5.5 lead | balanced | DS4 lead | 40 min | 1 h 15 min (docs conflicts, a check of what runs on push to main, two CI runs) | Nov 11 00:57 | Nov 11 01:12 | 15 min | about 8 min (merge, one docs conflict, the main.yml check) | about 14 min (cold run 9 min 17 s, warm rerun 4 min 4 s) | none | 0.20 | One docs conflict only; the main.yml retirement turned out to need a ruling (the native release runner pins that file), so it was left as is |

Notes:

- E-001 to E-004 are backfilled from the launch log (`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`) and the commit times on `web/design-system-4` and `main`. Estimates are as stated at the time. Model and complexity were not recorded then.
- E-001 ratio is blank because no time estimate was given. Its elapsed time (Nov 9 15:08 to Nov 10 16:52) is the only datum.
- E-005 to E-009 are Fable 5.2's estimates in `docs/superpowers/plans/ci-speed/`. They are active-work estimates and no wall estimate was given. Fill the rows when the work starts.

## Calibration

Median ratio (actual wall divided by est. wall). Update whenever 5 new rows finish. Count only rows with a ratio, and skip rows that re-estimate the same work.

Last updated: not yet. Rows finished since the last update: 0.

| Group | Rows | Median ratio |
|---|---|---|
| Overall | 0 | |
| UI fix | 0 | |
| Feature build | 0 | |
| Port/merge | 0 | |
| Docs/legal | 0 | |
| CI/infra | 0 | |
| Deploy | 0 | |
