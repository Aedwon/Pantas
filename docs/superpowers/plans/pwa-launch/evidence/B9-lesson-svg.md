# B9 lesson SVG evidence

Status: review fixes round 1 implemented, committed locally, not pushed. The
oversized-image decision is resolved by the lead ruling below. Full APP suite,
static gates, render check fixtures, Android debug build and the STAGING uploader
tests and web build passed on the SHAs below. iOS is unverified: the dev iOS build
was blocked by the existing scheme setup and was not rerun. No visual acceptance,
device run, screenshot capture, deployment or push.

Source SHAs after the review fixes, before this evidence commit:

| Tree | Branch | Base | Head |
|---|---|---|---|
| APP | web/lesson-svg-r1 | cff80d81cfb0a67a0b3b0df83303551d47b81891 | b77ad101 |
| STAGING | web/pwa-staging-r1 | bf6f58e665ff50678cbcbb0b5caa1fbe3436837a | 24baa017 |

| Review item | APP | STAGING |
|---|---|---|
| 1 Reuse decoded data-URL bytes | a91dbcab | 7ecc59f5 |
| 2 Malformed data URLs show the failure state | f509f32e | c418a6db |
| 3 Misnamed and unused figure files fail | f7cb304c | 932005a0 |
| 4 Same credit and size rules on seed and upload | 7c6421a0 | 9d8fe850 |
| 5 SVG frame, loading and failure like PNG | 31245d19 | 24baa017 |
| 6 Render check names and use cycles | b77ad101 | none (the checker is APP only) |

## Scope and source

Policy read with git show origin/main, without fetch or pull:
73572280cf4d9478d56e42247be04dad8ad1acd9.
APP: web/lesson-svg-r1, 0a21e5b9ed2fc4bc75abd2fc6d7b6b2e2528afc7.
STAGING: web/pwa-staging-r1, 80ddb7c52f1b9728d7c07945f480d2ed0c3d5950.
(The first hand-in. The review fixes below start from the commits cff80d81 and bf6f58e6.)
Live remote inspection found STAGING at that SHA. APP remote branch does not yet
exist. APP's pre-existing pubspec.yaml and pubspec.lock changes were preserved.
No other worktrees were touched.

The current stable flutter_svg version from https://pub.dev/api/packages/flutter_svg
was 2.3.0, requiring Dart ^3.9.0 and Flutter >=3.35.0. Installed SDK:
Flutter 3.44.6, Dart 3.12.2. No other package added. Both worktrees directly
reference flutter_svg ^2.3.0.

## Changes by brief item

1. Both the legacy portable renderer and the current lesson ContentRenderer
   dispatch SVG through flutter_svg. PNG network paths remain. Data URLs carry
   native-seeded and server-delivered figure bytes; bundled SVG asset paths and
   remote SVG URLs are supported. Remote native SVG uses the PNG path's existing
   disk cache. Loading heights, failure messages, retry, clipping, alt text,
   expansion, and credits retain the existing paths. Both expanded viewers have
   explicit labeled image semantics.
2. Authoring note documents currentColor and seven reserved literal palette
   tokens mapped to PantasColors. SVG frames inherit the active theme, including
   expanded figures. Existing PNG/code figure backgrounds stay unchanged.
3. Seed asset resolution discovers the approved illustration path and joins in
   numeric marker order, with SVG replacing the corresponding PNG. Existing
   remote URLs, alt text, and credits are preserved. STAGING uploader resolves
   illustration markers into IMAGE markers carrying bytes or existing remote
   URLs; its remote Markdown parser reads these markers. Local files remain in
   lesson content and its existing cache. Symlink escapes and duplicate sequence
   files fail. This path has an unresolved corpus-size limit below.
4. Strict XML preflight rejects unsupported elements, ignored styling/attributes,
   filters/shadows, masks, animation/SMIL, external references, raster images,
   scripts, and handlers. The render harness uses the app's loader and flutter_svg
   parser to draw accepted figures in memory in both themes. It saves no images.
5. Final gates and builds are recorded below. Aedwon owns visual
   acceptance. No devices or emulators ran.

## Test-first evidence

Tests failed before the corresponding implementations or corrections. Initial
checker import failure was scaffolding only, not counted as a behavioral RED.
The checker was then run with a no-op validator and all rejected fixtures failed.
Palette implementation was removed before its RED check and restored afterward.

### Initial renderer dispatch RED

```text
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart line 61
The test description was:
  invalid SVG uses existing failure state reader=false
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +1 -6: invalid SVG uses existing failure state reader=false [E]
  Test failed. See exception logs above.
  The test description was: invalid SVG uses existing failure state reader=false
  
00:00 +1 -6: invalid SVG uses existing failure state reader=true
00:00 +2 -6: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG renders with alt text reader=false dark=false
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG renders with alt text reader=false dark=true
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG renders with alt text reader=true dark=false
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG renders with alt text reader=true dark=true
  ... and 2 more
```

### Seed discovery RED

```text
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tools/lesson_svg_assets_test.dart 20:5         main.<fn>
  
00:00 +0 -1: duplicate SVG sequence fails instead of selecting an arbitrary file
00:00 +0 -2: duplicate SVG sequence fails instead of selecting an arbitrary file [E]
  Expected: throws <Instance of 'FormatException'>
    Actual: <Closure: () => LessonAssetMap>
     Which: returned <Instance of 'LessonAssetMap'>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tools/lesson_svg_assets_test.dart 33:5         main.<fn>
  
00:00 +0 -2: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tools/lesson_svg_assets_test.dart: duplicate SVG sequence fails instead of selecting an arbitrary file
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tools/lesson_svg_assets_test.dart: seed joins local SVG and PNG to markers in numeric order
```

### Palette RED

```text
  test/core/ui/components/lesson_svg_test.dart 27:9   main.<fn>
  
00:00 +0 -1: SVG palette follows active theme dark
00:00 +0 -2: SVG palette follows active theme dark [E]
  Expected: Color:<Color(alpha: 1.0000, red: 0.9608, green: 0.9608, blue: 0.9686, colorSpace: ColorSpace.sRGB)>
    Actual: Color:<Color(alpha: 1.0000, red: 0.0039, green: 0.0039, blue: 0.0039, colorSpace: ColorSpace.sRGB)>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/core/ui/components/lesson_svg_test.dart 27:9   main.<fn>
  
00:00 +0 -2: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG palette follows active theme dark
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG palette follows active theme light
```

### Unsupported SVG feature RED

```text
  File "/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/check_lesson_svgs_test.py", line 19, in test_rejected_fixtures
    check.validate(file)
AssertionError: ValueError not raised

----------------------------------------------------------------------
Ran 2 tests in 0.001s

FAILED (failures=17)
```

### Upload marker resolution RED

```text
test at tools/upload_content/lesson_illustrations.test.mjs:25:1
✖ rejects unsafe lesson paths (0.393541ms)
  AssertionError [ERR_ASSERTION]: Missing expected exception.
      at TestContext.<anonymous> (file:///Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/tools/upload_content/lesson_illustrations.test.mjs:26:10)
      at Test.runInAsyncScope (node:async_hooks:226:14)
      at Test.run (node:internal/test_runner/test:1402:25)
      at Test.processPendingSubtests (node:internal/test_runner/test:974:18)
      at Test.postRun (node:internal/test_runner/test:1542:19)
      at Test.run (node:internal/test_runner/test:1467:12)
      at async startSubtestAfterBootstrap (node:internal/test_runner/harness:387:3) {
    generatedMessage: false,
    code: 'ERR_ASSERTION',
    actual: undefined,
    expected: /path/i,
    operator: 'throws',
    diff: 'simple'
  }
```

### Remote Markdown RED

```text
    Actual: <Closure: () => List<Map<String, Object?>>>
     Which: returned []
  
  package:matcher                                          expect
  package:flutter_test/src/widget_tester.dart 473:18       expect
  test/core/content/remote/lesson_markdown_test.dart 20:5  main.<fn>
  
00:00 +0 -2: every lesson converts exactly as the bundled content build does
00:00 +1 -2: drops illustration markers and keeps figures, tables and math
00:00 +2 -2: a malformed table is refused with its line number
00:00 +3 -2: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/core/content/remote/lesson_markdown_test.dart: malformed resolved image marker fails explicitly
  /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/core/content/remote/lesson_markdown_test.dart: server resolved SVG marker becomes an accessible image block
```

### Review: ignored features RED

```text
  File "/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/check_lesson_svgs_test.py", line 19, in test_rejected_fixtures
    check.validate(file)
AssertionError: ValueError not raised

----------------------------------------------------------------------
Ran 2 tests in 0.003s

FAILED (failures=5)
```

### Review: credit and duplicate sequence RED

```text
00:00 +1 -2: duplicate PNGs fail even when an SVG sorts between them [E]
  Expected: throws <Instance of 'FormatException'>
    Actual: <Closure: () => LessonAssetMap>
     Which: returned <Instance of 'LessonAssetMap'>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/tools/lesson_svg_assets_test.dart 58:5         main.<fn>
  
00:00 +1 -2: duplicate SVG sequence fails instead of selecting an arbitrary file
00:00 +2 -2: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tools/lesson_svg_assets_test.dart: duplicate PNGs fail even when an SVG sorts between them
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tools/lesson_svg_assets_test.dart: replacement retains an existing separate credit key
```

### Review: upload preservation/path RED

```text
      at Test.run (node:internal/test_runner/test:1467:12)
      at async Test.processPendingSubtests (node:internal/test_runner/test:974:7)

test at tools/upload_content/lesson_illustrations.test.mjs:46:1
✖ rejects symlinked subject ancestors (1.20075ms)
  AssertionError [ERR_ASSERTION]: Missing expected exception.
      at TestContext.<anonymous> (file:///Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/tools/upload_content/lesson_illustrations.test.mjs:53:12)
      at async Test.run (node:internal/test_runner/test:1409:7)
      at async Test.processPendingSubtests (node:internal/test_runner/test:974:7) {
    generatedMessage: false,
    code: 'ERR_ASSERTION',
    actual: undefined,
    expected: /unsafe/i,
    operator: 'throws',
    diff: 'simple'
  }
```

### Review: replacement credit RED

```text
      at Test.run (node:internal/test_runner/test:1402:25)
      at Test.processPendingSubtests (node:internal/test_runner/test:974:18)
      at Test.postRun (node:internal/test_runner/test:1542:19)
      at Test.run (node:internal/test_runner/test:1467:12)
      at async Test.processPendingSubtests (node:internal/test_runner/test:974:7) {
    generatedMessage: true,
    code: 'ERR_ASSERTION',
    actual: 'Pantas',
    expected: 'Original artist',
    operator: 'strictEqual',
    diff: 'simple'
  }
```

### Expanded SVG accessibility RED

```text
This was caught by the test expectation on the following line:
  file:///Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart line 80
The test description was:
  SVG renders with alt text reader=true dark=true
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +2 -2: SVG renders with alt text reader=true dark=true [E]
  Test failed. See exception logs above.
  The test description was: SVG renders with alt text reader=true dark=true
  
00:00 +2 -2: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG renders with alt text reader=true dark=false
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG renders with alt text reader=true dark=true
```

### Legacy expanded accessibility RED

```text
  file:///Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart line 97
The test description was:
  legacy content expansion retains SVG alt text
════════════════════════════════════════════════════════════════════════════════════════════════════
00:00 +0 -1: legacy content expansion retains SVG alt text [E]
  Test failed. See exception logs above.
  The test description was: legacy content expansion retains SVG alt text
  
00:00 +0 -1: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: legacy content expansion retains SVG alt text
```

### Focused acceptance after fixes

```text
00:00 +13: /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: invalid SVG uses existing failure state reader=false
00:00 +14: /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: invalid SVG uses existing failure state reader=true
00:00 +15: All tests passed!
```

## Review and recovery

Independent read-only review found ignored SVG features, loss of remote map
slots, ancestor symlink escapes, replacement credit loss, duplicate PNG ambiguity,
and expanded-view alt semantics. Each fix has a regression test. The reviewer
rechecked the fixes and reported no remaining findings from that review.

APP initially lacked generated domain files. Relay #11697 generated them with
`dart run build_runner build --delete-conflicting-outputs`: exit 0, 25 seconds,
3142 outputs. No schema or pinned seed package was changed. Generator warnings:
removed --delete-conflicting-outputs option; existing root SDK language-version
warning; existing drift generate_connect_constructor option warning.

Relay #11698: focused 50 tests pass; analysis found owned style issues, corrected.
Relay #11699 was canceled after the expanded-view assertion failed. It provides
no completed full-suite evidence. Relay #11700 completed the final APP run, with one
Flutter command at a time. Earlier failed checks remain recorded, not relabeled.

## Review fixes, round 1

Policy read with git show origin/main, without fetch or pull. Each fix had its test
written first and seen failing, in one commit per item, in APP and then in STAGING.
STAGING carries identical copies of the shared renderer, loader, seed-tool and
content files (checked with cmp after the last commit).

1. Memoize decoded bytes. Tests: loaders for one URL compare equal across rebuilds
   and themes; a parent rebuild keeps the same loader. Both failed first
   (Expected and Actual both `SvgBytesLoader`, not equal). A 16-entry least recently
   used cache keyed by URL now returns the same bytes.
2. Malformed data URLs. 12 widget tests (four bad URLs through the portable, reader
   and legacy renderers) failed first with `FormatException` thrown building
   `_ContentImage` and `_ImageBlockRenderer`. One helper now returns null for a
   malformed URL and each renderer shows its existing failure state.
3. Misnamed and unused figures. Failed first: eight misnamed names (one digit, upper
   case, `.SVG`, `.jpg`, underscore, `00`, too shallow, too deep), an unused figure,
   a figure in a lesson with no markers, a figure folder with no lesson file, and a
   symbolic link in place of a figure. Seed, export and upload now stop with the file
   path and the rule. STAGING failed first on the same cases in the uploader tests.
4. Same rules on both sides (lead ruling). Failed first: a local PNG with no credit,
   an SVG replacing an entry whose credit is missing, and the size limit (four
   tests). The seed and the upload now give the credit `Pantas` only to a new
   original SVG, which the authoring note defines. Both count the 900,000-byte
   limit the same way. The seed drops the figure that would pass it, with a warning,
   as before B9. The upload rejects the lesson. One test pair uses the same body and
   the same two sizes (674,916 bytes kept, 674,917 over) on each side. No PNG hosting.
   The three founder PNGs under reading-comprehension had no credit entry and relied
   on the old default, so `content/illustrations/sources/pantas.yaml` now names them
   with the credit Pantas. That file is a content decision for the lead to confirm.
5. Layout parity. The size test compares an SVG and a PNG of the same size, with and
   without width and height, in the portable, reader and legacy renderers: all 18
   cases were already equal, so no sizing rule changed. The failure test failed
   first: a failed SVG sat outside the frame in legacy content. It now sits inside
   like a PNG. The loading space was already inside the frame. A PNG data-URL test
   covers the path the seed uses for PNGs. The authoring note has size guidance.
6. Render check. Failed first: seven misnamed names exit 0 (the `.SVG` file was not
   even listed), and two `<use>` cycle fixtures raised nothing. The check now applies
   the path rule under `content/illustrations` and reports cycles with their ids.
   Fixture folders outside that path have no name rule.

Remaining differences, for the lead:

- An existing asset-map entry with a URL and no credit: the upload stops on it; the
  seed still drops that image with a warning, as before B9, because an existing test
  fixes that behavior.
- The full uploader dry run still refuses two lessons over the size limit
  (reading-comprehension/text-types/visual-media and
  science/earth-science-astronomy/layers-of-the-earth) and the malformed ratio and
  proportion question YAML. The seed drops the over-limit figures with a warning.
  Those lessons wait for smaller SVG replacements.

### Review fixes gate output

APP, on head b77ad101, one Flutter command at a time:

```text
flutter test (full):           07:48 +4909: All tests passed!
flutter analyze lib test tool: No issues found! (ran in 3.9s)
dart format --output=none --set-exit-if-changed lib test: Formatted 1601 files (0 changed)
dart run tool/check_layering.dart:            check_layering: OK (exit 0)
dart run tool/check_no_ai_attribution.dart:   check_no_ai_attribution: OK (exit 0)
python3 tools/check_lesson_svgs_test.py:      Ran 6 tests ... OK
python3 tools/check_lesson_svgs.py tools/svg_fixtures/pass:  +5: All tests passed! (exit 0)
python3 tools/check_lesson_svgs.py tools/svg_fixtures/fail --validate-only:
  SVG preflight: 26 files, 26 failures (exit 1; names use-cycle.svg and use-self.svg)
flutter build apk --debug --flavor dev -t lib/main_dev.dart:
  Running Gradle task 'assembleDevDebug'... 24.3s
  Built build/app/outputs/flutter-apk/app-dev-debug.apk (exit 0)
```

STAGING, on head 24baa017:

```text
node --test tools/upload_content/:  tests 18, pass 18, fail 0
flutter test (lesson_markdown, test/tools, lesson_svg): +117: All tests passed!
dart format --output=none --set-exit-if-changed lib test tools/content ...: 0 changed
flutter build web --release -t lib/main_staging.dart: Built build/web (exit 0)
```

Not verified in this round: iOS build, any device or emulator run, visual
acceptance, the full STAGING Flutter suite.

## Known blockers and decisions

The full uploader dry run currently refuses all writes:

```text
Invalid sources (3):
lessons/reading-comprehension/text-types/visual-media.md: resolved lesson exceeds safe Firestore document size
lessons/science/earth-science-astronomy/layers-of-the-earth.md: resolved lesson exceeds safe Firestore document size
questions/mathematics/arithmetic-number-sense/ratio-and-proportion.yaml: Missing closing 'quote at line 355, column 21:
Nothing written. Fix the sources or pass --skip-invalid.
```

The malformed question YAML predates B9 and is in the rewrite scope, not this
change. No question source was modified. Embedding the existing large PNG files
exceeds the 900,000-byte safe body threshold in two lessons. No size limit was
weakened. Aedwon has been asked whether to place illustrations in the existing
web Hosting build and store URLs. No hosting change or deployment is authorized
by an unanswered question. This remains an open decision and item 3 is partial
until the oversized local PNG path is resolved.

Superseded: the lead ruled no PNG hosting. See Review fixes, round 1, item 4.

## Scope additions discovered from source

The brief names the legacy portable renderer. The actual W4c lesson reader uses
ContentRenderer. Both were changed; otherwise the feature would not appear in
current lessons. STAGING receives the same renderer, loader, dependency and asset
resolver changes so its web build compiles the actual feature. The server remote
Markdown parser also required a change because it previously dropped all image
markers. These additions are required to satisfy the named runtime paths.

No seed database, signed manifest, detached signature, question figure, question
source, deployment configuration, native flavor, or scheme was modified.

## Additional checker regression

The selected parser also ignores symbol viewBox attributes and marks nested SVG
as unsupported. Two fixtures reproduced acceptance before the checker rejected
them. The authoring subset now rejects both cases. The Python fixture suite
passes after this correction.

## Final gate output

Every command below was run. Log excerpts are actual output. Full local logs
remain in APP and STAGING `build/b9/`. Relay links:
- APP generation: https://github.com/Aedwon/chatgpt-terminal-relay/issues/11697
- APP final gates/builds: https://github.com/Aedwon/chatgpt-terminal-relay/issues/11700
- STAGING checks/web build: https://github.com/Aedwon/chatgpt-terminal-relay/issues/11704
- Android successful retry: https://github.com/Aedwon/chatgpt-terminal-relay/issues/11706

Flutter command invocations were serialized. A canceled run left a headless
test child, verified and terminated as recorded below. STAGING's test formatting correction
changed commas only; its final analysis and format results are included below.


### APP focused-accepted

Command: `flutter test test/core/ui/components/lesson_svg_test.dart test/tools/lesson_svg_assets_test.dart`

Exit: 0

```text
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG renders with alt text reader=true dark=false
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: SVG renders with alt text reader=true dark=true
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: legacy content expansion retains SVG alt text
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: remote SVG uses the SVG loader even with a query
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: existing remote PNG keeps its cached image path
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: invalid SVG uses existing failure state reader=false
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/core/ui/components/lesson_svg_test.dart: invalid SVG uses existing failure state reader=true

🎉 15 tests passed.
```

### APP full-test-accepted

Command: `flutter test`

Exit: 0

```text
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tool/release_e2e_runner_test.dart: Firebase isolation and failure plumbing Firestore reset fails closed on malformed collection listing JSON
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tool/release_e2e_runner_test.dart: Firebase isolation and failure plumbing Firestore reset fails closed on non-object collection listing JSON
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tool/release_e2e_runner_test.dart: Firebase isolation and failure plumbing bounded polling times out with predicate diagnostics
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tool/release_e2e_runner_test.dart: Firebase isolation and failure plumbing cleanup, diagnostics, and summary failures are fatal
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tool/release_e2e_runner_test.dart: Firebase isolation and failure plumbing redacts credentials and learner-payload-like fields
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tool/release_e2e_runner_test.dart: static runner and workflow contract runner is strict, device-bound, deterministic, and sleep-free
✅ /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/test/tool/release_e2e_runner_test.dart: static runner and workflow contract jobs.ci remains semantically unchanged and integration is absent

🎉 4851 tests passed.
```

### APP analyze-final

Command: `flutter analyze lib test tool`

Exit: 0

```text
  web 1.1.1 (1.1.2 available)
  webdriver 3.1.0 (3.2.0 available)
  xml 6.6.1 (7.1.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
124 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing 3 items...                                            
No issues found! (ran in 6.7s)
```

### APP format

Command: `dart format --output=none --set-exit-if-changed lib test tool tools/content/lesson_asset_map.dart tools/check_lesson_svgs_render_test.dart`

Exit: 0

```text
Formatted 1606 files (0 changed) in 2.61 seconds.
```

### APP layering

Command: `dart run tool/check_layering.dart`

Exit: 0

```text
Running build hooks...Running build hooks...check_layering: OK
```

### APP attribution

Command: `dart run tool/check_no_ai_attribution.dart`

Exit: 0

```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

### APP svg-fixture-tests

Command: `python3 tools/check_lesson_svgs_test.py`

Exit: 0

```text
..
----------------------------------------------------------------------
Ran 2 tests in 0.005s

OK
```

### APP svg-pass-render

Command: `python3 tools/check_lesson_svgs.py tools/svg_fixtures/pass`

Exit: 0

```text
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
124 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/check_lesson_svgs_render_test.dart
00:00 +0: draw /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/pass/basic.svg light
00:00 +1: draw /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/pass/basic.svg dark
00:00 +2: SVG root exists
00:00 +3: All tests passed!
```

### APP svg-fail-fixtures

Command: `python3 tools/check_lesson_svgs.py tools/svg_fixtures/fail --validate-only`

Exit: 1

```text
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/animation.svg: unsupported element <animate>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/css.svg: unsupported element <style>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/doctype.svg: external declarations, entities and stylesheets are forbidden
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/event.svg: unsupported attribute onclick on <rect> (CSS and event handlers are forbidden)
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/external-paint.svg: external paint reference: https://example.com/a.svg#x
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/external.svg: external reference: https://example.com/x.svg#x
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/filter.svg: unsupported element <filter>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/ignored-attribute.svg: unsupported attribute class on <rect> (CSS and event handlers are forbidden)
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/ignored-baseline.svg: unsupported attribute dominant-baseline on <text> (CSS and event handlers are forbidden)
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/ignored-clip-units.svg: unsupported attribute clipPathUnits on <clipPath> (CSS and event handlers are forbidden)
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/ignored-font-style.svg: unsupported attribute font-style on <text> (CSS and event handlers are forbidden)
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/ignored-fr.svg: unsupported attribute fr on <radialGradient> (CSS and event handlers are forbidden)
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/inline-css.svg: unsupported attribute style on <rect> (CSS and event handlers are forbidden)
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/malformed.svg: invalid XML: mismatched tag: line 1, column 13
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/mask.svg: unsupported element <mask>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/nested-svg.svg: unsupported nested svg element
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/raster.svg: unsupported element <image>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/script.svg: unsupported element <script>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/set.svg: unsupported element <set>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/shadow.svg: unsupported element <filter>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/smil.svg: unsupported element <animateTransform>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/symbol-viewbox.svg: unsupported attribute viewBox on <symbol> (CSS and event handlers are forbidden)
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/unsupported-clip-child.svg: unsupported clipPath child <text>
/Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/tools/svg_fixtures/fail/unsupported.svg: unsupported element <foreignObject>
SVG preflight: 24 files, 24 failures
```

### APP svg-corpus

Command: `python3 tools/check_lesson_svgs.py`

Exit: 0

```text
SVG preflight: 0 files, 0 failures
```

### APP apk

Command: `flutter build apk --debug --flavor dev -t lib/main_dev.dart`

Exit: 1

```text
  url_launcher_linux 3.2.2 (3.2.3 available)
  url_launcher_macos 3.2.5 (3.2.6 available)
  url_launcher_windows 3.1.5 (3.1.6 available)
  vector_graphics 1.2.0 (1.2.4 available)
  vector_graphics_compiler 1.2.1 (1.3.2 available)
  vector_math 2.2.0 (2.4.3 available)
  very_good_analysis 6.0.0 (11.0.0 available)
  vm_service 15.2.0 (15.4.0 available)
  web 1.1.1 (1.1.2 available)
  webdriver 3.1.0 (3.2.0 available)
  xml 6.6.1 (7.1.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
124 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Running Gradle task 'assembleDevDebug'...                       

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':gradle:compileKotlin'.
> Could not isolate parameters org.jetbrains.kotlin.gradle.internal.transforms.BuildToolsApiClasspathEntrySnapshotTransform$Parameters_Decorated@625817d9 of artifact transform BuildToolsApiClasspathEntrySnapshotTransform
   > Could not isolate value org.jetbrains.kotlin.gradle.internal.transforms.BuildToolsApiClasspathEntrySnapshotTransform$Parameters_Decorated@625817d9 of type BuildToolsApiClasspathEntrySnapshotTransform.Parameters
      > Could not resolve all files for configuration ':gradle:kotlinBuildToolsApiClasspath'.
         > Could not download kotlin-compiler-embeddable-2.2.20.jar (org.jetbrains.kotlin:kotlin-compiler-embeddable:2.2.20)
            > Could not get resource 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-compiler-embeddable/2.2.20/kotlin-compiler-embeddable-2.2.20.jar'.
               > Could not GET 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-compiler-embeddable/2.2.20/kotlin-compiler-embeddable-2.2.20.jar'.
                  > Read timed out

* Try:
> Run the 'artifactTransforms' report task to view details about registered transforms.
> Review the documentation on Artifact Transforms at https://docs.gradle.org/8.14/userguide/artifact_transforms.html.
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 2m 29s
Running Gradle task 'assembleDevDebug'...                         150.4s
[!] Gradle threw an error while downloading artifacts from the network.
Retrying Gradle Build: #1, wait time: 100ms
Running Gradle task 'assembleDevDebug'...                       

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:processDevDebugGoogleServices'.
> File google-services.json is missing. 
  The Google Services Plugin cannot function without it. 
  Searched locations: /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/android/app/src/dev/debug/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/android/app/src/debug/dev/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/android/app/src/dev/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/android/app/src/debug/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/android/app/src/devDebug/google-services.json, /Users/aedwon/Documents/Projects/Pantas-wt-lesson-svg-r1/android/app/google-services.json

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 2m 52s
Running Gradle task 'assembleDevDebug'...                         173.0s
Gradle task assembleDevDebug failed with exit code 1
```

### APP ios

Command: `flutter build ios --no-codesign --debug --flavor dev -t lib/main_dev.dart`

Exit: 1

```text
  web 1.1.1 (1.1.2 available)
  webdriver 3.1.0 (3.2.0 available)
  xml 6.6.1 (7.1.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
124 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Warning: Building for device with codesigning disabled. You will have to manually codesign before deploying to device.
Xcode is fetching Swift Package Manager dependencies. This may take several minutes...
  Fetching from https://github.com/google/GTMAppAuth.git...     
  Fetching from https://github.com/firebase/nanopb.git...       
  Fetching from https://github.com/simolus3/CSQLite.git...      
  Fetching from https://github.com/GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk.git...     
  Fetching from https://github.com/google/GoogleSignIn-iOS.git...     
  Fetching from https://github.com/google/gtm-session-fetcher.git...     
  Fetching from https://github.com/google/app-check.git...      
  Fetching from https://github.com/google/GoogleUtilities.git...     
  Fetching from https://github.com/google/interop-ios-for-google-sdks.git...     
  Fetching from https://github.com/google/GoogleDataTransport.git...     
  Fetching from https://github.com/firebase/firebase-ios-sdk...     
  Fetching from https://github.com/google/abseil-cpp-binary.git...     
  Fetching from https://github.com/googleads/google-ads-on-device-conversion-ios-sdk...     
  Fetching from https://github.com/RevenueCat/purchases-hybrid-common.git...     
  Fetching from https://github.com/google/GoogleAppMeasurement.git...     
  Fetching from https://github.com/google/promises.git...       
  Fetching from https://github.com/google/grpc-binary.git...     
  Fetching from https://github.com/firebase/leveldb.git...      
  Fetching from https://github.com/RevenueCat/purchases-ios-spm...     
  Fetching from https://github.com/openid/AppAuth-iOS.git...     

The Xcode project defines schemes: app-settings, cloud-firestore, cloud-functions, firebase-analytics, firebase-app-check, firebase-auth, firebase-core, firebase-crashlytics, firebase-messaging, firebase-remote-config, firebase-storage, flutter-local-notifications, flutter-secure-storage-darwin, FlutterFramework, FlutterGeneratedPluginSwiftPackage, google-sign-in-ios, in-app-review, integration-test, purchases-flutter, RevenueCatUI, RevenueCatUITests, Runner, sign-in-with-apple, sqflite-darwin, url-launcher-ios
You must specify a --flavor option to select one of the available schemes.
```

### APP Android final retry

Command: `flutter build apk --debug --flavor dev -t lib/main_dev.dart`

Exit: 0

```text
124 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Running Gradle task 'assembleDevDebug'...                       
Note: /Users/aedwon/.pub-cache/hosted/pub.dev/cloud_firestore-6.8.0/android/src/main/java/io/flutter/plugins/firebase/firestore/utils/PipelineStageHandlers.java uses unchecked or unsafe operations.
Note: Recompile with -Xlint:unchecked for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
3 warnings
Running Gradle task 'assembleDevDebug'...                         159.1s
✓ Built build/app/outputs/flutter-apk/app-dev-debug.apk
```

Android recovery: the first attempt had a Maven download timeout, then reached
missing dev google-services.json. The existing registered dev SDK configuration
was retrieved read-only with Firebase apps:sdkconfig into the already ignored
flavor path. No app registration, project change, secret display, or deployment
occurred. Relay #11703 reported exit 0 and file present. The retry built the APK.
The ignored SDK configuration remains available for the lead's local builds.

iOS: Xcode 27.1 is installed. The exact requested command failed because the
project has no dev scheme. Runner and package schemes exist. No schemes were
created. Xcode removed CSQLite from Package.resolved during its failed attempt;
only that exact tool-generated deletion was restored to its original bytes.
The canceled test left one headless test process. Relay #11702 verified its cwd
and #11705 terminated only that confirmed orphan, with PID/parent/path guards.

SVG corpus: zero SVG files currently exist under content/illustrations. The real
corpus scan therefore exits 0 with zero files. Parser/draw coverage comes from
the pass fixture in both themes; 24 negative fixtures each fail preflight.
Actual lesson SVG artwork and Aedwon's visual acceptance remain future inputs.

### STAGING pub-get

Command: `flutter pub get`

Exit: 0

```text
  vector_graphics 1.2.0 (1.2.4 available)
  vector_graphics_compiler 1.2.1 (1.3.2 available)
  vector_math 2.2.0 (2.4.3 available)
  very_good_analysis 6.0.0 (11.0.0 available)
  vm_service 15.2.0 (15.4.0 available)
  web 1.1.1 (1.1.2 available)
  webdriver 3.1.0 (3.2.0 available)
  xml 6.6.1 (7.1.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
124 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

### STAGING focused

Command: `flutter test test/core/ui/components/lesson_svg_test.dart test/core/content/remote/lesson_markdown_test.dart test/tools/markdown_portable_text_test.dart`

Exit: 0

```text
✅ /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/tools/markdown_portable_text_test.dart: markdownToPortableText resolves image marker by lesson and sequence
✅ /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/tools/markdown_portable_text_test.dart: markdownToPortableText throws FormatException with lesson path and line for unresolved image marker
✅ /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/tools/markdown_portable_text_test.dart: markdownToPortableText preserves existing markdown structures: headings, lists, quotes, inline math
✅ /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/tools/markdown_portable_text_test.dart: markdownToPortableText ignores non-figure and non-illustration HTML comments
Shell: content/lessons/science/physics/gravity-and-keplers-laws.md:7: dropped image without source credit
✅ /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/tools/markdown_portable_text_test.dart: markdownToPortableText resolves sparse image markers in numeric order of keys (e.g. keys #2 and #4)
Shell: content/lessons/science/physics/gravity-and-keplers-laws.md:1: dropped image without source credit
Shell: content/lessons/science/physics/gravity-and-keplers-laws.md:2: dropped image without source credit
✅ /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/tools/markdown_portable_text_test.dart: markdownToPortableText throws FormatException with lesson path and line when markers exceed available sparse keys
✅ /Users/aedwon/Documents/Projects/Pantas-wt-pwa-staging-r1/test/tools/markdown_portable_text_test.dart: markdownToPortableText unconfigured or disabled LessonAssetMap ignores ILLUSTRATION markers and preserves text

🎉 31 tests passed.
```

### STAGING analyze

Command: `flutter analyze lib test tool`

Exit: 1

```text
Analyzing 3 items...                                            

   info • 'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead. The onReorderItem callback adjusts the newIndex parameter for a removed item at the oldIndex. This feature was deprecated after v3.41.0-0.0.pre. Try replacing the use of the deprecated member with the replacement • lib/features/lesson/presentation/widgets/bookmarks_sheet.dart:238:21 • deprecated_member_use
   info • Missing a required trailing comma. Try adding a trailing comma • test/core/content/remote/lesson_markdown_test.dart:18:41 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • test/core/content/remote/lesson_markdown_test.dart:22:30 • require_trailing_commas

3 issues found. (ran in 33.7s)
```

### STAGING format

Command: `dart format --output=none --set-exit-if-changed lib/core/ui/components/lesson_svg.dart lib/core/ui/components/content_renderer.dart lib/core/ui/components/portable_text_renderer.dart lib/core/content/remote/lesson_markdown.dart test/core/ui/components/lesson_svg_test.dart test/core/content/remote/lesson_markdown_test.dart tools/content/lesson_asset_map.dart`

Exit: 0

```text
Formatted 7 files (0 changed) in 0.05 seconds.
```

### STAGING upload-tests

Command: `node --test tools/upload_content/lesson_illustrations.test.mjs`

Exit: 0

```text
✔ server content carries SVG and PNG bytes in marker order (19.449125ms)
✔ rejects unsafe lesson paths (0.302375ms)
✔ preserves remote PNG slots while replacing a later slot with local SVG (6.740792ms)
✔ rejects symlinked subject ancestors (9.405208ms)
ℹ tests 4
ℹ suites 0
ℹ pass 4
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 233.429917
```

### STAGING web

Command: `flutter build web --release -t lib/main_staging.dart`

Exit: 0

```text
Compiling lib/main_staging.dart for the Web...                  
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, Phosphor, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, Phosphor). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 9244 bytes (99.4% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 8836 bytes (98.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main_staging.dart for the Web...                     78.4s
✓ Built build/web
```

### STAGING final whole-tree analysis

Command: `dart analyze lib test tool`

Exit: 0

```text
Analyzing lib, test, tool...

   info - lib/features/lesson/presentation/widgets/bookmarks_sheet.dart:238:21 - 'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead. The onReorderItem callback adjusts the newIndex parameter for a removed item at the oldIndex. This feature was deprecated after v3.41.0-0.0.pre. Try replacing the use of the deprecated member with the replacement. - deprecated_member_use

1 issue found.
```

### STAGING changed Dart files analysis

Command: `dart analyze <seven changed Dart files>`

Exit: 0

```text
Analyzing lesson_svg.dart, content_renderer.dart, portable_text_renderer.dart, lesson_markdown.dart, lesson_svg_test.dart, lesson_markdown_test.dart, lesson_asset_map.dart...
No issues found!
```

### STAGING final changed-file format

Command: `dart format --output=none --set-exit-if-changed <seven changed Dart files>`

Exit: 0

```text
Formatted 7 files (0 changed) in 0.02 seconds.
```

The one remaining STAGING notice is the pre-existing bookmarks onReorder
API deprecation. `git show HEAD:<path>` confirms that original call. It was not
modified. STAGING's whole-tree analysis is not reported as clean. The two owned
trailing-comma findings were corrected, and all seven changed Dart files analyze
cleanly. APP's required flutter analyze lib test tool is clean.

## Final worktree status, pasted

### APP

`git status --short`

```text
 M lib/core/ui/components/content_renderer.dart
 M lib/core/ui/components/portable_text_renderer.dart
 M pubspec.lock
 M pubspec.yaml
 M tools/content/lesson_asset_map.dart
?? docs/content/lesson-svg-authoring.md
?? docs/superpowers/plans/pwa-launch/
?? lib/core/ui/components/lesson_svg.dart
?? test/core/ui/components/lesson_svg_test.dart
?? test/tools/lesson_svg_assets_test.dart
?? tools/check_lesson_svgs.py
?? tools/check_lesson_svgs_render_test.dart
?? tools/check_lesson_svgs_test.py
?? tools/svg_fixtures/
```

APP dirty non-document source and fixture SHA-256 inventory:

```json
{
  "lib/core/ui/components/content_renderer.dart": "5df869c3dbf7651a4a70743aa0aae969d8e84a9574711dd0332ea8d86b1eb672",
  "lib/core/ui/components/lesson_svg.dart": "ccbc071c4e9dde60952765e16b46ca29e3906c826e428610b8f6b078736d0bcb",
  "lib/core/ui/components/portable_text_renderer.dart": "f89786012680255bb6baf056fe413ab8b8f278725fee6df44eccfde461811056",
  "pubspec.lock": "7d7f0fd60538172eb833c6a1379cad877047ba5cdf3c4b6eb1b419686eda6b94",
  "pubspec.yaml": "05f28cc200c04249d7bc3165c1ee7e0c8d6880e7296a3525ba421d1685c11511",
  "test/core/ui/components/lesson_svg_test.dart": "6a98838f368d11951d00a1d6cfdde52af9cfc8d13399228b10e750b684a348ad",
  "test/tools/lesson_svg_assets_test.dart": "76edd4fdccb2c362d9535399db885b9ff4a820ceb60914a3fdfd57902624d642",
  "tools/check_lesson_svgs.py": "b5a431ecfcd3087b1bf7fb3fed58379b7e130a9351bca09a3e4f17259cec6ab2",
  "tools/check_lesson_svgs_render_test.dart": "c16ddb7142ba489bb36b9f93b7f0e0340df08635a63077e7485e290744682ba5",
  "tools/check_lesson_svgs_test.py": "b042c980a0dd00931442725eb19ffe14f026ce3ab26115b2cff6beae9317fcdc",
  "tools/content/lesson_asset_map.dart": "70f82fb6040f5744a75a3595b99c2b2ea424f42198e75ca7035e233fcf962567",
  "tools/svg_fixtures/fail/animation.svg": "9e5e5dfa21bc8821d02551bd3d1b9b5a50ad219e9e949fe74b0a716c526aab6c",
  "tools/svg_fixtures/fail/css.svg": "3d9bacddcd79857d9b903c5a1d44100ef6289d3818c0c05d0614d7369addee8f",
  "tools/svg_fixtures/fail/doctype.svg": "fb2f53c74bd5295f9a7e932cb73960607e7f5e7a8d6c4480610b64cae1098238",
  "tools/svg_fixtures/fail/event.svg": "6f9f604d342d04b3edee522a91de90a18f8329ebf42eaf939ab3312c5f1611f6",
  "tools/svg_fixtures/fail/external-paint.svg": "abd6d0e789405e45f8b860bc64cf9d16d1608d196cba56156323f4dd21603363",
  "tools/svg_fixtures/fail/external.svg": "14f8e4ecd1a1c630001a07082ee5a6237d24e9dbc5cd8461b034fcb7485d3f44",
  "tools/svg_fixtures/fail/filter.svg": "055a237f626a8c28090fa54f10464f759d6a98a989d50392c1e5bb3a16a3c4d3",
  "tools/svg_fixtures/fail/ignored-attribute.svg": "0842302e1cd34f8b325ed21a279bfef7b178fbab612c9cf3d2ec311de47b1655",
  "tools/svg_fixtures/fail/ignored-baseline.svg": "f70c9b0154145de5273e3bb6d190310d902101b989c168d20dd10d3de1328a0c",
  "tools/svg_fixtures/fail/ignored-clip-units.svg": "3a54fc8a75cebbddee8249942b7b90b51d8eeb771763feccc7e6a95ec34ef568",
  "tools/svg_fixtures/fail/ignored-font-style.svg": "45a3126e6016def3ca23772f39a2d76dd975dbbadea947ebf51a8d3b32f96ac9",
  "tools/svg_fixtures/fail/ignored-fr.svg": "f1ca6d1de1da39126fbc076c8bb965e51642d543fb9443c30386e91cd850139f",
  "tools/svg_fixtures/fail/inline-css.svg": "1dc700656c8a7b3804296c0ea63ebe57a1a2db00744764d3ee04b2d92d948788",
  "tools/svg_fixtures/fail/malformed.svg": "2b208b66509a5b182e27e36078eb69fc5cc21f8c8cf1044aece4a0320011d525",
  "tools/svg_fixtures/fail/mask.svg": "68452744761dc69e49405b72a526013df50d6bb1659a047c6c2b752b424c224e",
  "tools/svg_fixtures/fail/nested-svg.svg": "f279035acd4d0a8c9606b81a0e2de27c5b40f9ed7ec3e1feb72dfa0e552712e4",
  "tools/svg_fixtures/fail/raster.svg": "0bb59cd2163023fe4a041891dc550cd19b941717f663ca30c849388993fb7a9e",
  "tools/svg_fixtures/fail/script.svg": "7ac2b07d2adfc1a6c6e4d9c67002e81b2b01fef7d4a5808a8918ec8440eeaf78",
  "tools/svg_fixtures/fail/set.svg": "cfb632e323bb2962525d5d9c4b1a447babb1c445e86a31aef4de1073215a9d8b",
  "tools/svg_fixtures/fail/shadow.svg": "fbbce1d390bacfa6f4887428a79f9f70be50088e981e5c822127bcebfd5f23bb",
  "tools/svg_fixtures/fail/smil.svg": "089ef578938ab82eb9accce955bcf457da88706d3ae71a236840c21a57988389",
  "tools/svg_fixtures/fail/symbol-viewbox.svg": "177bbdd1d9fffd4c1efc6a7b8f96fdf9d7a6ff946558d2aa2f0f32c721141a2d",
  "tools/svg_fixtures/fail/unsupported-clip-child.svg": "61699f4d22dea0c90e8a338e95c91e097c345109187315375b113c605047df6d",
  "tools/svg_fixtures/fail/unsupported.svg": "a3c2f6488fba451896214a174d471179e454707fcee2d419a270f9002ee5928f",
  "tools/svg_fixtures/pass/basic.svg": "132afbf96384d5e3269e6b0e4959a50abfc7c3b152bfa7a619a7786f2772b47f"
}
```

### STAGING

`git status --short`

```text
 M lib/core/content/remote/lesson_markdown.dart
 M lib/core/ui/components/content_renderer.dart
 M lib/core/ui/components/portable_text_renderer.dart
 M pubspec.lock
 M pubspec.yaml
 M test/core/content/remote/lesson_markdown_test.dart
 M tools/content/lesson_asset_map.dart
 M tools/upload_content/upload_content.mjs
?? lib/core/ui/components/lesson_svg.dart
?? test/core/ui/components/lesson_svg_test.dart
?? tools/upload_content/lesson_illustrations.mjs
?? tools/upload_content/lesson_illustrations.test.mjs
```

STAGING dirty non-document source and fixture SHA-256 inventory:

```json
{
  "lib/core/content/remote/lesson_markdown.dart": "e1e4b1db50fee73a7df23bcd229f4005489a9d13b413806545ef9422464450c9",
  "lib/core/ui/components/content_renderer.dart": "5df869c3dbf7651a4a70743aa0aae969d8e84a9574711dd0332ea8d86b1eb672",
  "lib/core/ui/components/lesson_svg.dart": "ccbc071c4e9dde60952765e16b46ca29e3906c826e428610b8f6b078736d0bcb",
  "lib/core/ui/components/portable_text_renderer.dart": "f89786012680255bb6baf056fe413ab8b8f278725fee6df44eccfde461811056",
  "pubspec.lock": "7d7f0fd60538172eb833c6a1379cad877047ba5cdf3c4b6eb1b419686eda6b94",
  "pubspec.yaml": "05f28cc200c04249d7bc3165c1ee7e0c8d6880e7296a3525ba421d1685c11511",
  "test/core/content/remote/lesson_markdown_test.dart": "fe3a7b3fd36daae2188d6782700f8adf5ee2282938f5ed884b486af43b9cf5f1",
  "test/core/ui/components/lesson_svg_test.dart": "6a98838f368d11951d00a1d6cfdde52af9cfc8d13399228b10e750b684a348ad",
  "tools/content/lesson_asset_map.dart": "70f82fb6040f5744a75a3595b99c2b2ea424f42198e75ca7035e233fcf962567",
  "tools/upload_content/lesson_illustrations.mjs": "156bd8e3ffaa2da3e9c35bd67dcdea69ee586682189961f12765a7a10333aa86",
  "tools/upload_content/lesson_illustrations.test.mjs": "563acb1c7f5ba0372aebafc29eec43f692ab21cd1f52f01706cb36ff6228b90d",
  "tools/upload_content/upload_content.mjs": "37733e8a3de452f2b003bd041237a712a8afef5f027cdab167717909ea5caf73"
}
```

## Material build inputs and artifacts

```text
APP assets/seed/content.db: 9973760 bytes sha256 0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc
APP assets/seed/content.manifest.json: 538 bytes sha256 51bc0a766558879e540475ab972f03df7e3077241bab8f688c1b50ece5874f23
APP assets/seed/content.manifest.sig: 64 bytes sha256 e0853df259529031344f14d5a5fe6628e1b92c367a96c584894058fe13199f31
APP build/app/outputs/flutter-apk/app-dev-debug.apk: 197842436 bytes sha256 ff6c383b4cbaab9af2ea00df692f40fd3738db91cc7fe3d761e99582d7a44b69
STAGING assets/seed/content.db: 9973760 bytes sha256 0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc
STAGING assets/seed/content.manifest.json: 538 bytes sha256 51bc0a766558879e540475ab972f03df7e3077241bab8f688c1b50ece5874f23
STAGING assets/seed/content.manifest.sig: 64 bytes sha256 e0853df259529031344f14d5a5fe6628e1b92c367a96c584894058fe13199f31
STAGING build/web/main.dart.js: 6055288 bytes sha256 763ba688ef5c60f5c5b5b98afae05e3178fc91dbe603ff6a558a9abd03224179
```

No pinned content package was rebuilt. Source SHA-256 inventories cover the final
non-document dirty files, including all negative/pass SVG fixtures. Documentation
is intentionally excluded from its own identity inventory.

## Outstanding decisions and next action

1. Resolved by the lead ruling: no PNG hosting. Oversized lessons wait for SVG
   replacements; the seed drops an over-limit figure with a warning and the upload
   rejects the lesson. See Review fixes, round 1, item 4.
2. Restore the existing dev iOS scheme through the owning setup workstream, then
   rerun the required iOS command. This is a setup blocker, not a figure design choice.
3. The content rewrite owner fixes the existing malformed ratio/proportion YAML.
4. The lead commits the uncommitted changes, performs integration/acceptance, and
   updates the lock-holder-owned B9 status row. No main/status upload was attempted.
5. Aedwon performs visual review. Automated checks are not visual acceptance.

Final post-evidence checks: attribution exit 0; both `git diff --check` commands
exit 0. Final source inventories were compared to the verified dirty sources:

```text
check_no_ai_attribution: OK
APP source inventory changes after verification: []
STAGING source inventory changes after verification: []
```
