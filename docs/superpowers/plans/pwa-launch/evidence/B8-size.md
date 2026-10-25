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
