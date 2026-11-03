# Nov 3 change requests: code map (read-only)

Policy read from `origin/main` at 832787a5 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md; also confirmed `docs/workflow/orchestrator.md`, `docs/workflow/visual-companion.md`, `docs/pricing.md` exist there).
Code read from /Users/aedwon/Documents/Projects/Pantas-wt-vc-fixes-r1 (c39cb87e). Flutter SDK on this machine: 3.44.6.
Paths are relative to the worktree unless they start with `/`. Boards are in `/Users/aedwon/Documents/Projects/Pantas/web-design/pantas-handoff/{web,mobile}/project/`. Nothing was run, built or edited.
Confidence words: HIGH = the code plus the screenshot explain it; MEDIUM = the code explains it, not reproduced; LOW/unknown = needs reproduction.

## 0. Contradictions and traps found while mapping

1. Complexity choice. `nov3-requests.md` and HANDOFF 16 say Aedwon has not chosen. The launch log (`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` lines 2430-2438) records "hardened" for all 17, plus a question about GitHub Actions. Treat hardened as chosen (regression tests for motion and performance are in scope).
2. Item 3 leads are wrong. The handoff points at `exam_picker_screen.dart` skeletons. The bars in `02-custom-exam-skeleton.png` are widths 34%, 46% and 28% of the window, no frame, no top bar. That is exactly the default `LoadingShapes` (`lib/core/ui/components/loading_shapes.dart:23-27`), not the picker skeleton.
3. Existing test forbids item 17 for the tab bar: `test/features/shell/app_shell_test.dart:177` "selection swaps immediately because the board has no tab motion" asserts no `AnimatedBuilder` in `AppNavBar`. It must be rewritten, not just extended.
4. Existing test locks the item 14 message: `test/features/mock_exam/presentation/server_mock_route_test.dart:478` asserts that the Free-limit refusal ("Free accounts can take one mock every 30 days.") shows as "Could not load your mock." with Try Again. A fix that shows a proper Free-limit state flips this test.
5. Board versus app for Settings: board W_Settings title says "a list and its page side by side; no pushing". The app pushes a whole page per row (`settings_pane_page.dart:238-239`, `settings_home_page.dart:39-41`). That is the item 15 cause, and the board already agrees with Aedwon.
6. Boards versus Aedwon's calls (his Nov 2 rule: his calls override boards):
   - Item 4: SD_MapEmpty shows the empty Bookmarks line on purpose.
   - Item 7: RD_Real and RD_Focus draw Core Concept as the small gray eyebrow.
   - Item 9: W_Reader and RD_Contents solve "next lesson" on wide web with a Next card and the right-arrow key, not a pull.
   - Item 10: HP_Day draws the dots flush (8 px) to the exam tile.
7. HANDOFF.md says the mobile canvas is "not exported". `web-design/pantas-handoff/mobile/project/` holds 280 mobile boards and a `canvas.json`. Use them (HP_Day, ST_Map, RD_Figure, RD_Real, HE_LongTitle, DK_*).
8. Free mock window: server `functions/src/mock.ts:16` is 30 days (matches the launch-log decision). Native client `lib/features/paywall/domain/entitlement.dart:222-228` still says 14 days (`mockLimit`). It is only used on the non-web path (`mock_availability_provider.dart:87-91`), but it is a stale landmine if anyone reuses it for item 14. Older decision logs also say 14.
9. Item 8 and item 5 share a cause (see item 8): the lesson page's transition reacts to any route pushed on top of it.
10. `web/index.html` has no `viewport-fit=cover` meta, and Flutter web reports no safe-area insets. This matters for item 11 on a real iPhone (see item 11).

## 1. Shared infrastructure (answers to the specific questions)

### 1a. Where motion durations and curves live
- Curves: `lib/core/ui/motion/pantas_curves.dart` (`PantasCurves`: houseOut, riseIn, slideA/B/C, edgeGrow = the handoff's shared `cubic-bezier(.32,.72,0,1)`, popA/B/C, ease, easeOut, easeInOut, steps()).
- Effects: `lib/core/ui/motion/pantas_effects.dart` (`PantasEffects.pop/rise/gauge/checkDraw/shake/press/ring/burst/push/collapse/fade`). Duration is passed in by each caller. It respects `MediaQuery.disableAnimationsOf`. `push` = 40 px slide + fade, `rise` = 14 px.
- There is NO central duration table. About 154 literal `Duration(milliseconds:` in `lib/`. Examples that matter:
  - Reader page transition 380 ms: `lib/core/ui/reader_transition.dart:21` (`readerAdvanceDuration`).
  - Onboarding step switch 380 ms, 300 ms for welcome, riseIn curve, 40 px slide: `lib/features/onboarding/presentation/onboarding_page.dart` (AnimatedSwitcher, around lines 190-230).
  - Figure viewer 380 ms in, 280 ms out: `lib/core/ui/components/content_renderer.dart:816-865`.
  - Assessment results fade 240 ms: `lib/app/routes/onboarding_routes.dart:34-46`.
  - Web reader focus bar 420 ms in, 700 ms out, `Cubic(.32,.72,0,1)` inline: `lib/features/lesson/presentation/widgets/web_reader_layout.dart:670-680`.
  - Pull to advance 190/480 ms: `lib/features/lesson/presentation/widgets/pull_to_advance.dart:210,231`.
  - Skeleton pulse 1300 ms, shows after 300 ms: `lib/core/ui/components/skeleton.dart`.
- There is NO `pageTransitionsTheme` anywhere in `lib/`. All ordinary routes get Flutter's default. Verified in the SDK (`packages/flutter/lib/src/material/page_transitions_theme.dart:764-771`): `macOS` and `iOS` use `CupertinoPageTransitionsBuilder` (right-to-left slide of the whole page, with the old page parallaxing left), `windows`/`linux` use Zoom, `android` uses PredictiveBack. Aedwon's Brave on a Mac and iPhone Safari therefore both get the Cupertino slide. This is the single lever behind items 1, 15 and part of 17 (`lib/core/ui/theme/app_theme.dart` `_buildTheme`, or per-route `pageBuilder`).
- Only two routes override: `readerPage()` (study_routes.dart:31) and the assessment results fade.
- Boards' motion spec: HANDOFF.md "Motion" section (shared ease `cubic-bezier(.32,.72,0,1)`, reduced motion respected). Exact keyframes live in `RD_FocusMotion`, `MK_NavMotion`, `MK_PauseMotion`, `MK_Finale*`, `ST_ExamSwitchCount`, `RV_Reveal`. No board defines page, tab, row or chip motion. Item 17 is new design.

### 1b. Where scroll behavior is configured (item 13)
- Nowhere. `lib/app/app.dart:42-56` builds `MaterialApp.router` with no `scrollBehavior`. No `ScrollConfiguration`, `ScrollBehavior`, `Scrollbar` or `ScrollbarTheme` anywhere in `lib/` or `test/`.
- The default `MaterialScrollBehavior.buildScrollbar` (SDK `material/app.dart:857-876`) wraps every vertical scrollable in a `Scrollbar` when `Theme.platform` is macOS, windows or linux, and adds none on android, ios, fuchsia. That is why Aedwon sees bars in Brave on Mac and not on iPhone. "All platforms" is satisfied by one custom `ScrollBehavior` whose `buildScrollbar` returns the child, passed as `MaterialApp.router(scrollBehavior: ...)` in `app.dart`.
- Side effect to decide on: the default behavior does not let a mouse drag-scroll (`dragDevices`). Removing bars leaves mouse users with wheel and trackpad only. Aedwon was told this. A custom behavior is also the place to add mouse drag if wanted.
- `web/index.html` has no CSS scrollbar rules (Flutter web draws its own bars). No change needed there.

### 1c. Tab bar and shell layout (item 11)
- Phone: `lib/app/router.dart:104-135` builds `StatefulShellRoute.indexedStack` with `builder: AppShell`. `lib/features/shell/presentation/app_shell.dart:14-45`: `Scaffold(extendBody: true, body: navigationShell, bottomNavigationBar: wideWeb ? null : Padding(16,0,16,24) > SafeArea(top:false) > AppNavBar)`, hidden while `phoneTabBarHidden` (`tab_bar_visibility.dart`). `AppNavBar` is a pill (surface color, radius pill, two shadows). `_NavItem` (line 192+) is a plain `Container` with a color swap, no animation.
- Mechanism: `extendBody: true` makes the outer Scaffold publish a bottom `MediaQuery.padding` of about 88 px or more. That is the intended contract, tested at `test/features/shell/app_shell_test.dart:302` ("floating bar exposes occupied space to scrolling screens", expects bottom >= 88).
- Root cause (MEDIUM, from reading, not reproduced): every tab page then wraps itself in its OWN `Scaffold(body: SafeArea(...))`, and that `SafeArea` consumes the published bottom padding as a hard inset, so the scroll viewport ENDS above the bar with the page background underneath. That is the "hard line and solid band". Sites: `lib/features/home/presentation/home_tab.dart:46-47`, `lib/features/lesson/presentation/learn_tab_home.dart:174-176` (`_stateFrame`) and the data path through `PantasPage.content` (`lib/core/ui/components/pantas_page.dart:248-272`, `_ordinaryPage` line 269), plus the Quiz and Settings tab roots (not opened; check `quiz_tab_screen.dart`, `settings_home_page.dart`). A fix must stop SafeArea from eating the bottom (`SafeArea(bottom:false)`) and give each scrollable bottom padding of `MediaQuery.paddingOf(context).bottom` so content scrolls under the pill.
- Top clip in Brave Study (`11-brave-phone-study.png`): `learn_tab_home.dart` ~lines 255-330: `SearchFieldBar` + 18 px gap + `Expanded(Stack(ListView))`. The list is clipped at the top of the Expanded, so text slices under the search field. Letting content scroll under the header needs a restructure (header over list, list padded). Design decision: translucent or gradient header, not on a board.
- Bar running past the bottom with clipped labels in Brave emulation: unknown, needs reproduction. Suspects: fixed 24 px bottom padding plus `SafeArea` returning 0 because Flutter web does not receive `env(safe-area-inset-bottom)` and `web/index.html` has no `<meta name="viewport" ... viewport-fit=cover>`. Emulator viewport height versus visual viewport may also differ.
- Wide web: `WebRouteShell` (`lib/app/web_route_shell.dart`) chooses `WebShellFrame` (sidebar, `web_shell.dart:30`), `WebTabletNavigation` (`web_shell.dart:328`) or the bare child, by route (`webSidebarRoute`, `web_shell.dart:11-27`; `/lesson/*` is not a sidebar route, so lessons have no sidebar). Tablet portrait centers a 640 px column.

### 1d. Free-limit logic behind "Could not load your mock." (item 14)
- Server (authoritative on web, `mockUsesServerProvider = kIsWeb`, `lib/features/mock_exam/application/server_mock_results_providers.dart:12`): `functions/src/mock.ts:16` `FREE_MOCK_WINDOW_MS = 30 days`; `beginMock` (mock.ts:127-166) throws `HttpsError('failed-precondition', 'Free accounts can take one mock every 30 days.')` when a Free account has a submitted mock newer than 30 days (line 150-156). Other `failed-precondition` refusals in the same call: "This exam has no mock yet." (line 90) and "There are not enough questions for this mock yet." (line 110). `readMock`/`mockReader.ts:96` computes `nextEligibleAt` = last submit + 30 days. `mockReader.ts:17` `broken()` = "Saved mock results are not available." (also failed-precondition).
- Client availability: `serverMockAvailabilityProvider` (`server_mock_results_providers.dart:110-141`) and `mockAvailabilityProvider` (`mock_availability_provider.dart:21-95`) map status `cooldown` to `MockAvailabilityState.cooldown` -> `MockCardState.waiting` on the Quiz tab, and the setup route maps cooldown to `ServerMockNotOpen` (`server_mock_results_providers.dart:146-181`, shown by `mock_setup_route.dart:86-90`). Those paths treat the limit as a normal state.
- The generic message comes from `errorFor('mock', ...)` (`lib/core/error/state_patterns.dart:14-30`, "Could not load your $what."). It is called at:
  - `lib/features/mock_exam/presentation/pages/server_mock_route.dart:308-315` (web start/resume: any exception from `api.start` / `api.read` / `api.results`, including every `failed-precondition`, lands in `_loadError`, lines 118-166).
  - `lib/app/routes/quiz_routes.dart:53` (availability error on the Quiz tab) and `:76` (`lastSubmittedMockProvider` error, `lib/features/mock_exam/application/mock_panel_providers.dart:18-37`, which reads `serverMockResultProvider(lastMockId)` and fails with `broken()` when the saved result is unreadable).
  - `lib/features/mock_exam/presentation/pages/mock_start_route.dart:838` (native).
- Which one produced the screenshot: unknown, needs reproduction. The crop shows card edges at the left, which fits the Quiz tab panel (`quiz_routes.dart:53/76`) more than the full-screen start route. Capture the callable response code for `getMockAvailability`/results/`startMock` in the Network panel. The setup page already handles the Free cooldown correctly, so if Aedwon was Free on CSE Professional with a submitted mock, only the start route would show this message, and only if he reached start without setup or the state changed between the two.
- Another candidate for the local run: `tools/local/run_web_local.py:151-153` copies the CSE mock blueprint into the content root for the visual pass only. If the emulator content has too few questions, `startMock` throws "not enough questions" (mock.ts:110), which also shows as the same generic message.
- Related Nov 2 open item "Mock setup error for the Steady student on Free": local sample students seed mock attempts into the LOCAL database (`lib/core/dev/local_sample_students.dart:983`, panel plan line 139), while web reads the server's mock records. A student with local-only mock history and no server record, or the reverse, could fail `lastSubmittedMockProvider`. Unverified.

## 2. Per-item report

Legend for "Board": COVERED = an approved board shows it; OVERRIDE = a board exists but Aedwon's call changes it (his Nov 2 rule), so show a before/after; PREVIEW = no board covers the decision, build a visual companion preview first (`docs/workflow/visual-companion.md`); NONE = no UI decision.

### Item 1. Legal pages open with a full-page slide
- Files: `lib/app/routes/settings_routes_web.dart:34-60` (the `/legal/:doc` GoRoute uses `builder:`, so the default page transition applies); `lib/app/routes/settings_routes_native.dart:147-180` (what is built, three layouts); `lib/features/legal/presentation/legal_document_page.dart` (`OnboardingLegalPage`, about line 148-226, has its own `WebTopBar` with `PantasLogo` and a "Back"); `lib/app/web_route_shell.dart:33-35` (during onboarding on wide web the shell is skipped, so there is no sidebar and the whole page including the logo is the moving layer); callers `onboarding_consent_step.dart:148-201`, `about_page.dart:158-162`, `guardian_confirm_page.dart:170-172`. Router redirect lets `/legal/*` through at any time (`router.dart:72-81`).
- Likely cause (HIGH): default `CupertinoPageTransitionsBuilder` on macOS and iOS slides the whole page right to left. In onboarding the page includes the logo bar, so the logo moves. From Settings (sidebar shell) only the pane slides.
- Board: legal layout COVERED (ST_Privacy, "a plain reading page in the pane"); motion PREVIEW (no board). Consistent with the Nov 2 onboarding continuity rule (frame stays still, content moves).
- Collisions: items 5, 15, 17 (global page transition lever, `app_theme.dart` or route `pageBuilder`s); 3/2 only via the onboarding frame (no file overlap).
- Tests: `test/app/onboarding_legal_links_test.dart`, `test/app/router_redirect_test.dart`, `test/features/settings/presentation/about_page_test.dart`, `test/features/settings/presentation/web_settings_layout_test.dart`. No transition test exists for legal.
- Regression test that works in `flutter test`: unit-test the new transition builder with `AlwaysStoppedAnimation` (same pattern as `test/core/ui/reader_transition_test.dart`): at t = 0.3 and 1.0 the top bar and logo rect does not change, only content opacity changes, no horizontal offset; with `disableAnimations` the child is shown at once. Fake-time pumping (`tester.pump(Duration(...))`) gives frame samples. Pair with a source-scan test (pattern: `test/tool/settings_boundary_test.dart`) that every `/legal/:doc` route declares a pageBuilder.

### Item 2. Awkward skeleton after the custom exam
- Files: `lib/core/error/state_patterns.dart:10-12` (`loadingFor` shows `LoadingShapes`); `lib/core/ui/components/loading_shapes.dart:23-27` (default 34/46/28 percent bars, matches the screenshot); sites in onboarding: `onboarding_page.dart:150` (progress loading, no frame), `:293-302` (Reminders step, unframed, `loadingFor(AsyncLoading)` while `_finish()` runs), `onboarding_exam_date_step.dart:~170` (`!_loaded`, inside the frame).
- Cause: after the last custom step the next visible screen is the unframed Reminders/finish screen, which draws bare `LoadingShapes` at the top-left with no top bar, the opposite of the "frame stays still" rule. Same root as item 3 if the wait is long (MEDIUM).
- Board: PREVIEW only if a wait remains after fixing 3. Related boards: OB_PickerLoading (picker only), none for the finish step.
- Collisions: item 3 (same files); `loading_shapes.dart`/`state_patterns.dart` are used app-wide (item 17 if loading motion is changed).
- Tests: `test/features/onboarding/presentation/onboarding_web_completion_test.dart:65` (expects `LoadingShapes`), `onboarding_load_failure_test.dart`, `onboarding_continuous_test.dart`, `onboarding_frame_test.dart`, `test/core/ui/skeleton_layout_test.dart`.
- Regression test: widget test that after `CustomTrackSubjectsStep` completes, with a slow fake `studySettingsCaptureProvider`, the frame (top bar) stays mounted and no bare `LoadingShapes` is the only child; reuse `onboarding_frame_test.dart` harness.

### Item 3. Stuck after a custom exam (bug)
- Files: `lib/features/onboarding/presentation/onboarding_page.dart` (`_finish` line 49-85; reminders case 293-302; progress gate 148-160); `steps/custom_track_subjects_step.dart:94-135` (`_save`: creates the track, `setCompletedOnboarding(false)`, `setSelectedExamId`, invalidates `activeExamFocusProvider`, `scopedTopicsProvider`, `scopedSubjectsProvider`, then `onCompleted`); `lib/features/home/application/study_delivery.dart:42-82` (`studySettingsCaptureProvider`, `_request` at ~90-127, awaits the sync context snapshot and auth before `_finish` can complete); `lib/features/onboarding/application/onboarding_flow.dart:150-173` (`onboardingProgressProvider` awaits six reads).
- The frame is absent in the screenshot, so the state is (a) `onboarding_page.dart:150` progress still loading on a fresh `OnboardingPage`, or (b) the Reminders step stuck inside `_finish()` waiting on `studySettingsCaptureProvider()` or `publish.apply`. CSE Professional works, so a custom-only difference is likely in what `_finish` awaits for a custom track (sync projection of the new track, `lib/core/sync/custom_track_projection`).
- Root cause: unknown, needs reproduction. State this plainly. Do not fix by guessing. Use `systematic-debugging`: add temporary logging or read the Brave console and `flutter_01.log`/server log for the exact await.
- Board: NONE (bug). Collisions: item 2 (same file), item 1 only via consent step. `onboarding_page.dart` is a single-owner file for this lane.
- Tests: `onboarding_custom_back_test.dart`, `custom_track_steps_test.dart`, `onboarding_web_completion_test.dart`, `router_onboarding_completion_test.dart`, `onboarding_page_test.dart`, `onboarding_telemetry_test.dart`. There is no test that completes the custom path end to end through to `/home`.
- Regression test: widget test driving name -> subjects -> date -> days -> name with real in-memory repositories and a custom track, asserting `/home` is reached and `LoadingShapes` is gone. The failing test is the deliverable of the reproduction step.

### Item 4. Study page on wide web (empty Bookmarks, narrow topic list)
- Files: `lib/features/lesson/presentation/widgets/web_study_layout.dart`: `WebStudyMap` (214-445); map column width `300 + spare/1000` clamped 300-340 (264-270); empty Bookmarks heading plus quiet line (313-337); right pane `selected == null ? const SizedBox.shrink()` (381-383); row title `maxLines: 1, ellipsis` (466-470). Host: `lib/features/lesson/presentation/learn_tab_home.dart:204-208` returns `WebStudyLayout` on wide web. Phone equivalent `widgets/bookmarks_section.dart:~69` (same copy) if the phone should change too (scope question for Aedwon).
- Board: OVERRIDE. SD_MapEmpty (web) and ST_MapEmpty (mobile) deliberately show the empty line, with a topic already open on the right. The "nothing selected" state is on no board. Use of the full width and hiding or shrinking Bookmarks: PREVIEW.
- Collisions: item 12 (same file and same column, do together), 17 (row and selection motion), 11 only if phone bookmarks change (`learn_tab_home.dart`).
- Tests: `test/features/lesson/presentation/web_study_reader_test.dart`, `web_bookmarks_test.dart`, `bookmarks_section_test.dart`, `study_head_block_test.dart`, `test/core/ui/components/state_view_bookmark_layout_test.dart`, `study_map_page_test.dart`.
- Regression test: widget test at 1440 wide with no bookmarks and no open topic: no "BOOKMARKS" label, topic title not truncated at a 1440 and a 1100 width (`tester.getSize` plus `Text.overflow`), and the empty right pane is not blank (whatever is approved).

### Item 5. Opening a lesson is jarring
- Files: `lib/core/ui/reader_transition.dart` (whole file: `readerPage`, `ReaderAdvanceTransition`; forward entry slides the lesson in from the right by 100% of width while the old page travels 34% left and fades to 25%, 380 ms, easeOutCubic/easeInCubic); `lib/app/routes/study_routes.dart:29-44` (`/lesson/:lessonId`, `via=pull` picks `advance`); `lib/features/lesson/presentation/lesson_page.dart` (loading branches use `ReaderSkeleton` at 400 and 532; wide shell frame `build` at 559-600; `WebReaderLayout` at 1206); `lib/app/web_route_shell.dart` and `web_shell.dart:11-27` (the sidebar is dropped for `/lesson/*`, so the whole screen including the sidebar changes at once); `web_reader_layout.dart:670-680` (focus bar slides in separately, 420 ms).
- Likely causes (MEDIUM, matches Aedwon's wording; frame-by-frame capture still needed): (1) a full-screen 2000 px horizontal sweep with a fading page behind it; (2) the sidebar vanishing instantly while the page slides; (3) skeleton then content then bar all animating in sequence. The handoff asks for frame-by-frame capture; the visual-pass plan authorizes the lead's own captures.
- Board: PREVIEW. No board specifies the lesson-open entrance (RD_* boards are static; RD_FocusMotion is only the top bar).
- Collisions (high): items 8 and 9 (`reader_transition.dart`, `lesson_page.dart`), 1/15/17 (global lever), 6/9 (`web_reader_layout.dart`).
- Tests: `test/core/ui/reader_transition_test.dart` (asserts arrive-from-below for advance and from-the-side for forward; will change), `test/app/study_route_test.dart`, `lesson_page_test.dart`, `reader_boundary_test.dart`, `lesson_page_progress_test.dart`.
- Regression test: extend the `reader_transition_test.dart` pattern: sampled frames at 0, 25, 50, 75, 100 percent for the approved curve; the sidebar/frame rect stays constant (if the frame is kept); reduced-motion returns the child with no wrapper.

### Item 6. Reader full-width option (new)
- Files: `web_reader_layout.dart:435-438` (side margin math `(maxWidth - 680 - 112) / 2` clamped 120-220) and `:596` (`SizedBox(width: 680)` reading column); `lesson_page.dart:~585` (state frame also fixed 680); `lib/core/ui/components/content_renderer.dart` (figure frames size to column); persistence precedent for reading preferences: `lib/core/ui/theme/lesson_text_scale.dart` and `lib/features/settings/presentation/pages/appearance_page.dart`; reader top bar controls at `web_reader_layout.dart:~690-850`.
- Board: PREVIEW. RD_Real says "one 680px column"; the control, memory and maximum line length are new decisions (WORKFLOW: show cost and a recommendation; line length research is evidence-based per policy, not preference).
- Collisions: item 9 (same layout and `lesson_page.dart`), item 7 (typography inside the column), item 5 (bar motion).
- Tests: `web_study_reader_test.dart`, `reader_body_board_test.dart`, `lesson_text_scale_test.dart`, `reader_rail_test.dart`.
- Regression test: widget test at 1920 wide: default column 680; toggled column wider and capped; the choice survives rebuild (provider-backed prefs); the outline margin does not overlap.

### Item 7. Lesson hierarchy on wide web
- Files: `lib/core/ui/components/content_renderer.dart:186-222`: wide web renders an `h2` whose text is "core concept" with `webTokens.eb` (small gray uppercase eyebrow, `web_tokens.dart`), while phones use `sectionHero` 22 px; other wide `h2` are 24 px bold. Margin outline `web_reader_layout.dart:~455-585` derives from the h2 blocks.
- Cause (HIGH): this is the board's design (RD_Real draws it as the eyebrow). Aedwon's standard overrides.
- Board: OVERRIDE, PREVIEW with phone and wide side by side and options (as the handoff says).
- Collisions: content_renderer.dart (item 8 shares the file, different regions 733-1140); item 6 (column typography).
- Tests: `reader_body_board_test.dart`, `web_study_reader_test.dart`, `reader_content_extensions_test.dart` (assert the current eyebrow; they must change with the approved look).
- Regression test: golden-free: widget test that the Core Concept run has font size at or above N and weight at or above W on wide web and is not `webTokens.eb`; keep the existing phone assertion.

### Item 8. Figure zoom
- Files: `content_renderer.dart`: `_FigureFrame` (724-960), `_openViewer` (816-865, `PageRouteBuilder`, barrier transparent, scrim comes from the viewer widget), `_FigureViewer` (976-1140; wide `_wideViewer` 1010-1090 with a card of padding 40 inside `InteractiveViewer` and `Flexible`; phone body 1094-1135 inside `Center > InteractiveViewer(minScale 1, maxScale 5) > Transform.scale(.92..1)`); keyboard `+`/`-` `_scale` (996-1002, wide only; phone has no buttons); `figureScrim`, `figureViewerBackground` in theme/tokens.
- Wide-web scrim and shift (HIGH): the viewer is pushed on the same Navigator as the lesson page, and `ReaderAdvanceTransition` (reader_transition.dart:104-113) drives the lesson page from `secondaryAnimation` for ANY route pushed on top. It translates the lesson left by 34% and fades it to 25%. Check against the screenshot: 34% of 2000 px = 680 px, and the dark region ends at 1320 px, the lighter band on the right (the shell behind) is 680 px wide. So the "left two-thirds" is the lesson page moved 34% left, not the scrim. Fix: stop the reader transition from reacting to non-reader routes (`canTransitionFrom/To`, or use a `RawDialogRoute`/overlay for the viewer, or an `OverlayEntry`), and make the scrim full-screen.
- Cropped figure, both layouts (LOW, unknown): the figure is drawn about 2.3x (wide) and larger (phone) than its layout box, then clipped by the viewer card or viewport. There is no fit-to-contents step and no initial transform in either layout; `SvgPicture` uses contain with no width (comment at 1207-1209). Why it is oversized needs reproduction (suspects: unbounded constraints through `InteractiveViewer`/`Flexible` giving the SVG its intrinsic size larger than the card, or the viewer opening with a non-identity matrix). Also missing: pan clamping, +/- buttons on screen, double-tap, trackpad/wheel zoom on wide (the hint text says "Scroll" but only `InteractiveViewer`'s default pointer-signal handling applies, with no `scaleEnabled` tuning).
- Board: COVERED. RD_Figure (web: "scroll or + - zooms the labels, Esc closes"; mobile: "full screen, pinch to read the labels"). Aedwon's wanted behavior is the board's behavior. Close button position per board.
- Collisions: item 5 and 9 (`reader_transition.dart` secondary animation), item 7 (same file), item 17 (viewer motion).
- Tests: `test/core/ui/components/reader_content_extensions_test.dart`, `lesson_svg_test.dart`, `content_completion_test.dart`, `study_state_extensions_test.dart`, `test/features/lesson/presentation/web_study_reader_test.dart` (find `web-figure-scrim`, `Expand figure`).
- Regression test: widget test that pushes the viewer from a reader route and asserts (a) the lesson page's offset is unchanged while the viewer is on top (rect equality), (b) the figure's rendered rect, at identity transform, is fully inside the viewport at 390x844 and 1440x900 (use a figure wider than tall and one taller than wide), (c) `TransformationController` clamps scale to [1,5] and pans cannot leave the figure bounds.

### Item 9. Pull up for the next lesson on wide web (new)
- Files: `lib/features/lesson/presentation/widgets/pull_to_advance.dart` (phone only; reacts only to touch drag: `notification.dragDetails != null` at lines 387-409, 90 px threshold at 49, handoff of the lift animation 190/480 ms); `lesson_page.dart:1188-1290` (wide branch: `WebReaderLayout`, `advance()` closure at 1200-1204, `onNext`, footer `WebReaderNext`) versus `:1317-1345` (phone `PullToAdvance`); `web_reader_layout.dart:411-421` (Esc, `B`, right-arrow shortcuts), `:864-949` (`WebReaderNext` card with right-arrow hint); `reader_transition.dart` (`ReaderEntry.advance` from below); `_isAtEnd` at `lesson_page.dart:1059` (24 px tolerance).
- Cause of absence: by design; wide web was built from W_Reader/RD_Contents, which use the Next card and the right-arrow key. Mouse wheel produces `PointerScrollEvent`, no `dragDetails`, so the phone code never fires for wheel or trackpad.
- Board: OVERRIDE and PREVIEW. Needs the full UX pass Aedwon asked for: wheel over-scroll at the end with a deliberate hold or accumulated threshold, trackpad momentum guard (ignore momentum from the same gesture that reached the end), keyboard (Space/PageDown at end, right arrow already exists), the visible fallback (the Next card stays). Do not reuse the touch handlers.
- Collisions: items 5 and 8 (`reader_transition.dart`), 6 (`web_reader_layout.dart`, `lesson_page.dart`), 17.
- Tests: `test/features/lesson/presentation/pull_to_advance_test.dart`, `test/core/ui/components/pull_ring_test.dart`, `lesson_page_test.dart`, `web_study_reader_test.dart` (WebReaderNext), `reader_boundary_test.dart`.
- Regression test: widget tests with `tester.sendEventToBinding(PointerScrollEvent)` sequences: a single wheel notch at the end does nothing; a sustained over-scroll beyond threshold advances once; momentum events after the end was reached do not arm it; keyboard path; with `disableAnimations` the commit is immediate; the visible Next control still works.

### Item 10. Date strip balance
- Files: `lib/features/home/presentation/widgets/home_masthead.dart:150-190` (phone row: `Expanded(WeekStrip)`, `SizedBox(6)`, `_BridgeDots`, `SizedBox(8)`, `_ExamChip`), `_BridgeDots` 205-225 (`top: 29`, 3 px dots, 3 px gaps), `_ExamChip` 227+; `lib/core/ui/components/week_strip.dart` (seven equal-width cells; the "7" is centered inside the last cell, so there is up to half a cell of empty space before the dots). Wide web has its own `_WebWeekCard` (same file, not in the screenshot).
- Cause (HIGH): visual gap left of the dots is half a cell plus 6 px, right gap is 8 px. The board HP_Day has the same geometry (`gap: 8px`), so this is a board-faithful imbalance Aedwon wants corrected.
- Board: OVERRIDE (small). Recommend before/after screenshot for his approval, no full preview.
- Collisions: none (single owner file). Item 17 only if the strip gets motion.
- Tests: `test/features/home/presentation/widgets/home_masthead_test.dart`, `home_tab_test.dart`, `test/features/home/presentation/web/home_header_wide_test.dart`, gallery tests.
- Regression test: widget test measuring `getRect` of the last day number, the dots group and the exam tile at several widths and text scales: left and right gaps of the dots within 1 px.

### Item 11. Floating tab bar on phone web
See section 1c for the layout. Files: `app_shell.dart:14-45`, tab roots (`home_tab.dart:46`, `learn_tab_home.dart:174` and ~255-330, `pantas_page.dart:248-272`, quiz and settings roots), `web/index.html` (no `viewport-fit=cover`), possibly `lib/core/ui/web/web_layout.dart` (phone tier).
- Board: COVERED (the mobile boards draw the pill floating over content; HP_Day, ST_Map, DK_Home). Aedwon's top-clip request (content scrolls under the search field) is a small design choice: PREVIEW only for that header treatment.
- Collisions: item 17 (`app_shell.dart` tab selection motion), item 4 (phone bookmarks, only if scope grows), item 13 (`pantas_page.dart` scroll views).
- Tests: `test/features/shell/app_shell_test.dart` (302: bottom padding probe, still valid), `router_tab_bar_test.dart`, `tab_label_measurement_test.dart`, `app_nav_bar_accessibility_test.dart`, `learn_tab_home_test.dart`, `home_tab_test.dart`.
- Regression test: pump a tab page inside `AppShell` at 390x844 with a long list: the list's viewport bottom equals the screen bottom (not the bar top), the last row can scroll clear of the bar (`ensureVisible`), and the bar is not covered by an opaque `ColoredBox` of the page. Needs a real iPhone check through Aedwon for safe-area behavior.

### Item 12. Last opened card with long titles
- Files: `web_study_layout.dart:271-310` (wide: `WebCard` > `Row[Expanded(Column(eyebrow, title t.style(17 w600), topic t.style(14))), SizedBox(12), WebButton Resume]` inside a 300-340 px column; no `maxLines`); phone variant `widgets/study_head_block.dart:45` (Resume below the text, matches ST_Map).
- Cause (HIGH): the right-side button takes the width, so a long title wraps to four lines.
- Board: PREVIEW with options. W_Study draws Resume on the right with short titles. ST_Map (phone) puts a full-width button under the text. HE_LongTitle is the existing precedent (long lesson titles truncate to one line, Home). Options: button below like phone; two-line limit with ellipsis; both.
- Collisions: item 4 (same file, same column; do in one change).
- Tests: `web_study_reader_test.dart`, `study_head_block_test.dart`, `web_bookmarks_test.dart`.
- Regression test: widget test with the 56-character title and the 41-character topic in a 300 px column: card height under a fixed limit and the title line count at or below the approved limit.

### Item 13. Remove all scroll bars
See section 1b. Files: `lib/app/app.dart:42-56` (add `scrollBehavior`); nothing else configures scrolling.
- Board: NONE.
- Collisions: `app.dart` only (keep page transition changes in `app_theme.dart`/routes to avoid colliding). It is safe in parallel with everything.
- Tests: none cover scrollbars. Regression test: pump the app shell with `Theme.platform` macOS, windows and linux and assert `find.byType(Scrollbar)` finds nothing for a long `ListView` and `SingleChildScrollView`; assert the behavior object's `buildScrollbar` returns the child for all platforms; add a source-scan test that `Scrollbar(` is not used in `lib/`.

### Item 14. "Could not load your mock."
See section 1d. Files: `server_mock_route.dart:118-166,308-315`, `quiz_routes.dart:53,76`, `mock_panel_providers.dart:18-37`, `server_mock_results_providers.dart:110-181`, `mock_setup_route.dart:86-90,140+` (`_MockNotOpen`), `functions/src/mock.ts:90,110,150-156`, `functions/src/mockReader.ts:17,96`, `state_patterns.dart:14-30`.
- Cause: MEDIUM for "a Free-limit `failed-precondition` collapses into the generic message on the start path" (the existing test proves it); unknown for which call failed in the screenshot. Needs the callable's response code.
- Board: existing states are COVERED (Quiz tab waiting card, setup "not open" page, MK_Past* Free boards). A new message needs copy approval under AGENTS.md voice rules (simple English, no em dash). If the fix maps `failed-precondition` plus a cooldown to the existing waiting state, no new design.
- Collisions: none with other items (mock_exam and `quiz_routes.dart` are untouched elsewhere). Item 17 only for generic motion.
- Tests: `test/features/mock_exam/presentation/server_mock_route_test.dart` (478 locks the message), `mock_start_route_persistence_test.dart`, `test/features/mock_exam/data/server_mock_api_test.dart`, `mock_panel_states_test.dart`, `test/app/router_mock_panel_test.dart`, `functions/test/mock-paper.emulator.mjs`.
- Regression test: fake `ServerMockApi` returning `failed-precondition` with the 30-day message and a cooldown availability: expect the waiting state with the next date, not "Could not load"; a true network error still shows Try Again; a second test for "no blueprint" and "not enough questions".

### Item 15. Settings detail transition on wide web
- Files: `lib/features/settings/presentation/widgets/settings_pane_page.dart` (every destination is a full `SettingsPanePage`: heading, `SettingsNavigation` list at 141, and the detail pane at ~146-200, so the entire page is the animated layer); `:224-246` `SettingsNavigation` uses `router.push` per row (line 239); `settings_home_page.dart:39-41`; `lib/app/routes/settings_routes_web.dart` and `settings_routes_native.dart` (all `/settings/*` are separate top-level `GoRoute`s with default transitions); wide pages in `pages/*.dart` (`account_page.dart:126,246`, `pro_page.dart:701`, `exam_page.dart:159,476`, `appearance_page.dart:30,131`, `backup_page.dart:49,96`, `about_page.dart:125`, `name_page.dart:84`, `whats_included_page.dart:144`, `delete_account_page.dart:240`, `session_building_page.dart:26`).
- Cause (HIGH): each row opens a whole new page via `push`, and macOS uses the Cupertino slide, so the list, heading and pane all slide. Fix direction: keep the list frame still and swap only the detail (one wide shell with a detail slot, or `pageBuilder` with a fade/slide of the detail only).
- Board: COVERED for layout (W_Settings "a list and its page side by side; no pushing"; ST_* boards), PREVIEW for the detail motion (no board).
- Collisions: item 1 (the legal page is also a `SettingsPanePage`), 17, global transition lever. `settings_pane_page.dart` is a single-owner file for this lane; careful with nine page files only if the structure changes.
- Tests: `test/features/settings/presentation/web_settings_layout_test.dart`, `web_settings_second_pass_test.dart`, `settings_detail_pages_test.dart`, `test/app/router_settings_test.dart`, `deferred_settings_routes_test.dart`, `test/core/ui/web/web_settings_loading_test.dart`.
- Regression test: pump the settings route, push from Pro to Account, sample frames: the `SettingsNavigation` list rect and heading rect are identical in every frame; only the detail subtree's opacity or offset changes; reduced motion shows the final state; back/Esc still works.

### Item 16. Choppy frame rate on phones
- Files and facts: `tools/local/run_web_local.py:203` builds `flutter build web --profile ... -t lib/main_dev.dart` (not release; no renderer flag, so the SDK default, not verified); only one `RepaintBoundary` in `lib/` (`quiz_page.dart:199`); about 108 `Opacity`/`AnimatedOpacity`-style or `saveLayer`-prone uses (`grep Opacity(`) and one `ImageFiltered` blur (`pause_page.dart:319`); frame-timing collector exists for native emulator rehearsal: `integration_test/release/support/qlp5_performance_collector.dart` (`recordFrameTimings`) and `integration_test/release/qlp5_emulator_rehearsal_test.dart`. Heavy build-time work: `ContentRenderer` and math (`math_text.dart`, `math_support.dart`), skeleton pulse (`skeleton.dart`), the reader scroll listeners (`lesson_page.dart` ~1059 offset notifier), large `ListView(children:)` lists (learn_tab_home.dart ~330 uses a non-lazy `ListView`).
- Cause: unknown, needs measurement on a release build on the phone first (handoff step). Do not edit before a trace.
- Board: NONE. Collisions: every motion item (C and part of 11) adds frames; sequence 16's measurement before and after batch C, and keep fixes out of files owned by other lanes.
- Tests: none for performance. What `flutter test` can do: (1) rebuild budget: wrap a screen with counting builders and assert at most N rebuilds of the subtree per scroll step or per animation frame; (2) no endless tickers: `pumpAndSettle()` must finish on idle screens; (3) saveLayer budget: count `RenderOpacity` with partial alpha and `ShaderMask` nodes on Home, Study and Reader trees against a ceiling; (4) `RepaintBoundary` present around the tab bar and the animated lists; (5) a source-scan test for `ImageFilter.blur` outside an approved list. Real frame time needs `integration_test` with `traceAction` or `watchPerformance` on Chrome in `--profile` (CI feasible; thresholds only as trends), plus the DevTools trace Aedwon asked for. `flutter test` cannot measure fps.

### Item 17. Missing motion everywhere
- Files and facts: tab bar `app_shell.dart:192-260` (`_NavItem` plain `Container`, no animation) and `test/features/shell/app_shell_test.dart:177` forbidding it; wide sidebar `web_shell.dart:106+` (no animated widgets); `WebTabletNavigation` `web_shell.dart:328+`; rows `lib/core/ui/components/list_row.dart`, `selection_row.dart`, `choice_row.dart`, `segmented_switch.dart`, `pantas_switch.dart`, `settings_row.dart` (only a few use `Animated*`: counts 0 to 2 per file); chips in `exam_picker_screen.dart`; sliding between related views = the page transitions (items 1, 5, 15); shared motion tools in 1a.
- Board: PREVIEW (explicitly required by Aedwon: write the list, show a motion set, then build). HANDOFF "Motion" sets the shared ease and reduced-motion rule; onboarding continuity (frame still, content moves) is the guiding decision (launch log line 2400).
- Collisions: with everything. It also needs the durations table that does not exist yet (propose `lib/core/ui/motion/pantas_durations.dart` next to `pantas_curves.dart`, so later lanes share values).
- Tests: `test/core/ui/motion/pantas_curves_test.dart`, `pantas_effects_test.dart`, `test/core/ui/components/floating_bar_motion_override_test.dart`, `audit_progress_motion_test.dart`, `app_shell_test.dart`, `reader_transition_test.dart`, `onboarding_continuous_test.dart`.
- Regression tests: one test per approved motion: sampled-frame assertions on position, opacity and color (`tester.pump(Duration)`), each paired with `disableAnimations` giving the final state in one frame; a table test that every motion uses a `PantasCurves`/duration constant (source-scan, pattern `test/tool/*_boundary_test.dart`); `pumpAndSettle` completes (no runaway loops).

## 3. Collision map

| File or area | Items |
|---|---|
| `lib/core/ui/theme/app_theme.dart` (page transitions theme), route `pageBuilder`s | 1, 5, 15, 17 |
| `lib/core/ui/reader_transition.dart` | 5, 8 (secondary animation fix), 9, 17 |
| `lib/app/routes/study_routes.dart` | 5, 9 |
| `lib/app/routes/settings_routes_web.dart`, `settings_routes_native.dart` | 1, 15, 17 |
| `lib/features/legal/presentation/legal_document_page.dart` | 1 |
| `lib/app/web_route_shell.dart`, `lib/features/shell/presentation/web_shell.dart` | 1, 5, 17 (11 on tablet only) |
| `lib/features/lesson/presentation/lesson_page.dart` | 5, 6, 9 |
| `lib/features/lesson/presentation/widgets/web_reader_layout.dart` | 5 (bar), 6, 9, 17 |
| `lib/features/lesson/presentation/widgets/pull_to_advance.dart` | 9, 16 |
| `lib/core/ui/components/content_renderer.dart` | 7 (lines 186-222), 8 (724-1140), 6 (figure width) |
| `lib/features/lesson/presentation/widgets/web_study_layout.dart` | 4, 12, 17 |
| `lib/features/lesson/presentation/learn_tab_home.dart`, `home_tab.dart`, `pantas_page.dart` | 11 (+13 scroll views, 16) |
| `lib/features/shell/presentation/app_shell.dart` | 11, 17 |
| `lib/features/settings/presentation/widgets/settings_pane_page.dart` | 15, 17, 1 (legal page uses it) |
| `lib/features/onboarding/presentation/onboarding_page.dart`, `steps/custom_track_subjects_step.dart`, `state_patterns.dart`, `loading_shapes.dart` | 2, 3 (+17 if loading motion changes) |
| `lib/features/home/presentation/widgets/home_masthead.dart`, `week_strip.dart` | 10 only |
| `lib/app/app.dart` | 13 only |
| `lib/features/mock_exam/**`, `lib/app/routes/quiz_routes.dart`, `functions/src/mock*.ts` | 14 only |
| Every screen | 16, 17 |

## 4. Proposed batches (parallel-safe lanes)

- Lane A, bugs: item 3 then 2 (onboarding files). Reproduce first with a failing test.
- Lane B, bug: item 14 (mock_exam, quiz_routes). Reproduce which call fails first. Flip test 478 deliberately.
- Lane C, small fixes, each its own worker, no shared files: 10 (home_masthead); 13 (app.dart); 11 (shell and tab roots, but wait for 17's `app_shell.dart` decision or do 11 first and let 17 follow).
- Lane D, wide reader, serial in one worker: 8 first (it also fixes the shared `reader_transition` secondary animation), then 7 (same file), then 6, then 9 after previews. Item 5 must wait for 8 because both edit `reader_transition.dart`.
- Lane E, wide Study, one worker: 4 and 12 together after one preview (shows options for both).
- Lane F, motion foundation (after Aedwon's preview approvals, serial): durations table and page transition theme, then 1, 15, 5, then 17. Nothing else touches `app_theme.dart` or `settings_pane_page.dart` meanwhile.
- Lane G, performance 16: measure on a release phone build in parallel with everything (read-only), apply fixes only after lane F lands, to avoid blaming new motion.
- Previews needed for Aedwon before building: 1, 4, 5, 6, 7, 9, 12, 15, 17 (and 2 only if a wait remains). Board-covered or no-design: 3, 8, 10 (before/after), 11, 13, 14, 16.
