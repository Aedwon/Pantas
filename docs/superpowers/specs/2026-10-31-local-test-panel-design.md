# Local test panel

Date: 2026-10-31. Complexity: Balanced (Aedwon's choice). Decision record:
`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`, "Oct 31: local test panel".
Approved presentation: `docs/superpowers/plans/pwa-launch/boards/local-test-panel-b-v2.html`
(layout B, v2, all three tabs).

## For approval (plain language)

**What it is.** A page you open in a second browser tab while "Pantas Local Test" runs. It
controls the app in the other tab. It exists only in local runs. The staging and production
builds do not contain the page or the code that listens to it.

**What it does.**

- **Status line.** Shows whether the app tab is open and which screen it shows.
- **Start fresh.** After one confirmation, clears this browser's Pantas data and signs out. The
  app tab reloads as a brand-new student on Welcome.
- **Plan: Free, Pro, Real.** Free and Pro switch the app tab at once, without a reload. Real
  removes the switch, so the signed-in account decides.
- **Onboarding tab.** One card per onboarding state (19 cards, as in the mockup). A click starts
  fresh, fills in the earlier steps, and opens that state in the app tab. Example: "Study days:
  too late" opens the study days step with an exam in 3 days and Sunday to Tuesday picked.
- **Screens tab.** Every app screen, grouped by area, with a search field. A click opens it in the
  app tab. Screens that need an exam use the current one. Screens that need a lesson or an attempt
  ask for its ID in the card.
- **Today tab.** Sets the date the app treats as today, or returns to the real date. The app tab
  reloads to use it. The time of day keeps running. The local server keeps the real date.

**Look.** Layout B from the mockup: wide page, header with status, Start fresh and the plan
switch, then three tabs. The panel matches the mockup's layout, text, colors and sizes.

**Not included (Hardened scope):** sample study history, forced loading and error states (exam
list loading, error, empty), saved presets. Phone and dark layouts of the panel itself.

**Costs and risks.**

- About half a day of work. Small, local-only hooks are added to four onboarding steps so a card
  can open a step already filled in.
- If a hook leaked into a real build, a student could not reach it: there is no control in the
  app, and the listener only starts when the local-run flag is set. Tests check that the flag is
  off in normal builds.
- The fake date affects the app tab only. Anything the local server computes by date (for
  example, server-side checks) still uses the real date.

**Done when:** each card and control does what it says in the running local app, the app's
normal tests and analyzer pass, and Aedwon has compared the panel with the mockup.

## Agent section (technical)

Code branch: `web/visual-check-fixes-r1`, fast-forwarded into `web/staging-candidate-r1` after
verification.

### Panel page

- Source: `tools/local/panel/index.html` (single file: HTML, CSS, JS; no build step). Visual spec:
  the approved presentation above, 1:1 for header, tabs, card grid (4 columns), section labels,
  colors, radii and type sizes.
- `tools/local/run_web_local.py` copies it to `build/web/local-panel.html` next to
  `local-login.html`, adds a link to it on `local-login.html`, and prints its URL with the others.
- Same origin as the app (localhost:7357), so it talks to the app tab through
  `BroadcastChannel('pantas-local-panel')`.

### Messages (panel to app, JSON)

- `{type:'ping'}` -> app replies `{type:'status', route, plan}`; the app also sends status on
  every route change.
- `{type:'go', path}` -> `router.go(path)` for shell tabs, `router.push(path)` otherwise
  (AGENTS: push for destinations outside the tab shell).
- `{type:'plan', value:'free'|'pro'|'real'}` -> sets the existing `devProOverride` notifier
  (`true`, `false`, `null`). Do not persist it.
- `{type:'fresh'}` -> app replies `{type:'ack'}` and navigates the window to
  `/local-reset.html`.
- `{type:'preset', id}` -> stores the preset id in `localStorage['pantas.local.preset']`, then
  starts fresh. After reload, the app applies the preset (below).
- Today: the panel writes `localStorage['pantas.local.today']` (`YYYY-MM-DD`) or removes it, then
  sends `{type:'reload'}`.

### App bridge

- `lib/core/dev/local_panel_bridge.dart`, started from bootstrap only when `localEmulators`
  (const from `LOCAL_EMULATOR_HOST`) and `kIsWeb`. Uses `package:web` / `dart:js_interop`.
  Normal builds compile the const false branch away.
- Reads the router from `routerProvider` and `devProOverride` from `dev_pro_switch.dart`.
  `devProOverrideProvider` already rebuilds entitlement when the notifier changes; confirm it is
  watched in profile builds (registration is debug-only, but the notifier is not).

### Start fresh

`build/web/local-reset.html` (written by the runner): deletes every IndexedDB database
(`indexedDB.databases()`), clears OPFS (`navigator.storage.getDirectory()` entries), Cache
Storage, sessionStorage, and localStorage except `pantas.local.*` keys, then
`location.replace('/')`. The app must not be holding the databases: the app tab navigates to this
page itself, so its connections close first. A new anonymous student follows from the normal auth
bootstrap. Firestore emulator data of the old student is left alone; it is unreachable once the
local auth state is gone.

### Today

The runner's existing `index.html` shim gains a date patch before Flutter loads: if
`pantas.local.today` is set, replace `Date` with a subclass whose `now()` and no-argument
constructor return the chosen date at the current wall-clock time of day. Dart's `DateTime.now()`
on web reads `Date.now()`. Firebase token requests keep working because only the date changes for
the app tab and the emulators do not reject skewed client clocks; verify sign-in and content load
with a date 30 days ahead.

### Onboarding presets

Applied by the bridge after a fresh start when `pantas.local.preset` is set (then removed).
Earlier steps are written through the same application actions the steps use (birth year, policy
acceptance, exam pick of CSE Professional, exam date, study days), and the onboarding flow then
resumes at the target step. In-step state uses a local-only `ValueNotifier<LocalPresetSeed?>`
read once by the four affected steps in `initState` (age year text; custom exam name text; date
step mode, month and day; study days selection). Normal builds never set it.

| Card | Opens | Seed |
|---|---|---|
| Welcome | Welcome | none |
| Birth year | Age | empty |
| Terms | Terms | age passed |
| Exam picker | Picker | + policy accepted |
| Exam date: known | Date, known card | + CSE Professional |
| Study days | Days, Mon to Sat | + exam date known |
| Your name | Name, empty | + days Mon to Sat |
| Under 13 | Age blocked | year 2020 submitted |
| Custom exam: name | Custom name, empty | policy accepted |
| Custom exam: subjects | Custom subjects | name "Nursing Board" |
| Date: nothing picked | Date picker, no month | CSE Professional, Different Date |
| Date: month picked | Picker, December of this year | |
| Date: day picked | Picker, December 15 | |
| Date: next year | Picker, February next year | |
| Date: this month | Picker, current month, no day | |
| Date: exam today | Picker, today picked | |
| Study days: none | Days, none picked | exam date today + 3 |
| Study days: too late | Days, Sun to Tue | exam date today + 3 |
| Study days: exam soon | Days, Wed to Fri | exam date today + 3 |

"December" and "next year" are relative to the panel's today, so boards dated Oct 14 2026 match
when Today is set to 2026-10-14.

### Screens tab

Generated by the runner from the router: `tools/local/panel/routes.json`, written by a small Dart
script (`tool/list_routes.dart`) that walks `lib/app/router.dart` and `lib/app/routes/` route
definitions and outputs `{path, name, group}`. Duplicates (`/pro`, `/settings/pro`) appear once
per path. `:examId` is filled by the app bridge with the active exam; other parameters come from
the card's ID field (card disabled until filled). Debug-only routes (`/settings/_gallery`,
`/settings/_debug`) are listed under "Developer".

### Tests and checks

- Unit test: the bridge is not started when `localEmulators` is false.
- Unit tests for message handling (go, plan, preset parsing) with a fake channel.
- Widget tests for each seeded step: given a seed, the step shows the seeded state.
- `flutter analyze`, `flutter test`, `dart run tool/check_layering.dart`,
  `python3 tools/local/test_run_web_local.py`.
- Lead: run the local app, open the panel, exercise every control and every card once, and record
  results in `docs/ui-audit.md`. Aedwon performs the visual comparison of the panel with the mockup.
