# CI speed plan: second review (Fable)

Date: November 10, 2026. Read-only. Nothing was changed.

Sources read: the plan, the profile, the Codex review (all from `origin/main` at 2651a6fd0),
the live workflow on `origin/ds4/completion-r1` at d2ee9927c (the branch that carries commit
ba45eb05c), and the job timings of CI run 42766777536 (Nov 10, green).

Everything marked "estimate" is a forecast from the measured numbers, not a measurement.

## Bottom line

The plan is sound and its first step is the right one. It has four errors worth fixing before
anyone builds it, and its baseline is already out of date. The realistic floor on free hosted
runners is 4 to 5 minutes. The plan as written lands at about 7 to 9, because Android and the
setup step stay on the critical path.

## Fresh numbers (run 42766777536, Nov 10)

| Item | Plan baseline (Nov 8) | Now (Nov 10) |
|---|---|---|
| Wall time | 26m16s median | 30m24s |
| Test step per shard | 1244 s median (933 to 1447) | 1146 to 1654 s |
| Test files | 1,033 | 1,193 (66 of them goldens) |
| Setup step | 108 s median | 81 to 120 s |
| Android job | 394 s build plus setup | 521 s total (392 s build) |
| Coverage job (runs after the shards) | 30 to 45 s | 41 s |
| Jobs per CI run | 13 | 14 (goldens added) |

Wall time is the slowest shard (29.6 min) plus the coverage job (41 s). The suite grew 15% in
files in two days. The slowest shard is at 27.5 min against a 40 min timeout.

Note: the brief says setup takes 2.6 min. The latest run shows 1.4 to 2.0 min. I used the
measured value.

## 1. Is the plan sound?

Yes for direction and order: baseline, file shards, Android cache, tune shard count, caches,
duplicates, slow tests, path filters, bundling last. The verification rules (test identity, exact
partition, coverage line totals, one `ci-ok` gate) are right and should stay.

### Errors and risks to fix

**E1. The setup cache in S3 will almost never hit.** The key includes a hash of `lib/**`. Nearly
every push changes `lib/`, so nearly every push misses. All jobs in a run start together, so none
can reuse what another saved in the same run. Expected saving as written: about zero on a normal
push. Fix: restore `.dart_tool/build` with a prefix key (`restore-keys`) and always run
build_runner. It checks its own inputs by content and rebuilds only what changed. No stale-output
risk, because generation still runs. Cache the content asset under its own key (content sources
and `tools/**` only); that one hits on most code pushes. Estimate: setup falls from about 100 s to
about 45 to 60 s in every job.

**E2. The Android path filter in S6 does nothing.** It runs Android when `lib/**` changes. That
is almost every push. Android (8.7 min) stays the floor after S1. Gradle caching (S1b) brings it
to perhaps 6 to 7 min, which is still the slowest job. Decide whether a debug APK build must pass
on every branch push for a web PWA. See idea 2.

**E3. S4 describes the wrong `ci.yml`.** The plan says "`ci.yml` already runs on push to main,
sharded, on Flutter 3.44.6". That is the branch version. On `main` today, `ci.yml` is a single
unsharded pull-request job on Flutter 3.41.x with a 15 min timeout, and `main.yml` is the push
job. So S4 is not "delete one file". It must land the branch `ci.yml` on main, delete `main.yml`,
and update the required-check names, in one change. Check the current required-check names first.

**E4. A new duplicate the plan does not know about.** `ds4/completion-r1` and
`web/ds4-completion-r1` point at the same commit and both match the push trigger. Every push ran
CI twice (runs 42766777536 and 42766775030) plus journeys. That is 28 CI jobs against the
20-job account limit, so jobs queue. The second run finished 2 min later. Fix: trigger on one
branch pattern, or stop pushing the twin.

**E5. Caches do not cross branches.** A branch can read only its own caches and those of `main`.
Main runs a different, older workflow, so nothing seeds a new `web/**` branch. First pushes on a
new branch are always cold unless main runs the same setup. Also the repository cache cap is
10 GB. Twelve shards each saving a test compiler cache per branch will evict the 1.6 GB Flutter
cache. Fix: one job saves each cache, all jobs restore it, and main runs the same setup (E3).

**E6. The baseline and the "done" numbers are stale.** 8,210 tests and "about 26 min" are two
days old and already wrong. S0 must re-profile on the current branch, and the done criteria must
pin the count measured then.

**E7. S5 refers to a `prepare` job that S3 removed.** The setup step already builds
`build/export.json` in every job. Point the tests at that file. No new job is needed.

**E8. Golden files are loaded and skipped in every shard.** 66 golden test files are tagged to
skip in a plain `flutter test`, and run in their own job. The S1 file list should exclude
`test/goldens/**`, and the partition check must expect that.

**E9. The coverage job is on the critical path and the plan does not count it.** It adds 41 s
after the slowest shard, mostly installing Flutter to run one Dart script. Use the Dart SDK alone
or a shell gate. Estimate: 20 to 30 s saved on every run.

**E10. Timing file goes stale fast.** 160 files arrived in two days. A checked-in timing file
refreshed monthly will leave shards unbalanced. Refresh it from each main run's timing artifact,
or by a weekly job. Unknown files at the median is a fine fallback.

**E11. Path filter edge cases (S6).** A new branch or a force-push has no usable "before" commit.
The filter must then run everything.

**E12. Shard count versus the job limit (S2).** Several agent sessions push different branches
at the same time. Two overlapping runs of 16 jobs exceed the 20-job limit and queue. Prefer 8
shards and cut the job count (merge the scans into one job without setup; move the always-failing
OSV report to a schedule).

### Timing of the work

The plan is "after the beta". The timeout was raised from 30 to 40 min on Nov 10 and the slowest
shard is at 27.5 min. At the current growth the shards reach the new limit within weeks. S0 and
S1 alone are about half a day and remove the risk. I would pull those two forward. That is
Aedwon's call.

After S1 lands, lower the test timeout to about 15 min so a hung shard fails fast.

## 2. What the plan missed

Minutes are wall-time estimates against today's 30 min, in the order the gains stack.

| # | Idea | Saves | Cost | Risk | Recommendation |
|---|---|---|---|---|---|
| 1 | File-based shards, 8 of them (plan S1, S2) | About 21 to 23 min (30 to about 7 to 9) | 0.5 to 1 day, no money | Low, with the partition and identity checks | Do first. Consider doing it now. |
| 2 | Take Android off the per-push required path: run on main, before a release, and when `android/**` or `pubspec.*` change | 2 to 3 min after idea 1 (Android stops being the slowest job) | 1 to 2 hours, no money | Low. An Android-only break shows on main, not on the branch. The VM tests already compile `lib/`. | Do. Add the Gradle cache anyway for the runs that remain. |
| 3 | Incremental setup (E1) plus coverage job trim (E9) | 1 to 1.5 min on every run | 2 to 4 hours, no money | Low. Generation still runs. | Do. Replaces S3's skip-on-hit design. |
| 4 | Stop the twin-branch duplicate run and cut the job count (E4, E12) | 0 to 2 min of queueing; halves compute | 30 min, no money | None | Do now. It needs no other step. |
| 5 | Slow tests (S5) then small bundles (S8) | 1 to 1.5 min | 1 to 1.5 days, no money | S5 low. Bundles medium (state leaking between files). | S5 yes. Bundles only if the result is still over target. |
| 6 | Fast signal job: run only the test files changed in the push, not required | 0 on the full run; a failure in new tests shows in about 2 to 3 min | 2 to 3 hours | Low, since it is not the gate | Optional. Worth it only if agents wait on red runs often. |
| 7 | Test compiler cache seed (in S3) | 0 to 1 min per shard, cold start only | 1 to 2 hours | Low for correctness, real for the 10 GB cap (E5) | Measure once. Keep only if it saves over 30 s. |
| 8 | Retry the setup step once on failure (profile saw setup flakes costing 100 to 217 s) | Avoids full reruns | 30 min | Low | Do with idea 3. |
| 9 | Affected-test selection as the required gate | 3 to 4 min on small changes | 2 to 3 days | High: generated code, assets and content make the dependency graph incomplete; the coverage gate needs the full suite | Do not. |
| 10 | Merge queue with a fast gate and a full suite later | Would cut branch pushes to about 2 to 3 min | Unavailable | GitHub offers merge queue only for organization-owned repositories; this one is on a personal account. Verify before relying on this. A hand-built two-tier gate would break the rule that staging only takes a commit that passed the full run. | Do not. |
| 11 | Larger GitHub runners (8 or 16 cores) | 1 to 1.5 min | Paid per minute even on a public repository, roughly a dollar per push at 8 shards (check the current price) | Low | Do not. Free shards give the same result. |
| 12 | Third-party runners (Blacksmith, Depot, Namespace) | 1 to 2 min from faster cores and cache | Free tier covers roughly 50 pushes a month, then paid; a new vendor has access to the build | Low to medium | Not now. Revisit only if 4 to 5 min is not enough. |
| 13 | Self-hosted Mac runners | Android could build in 1 to 2 min warm; tests would be slower than 8 hosted shards | No money | High: on a public repository a pull request can run code on the Mac; the Mac is shared with agent sessions (load 5 to 17), and CI stops when it sleeps | Do not use for required checks. |
| 14 | Split goldens | Already a separate job | None | None | Nothing to do beyond E8. |
| 15 | Prebuilt container image with Flutter | None; the image pull is slower than the 17 s cache restore | | | Do not. |

### How the estimates were derived

Today a shard step is about 1,450 s. The profile shows work tied to loading every file dominates;
a shard's own tests are about a tenth. Splitting by file leaves each shard about
1,300 / N seconds of loading, about 150 x 6 / N of its own tests, and about 40 s of one-time
compile. Each shard has its own compiler, so loading scales with file count.

| Setup | Shards | Slowest shard (est.) | Plus coverage job | Slowest other job |
|---|---|---|---|---|
| S1 only | 6 | about 8.5 to 9.5 min | 9 to 10 | Android 8.7 |
| S1 + S2 | 8 | about 7 min | 7.5 | Android 8.7 (the limit) |
| + Android off path, setup trimmed | 8 | about 6 min | 6.5 | web or static, about 3 |
| same | 12 | about 4.5 to 5 min | 5 to 5.5 | about 3 |
| + slow tests and small bundles | 12 | about 3.5 to 4 min | 4 to 4.5 | about 3 |

Shard imbalance and runner noise add up to a minute to any single run.

## 3. Can it beat 6 to 9 minutes?

Yes.

- **5.5 to 7 min** with low-risk steps only: ideas 1 to 4. About 1.5 days of work, no money.
- **4 to 5 min** is the realistic floor on free hosted runners: add 12 shards, the slow-test
  fixes and small bundles. About 3 days in total. Bundling carries the medium risk.
- **Under 4 min** needs paid faster runners or a gate that runs fewer tests. I do not recommend
  either.

Limits that hold the floor: about 50 s of setup per job, about 40 s of first compile per shard,
the coverage job after the shards, and the 20-job account limit when sessions push at once.

## Changes I would make to the plan

1. Pull S0 and S1 forward; do not wait for the end of the beta (decision for Aedwon).
2. Re-baseline in S0 and re-pin the done criteria (E6).
3. Rewrite S3 as incremental generation with prefix keys, one saver per cache (E1, E5).
4. Replace the Android line in S6 with "main, release, `android/**`, `pubspec.*`" (E2), if
   Aedwon accepts that an Android-only break shows on main.
5. Rewrite S4 for what main really runs today, and add the twin-branch duplicate (E3, E4).
6. Exclude goldens from the shard file list (E8); trim the coverage job (E9).
7. Target 8 shards first, 12 only if needed, and cut the job count (E12).
8. Fix the S5 reference to `prepare` (E7); refresh timings automatically (E10); handle the
   no-base case in the path filter (E11).
9. Lower the shard timeout to about 15 min after S1.

## Top 5, ranked

1. File-based shards at 8: about 21 to 23 min saved, 0.5 to 1 day, free, low risk.
2. Android off the per-push path: 2 to 3 min, 1 to 2 hours, free, low risk.
3. Incremental setup and coverage job trim: 1 to 1.5 min, 2 to 4 hours, free, low risk.
4. Stop the twin-branch duplicate and cut jobs: 0 to 2 min and half the compute, 30 min, free.
5. Slow tests, then small bundles: 1 to 1.5 min, 1 to 1.5 days, free, low to medium risk.
