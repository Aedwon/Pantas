# Figure answer choices

Status: Part A approved by Aedwon on November 18, 2026, with scope Minimal (relayed by the
operations manager). The odd-one-out boards are approved as part of his Option 2 pick.
Build started: drawing fixes and the numbered row first, then the tiles.
Date: November 18, 2026. Lane: figure answer choices UI lead (Opus 5.5). Velocity row E-120 (timer E-106).
Policy read: `origin/main` 7da59dda4 (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`,
`docs/workflow/process-improvement.md`).
Decision log, with his exact words: `docs/superpowers/decisions/2026-11-17-figure-answer-choices-log.md`.
Parent decision: question 5 in `2026-11-17-question-generator-log.md` ("figure choices, in a
second, small spec with boards"). Part of the PSHS-NCE sale gate.
Boards (the visual source of truth, matched 1:1): Claude Design canvas "Figure Answer
Choices", https://claude.ai/artifact/1ceeLDYSix7tSyP6fUSFv2, Option 2 boards
(O2_Phone, O2_Wide, O2_Dark, O2_States, O2_OddOneOut_Phone, O2_OddOneOut_Wide), canvas version 6.

---

## Part A: for Aedwon

### What you decided

- A figure choice shows the figure and its letter only. The text description is read by
  screen readers and never shown. Your words: "go with reco".
- Layout: Option 2, 2 by 2 tiles. Your words: "i pick option 2 2x2 tiles".

### What a student sees

- Abstract reasoning questions whose answers are figures show four tiles. On the phone they
  sit two by two; on wide web, four in one row under the question.
- Each tile shows a white figure card and its letter at the top left. Tapping a tile picks
  it. Check and Next work as today.
- After Check, the right tile gets the teal ring, tint and a check mark at its top-right
  corner. A wrong pick gets the red ring, tint and a cross. Letters stay in every state.
- Figures never fade in review, so they stay readable. Only the letter ring changes on the
  other tiles.
- Questions whose answers are a count, an order or a condition keep today's text rows.
  Five hand-written figure questions also keep text rows, because their answer figures
  cannot be drawn yet.
- The same tiles appear in practice quizzes, lesson quizzes, mock exams, the assessment and
  answer review, on phone and web, light and dark.

### Odd-one-out questions (new case, please check the boards O2_OddOneOut_Phone and O2_OddOneOut_Wide)

Some questions ask which shape in a row does not belong, and their choices read
"Figure 1" to "Figure 4". Today the row shows no numbers, so those choices are unclear.

- Now: the shape row shows a number under each shape. This fixes the live questions.
- When this screen ships: for three of these question types the four shapes become the four
  tiles, and no separate question figure is shown, since it would repeat the tiles. This is
  the only layout that is not on the boards you picked from, so it is drawn on those two boards.
- One type (dot counting) has five shapes and four choices, sometimes with two identical
  shapes. It keeps the numbered row and text choices.
- The three types and their live source questions switch together, through the content
  approval gate, so nothing changes for a student before the screen ships.

### Two live figure fixes

- Figure series question 18: a line pointing right lies on top of the row of dots. The
  drawing will move the dots so no line can cover them.
- Figure matrices question 8: dots in the small triangle are crowded and hard to count. The
  drawing will size and space dots so they stay countable in the smallest shape.
- Both are drawing fixes only. No question text or answer changes.

### Scope options (pick one before the build)

- **Minimal (recommended).** The tiles on every quiz surface, phone and web, light and dark;
  the numbered shape row; the two drawing fixes; tests and one picture sheet per screen for
  your check. About 1.5 days of Claude worker time, plus your visual check.
- **Balanced.** Minimal plus opening a choice's figure full screen with a long press (phone)
  or a zoom button (web). About 2 days. Not on the boards, so it would need a board first.

Hardened adds nothing useful here, so it is not offered.

### Order and dates

- On your approval and scope pick: the plan, then the build on a branch. Claude workers only.
- The numbered shape row and the two drawing fixes can ship first, on their own.
- The tiles reach prod after the beta ends (November 22) and after your visual check and
  "ship it".
- The odd-one-out switch follows in the question generator's window, from November 23.

### How we judge it done

- Every Option 2 board state matches the app 1:1 on phone and wide web, light and dark.
- A screen reader reads each tile as its letter and description, and says "correct answer"
  or "your answer, wrong" after Check.
- Series 18 and matrices 8 show every dot clear of lines and countable on a phone.
- Odd-one-out "Figure N" choices match numbered shapes until the switch.

---

## Part B: for agents

### Sources

- Boards: canvas above, Option 2 and the two O2_OddOneOut boards only. Options 1 and 3 are rejected.
- DS4 (Pantas design system): https://claude.ai/artifact/N4y4tGXPS2mecemzAMd5dJ.
  AnswerOption (states, roles, keyboard), Figure (figure-bg, white in dark), SelectableTile
  (tile geometry, focus), FocusLayout, KeyHint, patterns.md.
- Approved screens: `web-design/pantas-handoff/` (QV_Figure, QV_Answer, W_Question,
  W_QRight, W_QMiss).
- Choice data: `docs/superpowers/plans/2026-11-17-question-generator.md` Part 3 and 3b on
  `gen/question-generator-r1`. Each type declares `choiceKind: figure | text`; every choice in
  one question uses it. A figure choice carries `figure`: one item of the parent figure kind
  (a series item, a matrix cell, a shape-row shape, a fold result, a cube), plus `text`.

### Data and rendering

1. A question renders figure tiles when every choice has `figure` and its kind has a painter
   for a single item. Otherwise it renders AnswerOption rows. Mixed questions are rejected by
   the generator checker; the app falls back to rows if one appears.
2. Single-item painters: reuse the existing figure painters (`lib/core/ui/figures/`) to draw
   one item at tile size. Same stroke, fill and dot rules as in the question figure, so a
   choice and its source item look identical. No new drawing style.
3. The figure inside a tile is `aria-hidden`. The tile's accessible name is
   "<letter>, <text>"; after reveal add ", correct answer" or ", your answer, wrong".
4. Tiles do not open the figure viewer. A tap selects.
5. The content schema in `HANDOFF.md` is unchanged except for the optional per-choice
   `figure` field the generator already writes.

### Component: figure choice tile

- Phone: 2 columns; wide: 4 in one row inside the 720 question column; 5 choices reflow as
  drawn on O2_States. Sizes, gaps, radii and the corner mark position come from the O2
  boards; read them there, do not re-derive.
- States, as on O2_States: rest, hover (web), pressed (scale 0.98), selected (2px accent ring,
  badge accent-fill), keyboard focus (wide only, 2px outline; text-primary on a selected
  tile), revealed right (accent ring, accent-tint, check at top-right), revealed wrong
  (danger ring, danger-tint, cross at top-right; right tile follows 150ms later), review
  (read only). Letters stay visible in every state.
- Dimming rule (lead ruling): figures are never dimmed and tiles never use opacity. Other
  tiles keep the rest look; only the badge ring goes to `divider`.
- Dark: the tile is `surface-card`; the figure card stays `figure-bg` (white), as O2_Dark.
- Group: `role="radiogroup"` labelled by the stem; tiles `role="radio"`, `aria-checked`,
  roving tabindex. Arrows move and select before reveal, move only after. Enter checks.
  Letter keys only with focus in the question region and Settings > Keyboard Shortcuts on.
  After reveal `aria-disabled="true"`, never `disabled`. Result announced once by the bar.
- Motion: AnswerOption's timings (ring and fill 180ms, mark pop 560ms on `motion-move`,
  late reveal 150ms); reduced motion shows end states. Wide web animates wherever the phone
  does (rule 1).
- Flutter: phone beside `ChoiceRow`, web beside `WebAnswerOption`; reuse their state enum and
  semantics. Surfaces: quiz page and viewer, mock session and review, assessment (phone and
  web layout), in-lesson quiz, and any review screen that lists choices.

### Odd-one-out (positional) types

- Interim (ships first): the shape-row painter draws position numbers 1 to N under the
  shapes, always. Numbers use the figure font (Source Serif 4) in figure ink. Shape-row
  questions whose choices name shapes are unaffected in meaning.
- At the screen release: `group-boundary`, `group-dot-parity`, `group-side-double-dots`
  become `choiceKind: figure` (`figure = shapes[value-1]`, text = a shape description, not
  "Figure N"). Their question figure is not shown (O2_OddOneOut_Phone and _Wide). Their live source
  questions convert in the same release through the content approval gate, so version 0
  equals its source. Owner: question generator lead, Phase 2 window (from Nov 23).
  Checker: figure choices must be visually distinct; notes and explanations must not say
  "Figure N". Re-approval of the three lists (checker, blind solve, wording re-audit).
- `group-dot-count` keeps the numbered row and text choices (5 shapes, 4 choices, repeats).
- Held `group-line-count` and `group-center-cuts` use the new form when they return.
- A question with no question figure needs a flag the app reads. The generator writes it;
  the plan names the field with the generator lead.

### Painter fixes (no content edits; version 0 compares data, not pixels)

- Figure series 0018 (`line: 90`, dots 4): a ray at 90 degrees runs along the dot row
  (`SeriesGeometry.dotRow`, offset 0 for squares). Fix: place the dot row so no line angle
  in use (any multiple of 45 degrees) passes through a dot; for example move the row off the
  centre line and clip ray length to the gap. Test: for every form, every dots count 0 to 5
  and every line angle 0 to 315 in steps of 45, no dot is within one dot radius plus 1px of
  a line.
- Figure matrices 0008 (small triangle, 3 dots): dots crowd. Fix: dot radius and spacing
  scale with cell and form size with a minimum gap of one dot diameter between dots and
  from the outline; if a small form cannot fit them, the row may wrap to two rows inside the
  form. Test: every form at every size with 1 to 5 dots keeps those gaps.
- One offscreen sheet per changed painter, light and dark, for Aedwon's check.

### Verification

- Golden sheet per surface (phone and wide, light and dark) for the O2 states, compared with
  the boards by Aedwon; one sheet per screen, not per state.
- Widget tests: semantics names and suffixes, roving focus, letter keys scoped, aria-disabled
  after reveal, fallback to rows for text choices and mixed data.
- Painter tests above.
- `dart run tool/checks/run_checks.dart`, `flutter analyze`, `flutter test`, format,
  layering, attribution on the branch.
- Independent Claude reviewer on the UI diff (component use and the look, `SUBAGENTS.md`
  Part 7b). No Codex on UI.

### Out of scope

- Opening a choice figure full screen (Balanced option).
- New figure kinds, and drawing the five undrawable singles.
- Any change to the question figure, stem, bar or explanation layout.

### Risks

- A figure too small to read at tile size on a 360px phone. Mitigation: the tile figure card
  takes the full tile width minus padding; the golden sheet includes a 360px width.
- Source question conversion slips past the screen release. Then the three types keep text
  choices with the numbered row, which still works.

### Board versions

- Canvas version 6 at spec writing (Nov 18). A later canvas change needs Aedwon's approval
  before it binds the build.
