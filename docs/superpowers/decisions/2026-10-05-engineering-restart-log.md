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

## October 6, 2026: W3 scope adds tiered pricing (level 1 amendment)

Found while writing level 2: the approved Pro pages and `docs/pricing.md` price Pro by exam tier,
with Season Passes and an upgrade on switching to a pricier exam, but the app has only the three
Student products (trial on Yearly) and no workstream owned tier support. CSE ships at launch and
has its own tier.

Options offered: (1) build tier support in W3 now, about 4 to 6 days, plus Aedwon creating the
Civil Service products in Play Console and RevenueCat and moving the trial offer to Monthly
(recommended); (2) Student tier only for beta, about 1 day, CSE without Pro at launch.

Aedwon: "1".

Changes: strategy B2 W3 now includes tier support; B1's question-qa-r2 row corrected (no
application code; the earlier "16% under lib/features" was wrong). Licensure, academy exams and
PSHS-NCE stay Coming soon and sell nothing.

## October 6, 2026: level 2 gate review 1 (not passed) and fixes

Independent Opus review: `docs/superpowers/plans/new-design/gates/l2-gate-review-1.md`. 4 blockers,
17 should-fix, 15 notes. Traceability passed mechanically (831 rows, every owner and section valid).

Fixed by the lead:
- F-1 assessment boards moved to W4a. F-9 lesson quiz set and quick quiz moved to W4d (W4c keeps the
  buttons). F-17 kept-data rows moved to the families that rebuild that code.
- F-4 the "other" mistake tag, note text and blank reasons are new data: W0 adds them in app
  database schema 26 with its migration and sync fields.
- F-2 exam catalog (tier, group, Coming soon, published sittings with sources) added as a W0
  contract. F-15 mock blueprint placeholder marker added to W0; W4e authors CSE and ACET blueprints.
- F-3 tier pricing spec written (`specs/2026-10-06-tier-pricing-design.md`) for Aedwon's approval;
  W3 level 3 waits for it; price-point check added as a stop.
- F-5 decision references corrected (R-20 placeholders, R-12 mock review, R-16 Progress, R-13 History).
- F-6, F-7, F-10 route retirement owners, per-family route files, file owners and order.
- F-8 strategy B2 amended: families may own named family-specific contracts. F-26 B2 dependencies.
- F-11 every consumed contract named in its owner's plan. F-12 one curve constant per CSS curve.
- F-13 board conflicts go to the lead. F-14 two missing sheets listed. F-20 B1 citation in W4 plans.
- F-21 W0 seed facts corrected (no dev seed; signed package only). F-22 full icon list. F-23, F-24,
  F-27, F-28, F-31 to F-34, F-36 corrected or clarified.

Open for Aedwon: the tier spec (with its three questions), F-16 (Pro pages for exams that are
Coming soon), F-18 (what a student keeps after Pro lapses), F-19 (notice order, History sentences
and Follow up copy). For his information: F-29, F-30, F-35.

## October 6, 2026: answers to gate review 1 questions and the tier spec

Exact answers:

> 1. a
> 2. ok
> 3. ok
>
> sorry i need figures for CSE weekly. and yearly. does that go against the pricing doc?

> weekly 49 yearly 1199

Resulting decisions (items not answered take the stated recommendation, per the reply convention):
1. Tier spec Part A approved. Official exam dates: Aedwon supplies each with its source link; an
   exam without one sells no pass and shows no known-date card. Price points confirmed by Aedwon in
   Play Console before products are created. Product names as proposed, plus the two new plans.
2. Civil Service adds Weekly ₱49 and Yearly ₱1,199 (Monthly ₱149 with the trial, pass ₱499).
   `docs/pricing.md` updated. CSE Pro page follows the academy-exam layout (preview
   `docs/design/proposals/cse-pro-2026-10-06.html`, board ST_ProCSE_v2). Products:
   `pantas_cs_weekly`, `pantas_cs_monthly`, `pantas_cs_yearly`, `pantas_pass_civil_service`.
3. F-16: Pro pages for Licensure, academy exams and PSHS-NCE are deferred until those exams launch.
4. F-18: after Pro lapses, Free rules apply to mock reviews and Wrapped history; nothing is deleted;
   renewing restores.
5. F-19: notice order, History sentences and Follow up copy as proposed.
6. F-29, F-30, F-35 noted for information: streak freeze code stays dormant; the Wrapped web page
   keeps its copy; existing daily reminder messages stay.

## October 6, 2026: level 2 gate review 2 (not passed), record of what was asked, and answers

Review 2: `docs/superpowers/plans/new-design/gates/l2-gate-review-2.md`. 1 blocker, 14 should-fix,
11 notes; review 1 findings 30 resolved, 5 partly.

What the lead sent Aedwon after review 1 (gate N-2 asks for the exact options). The message said
"Reply with the numbers you change; anything you leave out takes my recommendation" and listed:
1. Tier pricing spec approval, with (a) official exam dates supplied by Aedwon with source links,
   (b) confirming ₱149 and ₱499 in Play Console, (c) permanent names `pantas_cs_monthly` and
   `pantas_pass_civil_service`.
2. Pro pages for Coming-soon exams: recommended deferring them until those exams launch.
3. After Pro lapses: recommended Free rules for mock reviews and Wrapped history; nothing deleted;
   renewing restores.
4. Copy with no board: notice order (service message, trial ending, welcome to Pro, no date, month
   only); History entries "You switched to CSE Professional. Your plan was rebuilt for it.", "Your
   exam date passed. Your plan waits for a new date.", "Your exam date was removed. Your plan is
   rebuilt when you set one.", "Your plan was built from your assessment results.", no entry for the
   internal topic-order fix; Follow up "Still time today" / "One short session gets today's plan
   started."
5. For information: streak freeze code stays dormant; the public Wrapped page keeps its copy;
   existing daily reminder messages stay.

The preview of the CSE Pro page shown on Oct 6 had empty phone frames (the board is taller than the
preview assumed). Fixed; the preview now shows the approved page, the proposal, and the proposal's
pass-picked state (board ST_ProCSEPass_v2). Savings round down ("SAVE 32%", like the Student page).

Then asked: (1) approve the CSE layout and the names `pantas_cs_weekly`, `pantas_cs_yearly`;
(2) confirm the items above that took recommendations; (3) Wrapped history on reinstall: keep on
the phone for beta (recommended) or sync (about 1 to 2 days). For information: the store rating
prompt never appears within 24 hours of opening the Pro page.

Exact answers:

> 1. yes
> 2. yes
> 3. keep on phone
>
> is this going to rerun the level 2 gate review?

Resulting decisions: CSE Pro page per ST_ProCSE_v2 and ST_ProCSEPass_v2 and all four Civil Service
product names approved; items 2 to 4 above confirmed; Wrapped history stays on the phone and is lost
on reinstall until sync exists.

Fixes for review 2 (lead): W0 data the design adds is stored as fields inside existing JSON columns
(app schema stays 25); content database schema 10 for the exam catalog, Coming soon exam rows, and a
functions copy of the catalog; strategy B2 W0 row amended; one complete retired-route list owned by
W1; per-family route files and the dev route file; W2 edits no feature files; trial-ending interface
`TrialEndingNotifier` owned by W3 and implemented by W4f; landing orders for every consumed family
contract; W5 covers the tier purchase cases; traceability statuses refreshed; tier spec replacement
wording corrected; amendment spec B2 trial text clarified to use the student's own plan price.

## October 6, 2026: level 2 gate review 3 (not passed, no blocker) and fixes

Review 3 (delta): `docs/superpowers/plans/new-design/gates/l2-gate-review-3.md`. All 31 review 2
items resolved; 4 should-fix and 6 notes from the changes. Fixed: W0's recorded-data row names the
JSON fields (no schema 26); W0 owns the mock JSON field additions in `mock_results.dart` before W4e;
W2's Ink and sheet retirement moved to a W2 close-out task after the last W4 family, and each W4 plan
replaces its own call sites; G-h-28 icon mapping moved to W4g using W1's getters; R-21 and A-B2b
carried in the cited sections; v2 boards registered in `docs/design/SCREENS.md` with the originals
marked superseded (the canvas gallery `index.html` is not regenerated); level 3 notes added for the
catalog storage form, the `MistakeTag` unknown-value fallback and pass end dates moving later;
G-g-15 marks the Pro tag after a lapse as a lead default. Aedwon hit a usage limit during this step;
work resumed after the reset.

## October 6, 2026: level 2 gate review 4 (not passed, 3 should-fix) and fixes

`gates/l2-gate-review-4.md`. Fixed: W0 declares the mock JSON fields only and W4e computes and writes
them; W4g section 2 resynced with the table (G-h-28); the share note and reveal bar follow WR_Share
and the reveal boards, so the old globe and bookmark icons are removed rather than remapped; W4g
marks the Pro tag after a lapse as a lead default.

## October 6, 2026: level 2 gate passed

Review 5 (`gates/l2-gate-review-5.md`): "Gate verdict: pass". All 833 traceability rows have one
owner and a level 2 section; every W4 plan's lists match the table. Accepted notes are carried to
level 3 in `docs/superpowers/plans/new-design/L3-carry-forward.md`. Gate history: reviews 1 to 4 not
passed, each fixed by the lead; review 5 passed. Level 3 (strategy B5) starts.

## October 6, 2026: level 2 amendments found while writing level 3

From the level 3 code inventory (Sonnet gathering, lead review). Changes go up first:
- L2 W1: retired routes become interim redirects to the nearest living screen until no caller
  remains (W2 close-out removes them); `/settings/sessions` redirect moves to W4f, which creates
  `/settings/practice`. Theme migration: W1 keeps the old theme API as deprecated adapters so the app
  compiles while families migrate; W2 close-out deletes them and the SourceSans3 font.
- L2 W2: also owns the shared question and content pieces (`QuestionCard`, `ChoiceRow`,
  `AnswerReveal`, `PassageCard`, `ContentRenderer`) and `PantasPage`.
- L2 W4b and W4f: the table order contract uses the existing names `tableOrderProvider` and
  `retainTableOrderProvider` (the invented name is gone); `topic_accuracy_provider.dart` moves with
  them before `lib/features/progress/` is deleted.
- L2 W3: Season Passes are one-time consumable products, as the tier spec says.
- W4a gets a recorded cross-family permission to change `updateExamDate` (allow today, D-34) in the
  settings repository, before W4f runs.

## October 6, 2026: level 3 gate review 1 and fixes

Gate review 1 (`plans/new-design/gates/l3-gate-review-1.md`, independent Opus reviewer): not passed,
1 blocker, 11 should-fix, 9 notes. The lead fixed every item:
- L3-1: W3's router edits land after W1 integrates; L2 W1 §9 and the parallel map amended.
- L3-2: mock `SectionResult.wrong` and `blank` are nullable (null means an old row); W4e's section
  parse in `mock_results_route.dart` is the one decoder; the metrics reader is unchanged.
- L3-3: the catalog field keeps the L2 name `publishedSittings`.
- L3-4: the S0-43b assessment refresh moves from W4d to W4a Task 10 (L2 W4a and W4d amended).
- L3-5: W4b Task 1 also moves `record_provider`, `how_you_work_provider` and `miss_causes_provider`.
- L3-6: new W0 Task 4b writes figure credits into lesson image blocks; W4c reads `asset.credit`.
- L3-7: cross-family edits recorded in L2 §8 of W0, W3, W4d, W4g, W4h and W5.
- L3-8: concrete check commands added to W0, W1, W2, W3, W4g and W4h tasks.
- L3-9, L3-19: traceability rows corrected (boards cited to delete tasks, W4c decision ranges,
  D-5, D-195, D-233; D-229 marked deferred).
- L3-10: G-a-19 moves to W4a Tasks 1 and 5; R-28 stated in W4a Task 8 and W4f Task 4.
- L3-11: G-g-21 corrected: no Wrapped analytics events exist and none are added (L2 W0, W4g).
- L3-12 to L3-14: parallel map rows added or corrected; W4b and W4f run their tracks in one slot;
  W2 starting before W3 finishes differs from strategy B6 and is recorded here as harmless.
- L3-15, L3-21: citations and row constraints added to the tasks.
- L3-16, L3-17: W0 Task 6 is optional (a device build with the merged QA content); the release
  package is built once in W5 Task 1. Exam dates arriving later are a lead edit to the catalog with
  a re-export, before W5 Task 1.
- L3-18: the week-strip tap is wired in W4b Task 7 with its route.
- L3-20: `paywall_recommendation.dart` deleted by W4f Task 7; `app_error_view.dart` by W4h only;
  W3 Task 8 states how each `proIsActive` getter changes. N-19 settled: `WITH_TIME_PRORATION` for
  every Student to Civil Service pair (Play Billing docs, Oct 6), since `CHARGE_PRORATED_PRICE`
  fails pairs whose price per day falls.

Process slip: commit b43d93a6 on main carries an AI attribution trailer, which WORKFLOW forbids.
Removing it needs a force-push to main, which only Aedwon can approve; asked at the level 4 stop.

## October 6, 2026: level 3 gate review 2 and fixes

Gate review 2 (`gates/l3-gate-review-2.md`): not passed, 0 blockers, 7 should-fix, 6 notes; 15 of
review 1's items resolved, 6 partly. The lead fixed every item:
- L3R2-1: W0 Task 4b rewritten (the converter file, the export command with its output argument,
  `test/tools`). Fact recorded: `content/illustrations/assets.json` is not in the repository, so no
  lesson image ships today; producing it needs a Sanity upload with Aedwon's approval (asked at the
  level 4 stop). Images without a credit entry do not ship.
- L3R2-2: L2 W0 and W5 amended: the W0 package build is optional; W5 Task 1 builds and verifies the
  release package (`verify_content_package`, release sequence, placeholder test).
- L3R2-3: W4h's raw-error check uses two exact greps.
- L3R2-4: leftover Try Pro files go in W4f Task 9; W4g has no `/paywall` push.
- L3R2-5: W3 Task 8 lists every `proIsActive` read with its owner; W4c, W4e, W4f and W4g headers
  state the rule; L2 W3 §8 amended.
- L3R2-6: Season Pass bought by an active Student subscriber: lead default (the Pro page says the
  Student plan still renews, with Manage in Google Play) for Aedwon to confirm at the level 4 stop.
- L3R2-7: L2 W4a and W4d row counts corrected.
- Notes L3R2-8 to L3R2-13 fixed in the plans and the map.

## October 6, 2026: level 3 gate review 3 and fixes

Gate review 3 (`gates/l3-gate-review-3.md`): not passed, 0 blockers, 4 should-fix, 7 notes. Fixes:
- L3R3-1: the mock entitlement override in `bootstrap.dart` is a gate; W3 Task 8 switches it (map
  and L2 W3 §8 amended).
- L3R3-2: plan status (Settings Pro row, Pro page plan name and Manage link) keeps the any-plan flag;
  only gates read the active-exam provider. W4f has no gate.
- L3R3-3: W4f Task 6 builds the Season Pass "Student plan still renews" line once Aedwon decides.
- L3R3-4: the export drops an image with no credit entry.
- Notes L3R3-5 to L3R3-11 fixed (L2 W0 and W5 wording, full verify command, tested raw-error
  greps, L2 W3 files, W4c header line removed, remaining call sites named).

## October 6, 2026: level 3 gate review 4 and fixes

Gate review 4 (`gates/l3-gate-review-4.md`): not passed, 0 blockers, 1 should-fix, 5 notes. Fixes:
- L3R4-1: the Pro page offers the active exam's plans and pass when `proForActiveExamProvider` is
  false (a Student Pro subscriber on CSE sees the Civil Service plans); plan name, Your plan rows
  and Manage keep the any-plan flag. W3 Task 8, W4f header and Task 6, L2 W3 §8 amended.
- Notes: W4f reads `studentPlanStillRenews` from `switchOutcome`; W3 Task 8 runs `test/app` and
  updates the override test; W0 Task 4b rewrites the existing image tests for the drop rule; W4h's
  greps are stated as a backstop.

## October 6, 2026: level 3 gate passed; stop before level 4

Gate review 5 (`gates/l3-gate-review-5.md`): passes, 0 blockers, 0 should-fix, 3 notes (fixed:
L2 W3 wording and "Your plan rows"; W0 Task 4b names the drop case). The lead stopped before level 4
per Aedwon's instruction and sent him the level 4 start requests listed in STATUS.

## October 6, 2026: Aedwon's answers to the level 4 start requests

Verbatim: "1. yes you may 2. yes, give me step by step instructions 3. idk how to answer that I'm
not competent enough idk what that is. what do you recommend? 4. March 14 2027
https://www.csc.gov.ph/examination-advisories/examination-announcement-no-05-s-2026-calendar-of-civil-service-examinations-pen-and-paper-test-for-cy-2027
next one is Aug 8, 2027 5. what do you recommend 6. can you link the file to me I don't think I've
read 7. ok 8. wait what images? do you mean for illustrations? clarify 9. remove it"

Recorded:
1. Permission to use the signing seed for the W0 optional package and the W5 release package,
   following `docs/content-key-access.md`.
2. Store setup steps written: `plans/new-design/level4-setup-steps.md` (Parts 1 to 4).
3. Lead recommendation: create a V2 read-only RevenueCat secret key and store it himself with
   `firebase functions:secrets:set` (Part 5); W3 Task 2 uses API v2 with that key.
4. CSE Professional and Subprofessional 2027 pen-and-paper dates: March 14, 2027 and August 8,
   2027 (one day each), source CSC Examination Announcement No. 05, s. 2026 (link above; the page
   blocks automated fetches, confirmed through search results Oct 6). These go into
   `content/exams/catalog.yaml` in W0 Task 3. The CSE-FSO (January 24, 2027) is not a Pantas exam.
5. Lead recommendation sent: App Store purchases out of beta scope; iPhone used for app testing.
6. Privacy draft written: `plans/new-design/drafts/privacy-pantas-id.md`.
7. Season Pass for an active Student subscriber: lead default approved; exact copy proposed for
   approval.
8. Clarification sent (lesson illustration image files).
9. The AI attribution trailer was removed from b43d93a6 by rewriting the seven docs commits after
   34ab3994 (messages only; trees identical) and force-pushing main (old head 475de455, new head
   a7764b69), with Aedwon's approval.

## October 6, 2026: abuse review and the level 1 amendment

Aedwon asked whether the plans cover abuse vectors ("mistakes in the infrastructure that could have
been avoided from Day 0 ... an exploit to have unlimited Pro access or patching the app"). The lead
answered that no plan step checked abuse. At his request GPT-6 Astra (Codex, medium, read-only)
reviewed the code and plans: `plans/new-design/gates/abuse-review-1.md`, 19 findings; the lead
confirmed the main ones in the code and agreed with 17, partly with 2 (CX-12, CX-14).

Aedwon approved folding the fixes into the plans ("yes please add them"), with the higher-level
fix. Per the strategy rule "changes go up first", the change starts at level 1:
- Part A gains the rule "Abuse cases are a requirement".
- B2: W3 and W4g gain their abuse fixes; new workstream W6 (backend hardening, parallel with W1 and
  W3; lead's structuring choice so backend hygiene can go to a non-Claude worker); W5 gains
  obfuscation and an abuse re-check on the final build.
- B4 and B6 amended (abuse section in level 2 plans, a gate check, W6 in the order).
Next: level 2 amendments for W3, W4g, W5 and a new L2 W6, a level 2 delta gate; then level 3
amendments and a level 3 delta gate. Open product decisions for Aedwon: offline Pro after the paid
period ends (lead recommends 3 days), and the trial rule (lead recommends Play's "never had a
subscription" rule and correcting the tier spec).

## October 6, 2026: offline window and trial rule

Aedwon, verbatim: "let's do 3 days. A use Google's rule".
- Offline window: Pro keeps working offline until the paid period ends, plus 3 days with no
  successful check; then Pro features pause until one successful check. This amends the August 3
  offline rule ("last known entitlement stands until positively contradicted") for the time after
  the paid period. The lead had recommended 7 days (weekly renewals); Aedwon chose 3.
- Trial: Google Play's rule (a Google account that ever had a Pantas subscription gets no second
  trial). The tier spec's "ever had any Pantas Pro plan" is corrected. Pass and giveaway holders
  can take one trial; new Google accounts are an accepted risk.

## October 6, 2026: level 2 abuse gate review 1 and fixes

`gates/l2-abuse-gate-1.md`: not passed, 2 blockers, 19 should-fix, 11 notes. Fixed in L2 W3, W4f,
W4g, W5, W6 and the review verdict table. Blockers: the offline window now uses a time high-water
mark (a clock set back counts the window as used); W6 moves Functions to Node 22 (Google
decommissions Node 20 on October 30, 2026, confirmed on the Cloud Functions runtime support page).
Lead decisions recorded: sandbox purchases count in prod only for a tester allowlist (A03 on the
release package); RevenueCat restore behavior stays "Transfer to new App User ID"; one deploy
policy (each workstream deploys after its review, with Aedwon's approval, after W6 Task 1).
For Aedwon: how the live backend was deployed and whether to redeploy on Node 22 before October
30; copy and limits (paused line, share limits and messages, export error); the giveaway fallback
(an unrecorded grant counts as Student tier); whether W6 may run on Codex (strategy B7).

## October 6, 2026: Aedwon's answers on the backend, giveaways and models

Verbatim: "1. i manually configured it using the Firebase console. is there a way for you to be the
one to set this up or no? so I can let agents do that work as well. it's okay if I have to do it
myself 2. what's Node 22? ... 3. is the image generated on-device? if yes, then it's approved
4. no. there should be a difference with CSE tier giveaway and student giveaway. cse tier giveaway
of course has access also to student. the tiers and logic still follow 5. yes you can use codex for
audits". Then: "1. okay you have my approval. go 2. okay then. proceed as you recommend
3. approved 4. great. though there is a much higher professional tier in the future. do we need to
include that now or defer when the actual content is ready for using in the app? 5. sorry, I meant,
6.1 Sol High for execution (if the plans are already ready), then Astra for deep,
security/optimization, sweeping audits. you (Claude Opus 5.5 Med) would only oversee this process
wording is approved".

Recorded:
- Read-only check (approved "go"): `firebase functions:list` fails in pantas-prod, pantas-staging
  and pantas-dev because the Cloud Functions API has never been enabled. No functions have ever
  been deployed. The Node 20 retirement on October 30 affects nothing live; W6's package becomes
  the first deploy, after Aedwon enables the API and confirms the Blaze plan. Agents can deploy
  with the Firebase CLI on this Mac, each deploy with Aedwon's approval.
- Share image is made on the phone (`wrapped_png_renderer.dart`); share limits and messages
  approved. Paused line ("Connect once to keep using Pro.") and export error text approved.
- Giveaways: tier-named promotional entitlements `promo_student` and `promo_civil_service`; no
  default tier. Future tiers (Licensure) are deferred until their content ships; adding one is one
  entitlement and one product table row.
- Strategy B7 amended: GPT-6.1 Sol High builds, GPT-6 Astra audits, Opus oversees.

## October 6, 2026: level 2 abuse gate reviews 2 and 3 and fixes

Review 2: 1 blocker (repeated small clock setbacks), 9 should-fix. Review 3: 1 blocker (a cached
RevenueCat answer counted as a check), 4 should-fix. Fixed in L2 W3 (AC-1 time rules: only a fresh
server answer counts, trusted time never moves back, cumulative rollback total; AC-3 claim marker
on the user record, refresh triggers, 1-day margin accepted, deploy-step checks; AC-7: a `pro`
grant with no known product covers nothing), W4g, W5, W6 (first deploy; export live console rules
before any deploy) and strategy B7 (the Astra audit adds to the Opus independent review). Level 3
items noted: executor lines in every L3 plan and the map, setup steps for the Functions API, Blaze
and the two promotional entitlements.

## October 6, 2026: level 2 abuse gate review 4 and fixes

Review 4: 0 blockers, 5 should-fix, 5 notes. Fixed: a successful check is a `verified` RevenueCat
answer with a later `requestDate` (the Flutter SDK cannot say fresh versus cached); coverage is the
union of known products, passes and promotional entitlements on both phone and server, existing
`pro` grants reissued as tier-named; a one-time reconciliation after the webhook URL is set; B7:
the lead's integration code gets a separate review. Open for Aedwon at E14 (lead recommends
accept): clock set back while the app is closed plus a reboot spreads the paid period plus 3 days
over a longer calendar span when RevenueCat is blocked. (Corrected at review 5: the app now also detects clock changes made
while it is closed within one boot, so the residual needs a clock change and a reboot before every
session.)

## October 6, 2026: level 2 abuse gate review 5 and fixes

Review 5: 0 blockers, 4 should-fix, 4 notes. Fixed: paused or after a rollback, the app forces a
fresh RevenueCat answer (`invalidateCustomerInfoCache`) so an honest user is unpaused at once;
in-boot clock-change detection; passes count only from the ledger; W5's E14 list carries the clock
residual as an open decision; B7 wording. Level 3 setup-step items: enable the Cloud Functions API
and confirm Blaze before the secrets steps; create `promo_student` and `promo_civil_service`; grant
giveaways only with them; new products enter the product table before sale; list and reissue
existing promotional `pro` grants before W3's release.

## October 6, 2026: level 2 abuse gate passed

Reviews 6 and 7: review 6 asked for named AC-1 and AC-7 tests (added); review 7 passes, 0 blockers,
0 should-fix, 3 notes carried to level 3 (`gates/l2-abuse-gate-7.md`). Next: level 3 amendments
(L3 W3, W4g, W5, new L3 W6, the parallel map, setup steps, executor lines per amended B7,
traceability level 3 column for X rows), then a level 3 gate.

## October 6, 2026: level 3 abuse amendments written

L3 W3 rewritten (Task 1 rebases on W6; Task 2 webhook reconciliation; Task 5 pass ledger; new
Tasks 11 to 15: offline window and trusted time, account switch, coverage rule and giveaways,
server content rule, deploy steps; Task 16 full checks), L3 W4g Task 3b (safe share creation), L3
W5 Task 1b (obfuscation and abuse re-check), new L3 W6 (8 tasks), the parallel map (W6 in waves 2
and 3, file orders), executor lines in every L3 plan per amended B7, setup steps Parts 4b and 4c,
and the traceability level 3 column for X rows. Next: level 3 abuse gate review.

## October 6, 2026: level 3 abuse gate review 1 and fixes

`gates/l3-abuse-gate-1.md`: not passed, 0 blockers, 12 should-fix, 7 notes; all fixed: W6 test
runner (built `lib/` modules, Auth emulator, `firebase-tools`, Java, demo project), W6 Task 3b early
integration, W3 execution order, answer time from the function's own clock (v2 has no request
time), the sync callable checks `proUntil`, the Android clock channel and trusted-entitlements
setting named, one owner for the trial display, W4f paused state, W4g live-link count by query and
create-only share records, budget alerts and tester allowlist setup steps, W5 symbol upload.

## October 6, 2026: level 3 abuse gate review 2 and fixes

`gates/l3-abuse-gate-2.md`: 0 blockers, 3 should-fix, 5 notes; all fixed: emulator tests named
`.emulator.mjs` so the plain stage skips them; W6 integrates Tasks 1 to 5 early (Task 5b) so W3 and
W4g never wait on deploys; paused Pro gates follow L2 W4f: a new W2 component `ProPausedLine`
(the approved line, L2 W2 contract amended) shown by every family's Pro gate while paused. L2 W3
AC-3 wording aligned (answer time from the function's own clock).

## October 6, 2026: level 3 abuse gate passed; ready for level 4

`gates/l3-abuse-gate-3.md`: passes, 0 blockers, 0 should-fix, 4 notes. The abuse review amendment
is complete at levels 1, 2 and 3. Level 4 starts with W0 when Aedwon says so; workers are GPT-6.1
Sol High through Codex (B7 as amended), so the start also depends on his Codex limit.

## October 6, 2026: Codex sandbox for level 4 workers

The first W0 run on Codex stopped at `git fetch`: Codex's workspace sandbox blocks writes to the
repository's Git folder. Aedwon chose option 1 ("1"): Codex workers run without the Codex sandbox
(`--dangerously-bypass-approvals-and-sandbox`), bound by their dispatch rules (one worktree, no
push, no secrets, no external changes); the lead reviews every commit before any push.

## October 6, 2026: W0 run 2 (Codex) stopped on the approval count; plan corrected

W0 Task 1 fast-forwarded the integration branch to 765c5dc0 (checks green, 158 of 158 lesson ids)
and stopped because the content gate showed `approved 158` where L3-W0 expected 0. The lead's
plan was wrong: the SUBAGENTS Part 4 "approved 0" rule is for question writers (Question Studio
sets `approved:`); 83 files were already approved at 1f79d880. L3-W0 Task 1 corrected; Codex
resumes at Task 2. Usage: Aedwon's Codex plan went from 42% to 55% of the 5-hour limit across the
failed sandboxed run (about 60,000 tokens) and this run (about 147,000 tokens).

## October 6, 2026: DOST-SEI and SM, lesson ids

Aedwon, on the two picker exams with no exam setup: "these should be included". W0 Task 3 adds
`exam_dost_sei` (questions already tagged) and `exam_sm_foundation` (no questions yet; release
blocker until the content track tags them) as available Student-tier exams in the Scholarships
group. On the content audit's planned prerequisites: lesson storage does not change now; lesson-level
prerequisites would change the roadmap engine and the content format, planned when the audit
reports. Aedwon: "note that the current content might get split so... proceed". L2 W0 gains the
rule that no lesson id changes without an approved progress migration. The content coverage audit
stays untouched (Aedwon: "you shouldn't touch it for now").

## October 6, 2026: W0 Task 3 stop; exam catalog moved out of the content database

The Codex worker stopped at W0 Task 3 (evidence commit 6109ad1b on the integration branch): the
plan's content schema bump from 9 to 10 conflicts with the protected content package contract (the
installer validates schema 9 on every start, the signed manifest's reader range is 9 to 9, and a
pinned schema-8 fixture inherits the database class). Lead decision (internal; no student-facing
change): the exam catalog becomes a hand-edited bundled file `content/exams/catalog.json`, read by
`ExamCatalogRepository` (API unchanged) and copied into the Functions build; content schema stays
9. Exam rows for DOST-SEI and SM go into the export's roster like ACET. Amended: strategy B2 W0 row,
L2 W0 (§1, §3, §6, §7, §8), L3 W0 Task 3, L2 and L3 W3, L2 and L3 W6, the tier spec, the map,
carry-forward N3-7. Process note: this level 2 change is checked by W0's Astra audit and the lead's
review instead of a separate gate round, to save usage; the next plan gate re-checks it.
Usage: run 3 used about 298,000 tokens; Aedwon reported 63% after run 2.

## October 6, 2026: Codex usage calibration and pacing

Aedwon asked the lead not to start the next Codex run before his usage reading; the lead had
started one (Task 4b commit and Task 5), stopped when he said so. It had already committed Task 4b
(901ffb81); Task 5 did not complete; the worktree is clean. Readings: 42% before W0, 55% after
runs 1 and 2 (about 207,000 tokens), 63% after run 3 (233,000), 95% after runs 4 and 5 (about
717,000 plus the stopped run). Calibration: about 24,000 Codex tokens per 1% of the 5-hour limit
(about 2.4 million tokens per window). Aedwon: "if you do you can stop asking me about it"; the
lead now estimates from token counts and paces runs to the limit.

## October 6, 2026: W0 accepted

W0 Task 5 ran all checks one at a time on 901ffb81: Flutter 3,429 tests passed, analyze shows only
the known `onReorder` info, format, layering and attribution checks pass. Backend `node --test`: 42
passed, 2 failed, because the test dependency and compiled policy module are missing; `functions/`
is unchanged since 1f79d880, so these predate W0. Lead decision: accept them as the known backend
baseline; W6 Task 1 must make them green. GPT-6 Astra audit (read-only): no blocker or major finding
in W0's changes; one weak equality test (fixed by the lead in 13e4f830); a W4e note that the app's
blueprint readers need the placeholder marker first (L3 W4e Task 3 amended). Lead review agrees. The
integration branch was pushed at 13e4f830. Usage: Task 5 about 571,000 tokens, audit about 123,000.

## October 6, 2026: usage recalibration

After the reset, Aedwon reported 95% used after W0 Task 5 (about 571,000 tokens), the Astra audit
(about 123,000), W1's first run (about 158,000) and part of a W1 resume (stopped by the lead with no
commits or edits). That is roughly 10,000 tokens per 1%, not the 24,000 measured before; the
earlier figure is withdrawn. Aedwon (Oct 6): usage differs by model ("when you use 6.1 Sol the usage is
different"), so token counts from Sol and Astra runs are not on one scale; the lead estimates each
model separately. Aedwon: "no need to cut things"; checks and audits stay as planned. W1 setup gap: new worktrees lack the ignored `assets/seed/content.*` files; the lead
copies the accepted package files (unchanged, never committed) into each new worktree before the
worker starts. W1 resumes from Task 1 at 2cc11ce1 after the next reset.

## October 6, 2026: backend test tools installed

With Aedwon's approval, the lead installed Node 22 (`/opt/homebrew/opt/node@22/bin`, 22.23.3) and
Java 21 (`/opt/homebrew/opt/openjdk@21/bin`, 21.0.12.1) through Homebrew for W6's emulator tests.
Both are keg-only; the shell profile is unchanged, so W6 runs put both folders first on `PATH`.
The progress Doc's 5 Oct entry now records W0's acceptance (Aedwon approved the edit).

## October 6, 2026: usage readings around Astra runs

Aedwon: "if you use astra it's okay for you to ask me about limits so that you have a better and
better estimate, and you can judge if there's enough usage for an astra run". The lead asks for a
reading before and after each Astra run, starts one only when the reading leaves room, and does not
ask around Sol runs.

## October 7, 2026: W1 and W6 lead rulings

W1 stopped at Task 2: QV_Answer's disabled Check text is `#B8B8BD`; the README token for disabled
text is `#AEAEB2`. Ruling: the README token everywhere (one token for one meaning; the difference is
slight). Aedwon may overrule. W6 stopped at Task 3: the sync spec states no cap on staging
generations. Ruling: at most one new staging generation per account every 5 minutes, enforced in
the Firestore rules through a limits document written in the same batch, because clients create
staging generations directly; stale ones are already cleaned daily. Plans L3 W1 Task 2 and L3 W6
Task 3 amended. W1 Task 1 (d880d6bc) and W6 Tasks 1 and 2 (a8aef406, 10a713f2) are done. W6 found
16 npm dependency vulnerabilities, for the lead's review at W6 acceptance. Node was also upgraded
(26.10.0) because the Node 22 install had updated a shared library Codex needs.

## October 7, 2026: W1 icon package and W6 batch bypass rulings

W1 stopped at Task 4: `phosphor_flutter` 2.1.0 (its last release, May 2024) does not compile on
Flutter 3.44 because `IconData` is now final. Ruling: bundle the package's own Phosphor regular font
(MIT) and define the icons directly; glyphs are identical; the dependency is removed. W1 Tasks 2 and 3
are done (05112e1c, 5e0eef33). W6 stopped at Task 3: the emulator let one batch create two staging
generations through one limits write. Ruling: the limits write names the generation id, and the
create rule requires it to match. Plans L2 and L3 W1, L3 W6 amended.

## October 7, 2026: W6 Astra audit 1

GPT-6 Astra audited W6 Tasks 1 to 5 (126,000 tokens): 1 blocker (anonymous cleanup ignores token
refresh, so a daily user could be deleted), 4 major (the 5-minute staging limit can strand sync with
no retry, which the lead's ruling caused; three cleanup races, two of them older than W6), 3 minor.
The lead checked the sync retry finding in the code and agrees with findings 1 to 6; 7 and 8 are
recorded for W5. Fixes are L3 W6 Task 5c. The lead's own review had missed the blocker and the
races. Process error: the lead started the Astra run alongside a W1 Sol run without a reading, so
Aedwon's 75% reading cannot be split by model; Astra runs alone from now on. W1 reached Task 7
(43da63fa) and stopped at the Codex limit (1,253,000 tokens in that run).

## October 7, 2026: W6 Tasks 1 to 5c integrated

Sol fixed audit findings 1 to 6 (Task 5c, 1,090,000 tokens). The lead checked the fixes, reran the
backend tests (52 plain, 58 emulator) and the sync tests (211), and fast-forwarded the integration
branch to 739ccae1; the full Flutter suite there passed (3,434 tests). W3 can now start its tasks
that wait on W6. W1 reached Task 9 and stopped at the Codex limit (1,588,000 tokens in that run;
it found and is fixing its own Task 7 error, Settings outside the tab shell).

## October 7, 2026: W1 complete; W3 tier contract ruling

W1 finished Task 9 (4136c146): full suite 3,507 tests passed, analysis shows only the accepted
notice, format, layering and attribution checks pass; the backend's two known failures are on its
pre-W6 base. W1 now needs the Astra audit, the lead's review and visual acceptance. W3 stopped at
Task 4: the plan expected a `PriceTier` enum from W0, but W0 stores the tier as a string. Ruling:
W3 Task 4 adds the enum and `tierForExam` over the catalog (L3 W3 Task 4 amended).

## October 7, 2026: W3 pending-payment ruling

W3 Tasks 3 and 6 are done (e102802f, b22897d5). Task 7 stopped: the SDK cannot list pending
orders, so the plan's "nothing can be bought twice while pending" had no defined end. Ruling: a
device marker per account; it clears when the entitlement turns active, or when the student taps
"Restore Purchases" (the button ST_ProPending draws) after 72 hours with no entitlement; Play rejects a true duplicate (L3 W3 Task 7
amended). Source: RevenueCat's Google Play guides (pending purchases are canceled when payment
fails or expires).

## October 10, 2026: W1 Astra audit 1

The scheduled audit ran alone on Oct 8 at 12:12 AM (146,600 tokens, 5 minutes). No blocker; 5 major
(font and icon licenses not shipped; adapter colors lower contrast on screens not yet rebuilt;
unselected tab labels at 3.44:1; tabs lost keyboard activation; pop and shake differ from the
keyframes), 5 minor. The lead agrees with all and added L3 W1 Task 9b; finding 3 (tab label color
drawn by the design) is a design choice for Aedwon. The lead's own review had checked colors and
routes only and missed these. W3 reached Task 8 (9ff83c62) and stopped at the Codex limit on Oct 7
with Task 9 edits uncommitted in its worktree.

## October 10, 2026: unselected tab color

Aedwon chose, from a side-by-side of both tab bars: "Tab labels: option 2, use the darker gray
#6E6E73". Unselected tabs in light mode use the secondary label token instead of the drawn
`#8A8A8E` (3.44:1, below the 4.5:1 minimum). This overrides the boards for that one color. L3 W1
Task 9b item 3 amended.

## October 10, 2026: W1 legacy contrast ruling

W1 stopped before Task 9b: restoring old colors for legacy screens could not reach 4.5:1 either.
Ruling: keep the new destructive fill and make its label white (5.39:1); leave the legacy
wrong-answer text and legacy mock timer as they are, because W4d and W4e replace those screens and
now carry a contrast test each (L3 W1 Task 9b item 2, L3 W4d, L3 W4e amended).

## October 10, 2026: model roles amended

Aedwon proposed and approved (answers "1. yes 2. yes"): Opus plans and orchestrates; GPT-6.1 Sol
implements, with Sonnet 5.5 as a second implementor; Haiku or GPT-6 Luna read and summarize. His
limit: "only invoke sonnet if 6.1 Sol has run out, and never have it pick up Sol's work". Strategy
B7 amended. The extra Claude usage for Sonnet is accepted. Astra audits all workstreams.

## October 10, 2026: reading tier may run checks and mechanical edits

Aedwon agreed ("yup that makes sense"): Haiku or GPT-6 Luna may run checks and report, make
rule-exact mechanical edits, and do lookups; on a failing check they report and stop. They do not
write tests or touch payments, security rules or sync. Strategy B7 amended.

## October 10, 2026: W3 claims ordering ruling; W1 audit fixes done

W3 Tasks 12 and 1 are done (bf32a453, 7b47cbb1). Task 2 stopped: the plan put the claims write
"in one Firestore transaction", which Firebase cannot do. Ruling: Firestore holds the entitlement
record; claims are copied from it after commit, with a version check, a 500 on failure so
RevenueCat retries, and an hourly repair job for mismatches (L3 W3 Task 2 amended). W1 Task 9b is
done (70d0a476; 3,526 tests passed); the lead merged W1 into the integration branch locally and is
running the full checks before pushing.

## October 10, 2026: W2 rulings and the W3 pass question

W2 built nine components and stopped on fourteen questions (245a8358; full suite 3,588 passed).
Cause: the lead's dispatch demanded 4.5:1 for every color, which also caught disabled, dimmed and
decorative marks. The lead narrowed the contrast rule (text 4.5:1, large text and meaningful icons
3:1, disabled, dimmed, placeholder and decorative marks exempt) and ruled on the accuracy bar,
skeleton token, Pro tag (teal as drawn; "gold" in L2 was the lead's error), question stem sizes and
page title (L3 W2 "Lead rulings"). Four design choices wait for Aedwon and are built with board
values meanwhile: day-off dates, search placeholder, wrong-answer text in dark mode, math font.
W3 Task 2 is done (0bef4c44; 56 plain and 66 emulator tests). W3 Task 5 stopped: RevenueCat gives
no reliable way to attach the chosen exam to a one-time pass purchase. The plan's fallback is one
pass product per exam, which changes the approved product list, so it goes to Aedwon.

## October 10, 2026: pass products and four design choices

Aedwon, after a detailed explanation and side-by-side comparisons: "1. A" and "2. A A C B".
1. One Season Pass product per exam (`pantas_pass_cse_pro`, `pantas_pass_cse_sub`); the product id
   binds the exam, because RevenueCat does not reliably deliver purchase metadata for one-time
   purchases. Amended: tier spec, L2 and L3 W3 (Tasks 4 and 5), setup steps Parts 2 and 4.
2. Day-off dates as drawn; search placeholder as drawn (he accepts 2.79:1); wrong-answer text in
   dark mode `#FF6961`; math keeps the KaTeX serif fonts. Amended: L3 W2 ruling 7. The README's
   "Source Serif 4 only for math" no longer applies to rendered math.

## October 11, 2026: Astra cost measured

The W2 Astra audit started alone at 5:26 AM, two minutes after the Codex reset, and hit the usage
limit after 2 minutes and about 122,000 tokens, before writing its report; the limit then showed
"try again at 10:27 AM". One Astra audit at medium effort therefore costs about one full 5-hour
window (earlier complete audits used 123,000 to 147,000 tokens). This explains the earlier readings
the lead could not split. Consequence for Aedwon to decide: Astra for every workstream means one
window per audit with no building in it. W2's worker finished all components (d2edde76; lead-run
checks: 3,675 tests passed, layering and attribution pass, analysis shows the known notice, two W2
files need formatting). W3 resumes at 10:29 AM.

## October 11, 2026: W2 audit 1 and W3 build complete

Astra resumed the W2 audit at 10:29 AM and finished in 2 minutes (about 7,000 more tokens; the
interrupted run had done the reading). No blocker; 10 major (math corrupted by Markdown parsing,
screen-reader and keyboard gaps, missing answer marks, a missing horizontal wheel, motion that
differs from the boards, two contrast pairs), 9 minor. The lead agrees with all; fixes are L3 W2
Task 8b with rulings for the token and outline questions. W3 then finished Tasks 5, 13, 10 and 14
(5b23689d; 81 plain and 89 emulator tests pass). Remaining for W3: the router edits held back for
W1, the Astra audit, Aedwon's setup steps and the deploys.

## October 11, 2026: W2 accepted and integrated

All 19 audit findings fixed (Task 8b, through 9e149234). The lead merged W2 into the integration
branch (18399e61, evidence commit b935cbd2): 3,712 Flutter tests and the backend tests pass. W4h (app-wide
states) starts next because its first task sets the pattern for the other screen families. The
lead added `docs/design/tools/outline.py`, which prints a board's text and key style values, so
screen workers read less.

## October 11, 2026: W4h rulings

W4h finished Task 3 (b8de9e05; full suite 3,715 passed) and stopped on Tasks 1 and 2. Rulings: the
save-failure line is "Could not save your progress." with "Try Again" (lead default, for Aedwon to
confirm); a screen family may extend a W2 component in place, with tests, when a board needs more
(never a local copy); `StateView` follows ST_NoExam and SY_Error exactly (L3 W4h amended).

## October 11, 2026: W4h integrated; W3 audit 1

- W4h Tasks 1, 2, 3 and 5 reviewed by the lead and integrated (integration/new-design-r1 at
  cee7a9c5; 3,730 Flutter tests pass). Start-up failures of storage, content install or Firebase
  setup now show "Something went wrong." with Try Again, as the plan requires. Task 4 waits for the
  other screen families.
- GPT-6 Astra audit 1 of W3 at 4a36a3b3: no blocker, 3 major, 2 minor
  (`gates/w3-astra-audit-1.md`). The lead agrees with all five and wrote the fix designs as L3 W3
  Task 14b: one claims copier per account with a lease and a pending flag, an indexed hourly repair
  plus a daily check of recently changed records, expiry on webhook records, an automatic fresh
  check when access pauses, and the Restore result taken from confirmed coverage.
- Usage note: the audit used about 129,000 tokens in 3 minutes; two Sol workers then ran 30 minutes
  (about 850,000 tokens reported) before the window ran out.

## October 12, 2026: W3 accepted and integrated

- Sol fixed all five audit findings (Task 14b). The lead's review found the two new `server`
  indexes written as one-field composites, which Firestore rejects at deploy; fixed as Task 14c
  (field overrides). The lead merged the integration branch into W3, ran the full checks
  (3,858 Flutter, 84 plain and 92 emulator backend tests), and fast-forwarded the integration
  branch to 2d438daf.
- Note for the deploy: the TTL override on collection group `users` (field `expireAt`) also
  covers top-level user documents; a test now asserts no source writes that field there.
- Aedwon confirmed on October 11 that GPT-6 Astra keeps auditing every workstream (he considered
  Sol High for audits and chose to keep Astra).

## October 12, 2026: Codex weekly limit reached

- At 7:25 PM all Sol workers stopped with "try again at Oct 18th, 2026 12:58 PM" (the weekly
  limit, not the 5-hour window). Since October 11 the windows had lasted 20 to 100 minutes with
  two workers.
- State then: W0, W1, W2, W3, W6 Tasks 1 to 5c, W4h (Tasks 1, 2, 3, 5), W4b Task 1 and the
  day-context type, and W4e Tasks 1 and 2 integrated at 958ed879. W4a, W4b, W4c, W4d, W4e, W4f in
  progress on their branches and worktrees.
- Lead also wrote standing rulings for the W4 families (L3-parallel-map.md) after W4a, W4b and W4c
  stopped for contrast gaps and cross-family contracts.
- Aedwon's decision (Oct 12): wait for the weekly reset on October 18. He declined adding credits
  and declined letting Sonnet 5.5 continue Sol's unfinished families. Until then the lead does only
  lead work (review, integration, records).

## October 13, 2026: engineering resumed in Codex

Aedwon asked: "can you pick up and continue the latest engineering work? before that, tell me the current state, what % of the total completion is the engineering path of things, and then wait for my confirmation before proceeding". The lead reported an approximate 50% implementation task-count estimate for the current restart, excluding the separate content track; this is not a weighted effort or release-readiness measurement. The current integration head is 5e6cda4541a80609b27f2784fc2e58d39731a33b and matches origin. The recorded 3,971 Flutter test pass is historical evidence on that candidate, not a fresh run.

Aedwon then authorized: "okay resume that. the plan already tells what to do exactly right?" This lifts the October 18 wait for already-approved implementation. Scope and complexity remain those approved in the strategy, amendment spec, L2/L3 plans and later rulings. It does not authorize production deployment, publication, application-code changes on main, autonomous app screenshots, or a new unattended automation. The paused B9 scheduled task remains paused.

The lead read policy from main c96177bc4495fd2482489b0d44585ea54b3e000b and retrieved current policy again on resumption. Live account limits permit ordinary work (4% short-window, 1% weekly used at the check); the earlier reported limit is not currently active. Current remote and local integration heads match. Worktrees retain their expected local merges and dirty drafts: W4a 5, W4c 13, W4d 10, W4f 29. No reset, cleanup, or overwrite occurred.

Routing: one self-hosted relay runner online and idle, two offline. Actual relay request Aedwon/chatgpt-terminal-relay#9488 succeeded on W4d, exit 0, and confirmed its dirty drafts. No browser dispatcher is used. Two GPT-6.1 Sol High workers resume W4d and W4c in their existing separate worktrees; lane order remains W4d/W4f/W4a and W4c/W4b/W4e. They preserve unfinished Sol work and current standing rulings. Astra audits run alone after implementors stop. Lead accepts and integrates only after required independent review and applicable checks; visual acceptance stays with Aedwon. Required live setup and deployment steps remain pending.

## October 13, 2026, 9:46 PM: continue after the usage-window stop

Aedwon said: "continue". Live account state now permits ordinary work: short-window 0% used, weekly 16% used. This continues the existing approved scope; no new complexity choice or implementation approval is needed. The lead re-read current AGENTS.md and WORKFLOW.md from origin/main f11a45cb150620250b0ab0e80cefa3a8d70ef559 and verified one online idle relay runner.

Verified handoff from the prior window: W4d's Task 2 partial checkpoint is locally committed at 0ad018fe64678a26ae8e35af665de5e94c79c45b. Relay #9517 passed 975 affected Flutter tests, formatting (1,448 files, zero changes), layering, attribution and diff checks. Analysis reports only the explicitly accepted W4c bookmark onReorder notice. Relay #9519 committed the scoped source/tests/evidence and confirmed a clean worktree. Nothing was merged or pushed. Task 2 still lacks the Home-owned row/sheet contract and later session metadata; the family remains unaccepted, unaudited and visually unverified.

W4c relay #9518 timed out after 120 seconds, exit 124. The worker then failed on the usage limit before it could finish the handoff. No passing result or completed-task commit is inferred. Its dirty draft is preserved. The same two Sol workers resume: W4d begins Task 3, and W4c inspects the saved source/logs and continues Task 8 systematic debugging before later independent tasks. Astra audits remain serialized after implementors stop. The main application-code freeze, deployment approvals and publication boundary remain unchanged.

## October 13, 2026: W4d Task 3 clarifications

The worker asked whether Adjust should preserve the Total time budget or change the total/time,
pointing to the single-lesson board. The lead opened DECISIONS.md D-164 through D-166,
SCREENS.md and the actual QZS_1c, QZS_1d and QZE_One board sources. QZS_1c and QZS_1d keep 30
minutes/~33 questions while changing 28+5 to 20+13. QZE_One is Questions per lesson mode (20
questions/~18 minutes), not Total time. Ruling: Total time remains fixed, Adjust redistributes its
question budget within availability, Reset returns to the even allocation. A lone lesson has no
alternate redistribution destination; bounded steppers do not silently change the time wheel.
This interprets the already-approved "You set the time. Questions follow." and "set the split by
hand" rules. No user choice or visual substitution is claimed. Questions-mode Adjust remains drawn.

The worker also found that questionOutcomes reads completed saved attempts. The lead read the
assigned branch's SubmitAnswer, ReviewStateRepository and questionOutcomes source: each checked
answer saves its review state and timestamp before the session completes; saved attempts alone
miss a discarded partial session. Ruling: supplement the required attempt query with existing
batched review-state reads and real checked-answer timestamps (reps > 0), with regression coverage
for discarded partial sessions, fresh seeds, the seven-day boundary and top-up. No new storage,
schema, synchronization path or study-method decision is authorized. Current L3 W4d carries both
clarifications before the affected adjustment/recency implementation. Tests and the later Astra
family audit must check these cases.

### Questions per lesson Adjust, same Task 3 clarification

The worker proposed retaining the selected wheel value as the even base, using explicit row
steppers for manual count overrides, letting derived time follow, and clearing overrides on
Reset or an explicit wheel change. The lead accepts this interpretation of the existing D-164
question-driven mode and Reset rule. QZE_One keeps its drawn Adjust control and can change a
single lesson's real count. Unlike Total time mode, the student is explicitly setting questions,
so derived time changes. No silent wheel synchronization occurs. Pool availability still caps
every count. Current L3 W4d records the rule before implementation, with tests for counts/time,
single-lesson behavior, bounds, Reset and wheel changes. No visual styling, price, storage schema
or spacing rule changes. If Aedwon requests different wheel semantics later, return it as a
visible product revision; do not silently change an approved presentation.

## October 14, 2026, 2:47 AM: continue from the next reset

Aedwon said: "continue". The short-window limit has reset (0% used, weekly32%, ordinary usage
allowed). The lead fetched origin and read current AGENTS.md and WORKFLOW.md from main93d563b7;
no policy/code-branch drift was found. One self-hosted relay runner is online and idle.

W4c's partial Task8 checkpoint606ee3fc6e569d187bad90e1cbcd880519fab72f was committed by#9552
before the limit:925 focused tests and clean analysis, formatting/layering/attribution/diff
checks pass. Tree is clean. Full Task8 still lacks drag proxy and screen-reader destination
fidelity. No upload occurred. Lead review of the immutable source found that a retained Undo
payload carries old rows/order/examId without an account/reset provenance check; the account-clear
test only performs fresh reads. The mutation recorder captures current context when restoration
starts, so it is not proof that old Undo data is rejected. The worker was asked to reproduce the
actual boundary case or prove an existing lifecycle guard, and fix through existing mechanisms
if needed. This is a pending finding, not a claimed exploit or accepted fix. Upload remains held.

W4d remains at uploaded0ad018fe. Task3's dirty core slice passed522 applicable tests in#9554
but had seven owned style findings; the picker UI remains an intentionally unfinished RED draft.
No Task3 commit is inferred. Same Sol workers resume their exact checkpoints: W4c boundary/Undo
verification first, then Task8 fidelity; W4d style/focused checks and a scoped core save, then UI.
Original approved scope, model roles, application-code freeze, deployment approvals and visual
acceptance remain binding. Neither family is accepted or integrated by these partial checks.

### October 14: existing token for retained bookmark Undo

The worker located the existing SyncActiveContextStore token, which changes on runtime quiesce
and wipe. The lead read its actual assigned-branch implementation: anonymous snapshots keep a
token with null context; clearStable and publishStable rotate tokens. The mutation recorder binds
current writes but does not authenticate an earlier retained removal payload. Technical ruling,
recorded before guard code: capture the existing token transactionally at removal and compare it
before restoration writes in the same transaction; expire old Undo when the boundary changes.
Keep valid active context intact. Missing legacy token may initialize the existing anonymous
envelope only. No new schema, account mechanism or synchronization path is authorized. Tests must
reproduce actual wipe/account-switch/anonymous cases and preserve normal Undo. This implements the
existing account-isolation requirement; it does not claim the pending finding already fixed.

### October14: current sizing-mode semantics and nonpositive pace

The worker flagged an ambiguity between current D-166 "nearest matching value" and retained July
numeric snapping. The lead read the old spec and source: July explicitly sized minutes per
selection, never a total. Current approved design changes to questions per lesson and total time,
so carrying10 from one mode to the other can change quiz size substantially. Ruling: match the
closest actual aggregate question count under current pools/pace and valid destination wheel
values; use deterministic ties, clear explicit manual overrides, and test repeated toggles against
successive drift. This interprets the current approved design rather than restoring old scope.

The worker also found that the repository can return a zero average, while the UI divides by it.
Ruling before affected code: nonpositive pace is unavailable for estimation; the already-approved
50-second initial pace covers both core and UI until a positive measurement exists. Tests cover
zero/negative values, bounded counts and nonempty estimates. No new student figure, spacing rule,
pricing, storage schema or data source is authorized. Current L3 W4d records both clarifications.


## October 14, 2026, 10:36 AM: continue and save reviewed bookmark work

Aedwon said: "continue". Live usage permits ordinary work (2% short-window,48% weekly used).
Current AGENTS/WORKFLOW were retrieved from main26b83566. Existing Sol workers resume, preserving
ownership, drafts and the approved scope. No new complexity or publication permission is inferred.

Relay9594 fetched main and W4c but stopped at the missing W4c upstream configuration. Relay9595
then checked explicit refs successfully: W4c clean23113d73 ahead6/behind0 from287a640b;
W4d15325e04 matches remote with known UI drafts; integration5e6cda45 matches remote. Main trails
only expected lead documentation commits. No reset, overwrite or history rewrite occurred.

The lead inspected immutable W4c606ee3fc..23113d73 source/tests and actual9579/9589 evidence.
Token/exam validation precedes restoration writes in the transaction; valid active contexts are
preserved. Boundary tests use the actual wipe and verify next-account membership remains intact.
Expired Undo clears Retry, including late old errors; move messages capture destination before
persistence. Relay9589 passed937 prescribed tests, clean analysis/format/layering/attribution/diff.
The blocking retained-Undo finding is resolved at4d1d9980; destination wording is23113d73.
Normal upload9596 passed and GitHub full SHA23113d73a72ffa498f2c9ca652c9b2ee83af3d48 matches
intended local head. This is a scoped reviewed working checkpoint, not full-family/Astra,
integration, visual acceptance, peer-device convergence or publication.

The reported bookmark timing conflict is under further source review: BMEdit_n92 holds the same
translateY at release and200ms later while scale/shadow settle. Do not assume it promises200ms
proxy-position settling or ask for an exception before establishing a real represented mismatch.
No alternate proxy implementation or visual waiver has been approved. W4d continues recorded
aggregate-mode matching and nonpositive-pace corrections before its Task3 UI checkpoint.


### October14: resume reader work through landed contracts

The lead read actual assigned-branch LessonDayContext and quiz entry source. Both exist in the
integrated5e6cda45 base. L3W4c5f5748fe resolves the older missing-contract hold: finish remaining
Task8 fidelity when possible, then Tasks5,6,7,9. If a real presentation departure blocks only
Task8, independent reader tasks may continue while the lead resolves that specific choice.
Task9 and full-family acceptance remain blocked by any unresolved requirement. No substitutes,
new scope, visual waiver or user decision is inferred.


### October14: correct the drag-timing finding; offer the actual neighbor curve choice

The lead initially reported a250ms versus200ms drop-timing conflict. That inference was too
broad. Worker and lead reread BMEdit_n92 and the timeline: translateY(-124px) is unchanged between
10000and10200ms; only scale/shadow settle. Public animation status allows a local decorator to
match150ms lift and200ms houseOut settle. L3W4c b7176243 records this correction before code,
including short-release, cancellation, unmount and reduced-motion coverage. No SDK patch needed.

There is a different actual represented mismatch: BMEdit_n89/n86 shift62px in250ms using
cubic(.3,.9,.3,1). InstalledFlutter3.44.6 revisionee80f08bbf97172ec030b8751ceab557177a34a6 uses
250ms gap offsets with easeInOut cubic(.42,0,.58,1), a private animation without a public curve
parameter. The decorator changes only the dragged row, not neighboring offsets. Lead verified
SDK lines1307/1339 and board timeline9300→9550and9600→9850. This is not a duration difference.

Proposed comparison v1: task-owned bookmark-neighbor-motion.html under chat visualization root.
It isolates two mathematical62px translations over250ms, with actual-speed and quarter-speed
replays. It omits full app rendering, row styling, dragging, lift/drop decoration and other
screen states. Do not claim phone/visual acceptance. Local DOM/runtime checks verified midpoint,
both replay endpoints, reduced-motion behavior and file limits; no browser/app operation occurred.

Offered options: accept the built-in neighboring movement curve, requiring no replacement drag
system (lead recommendation, least code/maintenance); or retain exact approved curve, requiring
custom drag behavior, estimated1–2 engineering sessions plus review, with effort uncertain until
implementation/verification. This recommendation is only a proposal, not permission to waive
1:1 fidelity. Aedwon's choice is pending. Approved decoration and independent reader/quiz work may
continue; Task8/full-family acceptance cannot pass with this represented difference unresolved.

The project workflow says: "Any necessary difference must be shown and resolved with Aedwon
before implementing that difference." This project requirement, not a new skill gate, requires
his decision. The motion-only representation is disclosed for that decision. No custom drag
system, curve exception, app screenshot, deployment, publication or main application change
is approved by this offer.


## October14, 2026, 12:06 PM: built-in neighbor motion accepted

Aedwon's exact reply: "accept built-in". He chose the recommended built-in neighboring-row
movement after comparisonv1 disclosed movement-only representation. Accepted difference:
250ms easeInOut cubic(.42,0,.58,1) for neighboring gap offsets instead of BMEdit's250ms houseOut.
Rejected alternative: replacing drag behavior to retain the exact curve, estimated1–2 sessions
plus review and more maintenance. Keep the existing SDK drag system. This approval is confined
to that demonstrated neighbor curve; lift150ms/drop-decoration200ms houseOut remain binding.
It is not full-screen phone acceptance, a broader motion waiver, deployment or publication.

The worker has verified decoration checkpointcdda64f5bef052f201e263f1f466e3f0893bd545;
945 prescribed tests and clean static gates are reported, pending lead inspection of actual
source/logs. No worker upload is inferred. Task5 boards/source investigation continues.
Current live capacity was90% short-window/62% weekly at the lead check; prioritize exact saves
and handoffs if the window runs out. Approved continuation remains authorized.


### October14: bounded technical reader and duration clarifications

Before affected fixes, L3d d77df3bd records positive sub-minute formatting: retain valid measured
pace; a nonempty positive duration rounding to0 uses existing metric "<1"/"minute" and summary
"under 1 min". Do not invent1minute or alter Total time budget. Empty remains0. Cover real
positive sub-minute, ordinary and empty cases. This resolves an implementation-format gap in
the approved estimator, not a new measured/default pace or layout.

L3c a04aca18 records a board-required additive readerContents PantasSheet variant, preserving
other modes. Worker source/board comparison found generic420/320 timing versus required450/400
slideC and350ms ease wash32%,105% translation, intrinsic height, no page transform. Lead read
actual shared source before extending ownership to that component/tests. Navigation source
closes Bookmarks before pushing a reader labeled Bookmarks; preserve the sheet on stack for a
truthful return. Use existing Home/Study fallback when no origin stack exists; do not create
absent plan/performance routes. Focused tests required before acceptance.

Lead confirmed Task8 ListRow.divider is leftfalse while board draws0.5px separators. Reuse the
shared option if placement matches, otherwise report exact needed extension. This remains an
unfinished fidelity item, not resolved by the neighbor-curve approval. Task5 has six dirty
production/test files, not merely RED fixtures: routeextra/daycounter/dayrail and origin/bookmark
work is partial. Known tests18bar/1day-route pass, but one style notice and stale ProgressRule
rail test remain. Shared sheet/navigation still unimplemented. Preserve exact drafts; do not
commit or upload them as verifiedTask5.

Decorationcdda64f5 was lead-reviewed against immutable23113d73 delta and actual#9604 output:
945 prescribedtests, clean analysis/format/layering/attribution/diff. Public150/200 localcontroller
and listener cleanup match scoped requirements, including reducedmotion/shortrelease/cancel.
Relay9624 fetched and confirmed cdda64f5 ahead1/behind0 from23113 with the known six Task5 drafts.
Normal checkpoint upload9625 requested; success/SHA must be verified separately.
Capacity96% short-window/63% weekly. Workers were told to save only verified boundaries or
preserve exact unverified drafts and idle; no new broader tasks. This capacity stop does not
revoke Aedwon's approved continuation or restore his earlier October18 wait.


### October14,12:10PM: verified upload and capacity boundary

Relay9625 normalpush succeeded. The lead checked GitHub full remoteSHA
cdda64f5bef052f201e263f1f466e3f0893bd545 against intended localHEAD. Only reviewed committed
bookmark decoration was uploaded; six known uncommitted Task5 drafts remain local. W4c Task8
still needs separator fidelity correction. Fullfamily/Astra/integration/phone acceptance remain.

W4d remains local/remote15325e0465e2581171180fdb5b89325d159d76ab, no UI commit. Worker reports
actual9623:91 focused tests pass; format/layering/attribution/diff0; owned12-file analysis has
one test cascade notice. No relay pending. Exact current12-source SHA256 manifest saved at
W4d-task3-current-identity.json under evidence/logs; root read it. L3d sub-minute formatting and
regression have not started. Save unverified drafts/evidence; do not mark Task3 completed.

Live short-window99% used, weekly63%. Workers stop at saved capacity boundary; original
engineering continuation remains authorized. Next reset14October3:34PM Asia/Manila. No new
unattended automation or repeated approval is required/inferred. Status lock released for
next authorized resumption, which must refresh policy, reconcile refs and preserve drafts.
