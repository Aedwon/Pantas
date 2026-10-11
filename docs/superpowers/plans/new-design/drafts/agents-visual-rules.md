# Visual rules for the new design

Draft only. W1 Task 8. Policy read: origin/main 9618ff9e.
Aedwon must approve this text before it replaces the visual section on main.
It does not change the current policy or approve the implementation.

Sources: `docs/design/README.md`, `DECISIONS.md`, `MOTION.md`, approved boards,
and the later decisions in the engineering restart log. The handoff wins over
older visual specs. A later recorded decision wins over an older board.

## Build from the approved boards

Match each board's states, words, layout, styling and interactions 1:1.
Read its CSS and motion timeline before implementation. If the board, README,
and decisions disagree, stop and ask the lead. Do not choose a near match.

The design is mobile only. Boards use a width of 390 points and a 16-point
side gutter. A list title stays on one line and ends in an ellipsis when needed.
Test large phone text sizes without clipping controls or losing their actions.

Choices open in place, on their own screen, or in a centered dialog.
Do not add bottom sheets. Use the containers shown on the approved board.
Android permission dialogs and other system surfaces remain the platform's.

## Color carries meaning

Use teal as the single accent on a screen. Red means a wrong answer or a
destructive action. Gold marks Pro. Do not add accent colors for decoration.

Use the shared light and dark tokens below. Dark illustrations keep their white
backing. Screens without a dark board use the same dark tokens.
Disabled text uses the README token everywhere, including the disabled Check
label. The October 7 ruling replaces that board's slightly different gray.

| Role | Light | Dark |
|---|---|---|
| Background | `#F5F5F7` | `#000000` |
| Surface | `#FFFFFF` | `#1C1C1E` |
| Label | `#1D1D1F` | `#F5F5F7` |
| Secondary label | `#6E6E73` | `#98989D` |
| Tertiary and disabled text | `#AEAEB2` | `#5A5A5E` |
| Separator, 0.5 points | `#E3E3E8` | `#38383A` |
| Fill | `#EDEDF0` | `#2C2C2E` |
| Chevron and empty radio | `#C7C7CC` | `#48484A` |
| Accent text | `#0B7A68` | `#2FB39C` |
| Accent fill | `#0B7A68` | `#1F9C86` |
| Accent tint, selected and correct | `#E4F1EE` | `#123F37` |
| Destructive and wrong | `#D70015` | `#D70015` |
| Wrong tint | `#FDECEE` | `#3A1215` |
| Pro | `#D9A400` | `#D9A400` |
| Liquid gradient | `#14937D` to `#0B7A68` | Same |

An unselected tab is an enabled control, not disabled text. Build its presentation
from the approved tab bar. Light, Dark and Automatic follow Appearance settings.

## Fonts and type

Use Geist for interface and lesson text, with weights 400, 500, 600 and 700.
Use Source Serif 4 only for math inside lessons. Bundle both families and their
OFL texts. Fonts work offline; do not download them at runtime.
Use tabular figures wherever numbers change or line up.

| Role | Size and weight |
|---|---|
| Large title | 34 / 700 |
| Page title | 28 to 30 / 700 |
| Section hero | 24 / 700 |
| Body | 17 / 400 |
| Row value | 17 / 400, secondary label |
| Emphasized and button text | 17 / 600 |
| Subhead | 15 / 400 or 600 |
| Footnote | 13 / 400 |
| Section header | 13 / 600, uppercase, letter spacing 0.02em |
| Caption | 10 to 11 / 500 or 600 |

Use the board's exact style for each role. When a board needs a second size,
use a named style. Do not flatten the hierarchy to one approximate size.
The lesson preference multiplies the phone's text scaler only for lesson and
question bodies. Other controls retain the phone's scaling.

## Shapes and navigation

Grouped lists use radius 14. Cards use radius 18. Floating bars and cards use
radius 22 to 24. Pills and chips use radius 99. The primary button is 52 points
high, full width, with radius 14. Rows are at least 44 points high with 16-point
insets. Use the board's exact shape when it is more specific.

Navigation uses a floating pill bar: Home, Study, Quiz, Settings, in that order.
Each tab keeps its stack. Tapping the current tab returns to its root.
Settings is a tab root and has no back button.

Use the IC_Final icon set. Phosphor regular is bundled as the `Phosphor` font
under the MIT license. The October 7 ruling replaces the incompatible package
with the same font and pinned regular codepoints.
The nine own icons keep their approved SVG geometry, at 1.5-point line weight
on a 24-point canvas, with round ends. Do not substitute a lock icon.
Older boards' hand-drawn icons do not override IC_Final.

## Motion is final

Use each board's exact duration, delay, curve and sequence. Read its CSS or run
`docs/design/tools/timeline.py`. Do not retime, simplify or substitute a similar
Flutter curve. Use the shared curve constants when they match the board.

The screen at rest equals the last animation frame. With reduced motion,
show that frame immediately. Keep the order and overlaps of state changes.
Change the affected element in place; do not fade or reload the whole screen.
Animate only what the board animates. The approved Home tab bar has no tab
animation. Do not add page transitions, fades or hero moves that are not drawn.

A gray circle on a board represents a finger, not an interface element.
A demo loop's hold and reset exist for review. Build one interaction through its
last change. Only effects marked continuous may loop in the app.

## Copy and figures

Board copy is final, including capitalization and punctuation. Do not add an
explanation unless a later approved decision requires it. Use American spelling
and no em dashes. Existing lesson and quiz language rules still apply.

Scores are points. Items are questions. Do not show these words in the interface:
behind, ahead, on track, ready, mastery, FSRS, stability, retention,
retrievability, algorithm, cards, marks.

Dates follow the approved forms: `Nov 11, 2026`; `Oct 17` this year;
`Sat, Oct 17`; `Saturday, October 3`; `November 2026` for a month only.
Weeks run Sunday to Saturday. Date ranges use an en dash as drawn.

Board numbers are sample data. Real figures come from the student's measured
use, a published testing-body source, or a named algorithm used as designed.
Do not replace missing data with an estimate or a plausible constant.
Keep any separately approved development placeholder visible in its release
blocker record; it is not permission to invent another figure.
