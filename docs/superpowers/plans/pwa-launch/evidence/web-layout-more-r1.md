# More wide web layout, October 30, 2026

Implemented on `web/web-layout-r1`, ready for the lead's review. Nothing staged,
committed, pushed, fetched, merged, or switched. No screenshots or browser use.
Initial worktree was clean. Existing tests, seeds, generated code, dependencies,
providers, persistence, completion, and account ownership rules were preserved.

Policy read through `git show origin/main:<file>`: AGENTS.md, WORKFLOW.md,
SUBAGENTS.md. Policy revision: `245edecd31902824c8a97daaaa0458c5f4415c7b`.
Source HEAD: `9eef20300c17cb7ad1c348f1ab37ea1bcaf72ca8`.
Tracked patch SHA-256: `0cd88f3eddee2523be3c0adeca5bbd34fa93f6f53c58eb6c8cb6dc5228fa3031`.
Environment: Flutter 3.44.6, Dart 3.12.2, macOS local terminal.

Controlling scope: origin/main's `2026-10-30-web-layout-design.md` and
`pwa-launch/web-layout-board-map.md`, the handoff HANDOFF.md, AS/CM HTML boards,
and shared pantas.css. The existing layout helper gates every presentation fork.
The existing route shell supplies the custom mock sidebar. Shared web tokens,
question/answer options, cards, rows, buttons, keyboard hints, top/bottom bars,
switches, score gauge, and delayed debrief loading are reused.

## Completed boards and tasks

1. AS_Question and AS_Picked: 720px question column, focus header, runtime exam
   name, selected choices, compact floating bar, disabled Next until picked,
   A-D selection, Enter to advance, Escape to request leaving. Existing passage,
   figure, report, completion retry, and unavailable behavior remain available.
2. AS_Leave: 440px dialog, horizontal natural-width Leave and Keep Going actions,
   destructive Leave text, Escape keeps going, existing confirmation guard.
3. AS_Results: centered title, score and weakest-first subjects side by side,
   real counts, measured elapsed time when available, weakest-topic plan card,
   Go to Today with Enter, save/retry and one-time acknowledgment unchanged.
4. CM_Setup and CM_Wheel: 640px settings column in the sidebar shell, inline
   five-value steppers, arrow controls/keys, natural-width Save with Enter.
5. CM_Ceiling: retain requested value, show actual corpus ceiling and correction
   action, block Save while invalid. CM_Breakdown: actual subjects, inline item
   and minute editors, timing switch, computed totals, and unset-row Save guard.
6. L_DebriefSlow: assessment results reuse the existing delayed two-column
   debrief placeholders. No dedicated DK board belongs to AS/CM. All new screens
   and key states have 1440px light/dark tests using shared charcoal tokens.

No motion, Wrapped, SKIP, NEW-FEATURE, schema, system-screen, or extra route work.
The More screen list in section 2 is assessment and custom mock. Other areas'
loading and dark boards remain with those areas.

## Preserved behavior and board differences

- CSE/runtime exam names, actual questions, real subjects and results replace
  UPCAT and sample statistics. Missing measured elapsed time stays absent.
- The assessment Report action remains available although the board omits it.
  Its sent state still changes the icon color.
- Time remains editable in custom setup. The app already supports this even
  though the base board shows Time as a plain row.
- Section values start unset until the student supplies them. No sample section
  allocation is filled automatically. Saved sections and totals remain intact.
- Assessment retains its Go to Today acknowledgment flow, including empty
  results. No extra Done action or navigation bypass was added.
- Phone and narrow-web branches retain their original widgets and styling.

## Files touched

- `lib/features/assessment/presentation/assessment_page.dart`
- `lib/features/assessment/presentation/assessment_results_page.dart`
- `lib/features/assessment/presentation/web_assessment_layout.dart`
- `lib/features/mock_exam/presentation/pages/custom_mock_setup_page.dart`
- `lib/features/mock_exam/presentation/pages/web_custom_mock_setup.dart`
- `test/features/assessment/presentation/web_assessment_routes_test.dart`
- `test/features/assessment/presentation/web_assessment_test.dart`
- `test/features/mock_exam/presentation/web_custom_mock_setup_test.dart`

This evidence file is the only extra documentation file. It records the area handoff.

## Verification

All commands below exited 0 on the final source.

`flutter analyze`

```text
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 6.0s)
```

`dart format --output=none --set-exit-if-changed lib test`

```text
Formatted 1641 files (0 changed) in 4.10 seconds.
```

`dart run tool/check_layering.dart`

```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

`flutter test test/features/assessment test/features/mock_exam/presentation/custom_mock_setup_page_test.dart test/features/mock_exam/presentation/web_custom_mock_setup_test.dart test/app`

```text
00:09 +204: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/app/router_redirect_test.dart: age gate passed, invalid persisted exam id → onboarding picker
00:09 +205: All tests passed!
```

`flutter build web --release`

```text
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 11368 bytes (99.3% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             37.4s
✓ Built build/web
```

The build succeeds with a font-family warning about CupertinoIcons. The build
finds MaterialIcons and Phosphor. No Cupertino icon was added by this change.

Red checks were run before implementation: assessment tests failed because the
new presentation did not exist; custom setup tests failed because wide structure,
inline steppers, and switches did not exist. Those checks now pass.

No unresolved stop conditions. Visual acceptance and independent review remain
with Aedwon and the lead. No screenshots, browser check, device check, full test
suite, or deployment was performed. The required focused areas and test/app ran.

## Final source identity

SHA-256 of every changed code and test file, including untracked additions:

```text
efefd1822a939b310baccc609dcf115045f824fbb5c47b9f48870cf0b3fea521  lib/features/assessment/presentation/assessment_page.dart
b950212bdbe330a6eba5719e4ef3c5ffd528a1f7790302822a8861bea9258421  lib/features/assessment/presentation/assessment_results_page.dart
86869f7bd25055244d83e7cf3e89a3cb36dd90d31cce17b4c8a060ccc6d7b781  lib/features/assessment/presentation/web_assessment_layout.dart
7435534d2425b1d00fde622cf968cdf7fee173a6522cd40f1ad3d7cd3decfbc9  lib/features/mock_exam/presentation/pages/custom_mock_setup_page.dart
45131644984821b14ed1804b1d757992f7cebd5e3b668892440ebf36030c6b45  lib/features/mock_exam/presentation/pages/web_custom_mock_setup.dart
d48652b54bbc78f6843a692cb3ed4cdec3ef9e3da4ec8934483c845f2d29fafb  test/features/assessment/presentation/web_assessment_routes_test.dart
18930af211a1b4b2e439fa889589e1b378a0e025757567649cadecdd3759cc77  test/features/assessment/presentation/web_assessment_test.dart
064e64da7db8c251e510d2df0e5870c69ff889b88f65c03dfd9b4d5ce26dab41  test/features/mock_exam/presentation/web_custom_mock_setup_test.dart
```


## Review corrections, October 30, 2026

This section supersedes the earlier verification and source identity for the files
changed below. All three review findings were accepted and fixed. None rejected.

1. AS_Results: the shared gauge now has native 264×140 wide assessment geometry,
   a 16px stroke, and the correct label inside the arc. Removed outer scaling.
   The change applies only to web assessment mode.
2. AS_Question / AS_Picked: shared bottom bars render noninteractive counters
   as normal text. No disabled-button dimming or fake navigation callback.
3. CM_Wheel: both arrow controls have explicit 32×32 constraints and no extra
   minimum touch-target padding.

Added light/dark regression assertions for the inside label, native paint size,
arc geometry and stroke, noninteractive counter, and arrow dimensions. Regression
tests failed before the fixes. They passed after the fixes.

Files edited in this correction pass (the shared gauge and bar fix root causes
in existing components; no parallel components added):
- `lib/core/ui/components/half_ring_gauge.dart`
- `lib/core/ui/web/web_components.dart`
- `lib/features/assessment/presentation/web_assessment_layout.dart`
- `lib/features/mock_exam/presentation/pages/web_custom_mock_setup.dart`
- `test/features/assessment/presentation/web_assessment_test.dart`
- `test/features/mock_exam/presentation/web_custom_mock_setup_test.dart`

All required commands completed successfully (exit 0). The broader focused run
also includes all of test/core/ui because shared components changed.

`flutter analyze`
```text
No issues found! (ran in 9.7s)
```

`dart format --output=none --set-exit-if-changed lib test`
```text
Formatted 1641 files (0 changed) in 4.47 seconds.
```

`dart run tool/check_layering.dart`
```text
Running build hooks...Running build hooks...check_layering: OK
```

`dart run tool/check_no_ai_attribution.dart`
```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

`flutter test test/features/assessment test/features/mock_exam/presentation/custom_mock_setup_page_test.dart test/features/mock_exam/presentation/web_custom_mock_setup_test.dart test/core/ui test/app`
```text
01:00 +850: All tests passed!
```

Final assessment regression rerun, including the arc stroke assertion:
```text
00:01 +4: All tests passed!
```

`flutter build web --release`
```text
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 11368 bytes (99.3% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             52.9s
✓ Built build/web
```

The existing CupertinoIcons warning remains. No new icon family was introduced.
No stop conditions or unresolved findings. Visual acceptance remains with Aedwon.
No browser, screenshots, device checks, full repository test suite, staging,
commits, fetches, branch switches, pushes, or deployment.

Updated SHA-256:
```text
51f58b2ca99dd1f31f32482a2e66f4f7f2fd2d503f8d42726fbe682e8e8cf1e2  lib/core/ui/components/half_ring_gauge.dart
a6b4af1c425f6f443bf51f6a5ea9f658c5ba854ea573794c865acb109b199c50  lib/core/ui/web/web_components.dart
5786dfcfb75277bc7d2d994bfcbbff7bce1d0443f312b9f4ca3139e976460183  lib/features/assessment/presentation/web_assessment_layout.dart
cb0e2cba4e5233a83150fd4252790989cfabc8c2e6780e65b0ce8df2d83d76fe  lib/features/mock_exam/presentation/pages/web_custom_mock_setup.dart
cdfa2bb458c074228d3bd34c527f602695f62114cfd9438e1e543d00bc2c65d4  test/features/assessment/presentation/web_assessment_test.dart
22b1485c321f5a8ca799d1e8c7af59d9a7b719f4a23025a1f019129e1b0916a7  test/features/mock_exam/presentation/web_custom_mock_setup_test.dart

```
