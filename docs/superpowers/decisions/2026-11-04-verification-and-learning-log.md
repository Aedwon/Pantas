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

## November 4, 2026: timing

Stages proposed, in one spec so he approves once: (1) content and navigation checks and the reviewer proof rule; (2) the shared log and backfill; (3) browser checks for every page and the feature map; (4) daily review of real use.

Options offered, with costs:

1. Staged around beta (recommended): stage 1 and five core journeys by Nov 7, the rest of stages 2 and 3 during beta week, stage 4 after Nov 15. Cost: full scope finishes after the beta.
2. All before beta: everything by Nov 7. Cost: competes with deployment for his approval time, and stage 4 gets built without real data.
3. All after beta: starts Nov 16. Cost: no disruption, but the beta runs without these checks.

Aedwon's exact answer: "All after beta"

Result: no stage starts before November 16. The beta (Nov 9 to 15) runs without these checks. Mistakes from beta week are not lost, because the backfill reads the same records.

Open design questions, for whoever resumes:

- Approve the policy change: scripted pass or fail only, with screenshots saved only when a check fails. CI logs and artifacts are public, so test data only.
- Does a failed journey block a merge into the staging branch?
- Daily review: report only, or may it also draft fixes? Where does student data live, given the public repository? Which quota does it spend?
- Question reports stay on the student's device today. Does stage 4 include the app and copy change to send them?
- Which errors reach us from web? Not yet checked.
- Test first whether browser scripts can use the web app, which does not turn on its accessibility layer by default. The result may change the estimates.

## November 4, 2026: design paused

Question: "Should the remaining design questions wait until November 16?"

Options offered, with costs:

1. Pause until Nov 16 (recommended): his approval time stays on the beta, and real beta data can shape the daily review. Cost: the build starts a few days after November 16, once he approves the spec.
2. Finish design now: about six more questions and a spec review before the beta, so the build can start on November 16. Cost: answers about the daily review may need redoing once beta data exists.

Aedwon's exact answer: "Pause until Nov 16"

Result: PAUSED. No spec, plan or build until he resumes it on or after November 16. Next action on resume: reread this log, refresh the policy from main and the facts from the then-current engineering branch, then continue with the open design questions above.
