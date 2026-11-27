# Operations manager handoff (Nov 26, about 7:30 PM Manila)

Manager thread: `mcp:launch:00976645432b2f793e42bfeeea73583c727484762376837beea722b8a3c65b8d` (retire it after takeover). Read first, from main: AGENTS.md, WORKFLOW.md, `docs/workflow/operations-manager.md` (lanes table current as of Nov 26 3:40 PM; update it), `docs/workflow/process-improvement.md` (all rules and every Nov 21 to 26 entry; Nov 26 added: wordy UI cut pass, walk-through example connection rule, silent spacer, wide Performance rows, guesses stated as fact, manager-run workers, shell commands that prompt him), and the "Aedwon's requests" table at the top of `docs/superpowers/backlog.md`. Previous note: `2026-11-26-operations-manager.md`.

## Opening: Saturday Nov 28, 6:00 AM Manila (his "make it Saturday 6 AM")
- Opening build complete on main, CI green: legal texts dated Nov 28, the batched fixes, Pro flicker fix, wide Performance (Overall above tabs, "(N)" counts), his Pro wording and the phone green on wide, the lesson walk-through renderer (old lessons byte-identical on all 1,271), the Quiz tab count fixes. Website homepage branch head set (his approved Free and Pro section with "Everything in Free" as Pro's first item, open book under Free, no BIR badge, no "No ads").
- Release lead r9 handoff: `docs/superpowers/handoffs/2026-11-26-cse-release-lead-r9-opening-prep.md`. Scheduled: Fri 7:00 PM restart r10 fresh; 7:30 PM rebuild; 8:00 PM final staging proof; 7:45 PM manager backup check. r10 sends go or no-go and the hour of each opening step.
- After the opening (his "A"): no prod web update until service worker option A passes audit and a 48-hour staging soak, unless urgent with his approval. Content uploads allowed (walk-through lessons go live that way).
- Hold: do not deploy checkout or guardian functions from main before the opening step (date mismatch blocks checkout).

## Live today
- Live payments on (his ₱49 QR Ph test passed). Webhook events: paid, refunded, refund updated only; he checks PayMongo disputes daily.
- Mock navigation fix (3:20 AM), first-run and his refinements (4:58 AM), "kuwento" answer key (1:33 PM).

## Lesson walk-through rewrite (approved; board round 2 "layout approved")
- Example rule approved ("yes that's it!"): one short lead-in, every chain ends at its value, no added words. Quick Checks use a fresh instance.
- Claude lesson lead `mcp:launch:d0b92d05876bd9854657cafae346820c99095f72f43494be336846fad3ba9c63` (branch `content/lesson-walkthrough-cse-r1`, handoff `docs/superpowers/handoffs/2026-11-26-claude-lesson-lead-cse-walkthrough.md`): Grammar and Vocabulary to Codex about 8 PM; then Math, Language Application, Reading Comprehension. About 10 h left.
- Gemini GI lead `mcp:launch:b0df58086776a5a77d6f3512e73088175546b9de53242fd3645752a166cae361` (branch `content/lesson-walkthrough-cse-gi-r1`, General Information only): 46 of 170 verified; Batch 6a waits for Codex. Quota stops every ~1 h; resume scheduled 8:50 PM.
- Codex: only account b (a and c have no subscription). His words "86% in weekly is plenty. exhaust it". b at 94% weekly, resets Mon Nov 30 6:06 AM; after it runs out, Fable 5.2 high audits, and Codex re-audits Fable-passed batches after Monday.
- Nothing goes live until a batch has its audit PASS; then content uploads through the release lead.

## Waiting on him
- A small hook that refuses shell commands which would prompt him (about 20 lines, 30 min): asked, no answer yet.

## Decisions he made Nov 26 (all in the launch log)
Alert email confirmed; service worker: open on today's worker, fix after (two Fable consults); update-loop findings "A"; daily plan stays free; no Free backup expansion; BIR badge off and image deleted; homepage wording, Free and Pro section and his own list text; Performance sheet passed; wide Pro green passed; walk-through board approved; Claude takeover of lessons; Gemini for General Information after its reset.

## Schedules bound to the manager thread
Heartbeat every 55 min (prompt current), housekeeping 4 AM, daily sweep 1 AM, DMARC Nov 28 10 AM, Dec 1 cost check, Dec 5 plan cost check, Fri 7:00 PM r10 restart, Fri 7:45 PM final-proof backup, Gemini GI resume 8:50 PM tonight. Rebind all to the new thread at takeover.
