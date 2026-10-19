# C10 spike: roadmap engine compiled to JavaScript

Verdict: **works**, with caveats below. `BuildRoadmap.call` compiles with
`dart compile js` unchanged and returns output identical to the Dart VM for 10
scenarios. No file in `lib/` was touched.

## Numbers (Dart 3.12.2, Node v26.10.0, Apple silicon, local)

| Build | Raw | Gzip | Compile time |
|---|---|---|---|
| `-O2` | 106,148 B | 33,076 B | 0.69 s (compiler report; about 2 s wall on first run) |
| `-O4` | 101,310 B | 31,649 B | 0.61 s |

Node, 100 calls per scenario, JSON parse of the input and JSON encode of the
output included (input 69 to 76 KB, 840 to 960 questions):

| Scenario | -O2 median / p95 | -O4 median / p95 |
|---|---|---|
| planning_rich | 1.21 / 1.86 ms | 0.76 / 1.02 ms |
| planning_large_120x900 | 1.09 / 1.65 ms | 0.71 / 0.95 ms |
| review_only_anchored | 0.93 / 1.25 ms | 0.54 / 0.65 ms |

Cold load (require of the JS file): 3 to 5 ms at -O2, 7.5 ms at -O4 (single
runs, noisy). Plan to measure again on a real Cloud Function cold start.

## Commands (from the worktree root)

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed files the closure imports
dart run spike/roadmap_js/make_fixtures.dart               # writes fixtures/scenarios.json
dart run spike/roadmap_js/expected.dart                    # Dart VM reference, fixtures/expected.json
spike/roadmap_js/build.sh O2                               # or O4; writes build/roadmap.O2.js
node --test spike/roadmap_js/                              # ROADMAP_JS=... to pick the -O4 file
```

Result: 16 of 16 Node tests pass for both -O2 and -O4. They check each
scenario (parsed and byte for byte), the whole file byte for byte, a run inside
a bare `vm` context, no browser globals created, and 20 repeated calls equal.

## What the test shows

- Scenarios: rich planning, Sunday rest day on a Mon to Sat plan, 120 lessons
  by 840 questions, anchored review-only stretch, exam passed, month-precision
  exam, no exam date, prerequisite cycle, needs assessment, no content.
- No compile errors, no changes needed. The only setup is the existing
  build_runner step, because `question.dart` (freezed) is in the import closure.
- Input and output JSON mapping lives in `codec.dart` (spike only). The engine
  types have no JSON of their own except `RoadmapDayCounts`.

## Browser APIs and runtime

- Load-time references to `navigator`, `document` and `self` exist in the
  Dart runtime preamble but every one is guarded by `typeof ... != "undefined"`.
  Loading in an empty V8 context (no `window`, `document`, `process`, timers,
  `console`) works and returns the exact expected output.
- The code uses only `dart:js_interop` (one `globalThis` property set), not
  `dart:html`. It needs nothing newer than ES2015-era features Node 20 has.
- Caveat: only Node v26 was available locally. Node 20 itself was not run;
  the bare-context test is the evidence, not a Node 20 run. Run the same test
  on Node 20 (and in the Functions emulator) before relying on it.
- Node 21+ defines `navigator`; Node 20 does not. The test compares before and
  after load rather than asserting absence.

## Time and determinism

- The engine never calls `DateTime.now()` in its import closure (checked by
  grep over `roadmap/domain`, `core/time`, `exam_date.dart`, and the quiz
  model files it imports). "Now" is the `today` input.
- It uses `DateTime(y, m, d)` local-time arithmetic, so the process time zone
  matters at day boundaries. The spike passes dates with no offset
  (`2026-09-29`, `2026-09-29T08:05:00`) and reads them back as local.
  The Dart VM output was identical (same SHA-1) under TZ = Asia/Manila, UTC,
  America/New_York and Pacific/Auckland, and the JS output matched under each.
  This holds because the codec treats every value as a calendar date. A
  production reader must do the same: convert instants to the student's
  Philippine calendar date before building `today`, `readAt`, `due` and
  `lastSubmittedAt`, and run the function with `TZ=Asia/Manila` as a guard.
  A Cloud Function runs in UTC by default; do not pass raw UTC instants.
- Repeated calls return identical strings. No randomness found in the closure.

## What production needs

1. Move the pure closure (roadmap domain, `core/time`, `exam_date`, `ids`,
   question models) into a shared package (for example `packages/pantas_core`)
   used by the app and the compiled bundle. The `lib/` import paths change.
2. Promote `codec.dart` into that package with a versioned JSON schema and
   golden fixtures shared by the Dart test and the Node test.
3. A server input reader over the C9 Firestore answers and the exam settings:
   build `RoadmapInputs` (including `answeredPerActiveDay`, review
   retrievability, `anchoredReviewOnlyFrom`, `seenQuestionIds`) with the
   Philippine date rule above.
4. Build step in CI (`dart compile js`), commit or publish the artifact into
   `functions/`, and check bundle size and cold start in the deployed function.
5. Output is only `Roadmap` here. Roadmap diffing, `SittingPlanner`, and the
   insight signals are not covered by this spike.
