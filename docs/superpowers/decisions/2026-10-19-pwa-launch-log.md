# PWA launch: decision log

Chronological record for the decision to launch Pantas first as a progressive web app (PWA).
Controlling draft spec: `docs/superpowers/specs/2026-10-19-pwa-launch-design.md`.

Current status: Part A approved at balanced complexity on October 19. Freeze lifted for the PWA
launch scope. Next: the implementation plan in `docs/superpowers/plans/`. No application code
has changed.

---

### October 19: launch direction

Context: Aedwon asked to accelerate publishing because funds are short. Policy main was
`7e6acb4e` when read.

Aedwon's exact comment:

> okay here's the thing: I want to further accelerate to publish this service. I have made the
> following decisions
>
> 1. i will publish this as a PWA, deferred publishing on Android and iOS (i really am short of funds)
> 2. i will turn my base m4 macbook air as a sort of VPS (same reason, can't afford)
> 3. i will first only focus on CSE Professional and Subprofessional
> 4. i will use PayMongo as the merchant smth (idk exact term they receive payments)
>
> what do you think of this plan? my laptop is perpetually on (with only a few moments of
> downtime for restart) and always connected to wifi so
>
> i need you to help me steer things. i have a chatgpt plus plan as well. you are 76% used weekly
> usage and chatgpt is 16% used weekly (though resets come often here).
>
> what is the fastest path for me? i need to finish the content audit for CSE and the engg of the
> app as a PWA. this is flutter so PWA is feasible. the app will support both web and mobile views
> (designs are separate projects in Claude Design).

Decisions recorded:

1. **PWA first.** Android and iOS store publishing is deferred.
2. **MacBook as server.** Proposed by Aedwon. See the recommendation below; not yet resolved.
3. **Scope: CSE Professional and Subprofessional only** for the first launch.
4. **PayMongo** as the payment provider (the merchant account that receives payments).

Claude's assessment, as offered:

- PWA first: agreed. The repository has no web platform yet. Mobile-only parts need web
  handling: local notifications, Crashlytics, the content database install, secure storage, and
  RevenueCat purchases.
- MacBook as server: recommended against. Home power cuts, Wi-Fi drops and restarts would take
  payment confirmation offline, and exposing a personal machine is a security risk. The backend
  is already Firebase (Firestore, Auth, Functions, Hosting), which can host the PWA and the
  PayMongo webhook. Cloud Functions needs the Blaze plan and a card on file, with a budget alert.
  Fallback without a card: a free Cloudflare Worker for the webhook. The Mac stays useful as a
  build machine.
- CSE only: agreed; it shrinks the content audit and the download.
- PayMongo: fits the Philippine market (GCash, Maya, cards). Merchant verification takes days and
  may need business registration (not verified). Aedwon should start it immediately.
- Provider split: the CSE content audit runs on ChatGPT, which has the most remaining usage.
  Claude leads engineering decisions and review. Haiku runs test suites and crawls.

Rejected or set aside: running production services on the MacBook (reasons above).

### October 19: capacity and on-device content

Aedwon's exact comment:

> but is Firebase even enough for the amount of requests (and also the lessons, quizzes, since
> they won't be saved on device - or am I wrong to think they won't be saved on device for a
> PWA?) that will happen? I expect the app to have thousands of users since we have a freemium
> model

Findings given (Firebase pricing page, dated October 14, 2026, read October 19):

- Lessons and quizzes ship inside the app as `assets/seed/content.db` (9.0 MB, 1.6 MB gzip).
  They are not fetched from Firestore.
- Free quotas: Firestore 50K reads, 20K writes and 20K deletes per day, 1 GiB stored. Hosting
  10 GB stored and 360 MB transfer per day, then $0.15/GB. Functions 2M invocations per month.
  Auth 50K monthly active users.
- Estimate (not measured): about 5 MB first download per new user, so roughly 70 new users per day
  fit the free transfer and 1,000 more cost about $0.75. Expected bill at thousands of users:
  about $0 to $5 per month, if progress sync batches writes instead of writing per answer.

Aedwon's follow-up, exact comment:

> to clarify, even on a PWA? the lessons/quizzes stays on-device?

Answer given: yes, after engineering work. The current seed installer writes to the device file
system (`dart:io` and `path_provider`), which browsers do not have. The web build must install the
database into browser storage instead, which the drift library supports. iPhone Safari may clear
site storage after 7 days without use unless the app is added to the Home Screen; content then
downloads again and synced progress is unaffected.

### October 19: download size and user experience

Aedwon's exact comment:

> wait explain to me first how that works, and will it affect UX? last time the APK for testing
> was over 150 MB

Answer given: the 150 MB APK was likely a debug build, which includes developer tooling and code
for every processor type. It does not predict the web size. Estimated first load is 5 to 8 MB
compressed (to be measured in the web spike), about 3 to 6 seconds on Philippine mobile data.
Later opens load from the phone in about 1 to 2 seconds. Scrolling and text feel slightly less
smooth than native.

Aedwon's exact comment:

> yes you can do the techniques needed to optimize for performance and UX. what's the game plan

Result: performance and user-experience optimization is in scope. The plan offered is recorded in
the draft spec. Claude recommended balanced complexity. Aedwon has not yet chosen a complexity
level, approved the spec, or lifted the freeze.

### October 19: record the plan

Aedwon's exact comment:

> Write the PWA launch plan and my four decisions into the repo docs now. No app code changes yet.

What changed: this log and the draft spec were added on main. No application code changed.
`docs/superpowers/plans/new-design/STATUS.md` was not edited, because its lock is held by the
Codex lead; the PWA direction still needs to be reflected there.

Mistake recorded: in the earlier reconciliation report, Claude offered to push the 7 local W4c
commits. The engineering restart log (October 18) says W4c source stays local until the whole
family audit. Those commits must not be pushed outside that sequence.

Open decisions for Aedwon:

1. Approve the plain-language section of the draft spec.
2. Choose minimal, balanced or hardened complexity.
3. Lift the application-code freeze for the PWA launch scope.
4. Confirm Firebase hosting instead of the MacBook as server, and whether a card can go on the
   Blaze plan.
5. Decide how the PWA work relates to the in-flight new-design restart (see the spec).

### October 19: Part A approved and open decisions answered

Aedwon's exact comment:

> part A is approved
>
> go with balanced
>
> i authorize the app-code freeze
>
> okay I can handle Blaze
>
> new design is final. it should be finished and integrated
>
> yes okay since this is a PWA now, I can accept prepaid passes.
>
> okay with no reminders.
>
>
> also anent all this, i have $39 left on Claude cloud credits, so should you run out of limits I
> can temporarily resume work there (or maybe you do that if you can access)
>
> also, for the content audit, would you still continue with the level method it's currently on?
> the only difference is we laser focus on CSE topics only

Resulting decisions (numbers match the spec's "What needs your decision"):

1. Part A approved.
2. Complexity: balanced.
3. Application-code freeze lifted for the PWA launch scope. Recorded wording is "i authorize the
   app-code freeze"; read as lifting it, because it answered the question "Lift the freeze?".
   Claude confirmed this reading in the reply. The completion permissions in `WORKFLOW.md` for
   merging approved work into main now apply to PWA launch work.
4. Hosting: Firebase on the Blaze plan with a budget alert. The MacBook does not run production
   services.
5. The PWA ships on the new design. The new-design W4 screen families must be finished and
   integrated first. The W4 serial sequence and its Codex lead lock in `STATUS.md` still govern
   that work.
6. Products sell as prepaid access (weekly, monthly, yearly and the pass), renewed by hand. No
   automatic renewal on web. The trial rule for prepaid access is still to settle in the plan.
7. No reminders at first launch.

Content audit answer given: keep the five-level method. Levels 1 to 3 are already accepted for all
exams, including both CSE exams. Levels 4 and 5 narrow to lessons and question sets tagged for CSE
Professional or Subprofessional (rough count: 71 of 158 lessons). This narrowing is a scope change
to the audit plan and is recorded here; the audit plan update is pending.

Cloud credits answer given: Claude cannot move work to the credits or spend them. If limits run
out, Aedwon can resume in a cloud or API session; this log, the spec and `STATUS.md` are the resume
point.

### October 19: content production phase

Aedwon's exact comment:

> hmm there's a missing step, the audit is only an audit. there are stills steps to produce the
> lessons and quizzes and illustrations. first two can be delegated to chatgpt (even web chat would
> work) and illustrations as svg by haiku 5.5 (would you recommend this? it uses little usage for
> simple illustrations - if there are any for CSE)

Correction accepted: the plan lacked a production phase after the audit. Answer given:

- Lessons and quizzes: ChatGPT, following `docs/content/lesson-authoring-runbook.md`,
  `docs/content/question-authoring-runbook.md` and the style guides. Codex is preferred over web
  chat because it writes into the repository; web chat is overflow.
- Illustrations: Haiku, but not as SVG. The app has no SVG support; figures are drawn in code by
  the figure types in `lib/core/ui/figures` (registry plus 23 figure widgets). Haiku writes the
  data for those types, which also gives light and dark themes.
- CSE figure count is unknown until audit Levels 4 and 5.
- Production can overlap the audit, one subject at a time.

### October 19: quality assurance and model split

Aedwon's exact comment:

> since the scope is now limited to CSE only, I can QA the lesson content and illustrations myself.
> multi-agent checks, scripts and other token-using tasks are reserved for questions only. the
> principle is: be cost-effective. I want to deliver this product as early as possible. this should
> also be your split too. high-level agents like Opus 5.5 medium for reasoning/planning/escalation/
> high-level audit(not content. can also use Astra if available); Sonnet 5.5 medium 6.1 Sol for
> engg work; Haiku 5.5 or 6 Luna or chatgpt web chat (i will manually paste prompts for this) for
> the smaller, easier, mechanical work where possible

Decisions:

1. Guiding principle for the PWA launch: be cost-effective and deliver as early as possible.
2. Aedwon personally reviews CSE lesson content and illustrations. Agent review, multi-agent
   checks and token-using checks apply to questions only. For CSE illustrations this replaces the
   October 5 pipeline's different-model visual critic and separate accuracy check.
3. Model routing for this launch (roles stay as defined in `SUBAGENTS.md` Part 7b):
   - Lead work (reasoning, planning, escalation, high-level engineering audit, not content audit):
     Opus 5.5 at medium effort, or Astra when available.
   - Engineering implementation: Sonnet 5.5 at medium effort, or GPT 6.1 Sol.
   - Small mechanical work: Haiku 5.5, GPT 6 Luna, or ChatGPT web chat with prompts that Aedwon
     pastes himself.

Claude's recommendation, offered and not yet answered:

- Keep the deterministic content validators for lessons. They cost almost no tokens, and a
  malformed lesson file can break the content build for the whole app.

Open question for Aedwon: whether audit Level 4 (agent-run lesson standards check) is replaced by
his own review for CSE lessons, leaving only Level 5 (questions) as an agent-run level.

### October 19: clarification of Aedwon's review pass

Aedwon's exact comment:

> my pass is only QA after things have been audited and rewritten/refactored as necessary, just to
> be clear

Correction to the previous entry, decision 2: audit Levels 4 (lessons) and 5 (questions) both
stay, narrowed to CSE. After the audit, lessons, questions and illustrations are rewritten or
refactored as the findings require. Aedwon's own pass is the final QA of the rewritten CSE lessons
and illustrations; it replaces agent verification of that rewrite, not the audit. Rewritten
questions keep agent verification (multi-agent checks and scripts). The open Level 4 question is
answered: Level 4 is not replaced.

Still open: whether lessons keep the deterministic format validators (Claude recommends yes).

### October 19: format checks kept; implementation plan written

Aedwon's exact comment:

> Keep the low-cost format checks for lessons. Write the full PWA implementation plan now,
> including audit, rewrite and QA, W4 sequencing, and model routing.

Decision: rewritten lessons keep the deterministic format gates (`python3 tools/audit/run_all.py`
and the content import) before Aedwon's QA.

What changed: `docs/superpowers/plans/2026-10-19-pwa-launch.md` added. It sequences Lane A
(finish W4, adjusted for the PWA), Lane B (web foundation and speed), Lane C (PayMongo), Lane E
(CSE audit, rewrite, QA) and Lane L (launch hardening). Facts came from a read-only Haiku crawl.

Revision to the spec estimate: the spec's 2 to 3 weeks assumed the current screens. Shipping on the
finished new design makes W4 the critical path. The plan estimates about 4 weeks if W4 runs in
parallel lanes (plan decision D2), and about 3 weeks more if W4 stays serial.

Open decisions D1 to D9 are listed in plan Part A with recommendations. None is answered yet.

### October 19: faster first open

Aedwon asked whether the first download could happen in the background. Options offered: an
instant HTML loading screen (already planned), content download after the first screen (already
planned), a plain-HTML Welcome screen shown while the engine downloads, and loading less-used
screens on demand. Recommended: add the last two, about 1 to 2 days together.

Aedwon's exact comment:

> okay add them. it's for better UX after all

What changed: plan tasks B7a (HTML Welcome screen, must match the approved Welcome board and pass
the visual companion) and B7c (deferred loading for mock exam, settings and account, and the Pro
page) added. B8 target adds the Welcome screen visible within 1 second on a throttled mobile
profile.

### October 19: answers to plan decisions D1 to D9

Aedwon's exact comment:

> D
>
> 1. ok
> 2. won't that burn my limited weekly/5-hour usage?
> 3. ok
> 4. ok
> 5. is CSE done for level 4? if so, okay then i authorize. if possible this part is also done
> through chatgpt web chat (me prompt pasting - help me with a tool that i can just click to copy
> the prompt) so it doesn't use my usage
> 6. let's implement this. so they can feel the difference and eventually convert
> 7. it should be encrypted.
> 8. already bought. it's pantas.study
> 9. can you run a haiku 5.5 medium to check for me

Results:

- D1 approved: the web and payments lanes run alongside W4. This is an exception to the October
  16 one-branch-at-a-time rule for those lanes only.
- D2 not answered; Aedwon asked about usage. Answer given: parallel lanes do the same total work
  sooner, so total usage does not rise, and the single end-of-family audit lowers it. Usage per
  5-hour window rises, because up to 3 lanes run at once. W4 implementation runs on ChatGPT
  quota (Codex lead, Sol implementors), not Claude. Still awaiting a choice.
- D3 approved: W4g after launch.
- D4 approved: one Level 4 reading chat per CSE lesson.
- D5 not authorized. The condition fails: Level 4 has not run for any lesson (inbox empty,
  `status.md` first line still BLOCKED). Aedwon wants Level 5 run through ChatGPT web chat with
  prompts he pastes, and a page with one-click copy for each prompt. The existing Level 4 page
  (`level4/page/index.html`, `server.py`) is built around the relay dispatcher and has no copy
  buttons, so a copy-prompt page is needed for Level 4 as well.
- D6 approved: a free trial on web, so students feel Pro and convert. Server-granted, once per
  account.
- D7: the web study database must be encrypted. Claude to state the limit: a browser has no
  secure key store, so the key protects against copying the stored files, not against code running
  on the site.
- D8: domain `pantas.study`, already bought.
- D9: Haiku 5.5 at medium effort is checking PayMongo's published fees.

### October 19: PayMongo fee check (D9)

Haiku 5.5 (medium) read https://www.paymongo.com/en/pricing on October 19 (page date not shown).
Rates are listed "exclusive of VAT": local cards 3.125% + ₱13.39; international cards 4.02% +
₱13.39; GCash 2.23%; Maya 1.79%; GrabPay 1.96%; ShopeePay 1.70%; QR Ph 1.34%; BillEase 1.34%;
online banking "0.71% or ₱13.39". Payouts ₱10 each. No monthly fee listed. The Accept Payments page
conflicts (cards 3% + ₱15; e-wallets 2.5%). Unconfirmed: 12% VAT on the fee, Checkout method
coverage, payout schedule.

With 12% VAT on the fee (Claude checked two rows by hand): a ₱49 Weekly pays ₱16.71 by local card
(34%) and ₱1.22 by GCash. ₱149 Monthly pays ₱20.21 by card (14%) and ₱3.72 by GCash. ₱1,199 Yearly
pays ₱56.96 by card (5%).

Recommendation offered: hide cards for Weekly and keep e-wallets and QR Ph; keep cards for Monthly,
Yearly and the pass. Awaiting Aedwon's choice.
