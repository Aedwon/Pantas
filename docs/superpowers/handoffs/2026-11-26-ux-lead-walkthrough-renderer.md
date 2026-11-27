# UX lead: lesson walk-through parts in the reader (E-196), and the homepage Free and Pro fix (E-197), Nov 26

Policy read: `Aedwon/Pantas` main 094637286 (workers later read up to 118a00ef3). Lane rules followed: UI only to Claude workers, at most 2 at once, "Do not start subagents" in every brief, files changed with Edit or Write (exceptions below), browsers with `--use-mock-keychain --password-store=basic`.

## Delivered

- **Branch `ux/walkthrough-renderer-r1`** (from main 094637286), head **398704213**, full CI green (run 45804010062, all shards, static, goldens, web, coverage). Handed to CSE release lead r9 at 6:52 PM Manila for the opening build's Friday staging proof. Spec `docs/superpowers/specs/2026-11-26-walkthrough-renderer-build.md`; plan `docs/superpowers/plans/2026-11-26-walkthrough-renderer-build.md`.
  - Importer: both lesson converters read the agreed `:::` blocks (`walkCheck`, `walkTry`, `walkWhy`, `walkPair`, `walkChecklist`; `anchor` on h3 in walk-through lessons) through one shared parser; malformed blocks fail with path and line. The 158 lessons in `content/lessons` convert byte-identically (SHA-256 before and after). Corpus `content/lesson-walkthrough-cse-r1` at 46893d0ff: 187 of 191 convert, every target resolves; 4 Filipino vocabulary lessons fail (3 checklist lines without `{#slug}`, 1 lesson with 4 pairs), sent to the lesson lead, now the Claude lesson lead.
  - Reader: Quick Check, Try the last step, Why?, right and wrong pair, Next step and Show all steps (4 or more steps), Traps checklist with tap-back (opens hidden steps, centers the target, teal tint holds 300 ms after the scroll lands and fades over 1.2 s; Reduce Motion: jump and a static outline), reveals 240/180 ms, wide and phone, light and dark. Walk-through lessons show solutions open (built to the board; manager's no-objection recorded). Old-format lessons unchanged, "Show solution" included.
  - Tests first throughout; goldens from the CI image: four samples and a worst-case lesson at 390 and 1440, light and dark, rest and open, plus tap-back and Reduce Motion (`test/goldens/screens/walkthrough_reader_golden_test.dart`).
  - Side-by-side review by a fresh Sonnet reviewer: 12 findings; 5 fixed with tests, the rest ruled in the spec ("Side-by-side review rulings").
- **Homepage Free and Pro fix (E-197):** pantas-web `web/home-opening-r1` 179613d, his "just maybe make Everything in Free its own item?"; board version 116 (Pantas Website canvas, "Free and Pro: Everything in Free as an item"); r9 rechecked it and publishes it at step 4 of the opening.

## For the release lead (r9)

- Ship order: this build before any walk-through lesson reaches users. A client without it shows `:::` lines as text.
- The 4 failing lessons must be fixed before their content ships; the client converter rejects them.
- The board figures (number line, jump, discount bar, exponent, sentence head) are content work for the lesson leads; the samples carry only `ILLUSTRATION` comments.
- CI: the new test files re-sharded the suite, and `figure_choice_tiles_test` (sets a 1440 view, never reset) then leaked into `home_questions_sheet_footer_test` in the same bundle. Fixed at the source with `addTearDown(tester.view.reset)`; reproduced and cleared locally on the generated bundle.

## Process notes

- Golden PNGs were copied from the CI artifact with `cp` (a binary file cannot be written with Edit or Write); `dart format` rewrote one test file. A fix worker once ran `sed -i` on a test import by mistake and reported it.
- I ended a turn after the reader worker reported, with the renderer unfinished and no watcher running (manager: "you have been idle since 3:15 PM"). This repeats the Nov 25 entries; entry added to process-improvement.

## Open

- Aedwon's visual check of the reader on staging; r9 integrates and ships (the branch is not merged by this lane).
- The 4 failing lessons (Claude lesson lead) and the board figures (lesson leads).
- Velocity: E-196 and E-197 closed with timer actuals on main.
