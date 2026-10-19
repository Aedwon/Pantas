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
