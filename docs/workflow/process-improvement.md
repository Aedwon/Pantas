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
3. Boards for UI decisions are built in Claude Design (a Design Artifact), starting from
   the approved screens in the Pantas Web and Pantas Redesign canvases (exported copies in
   `web-design/pantas-handoff/`). Never hand-draw a local HTML board or redraw a screen from
   widget code. No check can judge fidelity: he does the visual check.

## Entries

Newest first. When this file passes about 120 lines, move the oldest closed entries to
the current decision log.

### Lead forwarded an approval Aedwon never gave (Nov 7)

- **His words (relayed by the design-system session):** "no i didn't approve anything you've sent, i was commenting on" the design-system plan summary.
- **What was wrong:** the design-system session told the lead that Aedwon had approved a Tester Guide row in Settings ("yes good"). The lead searched the decision log, did not find those words for that item, and forwarded the request to the Feedback (Beta) session anyway, marked only as relayed.
- **Why the process let it through:** nothing required a session to confirm an approval against the log before acting on another session's report of it.
- **Fix:** required step: a session acts on another session's report of an approval only after it finds Aedwon's exact words for that specific item in the decision log; if they are missing, it asks Aedwon or the reporting session and does nothing meanwhile. The lead withdrew the row and holds `web/design-system-r1` until each of its changes shows his words in the log.

### A bundled item was logged as approved (Nov 7)

- **His words:** "no i didn't approve anything you've sent, i was commenting on" the design-system plan summary.
- **What was wrong:** the lead's reply laid out the design-system plan and, in the same message, said a Tester Guide row would be added to Settings before Nov 9. His "yes good, include animations, motion, movement, etc" answered the plan, but the lead logged it as approving the row too and had it sent to the Feedback session for building.
- **Why the process let it through:** nothing says an approval covers only what his words answer, and a long reply let a side decision ride along with the main one.
- **Fix:** required step. A change counts as approved only when his words name it, or answer a question that asked about that change alone. Never put a side decision inside a plan he is asked to accept; ask it separately. Before logging an approval or dispatching work on it, quote the exact words and the item they answer.

### Beta notice board adapted carelessly (Nov 7)

- **His words:** "lol this is the type of UI that made me realize we needed a robust design system in the first place. this looks terrible"
- **What was wrong:** the "Welcome to the Pantas beta" Home notice board copied HM_ProWelcome and swapped in longer copy. The button pair then wrapped: Got It floated beside the text and Read the Guide dropped to its own line at the left, against the placement rule he had just approved (P2). Got It kept the light-mode gray, so it looked disabled on dark, and a stray ↗ glyph and the collapse arrow added clutter.
- **Why the process let it through:** written rule 3 makes boards start from approved screens, but nothing says to re-check an adapted board's layout once its copy or theme changes, and there is no written notice component to build from.
- **Fix:** required step (a repeat of the board-quality failure on the splash board, so it moves up from a written rule): before showing an adapted board, the lead lists each changed text block and button group, confirms every button group keeps its order and alignment at the frame width in each theme shown, and names the approved board and the design-system rule it follows in the board's note. The design system being built (Pantas Design System canvas) defines the notice anatomy so boards use it rather than a copied screen. The board was rebuilt (canvas version 5).

### Splash board hand-drawn, not built in Claude Design (Nov 7)

- **His words:** "what is that ew, why didn't you use claude design, and the fidelity is awful from the actual thing"
- **What was wrong:** for the splash hand-over decision the lead had a subagent hand-draw a local HTML board, redrawing Home's skeleton and chrome from widget code. It looked nothing like the real app.
- **Why the process let it through:** `docs/workflow/visual-companion.md` asks for fidelity but does not name Claude Design or the approved canvases as the source, and an older local HTML board (b5-splash-v1) was copied as the template.
- **Fix:** written rule 3 above (fidelity cannot be checked by a script). Required step: before showing a board, the lead names the canvas boards it was built from in the board's notes. The rejected file was deleted.

### Home could not load the plan on first use (Nov 6)

- **His words:** "when i finally got around to the Home for the first time, the screenshot shows what I encountered. please fix this" (Home showed "Could not load your plan." twice).
- **What was wrong:** `getRoadmap` and `setExamSettings` run a range query on today's study history (`examId ==`, `occurredAt` range). Production had no composite index for it, so both failed with FAILED_PRECONDITION.
- **Why the process let it through:** the Firestore emulator does not enforce composite indexes, so every local and CI test passed. The post-deploy live step added earlier the same day covered sign-in only, not reaching Home.
- **Fix:** the index is added and deployed, and `test/tool/firebase_indexes_layout_test.dart` now requires it (it names this failure). Required step widened: after a production deploy, the live check goes through onboarding to Home with an owner test account, and the agent reads the production error log for `FAILED_PRECONDITION` before saying it is ready.

### Beta sign-in shipped broken: codes never sent, Google sign-in left the domain (Nov 6)

- **His words:** "why does it do this unclean redirect" and "the reason i tried to sign in was because i couldn't manually use my own email". Then: "please note this problems on main first".
- **What was wrong:** The email code sign-in was deployed to pantas-prod and announced as ready, but every code request failed. The callables consume App Check tokens, and the functions service account lacked `roles/firebaseappcheck.tokenVerifier`, so the server rejected every call with "We couldn't send the code." The beta access check has the same dependency. Separately, Google sign-in used `pantas-prod.firebaseapp.com` as the auth domain: Google's page said "continue to pantas-prod.firebaseapp.com", and inside Messenger's in-app browser the hand-off page stayed blank.
- **Why the process let it through:** The deploy was gated on CI and unit tests only. Unit tests fake App Check and IAM, so a missing production permission cannot fail them. No live call was made against production after the deploy, and the custom domain was added without moving the auth domain to it. Aedwon had said he would do the visual check; that was read as covering whether the flow works at all.
- **Fix:** (1) A check: a deploy preflight under `tool/checks/` that reads pantas-prod IAM and fails when a callable with `consumeAppCheckToken` is deployed without `roles/firebaseappcheck.tokenVerifier`, or `createCustomToken` without `roles/iam.serviceAccountTokenCreator`, on the functions service account. (2) A required step: after any production deploy that touches sign-in, beta access or a callable, the agent makes one live call against production (request a code to an owner test address) and confirms success before telling Aedwon it is ready. His visual check never replaces it. (3) The web auth domain is the custom domain on every hosted flavor.
- **Found while fixing:** returning visitors kept the old app. Flutter's service worker version ignores Dart-only changes, so the worker served its cached `main.dart.js`, and root scripts were also cached for an hour. Fixed with a post-build stamp (`tool/web/stamp_worker_version.mjs`, tested) and `no-cache` on root scripts.
- **Done (Nov 6, branch web/visual-check-fixes-r1):** token verifier role granted; `tool/deploy/prod_iam_preflight.mjs` with tests, wired into the deploy steps in `docs/deploy-prod.md`; auth domain is app.pantas.study with the OAuth origin and redirect added; a live code request against production succeeded.

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
