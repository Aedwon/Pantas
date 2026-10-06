# L3 W1: design foundation (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 9d2c0b5f.
Level 2 plan: `L2-W1-design-foundation.md`. Base: integration branch after W0 Task 5 (SHA recorded
in `evidence/W0.md`). Executor: one worker in its own worktree from that base (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews).
Inventory: `stage0`-style facts gathered Oct 6 (lead's copy summarized here). Closes carry-forward F-23.

Rules for every task: failing test first, confirm it fails for the expected reason, smallest code,
task checks, commit with a why message. No generated files. No dependency except the two below.

Migration approach (fixed here because 160+ lib files and 88 tests use the old theme API):
W1 adds the new API and turns the old `AppColors`, `AppTextStyles` and `AppDimensions` into
deprecated adapters whose values come from the new tokens, so the app compiles and every screen
already uses the new colors and fonts. Each W4 family moves its own files to the new API as it
rebuilds them. W2's close-out task deletes the adapters when no caller remains.

## Task 1. Fonts and icon package

Traceability: L2 §1 fonts, icons; W1 contract Icons.
1. Add `phosphor_flutter` (latest stable, pinned exact) to `pubspec.yaml`. Before any other step,
   check that every Phosphor name on IC_Final exists in that version (house, book-open, check-circle,
   gear-six, caret-left, caret-right, x, caret-down, arrow-up, arrows-out-simple, caret-up-down, list,
   flag, note-blank, note, check, pause, timer, clock, moon, calendar-blank, sparkle, lightbulb,
   lightning, magnifying-glass, bookmark-simple, image, pencil-simple, export, target, brain, bell,
   envelope-simple, user, chat-circle). Any missing: stop and report.
2. Add Geist (400, 500, 600, 700) and Source Serif 4 (400, 600) font files with their OFL texts under
   `assets/fonts/`; declare families `Geist` and `SourceSerif4`. Keep `SourceSans3` declared (17
   files still name it; removed in W2 close-out).
Test: `test/core/ui/theme/fonts_declared_test.dart` reads `pubspec.yaml` and asserts both families
and weights are declared and files exist.
Checks: `flutter pub get` exits 0; `flutter test test/core/ui/theme` green; `flutter analyze` no new
issues.

## Task 2. Tokens: colors, type, shapes (light and dark)

Traceability: W1 contracts Colors, Type, Shapes; DK_* and ST_Dark* boards; F-23.
Tests first: `test/core/ui/theme/pantas_colors_test.dart` asserts every README token value, light and
dark; `pantas_type_test.dart` asserts each style's size, weight, family, letter spacing and
`.tabular`; `pantas_shape_test.dart` asserts each value.
F-23: before fixing `pageTitle`, `caption` and `floatingRadius`, run `timeline.py` or read the CSS of
the boards that use them (HP_Free title, ST_Root title, a caption on QV_Answer, the tab bar and
floating bar on HP_Free and QV_Answer) and set the value each board uses; if boards differ, add the
second value as a named style (`pageTitleCompact`, `captionSmall`, `floatingRadiusLarge`).
Lead ruling, Oct 7 (W1 stop at 0512dffc): QV_Answer's disabled Check text `#B8B8BD` differs from the
README "Tertiary / disabled text" token `#AEAEB2`; disabled text uses the README token everywhere,
no board-specific token. The board's disabled control fill `#EDEDF0` is used as drawn if a README
token has that value; if none does, stop.
Implement `lib/core/ui/theme/pantas_colors.dart`, `pantas_type.dart`, `pantas_shape.dart`;
`context.colors` returns `PantasColors`; `context.type` returns `PantasType`. Adapters: old
`AppColors` fields map ink→label, inkMuted→secondaryLabel, rule→separator, ruleFaint→fill,
board→accent, boardTint→accentTint, onBoard→surface, rust→destructive, amber→pro, background and
surface same; old `AppTextStyles` map display*→largeTitle/pageTitle/sectionHero, headline*→sectionHero
or emphasized, body*→body/subhead, label*→footnote/sectionHeader, caption*→caption, mathBody→mathSerif;
mark all `@Deprecated('W1 adapter, removed in W2 close-out')`. Update `buildLightTheme`/`buildDarkTheme`
and `test/helpers/pump_app.dart` to register both the new extensions and the adapters.
Checks: new tests; `flutter test test/core/ui/theme test/helpers`; `flutter analyze` (deprecation
infos from adapter use are expected and listed in evidence, no other new issue).

## Task 3. Motion primitives

Traceability: W1 contract Motion.
Tests first: each `PantasCurves` constant equals its MOTION.md cubic; `steps(n)` produces n equal
steps; each `PantasEffects` builder shows the last frame when `MediaQuery.disableAnimations` is true.
Implement `lib/core/ui/motion/pantas_curves.dart`, `pantas_effects.dart`.
Checks: `flutter test test/core/ui/motion` green.

## Task 4. Icons

Traceability: W1 contract Icons (45 getters); S0-3.
Tests first: `PantasIcons` exposes exactly the 45 getters (reflection-free list test); no `locked`;
each own icon paints at 24 with 1.5 stroke and round ends (golden per icon, light and dark).
Implement `lib/core/ui/icons/pantas_icons.dart` and `lib/core/ui/icons/own/` (nine painters drawn
from IC_Final's SVG paths).
Checks: `flutter test test/core/ui/icons` green (every one of the 45 names resolves).

## Task 5. Dates

Traceability: W1 contract Dates; R-19 (approved format).
Tests first: `test/core/time/pantas_dates_test.dart`: `full`, `short` (this year and other years),
`withWeekday`, `heading`, `monthOnly`, `weekRange` within a month, across months and across years,
`relativeDay` (today, yesterday, older), `weekStart` is Sunday for every weekday input.
Implement `lib/core/time/pantas_dates.dart` with `intl` (already a dependency), locale `en_US`.
Existing hand-rolled formatters and Monday-based week math stay until their families replace them
(W4 plans list them).
Checks: `flutter test test/core/time/pantas_dates_test.dart` green.

## Task 6. Lesson and question text scale

Traceability: W1 §4 text size.
Tests first: `lessonTextScaleProvider` defaults to 1.0, persists a value through
`AppPreferencesRepository` (key `lesson_text_scale`), and `LessonTextScale` multiplies the phone's
`TextScaler` only inside its subtree.
Implement `lib/core/ui/theme/lesson_text_scale.dart`. W4f's slider writes the provider; W4c and W4d
wrap lesson and question bodies in `LessonTextScale`.
Checks: `flutter test test/core/ui/theme/lesson_text_scale_test.dart` green.

## Task 7. Route files and shell

Traceability: W1 contracts Shell, Routes; S0-42; G-h-1, G-h-2, G-h-6.
1. Split `lib/app/router.dart` (no behavior change): move each existing entry verbatim into
   `lib/app/routes/{onboarding,home,study,quiz,mock,settings,wrapped,states,dev}_routes.dart`
   (assessment in onboarding; lesson and ending in study; legal in settings; update-required in
   states). `router.dart` keeps the shell, redirects and `collectRoutePaths`. Test first:
   `collectRoutePaths` returns the same set before and after.
2. Shell: tabs `home`, `study`, `quiz`, `settings`; `/settings` becomes the fourth branch root (no
   back button); `/progress` branch removed from the shell; telemetry label `settings`. Floating
   pill tab bar matching the tab bar on HP_Free, QZ_Tab, ST_Map, ST_Root (run `timeline.py` on HP_Free
   for any tab motion; none if silent). Tests first: four tabs in order; re-tap pops to root (already
   true, now tested); each tab keeps its stack; Settings root has no back button.
3. Retired routes (the list in L2 §1): each becomes a redirect to its nearest living screen until
   its callers are gone (`/progress`, `/progress/how-you-work`, `/progress/your-record`, `/mock-exam`,
   `/notifications/rationale` → `/home`; `/review`, `/quiz/results/:attemptId` → `/quiz`; `/paywall`
   → `/settings/pro`; `/plan/dossier/:mockId` → `/home`). Their screens stay until their family
   deletes them. W2's close-out removes these redirects once `grep` finds no caller. Remove the
   rationale gate from the onboarding redirect and `_isProRoute`. Update
   `test/app/router_redirect_test.dart` (rationale, paywall, dossier cases) to assert the redirects.
4. `/settings/sessions`: unchanged here; W4f adds its redirect when it creates `/settings/practice`
   (avoids a dangling redirect; L2 W1 §3 amended Oct 6).
Checks: `flutter test test/app test/features/shell`.

## Task 8. AGENTS.md visual rules (draft only)

Write `docs/superpowers/plans/new-design/drafts/agents-visual-rules.md`: the README rules and tokens
in AGENTS.md style (one accent, red and gold rules, no sheets, Geist and Source Serif 4, motion
rules, copy rules). It merges to main only after Aedwon approves the text.

## Task 9. Full checks and handoff

All required checks (SUBAGENTS Part 5); paste outputs into `evidence/W1.md`. Independent review
(GPT-6 Astra audit, then the Opus lead's review; B7 as amended). Lead integrates into the integration branch.

Stop conditions (in addition to L2 §7): a board's tab bar or token value conflicts with the README:
stop and ask the lead; any Phosphor name missing; any test outside W1's files fails for a reason other
than the theme adapters.
