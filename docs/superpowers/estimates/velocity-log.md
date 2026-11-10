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
