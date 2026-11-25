# Loading, reader line and week strip boards (E-149), Nov 25

UX design lead, board only. Policy read from main at 0be11beeb (estimate pushed as 1129c6810). Nothing built or shipped.

## What was asked

Manager brief: one Claude Design board with three sections, each starting from his approved screens, phone first plus wide,
light and dark, beside the live state. 1: delayed loading indicator, 2 options. 2: reader progress bar replacement, 2 or 3.
3: Home week strip with long CSE exam names (U14), 2 options. Search the approved boards, specs and rulings first; skip the
options where a board of his already draws it.

## Board

Claude Design canvas "Loading, Reader Line, Week Strip": https://claude.ai/artifact/MQxxjEmiWjbzwUqaF8h9Ec (private until
he shares it). Pages: 1 Loading, 2 Reader line, 3 Week strip, Parts. Each row has a sticky naming what was searched and the option.
Two Sonnet workers built the frames from the exported approved boards; the lead did not render it. He does the visual check.

## 1. Delayed loading indicator

- Searched: Pantas Web and Pantas Redesign `L_Rules`, `L_PlanSlow`, `ST_Loading`, `SD_Loading`, `OB_PickerLoading`, `SP_Splash`,
  `SP_WebBStill`, `SP_PhoneBFade`, `SP_Flow`; spec `2026-11-07-load-speed-and-telemetry-design.md`; the rulings; live
  `web/index.html` and `web/pantas_splash.js` on main.
- Found: his boards already draw every wait inside the app (grey shapes pulse, only past 300 ms; nothing under 300 ms; no fake
  progress) and the splash hand-off to Home (B Smoothest). Not drawn: the wait before the app code arrives. On a return visit
  the logo pops in, then nothing moves until the first screen is ready (up to 8 s after the app starts, 60 s before).
  First visits show the Welcome screen, whose button already spins if tapped early.
- Options (rows on page 1; 7 s loop each):
  - A, the logo breathes (recommended): from 1.5 s the logo and wordmark pulse with the `L_PlanSlow` pulse. Nothing new appears.
  - B, a small spinner: from 1.5 s a 20 px grey ring spinner fades in 40 px under the wordmark.
  - Reduce Motion, both: nothing moves; "Loading" appears at 1.5 s (`L_Rules`).
- Frames use the live phone splash position (lifted 135 px, the Nov 10 phone fix), not the board's centered one.
- `build/audit/load-perf/` (the measurement the load-perf brief asked for) does not exist in the qa-cse-release-r1 worktree, so
  the load causes are still unmeasured. The options do not depend on them.

## 2. Reader line (wide web only)

- Searched: Pantas Web `W_Reader`, `RD_Focus`, `RD_FocusOpen`, `RD_Held1100`, `held/fs.css`; spec
  `2026-11-23-lesson-reader-full-screen-design.md` ("Section line"); rulings "Nov 23, lesson reader full screen" and
  "Nov 24, T15 reader undrawn states" (ruling 2); live `reader_section_line.dart`.
- Found: the segmented line is council-designed (Nov 23), not his pick. His earlier approved `RD_Focus` drew one plain 2 px line.
  The phone reader does not change.
- Options (page 2):
  - A, one line: a 2 px line fills as you read, as on `RD_Focus`. The line no longer jumps to sections. Smallest build.
  - B, one line, names on hover: same at rest; pointing thickens it to 4 px and names the section; a click jumps there.
  - C, one line, sections in the lesson list (recommended): same at rest; the `RD_FocusOpen` lesson list shows this lesson's
    sections one level in, the current one teal; a click jumps there. No new top bar button.
- Gaps: the popover has no approved dark look, so C's open state is light only. Hover and jump are drawn as still states.
  The lesson body is the board's sample lesson; the live row draws 47 segments to show the reported case.

## 3. Week strip, long CSE exam name (U14)

- Searched: Pantas Redesign `HP_WeekStrip`, `HP_WeekStripLarge`, `HP_WeekFrame`, `HE_ManyLessons`; Pantas Web `HM_NoContent`;
  ruling D196; finding U14.
- Found: answered by his board. `HP_WeekStrip` (his pick B, D196) shows a short name, "CSE Pro". No options.
- Lead copy ruling (rule 4), recorded in `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, "Nov 25, UX design
  lead": the chip says "CSE Pro" and "CSE Subpro"; everything else keeps the catalog short name. Four days fit beside
  "CSE Subpro"; at 200% text the chip goes under the strip (D196). Live "CSE Subprofessional" does not fit beside the strip at all.
- This is a build fix to his board, not a new look: the CSE release lead can build it without a pick.

## Open

- His pick for section 1 (A or B) and section 2 (A, B or C). Until then nothing from those sections reaches prod (Nov 24 rule).
- Section 3: a build task for the CSE release lead (UI list item, U14).
- Canvas source files: the lead's scratchpad (`canvas/project/`), disposable; the canvas itself holds every file.
