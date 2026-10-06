# New design: level 3 parallel execution map

Level 3. Date: October 6, 2026. Author: lead. Strategy B5 ("a parallel execution map") and B6
(order). Sources: the "Base" and "Landing order" lines of each level 3 plan.

## Worker limit

At most three workers run at once, each in its own worktree (lead's working limit after Aedwon's
Oct 6 concern about usage cost; fewer, larger jobs). A worker keeps its worktree across the plans
in its slot, so it does not re-read context between small jobs. The lead integrates; workers never
merge (SUBAGENTS). Amended Oct 6 (strategy B7): workers are GPT-6.1 Sol High through Codex, so
the pace also follows Aedwon's Codex limits; GPT-6 Astra audits each workstream before it
integrates.

## Dependencies

| Before | After | Why |
|---|---|---|
| W0 (all) | W1, W3, W6 | base; W3 needs the exam catalog |
| W6 Task 5b (Tasks 1 to 5 integrated) | W3 Tasks 1, 2, 5, 10, 13 TS half, 14, 15; W4g Task 3b | Functions package, test runner, rules and limits |
| W6 Tasks 2 and 3 | W3 Task 2 (`firestore.rules`), W3 Task 10 (`recordSignInEvent.ts`) | rules and limit land first |
| W3 Tasks 2, 5, 10 and 14 | W4g Task 3b (`firestore.rules`) | rules order W6, W3, W4g |
| W1 (all) | W2 | tokens, icons, route files |
| W1 integrated | W3's router edits (Tasks 3 and 8) | W1 Task 7 splits `router.dart` (gate L3-1) |
| W2 Task 8 | W4h, every W4 family | components |
| W4h Task 1 | every other W4 family | state patterns |
| W3 (all) | W4b, W4d, W4e, W4f, W4g | entitlement, tiers, `proForActiveExamProvider` |
| W4f Task 1 | W4a Task 8 | `ReminderPrefs` |
| W4a Task 5 | W4f Task 3 | `ExamPickerScreen` |
| W4b Task 1 | W4f Task 4 | `retainTableOrderProvider` moved |
| W4b Task 3 | W4c Task 5 | `LessonDayContext` |
| W4d Task 1 | W4c Task 7 | `startLessonQuiz`, `startQuickQuiz` |
| W4e Task 1 | W4d Task 2 | `MockCard` |
| W4b Task 8, W4f Task 5 | W4g | Your record and About slots |
| W4b `/paywall` removals | W4f Task 7 deletions | the old Try Pro files go once no caller remains; any still left go in W4f Task 9 |
| every W4 family | W4h Task 4 (raw-error grep) | runs at W4 completion |
| every W4 family | W2 Task 9 (close-out) | adapters and redirects removed last |
| W2 Task 9, W4e Task 3 (last content change), W6 | W5 | release candidate |

## Slots

| Wave | Slot 1 | Slot 2 | Slot 3 |
|---|---|---|---|
| 1 | W0 (on the integration branch) | | |
| 2 | W1 | W3 (order 4, 13 Dart half, 3, 6 to 9, 11, 12; the rest after W6 Task 5b) | W6 (Task 5b integrates Tasks 1 to 5 early) |
| 3 | W2 | W3 continues | W6 continues |
| 4 | W4h, then W4b (track A, then track B) | W4e, then W4d | W4f Task 1, then W4a |
| 5 | W4g | W4c | W4f Tasks 2 to 9 (tracks A then B) |
| 6 | W4h Task 4, then W2 Task 9 close-out | | |
| 7 | W5 (lead) | | |

Waits inside a wave: a task whose "Before" row has not landed waits; the worker moves to the next
task of its own plan that has no open dependency, or stops and reports. W4c starts Task 5 only
after W4b Task 3 lands; W4g starts only after W4b Task 8 and W4f Task 5 land.
W2 starts after W1 without waiting for W3 (L2 W2 needs only W1). This differs from strategy B6
("W1 and W3 in parallel; then W2"); it is harmless and recorded in the decision record.
The L3 plans that offer two tracks (W4b, W4f) run them one after the other in a single slot
under this limit.

## Shared files and their order

| File or folder | Order |
|---|---|
| `lib/app/router.dart` | W1 Task 7, then W3 Tasks 3 and 8 (after W1 integrates), then W4a Task 11, then W2 Task 9 |
| `test/app/router_redirect_test.dart`, `router_settings_test.dart`, `mock_entitlement_override_test.dart` | W1 Task 7, then W3, then W4a Task 11, then W4f, then W2 Task 9 |
| `lib/app/routes/home_routes.dart` | W4b track A, then W4b track B |
| `lib/app/routes/settings_routes.dart` | W3 Task 3 (Settings Pro switch, after W1), then W4f in task order (W4g's shared-links route is in `wrapped_routes.dart`) |
| `lib/features/settings/data/settings_repository.dart` | W4f Task 1, then W4a Task 4 (earliest exam date), then W4f Task 8 |
| `pubspec.yaml` | W1 Task 1, then W2 Task 9 (`SourceSans3` removal) |
| `lib/features/settings/presentation/pages/pro_page.dart`, `paywall/presentation/subscription_panel.dart` | W3 Task 3 (switch cases only), then W4f Tasks 6 and 7 |
| `lib/core/storage/data/repos/attempts_repository.dart` | W4d Task 6 only |
| `tools/content/`, `tools/build_content_export/` | W0 Tasks 3, 4 and 4b only |
| `lib/app/routes/quiz_routes.dart` | W3 Task 8 (gate reads, after W1), then W4d in task order |
| `lib/app/routes/mock_routes.dart` | W3 Task 8 (gate reads, after W1), then W4e in task order |
| `lib/features/paywall/` | W3, then W4f Tasks 6 and 7 |
| `lib/features/progress/` | W4b Task 1 moves the shared providers to `lib/features/home/application/`; W4f Task 4 reads them there, so W4b Task 10's deletion of the rest does not affect it |
| `lib/features/notifications/` | W4f Task 1, then W4a Task 8 (reads), then W4f Task 1's delayed deletion |
| `lib/features/review_prompt/` | W4d Task 5, then W4f Task 6 calls `recordPaywallSeen` |
| `lib/core/ui/theme/` and `lib/core/ui/components/` | W1, then W2; W2 Task 9 deletes the adapters last |
| `lib/app/bootstrap.dart` | W3 Task 8 (mock entitlement override), then W4h Task 2 (start-up failure screen) |
| `lib/app/firebase_bootstrap.dart` | W5 Task 6 only (iOS options) |
| `functions/src/deleteAccount.ts` | W3 Task 10 only; W4g keeps it unchanged |
| `functions/package.json`, `firebase.json`, `.gitignore` (functions entries) | W6 Task 1 only |
| `content/mock/` | W4e Task 3 only; then the signed package rebuild in W5 Task 1 |
| `lib/core/content/` | W0 Tasks 3 and 4 only |
| W4e submit path and the streak update | W4e and W4d land, then W4g Task 1 adds its trigger calls |
| `firestore.rules` | W6 Tasks 2 and 3, then W3 Tasks 2, 5, 10 and 14, then W4g Task 3b |
| `storage.rules` | W4g Task 3b only |
| `functions/src/index.ts` | W6 Tasks 1, 4, 5 (integrated in Task 5b), then W3 (new exports), then W4g Task 3b |
| `functions/src/recordSignInEvent.ts` | W6 Task 3, then W3 Task 10 |
| `functions/src/renderWrappedPage.ts` | W4g Task 3b, then W4g Task 6 |
| `tools/release/android/release.sh` | W5 Task 1b only |
| `functions/src/syncGenerationPolicy.ts`, `activateSyncGeneration.ts` | W6 Task 3, then W3 Task 2 |
| `android/app/src/main/kotlin/com/aedwon/pantas/MainActivity.kt` | W3 Task 11 only |
