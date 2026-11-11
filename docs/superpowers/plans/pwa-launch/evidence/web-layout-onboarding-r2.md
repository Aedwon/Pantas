# Onboarding wide web, second pass

Candidate: `web/web-layout-r1`, base `b6e8931532d73702f35a11d65c4f086048deb6bb`, plus the unstaged patch listed below.
Policy: `origin/main` at `245edecd31902824c8a97daaaa0458c5f4415c7b` was read with `git show`. No fetch, stage, commit, branch switch, push, browser operation, or screenshot.

Sources: `docs/superpowers/specs/2026-10-30-web-layout-design.md` and `docs/superpowers/plans/pwa-launch/web-layout-board-map.md` from origin/main; local handoff and board HTML under `/Users/aedwon/Documents/Projects/Pantas/web-design/pantas-handoff/`.

## Initial inventory and work

Every onboarding BUILD board had a wide presentation in the first pass. “Present” below identifies implemented presentation, not visual acceptance.

| Board | Initial state | Second pass |
| --- | --- | --- |
| OB_Welcome | Present | Existing light/dark structure and Enter tests retained |
| OB_Age | Partial | Field constrained to board's 240 × 64 size |
| OB_AgeBlocked | Present | Existing blocked/retry tests retained |
| OB_Terms | Partial | Usage label now toggles whole row; card radius 16 |
| OB_PickerLoading | Present | Existing light/dark state tests retained |
| OB_PickerError | Present | Existing light/dark state tests retained |
| OB_Picker | Present | Existing selection and Enter tests retained |
| OB_PickerEmpty | Present | Existing light/dark state tests retained |
| OB_CustomName | Present | Existing empty/entered name tests retained |
| OB_CustomCover | Partial | Subject cards radius 14, text 16, padding 16, rounded checks |
| OB_DateKnown | Present | Existing confirm/change tests retained |
| OB_DatePick | Present | Existing empty calendar tests retained |
| OB_DateMonth | Partial | Month cells 42 high; day cells 46 high; board text size/weight/radii |
| OB_DateDay | Partial | Same calendar correction |
| OB_DateYear | Partial | Same calendar correction |
| OB_DateThisMonth | Partial | Same calendar correction |
| OB_DateToday | Partial | Same calendar correction |
| OB_Days | Present | Existing selection tests retained |
| OB_DaysNone | Present | Existing disabled Continue tests retained |
| OB_DaysTooLate | Present | Existing warning/disabled Continue tests retained |
| OB_DaysSoon | Present | Existing measured countdown tests retained |
| OB_Name | Present | Existing name/Done tests retained |
| OB_SignIn | Present in Account | Added light/dark busy/cancel state tests at 1440 |
| OB_Restoring | Present as shared StepsScreen | Existing completed/Enter test retained; no live restore route exists |
| L_SignIn | Present in Account | Added busy state tests |
| L_Restore | Partial shared StepsScreen | Added 520-wide loading layout, heading outside progress card, shared WebRow components |

There is no onboarding DK board. Existing wide tests and new tests exercise light and charcoal dark themes at 1440. No motion work was added.

## Files changed

- `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`
- `lib/features/onboarding/presentation/onboarding_consent_step.dart`
- `lib/features/onboarding/presentation/onboarding_web_calendar.dart`
- `lib/features/onboarding/presentation/steps/custom_track_subjects_step.dart`
- `lib/core/ui/components/steps_screen.dart`: required by L_Restore; other titles and phone presentation retain their paths.
- `test/features/onboarding/presentation/web_onboarding_second_pass_test.dart`: new tests only; existing tests unchanged.
- This evidence and `docs/ui-audit.md` for handoff/status.

## Preserved behavior and limits

- CSE-only selection on web remains. Other exams in the board are not enabled.
- Subjects come from the existing corpus provider. No board example subjects are fabricated.
- Sign-in retains the approved browser-only progress copy and Delete My Data action from the app. L_SignIn uses the browser-only copy too. No cross-device restore promise was added.
- OB_Restoring and L_Restore are reusable presentations only. Source search found no actual restore-progress route/caller. Connecting account restoration requires a lead decision and existing operation progress data. No progress stages or answer count were invented.
- Reminders, browser permission, install, Wrapped, and motion boards remain excluded.
- An apparent title-placement conflict was resolved by reading the distinct boards: OB_Restoring contains its heading in the card; L_Restore has a heading above the card. Existing tests need no changes.
- Automated checks do not establish 1:1 visual acceptance. Aedwon retains that check. No screenshots or browser use.

## Verification

New tests were run red first for birth-year sizing, consent row clicks, subject styling, loading restore structure, and calendar cell heights. Both themes failed for the expected assertions, then passed after changes. Busy sign-in tests cover existing behavior.

Commands and final output follow. Initial verification caught a missing token getter and trailing comma in new code. Both were corrected. One initial test command named a nonexistent steps test file; the final command uses actual affected test paths.

### flutter analyze

```text
Try `flutter pub outdated` for more information.
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 16.5s)
```

### dart format --output=none --set-exit-if-changed lib test

```text
Formatted 1633 files (0 changed) in 2.93 seconds.
```

### dart run tool/check_layering.dart

```text
Running build hooks...Running build hooks...check_layering: OK
```

### dart run tool/check_no_ai_attribution.dart

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

### flutter test test/features/onboarding test/app test/core/ui/components/onboarding_date_extensions_test.dart test/core/ui/components/onboarding_extensions_test.dart test/features/settings/presentation/web_account_states_test.dart test/features/settings/presentation/web_settings_second_pass_test.dart

```text
00:46 +306: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/features/settings/presentation/web_settings_second_pass_test.dart: delete shows real pending operation then Close dark=true
00:46 +307: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/features/settings/presentation/web_settings_second_pass_test.dart: wide setting values use board typography dark=true
00:46 +308: All tests passed!
```

### flutter build web --release

```text
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 10932 bytes (99.3% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             65.7s
✓ Built build/web
```

Exit 0. The build reports a missing CupertinoIcons font-family warning. Wasm dry run succeeded. No content assets or generated code were rebuilt.

All final required commands exited 0. Tests: 308 passed, including 12 new light/dark cases. Existing tests were not edited. Final formatting adjustment after the test/build launch added only a trailing comma. Analysis and format checks ran after that adjustment.

## Source hashes (SHA-256)

```text
38de247989af06e81ffaad6d07213fe3e81d9181c29aaae8a0c243facb6854e0  lib/core/ui/components/steps_screen.dart
c3ad72571d63f60772b481119350f4d7492873c6cbeef1b70489fd4875c08f15  lib/features/onboarding/presentation/onboarding_age_gate_step.dart
3c5d081fd7aca1d617a4776750db5dfabd10052d1017e5fb6c5e05e53acbd5cc  lib/features/onboarding/presentation/onboarding_consent_step.dart
e3757416d0f45eb359043e527928ae5ecf0cc68d04979464e5e76291ee23f1e2  lib/features/onboarding/presentation/onboarding_web_calendar.dart
5f7f09b9aef08977f993db55f70122f99f8cdbce293e45f64de5176b8f16ad75  lib/features/onboarding/presentation/steps/custom_track_subjects_step.dart
73517d8105909806088d828f81ba74b399627e297cac2994a9cfc4af880b9916  test/features/onboarding/presentation/web_onboarding_second_pass_test.dart
```

Lead review, integration, and visual acceptance remain pending. Work is unstaged.


## Review fixes, October 30

This section supersedes the earlier verification and hashes for the amended files.
Accepted all three findings. No findings rejected.

- OB_CustomCover: the checkbox now paints at 24px with a 14px label gap and a 16px visible left inset. Kept CheckboxListTile for existing behavior and tests. Its supported scale factor enlarges the 18px painted box; radius and stroke are compensated for the scale.
- OB_DateMonth/Day/Year/ThisMonth/Today: selected months, selected days, today's day number, and the Today label use weight 700.
- L_Restore: actual completion dots are 26px and the active spinner is 16px. These sizes apply only to the wide loading restore presentation.
- Extended the second-pass tests in both themes at 1440. All six affected cases failed before the implementation fixes. All twelve cases passed afterward. Existing committed tests were unchanged.

Only these source/test files were amended in this fix run:
`lib/core/ui/components/steps_screen.dart`,
`lib/features/onboarding/presentation/onboarding_web_calendar.dart`,
`lib/features/onboarding/presentation/steps/custom_track_subjects_step.dart`,
`test/features/onboarding/presentation/web_onboarding_second_pass_test.dart`.
This evidence file was also updated. Preserved all other pre-existing changes.

Final required check outputs (all exit 0):

`flutter analyze`

```text
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 9.9s)
```

`dart format --output=none --set-exit-if-changed lib test`

```text
Formatted 1633 files (0 changed) in 3.08 seconds.
```

`dart run tool/check_layering.dart`

```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

`flutter test test/features/onboarding test/app test/core/ui/components/onboarding_date_extensions_test.dart test/core/ui/components/onboarding_extensions_test.dart test/features/settings/presentation/web_account_states_test.dart test/features/settings/presentation/web_settings_second_pass_test.dart`

```text
00:24 +308: All tests passed!
```

`flutter build web --release`

```text
Compiling lib/main.dart for the Web...                             34.1s
✓ Built build/web
```

The first analyzer run found nine missing trailing commas in the fix. Those were corrected. Final analysis and format checks passed. Test and build inputs differ from the final files only by these trailing commas. The build retains the CupertinoIcons font-family warning recorded above. Wasm dry run succeeded.

No browser, screenshots, stage, fetch, commit, push, or branch switch. No additional behavior conflict or stop condition. The earlier preserved-behavior limits still apply, including restore presentation without a live restore caller. Lead review and Aedwon's visual acceptance remain pending.

Amended source hashes (SHA-256):

```text
22b30790f464a1b46d09943a22bae8464f041855299b3c1f9c46796ad1b61b58  lib/core/ui/components/steps_screen.dart
2bbe01e378b82306b0abd79162ca4789ae8dddd1a1a17916a94bf37be150e995  lib/features/onboarding/presentation/onboarding_web_calendar.dart
d608ea9200dd119adbab4920a8f9566f84225ea65a2acb5fd13c9329e8eded9e  lib/features/onboarding/presentation/steps/custom_track_subjects_step.dart
e6af1ef91ad40ad8efb54802c505d1aa9ca36094d297e38cee89151680e67799  test/features/onboarding/presentation/web_onboarding_second_pass_test.dart
```
