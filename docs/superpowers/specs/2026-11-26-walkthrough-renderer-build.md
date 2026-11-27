# Walk-through lesson parts in the reader: build spec (E-196)

Date: November 26, 2026. Lane: UX lead. Policy read: `Aedwon/Pantas` main 094637286.
Status: build spec under approved decisions. No new approval is needed: the standard, its picks and the board layout are approved.

His words: Nov 25 "i am approving the lesson walkthrough standard. i think we have enough usage to implement it for CSE / please queue this ..."; Nov 26 on the board: "layout approved. for the lesson board"; Nov 26 "as a rule, Claude is still on UI". Picks at the standard's recommendations (length a, Quick Check A: tap "Show answer").

Controlling documents:
- Standard: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part B, Markup and UI).
- Board: "Lesson Walk-Through Samples", https://claude.ai/artifact/7hd4pLNonSKfmrbs9kyePu, version 11 as approved (served version id 1795675138-cf91). The look comes from its `project/walk.css`, `project/reader.css` and the `PT_*` state frames; lesson flow from `LB_*`.
- Syntax: `docs/superpowers/handoffs/2026-11-26-ux-lead-homepage-opening.md`, "Next", items 1 to 5, agreed with the Gemini walk-through lead and matching `tools/audit/sweep_structure.py` on `tools/walkthrough-checks-r1`.
- Samples: `docs/content/walkthrough-samples/` at b8640b532. Corpus: 191 rewritten CSE lessons on `content/lesson-walkthrough-cse-r1`.

## Part A: what the reader does (plain words)

1. A lesson written with the new parts shows them exactly as the board draws them, at phone and wide, light and dark.
2. Quick Check: a card with the question and "Show answer". Tapping shows the answer, first sentence bold. Wide: button at the right end; phone: full width in the card.
3. Why?: a small teal button under its rule. It opens a panel and becomes "Hide".
4. Right and wrong pair: always open. Right in a card with a teal check; Wrong under it, quieter, gray cross, never red; the note under both.
5. Examples in these lessons show the solution open. A solution with 4 or more steps shows one step at a time with "Next step" and "Show all steps".
6. Try the last step: the Quick Check card inside the solution, with the Check line inside the hidden answer.
7. Traps to Watch For: a checklist. Tapping a line scrolls to its pair or rule, opening hidden steps first; a teal tint fades over 1.2 s. With Reduce Motion: an instant jump and a teal outline that stays.
8. Every reveal opens over 240 ms; with Reduce Motion the end state shows at once.
9. Lessons in the old format look and behave exactly as today, including "Show solution".

Lead decisions (rule 4; searched the standard's UI section, the board notes and files, patterns.md button placement, the Nov 21 to 26 process entries):
- Walk-through mode is per lesson: a lesson is in it when its Markdown has any `:::` block. Only then are solutions open and stepped. This keeps old lessons unchanged, as the brief requires.
- Built to the board: walk-through solutions show open (the board's `LB_*` and `PT_Next_*` frames draw no "Show solution"), with Next step for 4 or more steps; old-format lessons keep "Show solution". Manager, Nov 26: "no objection. Build to the approved board: walk-through solutions show open (Next step for 4+ steps); old-format lessons keep \"Show solution\". Record it as built-to-board in your spec."
- The Reduce Motion outline stays until the reader taps another checklist line or leaves the lesson (the board's state holds it).
- A step group is a numbered step and every block after it up to the next numbered step; the answer line and the Check line belong to the last group (board `PT_Next_*`).
- Malformed blocks fail the build with the lesson path and line, as malformed tables do today.
- Old app versions: the client converts lesson Markdown itself, so a client without this build shows the fence lines as text. The release lead ships this build before any walk-through lesson.

## Part B: for agents

### Standards applied

- Instructional design (`~/Documents/Projects/agent-standards/instructional-design.md`): ID-WORKED, ID-RETRIEVE, ID-TRY, ID-EXPLAIN, ID-ERR-FIX, ID-SEGMENT, ID-SIGNAL (as in the standard; this build renders them, it does not change content).
- Web interface design: WEB-C1, WEB-C2, WEB-C6 (both themes), WEB-I10 (targets at least 44 px), WEB-A1 (focus visible, reading order), WEB-A3 (names: checklist rows say "Go to its step"), WEB-M1, WEB-M6, WEB-M9.
- Motion design: MOT-STATE, MOT-CONT (reveal grows from its place), MOT-REDUCE (outline in place of the fade, not a switch-off), MOT-CANCEL (taps during a reveal are not blocked), MOT-FREQ.
- UX writing: UXW-BUTTON, UXW-CASE, UXW-CONCISE for button labels ("Show answer", "Why?", "Hide", "Next step", "Show all steps").
- Project: `design/system/patterns.md` button placement (wide right end, natural width, secondary then main; phone full width in its card, stacked pair same width, main on top), `AGENTS.md` maths rules, process entries Nov 25 to 26 (worst-case golden rows, cut pass, internal terms).

### Portable Text schema (both converters emit exactly this)

Nested content is a list of ordinary Portable Text blocks produced by the same converter.

```
{_type: 'walkCheck',  question: [blocks], answer: [blocks]}
{_type: 'walkTry',    prompt:   [blocks], answer: [blocks]}
{_type: 'walkWhy',    body:     [blocks]}
{_type: 'walkPair',   id: 'slug', right: [spans], wrong: [spans], note: [blocks]}
{_type: 'walkChecklist', items: [{cue: [spans], move: [spans], target: 'slug'}]}
```

- Spans are the converter's inline spans (`_type: 'span'`, `text`, `marks` with `latex`, `strong`, `em`).
- Checklist item: text after `- `, `{#slug}` stripped from the end, split at the first `:` outside `$...$`. `cue` keeps the colon. No colon: `cue` empty.
- In a lesson with any walk block, every `h3` block also carries `anchor`: the slug of its raw Markdown title (`re.sub('[^a-z0-9]+', '-', title.lower()).strip('-')`, the sweep's rule). Lessons with no walk block get no new field, so their output is byte-identical to today.
- Errors (FormatException with path and line): unclosed block, stray `:::`, unknown fence, `:::answer` outside check or try, a second `:::answer`, nesting, pair without exactly one `Right:` then one `Wrong:`, duplicate pair id, more than 3 pairs, checklist with 0 or more than 3 items, an item without `{#slug}`, a target that matches no pair id or `###` slug, a figure or illustration marker inside a block.

### Reader

- `planReaderBlocks` learns the walk types; an example in a walk-through lesson carries step groups.
- One controller per rendered lesson holds the targets (pair ids and h3 anchors), opens a hidden step group that holds a target, scrolls the target to the middle, and runs the tint or the outline.
- Every reveal sends `ReaderResizedNotification`, as the example card does today.
- The wide held layout (`content_renderer_held.dart`) renders the same parts.
- Tokens: board variables map to existing color tokens (`--acc` accent, `--acctint`, `--acctext`, `--surf` card, `--edge` separator, `--deep` reader deep, `--sec` secondary). A missing token is added to the theme with a `ds-board` note, not hard-coded.

### Build versus board: lead decisions (rule 4, after the reader build, Nov 26)

Searched: the board's `walk.css` and `reader.css`, `design/system/patterns.md`, the design-system button README and tokens, the standard's UI section. The new parts follow the board; where the board's base layer (`reader.css`) redraws the existing reader, the existing approved reader wins, because the brief is the new parts and old lessons must not change.
- Kept from the app, not the board: reader paragraph size on phone (17, board 16) and the reader's 16 px paragraph gap (board 18). These are the live reader, outside this build.
- Buttons are the design-system `WebButton` (tonal and accent tertiary, 44 px). Its hover, press and dark tonal label colors come from design-system tokens; the board's one-step-different hex values for `.wbtn` hover and press, and `--acc` as the dark tonal label, are not copied. The pattern rule (every control a design-system component) wins over a hand-drawn hex.
- Fixed to the board: "Why?" sits 8 px under its paragraph; the answer line in a walk-through solution lines up with the step text (`.note`).
- Not drawn on the board, decided: the tap-back scroll takes 420 ms on the app's move curve, then the tint holds 300 ms and fades over 1.2 s; the first sentence of a revealed answer is bolded by the reader.

### Side-by-side review rulings (fresh Sonnet reviewer, build 587048e86, Nov 26)

Fixed with tests: first-sentence bold ends after a closing quote; a Why? panel that opens with a question bolds it, as the board does; revealed answers with inline fractions no longer overlap; the tap-back golden shows the landed state with the tint at full; parts keep the board's space after display maths.
Accepted, not fixed (rule 4, lead; searched the board files, the spec, patterns.md):
- Maths in a bold answer lead stays regular weight: the maths renderer has no bold weight for numbers. The words carry the bold.
- Phone cards and checklist rows run 3 to 4 px shorter than the board, and the phone side gutter is 24 (board 20): both follow from the live reader's text metrics and padding, kept per the decision above. Every row stays over 44 px.
- `|-15|` gets operator spacing, a line can break between "(" and its maths, and a long display formula shrinks to fit instead of wrapping: all are the live reader's maths behavior for every lesson, outside this build. Content can write `\lvert -15 \rvert`; noted for the lesson leads.
- The board's figures (number line, jump, discount bar, exponent, sentence head) are not in the samples as files, only as `ILLUSTRATION` comments; drawing them is content work for the lesson leads, outside the renderer.
- The checkmark inside the filled teal disc uses the page color in dark mode (board #10201C has no token; the design lint rejects literals).

### Completion is judged by

- Converter tests written first and shown failing; both converters agree on every lesson in `content/lessons` and every walk-through lesson on `content/lesson-walkthrough-cse-r1` (no error, every target resolves).
- Every old lesson in `content/lessons` converts byte-identically before and after (evidence pasted).
- Widget tests for each part and state, the tap-back (opens hidden steps, ends centered, tint then none; Reduce Motion outline), Reduce Motion end states, button placement check on wide.
- Goldens on the CI image: the four samples plus a worst-case lesson (3 pairs, 3 long checklist lines, a 7-step example, long words), phone 390 and wide 1440, light and dark.
- Side-by-side review against the board by a reviewer who did not build it; hosted CI green; `dart run tool/checks/run_checks.dart` clean.
