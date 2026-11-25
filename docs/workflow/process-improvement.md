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
4. Do not ask Aedwon anything an approved board, spec or ruling already answers. That
   includes layout, motion, controls, and in-app copy inside an approved layout (a Dialog's
   title and text, a caption, a button label). Build to the board. The lead settles copy
   under his delegation (D191), following the voice rules in `AGENTS.md`, records it, and
   tells him the wording. A state no board draws is the lead's decision: the lead decides,
   records the reason, and owns it. Fable 5.2 is an advisor only (his words, Nov 24: "Fable
   should be an advisor only"): the lead asks Fable for advice on a genuinely hard or
   high-stakes call, then decides itself. It goes to him only if it is a new screen state or
   is reserved to him. Website copy stays his.
   Before a lead or the manager puts any question to him, they search the boards, the specs
   and the rulings files for an answer and name what they searched. No check can tell a
   decided question from an open one.

5. Never ask Aedwon to write legal or policy text (terms, privacy notices, legal bases,
   consent or refund wording). First search `docs/legal/`, `docs/legal-drafts/`, the app's
   legal documents on the integration branch and the pantas-web project; use what exists as
   the base. If text is missing, an agent drafts it to favor Pantas as far as Philippine law
   allows, Codex GPT 6.2 Sol at high effort critiques it through `codex-pick`, and he only
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

7. Only real users may cost money. Testing, staging, CI, journeys, proofs, scheduled
   jobs, secrets, stored images, backups, logs, alarms and every other fixed or
   housekeeping item must stay inside Google's and Cloudflare's free tiers, counted per
   billing account across pantas-prod and pantas-staging together. Before any change that
   adds or keeps such an item (a scheduled job, a secret version, a minimum instance, a
   backup, a new API or service, a test that hits a hosted project), the agent counts it
   against the free tier and does not ship it if the account would go over. If it already
   bills, it is a defect to fix at once, not a cost to accept. His words (Nov 15): "that is absurd, i should never have been billed in the first place with just testing traffic and scheduled jobs. make this a strict standing rule. this should never happen again. the only thing that should bill us is due to users, and that's justifiable and by then we should be already able to cover the costs. i am disappointed." This rule retires when the free-tier
   check (see the entry below) covers every item.
   Runs count too, not only config (Nov 21). Before any run against a hosted project
   (a proof, journey, headless check, count comparison or load of content), the agent
   writes down its expected reads, writes and egress from the per-step costs in the
   release checklist, adds what that project already used today, and does not start it
   if the total would pass the free tier. If the cost is unknown, it measures one small
   step first. His words (Nov 21): ">:( how many times should I mention this".

8. Emails to testers and users follow the shape of Aedwon's own Nov 15 rewrite. Subject:
   a short plain label ("Pantas beta extension"), no claim. Body: a greeting, then two or
   three short sentences in a plain, friendly "we" voice (contractions are fine): what
   changed, what the reader must do, with their own number when we have it ("You still
   need to complete 4 days by then"). One button. No bullet lists, no sign-off ("The
   Pantas team"), no repeated facts, no extra links, no offer words ("reward", "free",
   "1 year of Pro"), which also sent a version to Gmail Promotions. Dates in full with
   the weekday: "November 22 (Sun)". Draft to this shape before the self-test (rule 6),
   not after his complaint. His words (Nov 15): "but i think now it's too long. same
   cuts, unnecessary info out", "i think this is too long. make it more concise, too many
   words here.", "tsk terrible", then his own text, then "lgtm send them out please, and
   note my preference on email wording/structure/tone/whatever". No check can judge tone
   or length well enough; the self-test is where he sees it.

9. Once the app is open to the public, every change to what Pantas collects about users,
   why, how long it keeps it, or who receives it goes out by email to every affected user
   before the change takes effect. For an under-18 user, the email goes to the guardian too.
   The in-app notice is not a substitute. The email follows rules 6 and 8, and its legal
   text follows rule 5. During the closed beta, Aedwon may tell testers himself instead.
   He did this for screen counts on Nov 15. His words (Nov 15): "i already told the testers personally. you can skip this, but make it of record that changes to privacy should come with an email. this is industry practice correct? we'll do this strictly when the app has opened". No check can tell when a code change alters
   collection. The lead building such a change flags it in its handoff, and the manager
   holds the prod "ship it" until the email has gone.

## Entries

### A Codex audit waited on input and ran nothing, again (Nov 26)

- Words: none from Aedwon. The CSE release lead r8's report (about 1:40 AM Manila): "Its first Codex Sol High audit lost 1 hour: codex waited on input and ran nothing. It is rerunning now with input closed."
- Wrong: the service worker fix's first Codex Sol High audit started in the background through `codex-pick exec` with its input left open. Codex waited to read a prompt from that input, did no work, and the lane lost about 1 hour on the path to the opening ship.
- Why it got through: this already happened on Nov 7 (launch log: "the first Astra runs stalled waiting on stdin and produced nothing"). The fix then lived only in one audit brief ("Run with no stdin"), not in any rule, brief template or in `codex-pick`, so later briefs and leads did not carry it.
- Fix (required step, every lead and the manager, until a tool fix lands): every non-interactive `codex-pick exec` run closes its input (`< /dev/null`), and every Codex brief or command shape says so. A repeat moves this up the order: the tool fix is to make `codex-pick` close input itself for `exec` runs started without a terminal (a few lines in `~/.local/bin/codex-pick`), which needs Aedwon's yes because it changes shared tooling.

### Wide stacked sign-in buttons did not match in size (Nov 25)

- His words (about 9:36 PM Manila): "also i think there's a regression with the buttons? like that google one, if they're paired with each other, i think it would be more visually pleasing if they're similar in proportions/size or something idk how to best express it", then "sorry i meant that when they're vertically stacked".
- Wrong: on wide sign-in, Continue (52 high) sat above "Use Google Instead" (44 high), and each took its own natural width, so the stacked pair had two sizes.
- Why it got through: the placement sweeps (E-158, E-162) and their reviews checked position, order, gap and full width. They never checked that two buttons in one group match each other in size. No rule in patterns.md asked for it, and the sign-in buttons were outside the check (raw TextButtons).
- Fix (check): patterns.md, Button placement, "Paired buttons stacked one above the other share width and height". The placement check fails a stacked pair whose widths or heights differ by more than 1 px, and the sign-in page runs that check. It was shown failing on the old sign-in. E-175, branch `ux/google-button-padding-r1`.

### Wide "Use Google Instead" hover box hugged its content (Nov 25)

- His words (about 9:10 PM Manila, wide dark sign-in screenshot, the button hovered): "also i saw this, tell me if you can see the problem".
- Wrong: on wide web the sign-in text buttons ("Use Google Instead", "Use a Different Email") had no inside padding. The hover tint started at the Google mark's left edge and ended at the last letter. Centering was correct.
- Why it got through: (1) the Nov 22 fix for U46 made these buttons natural width but kept the zero padding that only worked while they filled the 420 column; its test checked only that the width was under 400. (2) The buttons are raw TextButtons (ds-raw, brand logo content), so they skip PantasButton's built-in padding and the wide placement check, which finds only WebButton and PantasButton and checks order, gap, width and place, never inside padding. (3) At rest the button is transparent, so a resting golden or a side-by-side review shows nothing wrong; the defect shows only on hover. (4) The sign-in board draws the button full width, so comparing with the board could not give the padding; it comes from the design system's wide text button (14 beside the label).
- Fix (check): a sign-in test that fails on the old code (0 px inside, 14 expected), and an inside-padding rule in `test/helpers/button_placement.dart`: a wide button that paints a hover box and is not stretched must keep at least 8 px between its edges and its content. The rule covers raw TextButtons too, and the sign-in page now runs the placement check. E-170, branch `ux/google-button-padding-r1`.

### An internal term reached a board he reviews ("taste finished") (Nov 25)

- His words (about 9:36 PM Manila, on the guided first-run board): "don't call it taste finished. why even call it that - that's an internal term", and on the same board "also please improve text copy - remove redundancies, remove unnecessary text/info".
- Wrong: the manager's brief called the guided first run "the taste", and the board carried that word into on-screen text ("Taste finished"). The intro screen also repeated what its own button and steps already said.
- Why it got through: briefs used an internal shorthand, and the board review checked styling and placement but not whether every on-screen word is user language. This is the same kind as the Nov 24 entry on internal codes in chat, now in product copy.
- Fix (required step, boards and builds): before a board reaches him or a build ships, a reviewer scans every user-visible string for internal terms (lane words such as taste, trial, starter check, T-numbers, U-numbers, ruling codes) and for sentences that repeat the screen. Briefs name the user-facing wording separately from the internal name. A check on the app's own strings for a deny list of internal terms is possible; the UX lead adds it if it can be shown failing on a real string first.

### Release lead ended its turn after a part report with the next part queued (Nov 25)

- Words: none from Aedwon. The manager's note: "you reported part 1 at 2:44 PM and then stopped, with nothing running. Start part 2 now".
- Wrong: the CSE release lead r7 shipped part 1 of a four-part brief, reported, and ended its turn with no worker, watcher or wait running, though the brief said "Do these in critical-path order" and parts 2 and 3 needed nothing from him. About 1 h 19 min passed idle.
- Why it got through: "report to me after each part" was read as a stop point. The Nov 25 idle entry (UX lead) covered a missing watcher, not a turn ended by choice with work queued.
- Fix (required step, every lead): a part report is not a stop. In the same turn as the report, start the next part (log its estimate, start its timer or worker) unless the brief or the manager says to wait, and say in the report what is now running. End a turn only when something is running under a registered watcher, or the next step needs Aedwon or the manager.

### Manager ruled on the Home footer without finding his Oct 31 decision (Nov 25)

- His words: "didn't we remove 2" (about the manager's list item "Home footer: About 45 min today becomes real counts").
- Wrong: the manager ruled that the wide Home footer would show "3 lessons, 18 reviews left" in place of the time estimate, built it and queued it to ship. On Oct 31 he had already decided "Leave it out": the footer keeps only the button. The live app already matched his decision, so the change would have added something he had removed.
- Why it got through: the manager ruled under rule 4 from the lead's summary ("used to show About 45 min today") and did not search the launch log or rulings first. This is the same kind as the Nov 23 entry (deciding or asking without searching), now on the manager's own rulings.
- Cost: the counts line reached prod inside #124 (7:07 AM Manila); the release lead rolled prod back at 7:11 AM, which also pulled the Quiz tab card and the T9 fixes until a reship (his question: "why do they take this long").
- Fix (required step, manager and leads): every rule-4 ruling names the search done before it (launch log, rulings file, boards, with the terms searched) in the message that gives the ruling. A ruling that names no search is not acted on. The release lead dropped the U24 branch before shipping. No check can tell a decided question from an open one.

### UX lead sat idle on a finished CI step with no live watcher (Nov 25)

- Words: none from Aedwon. The manager's note: "you've been idle since 7:58 AM. You ended your turn while the CI goldens ran, with no watcher."
- Wrong: the lead started `gh run watch` in the background and ended its turn without registering it with the thread (T3 `t3_background_wait`). The session ended, the watcher stopped with it, and the goldens run finished unseen; about 1 h 37 min passed before the manager asked.
- Why it got through: a background command looked like a watcher, but in T3 only a registered wait keeps the thread alive to hear it finish.
- Fix (required step): before ending a turn on CI, a goldens run or any other background wait, start the watcher in the background and register it with `t3_background_wait` in the same turn; the turn's last line names the run and that a registered watcher is on it.

### Walk-through lesson rewrite still too compressed (Nov 25)

- His words: "i found some lessons could use more detail, or a sort of \"walk you through it\" type of teaching" (Signed Integers and Substitution, three screenshots), then on the manager's sample rewrite: "close, but not as detailed as I'd like. you are allowed to have numbers in core concept".
- Wrong: the sample kept each rule to one or two worked numbers and still skipped the reasoning behind each move: why a rule works, what goes wrong without it, and checking the answer.
- Why it got through: the lesson style guide sets the reading level (Grade 5) but no depth standard, so "plain" was read as "short". The sample also aimed at the current lesson's length.
- Fix (required step until a depth standard is approved and added to docs/content/lesson-style-guide.md): a math lesson rewrite walks through every rule with numbers in Core Concept, shows each arithmetic and sign move on its own line, says why the move works, shows the common wrong move next to the right one, and ends worked examples with a check. The manager's next sample follows this, and his reaction sets the standard.

### Wide Quiz tab paused card still breaks the button placement rule he set (Nov 25)

- His words (about 4:35 AM Manila, wide dark screenshot of the Quiz tab paused card: caption and "Discard this session" on one line, Resume at the bottom left): "was this never addressed? particularly the placement of discard resume (basically the CTAs in general)? i think i've raised this before, and that's also why DS4 i believe was added / i want answers first before you change anything".
- Wrong: he raised button placement on Nov 7 ("worth considering their placement. especially when there are two of them") and chose P2 (right end, main last). That choice is why the design system was built. On Nov 10 he raised desktop placement again ("awkward"). The design system has a rule for exactly this card (patterns.md: "A stacked phone-style pair on a wide page (guardian confirm, paused quiz notice) becomes a right-aligned row, secondary then main"). The live wide card still puts Resume at the bottom left.
- Why it got through: builds and side-by-side reviews compared each screen only to its drawn board. This card's board (QZ_Resume, approved Oct 2) predates the Nov 7 rule. The Nov 24 borderless-buttons work and the Discard centering both matched the old board and never checked patterns.md. Nothing swept the wide screens for P2 after the system shipped.
- Fix (required steps):
  1. Every UI build brief and every side-by-side review checks design/system/patterns.md (placement, spacing, buttons) as well as the board. Where a board drawn before Nov 7 conflicts with a pattern, the pattern wins, and the review names the rule.
  2. A one-time sweep of every wide screen for placement against patterns.md, results listed for the manager. It starts only after he answers; he asked for answers before changes.
  A placement check in code may be possible later (widget tests asserting button order and alignment on wide cards); none is promised until it is shown failing on this card.
- Done (Nov 25, UX lead, E-158): step 2 ran as a code-only scan at his request ("isn't there a faster way to determine that without using screenshots", then "okay proceed"). Check added, as this entry asked: `test/helpers/button_placement.dart` (on `ux/button-placement-r1`) fails a wide pair that is out of order, off 8 px (board exceptions listed with his approval), stretched, neither at the right end nor centered, or stacked phone-style; it runs on every wide screen golden. Shown failing on the old mock card, guardian and exam-change screens before their fixes. Results and rulings: the rulings file, "Nov 25, UX design lead: wide button placement, code only (E-158)".

### Two lead sessions shipped the same PRs at once (Nov 25)

- Words: none from Aedwon. The manager's note: "Your workers already shipped ENT-06 at 19:40 UTC, and the reader with #117 at 19:48 UTC ... Don't redeploy #117."
- Wrong: the manager's fresh-memory tasks started a second CSE release lead session (r5) on the same three PRs while the r4 session still owned them. r5 shipped ENT-06 and then #117; r4's ship worker was at the same time building ENT-06 from an older main commit. Had it reached prod, it would have rolled #117 off prod. r4 stopped it at staging after reading the launch log.
- Why it got through: nothing tied a PR to one owning session, and a ship brief's rollback point was checked once at the start, not right before the deploy.
- Fix (required steps): (1) a PR has one integrating session; the manager names it, and a lead that finds another session acting on its PRs stops its own ships and asks. (2) Every ship brief checks, immediately before the prod deploy, that app.pantas.study still serves the build recorded as the rollback point, and stops without deploying if it does not (in the r4 #121 brief).

### Discard spacing in the Quiz tab shrank after a spacing ship (Nov 25)

- His words (about 3:50 AM Manila): "the space on top and bottom of discard in the quiz tab got too small though".
- Wrong: the vertical space above and below Discard on the Quiz tab's paused card is smaller than he expects. It most likely came from the Nov 24 Discard centering or the Nov 25 Study and Quiz spacing ship, but the cause is not confirmed yet.
- Why it got through: the Nov 24 borderless buttons change (commit baac08a99, shipped to prod 9:50 PM Nov 24), not the Discard centering or the Nov 25 spacing ship. It moved every phone text button to the board's text sizes. Discard on the Quiz tab paused card became the 15/600 line in a 24 px box, so the space around its text fell from 20.5 px above and 24.5 px below (a 52 px tertiary button, 6 px under Resume) to 12 and 10 (measured on headless renders of both versions, Nov 25). The new values matched the QZ_Resume board ("12 under Resume"), so the side-by-side board review passed it: the board itself draws the tighter spacing, and nothing compared the card with how it looked before. His call from using the app beats the board here (manager ruling, Nov 25): the build restores 20 above and 24 below the text and the reference canvas changes to match (the Quiz tab card is held while he answers a placement question).
- Fix (required step, already in the Nov 23 entry, now applied to spacing): a spacing change is compared side by side with the board at phone and wide for every card it touches, not only the card it targets. Added, because the board itself was tighter than what he was used to: a change that shrinks the space around a control he already uses is also compared with the live version before it, and any loss over 4 px is shown to him on the capture sheet before it ships. Checks: `quiz_tab_paused_spacing_test` (fails on the shrunk spacing: 20 above and 24 below the Discard text) and the `quiz_tab_paused` golden sheet at 390 and 1440.

### Week strip put in front of him though he never raised it and a board already answered it (Nov 25)

- His words: "what was the reason why i'm being made to choose for the week strip? was it a complaint from me?"
- Wrong: the long CSE exam name in the Home week strip was finding U14 from an agent UI audit, not his complaint. His approved week strip board (D196) already draws the short name. Even so, the manager's E-149 brief asked for "2 options". The UX lead correctly found no choice, but still drew the section on the board sent to him, and the manager opened that board for him and explained the section.
- Why it got through: this is the same kind as the Nov 23 entry (boards built as options for questions already answered). Rule 4 made the lead search first, but nothing stopped an answered item from reaching him on a board, and the manager wrote "options" into the brief before anyone had searched.
- Fix (required steps, moved up from the Nov 23 entry):
  1. The manager's brief never asks for options. It asks the lead to search first and to draw options only for what no board, spec or ruling answers.
  2. Before the manager opens a board for him or relays one, it removes every section that holds no choice for him. Answered items are built to their source and reported to him only as an outcome once they are live.
  3. Every item put to him names where it came from: his own words (quoted), or an agent finding (named as such).
  No check can tell an open question from an answered one.

### Reader request turned into a redesign he did not ask for (Nov 25)

- His words: "i don't understand the reader line, i just wanted you to maybe remove the lesson indicator on top because it gets so long when there's a lot of lessons in a certain topic, and especially so after the instruction to make the lessons bite-sized. for the thing that indicates how far along you are in the lesson itself, no changes". His original request words are not recorded on main; the manager's brief (E-149) said only "reader progress bar replacement, 2 or 3 options".
- Wrong: the UX lead drew three options to replace the in-lesson section line on wide web. He wanted one thing removed (the lesson indicator at the top that grows with the number of lessons in a topic) and the in-lesson progress left alone.
- Why it got through: the manager paraphrased his request into a design task, and the lead designed from the paraphrase. This is the same kind as the Nov 24 entry on a paraphrased ruling, so it moves up from "relay in his exact words" (operations-manager.md) to a required step with a stop.
- Fix (required step, manager and every lead): every brief that carries a request from Aedwon has a line "His words:" with his exact words, pasted. A lead that gets a brief without that line asks the manager for it before starting work. The lead's first line back restates what he asked for in one plain sentence. No check can judge whether a paraphrase kept his meaning.

### Lead threads reused with large old context (Nov 24)

- His words: "process improvement: you are reusing lead threads that have lots of context from previous tasks. i think that's inefficient. we should save tokens. as the operations manager it's your job to make the process efficient. propose a solution and i'll approve ot". Approved: "ok approved".
- Wrong: the manager sent the paused-session board task to the UX lead thread, which already held about 540 items of unrelated work, and the old CSE and security leads had grown past 2,000 items. Each reply rereads that whole history, which spends his Claude usage on old context.
- Why it got through: the Nov 16 routing rule only moved work to a fresh lead above 1,000 items or outside the lane, so a thread could carry hundreds of items of finished work into every new task.
- Fix (required steps, manager and every lead; replaces the 1,000-item test in operations-manager.md):
  1. Every new task starts with a blank memory: send it with `t3_thread_send` and `freshContext: true` (same thread and worktree, no old chat), or launch a new lead for a new lane. The brief carries everything the task needs.
  2. Every task ends with a short handoff note on main in `docs/superpowers/handoffs/` (what changed, where the work is saved, what is left). The next fresh session reads the note, not the old chat.
  3. A task that runs long (about 3 hours of steady work, or past about 300 thread items) writes its note and restarts itself with a blank memory.
  4. The manager does the same: it restarts from a handoff note when its own thread gets long.

### A new quiz bar design reached prod without his visual check (Nov 24)

- His words: "where did this come from? why is there now those dashes", then "lol that looks terrible. what else did you ship that I should know?" (about the one-mark-per-question quiz bar, phone screenshot, about 7:15 PM Manila).
- Wrong: the core loops polish spec (B2 marks in the session bar, flying into results; B5 fewer words) was designed by the UX lead while he was away, approved by a Gemini and Fable council, built, and shipped to prod in the 5:54 PM release under his standing "ship it". No board he approved draws the marks, and he never saw them before they were live.
- Why it got through: the standing "ship it" was read as covering every merged change, including new visual designs that only a council had approved. The council path was meant for build-versus-board doubts, not for new looks. Nothing separated "built to a board he approved" from "new design he has not seen".
- Fix (required step for the manager and every lead before a prod ship): list each user-visible UI change in the release and name the board he approved that draws it. A change with no such board (council, Fable or lead designed) does not ship to prod until he has seen it on a board and picked it; it waits behind a flag or stays off main. The standing "ship it" covers only changes built to his approved boards, server work and fixes. No check can tell an approved look from a new one.

### Ship report packed jargon, internal codes, and hashes into chat (Nov 24)

- His words: "did you read your global instructions, agents.md workflow.md cuz none of your words made sense to me".
- Wrong: the temporary operations manager's ship report packed raw build and commit hashes, version and alert IDs, internal task codes (`T18`, `T19`, `B2/B5`, `H5`, `PAY-06`), code and script names (`became_adult`, `compare.mjs`), scattered bold, and a 75-word sentence into a routine reply to Aedwon, breaking `WORKFLOW.md` ("Write for Aedwon").
- Why it got through: the prompt asked for a 3-line ship report with rollbacks, and the agent compressed the technical deploy record directly into chat instead of putting IDs in the launch log and writing plain English for Aedwon.
- Fix (required step before sending any chat reply to Aedwon): put commit hashes, version IDs, alert IDs, internal task codes, and script or function names in the launch log or private release folder, never in routine chat replies. Before sending, check that every sentence uses plain words, carries one idea in 25 words or fewer, and avoids scattered bold; describe rollbacks in plain words ("switch back to the previous app version, server code, database rules, and indexes saved in the release folder") instead of raw IDs. No automated check can judge plain-English clarity across chat messages.

### Manager routed every decision to Fable (Nov 23 to 24)

- His words: "i also think you're being too dependent on Fable, Fable should be an advisor only".
- Wrong: the manager sent nearly every open question to a Fable 5.2 agent and treated its answers as final rulings: legal product decisions, retention periods, reader states, the phone bar, the under-18 framing. The leads did the same. Fable was acting as the decider, not the advisor his model-layer rule describes ("Advises; the lead still owns the conversation and final acceptance").
- Why it got through: written rule 4 said undrawn states go "to a Fable 5.2 ruling first", and an older Nov 17 delegation let Fable decide for him. The manager read both as "Fable decides".
- Fix (rule 4 changed): the lead (Opus) decides and owns undrawn states and product calls, with the reason recorded. Fable is asked for advice only on genuinely hard or high-stakes calls, and the lead decides after. Exceptions he set himself stay: the Gemini and Fable council for UNSURE board-versus-build UX calls, at his Nov 23 request. Rulings already made stand.

### Keychain prompt from a test browser again (Nov 24)

- His words: "how many times is this now" (with a screenshot of the "Google Chrome for Testing wants to use ... Chromium Safe Storage" prompt, 2:36 PM Manila).
- Wrong: the Nov 14 fix (below) put `--use-mock-keychain --password-store=basic` into the repo's launch scripts, but ad hoc render scripts written by workers and Fable checkers (board renders, golden checks, frame-time runs) launched Chrome for Testing without the flags. One of them also ran `pkill` on Chrome for Testing the same afternoon.
- Why it got through: the rule lived only in the repo scripts and in one lead's briefs. The manager's own worker briefs and Fable checker briefs never carried it.
- Fix (required step for every brief that might open a browser, manager and leads alike): the brief says "Any browser you launch must pass --use-mock-keychain and --password-store=basic, or use tool/journeys or tool/design_system launchers; never kill processes you did not start." The manager adds it to every worker and Fable brief from now on.

### A brief paraphrased a ruling and dropped its scope limit (Nov 24)

- Words: none from Aedwon; found by the Fable 5.2 advisor (ruling C5): "H1(b) already answers this. Its last sentence, which the T18 brief left out, reads: \"Short-lived rate-limit counters are outside this test.\""
- Wrong: the CSE release lead's T18 brief paraphrased ruling H1(b) without its last sentence. Codex audits then held rate-limit counters to the full unlinkability test, and the lane spent about three extra build and audit rounds (Codex quota and worker usage) on counters the ruling had excluded.
- Why it got through: briefs restated rulings in the lead's words; nothing required the ruling's exact text, so a scope limit could fall out silently, and the auditor checked against the brief.
- Fix (required step for any lead writing a worker or audit brief that rests on a ruling): paste the ruling's operative text verbatim (or link its section and say "read it in full"), never a paraphrase, and give the auditor the same section. Applied: T18 round 5 and its final audit read ruling C5 in full.

### Claude 5-hour limit hit with three Opus leads running (Nov 23)

- Words: none from Aedwon. His standing words: "mind my usage, limits in my PC" (Nov 22). The limit message: "You've hit your 5-hour limit · resets 9:40pm (Asia/Manila)".
- Wrong: at 7:25 PM Manila, every lead stopped. Three Opus leads were working (CSE release, UX ambition, and security running the money-path audit with a Fable verifier). The manager's own Sonnet workers and a Fable ruling ran at the same time. About 2 hours 15 minutes of work stopped.
- Why it got through: the manager counted the security lead as "the short task" after giving it the audit, which is not short. The manager did not count its own workers against the cap.
- Fix (required manager step): at most 2 Opus leads do real work at once. A third lead waits until one is idle or has handed off. The manager's own workers and Fable rulings count as the one short task. After a limit stop, the heartbeat resumes each lead once the reset time passes, and checks its workers for partial changes.

### Boards built as options for questions the approved boards already answered (Nov 23)

- His words (relayed by the manager): "why are you asking me things that have been decided before?" and "isn't there a reference/boards already for the UI? including animations? are you kidding me?" Then: "i spent a lot of time going through those boards. every single animation. every single detail. and then it was not implemented properly, and now you're asking me again to decide?"
- Wrong: the CSE release lead turned three settled UI questions into picks on the "CSE Release Picks" canvas: the report bar morph (the approved QN_Report boards already draw it, with timing), borderless Cancel and Close (the boards already draw the sizes and where no Close exists; option A was simply "match the boards"), and the checkout tick (a Fable D2 ruling already recommended it, matching the approved guardian box). It then sent them up again as open picks, and the manager relayed them to him twice without checking.
- Why it got through: the manager's request said "options for him to pick", and the lead built options without first asking whether an approved board, spec or ruling already decided each one. His findings were that the build does not match the boards, so the boards were the answer, not a question.
- Fix (required step for any lead, before any UI question reaches Aedwon): check the approved boards (Pantas Redesign, Pantas Web, later approved canvases), the spec and the rulings. If any of them answers it, build to it and say which source in one line. Only a state that no board draws is escalated, and it goes to a Fable 5.2 ruling first, not to Aedwon. The same search is a required manager step before relaying any question, and written rule 4 now covers layout and motion, not only copy. Second required step, for "not implemented properly": every UI task names the boards it built from, and before it counts as done a reviewer compares the build side by side with them at phone and wide widths, including motion timing and easing. Each difference is classed (his Nov 23 refinement): build worse, fix it to the board; build better, keep it and update the reference canvas; unsure, a council of Gemini 4 Neon High (or GPT 6.2 Sol High through codex-pick) and Fable 5.2 decides, with Fable final on a split. His guidance for the council: no wordy UI, compress text, clean, intuitive, elegant, satisfying motion. The approved spec is Pantas Web (https://claude.ai/artifact/4mUpC5apRsMhtQDg5VVjx8), Pantas Redesign (https://claude.ai/artifact/M1hptDwMLUcuGxSAGescHi) and, for checkout, Guardian Manage and Minor Checkout (https://claude.ai/artifact/VhNW1aCxSs5sF48XMQZLAQ). Applied: sections 2, 3 and 4 are built to the boards and the D2 ruling.

### A Claude worker started four more workers past the 2-worker cap (Nov 22)

- Words: none from Aedwon. The manager's correction: "you have 6 Claude subagents running; the brief's limit is 2 at once (his Claude usage)". The cap protects his Claude usage (Nov 19 and Nov 22 entries below).
- Wrong: the CSE release lead started two Sonnet UI reviewers, within the cap. One of them started four more Sonnet workers of its own to split its scope. The lead counted only its own two and told the manager so.
- Why it got through: the brief named the scope and the output file but did not forbid subagents, and a general-purpose worker may start them. The lead counted dispatches, not running workers.
- Fix (required step for any lead): every Claude worker brief says "Do not start subagents; do the work yourself." Before reporting a worker count, the lead counts the workers each worker started too. Applied: the CSE release lead's later briefs carry the line.

### Manager restarted five leads at once after his Claude reset (Nov 22)

- His words: "so you didn't learn anything did you". Earlier, Nov 21: "my 5-hour usage is getting burned too fast", and "my 5-hour limit is at 8% right now".
- Wrong: the manager had promised to ask him which lanes to resume, and in what order, after his 12:09 AM reset. When he said "limits have reset, could you continue?", it restarted four Opus leads and launched a fifth (the dots figure kind UI lead) within minutes, without asking. The machine caps held (load 4.7), but five Opus leads at once is the pattern that had drained his Claude limit the day before.
- Why it got through: the Nov 21 caps covered Codex jobs and Flutter builds, not Claude leads. The manager read "continue" as approval for every paused lane at once, and dropped its own promise to ask.
- Fix:
  1. Required manager step: at most 2 Opus leads run at once, plus one short task (one or two turns) at a time. Other leads wait in a queue the manager states to him. Going past 2 needs his approval for that time.
  2. When the manager has told him it will ask before doing something, it asks. A general "continue" does not replace that question.
  3. Applied now: the question generator Phase 2 and dots figure kind leads are paused. Under-13 and PSHS-NCE continue, and the security lead finishes its short task.

### Manager overloaded the Mac and ignored his report of it (Nov 21)

- His words: "t3 code is using 13 GB of my ram, that's not normal", then "??? what the hell were you doing? my mac reached 14 GB in RAM usage with t3 code only", "i stopped a lot of processes. you didn't even respond to me", "hello? can I even trust you as my operations manager at all?"
- Wrong: the new manager launched four leads at once and told each to run Codex jobs in parallel wherever accounts had room ("burn it" was about quota, not the machine). Each Codex job and Claude worker built and tested Flutter in its own worktree, so a dozen heavy processes stacked up: load average 63, about 14 GB used. Aedwon had to kill processes himself. When he first reported the RAM, the manager took his message for a lead's "ok" and replied "Nothing new since my last message".
- Why it got through: the standing rule "One build per session" (operations-manager.md) was never turned into a number the leads could follow, and the manager never checked machine load before allowing parallel work. Quota room was treated as the only limit. The manager did not check who sent a message before answering it.
- Fix:
  1. Machine-wide cap, in force now: at most 2 Codex jobs at once across all lanes, and at most one Flutter build, test or analyze at a time on the Mac. Leads ask the manager before going past it.
  2. Required manager step: before starting or allowing parallel work, run `uptime` and `memory_pressure`. If the 1-minute load is above 12 or free memory is under 30%, start nothing new.
  3. Messages from Aedwon are answered first and directly. A short message is read as his unless it carries a lead's thread label.

### Staging proof read past the free tier again (Nov 21)

- His words: ">:( how many times should I mention this", after reading that a Nov 20 staging proof cost money.
- Wrong: on Nov 20 (09:15 to 10:35 UTC) the integrator's headless CET staging proof made about 800 calls and read about 110,000 Firestore documents. A count comparison read 31,000 more on staging and 24,000 on prod. Staging passed its 50,000 free daily reads and billed about $0.05. Rule 7 forbids exactly this, and he had already said it on Nov 15.
- Why it got through: rule 7's pre-check was written for changes that add a fixed item (a job, a secret, an instance). Agents read a proof run as testing, not as a change, so nobody counted its reads before starting. The free-tier check counts config, not traffic. The 40,000-read staging budget set on Nov 16 lived in a note, not in a required step. Settings saves, new lesson reads, mock previews and mock starts rescan the whole bank (1,460 reads) on a cold server, so every proof step was far costlier than it looked.
- Fix:
  1. Rule 7 now covers runs: count expected reads, writes and egress before any run against a hosted project, and do not start it if the day would pass the free tier (applied Nov 21).
  2. The per-step costs and the staging budget are a required release-checklist step, and the live free-tier check warns above the budget (security and billing lead, PR #80).
  3. Root cause in code: the four calls read one small summary document per exam instead of rescanning the bank, so a cold scan drops from 1,460 reads to under 10 (security and billing lead, approved Nov 21; prod after his "ship it"). This also protects prod once real users arrive.

### A brief's judgment stated as fact: "no gated exam can sell before mid-2027" (Nov 17)

- His words: "actually correction, PSHS-NCE can still sell"
- Wrong: in the question generator session, the lead told him three times that no gated exam can sell before mid-2027, and used it as the reason that waiting to build costs nothing. The source was the next-exam brief's line on PSHS-NCE, "Not feasible for this cycle". That brief is a recommendation he never approved, and the PSHS-NCE test is January 30, 2027.
- Why it got through: the lead did not separate his decisions from an agent's judgment in a brief, and repeated the judgment without its source or its blockers.
- Fix (a required step for any lead): a claim that something cannot ship, sell or be done by a date is given to him only with its source named and its blockers listed, and it is labeled a judgment unless his own words decided it. Such a claim is not used as the cost argument for a recommendation until he has accepted it. Applied in this session: the blockers for PSHS-NCE this cycle were listed and he was asked which cycle he means.

### Picking rule proposed before reading how the app picks questions (Nov 17)

- His words: "um i think you have to marry this idea with how the roadmap does things as well" and then "among other systems that exist in the app, there might be some contradictions/conflicts need resolving"
- Wrong: in the question generator session, the lead adopted a serving rule (least-seen problem type first, a missed type returns as a new version) and gave it a cost of 1 to 2 days. It had not read the roadmap, the review scheduler, the practice picker, the mock sampler or the other systems that already decide which question a student gets. The log entry itself said the app's behavior was "not re-read on the current code branch".
- Why it got through: the lead treated the rule as a study-method ruling and checked only the research evidence. Nothing made it check a serving rule against the systems that serve questions before stating it and pricing it.
- Fix (a required step for any lead in a design session): before proposing or pricing a rule about what the app serves, in what order, or what it counts, read the current code and specs of every system that serves or tracks questions (roadmap, review scheduler, practice and in-lesson quiz, mock, assessment, progress figures, sync). State in the same reply how the rule fits each one and where it conflicts. A rule whose fit has not been read is offered as an idea with no cost figure. Applied in this session: the systems were mapped before the design continued.

### His scrolling goal kept getting answered in parts (Nov 17)

- His words: "even if you fix the dropped frames while my finger is down, when i let go, it's still not as smooth as it can be. oh come on, i'm getting sick of my intent not landing with you. consult a Fable 5.2 adviser!"
- Wrong: his goal from the start was "scroll as smoothly as any other website on my 120 Hz iPhone". The manager answered it in pieces, each one framed as the fix: a pixel-density cap, then touch resampling, then dropped frames during drag, then a native app. None of them could meet his goal, and he had to say so each time.
- Why it got through: the manager measured each proposal against the last measurement, not against his stated goal. On a hard call, it did not ask Fable for the whole picture until he demanded it.
- Follow-up, his words: "tsk nevermind. note my frustration on this. i don't have enough usage for that." He dropped the scroll work. The piecemeal rounds had used up the usage the real answer needed.
- Fix (a required step for the manager): before any investigation that will take more than one round, give him the expected usage cost and a stop point, so he decides with the cost in view. When he reports a problem he can feel, write his goal in his words as the success test, for example "feels like any other website, drag and fling, on his iPhone". Open every proposal by saying whether it meets that test, and stop offering steps that can't. If the path to the goal is unclear after one round of measurement, ask a Fable 5.2 adviser for the full option set before replying to him.

### Native-app answer to a PWA problem (Nov 17)

- His words: "yeah you say that but I'm not getting the 120 Hz on my 120Hz iPhone 17!!!!!" and then "I KNOW. the app will launch as a PWA."
- Wrong: asked why scrolling in Pantas is not as smooth as other websites on his iPhone, the manager twice offered a native Flutter iPhone app as "the real fix". Pantas launches as a PWA. A native app does not solve the product he ships, and offering it read as a dodge.
- Why it got through: the manager answered the technical question ("what gets 120 Hz?") instead of his question ("how does my PWA scroll like a website?"). Nothing tied answers to the launch target.
- Fix (a required step for the manager): before proposing any fix to a user-facing problem, check it against the launch target in the launch log and specs. Today that is a PWA on Flutter web, for phones first. A fix outside that target may be mentioned only as background, never as the recommendation, unless Aedwon has changed the target.

### New problem routed to an overloaded lead thread (Nov 16)

- His words: "question, you gave it to DS4 completion, a really long thread filled with other problems, why?", then "it has already sent its context and used up usage for it, so new thing would be a waste", then "?? that's it? no process improvement? can you not sense you've done wrong here"
- Wrong: the manager sent the phone scroll-jank investigation to the DS4 completion lead. That thread already held about 1,800 items across unrelated work: components, screen counts and the sync loop. The manager picked it because it was idle and had touched web performance, not because it owned scroll performance or had room. A long thread gets compacted, so old detail drops and attention is split, and moving the task after it starts wastes the usage already spent. Then, when Aedwon questioned it, the manager answered without writing this entry, which this file requires in the same turn.
- Why it got through: the routing step asked only "who is free and has touched this?" It never asked whether the problem was new, or whether the target thread was already long. The rule to write an entry when he sounds frustrated was not applied to questions about the manager's own choices.
- Fix (a required step for the operations manager, before sending any new task to a lead):
  1. Read the target thread's item count, which the thread list shows.
  2. If the task is a new problem outside that lead's current lane, or the thread has more than 1,000 items, launch a fresh lead for it with a full brief. Use the existing lead only when it owns that exact code and is under the limit. Launching leads per lane is the manager's job (operations-manager.md); it does not wait for Aedwon.
  3. State the routing reason in one line in the reply to Aedwon, so he can object before usage is spent.
  4. When Aedwon questions a manager decision with a "why", treat it as a correction: write the entry here in the same turn, before answering.

### Beta extension email drafts too long and too formal (Nov 15)

- His words: "but i think now it's too long. same cuts, unnecessary info out", "i think this is too long. make it more concise, too many words here.", "\"The Pantas team\" is this in other emails we sent? if not, remove it", "tsk terrible", then he wrote the email himself.
- Wrong: four drafts (an approved text in the newsletter template, a rephrase, a shorter one, a tightened one) each carried more than the reader needed: perk lists, Pro dates, links to the guide, a team sign-off no earlier email used, and instruction sentences of 20 words or more. The first also landed in Gmail Promotions.
- Why it got through: drafts started from the facts to cover, not from what one tester must do next, and each round trimmed instead of rewriting.
- Fix: written rule 8 (his rewrite is the model). The monitor's send script also refuses a recipient its wording does not cover (for example a tester who already has 5 days).

### Manager waited to be asked instead of acting in his interest (Nov 15)

- His words: "do your job more proactively. it should be in my best interests always. that includes my interests for peak user experience decisions"
- Wrong: the manager relayed and reported but did not go looking. Several problems sat open until Aedwon or a lead found them: fixed costs billing with no users, the beta gate's built-in end date (found by chance while preparing the extension), the exit survey reachable only from Settings (0 of 19 replies), medium tester-facing bugs in the beta digest with no fix in flight, and a tester email that landed in Promotions.
- Why it got through: the manager's checklist covers what leads report, not what nobody has looked at. No step asked "what is costing him money, hurting users, or about to break on a date?"
- Fix (a required step for the operations manager): at takeover, at each scheduled event, and at least daily while lanes run, sweep three things and start a fix for each finding without waiting to be asked (through a lead, with a Fable 5.2 ruling where a decision is needed; prod still needs his "ship it"):
  1. Cost: anything billing without users (written rule 7).
  2. Users: every open medium or higher item in the beta digest and tester feedback has an owner and a fix in flight. UX decisions aim at the best experience, following the approved boards and his rulings from use.
  3. Dates: hardcoded dates, expiries, quotas and scheduled cutoffs in code, config and schedules within the next 14 days.
  Tell him what was found and started, in one line each.

### Billed for test traffic and scheduled jobs (Nov 15)

- His words: "that is absurd, i should never have been billed in the first place with just testing traffic and scheduled jobs. make this a strict standing rule. this should never happen again. the only thing that should bill us is due to users, and that's justifiable and by then we should be already able to cover the costs. i am disappointed. as the operations manager please make sure these things don't happen again. then you also have the prerogative to consult fable, and do other necessary checks that would lead to this same situation"
- Wrong: November to Nov 14 billed $0.22 after credits, none of it from users. Cloud Scheduler billed $0.16 (18 jobs across both projects against 3 free per billing account; paused jobs still count). Staging Hosting egress from journeys and proofs billed $0.04. About $0.02 was unattributed (App Engine $0.01 and $0.01 unknown).
- Why it got through: each lane added scheduled jobs, secrets and staging traffic on its own and priced them as "a few cents a month". No step counted fixed items against the shared free tier, and the Nov 12 approval asked for "a few cents" instead of $0. The cost review ran only after the bill existed.
- Fix:
  1. Written rule 7 above, in force now.
  2. Check (owner: the security fixes and billing cap lead): a free-tier check that fails when the non-user items on the billing account exceed the free tier. It counts scheduler jobs, active secret versions, minimum instances, stored images, Hosting storage and staging egress, backups, enabled paid APIs and alarm references. It runs in CI against the repository's deploy config, and monthly against the live projects. It must be shown failing on the Nov 14 state (18 jobs) first.
  3. Required step: a full audit of every non-user cost source on both projects, with a Fable 5.2 ruling on each fix, before the check is called done.

### Inline quiz results missed the update safe point (Nov 14)

- His words: "A "Quiz yourself" quiz started from a lesson runs on /quiz/inline/<id> and shows its results on the same route" and "so the results screen never counted as a safe point and the app did not reload into the new build there."
- Wrong: coordinator safety inferred completion only from separate results URLs.
- Why it passed: coordinator tests changed routes instead of completing an inline quiz through the real controller.
- Fix: the inline controller regression in `test/features/quiz/presentation/quiz_controller_test.dart` drives start, answer and next with a fake update bridge. It failed with expected one apply, actual zero before the hook existed. It also checks unsafe questions/reveals and restarting on the same URL. Coordinator tests cover route reset, pending writes, repeated completion and input overlays.


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

### Nov 14, 2026: a headless browser asked Aedwon for his keychain

- His exact words: not recorded (the manager relayed that a "Chromium Safe Storage" keychain prompt appeared at 3:56 PM Manila and he had to deal with it).
- Wrong: the DS4 lead's staging update proof launched Chromium on the shared Mac without keychain flags, so macOS asked Aedwon to unlock the keychain.
- Why: no rule covered browser launch flags on the Mac; scripts used Playwright's defaults.
- Fix: every automated Chromium or Chrome launch passes `--use-mock-keychain` and `--password-store=basic` (journeys, staging proofs, captures, any headless browser). Added to the lead's scratch scripts and the worker's proof scripts.

### Update transport failed two migration reviews (Nov 14)

- His words: "Lead ruling (final), after two read-only reviews" and "SCALE BACK."
- Wrong: replacement workers and versioned hosting were treated as ready without
  proving compatibility with the worker already installed on phones.
- Why: isolated new-worker tests did not exercise the existing worker's rollout.
- Fix: required completion step for this correction: compare worker, hosting,
  index, bootstrap, deployment guide and Drift opener against origin/main; require
  an empty diff. Retain Node regressions for no-store detection, worker update,
  failed/slow retry and reload-only apply. No new worker or hosting migration ships.

### Nov 14, 2026: a tool cache file was pushed to a public branch

- Words: not Aedwon's; the manager's instruction: "leave the history alone; no force push", then "check `git status` for tool cache files before pushing".
- Wrong: the security fixes lead committed `tool/cloudflare-app/.wrangler/cache/wrangler-account.json` (the Cloudflare account name, which contains Aedwon's Gmail address, and the account id) and pushed it to `web/security-cloudflare-r1`. Removed in the next commit; the history stays, by the manager's ruling (the address already appears as the author email on public commits).
- Why: `git add <folder>` staged a cache that wrangler writes next to its config, and nothing ignored it.
- Fix: `.wrangler/` is in the root `.gitignore` (any depth). Required step before every push: read `git status` and the staged file list, and unstage any tool cache or local state file (`.wrangler/`, `.firebase/`, `node_modules/`, build output).

### Nov 14, 2026: a failed staging build was deployed to staging

- Words: none; found by the DS4 lead.
- Wrong: the goldens-lock staging deploy ran in a fresh worktree without generated code, so `flutter build web` failed, but the same shell line went on to deploy the partial `build/web` (23 files, no `version.json`) to Firebase Hosting and the Cloudflare Worker. staging.pantas.study was broken from 15:07 to 15:09 UTC, until the lead re-released the previous Hosting version and mirrored it to the Worker.
- Why: the deploy steps were joined with `;`, not stopped on failure, and a fresh worktree needs `dart run build_runner build --delete-conflicting-outputs` before any Flutter build.
- Fix: every build-and-deploy line uses `set -e` or `&&`, and checks that `build/web/version.json` and `build/web/main.dart.js` exist before any `firebase deploy` or Worker upload. A fresh worktree runs codegen first.


### Nov 14, 2026: a functions deploy ran with the wrong firebase-tools

- Words: not Aedwon's; found by the integrator on a staging deploy and diagnosed by the security fixes lead.
- Wrong: a staging deploy used the global firebase-tools 15.26.0, which does not pass `functions/.env.<project>` to discovery, so the deploy planned functions the deployed code then did not export; every scheduled function failed its health check.
- Why: deploy steps said `firebase deploy` without naming the CLI, and the repository's pinned version differs from the global one on this Mac.
- Fix: a check. `functions/src/scheduleGate.ts` throws during discovery for pantas-prod or pantas-staging when the project's `.env` file is missing, naming the pinned CLI; tests in `functions/test/scheduled-gating.test.mjs` (failing first). Required step: functions deploys use `npx --prefix functions firebase deploy`.

- Nov 15 (manager): when Aedwon sets a multi-item goal, give an overall estimate at once and log it in the velocity log before work starts (E-080 had none until he asked). Back every timed lead step (cutovers, watches, staged rollouts) with a durable T3 scheduled reminder, because in-session timers die with the session; the Nov 14 18:07 Cloudflare cutover slipped 30 minutes without one.

### Nov 15, 2026: a merge went to main with red CI

- Words: none; found by the DS4 lead.
- Wrong: the deploy-guard branch was merged to main (88aee3378) while its CI had failed (a test pinned the old functions predeploy string).
- Why: the merge step grepped the whole wait-loop output for "CI completed success", which matched a line from an earlier poll; a later wait loop also used a short SHA, which `gh run list --commit` does not match.
- Fix: before any merge, read the CI conclusion directly with the full SHA (`gh run list --commit <full sha> --json name,conclusion -q '.[]|select(.name=="CI").conclusion'` must equal `success`). Main was fixed forward within 30 minutes (a01635b22, CI green); nothing was deployed from the red commit.


### Nov 19, 2026: the new manager burned the Claude 5-hour limit in a few hours

- Words: Aedwon, "burning usage too fast, what did you do".
- Wrong: on the second Claude account (Pro plan, much smaller limits than the first account), the manager ran an Opus integrator for the prod ship, then two Opus lead sessions at once (under-13 build and CET finish). The CET lead started 11 Sonnet workers in parallel. The 5-hour limit reached 93%.
- Why: the manager applied the Nov 15 relaxation ("you can accelerate things") made for the first account and did not read this account's limits before starting lanes.
- Fix: at takeover and before starting any lane, read the plan limits (`get_usage`). On this Pro account: one Claude lane at a time, at most 2 workers per lead, Sonnet or Haiku workers by default, and pause lanes when the 5-hour limit passes 70%. Bulk reading and generation go to Codex (`codex-pick`) or Gemini where the rules allow, not Claude workers.
