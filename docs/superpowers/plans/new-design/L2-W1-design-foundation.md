# L2 W1: design foundation

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 24ce4a98.
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W0.
Traceability rows: every row with workstream `W1`.

## 1. Purpose and scope

Give every screen one shared set of values, fonts, icons, motion, dates and the app shell, so the
screen families cannot drift from the design.

In scope:
- Color and type values for light and dark, from `docs/design/README.md` "Tokens", as one theme.
- Fonts: Geist (400, 500, 600, 700) for all UI and lesson text; Source Serif 4 for math only.
  Bundled as assets under the OFL (the app works offline; no font download).
- Icon set: Phosphor regular via the `phosphor_flutter` package (named by DECISIONS "Icons") plus
  the nine own icons redrawn at 1.5 weight: questions sheet, report a question, paused hourglass,
  day streak flame, progress couldn't load, reorder, Appearance, Backup, About.
- Motion primitives: the curves table and shared effects from `docs/design/MOTION.md`.
- App shell: floating pill tab bar with Home, Study, Quiz, Settings; each tab keeps its own stack;
  tapping the active tab returns to its root; Settings is a tab with no back button.
- Route skeleton: tab roots and redirects; W1 removes every retired route: `/progress` branch with `/progress/how-you-work` and `/progress/your-record`, `/plan/dossier/:mockId`, `/mock-exam`, `/quiz/results/:attemptId`, `/review`, `/paywall`, `/notifications/rationale`; keep `/more`
  and `/settings/subscription` redirects.
- Date formatting helpers (approved format).
- Dark mode values for the main screens (DK_* boards, ST_DarkRoot, ST_DarkPractice).
- Draft of the "Visual rules" section for `AGENTS.md`.

Out of scope: any screen's content (W4), shared components (W2), retiring Ink-named components (W2
does that as it replaces them).

Contracts consumed: W0 baseline only.

## 2. Inputs

README "Tokens", "Rules"; MOTION.md; DECISIONS "Navigation", "Icons", "Dates", "Dark mode on the
main screens", Settings dark rules; boards IC_Final, DK_Home, DK_Quiz, DK_Study, DK_Reader, DK_Miss,
DK_MockEnd, ST_DarkRoot, ST_DarkPractice, ST_Appearance; restart log decisions on dates and naming;
traceability rows S0-3 (no lock icon), S0-42, G-b-18, G-d-15, G-h-1, G-h-2, G-h-3, G-h-6.

## 3. Contracts owned

These names are fixed here. Consumers use them and may not redefine them.

| Contract | Interface |
|---|---|
| Colors | `PantasColors` (a `ThemeExtension`), fields: `background`, `surface`, `label`, `secondaryLabel`, `tertiaryLabel`, `separator`, `fill`, `chevron`, `accent`, `accentFill` (dark `#1F9C86`; light same as `accent`), `accentTint`, `destructive`, `wrongTint`, `pro`, `liquidStart`, `liquidEnd`. Values exactly as README "Tokens". Access: `context.colors`. |
| Type | `PantasType` (a `ThemeExtension`), styles: `largeTitle` 34/700, `pageTitle` 30/700, `sectionHero` 24/700, `body` 17/400, `rowValue` 17/400 secondary, `emphasized` 17/600, `subhead` 15/400, `subheadStrong` 15/600, `footnote` 13/400, `sectionHeader` 13/600 uppercase letter-spacing 0.02em, `caption` 11/500, `captionStrong` 10/600. Tabular figures available as `.tabular`. Math style `mathSerif` (Source Serif 4). Access: `context.type`. |
| Shapes and spacing | `PantasShape`: `groupRadius` 14, `cardRadius` 18, `floatingRadius` 22, `pillRadius` 99, `buttonHeight` 52, `buttonRadius` 14, `rowMinHeight` 44, `rowInset` 16, `gutter` 16. |
| Motion | `PantasCurves`: one constant per CSS curve in MOTION.md, never a near match: `houseOut` (0.3,0.9,0.3,1), `riseIn` (0.2,0.9,0.3,1), `slideA` (0.22,1,0.36,1), `slideB` (0.2,0.8,0.25,1), `slideC` (0.2,1,0.35,1), `edgeGrow` (0.32,0.72,0,1), `popA` (0.3,1.4,0.5,1), `popB` (0.3,1.5,0.5,1), `popC` (0.34,1.56,0.64,1), `checkDraw` (0.6,0,0.3,1), `shake` (0.36,0.07,0.19,0.97), `burst` (0.15,0.7,0.35,1), `liquid` (0.45,0,0.25,1), `ease`, `easeOut`, `easeInOut`, `linear`, and `steps(n)` for typing (N-25). A board curve not in this list is built as `Cubic` from the board's exact values and added here. `PantasEffects` builders for `pop`, `rise`, `gauge`, `checkDraw`, `shake`, `press`, `ring`, `burst`, `push`, `collapse`, `fade`, each taking an explicit duration (boards are the authority) and honoring `MediaQuery.disableAnimationsOf` by jumping to the last frame. |
| Icons | `PantasIcons`, exactly these 45 getters (IC_Final minus `lock`, S0-3): getting around `homeTab`, `studyTab`, `quizTab`, `settingsTab`, `back`, `next`, `close`, `counter`, `toTop`, `expandFigure`, `sort`, `contents`; questions `flag`, `report`, `questionsSheet`, `addNote`, `noted`, `check`, `pause`, `paused`, `timer`, `pendingSend`, `nextMonth`; home and study `streak`, `restDay`, `addDate`, `pro`, `progressError`, `tendencies`, `answerStreak`, `search`, `bookmark`, `reorder`, `imageFailed`, `edit`, `share`; settings `exam`, `practice`, `reminders`, `appearance`, `backup`, `feedback`, `about`, `proSettings`, `profile`. Phosphor names as on IC_Final; the nine own icons as listed in section 1. |
| Shell | `AppShell` with tabs in this order: `home`, `study`, `quiz`, `settings`. Tab roots `/home`, `/study`, `/quiz`, `/settings`. Re-tap returns to root. Tab bar motion per MOTION.md where drawn; none where silent. |
| Routes | W1 splits `lib/app/router.dart` into per-family route files `lib/app/routes/<family>_routes.dart` (onboarding, home, study, quiz, mock, settings, wrapped, states, dev), registered once in `router.dart`. W1 owns `router.dart`, the tab roots, redirects (`/more` to `/settings`, `/settings/subscription` to `/settings/pro`, update-required gate, onboarding gate) and retires the routes in section 1 (the one complete list): each retired path becomes a redirect to its nearest living screen until no caller remains, then W2's close-out removes it (amended Oct 6, level 3). W4f adds `/settings/sessions` to `/settings/practice` when it creates `/settings/practice`. It also creates the `dev` route file, which holds `/settings/_gallery` (W2 adds its screen); `/settings/_debug` stays in the `settings` file. Each W4 family edits only its own route file and deletes the screens behind its retired routes. Prefix exceptions: W4g's file also holds `/record/wrapped` and `/settings/about/shared-links`. Destinations outside the tab shell use `context.push` (AGENTS.md). |
| Dates | `PantasDates`: `full(d)` "Nov 11, 2026"; `short(d)` "Oct 17" in the current year, else `full`; `withWeekday(d)` "Sat, Oct 17"; `heading(d)` "Saturday, October 3"; `monthOnly(d)` "November 2026"; `weekRange(start)` "Sep 27 – Oct 3" (en dash between dates, as drawn); `relativeDay(d)` "Today", "Yesterday" else `short`. Weeks start Sunday everywhere (`PantasDates.weekStart`). |

## 4. Behavior

- Light, dark and Automatic follow Settings Appearance (W4f owns the screen; W1 owns the values and
  the `ThemeMode` wiring).
- Text size: W1 provides an app text scale that multiplies the phone's scale for lessons and
  questions only (ST_Appearance: "Lessons and questions use this size"). W4f owns the slider.
- Dark mode: black background, dark gray groups, brighter teal, illustrations keep a white backing.
  Screens without a dark board use the same tokens (Aedwon waived previews, Oct 5).
- One accent per screen; red only for wrong and destructive; gold only for Pro (README rule 4).
- Free and Pro: same. Placeholders: none.
- README ranges (page title 28 to 30, caption 11 to 10, floating radius 22 to 24): level 3 checks
  each value against the boards that use it and adds the second value where a board needs it.

## 5. Motion

Primitives only. Every timing comes from the board through `docs/design/tools/timeline.py`.
Reduce motion shows the last frame.

## 6. Acceptance

- Golden or widget tests that read every token and type style value against the README table.
- Tests for `PantasDates` covering this year, other years, weekday, month only, ranges across a month
  and a year, and Sunday week start.
- Shell tests: four tabs in order; re-tap pops to root; each tab keeps its stack; retired routes are
  gone; redirects work.
- Fonts render offline (assets declared; no network font loading).
- Full required checks (SUBAGENTS Part 5).
- Aedwon: visual check of the shell and tab bar in light and dark on his phones; approval of the
  AGENTS.md visual rules text before it is merged to main.

## 7. Risks and stop conditions

- Adding `phosphor_flutter` and font assets is a dependency change named by the approved design;
  no other dependency may be added.
- If a Phosphor glyph named on IC_Final does not exist in the package version, stop and report; do
  not substitute.
- If a board's color differs from the README token: stop and ask the lead (README "ask instead of
  guessing").
- The AGENTS.md section is a policy change: W1 drafts it; it merges to main only after Aedwon
  approves the text.

## 8. Files and directories

`lib/core/ui/theme/`, `lib/core/ui/motion/` (new), `lib/core/ui/icons/` (new), `lib/core/time/`
(dates), `lib/app/router.dart` (shell, roots, redirects, retirements), `lib/app/routes/` (creates
the per-family route files, then each family owns its file), `lib/features/shell/`,
`assets/fonts/`, `pubspec.yaml` (fonts and `phosphor_flutter`), matching tests. The old
`SourceSans3` font family is removed once no screen uses it (W2 confirms).

## 9. Order and parallelism

After W0. Runs in parallel with W3. One shared file: `lib/app/router.dart`; W3's router edits land after W1 integrates (Amended Oct 6 (level 3 gate review 1), L3-1). W2 starts after W1.
