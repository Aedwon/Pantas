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

## Nov 23, lesson reader full screen on wide web (UX design lead)

Brief: the operations manager, for Aedwon (away, decisions delegated). His words, Nov 23: "I trust you, please do not disappoint me. be ambitious with the UI/UX for it to deliver the best experience in its category" and "in the full screen for lesson view, you might want to hide completely the sections on the left, and use the entire width. you can also reposition some figures, like say, illustrations, to be on a separate column at the right immediately to its connected line of explanatory text. this is just an idea though. you could have better ideas. hill climb on this". Standing: "i do not like wordy UI. if you can compress text, do it. I like clean, intuitive, elegant, and satisfying (in terms of motion and animations) UI/UX".

Canvas: "Lesson Reader Full Screen", https://claude.ai/artifact/Sb3f8m64ZpouMDBKjTE14K, built from the approved Lesson Reader Polish option C component and stylesheet and the RD_ boards (rule 3). New standards sheets written first: `long-form-reading.md` and `instructional-design.md` in the agent-standards library.

Directions offered (real lesson: Circles, two Core Concept figures, Example 1 closed, Example 4 open):
1. Margin (his idea as stated): outline gone, 640 px text, figures in a 400 px right column level with their paragraph; they scroll with the text. Page 3,612 px against 5,186 px for one column (30% shorter).
2. Pinned: one sticky figure stage on the right that swaps to the figure of the passage being read.
3. Column: the approved reader without the outline, one centered 680 px column (smallest change).
4. Held: as 1, but each figure stays in view while its passage is on screen, and the passage end pushes it away.

Council (Gemini 4 Neon High through agy, Fable 5.2 high; Fable final on a split):
- Round 1: both chose 4. Scores (clarity, focus, readability, elegance, motion): Gemini 9/9/9/9/9, Fable 9/9/9/8/9. Rejected: 1 loses the figure while the solution steps still use it; 2 keeps stale figures beside unrelated sections; 3 leaves about 760 px empty and ignores his guidance.
- Round 2 changes from both: example figures sit in their own card; the hold ends at the passage end; the sticky line follows the top bar (92 px, 32 px); gutter 56 px; linked words (figure labels named in the text) light their part; the solution figure replaces the problem figure in place and its new mark draws in; section segments in the progress line; the approved expand button back on plates.
- Round 3 changes from both: highlight by emphasis (the part keeps its own color, thickens; the rest dims to 35%) instead of turning teal, which broke the figure's color code; the push-off fade removed; close figures stack (option b) instead of going inline; lessons with no figures keep the centered column; tap and keyboard for linked words and section segments.
- Round 4 (both): keep every figure inside its own passage. Then both: raise a plate within its block before adding white space. Fable: "Apply it and ship. It does not need another round." Gemini found no other clear improvement.

Real-content check (A4): seven lessons with the most text, figures, tables and math (triangles, basic geometric concepts, circles, Earth's motions, truth tables, systems of equations, quantum numbers), KaTeX math, windows 650 to 900 px tall, solutions open and closed, five runs. Final run: no overlap, no overflow (widest table 558 px in the 640 px column), no figure beside the wrong passage, no inline fallback, one 18 px push, at most 59 px of added white space under one passage. Not covered: real figure proportions (placeholders were 288 and 300 px tall); the build's acceptance check 3 repeats the run with real figures.

Ruling: 4 Held, with the placement rules and motion values in `docs/superpowers/specs/2026-11-23-lesson-reader-full-screen-design.md`. Phone unchanged. W4_Held is marked council-approved on the canvas.

Schema check (manager, Nov 23): the linked words use the existing `labels` in lesson FIGURE specs only. 70 of 241 lesson figures have at least one label named in their own passage (160 of 453 labels); elsewhere the text stays plain.

Risk named by Fable: Flutter web has no CSS sticky. The hold must be driven in layout or paint in the same frame as the scroll. If it cannot be made smooth, ship direction 1 (figures at rest) and report it; never direction 2.

## Nov 23, core loops polish (UX design lead)

Brief (operations manager, for Aedwon): the 5 to 8 changes with the most impact on lesson, quiz, mock, results and review; boards in Claude Design; the same council; approved motion untouched unless improved; reduced motion respected.

Shortlist and the schema check. The first list had try-first choices in lesson examples and linked words in question figures. The manager asked for a content check against HANDOFF.md ("Never add features that need content the schema doesn't have"). Counted: 38 of 629 lesson examples list choices, none has a structured correct answer and only 15 state the letter in parseable text; 193 questions have a figureSpec and none has text labels. Both dropped. A lesson sheet from "From the lesson" was also dropped before boards: Aedwon left that link out on Nov 5. Replacements use existing fields only.

Canvas: "Core Loops Best in Class", https://claude.ai/artifact/1tyuTs3m832KjUtgZdvzXZ (built from W_Question, W_QRight, W_QMiss, W_SessionEnd, W_QuizTab, W_MockResults and the phone QV_, QZ_ and MK_ boards).

Council (Gemini 4 Neon High, Fable 5.2 high):
- Round 1: both kept all five. B1 needed fixes (white wipe, square corners). Ranks: Fable B2, B4, B3, B5, B1; Gemini B4, B2, B3, B5, B1. Split on B3 timing: Gemini wanted the reveal at 300 ms with no pause; Fable kept the 120 ms pause. Fable's call stands.
- Round 2: both found all five right; fixes were spec and board mismatches only (B1 reverse timing, the B2 end timing wording, two stale boards). During round 1 fixes the board worker shortened the approved 1.4 s ring fill to 480 ms to meet a 1.2 s target; the lead restored 1.4 s (rule 2) and moved the target to the marks.
- Round 3: Gemini "No clear improvement"; Fable confirmed, with two spec clarifications for sessions over 20 questions and the Done button, now in the spec.

Ruling: build B2, B4, B3, B5, B1 in that order per `docs/superpowers/specs/2026-11-23-core-loops-polish-design.md`. Copy in B5 settled by the lead under D191: the two bar hints removed; "Tell Pantas why you got each one wrong. The better your notes, the more every review helps." becomes "Note why you missed each one." in the session end and the mock review; "Finish the Notes" stays (July 27 choice).

Process note: the board worker hit the Claude 5-hour limit mid-task (Nov 23, about 7:25 PM to 9:40 PM Manila) and was resumed after the reset; no work was lost.

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

## PAY-06: a web plan bought while holding a pass for another exam (Fable 5.2 High, Nov 23, 2026)

Asked by the security and billing lead (r2) under Aedwon's delegation (written rule 4), from the M4 money-path audit
(finding PAY-06, confirmed in code: `planGrant` queues a tier-wide plan behind any active grant of the same or higher
tier, including a pass for a different exam). Lead recommendation: option A. Ruling, verbatim:

"PAY-06 ruling (Fable 5.2, under Aedwon's delegation, Nov 23, 2026): Option A, widened to all exam-only coverage.
A tier-wide plan queues only behind live tier-wide coverage of the same or a higher tier: web plans, the trial, store
subscriptions and promotional entitlements. Exam-only coverage (web or store passes, beta and beta reward grants) never
delays it. Reason: C1 item 4 (docs/superpowers/plans/pwa-launch/C1-C10-ruling.md, Oct 19) queues plans 'so buying early
never wastes days'. Behind a pass, the queue withholds paid access instead. B fails because a pass never unlocks custom
exams, and the active exam can change after payment. No earlier ruling covers a plan behind a pass; this amends item 4.
Aedwon's Oct 19 refund decision stands. Example: the student pays ₱149. Civil Service Monthly starts at payment and ends
on the same date in March. Subprofessional unlocks at once. The Professional pass stays to Mar 14, 2027. The overlap
earns no credit. Build edges: Apply the same tier-wide test to new purchases, moves after a refund, and re-anchoring
after store or beta changes. The last two still count pass ends today. Pass bought after a queued plan: starts now,
moves nothing. Pass refund: moves nothing. Trial: a same-tier plan bought during it starts at trial end. Plans already
queued behind exam-only coverage, if any exist: start now, same length."

Options offered: A (queue only behind coverage that covers the whole plan), B (queue behind a pass only for the exam the
student studies now), C (keep today's behavior). Built by the security and billing lane in the money-path hardened fixes
(group G2).

## Nov 23, legal round 3 decisions

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent, under Aedwon's delegation. The rulings are final and are not queued for his sign-off. Legal sign-off on the final texts, "ship it", billing purchases and physical steps stay his. This agent wrote no legal text: wording named below goes to the text lane and to Sol High (rule 5). No lawyer reviewed anything here, and this agent is not a lawyer: where the law is unsettled, the entry says so.

- Policy read at `origin/main` 225a7e773: `AGENTS.md`, `docs/workflow/process-improvement.md` (rules 4, 5, 7, 9), the sections "Nov 22, legal package D1 to D8" and "Nov 23, legal round 2 product decisions" above, and `docs/superpowers/plans/2026-11-23-cse-release-phase2-plan.md`.
- Input, on `legal/public-launch-r1` f004784c8: `README.md` section "Needs a product or code decision (round 3)", `critique-2026-11-23b-sol-high.md`, and the three texts.
- Code read: main 225a7e773 (`functions/src/guardianConsent.ts`, `scheduledJobs.ts`, `lib/features/guardian/`, `docs/OPERATIONS.md`), PR #90 `qa/checkout-declaration-r1` 42d423ff5, PR #86 `qa/report-send-r1` 6fb02f70b, `fix/money-path-hardened-r1` 1ebd78528.
- Test used: no risk at release, inside the hardened scope. Texts and behavior lean toward Pantas as far as Philippine law allows. Every published sentence is true on the day it publishes.
- "Gate" means on prod before the beta gate drops and before live payment keys (checklist G2), as in the two sections above.
- Standards applied: Data Privacy Act Sections 3(l), 11(e) and (f), 12(f), 13(a), (b) and (f), 16(b); NPC Advisory Opinion 2017-049 and Advisory 2024-02; Firestore TTL deletion behavior (Google's documentation, as cited in the critique); PayMongo's refund documentation (read Nov 23, page dated Sep 4, 2026); Internet Transactions Act Sections 20, 23 and 24 and Rules of Court Rule 21 (as cited in the critique); RA 10175 Section 13 (cited from memory, for the round 4 critique to confirm). No sheet exists in `agent-standards` for privacy or consumer law.
- Velocity: this ruling pass was not timed. It changed documents only. Sizes are estimates for one lane with tests.
- Items are numbered H1 to H6, in the order of the README round 3 list.

### What was checked

1. **D1 is planned and not built.** The Phase 2 plan lists it in T10 ("D1 under-18 record deletion (server)"). On main, the cleanup still trims an expired or declined request to the flag (`guardianConsent.ts:582-585`). PR #90 carries D2, D3, R2, R5 and R6 only: it changes `paymongoCheckout.ts`, `deleteUserData.ts` and `purgeInactiveAccounts.ts`, and does not touch `guardianConsent.ts` or `webTrial.ts`. So D1 and D7 are built on no CSE release branch. Only the under-13 branches change those files, for another purpose.
2. **After D2, nothing reads an unconfirmed request except the guardian flow.** PR #90 picks the guardian wording only when the record is confirmed (`paymongoCheckout.ts:63-64` on the PR). The Firestore rules read the record only for `withdrawn`.
3. **A declined request does nothing for seven days.** The student's waiting page shows a declined request and an expired one the same way: resend or change the email (`guardian_waiting_page.dart:15-16`). The seven-day wait is only the time the cleanup already used.
4. **A guardian page link outlives the request.** Each request email carries a manage link stored against the account with no expiry (`guardianConsent.ts:245-247`). The cleanup skips open manage links (`:551-552`). After D1 deletes the request, that row still ties the account to a guardian request. Used and revoked answer links also hold the account ID for seven more days (`:553-563`).
5. **The hourly guardian cleanup reads every server-side document of every account.** It scans the whole `server` collection group, about ten document kinds per account, 24 times a day (`guardianConsent.ts:566`). Counted from the code and not measured: about 200 accounts would pass the 50,000 free daily reads from this task alone.
6. **Reports already expire.** PR #86 writes `expireAt` at 85 days and adds the TTL policy (`questionReports.ts:36`, `148`; `firestore.indexes.json:151`). TTL fields have their single-field index switched off, so a query on `expireAt` cannot run.
7. **Scheduled tasks are free, jobs are not.** Prod runs nine tasks from three scheduler jobs. The free limit counts jobs (`scheduledJobs.ts:14-18`).
8. **A manual refund path exists.** `docs/OPERATIONS.md`, "Manual QR Ph refund": a bank transfer, then a command that records the refund through the webhook's own refund logic, so access changes correctly. It was tested by hand on staging on Nov 9. It takes any `pay_` ID, so it is not limited to QR Ph. No automated test covers it. The money-path fixes change the webhook and the grant logic (`fix/money-path-hardened-r1`).
9. **PayMongo's refund windows.** Card 60 days, QR Ph 30 days, GCash 180 days, GrabPay 90 days, Maya 12 months. The page says QR Ph refunds work from the dashboard and the API. The Nov 9 test-mode run refused them. The live answer comes from the QR Ph payment already planned (D4, option C). The page does not say what happens after a window closes.
10. Not checked: live merchant settings, what PayMongo's payment record shows about a QR Ph payer, console settings, and the number of documents per account on prod.

### H1. The under-18 flag before a guardian confirms: D1's design stands. The text change is as far as wording can go. Three tightenings join the D1 build. Gate

- The flow and the timing of the first write do not change. A teen sends the request, and the server records it.
- "Do not store the flag until a guardian confirms" is rejected. Moving the label to the confirmation would be cosmetic: an open guardian request tied to an account says the same thing as the label. A design that keeps nothing on the server before the answer (a signed link that carries the account) would still process the same fact to send the email, would lose "only the newest link works", and is a two to three day rewrite of a security flow in the launch window.
- The one design that removes the problem is guardian-first sign-up. Aedwon declined it on Nov 11, knowing the flow was "legally shaky, but it isn't clearly unlawful". That decision stands and is not re-ruled.

**Tightenings, inside the D1 build.**

1. **Decline deletes at once.** When a guardian declines, the request record is deleted in the same write that records the answer, not seven days later. The decline stays in the guardian evidence (R6). The student then sees the contact form, the state a trimmed request already gives today, so no new screen state exists.
2. **Nothing else ties the account to the request afterwards.** When a request is deleted (expiry or decline), its guardian page links are deleted with it, and its used or revoked answer links lose the account ID. Test: after a decline or an expiry, the only record that links the account to a guardian request is a decline answer in the evidence. Short-lived rate-limit counters are outside this test.
3. **The one-time removal (D1 condition 2) covers the same records** for accounts with no confirmed guardian: flag-only records, declined requests still waiting, and their links. Count it against the free tier first (rule 7).

**Reason.** Sol High is right that wording cannot supply a basis, and right that the wait after a decline has none. The open request cannot be designed away without changing who starts sign-up. What can be made true is that the record does one job, asking the guardian, for seven days at most, and leaves nothing behind. Check 2 makes the first part true once PR #90 ships. Checks 3 and 4 show the second part is not true yet, even after D1 as ruled.

**The honest limit.** The first write still happens before a guardian answers. No Philippine ruling decides it. This is the residual risk Aedwon accepted on Nov 11, now smaller. It is not a new decision for him.

**Text lane.**

1. Teen Notice: a declined request is deleted when the answer is recorded. Change the two timing paragraphs ("If the request expires..." and the retention paragraph).
2. The basis bullet states the purpose limit: the open request is used only to ask the guardian and record the answer.
3. Round 4 question for Sol High: which basis best fits the open request. Test Section 13(b) with the NPC's guardian-permission requirement (Advisory Opinion 2017-049) against Section 13(f). If neither holds, the notice says what Pantas does and why, and claims no more than Sol High will support.

**Side finding, rule 7 (check 5).** The D1 build changes this cleanup. The lead measures its daily reads on prod before the build. If the count confirms check 5, the same change makes the cleanup read only guardian records that are due. This is a rule 7 defect, not a legal item.

**Size.** D1 stays about 0.5 day. The tightenings add about 0.25 day. The scan fix, if confirmed, adds about 0.25 day. Owner: the CSE release lead (T10). Text: the text lane, 1 hour plus the critique.

### H2. The 90-day report period: the ruled words stay. A daily sweep makes them a hard maximum. Gate, inside PR #86

- "Within 90 days of receipt" stays in both notices. Sol High's "scheduled to expire, deletion can take longer" is not used: it is always true, but it gives no maximum, and a retention period with no end is the weaker statement under Section 11(e) and (f).
- The design changes by one piece. The 85-day TTL stays. An existing daily job gains one task that deletes any report older than 86 days that TTL has not yet removed. It is a task inside a job that already runs, so it adds no scheduler job (check 7).
- The task finds reports by their receipt time, because the expiry field cannot be queried (check 6). It reads only overdue reports, normally none, so its cost is about one read a day. The lead counts it (rule 7).
- A test fails if a report older than 86 days survives one run.

**Reason.** A hard promise on a best-effort mechanism can become untrue with no fault of ours. Five days of margin makes that unlikely, not impossible. The sweep costs about a quarter day and makes the stronger sentence true.

**Rule for other periods.** A published "within N days" needs a sweep behind the TTL. A period that rests on TTL alone is worded as a schedule. D7's trial codes rest on TTL alone, so the text lane words the 730 days as a schedule when D7 ships. Guardian evidence already uses "schedule for deletion" and is removed by a job.

**Size.** About 0.25 day. Owner: the CSE release lead (T2, PR #86). No text change.

### H3. Guardian identity wording, "said they are": confirmed. No build. Gate for publishing only

The texts say the copy is made where the buyer "said they are" a parent or legal guardian. That is exactly what the record can prove. R2 is unchanged: the server sets the kind, and the deletion copy selects by that kind. The Teen Notice already says the tick is a declaration and does not prove who ticked. No sentence may state as fact that the buyer is the guardian (R1, condition 1).

**Size.** None. Owner: the text lane, already applied.

### H4. Preservation orders: a runbook step is needed. No code, no hold in the cleanup. Gate, documents only

- The cleanup keeps no hold switch. R6 stands.
- `docs/OPERATIONS.md` gains a short procedure, "A binding order to keep records":
  1. Log when the order arrived, who issued it, and which accounts and records it names.
  2. The same day, copy the named records to a private folder outside the app and outside git, as in D8. The fastest clocks are an open guardian request (seven days at most), a question report (85 days) and an account deletion already under way.
  3. Never pause a cleanup job or a TTL policy. That would break the published periods for every user.
  4. Keep the copy only as long as the order requires. Then delete it and log the date.
  5. If the order requires the live record itself to stay in place, he gets legal advice before the next cleanup run. This is the one place where "no lawyer" (L8) cannot hold.
- The procedure names the record paths for each kind, so a copy takes minutes.

**Reason.** A binding order outranks the notice, and Sol High is right that no wording cures a system that cannot comply. A copy made by hand complies without a hold mechanism, and such an order is rare for a study app. The published sentence must then allow it: today both notices say the schedules for guardian evidence and question reports have no exception, which the procedure would make untrue.

**Text lane.** In both notices, the general retention sentence allows one exception for those two kinds: a copy kept under a binding order from a court or authority, for as long as the order requires. Sol High critiques it in round 4 and confirms RA 10175 Section 13.

**Size.** 0.1 day for the procedure. Owner: the CSE release lead writes it. Text: the text lane.

### H5. Pre-build claims: the publish gate is confirmed. Gate

The texts publish in the same prod release as the behavior they describe, or after it. Never before. Each sentence below is checked live on prod, and the check is logged in the launch log, before step 2 of the README publishing steps.

| Claim in the texts | Build that makes it true | State on Nov 23 |
|---|---|---|
| A tick on every web purchase; the declaration, time, Terms version and wording version recorded; the Terms open without ticking; the seller line | D2, D3, R2, R5 (PR #90) | Draft PR |
| Only guardian declarations copied at deletion; ten years and four years for evidence; sharing permission records deleted 1,461 days after the account's deletion and never the newest record | R2, R6, legal round 5 (PR #90) | Draft PR |
| A failed request is deleted whole; a decline is deleted at once | D1 with H1 | Not built |
| An unconfirmed account that says it is 18 leaves no evidence row (the `became_adult` row is kept only where a guardian confirmed) | Nov 24 became_adult ruling, code items 1 to 3 (added Nov 24) | Not built |
| Reports deleted within 90 days of receipt | R3 (PR #86) with H2 | Draft PR; sweep not built |
| The trial code period | D7 | Not built. The texts say "no scheduled expiry" until it ships |
| A refund route when PayMongo's route is closed | H6 | Path exists; runbook and test not done |
| Seller details in the website footer | D3 | Not built |

- If a build slips, its sentence is not published as written. The launch waits, because every row is already a gate. The other path is that the text lane rewrites that sentence to the built state and Sol High critiques it again.
- Sol High's weaker replacement for the checkout sentence is not needed, because the build is a gate.

**Reason.** A notice that describes behavior the app lacks is a false statement on the day it publishes, which is the one thing the test forbids.

**Size.** No build. Owner: the CSE release lead holds the gate and runs the live checks. The text lane adds the table to the README publishing steps.

### H6. The refund route after PayMongo's window closes: a transfer by hand to the payer, then the refund command, then a record. Gate

One route for every payment method. The existing "Manual QR Ph refund" procedure is widened, not replaced. No new code.

1. **PayMongo first.** While PayMongo's own refund works for the payment (check 9), use it. The money returns to the payer by itself and the webhook changes access.
2. **Otherwise a transfer by hand,** when PayMongo refuses the refund or its window has closed. Bank transfer by default. An e-wallet transfer is allowed when the payer has no bank account.
3. **The money goes to the payer only.** The receiving account's name matches the payer on PayMongo's payment record. If the record shows no usable name, the claimant sends the payer's own bank or wallet receipt for that payment, and the transfer goes to that payer. This identifies the payment. It does not ask a guardian to prove the denial, so "without contest" holds. Never transfer to an account named only in an email.
4. **Card payments: check for a dispute first.** If a bank dispute is open, do not transfer: the dispute returns the money, and Pantas accepts it. If a dispute arrives after a transfer, contest it with the transfer proof, because the money was already returned.
5. **The full amount.** Pantas pays the transfer fee.
6. **Run the refund command** so access ends and the refund is on the account's records. If the account is already deleted, skip the command and find the payment by its PayMongo reference (D4, D8).
7. **Record it** with the business's refund records outside the app (D8): date, account ID or public ID, `pay_` ID, amount, route and reference, how the payer was matched, the command label, the reason. His books carry the matching refund entry.

**Reason.** The Terms promise a full refund with no deadline for a purchase a guardian denies. PayMongo's windows are 30 days for QR Ph and 60 for cards, so the promise needs a route that does not depend on them from the first day of live payments. The route exists and was tested for QR Ph (check 8). The gaps are that it is written for one method, has no recipient rule, and has no automated test while the money-path fixes change the code under it.

**Server item, for the security and billing lead.** One emulator test of the documented command against the webhook, on the money-path fixes: a card payment and a QR Ph payment; a pass that has ended; a plan with a queued plan behind it; a payment PayMongo already refunded in part (the amounts add up, nothing is counted twice); and a payment with a live dispute. The same label sent twice changes nothing. If any case fails, that is a money-path defect to fix before live keys.

**His step, already planned.** The live QR Ph payment and refund (D4, option C, in M3 and M6) also records what PayMongo shows about the payer, because rule 3 depends on it.

**Text lane.** The Terms sentence about a bank transfer "with the verified payer" sits under the QR Ph bullet. Widen it to any payment whose original route is closed. Sol High critiques it in round 4.

**Size.** 0.25 day for the runbook (CSE release lead). 0.25 day for the test (security and billing lead). Text: the text lane.

### Summary

| Item | Ruling | Size | Launch | Owner |
|---|---|---|---|---|
| H1 | D1's design stands. Decline deletes at once, links go with the request, the one-time removal covers them. No "flag at confirmation" change | D1 0.5 day, plus 0.25; scan fix 0.25 if confirmed | Gate | CSE release lead (T10); text lane |
| H2 | "Within 90 days of receipt" stays. A daily sweep in an existing job backs the 85-day TTL | 0.25 day in PR #86 | Gate | CSE release lead (T2) |
| H3 | "Said they are" confirmed | None | Gate for publishing only | Text lane, done |
| H4 | Runbook procedure for a binding order: copy by hand, never pause cleanup. The notices allow that one exception | 0.1 day, no code | Gate, documents only | CSE release lead; text lane |
| H5 | Texts publish with or after the builds, each claim checked live on prod | No build | Gate | CSE release lead; text lane |
| H6 | PayMongo first; otherwise a transfer by hand to the payer, the refund command, a record | 0.25 day runbook, 0.25 day test | Gate | CSE release lead; security and billing lead; text lane |

Gate work added by this section: about 1 day of lane time, or 1.25 if the scan fix is confirmed. No new board. No new scheduler job.

### Build items (for the CSE release lead)

1. T10, D1 (not built on any branch): build it as ruled on Nov 22, with H1's three tightenings. Tests fail first on the old trim, on the seven-day wait after a decline, and on a link row that survives the request.
2. T10, D1: measure the hourly guardian cleanup's daily reads on prod before the build. If it reads every `server` document, make it read only due guardian records in the same change (rule 7).
3. T10, D7 (not built on any branch): unchanged from Nov 22.
4. T2, PR #86, before merge: the daily sweep task for reports older than 86 days, in an existing job, with its test and its free-tier count (H2).
5. `docs/OPERATIONS.md`: the procedure "A binding order to keep records" (H4).
6. `docs/OPERATIONS.md`: widen "Manual QR Ph refund" to every method, with H6's seven steps.
7. Publish gate: hold the texts until each row of the H5 table is checked live on prod and logged.

### Server item (for the security and billing lead)

1. The emulator test of the manual refund command on the money-path fixes, with the cases in H6.

### Text changes these rulings need (for the legal lane, rule 5)

1. Teen Notice: decline deleted at once; the purpose limit in the basis bullet (H1).
2. Both notices: the binding-order exception in the general retention sentence (H4).
3. Terms: the transfer sentence covers any payment whose original route is closed (H6).
4. The trial code period worded as a schedule when D7 ships (H2).
5. README publishing steps: the H5 table.
6. Sol High critique, round 4, on the changed paragraphs through `codex-pick`, including the basis for the open request (H1) and RA 10175 Section 13 (H4).

### What needs Aedwon

Nothing new to decide. For his information: the risk he accepted on Nov 11 (H1) remains, smaller. H4 step 5 is the one case that would need a lawyer. The transfers in H6 are his to send.

### Corrections found while ruling

- The Phase 2 plan lists D1 and D7 in T10, but PR #90, the T10 pull request, builds neither (check 1).
- D1 ruled that an expired or declined request is "deleted whole". Guardian page links and used answer links would have survived it (check 4).
- D1 kept the seven-day wait after a decline as "the times cleanup already uses". The wait serves no screen and has no basis (check 3).
- The Nov 9 test-mode finding that QR Ph cannot be refunded through PayMongo conflicts with PayMongo's current documentation (check 9). The live test decides.
- The runbook's manual refund section is titled for QR Ph but works for any payment (check 8).

## Nov 23, under-18 flag risk: options for Aedwon

Framed by a Claude Fable 5.2 agent, acting as the design sub-agent. **This is not a ruling.** It is a legal risk acceptance, so the choice is Aedwon's. H1 above stays in force until he chooses. No lawyer reviewed anything here (his Nov 9 decision, checklist row L8), and this agent is not a lawyer.

- Why it returns to him. On Nov 11 he kept the flow ("legally shaky, but it isn't clearly unlawful ... nor would I want to design a fundamentally worse UX for users", `LL:3131-3136`). On Nov 23 he set the release test: "go hardened. i do not want any risks when I release this app." and "i want to be fully ready before i post a single thing leading users to the app". The same day Sol High rated this item the biggest legal risk in the package. H1 treated the Nov 11 acceptance as still standing. His Nov 23 words are newer, so the acceptance is put to him again.
- Policy read at `origin/main` 5cfe4a0fa: `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, sections D1 and H1 above, `docs/superpowers/plans/2026-11-22-cse-public-release-checklist.md`, `docs/superpowers/plans/2026-11-23-cse-release-phase2-plan.md` (T10, T18).
- Input: `critique-2026-11-23c-sol-high.md` and `README.md` round 4, on `legal/public-launch-r1` 5a50ef3bd. `docs/legal/research/2026-11-11-minor-label-lawful-basis.md`. The under-13 spec on `claude/under-13-build-386afc` (`docs/superpowers/specs/2026-11-17-under-13-accounts-design.md`, draft PR #76).
- Standards applied: Data Privacy Act Sections 3(l), 13 and 25; NPC Advisory Opinion 2017-049 and Advisory 2024-03 (as read in the critique and the Nov 11 research); the CSC age rule (CS Form 100, Revised 2023, through a web search on Nov 23; see check 3); Civil Code Articles 1327 and 1390 (as cited in the Nov 11 research). No sheet exists in `agent-standards` for privacy law.
- Velocity: this pass was not timed. It changed documents only. Every size below is this agent's estimate, not a measurement. Estimates in this area have grown before: the under-13 build went from 2 to 3 days to 8.5 to 10.

### The finding in one paragraph

When a student under 18 sends the guardian request, the server writes "under 18" against the account before the guardian answers (`functions/src/guardianConsent.ts:249`). Age is sensitive personal information (Section 3(l)). Sol High, round 4: no Section 13 ground covers that write. A guardian's later yes cannot cover an earlier write. Section 13(b) and Advisory Opinion 2017-049 do not fit. Section 13(f) fits only the separate answer record. The draft Teen Notice therefore claims no basis for it. Section 25(b) is the exposure: unauthorized processing of sensitive personal information, three to six years and a fine of ₱500,000 to ₱4,000,000 as the Act is written. No Philippine ruling decides this exact design, so the chance of a case is low and not measurable. D1 and H1 shorten the life of the record. They do not supply a basis for the first write.

### What was checked

1. **Only the two CSE exams can be picked at launch.** Checklist row C5: "Only CSE is open to the public. Other exams stay 'Coming soon' or hidden", met on prod, and opening any other exam is his. An exam is selectable only when it is not marked coming soon and its content is on the server (`lib/core/content/data/exam_catalog_repository.dart:39`). The custom exam row is hidden (backlog E6). Main's own catalog file marks the college entrance exams as open, so what prod serves is what holds them closed (`LL:4046`: "CET exams stay 'Coming soon'"). Not checked: the live prod picker. The release lead confirms it on the gate-off build.
2. **A minor can pick CSE today.** The age step comes before the exam picker (`onboarding_flow.dart:130-133`), and the minimum age is 13 for every exam, CSE included (`age_policy.dart:30-33`). A 13 to 17-year-old who gets a guardian's yes continues to the picker and can choose CSE.
3. **The CSC takes CSE applications only from people 18 or older.** CS Form 100 (Revised 2023), as quoted by a web search: "Must be at least 18 years of age on the date of filing of application". News reports of CSC announcements say the same. The CSC site refused direct reads on Nov 23, so the wording was not read on the CSC page itself. The next sittings in the catalog are March 14 and August 8, 2027. A secondary source puts the start of filing for March at November 2, 2026; that date was not confirmed on the CSC site. So the under-18 CSE audience is people who study before their 18th birthday. Nobody under 18 can sit the exam.
4. **A block for an age below the minimum already exists and sends nothing.** The age stays in memory, the device stores only the block, and no server call is made (`onboarding_age_gate_step.dart:243-250`). The blocked page is an approved board (OB_Age_Blocked) and prints the minimum from a variable: "Sorry, this app isn't available for users under 13." The block lasts on that device and only support clears it (`:193`).
5. **Old installed copies can still send a guardian request.** A PWA copy that stays offline keeps its old code (checklist G5). So closing sign-up in the app alone is not enough. The server function that sends the request (`sendGuardianLink`, `guardianConsent.ts:632`) must refuse too.
6. **Under-18 beta testers: one on record.** The beta had 19 testers. One is under 18, and that tester's guardian confirmed in the app (private beta digest; counts only, this repository is public). Not measured: unconfirmed or flag-only guardian records on prod. T18's one-time removal counts them before it runs.
7. **The under-13 build is already guardian-first.** In the approved under-13 spec the parent signs in with their own email and ticks consent before any record of the child exists. The same spec says "The 13 to 17 emailed guardian link stays as it is". That build was sized at 8.5 to 10 working days and is an open draft (PR #76). Its target is the PSHS-NCE pass on sale by mid-December. Besides T18, the under-13 branches are the only work that edits the guardian server file (H1, check 1).
8. **Exams for minors are close behind CSE.** PSHS-NCE is on January 30, 2027, and some takers are 13. The ACET is on January 16, 2027 ("Still his", item 6 above). College entrance takers are mostly 16 to 18.

### The options

"Days" are lane days with tests. "Risk left" is about Section 25 for the under-18 record only.

| | Option | Build | What students lose | Risk left |
|---|---|---|---|---|
| A | Keep the flow, accept the risk again. D1 and H1 ship as ruled (T18) | 0 new days. T18 is about 0.75 to 1 day and is already queued | Nothing | The finding stays whole for every new under-18 sign-up. The record lives seven days at most, but the write has no basis. The notice says so in public by claiming none |
| B | Guardian-first for 13 to 17 before opening: a parent or guardian signs in and gives permission, and only then is the under-18 record written | 4 to 6 days if built on the under-13 parent setup after PR #76 merges. 5 to 8 days if built alone now, and it would edit the same server file as PR #76. Plus boards for his pick, a text round and a Sol High round. Moves the opening by one to two weeks | A teen can no longer start alone and wait for an emailed link. A parent has to act first, and may hold the sign-in. This is the "worse UX" he declined on Nov 11 | The finding is removed for new sign-ups. Left: the guardian is not verified ("said they are"), the age check still runs on the device, and a sign-up flow rebuilt inside the launch window is its own product risk |
| C | Close under-18 sign-up at the CSE opening. Reopen it when B exists | About 1 day: the minimum age becomes 18 so the approved blocked page shows (0.25), the server refuses new guardian requests behind a switch (0.25), handling for devices caught mid-request (0.25), texts and a Sol High round (0.25). T18 still ships | Anyone 13 to 17 cannot create an account at the opening. For CSE that is only people studying ahead of their 18th birthday (check 3). No "tell me when it opens" list: taking a teen's email for that recreates the problem. A blocked 17-year-old who turns 18 emails support to unlock (check 4). UPCAT, the other college tests and 13-year-old PSHS-NCE takers stay shut out until B ships | The finding is removed for new sign-ups: the server writes nothing about an under-18 student. Left: see "What C does not remove" |
| D | Guardian ticks on the teen's own device. No email. The record is written only with the tick | 2 to 3 days, one new board for his pick, a text round | The emailed link, and with it the guardian's own page for managing or withdrawing | The pre-permission write is removed. The proof becomes weaker than today: the teen can tick the box, and no second person or device is involved. If the teen ticked it, Pantas holds an under-18 record with no real permission behind it |

Looked at and dropped. A signed link that keeps nothing on the server before the answer: H1 already rejected it, and Sol High's point is about processing, not storage. A study mode with no account for teens: a build of three days or more, and Pantas would still knowingly process a minor's study records with no guardian. A lawyer's opinion on Section 13(f): his Nov 9 decision stands and is not reopened. A request to the NPC for an advisory opinion: free, but it takes months and cannot decide a launch.

### What C does not remove

No option reaches zero. C is the lowest of the four.

1. **Records already written.** The beta's guardian requests happened. T18 deletes the unconfirmed ones. Deleting ends the holding and cannot undo the write. The scale is small (check 6).
2. **A teen who enters a false age.** Pantas then holds no age information about that person, and the Terms say 18 or older. Every 18-and-over service is in this position. The money side (a minor's purchase can be undone, Civil Code Article 1390) is covered by the adult declaration at checkout (D2), not by this item.
3. **The age check itself on a teen's device.** A teen who answers truthfully has the age checked on the device, and the device keeps the block. Nothing reaches Pantas. The Nov 11 research said an on-device check "reduces exposure, but does not automatically remove the legal question". This is the smallest item. Sol High should rate it in the next round.
4. **Accounts a guardian already confirmed** continue under that guardian's permission (Section 13(a)). Their pages, the guardian wording at checkout and the "I'm 18 now" check stay as built.

### Recommendation: C now, with B as a gate before any exam for under-18 students opens

- His Nov 11 reason was the experience of his users. At a CSE-only opening, the users C turns away cannot sit the only exam on sale. The reason that justified the risk on Nov 11 is mostly absent on opening day.
- C costs about 1 day and adds no board. B costs 4 to 8 days, boards, and one to two weeks of delay, for the same legal result on opening day.
- C is a number and a server switch. It is reversed by one release when B ships.
- A fails his Nov 23 test as he worded it. If he picks A, the record should show that he accepted this risk again with the Section 25 exposure named.
- D trades a risk for weaker evidence. It is not better than today on the day a dispute arrives.

C does not make B optional. PSHS-NCE and the college tests need 13 to 17-year-olds. B should be built on the under-13 parent setup, and it must be on prod before PSHS-NCE opens, or 13-year-old takers are shut out of a pass sold for their exam.

### What needs Aedwon

One choice: A, B, C or D. Nothing is built until he chooses. H1 and T18 proceed unchanged in every case.

### If he chooses C (for the CSE release lead and the text lane; not started)

1. App: the minimum age is 18. The approved blocked page shows with "under 18". No guardian step for new students.
2. Server: `sendGuardianLink` refuses new requests while under-18 sign-up is closed, behind a server switch that is closed on prod. Answers to a request that is already open still work until it ends. Tests fail first.
3. Devices caught between the age step and a guardian's answer: the lead settles the state, with no new board.
4. Confirmed under-18 accounts are untouched. The lead counts them on prod with T18's count (rule 7).
5. Text lane (rule 5): Terms and Privacy Policy say an account needs age 18 or older for now. The Teen Notice covers only accounts a guardian already confirmed, and its open-request paragraphs say new requests are closed. Sol High round 5 critiques the changed paragraphs and rates item 3 of "What C does not remove".
6. Website copy is his. Any line there that invites students under 18 conflicts with C until B ships. Not checked: the website repository.
7. New gate for the checklist: no exam whose takers are under 18 opens before guardian-first sign-up for 13 to 17 is on prod. The under-13 lead is told, because PR #76 changes what the under-13 block does and must leave 13 to 17 closed until B.
8. Reopening later adds collection for new students. The lead checks rule 9 before that release.

### Corrections found while framing

- H1 says "It is not a new decision for him." That was true against his Nov 11 words. It does not hold against his Nov 23 release test, which is newer.
- Checklist row L9 says "CSE is 13+". That is the app's minimum age. The CSC's own minimum for filing is 18 (check 3).
- The manager's Nov 11 advice was "no change during the beta" and option D "before live payments" (`LL:3131-3136`). The beta has ended and live payments are next, so the point he was advised to revisit has arrived.

### C4. Splitting the sign-out guard out of report sending (Fable 5.2 advisor, Nov 24)

- Context: PR #86 (report sending) carried ruling C3's sign-out block for all unsent data. Four Codex rounds each found new must-fix defects where the sign-out and switch sequence meets the sync runtime (`build/audit/codex-t2-r4.md`).
- Advice, taken as the lead's ruling: option 3, check first. Before any teardown (Sync stop, wipe, purchase identity change), send this account's pending reports (bounded) and count what is still pending; refuse only when reports remain after a network failure; otherwise run main's sign-out sequence unchanged. PR #86 carries no sync-runtime change against main. A server refusal (quota) does not block: those reports are discarded and the residual recorded. Accepted residual: a report filed in another tab during the send window can be lost. The Free sign-out copy fix ships now.
- The Pro-row part of C3 moves to its own launch-gate task (T20), design reviewed before code, time-boxed to two audit rounds; if it fails, the choice goes to Aedwon: launch with the existing loss, or delay. It must guarantee: unsent Pro rows are sent or sign-out is refused with data, Sync generation and Pro state unchanged; no row written under A uploads under B, enforced inside each sync write transaction, and the owner marker is never absent while signed in; every wait is bounded and a timeout refuses, never hangs or wipes; a closed-account pull cannot restore wiped data; one wipe per transition and a failed sign-in ends signed out; tests run the production controller, with no instant fakes.

### C5. How strict H1(b) is, and the stop rule for T18 (Fable 5.2 advisor, Nov 24)

- Context: four Codex rounds on T18 (D1 with H1) kept finding finer correlations between closed guardian requests and rate-limit counters.
- Ruling, verbatim: "H1(b) already answers this. Its last sentence, which the T18 brief left out, reads: \"Short-lived rate-limit counters are outside this test.\""
  1. H1(b) covers the request record, `guardianTokens` rows and evidence only. Pass: after decline or expiry, no document except the decline evidence sits under the account's path or holds the account ID, and no retained link shares an ID or exact time with the evidence.
  2. Limiter rule: no plain account ID in path or field, no email, token or request field, and a cleanup time on every write at most 8 days out. Exact window times are allowed. The keyed hash stands.
  3. Move `guardianStatus`, `guardianAdult` and `guardianAnswer` to the keyed-hash form; the one-time script deletes the old uid-keyed rows of all three plus `guardianSend`, for every account.
  4. Fix the decline after expiry: read the links before the final clock read; the test fails first.
  5. Not required: the email counter finding. The send-counter timing should-fix is the lead's call (lead: accepted as is).
  6. Stop rule: one more Codex round, asked only whether items 1 to 4 pass, naming a document and field for any fail. Findings that need a join across rows, the server secret or timing inference are recorded, not fixed. Merge on four passes plus the worker's green emulator run.
  7. Residual: for at most 8 days, someone holding the server secret and the full database could join a counter to a closed request. Accepted under H1's exclusion. No lawyer reviewed this.
- Process note (lead): the T18 brief quoted H1(b) without its last sentence; briefs now quote rulings in full.

### C6. Phone Pro page: the required tick card is below the fold and Pay is off with no reason (UX design lead, Fable 5.2 agreed, Nov 24)

- Asked by the CSE release lead for PR #90 (checkout declaration, D2 option T). At 390 x 844 on first view, the plans push the tick card below the fold. The fixed bar shows Pay disabled and nothing says why. Board S4P_T avoided this with a shorter plans block; the real page has five hero bullets and a yearly plan. Renders: `cse-checkout-decl` build, `render/r6/sheet_phone390_*.png`.
- Options: (1) a one-line hint under Pay while it is off; (2) tapping the disabled Pay scrolls the card into view and focuses it; (3) move the card into the bottom bar.
- Ruling: 1 and 2 together; 3 rejected (five lines of fixed legal text would take about 150 px of 844 and hide the plans).
- Hint: the bar's status line (the slot that shows "Read the box again, then tick it to pay.") reads "Tick the box to pay." while Pay is off. The same words are Pay's accessibility hint. The status line's height is always reserved, so the bar never changes height. On tick the hint fades out over 150 ms. No direction words: the hint sits at the bottom of the screen.
- Pay: keeps the approved disabled look but stays tappable and focusable; screen readers hear a button with the hint, not "dimmed". A tap or Enter while off: if the card is not fully visible, it scrolls into view to rest 16 px above the bar (400 ms, `cubic-bezier(.32,.72,0,1)`); then focus moves to the tick and the app's ring pulse plays once on it (0.7 s, ease-out), never during the scroll. If the card is already visible: focus and pulse only. Reduced motion: the scroll jumps, no pulse.
- Fable 5.2 (high) agreed and added the reserved status line, skipping the scroll when the card is visible, and the screen reader rule.

### C7. The adult mark kept after a guardian request ends is outside H1(b) (Fable 5.2 advisor, Nov 24)

- Asked by the CSE release lead under the C5 stop rule. The final Codex check passed C5 items 2 to 4 and failed item 1: after decline or expiry, `users/{uid}/server/guardianConsent` can remain with `ageGroup: 'adult'` and `adultSince`.
- Ruling, verbatim: "A. Item 1 passes and T18 merges with no code change."
  1. Scope: H1(b) tests for a record that links the account to a guardian request. The kept mark holds no request field, only the account holder's own statement that they are 18. An adult made that statement, so H1's missing guardian basis does not apply.
  2. Purpose: the mark stops a new under-18 request. Deleting it would reverse an earlier required fix.
  3. Time check: `adultSince` cannot match the decline evidence (the decline reads its own clock in a later write; an expiry writes no evidence). It equals `revokedAt` on guardian page links revoked by the same act, but ending the request deletes every such link. Retained answer links keep only a coarse end day.
  4. C5 item 1 should read "no request document".
- Recorded, not fixed in T18:
  - `adultSince` equals `decidedAt` on the `became_adult` evidence row (on main before T18). Both sit under the same account ID, so the time adds no link. Whether a `became_adult` row may sit in the evidence at all, against R6's "Adult declarations never enter the evidence (R2)", needs its own ruling. Sent to the legal lane through the operations manager.
  - The mark exists only where a request once existed; dropping `adultSince` would not remove that inference.

## Nov 24, became_adult evidence row

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent, under Aedwon's delegation. The ruling is final and is not queued for his sign-off. Legal sign-off on the final texts stays his. This agent wrote no legal text: wording named below goes to the text lane and to Sol High (rule 5). No lawyer reviewed anything here, and this agent is not a lawyer.

- Asked by ruling C7 ("needs its own ruling").
- Policy read at `origin/main` 6ff6f6889: `AGENTS.md`, `docs/workflow/process-improvement.md` (rules 5, 7, 9), and in this file D1 to D8, legal rounds 2 and 3, the under-18 flag options, C5 and C7.
- Code read: main 6ff6f6889 (`functions/src/guardianConsent.ts`, `deleteUserData.ts`, `purgeInactiveAccounts.ts`, `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`), PR #90 `qa/checkout-declaration-r1` 6177b6898, PR #95 `qa/guardian-d1-r1` f021040f0.
- Text read: `legal/public-launch-r1` 5a50ef3bd, `teen-notice.md` and `privacy-policy.md`.
- Standards applied: Data Privacy Act Sections 11(e) and (f), 13(a) and 13(f); Civil Code Articles 1144 and 1391, as R6 used them. No sheet exists in `agent-standards` for privacy law.
- Velocity: this pass was not timed. It changed documents only. The size below is an estimate.

### What was checked

1. **What the row is.** When a student in the under-18 group says they are 18, the server marks the account adult, revokes the guardian page links, and adds one row to the guardian evidence. The row holds the action `became_adult` and the time, and nothing else (`guardianConsent.ts:517-519`). PR #95 leaves this as it is (`:650-652` there).
2. **It is written whether or not a guardian confirmed.** The only tests are: the record is in the under-18 group, has not switched before, and is not withdrawn (`:511-516`). A pending request passes. On main, a declined or flag-only record passes too. The app calls it from the age recheck (`onboarding_age_gate_step.dart:234`).
3. **One such row keeps the evidence after deletion.** Account deletion keeps the evidence and writes its marker when any answer row exists (`deleteUserData.ts`, `keepGuardianEvidence`). So an account with no guardian answer and one `became_adult` row leaves a record under its account ID.
4. **PR #90 counts the row as a reason for ten years.** Its period test asks for any row whose action is not `decline` (`purgeInactiveAccounts.ts` on PR #90). A decline plus a `became_adult` row is kept ten years, and so is a `became_adult` row alone. R6's words give the first case four years and do not name the second.
5. **No other row can exist without a confirmation, except a decline.** A sharing change and a withdrawal both need a confirmed record.
6. **After the switch, no purchase is copied.** Checkout uses the guardian wording only when the record is confirmed and still under 18 (PR #90, `paymongoCheckout.ts:69`). Later purchases carry the adult declaration, which R2 keeps out of the evidence.
7. **The texts say the server records the statement, but no evidence list names it.** Teen Notice: "our servers record that you are 18 or older". The three lists of guardian evidence name answers, withdrawal and guardian purchase declarations only: the Teen Notice deletion paragraph, its "Guardian evidence" bullet, and the Privacy Policy line "limited guardian evidence".
8. Not checked: how many `became_adult` rows exist on prod or staging, and live behavior. Aedwon's choice among options A to D above is not recorded on main.

### Ruling

1. **R6 does not cover it.** In R2 and R6, "adult declarations" means the adult declaration ticked at checkout. The `became_adult` row is not a purchase declaration: no purchase, another function, another purpose. So R6's sentence does not forbid it. R6's period list did not place it either. This ruling does.
2. **The row stays where a guardian confirmed, unchanged. It is no longer written where no guardian confirmed, and existing rows of that kind are deleted.**
   - With a confirmation, the row is the end date of the guardian's permission, in the account holder's own words. It shows why the guardian's links stopped, and that later purchases were the adult's own. That is the same legal-claims purpose as the rest of the evidence (Section 13(f)), and the guardian's permission covers the under-18 label it implies (Section 13(a)).
   - With no confirmation, the row records no guardian act and no contract. Its only content is that this account once had a guardian request, kept under the account ID for ten years after deletion. That is the record D1 and H1 exist to remove, and it cannot pass the "necessary" test. The adult mark on the account already stops a new under-18 request (C7), so nothing depends on the row.
3. **The row has no period of its own.** It follows the evidence it sits in, which always holds a confirmation: 3,653 days from the newest record, once the account is gone. It counts as a record for "newest". It never chooses the period. The statement is not verified, so it does not shorten the period, and the Article 1144 reason does not depend on age.
4. **Rejected: text only, with the row kept in every case.** The texts would then have to describe a ten-year record with no purpose for an account no guardian answered.

### Code change. Gate, about 0.25 day

1. The adult switch writes the `became_adult` row only when the record's status is confirmed. Everything else in the switch is unchanged. Tests fail first: a pending record that switches leaves no evidence row; a confirmed record still gets one.
2. The evidence period test becomes positive: ten years only when the evidence holds a confirmation, a withdrawal or a guardian purchase. Otherwise four years. Test fails first: a decline plus a `became_adult` row is released at four years. This makes the code match R6's words whatever rows exist.
3. One-time removal: delete every `became_adult` row in evidence that holds no confirmation, and the evidence parent if nothing is left under it. Count it against the free tier first (rule 7). It joins T18's one-time removal if that has not run on prod, else it runs alone. Expected count is near zero: the beta had one under-18 tester, confirmed.
4. PR #95 is not reopened: C7 stands and it merges as ruled. Items 1 and 3 go in a follow-up after it merges. Item 2 goes in PR #90 if it is still open, else in the same follow-up. The lead's normal review applies. No new Codex loop is required.
5. Gate, because the change shortens what is kept: after opening it needs the rule 9 email, and the texts must be true on the day they publish (H5). Add one row to the H5 table: an unconfirmed account that says it is 18 leaves no evidence row, checked live on prod.

### Text changes (for the legal lane, rule 5)

1. Teen Notice, the "When you turn 18" paragraph: if a guardian had confirmed the account, the date of this statement joins the guardian evidence.
2. The three evidence lists in check 7: add that date, for an account a guardian confirmed.
3. No period sentence changes. After the code change every evidence set either holds a confirmation, a withdrawal or a guardian purchase (ten years) or holds only declines (four years).
4. Sol High critiques the changed paragraphs in the next round, and confirms Section 13(f) for this row.
5. These sentences publish only after the code change is on prod (H5).

### What needs Aedwon

Nothing. The ruling holds under each of options A to D. Under C the unconfirmed case can arise only for requests open at the opening.

### Recorded, not ruled

- After the switch on a pending request, the request stays open until it expires, and a guardian can still answer it (read in `guardianConsent.ts` on PR #95; not tested). The guardian's contact data then stays up to seven days with no use. Recommended, at the lead's call and not a gate: the switch ends an unconfirmed request the way an expiry does.
- The same three evidence lists do not name the guardian's sharing changes, which the evidence also holds (`sharing_on`, `sharing_off`, main `guardianConsent.ts:451`). The text lane decides whether "the guardian's answers" covers them.
- R6's line "Adult declarations never enter the evidence (R2)" should read "Adult purchase declarations". C7 read it as possibly wider.

## Nov 24, legal round 5: sharing-change retention

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent, under Aedwon's delegation. The ruling is final and is not queued for his sign-off. Legal sign-off on the final texts stays his. This agent wrote no legal text: wording named below goes to the text lane and to Sol High (rule 5). No lawyer reviewed anything here, and this agent is not a lawyer.

- Asked by Sol High's round 5 verdict: ten years from the newest record is hard to justify for every older entry, "especially optional-sharing changes".
- Read: `AGENTS.md` and `docs/workflow/process-improvement.md` (rules 5, 7, 9) at `origin/main` 5f40b1e7d; R6, H5 and "Nov 24, became_adult evidence row" in this file; `critique-2026-11-24-sol-high.md`, the README "round 5" section, `teen-notice.md` and `privacy-policy.md` at `legal/public-launch-r1` 5d895e58d.
- Code read: main 5f40b1e7d (`functions/src/guardianConsent.ts`, `purgeInactiveAccounts.ts`, `deleteUserData.ts`, `usageVisit.ts`) and PR #90 `qa/checkout-declaration-r1` (`purgeInactiveAccounts.ts`).
- Standards applied: Data Privacy Act Sections 3(b) (permission must be evidenced), 11(e) and (f) (proportionality, retention), 13(a) and 13(f); NPC Advisory 2024-02; Civil Code Articles 1144, 1146 and 1391, as R6 used them. The articles are cited from memory. No sheet exists in `agent-standards` for privacy law.
- Velocity: this pass was not timed. It changed documents only. The size below is an estimate.

### What was checked

1. **A sharing change is one small row.** It holds the action (`sharing_on` or `sharing_off`), the time, and the document and wording versions (`guardianConsent.ts:424-427`, `:451`). Only a confirmed record can get one.
2. **The guardian's first sharing choice sits on the confirmation row,** as the field `sharingAllowed` (`:371-376`).
3. **A sharing change moves the clock for the whole evidence.** The cleanup takes the newest answer row of any kind as "newest record" (`purgeInactiveAccounts.ts:281-287` on main, `:291-299` on PR #90). A switch flipped five years after the confirmation keeps the confirmation five years longer.
4. **The cleanup runs only once the account is gone,** and it holds the account's deletion date (`accountDeletedAt`). Sharing cannot happen after that date.
5. Not checked: how long Google Analytics keeps the shared usage data (the Privacy Policy draft says 14 months, unconfirmed in the console), the filing period for an NPC complaint, and live behavior.

### Ruling: option (c). Sharing permission records get four years from the account's deletion date, and never move the ten-year clock

1. **While the account exists, the full sharing history stays.** Permission must be evidenced while Pantas relies on it (Section 3(b)), and each "on" row proves one stretch of permitted sharing.
2. **After the account is deleted, every sharing permission record is deleted 1,461 days after the deletion date.** That covers `sharing_on` rows, `sharing_off` rows, and the `sharingAllowed` field on the confirmation row. The confirmation row itself stays on its own period.
3. **A sharing row is never the "newest record" and never chooses a period.** The ten-year and four-year clocks run from the newest of: a confirmation, a decline, a withdrawal, the `became_adult` row, a guardian purchase.
4. **Rejected: (a) keep ten years.** Both of R6's ten-year reasons are contract reasons (Articles 1144 and 1391). Sharing permission is a permission the guardian can take back, not a contract term. Its record answers only a claim that Pantas used data without permission. R6 already treats that claim as a four-year claim (Article 1146) for declines. Check 3 also has no claim behind it.
5. **Rejected: (b) the latest state only.** Sol High's own point: the current setting cannot show the history. On, off, on, off leaves the second "on" stretch with no proof, while a claim about it is still live.
6. **Why the clock starts at deletion, not at each row.** A row's use ends when the next row replaces it, so a per-row clock would need old rows rewritten on every change. The deletion date is the last day sharing could happen, so four years from it covers every stretch.

**The honest limits.** No Philippine ruling fixes this period. A damages claim under the Data Privacy Act could be argued as an obligation created by law, ten years under Article 1144(2). R6 chose Article 1146 for the same kind of claim, and this ruling follows it. Criminal prescription under Act No. 3326 (eight or twelve years, from memory) is not used: keeping records ten years against a possible prosecution is the reasoning Section 11(e) does not allow. A self-declared adult switch does not start the clock, for the reason in the `became_adult` ruling: the statement is not verified.

### Code change. Gate, about 0.5 day

1. Evidence cleanup, for an account that is gone: once 1,461 days have passed since `accountDeletedAt`, delete the sharing rows and remove `sharingAllowed` from the confirmation row. Tests fail first: sharing rows survive at 1,460 days and are gone at 1,461; the confirmation row survives without the field.
2. "Newest record" ignores sharing rows. Test fails first: a confirmation from year 0 plus a sharing change from year 5 is released ten years after year 0.
3. A legacy parent with no marker gets its marker when first seen, as today, so its sharing clock starts then. Never shorter than ruled.
4. Count the added reads against the free tier (rule 7). The extra reads happen only for accounts that are gone.
5. It goes in PR #90 if that is still open, because the period test lives there. Otherwise it joins the `became_adult` follow-up. The lead's normal review applies.
6. Gate, for R6's reason: the texts state the period, texts publish only with the behavior (H5), and after opening a change to a period needs the rule 9 email. Nothing can be deleted by this change for four years, so no user sees a difference. It joins the H5 row "ten years and four years for evidence".

### Text changes (for the legal lane, rule 5)

1. Teen Notice, "Guardian evidence" bullet: after the account is deleted, records of when the guardian gave or took back sharing permission, including the choice made at confirmation, are scheduled for deletion 1,461 days (four years) after the day the account was deleted.
2. Same bullet: "its newest record" does not count a sharing change.
3. Same bullet, the reason: sharing permission is not a contract. Its record serves only a claim about use of data, treated as a four-year claim (Article 1146), counted from the deletion date because no sharing can happen after it.
4. The three evidence lists and the basis bullet do not change. The Privacy Policy line already points to the Teen Notice schedule.
5. README "round 5", item 1: closed by this ruling.
6. Sol High critiques the changed bullet in the next round, and confirms Article 1146 against Article 1144(2) for a sharing claim, and whether Act No. 3326 changes the answer.
7. These sentences publish only after the code change is on prod (H5).

### What needs Aedwon

Nothing. He can change the period at legal sign-off, as with R6.

### C8. Evidence that ends before its sharing records (Fable 5.2 advisor, Nov 24)

- Asked by the CSE release lead while building legal round 5 in PR #90. Edge the round does not draw: evidence with a confirmation runs ten years from its newest record; sharing records run 1,461 days from the account's deletion. An account deleted more than six years after its newest non-sharing record (confirmed year 0, deleted year 8) reaches the evidence end (year 10) before the sharing end (year 12). The first sharing choice is the field `sharingAllowed` on the confirmation row.
- Options: (A) the whole evidence waits for the sharing period; (B) at the evidence end, delete everything except the sharing records, keeping a stripped confirmation row with only the sharing choice until the sharing end; (C) delete everything at the evidence end.
- Ruling, verbatim: "B."
  1. Each record keeps its own period: the confirmation row "stays on its own period", sharing records run 1,461 days from deletion.
  2. A would keep guardian purchase copies and the withdrawal, decline and adult rows up to four years past the stated ten, so the notice would be false (H5).
  3. C deletes sharing proof while a four-year claim is still live, the gap legal round 5 rejected in its option (b), and breaks the notice's 1,461 days.
  4. B needs no text change.
- Build: the stripped row keeps `sharingAllowed`, its time and the two version fields, as a sharing row does. Drop `agreed`; change `action` from `confirm` (simplest: rewrite it as a `sharing_on` or `sharing_off` row) so it stops setting a clock. Keep the parent marker.
- Tests, failing first: (1) confirmed year 0 with a sharing choice, a later sharing change and a guardian purchase copy, deleted year 8: at ten years only the sharing rows, the stripped row and the marker remain; (2) the same record is unchanged at deletion plus 1,460 days and empty at 1,461; (3) a second run after (1) changes nothing.

## Rule 7: Firestore TTL deletes (security and billing lead, Nov 24, 2026)

Question (CSE release lead, via the manager): Firestore TTL deletes are not in the free tier. Is that allowed on prod
and on staging? Not a close call, so no Fable ruling.

**Facts, checked Nov 24.** The quotas page lists "TTL deletes" under operations that "don't include free usage"
(https://firebase.google.com/docs/firestore/quotas). The TTL page says they "count towards your document delete costs"
(https://cloud.google.com/firestore/docs/ttl). Google's billing catalog: "Cloud Firestore TTL Deletes Singapore",
$0.0123 per 100,000 from the first delete; ordinary "Entity Deletes Singapore (with free tier)" are free for the first
20,000 a day. Both projects ran 8 TTL policies (limits, shards, signInChallenges, signInLimits, signInRequests, users
(the webhook event markers), webhookRateLimits, wrapped_shares). TTL deletes in the last 30 days: prod 398, staging
616 (Cloud Monitoring `document/ttl_deletion_count`).

**Ruling.**
1. Prod keeps every TTL policy, and the new ones (questionReports, trial codes) may ship. The deletes come from real
   users, which rule 7 allows. Cost now: about $0.00005 a month. At public scale (an estimate of 5,000 TTL deletes a
   day: sign-in records, sync counters, webhook markers, reports) about $0.02 a month.
2. Staging runs no TTL policy, because its TTL deletes bill a nonzero amount (rule 7). This is option (b) changed: staging
   has no scheduled jobs (prod holds the 3 free Scheduler jobs), so nothing replaces the TTL deletes. Staging test data
   is small, and every staging proof deletes its own documents with ordinary deletes, inside the free 20,000 a day.
   Published deletion periods apply to real users only, so they do not apply to staging.
3. Applied Nov 24: all 8 staging TTL policies turned off. `firestore.indexes.json` turns TTL back on with any staging
   indexes deploy, so run `tool/deploy/staging_disable_ttl.sh` after one (docs/deploy-prod.md). The live check
   `tool/checks/free_tier_live.mjs` shows a "Firestore TTL policies" row that is OVER while staging has any.

## Nov 24, T15 reader undrawn states

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent, under Aedwon's delegation (written rule 4). The rulings are final and are not queued for his sign-off. His visual pass still gates release (`WORKFLOW.md`).

- Asked by the T15 build lead (lesson reader full screen, "4 Held") through the CSE release lead: seven states no board draws, and one release question on frame times.
- Policy read at `origin/main` c92aa65f4: `AGENTS.md`, `WORKFLOW.md`, `docs/workflow/process-improvement.md` rules 1 to 4, the UX ambition hand-off, the reader build spec, and in this file "Nov 23, lesson reader full screen".
- Boards read on the live canvases, Nov 24. Lesson Reader Full Screen: `canvas.json`, `R`, `W4_Held`, `M1100`, `H4`, `fs.css`, `reader.css`, and the linked-word scene of `MO`. Pantas Web: `canvas.json`, `W_Reader`, `RD_Focus`, `RD_FocusOpen`, `RD_Figure`, `W_ReaderHeldDarkFull`, `RD_Held1100`. Not read: the body of `RD_FocusMotion` (no ruling here touches the bar's timing).
- Code read: `qa/reader-4-held-r1` 600c63a31 (placement, hold, linked words, the wide-art list, the top bar). Content read: `content/lessons/mathematics/geometry/circles.md`, and a scan of every lesson's figure labels with the build's matching rules.
- Standards applied: READ-MEASURE, READ-MARGIN, READ-FIG-NEAR, READ-FIG-SIZE (`long-form-reading.md`); ID-SPATIAL, ID-COHERE (`instructional-design.md`); WEB-M11, WEB-M13 (`web-interface-design.md`); the DS4 radius scale (`pantas_radius.dart`).
- Velocity: this pass was not timed. It changed documents only. Build sizes below are estimates.

### Rulings

1. **1024 to 1279 px: center it. Change, under 0.25 day.**
   - The text column (up to 600), the 48 px gap and the 300 px figure column are one block. Center the block in the window. Each side margin is at least 40 px: left margin = the larger of 40 and (window width minus block width) / 2.
   - At 1024 this gives 40 px each side, as drawn. At 1100: 76 px each side (the board: 40 left, 112 right). At 1279: 165.5 px each side (the build: 40 left, 291 right).
   - The title and the end-of-lesson block keep the text column's left edge. The top bar and the section line do not change.
   - Why: every other reader state is centered (the 1,096 px page at 1280 and up, and the 680 px column). The board's left alignment comes from its style sheet (`width:auto; margin:0 40px`) and was drawn only at 1100, where the slack is 72 px.
   - Rejected: letting the figure column grow with the window. It changes values the board draws at 1100 and every plate height in the real-content run.

2. **Section line: 2 px. Confirmed, no change.** The spec and `fs.css` both give 2 px at rest, 4 px on hover or focus, 3 px gaps. This is wide web only. The phone keeps its approved bar.

3. **Expand button radius: 8. Use the token.** `PantasRadius.sm` is the DS4 radius for controls under 40 px, and DS4 folded 7 and 10 into it on purpose. 1 px on a 34 px button cannot be seen. The board's 9 is the outlier.

4. **Width control: hidden on a lesson with margin figures. Confirmed.**
   - The held layout already uses the full width, which is what the control was for (Aedwon, Nov 3: "so they can choose to utilize more of the whole screen area or not"). Wider text there would break the 640 px measure. No held board draws the control.
   - The saved choice is kept and applies again on lessons with the single column (680 or 800 px). No disabled state and no empty gap. The bookmark does not move.

5. **Stacked figures: one unit only when they share a passage. Change, about 0.25 day.**
   - Figures whose passages end at the same place (no text between them in the source) and that stack are one unit. They hold and leave together, 18 px apart. Rule 5's cap applies to this unit.
   - A figure that rule 4 only pushed down from its own anchor keeps its own passage. Each such plate holds within its own passage. A held plate's bottom never comes closer than 18 px to the next plate's top.
   - Why: the build gives a group the latest passage end of its members. The upper figure then stays in view beside text it does not explain. Council round 4: "keep every figure inside its own passage". The same fault is why direction 2 (Pinned) was rejected. Rule 5 implies a unit only for figures that are read together.
   - Motion does not change. This is the hand-off in `MO`: the upper plate leaves at the speed of the scroll, the next plate arrives and holds.
   - Test, failing first: two figures with different passages, the second pushed down 12 px. At every scroll position the first plate's bottom is at or above its own passage end.

6. **Acceptance check 5: replace the second pair with a real one.**
   - New text: "Linked words: in circles, 'Tangent' lights the tangent line and dims the rest. In Example 4 with the solution open, `$AB$` in the first solution line ('... and $AB$ is the hypotenuse.') lights side AB, makes its label 'AB = 10' bold and dims the rest. Keyboard: Tab reaches each linked word and each section segment, with the focus ring."
   - Why: no figure label says "hypotenuse", so the label rule cannot link that word. `H4` drew a link the rules do not make. The real pair keeps what `H4` shows (the hypotenuse lights), and `R` already draws this link on that line.
   - A second real pair, solution closed: `$BC$` in the problem lights side BC (label "BC = ?").
   - Real content links fewer words in Example 4 than the board. The problem figure's labels are "Diameter AB = 10" and "AC = 6", so `$AB$` and `$AC = 6$` in the problem line do not link. That is content, not a build defect. No content change for launch (the spec adds no content).
   - The scan estimates passages from the lesson source. The lead confirms both pairs with the build's own matcher.

7. **Wide art: accept a list, with a guard. No natural size for this release. About 0.5 day.**
   - Facts: each painter draws at a fixed height into the width it gets. There are 26 painter files and about 127 figure types in the lessons. A natural size for each is about 2 to 3 days and touches every phone figure.
   - At 1280 and up the plate's inner width is 360 px, wider than the phone's figure (about 326 px). A figure that reads on the phone reads there. The squeeze risk is the 1024 to 1279 band (260 px inner).
   - Required in T15:
     1. The list is explicit, one entry per figure type, and lives with the figure registry. The reader does not match name endings ("gallery", "triptych"). A new type can miss that match without any failure; `orbital-shapes` and `atomic-models` already needed their own entries.
     2. A check fails when a shipped lesson has a figure type that is on neither list (wide or margin). A new type cannot ship unclassified.
     3. One pass over every figure type in the shipped lessons, not only the seven lessons of check 3. Render each at 260 px inner width, one sheet per painter (the Nov 9 screenshot exception). A Claude worker moves to the wide list any type whose labels clip or overlap, or whose parts are a row of three or more panels. This is UI, so no Codex.
   - A natural size per painter is not scheduled. The check removes the reason for it.

8. **Frame times: a real-GPU Chrome run gates the release. Safari gates it through Aedwon's visual pass.**
   - The measured run passes on what it measured: p95 5.4 ms is a third of the 16.7 ms budget, and p99 is warm-up. It does not close acceptance check 4, which names a mid-range laptop, Chrome and Safari.
   - Shake is not a browser risk. Flutter paints the text and the plates in the same frame in every browser, because the hold moves plates at paint time. Only the frame rate depends on the browser.
   - Gate, agent-run, about 0.25 day: the same script in Chrome with the real GPU and the CPU slowed 4 times (this Mac is an M4; a mid-range laptop is about 2 to 3 times slower), at 1440x900 and 1100x900, first second left out. Pass: p95 at most 16.7 ms.
   - If it fails at 4 times, do not fall back yet. Report the 2 times and 4 times numbers to this agent: the 4 times setting is harsher than the target.
   - Safari gate: Aedwon scrolls Circles with Example 4 open in Safari on the Mac, as part of the visual pass that already gates release. An iPad in landscape counts too, if one is at hand: every iPad browser is WebKit, and the held layout starts at 1024 px. No instrumented Safari run is required. Agents do not drive Safari (no computer control). An agent may add a headless WebKit run of the same script if it needs no permission prompt. That run informs his pass and does not replace it.
   - If Chrome passes and Safari does not: Safari and iPad get figures at rest (the spec's fallback, direction 1), Chrome keeps the hold, and the lead reports it.

### Board changes (for the operations manager's reference canvas list)

- Ruling 1: `M1100` (Lesson Reader Full Screen) and `RD_Held1100` (Pantas Web). Center the text and figure block. At 1100 the side margins are 76 px each (now 40 left, 112 right). The mid-width rule in `fs.css` and `held/fs.css` changes with it.
- Ruling 3: `fs.css` (Lesson Reader Full Screen) and `held/fs.css` (Pantas Web). The expand button `.fx` radius goes from 9 to 8. This reaches every held board.
- Ruling 6: `H4`, `R` and scene 3 of `MO` (Lesson Reader Full Screen); `RD_HeldLinked`, `RD_HeldPart` and `RD_HeldMotion` (Pantas Web).
  - The pointer sits on `AB` in the first solution line, not on "hypotenuse" in step 1. Remove the link from "hypotenuse".
  - In the problem line only `BC` is linked, not `AB` or `AC`.
  - The problem figure's label reads "Diameter AB = 10", as in the lesson.
- Rulings 2, 4, 5, 7 and 8: no board change. No board draws a stack, and no held board draws the width control.

### Spec lines these rulings change (for the spec's owner)

- Layout, 1024 to 1279: add "centered; side margins at least 40 px".
- Rule 4: add the two cases of ruling 5.
- Rule 6, last clause: "A figure type is wide when the figure registry lists it. A check fails on an unlisted type."
- Figure plate: the expand button's radius is 8.
- Acceptance check 5: the text in ruling 6.
- Acceptance check 4: the two gates in ruling 8.

### What needs Aedwon

Nothing new. His visual pass, which already gates release, includes one scroll of the held reader in Safari (ruling 8).

## PAY-07 follow-on: a grant with both a dispute and a refund (Fable 5.2 advisor, Nov 24, 2026)

Asked by the security and billing lead after eight review rounds of the money-path fixes kept finding new interleavings
of disputes and refunds on one grant. Options: (A) keep fixing every interleaving automatically; (B) never re-plan such
a grant automatically and hand it to the owner; (C) other. Lead recommended B.

**Ruling: B, with one tightening.**
1. A grant that has a dispute and any refund, in either order, is never restored or re-planned on a win. The win is
   recorded, the dispute is marked resolved, the grant stays as it is (revoked or shortened).
2. One pending follow-up, reason `disputeWithRefund`, keyed by payment: paid amount, refunded total, dispute id, unused
   days, and the later plans or rewards the dispute had pulled earlier (left where they are). The existing log alert
   emails the owner, who settles it by hand: grant the remaining days, or refund the rest (a guardian denial is owed the
   rest, per the Terms).
3. A lost dispute keeps its automatic path; it adds a follow-up only when refunds plus the chargeback exceed the amount
   paid (the owner then paid twice).
4. A dispute that opens on an already refunded grant still revokes at once. A refund that arrives after a pure dispute
   was won and restored is a pure refund.
5. **Keep revoked, not restore the unrefunded part:** that calculation produced the last findings. Missing access is
   reported by the user and cheap to fix; wrong access or a shifted later plan is seen by nobody.

**Build edges.** Decide on "has a dispute id and refunds above zero", never on the stored revocation reason. Do not
overwrite a pending refund task with the same key, and the refund-closing logic must not close this follow-up. A replayed
win, or a win before its opening event, writes no second record and restores nothing. The property test covers both
orders and asserts no grant changes on such a win.

### C9. BIR Registration Seal Badge placement (Fable 5.2, Nov 24)

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent for the CSE release lead, under Aedwon's delegation (written rule 4). The placement, size and treatment below are final and are not queued for his sign-off. One point is his and is not ruled: whether the badge is shown at all while the BIR's display rule is suspended (see "What needs Aedwon"). His visual pass still gates release (`WORKFLOW.md`).

- Asked by the CSE release lead. Source: the operations manager, relaying page 3 of Aedwon's BIR Certificate of Registration (Form 2303), verbatim: "For taxpayers engaged in online business or with online presence, the BIR Registration Seal Badge should be prominently displayed on their website or profile page. This badge should be easily visible to the public and readily scannable that will serve as verification of their registration with the Bureau of Internal Revenue." The manager's instruction: place it where the D3 seller details go, the website footer and the Pro page. No board draws it.
- Policy read at `origin/main` 976432809: `AGENTS.md`, `WORKFLOW.md` (website copy, visual checking), `docs/workflow/process-improvement.md` (written rules 1 to 9 and the entries), and in this file D2, D3, the H5 table, C6 and the legal rounds.
- Velocity: this pass was not timed. It changed no code. Build sizes below are estimates.

#### What was checked

1. **The asset** (`build/audit/bir_badge.png`, 1160 x 380). Read with Apple's Vision decoder, confidence 1.0:
   - The QR code holds `https://verify.bir.gov.ph/correspondence/<id> (the full address is kept out of this public repo)`.
   - It is a version 5 code: 37 modules a side, error correction M.
   - Its dark area is 239 x 247 source px (x 878 to 1116, y 43 to 289), so one module is about 6.5 source px.
   - Clear paper around it: 43 px above, 44 px to the right, about 50 px down to the RSN line. The standard asks for 4 modules, 26 px.
   - The paper is already pure white (255, 255, 255) under the pale watermark. No tone correction is needed.
   - The left 60 px hold only watermark. The ribbon's tip starts at x 82.
2. **The code** (`origin/main`):
   - `lib/core/config/seller_facts.dart`: the proprietor name and email are constants; the trading name, place and phone are build inputs.
   - `pro_page.dart` and `widgets/declaration_card.dart`: the seller line shows only while the tick card shows (web, a payment about to be taken, not the free trial).
   - Phone: the seller line sits in the fixed bar, between Pay and Restore Purchases. The bar already holds Pay, the seller line (three lines at 390 px), Restore Purchases and C6's status line.
   - Wide web: the seller line sits right-aligned under Pay, at most 480 px wide, inside the page's scrolling content. By the pane's width rule, the detail pane is about 460 px wide at a 1024 px window and about 750 px at 1440 (estimated, not measured).
3. **"Website footer" today.** The app has no footer. The website is the separate `pantas-web` project (pantas.study, a Cloudflare Worker). Its footer is the `pn-founder` block ("Built by a solo developer") on seven pages; the investor page has its own. The D3 seller footer is not built. The site has no dark mode.
4. **Boards.** Read live on Nov 24: `S4P_T_light`, `S4P_T_dark`, `S4W_T_light` (CSE Release Picks); `CB_Ph`, `CB_PhDark`, `CB_Wide` and `canvas.json` (Guardian Manage and Minor Checkout); `ST_ProCSE`, `ST_Paywall`, `ST_Pro`, `ST_About` (Pantas Web); the design system's `tokens.css` and `components/bundle.css`. No board draws a badge, a footer or any image on the Pro page. The system's Figure component draws images on a plate that stays white in dark mode (`figure-bg`), radius 12, with a 1 px `divider` ring.
5. **The rule itself, on the web, Nov 24.** This changes the premise:
   - The display duty comes from BIR RMC 38-2026, supplemented by RMC 64-2026 and 99-2026.
   - **BIR RMC 113-2026, issued October 26, 2026, suspended the mandatory display "until further notice".** Sellers who hold a badge "may continue displaying them on a voluntary basis", and "no penalties shall be imposed solely due to the non-display".
   - The reported reasons were privacy and technical complaints. Scanning a badge shows the registrant's name and TIN digits. One report says the digits are masked; another says the full TIN shows.
   - Rules that still describe a correct display: the badge "must remain clear, readable, and completely unaltered, preserving all of its original design elements"; it may be cropped, scanned or extracted from the certificate; it must be "visible and easily accessible" to customers; a real code leads to `https://verify.bir.gov.ph/correspondence/`.
   - RMC 64-2026 lets a taxpayer generate the badge as a digital file in ORUS.
   - Limit: the circulars themselves were not read. These points come from Grant Thornton, KPMG and GMA News summaries (sources at the end). No lawyer reviewed this.
6. **Scan range.** A simulation, not a field test: the badge was drawn at each size and screen density, then passed through a modeled phone camera (1920 px preview, 69 degree view, blur, 4 degree tilt, noise, lowered contrast) and decoded with Apple's Vision.

   | Surface | Badge width | QR side | Per module | Farthest decode |
   |---|---|---|---|---|
   | Phone | 240 px | 52 px | 1.4 px | 10 cm |
   | Phone | 300 px | 65 px | 1.8 px | 15 cm |
   | Phone | 358 px | 78 px | 2.1 px | 20 cm |
   | Laptop, Retina density | 480 px | 104 px | 2.8 px | 35 cm |
   | Laptop, Retina density | 640 px | 139 px | 3.8 px | 45 cm |
   | Desktop monitor, 96 dpi | 480 px | 104 px | 2.8 px | 40 to 45 cm |

   - The range follows the physical module size: about 60 cm of range per millimeter of module.
   - Vision is a strong decoder, so this is an upper bound. Cheaper scanners will do worse. The phone check in the build items is the proof.
   - The code also decodes from a headless render of the draft board at 1x and at 2x.

#### Standards applied

- **ISO/IEC 18004 quiet zone**, as stated by Denso Wave: "QR Code requires a four-module wide margin at all sides of a symbol." Kept at every size: the crop and the plate's corner radius leave more than 4 modules clear.
- **Module size on screen.** No standard gives an on-screen minimum (Denso Wave's figure is for print). The floor here is set from the scan-range table above and is marked as this project's own measurement.
- **BIR RMC 38-2026**, through the KPMG summary: "clear, readable, and completely unaltered, preserving all of its original design elements"; cropping or extracting the badge alone is allowed.
- **WCAG 2.2, 1.1.1 Non-text Content**: "If non-text content is a control or accepts user input, then it has a name that describes its purpose." Also 1.4.5 Images of Text (a seal is the essential-presentation case), 2.4.7 Focus Visible, 2.5.8 Target Size.
- **Agent standards library**: WEB-A1, WEB-I10, WEB-C6, WEB-K6, WEB-M1 (`web-interface-design.md`); UXW-CONCISE, UXW-LINK (`ux-writing.md`).
- **His guidance for UI councils** (process-improvement, Nov 23): "no wordy UI, compress text, clean, intuitive, elegant".
- **AGENTS.md voice rules** for the one in-app string. **WORKFLOW.md** for website wording, which stays his.

#### Options

1. **In the phone's fixed bar, beside the seller line.** Rejected. The badge is 124 px tall at full width. The bar is about 230 px tall today. It would reach about 360 px of 844 and hide the plans. C6 rejected a tall bar for the same reason.
2. **Above the plans, or between the plans and the tick card.** Rejected. It puts a government graphic in the middle of the purchase path and pushes the required tick card further below the fold, which C6 just fixed.
3. **A small mark that opens the full badge in a sheet.** Rejected. A shrunken or redrawn mark is an altered badge, and it adds a tap and a new screen state.
4. **The last item of the page, at a size that scans. Chosen.** It is out of the purchase path, it rests directly above the seller line when the page is scrolled to its end, and the bar does not change.
5. **A second home in Settings, About.** Not ruled. Nobody asked for it, and the website footer is the public surface.

#### Ruling

1. **When it shows (app).** Web only, and only while the seller line shows: one condition, the existing one. Not on the free trial state, not for a Pro owner, not on Android. The badge and the seller line are one seller block.

2. **Placement, phone (390 x 844).**
   - The badge is the last item of the scrolling page: 24 px under the tick card, followed by the page's existing 24 px end space.
   - The bar does not change. C6 holds as written: the status line keeps its reserved height, and a tap on the off Pay button still brings the tick card to rest 16 px above the bar. At that rest position the badge is below the fold.
   - Nothing moves above the tick card.

3. **Placement, wide web.**
   - The badge is the last item of the page's bottom block: its own row, 16 px under the Pay row and any message line, right-aligned to the pane's right edge, under the seller line.
   - It does not go inside the Pay column. At a 1024 px window that column is about 280 px wide (estimated), which puts the QR code under the floor in ruling 5.

4. **Placement, website footer (`pantas-web`).**
   - The badge sits directly under the D3 seller details, on the same left or right edge as that text, on every page that carries them.
   - It ships in the same change as the D3 footer and under the same approval (D3 condition 2). It adds no visible words.
   - The site is light only. The plate is the site's white surface with its hairline rule.
   - The website is the public surface the certificate names. The Pro page is the point of sale. If only one can ship first, the website goes first.

5. **Size.**
   - Phone layouts, app and website: the full content width (the screen width less the two 16 px gutters). At 390 px that is 358 x 124 with a 78 px QR code. At 360 px it is 328 x 113 with a 71 px QR code.
   - Wide layouts, app and website: 480 px wide, 166 px tall, with a 104 px QR code. If the pane or column is narrower than 480 px, the badge takes its full width.
   - **Minimum QR side: 70 CSS px on a phone layout and 104 CSS px on a wide layout.** Hard floor on any surface: 64 CSS px, a badge 296 px wide. Below that the badge is not shown at all.
   - The aspect ratio is fixed at 1100:380. The badge does not grow with the app's text size setting.
   - Why these numbers: the QR code is 21.7% of the badge's width, so the badge's width sets everything. On a phone, 70 px is about 13 mm and scans from a second phone at 15 to 20 cm, the distance people hold two phones. On a laptop, 104 px scans to about 35 cm, the distance of a phone held up to a screen. Under 64 px the range falls to 10 to 15 cm and it stops being "readily scannable".
   - Why not 640 px on wide: it adds 10 cm of range and makes the badge as large as the hero card. The link covers the rest.

6. **Link.** The whole badge is one link to the address its QR code holds. It opens in a new tab and the Pro page stays open.
   - Reason: a person on a phone cannot scan their own screen. For them the tap is the only way to verify.
   - The link address is a constant beside the proprietor name in `seller_facts.dart`. It must equal the QR code's content, character for character.
   - On the website: `target="_blank" rel="noopener noreferrer"`.
   - The link sends no Pantas user data.

7. **States and motion.**
   - Keyboard focus: the app's ring, 2 px accent, offset 2, on the plate's shape. Enter opens the link. It is the last tab stop on the page.
   - Hover: the pointer cursor only. Press: nothing. No tint, overlay, scale or opacity change is ever drawn on the badge.
   - No motion of its own. It appears and leaves with the tick card, the way that card already does.
   - Its box is reserved by the aspect ratio, so the page does not jump when the image arrives. If the image fails to load, the badge is absent, with no error text.

8. **Text alternative.** One string, the link's name: "BIR registration seal. Opens the BIR verification page."
   - In the app it is a link and an image for screen readers, one node.
   - The RSN is left out of the name. A screen reader would spell 20 characters, and the page the link opens states the registration.
   - On the website the same words are the image's `alt`. They are website wording, so he approves them with the D3 footer (`WORKFLOW.md`).

9. **Light and dark.** The same plate in both: `figure-bg` (white in light and dark), `radius-md` 12, a 1 px `divider` ring, no padding. The scan's white paper is the plate.
   - In dark mode the badge is a white plate on the dark page, as lesson figures are. It is not inverted, dimmed, tinted or blended.
   - Reason: any dark treatment changes the badge and lowers the QR code's contrast.

10. **The image: what is allowed.**
    - Allowed: cropping empty paper (crop to x 60 to 1160, giving 1100 x 380); straightening; uniform scaling; white padding; rounding the plate's corners where they cut only empty paper; re-encoding at high quality.
    - Not allowed: redrawing or tracing it; removing or lightening the watermark; recoloring; sharpening or thresholding the QR code; replacing the QR code with a fresh one made from its content; moving, splitting or hiding any part, the RSN included; changing the aspect ratio; drawing anything over it.
    - File: WebP at quality 90 or higher, at most 150 KB (measured: 113 KB at quality 90, and it decodes at 358 px and 480 px). If blocks show at 3x zoom, use lossless WebP (373 KB). Web builds only (`platforms: [web]` in `pubspec.yaml`).
    - If Aedwon downloads the digital badge from ORUS, that file replaces the scan with no layout change. The build items' checks run again.

11. **Copy beside it: none.** No caption, no "Verified" label, no heading, no icon, no tooltip. The badge says "REGISTERED" and "BUREAU OF INTERNAL REVENUE" itself.

12. **Gate status.** Not a launch gate. The display duty is suspended, the H5 table has no row for it, and no legal text mentions it. The legal texts must not say the badge is shown or required. If the BIR lifts the suspension before launch, the badge becomes a gate and the manager adds an H5 row. If the app is already open, it becomes a task dated to the BIR's new deadline.

#### Reasons

- The certificate asks for three things: prominent, visible to the public, readily scannable. The website footer gives the public view. Full-width on a phone and 480 px on wide give the scan. The link gives everyone else the same result in one tap.
- The purchase path stays as approved: hero, plans, tick, Pay. The badge supports the seller line and does not compete with Pay.
- The Figure plate is an existing recipe, so the badge needs no new token and no new look (WEB-K6).
- "Unaltered" is the BIR's own test, and a badge that looks edited reads as fake. So the image gets no styling at all.
- A badge whose code does not scan is worse than no badge. That is why the size has a floor and the build has a phone check.

#### Build items (for the CSE release lead). Not a gate. Start after his answer below.

App, about 0.5 day. UI work goes to Claude workers, never Codex.

1. **Asset.** Crop to 1100 x 380, encode as ruled, add it for web only. Add the link constant. Tests, failing first:
   - The constant is `https`, host `verify.bir.gov.ph`, path under `/correspondence/`.
   - The asset's SHA-256 equals a pinned value, and the file is at most 150 KB. A changed file fails until the scan check (item 5) is run again and the pin is updated.
2. **Widget**, beside `SellerLine`. Tests, failing first:
   - Phone 390, payment state: the badge is the page's last item, 24 px under the tick card, 358 px wide, ratio 1100:380. The bar's height equals its height on `main`.
   - The C6 test still passes: a tap on the off Pay button rests the tick card 16 px above the bar.
   - Absent on the free trial state, for a Pro owner, and when `web` is false.
   - Wide 1440: 480 px wide, right edge on the pane's right edge, under the Pay row and the message line. Wide 1024: width equals the smaller of 480 and the pane.
   - A width under 296 px shows no badge.
   - A tap and Enter each open the constant's address once. Neither changes the tick or starts a payment.
   - One semantics node: a link, with the exact name in ruling 8.
   - Dark theme: the plate is white, and the image has no color filter, blend or opacity.
3. **Render sheets** (the Nov 9 screenshot exception): one sheet, phone 390 at the page end and wide 1440, light and dark. Compare with the board.
4. **Free tier (rule 7).** One static file of at most 150 KB, cached by the browser. No new service, job or secret.
5. **Scan check, a required step before it counts as done.** On the built page, scan the badge with a phone: from a second phone at phone width, and from a laptop screen at wide width, light and dark. Each scan must open the constant's address. Log the phone model, the distances and the result in the launch log.

Website, about 0.25 day, inside the D3 footer change.

6. Add the badge under the seller details as ruled, with `width` and `height` set. Test: every page that carries the seller details has the link with the exact address, the `rel` values and the approved `alt`. Run the scan check once on the live preview.

#### Board changes (for the operations manager's reference canvas list)

- A working draft of one state is at `build/audit/bir-badge-board.html`: phone 390 x 844, light, page end, box unticked. It is built from `S4P_T_light` and the design system's own two style files, unchanged, with one added block. It is not the reference. Written rule 3 applies: the state is added to the canvas in Claude Design.
- CSE Release Picks, checkout boards: add the badge to `S4P_T_light`, `S4P_T_dark`, `S4P_G_light`, `S4P_G_dark` (phone, drawn at the page end) and `S4W_T_light`, `S4W_T_dark`, `S4W_G_light`, `S4W_G_dark` (wide, 480 px, right-aligned under the seller line). The dark boards show the white plate.
- These boards are not folded into Pantas Web or Pantas Redesign yet (reference canvas folds, Nov 23). When they are, the badge goes with them.
- Guardian Manage and Minor Checkout (`CB_Ph`, `CB_PhDark`, `CB_Wide`): no change. Their wording is already stale against D2.
- `ST_Paywall`, `ST_ProCSE` and the other `ST_Pro*` boards: no change. They draw the free trial state, which shows no seller block.
- The website has no board. The D3 footer he approves is the reference.

#### What needs Aedwon

1. **One yes or no: show the badge while the BIR's display rule is suspended?** This is his because the badge's link shows his own tax record.
   - Before the manager asks, the lead opens the link once and writes down what the page shows: the name, whether the TIN is masked, and any address.
   - Recommendation: yes, if the TIN is masked. The seller line already publishes his name, and a BIR mark is a strong trust signal for a first-time buyer from a solo seller. If the full TIN shows, recommend no until the BIR masks it.
   - If he says no, nothing is built and nothing else changes.
2. **Optional, his login only:** the digital badge file from ORUS. It would be sharper than the scan.
3. Nothing else new. The website footer wording is already his under D3. His visual pass, which already gates release, sees the badge at both widths in light and dark.

#### Corrections and things recorded

- **The certificate's sentence is not a duty today.** The manager's relay treats it as one. RMC 113-2026 suspended it on October 26, 2026, four weeks before the Nov 22 legal package was ruled. Source and status are in check 5. This is a judgment from news and firm summaries, not from the circulars.
- **The "26" on the badge.** If it is the year and the BIR reissues the badge each year, the file, the link constant and the pinned hash change together. Not confirmed. The manager asks at the January cost check.
- **Google Play.** The certificate says "website or profile page". A Play listing has no place for the badge except a screenshot. Not ruled; Android checkout is out of scope for this launch (D2).
- **Standards library.** No sheet covers a code shown on a screen. Proposed rule for `web-interface-design.md`, for the manager to add: "A QR code on a screen keeps a clear margin of 4 modules and a module of at least 2 CSS px on phones and 2.8 CSS px on wide screens (suggested, from the C9 scan table), and the same destination is offered as a link." Source to cite: Denso Wave, "QR Code requires a four-module wide margin at all sides of a symbol."
- **Written rule 3.** The lead asked for a local HTML board. It was built from the approved board and the design system files, not from widget code, and is labeled a draft. The canvas change above is the real board work.

#### Sources

- Grant Thornton (P&A), "Suspension of the mandatory display of the BIR Registration Seal Badge": https://www.grantthornton.com.ph/insights/articles-and-updates1/tax-notes/suspension-of-the-mandatory-display-of-the-bir-registration-seal-badge/
- GMA News, Oct 26, 2026, "BIR suspends mandatory display of registration seal badge for online sellers, creators": https://www.gmanetwork.com/news/money/companies/1007190/bir-suspends-mandatory-display-of-registration-seal-badge-for-online-sellers-creators/story/
- GMA News, "Identity theft cannot be traced to BIR seal QR code alone, says privacy body": https://www.gmanetwork.com/news/topstories/content/1007263/identity-theft-cannot-be-traced-to-bir-seal-qr-code-alone-says-privacy-body/story/
- KPMG Philippines, "The BIR's blue check: the badge for online sellers": https://kpmg.com/ph/en/insights/2026/06/the-birs-blue-check-the-badge-for-online-sellers.html
- Denso Wave, "How to create a QR Code": https://www.qrcode.com/en/howto/code.html
- W3C, Understanding WCAG 2.2, 1.1.1 Non-text Content: https://www.w3.org/WAI/WCAG22/Understanding/non-text-content.html

## Nov 24, remaining legal brackets

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent, under Aedwon's delegation. The four rulings are final and are not queued for his sign-off. Legal sign-off on the final texts stays his, and he can change any value below when he signs. This agent filled the brackets in the drafts with the ruled values. Codex GPT 6.2 Sol at high effort critiqued the changed passages (rule 5, `critique-2026-11-24c-sol-high.md` on the legal branch), and every wording finding is applied. It asked for no value to change. No lawyer reviewed anything here, and this agent is not a lawyer.

- Asked: remove the brackets in the public-launch texts that do not need him. Four were ruled: the Google Analytics retention period, the refund reply time, the message retention period, and the invoice sentence. Two stay his and are not ruled: the publication date, and NPC registration (its bracket is already removed).
- Policy read at `origin/main` 7f5ff14f5: `AGENTS.md`, `SUBAGENTS.md`, `docs/workflow/process-improvement.md` (rules 5, 7, 9), checklist rows M8 and L1 to L10, and in this file D3, D8, R3, H2 and the Nov 24 legal rounds.
- Input, on `legal/public-launch-r1` e7e93dece: `terms.md`, `privacy-policy.md`, `teen-notice.md`, `README.md`, `change-summary.md`, `critique-2026-11-22-sol-high.md` (findings 3, 8, 15 and 16).
- Code read: main 7f5ff14f5, `lib/core/telemetry/firebase_telemetry.dart` and `lib/features/legal/domain/legal_document.dart`.
- Standards applied: Data Privacy Act Sections 11(e) and (f) (proportionality, retention) and 16; RA 11967 Sections 23(h), 23(i) and 24 and JAO 24-03 Sections 34 and 38, as Sol High cited them on Nov 22; Consumer Act Article 169 and RA 11967 Section 28 (two years, as Sol High read them on Nov 24); Google's help page "Data retention" (support.google.com/analytics/answer/7667196, read Nov 24). No sheet exists in `agent-standards` for privacy or consumer law.
- Velocity: this pass was not timed. It changed documents only.

### What was checked

1. **The Google Analytics setting could not be read.** The linked property is `pantas-prod`, ID 549551450, with one Android stream and one web stream (Firebase Management API, read-only). The retention setting sits behind the Analytics Admin API. The signed-in `gcloud` account lacks the Analytics scope (403, `ACCESS_TOKEN_SCOPE_INSUFFICIENT`). No sign-in was widened to get it.
2. **Google's page, read Nov 24.** A standard property offers 2 or 14 months, set separately for user-level data and for event data. "When data reaches the end of the retention period, it is deleted automatically on a monthly basis." "The data retention setting does not affect standard aggregated reports". "The data retention setting only affects explorations and funnel reports." The switch "Reset user data on new activity" restarts the period of the user identifier with each new event. "If you reduce the retention period, then any affected data is deleted during the next monthly process." A change applies after 24 hours.
3. **What the app sends.** One file sends events, and only when the user turns usage sharing on. It also sets the account ID as the Analytics user ID (`firebase_telemetry.dart:54`, `:75`, `:110`). No document in the repo names an exploration, a funnel report or a BigQuery export.
4. **The live text says "up to 14 months after your last activity"** (`legal_document.dart:214-215`). Sol High's Nov 22 finding 15 called that an overstatement of what the settings establish.
5. **Messages are emails.** The Privacy Policy defines them as "emails you send to support@pantas.study or dpo@pantas.study". In the Notice for teens the guardian's emails count too. Question reports are a separate record (R3, 90 days). Guardian answers on the guardian page are guardian evidence (R6), not messages.
6. **Refund records already have a period.** Both notices keep "tax books, receipts and refund records" five years outside the app (D8).
7. **M8 is a launch gate and its note is stale.** It reads "waits on BIR registration". The registration exists: the Certificate of Registration is dated Oct 29, 2026 (checklist L3 and L10). What is left is the invoice stock and the by-hand process.
8. Not checked: where the mailboxes are hosted and whether the host can delete by age; what BIR-approved invoice form he will use; whether the tax code lets small sales go without an invoice (Sol High's Nov 22 reading is that the Internet Transactions Act covers every sale either way); live behavior.

### B1. Google Analytics retention: two months. Gate on the console setting

- The property keeps user-level data and event data for 2 months, the shortest option. "Reset user data on new activity" is off, so an active user's identifier also ends at 2 months.
- The texts say, in Sol High's wording: "Google Analytics data about individual users and events expires after two months. Google deletes expired data in a monthly cleanup. Standard reports that combine data can stay available longer."

**Reason.** Two months serves the app. The setting limits only explorations and funnel reports, and Pantas uses neither. The standard reports, which hold counts and no user-level rows, keep working. Fourteen months would be chosen for year-on-year explorations, and no one has asked for one. The shorter period is also the easier one to defend under Section 11(e) and (f) for records that carry the account ID.

**Conditions.**

1. Before the texts publish, the console must show 2 months for both settings and the reset switch off, on property 549551450 (Admin, Data collection and modification, Data retention). The check is logged in the launch log. It is his console step, about two minutes, unless he grants an agent the Analytics scope.
2. If the console shows 14 months, set it to 2 months. Google then deletes the older user-level and event rows at its next monthly process. Standard reports are untouched.
3. If he wants 14 months, he changes the word in both notices at sign-off and sets the console to match.

**Sol High.** Must-fix, applied: the first wording named only event records and implied Google deletes all older data. The texts now name user and event data and say the combined reports can stay longer.

### B2. Refund reply time: three business days. His to confirm

- The Terms say "We aim to reply within three business days."

**Reason.** The law sets the real limit, not the Terms. A purchase complaint that is unresolved seven calendar days after filing counts as exhausted, and the buyer may then go to the DTI. Five business days is seven calendar days or more, so a reply on the last day arrives as that window closes. Three business days leaves at least two days to settle the matter inside it. The sentence is an aim, not a promise, so a missed day breaks no term.

**What it asks of him.** Read support@pantas.study at least every second business day. Forwarding it to the inbox he already reads does this with no new habit (checklist L5).

**His to change.** This is his personal commitment. He can set five at sign-off. Above five, the aim itself would pass the seven calendar days.

### B3. Message retention: two periods, deleted by hand once a month. Gate on the written procedure

- **Ordinary messages** (questions, account help, bug notes, feedback): deleted within 90 days after the matter closes.
- **Messages about a payment, a refund, a purchase complaint or a privacy request:** deleted within two years after the matter closes. This class includes a guardian's email that denies a purchase, and requests to see, correct or delete data.
- **The periods count from the date of the last email about the matter.** A matter with an unanswered request, a bank dispute, a DTI or NPC complaint, or a court case is held out of the count. The sentence already in both notices covers it: "We may keep other specific records longer when the law requires it or when we need them for a legal claim."
- **A refund that was paid** leaves a minimum record in the refund records kept five years (D8): date, payer name, payment reference, amount, route, transfer reference, and the last four digits of the receiving account. The full account number is never copied there. It leaves with the email.

**Reason.**

1. Ordinary messages follow R3. A question report is deleted within 90 days because it is useful for weeks, not years. An email asking for help is the same kind of record. A lesson learned from one is written down without the person's details, as R3 requires for reports.
2. The second class is evidence. Two years is the period for claims under the Consumer Act (Article 169) and for a damages claim or a DTI penalty case under the Internet Transactions Act (Section 28; JAO 24-03 Section 44), as Sol High read them on Nov 24. It is longer than a card dispute window. Sol High could not verify a filing deadline for an NPC complaint, so privacy requests take the same two years for one simple rule, not because a deadline sets it. The money facts live five years in the refund records, so the email does not need to.
3. Ten years (R6) is not used. R6 keeps the proof that a guardian allowed an account, which the app records itself. An email is the conversation around a record, not the record.
4. Risk accepted, as in round 6: a contract claim can be timely after the email is gone. The refund record and PayMongo's own records remain.
5. Sol High's biggest risk: the sweep deletes evidence of a claim that is still open because its last email aged out. Step 2 below answers it.

**Wording.** Sol High's, applied: the texts say the limits cover emails to both addresses and our replies, call the first class "other emails", and count from the last email instead of saying a matter "closes on" that day, which could read as silence ending a request. The Notice for teens adds the guardian's emails.

**The mailbox process (this is what "once the mailbox process exists" means).**

1. Two labels, put on the thread at the first reply: one for the second class, one named "hold" for a matter that is unanswered or under a dispute, complaint or case. Everything without a label is ordinary.
2. Once a month, at the monthly cost check, two searches: delete unlabeled threads whose last message is older than 45 days, and second-class threads whose last message is older than 23 months. The published limits then hold even when a sweep is a month late. A thread labeled "hold" is never deleted. Answer any unanswered thread before the sweep. Remove "hold" when the dispute ends. Empty the trash.
3. The sweep covers support@, dpo@, contact@ if it is in use, the sent replies, and any forwarded copy in his personal inbox.
4. If the mail host can delete by age, a host rule replaces the sweep. Not checked.

**Conditions.**

1. The manager writes the procedure in `docs/OPERATIONS.md` before the texts publish, next to the D8 procedure, and adds "sweep the mailboxes" to the monthly cost check beside "read question reports" (R3). About 0.25 hour. The same file still names `dpo@pantas.app` (line 76); the texts say `dpo@pantas.study`. Fix it in the same change.
2. The sweep is his step, about five minutes a month. They are his mailboxes.
3. He can change either period at sign-off.

### B4. Invoice sentence: publishes at launch, in the short form, once M8 is met

- The Terms say "Pantas issues a sales invoice for each web purchase." The words "and sends it to the email you give us" are dropped.
- If M8 is not met on the day the texts publish, the sentence is deleted before publishing and returns in the first Terms update after M8.

**Reason.** D3 kept the sentence out "until the invoice process exists (checklist M8)". M8 is a launch gate, and the duty starts with the first live sale whatever the Terms say, so the by-hand process must exist at launch. The sentence is then true on the day it publishes. It restates a legal duty and adds no new promise. Publishing it at launch also avoids a second Terms version, which would ask every student to accept again (checklist L7). The short form is Sol High's own Nov 22 wording. The dropped words promised a delivery channel, and a bounced email would break them.

**By hand until C (D3).** For each paid web purchase he writes the invoice from his BIR-approved stock, sends the buyer a clear photo or scan by email, and keeps the original with the books for five years. The TIN goes on the invoice and never in the repo.

**Conditions.**

1. M8 counts as met when he holds invoice stock the BIR accepts and has issued one real invoice for the small live payment in M3. The manager corrects the M8 note (check 7) and writes the by-hand steps in `docs/OPERATIONS.md` with the D8 procedure.
2. D3's trigger for the automatic invoice email stands: when he reports that invoices by hand are a burden.

### Publish gates added

| Claim in the texts | What makes it true |
|---|---|
| Google Analytics user and event data expires after two months | Console shows 2 months for user-level and event data, reset switch off (B1) |
| Emails deleted within 90 days or two years after the matter closes | The mailbox procedure is written and the two labels exist (B3) |
| "Pantas issues a sales invoice for each web purchase." | M8 met; otherwise delete the sentence before publishing (B4) |

### What needs Aedwon

1. The publication date.
2. Confirm or change "three business days" (B2). It is flagged in `change-summary.md`.
3. The console check in B1, the monthly mailbox sweep in B3, and the invoices in B4 are his steps. None is a decision.
4. NPC registration stays his. No text mentions it.

The numbers he can change at sign-off are now: two months (B1), three business days (B2), 90 days and two years for messages (B3), plus the earlier 90 days for reports and the ten and four years for guardian evidence.

## Nov 24, T16 B2 phone bar states

Ruled by a Claude Fable 5.2 agent, acting as the design sub-agent, under Aedwon's delegation (written rule 4). The rulings are final and are not queued for his sign-off. His visual pass still gates release (`WORKFLOW.md`).

- Asked by the CSE release lead for the T16 B2 build: three phone bar states no board draws (the flag under 370 px, the flag while looking back under 430 px, the count column's right padding at 4 px).
- Policy read at `origin/main` 0931a6fe0: `AGENTS.md`, `WORKFLOW.md`, `docs/workflow/process-improvement.md` rules 1 to 4, the UX ambition hand-off, the core loops build spec (B2, B5), and in this file "Nov 23, core loops polish".
- Boards read on the live canvases, Nov 24. Core Loops Best in Class: `canvas.json`, `B2_PhoneBar`, `B2_PhoneLong`, `B3_PhoneWrong`, `phone.css`. Pantas Redesign: `canvas.json`, `QV_Answer`, `QV_Last`, `QV_Flag`, `QV_GridBack`. `B2_PhoneBar` is on the Core Loops canvas, not on Pantas Redesign.
- D71 read: `docs/superpowers/plans/design-system-4/map.md` line 180 and the Nov 8 quiz family entry in the PWA launch log. Under 400 px the flag moved to the question header so that the bar's hint fit on one line. Aedwon approved it on Nov 8.
- Build read: `qa/core-loops-b2-r1` 3376c1db9 (bar code, track, tests) and the `bar_*_390_*`, `end_25_390` and `strip_25_390` renders. Widths below come from the 390 renders and from the app's Geist metrics. No Flutter run: the Mac's one Flutter slot was in use.
- Standards applied: WEB-L5 (adapts at 320 px and to text size), WEB-K6 (same component, same look), WEB-I10 (44 px touch targets), from `web-interface-design.md`.

### What the numbers say

- A phone needs 120 px plus the count column's content plus the button. The 120 is the bar's insets, the count's paddings (16 and 12), the 44 px flag and the two 16 px gutters. The boards and the build both total 120.
- Buttons: Check 86, Next 90, Finish 82, "Back to 4" 110, "Back to 20" 121, "Back to 120" 128.
- Ten marks are 107 px. The count line ("19 of 20" and its caret) is at most 86 px with two-digit numbers and 99 px with three.
- Twenty marks in one row are 217 px. With the flag and Check that needs a 423 px phone. The session lengths are 5, 10, 20 and all due, so a 20-question session is common. By the code, the build's one row of 20 overflows a 390 phone by about 25 px, even with the 4 px padding. No test covers it: the matrix has only 390 and 1440, and no bar test runs 11 to 20 questions.
- So the one long row is the cause of all three questions. The flag is not.
- With a track no wider than ten marks, every state fits at board values from 348 px up (355 for a session over 99 questions). Check, Next and Finish fit at 320.

### Rulings

1. **The flag stays in the bar on every phone, in every state.** It sits between the count and the button from 320 px up: before a pick, picked, checked, the last question, looking back, and the large-text stacked bar. The header flag is removed on this screen. No width threshold moves it.
   - D71 is retired here. Its reason was the hint line, and B5 removed the hints. `QV_Flag`, `QV_Answer` and `B2_PhoneBar` draw the flag in the bar.
   - Rejected: the header flag under 370 px. One control would sit in two places across phones.

2. **Looking back keeps the same bar.** The count shows the question in view, the flag acts on that question, and the button reads "Back to N". The 430 px threshold is removed.
   - This state is drawn: `QV_GridBack` shows it at 390 with the flag in the bar. With the threshold, the flag would jump to the header in the middle of a session on the reference phone.

3. **The track is never wider than ten marks. 11 to 20 questions make two rows.**
   - Ten marks on the first row and the rest on the second, left-aligned, in reading order. 3 px between the rows. Marks stay 8 x 4 with a 3 px gap. Colors, the 200 ms change and the spoken label do not change.
   - The phone layout always uses ten per row, at every phone width, even where one row of 20 would fit. The wide bar keeps its one row (`B2_WideBar`).
   - Why: the phone results row is already ten per row at 390 (`end_25_390`), so each track row lands as its own row of circles. The line over 20 questions is already "as wide as ten marks" (107 px). The bar's shape is then the same for every session length.
   - End flight: the marks fly from their real places in both rows. Timing, stagger and its 180 ms cap do not change.
   - Rejected: one row with narrower marks. On a 360 px phone 20 marks would be about 4 px wide, and on a 320 px phone they do not fit at all. Rejected: the line for 11 to 20. It removes the end flight from the 20-question setting.

4. **Count column right padding: back to 12 at 360 px and wider.** Board values hold there with no exception. The 4 px value was needed only for the one long row.
   - Rejected: a narrower Check or a smaller count. Neither frees enough room, and both change values the boards draw at 390.

5. **Under 360 px (320 to 359, which includes the 344 px fold cover): compact values for the whole session, in every state.**
   - Marks 6 x 4 with a 2 px gap, and 2 px between rows. Ten marks are 78 px. The line over 20 questions is 78 px.
   - Count column right padding 4.
   - The count text, the caret, the flag (44 px) and the button keep the board's sizes.
   - Worst case at 320: looking back in a 20-question session needs 315 px.
   - The values depend on the phone's width only, never on the state, so nothing in the bar changes size between pick, check and looking back.

6. **Last resort: the count column scales down as one piece.** If the row still does not fit, the track and count shrink together, left-aligned, only as far as needed. The flag and the button never shrink, and nothing clips or overflows.
   - This covers a session over 99 questions while looking back on a 320 px phone, and system text between 1.0 and 1.5 times on a narrow phone.
   - Above 1.5 times the stacked bar applies as it does today: the count and the flag on the first line, the button below.

### Checks, failing first

- New bar tests at 320, 344, 360, 390 and 430 px, with 5, 10, 20 and 25 questions, in each state: before a pick, checked (Next), last question (Finish), and looking back from the last question to question 19. Each expects no overflow error, the flag inside the bar, and no flag in the header. Add 320 px at 1.3 times text.
- The 20-question cell at 390 must fail on 3376c1db9 first. If it passes there, report the real widths to this agent before building: the two-row ruling rests on that overflow.
- Track tests: 20 questions give two rows of ten, 13 give ten and three, and `markRects` returns the two-row places.
- Build size, an estimate: about 0.5 day.

### Board changes (for the operations manager's reference canvas list)

- New derived phone board, Pantas Redesign and Core Loops: the bar in a 20-question session, two rows of ten (ruling 3). The end-flight boards need no change: they draw 10 questions.
- New derived phone board at 320 px: compact marks 6 x 4 with a 2 px gap, and count padding 4 (ruling 5).
- `QV_GridBack` and `QV_Flag` (Pantas Redesign) still draw the bar without the track. Add the track above the count, as on `QV_Answer`. The flag stays where they draw it. The other `QV_` boards with a session bar were not checked.
- `B2_PhoneBar`, `B2_PhoneLong`, `QV_Answer`, `QV_Last` and `phone.css`: no change. The count column's 12 px holds.
- Design system (the Pantas Design System canvas and the exports in `web-design/pantas-handoff/`): retire the D71 rule. That is the `bp-phone-narrow` token's use (400 px, "the quiz bar's flag moves to the question header"), the `.fbar__flag-alt` rule in `bundle.css`, and the D71 line in `design-system-4/map.md`. The new phone breakpoint is 360 px (ruling 5).
- No wide board changes.

### Spec lines these rulings change (for the spec's owner)

- B2, Track: add "Phone: ten marks per row; 11 to 20 questions make two rows, 3 px apart. Under 360 px: marks 6 x 4, 2 px gaps, the line 78 px, count padding 4. The flag is in the bar at every phone width."
- Acceptance check 3: add a 20-question session at 390 and at 320, and looking back at 320.

### What needs Aedwon

Nothing new. Rulings 1 and 2 replace D71, which he approved on Nov 8 for the hint line that B5 removed. The lead tells him this, and that a 20-question session shows two rows of marks. He sees both in his visual pass.

## Nov 25, UX design lead: week strip chip names for CSE (finding U14)

Decided by the UX design lead under written rule 4 (in-app copy inside an approved layout). Not a new look.

- Searched: Pantas Redesign `HP_WeekStrip`, `HP_WeekStripLarge`, `HP_WeekFrame`, `HE_ManyLessons`; Pantas Web `HM_NoContent`; ruling D196; finding U14 (`build/audit/ui-2-findings.md` in the qa/cse-release-r1 worktree).
- His board `HP_WeekStrip` (his pick B, D196) draws the phone chip with a short name, "CSE Pro". Live builds the chip from the catalog short name, "CSE Subprofessional", which does not fit beside the strip and wraps to three lines at 200% text.
- Ruling: the Home week strip chip says "CSE Pro" and "CSE Subpro", on phone and wide. Every other place keeps the catalog short name. All other exams keep their catalog short name in the chip. Day count and the 200% fallback follow D196 unchanged.
- Why "CSE Subpro": it follows the board's "CSE Pro" pattern and is the common Philippine shorthand. "CSE-SP" (`HM_NoContent`) is older and does not match the board's spelling.
- Arithmetic (board worker, Geist metrics): "CSE Subpro" makes a 141.7 px chip block, so four days fit beside it in the 340 px strip; at 200% text the chip goes under the strip with four days.
- Drawn: canvas "Loading, Reader Line, Week Strip", page 3 Week strip, https://claude.ai/artifact/MQxxjEmiWjbzwUqaF8h9Ec

## Nov 25, UX design lead: his answers to the loading, reader and week strip board

His words (Nov 25, about 1:35 AM Manila, relayed by the manager in full): "i think B makes sense because the industry uses it and it's more familiar and what users expect. is it possible to add a % number?
i don't understand the reader line, i just wanted you to maybe remove the lesson indicator on top because it gets so long when there's a lot of lessons in a certain topic, and especially so after the instruction to make the lessons bite-sized. for the thing that indicates how far along you are in the lesson itself, no changes
also what is this in the week strip?" (with a screenshot of page 3, frames drawn as plain serif text in white boxes).

Board: https://claude.ai/artifact/MQxxjEmiWjbzwUqaF8h9Ec (version 6).

### 1. Loading: B picked; a real percent is possible

- His pick: B, the small spinner under the wordmark from 1.5 s.
- Finding: prod serves the app files brotli-compressed through Cloudflare with no Content-Length (checked Nov 25 on `main.dart.js`, `canvaskit/chromium/canvaskit.wasm`, `flutter.js`), so the browser alone does not know the total. Wire sizes about 2.2 MB each for the two big files; decoded 7.6 MB and 5.8 MB.
- How a real number works: the page already waits for the app's service worker (`pantas_sw.js`) to take control before Flutter starts, so every app file passes through it. The worker can count the decoded bytes it passes on, and the build can write the decoded size of each file the loader fetches before the first frame. Percent = bytes received / that total. Both are measured, so it meets "Never invent a figure". Files already in the worker's cache count as received at once.
- Limit he must know: the splash shows only on return visits (first visits get the Welcome screen, and the worker does not yet control a first visit). On most return visits the files are already on the device, so no number shows. The number appears on the first open after each update, or after the browser clears its stored files. It covers only the download: after 100% the app still starts up (seconds), so the number hides and the spinner stays.
- Lead design (drawn as "B with %", page 1 rows 5 and 6): the number sits 8 px under the spinner, 13 px phone and 15 px wide, medium weight, secondary text color, tabular figures; it shows only while bytes are arriving and hides at 100%. Reduce Motion: "Loading 0%" counting up in the existing label spot, then "Loading". Waiting on his look before any build.

### 2. Reader: remove the lesson dashes at the top (wide web)

- What he means: the wide reader top bar draws one 18 x 4 px dash per lesson in the topic (or plan day) beside "3 of 6". It grows with the lesson count. The phone reader has no such row: its top bar shows a short "2 of 5" only for plan days, and the phone progress rail is the in-lesson progress he said not to change.
- Ruling: remove only the dash row. Keep the lesson title that fades in on scroll, the "N of M" text, the chevron and the lesson list it opens; the "N of M" text is short and is the only way into the lesson list from the top bar. The section line under the bar (in-lesson progress) is unchanged. Phone unchanged.
- The reader line options A, B and C are retired on the board (page renamed "2 Reader line (retired)").

### 3. Week strip frames rendered unstyled

- Cause: each page 3 frame imported the strip part but did not load the stylesheets in its own head. The design canvas loads stylesheets only from the frame being shown, not from an imported part, so the frames fell back to the browser's default serif. His own boards (`HP_WeekStrip`, `HP_WeekStripLarge`) carry the three stylesheet links in the frame, which is why they render.
- Fix: the strip part is now a copy of his `HP_WeekFrame` with the chip name as the only new input, and every frame carries his three stylesheet links; the stylesheets are copied server side from the Pantas Redesign canvas (they were already byte-identical). The invented greeting line under the strip is gone. No design change: the chip names follow the U14 ruling above.

Later the same day (manager): section 3 dropped. He never raised the week strip and D196 answers it, so page 3 was removed from the board (version 8) instead of redrawn. The U14 build is the CSE release lead's, already merged (PR #118).

Later (Nov 25, about 3:15 AM Manila), his words on the loading board: "i imagined the spinner and the % text to be on the same line. get a Neon and codex opinion on this". Both advisors (relayed by the manager): one line, spinner left, percent right, 8 px gap, 13 to 14 px medium, fixed-width digits, 40 px under the wordmark. They differ at 100%: A (Gemini Neon) keeps the row centered and closes the number's width over 220 ms so the spinner glides back to center; B (Codex) keeps the spinner fixed at center with the number in a fixed slot to its right, so nothing moves (Codex's stated risk: right-heavy). Reduce Motion: A "Loading 42%" on one line; B "Loading" with "42%" beside it. Both drawn on page 1 of the board (version 10), phone and wide, light and dark, plus Reduce Motion; the stacked percent rows are retired. Waiting on his pick; nothing built.

## Nov 25, UX design lead: paused review sheet bugs and the T9 rows with no board (E-155)

Manager brief, his words (Nov 25, about 3:40 AM Manila): "i've reset limits, please continue finishing UI". Policy read from main at 3ed9828f8.

### Paused review sheet

- (a) "0 of 11", an empty ring and "Start Reviews" for a Reviews session paused at 1 of 11. Root cause: Home stays alive behind the tab bar (indexed shell) and reads its question counts and prepared work only when it loads or when the plan copy changes. A Reviews session started or paused from the Quiz tab does not change the plan, so Home kept the counts it read before the session began. Fix: leaving a quiz part way through publishes a pause revision; Home reads its questions again on it (the plan stays on screen meanwhile). Test: `home_today_refresh_test` "a quiz paused in another tab makes Home read its questions again" fails on the old code.
  - Not fully explained: the generic "You paused a quiz" notice needs the start to find no Reviews batch, or a second open session. The repository reproduction (stale work, same paused session) resumes the session instead of refusing. His two screenshots are IMG_2843 (Home, 7:18 PM) then IMG_2844 (Quiz tab, later), so at 7:18 another quiz may have been paused and the notice correct. Leads should not cite this as proven to be the same session.
- (b) Close on the phone Reviews sheet: already removed on main by the borderless buttons change (Nov 24, shipped 9:50 PM Nov 24) and guarded by `sheet_close_rule_test`. His screenshot predates that ship. The wide panel keeps the close glyph at its top right, which `HM_ReviewsPanel` draws (`aria-label="Close"`). Nothing to build.

### T9 rows with no board (37 rows, PR #117 map)

Search per row: `build/audit/t9-noboard-search.md` in the UX lead worktree (Sonnet worker, read only; the lead reviewed every row). Searched for every row: the exports in `web-design/pantas-handoff/` (mobile and web), live Pantas Web for W_ReaderPart, HM_ReviewsPanel and MK_Proctor, `docs/design/DECISIONS.md`, this file, the PWA launch log, the Nov 23 folds record, `docs/ui-audit.md`, `docs/pricing.md`, component READMEs, handoffs Nov 22 to 25.

Answered by a source (build): LI1 phone floating bar 60 high, radius 30 (every QN_* phone board; the token and README say 64); LI3 wide report Cancel and Send 40 high, radius 10, 15 px label (QN_Report web); P17 phone answer keys a bare 15/700 secondary letter in the 30 px column, no circle (QV_MissPro, MK_ReviewQ, QV_Last); U17 no "Saved on this device" hint in the wide mock bar (MK_FiveMin, MK_LastMinute web, MK_Proctor); U22 no "5 min left" tag on the clock (MK_FiveMin, MK_LastMinute; the proctor line and the semantics value carry the words); U23 no header row on wide Performance lists (PF_Subjects, PF_Topics, PF_Lessons web); U29 exam picker error and empty copy and Retry (O_Picker, OB_PickerError, OB_PickerEmpty); U37 header "Text size" (ST_Appearance); U38 tier dialog copy and buttons (CX_TierDialog); U49 the wide drawer footer button full width (HM_ReviewsPanel; the board for the screen beats the general HANDOFF line); U72 no button screen before the paper (HANDOFF line 22), keeping the L_Rules Steps screen, with a stop if the button carries the clock start or a browser gesture; U90 the last minute red (DECISIONS line 187, MK_LastMinute).

Undrawn, no new look (lead decided, build): P11 remove the unused phone Today tap parameter (DP_Drill draws no tap); U25 a day before the plan began shows "No plan on this day." in the PL_DayPast sub line style; U21 a one-block paper (CSE) drops "in this subject": the proctor line reads "5 minutes left." (copy under D191); U26 Pro page loading and error use the skeleton and `StateView` (SY_Error); U32 phone install card copy follows OB_Install: "Keep Pantas one tap away" and "Add it to your Home Screen. Your progress stays the same." (drops the unmeasured "opens faster"); U36 About row names in sentence case as ST_About draws them ("Privacy policy", "Terms of service"), consent wording untouched (legal pause); U40 zero-answer discard uses the MK_Discard dialog with "You haven't answered anything yet. This attempt won't appear in your record, and it doesn't use up a mock attempt."; U52 the wide reader end-of-part quiz button uses `WebButton` secondary, the design system's grey button that matches the phone RD_End fill; U78 sidebar avatar and name show the Skeleton until settings load; U81 the Performance skeleton matches PF_Subjects; U86 keep "Continue with Email" (drawn), the Email row uses the ST_Account "Signed in with" row; U91 the web save-failure line sits on the existing toast surface.

New look, for his board: U24, the wide Home checklist footer band when no measured time exists (the boards print "About 45 min today"; the build cannot, under never invent a figure).

No choice now (left off the board): LI2 each timing matches its own approved board; LI9, P7, P25, U20, U27, U33, U69, U84, U85 Pro, store and charge surfaces wait on the paused payments and legal lanes; U36 the "Send speed and error reports" toggle is consent wording (legal pause); U28, U89 and U86 "I'm 18 now" wait on the paused under-13 lane. P7 and P25 were proposed as board items by the worker; the lead moved them here because both are store surfaces.

### Nov 25 (later), T9 build corrections (UX lead)

- U52: the wide reader end-of-part quiz button uses the design system's `neutral` grey button (the RD_End fill), not `secondary`, which is the teal tint. The ruling's word was wrong; the intended look (grey, as the phone RD_End) stands.
- U72: kept. "Start the Paper" starts the attempt and its clock ("The clock starts when you tap"). Removing it would start a timed paper without the student's tap, which changes timing behavior, so the HANDOFF line 22 removal does not apply to this screen. No change.
- Tokens: the phone floating bar is `size-bar` 60 and `radius-bar` 30; the wide bar keeps 64 as `layout-bar-wide` and `radius-bar-wide` 32 (the size family is at its 60-token cap); the wide report buttons use `radius-report` 10. Values edited in design/system/tokens.json and generated, not hand-edited.
- U86: not built. The signed-in user carries no sign-in provider, so a "Signed in with" row would say "Google" for email-link users. It needs that field first; no new look and no choice for him. Left for the account lane.
- U26: the Pro page loading state shows skeleton tiles; a failed passes load uses the shared error view with its existing "Could not load your passes." (more specific than the SY_Error line, same look).
- U49 and U38: already matched their boards on main; tests now guard them.

### Nov 25 (later), paused option A: the Quiz tab card is held; the sheet ships

- Manager hold (Nov 25): Aedwon is asking about button placement on the Quiz tab paused card, so the card (phone and wide) is held, unchanged from live. Board A draws the wide card with no caption and "Discard this session" then Resume at the right end of the foot (the patterns rule: a right-aligned row, secondary then main). Built and held on `ux/paused-review-a-r1` (with the Discard spacing from before Nov 24); the shipping branch `ux/paused-sheet-a-r1` carries only the Home and Quiz tab Reviews and New questions sheets.
- His wide screenshot: Reviews "0 of 11" with "Questions due today" under it while paused. The paused quiz was not a Reviews session (most likely "Practice this topic" or "Practice weakest topics", which start through the older today path with no Reviews batch), so 0 of 11 is the true count. The card never says which quiz is paused: a copy gap inside board A's layout, settled under rule 4 (manager agreed): when the paused quiz is not the Reviews or New questions session, the card shows one line above Resume, "Paused: <quiz name>" ("Paused: Algebra practice", "Paused: Weakest topics practice", "Paused: Flagged questions"). No line when the rows already show the paused session. Reason: the shortest line that names the quiz Resume will open; his guidance is compressed text. Built with the held card.
- The same case explains his 7:18 PM Home sheet (generic notice, 0 of 11): another quiz was paused. Board A's "another quiz is paused" state now covers it on the sheet: "Finish or discard your paused quiz first." over a dimmed Start.
- Released (Nov 25): his words after the wide and phone sheets, "yes A lgtm, go ahead with it". The card ships to board A with the spacing from before Nov 24 (20 above, 24 below the Discard text) and the "Paused: <quiz name>" line, on `ux/paused-card-r2` (on top of `ux/paused-sheet-a-r1`).



## Nov 25, about 3:50 AM Manila: his picks on the loading and paused-session boards

His words, verbatim (relayed by the operations manager):

> 1. A
> 2. okay with A. the space on top and bottom of discard in the quiz tab got too small though

- Loading board (https://claude.ai/artifact/MQxxjEmiWjbzwUqaF8h9Ec): A, Neon's centered row. The spinner and the percent share one centered row; the spinner slides back to center when the number hides. Build 1:1 to the board: real decoded bytes counted in the service worker against a size list made at build time, Reduce Motion as drawn.
- Paused-session board (https://claude.ai/artifact/9MLsiFtEwsdLodfe8eHZig): A. Build 1:1 on the Home Reviews sheet and the Quiz tab card, phone and wide, on top of the E-155 sheet fixes. The board's "another quiz is paused" row (lead decision on that board) comes with it.
- Discard spacing on the Quiz tab card: build to board A, compared with the version before the Nov 24 Discard centering and the Nov 25 spacing ship; a golden test guards it (process entry, Nov 25).
- U24 (manager ruling, Nov 25; not put to him): the wide Home checklist footer slot the boards fill with "About 45 min today" shows what is left as real counts, "2 lessons, 18 reviews left" (zero kinds left out, singular for one; "The mock comes first today" on a mock day; empty when nothing is left). Reason: "Never invent a figure" already forbids the time estimate, so removing it is a fix, and the replacement line sits in the existing footer slot, so it is copy inside an approved layout, ours under rule 4 and the Nov 25 process entry. The UX lead's board (https://claude.ai/artifact/A9vWJxf5HnvrvpAtT3xYYq) was a mistake for that reason and is retired unused.

- U24 ruling of Nov 25 WITHDRAWN (manager, Nov 25): Aedwon decided the footer on Oct 31, "Leave it out" (launch log, Oct 31 entry). The footer keeps only the button. The counts line is not shipped.

## Nov 25, UX design lead: wide button placement, code only (E-158)

His words (about 7:25 AM Manila, relayed by the operations manager): "i think the button placement sweep is excessive, isn't there a faster way to determine that without using screenshots", then "okay proceed" to a code-only scan. Rule: design/system/patterns.md, "Button placement" (P2, his pick Nov 7: "go with P2"). Branch `ux/button-placement-r1`.

Search done before each ruling below (process entry, Nov 25, "rulings name their search"): the launch log (`2026-10-19-pwa-launch-log.md`), this rulings file, patterns.md and `docs/ui-audit.md`, for: placement, P2, right end, main last, secondary then main, left-aligned, button order, reversed; and per screen: Take the Exam, View Last Results, QZ_Mock; guardian confirm, I Don't Agree, G_*; Change Exam Date, now studying for, L_ChangeExam; Every Day, I don't know, OnboardingActions; ST_Pro, Restore Purchases; Select All, bookmarks; Add Note, note editor; install card; Start Session, session results; Discard This Mock; Switch Exams, ExamPassed; Continue with Email (and the Nov 10 "Staging Check Fixes" board, S1_Account, option A he chose); MK_SetupCSE, MK_SubmitCSE, practice picker; drawer foot, HM_ReviewsPanel; Use Google Instead, Use a Different Email. His decisions found: P2 (Nov 7); Account signed out option A (Nov 10); board A for the paused Quiz tab card and the Reviews drawer (Nov 25, "yes A lgtm, go ahead with it"). Nothing else of his covers these screens.

Scan: 32 wide button groups and 7 wide full-width single buttons (Sonnet worker, code only, lead reviewed every violation in the code). The full table with file and line is in the handoff note.

Fixed (each with a wide test that failed on the old code):
- Quiz tab mock card: the action spanned the card (and Change the Setup sat under it, left). Now at the card's right end at natural width, card size 44, Change the Setup first in the same row. The phone board drew a full-width button; the wide card had no board after Nov 7, so the pattern wins.
- Guardian confirm and waiting (wide): stacked and centered, main first. Now one row at the column's right end, secondary first, main last, 8 apart. patterns.md names guardian confirm. A single action on these pages stays centered (centered layouts).
- Settings exam change confirmation (wide): the phone board's stack (L_ChangeExam2, 390 wide) showed on wide, main first. Now one centered row, Done then Change Exam Date. No wide board draws this state. The phone keeps its stack.
- Gaps to 8 px: Account signed-out footer (12; the Nov 10 board he chose places the pair in the footer but does not state a gap, so the pattern's 8 applies), session results (12), mistake note editor (4), paused mock (12), Home passed card (12), Home notice (12), install card (10).

Kept, his decision wins over the pattern:
- Quiz tab paused card: 16 px between Discard and Resume (board A). Listed as the one exception in the check.
- Reviews and New questions drawer foot: full-width Start or Resume with Discard centered under it (board A, his pick).

Kept, the pattern allows it: Pro page bottom bar (patterns.md puts Restore Purchases at the left of that row); Settings ghost rows at the left; onboarding footers (the main action stays bottom right; the ghost alternative at the left like Back); bookmarks selection foot (a caption between Select All and Remove, a toolbar, not a pair); sign-in forms (one main button with a text link under it).

Found, not fixed (single buttons, outside the pair scan; for the manager): wide full-width buttons in the mock setup column (MK_SetupCSE), the practice picker panel, the mock paper's Submit (MK_SubmitCSE), and fixed-width Get Started (onboarding welcome) and Done (session results). patterns.md says side panels put the action at the bottom right at natural width, and the boards that drew 100% are older than the rule.

Check: `test/helpers/button_placement.dart` reads the laid-out screen and fails on a wide pair whose main button is not last, whose gap is not 8 (board exceptions listed with his approval), that is stretched, that sits neither at the right end nor centered in its box, or that is stacked phone-style; and on a lone button spanning its box. It runs on every wide screen golden (`screen_harness.dart`) and in the tests above. Shown failing on the old mock card (5 states), guardian (2) and exam change (1) before the fixes. Tuned on the 32 screen goldens: filter chips were false alarms (choices, not actions) and are left out; a card foot band with no text is judged by its padding; the Home golden showed the phone card at 1440 because the card ignored the test's web override, fixed in the card (no change on the real web).

## Nov 25, UX design lead: wide full-width single buttons (E-162)

Manager ruling (rule 4), relayed in the brief: "Search done: I searched the launch log and the rulings file for "full-width" and "full width". No decision of his covers these single buttons. The boards that draw them (MK_SetupCSE, MK_SubmitCSE, onboarding welcome, results) predate his Nov 7 placement rule. Under the Nov 25 process entry, the pattern wins over an older board. His request also covered "the CTAs in general" (Nov 25, 4:35 AM)." His words (Nov 25, about 4:35 AM Manila): "was this never addressed? particularly the placement of discard resume (basically the CTAs in general)?". Rule: design/system/patterns.md, "Button placement" ("Never a full-width button on a wide screen"; centered layouts; side panels and drawers; results pages) and design/system/README.md decision 149 (fine print right-aligned under its button on wide).

Built on `ux/button-placement-r2`, wide only, phone unchanged:
- Mock setup column, "Start the Mock Exam": right end of the column at natural width; "The clock starts when you click." right-aligned under it (decision 149).
- Practice picker panel, "Start": the panel's right end at natural width.
- Mock paper side panel, "Submit the Exam": the panel's right end at natural width.
- Onboarding welcome after Back, "Get Started": centered at natural width (was stretched to a fixed 260 px box). The first-visit HTML welcome is not touched.
- Session results, "Done": top right, level with the title. Lead decision on a state no board draws (search: this rulings file and the launch log for "session results", "Session finished", "Start Session", "Done"; patterns.md results rule): the title and its line stay centered, because the page is a centered layout (gauge, answer dots); Done sits at the title line's right end; "Start Session N", when there is one, stays centered under the duration line at natural width (centered layout, single action). Both keep their 1700 ms fade.

Kept, his decision wins over the pattern: the Reviews and New questions drawer's full-width Start or Resume (board A, "yes A lgtm, go ahead with it"). It carries the key `drawer-foot-start`, the check's one full-width exception.

Check: `test/helpers/button_placement.dart` now also fails any wide button built with `expand: true` (its width set by its parent: a column, a panel or a fixed box), unless listed in `boardFullWidth`. The painted-box test had missed all five: three sit in columns with no painted box, two were stretched to fixed boxes. Shown failing on today's code: the mock setup and session results screen goldens at 1440 ("is full width (440 px ...)", "(192 px ...)"), and the new wide tests for the picker, Submit and Get Started (worker report, below in the handoff).

## Nov 25, UX design lead: first run guided taste board (E-165)

His words, verbatim, Nov 25 (relayed by the manager):
- 2:15 PM: "i think we have a missing 'tutorial' step in the onboarding, a sort of getting users to try the core features but guided, if you know what i mean. do you understand this? so that they don't need to go through a long assessment / i think this would help hook people into the app more. wdyt?"
- 2:45 PM, after three advisors (Gemini 4 Neon xhigh, Codex GPT 6.2 Sol High, Fable 5.2) answered: "i want it before launch but i think we should still require the assessment for more accurate display of score in the home / a taste of the app is the purpose so that they get it, but for the further stuff, like overall accuracy display, an assessment is still required. the point of why i raised this is that so users try out the core features of the app (studying > quizzing) before they commit to a long test, but the long test still is required to get better accurate results. we can add their trial score too if you think that can help"
- Later, before seeing the board: "someone can optionally skip the tutorial / after it, they should be at Home greeted by take the assessment as it is now"

His call overrides the advisors: all three advised making the assessment optional; it stays required for the score.

Decided by him (drawn as the design, not options): the taste has a Skip. After the taste, finished or skipped, Home opens as it does today, with the "First, a short assessment" card.

Searched before the rulings below: Pantas Redesign and Pantas Web boards O_Name, O_Days, O_Picker, OB_Welcome, OB_Name, OB_Days, OB_Picker, HE_BeforeAssessment, HM_BeforeAssessment, AS_Question, AS_Leave, AS_Results, QN_Correct, QN_Wrong, QV_EndLowB, QV_EndPerfectB, QS_EndLow, QS_EndPerfect, RD_Real, W_Reader, DK_Home, DK_Reader, DK_Quiz, HM_DayStart; specs `2026-05-11-assessment-flow-design.md` and `2026-05-16-onboarding-exam-selection-design.md`; decisions, specs and handoffs on main for "tutorial", "guided taste", "trial score", "first win" (no hits). No board draws a taste or answers how its answers count.

Lead rulings (rule 4):
1. Taste answers do not count toward the assessment. The assessment keeps its length (up to 30 questions) and leaves out the taste's questions so none repeats. Why: the taste questions come minutes after a lesson on the same topic, with the explanation shown after each, so they measure short-term recall, not where the learner starts (learning versus performance, Soderstrom and Bjork 2015 review; strong). His stated priority is the accurate score. Fable advised reusing them to shorten the test; not followed for that reason. Cost: the assessment is not shorter.
2. Trial score: shown once, on the taste's end screen, in the approved session-end form ("2/3 correct", QV_End and QS_End boards), never a percent or a readiness figure. Home's card stays as it is now (his words). Taste answers enter no score and no Accuracy figure. The lesson counts as read.
3. The taste is one bite-sized lesson, then 3 questions, each followed by its explanation (his "studying > quizzing"; advisors said 2 to 8).
4. Skip: a "Skip" text button at the right of the header on the intro and every taste screen; it goes straight to Home with no confirm, since nothing is lost. Esc does the same on wide. The taste has no Close.
5. Intro screen after setup: "Try Pantas first", "Read one short lesson, then answer 3 questions. You see each answer right away.", Start (main) and Skip (ghost), following the onboarding step layout. The end screen keeps the session-end layout and its Done (results-page placement in patterns.md).
6. Reduce Motion: the end count shows its final number at once; reader and quiz screens follow their boards' Reduce Motion.

Open for him on the board: (a) which lesson the taste uses (a fixed starter lesson, recommended, or the learner picks a subject); (b) leaving the assessment loses progress (below).

Problem found in code (main at the time of this entry): the assessment holds answers in memory and saves only after the last question. Leaving through the dialog ("Your answers so far won't be kept. You can start again from Home."), browser Back, a reload or closing the app loses every answer. With the assessment as the one gate to the score, this is put to him as a choice: keep, or save answers on the device and resume from Home's card (recommended).

Board (E-165): https://claude.ai/artifact/D3JLTrRGiN8vjnfLrbhoMN (private until he shares it). Refinement of ruling 4 after review: the intro screen's Skip is the ghost button under Start (phone) or before Start (wide); the header Skip is on the lesson and question screens only, so no screen shows two Skips. The wide Home frames and the wide leave dialog follow patterns.md and the live app (assessment button at the right end; Keep Going, then red Leave), not the pre-Nov 7 board order.

## Nov 25, link-preview image without the beta mark (UX design lead, E-169)

Manager brief: replace the link-preview image's beta mark; the manager ruled Nov 25 that a replacement is a new look and needs his pick.

Searched before the rulings below: Pantas Web and Pantas Redesign (all board titles; SP_Splash, SP_WebBStill, SP_PhoneBFade, QA_Splash, QA_SplashBLight, O_Launch, WR_Share), Splash Hand-off, Home Screen Icon, Pantas beta sign-in, Pantas Website, the handoff exports, the launch log, this file and the CSE release checklist (G4 row 18). No board draws a link preview or a 1200 x 630 frame; SP_Splash draws the approved brand lockup, which fits.

Lead rulings (rule 4): the image is the SP_Splash lockup at twice its wide size (mark 240, gap 40, wordmark 84) centered on #F5F5F7; no tagline; alt text "The Pantas logo". Single design, for his pick.

Board: https://claude.ai/artifact/8emGUsKPxKrkpqd1rHi2sw (private until he shares it). Handoff: docs/superpowers/handoffs/2026-11-25-link-preview-image-board.md.


## Nov 25, UX design lead: wide "Use Google Instead" inside padding (E-170)

His words (about 9:10 PM Manila, wide dark sign-in screenshot): "also i saw this, tell me if you can see the problem".

Search done before the ruling: the "Pantas beta sign-in" canvas (https://claude.ai/artifact/EDnTTuSJPmCFPcDR3acEeJ, boards Laptop and LaptopCode, the only laptop sign-in boards; BDesktop is a superseded option), the handoff export `web-design/pantas-handoff/` (OB_SignIn, ST_AccountOut, ST_AccountOutPart, ST_AccountOffline; none draws "Use Google Instead"), the "Beta results email review" canvas (no sign-in boards now), patterns.md and the Button README, this rulings file, `docs/ui-audit.md`, the launch log and the Nov 22 QA findings, for: Use Google Instead, Use a Different Email, SignInTextButton, U46, natural width, .btn3, text button padding.

What the boards draw: Laptop and LaptopCode draw both text buttons 44 high, full column width (420), transparent, teal 16/600, content centered with a 10 gap after the 18 px Google mark, radius 12, a light tint on hover. U46 (Nov 22) moved them to natural width under P2 ("never a full-width button on a wide screen"), but kept the zero padding the full-width version had.

Ruling (rule 4, a state the board no longer draws): natural width stays (P2); the button keeps the design system's wide text button padding, 14 on each side (Button README, `.btn3`), and stays centered under Continue. Height 44, gap 10 and the hover tint are unchanged. Phone unchanged (full width, content centered). Every use of the shared sign-in text button gets it: "Use Google Instead" (email step), "Use a Different Email" (code step and expired code). No other button in the app had the same zero padding with a hover box (searched every zero-padding TextButton in lib/; the rest are inline links with no fill, fixed-size picker rows, calendar cells or icon buttons).

## Nov 25, UX design lead: first-run board revision (E-176)

His words (about 9:36 PM Manila): "don't call it taste finished. why even call it that - that's an internal term", "so much space unutilized" (phone "Try Pantas first"), "also please improve text copy - remove redundancies, remove unnecessary text/info", "for the choices, go with your recommendations".

His picks (from the recommendations): lesson A, one fixed lesson per exam; assessment progress B, answers saved on the device as you go, Continue on Home's card.

Lead rulings (rule 4; search: this rulings file's E-165 entry, the E-165 handoff, patterns.md Button placement, the canvas's own approved-board frames RD_Real, QN_Correct, QV_End and QS_End):
- No user-visible "taste", "trial", "starter", "tutorial" or "guided"; the canvas is renamed "First Run". The overline "Try Pantas" next to Skip stays on the lesson and question screens.
- "Try Pantas first": the eyebrow and the description line are removed (the title and the steps say it). Three numbered steps fill the screen: "Read a short lesson" (a static crop of the reader: overline, title, first Core Concept sentence), "Answer 3 questions" / "Each answer is explained." (a static crop of the question: stem and two choices, one marked right), "Get your score from the assessment on Home". No illustrations, no durations. Start and Skip stay stacked at the same width and 52 height (the Nov 25 stacked-pair rule).
- End screen: "You finished the lesson", "2/3 correct", "Take the assessment on Home for your score and study plan."; "in 2 minutes" removed; on wide, Done top right level with the title.
- Lesson end button: "Answer 3 Questions".
- Home's Continue card reads "8 of 30 answered." (the leave dialog already says answers are saved on this device).

Board: https://claude.ai/artifact/D3JLTrRGiN8vjnfLrbhoMN, version 1795614653-2f1d. Fresh Sonnet reviewer: one headless render, no unstyled or clipped frame, no internal term outside one exact quote of his in a note. Reviewer findings not taken: "Skip should be a filled secondary button" (patterns.md allows a ghost secondary under the main one, and it already shares width and height); differences inside his unchanged approved frames (math spacing, sample dates) stay as the boards draw them.

## Nov 25, UX design lead: first-run build, states no board draws (E-179)

Board approved Nov 25 about 10:50 PM Manila ("okay lgtm!", revision E-176). The 19 lead rulings for undrawn states (where the run starts, who sees it, the fixed lesson and questions 0001, 0003, 0002, the shown lesson sections, Check before the explanation, Back, Skip and Esc, resume after reload, offline, Pro, the wide lesson link, the wide mistake row, nothing recorded, assessment progress saved on each pick, the Continue card on every surface, the teal non-destructive Leave, stacked pairs, Reduce Motion, screen names) and the searches behind them are in `docs/superpowers/plans/2026-11-25-first-run-build.md`, "Lead rulings for states no board draws". Board wording kept where the manager's brief paraphrased it: the end count reads "2/3 correct" as drawn, not "2 of 3 right".

## Nov 25, UX design lead: support email row in Settings (E-179, manager request)

His "ok" (relayed by the manager) to support@pantas.study shown in Settings as the support channel; the in-app Feedback row was removed Nov 25 (5ee53ce56).

Searched: every Settings board in `docs/design/boards/` (ST_*, 74 files) for "support", "contact", "help", "mailto" and "pantas.study"; hits only ST_About ("Get in touch": Send feedback, Facebook group; "Contact our data protection officer", which opens the mail app) and ST_Privacy (points to that officer row). No board draws a support row.

Ruling (rule 4): About, first row of the board's "Get in touch" group, above Send feedback: "Email support", value "support@pantas.study", the same value row as Send feedback, opening the mail app with an empty message like the officer row (external icon on the phone, none on wide, as both rows do). Why: the plainest existing row style, in the group the board already uses for contact, with no new component. The address comes from the seller facts constant, so it stays the one address the app shows elsewhere.


### Nov 26, UX design lead: side-by-side review rulings (E-179)

A fresh Sonnet reviewer rendered every board frame headless at 390 and 1440 and compared it with the CI goldens: 18 must-fix and 9 minor. All must-fix and minor M1, M2, M5 and the focus move were fixed. Kept by lead ruling: the explanation label "Correct answer" (the design system's Explanation README governs over the board's lowercase, which copied an older board); the Home Continue button keeps the live card's size (same component as the live "Start Assessment" card); the leave dialog keeps the shared dialog's width; the intro previews stay static crops as drawn, with a test that ties them to the content source. Phone bar right arrow in dark uses the dim text color, since the board's #1D1D1F on the dark page fails contrast.
