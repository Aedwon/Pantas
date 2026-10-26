# B8 staging candidate size evidence

## Identity and scope

- Candidate: `web/staging-candidate-r1`, HEAD `3a55d5406f8858a40e83bf948164daf251c30bfa`.
- Policy: `origin/main` at `44afc369259e599acdfdc6417d808014e578c1fc`; read AGENTS.md, WORKFLOW.md and SUBAGENTS.md with `git show`.
- Explicit lead brief overrides fetching and completion permissions: no fetch, pull, staging, commit, push or deploy performed.
- Initial `git status --short`: empty. Repository remote: `https://github.com/Aedwon/Pantas`.
- Scope: B4 measurements and B8 decision-free cuts only. No deferred imports, hosting configuration changes, dependencies, seed changes or generated-file changes.
- Flutter 3.44.6, Dart 3.12.2, engine `83675ed27633283e7fc296c8bca22e841224c096`, macOS arm64.
- Existing candidate evidence and B2-B3 verification were inspected. No B4 first/repeat-load transfer record was found in this branch's evidence directory. This report does not substitute historical deployment evidence.

## Cut and proof

Only the native protected-content package declarations changed. The database, signed manifest and signature now declare platforms `android, ios, linux, macos, windows`. Flutter's installed asset parser supports this platform filter. Native declarations remain present.

Code search: `rg -n 'content.db|manifest.sig|manifest.json|kIsWeb' lib/core/content lib/app`. Startup skips protected installation on web, opens an in-memory content mirror, and fetches content through the server. The web protected database opener and seed installer throw rather than reading these assets. Existing `test/core/content/remote/web_content_overrides_test.dart` exercises the server-backed mirror and catalog refresh. Build output checks establish the packaging difference.

This cuts shipped bytes, not a proven first-navigation download: the current web app does not request the protected seed package during startup. CSE-only seed generation remains skipped because E7 owns it. This change does not rebuild or inspect the protected database contents.

## Font assessment

The release command enables icon tree shaking by default. Actual baseline output:

```text
Font asset "Phosphor.ttf" was tree-shaken, reducing it from 488636 to 13660 bytes (97.2% reduction).
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 9264 bytes (99.4% reduction).
```

Phosphor uses constant icon references and already receives automatic subsetting. No additional cut is needed. Geist remains four weights. Flutter's icon subsetter is installed, but its constant-codepoint analysis does not prove the character set for text fonts. Remote lesson text, Filipino text and student-entered text prevent a decision-free static character whitelist. No font or icon was removed, and KaTeX fonts remain for lesson mathematics. Font license files remain.

## Measurement method

Raw sizes count file payload bytes, not filesystem allocation. Decimal MB means 1,000,000 bytes. Gzip uses Python `gzip.compress(..., compresslevel=9, mtime=0)`. Brotli uses installed `brotli -q 11 -c FILE`. Compression is measured output, not a claim that a server serves that encoding.

First-load inventories below are static payload budgets inferred from startup and Flutter's loader, not browser network traces. Include entry HTML, bootstrap, compiled app, manifests, renderer, startup database engine/worker the bundled exam catalog, and all bundled fonts as a conservative font bound. Exclude source maps, renderer variants not selected, license text, and unused protected seed assets. Dynamic Firebase/auth/App Check scripts, server responses, headers, cache negotiation and browser-specific fallback requests remain unmeasured. Therefore the under-6-MB transferred acceptance target and repeat-load traffic are not verified here.

## Lighthouse attempt

Google Chrome is absent from `/Applications`. Cached Chrome for Testing exists at `/Users/aedwon/Library/Caches/ms-playwright/chromium-1248/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing`. `npx` is available.

```sh
python3 -m http.server 8769 --bind 127.0.0.1 --directory build/web
CHROME_PATH='/Users/aedwon/Library/Caches/ms-playwright/chromium-1248/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing' npx --yes lighthouse http://127.0.0.1:8769 --output=json --output-path=/tmp/B8-before-lighthouse.json --chrome-flags='--headless --no-sandbox'
```

The browser did not expose its debugging port in this sandbox. No report was produced. Scores and LCP: unavailable. Actual error:

```text
Runtime error encountered: waiting for dynamic debugging port in chrome-err.log
Error: waiting for dynamic debugging port in chrome-err.log
```

No phone, Safari, visual acceptance, deployed staging traffic, repeat-load traffic, or Welcome-within-one-second measurement was performed. No hosting configuration changed. The runner availability query `gh api repos/Aedwon/Pantas/actions/runners --jq '.runners[] | [.name,.status,.busy]'` returned no runners; direct local commands were used.

## Test correction during verification

The first full-suite run found an affected test that casts every asset entry to a string. Platform-specific entries are YAML maps. That run was interrupted after this known failure; it is not a passing full-suite result. Flutter also printed shutdown cleanup errors after interruption.

```text
02:33 +809 -1: .../test/core/content/bundle/content_asset_test.dart: Flutter assets declare the protected content package companions [E]
  type 'YamlMap' is not a subtype of type 'String' in type cast
```

Updated that existing test to accept both supported declaration forms and assert the exact five native platforms for every protected seed companion. This test change was outside the brief's named evidence file, and is required by the packaging change. No unrelated failure was fixed.

```sh
flutter test test/core/content/bundle/content_asset_test.dart test/core/content/remote/web_content_overrides_test.dart --reporter expanded
```

```text
00:01 +3: All tests passed!
```

## Baseline: 15 largest output files

Bytes, including diagnostics and unused renderer variants. These are shipped files, not the first-load request list.

| File | Raw | Gzip | Brotli |
|---|---:|---:|---:|
| `assets/assets/seed/content.db` | 9,973,760 | 9,976,823 | 9,973,780 |
| `canvaskit/canvaskit.wasm` | 7,229,467 | 2,898,563 | 2,248,161 |
| `main.dart.js` | 6,828,259 | 1,926,780 | 1,439,514 |
| `main.dart.js.map` | 6,004,570 | 2,046,671 | 1,671,974 |
| `canvaskit/chromium/canvaskit.wasm` | 5,760,502 | 2,181,707 | 1,632,753 |
| `canvaskit/skwasm_heavy.wasm` | 5,172,643 | 2,275,537 | 1,848,511 |
| `canvaskit/experimental_webparagraph/canvaskit.wasm` | 4,138,344 | 1,552,896 | 1,173,576 |
| `canvaskit/skwasm.wasm` | 3,580,947 | 1,531,680 | 1,206,207 |
| `canvaskit/wimp.wasm` | 3,514,226 | 1,423,932 | 1,116,648 |
| `canvaskit/wimp.js.symbols` | 1,801,519 | 201,492 | 132,692 |
| `canvaskit/skwasm_heavy.js.symbols` | 1,666,301 | 253,387 | 167,057 |
| `canvaskit/skwasm.js.symbols` | 1,541,208 | 226,918 | 149,303 |
| `assets/NOTICES` | 1,483,592 | 122,209 | 47,378 |
| `canvaskit/canvaskit.js.symbols` | 1,357,066 | 199,888 | 137,158 |
| `canvaskit/chromium/canvaskit.js.symbols` | 1,274,971 | 183,226 | 125,695 |

## Compiled JavaScript attribution

Baseline `main.dart.js`: 6,828,259 bytes raw. Source map generated with `--source-maps`. Approximate generated-character attribution follows source-map column spans. This is not exclusive retained-package cost: shared/minified runtime and unassigned spans prevent interpreting it as removable bytes. Newlines and unmapped output account for the remaining difference.

| Source group | Generated characters |
|---|---:|
| unmapped | 2,704,194 |
| app/other | 1,216,922 |
| flutter | 980,890 |
| Flutter engine | 474,627 |
| Dart SDK | 411,385 |
| flutter_localizations | 166,381 |
| drift | 106,086 |
| flutter_math_fork | 85,165 |
| vector_graphics_compiler | 42,715 |
| riverpod | 30,379 |
| go_router | 28,386 |
| intl | 26,056 |
| sqlite3 | 24,242 |
| material_color_utilities | 21,541 |
| cloud_firestore_platform_interface | 20,891 |
| purchases_flutter | 20,406 |
| firebase_auth_platform_interface | 18,607 |
| petitparser | 16,470 |
| vector_math | 11,991 |
| source_span | 11,415 |

The largest named external groups are Flutter, Flutter localizations, Drift and flutter_math_fork. Their size alone does not prove a removable dependency. No package or deferred library change was made.

## CDN payload probes and recommendation

Pinned engine URL: `https://www.gstatic.com/flutter-canvaskit/83675ed27633283e7fc296c8bca22e841224c096/`.

For each filename below, actual commands used this form:

```sh
curl --max-time 30 -sS -L -H 'Accept-Encoding: br' -D /tmp/B8-cdn-canvaskit.wasm.br.headers 'https://www.gstatic.com/flutter-canvaskit/83675ed27633283e7fc296c8bca22e841224c096/canvaskit.wasm' -o /tmp/B8-cdn-canvaskit.wasm.br
# Repeated for chromium/canvaskit.js, chromium/canvaskit.wasm, canvaskit.js,
# and canvaskit.wasm, with Accept-Encoding: gzip and br separately.
```

All eight responses returned HTTP 200. The gzip-only requests returned identity bytes with no Content-Encoding header. Brotli requests returned `Content-Encoding: br`. These are observations of this network path, not a promise for every client or CDN edge.

| Renderer pair | CDN identity bytes | CDN Brotli bytes | Local gzip-9 bytes | Local Brotli-11 bytes |
|---|---:|---:|---:|---:|
| Chromium JS + WASM | 5,846,998 | 1,675,392 | 2,209,125 | 1,657,046 |
| Full JS + WASM | 7,316,326 | 2,293,334 | 2,926,024 | 2,272,517 |

The decoded CDN Chromium WASM matches the local file exactly:

```sh
brotli -d -c /tmp/B8-cdn-probe.wasm | shasum -a 256
shasum -a 256 build/web/canvaskit/chromium/canvaskit.wasm
```

```text
c2fc2864763540922c71d464e983bebf97b3a5312fd01c6a8988969747d13314  -
c2fc2864763540922c71d464e983bebf97b3a5312fd01c6a8988969747d13314  build/web/canvaskit/chromium/canvaskit.wasm
```

Recommendation for the lead: keep the current pinned CDN for this candidate. It already serves Brotli with one-year public caching. Maximum-quality self-hosted Brotli saves only 18,346 Chromium bytes or 20,817 full-renderer bytes in this probe. Self-hosting can consolidate origins and gives control of response headers and availability, but requires verifying production compression and cache headers. Python's local server serves identity bytes and is not representative of a compressed deployment. Neither option establishes an offline guarantee by itself. Lead decision remains open; no hosting configuration changed.

## WebAssembly build

`flutter build web --release -t lib/main_staging.dart --wasm` exited 0. Output totals 56,703,895 raw bytes. Includes JavaScript fallback and all renderer variants; no source maps were requested.

| Output | Raw | Gzip | Brotli |
|---|---:|---:|---:|
| `flutter_bootstrap.js` | 10,093 | 3,856 | 3,372 |
| `main.dart.js` | 6,828,224 | 1,926,751 | 1,440,013 |
| `main.dart.mjs` | 67,184 | 13,713 | 11,482 |
| `main.dart.wasm` | 6,597,763 | 2,262,335 | 1,720,008 |

Static single-thread skwasm startup budget: raw 12,689,725, gzip 4,949,348, brotli 3,951,737 bytes. Browser renderer selection and fallback were not exercised.

Static heavy skwasm startup budget: raw 14,281,534, gzip 5,693,214, brotli 4,594,031 bytes. Browser renderer selection and fallback were not exercised.

The build does not prove runtime compatibility. No recommendation to switch to WASM is made without browser testing. No source-only symbols or diagnostics count toward the static first-load budget.

## Commands and reproducibility

Builds (all from the assigned worktree):

```sh
flutter build web --release -t lib/main_staging.dart --source-maps
flutter build web --release -t lib/main_staging.dart --wasm
flutter build web --release -t lib/main_staging.dart --source-maps --no-web-resources-cdn
```

Inventory commands: `python3 /tmp/b8_measure.py /tmp/B8-before.json`, then `python3 /tmp/b8_fast_measure.py /tmp/B8-wasm.json`. The scripts enumerate every file under `build/web`; the latter reuses compression measurements only when a file's SHA-256 matches the baseline. Core measurement logic, sufficient to repeat independently:

```python
import gzip, pathlib, subprocess
root = pathlib.Path('build/web')
for path in sorted(root.rglob('*')):
    if path.is_file():
        data = path.read_bytes()
        raw = len(data)
        gz = len(gzip.compress(data, compresslevel=9, mtime=0))
        br = len(subprocess.check_output(['brotli', '-q', '11', '-c', str(path)]))
        print(path.relative_to(root), raw, gz, br)
```

`python3 /tmp/b8_maps.py > /tmp/B8-packages.json` decodes source-map base64 VLQ entries, accumulates generated-column spans by the preceding source entry, and groups paths by pub-cache package, Flutter, engine, Dart SDK, app or unmapped output. Source maps remain local build output and are not staged.

Additional observed baseline warning: Flutter references the CupertinoIcons family without a bundled matching family. This preexists the cut and remains unresolved; no font was added or removed.

## Before and after measurements

All sizes are bytes. Compression totals below compress each file independently; they are not a compressed archive or a measured navigation. Both comparable JS builds use `--source-maps`.

| Output | Raw | Gzip | Brotli |
|---|---:|---:|---:|
| Before, CDN configuration | 66,018,308 | 28,657,132 | 24,499,440 |
| After, CDN configuration | 56,043,434 | 18,679,776 | 14,525,204 |
| After, self-hosted configuration | 56,043,387 | 18,679,698 | 14,525,308 |

Raw output reduction: 9,974,874 bytes. The three excluded native files total 9,974,362 raw bytes; remaining differences are manifests, bootstrap and compiled output. Source-map files account for 6,004,570 raw bytes in both comparable JS builds. The post-cut output excluding that diagnostic map is 50,038,864 bytes. Unrequested renderer variants and symbols still ship in the output directory but do not all load at startup.

### Static first-load inventory

This includes both AssetManifest representations and every bundled font as a conservative bound. Actual font requests depend on text and route. The catalog is included because the exam picker reads it. Native seed bytes fetched at startup are zero before and after, based on startup source. Server content responses are not included.

| Group | Before raw | Before gzip | Before Brotli | After raw | After gzip | After Brotli |
|---|---:|---:|---:|---:|---:|---:|
| HTML + bootstrap | 11,475 | 4,592 | 3,882 | 11,474 | 4,591 | 3,885 |
| main.dart.js | 6,828,259 | 1,926,780 | 1,439,514 | 6,828,259 | 1,926,780 | 1,439,514 |
| Chromium CanvasKit pair | 5,846,998 | 2,209,125 | 1,657,046 | 5,846,998 | 2,209,125 | 1,657,046 |
| SQLite + Drift worker | 1,176,595 | 494,090 | 425,255 | 1,176,595 | 494,090 | 425,255 |
| Geist, four weights | 510,404 | 241,178 | 208,329 | 510,404 | 241,178 | 208,329 |
| Phosphor + Material icons | 22,924 | 10,797 | 10,251 | 22,924 | 10,797 | 10,251 |
| KaTeX fonts, conservative bound | 640,372 | 370,050 | 347,905 | 640,372 | 370,050 | 347,905 |
| Asset/Font manifests + catalog + web metadata | 19,138 | 3,994 | 3,603 | 18,627 | 3,883 | 3,502 |
| Native seed/database package startup requests | 0 | 0 | 0 | 0 | 0 | 0 |

| Static configuration | Raw | Gzip | Brotli |
|---|---:|---:|---:|
| Before Chromium | 15,056,165 | 5,260,606 | 4,095,785 |
| After Chromium | 15,055,653 | 5,260,494 | 4,095,687 |
| Before full CanvasKit | 16,525,493 | 5,977,505 | 4,711,256 |
| After full CanvasKit | 16,524,981 | 5,977,393 | 4,711,158 |
| After self-hosted Chromium | 15,055,606 | 5,260,418 | 4,095,839 |
| After self-hosted full CanvasKit | 16,524,934 | 5,977,317 | 4,711,310 |

The rows above normalize renderer encoding using the same compressors. Actual HTTP comparison with this local identity-only server is below. The CDN renderer column uses the measured Brotli responses. All other local assets remain uncompressed in this comparison. These are constructed first-load payload sums, not a browser trace.

| Configuration | Chromium bytes | Full CanvasKit bytes |
|---|---:|---:|
| Before CDN | 10,884,559 | 11,502,501 |
| After CDN | 10,884,047 | 11,501,989 |
| After self-hosted | 15,055,606 | 16,524,934 |

### After: 15 largest output files

| File | Raw | Gzip | Brotli |
|---|---:|---:|---:|
| `canvaskit/canvaskit.wasm` | 7,229,467 | 2,898,563 | 2,248,161 |
| `main.dart.js` | 6,828,259 | 1,926,780 | 1,439,514 |
| `main.dart.js.map` | 6,004,570 | 2,046,671 | 1,671,974 |
| `canvaskit/chromium/canvaskit.wasm` | 5,760,502 | 2,181,707 | 1,632,753 |
| `canvaskit/skwasm_heavy.wasm` | 5,172,643 | 2,275,537 | 1,848,511 |
| `canvaskit/experimental_webparagraph/canvaskit.wasm` | 4,138,344 | 1,552,896 | 1,173,576 |
| `canvaskit/skwasm.wasm` | 3,580,947 | 1,531,680 | 1,206,207 |
| `canvaskit/wimp.wasm` | 3,514,226 | 1,423,932 | 1,116,648 |
| `canvaskit/wimp.js.symbols` | 1,801,519 | 201,492 | 132,692 |
| `canvaskit/skwasm_heavy.js.symbols` | 1,666,301 | 253,387 | 167,057 |
| `canvaskit/skwasm.js.symbols` | 1,541,208 | 226,918 | 149,303 |
| `assets/NOTICES` | 1,483,592 | 122,209 | 47,378 |
| `canvaskit/canvaskit.js.symbols` | 1,357,066 | 199,888 | 137,158 |
| `canvaskit/chromium/canvaskit.js.symbols` | 1,274,971 | 183,226 | 125,695 |
| `canvaskit/experimental_webparagraph/canvaskit.js.symbols` | 1,004,464 | 146,542 | 101,807 |

No native seed file remains in either post-cut JS output inventory or AssetManifest. The empty seed directory left by the incremental build contains no files. The final output is the default CDN configuration, restored using:

```sh
flutter build web --release -t lib/main_staging.dart --source-maps
python3 /tmp/b8_fast_measure.py /tmp/B8-after.json
```

The full-renderer gzip budget leaves only 22,607 bytes below 6 MB before dynamic scripts, API responses and HTTP overhead. The static budget is not enough evidence to accept the transfer target. Browser measurement against the actual staging encoding remains necessary. The native seed exclusion removes about 9.97 MB from hosted output but changes this startup budget by only 112 gzip bytes, mostly asset metadata.

## Source change identity and review boundary

```sh
git diff -- pubspec.yaml test/core/content/bundle/content_asset_test.dart test/tool/content_package_asset_contract_test.dart | shasum -a 256
```

```text
7bfa2bd35760a61731f6f09edcafc67e6a42df12410484ba58aa9b2f43826fb9  -
```

This hash covers the source and test patch, excluding this untracked evidence document. No files were staged or committed. Independent review and acceptance remain with the lead. The lead also owns any shared status/SSOT update; this bounded worker did not take the status lock or alter other workstreams.

## Full-suite blocker and final focused verification

`flutter test --reporter expanded --concurrency=16` completed with exit 1. It was the full suite, without filters. Actual summary:

```text
15:37 +4872 -2: Some tests failed.

Failing tests:
  /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/tool/content_package_asset_contract_test.dart: Flutter ships only the immutable protected content package assets
  /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/test/tool/content_seed_writer_test.dart: seed_writer creates an openable content database from fixture JSON
```

The first failure was another affected packaging assertion that searched for literal `- assets/seed/content.db`. It now parses YAML and checks the same required paths. It retains the existing ignore-file and historical-seed assertions. The other packaging test checks the exact native-only platform set. This second test amendment is included in the final source patch but occurred after its execution in the full run.

The second failure is outside B8's code changes. Actual subprocess failure:

```text
Expected: <0>
  Actual: <1>
Running build hooks...Running build hooks...Exception: Failed to get install name for dylib file:///Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/.dart_tool/lib/objective_c.dylib: error: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/otool-classic: can't open file: /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1/.dart_tool/lib/objective_c.dylib (No such file or directory)
```

This is a native build-hook failure, not an asset-path assertion. Root cause beyond the missing file was not established. It is not labeled pre-existing or accepted. SUBAGENTS.md's unrelated-test stop condition applies. No native tool, package, generated artifact or test expectation was changed to hide it. No green full-suite claim is made. A renewed full run on the final patch remains necessary after the lead resolves this blocker.

Final affected checks, exit 0:

```sh
flutter test test/core/content/bundle/content_asset_test.dart test/core/content/remote/web_content_overrides_test.dart test/tool/content_package_asset_contract_test.dart --reporter expanded
```

```text
00:00 +4: All tests passed!
```

The first analysis run found two missing trailing commas in the first test amendment. Both were corrected before the final analysis and format checks. No analyzer exception was accepted.

## Final gate output

The full suite is **failed**, as recorded above. These other commands exited 0. Output tails are copied from the actual logs.

```text
$ flutter analyze lib test tool
Analyzing 3 items...                                            
No issues found! (ran in 7.9s)
```

```text
$ dart format --output=none --set-exit-if-changed lib test tool
Formatted 1555 files (0 changed) in 1.87 seconds.
```

```text
$ dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK
```

```text
$ dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

```text
$ flutter build web --release -t lib/main_staging.dart --source-maps
Compiling lib/main_staging.dart for the Web...                     78.8s
✓ Built build/web
```

```text
$ flutter build web --release -t lib/main_staging.dart --wasm
Compiling lib/main_staging.dart for the Web...                    109.2s
✓ Built build/web
```

Files touched: `pubspec.yaml`, two existing packaging tests, and this evidence document. Both test amendments are necessary for the platform-specific declaration syntax. Seed files and generated files remain untouched and unstaged. No independent review, integration, commit, push or deploy was performed.

Final `git status --short`:

```text
 M pubspec.yaml
 M test/core/content/bundle/content_asset_test.dart
 M test/tool/content_package_asset_contract_test.dart
?? docs/superpowers/plans/pwa-launch/evidence/B8-size.md
```

B8 status: measurements and decision-free packaging cut recorded; engineering acceptance blocked by the native seed-writer test failure. Actual browser transfer, LCP, staging first/repeat load, and the under-6-MB transfer target remain unverified. CSE-only seed generation remains deferred to E7.

## October 26: merged B7c comparison at 417078bf

This new run supersedes the earlier statement that B7c size was unmeasured. It does
not replace browser transfer or offline acceptance. Policy: origin/main
`44afc369259e599acdfdc6417d808014e578c1fc`. Candidate:
`417078bf8015e50b6b78b0e5026204d680534aaf`; baseline: `9d3141a5`.
The initial candidate working tree was clean. No fetch, pull, staging, commit,
push, deploy, dependencies, or visual changes were made.

Both builds used Flutter 3.44.6 / Dart 3.12.2, engine
`83675ed27633283e7fc296c8bca22e841224c096`, and:

```sh
git worktree add --detach /private/tmp/pantas-b7c-before-9d3141a5 9d3141a5
# In that temporary worktree, after supplying the ignored generated files:
flutter pub get --offline
dart run build_runner build --delete-conflicting-outputs
flutter build web --release -t lib/main_staging.dart --source-maps
# In the assigned candidate worktree:
flutter build web --release -t lib/main_staging.dart --source-maps
# After saving measurements and checking the temporary tree was clean:
git worktree remove /private/tmp/pantas-b7c-before-9d3141a5
```

Actual execution built the candidate first, then the baseline. Existing ignored
`.g.dart`, `.freezed.dart`, and localization outputs were copied into the temporary
worktree before its own code generation. Ignored seed companions were also copied;
the platform-filtered web bundle excludes them. Both measurement builds used the
committed `588610f4184ff762` seed-version constant, so the local native rebuild did
not contaminate the source comparison. The rebuilt native constant was restored
afterward. The baseline worktree was removed successfully.

B8 method: raw file bytes; Python `gzip.compress(data, compresslevel=9, mtime=0)`,
compressing each file separately. Source maps are diagnostics and excluded from
first load. Deferred part files are excluded from the static first-load set for
onboarding/Home/lesson/quiz. Direct entry to a deferred route adds its part.
No browser request timing or transferred-byte measurement is claimed.

| JavaScript payload | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| `main.dart.js` | 6,828,259 | 1,926,780 | 6,705,270 | 1,889,609 |
| `main.dart.js_1.part.js` | absent | absent | 135,941 | 43,133 |
| Main plus all deferred parts | 6,828,259 | 1,926,780 | 6,841,211 | 1,932,742 |

Main savings: **122,989 raw / 37,171 gzip bytes**. Loading the deferred part later
makes the total compiled JavaScript **12,952 raw / 5,962 gzip bytes larger** than
the baseline. One part was emitted, plus its `.map` diagnostic. No other deferred
part files were emitted. Main SHA-256 before:
`b9ceeae07cd2a9e6486f6704de0435fa0c2cf3dce5e0ddad6ac61ffe7d35b393`;
after: `cb2b1c595470099614eec55150a7bddb1175de01d348c06af005345c914d17aa`.
Deferred part SHA-256:
`4c8f106604cd493c981127810de7ceee342b8a3ce19cfab7bd61bafbd51901df`.

### Static first-load set, same B8 inventory

Both AssetManifest representations, FontManifest, the exam catalog, web manifest,
favicon, HTML/bootstrap, SQLite/Drift worker, all Geist/icon/KaTeX fonts, main JS,
and the selected CanvasKit pair. Other renderer variants, source maps, native seed,
and deferred parts are excluded. Dynamic Firebase/auth/App Check scripts, server
responses, headers and cache behavior remain unmeasured.

| Group | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| HTML + bootstrap | 11,475 | 4,591 | 11,475 | 4,589 |
| Main JS | 6,828,259 | 1,926,780 | 6,705,270 | 1,889,609 |
| Chromium CanvasKit pair | 5,846,998 | 2,209,125 | 5,846,998 | 2,209,125 |
| SQLite + Drift worker | 1,176,595 | 494,090 | 1,176,595 | 494,090 |
| Geist, four weights | 510,404 | 241,178 | 510,404 | 241,178 |
| Phosphor + Material icons | 22,924 | 10,797 | 22,924 | 10,797 |
| KaTeX fonts | 640,372 | 370,050 | 640,372 | 370,050 |
| Manifests + catalog + web metadata | 18,627 | 3,883 | 18,627 | 3,883 |

| Renderer configuration | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| Chromium CanvasKit | 15,055,654 | 5,260,494 | 14,932,665 | 5,223,321 |
| Full CanvasKit | 16,524,982 | 5,977,393 | 16,401,993 | 5,940,220 |

Total static first-load savings: **122,989 raw / 37,173 gzip bytes**. The bootstrap
accounts for the extra 2 gzip bytes saved. As in B8, this is a conservative static
budget, not proof of the under-6-MB network target. The full-renderer gzip budget
leaves only 59,780 bytes for all omitted dynamic requests and overhead.

Both builds passed. Both printed the existing missing CupertinoIcons font warning.
The emitted `flutter_service_worker.js` unregisters itself on activation; it does
not contain a cache inventory for the new part. Offline delivery after a first
visit is therefore not established by this build. No service worker change was
made. Real-browser Back/retry/deferred-route behavior, phone/Safari checks, visual
acceptance, Lighthouse, actual staging first/repeat traffic and Welcome timing
remain unverified. Mock remains eager as documented above.

Full local build logs, byte/hash inventories, and the measurement script are in
`/private/tmp/staging-r1-verification/` (`web-before.log`, `web-after.log`,
`before.json`, `after.json`, `measure.py`). The table records the durable results.

## October 26: combined verification and native schema-10 rebuild

Assignment tasks 1 to 3 were executed. No merge breakage was found in this run.
Acceptance remains with the lead. The local rebuild exposes the fixed-digest test
conflict below; this run does not claim all gates pass on the rebuilt local inputs.
Initial source identity was exact HEAD `417078bf8015e50b6b78b0e5026204d680534aaf`
with empty `git status --short`. Policy was read from origin/main at
`44afc369259e599acdfdc6417d808014e578c1fc`, without fetching. The controlling
PWA plan/spec and later decision log were read from origin/main because the
candidate lacks those controlling documents. B7c/B8 evidence came from this branch.
Shared status/SSOT updates and integration remain with the lead and status-lock owner.

### Full suite and isolated flaky-test reruns

```text
$ flutter test --reporter expanded
07:48 +4877 -1: Some tests failed.

Failing tests:
  test/tool/content_package_builder_cli_test.dart: content package builder is an executable fail-closed CLI
```

Exit 1. The full suite ran before the local package rebuild. Both the seed-writer
and note-B files passed in this full run. The CLI assertion saw a native build-hook
error instead of the expected missing-key error:

```text
Expected: contains 'PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64'
Actual: ... Failed to set install names for dylib .../.dart_tool/lib/libsqlite3mc.dylib
install_name_tool: ... libsqlite3mc.dylib truncated or malformed object
(LC_SEGMENT_64 command 0 fileoff field plus filesize field extends past the end of the file)
```

All three known flaky files were then run individually, in sequence. Each exited 0:

```text
$ flutter test test/tool/content_package_builder_cli_test.dart --reporter expanded
00:04 +1: All tests passed!
$ flutter test test/tool/content_seed_writer_test.dart --reporter expanded
00:01 +2: All tests passed!
$ flutter test test/core/content/note_b_reaches_the_seed_test.dart --reporter expanded
00:03 +2: All tests passed!
```

The full-run failure is retained, not reclassified as a clean full-suite run.
Independent Dart format/layering/attribution/server checks overlapped the full run;
subprocess-based suite tests also run Dart native hooks. Flutter test/build/analyze
commands were otherwise serialized. No native-hook source or tests were changed.

### Static gates

Each listed gate exited 0:

```text
$ flutter analyze lib test tool
Analyzing 3 items...
No issues found! (ran in 8.2s)
$ dart format --output=none --set-exit-if-changed lib test tool
Formatted 1561 files (0 changed) in 4.41 seconds.
$ dart run tool/check_layering.dart
check_layering: OK
$ dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
$ server_dart/build.sh --check
generated JS is current
```

Analysis ran with the regenerated schema-10 version constant. Format/layering/
attribution/server checks ran before regeneration. The only generated source
change is the constant shown below. No generated server output was changed.

### Exact local package rebuild

Read `docs/content-key-access.md` before authorized credential access. The builder
contract is documented in E04.2 of
`docs/superpowers/plans/2026-09-07-e04-e14-content-protection-quiz-launch-release-plan.md`.
The branch CLI takes four arguments, including the generated version file and a
positive release sequence. Previous local package: schema/reader 9, sequence 2.
Rebuilt local package: schema/reader 10, sequence 3. These are local verification
artifacts, not an accepted production release. The old package and version file
were preserved in `/private/tmp/staging-r1-verification/original-seed/`.

Exact commands from the assigned worktree:

```zsh
dart run tools/build_content_export/build_content_export.dart build/staging-schema10-export.json
unsetopt XTRACE VERBOSE
export PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64="$(< /Users/aedwon/.pantas-production-keys/content-bootstrap-v1.b64)"
export PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64="$(< /Users/aedwon/.pantas-production-keys/content-signing-v1.seed.b64)"
trap 'unset PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64 PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64' EXIT
dart run tools/build_content_package/build_content_package.dart build/staging-schema10-export.json assets/seed lib/core/content/content_seed_version.dart 3
dart run tools/verify_content_package/verify_content_package.dart assets/seed/content.db assets/seed/content.manifest.json assets/seed/content.manifest.sig
```

All three commands exited 0. Export retained existing warnings that two lesson
images were dropped to meet the 900,000-byte lesson limit; no content was edited.
Package verifier output:

```text
content package verified: 8ee751ee0504bafc 1a139abae30cd58c41e419a1eb7824aa63114f2f00d348c25db3052f97ecb921
```

| Identity | Value |
|---|---|
| releaseSequence | 3 |
| contentSchemaVersion / readerSchemaMin / readerSchemaMax | 10 / 10 / 10 |
| sourceContentSha256 | `8ee751ee0504bafc3645b3e40d02239c6c2371d13930ef0d71c0c594bf738a9d` |
| contentSeedVersion | `8ee751ee0504bafc` |
| payload SHA-256 | `1a139abae30cd58c41e419a1eb7824aa63114f2f00d348c25db3052f97ecb921` |
| manifest SHA-256 | `283531edabfb0cd4a8e1e9410cbbe3bab49095fbbe98191d179718f44638884a` |
| signature SHA-256 | `21ceba5ee585aa6f1b269eeb2a0dad596ee51babe136fe9e9afd28e8e4d2a2e9` |
| export JSON SHA-256 | `d0d5f18d93e6be0d07ecd80274551c4c0119407cb567f627552baeef8f5d218a` |
| bootstrap / signing key IDs | `content-bootstrap-v1` / `content-signing-v1` |
| cipher | `pantas-sqlite3mc-content-v1` |

Encrypted payload bytes change on regeneration. Use these hashes to identify this
run, not as deterministic expected hashes for a later rebuild. No keys were printed.

### Native verification and unresolved fixed-digest test

```sh
flutter test test/core/content/bundle test/core/content/security test/core/content/content_providers_test.dart test/core/content/content_seed_version_test.dart test/tool/content_package_builder_test.dart test/tool/content_package_verifier_test.dart test/features/mock_exam/cse_blueprint_test.dart --reporter expanded
```

```text
00:05 +70 -1: Some tests failed.
Failing tests:
  test/core/content/content_seed_version_test.dart: the recorded seed version is the logical source digest prefix
Expected: '588610f4184ff762'
  Actual: '8ee751ee0504bafc'
```

Exit 1. The test pins the old package's source digest as a literal. The authorized
builder updates the generated version constant to the new source digest. The
manifest and generated constant agree; the old test pin does not. This is a stop
condition for native acceptance. The verifier left the test unchanged. The lead
must resolve the accepted-package/test-pin contract before claiming a clean final
suite. No full suite was rerun after this deterministic failure was established.

A separate temporary Flutter test loaded the actual rebuilt on-disk seed using
the production public signing-key lookup and bootstrap key. It exercised
`ensureProtectedContentInstalled` with mocked secure storage and an isolated
temporary install directory. Assertions: signature/digest validation succeeds,
fresh install succeeds, keyed open has `PRAGMA user_version = 10`, CSE blueprints
carry `unscored_items` 15 and 20, `PRAGMA integrity_check` is `ok`, and a second
installer call is idempotent. It did not use a fixture package.

```text
$ flutter test /private/tmp/staging-r1-verification/seed_smoke_test.dart --reporter expanded
00:00 +0: rebuilt local seed verifies, installs, opens schema 10, and reopens
00:00 +1: All tests passed!
```

Exit 0. Bootstrap key was loaded only into that command's scoped environment.
The smoke-test source and full log remain in the local verification directory.
Existing bundle/security/provider/builder/verifier/CSE tests contributed 70 passes.
No emulator, physical device, secure-storage hardware, or native startup UI was tested.

### Android build and environment workaround

The exact requested command first exited 1 at signing:

```text
$ flutter build apk --debug --flavor dev -t lib/main_dev.dart
Execution failed for task ':app:validateSigningDevDebug'.
> java.io.IOException: Unable to create debug keystore in /Users/aedwon/.android because it is not writable.
BUILD FAILED in 35s
Gradle task assembleDevDebug failed with exit code 1
```

Retried with a scoped writable Android user directory; no Gradle/source config edit:

```text
$ ANDROID_USER_HOME=/private/tmp/staging-r1-verification/android-user flutter build apk --debug --flavor dev -t lib/main_dev.dart
Running Gradle task 'assembleDevDebug'...                          17.0s
✓ Built build/app/outputs/flutter-apk/app-dev-debug.apk
```

Exit 0. Uses a temporary debug signer, not release signing. Both runs printed the
FSEvents stream warning. The APK includes the rebuilt schema-10 seed. This is a
build check, not a claim of device startup or entitlement/content runtime acceptance.


## October 27: resumed verification of the same candidate

This section records fresh execution of the complete lead brief. Earlier sections
remain historical evidence. HEAD stayed `417078bf8015e50b6b78b0e5026204d680534aaf`
on `web/staging-candidate-r1`. Policy was read with `git show origin/main:<file>`
at `3613e243f059de4f4ce5b6f8980c9229f59df933`: AGENTS.md, WORKFLOW.md and
SUBAGENTS.md. The controlling PWA spec, plan and later launch decision log were
read from that policy revision because this candidate lacks them. Task scope is
the explicit lead brief, including its authorized local package rebuild.

Initial status contained exactly the two evidence documents and the generated
seed-version constant. The prior diff was reviewed and retained. Its SHA-256 was
`c9b836ddabe6ab1a8508ad88fadaeea0ae11eeb0515fa8ab2ec8c047248e90ab`.
No merge breakage was found. No dependencies, visual changes, fetch, pull,
staging, commit, push or deploy were performed. No tests or handwritten production
source were changed. Only the two named evidence files were edited; the package
builder regenerated the same seed-version value already present on resumption.

### Task 1: fresh gate output

Flutter commands and Dart runtime checks ran sequentially. Actual summaries:

```text
$ flutter test --reporter expanded
09:55 +4877 -1: Some tests failed.
Failing tests:
  test/core/content/content_seed_version_test.dart: the recorded seed version is the logical source digest prefix
Expected: '588610f4184ff762'
  Actual: '8ee751ee0504bafc'

$ flutter test test/tool/content_package_builder_cli_test.dart --reporter expanded
00:04 +1: All tests passed!
$ flutter test test/tool/content_seed_writer_test.dart --reporter expanded
00:01 +2: All tests passed!
$ flutter test test/core/content/note_b_reaches_the_seed_test.dart --reporter expanded
00:03 +2: All tests passed!

$ flutter analyze lib test tool
No issues found! (ran in 8.4s)
$ dart format --output=none --set-exit-if-changed lib test tool
Formatted 1561 files (0 changed) in 1.59 seconds.
$ dart run tool/check_layering.dart
check_layering: OK
$ dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
$ server_dart/build.sh --check
generated JS is current

$ flutter build web --release -t lib/main_staging.dart
Compiling lib/main_staging.dart for the Web...                     866ms
✓ Built build/web
$ flutter build apk --debug --flavor dev -t lib/main_dev.dart
Running Gradle task 'assembleDevDebug'...                          21.7s
✓ Built build/app/outputs/flutter-apk/app-dev-debug.apk
```

Full suite exit: 1. All other commands above exited 0. All three known flaky files
passed in the full run and again separately. No dylib/build-hook failure occurred
in this run. The APK passed with the exact requested command, without the previous
run's Android user-directory override. It printed the FSEvents stream warning.
The web build and APK build used the local schema-10 generated constant.
The APK contains the rebuilt local package. This is build evidence, not a device
startup check or a production-release artifact.

### Task 2: repeatable local native package rebuild

The resumed local package was already schema 10 from October 26. The authorized
rebuild was repeated with this branch's builder after reading
`docs/content-key-access.md`, the builder source, and E04.2 of the content-protection
release plan. Exact commands were the export, scoped key loading, package build
and verification commands recorded in the October 26 section above, unchanged:

```zsh
dart run tools/build_content_export/build_content_export.dart build/staging-schema10-export.json
unsetopt XTRACE VERBOSE
export PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64="$(< /Users/aedwon/.pantas-production-keys/content-bootstrap-v1.b64)"
export PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64="$(< /Users/aedwon/.pantas-production-keys/content-signing-v1.seed.b64)"
trap 'unset PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64 PANTAS_CONTENT_SIGNING_PRIVATE_KEY_V1_B64' EXIT
dart run tools/build_content_package/build_content_package.dart build/staging-schema10-export.json assets/seed lib/core/content/content_seed_version.dart 3
dart run tools/verify_content_package/verify_content_package.dart assets/seed/content.db assets/seed/content.manifest.json assets/seed/content.manifest.sig
```

All three tool commands exited 0. Export again dropped the two oversized lesson
images named in October 26 evidence. No content was edited. Keys were scoped to
the required commands and were not printed. Release sequence 3 is a disposable
local rebuild, not a new accepted release. Fresh native installs used isolated
temporary directories. Never substitute this regenerated package for an accepted
immutable release or for an existing installed same-sequence artifact.

```text
content package verified: 8ee751ee0504bafc 7be9c689fc705b9ff04e0fb012e6421798ca11f7f110f7c72f2c8ec92567ff31
```

| Identity | October 27 value |
|---|---|
| contentSchemaVersion / readerSchemaMin / readerSchemaMax | 10 / 10 / 10 |
| releaseSequence | 3 |
| sourceContentSha256 | `8ee751ee0504bafc3645b3e40d02239c6c2371d13930ef0d71c0c594bf738a9d` |
| generated contentSeedVersion | `8ee751ee0504bafc` |
| assets/seed/content.db SHA-256 | `7be9c689fc705b9ff04e0fb012e6421798ca11f7f110f7c72f2c8ec92567ff31` |
| assets/seed/content.manifest.json SHA-256 | `ac3d1fbdf06d64148201054b732890f6c53736d1732d2ae532b18fc2bf722868` |
| assets/seed/content.manifest.sig SHA-256 | `06ac180dd74bb1e3917146c72df714189716211e95df179716facad59ac3ee56` |
| build/staging-schema10-export.json SHA-256 | `d0d5f18d93e6be0d07ecd80274551c4c0119407cb567f627552baeef8f5d218a` |
| build/app/outputs/flutter-apk/app-dev-debug.apk SHA-256 | `b97102488aa5e1bf63617f7c3a070645901a5e0fc11b779e6160aec818641f1b` |

The source digest matches October 26. Encrypted payload, manifest and signature
hashes changed because protection randomizes payload bytes. All three seed
companions remain ignored and unstaged.

Post-rebuild focused command:

```sh
flutter test test/core/content/bundle test/core/content/security test/core/content/content_providers_test.dart test/core/content/content_seed_version_test.dart test/tool/content_package_builder_test.dart test/tool/content_package_verifier_test.dart test/features/mock_exam/cse_blueprint_test.dart --reporter expanded
```

```text
00:05 +70 -1: Some tests failed.
Failing tests:
  test/core/content/content_seed_version_test.dart: the recorded seed version is the logical source digest prefix
```

Exit 1, same old digest pin. No full-suite repeat was justified after regeneration:
the generated source value and logical seed digest stayed unchanged, and the
focused checks reproduced the already recorded failure.

The previously reviewed temporary smoke-test source was rerun against the actual
rebuilt local package with the bootstrap key loaded only into the test process.
It checks the production signing-key lookup, signature/digest, fresh installation,
keyed open, schema 10, CSE unscored counts 15/20, integrity, and idempotent reopen.

```text
$ flutter test /private/tmp/staging-r1-verification/seed_smoke_test.dart --reporter expanded
00:00 +0: rebuilt local seed verifies, installs, opens schema 10, and reopens
00:00 +1: All tests passed!
```

Exit 0. Source is also preserved in the October 27 log directory.

### Unresolved acceptance

The fixed-digest test is the only observed deterministic failure. The manifest
and generated version agree with each other. The test still pins the old approved
package's digest. This is an acceptance stop condition; the lead must decide the
package/test-pin contract. No test was weakened or repinned, and no all-green
claim is made. Device startup, hardware secure storage, browser traffic, offline
deferred loading, Lighthouse, Safari/phone behavior, visual acceptance and live
staging remain unverified. Shared project STATUS/SSOT updates and acceptance remain
with the lead and status-lock owner; that status file is absent from this candidate.

Logs and identities for this run: `/private/tmp/staging-r1-oct27/`. These include
`full-test.log`, the three `*-alone.log` files, `native-tests.log`, `seed-smoke.log`,
`native-identity.json`, `package-build.log`, `package-verify.log`, `analyze.log`,
`format.log`, `layering.log`, `attribution.log`, `server.log`, `web-requested.log`,
`apk.log`, `initial.patch`, and the measurement logs and inventories below.


## October 27: repeated B7c measurement, exact before and after sources

The whole lead brief was repeated on resumption. Policy read from origin/main:
`3613e243f059de4f4ce5b6f8980c9229f59df933`. Source comparison remains before
`9d3141a5` and after `417078bf8015e50b6b78b0e5026204d680534aaf`.
Flutter 3.44.6 / Dart 3.12.2 and the engine revision match October 26.
The existing evidence edits were reviewed and kept as historical results.
This section records fresh measurements; it supersedes their byte totals for
this run only. No browser traffic measurement is claimed.

B8 method was reused: each selected file's raw bytes and Python
`gzip.compress(data, compresslevel=9, mtime=0)` bytes. The static inventory includes
HTML/bootstrap, main JS, both AssetManifest representations, FontManifest,
exam catalog, web manifest/favicon, SQLite/Drift worker, all Geist/icon/KaTeX fonts,
and one CanvasKit pair. Source maps, other renderer variants, native seed,
and deferred parts are excluded from first load. Direct deferred-route entry
adds its part. Dynamic scripts, server responses, headers and cache behavior
remain excluded and unmeasured.

The assigned branch was never switched. Exact comparison builds:

```sh
# Candidate: preserve the rebuilt local constant, use the committed source for comparison.
cp lib/core/content/content_seed_version.dart /private/tmp/staging-r1-oct27/schema10-content_seed_version.dart
git show HEAD:lib/core/content/content_seed_version.dart > lib/core/content/content_seed_version.dart
flutter build web --release -t lib/main_staging.dart --source-maps
cp /private/tmp/staging-r1-oct27/schema10-content_seed_version.dart lib/core/content/content_seed_version.dart
python3 /private/tmp/staging-r1-oct27/measure.py build/web /private/tmp/staging-r1-oct27/after.json

git worktree add --detach /private/tmp/pantas-b7c-oct27-before 9d3141a5
# In the temporary baseline worktree, supply ignored generated outputs and seed companions.
flutter pub get --offline
dart run build_runner build --delete-conflicting-outputs
flutter build web --release -t lib/main_staging.dart --source-maps
# From the assigned worktree:
python3 /private/tmp/staging-r1-oct27/measure.py /private/tmp/pantas-b7c-oct27-before/build/web /private/tmp/staging-r1-oct27/before.json
git -C /private/tmp/pantas-b7c-oct27-before status --short
git -C /private/tmp/pantas-b7c-oct27-before diff --exit-code
git worktree remove /private/tmp/pantas-b7c-oct27-before
```

Actual preparation created the baseline worktree before the candidate comparison
build. Candidate measurement preceded baseline measurement. Ignored `.g.dart`,
`.freezed.dart`, localization outputs and seed companions were copied for setup.
Baseline code generation ran against its own source. No dependencies were added.
Both comparison builds used the committed `588610f4184ff762` version constant.
A preparatory command briefly copied the rebuilt constant into the baseline;
it was restored from baseline HEAD before code generation or compilation.
An initial measurement invocation pointed at the unbuilt baseline and produced
an empty inventory; it was discarded and rerun against the candidate output.
Neither mistake affects the recorded inventories. The assigned candidate's local
schema-10 constant was restored. Baseline status/diff were clean before successful
worktree removal; no force removal was used.

```text
# Candidate comparison build, exit 0
Compiling lib/main_staging.dart for the Web...                     32.8s
✓ Built build/web
# Baseline comparison build, exit 0
Compiling lib/main_staging.dart for the Web...                     30.9s
✓ Built build/web
```

Both full compilations printed the existing missing CupertinoIcons font warning.
No font changes were made.

| JavaScript payload | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| `main.dart.js` | 6,828,259 | 1,926,780 | 6,705,270 | 1,889,609 |
| `main.dart.js_1.part.js` | absent | absent | 135,941 | 43,133 |
| Main plus all deferred parts | 6,828,259 | 1,926,780 | 6,841,211 | 1,932,742 |

Main saves **122,989 raw / 37,171 gzip bytes**. Loading the deferred part later
makes total compiled JS **12,952 raw / 5,962 gzip bytes larger** than baseline.
The candidate emits exactly one deferred part plus its diagnostic `.map`.
The baseline emits no deferred parts. Main and part hashes match October 26:

- Before main: `b9ceeae07cd2a9e6486f6704de0435fa0c2cf3dce5e0ddad6ac61ffe7d35b393`.
- After main: `cb2b1c595470099614eec55150a7bddb1175de01d348c06af005345c914d17aa`.
- After part: `4c8f106604cd493c981127810de7ceee342b8a3ce19cfab7bd61bafbd51901df`.

| Static first-load group | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| HTML + bootstrap | 11,474 | 4,590 | 11,475 | 4,592 |
| Main JS | 6,828,259 | 1,926,780 | 6,705,270 | 1,889,609 |
| Chromium CanvasKit pair | 5,846,998 | 2,209,125 | 5,846,998 | 2,209,125 |
| SQLite + Drift worker | 1,176,595 | 494,090 | 1,176,595 | 494,090 |
| Geist, four weights | 510,404 | 241,178 | 510,404 | 241,178 |
| Phosphor + Material icons | 22,924 | 10,797 | 22,924 | 10,797 |
| KaTeX fonts | 640,372 | 370,050 | 640,372 | 370,050 |
| Manifests + catalog + web metadata | 18,627 | 3,883 | 18,627 | 3,883 |

| Renderer configuration | Before raw | Before gzip | After raw | After gzip |
|---|---:|---:|---:|---:|
| Chromium CanvasKit | 15,055,653 | 5,260,493 | 14,932,665 | 5,223,324 |
| Full CanvasKit | 16,524,981 | 5,977,392 | 16,401,993 | 5,940,223 |

Static first-load savings: **122,988 raw / 37,169 gzip bytes**. Bootstrap output
accounts for the difference from main-JS savings and the small difference from
October 26 static totals. The full-renderer gzip budget leaves **59,777 bytes**
under decimal 6 MB before omitted requests and overhead. This does not establish
the under-6-MB transferred target. Source maps remain diagnostics only.

Mock remains eager. The generated service worker unregisters itself; deferred
chunk offline delivery remains unverified. Actual staging first/repeat traffic,
Welcome timing, Lighthouse, phone/Safari behavior, browser Back/retry and human
visual acceptance remain unverified. No deploy or UI automation was performed.
Fresh measurement inputs, file hashes, script and build logs are preserved in
`/private/tmp/staging-r1-oct27/` as `before.json`, `after.json`, `measure.py`,
`before-size.log`, `after-size.log`, `web-before.log`, `web-after.log`,
`before-pubget.log` and `before-codegen.log`.


Final artifact and workspace checks:

```text
APK: all three seed companion bytes match rebuilt local package
APK: schema 10 confirmed
check_no_ai_attribution: OK
```

The APK package companions were compared byte-for-byte by SHA-256 with the local
rebuilt assets. `git diff --check` exited 0. Final status contains only the same
three files reported on resumption: this evidence file, B7c-deferred-libraries.md,
and content_seed_version.dart. The three seed companions and dev Google services
configuration were confirmed ignored. No staged changes exist. The temporary
baseline worktree was removed. Local `build/web` is the exact-source comparison
build; the separately logged requested web build used the rebuilt local constant.
