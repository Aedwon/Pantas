# Operations manager handoff (Nov 25, 12:30 AM Manila)

Manager thread: `mcp:launch:2f628e2495c6e1411884e3ca9e4a1bdc13467273ae2643e58f0fdb984177a926` (restarted with a blank memory per the Nov 24 process entry). Read `docs/workflow/operations-manager.md` and `docs/workflow/process-improvement.md` first.

## His standing words
- Nov 24 ~4:10 PM: "just ship it please, temporarily drop the rule, do not wait for me as the bottleneck." Covers only changes built to boards he approved, server work and fixes (Nov 24 entry). New looks go to him as a board first.
- Nov 24 7:40 PM: "yes they should stop. go with prioritizing UI improvements please. i want the fixes shipped immediately". Legal texts and payments are PAUSED by him.
- Nov 24: every new task starts with a blank memory (`freshContext: true`), ends with a note in this folder.
- Replies: plain words, under 150 words, Manila times, no hashes, codes, file or function names. Show pictures, not descriptions ("you should show me instead of telling me"): use html_preview/html_render with real captures (golden images, renders), or open the board artifact.

## Live on prod (all verified on app.pantas.study)
- Nov 24 5:54 PM: big update (reader, report sending, part labels removed, guardian cleanup, trial expiry, NPC alert).
- Nov 24 9:50 PM: quiz bar to his own design (no dashes, no hints, flag centered), no Close area under lesson contents, Discard centered.
- Nov 25 12:10 AM: Study and Quiz spacing, splash centered on wide web.

## Leads
- CSE release lead: `mcp:launch:89c734558b4268cc20e870fa5fbd7e5395d6da9eeb6c0759940bd95f7e4b7fa0`. Running: board-drawn minors (T7 to T9), pulley figure fix, and T11 tester-only items (manager ruling: keep the sign-in gate, beta screens, BETA mark and link-preview image; remove tester-only Home notices, Feedback row and survey pages, expired Beta Pro switch, if no tester loses earned Pro). Notes: handoffs dated Nov 24 and 25 in this folder.
- UX lead: `mcp:d8548b12-d7ea-4fd6-8dc3-919a8b8c0570`. Running: one board with options for the delayed loading indicator, the reader progress bar, and long exam names in the Home week strip. Show it to him when it lands (Artifact open).
- Security lead r2: `mcp:launch:e29d46394b524c9bb1b3efca97421eeae55d54872d03697127a873b07e99ebc5`. PAUSED by him. PR #91 and #109 unmerged; lost-dispute follow-up fixes needed before live keys. Codex security adjudication landed: ~/Documents/Projects/Pantas-private/audits/2026-11-24-codex-b/adj-security-full.md (20 confirmed).
- Old leads, never message: `mcp:launch:b14e5d0e...`, `mcp:bc3317cf...`.

## Waiting on him
- Paused-session board https://claude.ai/artifact/9MLsiFtEwsdLodfe8eHZig: options A (recommended), B, C. Plus two bugs to fix either way: sheet shows 0 of 11 after an answer; Close on the Reviews sheet.
- Google Analytics retention 2 months with "Reset user data on new activity" off, and Gmail labels pay-2y and hold (both block the legal pages).
- Opening sign-up to the public (removes the beta gate): needs legal pages, launch caps (500 or 5,000), under-18 choice (C recommended).
- LGU permit then NPC, one Google sign-in on app.pantas.study, Safari reader check, deleting 12 old canvases.

## Other state
- Codex b audits done (queue empty). CET answer-key triage: ~/Documents/Projects/Pantas-private/audits/2026-11-24-codex-b/CET-TRIAGE.md. CSE content fixes wait after UI (release lead note, velocity E-145).
- Schedules bound here: heartbeat every 55 min (enabled), daily sweep 1 AM, housekeeping 4 AM, Dec 1 cost check.
- Disk: about 15 GB free after cleanup; leads clear their own build output.
