# Engineering restart decision log

Controlling document: `docs/superpowers/2026-10-05-engineering-restart-strategy.md`.
Policy revision read: `origin/main` at 23c48fea.

## October 5, 2026: restart decisions

Context: the lead presented the restart strategy with four decisions: lift the pause, the base
branch, the complexity level, and whether the uncommitted documents on main are final. It also
asked how to handle screens with no design board.

Naming. Aedwon: "yep just call it "the new design"". The handoff's name "Clarity" is no longer
used in project writing. The existing commit subject keeps it.

Exact comment:

> approved on the cleanup/deletion just make sure it really is not needed anymore
>
> i hereby lift the pause for the items you enumerated. just to clarify the content audit ongoing
> rn is unaffected right? i've made the content audit very very comprehensive so it's gonna take a
> while, but it shouldn't affect the other parts that much
>
> okay you can use the roadmap branch since it's kinda where everything is consolidated anyway
>
> go balanced
>
> no need to show me those screens. a lot of them share the same design so I can already imagine
> what other screens look like on dark mode without the design explicitly showing me

Resulting decisions:

1. Cleanup approved. Delete only branches, worktrees and stashes verified as fully contained in
   the roadmap branch or main, with nothing uncommitted and no active task depending on them.
   Anything uncertain is kept and reported.
2. Pause lifted for: the new design work, the two pre-beta fixes (subscription cancellation,
   short public ID), and merging the question-qa-r2 code. Everything else stays as it was.
3. Base: a new integration branch from `web/roadmap-engine-r1`.
4. Complexity: balanced (strategy Part B, B3).
5. Screens with no board, including dark mode outside the main screens: the lead builds them
   from the shared design rules without a visual companion preview. Aedwon waived the preview.
6. The content coverage audit continues on its own track, unaffected.

Still open: whether the three untracked documents and the log change on main are final, and the
handoff questions in strategy Part B, B4.

## October 5, 2026: cleanup performed

Every item below was verified by a worker and rechecked by the lead: tip contained in `origin/web/roadmap-engine-r1` (1f79d880) or `origin/main` (23c48fea), worktree clean, not protected. Nothing with uncommitted or uncontained work was removed. All three stashes were kept: each holds content found nowhere else.

- Removed 4 clean worktrees: release-e2e-r1, web-e09-qlp5-prepared-next-r1, web-e09-security-performance-verification-r1, web-release-e2e-r1.
- Deleted 81 local branches.
- Deleted 98 origin branches. Six contained origin branches were kept because a dirty worktree still uses them.
- Kept for a later decision: dirty worktrees (beta-final-verification-r1, e04-content-protection-r1, detached qlp5-physical-r1, release-e2e firebase, mock and shipping, android-release-swiftpm-r1, detached rc-be-verify-r2, lesson-illus-w4verify) and branches with uncontained commits.

Deleted origin branches and their SHAs, for recovery with `git push origin <sha>:refs/heads/<name>`:

```
__invalid_unused__ 0bf91353f55f58efab6540543a10bdb997525bd0
codex/a11y-final-verifier-r1 e82d098f830eda1ee1229e4ff76abe3bf9df06e1
codex/a11y-final-verifier-r2 a2a98bf5ff448dabb0c4b1e829b07d09d8fd1c50
codex/a11y-final-verifier-r3 ff0c4f2f35bb45b3e04ec87e995bef0c25ea18c5
codex/a11y-final-verifier-r4 218f0ccd1f2a890aca580a87026f2b592044a448
codex/a11y-final-verifier-r5 76eff778fb3e6289298029429221b5d97fc9b5a4
codex/a11y-final-verifier-r6 8154e159e73d74f4ab5b8770d37e58a6e309b4ba
codex/a11y-final-verifier-r7 8c5092dfadc7843729c098abb3814934180e198a
codex/a11y-formatter-r1 a2a98bf5ff448dabb0c4b1e829b07d09d8fd1c50
codex/a11y-inline-math-test-contract-r1 8c5092dfadc7843729c098abb3814934180e198a
codex/a11y-integration 8c5092dfadc7843729c098abb3814934180e198a
codex/a11y-math-large-text-r1 76eff778fb3e6289298029429221b5d97fc9b5a4
codex/a11y-navbar-large-text-r1 218f0ccd1f2a890aca580a87026f2b592044a448
codex/a11y-theme-semantics-r1 ff0c4f2f35bb45b3e04ec87e995bef0c25ea18c5
codex/a11y-w1-integration-verify e82d098f830eda1ee1229e4ff76abe3bf9df06e1
codex/android-release-build-r1 967540d2b49ef2187e9507e772e5ba45fdc5577a
codex/android-release-integration 3561a7de1f8a519e0773166bf42bfdc9bbfb1965
codex/android-release-lockfile-r1 5ffad22bcf7a702ed46e86ec931241bddf470270
codex/android-release-manifest-r1 cd5fffac31953828dc0684cf5c68041375e71b71
codex/android-release-notifications-r1 249aec340451c4a93eb8329eb5e4d5a148f9fedc
codex/firebase-runtime-account-boundary-format-r1 33e0ae29e783e3d6fdc4fa62ecb90121e6cae609
codex/firebase-runtime-account-boundary-r2 79bc13b112e5a59123af7469f48e0ed61e2a7451
codex/firebase-runtime-auth-errorcode-r1 6da8475ffa87c70befebf217adc1c3d2e24deab9
codex/firebase-runtime-auth-format-r1 a101fc5334c1ac3355406328f1b1b5600280d60f
codex/firebase-runtime-auth-functions-test-r1 fd46c44fb886cd4ff66327f61e8185de45e071e3
codex/firebase-runtime-auth-r2 69f2d243f05b03b7491abd9e68bba5830dc97b60
codex/firebase-runtime-auth-testharness-r1 3ed29f82a358e5e2af5365aa9890ff25cc9c5848
codex/firebase-runtime-core-bootstrap bc5fc87eb43406274673779223ab4a1905636cac
codex/firebase-runtime-integration b7855d18e856d2560687075e2572cfd241dae65b
codex/firebase-runtime-sync-backend-indexes-r1 cbfcb0275f0b0ed22624d23a11c7a41ebca676c5
codex/firebase-runtime-sync-backend-r1 e722e0c4a7cf381de12769b7b7de1c4ac6411242
codex/firebase-runtime-sync-dart-r1 02cb557a343130ee1ac4eaf818451c790ae55ef3
codex/firebase-runtime-sync-dart-r2 d814a600a287f4cb9b6ea95f8b207084e40a3d1b
codex/firebase-runtime-telemetry-consent 09fa0b198e86e7f261134c510c0c146f2fb35076
codex/lesson-illus-commons-repair 554a27266b222a3e6bc9d27fb688d25dfae2f8b2
codex/lesson-illus-final-approvals fdda8766eede325b3a3a4259eb09647caf6edb07
codex/lesson-illus-founder-assets ab394edbccf10c52f4ad305739a2d056566fe330
codex/lesson-illus-founder-metadata-fix 9d2c39b42331c33e26bb20254f6f6e229f9cf011
codex/lesson-illus-founder-polish 6b467cb53462e83411b1337d7b4856d0f94a3dc7
codex/lesson-illus-founder-polish-fix 276ac5ff6677ef07d96da9cd0f960e174005a584
codex/lesson-illus-founder-polish-fix2 9d2c39b42331c33e26bb20254f6f6e229f9cf011
codex/lesson-illus-integration fdda8766eede325b3a3a4259eb09647caf6edb07
codex/lesson-illus-kepler-contract-fix 9e204b7b41a6b2b8214941ff263c1c7ae59647ed
codex/lesson-illus-user-review 9d2c39b42331c33e26bb20254f6f6e229f9cf011
codex/payments-client-hardening-r1 b83e0fb58dc022591c81587a7ac13fc53dd7f8ac
codex/payments-integration bb741d4cd7a2428bef01f1971945d6ff80e6fb8d
codex/payments-ui-hardening-r1 bb741d4cd7a2428bef01f1971945d6ff80e6fb8d
codex/release-e2e-r1 ab3f1355e385f9afc120b79bf0ac85f3f8610260
tmp-do-not-use 641694161563ee510a6adae51aef592bef24c5e4
web/a11y-audit-features-r1 3a1ac087fd88bce1e1903d5c7996371054b36094
web/a11y-audit-harness-r1 3a1ac087fd88bce1e1903d5c7996371054b36094
web/a11y-audit-shared-r1 3a1ac087fd88bce1e1903d5c7996371054b36094
web/beta-a11y-reconcile-r1 f9ceacb895682fb581ec18676fad2f5321f56ee2
web/beta-aggregate-verification-r1 21f40b68b00effb78e2ff919eeb6cab5a7347a62
web/beta-android-release-reconcile-r1 21f40b68b00effb78e2ff919eeb6cab5a7347a62
web/beta-baseline-reorder-repair-r1 f54a9262a439b88f2da0240005cc2e022b7f0791
web/beta-final-analyzer-repair-r1 9dde5c0c8bfe28d8ef48b820bfddd7b1f1cc2084
web/beta-final-content-repair-r1 5b8e18bbcb0dcc5596bb983476030cf0ddfd4052
web/beta-firebase-reconcile-r1 eb1c04b77a13a1b874333a5060babb57b71facd5
web/beta-lesson-illustration-reconcile-r1 45aaf05a68680292e90f40cfe545762b37f6bc38
web/beta-payments-reconcile-r1 464f66462fd52611ccc482a1fae2ae945b3e1a52
web/beta-salvage-science-characteristics-r1 080b2e2a8dc5e36b0c4479ed250f5c32a8d3a1ef
web/content-qa-lessons-r1 a85dce3fd673e68cf5f4a9a1d8268d31d632425d
web/content-qa-questions-r1 080b2e2a8dc5e36b0c4479ed250f5c32a8d3a1ef
web/e03-cp-t0-qlp0-plan-r1 62e74a8fd55437c2684ac320728a3e03030635ca
web/e04-content-protection-recovery-r1 d274cf4387821ae5ab82806cf221dbe70439de1d
web/e04-content-protection-recovery-r2 3c686756ac31748f4acad0291e464fc45b1266cb
web/e04-protected-install-migration-r3b e104f9c9ba907415ff10351bdfb4d8831e38204d
web/e05-qlp1-selection-hydration-r1 70ebe6aa3d3f1115a085ce1f12fad282e0a03b6d
web/e06-quiz-prepared-launch-r1 65c8180a32ba109d585f62c2071ae2ee6c3bb828
web/e07-content-protection-audit-r1 32accc76289fb129653060c6480a27107d4b95e2
web/e08-security-quiz-integration-r1 e0b5a39c402e96d183654dd09fa878d538d2685f
web/e09-issue25-zero-content-exams-r1 c3dabf1c154c1c5d952d69c7b966c14c5b432c69
web/e09-qlp5-prepared-next-r1 13938943f447956af43d2de7e1f9999eb2418aee
web/e09-security-performance-verification-r1 9f7a2da1af9a516144067995beec5d2ed7a45f78
web/firebase-runtime-sync-dart-amendment-r1 ab32486be086a9fb4bcc57fdd04b3de3292107a0
web/firebase-runtime-sync-dart-mutation-boundary-r1 02cb557a343130ee1ac4eaf818451c790ae55ef3
web/firebase-runtime-sync-dart-r2-independent-review d814a600a287f4cb9b6ea95f8b207084e40a3d1b
web/firebase-runtime-sync-design-r1 02cb557a343130ee1ac4eaf818451c790ae55ef3
web/firebase-runtime-wave2e-integration-candidate b7855d18e856d2560687075e2572cfd241dae65b
web/lesson-illus-w10-earth-analyze-fix 576e6f74e5f17edcdbc2200a9feae044d1d0aacc
web/lesson-illus-w7-preview-renderer bec9162b0f436df4d3d9b7b07faa1a99ff82ab1e
web/lesson-illus-w7-review-server a291c42d4e0a514e421d55a13edd65004c8b65a9
web/lesson-illus-w8-review-ui-polish bac85478ed8bc49053d2375e6847768e524c73e3
web/lesson-illus-w9-preview-font-fix 912ea868916a5a62d58c57c9e63531d85019d526
web/onboarding-completion-repair-r1 ac02421aeaf16140c5dae3b6b0cf2e7ef2c4f05b
web/pantas-rc-be-repair-r1 e9f9ad6537d1573642e5d0e763cf858d01862aae
web/release-e2e-harness-auth-reset-r1 9339f9970a23de857164df7ff2c3d7270e706a6d
web/release-e2e-harness-r1 9e9a7d7b71beba796dc82364d9e5ca47b7147f77
web/release-e2e-provenance-r1 dbdd36a0277afe6da5e3948715f554be395d2544
web/release-e2e-provenance-r2 ba536e73dbda455b994291eb551c2d6b0bd5286d
web/release-e2e-provenance-verify-r2b ba536e73dbda455b994291eb551c2d6b0bd5286d
web/release-e2e-r1 ba536e73dbda455b994291eb551c2d6b0bd5286d
web/release-e2e-review-log-wiring-r1 482b96fb77d1504e6141f759455f22e4196c4156
web/release-e2e-runner-r1 d0c2b6a5a5a1c8d95249d26adea2dc670f84e9b2
wt-m4 d133d05ab94609d1518c2103c9d90e22f3f8dca6
wt-noteb-rsn2 50b8e8b5b4faff7c615b1c247c07c9791c8add1f
wt-s4 909492c47db5a22e87794cf95d23890fcb32cf1a
```

## October 5, 2026: attribution trailers removed from main history

Aedwon: "yes fix those commits". Four commits on main carried AI credit trailers that fail `tool/check_no_ai_attribution.dart`. The lead rewrote the messages of the last 12 commits on main (from 20d9f88a, formerly 39a8c684); file contents are unchanged. Old to new: 39a8c684 to 20d9f88a, 3a84a5d6 to 230a7585, cb48097b to 23c48fea, 239af773 to 58667f2a. SHAs in this log and the strategy were updated to the new values. No other branch contained the rewritten commits. Backup branch before the rewrite: local `backup/pre-attribution-rewrite`.

## October 5, 2026: handoff questions (strategy Part B, B4)

Exact answers:

> * Free users keep full mock review only until the next mock opens. Is that right? -YES
> * Should the Pro History screen ship now, even though it's lost on reinstall until sync exists? -What Pro history is this? in the roadmap screen? if that's what you're talking about it should ship
> * Should Wrapped add "topic turning weak to strong" as a trigger? -no
> * Should bottom sheets appear only where a board shows one? -yes the claude design's screens are authoritative. however, if there is something that was missed during the design process, it should be brought up. this is one pass that needs to happen in the plan. i need to decide on whether to keep or discard something. note that if something was changed by the design from the original, the new design triumphs (but still show me just in case). i should only decide on missing things, not old things that were changed
> * Progress merges into Home and Settings becomes a tab. Should the old Progress screens be retired? -yes
> * Should the date format, still marked proposed, be approved? -sorry where is this?
> * CSE subject counts and the ACET time have no published source, so they can't be shown. Should they stay hidden until sourced? -i will provide this later. just use dummy amounts make sure to note this

Resulting decisions:

1. Mock review gating ships as drawn: Free keeps full review until the next mock opens, then
   score and breakdown only; Pro reopens any time; notes on misses are Pro only.
2. Pro History is the History section of Your plan (boards DP_History, DP_HistoryEnd). It ships.
   Its entries stay on the device and are lost on reinstall until sync exists.
3. Wrapped keeps three moments: first mock or a new best; a streak of 7, 30, 100 or 365; the
   day after the exam. The handoff's "topic turning from weak to strong" moment is dropped by
   Aedwon's explicit decision, overriding the handoff.
4. The design handoff is authoritative. Each screen plan includes a gap pass:
   - Changed by the design from the old app or specs: build the new design, and list the change
     for Aedwon's information only.
   - Missing from the design (an old feature, control or state with no board): list it for
     Aedwon to keep or discard. Do not build or remove it before he decides.
   - Bottom sheets appear only where a board shows one.
5. Old Progress screens and routes are retired. Progress lives on Home.
6. Date format: approved (see below). Location: `docs/design/DECISIONS.md`, "Dates (proposed
   4 Oct)".
7. CSE per-subject item counts and ACET aptitude time: build with placeholder values that Aedwon
   will replace. Every placeholder is marked in code with a `PLACEHOLDER` comment and listed in
   the plan. This is an explicit exception to "Never invent a figure" for development only;
   replacing them is a release blocker.

## October 5, 2026: date format approved

Aedwon: "approved". The handoff date format ("Dates (proposed 4 Oct)" in `docs/design/DECISIONS.md`) is final: "Nov 11, 2026"; this year "Oct 17"; with weekday "Sat, Oct 17"; long headings "Saturday, October 3"; month only "November 2026". Boards drawn with "3 October" follow this when built.

## October 5, 2026: baseline on integration/new-design-r1

Branch `integration/new-design-r1` created from `origin/web/roadmap-engine-r1` at 1f79d880 and
pushed. Policy revision: origin/main ac4b30da. Flutter 3.44.6, Dart 3.12.2.

Seed assets (`assets/seed/content.db`, `content.manifest.json`, `content.manifest.sig`) are
gitignored. They were copied from the roadmap worktree at the same commit (files dated Sep 10).
SHA-256 prefixes: assets/seed/content.db;assets/seed/content.manifest.json;assets/seed/content.manifest.sig;

- build_runner: exit 0.
- flutter analyze: 1 info, `deprecated_member_use` of `onReorder` in the lesson bookmarks
  sheet. Not an accepted exception; fix it in W2, where that bottom sheet is replaced anyway.
- dart format: exit 0, no changes. check_layering: OK. check_no_ai_attribution: OK.
- flutter test: exit 0, 3,403 of 3,403 passed.
- functions tests (`node --test`): not run.

Pending: the SSOT entry still says the baseline is running; update it next session.

## October 5, 2026: restart strategy approved

Policy revision read: origin/main 84cdee25.

Aedwon approved Part A of the rewritten strategy (top-down plan of plans) and asked the lead to
start stage 0, set up unattended running (B9), and continue through levels 2 and 3 without him
after he answers stage 0, stopping before level 4.

Exact comment:

> I approve the strategy's top-down approach as written.

Resulting actions:

1. Strategy status changed to approved.
2. Status file created: `docs/superpowers/plans/new-design/STATUS.md`.
3. SSOT 5 Oct entry updated with the baseline result (strategy B3 step 6, pending since the
   baseline entry above).
4. Hourly resume task set up as a desktop scheduled task (B9).
5. Stage 0 started: gap pass and kept-work triage run in parallel.

## October 5, 2026: execution arrangement for level 4 (strategy B3 step 5)

Recorded by the lead from existing decisions; no new product choice.

- Inputs: `docs/superpowers/decisions/2026-09-25-chatgpt-web-relay-routing.md` and Aedwon's
  model rule in strategy B7 (October 5).
- Lead: the Claude Code desktop session (Opus 5.5), interactive or the hourly resume task.
- Implementors: Claude Code subagents on Sonnet 5.5, one plan and one worktree each, per
  `SUBAGENTS.md`. Opus subagents for W0 merge conflicts, W3 payments and entitlement, schema
  changes, and any task a Sonnet worker stops on twice.
- Independent reviewers: Opus subagents for gate reviews and W0 and W3 code review; Sonnet may
  review other code workstreams. Never the author.
- The ChatGPT web relay stays available as a fallback under its own decision record. It is not
  the default for this program.
- Not used: the Google worker service (canceled) and any Gemini-based agent, including the
  locally installed Gemini implementor agent type.
- Capability gap: the subagent dispatch tool sets the model but not the reasoning effort. Subagents
  run at their default effort, not at "medium" as B7 states. The lead session itself runs at the
  effort Aedwon set for it.

## October 5, 2026: stage 0 answers (gap pass and kept work)

Options, costs and recommendations: `docs/superpowers/plans/new-design/stage0-decisions.md`
(items 1 to 51). Evidence: `docs/superpowers/plans/new-design/stage0/`.

Exact answers ("gwyr" means "go with your reco"):

> gwyr = go with your reco
>
> 1. gwyr
> 2. gwyr
> 3. gwyr
> 4. there should be a time setting row in settings like in the onboarding
> 5. gwyr
> 6. actually you can add that as another notification item. you can just use the same design as everything else. remove the "nothing else" part in the copy
> 7. this is an automatic anti-churn notif, build it
> 8. discard
> 9. discard
> 10. discard
> 11. discard
> 12. backend should still record even tho there's no surface yet for this. data might be useful later
> 13. same as 12
> 14. gwyr
> 15. gwyr
> 16. gwyr
> 17. gwyr
> 18. gwyr
> 19. gwyr
> 20. gwyr
> 21. gwyr
> 22. gwyr
> 23. gwyr
> 24. gwyr
> 25. add it, 6 was amended slightly
> 26. gwyr
> 27. gwyr
> 28. build it. there's no screen yes but it doesn't have to surface. this is a backend feature
> 29. gwyr
> 30. gwyr
> 31. gwyr
> 32. gwyr
>
> 33-42 approved
>
> 43. gwyr
> 44. gwyr
> 45. gwyr
> 46. gwyr
> 47. gwyr
> 48. gwyr
> 49. i want to test it on my iPhone too. i have xcode 27, ios 27, and macos 27 so hopefully that wireless testing can be done since my iphone can't pass data from its usb c port (i've tested this with other cords and they work on other phones but not mine)
> 50. gwyr
> 51. gwyr

Resulting decisions (recommendation unless stated):

1. Exam switching follows the 4 Oct Settings boards: the student chooses Count Them or Start My
   Numbers Fresh; the "Rebuilding your plan" wait and date-kept confirmation stay.
2. Mock results: no best-mock pill, no confetti, no comparison sentence.
3. No lock icon; the small Pro tag as drawn.
4. Changed by Aedwon: Follow up replaces the old streak-save reminder, and Settings > Reminders
   has a Follow up time row like onboarding (shown only while Follow up is on).
5. Flagged questions list: built like the mock's All questions list.
6. Changed by Aedwon: exam countdown notifications are kept, as another item in the same style.
   The onboarding reminders copy drops "Nothing else." It reads: "One daily study reminder, and a
   follow-up if you haven't started."
7. Changed by Aedwon: the come-back notification after 3 missed study days is built (automatic
   anti-churn).
8. Wrapped-ready notification: discarded.
9. One-notification-a-day limit: discarded.
10. Lately line: discarded (idea for later).
11. Lessons-read total and Your pace panel: discarded.
12. Changed by Aedwon: time per question is not shown, but the app keeps recording it.
13. Changed by Aedwon: "Why you miss questions" is not shown, but the app keeps recording its
    inputs (notes, prior correctness, answer times).
14 to 24. As recommended: no miss cause lines or "back in X days"; no spaced-repetition
    explainer; quick quiz only on the Study "Nothing to study yet" screen; no study-first sheet; no
    assessment nudge or plan-ready moment; store rating prompt kept; sign-in conflict chooser kept
    as a centered dialog; Delete my data for signed-out students kept; no in-app export (DPO row);
    no milestone sign-in prompts; the separate Try Pro flow is retired and Pro buttons open the
    Settings Pro page and return.
25. Changed by Aedwon: the trial-ending phone notification 24 hours before the charge is kept.
26, 27. No Next blank or Next flagged shortcuts; no Strict badge.
28. Not repeating questions from the last two mocks: built, backend only.
29 to 32. Short-paper line on mock setup kept; no bookmark ribbon or bookmark notes; no ordinary
    mock message; Choose your exam fallback on every tab.
33 to 42. Approved as a group: the lead's defaults in stage0-decisions.md A3.
43 to 48, 50, 51. As recommended: keep the four release end-to-end tests (W5), the quiz-loading
    spec (record), the 5-line assessment refresh fix (W4d), and the inline math accessibility
    checks (W2); discard the 30 contained or superseded items, the benchmark harness, the backup
    branch, beta consolidation documents and illustration ledgers after saving them to one archive
    branch; leave the landing page documents untouched.
49. Changed by Aedwon: iPhone testing is in scope. The September iPhone QA design is kept and
    feeds W5. His iPhone's USB-C port does not carry data, so device testing uses Xcode wireless
    debugging (Xcode 27, iOS 27, macOS 27). Wireless pairing is unverified until it is tried.

## October 5, 2026: kept-work cleanup performed (stage 0 decisions 43 to 51)

- Archive branch `archive/pre-restart-kept-work` at 2bdde4fd pushed first. It holds a verified
  git bundle of every commit in the deleted branches and the three stashes not already in
  `integration/new-design-r1` or `main`, the uncommitted changes of every dirty worktree (diffs
  and untracked files), and the deleted refs with their SHAs. Its README explains recovery.
- Removed 14 worktrees: beta-final-verification-r1, web-e04-content-protection-r1,
  qlp5-physical-r1, android-release-swiftpm-r1, rc-be-verify-r2, beta-integration-r1,
  mock-resume-correctness-r1, web-e09-product-defects-repair-r1 and r2, lesson-illus-w4verify,
  w5a, w5b, w5verify, m7.
- Deleted 59 branch names (local where present, 51 on origin); list in the archive's
  `deleted-refs.txt`. Dropped all 3 stashes.
- Kept: the four release end-to-end test worktrees, the inline math accessibility worktree,
  `web/beta-salvage-assessment-cache-r1`, `web/ios-physical-qa-enablement-r1`,
  `web/landing-design-contract-r1`, and the active tracks.
- The 6 Sept quiz-loading spec, found only in stash 0, is now on main as a record:
  `docs/superpowers/specs/2026-09-06-quiz-loading-performance-design.md`. It is not a current
  requirement; the 1 Oct release-first cuts still apply.

## October 5, 2026: amendment spec sent for approval (strategy B3 step 3)

`docs/superpowers/specs/2026-10-05-new-design-amendment-design.md`, with a visual companion for
the only screen his answers change (Settings Reminders; onboarding reminders copy):
`docs/design/proposals/reminders-2026-10-05.html` (version 1), boards `ST_Reminders_v2.html` and
`O_Notify_v2.html`. Three questions are open in its Part A: notification overlap on countdown and
come-back days, the countdown when the daily reminder is off, and the follow-up time range.

## October 5, 2026: amendment spec approved

Exact comment:

> 1. ok
> 2. ok
> 3. ok
>
> also just to notify you you're at 83% usage used resetting at 3h 55m. can you leave to you to run and auto resume yourself even after you hit limits?

Resulting decisions:

1. Notification overlap: the exam countdown and the come-back reminder each replace that day's
   daily reminder; the follow-up still comes if Today is not started.
2. The countdown follows only its own switch; with the daily reminder off it arrives at 7:00 PM,
   and at 7:00 AM on exam day.
3. The follow-up time wheel offers only times after the daily reminder.
4. Approval: Aedwon answered the three open questions and asked the lead to continue
   unattended. The lead recorded this as approval of Part A. This is an inference from his
   request to continue, not an explicit "approved"; if he says otherwise, level 2 work done
   since then is revisited.

Stage 0 exit status: steps 1 to 3 and 5 and 6 done; step 4 (traceability table) is next and
runs unattended.

Confirmation, same evening. Aedwon: "and yes i mean to approve the spec". Part A approval is
explicit; the inference noted in item 4 above is resolved.

## October 5, 2026: resume task runs every 10 minutes

Aedwon: "can you make it more often? like checking if the limits have restarted or something is
running every 10 minutes? or would you advise otherwise". The lead changed the desktop resume
task from hourly to every 10 minutes and reordered it so each run first reads only STATUS.md and
exits if the restart is waiting on Aedwon or locked, before reading the policy files. A lock is
now stale after 2 hours instead of 3, so an interrupted step resumes sooner. Steps must fit in
2 hours. This amends strategy B9's "about every hour" and "3 hours".

## October 6, 2026: stage 0 complete; work moves to the interactive session

- Aedwon paused the scheduled resume task and asked the lead to continue in chat: "okay you can
  continue for me. again, top-down approach please". A routine run is a fresh session that rereads
  all policy and plans each time; the interactive session keeps context. The status file is still
  updated after every step so any fresh session can resume.
- Auto-continue at usage limits turned on in Aedwon's Claude Code user settings at his request.
- Traceability (B3 step 4) finished: 616 rows from the scheduled run (a9d94795) plus 215 gap pass
  rows from the lead. Every gap row maps to a stage 0 decision, an earlier decision, or a lead
  default inside the shared design rules; none needed a new product decision.
- Stage 0 exit met. Level 2 starts with W0.
