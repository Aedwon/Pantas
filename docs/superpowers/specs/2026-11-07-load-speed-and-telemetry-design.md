# Load speed and telemetry before the beta (Nov 7, 2026)

Status: draft for Aedwon's approval. Workstream: `web/visual-check-fixes-r1` at 571eea1aa
(the build live at https://app.pantas.study). Policy: main at 8d81dad6f.

Sources: three read-only audits on Nov 7 (two Codex Astra, one Opus) and the Nov 6 Sol
review. Their reports and the comparison are kept with this spec's evidence in
`docs/superpowers/plans/load-speed/audits/`.

---

## Part 1: For approval (plain language)

### What Aedwon asked for

- "this screen still takes too long for my taste on first load. any way you could speed
  this up? ... explore other things that could be sped up as well"
- Keep within the Blaze free allowances, and do not weaken security.
- "is it possible to add telemetry in everything we can so that we can have a lot of
  insights on things?" then "Yes, add it".
- Scope chosen: Balanced. Splash: "Yes, show me a board".

### Why the logo screen stays so long

On a return visit, the logo stays up while about ten startup steps run one after
another. Several of them wait on the network: the beta check, the Pro check, the app
settings fetch, and Home's plan. Only when Home's data has fully loaded does the logo
fade. Nothing in the app records how long each step takes, so the audits could only
estimate most of the time.

### What changes (speed)

1. **Keep the after-quiz functions warm.** The functions that save a finished quiz or
   lesson, and the quiz-end diagnosis, take 2.5 to 3.4 seconds when cold and 0.2 seconds
   when warm (measured). They join the existing 5-minute warm-up. Cost: $0.
2. **Cache startup files at Google's edge near the student.** Files that must always be
   fresh are cached at the edge until the next deploy, which clears them. Browsers still
   check for a newer copy every time. Removes slow 0.2 to 0.7 second outliers (measured).
3. **Run startup checks side by side.** The beta check, the Pro check and the app settings
   fetch start early and run while the app restores its content. Each check is still
   finished before the first screen shows, exactly as now. Estimated saving: 1 to 2 seconds,
   more when a function is cold.
4. **Home loads its data once.** Today Home can rebuild its plan up to three times on a
   return visit, and briefly shows the loading skeleton again between copies. After the
   change it builds once per plan change and keeps showing the plan while it refreshes.
5. **Quiz results are sent once.** After a quiz, two parts of the app can send the same
   result at the same time. Before every Home load, the app also rereads the student's whole
   study history to find unsent items. After the change it sends each result once and skips
   items already sent without loading them.
6. **Splash hand-over.** As decided on the "Splash Hand-off" board (see below).

Dropped from Balanced, with reason: the single 50-read content limit check. With 20 testers
its read cost is a few thousand reads a day, far inside the free 50,000, and the fix is
delicate concurrency code. It moves to after the beta.

### What changes (telemetry)

1. **Startup and screen timings.** The app records how long each startup step takes, and how
   long Home, a lesson, a quiz start and the quiz end take to become usable.
2. **Errors from the web app.** Today web errors are recorded nowhere. They will be reported,
   with personal details removed.
3. **Server timings.** Every function logs how long it took and whether it started cold.
4. **Study steps.** Analytics events for: session started, session finished, lesson opened,
   lesson finished, mock started, mock finished, Pro page viewed. These follow the existing
   "Help improve Pantas by sharing usage data" choice, which starts off.
5. **A readout.** One command prints each step's typical and slowest times from the reports,
   so each later fix is chosen from real numbers.

All of this stays free: reports go to Google Cloud logs (50 GB a month free, kept 30 days),
about 1 to 3 small reports per app open. No Firestore reads or writes.

### Decision needed: who sends speed and error reports

| Option | What it means | Cost |
|---|---|---|
| **A. Everyone, without identity (recommended)** | Timings and errors from every tester. Reports carry no account ID, no answers, no question IDs and no lesson content: only step names, times, browser type and a cleaned error message. | The privacy notice needs a new short section (wording below). You accept the legal basis yourself, without a lawyer. |
| B. Only testers who turned on usage sharing | No notice change. | Sharing starts off, so likely only a few of the 20 testers send data. Much weaker numbers. |

Proposed notice section for A (in-app privacy notice; needs your approval of the wording):

> **Speed and error reports.** To find slow screens and errors, the web app sends short
> technical reports: how long loading steps took, your browser type, and error details.
> These reports do not include your account ID, your answers, or lesson content. Google
> keeps them for 30 days.

And in "Where your data goes", after the Analytics sentence: "Speed and error reports from
the web app go to Google Cloud logs."

### Splash hand-over (board): decided

Board: Claude Design canvas "Splash Hand-off", https://claude.ai/artifact/VFNGCm2nCqhxqD1Je7mbRe,
version 6, boards Web_B_Still and Phone_B_Fade, built from the live splash code and the
approved Pantas Web and Pantas Redesign boards (L_PlanSlow, HM_DayStart, X_Side).

Aedwon chose B, then "Smoothest": the logo fades as soon as Home first draws, Home's loading
shapes pulse until the plan arrives, then the content fades in over the shapes while they fade
out underneath (shapes out over 0.2 s, content in over 0.3 s after 0.06 s), with no rise or
other movement at that moment. Phone and web behave the same.

### Order of work and deploys

1. Telemetry first, deployed alone (needs your approval), so the current speed is measured
   on your own phone and laptop.
2. Speed changes second, deployed after you approve, then measured again with the readout.
3. Both before Nov 9.

### Not in this batch (after the beta)

Removing the 4-second service-worker wait after each deploy (versioned build folder);
loading only the content each screen needs at startup; deferring math fonts; the 50-read
limit check; inlining the four small startup scripts.

### How completion is judged

- All required checks pass on the combined work, with output kept.
- After each deploy, the readout shows timings for every startup step.
- After the speed deploy, return-visit time to usable Home is lower than the telemetry
  baseline, reported as measured numbers with how many app opens they cover.
- No security check is removed or loosened; the server still checks every paid action.
- Aedwon checks the splash hand-over by eye against the approved board.

---

## Part 2: Agent detail

File and line references are at 571eea1aa. Implementers re-read each cited line first.

### Speed

- **S1 warm list.** `functions/src/keepWarm.ts:6-9` targets: add `ingestSession`,
  `recordLessonRead`, `getSessionDiagnosis`, `advanceRoadmap`. Same OPTIONS mechanism, same
  single scheduler job. Update its tests.
- **S2 edge cache.** `firebase.json` hosting rules for `/index.html`, `/`, `/*.js`,
  `/manifest.json`, `/version.json`: value `public, max-age=0, must-revalidate,
  s-maxage=31536000`. Leave `pantas_sw.js` (and any worker script) on `no-cache`: add an
  explicit rule after `/*.js` for it. Firebase Hosting clears its CDN on every release.
  Verify after deploy: two `curl -I` requests, second shows `x-cache: HIT`.
- **S3 Remote Config.** `lib/app/bootstrap.dart:284`: start
  `bootstrapRemoteFlagsOverrides()` right after Firebase init, await its future at the
  current line. Add preconnects for `firebaseremoteconfig.googleapis.com` and
  `firebaseinstallations.googleapis.com` (with `crossorigin`) in `web/index.html`.
  Test: a failing fetch still yields the fallback; minimum-version gate unchanged.
- **S4 beta check early.** After `ensureAnonymous` in bootstrap, when the beta gate is
  active and the user is signed in (same condition the gate uses), start
  `container.read(betaAccessProvider.future)` unawaited, errors ignored. The router keeps
  reading the same non-autoDispose provider. Limited-use token and server check unchanged.
  Tests: gate active and inactive, anonymous user does not call, router reuses the result
  (one call), identity change still invalidates.
- **S5 entitlement overlap.** Start `bootstrapRevenueCat(container)` before
  `mirror.start` and await it after, still before sync bootstrap and `runApp`. Preserve
  `prepareForIdentityChange` ordering. Tests: identity change during startup, downgrade.
  Do not make it unawaited.
- **S6 Home loader.** `home_today_screen.dart:413-417,164-167,425-437`. (1) Ignore the
  first loading-to-data transition of `serverStudyRoadmapProvider` while the current request
  is pending. (2) Retry only when the plan's revision, day or planned id lists differ from
  the plan the shown data was built from. (3) While a retry runs with data on screen, keep
  showing the previous data, not the skeleton. Owner and exam guards unchanged; errors after
  data keep today's handling. Widget tests: cached then same-revision network copy builds
  once; different revision rebuilds without a skeleton flash; owner change still aborts.
- **S7 observation flush.** `study_observations.dart:29-100`: load sent receipt keys once per
  flush into a set and skip sent rows before `byId`; drop the second row load. Share one
  in-flight flush per uid+exam+core across `StudyObservations` instances (provider-level
  future). Server idempotency and receipts unchanged. Tests: sent rows are not loaded;
  concurrent lifecycle and reader flushes send once.
- **S8 splash (board version 6, B Smoothest).** Home calls the splash `ready()` at its first
  frame with the skeleton drawn, not after the data (`home_today_screen.dart:427`); other
  routes keep today's rule. When data arrives, the loaded Today and performance sections
  cross-fade over the skeleton: skeleton opacity 1 to 0 over 200 ms, content 0 to 1 over
  300 ms starting at 60 ms, the skeleton kept in the tree until the fade ends; no slide,
  scale or entrance replay on that change. Errors after the skeleton keep today's handling.
  Reduced motion: instant swap. Splash fade, 8 s and 60 s limits unchanged. Widget test: the
  skeleton and content are both present mid-fade and no translation is applied; JS test:
  ready at Home's first frame.

### Telemetry

- **T1 marks.** A small client timeline: JS `performance.mark` at head start, worker
  resolved, loader start; Dart marks (via `dart:js_interop`) at each awaited bootstrap step,
  real `runApp`, beta resolved, Home data done, splash ready and removal. Screen timings for
  Home, lesson reader, quiz start, quiz end: from route push to that screen's first settled
  frame. `?timing=1` prints a console table.
- **T2 transport.** New callable `reportClientTelemetry` (App Check enforced, auth required,
  anonymous accepted), region `asia-southeast1`. Payload: build version, visit kind
  (first, return, after deploy), browser family, viewport class, up to 40 timing entries
  (name, ms) and up to 10 error entries (type, sanitized message up to 300 chars, top 8
  stack frames, count). Rejects larger payloads. Writes one structured log line per report
  with `logger.info`; never logs uid, email, token, IP, question or lesson ids. In-memory
  per-instance limit of 30 reports per minute per uid hash, dropped silently. Client sends
  at most one report after splash removal, then at most one per 60 s while there is new
  data, and on page hide if allowed; errors deduplicated by fingerprint, max 20 per session.
- **T3 web errors.** Route `recordError` on web to the T2 buffer, using the existing
  sanitizer. Phone Crashlytics path unchanged.
- **T4 server timing.** A wrapper used by every `onCall` export (36) that logs
  `{fn, ms, cold, outcome}` where `cold` is the first invocation on the instance. No uid.
- **T5 study events.** Through the existing gated telemetry (`GatedTelemetry`), names
  `session_start`, `session_finish`, `lesson_open`, `lesson_finish`, `mock_start`,
  `mock_finish`, `pro_view`, with only exam id, kind and counts as parameters.
- **T6 readout.** `tools/telemetry/report.mjs`: runs `gcloud logging read` for the last N
  hours on a given project and prints p50, p90 and max per timing name and per function,
  plus error counts by fingerprint.
- **Consent.** T1 to T4 follow the approved option (A: always on, no identity; B: only when
  usage sharing is on). T5 always follows usage sharing.
- **Notice.** If A, update `lib/features/legal/domain/legal_document.dart` with the approved
  wording only, and the web copy of the notice if one exists, with Aedwon's approval.

### Costs

- Warm list: +34,560 OPTIONS requests a month (total about 95,000 of 2,000,000 free).
- Telemetry: about 20 testers x 10 opens x 3 reports = 600 calls a day; logs well under 1 GB
  a month. Zero Firestore operations. One more function in the deploy.
- No minimum instances. No new scheduler job.

### Verification

`flutter test`, `flutter analyze`, `dart format --set-exit-if-changed lib test`,
`dart run tool/check_layering.dart`, `dart run tool/check_no_ai_attribution.dart`,
`dart run tool/checks/run_checks.dart`, functions `npm test` (unit and emulator), full sets
on hosted Actions. Deploys only with Aedwon's approval.
