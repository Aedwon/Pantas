# Lesson walk-through samples and board (E-156), Nov 25

Lesson walk-through lead, board only, branch `content/lesson-walkthrough-r1`. Policy read from main at 54b550f48
(estimate pushed as 5eba5054b). Nothing is built in the app and nothing ships.

## What was asked

His words, in order (Nov 25, about 4:45 to 5:00 AM Manila): "i found some lessons could use more detail, or a sort
of 'walk you through it' type of teaching ...", then "close, but not as detailed as I'd like. you are allowed to have
numbers in core concept", then "get Neon Xhigh's opinion on this ... you are also okay in the clear to add
illustrations as necessary", then, after Neon's answer: "okay! idea sounds good. i need a rewrite of sample lessons
please, and show me claude design screens for your ideas with the rewritten lesson and UI or whatever additions you
recommend". Restated: rewrite sample lessons to a deeper walk-through standard and show them in the app's reader with
Neon's new parts on one Claude Design board.

## Outputs

- Samples (rewritten from the prod content source, `content/cet-bite-r1` d97de9415):
  `docs/content/walkthrough-samples/`
  - `signed-integer-operations.md` and `substituting-negative-numbers.md`: "Signed Integers and Substitution" split in
    two, as Neon proposed (group goes from 3 to 4 parts).
  - `discounted-prices.md` (CSE percent and word problem).
  - `finding-subjects-and-matching-verbs.md` (CSE grammar; tests whether the standard carries over to non-math).
- Standard draft: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part A for his approval,
  Part B for agents). Not added to the lesson style guide.
- Board: Claude Design canvas "Lesson Walk-Through Samples", https://claude.ai/artifact/7hd4pLNonSKfmrbs9kyePu
  (private until he shares it). Pages: Signed Integers (live, A, B), Discounted Prices, Finding Subjects, New parts
  every state, One choice for you. 81 artboards; lesson frames are interactive (Show answer, Why?, Try the last step,
  Next step); a Reduce Motion frame and static state frames. Built from the exported approved reader screens
  (`RD_Real`, `RD_RealDark`, `RD_ReaderPart`, `W_Reader`, `W_ReaderDark`, `RD_Focus`; reader variant C CSS), figures
  in style D with theme colors. Source files and generators are in the lead's scratchpad (disposable); the canvas holds
  every file.

## Checks

- Independent Sonnet checker recomputed every number, step, Quick Check, Check line and trap claim from scratch with
  Python: all matched. It found 3 major and 6 minor issues, all in wording or rule completeness (grammar: "three
  verbs" listed two; a false have/has check line; the of-phrase shortcut missed some/most/half). All fixed except two
  minor exam-realism notes (Discounted Prices Example 1 stays the warm-up; grammar now has a third, exam-style example).
  A second pass on the changed text found no findings.
- Style: no em dashes, no `\frac`, American spelling, numbers in math, no tables, links or code blocks.
- Headless render (manager request, Nov 25): all 81 artboards rendered with the repo's board-capture approach (loopback
  server, local Geist, the export's `support.js` runtime, `--use-mock-keychain --password-store=basic`, browser closed
  after). Sheets, one per page: `build/walkthrough-board/sheet-{signed,discount,grammar,parts,choice}.png` in this
  worktree (gitignored). Every frame was refit to its rendered height; final run: 81 rendered, 0 errors, 0 clipped,
  0 with over 130 px of empty space, 0 serif fallbacks. The runtime is the export's copy, not the canvas's own, so the
  live canvas may differ slightly.
- Fresh Sonnet reviewer on the sheets: no blockers. One major (a Check line under "Try the last step" gave the answer
  away) and five minor findings (Check button enabled on an empty field, tiny bullets, exponent figure minus sign and
  border, uneven step gaps, "1." answer read as a list number), all fixed; the reviewer confirmed each on the
  re-render and found nothing new. Accepted as is: 42 px small tertiary buttons (Next step, Show all steps), allowed
  for section actions by patterns.md. Also fixed during the render: the Reduce Motion prop never reached the lesson
  body (camelCase attribute), now kebab case and confirmed.
- Content changes from the review: in each Try block the Check line moved inside the hidden answer; number answers
  start "The answer is ...". Word and screen counts in the spec were re-measured after these changes.

## Lead decisions (recorded here and on the board)

- Next step reveal applies to solutions of 4 or more steps, with "Show all steps" beside it.
- Discount bar and sentence-head figures (beyond Neon's three).
- Reveal motion: 240 ms height with the house curve and 180 ms fade (from the motion notes); Reduce Motion shows the
  end state at once.
- New cards use the reader surface, 1 px edge, 16 px radius; the Why? panel uses the Solution inset look; the Wrong row
  uses a neutral cross, not red.
- Reading-time minutes removed from the reader meta (figure rule and the bite-sized label ruling); the meta shows the
  part only, with no question count because the new lessons have no real counts.
- Discounted Prices: the live "Mnemonics" section was not a mnemonic; it became Way 2 in Core Concept.

## Open for him (through the manager)

1. Length: count only words visible before a tap and raise the cap to 900 (recommended), or keep the caps and split
   further. The rewrites show 515 to 875 words before a tap; the live lessons are 249 to 345. Phone screens (390 wide,
   default text): live 2.9 to 3.0; rewrites 4.7 to 8.3 at rest, 6.9 to 10.6 with everything opened.
2. Quick Check: A, tap to show the answer (recommended), or B, type the answer and the app checks it.
3. Approval of Part A of the standard. After it: add the rules to the style guide, write a build spec for the renderer,
   importer and checks, then plan the rollout.

## Standards applied

- Instructional design: ID-WORKED, ID-RETRIEVE, ID-TRY, ID-EXPLAIN, ID-ERR-FIX, ID-SEGMENT, ID-SIGNAL, ID-COHERE,
  ID-MEDIA, ID-SPATIAL, ID-PRETRAIN, ID-FB-ELAB, ID-FB-CHUNK, ID-FB-TASK.
- Long-form reading: READ-REFLOW, READ-FIG-NEAR, READ-FIG-SIZE.
- Web interface design (accessibility): WEB-C1, WEB-C2, WEB-C6, WEB-M1, WEB-M6, WEB-M9, WEB-I10, WEB-A1, WEB-A3.
- Project: AGENTS.md voice and math rules, lesson and question style guides, design/system/patterns.md, figure style D
  with theme colors.
- The instructional-design sheet already existed, so no new sheet was written. No sheet exists for mobile app design
  (listed in the library README as missing); the long-form reading and web interface sheets covered the phone reading
  rules used here.

## Process

- The Nov 25 process entry's required step ("walks through every rule with numbers in Core Concept, each move on its own
  line, why, wrong next to right, a check") is applied in all four samples. His reaction sets the standard; the entry
  stays open until then.
- Workers: 3 Sonnet runs, never more than 2 at once, no subagents of their own.

## Round 2 and parking (Nov 25)

- His words, relayed by the manager: "okay your reco sounds good. what does neon think of this?" (traps inline as pairs,
  end checklist), then "cool, sounds very good to me. let's spec this first. i don't think i have the proper usage to do
  these changes. let's prioritize release with current content first".
- Done: the four samples now carry 2 inline pairs each, each backed by a real wrong quiz choice, and a cue-plus-right-move
  checklist at the end. The spec is finished: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Part A
  for his approval, Part B for agents, both picks with recommendations, board status).
- Stopped on his change of plan: board round 2 (no render, no reviewer, nothing published). The board stays at version 5,
  round-1 layout; the spec lists the frames that still show the old trap layout. Round-2 content was recomputed by the
  lead only; an independent recompute is due on resume.
- **Lane parked until he resumes it.** Nothing is in flight. No keep-alive is running. Scratchpad board files are
  disposable.
