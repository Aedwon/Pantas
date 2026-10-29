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

### October 19: D2 and D5 answered; content exposure question

Aedwon's exact comment:

> D2 let's try small first, say 2, and i'll see if we can extend to more
>
> D5 ok
>
> D7 should I be worried? they might be easily able to get my entire content corpus, that's why i
> originally offered to have my mac as a makeshift vps because of the requests, so that only those
> requests, not the entire thing, is vulnerable. is my understanding right? or am i missing
> something, please explain to me thank you! i'm still learning this stuff
>
> D6 D8 alright

Results:

- D2: remaining W4 families run in 2 parallel lanes, with one engineering audit per family at the
  end. Aedwon may extend to 3 later.
- D5: Level 5 for CSE questions is authorized to run alongside Level 4. Per the earlier answer, it
  runs through ChatGPT web chat with prompts Aedwon pastes from the copy-prompt page (plan E1b),
  instead of the Codex orchestrator, to save quota.
- D6 and D8 confirmed.
- D9 card choice still open.
- D7 follow-up: Aedwon's concern is copying of the content corpus, which is separate from
  encrypting the student's own database. Facts checked: lessons and questions ship whole in
  `assets/seed/content.db`, on Android today and on web as planned. The old `getProContent`
  function (Sanity query stub) is gone from `integration/new-design-r1`, so no content is served
  per request. Options offered in the reply; awaiting a choice.

### October 19: Pro content served per request

Options offered: (1) keep shipping the whole corpus in the app, fastest and fully offline, but one
download copies everything; (2) ship free content in the app and serve Pro content item by item
from Firebase after a Pro check with per-account limits, so bulk copying is slow and needs a paid
account, at about 3 to 5 days of work and some Firestore reads. Recommended: 2. The Mac is not
needed for either.

Aedwon's exact comment:

> go with 2 thanks. that's alright I know things cannot be fully stopped. I just want to make them
> work hard the same way I worked hard for the content haha either way it's better if they put
> that effort into making their own anyway

Decision: option 2. The goal is to make bulk copying slow and costly, not impossible. Added as plan
task C7. The free and Pro split of content must come from an approved record; `docs/pricing.md`
does not define it.

### October 19: D9 answered

Options offered: hide cards for Weekly (keep e-wallets and QR Ph), or keep cards on every plan.

Aedwon's exact comment:

> Keep cards on every plan, including Weekly.

Decision: every plan offers cards and all other PayMongo methods. Accepted cost: about ₱16.71 of
₱49 per Weekly card payment (estimate with VAT).

### October 19: execution started (B1, E1, E1b, free and Pro split)

Aedwon's exact comment:

> Start Lane B1 (web inventory), E1 (CSE scope reset) and E1b (copy-prompt page). Also find the
> approved free versus Pro content split.

Mid-task, Aedwon added:

> btw the CSE corpus is in the SSOT

Results so far:

- B1 done (Haiku 5.5, read-only, `integration/new-design-r1` at 5e6cda45):
  `docs/superpowers/plans/pwa-launch/evidence/B1-web-inventory.md`.
- E1 done (Haiku 5.5, read-only, corpus `content/question-qa-r2` at 765c5dc0):
  `evidence/E1-cse-scope.md` and `.tsv`. The SSOT tab "Pantas Audited Corpus r1"
  (t.38uf83creimq, October 5) gives the same counts: 64 Professional, 62 Subprofessional, 55 both,
  71 lessons. Its tags are provisional, as in the repository.
- Lead rulings on tag disagreements (Claude): the accepted Level 1 exam maps decide scope.
  (A) 21 lessons tagged CSE whose question files lack a CSE tag: in scope; fix the question tags in
  E5. (B) 5 spatial-abstract reasoning question files tagged CSE whose lessons the maps exclude
  (figure grouping, figure matrices, figure series, mental rotation, paper folding): out of scope;
  remove their CSE question tags in E5. (C) 6 lessons whose Professional or Subprofessional tags
  differ: the lesson tag wins; fix the question tags in E5.
- Level 4 CSE scope: 71 real packets plus 6 planted calibration packets for in-scope lessons
  (L4-1575, L4-6370, L4-7668, L4-5501, L4-7442, L4-8177), 77 pastes in total:
  `evidence/E2-level4-scope.txt`. Planted packets are kept because they cost 6 pastes and show
  whether a single reader misses planted defects.
- E1b copy-prompt page: in progress (Sonnet 5.5 implementor, audit branch).
- Free and Pro split: search in progress (Haiku 5.5).

### October 19: free and Pro split found; C7 needs a revision

Search (Haiku 5.5, read-only): `evidence/C7-free-pro-split.md`. The approved split is by feature,
not by content (`docs/design/DECISIONS.md`, October 4): lessons, the Study map, the reader,
bookmarks, custom quizzes and flags are free. Free gets one mock every 14 days; Pro unlimited.
Wrong-choice notes are Pro only (October 1 explanations log). Progress tables and findings are Pro.
No lesson or question file carries a Pro field. Conflict found: the mock reopen copy in code says 7
days; the record says 14.

Consequence: plan task C7 as written ("bundle free content, serve Pro content") protects almost
nothing, because nearly all lessons and questions are free. The goal Aedwon set (slow bulk copying)
needs a choice. Options offered:

1. Serve all lessons and questions per request to every signed-in student (free students get an
   automatic anonymous account), with App Check and per-account limits, caching what was opened
   and prefetching the student's next items in the background. Copying needs many requests;
   anonymous accounts are cheap to create, so limits slow a copier less than a paid wall would.
   About 3 to 5 days; Firestore reads estimated within the free tier at 1,000 daily students.
2. Serve per request only questions, keep lessons bundled.
3. Keep the bundle and serve only Pro-only data (wrong-choice notes) per request. Cheapest, protects
   little.
4. Change the split so part of the question bank is Pro. A pricing and product change.

Recommended: 1. Awaiting Aedwon's choice. C7 does not start until then.

### October 19: copy-prompt page ready (E1b)

- Built by Sonnet 5.5 (medium) on `docs/content-coverage-audit-r1` at 4d60a71e; reviewed by the
  lead (prompt adaptation, JSON extraction, Host, Origin and header checks). Lead reran both suites:
  28 new tests and 263 existing level4 tests pass. Clipboard copy was not tested in a real browser.
- The page adapts each packet for paste mode: the relay hand-in section is replaced by "reply with
  only the completed form as one JSON code block", and pasted replies go through the existing
  `handin.process` and `form.py` checks. One retry per chat; a held lesson can start over in a new
  chat.
- Reversal: the earlier entry kept 6 planted packets. The paste setup refuses planted packets, and
  scoring them needs the pilot report path, so they are dropped. Scope is the 71 real packets.
- Run state prepared: `~/.pantas-audit/level4-paste` (71 packets, role A). Scope and audit
  `status.md` pushed at 439603ca.
- Found: the October 8 autorun watcher (`autorun/run.sh`) is still running in a Terminal window. Every 10
  minutes it commits and pushes changes under the audit folders, and it resumes the Codex
  orchestrator if the `status.md` STATE line reads RUNNING. The STATE line is kept as BLOCKED so
  Codex stays stopped. Aedwon may close that window if the orchestrator is no longer wanted.

### October 19: sign-in timing, mock allowance, and Free-to-Pro exploits

Aedwon's exact comment:

> let's settle some things
>
> 1. the initial use, onboarding, so they know how the app works, they don't need to log in. we
> can surface a message, they must create an account if they want their progress saved.
> 2. authoritatively, i am increasing the cooldown for mock attempts to +1 per month (later on i
> could have marketing campaigns where i give these out for those who need + this includes Pro ver
> giveaways not just mocks, using redemption codes or using their UID)
> 3. i want to ask, how easy will a user be able to exploit Free and kind of surface the Pro? so at
> least we know how to proceed

Decisions:

1. No sign-in during onboarding or first use. The app already supports a silent anonymous account
   (`lib/core/auth`, 54 references on `integration/new-design-r1`). The app shows a message that a
   student must create an account to keep their progress. Wording and placement go to Aedwon with
   the visual companion.
2. Free mock allowance changes from one every 14 days (`docs/design/DECISIONS.md`, October 4) to one
   per month. This supersedes the 14-day rule, and the 7-day copy found in code. Whether "per
   month" means a calendar month or 30 days after the last mock: asked, not yet answered.
   Later idea, not launch scope: grant extra mocks and Pro through redemption codes or by account
   ID for marketing campaigns. This extends the October 4 giveaways log, which deferred free codes
   until after launch.

Facts for item 3 (lead check of `integration/new-design-r1`): the mock cooldown is computed on the
device from the last local attempt (`mock_availability_provider.dart`). Pro status comes from the
signed `pro` token claim and the payment provider. Pro-only data such as wrong-choice notes ships
in the bundled content. Analysis and recommendation given in the reply; awaiting choices.

### October 19: mock window, account for mocks, and Pro gating

Aedwon's exact comment:

> okay go with your recommendation on the mock 30 days
>
> 1. okay sure, but the assessment and all shouldn't right. for better UX?
>
>
> for 2 and 3, can we increase security here so the data is truly gated by Pro? and not editable
> by someone who knows how to code. because i think this is a credibility issue. this can be
> considered as weak architecture and so people still start to question, what else is leaking?

Decisions:

1. Free mock allowance: one mock per rolling 30 days after the last mock.
2. Starting a mock requires a real account, and the server counts mocks. Onboarding, the
   assessment and the rest of the app stay usable without signing in.
3. Pro must be enforced by the server, not by the app, as a credibility requirement. Scope options
   are offered in the reply.

### October 19: server-enforced Pro, option B

Options offered: (A) the server delivers all content, Pro-only items and mock papers after checks,
while Progress insights stay computed on the device, about 4 to 6 days; (B) A plus the roadmap
and Pro insights computed on the server, about 1.5 to 2 more weeks if rewritten. Claude first
recommended A. Correction recorded: Aedwon pointed out that the personalized roadmap is the
product's selling point. `docs/design/DECISIONS.md` makes Coming up and History (the full plan to
the exam) Pro, while the device computes the whole plan and only hides those parts. A shared
browser script could reveal them. Claude then recommended B, reusing the existing Dart roadmap
logic compiled for the server instead of rewriting it, estimated at about 1 week more than A
(to be confirmed in the first task).

Aedwon's exact comments:

> this is exactly why i offered my m4 macbook air as a vps because i expected these checks to be
> on our end. caching of course is expected for fast loads but it should request latest and update
> asap. does this make sense?
>
> progress being easily exposed and the method shared over the internet destroys the selling point
> of the app, which is your roadmap is personalized for you. or am I in the wrong here? let me know

> yes go

Decisions:

1. Option B with content option 1. The app never decides Pro. Content, Pro-only data, mock papers,
   the mock allowance, the roadmap and Pro insights come from Cloud Functions after the server
   checks the signed account and tier. Each account receives only what its tier allows.
2. Caching: show the cached copy at once, request the latest in the background, and update as
   soon as it arrives.
3. Answers sync to the server in batches per session, for every account, as the input to the
   server roadmap.
4. The server runs on Firebase, not the MacBook; this gives the server-side control Aedwon wanted.

This revises spec Part A ("downloads all CSE lessons and quizzes", "works offline"); the spec is
updated to match.

### October 19: C1 and C10 lead ruling

Aedwon's exact comment starting this work:

> okay good. continue

Ruling written: `docs/superpowers/plans/pwa-launch/C1-C10-ruling.md` (facts in `evidence/C1-*` and
`evidence/C10-*`). Summary: PayMongo and the web trial become a new grant ledger feeding W3's
existing coverage, claims and repair jobs; products reuse the Civil Service ids with web prepaid
lengths of 7, 30 and 365 days; answer sync for all accounts is a new server-only ingest path,
because existing sync is Pro-only by rule; the pure Dart roadmap engine runs on the server through a
shared package compiled to JavaScript behind a Node callable, with a half-day spike first.

Estimate revision: C10 is about 1.5 weeks, not 1 week, because the insight signals read the
database directly and need splitting into readers and pure functions. C7 to C10 total about 2.5
weeks.

Lead choice to surface to Aedwon: prepaid Monthly is 30 days and Yearly 365 days.

### October 19: prepaid lengths follow the calendar

Claude offered same-date renewal: Monthly ends on the same date next month (clamped to the last day
when that date does not exist, so January 31 ends February 28 or 29), Yearly on the same date next
year; early renewal adds one period to the current end; Weekly stays 7 days.

Aedwon's exact comment:

> okay yes that makes sense. also you've reset limits

Decision: replaces the 30-day and 365-day lengths in the C1 ruling. Ends are computed in Philippine
time (UTC+8).

B2 and B3 status: Codex Sol's first pass split every blocker behind web and native files (native
unchanged) and added the web scaffold, but stopped on the database: the official encrypted
`sqlite3mc.wasm` (ChaCha20 only) refuses a key on the Dart VFS ("Encryption is not supported by the
VFS"). Evidence: `evidence/B3-encrypted-web-db.md` on `web/pwa-foundation-r1`. A time-boxed second
pass is checking upstream guidance and VFS wrapping before any fallback. Also stopped: Google
sign-in on web needs its rendered button (visible change, goes to Aedwon), and Firebase web app
config values need the console or an authorized `firebase apps:create`.

### October 19: Firebase web apps created

Aedwon approved creating Firebase web apps ("go ahead") and re-authenticated the Firebase CLI
(signed in as business@aedwon.com). Claude created one web app named "pantas (web)" per project:

- pantas-dev-090126: 1:989349364007:web:6c2815acb478941bb9a902
- pantas-staging: 1:797279948229:web:5d863020ad5010864bcfac
- pantas-prod: 1:416041343210:web:cdf805fbfb28ca13639f93

Their SDK configs (public client identifiers, like the Android ones already in the options files)
go into the web branch of `lib/firebase_options_*.dart` on `web/pwa-foundation-r1` after the current
Codex pass, which is editing those files, finishes. API key restrictions (allowed HTTP referrers for
`pantas.study` and the staging hosts) are a Lane L task.

### October 19: roadmap server spike passes

Aedwon's exact comments:

> not another codex, but sonnet 5.5 medium
>
> also I'll start creating my PayMongo account in the meantime

> if you run out of usage make sure it's possible for me to have things picked up on a cloud session

Results: Sonnet 5.5 (medium) builds C2, C4 and C6 on `web/paymongo-r1` and ran the C10 spike on
`web/roadmap-server-spike-r1` (75690df3, pushed). The pure Dart roadmap engine compiles with
`dart compile js` unchanged; Node output matches the Dart VM byte for byte on 10 scenarios
(lead reran: 16 of 16 Node tests pass); 33 KB gzip; about 1 ms per call. Caveats: not run on
Node 20; the engine uses local calendar dates, so the server must pass Philippine dates. C10's
runtime choice (compiled Dart behind a Node callable) holds. Resume point for cloud sessions:
`docs/superpowers/plans/pwa-launch/RESUME.md`, updated at each checkpoint; working branches are
pushed at each checkpoint.

### October 19: payment functions reviewed

`web/paymongo-r1` at 694215d4 (pushed): checkout callable, webhook and web trial on a server grant
ledger feeding W3 coverage and claims. Lead review of the signature, re-read and amount checks found
no issue. An automated security review raised three gaps, all fixed in 694215d4: coverage now
respects each grant's start and a refund pulls later stacked grants forward; a refund that arrives
before its payment leaves a tombstone so the grant is born revoked; refund and dispute event names
are handled for every name PayMongo's docs list, and an unidentifiable refund returns 500 so it
retries. Lead reran: plain 107/107, emulator 131/131, tsc clean, Dart products test 4/4.

Open for Aedwon: a partial refund currently revokes the whole grant (ruling choice). Not verified:
any live or test-mode PayMongo call; that waits for the PayMongo account and test keys.

### October 19: partial refunds shorten access proportionally

Options offered: any refund revokes the whole grant, or only a full refund revokes.

Aedwon's exact comment:

> partial refunds are a thing? i assume this is a paymongo thing right? if so, yes it should revoke
> the pro commensurately

Decision: a partial refund shortens the grant in proportion to the refunded share of the amount
paid (for example, half refunded removes half the grant's length); several partial refunds add up;
a full refund revokes. Later stacked grants move earlier to close the gap. A dispute (chargeback)
still revokes the whole grant. Context given: only the merchant (Aedwon) issues refunds, from the
PayMongo dashboard or API; a student cannot trigger one, apart from a bank dispute.

### October 19: refund policy

Options offered: (1) no refunds except errors (double charge, payment that did not unlock Pro,
technical failure on Pantas's side), relying on the 7-day trial; (2) 7-day money-back on a first
purchase once per account; (3) refund of unused time on request. Passes not refunded after their
exam date in every option. Recommended: 1.

Aedwon's exact comment:

> go with 1. also can this be verified if indeed they paid twice and that the first did not unlock
> their Pro?

Decision: option 1. The policy goes into `docs/TERMS.md` and on pantas.study before PayMongo
verification and launch (Lane L4), with a legal check against Philippine consumer rules advised.
The proportional refund mechanism stays, since Aedwon may still issue partial refunds for errors.

Proportional partial refunds built on `web/paymongo-r1` at caf2142e (pushed). Lead reran: plain
110/110, emulator 142/142, tsc clean. Pending Aedwon: whether to add an admin lookup tool for
double charges and payments that did not unlock Pro (about half a day).

### October 19: what students can ask to have refunded

Aedwon's exact comment:

> okay those two points make sense. also, maybe record this somewhere but they cannot request for
> a partial refund (even though the code allows it right)? they can only refund excess just like on
> the first point where it isn't "activated" or consumed in a sense
>
> that tool can be built after release, park it for now

Decisions:

1. Students cannot request a partial refund. A refund is available only for a payment whose access
   was never activated or consumed: a duplicate charge (the extra, not-yet-started period) or a
   payment that did not unlock Pro. Such a payment is refunded in full.
2. The code's proportional partial refund stays as an admin capability for Aedwon only (for example,
   to correct an error). It is not offered to students. The Terms and the pantas.study refund
   policy (Lane L4) state rule 1, not the proportional rule.
3. The admin lookup tool for double charges and payments that did not unlock Pro is parked until
   after launch (plan "After launch" list).

### October 19: web foundation checkpoint

`web/pwa-foundation-r1` at 5cd9f119 (pushed, checkpoint). Codex Sol's second pass found the
supported way to encrypt the browser study database: the upstream SQLite3MultipleCiphers VFS shim
(`multipleciphers-<vfs>`) over IndexedDB with ChaCha20, a random 32-byte key wrapped by a
non-extractable Web Crypto key. Node probes pass (encryption, persistence, wrong key, tamper);
browser not yet tested. One study database tab at a time on web.

Lead ruling: the native protected content package is decrypted with a pinned bootstrap secret that
cannot stay secret in a browser, so the web build ships no content package. Web content arrives
only through C7 (server per request, cached in the encrypted study database). This makes C7 a
prerequisite for any web smoke test with real lessons. Firebase web config is now in the three
options files. Analyze clean apart from one existing deprecation; full test rerun running.

Lead full test run on `web/pwa-foundation-r1`: 3,971 of 3,971 pass in 5 minutes 45 seconds; the
earlier unfinished property test completed. Security review finding on a test-only probe (module
loaded from a shared /tmp default) fixed at edfd988b.

### October 19: builder preference

Aedwon's exact comment:

> oh okay. actually i might argue my claude limits is better than my chatgpt, based on experience.
> $39 on the cloud is a lot

Decision: Sonnet 5.5 (medium) stays the default builder for PWA engineering; Codex jobs are
overflow. If local Claude limits run out, work continues in a Claude cloud session from
`pwa-launch/RESUME.md` using Aedwon's $39 cloud credit.

### October 19: server content, mocks and answer sync built

Aedwon's exact comment starting this work:

> okay, but keep in mind you might hit limits soon. 73% used on codex, 61% used for you on 5-hour
> limits. on weekly limits codex is 27% used, you are 89% used. tho for you there's not a problem
> because of the cloud pickup session thingy
>
> go ahead with your plan

`web/server-pro-r1` at e7c27574 (pushed), built by Sonnet 5.5: `getContent` (Pro-only fields only
for a live `pro` claim; 300 items per account per day, 20 per call), a content uploader (dry run:
158 lessons, 157 question sets, 157 Pro documents), `startMock`/`submitMock` (named account; Free
one per rolling 30 days), `ingestSession` (200 sessions per day, 300 answers per batch), and
explicit deny rules. Lead reran: plain 116/116, emulator 157/157, tsc clean. The mock paper sampler
is plain Dart, so the server can assemble papers with the same compiled-Dart approach as the
roadmap.

Open: an abandoned mock currently frees the Free allowance (decision for Aedwon); Free answer
visibility after a mock is not yet enforced on the server; one revenuecat-passes emulator test
failed once and passed in four later runs; `content/questions/.../ratio-and-proportion.yaml`
fails a strict YAML parse (content fix in E5).

### October 19: mock allowance and resume rules

Aedwon's exact comments:

> only after submitting, and also under strict mode (which prematurely submits). can a crash be
> identified though? what if the user force closes it or something

> okay so on strict mode they can just close the app to "pause" things? or am i misunderstanding
> something

> okay yes that makes sense. basically that last gap you mentioned caches the mock data until they
> finish it right?

Answer given: the server cannot tell a crash from a force close or a deliberate exit. The approved
design (`docs/design/DECISIONS.md`) already covers strict mode: leaving ends the mock after a
10-second grace ("Not finished", answered items scored); a crash or force close resumes on next
launch with the clock having kept running. Non-strict mode allows pause and discard.

Decisions (C8, server-enforced):

1. A Free mock counts only when submitted: by the student, by strict mode's early end, or when time
   runs out. The next Free mock opens 30 days after that submission.
2. One open mock per Free account. Leaving for any reason resumes the same paper with saved answers.
3. The server holds the clock (server start time, pauses recorded only in non-strict mode); a
   strict-mode mock whose time ran out while closed is ended and scored on the next contact.
4. A non-strict discard clears answers but keeps the same paper pinned: the next start returns it.
   Answer to Aedwon's question: the server, not the phone, pins which questions the paper holds
   until it is submitted, so closing or discarding never yields a new paper.

Implementation: with server paper assembly (the plain Dart sampler compiled like the roadmap),
before the app screen work.

### October 19: Codex lead handoff delivered; staging and server roadmap work started

Aedwon's exact comments:

> can't you do the codex lead handoff?
>
> what do you recommend doing next. i'm in the process on level 4 pasting. this is not a
> prerequisite for your work is it?

> sure proceed

Claude resumed the Codex lead session (01a1410a, idle since October 18) headlessly in read-only mode
with the handoff, asking for a plan only. Its reply: once Aedwon says continue, Lane 1 finishes the
W4c family audit and integration, then W4b; Lane 2 finishes W4e, then W4d; W4c source stays local
until its audit; CSE-only selection, no web reminders and PayMongo plans apply to onboarding and
Settings; W4g after launch. No edits or lock changes. Cost note: the resume reloaded its long
context (about 2.9 million tokens of ChatGPT usage).

Level 4 is not a prerequisite for engineering; it gates only the content rewrite.

Started (Sonnet 5.5): the client content path and Hosting config on `web/pwa-staging-r1` (merge
of `web/pwa-foundation-r1` and `web/server-pro-r1`, clean, pushed at 737d471a), and server mock
papers and roadmap on `web/roadmap-server-r1`, compiling the existing Dart from lib paths with no lib
edits, so W4 files are untouched.

Aedwon's exact comment:

> can you continue codex yourself please

Claude resumed the Codex lead headlessly with "continue" and the plan it gave, using the settings
its own sessions used (gpt-6.1-sol, approval never, full access). It runs W4 Lane 1 and Lane 2
and records progress in `STATUS.md` and the restart log.

### October 19: Claude lead handed to a cloud session

The local Claude lead stopped on a usage limit. Aedwon started a Claude cloud session as the new
lead from `pwa-launch/handoff-orchestrator.md` (policy main 44c07663).

The cloud session cannot see the Mac's worktrees. Aedwon pointed it to the relay:

> check my chatgpt-relay system in github, you should be able to run tests through a local runner.
> 2 are enabled rn

The lead now runs Mac commands through `[relay]` Issues in `Aedwon/chatgpt-terminal-relay`
(issues 11056 onward), authored by Aedwon's GitHub account.

Findings on `web/pwa-staging-r1` local commit 84651f59 (C7 client, B4 config), lead review plus
relay runs on the Mac:

- The commit adds `ContentService` (stale-while-revalidate over `getContent`, encrypted cache
  table, schema 25 to 26 with its migration) but nothing reads it. No lesson or question
  repository uses it, and on web `contentDatabaseProvider` is never overridden, so any screen that
  reads content would throw on web. C7 client is not finished, although the commit message reads
  as if it were.
- `flutter build web --release -t lib/main_staging.dart`: exit 0.
- `flutter test`: 3,983 pass, 1 fail. `test/tool/firebase_indexes_layout_test.dart` ("source never
  writes expiry to a top-level account document") flags `functions/src/paymongoGrants.ts`. Lead
  read the code: both writes go to `webhookEvents/{id}/users/{uid}`, not the account document, so
  the data is safe; the guard cannot follow the shared `seen` object and the repeated `event`
  binding. The failure came in with the payments code; earlier full runs were on the foundation
  branch without it. Fix the code shape so the guard can verify it; do not loosen the guard.
- `flutter analyze`: one new lint (trailing comma in
  `test/core/content/remote/content_service_providers_test.dart:60`), one existing deprecation,
  and errors from `functions/node_modules/firebase-tools/templates`, which the analyzer should
  exclude.

Pushed 84651f59 to `web/pwa-staging-r1` as a checkpoint.

Roadmap worktree: last edit 18:09 with work unsaved; Aedwon confirmed the builder stopped.

Aedwon's exact comments:

> 1. it's stopped, i'm out of credits. i have turned off auto-continue so that you can pick up on
> it cleanly and not get interrupted
> 2. can you? won't that take a lot of tokens? i don't want to burn my usage
> 3. main
>
> you can push on your own

Results:

1. The lead committed the unsaved roadmap work as checkpoint e8df82d1 on `web/roadmap-server-r1`
   (unreviewed) and pushed it. Builders finish it from the cloud.
2. Flutter is installed in the cloud container (a download, almost no tokens). Builders work in
   the cloud. Final checks before integration run on the Mac through the relay.
3. Records (`RESUME.md`, this log) stay on main.
4. The lead pushes working branches and records without asking first. Deploys and other outside
   changes still need Aedwon's approval.

### October 19: server mock papers and roadmap reviewed (C8b, C10 roadmap)

A Sonnet 5.5 builder in the cloud found checkpoint e8df82d1 on `web/roadmap-server-r1` already
complete and made no changes. The commit is titled "Checkpoint ... unfinished"; that title is now
wrong but stays, because rewording would rewrite pushed history.

Lead review of `mock.ts`, `roadmap.ts`, `ingestSession.ts` and the upload changes against the
October 19 mock rules and the C1 to C10 ruling: the rules are met (paper pinned until submission,
server clock, strict time-out scored on next contact with submission at the moment time ran out,
non-strict discard keeps the paper, Free counted at submission with the next Free mock 30 days
later, anonymous refused, Free roadmap carries Today only). Lead fix 953f7f24: the uploader
refuses a mock blueprint without a positive duration (otherwise a strict mock ends at once).

Lead checks in the cloud: `tsc` clean; plain 136/136; emulator 174/174 (Java 21).

Findings carried forward:

1. **CSE has no mock blueprint.** `content/mock/` holds only `upcat.yaml`, so a CSE mock start
   answers "This exam has no mock yet". A CSE Professional and Subprofessional blueprint (sections,
   item counts, time) is needed before launch. Its figures must come from the Civil Service
   Commission or an approved record.
2. **Roadmap read cost grows with history.** Each session batch and each daily first view rebuilds
   the roadmap by reading every stored session document. Fine for staging; before launch, keep
   running per-topic totals instead (Lane L, cost).
3. Answer correctness comes from the app, so a student can only mislead their own roadmap and
   mock score. Accepted; the server can score from the stored content later if needed.
4. The app must call the new `setExamSettings` (exam date, study days) and the mock and roadmap
   callables. No client wiring exists yet; it belongs with the W4 screens and goes through the
   Codex lead.

### October 19: CSE mock blueprint has no approved source

Asked whether an approved CSE Professional and Subprofessional mock layout exists, Aedwon's
exact comment:

> i'm not sure, i don't think there is

Facts found (web search, October 19; the CSC's own current advisory was not retrieved):

- Repository: the August 11 mock spec records only "170 items, 3h10, one booklet" for
  Professional from an unnamed source and nothing for Subprofessional. The August 4 CSE coverage
  spec says the CSC scope document publishes no item counts or time limits.
- Press and CSC-relayed reports (PIA 2024 and others): Professional 170 items in 3 hours 10
  minutes; Subprofessional 165 items in 2 hours 40 minutes.
- A 2020 CSC advisory split these as 150 test items plus 20 examinee descriptive questionnaire
  items (Professional) and 145 plus 20 (Subprofessional). Whether that split still holds is
  unconfirmed. The questionnaire items are not scored test questions.
- No source found gives the number of items per subject area.

Options offered (awaiting Aedwon's choice): see the reply of this date.

### October 19: C7 client wired; roadmap merged into staging; CSE mock choice

Aedwon chose option 1 for the CSE mock. Exact comment:

> 1

Option 1: one full-length mock per level with the official time and the real question count,
spread evenly across the subject areas the CSC lists; the app never claims a count per area.
Pending: the exact count. The CSC site (Cloudflare) refuses automated reads from the cloud and from
the Mac, so the lead asked Aedwon to paste the item and time lines from the March 2027
announcement. If it is silent on the questionnaire items, the 2020 CSC split (150 and 145 test
items) is used with its source stated.

C7 client (Sonnet 5.5, `web/pwa-staging-r1` 7af9eed7 to 3d05636b), lead-reviewed:

- TTL guard fixed by code shape only; lead read the `paymongoGrants.ts` diff: same writes and values.
- Analyzer excludes `functions/node_modules`; trailing-comma lint fixed.
- In-memory web `ContentDatabase` filled from the encrypted cache and a server catalog; fetch-before-read
  hook. Approved deviation: the hook also sits on `ContentRepository` (the real read path, 21
  consumers), with only an optional named parameter added.
- Builder gates: analyze 1 issue (known deprecation); `flutter test` 4,017 pass; web build ok;
  format, layering and attribution checks ok. Not run in a browser.
- Lead rulings on its findings: passage text is protected content and rides inside the question
  sets that use it, not the catalog; compact per-set catalog with parts approved; server keeps
  Markdown lesson bodies; catalog lists only exams with content.
- W4 collision to tell the Codex lead: `storage.dart` (W4d) and `bootstrap.dart` (W4h) are also
  changed on W4 branches; expect merge conflicts there.

Lead merged `web/roadmap-server-r1` into `web/pwa-staging-r1` (fd8357ba, pushed). Lead checks on the
merge: tsc clean; functions plain 136/136, emulator 174/174; `flutter test test/tool/` 194 pass.

Next: the same builder builds the server catalog and moves passages into sets; then final checks
on the Mac through the relay; then ask Aedwon before the staging deploy.

### October 19: server catalog built; lead fixes; Mac checks started

The C7 builder's second round (`web/pwa-staging-r1` 34c852f7, e8c6075d): `getContent` serves kind
`catalog` (index plus one document per exam with content, split into parts over 700 KB); passage
text travels inside the question sets that use it, never in the catalog; a contract test feeds
the uploader's output from the real `content/` tree through the Dart parser. Builder gates:
functions plain 145/145, emulator 178/178; `flutter test` 4,021 pass; web build ok; format,
layering and attribution ok. Lead read the `content.ts` and rules changes: no Pro field or text
reaches the catalog.

Lead fixes:

- d0b5030b: six analyzer style lints in `server_dart/` that came in with the roadmap merge (the
  roadmap builder never ran `flutter analyze`). Comments and commas only; the compiled module
  changed only in its source-hash line. Analyze now shows only the known deprecation.
- 4e6e41e8: catalog ids get their own daily budget (200), separate from the 300 content ids. Each
  app start asks for 9 catalog ids, which would otherwise come out of what a student can study.
  Catalogs carry no protected text. Test first; plain 145/145, emulator 178/178.

Findings recorded for later tasks:

- Native content defect: 20 passage ids that questions name exist only in the question YAML
  `passages:` lists, which the bundled native build does not read (`historical_v1.json` only).
  Android reading questions with these passages lack their passage. Web is correct. Android is
  deferred, so this is a task for when Android resumes.
- `ratio-and-proportion.yaml` (line 355) fails the JavaScript YAML parser; the upload leaves that
  set out with `--skip-invalid` until the E5 content fix.

Pushed 4e6e41e8. Final checks on the Mac started through relay issue 11075.

### October 19: Mac checks; intermittent test failures traced; CSE figures reported

Mac checks of `web/pwa-staging-r1` at 4e6e41e8 (relay 11075, Flutter 3.44.6): web build ok; tsc
clean; analyze shows only the known deprecation; `flutter test` 4,019 pass, 1 fail; emulator suite
failed. Reruns (relay 11076 to 11078):

- Emulator: with files run in parallel, `mock-paper` tests failed in two of three Mac runs ("not
  enough questions") and a `revenuecat-passes` AC-4 test once. Run one file at a time: three of
  three runs passed, and `mock-paper` alone passes. Cause: the files share one emulator database;
  the interfering pair is not identified. Sampler ruled out (3,000 seeds, plus an extra pool).
  Lead fix 51f39659: `--test-concurrency=1` for the emulator files. Cloud rerun: plain 145/145,
  emulator 178/178, about 75 seconds.
- Flutter: `test/tool/content_seed_writer_test.dart` ("seed_writer creates an openable content
  database") failed once in four runs alone on the Mac, at the native sqlite open. The PWA work
  does not touch that tool. Recorded as a pre-existing intermittent failure for a later task; it
  is not skipped.

CSE mock figures. Aedwon's exact comments:

> for CSE times and items: i'm asking those who have taken it if they remember. are you able to
> adjust this later? so that this information isn't blocking you building the things

> hi there, just got a reply
>
> CSE Professional - total 3 hours
>
> 20 items gen info
> 55 verbal
> 35 analytical
> 45 numerical
>
> they also mentioned 15 items but it was about personal things, so no need for this

He also pasted a web search summary: Professional 170 items, 3 hours 10 minutes, about 20
personal-information items and 150 test items, with per-area percentage ranges; Subprofessional
165 items, 2 hours 40 minutes, with per-area ranges. Its sources are a Scribd upload, Facebook
groups and review sites, not the CSC.

Lead reading: the examinee's counts (155 test items plus 15 personal items) add up to 170, which
matches the reported total. The 150/20 split in the search summary conflicts with it. None of
these is published by the CSC. The UPCAT blueprint already uses reported figures, marked
`source: reported` with a source note, as precedent. The blueprint is server content, so it can be
changed later by upload without an app release. Proposal put to Aedwon in the reply.

### October 19: staging deploy started; blocked on billing, App Check key and Cloud login

Aedwon's exact comments, to the CSE proposal and the deploy request:

> proceed

Read as approval of both: Professional mock uses the examinee's counts (20, 55, 35, 45) marked as
reported, with the reported 3 hours 10 minutes; Subprofessional uses an even split until a taker
recalls its counts; and the staging deploy.

Mistake recorded: the first readiness check on the Mac (relay 11079) included
`firebase functions:secrets:get PAYMONGO_SECRET_KEY`. That command lists secret versions, but it
should not have been run; the lead did not read its output and asked Aedwon to delete the issue
if it shows a key. Readiness checks no longer touch secrets.

Found: the web build passed no App Check provider, and every callable enforces App Check, so the
web app could not load content. Options offered: Aedwon creates a reCAPTCHA Enterprise key in the
console (recommended) or deploy server parts only. Aedwon's exact comment:

> 1 - i give you all the authorization you need to proceed with this

Lead change e3adb564 (test first): the web build attests with reCAPTCHA Enterprise when built with
`--dart-define=APP_CHECK_WEB_SITE_KEY=...`; native unchanged.

Deploy run (relay 11081, Mac, Firebase CLI as business@aedwon.com):

- Created Hosting site `pantas-staging-app` (https://pantas-staging-app.web.app).
- Firestore rules compiled and uploaded; the index deploy then failed: "Project pantas-staging has
  billing disabled". Whether the rules release completed is unconfirmed.
- Functions deploy failed: pantas-staging must be on the Blaze plan.

Waiting on Aedwon: Blaze on pantas-staging with a budget alert; the reCAPTCHA Enterprise site key;
Google Cloud application-default login on the Mac for the content uploader.

### October 19: billing blocked; work that needs no billing

Aedwon's exact comments:

> is the firebase upgrade really necessary? i can't do 1 rn, none of my cards are getting accepted

> what if we go 3? how necessary is it to use Firebase

> okay i'll go back on this tomorrow for option 1. can you do something else?

Facts checked: none of pantas-dev-090126, pantas-staging or pantas-prod lists functions (no
Blaze on any). Options offered: (1) another card, for example a GCash or Maya virtual card
(recommended); (2) move only the functions to a free Node host such as Netlify, about 3 to 5
days, free-plan terms not checked; (3) leave Firebase, about 2 weeks or more, not recommended.
Publishing only the web app was offered as a screens-only check; not chosen. Aedwon returns to
option 1 tomorrow.

Started meanwhile (Sonnet 5.5, cloud): CSE mock blueprints on `web/cse-mock-blueprint-r1`, and
roadmap running totals (finding 2 of the roadmap review) on `web/roadmap-totals-r1`, both from
`web/pwa-staging-r1` at e3adb564.

### October 19: CSE blueprints and roadmap totals merged into staging; Codex W4 state

CSE blueprints (`web/cse-mock-blueprint-r1`, Sonnet 5.5): `content/mock/cse-pro.yaml` (sections
20, 55, 35, 45; 190 minutes; `roamable`, so no per-section minutes are shown) and `cse-sub.yaml`
(36, 36, 36, 37; 160 minutes; placeholder split stated in its `sourceNote`); both `source:
reported`. Both the Dart build and the functions uploader read them; the server sampler builds
papers from the real tagged pools. Builder set `totalPublishedItems` to 170 and 165, which shows
"The real exam has 170 items. This practice run covers the 155 the app can mark for you." Kept,
following the UPCAT precedent; to confirm with Aedwon. Lead fix 4000ba42: Professional Numerical
weights 0.6 arithmetic and 0.4 algebra, because the bank holds 20 CSE algebra questions and the
even split asked for 23 (every paper was 3 short). Content notes for E5: Subprofessional Clerical
has 40 questions for 36 slots (repeats likely); `logical-verbal-reasoning` carries a Sub tag
outside Sub scope; no reading-comprehension question file is tagged CSE yet.

Roadmap totals (`web/roadmap-totals-r1`, Sonnet 5.5): one server-only `answerTotals` document per
account, updated in the session-ingest transaction (a replay never double counts), backfilled
once for older accounts; a rebuild reads 1 document instead of N sessions; bounded under 1 MiB
(worst case measured 724,866 bytes). Tests compare the roadmap from totals with the old full scan.
Lead reviewed the transaction order and reran: plain 155/155, emulator 181/181.

Merged into `web/pwa-staging-r1` at 2c2332e0 (pushed). Lead checks on the merge: functions plain
159/159, emulator 181/181; `flutter test test/features/mock_exam test/tool` 486 pass; analyze only
the known deprecation.

Aedwon's exact comment:

> hi just to let you know codex limits have reset. is the work assigned to it still there or has it
> been completed already?

Mac check (relay 11083): no `codex exec` running. W4 is unchanged since the Codex lead's last
records: W4c 7 local commits ahead (f495a8dd, October 18), W4d 2 uncommitted files, W4f 29
uncommitted files, W4a 5; W4b and W4e at their October 15 and 16 remote heads. The `STATUS.md`
lock (held since 18:06) is now stale. No A1 to A4 task has completed.

### October 19: Codex lead resumed; CSE Professional count confirmed

Options offered for Codex: resume the Codex lead (about 3 million tokens of ChatGPT usage to reload
its context; Aedwon pastes the command) or start a fresh Codex lead from a short handoff. Aedwon's
exact comment:

> 1

The Claude lead wrote `pwa-launch/codex-lead-note-2026-10-19.md` (server contracts, W4 state, likely
conflicts, billing block) and gave the command (same settings as its last run: gpt-6.1-sol, full
access, no approvals, output to `~/codex-lead-run-2.log`). Aedwon's exact comment:

> and i also already ran that command in the terminal

On the mock count, Aedwon asked:

> wait 155 items? so you reduced the 15 that are personal questions from the 170?
>
> i understood it as 170 + 15

Answer given: the four reported areas add to 155 test questions; plus 15 personal items is the
170 reported total; nothing was removed. Aedwon's exact comment:

> oh no no, 155 seems right if that's the total my reference gave

Decision: the Professional mock stays at 155 test questions. Still open: whether the shown line
"The real exam has 170 items. This practice run covers the 155 the app can mark for you." is
acceptable.

### October 19: mock size line and the personal-information items

Aedwon's exact comment on the old setup line ("The real exam has 170 items. This practice run
covers the 155 the app can mark for you."):

> wording is ok but can you add 15 personal just so its clear

Finding: that line is on the old mock setup screen. The new-design setup screen (W4e, which ships)
prints `totalPublishedItems` as "170 total items · 3h 10m" and then "This mock has 155 questions
instead of 170.", which reads as a shortfall. Proposal offered: (1) drop `totalPublishedItems` so
the screen shows 155 total items (content change, now); (2) add one line to the new setup screen,
"The real exam also has 15 personal-information items. They are not scored, so this mock leaves
them out." (20 for Subprofessional), a visible change that needs a faithful preview and Aedwon's
approval, then implementation by the screen owner (Codex lead, W4e). Aedwon's exact comment:

> okay go with both

Done: cb12a504 on `web/cse-mock-blueprint-r1` removes `totalPublishedItems` from both CSE
blueprints (test first), merged into `web/pwa-staging-r1` at 8e0420c9 (pushed). Started: a
Sonnet 5.5 builder renders the real W4e `MockSetupPage` as a web preview (now and proposed, both
levels, light and dark) from a local scratch branch of W4e that is never pushed.

### October 19: personal-items line approved; Codex limit reached again

Preview published (private artifact https://claude.ai/artifact/VWUTUbGtQoK7iruAaBiME9, version 1):
the real W4e `MockSetupPage` rendered with the app theme for CSE Professional and Subprofessional,
now and proposed, light and dark. Built from a local scratch branch of W4e e3ba3785 that is not
pushed. Disclosed gaps: no status bar, no back arrow, CanvasKit text rendering, text scale 1.0.
Approved copy, placed after the paper-rule line in `type.subhead` with `colors.secondaryLabel`:
"The real exam also has 15 personal-information items. They are not scored, so this mock leaves
them out." (Professional; Subprofessional says 20). Aedwon's exact comment:

> ok but codex is 100% used usage rn

Read as approval. Implementation belongs to the W4e owner (Codex lead), with the count coming from
the blueprint rather than hard-coded text; queued in the Codex lead note.

Codex run 2 (log `~/codex-lead-run-2.log`) stopped on its usage limit (resets October 20, 2:49 AM)
after 3,318,394 tokens. Progress it left: main a0ebc84b, 252d26e2, c12a3deb, 33b3fd2e (W4 client
seams against the server contracts, web mock wiring bounds, W4c audit findings); W4e one local
commit 3b454b3a; W4c 4 uncommitted files.

### October 19: W4e moves to a Claude builder; cloud lead hands back to the local lead

Options offered: (1) a Claude (Sonnet 5.5) builder takes W4e (mock screens) while Codex is out of
usage, starting from Codex's saved work; Codex keeps W4c and W4b (a change to the plan, which
reserves W4 for the Codex lead; each Codex resume reloads over 3 million tokens); (2) wait for
Codex (resets October 20, 2:49 AM). Recommended: 1. Aedwon's exact comment:

> okay go, but note that you have $8 of cloud usage left. be prepared to hand off to the previous
> orchestrator before you since my limits for non-cloud use have reset.

Decisions:

1. W4e moves from the Codex lead to a Claude builder (Sonnet 5.5, medium). Codex keeps W4c then
   W4b (Lane 1) and W4d (after W4e in Lane 2 order). The Codex lead must be told before its next
   run, so it does not also work W4e.
2. The W4e builder runs on the Mac, not in the cloud: Codex's newest W4e commit 3b454b3a is local
   only, and the W4e worktree is `Pantas-wt-new-design-w4e-r1` there.
3. The cloud lead stops new work and hands back to the local Claude lead (budget about $8 left).

### October 19: W4e state and the unscored-items field (lead ruling)

Aedwon's exact comment, on the cloud budget:

> um you can continue to do work that you can do until you exhaust

The lead pushed `web/new-design-w4e-r1` from the Mac (relay 11087; now at 3b454b3a on origin) and
added note addendum 2 (W4e is Claude's). A Sonnet builder checked W4e progress and stopped before
any change at a planned stop condition. W4e state from its history: Tasks 1 and 2 on the base;
Task 3 saved as ac712f6f (no acceptance claimed, per the October 16 ruling); Task 4 partly done
(40600f16, 4509861f, b6ba49d3, 3b454b3a); Task 5 partly done (67c02af9, e3ba3785); Tasks 6 to 9
not started; the October 19 PWA web mock adapter (server mock API, paper, session) not built yet.

Stop: the approved personal-items line needs the count on the blueprint. Blueprints are read from
the `ContentDatabase` table, so a new nullable `unscoredItems` column needs content schema 9 to 10.

Lead ruling (technical): take the column, the same way `totalPublishedItems` was added (`from <
3`). The content database is rebuilt from the content package and holds no student data, so the
bump is low risk. Rejected: hiding the count inside another column's JSON (a second, undocumented
place for blueprint fields). Conditions: the bump and its migration land in one commit with a
migration test; confirm first that no other open branch (W4c, W4d, staging) bumps the content
schema; thread the field through `tools/build_content_export` and the staging catalog parser when
W4e integrates with `web/pwa-staging-r1`; check whether the content package or its installer pins
schema 9 and stop if it does. Not started, to save the cloud budget; the next lead dispatches it.

### October 19: unscored-items line built on W4e (content schema 10)

Aedwon's exact comment, on continuing with the cloud budget:

> that's $6 it's enough for the next thing

Second stop by the builder: the protected-content installer pins content schema 9
(`_contentSchemaVersion` in `lib/core/content/bundle/protected_content_installer.dart`) and refuses
any other `user_version`. Options: raise the pin to 10, or accept 9 and 10. Lead ruling: raise it to
10. Rejected: accepting both, because the protected database may be opened read-only and an old v9
package would then hit the addColumn migration it cannot write. Packages must be rebuilt; Android
is deferred and no web package exists.

Pushed on `web/new-design-w4e-r1`: 3269098a (schema 10, migration, installer pin, migration test, in
one commit), 66f4a94e (field threaded through domain, parser and repository; the approved setup
line with parser and widget tests), dd7cf640 and lead fix e1c9489b (lints). Head e1c9489b.

Checks (cloud): `flutter test test/features/mock_exam test/core/content test/tool` 653 pass, 1 fail:
`content_providers_test.dart` setUpAll expects the e02 seed hash `eb3a9da4...` and gets
`5b542c26...`; it fails the same without the change. The cloud seed files were rebuilt with
throwaway keys, so this is expected here; rerun on the Mac with the real seed. Analyze: only the
known deprecation. Format and attribution checks pass.

Not verified: the real package builder CLI at schema 10. `tools/build_content_seed/seed_writer.dart`
pins a schema-8 seed subclass; the next lead must run the real content package build on the Mac and
confirm the installer accepts it before any native release.

Integration needs: `tools/build_content_export` and the staging catalog parser must carry
`unscoredItems`, and the CSE blueprints on `web/pwa-staging-r1` must author it (15 Professional,
20 Subprofessional).

### October 19: E02 seed hash regression fixed

Aedwon's exact comment:

> did you stop? $4 still remain. all that work since $6 cost $2

The Mac rerun (relay 11088, real seed) showed the same `content_providers_test` failure with the
same actual hash, so it was not the cloud keys. The lead ran the test on the pre-change base
3b454b3a: it passes. The builder's report that it "fails identically with my changes stashed" was
wrong. Cause: the schema 8 E02 fixture database was created from current table definitions, so the
new `unscored_items` column changed its bytes and the approved E02 seed hash.

Lead fix f6b76e56 (`tools/build_content_seed/seed_writer.dart`, test and tool path only): the
schema 8 subclass creates `content_mock_blueprints` with its exact schema 8 DDL, in the same
position, and the blueprint insert omits the new column for that fixture. Checks (cloud):
`content_providers_test` 12 pass; `flutter test test/core/content test/features/mock_exam test/tool`
665 pass; analyze only the known deprecation; format clean. W4e head f6b76e56 (pushed).

Still to verify on the Mac: the real content package build at schema 10.

### October 19: unscoredItems carried on staging

Aedwon's exact comment:

> exhaust please, anything you can work on

Lead change 20692945 on `web/pwa-staging-r1` (test first): `content/mock/cse-pro.yaml` sets
`unscoredItems: 15`, `cse-sub.yaml` sets `unscoredItems: 20`, and `tools/build_content_export`
passes the field through. The staging catalog and Dart parsers ignore it until W4e merges (W4e's
parser reads it). Checks: `flutter test test/features/mock_exam test/tool` 487 pass; functions
blueprint and upload tests 21 pass; analyze only the known deprecation; format clean. Merge note:
`build_content_export.dart` and the blueprint parser meet when W4e and staging integrate.

### October 20: local lead resumes; schema 10 package check

Aedwon's exact comment:

> substantial progress was made with the cloud orchestrator. can you continue?

The local Claude lead (Opus 5.5) resumed on the Mac. Check on W4e f6b76e56 with the real corpus and
throwaway keys (real keys not touched): export and package build succeed; installer, builder and
verifier tests 149 pass. Found: the built manifest declares `contentSchemaVersion`,
`readerSchemaMin` and `readerSchemaMax` 9 (`ContentPackageManifest.contentSchemaV2 = 9`) while the
payload is schema 10 and the installer pins 10. Lead ruling (technical): the manifest declares the
payload schema, 10, for writing and verification, so an older reader rejects a schema 10 package at
the manifest step. Assigned to the W4e builder as its first commit, with tests.

W4e builder (Sonnet 5.5, medium) started on the Mac in `Pantas-wt-new-design-w4e-r1`: the manifest
fix, then W4e Tasks 4 to 9 and the web mock adapter. It stops on any unapproved visible choice or
missing server field.

### October 20: W4e builder run 1 result

Pushed on `web/new-design-w4e-r1`, head b5da6f99 (local matches origin). Lead-reviewed: b25be7bf
(manifest declares schema 10; E02 seed untouched). Builder-reported, not yet lead-reviewed: Tasks 4,
5, 8, 9 and the web mock adapter (server client, validated paper, account-bound session, route
behind a web seam); unused mock screens deleted. Checks (builder): full `flutter test` 4,116 pass;
analyze only the known deprecation.

Not built: Task 6 (results gauge size differs from the board; "See full record" has no board),
Task 7, the pause dialog's "Don't show this again" checkbox (dialog has no slot), the paper-to-pause
crossfade; web results, history, review and next-eligible time (no server reader yet); Quiz card
Resume for a server mock.

Visible choices the builder made without an approved board (they need Aedwon's approval through the
visual companion before W4e merges): custom setup wheels on subject rows, the "Set" label for an
unset row, the held Save with no explanation line, the grid sheet's generalized "Parts 1, 2 and 3 are
closed" wording and its four differences from MK_Sheet, instant Previous and grid jumps, the 2.6 s
clock restart delay on Resume, and strict back blocked with no message.

### October 20: W4e visible details approved (visual companion)

Shown in the visual companion, each with the builder's version and an alternative. Aedwon's exact
picks:

> W4e picks: 1A, 2A, 3B, 4A, 5B, 6A, 7B

1. A: custom setup edits a subject row with a 5-row wheel that grows inside the row (300 ms);
   questions 10 to 240 by 5, minutes 15 to 360 by 5 (as built).
2. A: an unset pill reads "Set" (as built).
3. B: while any row is unset, one line above the disabled Save: "Choose questions and minutes for
   every subject." Same place and style as the approved short-subject line.
4. A: "Parts 1, 2 and 3 are closed" for three or more closed parts (as built).
5. B: Previous mirrors Next (incoming slides in from the left, outgoing leaves to the right; 0.38 s,
   40 px, Cubic(0.2, 0.9, 0.3, 1)); a grid jump crossfades over 200 ms.
6. A: after Resume, the clock restarts when the 2.6 s hourglass sequence ends (as built).
7. B: in strict mode, Back shows a short note at the bottom of the paper: "Strict mode is on. Back
   is off until you submit." Dark note (label color), white 12 pt text.

Lead ruling (no decision needed; the approved boards already decide these): the grid sheet matches
MK_Sheet (per-part count "13 of 60", "Opens when this part starts.", footer "Tap any question in
this part to go to it."); Next uses the MK_Paper slide (0.38 s, 40 px, Cubic(0.2, 0.9, 0.3, 1)); the
pause warning gets MK_PauseWarn's "Don't show this again" checkbox and stores it (today the flag is
never set); the results page uses the MK_Results gauge (264x128, 56 pt, one decimal).


### October21: W4e local continuation authorized

Aedwon's exact instruction:

> can you continue until completion? no need to use the relay, you have full access to local files and you're on codex

Continue the existing approved W4e scope locally. This changes the execution path, not product scope, the application-main freeze, the server workstream's ownership or human visual acceptance. No new complexity menu is needed for corrections within settled W4e requirements. Reconciliation found clean local ecbb6c76, four expected commits ahead of remote b5da6f99; main49b15889 and integration72629940 match GitHub. Root requested one independent read-only review of the saved continuation slices and reproduced/corrected three review-screen regressions with tests first. The full-family audit remains deferred until required inputs exist. The user has been asked whether root should also own the missing server reader on a separate working branch; that answer is pending. CSE finale fidelity still needs a faithful proposal and Aedwon's approval before implementation differences.


### October21: W4e continuation limited to its workstream

Aedwon's exact instruction:

> i authorize you to complete W4e including its dependencies (unless it's on another workstream)

Continue existing approved W4e tasks and dependencies inside its ownership. Root explicitly stated that the separate PWA server track and W4d remain excluded; no server takeover is inferred. Root prepared the missing CSE finale comparison under the existing lead re-planning requirement. Proposal version1 is saved on E86269158 and linked from current STATUS/evidence. Offered geometry options: A, recommended,13columns preserving existing full-paper card size/scan distance at the cost of tighter initial dot spacing; B,10columns with more initial dot space at the cost of taller cards, longer scan distance and extra geometry work. Both preserve the sampled motion timeline. Selection is pending, and clicking a draft control alone is not approval. No application source changed in this proposal slice; no new family-completion claim or integration permission is implied.


### October21: compact booklet selected and extended vertically

Aedwon: "oh yeah go compact booklet then. is that actually 155 dots?" This chooses optionA from proposalv1, not10-columnB. Root verified155/145 actual generated dots.

Aedwon: "um if that's 155 dots, maybe you can extend it so it reaches further down? then also you don't have to show me just clarify, will it still do the mock-end animation?"

Root clarified keeping13columns, extending rows/card/scan downward while retaining the scan, gathering, ball, impact/gauge and result sequence/timing. Aedwon: "okie dokie, proceed then".

The extension supersedes A's original tight vertical spacing. Technical dimensions:9pxdots; initial/checking horizontal22/24 and vertical16/18;155-question initial/checking cards255/237high. Sampled source tracks/time remain binding; no additional preview is required by the user's explicit waiver for this extension. No wider scope or external server/W4d ownership is granted. Original chosen proposal remains immutable for history; the spec/plan records this later text-approved amendment before production changes.


### October21: approved taller compact CSE sequence landed on its working branch

Implemented the user's compact13-column selection plus the later approved vertical extension, without another visual-preview gate. The native fresh-CSE presentation now consumes the real saved submission input; it never reconstructs history or invents web result authority. The original sampled motion is retained, and count/scan/card bounds extend together. Root resolved two independent review findings in one tests-first pass and uploaded8aee08ea after4174full/585focused checks and exact remote SHA verification. Root keeps source changes on the existing E working branch; server/W4d ownership remains excluded, no application main/development integration or release is performed, and the user's phone visual acceptance remains required. Detailed evidence and remaining non-CSE/family scope are explicit in current STATUS and E evidence.


### October21: all necessary W4e dependencies authorized

Aedwon: "thanks, i give you full authorization on all you need to do to complete w4e". Root recommended completing the C8 reader dependency first, then connecting and completing W4e before W4d. Balanced scope includes required reader/access controls/contract tests without unrelated server changes. The latest instruction supersedes the earlier external-dependency exclusion for necessary W4e work. Preserve existing staging and other workers through a separate reader branch. Existing product rules and approved designs remain binding; no additional execution approval is needed. Deployment/live acceptance remain later launch stages, and the main application freeze remains.


### October21: W4e completion narrowed explicitly to launch CSE

Root asked: "Should W4e completion cover the CSE launch scope or every exam in the original plan? CSE launch is my recommendation. Completing every exam also requires adapting and approving the remaining exam-specific end animations." Options: "CSE launch scope" or "Every exam in original W4e". Aedwon selected exactly "CSE launch scope". Proceed with CSE Professional/Subprofessional launch-scoped completion; retain other native behavior and record other-exam/UPCAT rebuilt finales as deferred. No additional execution approval is needed. Human visual checking and real deployed acceptance remain distinct later gates.


### CSE W4e engineering closeout under the expanded authorization

The approved CSE-only continuation is engineering accepted after whole-family review, regression corrections and4439combined Flutter tests with clean static gates. Source is uploaded on E f608e570 and development72b04f00; the required separately reviewed server dependency is0c17bfb0 with165plain/205emulator pass. The necessary answer-to-review connection reuses the exact existing native scheduler, not new learning mechanics. Original server/staging ownership, native other-exam behavior and later global/human/release stages remain intact. No further product choice or execution permission was required, and no unrelated family was started. Detailed source identities, audit rulings, evidence and preserved handoffs are in STATUS and each working branch's existing evidence.


### October 24: C3 web purchase gateway chosen as parallel Claude work

Aedwon asked the Claude lead to continue W4 work in parallel with W4a and W4b (ChatGPT models
on those). Policy read: main 8d1d6303. Lane A tasks belong to Codex, so the lead offered
Claude-owned tasks that do not collide with W4a/W4b: C3 web purchase gateway (recommended;
unblocks W4f Task 6; real payment untestable until PayMongo test keys), B5 HTML loading screen
(needs a visual approval round first), L4 legal and refund pages (Aedwon writes the wording).
Aedwon selected "C3 web purchase (Recommended)". Complexity options: minimal (interface W4f
calls, fake-server tests, about 2 to 3 hours), balanced (plus abandoned-checkout recovery and a
pending state, about 4 to 5 hours), hardened (plus duplicate/tampered return checks, about a
day). Aedwon selected "Minimal (Recommended)". Plan:
`docs/superpowers/plans/pwa-launch/C3-web-purchase-gateway.md` on `web/paymongo-r1`.

Run 1 (Sonnet 5.5 high) built steps 1 to 5 and stopped at the offering: the client has no
price source and a guard test forbids a ₱ sign in paywall code. Options: (A) the server lists
web plans and prices from `functions/src/products.json`, the same source checkout charges,
about 1 hour; (B) copy prices into the client and relax the guard. Aedwon: "A". The lead also
found a pre-existing failure on the branch (account-document TTL guard flagged the PayMongo
dedupe writes) and fixed it without behavior change at 85489661 (full Flutter 4019 pass,
Functions 110 plain / 142 emulator pass, tsc clean).

Aedwon offered to set up PayMongo test mode now. The lead gave steps and noted that the C5 run
still needs Blaze billing on pantas-staging, because functions cannot deploy without it. Aedwon
is considering billing from another Google account; the lead advised keeping the project and
linking a billing account owned by that account. Billing remains pending.

C3 completed at minimal scope on `web/paymongo-r1` b0946994 after lead review: steps 1 to 7,
including the server `listWebPlans` price list chosen as option A. Full Flutter 4032 pass,
Functions 118 plain / 143 emulator pass, static checks clean apart from the known branch-age
deprecation. Not integrated; C5 live test still waits on Blaze and PayMongo test keys. Handoff
for the W4f Task 6 owner recorded in `pwa-launch/W4-client-coordination.md`.


### October 24: web study database encryption (D7) reversed

Context: the lead proposed B3 browser verification of the encrypted web study database. Aedwon
asked why encryption is still needed after Pro content moved to per-request delivery (C7).
Facts given: D7 was decided on October 19 when the whole corpus was to ship to the browser; after
C7 the browser holds only items the student opened and was entitled to, the catalog, the current
unfinished session and possibly settings. Finished sessions go to Firebase (C9), which encrypts
stored data automatically; traffic is HTTPS; server rules limit each account to its own data; the
browser isolates each site's storage. Business view given: local encryption does not protect
revenue (a Pro student can screenshot or script requests; server limits are the real defense); it
helps a little on shared or lost devices; its main value is the claim "encrypted on your device".
Costs of keeping it: untested-in-browser wasm cipher shim, key-loss crash handling, one-tab limit,
B3 verification (about 3 hours). The lead recommended dropping it. Native apps keep SQLCipher;
store declarations are unchanged.

Aedwon's exact comments:

> i don't think it's worth building. how about you what do you think

> okay then proceed, record this decision and start the swap.

Decision: the web build uses the standard (unencrypted) browser database. D7 is superseded for
web only. Native encryption and the native content package are unchanged. Public wording must not
claim "encrypted on your device" for web; Aedwon writes that wording.

B3 swap done on `web/pwa-staging-r1` 80ddb7c5 after lead review: standard drift web storage
without cipher or key vault; several tabs share one database where the browser supports shared
workers; a damaged file is deleted and reopened empty (server holds content and finished
sessions); other open failures surface without deleting. Web settings sync only for signed-in
Pro accounts; Free and anonymous accounts keep settings locally; theme is device-local. Full
Flutter 4026 pass, browser test 5/5, web release build OK. Safari, Firefox and phones unverified.

## October 25: Level 4 CSE paste run closed out (E2)

Aedwon's exact comments:

> hello, i can't find the chat where you made a http://127.0.0.1:8766 prompt copy paste interface using this command [...] but I'm done with this process already. 71/71 what's next

> Close out Level 4: compile and check the 71 results, record them in status, and show me the findings summary.

Options offered: close out Level 4 first (recommended), or build the Level 5 paste prompts first.
He chose the close-out.

What changed: the lead added a paste-run close-out on `docs/content-coverage-audit-r1` (20db8920)
that treats each accepted single read as the lesson result, reruns the form check against the
pinned lessons, and reuses the existing report builders. Results are in `level4/paste/results/`.
Checks: 71 of 71 accepted, 0 held; fresh revalidation PASS; counting check PASS; Level 4 test
files 294 pass. Totals: 866 chat findings (Blocker 52: B03 26, B01 18, B02 8, in 31 lessons;
Major 628; Minor 186), script findings 93, illustration entries 41, accuracy concerns 20.

Limit recorded: D4 gives one read per lesson with no deciding chat or planted lessons, so the run
has no miss-rate measure and no second opinion. Some B01 findings are judgment calls rather than
wrong facts. The lead triages findings before E4 rewrites. Level 4 awaits Aedwon's review.

## October 25: rewrite CSE lessons before Level 5

Aedwon's exact comments:

> what do you recommend we do here onwards? should we rewrite the lessons per the audit first? because i think it would be faster than if checking all 3000+ questions and then rewriting them because of the lesson rewrites as well

> go do that in 34 minutes when claude limits reset

Facts given: CSE Level 5 covers about 1,100 questions in 55 question files, not all 3,222. Level 5
has two parts: question-only checks (answer key, wording, choices, explanations), which lesson
rewrites do not affect, and the practice-against-teaching check, which does depend on the lessons.

Options: (recommended) triage Level 4 findings, rewrite lessons (E4), then run all of Level 5
against the rewritten lessons; or run the question-only part of Level 5 during the rewrites,
which costs Aedwon pasting time while he also reviews rewrites.

Decision: the recommended order. The lead triages the 866 findings first, starting with the 52
Blockers. D5 (Level 5 in parallel with Level 4) is superseded by this order.

Triage done the same day (`docs/content-coverage-audit-r1` at c059bcfd,
`level4/paste/results/triage.md`): real 597, judgment 233, reject 14, illustration 2, and 25 rows
that need two standards rulings from Aedwon (General Information layout; Reasoning layout and
figures). Rewrites for subjects outside those rulings can start first.

## October 25: two lesson standards rulings approved

Aedwon asked whether the two rulings were the lead's recommendations or current standards. The
lead answered that both are recommendations and that the current guide says the opposite. His
exact comment:

> i see. so your recommendation is to make the standards flexible. yes that sounds good and much better than the current rulings. perhaps we can also revisit other rulings/standards?

Approved:
1. General Information lessons require Traps to Watch For; Speed Tricks & Shortcuts is optional.
2. Reasoning lessons may keep Speed Tricks & Shortcuts when it holds a real shortcut. Figures are
   required only where they help (for example Venn diagrams for syllogisms, figure series), not
   in every example.

Not yet done: the lesson style guide is not edited. The lead proposed reviewing other lesson and
question standards first, so the guide changes land together.

## October 25: question standards review, first answers

Lead proposals: review the fixed counts (20 per lesson, 2 to 3 variants per archetype); move the
YAML quoting rules into a checking script; keep the blind solve, one correct answer, wrong-choice
notes and no-clue rules. Aedwon's exact reply:

> * fixed counts remain 20 minimum. near-duplicates are okay for launch, we will build a parameterized question generation engine later on but this is for another conversation
> * ok
> * yes okay but i think we need to improve the way this is done.
>
> let me know if we're all good with the writing/rewriting standards for lessons and quizzes before we proceed to the next

Decisions: the 20-question minimum stays. Near-duplicate variants are allowed for launch
(supersedes "no near-duplicates" in the question guide's coverage rule until the generator
exists). The YAML quoting rules move to a checking script. The protective rules stay, and Aedwon
wants their process improved (detail pending).

Idea recorded, not approved for build: a parameterized question generation engine after launch,
to be discussed in its own conversation.

## October 25: four lesson rule changes approved; guides updated

Lead proposals: explain only exam instruction words with an exam-specific meaning (L03); numbered
steps only for solutions with two or more steps (L19); drop the learning-goal check while no
goals are recorded (L01); no claim about a specific exam without a source (B01, already in the
source policy). Aedwon's exact reply:

> 1. okay with your recommendations
> 2. i was talking about how we would delegate this to subagents. its entire process. optimize balance for speed because i want to launch early but also accuracy, because this is for building trust. consider that after the engineering run i have 3 ChatGPT Plus subscriptions and 1 Claude Pro subscription

Changed on main: `lesson-style-guide.md` (exam instruction words, exam claims, numbered steps,
Reasoning and General Information layouts), `content-checklist.md` (L01, L03, L19, Q19),
`question-style-guide.md` (near-duplicates allowed for launch). Not done yet: the checking script
that replaces the YAML quoting rules; until it exists the rules stay in the guide.

## October 25: shared lessons and dependency owners

Lead recommendations: a CSE rewrite may add CSE cases but must not remove a case another tagged
exam needs; the lead owns the topic and lesson prerequisite links, writers flag new
dependencies, and the checker confirms the links stay acyclic. Aedwon's exact reply:

> okay sure.

## October 25: writer batching and token savings

Lead recommendation: one Codex session per topic batch of 4 to 6 lessons, then a fresh session;
scripts make mechanical fixes; a script-built brief per lesson carries only its real findings and
cited rules; the checker reads the diff and the brief; effort matches fix size; cheaper model
first for blind solves. Savings to be measured in the one-subject pilot. Aedwon's exact reply:

> okay sounds good to me. what else?

## October 25: QA tool, pilot shape, full re-read, start, web chat batches

Lead asked: where Aedwon reviews (staging blocked on Blaze), which pilot subject, whether every
rewrite gets a full independent read, and when to start. Aedwon's exact reply:

> 1. use the lesson studio or what was it called? there's a tool that existed before
> 2. try on multiple subjects please since they each have different things going on right
> 3. i'm okay with doubling checking time since this is a QA thing. full independent read should be done. how many lessons is this?
> 4. when we're done with engineering we start with this.
>
> also, consider some parts we could use the web chat for the edits, it runs on 6 Sol High. there should be some items that it could cover multiple. but this should be unlike the one where I had to paste 1 lesson at a time. maybe we can do the multiple lessons at a time yknow, to save some time and effort

Decisions: Aedwon reviews in the existing Lesson Author (`tools/lesson_author`, local, renders
lessons and illustration previews) and Question Studio. The pilot covers several subjects. Every
rewritten lesson gets a full independent read (all 71 CSE lessons). Work starts after the
engineering run. The lead designs batched web chat pastes (several lessons per chat) for the
edits that suit them.

## October 25: model budget for content work

Aedwon's exact comment:

> web chat is virtually unlimited. Codex is the limited one but I have access to much better models like 6.1 Sol and 6 Astra. 6 Astra we've used before for adversarial reviews but this can be done at the very end since it burns a lot of usage

Consequence for the plan: web chat (GPT 6 Sol High, batched pastes) takes all volume work that
does not need the repository; Codex (6.1 Sol) takes only repository-bound work; 6 Astra runs one
adversarial review at the end.

## October 25: CSE teaching gaps and the five skipped lessons

Aedwon asked whether the 71 lessons were already corrected from the earlier exam research. The
lead explained they are existing lessons tagged for CSE, not yet edited, and raised two gaps.
Aedwon's exact replies:

> wait huh i don't quite understand what you want to do. please don't mention level 4 level x y z just tell me what those exactly mean

> for Problem 1, they're missing, so I can't technically paste like I did the 71 because they don't exist right? or am I misunderstanding something here? did you mean pasting for this plan we're about to make? idk
>
> for Problem 2, okay go do that

Done for Problem 2: gap list on the audit branch (`level4/paste/results/cse-teaching-gaps.md`):
361 parts; 339 into 57 lesson briefs, 4 proposed new lessons, Filipino sections in 6 lessons.
Problem 1 pending: the five lessons and their prompts exist; adding them to the paste page
needs his go-ahead.

## October 25: five abstract reasoning lessons added to CSE scope

Cause given: the CSE Professional map row "symbolic logic/abstract reasoning" was matched only to
two logic lessons; in Philippine exam usage abstract reasoning means figure puzzles. Aedwon's
exact reply:

> okay. proceed then. we're not missing any topic from the SSOT in relation to CSE? you've listed all there is?

Done: the five lessons are in the paste scope (76). Completeness check of all 96 CSE requirement
rows found two more Reading lessons (choosing a title, fact versus opinion) with CSE gaps and no
CSE tag; five Mechanical Reasoning lessons left out because CSE lists no mechanical area.

Aedwon's exact reply on the two Reading lessons:

> Add choosing a title and fact versus opinion to the CSE scope and the paste page.

Done: CSE lesson scope is 78 (71 checked, 7 to paste).

## October 25: the 7 added lessons done

Aedwon's exact comment:

> done with all 7

Lead result (`docs/content-coverage-audit-r1` at ecbfa88b): 78 of 78 lessons read and
revalidated, counting check PASS. Triage across 78 lessons: real 656 (497 small, 151 medium, 8
large), judgment 271, reject 19, illustration 7. The 25 rows held for the layout rulings were
resolved by the approved rulings. Next: the rewrite plan.

## October 25: rewrite plan drafted

Aedwon's exact request:

> Write the rewrite plan now with everything we agreed.

Drafted `docs/superpowers/plans/pwa-launch/E4-E7-cse-content-rewrite.md` (amends Lane E, tasks
E3 to E7). Facts found while drafting: lesson figures are PNG files (code-rendered, generated
through Illustration Studio, or open-licensed), question figures are code-drawn specs; no
in-lesson quiz items exist; four puzzle lessons have no active question (all need figures); the
illustration worklist (59 rows) disagrees with its README (278). Awaiting Aedwon: approval at a
complexity level (balanced recommended) and the figure order.

## October 25: plan revisions, relay hand-in and public repository

Lead proposal: web chats work through the relay; a local hand-in script checks and commits; a
GitHub check runs on push; the paste page marks items done from the commit. Caveats given: the
relay runner and Mac must be on; the Pantas repository is public, so lesson and question content
(including Pro) is readable by anyone. Aedwon's exact reply:

> 1. okay with the caveats. yes public for now. it wouldn't be a problem since nobody really knows about this project except me and some few close people
> 2. isn't it better to let it display svg? it would be lighter, or is that assumption wrong

Decision: relay hand-in design accepted; repository stays public for now. Illustration format
under discussion.

## October 25: illustrations as SVG

Lead answer: SVG is usually lighter and sharper; the app's SVG support covers shapes, colors,
gradients and text but not blur, some styling, or animation. Recommended static SVG with a render
check, animations as animated WebP. Aedwon's exact reply:

> let's go with svg everything with animations please
>
> in the future, when we release for play store app store, they can also display svg correct? if this gets implemented

Decision: every illustration is SVG. How animations are shown is under discussion (animated SVG
does not play in the app's SVG support).

## October 25: animations deferred to after launch

Aedwon asked whether the first-frame-only SVG limit is ours. Lead answer: it is a gap in
Flutter's SVG support, which has no animation player; options were a web view per figure, an
in-app player for the common SVG animation tags (recommended, about 3 to 4 days with tests), or a
ready-made package (none verified). Aedwon's exact reply:

> hmm go with your recommendation, but honestly these animations, let's defer to post-launch but take note of it

Decision: launch ships static SVG only. After launch: an in-app player for a supported subset of
standard SVG animation (move, rotate, scale, fade, draw a line), with a check script that rejects
unsupported tags; check for a ready-made package first. During the rewrite, figure briefs mark
animation candidates so they can be upgraded later.

## October 25: rewrite plan approved at balanced complexity

Aedwon's exact comment:

> approved, go for balanced. right now engineering is still not finished, but can you work on things you can work on?
>
> please don't forget to delegate tasks to Sonnet 5.5 or Haiku 5.5 as needed

Plan `pwa-launch/E4-E7-cse-content-rewrite.md` (revision 2) approved at balanced complexity. The
lead starts P0 preparation that needs no ChatGPT, delegating to Sonnet 5.5 and Haiku 5.5. Branch
`content/cse-rewrite-r1` created from `content/question-qa-r2` at 765c5dc0 (base unchanged) and
pushed; worktree `Pantas-wt-cse-rewrite-r1`. App code for SVG display waits until it can be
coordinated with the engineering run.

## October 25: lesson figure style

Options shown on the private page "Lesson Figure Styles" (version 1): A clean textbook, B friendly
illustrated, C bold infographic, D modern flat with depth. Asked which costs least to generate,
the lead answered C, then A; B and D cost up to about half again as much on small figures.
Aedwon's exact reply:

> hmm i think the quality bar should reach modern flat with deph. let's go with that

Decision: style D. Reference files and style rules on `content/cse-rewrite-r1` in
`docs/content/rewrite/figure-style/`.

## October 25: lesson splits approved

Options: split as proposed (8 new split lessons plus 4 new lessons, about 240 new questions,
about 12 more pastes), or no splits with only organizer-named parts. Lead recommended splitting.
Aedwon's exact reply:

> ok with splits
>
> what's with the svg sorry could you recap

Decision: split as proposed in `docs/content/rewrite/plans/split-proposals.md` on
`content/cse-rewrite-r1`, with the lead decisions recorded there.

## October 25: CSE rewrite pilot started

Aedwon's exact comment:

> hi there, you're currently 89% usage used 1hr 31 min before reset
>
> the engineering path is done, the 2 chatgpt accounts are available
>
> do you think we should proceed?

Lead answer: proceed with the pilot, keeping Claude usage low until the reset (the chats do the
work; the lead reviews after the reset). Relay runners `aedwon-m4-chatgpt-relay` and `-2` online.
Pilot: 15 lessons in 6 rewrite batches (RW-001 to RW-006), one topic each: data interpretation,
language application, RA 6713, comprehension skills, logical-verbal reasoning, earth science.
Spatial reasoning and the new or split lessons are left for the full run.

## October 25: CSE rewrite pilot accepted, full run approved

Pilot report on `content/cse-rewrite-r1` STATUS.md (15 lessons; 278 of 287 brief items fixed;
new findings concentrated in the 3 language application lessons; at least 4 connector refusals,
handled by Codex and Sonnet). Lead recommended the full run with four adjustments: rewrite the 3
language application lessons and the 3 single-Major lessons again; readers judge L18 by the cases
the exam actually tests, as the triage did; connector-refused batches go straight to Codex
(accounts a, b, c) with no chat retry; fix stale page labels. Aedwon's exact reply:

> go with your adjustments

Not yet approved: deleting branches `cse-inbox/RD-003` and `cse-inbox/RD-006`.

## 2026-10-25/26 CSE rewrite: first pass done, overnight Codex loop

- Branch deletions approved: "ok with deletions as long as it's safe to delete". Empty or fully handed-in
  `cse-inbox/*` branches were deleted; branches with unmerged work were saved first.
- Aedwon asked to stop pasting: "can you use codex a to complete the things please i'm tired of copy pasting lol",
  then "keep this path purely codex for now". Codex now writes and reads; for Codex-written lessons the reader is
  the same model, and the Astra audit is the independent check.
- Hand-in gate changes by the lead after false positives: the figure sweep no longer treats "folder" as folding;
  the formula sweep accepts letters an example names itself and is a reader note, not a block; polish-level sweep
  findings go to the reader instead of rejecting.
- First pass result: 86 lessons rewritten and read; 15 clean, 17 minor only, 45 with Majors, 9 with Blockers.
  A reader Blocker claiming the SALN deadline is April 15 was dropped: RA 6713 Section 8(A) says April 30.
- Overnight mandate (/goal): "please babysit this entire process of content while i sleep ... you can max out the
  codex usage". Choices: "Loop until clean", "Use A, B and C", "Start question blind-solves". Engineering:
  "i deliberately stopped engineering to focus on content". A lesson is parked for Aedwon after 5 rewrite rounds.
- Overnight outcome (2026-10-26 07:37): four rewrite rounds (54, 26, 8, 5 lessons). Final reads: 46 clean,
  39 minor only, 1 parked with a Blocker after 5 rounds (`lesson-code-of-conduct-ra-6713-penalties-and-enforcement`).
  Blind-solve of 1,100 CSE questions: 1,099 agree with the key; the one mismatch is a solver error. Report:
  `docs/content/audit/cse-blind-solve-r1.md` on `content/cse-rewrite-r1`.

## 2026-10-26 Roadmap dependencies and the Free and Pro split

- Found: the roadmap uses four hardcoded topic links (October 1) and alphabetical lesson order; the audit's lesson
  prerequisite map is unused.
- Aedwon: "a strict lesson order isn't good i think. because the purpose of having the dependencies is that the roadmap
  should recommend learning a prereq first before another lesson ... a 2nd consideration of it is the performance for
  that lesson. think of this as a smart but systematic roadmap maker."
- Design agreed: lesson prerequisite map with required and helpful links (content), rule-based prerequisite-aware
  recommendations at launch (R1), probabilistic engine after launch (R3). FSRS unchanged and read-only to the planner.
- Aedwon: "could we make a distinction for Free and Pro? just to give users a better reason to convert." Split follows
  the existing gates: the engine is never weaker for Free; Pro gets the diagnosis, knowledge map, forecast and what-if.
  Recommendation recorded, to confirm at kickoff: no cap on how far Free users advance.
- Debrief gap line placement: "1 sounds good" (session-finished screen). Mockups shown in the new design.
- Aedwon: "write up the changes for free vs pro, and also the roadmap. line it up for the engineering path, which will
  resume once we're done here in the content". Spec `docs/superpowers/specs/2026-10-26-prerequisite-roadmap-design.md`;
  STATUS rows R1, R2, E8; PWA plan After launch gains R3.

## 2026-10-26/27 CSE content close-out

- Questions: 243 new (all CSE files at 20+), two blind solves (1 key fixed, ng/nang per KWF), 54 files synced to the
  rewritten lessons. Prerequisite map and wrong-choice gap tags done (E8).
- Aedwon paused Sonnet figure work: "pause sonnet work for now, i'll need the usage for the beta signup website.
  continue with codex work". Then: "i just want the content (except illustrations for now, on purpose) to be fully and
  thoroughly done and ready for me to review". Figures: 58 of 86 committed; 28 wait for one fix round.
- Astra audit of General Information: 27 findings, 26 verified and fixed by Codex with sources.
- Lead rulings awaiting Aedwon's confirmation: RA 6713 penalties lesson teaches Section 11(c) as written without role
  classification (all conspirators are principals under the RPC); citizenship lesson is English, so L08/L10 are void.
  The Article 20 family exemption was removed earlier on Aedwon's decision ("ok then remove it").
- Final: 86 clean, 4 minor-only, 0 Blocker or Major. Aedwon asked why the minors were not cleared; each fresh read
  surfaces new minor notes, and minor items do not block under the checklist. The overnight /goal was cleared by
  Aedwon.

## 2026-10-26/27 Payments and access hardening (recovered from the engineering transcript)

Recorded October 29 by the engineering lead from transcript 51c348da (policy main 64e57576); these
were not in the repository before.

- An Astra payments audit (Codex account b, read-only) found 3 high and 5 medium issues. Sol fixed
  the five that needed no product choice: paid notes checked against the exam, share links bound to
  their owner, Manila-midnight sitting binding, web coverage for Google Play subscribers, and web
  passes extended when the exam date moves later.
- Aedwon's exact comment on the other three:

  > for issue 3, find a way to prevent them from abusing this exploit  for issue 5, double charges
  > usually mean 1 is activated, 1 is unactivated (queued for next month) so we can only refund the
  > unactivated one  for issue 8, what do you recommend

  Issue 3 (trial reuse after account deletion): the server keeps a one-way code made from the
  Google sign-in after deletion; no name, email or other personal data. The privacy policy needs one
  sentence about it; Aedwon writes the wording (pending). Issue 5 (double charge): a second checkout
  reuses the open one; a duplicate pass payment that still gets through is flagged for a refund that
  Aedwon issues; duplicate monthly or yearly payments add prepaid time.
- Issue 8, Aedwon's exact comment:

  > Yes, restore access on a won dispute unless the payment was refunded or revoked for another reason.

  Never longer than the original expiry.
- Result: `web/access-hardening-r1` 3e0a8e79 and `web/payments-hardening-r1` 440c4f0f, merged with
  B7c deferred libraries (`web/deferred-libs-r1`), W4h review fixes (`web/new-design-w4h-r2`),
  `integration/new-design-r1` and `web/pwa-staging-r1` into `web/staging-candidate-r1` 6078de3c
  (pushed). Full verification on October 27 (evidence `pwa-launch/evidence/staging-candidate-r1.md`
  there): Flutter 4880 pass, analyze, format, layering and attribution clean, Functions 195 plain
  and 280 emulator pass, web release and Android debug builds pass. Not deployed.
- Open: the Astra re-audit of the payments fixes never ran (all three Codex accounts hit their
  limits; the retry loop stopped October 27 19:45). Aedwon then paused engineering for content.

## 2026-10-29 CSE figures resumed: fonts, fixes, the last eight figures

Context: a new Claude content lead (Aedwon's other account) picked up the content conversation from
its local transcript and showed Aedwon a gallery of the 86 figures (58 committed, 28 held).

- Fonts. Aedwon's exact comment:

  > okay firstly, the font, why is that the choice? doesn't Pantas have a font already?
  > then also a different font (or matching what font is used in lessons) for the math things

  Finding: the app uses Geist for all text and KaTeX for lesson math. The figure style rule said
  Source Sans 3 with an Arial fallback and embedded no font, so most devices showed Arial. The lead
  also admitted the gallery page itself used fonts it picked instead of Geist; fixed. Proposal:
  Geist for figure text, KaTeX_Math italic variables and KaTeX_Main upright numbers and operators
  for figure math, with true minus, ≥ and superscripts. Aedwon's exact comment:

  > okay but for a few figures only not all of them. if it looks good to me only then can you mass apply

  A five-figure trial page (current beside proposed) followed. Aedwon's exact comment:

  > lgtm, apply and make the remaining corrections and illustrations. you're at 27% usage used so
  > there's plenty for Sonnet

  This also lifted the October 26 figure pause. Applied to all figures by the same script as the
  trial. Three cases the trial did not cover were corrected by a follow-up pass: words such as "for"
  upright, `2^x` as a raised exponent, single capital labels (A to E, O) in Geist.
- Illustrations. The 59-row `docs/content/illustrations/worklist.tsv` turned out stale: science
  lessons now use app-drawn FIGURE specs. Only 8 lesson markers lacked art (visual-media 3 to 9;
  logic-and-reasoning marker 1, added by rewrite RW-140 after the briefs). Options offered: SVG via
  the figure pipeline (recommended), SVG without briefs (faster, riskier), PNG via the Illustration
  Studio. Aedwon chose "SVG, figure pipeline (Recommended)".
- Animation. The figure style rule forbids animation, but on October 24 Aedwon asked for "svg
  everything with animations please". Options: static for now (recommended; checker and renderer
  lack support and app code is frozen) or add animation (engineering change). Aedwon chose
  "Static for now (Recommended)".
- Old visual-media pictures were numbered out of lesson order, and one was an outdated duplicate of
  the boulder cartoon. Options: renumber and delete the old one (recommended) or renumber and archive
  it. Aedwon chose "Renumber, delete old (Recommended)".
- Correction: the lead first reported 9 flagged held figures; there were 12 (three review notes
  named files without their folder).
- Result: `content/cse-rewrite-r1` c408899c (pushed). 94 SVGs plus 2 PNGs cover all 100 lesson
  markers. Held figures: Sonnet fix round, Codex review (6 of 12 passed), second Sonnet round on 11
  (including 5 new visual-media figures with margin issues). New figures: Codex brief for
  logic-and-reasoning 01, Sonnet drawing, Codex review. Checker 94/94 pass, every file parses.
  Known minor gaps: visual-media 07 label about 4 units from tick labels, citizenship 01 pill 3
  units from a card (rule is 6). Not yet verified in the app: the lesson SVG renderer must resolve
  Geist and the KaTeX families (handed to the engineering lead).

## 2026-10-29 Lesson SVG fonts: engineering resumed for one fix

The content lead's figures now name fonts: `Geist, sans-serif` for text, `KaTeX_Main, serif` and
`KaTeX_Math, serif` in tspans for math (approved by Aedwon earlier; figures static). Engineering
lead finding: B9 (SVG renderer) is already integrated (`integration/new-design-r1` fefe36a0), but
flutter_svg passes the raw font-family string to Flutter, so these names match no font and text
falls back to the default; the KaTeX fonts also need the `packages/flutter_math_fork/` prefix.
Options offered: minimal fix now (map the three names in the renderer, checker allows only them,
about 1 to 2 hours), or the payments re-audit first. Aedwon's exact reply:

> Yes, minimal fix

Decision: engineering resumes for this fix only; other paused engineering stays paused. Low-impact
change (renderer font mapping, checker and authoring note; no data, money or account effect), so no
separate spec or plan. Implementor Codex gpt-6.1-sol low on `web/lesson-svg-r1`, lead-reviewed, then
merged into `integration/new-design-r1` and `web/staging-candidate-r1`. Main application code stays
frozen.

Result (October 29): `web/lesson-svg-r1` 19764200 (Sol, lead-reviewed): the renderer maps the three
font-family values to `Geist`, `packages/flutter_math_fork/KaTeX_Main` and `.../KaTeX_Math` in every
lesson SVG loader; the checker rejects any other value; authoring note updated. All 94 figures on
`content/cse-rewrite-r1` pass the tightened checker. Merged into `integration/new-design-r1`
a3386e42 and `web/staging-candidate-r1` f176a763 (both pushed, remote SHAs verified). Checks on the
staging candidate: analyze, format, layering and attribution clean; web release build passes; full
`flutter test` had two failures in tool tests (`content_seed_writer_test`, `import_questions/cli_test`),
both pass when rerun alone and touch no SVG code (known intermittent). Integration: analyze clean,
743 component and tool tests pass. Not verified: how the fonts look on a phone (Aedwon's visual
check), Android and iOS builds for this change. Engineering is paused again.

## 2026-10-29 Figure accuracy follow-up

- Aedwon asked: "have necessary checks been done to ensure accuracy of the figures?" The lead
  answered not fully: second-round fixes and the font conversion were not independently re-reviewed,
  reviews read SVG source rather than rendered images, and a new check of all 96 brief markers
  against the current lessons found 3 stale figures (citizenship 01, three-branches 02 and 04),
  drawn before the lessons were corrected. Recommended: redo the 3, a final Codex review of
  everything changed, and an Astra audit of the constitution figures.
- Aedwon's exact comment: "hmm okay do the fixes first. then tell me, why are the figures mostly
  blue, does this fit in the app?"
- Result: `content/cse-rewrite-r1` 304d05c2. Codex rewrote the 3 briefs from the current lessons,
  Sonnet redrew, Codex traced every connector (accuracy OK), layout fixed in one more round.
  Citizenship 01 is 627 tall, over the 560 cap (full flow does not fit at 14-unit text). Not yet
  done, waiting on Aedwon: the wider final Codex review and the Astra audit.

## 2026-10-29 Roadmap R1 and R2 approved as specified

Aedwon asked whether the recent roadmap change was written down; the lead pointed to the October 26
spec and said two kickoff choices were open: complexity (spec recommends balanced) and no cap on how
far Free users advance (spec recommends no cap). Aedwon's exact reply:

> okay proceed as in the spec

Decisions: R1 and R2 at balanced complexity; no cap on how far Free users advance. Engineering
resumes for R1 and R2 only. The R2 debrief line still needs its final board approved through the
visual companion before implementation. Payments re-audit postponed by Aedwon ("let's do this
later"). Content inputs found on `content/cse-rewrite-r1`: `content/lesson-prerequisites.json` (90
lessons, 64 links, 4 required) and `content/question-gap-tags.json` (80 questions; wrong choices keyed
by choice text, not a `gapLesson` field in the rationale as the spec says; engineering reads the file).

## 2026-10-29 Figure colors: follow the app theme

- Aedwon asked why the figures are mostly blue and whether that fits the app. Finding: style D
  (chosen Oct 25: "hmm i think the quality bar should reach modern flat with deph. let's go with
  that.") uses a navy panel and gold accent; the app (Direction B, Clarity) uses neutral grays, teal
  `#0B7A68` and black in dark mode, shows figures in a `#FAFAF7` frame, and reserves gold for Pro.
  Verdict: partly fits. Recommendation: recolor to the app palette.
- Aedwon's exact comment: "Yes, color trial". A trial page showed five figures as now, B (fixed app
  light colors) and C (theme tokens, light and dark). The lead recommended C, with the risk that it
  depends on the renderer's token mapping, untested in the app. Aedwon's exact comment:
  "C, follows theme".
- Applied to all 94 SVGs by the trial's script. Rendering all 94 in both modes found cases the
  trial did not cover, fixed with added rules: outline-only shapes faded (lines now full-strength
  tokens), the old orange focus became error red (now accent), panel-navy fills meant holes in
  paper-folding but dark dots in matrices and cartoons (per-figure rule), small light dots faded.
  Deviation from the trial, decided by the lead for answer correctness: the 9 figures whose lessons
  name black and white shapes (figure series, matrices 04) stay in fixed light colors, since a
  theme swap would turn a "black circle" light in dark mode. Shown in the gallery for Aedwon's check.
- Aedwon confirmed the deviation. Exact comment: "Keep fixed light".
- Result: `content/cse-rewrite-r1` 1a56f521 (pushed). Style rules rewritten. Not yet seen in the app.

## 2026-10-29 Domain names in the app

- Finding: the app and functions still use `pantas.app` (Wrapped share links, the Wrapped landing
  page origin, and the privacy contacts `dpo@pantas.app` and `contact@pantas.app`). D8 chose
  `pantas.study`.
- Aedwon's exact comment: "all applicable to pantas.study, but the main app is on app.pantas.study
  , this makes sense right?"
- Decision: the marketing site (Hosting target `site`, which serves the `/wrapped/**` rewrite) is
  `pantas.study`; the app (Hosting target `app`) is `app.pantas.study`. Share links become
  `https://pantas.study/wrapped/<id>`. Contacts become `dpo@pantas.study` and
  `contact@pantas.study`; Aedwon creates both mailboxes before launch. Applied on
  `web/staging-candidate-r1` under the low-impact exception.

## 2026-10-30 Web layout from the design handoff

- Aedwon added the web design handoff (`web-design/pantas-handoff/`, HANDOFF.md plus 305 boards,
  1440 wide, light and dark) and asked for it to be built. Exact words: "i also added a web view
  design in design/ for you to implement. there will be some screens not applicable so skip them."
  and "i will be sleeping, so I hope you can babysit this end-to-end."
- Reading: this lifts the application-code freeze for the web layout work. The handoff's hard rules
  are settled decisions (Wrapped deferred, fixed content schema, no full-width buttons, text-link
  secondary navigation, results layout, fine print under its button, red only for destructive or
  wrong, reader top bar, mock flag and list toggle, UPCAT scoring). Board screens that need content
  or features the app lacks are not built without Aedwon. Per WORKFLOW, Aedwon does the visual
  checking; the lead does not capture screenshots.
- Complexity: the lead chose balanced in Aedwon's absence (he asked for unattended work). Scope and
  any decision the boards leave open are listed in the spec for his morning review.
