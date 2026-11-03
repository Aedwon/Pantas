# Verification and learning: decision log

Started from Lauren Tan's public principles on agentic software engineering, as summarized by Grok
and pasted by Aedwon. Policy read from `origin/main` at 6d3dec73. Engineering facts read from
`origin/web/staging-candidate-r1` at 5558a1c3. Spec not yet written.

## November 4, 2026: what to apply to Pantas

Aedwon's exact request: "now, if there are things we could apply for Pantas, then it would be good. let me know what you think we should apply given the current state of the project and also considering future plans"

Findings given first:

- The web CI builds the app but no script uses it as a student would. The release end-to-end tests are not in CI. The lost payment return (Nov 3) passed the automated suite.
- The content checks are not in CI. The rule on `context.go` is written guidance only; 23 files in `lib` use it, and some uses may be valid.
- Nothing is limited by agent capacity. The limit is Aedwon's approval time (Nov 3 finding).

Recommended: (1) scripted checks of real student journeys on the web build on hosted runners; (2) turn repeated mistakes into checks; (3) after the beta, a daily review of real use. Advised to skip: installing pstack (a Cursor plugin, and the workflow already covers most of it), mass parallel agents, formal models such as TLA+, and less human review.

Costs offered:

- Minimal: item 2 only. About half a day.
- Balanced (recommended): items 1 and 2, with five journeys. About 1 to 2 days.
- Hardened: Balanced, plus every page, a maintained feature map, and the daily review. About 3 to 5 days.

Policy decision named for him: item 1 changes the workflow's bar on autonomous visual review and app screenshots. Recommended: scripted pass or fail only, with screenshots saved only when a check fails. Not yet separately answered; it goes in the spec's approval section.

## November 4, 2026: how the Grok summary was checked

Mistake: the lead checked Grok's summary against one secondary article and reported that the article did not mention the "inverse pyramid" and undercut Grok's account of adversarial review.

Aedwon's exact comment: "grok's sources are X posts"

Result: X refused the two posts tried (HTTP 402), so they remain unread. The pstack repository README supports both points. Its `/correct` skill fixes a repeated mistake at the highest level that works: architecture, then types, lint and CI, then tests, with docs last. Its `/interrogate` skill has different models try to break a diff and keeps only findings a run proves. The lead withdrew the doubt.

Two additions offered: mine the history for repeated mistakes, and for code, count a reviewer's finding only if a run proves it. Answer key audits stay as they are.

## November 4, 2026: reviewer proof rule

Aedwon's exact comment: "okay on the second point"

Result: accepted in substance. It takes effect through the spec, not before.

## November 4, 2026: a log of mistakes and wins

Aedwon's exact comment: "mine the history: i think this can be more systematized with logs? basically we're accruing/accumulating data for mistakes/wins yknow, and use that as basis? can apply for a lot of things or everything. let me know what you think"

Offered: one shared log, one line per event (date, area, type of mistake, how it was caught, the fix), added at a failed review or CI run, a correction from Aedwon, or a reversed decision. Wins are measured as first-try results. At three repeats, a mistake type gets a check or a written reason for not adding one. Uses: code, content, model choice, previews. Limits: the repository is public, so no student data; small counts prompt a review and never overrule Aedwon's call from using the app; about half a day more, including one noisy backfill. Pushed back on logging everything: log only what can change a decision.

## November 4, 2026: scope

Question: "Which scope should I write the spec for, with the shared log included?" Options: Balanced or Minimal.

Aedwon's exact answer: "i think we go hardened on this. also wdym workflow bars new parallel tracking"

Result: hardened, as described in the costs above, with the shared log, the proof rule and the history mining included. This is a choice of scope; the spec's approval section is still pending.

Mistake: the lead said the workflow "bars new parallel tracking" and that the log needs an exception. The sentence is "Reuse existing records, not a new parallel tracking system," in the section on status and decision records. It is aimed at duplicate status and decision trackers, so "bars" overstated it. The overlap is real, because decision logs already hold mistakes and reversals. Proposed: decision logs remain the record, the new log holds one-line entries that point to them, and the spec adds a one-line clarification to the workflow.
