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
