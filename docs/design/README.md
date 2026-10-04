# Pantas design handoff (Direction B, "Clarity")

This folder is the approved redesign of the Pantas app, exported from the design canvas on Oct 5, 2026.
It is the source of truth for how every screen looks, reads and moves. Where it disagrees with an older
spec in `docs/superpowers/specs/`, this folder wins; where it disagrees with itself, `DECISIONS.md` wins.

## What's here

| Path | What it is |
|---|---|
| `index.html` | A gallery of every board. Open it in a browser and click any card to open the board. |
| `boards/*.html` | Each board as a self-contained page (390 wide, phone size). They play their animations exactly as approved. `runtime.js` runs the few step-by-step flows; everything else is plain CSS. |
| `screenshots/` | Stills. `Name.png` is the screen at rest. `Name_motion.png` is six frames across one loop of a looping animation. `Name_stepN.png` is each step of a step-by-step flow. |
| `SCREENS.md` | Every board: what it shows, its app route in `lib/app/router.dart`, how it moves, and the related specs. |
| `MOTION.md` | How to read a board's animation and turn it into Flutter without changing it. |
| `DECISIONS.md` | Everything decided while designing, by area. Copy, rules, prices, edge cases. |
| `tools/timeline.py` | Prints any board's animation as a millisecond timeline: `python3 docs/design/tools/timeline.py docs/design/boards/ST_ExamSwitchCount.html` |

## Rules for building from these boards

1. **Copy is final.** Use the words on the board exactly, including capitalization and punctuation. Do not add
   explanatory text. No em dashes. American spelling. Dates read like "Nov 11, 2026" ("Oct 17" this year).
   Words that never appear in the UI: behind, ahead, on track, ready, mastery, FSRS, stability, retention,
   retrievability, algorithm, cards, marks.
2. **Motion is final.** Every duration, delay, curve and order on a board was approved. Read it with
   `tools/timeline.py` or the board's CSS, not by eye from a screenshot. See `MOTION.md`.
3. **The screen at rest equals the last frame of its animation.** If motion is off (reduce motion), show the
   last frame.
4. **One accent per screen.** Teal is the accent. Red is only for wrong answers and destructive actions;
   gold only marks Pro.
5. **Don't add bottom sheets.** Choices open in place (in the list, or as their own screen) or as a centered
   dialog. Build exactly the containers each board shows and introduce no new sheets. System UI (the Android
   permission dialog) is the platform's.
6. **Mobile only.** Boards are 390 points wide; side gutter 16.
7. **Lists never wrap a title.** One line, ending in "…".

## Tokens

Font: **Geist** (400, 500, 600, 700), with tabular numbers wherever numbers change or line up.
**Source Serif 4** only for math inside lessons. Navigation is a floating pill tab bar (Home, Study, Quiz, Settings).

| Role | Light | Dark |
|---|---|---|
| Background | `#F5F5F7` | `#000000` |
| Surface (grouped rows, cards) | `#FFFFFF` | `#1C1C1E` |
| Label | `#1D1D1F` | `#F5F5F7` |
| Secondary label | `#6E6E73` | `#98989D` |
| Tertiary / disabled text | `#AEAEB2` | `#5A5A5E` |
| Separator (0.5px) | `#E3E3E8` | `#38383A` |
| Fill (search field, empty track) | `#EDEDF0` | `#2C2C2E` |
| Chevron, empty radio | `#C7C7CC` | `#48484A` |
| Accent (teal) | `#0B7A68` | `#2FB39C` text, `#1F9C86` fills |
| Accent tint (selected, correct) | `#E4F1EE` | `#123F37` |
| Destructive / wrong | `#D70015` | `#D70015` |
| Wrong tint | `#FDECEE` | `#3A1215` |
| Pro | `#D9A400` | `#D9A400` |
| Liquid fill gradient | `#14937D` → `#0B7A68` | same |

Type scale (size / weight): large title 34/700 · page title 28–30/700 · section hero 24/700 · body 17/400 ·
row value 17/400 secondary · emphasized 17/600 (buttons) · subhead 15/400–600 · footnote 13/400 ·
section header 13/600 uppercase, letter-spacing .02em · caption 11–10/500–600.

Shapes: grouped lists radius 14 · cards 18 · floating bars and cards 22–24 · pills and chips 99 ·
primary button 52 high, radius 14, full width · rows 44+ high with 16 inset.

## Pages of the canvas

Onboarding · Home (Home, the plan, Your performance, You) · Study (map, reader, bookmarks) · Quiz (quiz tab,
questions, notes, mock exams) · Settings (and Pro, passes, account, backup) · Loading states · Redesign
(assessment, custom mock, errors, Wrapped, dark mode, last gaps) · Icons. `SCREENS.md` lists them all.

## For Claude Code

- Before building a screen, open its board(s) from `SCREENS.md` and the matching section of `DECISIONS.md`.
- Before animating, run `tools/timeline.py` on the board and match it. Do not simplify, retime or swap curves.
- A gray circle that appears and fades on a board is the user's finger. It is not UI.
- The end of a looping board (hold, then a jump back to the start) only exists so the board replays. Build
  the animation from the start to the last change.
- Copy the board's numbers as sample data only; real values come from the app.
- If a board seems to conflict with this README or with `DECISIONS.md`, ask instead of guessing.
