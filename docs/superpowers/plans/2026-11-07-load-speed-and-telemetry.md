# Load speed and telemetry: implementation plan

> For workers: read `AGENTS.md`, `WORKFLOW.md` and `SUBAGENTS.md` from main first, then the
> spec `docs/superpowers/specs/2026-11-07-load-speed-and-telemetry-design.md` (main), then
> only your own task below. Test first, one task at a time, in your own worktree.

**Goal:** measure startup and screen speed from every tester, report web errors, then cut the
returning-visit wait and the post-quiz wait, before the Nov 9 beta.

**Architecture:** telemetry ships first in its own deploy (Phase 1) so the current speed is
measured; speed fixes ship second (Phase 2). Client reports go to one new callable that writes a
structured Cloud Logging line; no Firestore. A local script reads the logs.

**Base:** `web/visual-check-fixes-r1` at 571eea1aa. Integration branch: `web/load-speed-r1`.
Policy: main at 621169316.

## Global constraints

- No security weakening: App Check enforced on the new callable, auth required (anonymous
  accepted), no change to existing gates, rules, limited-use tokens or server checks.
- Reports never contain uid, email, name, tokens, IP, question ids, lesson ids, answers or
  content. Error messages pass through the sanitizer in Task B4 before leaving the device.
- No Firestore reads or writes for telemetry. No new scheduler job. No minimum instances.
- No new Dart or npm dependency.
- No visible change except the approved splash hand-over (Task C6) and the approved privacy
  notice text (Task B5). Notice wording is exactly the spec's.
- No em dashes; American spelling; commit messages explain why; no AI attribution lines.
- Do not touch sign-in, the beta gate's logic, guardian flows or the service worker's caching
  logic except where a task names it.

## Shared contract (Phase 1)

Callable `reportClientTelemetry`, region `asia-southeast1`, `enforceAppCheck` like
`getWebEntitlement`, normal (not limited-use) App Check token on the client.

Request `data`:

```json
{
  "v": 1,
  "build": "1293236267-5bbf79dc07b4",
  "visit": "return",
  "browser": "chrome",
  "mobile": true,
  "viewport": "phone",
  "timings": [{"n": "boot.firebase", "ms": 412}],
  "errors": [{"type": "StateError", "msg": "Bad state: ...", "stack": ["package:pantas/..."], "count": 1}]
}
```

- `v` must be 1. `build` string up to 40 chars, `[A-Za-z0-9._-]`.
- `visit` one of `first`, `return`, `after_deploy`.
- `browser` one of `chrome`, `safari`, `firefox`, `edge`, `samsung`, `other`.
- `mobile` boolean. `viewport` one of `phone` (<600 px), `tablet` (<1024), `wide`.
- `timings` up to 40 items; `n` matches `^[a-z0-9_.]{1,40}$`; `ms` integer 0 to 600000.
- `errors` up to 10 items; `type` up to 60 chars; `msg` up to 300; `stack` up to 8 strings of
  up to 200; `count` integer 1 to 1000.
- Anything else, or any extra key: `invalid-argument`.
- Response `{"ok": true}`; when rate limited `{"ok": true, "dropped": true}`.

Log line: `logger.info('client_telemetry', {kind: 'client_telemetry', ...data})`.
Server timing line: `logger.info('fn_timing', {kind: 'fn_timing', fn, ms, cold, outcome, code?})`.

Timing names (client): `page.helpers`, `page.worker`, `page.loader`, `boot.firebase`,
`boot.appcheck`, `boot.storage`, `boot.contentdb`, `boot.flags`, `boot.auth`, `boot.content`,
`boot.consent`, `boot.payments`, `boot.sync`, `boot.gates`, `boot.runapp`, `beta.resolved`,
`home.firstframe`, `home.data`, `splash.ready`, `splash.removed`, `screen.home`,
`screen.lesson`, `screen.quizstart`, `screen.quizend`. `page.*`, `boot.*`, `beta.*`, `home.*`
and `splash.*` are milliseconds since navigation start; `screen.*` are durations from the
route push to that screen's first settled frame.

---

## Phase 1: telemetry

### Task A1: `reportClientTelemetry` callable (functions)

Files: create `functions/src/clientTelemetry.ts`, `functions/test/client-telemetry.test.mjs`;
modify `functions/src/index.ts` (export).

- Pure `validateClientReport(data: unknown): ClientReport` throwing `HttpsError('invalid-argument')`
  per the contract; pure `RateLimiter` (per instance, keyed by a SHA-256 of uid, 30 reports per
  rolling minute, map pruned so it cannot grow past 5,000 keys).
- Handler: auth required, validate, rate check, log line, return.
- Tests first: every contract bound (one passing and one failing case each), extra key refused,
  rate limit drops the 31st report in a minute and allows after the window, the logged object
  never contains `uid` or any auth field.
- Add the name to the App Check test lists the repo keeps (`functions/test/app-check.test.mjs`)
  as a normal (not replay-protected) callable, and to `instance-caps` if that test lists every
  function.

### Task A2: server timing on every callable (functions)

Files: create `functions/src/_timed.ts`, test `functions/test/timed.test.mjs`; modify every
file that exports an `onCall` (36 sites).

- `export function timed<T, R>(fn: string, handler: (request: CallableRequest<T>) => R | Promise<R>)`
  returns a handler that measures wall time, logs the `fn_timing` line once per call with
  `cold: true` only on the first call in that instance, `outcome: 'ok' | 'error'` and the
  `HttpsError` code when there is one, and rethrows errors unchanged.
- Wrap each `onCall(options, handler)` as `onCall(options, timed('<exportName>', handler))`.
  No other change in those files.
- Tests first: logs once per call; cold only first; error rethrown with same code; no uid in the
  line. Existing unit and emulator suites must stay green.

### Task A3: readout script

Files: create `tools/telemetry/report.mjs`, `tools/telemetry/report.test.mjs`,
`tools/telemetry/README.md`.

- `node tools/telemetry/report.mjs --project pantas-prod --hours 24 [--build <id>] [--visit return]`
  runs `gcloud logging read` for `jsonPayload.kind="client_telemetry"` and `"fn_timing"` and
  prints: per timing name count, p50, p90, max; per function count, p50, p90, cold share, error
  count; errors grouped by type plus first stack line.
- Pure `summarize(entries)` and `percentile(values, p)` are unit-tested with fixtures.

### Task B1: page and boot timeline (web and Dart)

Files: modify `web/index.html` (one inline `performance.mark('page.helpers')` after the helper
scripts), `web/pantas_pwa.js` (mark `page.worker` when `registerWorker` resolves; expose
`pantasPwa.visitKind()` returning `first` when no controller existed at load, `after_deploy`
when the controller's `?v=` differs from this build, else `return`), `web/flutter_bootstrap.js`
(mark `page.loader` before `_flutter.loader.load`), `web/pantas_splash.js` (marks
`splash.ready`, `splash.removed`); create `lib/core/telemetry/perf_timeline.dart` with
web/stub split like `first_screen_ready.dart`; modify `lib/app/bootstrap.dart` (one mark after
each awaited step, names from the contract), `lib/core/auth/beta_access.dart` (mark
`beta.resolved` on first value), `home_today_screen.dart` (marks `home.firstframe`,
`home.data`), and the lesson reader, quiz start and quiz end screens for `screen.*`.

- API: `PerfTimeline.mark(String name)`, `PerfTimeline.measure(String name, Duration d)`,
  `PerfTimeline.entries()` returning the list for the reporter. Names validated against the
  contract regex in debug builds.
- JS tests in the existing web test files for the new marks and `visitKind`.
- Dart tests: marks recorded in order; unknown name asserts in debug.
- `?timing=1` prints `console.table` of the entries at `splash.removed`.

### Task B2: client reporter

Files: create `lib/core/telemetry/client_report.dart` and its test; wire in `bootstrap.dart`.

- Collects `PerfTimeline` entries and errors; sends one report after `splash.removed` (or after
  the first screen when there is no splash), then at most one per 60 s while there is new data,
  and one on page hide (`visibilitychange` to hidden). Max 20 distinct errors per page session,
  deduplicated by type plus first stack line, counted.
- Sends through `FirebaseFunctions.instanceFor(region: 'asia-southeast1')` with
  `callableOptionsFor('reportClientTelemetry')`. Failures are swallowed; never retried more
  than once; never blocks UI.
- Always on for web (spec option A). Native builds: no-op.
- Payload built only from the contract fields. Tests: payload shape, send cadence with a fake
  clock, dedupe, cap, no uid anywhere in the payload.

### Task B3: study-loop events (Analytics, consent-gated)

Files: `lib/core/telemetry/telemetry.dart` (new enum values with a comment naming the question
they answer: "Where do students stop in the study loop?"), the places that start and finish a
study session, open and finish a lesson, and view the Pro page.

- Names: `study_session_start`, `study_session_finish`, `lesson_open`, `lesson_finish`,
  `pro_view`. Mock start and finish already exist (`mock_started`, `mock_completed`); reuse them.
- Parameters: exam id, session kind, item count only. Go through the existing
  `GatedTelemetry`, so nothing is sent without usage-sharing consent.
- Tests: each event fires once at its place; nothing fires with consent off.

### Task B4: web error reports

Files: `lib/core/telemetry/firebase_telemetry.dart` (on web, `recordError` hands the error to
the client reporter instead of doing nothing), sanitizer in `client_report.dart`.

- Sanitizer: message cut to 300 chars; email addresses, long digit runs (6+), URLs' query
  strings and anything that looks like a token (20+ chars of base64url) replaced with `<x>`.
  Stack frames keep only `package:` paths and line numbers.
- Tests: each pattern removed; phone path unchanged.

### Task B5: privacy notice

Files: `lib/features/legal/domain/legal_document.dart` and its tests or goldens.

- Add the section titled "Speed and error reports" with the spec's exact text, after
  "Optional usage sharing", and the sentence "Speed and error reports from the web app go to
  Google Cloud logs." after the Analytics sentence in "Where your data goes".
- The legal-basis list has no line for these reports. Do not write one: the lead brings
  proposed wording to Aedwon, and it is added only after his approval.
- The pantas-web site copy, if it has one, is a separate change for Aedwon's approval: report,
  do not edit.

### Phase 1 gate (lead)

Full checks (Flutter, analyze, format, layering, attribution, `run_checks`, functions unit and
emulator) on hosted Actions; review; then ask Aedwon to approve deploy 1 (functions:
`reportClientTelemetry` plus all callables for the timing wrapper; hosting). After deploy: one
live report from the lead's own browser seen in the logs via Task A3, and the post-deploy
checks in `docs/deploy-prod.md`.

---

## Phase 2: speed (after deploy 1 has collected a baseline)

Each task follows the spec's Part 2 item of the same letter and number exactly; the spec holds
the line references and required tests.

- **Task C1 (S1):** warm list in `functions/src/keepWarm.ts` plus tests.
- **Task C2 (S2):** `firebase.json` edge cache headers, worker script excluded; a test in
  `test/tool/` that reads `firebase.json` and checks the rules.
- **Task C3 (S3):** Remote Config started early; preconnects.
- **Task C4 (S4 and S5):** beta check started during bootstrap; entitlement read overlapped
  with content restore.
- **Task C5 (S6 and S7):** Home loader once per plan change, no skeleton during refresh;
  observation flush skips sent rows and shares one in-flight flush.
- **Task C6 (S8):** splash released at Home's first frame; Smoothest cross-fade on data
  (board version 6, Web_B_Still and Phone_B_Fade).

### Phase 2 gate (lead)

Same checks; review; ask Aedwon to approve deploy 2; afterwards compare the readout before and
after by build id and report measured numbers with report counts.
