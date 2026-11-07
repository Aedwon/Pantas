# Feedback (Beta) client: verification record

Candidate: `web/beta-feedback-ui-r1` at 0b836dc4a (tree identical to 8fb4197c2). Policy: origin/main
4b8ea2833, unchanged through e2aacdaac. Plan: `docs/superpowers/plans/2026-11-07-beta-feedback-client.md`.

## History on the branch

- c791c5bdf merge of `web/visual-check-fixes-r1` 571eea1aa into `web/beta-feedback-r1` 1c1f42942.
- 6bd3cd8f5 plan and shared interface (lead).
- Lane D (Sonnet, `web/beta-feedback-data-r1`, fast-forward): 91ef327e9, 02e599aaf, 8a929f19d,
  904fed39d, d255c5623, 6e2d30776.
- Lane U (Sonnet, `web/beta-feedback-screens-r1`, merged): 0a53cc6d9, 6eab3033a, 495e49be4,
  63f9ba655, 1e685f7e6.
- Lead integration: 9e9f468d2 (Cmd/Ctrl+Enter ignores key repeats; the three routes added to the
  direct-load and route-split guards), 8fb4197c2 (sent images use the `<img>` fallback so Storage
  URLs show without bucket CORS).
- bac169f4b Tester Guide row, reverted in 0b836dc4a: the lead withdrew the request (relayed in
  error; the guide link placement after Nov 9 is undecided).

## Local checks (macOS, Flutter 3.44.6), after generating code, l10n and the content seed as CI does

| Command | Candidate | Result |
|---|---|---|
| `flutter analyze` | 8fb4197c2 tree | `No issues found!` (with empty local `content.manifest.*` placeholders, gitignored) |
| `dart format --output=none --set-exit-if-changed lib test` | merge of both lanes | `Formatted 1995 files (0 changed)`, exit 0 |
| `dart run tool/check_layering.dart` | 8fb4197c2 tree | `check_layering: OK` |
| `dart run tool/check_no_ai_attribution.dart` | merge of both lanes | `check_no_ai_attribution: OK` |
| `dart run tool/checks/run_checks.dart` | merge of both lanes | exit 0 (one accepted, pre-existing `lesson-list-exam-scope` hit) |
| `flutter test` (full) | merge of both lanes, before 9e9f468d2 | `+7940 -3`: `router_paths_preserved_test`, `start_location_routes_test`, `enter_repeat_test`, all fixed in 9e9f468d2 |
| `flutter test test/app/router_paths_preserved_test.dart test/app/start_location_routes_test.dart test/core/ui/enter_repeat_test.dart test/features/beta_feedback` | 9e9f468d2 | `+152: All tests passed!` |
| `flutter test test/features/beta_feedback/presentation/sent_feedback_page_test.dart` | 8fb4197c2 | `+6: All tests passed!` |
| `flutter build web --release --no-web-resources-cdn -t lib/main_dev.dart` | merge of both lanes | `✓ Built build/web` |

## Hosted CI on 0b836dc4a

- CI run 42372514669: success. Jobs static, web, android, functions, sast, coverage, test (0) to
  test (5) success. `osv` failure is the known non-blocking report (launch log, Nov 7 telemetry
  entry).
- Browser journeys run 42372514552: success.

## Not verified

- No browser, device or screenshot check (Aedwon does visual checking). Motion timing, fidelity to
  the boards, light and dark, phone and wide web are for his eye check.
- Nothing ran against pantas-prod or the emulators from the client: real uploads, Storage rules,
  the Firestore sent list, App Check limited-use tokens, `image_picker`, drop and paste, and the day
  reporter against the real roadmap are covered by unit tests with fakes only.
- The server lane (functions, `firestore.rules`, `storage.rules`) is unchanged from 1c1f42942; CI's
  functions job passed on this candidate.

## Differences from the boards (for the eye check)

Lead rulings for states no board draws (plan, "Undrawn states"): the Exit Survey row before,
during and after the window; "5 of 5 days" for counts over 5; the sent item page; image-only rows;
error toasts and file refusals; the wide survey counter counting Q7 when filled.

Lane U choices:
- Survey option tiles keep a transparent 1.5 px border when not picked, so a picked tile does not
  grow 3 px (the phone board grows).
- Q7 turns accent when it has text on both layouts, like Q6 (the wide board draws it static).
- The drop and paste hint hides once three images are added.
- Phone rows use the app's `ListRow`, 8 px before the chevron (boards: 12 px), like every other
  Settings row.
- The sent-state ripples use rgba(11,122,104,.38) in dark too, as the boards define.
- Loading skeleton, "Could not load your days. Try again.", the redirect when the survey is not
  open, and the redirect for non-testers on a deep link.
- All dates are shown in Philippine time.
- The Feedback pages take their Settings shell as a function (layering rule R2), so the BETA mark
  and chat glyph exist once in Settings and once in the Feedback feature.

## Deploy needs (for the lead, not done here)

- Functions `sendBetaFeedback`, `recordBetaDay`, `getBetaReward`, `submitBetaSurvey`,
  `activateBetaReward`, plus `firestore.rules` and `storage.rules` from this branch, must reach
  pantas-prod with the web build; the client asks for limited-use App Check tokens for all five.
- The pantas-prod default Storage bucket must exist (Wrapped already uses it).
- After deploy: one live send with an image from an owner test account, per the Nov 6 required step
  (live call after a deploy that touches a callable).
