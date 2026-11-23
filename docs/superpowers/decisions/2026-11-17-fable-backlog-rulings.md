# Backlog rulings under Aedwon's delegation (November 17, 2026)

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent for the operations manager.

Aedwon's delegation, verbatim, November 17: "for things not needing me have another Fable 5.2 agent decide on my behalf".

These rulings are final under that delegation (D191; `docs/workflow/operations-manager.md`, "Rulings made under his delegation are final"). They are not queued for his sign-off.

- Policy read at `origin/main` 0edf1dcf6: `AGENTS.md`, `WORKFLOW.md`, `docs/workflow/process-improvement.md` (written rules 1 to 9 and the entries), `docs/workflow/operations-manager.md`.
- Input: `docs/superpowers/backlog.md` at the same commit, groups A, C, D and E.
- Out of scope: D1, the question generator. It has its own Fable session with Aedwon. Groups B and F and the "Verify done" list were not ruled here.
- `LL` = `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`.
- Velocity: this ruling pass was not timed. It changed documents only.

## What stays his

Not ruled, by his instruction: "ship it" for any prod release; legal sign-off; money and billing purchases; physical steps (phone tests, logins, console clicks, documents only he holds); visual and taste choices he kept (board approvals, caption language); anything that changes how agents work with him; items that need his personal facts (BIR, DTI, phone number, account details). A task he paused himself also stays paused until he resumes it (`WORKFLOW.md`).

## Limits applied to every ruling

- Usage is tight this week. Low-usage actions go now. Large builds wait until the beta ends on November 22, unless a date forces them.
- Written rule 7: no new cost without users.
- Best user experience. Approved boards and motion stay.
- A stale or finished item is ruled "verify done", with the check named.

## Counts

71 rulings across 66 items. Four items were split (A10, D18, E11, E16).

| Ruling | Count | Items |
|---|---|---|
| His | 8 | A5, A6, A7, A9, A11, A14, A20, E1 |
| Do now | 5 | A1, A2, A18, D18 (main protection), E11 (high item) |
| Verify done | 3 | A16 (verified here), A19, C2 |
| Do later, with a trigger | 26 | A10 (billing export), A17, C5, C8, D2, D4, D5, D6, D8, D11, D12, D15, D16, D17, D18 (security pass), D20, E2, E3, E5, E6, E10, E11 (medium items), E12, E13, E15, E17 |
| Dropped | 8 | A8, A12, A13, A15, D18 (marketing key), D19, E9, E14 |
| Merged into another item | 19 | A3, A10 (Resend key), C1, C3, C4, C6, C7, D3, D7, D9, D10, D13, D14, E4, E7, E8, E16 (both parts), E18 |
| Already done before this pass | 1 | A4 |
| Out of scope | 1 | D1 |

## Do now

Each is small. None adds a cost item (rule 7), and none ships to prod by itself.

| Item | Action | Owner lane | Usage |
|---|---|---|---|
| A1 | Test the access already on the Mac for adding the free sign-in rate-limit rule: the Cloudflare connector, the wrangler login, the DNS token. Add the rule if one works. Ask Aedwon for the console click only if all three fail. | Security and billing | About 5 minutes, no worker |
| A2 | Read the prod logs for one real Google sign-in after the Cloudflare switch (Nov 16 18:40 UTC). A tester's sign-in counts. If found, the old Firebase page can retire after Nov 18 18:40 UTC, under the same "ship it" as the secrets release (A9). | Security and billing | About 10 minutes, no worker |
| A18 | Read prod counts since Nov 14 for a resumed Reviews session, a finished quiz and a feedback send by real testers. If all three show clean, close the proof. | Beta monitor | About 5 minutes inside its next 12-hour pass |
| D18, part 1 | Add a rule on `main` that blocks forced pushes and branch deletion. No review requirement and no required check, so docs commits to main keep working. | Integrator | About 5 minutes, one command |
| E11, part 1 | Check whether the phone reader bar's contents and bookmark controls have a Tab stop, hover and focus. | DS4 completion | About 10 minutes, one Haiku read |

The two "verify done" checks (A19, C2) go to the integrator: about 10 minutes together, one Haiku read.

The SSOT keeper carries the "still his" list below into the SSOT's "waiting on Aedwon" section on its next daily pass.

## Still his, most urgent first

1. **A9, "ship it" for the secrets release.** Needed by Nov 21 16:00 UTC, so the 48-hour watch ends before the Nov 23 16:00 UTC cutoff. The same word covers retiring the old Firebase page (A2).
2. **D1, the question generator choice.** In its own session.
3. **A1, the Cloudflare console click.** Only if the access test fails.
4. **A7 with E4, PayMongo live activation.** BIR COR, DTI name, the Sole Proprietor upgrade, and the support message about QR Ph refunds. Live payments wait on it.
5. **A6, founder app owner inputs.** Business phone, footer facts, BIR, NPC registration, the signed child privacy assessment, the dpo inbox.
6. **A11 with D3 and D9, the word to resume CET content.** Recommended right after Nov 22. The ACET test is Jan 16, 2027.
7. **A14 with C1, the word to resume the verification and learning build, then its spec approval.** Recommended after Nov 22.
8. **A5 with D10 and D14, founder app spec and its 20 boards.** Recommended after Nov 22.
9. **A20, one iPhone session.** Splash, Study gap and Backup row, plus the A2 and A18 fallbacks if those are still open.
10. **D17, legal sign-off on the teen notice's "Age check" basis.** Only at the public launch legal package, on an agent's draft.
11. **E1, funds for the native store releases.**
12. **A10, the billing export console step.** Only if its trigger fires.

## Rulings and reasons

### Group A

- **A1. Do now.** The memory rule is to test logged-in tools before handing him a step. The rate-limit rule is free on Cloudflare's plan and was approved with the Nov 14 security list (R2). His click is the fallback, not the first move.
- **A2. Do now.** The condition in `LL:3593` is "one confirmed real Google sign-in on prod from the logs". It does not have to be his phone. Testers sign in with Google; eight real sign-ins were seen in the 24 hours before Nov 16. The page retirement is a prod deploy, so it rides the A9 "ship it" and he is asked once.
- **A3. Merged into E3; the ask is dropped.** He stopped the scroll work on Nov 16 ("tsk nevermind. note my frustration on this. i don't have enough usage for that."). Fable's Nov 16 ruling made his phone approval a condition of shipping the cap. With the work stopped, the cap does not ship, and asking for another iPhone test would repeat the failure logged on Nov 17.
- **A4.** Done before this pass.
- **A5. His.** Board approvals are his, and he talks to that lane directly.
- **A6. His.** Personal facts and signed documents.
- **A7. His.** BIR, DTI and his PayMongo account.
- **A8. Dropped.** The backlog line was wrong. On Nov 11 he chose option A, the current flow, and declined B, C and D (`LL:3135-3136`): "I'll take that. I don't operate in bad faith, nor would I want to design a fundamentally worse UX for users". A legal call he already made is not reopened here.
- **A9. His, with one part ruled.** "Ship it" is his. The destruction of the old secrets needs no second ask, because Fable's Nov 17 ruling already orders it and the old values live on in the two new secrets. Conditions, all required:
  1. the prod deploy is verified and every secret-reading path is proved (checkout, both webhooks, a sign-in code send, guardian mail);
  2. a read-back shows the new secrets hold values identical to the old ones, with no value printed;
  3. 48 hours pass on prod with no secret-access error and no wish to roll back, because the previous functions revision binds the old secrets and cannot run without them;
  4. after destruction, the count is 4 active versions across both projects.
  If "ship it" comes after Nov 21 16:00 UTC, the 48 hours still hold. The free-tier check's secrets waiver is then extended to that exact end time and no further. A working rollback is worth more than one day of a waiver.
- **A10. Split.** Billing export: do later. It is a console step with no deadline, and the weekly free-tier live check and the monthly cost check already watch cost. Trigger: the Dec 1 cost check finds a charge of $0.05 or more that it cannot explain. Staging Resend key: the same item as E10, merged there.
- **A11. His.** He paused CET himself and moved it to the end of the queue. Recommendation: resume right after Nov 22. The Codex weekly reset on Nov 18 gives Astra room for the 61 lessons, and the ACET test on Jan 16, 2027 is the nearest date a finished CET exam could serve. C6, C7, D3 and D9 are parts of this work.
- **A12. Dropped.** Fable's Nov 15 ruling (`LL:3727`) put reminder emails out of scope and built the Home beta notice instead. The extension email went out Nov 15. A tester who starts after Nov 18 cannot reach 5 days, so a new email now changes little, and each send costs him a self-test check (rule 6).
- **A13. Dropped.** No disk task is recorded on main. It reopens if he raises disk space or the laptop overheats.
- **A15. Dropped: do not rewrite.** A forced push to a public main would break every branch and worktree and every lane's base, for no gain to a user. CI, including the attribution check, passes on main today. Choosing not to rewrite needs no authorization.
- **A16. Done, verified here.** He chose style D, "modern flat with depth", on Oct 25 (`LL:1749-1758`). The three Codex accounts are in use through `codex-pick`.
- **A17. Do later.** It needs a taker's recall, not Aedwon. Trigger: a Subprofessional taker reports the counts. The beta monitor watches feedback for it. The survey is not changed (Fable, Nov 15).
- **A18. Do now.** `LL:3196` says the proof needs "someone on a real phone". Real testers have used prod since Nov 14, so counts can prove it without him. If the counts do not show all three, it joins his one iPhone session.
- **A19. Verify done.** The web trial is on Monthly only and passed the Nov 9 staging payment proof (`LL:2814`); the Terms "Subscriptions" section says the same (`LL:2855`). Check: the Pro page on main names the trial on Monthly only and none on Yearly. Then close. The Play offer is native work and is merged into E1.
- **A20. His.** Physical. One session covers it and any fallback from A2 and A18.

### Group C

- **C1. Merged into A14.** The same build.
- **C2. Verify done.** The stamps on main read 2026-11-12 in the app and in functions. Check: that date is the day the legal documents went live on prod. If it is, close. If not, set them at the next prod ship, as he approved on Nov 12 ("okay proceed").
- **C3, C4. Merged into E1.** Both are steps of a native release.
- **C5. Do later.** A gate, not a task: it runs before any CET exam opens.
- **C6. Merged into A11.** The CET figure pipeline (a brief, a drawing, a render and a check per figure, in style D) is the working pipeline. A separate style-kit build would duplicate it.
- **C7. Merged into A11.** The file is science content, edited on the CET branch. Fixing it on main now risks a conflict with that paused branch, and no user sees it while non-CSE exams are hidden.
- **C8. Do later.** A known workaround exists: start the run by hand. Trigger: the first CI workflow change after Nov 22, or two merges blocked by the gap.

### Group D

- **D1.** Out of scope.
- **D2. Do later.** A large build with heavy design input from him. Trigger: the next build choice after D1 settles. The roadmap change log (E16) belongs to it.
- **D3. Merged into A11.** The brief recommends the CET exams, so the decision is the word to resume CET.
- **D4. Do later.** Applications need a registered business. Trigger: BIR and DTI registration done (A7). An agent then drafts the applications and he submits them.
- **D5. Do later.** Trigger: the next build choice after D1 settles. Its study-method questions are decided from evidence (`WORKFLOW.md`).
- **D6. Do later.** His own condition stands: revisit when Pantas is earning. Trigger: the first paying month.
- **D7. Merged into E5.**
- **D8. Do later.** Trigger: 30 days after public launch, when real use exists to shape it.
- **D9. Merged into A11.** The Nov 15 handoff already makes the split lessons the CET rewrite's baseline.
- **D10. Merged into A5.** The founder app holds refunds and grants. It is needed at live payments.
- **D11. Do later.** Three to four days of build with no user asking. Trigger: paying users and the CET figures finished.
- **D12. Do later.** Trigger: public launch. The desktop layout needs his boards. E8 is the same Wrapped work.
- **D13. Merged into E3.**
- **D14. Merged into A5.**
- **D15. Do later.** It costs nothing today and little with users. Trigger: before the beta gate drops for public launch. Fix: one batched call for the read lessons.
- **D16. Do later.** The record went live Nov 14 as report-only. Tightening before the reports prove every sender aligned could send sign-in codes to spam. Trigger: Nov 28 and every report aligned; then move to quarantine.
- **D17. Do later.** It is the same risk class he accepted on Nov 11 (A8), raised a day later. Trigger: the public launch legal package. An agent drafts the notice wording under rule 5, Codex Sol at high effort critiques it, and he signs off the result.
- **D18. Split.**
  - Do now: protect `main` against forced pushes and deletion. It is free, takes one command, and blocks only what `WORKFLOW.md` already forbids. A builder force-pushed a branch on Nov 17; main should not depend on care alone. No review or check requirement, so nothing changes in how agents or Aedwon work.
  - Dropped: replacing the marketing key. It was disabled on Nov 14 (`LL:3263`). It returns only if marketing intake reopens.
  - Do later: S-12 checkout, narrower function permissions, security headers and Pro sync quotas, as one security pass. Trigger: before the live PayMongo keys go in (A7). Payments are in test mode until then.
- **D19. Dropped.** A private repository makes CI minutes billable, against rule 7, and gives up the free hosted runners.
- **D20. Do later.** His own condition stands. Trigger: three QR Ph refunds in one month.

### Group E

- **E1. His (money).** It stays parked until he has the funds for the store accounts. C3, C4, E7, E18 and the Play trial offer wait with it.
- **E2. Do later.** Trigger: public launch and working redemption codes (D10). The outreach is his.
- **E3. Do later; stays parked.** It reopens on his word only. If it does, the Nov 17 entries apply: state his goal as the test, get a Fable full option set first, and give him the usage cost and a stop point. The staging check build is replaced by the secrets staging deploy on Nov 18 to 19, so no separate rollback is spent. The three scroll branches are kept; deleting unmerged work needs his word. Note: `origin/web/native-scroll-spike-r1` exists, although `LL:3910` says that branch was never pushed. The integrator checks what it holds.
- **E4. Merged into A7.**
- **E5. Do later.** Trigger: PSHS-NCE is scheduled, which waits on D1.
- **E6. Do later.** Triggers: the custom exams row when a second exam opens; reminders with the native release (E1); each hidden exam at its own launch.
- **E7. Merged into E1.**
- **E8. Merged into D12.**
- **E9. Dropped.** Accepted as it stands. The APIs bill only on use, forcing them off is forbidden by the Nov 15 ruling, and the weekly free-tier live check watches them.
- **E10. Do later.** Trigger: the next change to the sign-in code or guardian mail path that needs a staging proof. Test first whether an existing key can create the staging key. A second key on the same account is free.
- **E11. Split.** The high item was ruled "fix before the next prod release" on Nov 14 (`LL:3539`), and prod has shipped twice since. Do now: verify it. If it is still open, fix it in the first UI release after Nov 22. It does not join the secrets release, which stays single-purpose because of its date. The four medium items (doubled SidebarNav focus ring, Figure zoom badge, Home 1440 label and panel, Pro hero offset): do later, trigger the first DS4 session after Nov 22. Each is fixed to its board.
- **E12. Do later.** Trigger: the first DS4 session after Nov 22.
- **E13. Do later.** Fable's Nov 15 condition stands: reopen only on a load reading above 10 s. The low-end device campaign (E16) merges here; beta telemetry from real devices stands in for it until then.
- **E14. Dropped.** Closed as "built and measured, declined". Its reopen condition is on record (`LL:3037`).
- **E15. Do later.** Trigger: each exam's launch.
- **E16. Merged.** The roadmap change log into D2; the device campaign into E13.
- **E17. Do later.** He left it until after the beta. Trigger: the first release after Nov 22, before public launch. A small fix; few students can be affected within weeks of sign-up.
- **E18. Merged into E1.**

## Corrections to the backlog found while ruling

- A8 said a choice of option D was waiting on him. He had already chosen option A on Nov 11.
- A16 was closed on Oct 25.
- C2's stamps are already 2026-11-12 on main, not the 2026-11-11 placeholder.
- `origin/web/native-scroll-spike-r1` exists on the remote.

## Nov 21: D21 and D22 (PSHS-NCE partials and the dots figure kind)

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent for the operations manager, under the same delegation ("for things not needing me have another Fable 5.2 agent decide on my behalf"). Both rulings are final and are not queued for his sign-off. They replace the Nov 17 operations manager rulings on D21 and D22 ("decided before the Dec 8 go/no-go").

- Policy read at `origin/main` c6feb916b: `AGENTS.md`, `WORKFLOW.md`, `docs/workflow/operations-manager.md`, the written rules in `docs/workflow/process-improvement.md`. The dispatch named 0172e8dfb; c6feb916b adds one launch-log entry and one velocity row and changes no policy file.
- Input: the PSHS-NCE content lead's options A, B and C for each item, relayed by the manager; backlog D21 and D22; `docs/pricing.md`, "Release requirement"; `docs/superpowers/plans/2026-11-21-manager-handoff.md`; `docs/content/pshs-nce/map-summary.md` on `content/pshs-nce-r1`.
- Goal used as the test: sell PSHS-NCE this cycle (test Jan 30, 2027; go/no-go Dec 8).
- Velocity: this ruling pass was not timed. It changed documents only.

### What was checked against the repo

1. **"A part appears in an exam only when it has questions tagged for that exam": true on main.** `lib/core/storage/data/repos/content_repository.dart:169-190` (`_lessonEligibility`, commit 4459cb9a4, Nov 5, "Show only the lessons an exam has questions for"). The Study list, the practice picker and the roadmap pass the exam; lesson search adds only lessons already in the exam's study map. The content branch carries older app source without this rule, which does not matter: the app ships from main.
2. **One exception: custom tracks.** A custom track keeps every active lesson that has any active question, whatever its exam tag (same file, line 160). The custom exams row is hidden on web today (E6).
3. **Quiz size.** `tool/checks/lesson_pool_check.dart`: for each exam a part's questions are tagged for, every key point needs a shipping question and the pool must reach the quiz size, which is the key point count held between 2 and 6 outside Mathematics. So 2 to 3 questions per part pass for a part with 1 to 3 key points.
4. **Figure answer choices are on prod** (Nov 18 17:33 UTC, handoff; `lib/core/ui/components/figure_choice_tiles.dart` on main). The generator spec excludes new figure kinds (`specs/2026-11-17-question-generator-design.md:449`), and the release requirement in `docs/pricing.md` names the generator, not this kind.
5. **Finding: text-only dots questions already exist.** Commit 947d7146f (Nov 20, "fill PSHS-NCE pools") added 12 approved text-only questions, 2 in each of the six dots parts, tagged `pshs-nce` only. They are in the content tree uploaded to prod on Nov 20 (`LL:4048`, d97de9415). This went against the Nov 17 ruling "No hand-written or text-only versions of these items meanwhile". No student can see them: PSHS-NCE is still "coming soon". The lead's worktree had their deletion staged, not committed, when this was read.
6. Not checked here: the server's exam scoping (the app comment says it also scopes by question tags), and whether the three science partials need a figure.

### D21. Ruling: option A, do now

Seven new small parts for II-10, II-13, II-14, II-16, III-10, III-12 and III-15, each with 2 to 3 questions tagged for PSHS-NCE only.

**Reason.** A closes seven known gaps against the official sample for about 2 hours of lead time on Codex, which has room and is to be used heavily before it expires. It touches no live lesson, so CSE and CET students cannot be affected and no re-audit is spent, while B buys the same teaching for more time plus a regression risk, and C leaves sample item types partly taught in a paid product.

**Conditions.**

1. Added files only: the seven part files, their question files, and the ledger and approval entries. No edit to any existing lesson or question file, including the `part`, `partCount` and `ordering` of shared parts. Each new part stands alone and is not numbered into an existing family; it takes a free `ordering` value.
2. Every new question file is tagged `exams: [pshs-nce]` only. Each part passes the pool check (every key point has a question; the pool reaches the quiz size).
3. Proof before merge: build the export before and after and show that the CSE and CET lesson lists, question pools and mocks are identical. The lane report carries the result.
4. Lessons use Grade 5 English; questions use realistic PSHS-NCE language. Every question is original, not a copy of a sample item. II-16 and III-10 have disputed keys or scan limits in the transcript: teach the method, never the disputed key.
5. III-10 (phase diagram), III-12 (latitude map) and III-15 (coastal diagram) are about reading a diagram. If a part cannot teach or test its point without a figure, it gets one through the figure pipeline the CET lessons used, with existing figure kinds only. It does not ship describing the diagram in words; that part waits instead, and the lead reports the added time.
6. Codex runs through `codex-pick`, only when `codex-pick --status` shows 5-hour room. The writer and the reader are separate runs. Blind solve and fit read pass before approval.
7. Known limit, accepted for now: a custom track would list these parts (check 2 above). Before the custom exams row reopens on web (E6), check that PSHS-NCE-only parts stay out of other students' custom tracks.

### D22. Ruling: option A, start now, not a gate for the go/no-go

One new figure kind, dots inside overlapping shapes, then 15 to 20 questions with figure choices for the six dots parts.

**Reason.** The four dots items are the only sample item type with no practice at all, and without questions the six written parts stay hidden, so PSHS-NCE students would get neither the lesson nor the practice. The cost is 2 to 3 days of Claude UI work on a base that shipped Nov 18, it can land after the go/no-go without holding the sale, and it is the first step toward generated versions; B gives that up to save a small cost, and C stays rejected because describing a diagram in words tests a different skill.

**Conditions.**

1. Complexity is ruled here as minimal: one figure kind, drawn from data, shown in a stem and in the shipped figure answer choices. No second kind, no motion, no generator rule. A generator rule for these items is a separate decision after this cycle.
2. Claude only, for the spec, the board, the widget, the renderer and the goldens. No UI work goes to Codex.
3. Aedwon's part is one board pick and "ship it" for the prod release. The board is built in Claude Design from the approved figure answer choice screens (written rule 3) and reaches him once, with a recommendation. The plain-language spec section is approved through the manager's Fable route, not by him, unless it changes something he picked on a board.
4. Priority: the under-13 build and generator Phase 2 come first, because the sale cannot open without them. This lane starts now as a second Claude lane; if Claude usage forces a choice, this lane pauses first.
5. Not a gate: PSHS-NCE may go on sale with the six dots parts hidden. The Dec 8 go/no-go does not wait for this.
6. Stop points: if the UI lead's timed work passes 5 working days, stop and report to the manager. If the kind and its questions are not on prod by Jan 9, 2027, three weeks before the test, the lane stops and the parts stay hidden for this cycle.
7. Content lane, after the kind renders on staging: 15 to 20 original questions across the six parts, each part passing the pool check. The blind solve works from the rendered figure, not from the figure data, because the data states which region each dot is in. IV-15 and IV-16 have disputed official keys: do not copy those items or their keys.
8. The 12 text-only dots questions are retired. The deletion is committed on the PSHS-NCE content branch, reaches prod with the next content upload, and is confirmed gone before PSHS-NCE opens. No text-only version ships to a student.

### What needs Aedwon

- D21: nothing.
- D22: the board pick for the dots figure kind, when the UI lead has it, and "ship it" for the prod release that carries the kind.

### Corrections to the backlog found while ruling

- D21 said the partials would be "short added sections in existing lessons". They are now new PSHS-NCE-only parts; no shared lesson changes.
- D22 said the dots lesson "is written with no questions". Since Nov 20 it has been six parts with 12 text-only questions (check 5 above).
- The manager should log check 5 under `docs/workflow/process-improvement.md` if it judges the text-only questions a repeat or a costly miss; that call was not made here.

## Nov 22, legal package D1 to D8

Ruled by a Claude Fable 5.2 agent, acting as the review sub-agent for the operations manager, under Aedwon's delegation (Nov 14: "for things needing my decision, consult a fable 5.2 agent instead"; `docs/workflow/operations-manager.md`). The rulings are final and are not queued for his sign-off, except the items listed under "What needs Aedwon". Legal sign-off on the final texts stays his. No lawyer reviewed anything here (his Nov 9 decision, checklist row L8), and this agent is not a lawyer: where the law is unsettled, the entry says so.

- Policy read at `origin/main` 16bf042a6: `AGENTS.md`, `WORKFLOW.md`, `docs/workflow/process-improvement.md` (rules 5, 6, 7, 9), `docs/workflow/operations-manager.md`, `docs/pricing.md`, `docs/superpowers/plans/2026-11-22-cse-public-release-checklist.md`.
- Input, on `legal/public-launch-r1` bb45294e5: `docs/legal-drafts/2026-11-22-public-launch/README.md` (entries D1 to D8), `critique-2026-11-22-sol-high.md`, `terms.md`, `privacy-policy.md`, `teen-notice.md`, `change-summary.md`.
- Earlier decision that binds D1: Nov 11, `LL:3131-3136`. Aedwon kept the current guardian flow: "\"The short answer: the current flow is legally shaky, but it isn't clearly unlawful.\" I'll take that. I don't operate in bad faith, nor would I want to design a fundamentally worse UX for users".
- Goal used as the test: texts and behavior that lean toward Pantas as far as Philippine law allows, with no worse sign-up, at the lowest work that makes the published texts true on the day they publish.
- "Gate" below means: must be on prod before the beta gate drops and before live payment keys (checklist G2). "Later" names its trigger.
- Velocity: this ruling pass was not timed. It changed documents only. Sizes are estimates for one lane with tests.

### What was checked against the code (main 16bf042a6)

1. **The under-18 flag has one reader.** Outside the guardian functions, only checkout reads it (`functions/src/paymongoCheckout.ts:43-53`). Firestore rules read the consent record only for the `withdrawn` status (`firestore.rules:7-11`).
2. **The flag is written when the request is sent, and kept after a decline or no answer.** `guardianConsent.ts:247-251` writes `ageGroup: 'minor'` with the pending request. The hourly cleanup trims an expired or declined request to the flag alone, with the comment "checkout's guardian box depends on it" (`guardianConsent.ts:581-585`).
3. **An unconfirmed teen cannot reach checkout on that device.** The age gate stays closed until a guardian confirms (`lib/features/onboarding/application/onboarding_flow.dart:79-85`; `guardian_providers.dart`). Checkout also needs a named account. So the kept flag acts in one case only: a teen who answered truthfully, was declined or ignored, then sets up again as an adult on the same sign-in. A teen who uses another account, or who gives a false age the first time, never has a flag.
4. **What the flag enforces is a tick.** Checkout only compares the Terms version sent with the tick (`paymongoCheckout.ts:47-52`). The same person can tick it.
5. **The server holds no adult declaration at all.** The age stays on the device. For an adult buyer the order records nothing about age or authority.
6. **The adult Pro screen shows no Terms or refund link before payment.** The Terms link exists only inside the guardian box, which shows only when the device age group is minor (`pro_page.dart:841-844`, `401-436`). The draft Terms say "A new purchase uses the Terms shown before payment" (section 12), which is not true for adults today.
7. **The guardian box is an approved component** (boards CB_Wide, CB_Ph; approved Nov 11, `LL:3119-3121`).
8. **The server never stores the guardian's email address.** It stores a keyed hash and a masked address, and trims both seven days after confirmation (`guardianConsent.ts:17-25`, `541-580`). A guardian cannot be emailed from Pantas records at any point.
9. **The live Terms already promise 14 days of notice.** The Terms in the app today (version 2026-11-12) say a material change takes effect "at least 14 days ahead" after in-app notice (`lib/features/legal/domain/legal_document.dart:477-487`). Replacing them with the public-launch Terms is such a change for accounts that exist today. The README did not carry this.
10. **Setup consent names the records.** The one tick reads "I agree to the Terms of Service and Privacy Policy, and to Pantas keeping my study records (answers, results and study times)." (`onboarding_consent_step.dart:24-27`).
11. **Trial codes hold no date.** Each is `{used: true}` (`webTrial.ts:126`; also written at deletion, `deleteUserData.ts:60-67`). Firestore TTL policies are already in use (`firestore.indexes.json:149-150`).
12. **A manual refund changes access only when the refund command is run.** A bank transfer alone leaves the grant untouched (`docs/OPERATIONS.md:156-188`). A refund made through PayMongo fires the webhook and shortens or revokes access (`paymongoGrants.ts:43-51`).
13. **PayMongo holds the account ID and order reference for every web payment** (`paymongoClient.ts:36-37`), so a payment can be found there after Pantas deletes its own index.
14. Not checked: live merchant settings, console settings, the website repository, and the two Supreme Court cases cited under D2, which are cited from memory.

### D1. Ruling: keep the flow as built (his Nov 11 decision stands), and delete the under-18 record when a request fails. Gate

The flow does not change: the teen enters an age, sends the request, and the server records the request. Option C is rejected, as on Nov 11. The one change is retention: when a request expires, or seven days after a decline, the cleanup deletes the whole record instead of keeping the under-18 flag. Flag-only records that exist today are deleted in the same release. This is the retention half of README option B. It was not among the options he declined on Nov 11, and it changes no screen.

**Reason.** Check 3 and check 4 show the kept flag protects almost nothing: it reaches one narrow case and enforces a tick the same teen can make. A sensitive record kept forever for that purpose cannot pass the "necessary" test that Section 13(f) needs, and it is the part the critique calls hardest to justify. Deleting it costs half a day, changes nothing a user sees, and does not need D2 to ship first.

**What stays, and the honest limit.** The record still exists while a request is open (seven days at most) and after a guardian confirms. The open request is the step needed to get the guardian's permission, and after confirmation the guardian's permission covers it. The guardian's own answer record, including a decline, stays as evidence: that is the specific evidence Section 13(f) fits best. No Philippine ruling decides the open-request period, so that risk is smaller, not gone.

**Conditions.**

1. Cleanup: an expired or declined request is deleted whole at the times cleanup already uses. No new scheduled job (rule 7).
2. One-time removal of existing flag-only records, counted against the free tier before the run (rule 7).
3. Tests fail first on the old trim.
4. The text lane rewrites the matching Teen Notice paragraphs ("If the request expires...", the two retention bullets, the basis bullet): the flag is removed, not kept. Sol High critiques the changed paragraphs (rule 5).
5. Ship before opening. After opening, a retention change needs the rule 9 email.

**Size.** About 0.5 day: code and tests 2 to 3 hours, text and critique 1 to 2 hours.

**Later, not ruled.** A decline-only answer record could take a shorter period than ten years. Raise it with the next text pass.

### D2. Ruling: option C, in one Pro screen change with D3. Gate

Every web checkout carries a declaration. The server refuses a checkout without it and records it on the order with the date, time and Terms version. Checkout stops reading the under-18 flag for accounts with no confirmed guardian.

- Adult account, draft wording: "I am 18 or older. I may use the payment method I will pay with, and I accept the Terms and refund policy."
- Account with a confirmed guardian, draft wording: "I am the parent or guardian, 18 or older. I may use the payment method I will pay with, and I accept the Terms and refund policy." The server requires this version when it holds a confirmed under-18 record.
- "Terms and refund policy" links to the Terms. The final wording is legal text: the text lane settles it and Sol High critiques it (rule 5).
- Native purchases are out of scope for this launch.

**Reason.** Philippine cases on contracts with minors turn on whether the minor actively claimed to be of age (Mercado v. Espiritu, 1917, against Braganza v. Villa Abrille, 1959; cited from memory, to be confirmed in the next critique). Today the server holds no such statement for any adult buyer (check 5). A recorded statement at payment is the strongest cheap evidence Pantas can hold against a later claim that a minor bought alone, and against a payment dispute. It also records acceptance of the current Terms at every purchase, which the draft Terms already assert (check 6).

**Form.** A required tick, reusing the approved guardian box card in its approved place. It adds one tap to every adult purchase. Because adults see no box today, this is a new screen state: it goes to Aedwon as one board state in the CSE release boards (E-135, rule 3), with a no-tick line under the Pay button as the other option. The server record is the same either way. Recommendation: the tick, because an act is better evidence than a line.

**Conditions.**

1. UI work goes to Claude workers, never Codex. The function change may go to Codex through `codex-pick`.
2. The text lane updates the Terms "Students under 18" paragraph, the Privacy Policy "Payments" bullet and the Teen Notice "Payments for minors" section: the declaration is recorded for every web purchase.
3. Ship before opening. Adding the record after opening is a change to what Pantas collects and needs the rule 9 email.

**Size.** About 1 day: both wordings, the function check, the order record, tests, one board state.

### D3. Ruling: option B at launch with invoices by hand (A). C later. Gate

- The Pro screen links the Terms and refund policy beside the Pay button (the D2 declaration carries the link) and shows a short seller line: registered name, place of business, phone and email.
- The website footer carries the same seller details.
- Invoices are issued by hand until C is built. The Terms invoice sentence stays out until the invoice process exists (checklist M8).

**Reason.** The seller details and the policy shown before payment are plain duties under the Internet Transactions Act and the Consumer Act, the critique lists them as must-fix, and they cost under a day. Automatic invoices need the BIR invoice format first, and that waits on his registration.

**Conditions.**

1. The seller line is a layout change: it rides on the same board state as D2.
2. The footer is website copy. He approves its wording before it publishes (`WORKFLOW.md`).
3. The seller facts are his (checklist L3). The change cannot ship with brackets.

**Size.** About 0.5 day in the app, shared with D2's ship, and 0.25 day on the website.

**C trigger.** When he reports that invoices by hand are a burden. The manager asks at each monthly cost check. Size 2 to 3 days.

### D4. Ruling: options A and C now. B later. C is part of gate M6

- A: the refund code stays. A statutory case where access must continue (for example a price reduction) is paid by bank transfer and the refund command is not run, so access is untouched (check 12). The runbook says so in one line.
- C: the one real payment planned in M3 is made by QR Ph and refunded, to learn what the live account allows. The runbook gains a step to find a payment by its PayMongo reference when the Pantas index is gone (check 13).

**Reason.** A statutory price reduction is rare, and the by-hand path already gives the right result with no code. The untested part is the live account, and that test costs nothing beyond the payment already planned.

**Size.** 0.25 day, no code. The real payment and the bank transfer are his (M3, M6).

**B trigger.** The first statutory case that the by-hand path cannot handle, or the first refund that must go back through PayMongo with access kept. Size 0.5 day.

### D5. Ruling: option A for launch. B on a trigger. C and D rejected. Rule 9 amendment for his approval

- A: each change to the Terms or to data practices is run by hand: a Home notice, the email (rules 6, 8, 9), and the manager holds the version stamp change until 14 days after the notice. The manager logs the notice date in the launch log.
- With D2, every purchase records acceptance of the Terms in force. So every paid contract has recorded assent, and the draft Terms already keep an existing paid period on its old terms. Only Free use rests on notice and continued use, which the critique calls the more defensible case.
- B (re-acceptance screen, with a new guardian confirmation for teen accounts): build it before the first change that makes users' position worse outside a purchase, or the first change that needs new permission. Size 2 to 3 days.
- C rejected: a scheduler for a step the manager can hold by hand.
- D rejected: it adds a guardian's email address to the records only to send notices. The Nov 11 and Nov 12 design keeps no guardian contact, and less data held is less to breach and to explain.

**Finding that affects the launch (check 9).** The live Terms promise today's accounts 14 days of in-app notice before a material change. The launch does not need to wait. The public-launch Terms apply to new accounts from publication. For accounts created before publication they apply 14 days after the Home notice, or earlier when the user accepts them at a purchase. The text lane adds that line to the Terms and to the change notice. Today's accounts are beta testers with no real payments, so no paid period is affected.

**Rule 9, amended wording, for his approval.** Not applied to `docs/workflow/process-improvement.md`. Changing a written rule is his approval. The first three sentences change. The rest is as written today.

> 9. Once the app is open to the public, every change to what Pantas collects about users, why, how long it keeps it, or who receives it goes out by email to every affected user whose account has an email address, before the change takes effect. An account with no address gets the in-app notice only. For an under-18 account, Pantas keeps no guardian email address, so the guardian is not emailed: the email goes to the teen's own address, and the email and the in-app notice both ask the teen to show it to their parent or guardian. A change that needs new permission does not apply to an under-18 account until a parent or guardian confirms it through a new guardian request. Where an address exists, the in-app notice is not a substitute for the email. The email follows rules 6 and 8, and its legal text follows rule 5. During the closed beta, Aedwon may tell testers himself instead. He did this for screen counts on Nov 15. His words (Nov 15): "i already told the testers personally. you can skip this, but make it of record that changes to privacy should come with an email. this is industry practice correct? we'll do this strictly when the app has opened". No check can tell when a code change alters collection. The lead building such a change flags it in its handoff, and the manager holds the prod "ship it" until the email has gone.

Two changes, which he may approve separately: (1) the guardian sentence, because the email it asks for cannot be sent (check 8); (2) the "no address" sentence, because guest accounts have no address either. If he rejects (1), the only other path is option D, about 1 to 2 days, and it must ship before opening.

**After his answer.** The text lane aligns Terms section 12 ("we tell a parent or guardian too") and the Teen Notice "Changes" section with the approved wording. Both promise more than the app can do today.

**Size.** No work at launch beyond the text edits. Not a gate, except that the texts must match his answer before they publish.

### D6. Ruling: option A at launch. B in the first release after launch. Not a gate

**Reason.** The tick already names the records (check 10), and Pantas cannot run without them, so a second required tick gives the user no new choice. The gain is a cleaner record of permission, which matters but does not justify changing sign-up in the launch week (his Nov 11 reason). The law here is not settled: the critique calls a separate tick "stronger", not required.

**Conditions for B.** A board in Claude Design for his pick (rule 3). Accounts made before B are not asked again. The guardian page tick (option C) is decided on the same board.

**Size.** None now. B is about 0.5 day plus the board; C about 1 day in all.

### D7. Ruling: option B. The period is 730 days. Gate

Each trial code gets an expiry date 730 days after the trial started. Codes that exist today take the deploy date as their start. A Firestore TTL policy removes them, so there is no cleanup job.

**Reason.** A code kept forever to protect a seven-day trial of a ₱149 plan is the weakest retention claim in the package, and a date makes the legitimate-interest basis easy to defend. 730 days matches the inactive-account and audit-log periods already in the texts and covers four CSE sittings, so a trial cannot be repeated each exam season. The period is ruled here under the delegation. It appears in the texts he signs, so he can change the number at sign-off.

**Conditions.**

1. TTL policy on the expiry field. Count the one-time update of existing codes and the daily deletes against the free tier (rule 7).
2. The deletion path writes the same expiry, counted from the trial's own start time when the account record has it.
3. The text lane replaces "no scheduled expiry" in both notices with the period, and checks the Terms trial paragraph still reads true.
4. Ship before opening, for the rule 9 reason in D1.

**Size.** About 0.5 day.

### D8. Ruling: options A and C. B rejected for now. Gate, no code

- A: the texts stand. The business keeps its tax books, invoices, receipts and refund evidence outside the app.
- C: a written procedure, in `docs/OPERATIONS.md`, with two parts: (1) find a payment by PayMongo reference or account ID after deletion (shared with D4); (2) once a month, export the PayMongo transaction and payout reports to a private folder he controls. The folder is not a git repository, so records can be deleted when their five years end.

**Reason.** PayMongo already holds every payment, payer and refund with the Pantas account ID (check 13), so an archive in the app would copy data that exists, and the tax books and invoices are his documents whatever the app keeps. The text's claim is true only if those documents exist and outlive the PayMongo account, and the monthly export is what makes it true.

**Conditions.** The procedure is written before live keys. The first export follows the first real payment. The monthly export is his step, about five minutes.

**B trigger.** Two months in a row without the export. Size 0.5 day.

**Size.** 0.25 day, no code.

### Summary

| Item | Ruling | Size | Launch |
|---|---|---|---|
| D1 | Flow as built (Nov 11 stands); delete the under-18 record when a request expires or is declined | 0.5 day | Gate |
| D2 | C: recorded declaration on every web checkout, one Pro screen change with D3 | 1 day | Gate |
| D3 | B, invoices by hand; C later | 0.5 day app, 0.25 day website | Gate |
| D4 | A and C; B later | 0.25 day, no code | C inside gate M6 |
| D5 | A; B on a trigger; C and D rejected; rule 9 amendment for his approval | Text only | Not a gate; texts must match his answer |
| D6 | A; B in the first release after launch | None now | Later |
| D7 | B, 730 days, TTL policy | 0.5 day | Gate |
| D8 | A and C; B on a trigger | 0.25 day, no code | Gate |

Gate work in total: about 3 days of lane time, one board state, and his facts.

### What needs Aedwon

1. Rule 9 amendment (D5): approve, change or reject the wording above.
2. One board state (D2, D3): the adult Pro screen with the declaration and the seller line. Pick the tick or the no-tick line.
3. Website footer wording (D3).
4. His facts for the seller line and the texts (checklist L3, README list).
5. The QR Ph payment and refund on the live account (D4, inside M3 and M6), and the monthly PayMongo export (D8).
6. Legal sign-off on the final texts, after the text lane applies these rulings and Sol High critiques the changed paragraphs.

### Text changes these rulings need (for the legal lane, rule 5)

1. Teen Notice: expiry and decline paragraphs, two retention bullets, the basis bullet (D1).
2. Terms "Students under 18", Privacy Policy "Payments", Teen Notice "Payments for minors": the declaration on every web purchase (D2).
3. Trial code period in both notices; Terms trial paragraph check (D7).
4. Terms section 12 and Teen Notice "Changes": the guardian line after his rule 9 answer, and the effective-date line for accounts made before publication (D5).
5. Sol High critique, round 2, on the changed paragraphs through `codex-pick`, including the two case citations in D2.

### Corrections found while ruling

- Checklist row L2 says the minor-label flow "stays as built". That remains true of the flow. The retention of the flag changes (D1).
- Checklist row L7 says a Terms version bump asks existing students to accept again. It does not (README, "Where the app and the text disagree"). D5 replaces that with the notice, the email and acceptance at purchase.
- The README's D1 option B said checkout needs D2 before the flag can go. It does not (checks 3 and 4).
- The README did not carry the live Terms' 14-day notice promise for today's accounts (check 9).

## Nov 23, CSE release UX council rulings

Council (Aedwon, Nov 23, relayed by the manager): for a build-versus-board difference where it is unclear which is better, Gemini 4 Neon High (through agy) and a Fable 5.2 high agent judge independently, given the board, the build at phone and wide widths, and his guidance: "i do not like wordy UI. if you can compress text, do it. I like clean, intuitive, elegant, and satisfying (in terms of motion and animations) UI/UX". If they agree, that is the ruling; if they split, Fable's call is final.

### C1. Phone lesson reader topic line: B, the board's eyebrow (RD_Real). SUPERSEDED Nov 23

- Question: above the lesson title, A (the build since Nov 5: topic in sentence case, 15 px, regular, gray) or B (board RD_Real: 13 px all caps, weight 600, .04 em, 8 px above the title). No record of Aedwon approving A exists; a Nov 5 test comment cites "QA 2F-23" with no source.
- Fable 5.2: B. "Clearer hierarchy with less visual weight" (A reads like a second, weaker title); B is the approved design.
- Gemini 4 Neon High: B. "Clearer student hierarchy" and "cleaner, tighter craft" at 13 px with an 8 px gap.
- Ruling: B. Condition both named: switch to A if real topic names wrap to two lines in caps at 390 px; the T3 review checks the longest CSE topic name.
- Applied in T3 (`qa/no-part-label-r1`). Wide web keeps the topic at 15 px per W_Reader.

### C2. A long topic on the phone reader eyebrow (state no board draws): drop the parenthetical aside (Fable 5.2). SUPERSEDED Nov 23

- Found by the T3 board review: "Spatial & Abstract (Non-Verbal) Reasoning" in 13 px caps measures about 339 px of 342 px at 390 px, so it wraps to two lines on 360 to 375 px phones or with larger text. RD_Real never shows a topic this long.
- Options: let it wrap; one line with an ellipsis; a shorter eyebrow name; other.
- Fable 5.2 (high), verbatim ruling: "Option 3. Show \"SPATIAL & ABSTRACT REASONING\" on the reader eyebrow, full name elsewhere and to screen readers, no line limit, wrap as fallback, never an ellipsis." Reasons: "(NON-VERBAL)" restates "SPATIAL & ABSTRACT", matching his compress-text guidance; an ellipsis clips meaning when text is scaled (WCAG 1.4.4, 1.4.10).
- Applied as one general rule instead of a new content field: the reader eyebrow drops a parenthetical aside (`readerEyebrowText`, `qa/no-part-label-r1` a7b10ab4a), and the full name is the semantics label.

- Superseded, Nov 23 (CSE release lead): C1 and C2 were judged against the Nov 1 export of RD_Real. The same day the reference canvases were updated (`docs/superpowers/verification/2026-11-23-reference-canvas-folds.md`): the approved reader Polish C replaced RD_Real and W_Reader. Polish C draws the topic as one 15 px secondary line in sentence case, 8 px above the title, which is the build's "A". The build follows Polish C; the caps eyebrow and the shortened topic are removed (`qa/no-part-label-r1` 3119169d5). Mistake: the lead had the workers build from the Nov 1 export instead of the live canvases. Fix: every brief now points at the live Pantas Web and Pantas Redesign canvases and says to re-read the board before building.

### C3. Sign-out with unsent data (state no board draws) (Fable 5.2, Nov 23)

- Found by the Codex audit of report sending (PR #86): sign-out runs a send bounded to 2 seconds, then the local wipe; anything unsent "is lost with the wipe, as before". The dialog says only "Sign out? Your progress is saved to your account."
- Ruling, verbatim: "Block sign-out before the wipe when unsent data cannot be sent, reusing the existing connection message; defer option 4 and any \"sign out anyway\" escape to a board. Fix the Free-tier dialog copy before launch, because it is untrue."
- Reasons: silent loss fails "no risks"; blocking is recoverable, lost answers are not; the existing line "You need a connection to sign out." needs no new board. Possible worse bug to confirm: the wipe may run before the network steps, so offline sign-out could delete data and then show the error.
- Applied in T2 (`qa/report-send-r1`), with the Free-tier copy settled by the lead under rule 4.

## Nov 23, legal round 2 product decisions

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent, under Aedwon's delegation ("for things not needing me have another Fable 5.2 agent decide on my behalf"). The rulings are final and are not queued for his sign-off. Legal sign-off on the final texts, "ship it", billing purchases and physical steps stay his. This agent wrote no legal text: wording named below goes to the text lane and to Sol High (rule 5). No lawyer reviewed anything here, and this agent is not a lawyer: where the law is unsettled, the entry says so.

- Policy read at `origin/main` 26b7183d9: `AGENTS.md`, `docs/workflow/process-improvement.md` (rules 4, 5, 7, 9), and the section "Nov 22, legal package D1 to D8" above.
- Input, on `legal/public-launch-r1` a989972e3: `README.md` section "Needs a product or code decision (round 2)", `critique-2026-11-23-sol-high.md`, `change-summary.md`, `teen-notice.md`, `privacy-policy.md`.
- Code read: main 26b7183d9 (`functions/src/paymongoCheckout.ts`, `deleteUserData.ts`, `purgeInactiveAccounts.ts`, `guardianConsent.ts`, `scheduledJobs.ts`, `firestore.indexes.json`, `pro_page.dart`) and PR #86, `qa/report-send-r1` daef9e944 (`functions/src/questionReports.ts`, `deleteUserData.ts`, `lib/core/ui/components/report_form.dart`).
- Board read: Guardian Manage and Minor Checkout, boards CB_Wide, CB_Ph and the as-built notes.
- Test used: no risk at release, inside the hardened scope of about 12 to 14 working days. Texts and behavior lean toward Pantas as far as Philippine law allows. Every published sentence is true on the day it publishes.
- "Gate" means on prod before the beta gate drops and before live payment keys (checklist G2), as in the Nov 22 section.
- Standards applied: Data Privacy Act Sections 11(e) and (f) (proportionality, retention), 13(f), 16(a) and (b); Civil Code Articles 1108, 1144, 1146, 1390, 1391; RA 8792 Section 16; NPC Advisory 2024-03; WCAG 2.1.1 and 4.1.2 for the Terms link. The Civil Code articles are cited from memory and go to the round 3 critique for confirmation.
- Velocity: this ruling pass was not timed. It changed documents only. Sizes are estimates for one lane with tests.

### What was checked against the code

1. **The guardian's only verified channel is the manage link.** It is made when the request email is sent and when the guardian confirms, and it has no expiry (`guardianConsent.ts:245-247`, `354-379`). The server holds no guardian address (Nov 22 check 8), so it cannot send a guardian a request about one order.
2. **The deletion copy selects by time alone.** `keepGuardianEvidence` copies every checkout and order whose `attestedAt` is a number (`deleteUserData.ts:126-136`). Today only under-18 accounts write that field (`paymongoCheckout.ts:43-53`). Once D2 writes a declaration for adults, the same code would keep adult declarations for ten years. The copy already holds the product.
3. **Evidence is kept 3,653 days from its newest record, for every kind of record,** and only once the account is gone (`purgeInactiveAccounts.ts:24`, `276-296`). A decline counts the same as a confirmation.
4. **The server never learns a student's age.** It holds the under-18 group only. So it cannot compute a date such as "four years after this student turns 18".
5. **Reports have no expiry.** A report holds `createdAt` as a Firestore timestamp and nothing removes it except account deletion (`questionReports.ts:137-140`, `deleteUserData.ts:94-97` on the PR branch). No report is on a server yet: before PR #86 reports stay on the device (checklist P2).
6. **Two Firestore TTL policies already exist,** both on a field named `expireAt` (`firestore.indexes.json:149-150`). Prod runs nine tasks from three scheduler jobs, the free limit (`scheduledJobs.ts:14-18`).
7. **The Terms link already opens the Terms without ticking the box.** The label is one text flow, and the link is a span with its own tap handler (`pro_page.dart`, `_guardianBoxCard`). Board CB_Ph draws "Terms" as a link inside the label.
8. **The report form has a title, one line under it, the field, and Cancel and Save.** The line reads "Something wrong or unclear? Tell us and we'll check it." The field hint reads "What did you notice?". The button reads Save, not Send.
9. **Abandoned checkout attempts are never cleaned up.** An order record is written before payment and stays until the account is deleted.
10. Not checked: the Firestore TTL delay (stated from Google's documentation, from memory), the QN_Report board, live console settings.

### R1. Guardian approval of the specific order: not built for launch. The D2 record plus the guardian's account confirmation stand. Not a gate

Nov 22 ruling D2 stands and is not re-ruled. A guardian-approved order is built later, on a trigger.

**Reason.** The only verified guardian channel is the manage link (check 1). A real order approval is therefore a purchase path on the guardian page: new screen states for his pick, a second checkout entry authorized by a manage token, and new payment return handling. That is about 3 to 4 days plus a board round, on the payment path, inside the launch window. It fails the "no risks at release" test. What it would add is small: a purchase for a minor can be annulled whether or not a tick exists, and the most Pantas loses in one case is one plan price.

**What Pantas holds at launch.** The guardian's own confirmation of the account, answered through a link sent to the guardian's address, kept as evidence. The recorded declaration on the order (D2). PayMongo's record of the payer. The Terms right to ask for proof and to cancel. The honest limit, as Sol High says: the tick proves what the student's session submitted, not that a guardian bought.

**Conditions at launch.**

1. The texts describe a declaration. They never state as fact that the buyer is the guardian. The README says round 2 applied this. The text lane rechecks the Terms "Students under 18" paragraph and the Teen Notice "Payments for minors" section.
2. One line in `docs/OPERATIONS.md`: when a parent or guardian says they did not allow a purchase on an under-18 account, refund it in full by the D4 path, run the refund command so access ends, and do not contest. This keeps the open risk at the price of one plan. He can change this default.

**Trigger for the build.** The first refund demand or bank dispute on an under-18 account where the guardian or payer denies the purchase, or before native purchases open to under-18 accounts, whichever comes first. The manager checks at each monthly cost check. Direction when built: the guardian buys from the guardian page, so no guardian address is stored (consistent with D5, option D rejected).

**Size.** 0.1 day now, no code. Later: 3 to 4 days plus one board round.

### R2. Deletion copy: guardian declarations only, selected by the kind recorded at purchase. The product stays. Code change confirmed. Gate, inside the D2 build

- The D2 build records, on the order and on the checkout record, which declaration was made (adult or guardian) and the wording version, beside the time and the Terms version. The server sets the kind from what it holds when checkout starts: guardian when it holds a confirmed under-18 record, adult otherwise. The client does not choose it.
- The deletion copy keeps a purchase only when its kind is guardian. A record with a declaration time and no kind was written before the D2 build, when only under-18 accounts wrote one, so it counts as guardian.
- The copy holds: time, Terms version, wording version, payment reference, product. The product stays, because without it the record cannot show which purchase was approved.
- The kind is fixed at purchase. A student who later turns 18 keeps earlier guardian copies. Later adult purchases are never copied.

**Reason.** The texts promise guardian declarations only (Teen Notice "Guardian evidence", Privacy Policy "Account payment records"). Check 2 shows the code would break that promise on the day D2 ships. An adult declaration kept ten years after deletion has no basis under Section 13(f).

**Tests, failing first.** An adult declaration on an account that has guardian evidence is not copied. An adult account with no evidence leaves nothing. A guardian declaration is copied with the five fields. A legacy record with no kind is copied.

**Text lane.** Add the wording version to the field list in the Teen Notice "Guardian evidence" bullet. The product is already listed there.

**Size.** 0.25 day inside T10. It ships with D2, before opening.

### R3. Question reports: deleted within 90 days of receipt, by a Firestore TTL policy. No scheduled job. Gate, inside PR #86

- Each report is written with `expireAt`, 85 days after the server receives it. A TTL policy on `questionReports.expireAt` removes it. The published period is "within 90 days of receipt". The five days cover the TTL delay: Firestore removes an expired document usually within a day and does not promise a time (check 10; the worker confirms it in Google's documentation).
- Account deletion still removes reports sooner, as built.
- No deletion at "review end" at launch. No review tool exists, so that promise would be untrue. The text lane drops Sol High's clause "when we finish reviewing them".
- A fix made from a report is recorded with the question ID and what changed. It never holds the message or the account ID.
- The report counts stay with the account, as built and as the texts say.

**Reason.** 90 days is the longest period Sol High would defend, and it is enough: a report on a question is useful for weeks, not years, and question versions change. A TTL policy is the D7 pattern, adds no scheduler job (rule 7, check 6), and its deletes are ordinary document deletes. The period is ruled here under the delegation. It appears in texts he signs, so he can change the number at sign-off.

**Conditions.**

1. The change goes into PR #86 before it merges, so no report is ever stored without an expiry (check 5). A test fails if a stored report lacks `expireAt`.
2. `firestore.indexes.json` gains the policy in the same form as the two that exist. Deploy it to prod and staging.
3. Rule 7: count the TTL deletes against the free tier. They cannot exceed the report writes, which are capped at 20 per account per day.
4. Staging reports written before this change have no expiry. Delete them once, counted.
5. An unread report is lost after 90 days. The manager adds "read question reports" to the monthly cost check.
6. Ship before opening. After opening, a retention change needs the rule 9 email.

**Text lane.** Replace the bracket in both notices with the period, and keep "sooner if the account is deleted".

**Size.** 0.25 day.

### R4. Report form: no separate privacy line and no link. One instruction is required, folded into the line the form already has. Gate, with the report form

- Not required: a privacy line beside the button, or a "See how we use reports" link. The Privacy Policy and the Notice for teens name question reports, their use, their period and the rights. A student has them before the first report, which is what Section 16 asks.
- Required: the form tells the student to leave out personal details, in every state where the field accepts text. It replaces words. It adds no line and no control.
- Suggested, for the lead to settle under rule 4: the line under the title becomes "Tell us what's wrong. Leave out personal details." That is eight words where the form has ten today. The "reported before" state carries the same instruction in its own line. The hint and the buttons stay as built.

**Reason.** The message is free text, and Pantas has no legal basis to keep sensitive details a student types into it. Sol High moved the warning out of the notices and onto the form, so the form is now the only place that says it. That one instruction does real work. The link does not: NPC Advisory 2024-03 recommends a short notice at the point of collection for children, but it is guidance, the layered notice already exists, and no approved report board draws a link. His guidance is to compress text.

**The honest limit.** Sol High asked for the link. Leaving it out is a small accepted risk for accounts aged 13 to 17. Review it when under-13 accounts ship (E-124), where child-oriented notice weighs more.

**Conditions.** UI strings go to Claude workers (T4). The copy sits inside an approved layout, so it needs no new board (rule 4). The lead records the final wording and tells him.

**Size.** 0.1 day.

### R5. Checkout: the Terms open without ticking the box. Confirmed, already built. No separate "Payment help" link. Gate, inside the D2 and D3 build

- Confirmed. Both declaration wordings keep the behavior the guardian box has today (check 7): "Terms and refund policy" is a link inside the label, a tap on it opens the Terms, and the box does not change. The link takes keyboard focus by itself, and Enter opens it.
- A test fails if a tap on the link ticks the box or enables Pay.
- The link opens the Terms at the refund section if the in-app Terms page can open at a section with about an hour of work. Otherwise it opens at the top. This part is not a gate.
- No separate "Payment help" link. The seller line beside Pay already shows support@pantas.study (D3). Make that address a link that opens an email. One line serves both duties.

**Reason.** A buyer who must tick before reading has not been shown the terms, which weakens the assent the tick records (RA 8792 Section 16) and the D2 evidence with it. The behavior exists, so the cost is a test. A second support link repeats the seller line.

**Size.** No added size. It is part of the D2 and D3 build in T10.

### R6. Guardian evidence period: ten years stays for confirmations, withdrawals and guardian purchase declarations. Evidence that holds only declines drops to four years. Gate

- Evidence with a confirmation, a withdrawal or a guardian purchase declaration: 3,653 days from its newest record, once the account is gone. Unchanged.
- Evidence that holds only declines, with no confirmation, withdrawal or purchase: 1,461 days from its newest record, once the account is gone.
- Adult declarations never enter the evidence (R2).
- No legal-hold exception. The cleanup cannot honor one, so the text lane removes the bracket.
- This closes the question left open under D1 ("Later, not ruled").

**Reason.** Sol High is right that Article 1391 does not say "ten years". The period is still defensible for a contract record, for two reasons the text does not give today. First, Article 1391 gives four years from the day guardianship ends. The youngest account is 13, and the server never learns the age (check 4), so the only safe period is the worst case: five years to 18, then four more, nine years in all. Second, an action on a written contract prescribes in ten years (Article 1144). A decline creates no contract. Its record defends only a claim that Pantas kept using a minor's data after a guardian said no, and such a claim prescribes in four years (Article 1146; Article 1108 lets time run against a minor who has a guardian). Ten years for a decline cannot pass the "necessary" test.

**The honest limit.** No Philippine ruling fixes either period. The numbers are ruled under the delegation, and he can change them at sign-off.

**Conditions.**

1. The evidence cleanup picks the period from what the evidence holds. Tests fail first on a decline-only record at four years.
2. Ship before opening, for the rule 9 reason in D1. Nothing can be deleted by this change for four years, so it changes nothing a user sees.
3. Under-13 accounts (E-124) need their own ruling on this period before they ship. For an account younger than 12, the Article 1391 worst case passes ten years.

**Text lane.** In the Teen Notice "Guardian evidence" bullet: state both periods and their starting event, and replace the reason sentence with the two reasons above. Sol High critiques it in round 3 and confirms Articles 1108, 1144, 1146 and 1391.

**Size.** 0.25 day.

### R7. D1 text pass: confirmed. The text lane rewrites the Teen Notice flag paragraphs. Already ruled, D1 condition 4. Gate for publishing

Not re-ruled. D1 condition 4 and item 1 of "Text changes these rulings need" above already order it. Round 2 did not do it (README round 2, item 8). The paragraphs, on a989972e3:

1. "Why we ask your age": "We keep the under-18 group until your account is updated to 18 or older, or your account is deleted."
2. "How long we keep data": "Your under-18 group remains until your account is updated to 18 or older, or your account is deleted."
3. The basis bullet "Under-18 group record and guardian evidence": "We rely on this basis before your guardian answers, including if they decline or do not answer." After D1, the record exists only while a request is open and after a guardian confirms.
4. `change-summary.md`, "Notice for teens", the "Age check" bullet, and "Weakest point is still the age flag" under "Things you should know".

The new text says the whole record is deleted when a request expires, and seven days after a decline. The guardian's own answer record stays as evidence (R6). Sol High critiques the changed paragraphs in round 3 (rule 5). The texts publish only after the D1 build is on prod.

**Size.** 1 to 2 hours of text and critique, already counted in D1.

### R8. Added while ruling: abandoned checkout attempts keep today's rule at launch. The wording version is stored now. Not a gate

README round 2, item 3, was not in the request but is open. The wording version is stored in the D2 build (R2). A shorter life for an unpaid attempt waits: expiring order records touches the payment path in the launch window, and a paid order deleted by mistake would lose the evidence D2 exists to keep (check 9). The texts already say checkout declarations stay "while your account exists", which is true. Trigger: the first release after launch, with D6 option B, in one rule 9 email. Size then: 0.5 day.

### Summary

| Item | Ruling | Size | Launch |
|---|---|---|---|
| R1 | No guardian order approval at launch. D2 record plus account confirmation stand. Runbook: refund a guardian-denied purchase without contest | 0.1 day, no code. Later 3 to 4 days | Not a gate |
| R2 | Deletion copy keeps guardian declarations only, by the kind recorded at purchase. Product and wording version kept | 0.25 day in T10 | Gate |
| R3 | Reports deleted within 90 days of receipt. TTL policy on `expireAt`, set 85 days after receipt. No job | 0.25 day in PR #86 | Gate |
| R4 | No privacy line or link on the report form. "Leave out personal details" folded into the existing line | 0.1 day in T4 | Gate |
| R5 | Terms open without ticking, already built, kept with a test. Support address in the seller line is a link. No "Payment help" link | No added size | Gate |
| R6 | Ten years for confirmations, withdrawals, guardian purchases. Four years for decline-only evidence. No legal hold | 0.25 day | Gate |
| R7 | Text lane rewrites the Teen Notice flag paragraphs (D1 condition 4) | Counted in D1 | Gate for publishing |
| R8 | Abandoned attempts unchanged at launch. Wording version stored now | None now | Later |

Gate work added by this section: about 1 day of lane time. No new board. No new scheduled job.

### Build items (for the CSE release lead)

1. T10, D2 build: record the declaration kind (set by the server) and the wording version on the order and the checkout record (R2).
2. T10, deletion: the evidence copy keeps guardian declarations only, legacy records with no kind count as guardian, and the copy adds the wording version. Four tests, failing first (R2).
3. T2, PR #86, before merge: `expireAt` at receipt plus 85 days, the TTL policy, the test, the free-tier count, the one-time staging cleanup (R3).
4. T4, report form: the "leave out personal details" instruction in every state where the field accepts text. No link, no new line (R4).
5. T10, D2 and D3 UI: keep the Terms link behavior for both wordings, add the test, open at the refund section if cheap, make the support address in the seller line a link (R5).
6. Evidence cleanup: four years for decline-only evidence, tests failing first (R6).
7. `docs/OPERATIONS.md`: the guardian-denied purchase line (R1). The manager adds "read question reports" to the monthly cost check (R3).

### Text changes these rulings need (for the legal lane, rule 5)

1. Report period in both notices: "within 90 days of receipt", sooner on account deletion. Drop any "when we finish reviewing" clause (R3).
2. Teen Notice "Guardian evidence": both periods, the corrected reason, the wording version in the field list, no legal-hold bracket (R2, R6).
3. Teen Notice flag paragraphs and `change-summary.md` (R7).
4. Recheck that no sentence states the buyer is the guardian as fact (R1).
5. Sol High critique, round 3, on the changed paragraphs through `codex-pick`, including Articles 1108, 1144, 1146 and 1391.

### What needs Aedwon

Nothing new to decide. Three numbers appear in the texts he signs, and he can change them at sign-off: 90 days for reports (R3), ten years and four years for guardian evidence (R6). The refund default in R1 is his to change.

### Corrections found while ruling

- README round 2, item 5, places the report string "beside Send". The built form's button reads Save (check 8).
- Sol High's proposed report sentence promises deletion "when we finish reviewing them". No review step deletes anything (R3).
- The Teen Notice gives one reason for ten years, "four years after that person turns 18". That reason alone gives nine years at most and does not cover a decline (R6).
- The D1 entry left the decline period "Later, not ruled". R6 rules it.
