# UX lead: lesson walk-through board round 2 (E-188), Nov 26

Policy read: `Aedwon/Pantas` main ac22a23d5 (estimate pushed as 36b0c7e9e). Spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`
and samples `docs/content/walkthrough-samples/` on `content/lesson-walkthrough-r1` ab6b4cc84. Nothing built in the app.

## What was asked

Manager brief, Nov 26, with his words: Nov 25 "i am approving the lesson walkthrough standard. i think we have enough usage to implement it for CSE / please queue this ...";
Nov 26 "for lesson walk through, have it completed fully by Gemini 4 Neon Xhigh as lead and its own Gemini subagents. it can use codex for checkpoint audits." and
"just to be sure i'm authorizing gemini models for rewriting the lessons, not the UI itself. as a rule, Claude is still on UI". Restated: a Gemini lane rewrites the CSE
lessons; the UX lead (Claude) owns the reader UI, starting with board round 2 for his look.

## Output

Board "Lesson Walk-Through Samples", https://claude.ai/artifact/7hd4pLNonSKfmrbs9kyePu, version 8 (1795635636-c68c). Pages:
Signed Integers (two lessons), Discounted Prices, Finding Subjects and Matching Verbs (phone and wide, light and dark, all interactive),
New parts, every state, and Shared pieces (the figures and lesson bodies the frames import; nothing to review).

Round 2 changes:
- Right-and-wrong pairs at their steps, from the round-2 samples (2 per lesson, 8 total). Right in a card with a teal check; Wrong under it,
  no card or border, secondary color, one size smaller (16 wide, 15 phone), neutral cross; note under both. Stacked at every width.
- Traps to Watch For is a checklist (3, 3, 2, 2 lines): rows at least 44 px, cue semibold, right move after it, up arrow at the right end.
  Tap scrolls to the pair or heading; a teal tint behind the target fades over 1.2 s after a 300 ms delay (scroll time). Reduce Motion: instant
  jump and a static 2 px teal outline. A target inside hidden Next-step steps (Substituting Negative Numbers, minus-before-negative) opens all steps first.
- New state frames: pair (phone and wide, light and dark); checklist rest, first line pressed, wide; tap-back tint and Reduce Motion outline.
- Removed as holding no choice: live-lesson frames, the Quick Check A/B choice page (he took A), standalone figure frames, Quick Check tapped and
  Reduce Motion duplicates, and dark copies of round-1 part states (the dark lesson frames show them). Reading notes cut to behavior the frames cannot show.
- All tertiary buttons (Why?, Show all steps) now 44 px tall (reviewer finding; the phone Next step pair now matches in height).

## Lead decisions (rule 4; search: the walk-through spec UI section and Board status, patterns.md button placement, the Nov 23 to 26 process entries)

- Right card uses the neutral card edge, not a teal border; strength comes from the card, teal check and label.
- Tint delay 300 ms before the 1.2 s fade, so the tint is visible when the scroll lands. Heading targets get the same tint.
- Wrong text on the full tint in light mode is about 4.3:1 for the first moments of the fade; accepted as brief.

## Checks

- Every frame rendered headlessly (loopback server, the handoff `support.js`, Playwright 1.64 from an existing install, `--use-mock-keychain
  --password-store=basic`, browser closed after): 48 frames, 0 errors, 0 raw template text, every frame refit to its content height.
- Tap-back tested in a headless browser: Signed B line 3 opened all steps and centered the pair with the fading tint (opacity 0 after the fade);
  Reduce Motion frame showed the static outline.
- Fresh Sonnet reviewer (did not build it): content matched the samples word for word; every number recomputed correct; no internal terms, em
  dashes or British spelling in UI text. Its findings (42 px buttons, internal frame titles on component frames, notes repeating titles, frames
  with no choice) were fixed before publishing.

## Next

Waiting on his answer, relayed by the manager. After approval: build spec and plan for the renderer and the importer (the spec's `:::` blocks)
with tests, built by up to 2 Sonnet workers, side-by-side review at phone and wide, CI green, hand to CSE release lead r8. Block syntax is
coordinated with the Gemini walk-through lead through the manager. Board scratch files: the session scratchpad (disposable); the canvas holds every file.
