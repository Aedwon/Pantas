# Release-first cuts and prerequisite links

Date: 1 October 2026. Continues `2026-09-30-adaptive-roadmap-log.md`.

> "what else can be cut? i think my goal should be to release first and not really fully
> optimize to edge devices. i need to put it out there and start generating revenue.
> optimizations can come at later updates"

> "you decide for me considering what's best for the student and the app (backed by evidence
> if possible)"

## Release cuts (lead decision, delegated by Aedwon)

Options offered with cost and risk; all four chosen:

1. **Low-end device performance is not a release gate.** QLP-5's formal campaign on a 3 to 4 GB
   phone moves to a later update. Before release, a smoke check on the Redmi that Today, Start
   and Next feel responsive. Saves several days and a device. Risk: stutter on budget phones.
2. **Final Release E2E runs once, not three times** (E10). Saves hours. Risk: flakiness slips
   through; low for an internal beta.
3. **Roadmap change log stays on the device** (plan Task 11 deferred). Saves a task and a rules
   and Cloud Function deploy. Risk: a Pro student who reinstalls loses log history; no screen
   shows the log until the UI round.
4. **Accessibility (A05) and notifications/device runtime (A06) become smoke checks** instead
   of full passes. Saves about a day. Risk: TalkBack or reboot edge cases surface later.

Kept, because failure costs money, student data or Play standing: exact signed-artifact
verification (E12, E13), RevenueCat purchase and restore (A03), sync and account (A01), deletion
and privacy (A07), App Check (A02), device smoke (A04).

## Prerequisite links (lead decision, delegated by Aedwon)

Codex's audit proposed 12 links. Approved 4:

- Algebra after Arithmetic & Number Sense
- Trigonometry after Geometry
- Pre-Calculus & Basic Calculus after Algebra
- Language Application after Grammar and Structure

Dropped 8 (Geometry after Algebra; Statistics, Data Interpretation after Arithmetic; Chemistry
after Algebra; Physics after Algebra and Trigonometry; Vocabulary after Grammar; Mechanical
Reasoning after Trigonometry): each rests on one or two worked examples, and prerequisites
chain, so Physics would have forced four mathematics topics ahead of a weak Physics student.

**Evidence and its strength:** cognitive load research supports teaching material that builds
directly on earlier schemas after those schemas exist (Sweller, van Merriënboer and Paas 2019,
Educational Psychology Review, "Cognitive Architecture and Instructional Design: 20 Years
Later"); prior knowledge strongly predicts later performance, though much less the size of learning gains (Simonsmeier,
Flaig, Deiglmayr, Schalk and Schneider 2022, Educational Psychologist, meta-analysis). No study
decides these specific topic pairs; the calls apply the spec's approved rule, "only where a
topic cannot be understood without the other", to the lesson evidence in the audit. The dropped
links keep weak topics first, which the spec's ordering already chose.

---

## Build progress and lead technical revisions, 1 October 2026

> "write them yourself while codex resets but you can actually just drain codex lol"

Codex reached its 5-hour limit (99% used, reset 01:32). Three dispatches had first hung waiting
on stdin for up to 47 minutes (fixed: stdin closed in the dispatch script); relaunched, they hit
the limit before writing anything. The lead wrote Tasks 6 fix, 8, 9, 10, 15 and 17 and the four
prerequisite links, test first, with mutation checks on the key tests.

1. **Anchored review-only start** (spec Part 2 Section 4.2 amended). Daily recomputation of the
   quiet stretch shrank it near the exam; a student following the plan exactly got new material
   until the day before the exam (simulated worst case: 7 days, the whole stretch). Fixed by
   carrying the first plan's `reviewOnlyFrom` forward. The 200-seed coverage simulation fails
   without the fix and passes with it.
2. **Change log is not recorded for sync.** The plan said Task 10 would record sync mutations so
   sync could be switched on later; the sync engine rejects unregistered collections, so with
   Task 11 deferred that would break uploads. Plain local inserts instead; enabling sync later
   needs a backfill.
3. **Unscheduled questions.** Questions tagged to an out-of-scope or missing lesson were never
   offered; a final tier now schedules them (Task 6 review finding).
4. **Flaky under load:** `test/tool/content_export_roundtrip_test.dart` and
   `content_seed_writer_test.dart` failed once each while several suites ran at once, and pass
   alone and in a full rerun. Recorded, not fixed.

---

## Build complete, pending independent review, 1 October 2026 (about 02:40)

All plan tasks except the deferred Task 11 are on `web/roadmap-engine-r1` at `88bebdfe` (pushed).
Codex wrote Tasks 1, 2, 3 (audit), 4, 5, 6, 7, 13, 14 and 16; the lead wrote 6 fix, 8, 9, 10, 12,
15, 17 and the links, and reviewed every Codex result line by line against the spec. Lead fixes
applied on review: Task 6 orphaned questions; Task 13 crash on a withdrawn question; Task 16
crash on a missing lesson and a reminder read that could dispose the plan mid-load; Task 12
self-waiting future (caught by its own tests).

Gates at 88bebdfe: build_runner ok; `flutter analyze` only the accepted `bookmarks_sheet.dart`
onReorder info; `dart format` 1,270 files unchanged; layering OK; attribution OK; full suite
3,212 of 3,213 at `-j 4`. The one failure is `test/tool/import_questions/cli_test.dart` "fails
loudly on an invalid question": "Failed to codesign dylib ... .dart_tool/lib/objective_c.dylib:
replacing existing signature", a race between tool tests that each spawn `dart run`; it passes
alone. The content export and seed writer tool tests show the same load sensitivity. Pre-existing
tooling flake, not caused by this work; not fixed.

Grep gates: no `targetCount = 3`, `newCardCap`, `StudyPlanIntensity` or `pace_curve` in `lib`;
no verdict word in `lib/features/roadmap` except the spec's own field name `weeksAhead`.
Protected seed files byte-identical to E09 (content.db 0ef89a64..., manifest 51bc0a76...,
signature e0853df2...).

Independent review (plan Task 18 Step 4) dispatched to Codex as a tier-2 reviewer that did not
author the lead-written core. Device checks (Step 6) wait for Aedwon.
