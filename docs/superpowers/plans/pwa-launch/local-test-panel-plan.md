# Local test panel implementation plan

**PAUSED Oct 31.** Aedwon: "actually before you implement that can you finish the screens first".
No code was written (both Task 1 and 2 agents were stopped before any file change). Resume after
the visual pass of the remaining areas.

> For agentic workers: follow `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from origin/main. Steps
> use checkboxes. The lead commits; workers do not commit, push, fetch or switch branches.

**Spec (approved, Aedwon "lgtm", Oct 31):** `docs/superpowers/specs/2026-10-31-local-test-panel-design.md`.
**Presentation (1:1):** `docs/superpowers/plans/pwa-launch/boards/local-test-panel-b-v3.html`.
**Code branch:** `web/visual-check-fixes-r1`, worktree `/Users/aedwon/Documents/Projects/Pantas-wt-vc-fixes-r1`.

**Goal:** a local-only panel tab that controls the local web app: start fresh, Free/Pro/Real,
onboarding state cards, sample students, open any screen, fake today.

**Architecture:** a static page served only by the local runner sends JSON messages over
`BroadcastChannel('pantas-local-panel')`. The app starts a bridge only when the compile-time
`localEmulators` const is true. Start fresh and today are browser-side (a reset page and a `Date`
patch in the runner's existing `index.html` shim). Presets and sample students are applied by the
bridge after a fresh start, from a `localStorage` key.

## Global constraints

- Nothing reaches normal builds: every Dart entry point checks `localEmulators` (const), and
  every browser file is written by `tools/local/run_web_local.py` into `build/web` only.
- No user-facing control in the app. No change to phone or normal web behavior.
- American spelling, no em dashes in any text.
- `flutter analyze` clean; types written out (strict-casts, strict-inference).
- Sample data numbers come from generated records through the app's own code (spec, "Sample
  students"), never written as display values.

## Tasks

### Task 1: Panel page, reset page, date patch (browser side)

Files: create `tools/local/panel/index.html`, `tool/list_routes.dart`; modify
`tools/local/run_web_local.py`, `tools/local/test_run_web_local.py`.

- [ ] `tool/list_routes.dart`: parse `lib/app/router.dart` and `lib/app/routes/*.dart` for
  `path: '...'` (and the route's `name:` when present), resolve nested paths, drop duplicates,
  assign a group by first segment (Home and plan: home, plan, performance, record, tendencies;
  Study and quiz: study, lesson, quiz, assessment; Mock: quiz/mock, mock; Settings and Pro:
  settings, pro, legal; Developer: `_gallery`, `_debug`; Other: rest). Output JSON
  `[{path, label, group}]` to stdout. Label: humanized last static segment unless a better name
  exists. Test: `test/tool/list_routes_test.dart` runs it and expects `/home`, `/lesson/:lessonId`
  and no duplicate paths.
- [ ] `index.html`: layout B v3 exactly (header with status, Start fresh, Free/Pro/Real segment;
  tabs Onboarding, Sample students, Screens, Today; 4-column card grid; styles from the
  presentation). Loads `local-panel-routes.json`. Sends messages per spec "Messages". Start fresh
  uses `confirm('Start fresh? This clears this browser\'s Pantas data.')`. Status: ping every 2 s;
  "App tab not open" after 3 s without a reply. Screens search filters by label and path. Cards
  with `:param` other than `:examId` show an ID field and stay disabled until filled. Today tab
  shows the stored date in words ("Wednesday, October 14, 2026 (set)" or "Real date").
- [ ] Runner: copy `index.html` to `build/web/local-panel.html`; run `dart run
  tool/list_routes.dart > build/web/local-panel-routes.json`; write `build/web/local-reset.html`
  (spec "Start fresh"); add the panel link to `local-login.html`; print the panel URL. Extend the
  existing `index.html` shim with the date patch (spec "Today"): a `Date` subclass whose `now()`
  and no-argument constructor use the stored date plus the real time of day.
- [ ] Update `test_run_web_local.py` expectations for the new files and the shim.
- Verify: `python3 tools/local/test_run_web_local.py`; `dart run tool/list_routes.dart | head`.

### Task 2: App bridge (go, plan, status, fresh, reload)

Files: create `lib/core/dev/local_panel_bridge.dart`, `lib/core/dev/local_panel_bridge_web.dart`
(conditional import, stub for non-web); modify `lib/app/bootstrap.dart`,
`lib/features/paywall/application/paywall_providers.dart`; tests in `test/core/dev/`.

Interfaces produced:
- `Future<void> startLocalPanelBridge(ProviderContainer container)`; no-op unless
  `localEmulators && kIsWeb`. Called in bootstrap right after `registerDevDemoSwitch`.
- `abstract interface class LocalPanelChannel { Stream<Map<String, Object?>> get messages; void send(Map<String, Object?> m); }`
  with the web implementation over `BroadcastChannel`; tests use a fake.
- `Future<void> handlePanelMessage(Map<String, Object?> m, ProviderContainer c, LocalPanelChannel ch)`.
- Hooks for later tasks: `Future<void> Function(ProviderContainer, String id)? applyLocalPreset`
  and `applySampleStudent`, top-level variables assigned by Tasks 3 and 4; after bootstrap the
  bridge reads `localStorage['pantas.local.preset']` / `['pantas.local.student']`, removes the key,
  and calls the hook if set.

Steps:
- [ ] Tests first (fake channel): `go` pushes or goes per spec; `plan` sets `devProOverride` to
  true/false/null; `ping` replies status with current route and plan; unknown types are ignored;
  `startLocalPanelBridge` does nothing when `localEmulators` is false.
- [ ] Implement. `fresh`: reply `ack`, then `window.location.assign('/local-reset.html')`.
  `reload`: `window.location.reload()`. `preset`/`student`: store the key, then `fresh`.
  Route changes: listen to the router's `routerDelegate` and send status.
- [ ] Paywall: let `devProOverrideProvider` decide when `kDebugMode || localEmulators` (both
  places in `paywall_providers.dart`), so the profile local build honors the switch.
- [ ] Risk to check in Task 5: if Pro content is also gated server-side by the account's claims,
  Pro shows its UI but content fetches fail for a Free account. If so, report to the lead; do not
  change server rules.
- Verify: `flutter test test/core/dev test/features/paywall`; `flutter analyze`.

### Task 3: Onboarding presets

Files: create `lib/core/dev/local_onboarding_presets.dart`; modify the four steps
(`onboarding_age_gate_step.dart`, `steps/custom_track_name_step.dart`,
`onboarding_exam_date_step.dart` with `onboarding_web_calendar.dart` as needed,
`onboarding_study_days_step.dart`); tests in `test/features/onboarding/presentation/`.

Interfaces:
- `final ValueNotifier<LocalPresetSeed?> localPresetSeed` (local-only; read once in `initState`
  of each step, then cleared by the step that consumed it).
- `class LocalPresetSeed { String? birthYearText; String? customName; DateKnownMode? dateMode; int? year; int? month; int? day; Set<int>? studyDays; }`
  (use the steps' existing types for mode and days).
- Assigns Task 2's `applyLocalPreset` for the 19 ids in the spec's table (ids: `welcome`,
  `birthYear`, `terms`, `picker`, `dateKnown`, `days`, `name`, `under13`, `customName`,
  `customSubjects`, `dateNone`, `dateMonth`, `dateDay`, `dateNextYear`, `dateThisMonth`,
  `dateToday`, `daysNone`, `daysTooLate`, `daysSoon`).

Steps:
- [ ] Tests first: for each affected step, a seed produces the seeded state (age shows the blocked
  screen for 2020 when submitted; custom name shows the text; date picker shows the month/day;
  days shows the picked set and the too-late card for today + 3 with Sun to Tue).
- [ ] Earlier steps: write answers through the same application actions the steps call (no direct
  table writes), then navigate to `/onboarding` (or the custom routes) so the flow resumes at the
  target step.
- [ ] Panel card ids must match the ids above (Task 1 uses them).
- Verify: `flutter test test/features/onboarding`; `flutter analyze`.

### Task 4: Sample students

Files: create `lib/core/dev/local_sample_students.dart`; modify `lib/core/dev/dev_demo_switch.dart`
(replace `_populateFauxData` with a call to the new generator, Steady profile); tests in
`test/core/dev/local_sample_students_test.dart`.

Interfaces:
- `enum SampleStudent { newStudent, steady, behind, examWeek }` with panel ids `new`, `steady`,
  `behind`, `examWeek`.
- `Future<void> loadSampleStudent(AppDatabase db, ContentDatabase content, SampleStudent s, {required DateTime today})`.
- Assigns Task 2's `applySampleStudent`, then `go('/home')`.

Steps:
- [ ] Tests first, per profile, on in-memory databases with test content: Home's plan provider and
  streak load without errors; streak length matches (New 1, Steady 18, Behind 0, Exam week any
  >= 10); Behind has reviews due before today; mock attempt count (Steady 1, Exam week 4);
  exam date (New today + 120, Exam week today + 5). Same seed gives the same records.
- [ ] Implement per spec "Sample students": seeded random, records relative to `today`,
  CSE Professional, name "Aerol", Mon to Sat. Write only tables the app reads; let the app compute
  every displayed number.
- Verify: `flutter test test/core/dev`; `flutter analyze`.

### Task 5: Lead verification

- [ ] Full checks: `flutter analyze`, `flutter test`, `dart run tool/check_layering.dart`,
  `python3 tools/local/test_run_web_local.py`.
- [ ] Release safety: build `lib/main_prod.dart` for web and confirm `build/web/main.dart.js` has
  no `pantas-local-panel` string.
- [ ] Run the local app; open `/local-panel.html` in a second tab. Exercise Start fresh, each plan
  value, all 19 onboarding cards, the 4 sample students, 5 screens across groups (one with an ID),
  and Today (2026-10-14, then Real date). Record results in `docs/ui-audit.md` "Local test panel".
- [ ] Commit (no AI attribution lines), push the fixes branch, fast-forward staging, update the
  visual pass handoff. Aedwon compares the panel with the presentation.

## Execution

Lead dispatches Sonnet: Tasks 1 and 2 in parallel (disjoint files), then Task 3, then Task 4
(sequential: both touch the bridge hooks and run the analyzer over the same tree). Lead reviews
each result before the next dispatch.
