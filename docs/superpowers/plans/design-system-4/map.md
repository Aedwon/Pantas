# Design system 4.0.0 vs the Pantas web app: map

Policy read: origin/main 5c4d9ce53 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Code read from a detached worktree at origin/web/speed-r1 b6eb981ba. System (SYS): `design-system-4.0.0/` in the side-session notes folder. Paths below are under `lib/` unless stated.

## 1. Base branch

- Deployed to pantas-prod: `web/speed-r1` at b6eb981ba. Launch log (`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` on main, lines 2673 and 2679): Deploy 2 from 4cc4fd08c (functions, hosting), then the Study pinned-topic fix b6eb981ba (hosting only, CI 42397377279 green except the known OSV report).
- Ancestry: speed-r1 = load-speed-r1 (7367f1bf2, Deploy 1 line) + speed lanes. `web/design-system-r1` (783d9d572) forks from `web/visual-check-fixes-r1` 571eea1aa, so it lacks the Google sign-in fixes, beta gate and speed work.
- origin/main is not a usable code base. It carries policy and docs plus an old lib/ (690 lib files vs 1000 on speed-r1; no `web/`, `test/`, `tool/`, `server_dart/`, `.firebaserc`). speed-r1 is 1089 commits ahead of main; main is 741 ahead of speed-r1 (987 files, all docs/tools).
- Recommendation: create `web/design-system-4` from origin/web/speed-r1 b6eb981ba. Do not merge main; read policy with `git show origin/main:<path>`.
- Unmerged on `web/design-system-r1`: 50619b39a (Home card buttons right, main last: `features/home/presentation/widgets/home_state_card.dart` and test) and 783d9d572 (topic Practice button at right end: `topic_detail_page.dart` and test). Tested `git cherry-pick --no-commit 50619b39a 783d9d572` on b6eb981ba: applies cleanly, 4 files, no conflicts (reset afterward; nothing committed). Neither is an ancestor of speed-r1.

## 2. Theme today

Three parallel stacks in the deployed code:

| Stack | Files | Contents |
|---|---|---|
| Phone/native theme | `core/ui/theme/pantas_colors.dart` (451 lines), `pantas_type.dart` (231), `pantas_shape.dart` (12), `app_theme.dart` (142), `app/theme.dart` (5) | `PantasColors` ThemeExtension, 53 Color fields, `light`/`dark`. `PantasType` ThemeExtension, 15 styles (largeTitle, pageTitle, pageTitleCompact, sectionHero, body, rowValue, emphasized, subhead, subheadStrong, footnote, sectionHeader, caption, captionSmall, captionStrong, mathSerif), Geist. `PantasShape`: 10 constants (groupRadius 14, cardRadius 18, floatingRadius 22/24, pillRadius 99, buttonHeight 52, buttonRadius 14, rowMinHeight 44, rowInset 16, gutter 16). Read through `context.colors` / `context.type` (`AppThemeContext`, `app_theme.dart:133`). |
| Wide-web tokens | `core/ui/web/web_tokens.dart` (102), `web_layout.dart` (42), `web_layout_theme.dart` (29), `web_components.dart` (2091) | `WebTokens(brightness)` built per call by `context.webTokens`: charcoal dark overrides on `PantasColors.dark.copyWith(...)`, 13 extra color getters (accentHover, rowHover, dangerFill/Hover, strongDivider, disabledBackground/Text, figureScrim/Caption...), 9 text styles with hard-coded sizes (h1 38, h2 26, h3 20, qtext 27, big 40, sub 15, sm 13, eb 13). `WebLayoutTheme` swaps to the web theme at width >= 1024. Tiers (`web_layout.dart`): phone <600, tabletPortrait <1024, tabletLandscape <1280, desktop >=1280. |
| Motion | `core/ui/motion/pantas_curves.dart` (19 Cubics), `pantas_durations.dart` (5: tap 120, release 180, quick 160, base 240, page 320), `web_overlay_motion.dart` (drawer 450/400, dialog 420/320), `press_scale`, `pane_transition`, `view_swap`, `selection_motion`, `web_page_transitions` | The durations file says existing literals are not swept onto it. |

Components: 52 files in `core/ui/components/` plus 4 in `new_design/`; web widgets in `web/web_components.dart` (WebButton, WebCard, WebRow, WebSegmentedControl, WebAnswerOption, WebBottomBar, WebTopBar, WebBackLink, WebTextLink...); debug gallery at `/settings/_gallery` (`core/ui/gallery/component_gallery_page.dart`). Icons: `core/ui/icons/pantas_icons.dart`, `icons/own/own_icons.dart`; `assets/fonts/phosphor/Phosphor.ttf` is already bundled. Fonts: Geist, 4 weights; no Source Serif 4.

Consumption (files under lib): `context.colors` 164, `webTokens` 95, `PantasType` named in 4, `PantasShape.` 10 uses in 5 files, `Colors.white/black/red/grey/green/blue` 39. Buttons: `PantasButton(` 95 uses, `WebButton(` 89, raw Material buttons 101.

Literals under lib (grep over whole folders; script `scratchpad/build/count.sh`; Color column counts `Color(0x`, `fromRGBO`, `fromARGB`, not `Colors.x`):

| Folder | files | Color | TextStyle( | EdgeInsets.x( | Radius | fontSize: N |
|---|---|---|---|---|---|---|
| assessment | 15 | 0 | 0 | 16 | 2 | 4 |
| beta_feedback | 19 | 3 | 3 | 36 | 15 | 0 |
| guardian | 8 | 0 | 1 | 4 | 0 | 1 |
| home | 67 | 29 | 0 | 151 | 53 | 24 |
| legal | 5 | 0 | 1 | 8 | 0 | 3 |
| lesson | 42 | 13 | 1 | 111 | 21 | 17 |
| metrics | 38 | 0 | 0 | 0 | 0 | 0 |
| mock_exam | 76 | 3 | 1 | 116 | 40 | 33 |
| notifications | 22 | 0 | 0 | 1 | 0 | 0 |
| onboarding | 19 | 1 | 4 | 37 | 19 | 7 |
| paywall | 30 | 0 | 0 | 0 | 0 | 0 |
| quiz | 86 | 11 | 4 | 87 | 24 | 21 |
| review_prompt | 8 | 0 | 0 | 0 | 0 | 0 |
| roadmap | 24 | 0 | 0 | 0 | 0 | 0 |
| settings | 32 | 31 | 1 | 75 | 24 | 26 |
| shell | 3 | 2 | 0 | 11 | 17 | 0 |
| wrapped | 21 | 8 | 3 | 10 | 1 | 0 |
| **features total** | | **101** | **19** | **663** | **216** | **136** |
| core/ui | 117 | 158 | 23 | 174 | 111 | 68 |
| app | 41 | 2 | 2 | 24 | 6 | 4 |

Also in lib: 1071 `SizedBox(width/height: N)`, 305 `Duration(milliseconds:`, 45 `Cubic(` outside `pantas_curves.dart`, 27 `BoxShadow(`, 278 `withValues(alpha`/`Opacity(`. Spacing and radius are the large pools; color is concentrated in core/ui, settings and home.

## 3. Token map (SYS `tokens.json` vs Dart)

Contract (`tools/flutter_names.py`; it passes: 426 fields, 12 classes, 0 errors; full field table at `scratchpad/build/flutter_fields.md`): field = camelCase of the token name with the family prefix stripped (`space-`, `radius-`, `elev-`, `border-`, `layout-`, `size-`, `motion-`, `dur-`, `z-`, `opacity-`); a leading digit gets a letter (c, s, r, e, b, l, z, m, d, z, o); a Dart reserved word or Object member gets the class suffix. Color tokens keep their full name (`bg-page` -> `PantasColors.bgPage`). Type styles have no prefix (`web-h1` -> `PantasType.webH1`). `layout-*` flex tuples use a new `PantasFlex` type. Recipes: `PantasMotionRecipes` (12 fields from `motion.md`).

Name clash: four SYS class names already exist in the app with different fields: `PantasColors` (53 legacy fields: background, surface, label...), `PantasType` (15 legacy styles), `PantasCurves` (houseOut, slideA...), `PantasDurations` (tap, release, quick, base, page). SYS usage text maps legacy to new (for example `bg-page` = old `PantasColors.background`).

| Family (SYS class) | Tokens | Existing Dart equivalent | Gap |
|---|---|---|---|
| color (`PantasColors`) | 159: 79 primitives, 80 semantic roles, each light and dark | `PantasColors` 53 fields + `WebTokens` 13 getters. 53 of 80 roles name an existing field. 10 existing fields have no token: choiceOutline, disabledBackground, inactiveDateLabel, pendingMark, searchPlaceholder, segmentedShadow, shadow, switchThumbShadow, tertiaryLabel, transparent. | Primitives missing. 27 roles missing: surface-modal, surface-modal-hover, edge-bar, text-on-tint-secondary, icon-muted, kbd-on-fill, danger-text-hover, danger-muted, warning-tint, warning-tint-text, on-pro, switch-off, toast-action-hover, scrim, scrim-search, hero-start, hero-mid, hero-end, topic-done-end, share-end, on-hero, on-hero-secondary, chart-1..5. Many existing values change (D45 to D58, D112, D123, D124). Two palettes must become one. |
| type (`PantasType`) | 62 styles: Desktop 20, Desktop components 17, Phone 22, Math 1; families Geist and Source Serif 4 | 15 phone styles + 9 `WebTokens` styles + inline sizes in `web_components.dart` (`WebText` kinds) | 62 styles to generate; rem units; text-scale rules (D181, D190); new sizes (h1 38, h2 26, eyebrow 13, small 13, sub 15). Serif font files absent. |
| spacing (`PantasSpace`) | 17 (0,2,4,6,8,10,12,14,16,18,20,24,28,32,40,44,56) | none (`PantasShape.gutter`/`rowInset` = 16 only) | missing; 663 EdgeInsets and about 1071 SizedBox literals |
| radius (`PantasRadius`) | 9 (xs 5, sm 8, back 11, md 12, lg 14, xl 18, 2xl 22, bar 32, full) | `PantasShape` radii 14, 18, 22, 24, 99 | missing scale; 216 literals; 24 and 99 are off-scale |
| shadow (`PantasShadow`) | 10 (nav-active, segment, knob, thumb, popover, bar, toast, drawer, modal, sheet) | `PantasColors.shadow`, `segmentedShadow`, `switchThumbShadow` (colors only); 27 `BoxShadow(` literals | missing as `List<BoxShadow>` |
| border (`PantasBorder`) | 6 (hairline .5, ring 1, ring-strong 1.5, ring-selected 2, ring-current 2.5, focus 2) | none; focus ring helper `webFocusRing` in `core/ui/web/web_keyboard_focus.dart` | missing |
| layout (`PantasLayout`) | 59 (content-max 1080, sidebar 220/244, reader 680/800, modal 440/560, bp-*, flex tuples) | `readerStandardWidth` 680 and `readerFullWidthMax` 800 (`reader_full_width.dart`); `WebLayoutTier` 600/1024/1280; `webPageBottomInset`; rest inline in `web_components.dart`, `features/shell/presentation/web_shell.dart` | mostly missing; breakpoints differ (section 6) |
| size (`PantasSize`) | 55 (btn 44/50/42/36/46/52, field 48, switch 51x31, tabbar 64...) | `PantasShape.buttonHeight` 52, `rowMinHeight` 44; rest inline | mostly missing |
| easing (`PantasCurves`) | 13 | `PantasCurves` has all curves under legacy names; by value: motion-enter = riseIn, motion-move = edgeGrow (`shared`), motion-spring = popC, motion-fade = ease, motion-draw = checkDraw, motion-liquid = liquid, motion-linear = linear, motion-house = houseOut, motion-slide = slideC, motion-gauge = slideB, motion-scroll = slideA, motion-pop-b = popB, motion-burst = burst | exists; rename only. popA, shake, easeOut, easeInOut have no token. |
| duration (`PantasDurations`) | 24 (120ms to 8000ms) | 5 constants | 19 missing; hover fade 160 in code vs 150 (D93) |
| zIndex (`PantasZ`) | 8 | none (Flutter stacks by widget order) | missing, parity only |
| opacity (`PantasOpacity`) | 6 (disabled .4, hover .08, spinner-track .3, bar-ring .26, ripple .38, scroll-edge .18) | none | missing; disabled uses .45/.42 today (D89) |

## 4. Components (65 in SYS `components/`; gap = work to match the system)

Caveat: SYS Flutter sections say "reuse" `BackChevron`, `PageScaffold`, `TabHeader`, `InkTableRow` (these exist only on old main and new-design branches, not on speed-r1) and `PantasTextLink` (exists nowhere; the code has `WebTextLink`). Treat those lines as unverified.

| Component | Existing implementation (under `core/ui/` unless noted) | Gap |
|---|---|---|
| AccuracyBar | components/accuracy_bar.dart | S |
| AnswerOption | web/web_components.dart `WebAnswerOption`; components/choice_row.dart | M |
| AppShell | features/shell/presentation/web_shell.dart (`WebShellFrame`, `_DesktopShell`), app_shell.dart | L |
| Avatar | components/avatar.dart; `_SidebarAvatar` in web_shell.dart | S |
| BackLink | `WebBackLink` in web_components.dart; web/web_back_link_ring.dart | S |
| Button | components/pantas_button.dart (variants primary, secondary, tertiary, destructive, neutral); `WebButton` (`WebButtonVariant`); 101 raw Material buttons | L (merge into kind x tone, about 285 call sites) |
| Card | `WebCard`; ad hoc Containers | M |
| CardFooter | missing | S |
| Chart | figures/chart_figure.dart; `MockPastChart` (mock_results_page.dart); home performance | M |
| Checkbox | components/selection_row.dart `CheckboxRow` | S |
| Columns | ad hoc per page; components/pantas_page.dart; web/web_layout.dart | M |
| Cover | components/pantas_logo.dart | S |
| DataTable | mock_setup_page.dart `_SetupTable`; home performance table | M |
| DatePicker | components/month_first_date_picker.dart, value_wheel.dart, `WebPickerColumn`; features/onboarding/presentation/onboarding_web_calendar.dart | M |
| Dialog | components/centered_dialog.dart, button_pair.dart; `WebRootModal` | M |
| Drawer | web/web_side_overlay.dart `HomeWebOverlay`; motion/web_overlay_motion.dart | M |
| EmptyState | components/state_view.dart | S |
| ErrorState | components/state_view.dart | S |
| ExamChip | home_masthead.dart `_ExamChip`; components/week_strip.dart; exam_name_line.dart | S |
| Explanation | web/web_question.dart; components/new_design/answer_reveal.dart | M |
| Field | missing shared (16 raw TextField/TextFormField) | M |
| Figure | figures/*; components/placeholder_figure.dart | S |
| FloatingBar | components/floating_bar.dart; `WebBottomBar` | M |
| FocusHeader | `WebTopBar`, `WebCenteredTopBar` | M |
| FocusLayout | web/web_question.dart `WebQuizQuestion`; quiz pages | L |
| Gauge | components/half_ring_gauge.dart | S |
| GroupedList | components/grouped_section.dart, list_row.dart | S |
| IconButton | `WebTopBarButton`; raw IconButton | M |
| KeyHint | `WebKeyHint`; web/web_keyboard_hints.dart | S |
| LinkTile | missing shared (Home tiles ad hoc) | S |
| ListRow | components/list_row.dart; `WebRow` | M |
| Notice | components/notice_strip.dart, paused_quiz_notice.dart; `WebFullNotice` | S |
| PageHeader | web/web_page_heading.dart; `AppNavBar` in app_shell.dart | M |
| Passage | components/new_design/passage_card.dart | S |
| PhoneFrame | components/pantas_page.dart, tab_bar_visibility.dart | M (D180 large title) |
| Popover | quiz_page.dart `_Popover` (private) | M |
| ProMark | components/pro_tag.dart | S |
| ProgressBar | missing shared (2 LinearProgressIndicator uses) | S |
| ProgressRing | components/progress_ring.dart | S |
| QuestionNavigator | components/new_design/question_grid_sheet.dart; `HomeWebQuestionsSheet` | M |
| Radio | components/selection_row.dart `RadioRow` | S |
| ReaderBlock | components/reader_blocks.dart, content_renderer.dart | M |
| ReaderLayout | features/lesson/presentation/widgets/web_reader_layout.dart (1376 lines), reader_rail.dart | L |
| ReaderTopBar | features/lesson/presentation/widgets/reader_bar.dart | M |
| SearchField | components/search_field.dart | S |
| SearchOverlay | features/lesson/presentation/widgets/web_lesson_search.dart, search_results.dart | M |
| SectionHeader | ad hoc | S |
| SegmentedControl | `WebSegmentedControl`; components/segmented_switch.dart | M |
| Select | missing (`WebPickerColumn` only) | M |
| SelectableTile | missing shared (onboarding exam tiles, plan tiles) | L |
| Sheet | components/pantas_sheet.dart | S |
| SidebarNav | `WebSidebar` in web_shell.dart | M |
| Skeleton | components/skeleton.dart, skeleton_fade.dart, loading_shapes.dart | S |
| Slider | plain `Slider` in settings appearance_page.dart | S |
| Spinner | busy state of `PantasButton` | S |
| StatRow | components/score_breakdown_row.dart | S |
| Switch | components/pantas_switch.dart | S |
| TabBar | app_shell.dart; components/tab_bar_visibility.dart; `WebTabletNavigation` | M |
| TabletLayout | web/web_layout.dart; web_shell.dart | M |
| Tag | missing shared (`ProTag`, `_TodayTag` in topic_detail_page.dart) | S |
| TaskStatus | missing (ProgressRing and CheckMark exist) | S |
| TextLink | `WebTextLink` | S |
| Timer | missing shared (mock timer inline) | M |
| Toast | components/toast.dart | S |
| Tooltip | missing shared (7 raw `Tooltip(`) | S |
| WeekStrip | components/week_strip.dart | M |

Totals: L 5 (AppShell, Button, FocusLayout, ReaderLayout, SelectableTile), M 27, S 33. Missing outright: CardFooter, Field, LinkTile, ProgressBar, Select, SelectableTile, SectionHeader, Tag, TaskStatus, Timer, Tooltip (11).

## 5. Screens (router `app/router.dart`, `app/routes/*.dart`; web routes load lazily via `deferred_route.dart`)

Shell: `StatefulShellRoute.indexedStack`, 4 branches (Home, Study, Quiz, Settings); on web inside `WebRouteShell`.

| Family | Routes and screens | Main files | Size | Components needed |
|---|---|---|---|---|
| A. Foundation | tokens, theme, fonts, icons, motion, lint/check, gallery | `core/ui/theme/*`, `web_tokens.dart`, `app_theme.dart`, `motion/*` | L | all token classes, Phosphor, Source Serif 4 |
| B. Shared components | the 60 S and M components in section 4 | `core/ui/components/*`, `web/web_components.dart` | L | Button, Card, ListRow, Field, Tag, Tooltip... |
| C. Shell and nav | shell, `/beta`, `/auth/email-link`, `/update-required`, sign-in | `features/shell/presentation/*` (1189 lines), `app/web_route_shell.dart`, `beta_gate.dart`, `beta_waiting_page.dart`, `app/sign_in/` | L | AppShell, SidebarNav, TabBar, TabletLayout, PageHeader, PhoneFrame |
| D. Home | `/home`, `/plan`, `/plan/history`, `/plan/day/:date`, `/plan/week/:start`, `/performance`, `/performance/topic/:topicId`, `/record`, `/tendencies` | `features/home/presentation/*` (32 files, 12981 lines) | L | Card, LinkTile, WeekStrip, ExamChip, Notice, Drawer, DataTable, Chart, StatRow, Tag, Gauge, ProgressRing |
| E. Study and reader (includes bookmarks) | `/study`, `/lesson/:lessonId`, `/study/ending/:topicId`, search, bookmarks sheet | `features/lesson/presentation/*` (24 files, 10612 lines) | L | ReaderLayout, ReaderTopBar, ReaderBlock, SearchField, SearchOverlay, Sheet, Figure, Passage, Skeleton |
| F. Quiz | `/quiz`, `/quiz/today\|resume\|quick\|practice\|retake\|inline\|viewer\|all\|debrief\|flagged...`, session end | `features/quiz/presentation/*` (17065 lines) | L | FocusLayout, FocusHeader, AnswerOption, FloatingBar, Explanation, QuestionNavigator, Popover, SelectableTile, ProgressBar |
| G. Mock exam | `/quiz/mock/setup\|start\|resume/:id\|custom-setup`, `/mock/results/:id`, `/mock/review/:id` | `features/mock_exam/presentation/*` (35 files; `cse_finale_tracks.dart` 22.7k and `web_finale_tracks.dart` 13.5k lines are data; real UI about 13k) | L | FocusLayout, Timer, QuestionNavigator, DataTable, Chart, Gauge, Dialog, SelectableTile |
| H. Settings | `/settings`, `/settings/practice\|appearance\|exam\|exam/change\|exam/upgrade\|exam/included\|exam/transfer\|account\|account/name\|account/delete\|backup\|about\|_debug`, `/legal/:doc` | `features/settings/presentation/*` (7503 lines), `features/legal` | M | GroupedList, ListRow, Switch, Slider, SegmentedControl, Select, Dialog, Sheet, Field |
| I. Beta feedback | `/settings/beta-feedback`, `/survey`, `/sent/:id` | `features/beta_feedback/presentation/*` (3724 lines, own `fb_kit.dart`) | M | Field, Button, Notice, ListRow, Toast |
| J. Onboarding, assessment, guardian | `/onboarding`, `/onboarding/custom/name\|subjects`, `/assessment/:examId`, `.../results`, `/guardian`, `/guardian/waiting`, `/guardian/contact` | `features/onboarding/presentation/*` (4897), `features/assessment/*` (1793), `features/guardian/*` (600) | M | SelectableTile, DatePicker, Field, Button, FocusLayout, ProgressRing |
| K. Pro and paywall | `/pro`, `/settings/pro`, plan tiles, trial copy | `features/settings/presentation/pages/pro_page.dart`; `features/paywall` has no presentation folder | S to M | SelectableTile (plan tile), Tag, Button, Notice |
| L. Wrapped and misc | `/wrapped/:artifactId`, shared cards, share privacy sheet, notifications, review prompt | `features/wrapped/presentation/*` (358), `notifications`, `review_prompt` | S | Card, Sheet, Dialog, hero gradient tokens |

State-only features (no screens): metrics, roadmap. Progress and results pages live in D, F, G, J.

## 6. Contradictions (listed, not resolved)

1. Breakpoints: code starts the desktop tier and sidebar at 1280 (`core/ui/web/web_layout.dart:9`, comment in `web_shell.dart:37`); SYS D136 starts the sidebar at 1024 (compact 1024 to 1439, full from 1440, new `bp-wide`) and uses the TabBar below 1024.
2. Two palettes in code (`PantasColors` vs `WebTokens` charcoal overrides such as dark `accent` 4CC3AC, `surface` 1F1F1F); SYS has one set whose dark values differ (D50, D51, D112, D123, D124).
3. Class names: SYS Flutter handoff reuses `PantasColors`, `PantasType`, `PantasCurves`, `PantasDurations`, which already exist with other fields.
4. SYS Flutter sections name widgets that are not on the deployed base (`BackChevron`, `PageScaffold`, `TabHeader`, `InkTableRow`, `PantasTextLink`).
5. Pro color: code `pro` is `#D9A400` and dark `warningText` is the same gold (`pantas_colors.dart:165,226`); SYS D54 moves dark warning to `#F0A35A` so gold marks only Pro.
6. Radius and spacing snaps (D73, D99): checkbox 7 to 8, 42px buttons 11 to 12, explanation card 20 to 18, dialog padding 26 to 24, Material dialog radius 14 to 22; `PantasShape` has 24 and 99, off the SYS scale.
7. Hover fade 160 ms in code vs 150 (D93); disabled opacity .45/.42 vs .4 (D89); dimmed content by opacity vs color (D49).
8. SYS changes to approved phone/board layouts: answer check inside the badge, 10px stack (D86); quiz bar flag moves on phones under 400px (D71, Aedwon approved Nov 8); WeekStrip day cells 34 to 44 and legend removed (D69, D186).
9. Mock exam: D170 keeps the wide layout on phones until quiz code migrates; code serves one wide mock at all widths (open item in handover).
10. Text scaling: SYS D181/D190 want UI text to follow the OS size up to 2.0, tab labels capped at 12px, and an `osTextScaler` captured before the clamp for the reader; code has no app-level clamp and only `LessonTextScale` (`core/ui/theme/lesson_text_scale.dart`).
11. `AGENTS.md` sets no visual rules until Aedwon records them; boards win where SYS is silent; his lived use of the app overrides a board. SYS D191 says delegated rulings are final.
12. Existing tests pin legacy values (`test/core/ui/components/audit_color_tokens_test.dart`, `test/core/ui/theme/*`); they will fail when values change per SYS.

(Checked and not a conflict: overlay motion in `motion/web_overlay_motion.dart` already uses drawer 450/400 and dialog 420/320, scrims 350/300, matching D77.)

## 7. Staging deploy

How prod is built and deployed today (`docs/deploy-prod.md` steps 5 and 8; launch log lines 2564 and 2673):
- Build: `flutter build web --release -t lib/main_prod.dart --dart-define=APP_CHECK_WEB_SITE_KEY=<public reCAPTCHA Enterprise key>` plus `BETA_GATE=true` (launch log). A release build without the site key throws at startup (`core/platform/app_check.dart`). `PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64` is read in `app/bootstrap.dart:59` (key handling: `docs/content-key-access.md`). The full define set of the last deploy is not recorded in one place.
- Then `node tool/web/stamp_worker_version.mjs build/web` and `firebase deploy --only hosting:app --project pantas-prod`. Backend: `firebase deploy --only firestore:rules,firestore:indexes,storage`, then `--only functions` (predeploy `npm --prefix functions run build`, Node 22), after `tool/deploy/prod_iam_preflight.mjs`.
- `firebase.json`: hosting array with targets `site` (public/, rewrite `/wrapped/**` to `renderWrappedPage`) and `app` (build/web, SPA rewrite, immutable cache for hashed assets, must-revalidate for index, service worker, manifest, version). No `X-Robots-Tag` anywhere.
- `.firebaserc` (exists on speed-r1, not on main): staging=pantas-staging, prod=pantas-prod; hosting target `app` maps to `pantas-staging-app` (staging) and `pantas-prod` (prod).
- Functions: about 55 exports in 34 files under `functions/src`; secrets via `defineSecret`: GUARDIAN_HMAC_KEY, GUARDIAN_MAIL_API_KEY, PAYMONGO_SECRET_KEY, PAYMONGO_WEBHOOK_SECRET, REVENUECAT_SECRET_API_KEY, REVENUECAT_WEBHOOK_SECRET, SIGN_IN_CODE_KEY, TRIAL_IDENTITY_HMAC_KEY. `functions/.env.pantas-staging` holds only `BETA_PRO_UNTIL`.
- `lib/main_staging.dart` exists. `lib/firebase_options_staging.dart` already has the web app (appId 1:797279948229:web:5d863020ad5010864bcfac, authDomain pantas-staging.firebaseapp.com, created Oct 19).

Read-only Firebase CLI results (pantas-staging):
- `hosting:sites:list`: `pantas-staging` and `pantas-staging-app` (https://pantas-staging-app.web.app).
- `functions:list`: none deployed.
- `firestore:indexes`: 12 deployed vs 16 in `firestore.indexes.json`.
- Rules (Firestore and Storage): not readable here. The launch log shows rules uploaded Oct 19 and the index and functions deploys failing for billing; Blaze since Oct 31 per the handover. Rules for beta feedback and betaReward were added later, so they are not deployed.

What staging lacks:
1. Functions: deploy all; first set the secrets (PayMongo test keys only, SIGN_IN_CODE_KEY, TRIAL_IDENTITY_HMAC_KEY, plus guardian and RevenueCat if those functions deploy). Secret entry is Aedwon-only per `docs/deploy-prod.md`.
2. Firestore and Storage rules, and the 4 missing indexes.
3. A reCAPTCHA Enterprise site key and App Check registration for the staging web app, allowing `staging.pantas.study`, `pantas-staging-app.web.app`, `pantas-staging-app.firebaseapp.com`. Passed at build time only.
4. Auth: providers enabled, authorized domains (staging.pantas.study and the web.app domain), staging Web OAuth client redirect URIs. Not verifiable by CLI.
5. Seed content in staging via `tools/upload_content/upload_content.mjs --project pantas-staging` (content state unknown) and the content bootstrap key for the build.
6. Custom domain `staging.pantas.study` on `pantas-staging-app` plus Cloudflare DNS (needs the token).
7. Noindex: `firebase.json` is shared; use a staging-only config file (for example `--config firebase.staging.json`) so prod headers stay unchanged.
8. Decide BETA_GATE for the staging build (prod sets it true).

## 8. Tests and checks

- `test/`: 1034 `*_test.dart` files (app 43, core 346, features 587, tool 48, tools 8, l10n 1, performance 1). Also `integration_test/release` and Playwright browser journeys `tool/journeys/journeys.mjs` (workflow `browser-journeys.yml`).
- Goldens: yes, icons only: `matchesGoldenFile` in `test/core/ui/icons/pantas_icons_test.dart`, 18 PNGs in `test/core/ui/icons/goldens/`. No screen goldens.
- `tool/checks/run_checks.dart` runs 5 checks (ShellRoutePush, SyncMutationsTypedRead, MockBlueprintTopics, BoldStem, LessonListExamScope); each needs a failing-sample test in `test/tool/checks/`. There is no design-token check. Other gates: `tool/check_layering.dart`, `tool/check_no_ai_attribution.dart`, `tool/check_coverage.dart --min 70`.
- CI `.github/workflows/ci.yml`: static (dart format on lib and test, `flutter analyze`, layering, attribution, run_checks, gitleaks), unit and widget tests in 6 shards, coverage gate 70%, backend tests (`npm test`), release web build (`-t lib/main_dev.dart`), debug APK. Triggers: PRs to main, pushes to `web/**` except `web/staging-candidate-r1`. Also `browser-journeys.yml`, `main.yml`. The OSV report is non-blocking.
- Lint: `analysis_options.yaml` uses `very_good_analysis ^6.0.0` with strict-casts, strict-inference, strict-raw-types; `public_member_api_docs` off. custom_lint is not present. Blocking literals needs a new `tool/checks/*` check (existing pattern) or a custom_lint plugin.
- SYS ships four Python checks (`tools/build_css.py`, `contrast.py`, `flutter_names.py`, `validate.py`); CI would need Python.

## Blocking and notes

- Nothing blocks work. The base must be speed-r1, not main.
- Needs a lead ruling: how to resolve the four class-name clashes (rename the legacy fields or add the new classes in a new library and migrate).
- Staging backend setup needs Aedwon for secrets, the reCAPTCHA key, Auth console steps and the Cloudflare token.
