# Plan: walk-through lesson parts in the reader (E-196)

Spec: `docs/superpowers/specs/2026-11-26-walkthrough-renderer-build.md` (read it first, then the standard and the board files it names).
Branch: `ux/walkthrough-renderer-r1` from main 094637286. Workers branch from it in their own worktrees; the UX lead merges.

## Global constraints (every worker)

- Do not start subagents; do the work yourself.
- Change files only with the Edit or Write tool. Bash is for read-only commands, test runs, and git add, commit and push only; no python, sed, perl or heredoc writes.
- Every Flutter or Dart test run goes through `/Users/aedwon/.t3/worktrees/Pantas/qa-cse-release-r1-485b9ecb7345be22/build/audit/flutter-locked.sh <command>` (one at a time on the machine). Run focused tests only; the full suite runs on hosted CI.
- No browser. Do not capture screenshots. Never kill processes you did not start.
- No AI attribution in files or commit messages. Commit messages say why.
- Tests first: write the failing test, run it, see it fail for the expected reason, then implement.
- Old-format lessons must convert and render exactly as today.
- Board files for the look: `/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-ux-ambition-r1-ec9f70cc51bfa56c/d4221c60-f657-4927-a8e6-7d3c47fcea3d/scratchpad/board/project/` (`walk.css`, `reader.css`, `PT_*`, `LB_*`). Read them; do not edit them.
- Before writing a widget, check `lib/core/ui/components/` (PantasButton and its tertiary and tonal kinds, tokens in `lib/core/ui/theme/`). Every control is a design-system component or carries a true `// ds-raw: <reason>`. Values from the board that have no token get a `// ds-board: <board file>` note.

## Task 1: importer and parser (Worker A)

Files: new `lib/core/content/walkthrough_markdown.dart` (pure Dart, no Flutter import: fence scanning, checklist item split, heading slug, target validation); `tools/content/markdown_portable_text.dart`; `lib/core/content/remote/lesson_markdown.dart`; `lib/features/lesson/domain/portable_text_plain.dart` (search text recurses into walk blocks); tests `test/core/content/walkthrough_markdown_test.dart`, `test/tools/markdown_portable_text_test.dart`, `test/core/content/remote/lesson_markdown_test.dart`, `test/features/lesson/domain/portable_text_plain_test.dart`; fixtures `test/fixtures/walkthrough/` (copy the four samples from b8640b532 with `git show`, saved with the Write tool, plus `bad_*.md` cases).

1. Before any edit: print a SHA-256 over the JSON output of both converters for every lesson in `content/lessons` (a temporary test that prints, run on the unmodified branch). Keep the number for the report.
2. Tests first: each schema type from the spec, from the samples (exact expected structure for at least one of each type, the pair inside a numbered step, the try after the last step, display math inside an answer, a Filipino-style lesson keeping English markers); each error in the spec's error list, with path and line; `anchor` on h3 only in walk-through lessons; the two converters agree on every fixture.
3. Implement. Each converter converts nested content by calling itself on the inner lines, so spans and blocks match the rest of the lesson.
4. After: the same SHA-256 must match step 1 exactly.
5. Corpus: run both converters over every lesson on `origin/content/lesson-walkthrough-cse-r1` that has a `:::` line (read with `git show`, inside a temporary test that reads from `git show` output or a path passed by environment; do not commit that test). Report counts: lessons, blocks by type, errors (expected 0). An error in real content is a finding: report it with path and line, do not change content.
6. Commit on the worker branch.

## Task 2: reader parts (Worker B)

Files: `lib/core/ui/components/reader_blocks.dart` (plan items: walk types, step groups for examples in walk-through lessons), `lib/core/ui/components/content_renderer.dart` and `content_renderer_held.dart` (dispatch and layout), new `lib/core/ui/components/walkthrough_parts.dart` (Quick Check card, Try card, Why?, pair, checklist, step reveal, tap-back controller and highlight), theme tokens only if one is missing; tests `test/core/ui/components/reader_blocks_test.dart`, new `test/core/ui/components/walkthrough_parts_test.dart`, `test/features/lesson/presentation/` where the page scroll is needed.

Build each part to the board, phone and wide, light and dark:
1. Quick Check and Try: card (`.wcard`), label (`.wlab`: "Quick Check", "Try the last step" as the board writes them), question, "Show answer" (`.wbtn`: tonal, 44 px, radius 12; wide right end natural width; phone full width), answer panel (`.wans`, first sentence bold, check icon). After reveal the button is gone.
2. Why?: tertiary teal button (`.wtert`, 44 px) under its rule, label "Why?" then "Hide", panel `.wpanel`.
3. Pair (`.wpair2`, `.prt`, `.pwr`, `.pnote`): always open, stacked at every width, Right card with the filled teal check, Wrong with no card, secondary color, one size smaller (16 wide, 15 phone), neutral cross. Semantics group "Right and wrong".
4. Checklist (`.wcl`, `.clr`): rows at least 44 px, cue semibold, move after it, up arrow at the right, hidden label "Go to its step", pressed and hover colors, focus ring.
5. Examples in walk-through lessons: solution open (no "Show solution"); 4 or more numbered steps: first group shown, then `.srow` with "Show all steps" (tertiary) and "Next step" (tonal); wide: right end, secondary then main; phone: stacked, Next step on top, same width. The row goes once all groups show. Old-format lessons keep `_ExampleCard` unchanged.
6. Tap-back: a tap opens all groups of an example that holds a hidden target, then scrolls the target to the middle (`Scrollable.ensureVisible`, alignment 0.5), then the tint (`--acctint`, inset 12, radius 20; h3 inset 8 by 12, radius 12) holds 300 ms and fades over 1200 ms, ease (.25,.1,.25,1). Reduce Motion (`MediaQuery.disableAnimationsOf`): jump, and a static 2 px accent outline that stays until another checklist tap or leaving the lesson.
7. Reveals: height 240 ms, curve (.3,.9,.3,1), fade 180 ms; Reduce Motion: end state at once. Send `ReaderResizedNotification` on every reveal.
8. Tests first for every state above, including: old lesson still shows "Show solution"; tap-back on a target inside hidden steps opens them and ends with the target centered; tint opacity 0 after 1.5 s; outline present under Reduce Motion; wide button placement passes `test/helpers/button_placement.dart`.
9. Commit on the worker branch. Use hand-built block maps that follow the spec schema until Task 1 merges.

## Task 3: goldens and review (UX lead, after Tasks 1 and 2 merge)

1. Golden test `test/goldens/screens/walkthrough_reader_golden_test.dart`: the four samples and a worst-case lesson fixture (3 pairs, 3 checklist lines at the longest real length, a 7-step example with a pair inside a step, a Why? and a long Filipino word), 390 and 1440, light and dark, one sheet per lesson and state set (rest, everything open, tap-back landed, Reduce Motion outline). Images come from CI (`[update-goldens]`).
2. Side-by-side review against the board frames by a fresh Sonnet reviewer; fix findings with tests.
3. Hosted CI green; `dart run tool/checks/run_checks.dart` clean; internal-terms and cut pass on every new string.
4. Handoff to the CSE release lead r9 with the ship order (this build before walk-through content).
