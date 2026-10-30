# Settings second pass

Policy: origin/main 245edecd31902824c8a97daaaa0458c5f4415c7b.
Starting source: 0dcb6778c9faab429cd015314a3de44bf2e8e0b2. Working tree clean at startup.
No fetch, staging, commit, push, branch switch, screenshots, or browser use.

## Inventory before implementation

Every BUILD board in the Settings table follows. “Built” means a presentation
branch exists, not visual acceptance. The lead and Aedwon retain review.

| Board | Initial state |
|---|---|
| ST_Account | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_AccountPro | Existing approved behavior retained: web account saving replaces the backup UI; native backup presentation exists. |
| ST_AccountIDCopied | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_AccountIDWait | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_AccountOut | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_AccountOffline | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_Name | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_RootNoName | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_SignOut | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_DeleteAccount | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_BackupDetails | Existing approved behavior retained: web account saving replaces the backup UI; native backup presentation exists. |
| ST_BackupNow | Existing approved behavior retained: web account saving replaces the backup UI; native backup presentation exists. |
| ST_BackupNowOffline | Existing approved behavior retained: web account saving replaces the backup UI; native backup presentation exists. |
| ST_BackupStates | Existing approved behavior retained: web account saving replaces the backup UI; native backup presentation exists. |
| ST_Avatars | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_Paywall | Deferred by lead ruling: CSE-only web catalog. Shared Pro presentation exists. |
| ST_ProCSE | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ProCSEPass | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ProLET | Deferred by lead ruling: CSE-only web catalog. Shared Pro presentation exists. |
| ST_ProNCE | Deferred by lead ruling: CSE-only web catalog. Shared Pro presentation exists. |
| ST_ProNCENoDate | Deferred by lead ruling: CSE-only web catalog. Shared Pro presentation exists. |
| ST_ProPMA | Deferred by lead ruling: CSE-only web catalog. Shared Pro presentation exists. |
| ST_ProPMAPass | Deferred by lead ruling: CSE-only web catalog. Shared Pro presentation exists. |
| ST_Pro | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_RootTrial | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ProPassHave | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ProLapsed | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_PassEnded | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_PassNoDate | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_PassSoon | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_RestoreDone | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ProRestoreNone | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ProOffline | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_Exam | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ExamDate | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ExamMonth | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ExamUnknown | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ExamPassed | Partial: state and warning exist; wide row drops its warning value style. |
| ST_ExamCustom | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_DaysLast | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ExamPick | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_SwitchPassWarn | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_ExamSwitch | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_SwitchUpgrade | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_Included | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_IncludedOpen | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_IncludedLast | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| ST_Appearance | Built: color-only theme previews, slider, large rows and preference switch match the board structure. |
| ST_LargeText | Built: color-only theme previews, slider, large rows and preference switch match the board structure. |
| ST_About | Partial: version identity is centered text; board requires a card with badge and an external feedback indicator. |
| ST_Privacy | Built: existing wide presentation/state. Preserve approved behavior differences listed below. |
| SD_Error | Outside settings: Study owns this state. |
| SD_NoExam | Outside settings: Study owns this state. |
| W_Settings | Built: split view and Practice. |
| DK_Settings | Built: shared charcoal tokens and Practice. |
| L_Restore | Missing: StepsScreen supports wide mode, but no restore flow renders it. The sign-in/sync API exposes no per-stage restore progress. Blocked pending lead direction. |
| L_Delete | Built: deleting and deleted states use StepsScreen; the deletion API exposes one operation, not separate local/cloud progress. |
| L_ChangeExam | Built: existing switch confirmation busy state. |
| L_SignIn | Built: signing-in button state. |
| L_Purchase | Built: confirming-payment button state. |
| L_RestorePurchase | Built: restoring-purchases button state. |

## Approved behavior retained

- Web backup controls remain hidden. The web account saves progress to the
  account. Do not expose the native Pro-only sync control on web.
- CSE-only products and exam picker remain. Other exam tiers are deferred by
  the spec. Weekly and yearly offers remain when the real catalog supplies them.
- The web trial is prepaid. Existing no-payment wording remains.
- Names save on leaving the page. Existing sign-out confirmation copy remains.
- Legal pages use the actual legal documents and dates, not board sample copy.
- Version, dates, identities, prices and totals come from actual app data.
- No subscription-management destination is shown on web.
- No Reminders, pending GCash, Wrapped, new schema content, or motion work.
- SD_Error and SD_NoExam belong to Study, per lead ruling 21.
- L_Delete keeps truthful single-operation progress because the deletion callback
  does not expose local/cloud stages. Do not invent completed work stages.

## Work and verification

Baseline: `flutter test test/features/settings test/app` exited 0:
`00:27 +479: All tests passed!`

Implemented:
1. ST_ExamPassed now retains the warning value color, including the handoff dark
   red text. ST_ExamDate uses teal while its editor is open.
2. Settings row values use 16px web type. The existing WebRow accepts the value
   style. Large stacked values use the same style.
3. ST_About now has its 16px-radius identity card, 18px insets, 52px badge, 14px
   gap, 18px name and actual version/build. Feedback has the external indicator.
4. W_Settings/DK_Settings use the newest strict-mode copy, “Leaving the mock”.
   Phones and narrow web keep the existing copy and presentation.
5. Added 20 widget tests at 1440px in light/dark. They cover signed-out and
   ID-not-ready account states, ID copy timing, exact/month/unknown date editor,
   passed-date color at 1x/2x, About structure/copy, Practice options/copy, actual
   deletion pending/completed states, and row value type. Existing tests unchanged.

Tests first: the regression run produced 2 passes and 10 expected failures for
missing card layout, date colors, value type and Practice copy. After fixes the
original 12-test run passed. Expanded state coverage passes in the final suite.

Files changed:
- lib/core/ui/web/web_components.dart: extend the existing row, no parallel base.
- lib/features/settings/presentation/widgets/settings_row.dart
- lib/features/settings/presentation/pages/exam_page.dart
- lib/features/settings/presentation/pages/about_page.dart
- lib/features/settings/presentation/pages/session_building_page.dart
- test/features/settings/presentation/web_settings_second_pass_test.dart (new)
- This evidence record (new).

The assignment names an area, not a fixed file table. The shared row file is
necessary because it is the point at which all wide setting value styles were
lost. Its default presentation stays the same for callers outside Settings.

Final code/test patch identity (sorted relative names, NUL, bytes, NUL; SHA-256):
`d47ac6244520b9bf1c84b39646b6b41b11ac482a18d7552c98760c21e8222061`.

Final required checks, all exit 0:

```text
flutter analyze
No issues found! (ran in 16.7s)

dart format --output=none --set-exit-if-changed lib test
Formatted 1628 files (0 changed) in 1.92 seconds.

dart run tool/check_layering.dart
check_layering: OK

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
```

Focused test command:

```sh
flutter test test/features/settings test/app test/core/ui/web test/features/shell test/features/legal test/core/ui/components/segmented_switch_test.dart test/core/ui/components/audit_avatar_fallback_test.dart
```

```text
00:47 +603: All tests passed!
```

Full logs: /tmp/settings-r2-analyze-clean.log, /tmp/settings-r2-format.log,
/tmp/settings-r2-layering.log, /tmp/settings-r2-attribution.log,
/tmp/settings-r2-tests.log. Final build log: /tmp/settings-r2-build-final.log. Exit 0:

```text
flutter build web --release
Wasm dry run succeeded.
Compiling lib/main.dart for the Web...                             48.5s
✓ Built build/web
```

The earlier uncached build warned about missing CupertinoIcons. The final cached
build completed without that warning. No dependencies or font assets were changed.
`git diff --check` also exited 0. Nothing staged or committed.

## Remaining gap and acceptance

L_Restore is not complete. Only StepsScreen and gallery examples exist. The
account sign-in/sync contracts expose no answer/lesson/plan restore stages. The
board requires real stages to tick off. Implementing that needs a lead decision
about the restore flow and its progress contract. No fictional counts or stages
were added. L_Delete likewise keeps one honest in-flight operation, not invented
separate browser and cloud completions.

Existing wide page tests cover the remaining page structures at 1440px in light
and dark, at 1x and 2x. This is automated structure/state evidence, not proof of
pixel matching. No visual check, browser, screenshot, emulator, production payment,
or live account deletion was performed. Full repository tests were not run;
the assigned focused suite plus app and affected shared UI suites were run.
Independent review, visual acceptance, and integration stay with the lead.


Pre-flight: SettingsRow consumes WebRow; WebRow drops valueStyle. Forward it
through the existing shared component. No new parallel component.

The appearance preview initially looked incomplete against the native preview.
Reading the actual ST_Appearance markup confirmed its previews are deliberately
blank. No appearance code change is needed.
