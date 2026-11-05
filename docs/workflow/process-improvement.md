# Process improvement

Applies to every agent on Pantas. When Aedwon finds work unsatisfactory, the fixed
problem must not be able to return. The default answer is a check that fails on the
bad version and passes on the good one. A written rule is the fallback, for matters
of taste a check cannot judge.

## When it applies

Aedwon rejects, corrects, repeats himself or sounds frustrated. His reaction counts,
not the agent's opinion of whether the work was fine. "Log this" forces an entry.

Write the entry in the same turn, before continuing with anything else.

## What an entry holds

- His exact words. If they are not recorded, say so; do not reconstruct them.
- What was wrong.
- Why the process let it through.
- The fix. "Be more careful" is not a fix.

## Choosing the fix

Take the first of these that can work:

1. **A check**, shown failing on the bad version first. Code, text and content checks
   go in `tool/checks/`, one file each, with a test on a sample of the bad pattern.
   Journeys go in `tool/journeys/`. Each names the failure it came from.
2. **A required step** before saying work is done, named in the entry.
3. **A written rule**, with the reason no check is possible.

A repeat of the same kind of failure must move up this order. A check with false alarms
gets ignored: tune it, or drop it and say why.

## Telling Aedwon

He gets one line per entry. He approves only changes to how agents work with him. Checks
and required steps do not wait for him.

A handoff cannot close while an entry lacks its fix.

## Active written rules

At most 15, read at startup. A rule retires when a check enforces it. If adding one would
pass 15, retire or merge one first.

1. On wide web, the phone version is the reference for motion. Where the phone animates,
   wide web animates. No check can judge this: whether motion is right is his call.
2. Do not remove motion he approved or asked for without his approval. A sweep item or a
   performance finding is not approval. No check can tell a deliberate removal from a
   mistake.

## Entries

Newest first. When this file passes about 120 lines, move the oldest closed entries to
the current decision log.

### CSE showed the app's subjects, not the exam's parts (Nov 6)

- **His words:** "is this the actual subjects of CSE Professional?"
- **What was wrong:** Study grouped CSE topics under shared headings that are not the exam's parts. The sweeps never compared them with the CSC's scope, and agents had the announcement open.
- **Why the process let it through:** sweeps check screens against boards, and no check compares exam content with its official scope.
- **Fix:** a test that fails if a CSE heading is not one of the CSC's parts.

### Founder evidence was treated as unofficial (Nov 5)

- **His words:** "it is official because a lot of people are posting the same thing after they got their results. it should not wait for after beta"
- **What was wrong:** the lead weighed its web search above what Aedwon sees from examinees, and pushed the work past the beta.
- **Why the process let it through:** nothing says how to weigh his first-hand evidence against a search that finds nothing.
- **Fix:** written rule, since no check can judge this: a source's silence does not contradict what Aedwon reports from users. State the uncertainty once, and follow his call.

### A bug was handed off instead of reproduced (Nov 5)

- **His words:** "well why didn't you find it"
- **What was wrong:** Study days came back empty after a reload. The lead gave the bug to Codex, which read the code, could not run a browser in its sandbox, and reported no cause. The lead passed that on as "not fixed" without reproducing it. The real cause was found within minutes of tracing it in a browser: Drift does not flush a commit on IndexedDB, so the last write before a reload or a closed tab was lost, and not only on this step.
- **Why the process let it through:** nothing required a reproduction before reporting a cause as unknown.
- **Fix:** browser journey "The last answer survives a reload" in `tool/journeys/journeys.mjs`. Written rule: do not report a browser bug as unexplained until it has been reproduced in a browser with its state logged. A sandboxed agent's "no cause found" is not a result.

### Fixes reintroduced a Pro failure (Nov 5)

- Words: none recorded on this failure alone. He had said "i do not want this to be a
  problem when I check".
- Wrong: the sixth sweep found that once Pro held across a reload, a Pro student was
  asked "Choose which progress to keep" on every start. After that fix, the seventh
  sweep found a Pro student reloading on a lesson got "Could not load this lesson" with
  no retry. A typed read of the sync table also failed on the first real row.
- Why: nothing re-ran Pro across a reload after each fix, so a later fix could break it.
- Fix: check. The Pro reload journey runs on every web push. `sync-mutations-typed-read`
  blocks the typed read and has a failing-sample test.

### Sweeps missed serious bugs (Nov 4 to 5)

- Words: "seems like a lot of bugs are being found. it tells me you haven't done enough
  and thorough enough inspecting/QA. i do not want this to be a problem when I check...
  do not stop until you are 100% confident in having me check."
- Wrong: the sixth and seventh browser sweeps, run after that message, still found serious
  bugs. The seventh found the Pro lesson reload failure.
- Why: a sweep only sees what the agent thinks to look at, and it ends when the agent stops.
  It left nothing behind that ran again.
- Fix: check. Three journeys on GitHub Actions, and `tool/checks/` in the static job for
  the failures sweeps found (`shell-route-push`, `lesson-list-exam-scope`, `bold-stem`,
  `mock-blueprint-topics`). Required step: a bug a sweep finds gets a check, if one can
  catch it, in the same commit as the fix.

### A Study motion removal contradicted his rule (this week, date not recorded)

- Words: not recorded in the launch log. Relayed by the lead when this process was set up.
- Wrong: a fix removed motion on Study that his rule said should stay.
- Why, inferred and not confirmed: the agent worked from a finding without the rule in
  view. Rules lived in the conversation, not in a list read at startup.
- Fix: written rule 2. No check can judge intent. If this repeats, move up to a required
  step: state which motion a change removes, and quote his approval.

### Motion missing on wide web (this week)

- Words: "put animations where there are animations in the phone version" (relayed by the
  lead). In the launch log: "some animations, even the most little ones that would
  greatly elevate the quality of the app, don't appear."
- Wrong: wide web lacked the slides and fades the phone has, including the tab bar and
  selections.
- Why: no step compared wide web motion with the phone. Screens were judged still.
- Fix: written rule 1. Whether motion is right is a judgment a check cannot make.
