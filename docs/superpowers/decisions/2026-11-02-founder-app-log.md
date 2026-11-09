# Founder app: decision log

Spec in progress: `docs/superpowers/specs/2026-11-02-founder-app-design.md`.
Policy read from `origin/main` at be4164b7. Payment and account facts read from
`origin/web/staging-candidate-r1` at 412a389b. Guardian facts read from `web/guardian-consent`
at 9db8faab.

## November 2, 2026: weekly tasks

Question: "After launch, which of these do you expect to do at least once a week?"

Options offered, with costs:

1. Answer students (recommended): look up a student from a support email and check their payment
   and Pro. Cost: already in the first build.
2. Check numbers (recommended): sign-ups, payments and errors on one page. Cost: a second build,
   and some figures have no easy source yet.
3. Review question reports: read what students flagged and send it to the Content Pass queue.
   Cost: the app must start sending reports, which also changes the approved copy.
4. Make marketing posts: build posts from real question screens. Cost: the largest tab, and it
   depends on Content Pass finishing.

Aedwon's answer: "Answer students (Recommended),Check numbers (Recommended),Review question reports,Make marketing posts"

Result: all four are weekly, so frequency removes no tab. There is no usage data yet; this is his
estimate. Cuts must come from what existing services already do.

## November 2, 2026: PayMongo refunds

Question: "How should the Support tab handle a PayMongo refund?"

Facts given first: the Pantas records already flag duplicate payments and paid passes that need a
refund. PayMongo allows refunds for 60 days on cards and 30 days on QR Ph. A QR Ph student must
claim a transfer link within 3 days. The server ends access once PayMongo reports the refund, not
yet tested with a real test-mode refund. No web purchase goes through RevenueCat.

Options offered, with costs:

1. Check, then PayMongo (recommended): the app checks eligibility and copies the payment ID; he
   refunds on PayMongo's dashboard; the app logs the result when PayMongo reports it. Cost: one
   extra step. Benefit: no refund code and no PayMongo key on the Mac.
2. Refund inside the app: one confirmed click sends the refund. Cost: new money-moving code, two
   PayMongo refund addresses (cards and QR Ph), a key on the Mac that can refund any payment.
   Test-mode refund support is unconfirmed.
3. Dashboard now, app later: launch with option 1 and add in-app refunds only if refunds become
   common. Cost: a second small build later, only if he asks.

Aedwon's answer: "Check, then PayMongo (Recommended)"

## November 2, 2026: production access

Question: "How should the app get access to production accounts?"

Options offered, with costs:

1. Google sign-in each open (recommended): he signs in with Google when he opens the app. It gets
   access lasting up to an hour, kept in memory, through an account limited to what Support needs.
   Cost: a few one-time setup steps and one sign-in each open. No key on disk.
2. Key in Mac Keychain: the app opens with no sign-in, using a service account key. Cost: the key
   never expires, so anything that gets it can grant Pro or delete accounts until it is replaced.
3. Admin cloud functions: the Mac holds no production rights and the app calls locked-down
   functions. Cost: new internet-facing functions that can grant Pro and delete accounts, the
   target he wants to avoid, and each change needs a deploy.

Aedwon's answer: "Google sign-in each open (Recommended)"

## November 2, 2026: where UI options are shown

Aedwon's exact comment: "btw please use a new claude design artifact for the UI/UX"

Result: UI options for this spec use a new Claude Design artifact instead of the browser companion.

## November 2, 2026: design tokens

Aedwon's exact comment: "um which choice is the most intuitive here. also, please use the web's design tokens, it's in pantas-web (ignore if you're already using it)"

The first canvas version did not use them. All three Support layouts were restyled with the token
values in the pantas-web home page: ground #FBF9F4, surface #FFFFFF, faint #F1EDE4, ink #26221B,
muted #6E675C, control #8A8276, rule #E5DFD3, green #1D5C50, tint #E3EFEA, amber #996A15,
rust #A33B2E, Inter 400, 600 and 700. Answer given to his question: A is the most intuitive.

## November 2, 2026: overall look comes first

Aedwon's exact comment: "hmm i think we skipped some steps. can we first settle on the overall look of the dashboard? you didn't even ask me"

Mistake: the first canvas chose a look and went straight to layouts without asking. The layout choice
is paused until the overall look is settled. Three looks were added to the canvas.

## November 2, 2026: overall look

Question: "Which overall look do you want for the app?"

Options offered, with costs:

1. Green rail (recommended): green side menu, cream background and white cards. Tabs are easy to see.
   Cost: the green takes up space, and the screen holds less than Look 3.
2. Paper: cream throughout, tabs across the top, thin lines instead of cards, larger text. Calmest.
   Cost: the least data per screen, and sections stand out less.
3. Compact: white work area, small controls and real tables. Shows the most at once. Cost: 13px text
   and smaller click targets, and it feels less like Pantas.

Aedwon's exact comment: "green rail but add icons please for easier recognition. also plan out how notifications would look if something needs my attention, both in the sidebar and on the page"

Result: Look 1 with an icon on each tab. Notification options added to the canvas.

## November 2, 2026: redo the visual direction

Aedwon's exact comment: "please think this through more. i am not impressed with your ideas of a dashboard. i want this to look beautiful, elegant, and intuitive"

Mistake: the earlier screens were a generic admin template with Pantas colors. They ignored the
site's type scale and soft shadows, and they gave every item the same weight.

New direction work starts from what he does on opening the app: see what needs him, then find a
student. The page states what needs him. A coverage bar shows a student's paid Pro time, so a
refundable period is visible at once. Delete data is separated from everyday actions. Notifications
are part of each direction, not a separate choice. Three directions were drawn: A Green frame, B Open
page, C Pass card, each with a needs-you screen and a student screen. Earlier boards were moved to an
"Earlier drafts" page, not deleted.

## November 2, 2026: visual direction

Question: "Which direction do you want to refine?"

Options offered, with costs:

- A. Green frame (recommended): whole window green with a cream sheet inset. Calm and familiar. Cost:
  the frame takes some width.
- B. Open page: huge type like the site's hero, with a floating menu. Most striking. Cost: shows the
  least per screen.
- C. Pass card: each student looks like a physical exam pass. Most memorable. Cost: gets long as
  payments grow.

Aedwon's answer: "A. Green frame"

Result: canvas version 8, boards FrameHome and FrameStudent, are the base for further screens.

## November 2, 2026: confirmation pattern

Question: "Which confirmation do you want?"

Options offered, with costs:

1. Side sheet (recommended): slides in beside the student and shows the new end date with a coverage
   bar. The confirm button names the action. Cost: the most space, and part of the student is covered.
2. Center dialog: all attention on the decision. Cost: covers the student and shows the date as text.
3. Popover: opens under the button, quickest. Cost: no coverage bar, easiest to confirm by mistake.

Every confirmation saves a log entry. Delete data also needs the student's email typed.

Aedwon's answer: "Side sheet"

Result: canvas version 9, board ConfirmSheet, is the confirmation pattern.

## November 2, 2026: where grants are recorded

Question: "Where should Grant Pro record the grant?"

Options offered, with costs:

1. Pantas records (recommended): grants work like trials and web payments, appear on the coverage bar,
   and can be removed one at a time. No RevenueCat key on the Mac. Cost: a small server change, plus
   updating the giveaway line in docs/pricing.md.
2. RevenueCat: keeps the October 4 plan, with no new grant type. Cost: a RevenueCat secret key on the
   Mac or grants on its dashboard; removing one removes all of a student's promotional grants.
   Whether RevenueCat is set up for production could not be confirmed from the repo.

Aedwon asked: "um is revenuecat still needed since payments would be in paymongo? or will it be needed in the future when the app finally lands on the Play and App Stores"

Answer given: not for the web launch; probably for store builds, whose billing it connects to Pro. Store
rules were not rechecked. The server combines both sources; the store app's side was not checked.

Aedwon's answer: "ok proceed"

Result: option 1. This supersedes the launch giveaway route in the October 4 log, and docs/pricing.md
must change with the build. RevenueCat stays for later store builds.

## November 2, 2026: what Remove Pro can end

Question: "What should Remove Pro be able to end?"

Options offered, with costs:

1. Free access only (recommended): ends grants and trials. Paid time ends only through a refund or a
   dispute, so paid access cannot be taken by mistake while the money is kept. Cost: no one-click way
   to cut off someone who breaks the Terms.
2. Paid access too: can also end paid time, with a required reason and a warning that no money goes
   back. Covers account sharing and other abuse. Cost: legal risk if used wrongly; a lawyer should
   review the suspension clause first.

Aedwon's answer: "Paid access too"

Result: option 2. The Terms draft (section 6) refunds unused prepaid time when an account is ended for
any reason other than a breach, so the only reason offered for ending paid access is a Terms breach.
Other cases use the refund path. Lawyer review of that clause is listed before live payments.

## November 2, 2026: Delete data

Question: "How should Delete data work?"

Options offered, with costs:

1. Delete from the app (recommended): runs the same full deletion students get. He types the student's
   email and picks a reason. Blocked while a refund or dispute is open. The log keeps the account ID,
   not the email. Cost: the most dangerous action on the Mac, and a new server-side path because
   today's deletion only works for the signed-in student.
2. In-app deletion only: instructions for the student, with no destructive action on the Mac. Cost: a
   request from someone locked out needs a manual fix.

Aedwon's answer: "Delete from the app"

## November 2, 2026: Numbers on day one

Question: "What should Numbers show on day one?"

Facts given first: sign-ups, payments, refunds and server errors are available. Failed payments need one
more PayMongo event on the webhook, and PayMongo does not say exactly when it fires. Crashlytics is off on
web, so nothing collects web app errors. No direct spend reading was found; Google documents a BigQuery
export. $5 budget alerts already exist on both projects.

Options offered, with costs:

1. Core numbers (recommended): everything available, plus failed payments. Firebase cost is a link to the
   billing page, and web errors show as "Not tracked." Cost: one webhook change and no cost figure.
2. Add real Firebase cost: the same, plus a spend figure from the export. Cost: extra setup, small
   BigQuery charges, and data that can run behind.

Aedwon's answer: "Core numbers"

Parked: web error collection, its own spec if wanted sooner than after launch.

## November 2, 2026: Inbox contents

Question: "What should the Inbox tab hold?"

Options offered, with costs:

1. Reports only (recommended): lists question reports, each sent to the Content Pass queue. Email stays in
   Gmail, and an address is pasted into Support to look up the student. Cost: the student app must start
   sending reports: a new server function, an app change, and wording to replace "Saved on this device."
2. Reports and email: adds Gmail messages to the tab. Cost: all of the above, access to his personal Gmail,
   and a second, weaker email client.

Aedwon's answer: "Reports only"

Open items raised: Cloudflare forwarding of support@pantas.study is only a proposal in the record found, so
it is unconfirmed. The Terms draft says contact@pantas.study and website drafts say support@pantas.study.

## November 2, 2026: when the student app sends reports

Question: "When should the student app start sending reports?"

Fact given first: the beta runs November 9 to 15, and as built every report stays in the tester's browser.

Options offered, with costs:

1. Before the beta (recommended): reports reach Firestore from the first day and can be read there until
   the Inbox tab exists. Cost: roughly a day of work (estimate) on a candidate due November 7, a change to
   approved wording, and his approval to deploy.
2. After the beta: protects the November 7 date. Cost: wrong questions are only heard about through the
   Facebook group or email; saved reports upload later only if that is built and the tester keeps the browser.

Aedwon's answer: "Before the beta"

Result: the sender is separate from the founder app. No code until the spec is approved, as he instructed.

## November 2, 2026: how the Mac app is built

Question: "How should the Mac app be built?"

Options offered, with costs:

1. Local web app in its own Mac window (recommended): same approach as Content Pass. Opens from Spotlight,
   reuses the server's payment and deletion code, can match the canvas exactly, and Content Pass can fold in
   as a tab. Cost: a small local server that must accept requests only from this Mac and this app.
2. Native SwiftUI: the most Mac-like feel. Cost: money and deletion logic rewritten or duplicated, and the
   design rebuilt, so a 1:1 match gets harder.

Aedwon's answer: "Local web app"

## November 2, 2026: complexity for the Support build

Question: "Which complexity do you want for the Support build?"

All options include Support as settled: lookup, coverage bar, refund check, grant, remove, delete, the
needs-you list, and a log entry for each action. Times are rough estimates of agent build time; planning
takes about half a day on top.

Options offered, with costs:

- Minimal (2 to 3 days): production access only, the log is a file. Checked against the Firebase emulator
  plus one test-mode refund. No safe rehearsal on staging from inside the app.
- Balanced (4 to 5 days, recommended): adds a staging switch, a log screen, and an outside Codex audit
  because these actions touch money and deletion. Cost: the time and the audit usage.
- Hardened (1 to 2 weeks): adds a data export before each deletion and alerts while the app is closed, which
  needs a key on the Mac and undoes the Google sign-in choice.

Aedwon's answer: "balanced, but my codex limits reset in 2 days i think (do double check)"

Result: Balanced. Checked with the Codex usage tool on November 2: accounts a, b and c are at 100%, 95% and
95% of their weekly limits and reset on Wednesday, November 4, between 14:45 and 18:20 by this Mac's clock
(Pacific). The audit runs after the build, so this does not block it. Do not start the audit before the reset.

## November 9, 2026: brainstorm resumed, new facts

Resumed by the overall manager (Aedwon: "for the rest of items, please finish them"). Spec work only.
Policy read from `origin/main` at 6d6a70f94. Code facts read from `origin/web/design-system-4` at
89559a2e2, Content Pass from `origin/claude/content-pass-r1-4eb59e` at c1b94901f, the privacy batch
spec from `origin/docs/legal-texts-r1` at d3550d824.

Facts that change earlier entries:

- The question-report sender was never built. The Nov 2 answer "Before the beta" waited on this spec,
  which was not written, so reports still stay on the device ("Saved on this device"). The beta
  started Nov 9 without it.
- Web app errors are now collected: since Nov 7, `reportClientTelemetry` writes web errors and
  speed marks to Cloud Logging (30 days). The Nov 2 "Not tracked" no longer holds.
- Feedback (Beta) is live on prod (Nov 7) and stored per tester in Firestore. It carries no question
  ID. It is read in the Firebase console.
- The 1-year beta reward is a Pro source (`beta_reward` grants), as are trials, beta grants and
  PayMongo payments.
- PayMongo refuses API refunds for QR Ph. Aedwon's ruling (Nov 9, launch log): refund QR Ph by bank
  transfer, then record it with the manual refund runbook in `docs/OPERATIONS.md`. A refund larger
  than the PayMongo balance is refused (D8).
- PayMongo still runs test keys. Live payments wait for the BIR COR, the DTI name and the sole
  proprietor upgrade (launch log, Nov 9).
- Giveaway winners are found by their short public ID (Oct 4 log), not only by email.
- Content Pass is a Flutter web page with a Dart server on 127.0.0.1 and a native Mac window. It
  is not merged while Aedwon refines it. Its "queue" is its review list; it has no intake for reports.
- New requirement (Aedwon, Nov 9, launch log): an "Owner inputs" tab. His words, relayed by the
  manager: "founder app only. you're underestimating your speed of completing things. you should be
  able to finish the things you've listed in a week i bet". The manager's list: business phone; BIR
  COR or registration; DTI business name; the PayMongo sole proprietor upgrade; invoice or official
  receipt method; website footer facts (his own copy); NPC registration; signed child privacy
  assessment; the RevenueCat secrets; the guardian mail key. The privacy batch spec adds the sender
  address for warning and manage emails and a monitored dpo@pantas.study inbox.
- Founder app UI boards must be Claude Design boards on design system 4.0 (DS4), with a fresh DS4
  review and a render check before he sees them (process-improvement entry, Nov 9).

## November 9, 2026: lead rulings (D191, final)

Made under Aedwon's delegation. Each can be reversed by him.

1. **Look moves to DS4.** The approved Green frame (Nov 2) breaks DS4 rules: a teal window frame,
   card shadows, Inter, red for a system problem, amber buttons. The founder app is rebuilt on DS4's
   AppShell, SidebarNav, Card, ListRow, Sheet and the rest, keeping what he chose in the Green frame
   boards: the needs-you home, the student page with the coverage bar, side-sheet confirmations, and
   Delete data set apart. He sees the DS4 boards with the spec.
2. **Build stack.** Plain web pages that load DS4's `tokens.css` and `bundle.css`, so the app matches
   the boards; a local Node and TypeScript server that imports the payment, grant and deletion code
   in `functions/src` instead of copying it; a native Mac window like Content Pass, opened from
   Spotlight. The server listens on 127.0.0.1 only and requires a secret the window passes at launch.
   Content Pass has no such check today; that is noted, not changed here.
3. **Content Pass stays a separate app** in this build. Folding it in is its own later change.
4. **Lookup** accepts an email, a short public ID or an account ID.
5. **Coverage bar** shows every Pro source: PayMongo payments, trials, beta grants, the beta reward,
   founder grants and store passes.
6. **Grant Pro** writes a `founder` grant in the Pantas records (Nov 2 choice). Lengths: 1 week,
   2 weeks, 1 month, 3 months. Reasons: Giveaway, Support fix, Other with a note. Refused for a guest
   account with no email, per the Oct 4 giveaway rules. `docs/pricing.md` changes with the build.
7. **QR Ph refunds** in the app: the refund sheet says to send a bank transfer, then "Record bank
   refund" with the amount and bank reference. The local server calls the same refund code the
   webhook runs, directly. The webhook signing secret never reaches the Mac, because it could also
   fake a paid event. Card refunds stay "check, then PayMongo" (Nov 2).
8. **Delete data** gets a server-side path that deletes a named account with the same steps as
   self-deletion. It is refused while a refund, dispute or refund follow-up is open.
9. **Numbers** shows the web error count from the telemetry log instead of "Not tracked".
10. **Inbox** holds question reports only (Nov 2). The report sender ships with this build: a
    rate-limited callable with the server-side limits the abuse review asked for, and new wording in
    place of "Saved on this device" (lead's copy call, written rule 4). Beta feedback stays in the
    Firebase console; it ends with the beta.
11. **Owner inputs storage.** Each item has a state (Not yet, Ready) and, where safe, a value. Values
    and states live in a file on his Mac, never in the public repository. Secrets (the RevenueCat
    secret key, the guardian mail key) are pasted once and written straight to Google Secret Manager
    on the chosen project. They are never saved on the Mac or shown again; the tab shows only when
    each was set. The founder service account may add versions to those named secrets only. Each
    item names the work it unblocks. Sessions on this Mac read the file when blocked on an input;
    `docs/OPERATIONS.md` gets the pointer. Sessions without this Mac cannot read it.
12. **The action log** is a Firestore collection on each project, written for every grant, removal,
    refund record and deletion, and shown on the Log screen.

## November 9, 2026: Posts, complexity and build order

Options offered (relayed by the manager), with costs:

1. Posts tab. Separate spec later (recommended): after Content Pass merges and he gives marketing
   direction; posts are made by hand until then. Or in this build: delays the rest, and no design
   exists yet.
2. Complexity for the whole app. Balanced (recommended), as chosen for Support: staging switch, log
   screen, outside Codex audit for money and deletion; roughly 5 to 7 days of build. Or Minimal:
   about 2 days shorter, no staging switch, the log is a file. He asked what Hardened means; the
   manager answered: an export before each deletion, plus alerts while the app is closed, which
   need a key on the Mac.
3. Build order. Owner inputs first (recommended): the shell, sign-in and the Owner inputs tab in
   about a day, then Support, Numbers and Inbox. Or all at once: one release, Owner inputs wait
   about a week.

Aedwon's answer, verbatim (relayed by the manager): "1. okay do what you recommend / 2. okay go with balanced / 3. do what you recommend"

Result: Posts is a separate spec later. Balanced for the whole app. Owner inputs ship first, in
their own worktree, then Support, Numbers and Inbox. Build only after he approves the spec.
