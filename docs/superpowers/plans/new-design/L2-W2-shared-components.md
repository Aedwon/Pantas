# L2 W2: shared components

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 4478a462.
Parent: strategy B2, B4. Depends on: W1. Spec: amendment spec (approved Oct 5).
Traceability rows: every row with workstream `W2`, the cross-family patterns listed in the
traceability notes (picker D-221, notice strip and button order D-67 and D-68, Pro tag D-231 and S0-3,
loading tiers L_Rules), S0-46.

## 1. Purpose and scope

Build each element that more than one screen family uses once, with fixed interfaces and states,
so families compose screens and never restyle a shared element.

In scope: the components in section 3; retiring the Ink-named components and the six `showInkSheet`
callers plus the subject scope, custom mock wheel and other sheet call sites listed in
`stage0/gap-h-shell-states.md` "Bottom-sheet call sites" (removed by replacing them; sheets survive
only where a board draws one); the `onReorder` deprecation in the bookmarks sheet; the math
accessibility checks kept from the archive (S0-46).

Out of scope: screen layouts and copy (W4), theme values, icons and motion primitives (W1).

## 2. Inputs

README "Rules" and "Tokens"; MOTION.md shared effects; DECISIONS "Home" (rings, notices, buttons,
sheets), "Loading", "Quiz screens" (bottom bar, questions sheet, toast), "Settings" (no sheets,
switch colors), "Your performance" (accuracy bars, sort button), "Customize your own" (picker,
floating bar), "Icons"; boards L_Rules and the loading tiers, HP_Day, HP_NoDate, QV_Answer, QV_Grid,
QZS_1, QZ_Picker, DT_SortFlow, ST_Root, ST_Avatars, BM_Open.

## 3. Contracts owned

Names and states are fixed here. Each component reads only W1 tokens.

| Component | Purpose and states |
|---|---|
| `GroupedSection` | Inset grouped list with optional uppercase header and footer text; radius 14; footer explanations sit under the group, never inside rows. |
| `ListRow` | One row type with variants: `navigation` (chevron), `value` (secondary value), `switch`, `check` (checklist), `radio`, `destructive`, `inlineEditor` (opens in place below the row). Icon without tile in its own color (Settings). Titles never wrap: one line with "…". Large text: value moves under the label. |
| `PantasButton` | `primary` (52 high, radius 14, full width), `secondary` (tinted), `tertiary` (text), `destructive`. States: enabled, disabled (gray), `busy` (spinner plus short verb, the on-the-button loading tier). `ButtonPair`: stacked puts primary on top; side by side puts primary on the right. |
| `PantasSwitch` | White knob; gray track off, teal on; dark per Settings dark rules. |
| `SegmentedSwitch` | Subjects / Topics / Lessons and similar; picked segment lighter gray in dark. |
| `SortCycleButton` | One square button cycling weakest first, strongest first, A to Z with the bar glyph morph (DT_SortFlow). |
| `ProgressRing` and `CheckMark` | Empty, filling (fraction), done (ring becomes the check with `fx-pop`). Used by Today rows, topics, week strip. |
| `HalfRingGauge` | Overall accuracy and mock score: fills with `fx-gauge`, number counts up, rounded ends, teal only. Supports the mock finale's two-ball variant as an extension point W4e drives. |
| `AccuracyBar` | Quiet 5pt bar, soft teal deepening with accuracy (light at 40% and below, deeper toward 80%), no red or green. |
| `WeekStrip` | Sunday to Saturday, today centered; day marks done dot, half dot, missed plain, day off gray, today ring; tap a day. |
| `NoticeStrip` | Thin outlined strip, 52pt row, opens in place, 44x44 close, one line of detail, two 44pt actions (secondary plus tertiary, never solid); folds away when resolved. |
| `FloatingBar` | Bottom floating bar for quiz, mock, viewer and Customize your own: slots left, center counter, right action; colored states neutral, right (light green), wrong (light red); keeps room under content. |
| `QuestionGridSheet` | The one sheet for the questions grid: five across (six in the mock, grouped by part), right soft teal, wrong soft red, not reached gray outline, current dark edge plus bold number. Mock mode: answered gray, next part dimmed. |
| `PantasSheet` | The only sheet container, used only where a board draws a sheet: questions grid, reader contents, bookmarks, Today row sheets, the onboarding reminder time wheel (O_Notify, D-42), and the Home exam date picker (D-69). 74% height variant for bookmarks with the page behind settling down and darker. |
| `CenteredDialog` | Confirmation dialog (title, one line, `ButtonPair`); destructive variant with the red action. |
| `Toast` | Short message above the floating bar with optional Undo; used for the first flag and similar. |
| `ValueWheel` | Wheel picker opening in place (time, year, questions, minutes); struck-out values for invalid options (QZE_Short). |
| `MonthFirstDatePicker` | Year header, month row, optional day row, past greyed, "Today" mark; used by onboarding, Home sheet and Settings (D-30, D-69). |
| `ScopePicker` | Subjects as headings, topics with round boxes and a caret to lessons, dash for partial, "No questions yet" dimmed, "Unread" tag option; at-least-one rule with the shake. Used by Customize your own and What's included (D-221). |
| `SearchField` | Fill background; Cancel appears on focus; title folds away (ST_Search). |
| `Avatar` | Google photo, else first letter, emoji stays emoji, else plain person on gray; "Add your name" handling is the caller's copy. |
| `ProTag` | The small gold "Pro" tag; the one way Free sees a Pro feature. No lock icon, blur or banner. |
| `LoadingShapes` | Gray shapes that pulse, shown only after 300 ms; Pro-gate shapes stay still. `StepsScreen` for long or irreversible work (L_Restore, L_Delete, L_MockStart). |
| `StateView` | Error and empty pattern: title stays, faint icon, one line, tinted Try Again; a full-screen variant for "Something went wrong. / Nothing you've done is lost.". W2 owns the component; W4h owns the app-wide screen, its triggers and the retirement of `app_error_view.dart`. Never shows raw error text. |
| `MathText` | Inline and display math in Source Serif 4, `\frac` promoted to `\dfrac` at top level, spoken labels, fit-to-width at large text; carries the S0-46 accessibility checks. |
| `Placeholder` marking | `PlaceholderFigure(value, reason)` wrapper and a `// PLACEHOLDER:` comment convention; a test lists every use so W5 can block release on them (R-20). |

Contracts consumed: W1 colors, type, shapes, curves, effects, icons.

## 4. Behavior

- No sheets except `PantasSheet` at board-drawn places (README rule 5).
- One accent per screen; gold only in `ProTag` and Pro surfaces.
- Every component honors reduce motion (last frame) and large text without clipping.
- Components hold no business logic and fetch no data.
- Free and Pro: `ProTag` only. Placeholders: `PlaceholderFigure` only.

## 5. Motion

Each component's motion is taken from the board where it first appears (run `timeline.py` on it):
ring fill and check pop (HP_Day), notice open and fold (HP_NoDate), bar color change and Check to Next
(QV_Answer), grid sheet (QV_Grid), sort morph (DT_SortFlow), sheet with settling page (BM_Open),
shake (ST_IncludedLast), switch knob (ST_Root). Shared effects per MOTION.md.

## 6. Acceptance

- A widget test per component covering each listed state, light and dark, reduce motion, and 200%
  text scale without overflow.
- A gallery screen in debug builds only, listing every component and state, for Aedwon's visual
  check against the boards.
- No remaining imports of retired Ink components or `showInkSheet`; `flutter analyze` clean (the
  `onReorder` info gone).
- Full required checks.
- Aedwon: visual check of the gallery on his phones.

## 7. Risks and stop conditions

- Two families needing different behavior from one component: stop; the lead amends this plan
  before either family changes it.
- A board shows a sheet in a place this plan does not list: stop and report.
- Retiring an Ink component still used by a screen not yet rebuilt: keep it until that family's W4
  plan replaces the screen; the gate checks none remain at the end of W4.

## 8. Files and directories

`lib/core/ui/components/` (new components; retired ones deleted when their last caller moves),
`lib/core/ui/gallery/` (debug-only gallery screen, route `/settings/_gallery` in the `dev` route
file; W4f adds a link to it from the existing debug page), tests under `test/core/ui/`.

## 9. Order and parallelism

After W1. Every W4 family starts after W2's contracts are integrated. Retirement of old components
finishes when the last W4 family lands.
