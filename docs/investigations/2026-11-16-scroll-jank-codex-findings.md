# Phone-width web scroll investigation

Read-only second opinion. No repository files changed. No build run. No request sent to production or staging.

Scope: current main at /Users/aedwon/Documents/Projects/Pantas-wt-scroll-jank. Findings below are code-based suspects, not measured root causes. Approved motion must remain.

## Investigation notes

- Read AGENTS.md first. Reading workflow, process rules, DS4 motion requirements, release configuration, and long-scroll widget trees next.

- Repository revision: cc5af474b7c155fab5e1980ea5340b8294a6d590. Remote policy retrieval through shell failed because DNS was blocked. The web reader retrieved main's AGENTS.md and WORKFLOW.md. The user's read-only rule overrides policy steps that would fetch into Git or log into repository files.
- Motion constraints: docs/workflow/process-improvement.md:48-52 requires phone motion on wide web and forbids removing approved motion for performance. docs/design/MOTION.md requires exact board curves, order, overlap, and final states. DS4 spec: docs/superpowers/specs/2026-11-08-design-system-4-in-app-design.md:36-45 covers system motion and all screen families. No proposal here authorizes removing it.
- First exclusions: lib/app/no_scroll_bars.dart:9-18 only suppresses scrollbars. It does not replace physics or input devices. The repository-wide scan found no BackdropFilter. A glass navigation blur should not be assumed from appearance alone.
- Release configuration: web/flutter_bootstrap.js:16 calls the loader without renderer overrides. CI pins Flutter 3.44.6 in .github/actions/setup-app/inner/action.yml:16. The CI release web command (.github/workflows/ci.yml:374) has no --wasm flag. Inspecting the actual deploy path next.

- Important correction to an easy diagnosis: main already isolates reader offsets through ValueNotifiers (lib/features/lesson/presentation/lesson_page.dart:1090-1131). Its phone lesson body already has one RepaintBoundary at :1652. Study also uses a notifier for the pinned bar (:100-128 in learn_tab_home.dart) and RepaintBoundary per subject (study_map_entry.dart:43). Do not propose these existing protections as missing.
- Stronger reader suspect: reader_bar.dart:237-247 changes the header's actual height over the first 90 scroll pixels. The reader places that bar above Expanded(PullToAdvance(...)) in lesson_page.dart:1445-1482. This shrinks the scroll viewport while the user scrolls. A notifier avoids parent rebuilds but cannot avoid layout caused by changing height. Confidence: high that this layout work exists; medium that it is visible on the reported device. Confirm by comparing layout time over offsets 0-90 versus offsets beyond 90, in both directions.
- List granularity deserves measurement. Phone Home has one ListView item containing Today, all performance cards, and more rows (home_tab.dart:290-328). Phone Study has one item and one boundary per subject, with all topic rows and the open lesson Column underneath (learn_tab_home.dart:383-397; study_topic_section.dart:43-81, :161-176). These are not row-level lazy lists. Scroll can expose or rasterize large sections at once. This is different from small isolated tap animations.
- The legacy ReviewList looks expensive but has no caller in lib. The active quiz review route uses QuizQuestionViewer (quiz_review_page.dart:253). Exclude dead code from the causal ranking; inspecting the active list and viewer next.

- Existing performance tests explicitly do not measure frame time or GPU raster work (test/performance/frame_work_test.dart:3-10). They check zero Study row rebuilds (:357-367), zero reader paragraph paints (:391-403), and zero navigation bar paints during Study scrolling (:462-469). These are assertions in source, not tests rerun in this audit. They weaken a blanket claim that main still rebuilds everything or repaints the bar on every scroll.
- Active Quiz All Questions is QuizSessionEndPage, not the unused ReviewList. quiz_routes.dart:316-321 routes there. quiz_session_end_page.dart:294-350 places every question row in one GroupedSection inside a ListView. GroupedSection uses one clipped Column (grouped_section.dart:59-64). The active question viewer similarly wraps the passage, question, choices, and answer in one ListView child (quiz_question_viewer.dart:402-463). Those are concrete coarse scroll items.
- The renderer is CanvasKit for the documented release command. Flutter 3.44.6 local SDK source maps defaultForJs to canvaskit and defaultForWasm to skwasm (packages/flutter_tools/lib/src/web/compile.dart:206-207). No deployment command inspected enables --wasm. The installed SDK also reports Flutter 3.44.6, Dart 3.12.2. Do not mistake CanvasKit's own .wasm file for a Dart/skwasm build.
- No cross-origin isolation headers appear in firebase.json, firebase.staging.json, or tool/cloudflare-app/headers.prod. Thus merely adding --wasm would not establish threaded skwasm. The installed SDK's flutter_js/src/skwasm_loader.js:28 selects single-threaded mode unless crossOriginIsolated is true. Treat renderer migration as an experiment, not a proven fix.

## 1. Ranked suspected causes

### 1. Large scroll items still create bursts of work as content enters view

Evidence:
- Home: lib/features/home/presentation/home_tab.dart:265 and :290-328. One list item contains Today and the performance area.
- Study: lib/features/lesson/presentation/learn_tab_home.dart:346-397. Subjects are lazy items. Each subject contains every topic. The open topic contains every lesson at once: widgets/study_topic_section.dart:161-176.
- Quiz All Questions: lib/features/quiz/presentation/quiz_session_end_page.dart:266-350. Every result row belongs to one grouped list item.
- Quiz question review: lib/features/quiz/presentation/quiz_question_viewer.dart:402-463. Passage, question, choices, and explanation belong to one item.
- Reader: lib/features/lesson/presentation/lesson_page.dart:1640-1684. The whole lesson belongs to one scroll child and one repaint boundary.

Mechanism: scrolling brings new content into the viewport. Building a subject or a large result group can cost a whole frame. Text wrapping and math add work. On a narrow screen, the same content occupies more vertical space. Rasterization also has to draw the moving scene, even when Flutter reuses recorded paint commands. A repaint boundary prevents framework repaints. It does not guarantee that the browser can move one cached bitmap at no cost.

Confidence: medium. These trees are confirmed. Their contribution to dropped frames is unmeasured. Study is already lazy by subject. Calling the entire Study list non-lazy would be wrong. Reader layout may reuse its children's unchanged constraints. It does not necessarily relayout every formula on every scroll.

Confirm: record a warm local release scroll and a first downward pass. Mark subject boundaries and the first appearance of Quiz's result group. Compare build/layout bursts, raster duration, memory, and missed frames. If only the first pass stalls, construction and cache warming become stronger suspects. If repeated passes stall with little Dart work, raster cost becomes stronger.

### 2. CanvasKit's rendering path may limit full-screen scrolling on the affected browser

Evidence:
- web/flutter_bootstrap.js:16 has no renderer configuration.
- docs/deploy-prod.md:127 builds release JavaScript without --wasm.
- tool/deploy/staging_web.sh:9-11 does the same for staging.
- .github/workflows/ci.yml:374 builds release dev web with --no-web-resources-cdn, without --wasm.
- .github/actions/setup-app/inner/action.yml:16 pins Flutter 3.44.6. The installed SDK matches it. pubspec.yaml:13 only sets a minimum Flutter version.
- Flutter 3.44.6 SDK: packages/flutter_tools/lib/src/web/compile.dart:206-207 selects CanvasKit for JavaScript and skwasm for Wasm.
- tool/web/stamp_worker_version.mjs:38-50 changes build identity. It does not change the renderer.

Mechanism: this is Flutter-drawn scrolling inside a canvas. It does not use the browser's normal document scrolling pipeline. Each movement needs Flutter input handling and another rendered scene. CanvasKit competes for browser main-thread time with application work. A small ring or marker can remain smooth while a whole moving page exceeds the frame budget. A high device pixel ratio increases pixel work. Phone width alone does not establish the device pixel ratio or CPU speed.

Confidence: medium as a cross-screen explanation. High confidence about the configured build path. Low confidence that switching renderers alone fixes this complaint. The actual production artifact and active renderer were not inspected.

Confirm: compare identical local fixtures in optimized JavaScript/CanvasKit and --wasm builds. Verify which renderer actually loaded. Use the same browser, physical device, pixel ratio, and scroll gesture. Measure missed presentation frames and p95 frame intervals. A frame budget is about 16.7 ms at 60 Hz, or 8.3 ms at 120 Hz.

The pinned SDK disables Wasm by default on WebKit and Gecko. See engine/src/flutter/lib/web_ui/flutter_js/src/browser_environment.js:6-10 and src/loader.js:82-86. Adding --wasm alone therefore does not switch an ordinary iPhone Safari session to skwasm. This makes a generic "switch to Wasm" recommendation especially weak for iPhone reports.

The installed SDK also selects different CanvasKit rasterizers for Safari/Firefox and other browsers. See engine/src/flutter/lib/web_ui/lib/src/engine/canvaskit/renderer.dart:37-42. Results from desktop Chromium cannot settle iPhone Safari performance.

### 3. Reader scrolling changes layout and updates UI every offset

Evidence:
- lib/features/lesson/presentation/widgets/reader_bar.dart:231-269 calculates a title strip from offset / 90. It changes the strip's actual height and opacity.
- lib/features/lesson/presentation/lesson_page.dart:1445-1482 places the strip above the reader's Expanded viewport.
- lesson_page.dart:1468-1479 rebuilds ReaderRail for each progress update. widgets/reader_rail.dart:19-49 lays out its width and day ticks.
- Study has lighter offset work: learn_tab_home.dart:102-128 measures two global positions for its pinned bar.

Mechanism: the first 90 pixels of reader scrolling grow the header and shrink the viewport. That causes layout and changes the scroll extent while scrolling is already in progress. The progress rail updates throughout the lesson. Notifiers prevent a whole-page rebuild. They do not eliminate layout or painting in their listeners.

Confidence: medium for reader-local jank, especially near the top. Low as an explanation for Home or Quiz. Study's two coordinate conversions are a lower-priority suspect.

Confirm: compare slow drags across offsets 0-90 with equally slow drags far below 90. Count header and viewport layouts. Correlate long frames with extent changes. Trace the progress rail separately. Do not infer that the lesson body rebuilt merely because its viewport laid out.

### 4. Wheel input may look stepped even when frames are delivered on time

Evidence:
- lib/app/no_scroll_bars.dart:9-18 preserves default platform physics.
- lib/core/ui/web/web_layout.dart:16-27 changes layout by width. It does not change the input platform.
- Flutter 3.44.6 SDK: packages/flutter/lib/src/widgets/scroll_position_with_single_context.dart:210-234 applies wheel deltas directly with forcePixels.

Mechanism: a narrow desktop window can still receive desktop wheel events. Large or infrequent deltas produce visible steps. A timer-driven animation gets intermediate frames between its endpoints. These are different inputs. Clamping versus bouncing physics is not proof of dropped frames.

Confidence: conditional medium if "phone view" means desktop emulation or a narrow desktop browser. Low if this happens during real finger dragging and momentum scrolling.

Confirm: record event timestamps, delta sizes, offsets, and presentation frames together. Compare a physical phone touch drag, trackpad, and wheel. Timely frames with repeated positions followed by large jumps indicate input cadence. Long frame gaps indicate a rendering stall.

### 5. Image arrival and decoding can cause isolated reader stalls

Evidence: lib/core/ui/components/content_renderer.dart:2113-2147 loads SVG figures with placeholders. Lines :2156-2183 load raster images without an explicit decode target. The placeholder can be replaced by content with a different height. lesson_svg.dart:155-161 fetches and decodes SVG bytes.

Mechanism: first-time SVG parsing, image decoding, texture upload, or a height change can interrupt scrolling. This is plausible around figures. It does not explain persistent jank on an image-free Home or Study list. There is no evidence that every scroll offset starts another download.

Confidence: low to medium for cold figure-heavy lessons. Low as the general cause.

Confirm: compare first and repeated passes over the same figure. Correlate decoding, upload, and layout events with the stall. Repeat with local, already-loaded assets. Check whether image dimensions change the scroll extent.

## Candidates that should not lead the fix

- A glass backdrop blur is absent from these scrolling screens. The only image/mask blur uses found are mock pause and mock finale. test/performance/frame_work_test.dart:515-540 records that restriction.
- The phone tab bar has a solid system surface and a 30-pixel shadow. See app_shell.dart:107-112 and pantas_shadow.dart:99-104, :176-180. FloatingBar uses the same shadow at floating_bar.dart:99-103. These add raster work, but they do not resample scrolling content behind a blur. The existing Study test expects zero bar paints during scrolling. Measure compositing before blaming the shadow.
- GroupedSection uses ClipRRect, but it does not request antiAliasWithSaveLayer. See grouped_section.dart:59-64. Antialias clipping alone is not proof of an offscreen saveLayer.
- Study opacity settles at 1. Its search fade and pinned-bar fade are temporary. They are not permanent full-page fractional opacity. See learn_tab_home.dart:323-339 and :432-450.
- PullToAdvance calls setState during pull/settle motion. Ordinary scrolling before the end returns early. See pull_to_advance.dart:197-202 and :402-432. This could explain end-of-lesson pulling, not every scroll on every screen.
- No SliverPersistentHeader or SliverAppBar implementation was found on these paths. The reader's changing header is an ordinary Column child.
- No app-level JavaScript scroll listener or custom global scroll physics was found. Worker registration and welcome/splash code concern startup. The index viewport declaration is present at web/index.html:37.

## Why the other animations can be smooth

The animations often change one small object. The navigation marker is a local translation with a stable child: lib/core/ui/motion/selection_motion.dart:98-119. Study's entry animation has its own repaint boundary: study_map_entry.dart:43. Those designs limit framework work.

Scrolling moves a whole text-heavy scene. It also exposes new items, updates scroll-linked controls, and sometimes changes geometry. The renderer must present that scene at the input cadence. Smooth taps therefore do not rule out scroll-specific build bursts, raster limits, or uneven wheel deltas.

## 2. Proposed fixes, ranked by expected gain and risk

These are experiments for a separate writable copy. No fix was applied here. Preserve approved motion throughout.

1. **Split the largest list items where the trace shows stalls.** Expected gain: high for first-pass long lists. Risk: medium. Start with Quiz All Questions, then unusually large Study subjects. Use lazy rows or bounded sections with stable keys. Split Home at its visible card boundaries. Keep rounded group edges, separators, spacing, labels, and all content. Keep Study's 700 ms topic reveal, chevron rotation, staggered entrance, rings, and pinned-bar behavior. Lazy remounting must not replay an approved entrance every time an item returns. Preserve open topics, focus, bookmarks, and scroll position.

2. **Compare --wasm/skwasm on local builds before choosing a renderer change.** Expected gain: potentially high across screens. Risk: medium to high. First check dependency compatibility and actual renderer selection. On this pinned SDK, begin with Chromium. Safari and Firefox default to CanvasKit even with --wasm. Do not override that browser guard without a separate compatibility investigation. Keep the same widgets and every animation curve and duration. No visual change is intended. Do not force skwasm in the loader while shipping only a JavaScript build. Flutter documents the build flag in [Wasm support](https://docs.flutter.dev/platform-integration/web/wasm).

   Threaded skwasm is a separate experiment. The repository's hosting configs lack cross-origin isolation headers. The installed SDK's flutter_js/src/skwasm_loader.js:28 falls back to single-threaded operation without isolation. COOP/COEP changes require checking Google sign-in, App Check, workers, and cross-origin assets. Do not add them blindly. A Wasm build can also fall back to CanvasKit on unsupported browsers.

3. **Keep reader motion while reducing the work it drives.** Expected gain: medium near the top; smaller throughout the lesson. Risk: low for the rail, medium for header geometry. Drive the progress fill through a painter's repaint listener. Keep static day ticks outside that repaint area. Stop rebuilding the title strip after its clamped visual value stops changing. If viewport layout dominates, prototype a fixed-layout article with clipped/transformed header and content layers. Match the current visible movement, progress line, hit targets, and end detection. Do not freeze or remove the title reveal, replace it with a sudden jump, or disable pull-to-advance. A geometry redesign that changes the approved appearance needs separate approval.

   For Study, cache the open row's anchor after layout and compare offsets if coordinate measurement is measurable. Invalidate the anchor after topic expansion, resizing, or text scaling. Keep the same pinned-bar arrival and fade.

4. **If figure stalls are confirmed, stabilize and prepare their assets.** Expected gain: medium for affected lessons. Risk: low to medium. Reserve the figure's real aspect ratio while loading. Cache parsed SVGs and decoded images. Size raster decoding to displayed pixels only where the web decoder supports it. Preserve full quality in the expanded viewer, figure credits, and failure states. Keep the approved figure look and motion. Avoid precaching the entire lesson corpus.

5. **If the trace proves wheel stepping, fix only that input path.** Expected gain: high for wheel-only stepping; none for GPU stalls. Risk: medium. Evaluate frame-aligned accumulated wheel movement with prompt cancellation and correct trackpad handling. Keep real touch drag/fling behavior, keyboard scrolling, nested scrollables, and pull-to-advance. Do not apply BouncingScrollPhysics globally because the layout is narrow. That changes feel without addressing the measured cause.

6. **Only if raster evidence points there, isolate static chrome or split a large painted lesson into bounded layers.** Expected gain: uncertain. Risk: low for a measured static-layer isolation; medium for lesson sectioning. Keep the pill, its 30-pixel shadow, all rounded corners, and approved color transitions. Do not add RepaintBoundary to every widget. The main scroll viewports and several content sections already own layers. Extra layers can increase memory and compositing work. Do not remove shadows, clip corners, fades, gauges, or approved motion as a shortcut.

## 3. What a running trace still needs to determine

- Which screen, browser, OS, physical device, refresh rate, pixel ratio, and input produced the complaint.
- Whether "phone view" means a real phone, emulation, or a narrow desktop window.
- Which exact build production served. Main is not proof of the active installed build. The service worker can retain a build until its update conditions permit replacement.
- Whether the slow frames spend time in Dart/JavaScript, layout, Skia drawing, GPU/compositing, garbage collection, image work, or input delivery.
- Whether stalls happen after all entry animations settle, only on first exposure, near header thresholds, or throughout a warm fling.
- Whether real lesson and quiz sizes exceed the small regression fixtures.
- Whether skwasm compiles with all dependencies and improves this browser. No build was attempted.

Use local fixtures and local services in an isolated copy. Compare optimized release builds for the final A/B result. Use a profile copy only to attribute costs. Record browser Performance traces on Chromium and Safari's equivalent on iPhone. Capture the same settled animation and scroll gesture separately. Repeat the scroll with warm assets. Report missed frames and p95 frame intervals, not just average FPS.

The existing local FPS panel counts requestAnimationFrame callbacks, not completed Flutter raster frames. See tools/local/panel/local-fps.js:54-63. It can reveal a blocked browser loop. A high reading cannot prove smooth Flutter scrolling. The local runner builds profile mode and writes into its checkout at tools/local/run_web_local.py:208-216. It was not run against the read-only repository.

Final read-only Git status and diff output were empty. No tests, benchmarks, or builds were run. The source tests are evidence about intended protections, not fresh passing results. No production or staging request was made. Flutter's [performance guidance](https://docs.flutter.dev/perf/best-practices) supports measuring list, layout, opacity, and clipping costs. The rankings above are inferences from this app's source.

DONE
