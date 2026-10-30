# B8 size cuts and measurements (r1)

Base: `web/staging-candidate-r1` 3e89ec10, worktree `web/b8-size-r1`. Flutter release web build, entry `lib/main_staging.dart`, `--source-maps --dump-info`. Policy read from `origin/main`. Measured statically from `build/web` (no browser, no Lighthouse, no deployed traffic). Earlier B8 work (native seed package excluded from web through pubspec `platforms`, icon tree shaking, CDN versus self-host decision, WASM probe) is in `B8-size.md` and is not repeated here.

## Method

First load is the file set the entry page and Flutter loader fetch on a Chromium browser: index, bootstrap, `main.dart.js`, the Chromium CanvasKit pair (served from the gstatic CDN by default; the same bytes are counted), `sqlite3.wasm` and the Drift worker, four Geist weights, icon fonts, manifests and the exam catalog, shaders. Deferred parts, KaTeX fonts, `NOTICES` and unused renderer variants are excluded. Gzip level 9, Brotli quality 11, each file compressed alone. Bytes.

## Before (3e89ec10)

| Group | Raw | Gzip | Brotli |
|---|---:|---:|---:|
| index, bootstrap, manifest, icon | 29,010 | 15,022 | 13,610 |
| main.dart.js | 7,223,521 | 2,041,613 | 1,524,001 |
| CanvasKit (chromium js+wasm) | 5,846,998 | 2,209,125 | 1,657,046 |
| sqlite3.wasm + drift_worker.js | 1,176,595 | 494,090 | 425,255 |
| Geist x4 | 510,404 | 241,178 | 208,329 |
| Phosphor + Material icons (tree-shaken) | 25,104 | 11,933 | 11,231 |
| Manifests + catalog | 16,802 | 2,764 | 2,492 |
| Shaders | 15,627 | 3,346 | 2,992 |
| Total | 14,844,061 | 5,019,071 | 3,844,956 |

Deferred before: `main.dart.js_1.part.js` (settings, account, Pro) 159,248 raw, 50,703 gzip.

## After

| Group | Raw | Gzip | Brotli |
|---|---:|---:|---:|
| main.dart.js | 6,761,438 | 1,905,652 | 1,426,845 |
| Total first load | 14,381,978 | 4,883,110 | 3,747,798 |

All other groups unchanged. Net change: raw -462,083, gzip -135,961, Brotli -97,158. Deferred after: part 1 (settings) 159,251; part 3 (mock exam) 464,900 raw; part 2 is a 382-byte shared stub.

## Largest contributors in the first load (after)

- CanvasKit WASM + JS: 5.85 MB raw, 1.66 MB Brotli (CDN, cached across sites; self-hosting saves under 21 KB, see `B8-size.md`).
- `main.dart.js`: 6.76 MB raw. Largest named groups from the dump: Flutter framework, web engine, flutter_localizations, flutter_math_fork, Drift, programmatic figures (`core/ui/figures`, about 200 KB of source-size), Riverpod, go_router.
- SQLite WASM and Drift worker: 1.18 MB raw.
- Geist four weights: 510 KB. All four weights are used in `lib` (w400 33 uses, w500 47, w600 130, w700 105), so none can be removed without a visual change.

## Cut made

Mock exam on web is now a deferred library. Paths, parameters and behavior are unchanged; each route shows the existing loading pattern while the library loads (same mechanism as settings). Native keeps the original synchronous routes.

- The decoder for saved mock results moved out of a presentation file into the application layer, so the Home and Record code no longer pulls in mock pages. The old name is still exported from the route file for existing callers.
- The Quiz tab imports only what it uses from the mock feature (the card and the providers) instead of the whole barrel, which exported every mock page.
- Tests: path parity between web and native routes, and a web deep link to the review page that loads through the deferred route.

## Checked and left alone (no safe cut or needs a decision)

- Native seed package (`assets/seed/*`, 10 MB): already excluded from web by `platforms`; stays out.
- Phosphor and Material icon fonts are tree-shaken (13,660 and 11,444 bytes). CupertinoIcons warning is pre-existing; no font is bundled and none is needed.
- `purchases_js_hybrid_mappings.js` (781 KB) ships under `assets/packages/purchases_flutter` because the package is a dependency. It is not fetched on web (the SDK is not constructed). A package asset cannot be excluded by platform. Removing it needs `purchases_flutter` behind a conditional import (about 50 KB of source-size in `main.dart.js`); a payments-path change, not done.
- `assets/NOTICES` (1.48 MB) loads only on the licenses page.
- Programmatic figures (`core/ui/figures`) are used by question figures; deferring them changes how figures render and is not done.
- First-session screens (onboarding, Home, lesson, quiz, assessment) are not split, as the plan says.
- Service worker: this build emits Flutter's stub, so there is no precache to trim; B6 owns it.
- Not measured: transfer on a throttled phone, Welcome screen time, Lighthouse. Needs a browser.
