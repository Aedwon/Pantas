# Web layout foundation: implementation evidence

Date: October 30, 2026.
Worktree: `/Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1`.
Branch: `web/web-layout-r1`.
Source base: `b9e29947d9451ce50b6ed92178a15460ae4af0bf`.
Policy read from `origin/main`: `245edecd31902824c8a97daaaa0458c5f4415c7b`. No fetch performed.
Changed lib/test paths and contents SHA-256 (path, NUL, bytes, NUL in sorted order): `cc99f77a85cde60a304f631366724961a5ade183bd3d6276519d329e01a0f82a`.

## Assignment

User's foundation steps 1–5 are implemented: the single 1024px web helper,
light/dark web tokens, shared components, route shell, and widget tests.
The controlling spec and board map were read using `git show origin/main`.
HANDOFF.md, shared pantas.css, X_Side and dark-reference CSS supplied styling.
No screen content, schema, seeds, generated code, dependencies, or old tests changed.

Wide presentation is gated by the helper. The app starts with its existing
native theme. A root theme scope applies web tokens only at wide web widths.
This preserves narrow web colors as well as its layout. Native themes stay intact.
Existing buttons, answer options, segments and floating bars use the new wide
presentation through that same helper.

Sidebar data comes from the existing name, active-exam and exam-specific Pro
providers. The sidebar has no collapse control, as X_Side has none. Focus routes
have no sidebar. Wrapped rows and shared links are suppressed on wide web, and
wide direct Wrapped URLs return to the record. Update-required routing keeps
priority.

## Preserved behavior and remaining area work

- The exam badge uses the actual exam and entitlement, not the board's UPCAT sample.
- Search lessons and Ctrl K open and focus the existing Study search. The search
  overlay boards belong to the later Study area; no search screen content was built.
- The hard rule's 44/50px button heights supersede the stylesheet's 42px secondary
  and tertiary heights. Buttons remain natural width.
- KaTeX stays in use. No math font or content changes were made.
- Top-bar and bottom-bar primitives are ready for the later screen assignments.
  Existing screen contents have not been converted to the other area boards.
- Visual acceptance and independent review remain with Aedwon and the lead.
  No browser, screenshot, device, or visual review was performed.

## Automated evidence

Initial broad verification encountered two temporary native SQLite load failures
in `lesson_page_progress_test.dart`: the local native library was absent at load
time. Both tests passed on rerun. The subsequent broad run passed all 1,691 tests.
The initial environment failure was not treated as a pass or hidden.


### `flutter analyze`

```text
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 6.6s)
```


### `dart format --output=none --set-exit-if-changed lib test`

```text
Formatted 1586 files (0 changed) in 1.64 seconds.
```


### `dart run tool/check_layering.dart`

```text
Running build hooks...Running build hooks...check_layering: OK
```


### `dart run tool/check_no_ai_attribution.dart`

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```


### `flutter test --no-pub test/core/ui/web test/core/ui/theme test/core/ui/components test/features/shell test/features/lesson test/features/settings test/features/home test/app`

```text
02:31 +1690: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/app/router_redirect_test.dart: age gate passed, invalid persisted exam id → onboarding picker
02:31 +1691: All tests passed!
```


### `flutter test --no-pub test/core/ui/web test/features/shell/web_shell_test.dart test/app`

```text
00:07 +152: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/app/router_redirect_test.dart: age gate passed, invalid persisted exam id → onboarding picker
00:07 +153: All tests passed!
```


### `flutter build web --release`

```text
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 9264 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             29.0s
✓ Built build/web
```


The release build succeeds with a warning about the absent CupertinoIcons font.
No dependency or font asset was added for that warning.
The final build log also reports a successful Wasm dry run. Wasm execution was
not tested.

## Files touched

The user's assignment did not provide a file table. Search focus wiring crosses
into the existing Study route, Study widget, search bar and search-field component.
Record and About changes only suppress deferred Wrapped entry points. App/theme
composition changes preserve the narrow layout while installing the wide palette.


- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/app/routes/study_routes.dart`
- `lib/app/theme.dart`
- `lib/app/web_route_shell.dart`
- `lib/core/ui/components/choice_row.dart`
- `lib/core/ui/components/floating_bar.dart`
- `lib/core/ui/components/pantas_button.dart`
- `lib/core/ui/components/search_field.dart`
- `lib/core/ui/components/segmented_switch.dart`
- `lib/core/ui/theme/app_theme.dart`
- `lib/core/ui/web/web_components.dart`
- `lib/core/ui/web/web_layout.dart`
- `lib/core/ui/web/web_layout_theme.dart`
- `lib/core/ui/web/web_tokens.dart`
- `lib/features/home/presentation/record_screen.dart`
- `lib/features/lesson/presentation/learn_tab_home.dart`
- `lib/features/lesson/presentation/widgets/search_field_bar.dart`
- `lib/features/settings/presentation/pages/about_page.dart`
- `lib/features/shell/presentation/app_shell.dart`
- `lib/features/shell/presentation/web_shell.dart`
- `test/core/ui/web/web_components_test.dart`
- `test/core/ui/web/web_layout_test.dart`
- `test/core/ui/web/web_layout_theme_test.dart`
- `test/core/ui/web/web_tokens_test.dart`
- `test/features/shell/web_shell_test.dart`


This evidence file is the only documentation addition. Nothing was staged,
committed, pushed, fetched, merged, or switched. The lead owns review and saving.


## Review corrections, October 30, 2026

Both assigned findings are fixed. None were rejected. This is implementation
and automated verification evidence; lead review and visual acceptance remain pending.
Policy remains origin/main `245edecd31902824c8a97daaaa0458c5f4415c7b`.
Source base and branch are unchanged. Final changed lib/test SHA-256, using the
path/NUL/bytes/NUL procedure above:
`6e7c7a69df4729ce7dfcc19935e82d4c9bc72da90fb4d0af2ed92cc4b1e14961`.

- P2: canceling a route-requested search removes only the search query parameter.
  Other query parameters remain. The next sidebar click or Ctrl K can request
  focus again. The Study widget sends cancellation through a callback to routing.
- Testing also found that first-visit entry animation excluded the search field
  from focus. Route-requested search now skips that animation. Ordinary entry
  retains its existing animation.
- P3: dark key chips and bottom-bar hints use secondary #A3A3A3. Light hints
  and enabled button hints retain their previous colors.
- New regression tests cover first entry, three open/cancel cycles, preserved
  topic query parameters, and both dark hint colors. Each regression failed
  before its corresponding fix. Existing tracked tests were not changed.

Files changed in this correction pass:
- `lib/app/routes/study_routes.dart`
- `lib/features/lesson/presentation/learn_tab_home.dart`
- `lib/core/ui/web/web_components.dart`
- `test/app/study_search_reopen_test.dart` (new)
- `test/core/ui/web/web_components_test.dart` (foundation's untracked new test file)
- This evidence file.

All previously present worktree changes were preserved. No stop conditions remain.
No browser, screenshots, device test, staging, commits, fetches, pushes, merges,
or branch switches were performed. No protected package was rebuilt.

The first analyze run found four missing trailing commas in the new assertions.
They were fixed. Final checks all exited 0:

### `flutter analyze`

```text
Analyzing Pantas-wt-web-layout-r1...                            
No issues found! (ran in 7.8s)
```

### `dart format --output=none --set-exit-if-changed lib test`

```text
Formatted 1587 files (0 changed) in 2.70 seconds.
```

### `dart run tool/check_layering.dart`

```text
Running build hooks...Running build hooks...check_layering: OK
```

### `dart run tool/check_no_ai_attribution.dart`

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

### `flutter test --no-pub test/core/ui/web test/features/shell test/features/lesson test/app`

```text
00:37 +614: /Users/aedwon/Documents/Projects/Pantas-wt-web-layout-r1/test/app/router_redirect_test.dart: age gate passed, invalid persisted exam id → onboarding picker
00:38 +615: All tests passed!
```

### `flutter build web --release`

```text
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 9264 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             29.3s
✓ Built build/web
```

The existing missing CupertinoIcons font warning remains. Wasm dry-run passed;
Wasm execution and visual appearance were not tested. Full-repository tests were
not rerun; the requested focused areas and test/app passed. No screen content
was added. The lead owns final acceptance and saving.
