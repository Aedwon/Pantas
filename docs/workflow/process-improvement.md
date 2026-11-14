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
4. Do not ask Aedwon to decide in-app copy that sits in a layout or component he already
   approved (a Dialog's title and text, a caption, a button label). The lead settles it under
   his delegation (D191), following the voice rules in `AGENTS.md`, records it, and tells him
   the wording. Website copy stays his. No check can tell a copy choice from a layout choice.

5. Never ask Aedwon to write legal or policy text (terms, privacy notices, legal bases,
   consent or refund wording). First search `docs/legal/`, `docs/legal-drafts/`, the app's
   legal documents on the integration branch and the pantas-web project; use what exists as
   the base. If text is missing, an agent drafts it to favor Pantas as far as Philippine law
   allows, Codex GPT 6.1 Sol at high effort critiques it through `codex-pick`, and he only
   checks the result. His words (Nov 9): "how many times does this have to pop up. has this not been written already? in the pantas-web project? if not, i already told you, you should have an agent write it for me instead. for these texts, have a codex 6.1 Sol High critique it. the angle should be that it's leaning in favor of us, to the extend PH law allows. do not ask me any text of this kind again. i cannot afford a lawyer. i should only check what you drafted" No check can tell when a question to him
   asks for legal text.

6. Every email an agent sends goes to aerol.balayon@gmail.com first: the exact final
   email (same template, subject, sender and links, personalized for one sample recipient),
   to that address only. Tell him to check his inbox. Send to the real recipients only after
   he confirms he received and checked that copy. If he says "send" before the self-test has
   gone out and he has confirmed it, do not send: send the self-test and remind him first.
   Covers beta, results, guardian, marketing and one-off transactional sends. Does not cover
   mail the product sends by itself (sign-in codes, guardian requests). His words (Nov 9):
   "by the way, i had a thought. when we send out emails, make sure to send it to me first as a prerequisite before sending to anyone else. this rule supersedes me even if i mistakenly request to send it without receiving the thing in my own email first. remind me to check first in my email before you send it, if this makes sense." No single check can cover it: sends run from different scripts and providers, some
   outside the repository. Each send script must refuse a real send without a recorded
   self-test of the same email version.

## Entries

Newest first. When this file passes about 120 lines, move the oldest closed entries to
the current decision log.

### Flat web update protocol could mix deployments (Nov 14)

- His exact words: "Lead ruling (final): replace the web-layer approach with VERSIONED BUILD FOLDERS, and keep the app-side safe points."
- Wrong: the reviewed client-version protocol could start old code under a new identity,
  guess a legacy client's build, fetch new bytes for legacy misses, and consume an
  update attempt while an installation was incomplete.
- Why: tests modeled legacy pages with a protocol those shipped pages did not have,
  assumed ready workers, and asserted permanent suppression after failed apply.
- Fix: replace that protocol with immutable versioned paths and verified retained
  hosting inventories. Existing CI runs the Node regressions in tool/web and
  test/web. The new regression tests failed against the old implementation first
  (10 of 11 web cases, all 3 retention cases); Dart retry failed first too. Additional
  review regressions cover incomplete installs, wrong bytes, offline index identity,
  legacy flat metadata, fonts, retry deadlines and stale output directories. No new
  human workflow gate. Evidence: docs/superpowers/verification/2026-11-14-versioned-web-builds.md.

### Parallel Codex runs drained every account and lost an audit (Nov 11)

- His words: "? terrible output from you. please log this in the process improvement log or some document that would prevent things like this from happening again in the future" (after the manager reported that its early Codex audit had stopped on the usage limit).
- Wrong: the operations manager started a long Codex GPT 6 Astra High security audit (planned 1 h 30 min) minutes after telling the DS4 lead to run its two tasks on Codex. Three high-effort runs went in parallel, one per account, and each filled its account's 5-hour window in about 25 minutes. The audit failed after 28 minutes with no report (codex-pick restarts a prompt from scratch on failover, and the audit kept nothing on disk), and the lead's withdrawal fix stalled half-built until the first reset. The manager had told Aedwon "Codex has room now" from a status taken before the other runs started.
- Why it got through: WORKFLOW says to check capacity and serialize shared accounts before dispatch, but nothing enforced it at the moment a run starts, and no one estimated a run against one account's 5-hour window. `codex-pick --status` shows room, not other runs in flight.
- Fix (a check, plus a required step):
  1. Check: `codex-pick` (in `~/.local/bin`, outside this repo, so no test file here) refuses to start while another codex-pick run is active, with exit 76 and a list of the active runs. `CODEX_PICK_PARALLEL=1` overrides it, only after `codex-pick --status` shows room for every run. Shown refusing a run started while a simulated audit was active, and passing with no active run or with the override.
  2. Required step before any Codex run expected to take more than 20 minutes at high effort: the dispatcher (manager or lead) checks for other Codex work in every lane, sizes the run against one account's 5-hour window (about 25 minutes of high-effort work was observed on Nov 11), splits a longer job into parts, and has the run append each finding to a file the moment it is found (Aedwon: "have it write as it discovers, not at the end"), so a limit stop keeps the work and the next run continues from it, and tells Aedwon the room only from a status taken after those checks.

### Founder boards: refund buttons and Numbers missed what he needs (Nov 10)

- His words: "terrible placement of buttons, optimize this to be more elegant and intuitive" (refund card board) and "i'm not satisfied with what statistics are shown here, and how they're shown. i should be able to see things like MAU DAU or something, users per exam, marketing things, etc. they're missing / what i'm pertaining to are data that would be useful to me to make decisions. this idea is still cloudy in my head and i don't have the vocabulary to express it, but i need data to base my decisions off of" (Numbers board).
- Wrong: the refund board stacked two numbered buttons in the drawer footer ("1. Copy Payment ID", "2. Open PayMongo") beside Cancel, so a step list was dressed as actions. Numbers showed only what data was easy to read (Nov 2 "Core numbers"), never what decisions he makes with it.
- Why it got through: the DS4 review checked rules (classes, colors, control types), not whether each overlay reads as one clear action; and the Nov 2 Numbers question offered data sources, not his decisions.
- Fix (required steps; neither can be judged by a tool): (1) every board review also answers "what is the one action here, and does the layout make it obvious?" and flags a footer with more than one primary or numbered buttons; (2) any dashboard or stats screen starts by listing the decisions he makes with it and the question each number answers, and he confirms that list before metrics are chosen.

### Asked him to decide copy in an approved layout (Nov 9)

- His words: "sorry what needs deciding on Decision 4? that's just a copy decision right not a UI one" (relayed by the manager).
- Wrong: the custom exam tier amendment listed the raise-tier dialog's wording as a decision for him, although the DS4 Dialog already fixed its layout. The board then carried it as "still open" for three rounds.
- Why it got through: the amendment's decision list treated every visible string as a decision, and nothing separated copy from layout.
- Fix (written rule 4 above; no check can tell a copy choice from a layout choice): copy inside an approved layout is the lead's call under D191, recorded and reported, not asked.

### Misread "not clean", and an overstated claim on a board (Nov 9)

- His words: "go with Placement 2. "shows every price note this way" can you please show me this / also when I said not clean enough, i meant the placement of Civil Service tag. it has a oval background that is also colored. idk i don't like that" (relayed by the manager).
- Wrong: (1) his earlier "not clean enough" was about the Civil Service tag's filled oval, but the lead redrew where the tier line sits and kept the same tag; (2) the board note said the fine-print line "sits where every price note in the app sits", which is overstated: DS4 and the approved boards use fine print for trial, renewal and pass-end lines under a paywall or upgrade button, while prices sit inside plan tiles and limit notes sit in card text.
- Why it got through: the complaint named a quality, not an element, and the lead picked the element without saying so; and no step checked a board's comparative wording against the sources.
- Fix (required step; neither can be checked by a tool): (1) when a rejection does not name the element, the next board varies each visible element on its own and labels which element each option changes; (2) any "every", "always", "like X" or "the same as" on a board names where it is true, or is cut. Both are added to the reviewer's brief for board reviews from now on.

### Custom exam tier boards not clean, and not on DS4 (Nov 9)

- His words: "3B but please improve the placements, i'm currently not liking the options. not clean enough for me. make sure the designs also follow DS4" (relayed by the manager, on the "Custom Exam Tier Picks" canvas).
- Wrong: the first boards put the tier line as a loose sentence between the subject grid and Continue, overrode the tile grid and laid out the pages with inline styles, redrew the old onboarding rail and logo by hand, and on the phone built checkbox rows from list parts where the system prescribes tiles for two to eight choices. No DS4 placement pattern (fine print, card footer) was used.
- Why it got through: the lead started from the pre-4.0 `OB_CustomCover` board and read component markup but not `patterns.md`; nobody but the author looked at the boards; and they were never rendered before sending, because the canvas type's "never verify" was followed instead of the Nov 9 screenshot exemption.
- Fix (required step; no check can judge whether a placement is clean, and the boards live in an artifact, not the repo): before any board goes to Aedwon, (1) every element on it is a DS4 component or pattern, and anything with no system part is labeled as board scaffolding on the canvas; (2) a fresh reviewer who did not draw the boards checks each one against the DS4 READMEs and `patterns.md` and lists departures, and every departure is fixed before sending; (3) one headless capture per board confirms it renders, then the browser is closed. If boards are later kept in the repo, a lint for inline style literals in board files can replace part (2).

### Legal text asked of him again (Nov 9)

- His words: "how many times does this have to pop up. has this not been written already? in the pantas-web project? if not, i already told you, you should have an agent write it for me instead. for these texts, have a codex 6.1 Sol High critique it. the angle should be that it's leaning in favor of us, to the extend PH law allows. do not ask me any text of this kind again. i cannot afford a lawyer. i should only check what you drafted"
- Wrong: the teen notice, the Terms web Subscriptions wording and the telemetry legal-basis
  line kept coming back to him as open items ("Still needs him or a lawyer", Nov 5; "Open:
  legal-basis line wording for Aedwon", Nov 7), although a Nov 5 draft existed in
  `docs/legal/drafts/` and all three texts were already built into the app.
- Why it got through: the Nov 5 QA ruling said "legal text is not rewritten by agents", and
  nothing told agents to search for existing drafts or to draft and critique legal text
  themselves.
- Fix: written rule 5. No check can tell when a question to him asks for legal text. The
  three texts were redrafted, critiqued by Codex Sol at high effort and put in one review
  file, `docs/legal/drafts/2026-11-09-legal-texts-review.md` on `docs/legal-texts-r1`
  (1eb945a93).

### Raw framework controls bypassed the design system (Nov 9)

- His words: "tsk, this may be the only thing that i've personally encountered but there might be other things that haven't been followed. are you joking? we built this system exactly for the purpose of making sure things like this don't happen. shouldn't the lint checks catch this? where did we go wrong? fix this" (with a screenshot of the reader's "< Study" back control showing a gray pill hover on staging). Then: "you haven't yet proposed what to do to avoid something like this in the future", "is this list the best solution? i mentioned linters but you never seem to acknowledge the idea", "how do we best ensure these mistakes and regressions and deviations from the design system doesn't happen again?"
- Wrong: about 180 raw Material controls (TextButton, IconButton, InkWell, TextField, SnackBar, Tooltip and others) in about 60 screen files drew Flutter defaults (stadium highlights, gray overlays) instead of the system components. The reader back control was one. The lead also answered his linter question twice with text-search checks.
- Why it got through: the design-system 4.0 drift check (`tool/checks/design_token_literals.dart`) banned typed values only, so a control with no literal passed; the theme set no Material component themes, so leftovers fell back to Flutter defaults; tests asserted no overflow, not appearance; reviews compared code to README text and never rendered output; batches deployed faster than he looked.
- Fix (checks, planned in `docs/superpowers/plans/design-system-4/guardrails.md`): (1) screens import a design-system barrel that hides raw Material controls, and `tool/check_layering.dart` bans `material.dart` imports in `lib/features/` and `lib/app/`, so a raw control in a screen does not compile; (2) a type-aware analyzer lint for design literals replaces the text-search checks; (3) component and key-screen golden images, audited once against the system's own previews and approved by him, fail CI on any visual change; (4) Material component themes fall back to the system look. Open until those land; the immediate sweep of the 180 controls was running when this entry was written.

### Backup page jumped while backing up (Nov 8)

- His words: "i was trying to show you the jumpy behavior that's not good UI/UX. do you get what i mean? while it was "backing up" it did that multiple times which was jarring/unpleasant" (with a screen recording; earlier "look at this frame by frame").
- Wrong: the Backup page added and removed rows and swapped its footer per sync status, and the button grew when its spinner appeared, so the layout moved three times in about 1.5 s. The lead shipped it to web without looking at the transitions and, given the recording, first described its content instead of the movement.
- Why it got through: tests checked text per state, never layout across states; nobody watched a status change before deploy.
- Fix (check): `test/features/settings/presentation/w4f_backup_test.dart` "nothing moves while the backup status changes" steps the page through every status and fails if the status card or the button changes size or position. Shown failing on the old page ("Syncing resized the status card"), passing on the new one.

### Local HTML board instead of Claude Design, again (Nov 8)

- His words: none about this; the lead found it. He approved the board ("lgtm, proceed").
- Wrong: the lead rendered hand-written HTML previews for the Backup page options, which written rule 3 forbids.
- Why it got through: rule 3 is read at startup but nothing stops a preview at the moment it is drawn. This is a repeat, so it moves up from a written rule.
- Fix (required step): before showing any UI preview or board, the lead names the Claude Design artifact it comes from in the same message. No link, no preview: build it in Claude Design first.

### Google sign-in fix shipped and still failed (Nov 7)

- **His words:** "Google sign-in still did not work, it gave me this screen 3 times", then "i mean i only tried it once but it loaded that screen thrice".
- **What was wrong:** the server exchange worked in production (exchangeGoogleSignIn ok at 15:30:05). The client then cancelled its own account switch: signing out the old session made the beta gate rebuild the sign-in screen, and the screen's dispose cancels any running sign-in. The cancellation check had been added to the Google path after the security audit, but the Google button never held the gate the way the code check does.
- **Why the process let it through:** the repository was tested with fakes and the page with an instant fake result, so no test ran the switch while the gate reacted to the sign-out. The audit fix copied the code path's cancellation rule without its matching page hold. The deploy went out before Aedwon's device check.
- **Fix:** a check: two widget tests in `test/app/sign_in_test.dart` fail on the shipped version (the gate is not held while Google sign-in runs; a failed attempt must release it). Required step: an auth change that adds a cancellation or epoch rule must include a page-level test where the sign-in screen stays mounted through the account switch.

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

### Update transport failed two migration reviews (Nov 14)

- His words: "Lead ruling (final), after two read-only reviews" and "SCALE BACK."
- Wrong: replacement workers and versioned hosting were treated as ready without
  proving compatibility with the worker already installed on phones.
- Why: isolated new-worker tests did not exercise the existing worker's rollout.
- Fix: required completion step for this correction: compare worker, hosting,
  index, bootstrap, deployment guide and Drift opener against origin/main; require
  an empty diff. Retain Node regressions for no-store detection, worker update,
  failed/slow retry and reload-only apply. No new worker or hosting migration ships.
