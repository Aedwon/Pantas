# Level 2 gate review (strategy B4)

Reviewer: independent tier-2 reviewer (not an author of the reviewed documents). Date: October 6, 2026.
Policy revision read: origin/main 12fb353b (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Main checkout clean at 12fb353b.
Code branch checked: `integration/new-design-r1` at 1f79d880 (worktree `Pantas-wt-integration-new-design-r1`, equal to origin).
Nothing was edited, committed or pushed in the repository.

Totals: 4 blockers, 17 should-fix, 15 notes (F-25 is the list of verified-correct facts).

---

## Check 1: traceability ownership (script evidence)

Script: `scratchpad/trace.py` parses every table row of `traceability.md` (7 columns) and cross-checks plans.

- 831 rows, 0 malformed rows, 0 duplicate IDs.
- Workstream counts: W4f 153, W4b 153, W4e 98, W4d 95, W4c 86, none 67, W4a 55, W4g 37, W1 27, W2 18, W3 14, W4h 13, W0 12, W5 3.
- Every workstream value is one of the 13 plans that exist (W0, W1, W2, W3, W4a to W4h, W5) or `none`. 0 invalid.
- Every non-`none` row (764) has a section of the form `L2-<file>.md §n`; the file matches its workstream and section `## n.` exists. 0 violations. Every `none` row has an empty section. Level 3 column empty everywhere.
- W4a to W4h: the board and "other rows" lists in each plan's §2 equal the table's rows for that workstream exactly (0 missing, 0 extra), and the header counts match.
- 288 board rows equal the 288 files in `docs/design/boards/`. Every DECISIONS.md bullet (238) has a `D-` row, plus D-5 (the intro paragraph).
- Plan references that resolve to no row: D-18, D-33, D-89, D-102, D-160, D-170. All are heading lines inside cited ranges ("D-160 to D-166"); harmless.

Check 1 passes mechanically. Findings F-1, F-5 and F-17 below are ownership problems the mechanical check cannot see.

---

## Findings

### F-1 · check 1/2 · blocker
Location: `traceability.md` rows B-AS_Question, B-AS_Picked, B-AS_Leave, B-AS_Results (owner W4d); `L2-W4d-quiz.md` §2; `L2-W4a-onboarding-and-assessment.md` §1, §3, §5, §8.
Evidence: the table assigns all four assessment boards to W4d, and W4d §2 lists them. But W4a builds the assessment: §1 "and the one-time assessment (pick then Next, results by subject shown once)", §3 owns "`/assessment/:examId`, `/assessment/:examId/results`", §5 animates "AS_Question, AS_Picked, AS_Results", §8 files `lib/features/assessment/`. W4d §1, §4 and §8 never mention the assessment.
Resolution: move the four AS_* rows to W4a (section §2) and remove them from W4d §2, or the reverse. Recount the headers (W4a 59, W4d 91 if moved).

### F-2 · check 3 / facts · blocker
Location: `L2-W3-payments-and-identity.md` §3 ("Exam tier", "Season Pass end"); `L2-W4a` §1 (grouped picker, Coming soon rows, known-date card); `L2-W4f` §4 (Pro pages per tier and pass).
Evidence: W3 "`tierForExam(examId)` from exam metadata" and "Exam dates come from exam metadata, never the student's own date". On the branch, `lib/core/content/tables/content_exams.dart` has only id, schemaVersion, isActive, updatedAt, code, name, shortName, language, ordering, isCustom; `lib/core/storage/domain/exam.dart` has id, code, name, shortName, language, isActive, subjects. No tier, exam group, Coming soon flag, or published exam date exists, and `grep -rn "PSHS\|NAPOLCOM" lib tools` finds nothing. No plan owns this data. A published exam date is a figure shown to students ("Until Mar 1, 2027"), so it also needs a published source (AGENTS.md "Never invent a figure").
Resolution: add an "exam catalog" contract to W0 (or W3) naming the fields (tier, group, coming soon, published date per sitting, multi-day last day), their source and who supplies the dates. Mark any undated exam as "pass cannot be bought" per D-227 rather than inventing a date.

### F-3 · check 4/5 · blocker
Location: `L2-W3-payments-and-identity.md` §1 item 3, §3 ("Exam tier", "Products", "Entitlement"), §4 external setup.
Evidence: `docs/pricing.md` "Not yet settled": "Tiers need a design spec covering entitlements, new product IDs, upgrade handling, and pass expiry before any product is created. Product IDs are permanent." Also: "₱149, ₱249, ₱299, ₱499 and ₱1,499 must be confirmed as available in the Philippines before products are created." The amendment spec has no tier content. The Oct 6 log entry approves the scope ("Aedwon: '1'"), not a spec. W3 defines the entitlement model in a level 2 plan and has Aedwon create products in level 3. WORKFLOW treats payments as never low-impact.
Resolution: write the tier entitlement spec (plain-language part for Aedwon's approval) before level 3 of W3, or record Aedwon's explicit waiver of the pricing.md requirement. Add the store price-point confirmation as a W3 stop condition.

### F-4 · facts / check 3 · blocker
Location: `L2-W0-integration.md` §3 "Recorded-only data"; consumed by `L2-W4d` §4 ("reason stored as one nullable column plus optional text (W0 contract)") and `L2-W4e` §1, §4 (blank reasons).
Evidence: W0: "mistake tags keep `misread`, `slipped`, `unknown`, `other` plus optional text; mock review keeps blank reasons. Consumers delete widgets, never these writes or columns." On the branch: `lib/core/storage/domain/attempt.dart:11` `enum MistakeTag { misread, slipped, unknown }`; no text field; `grep -rni "blankReason\|ranOutOfTime"` finds nothing. These are new data (D-183, D-196), not kept data. W0 makes no `lib/` edits, so no plan adds them, and the sync payload changes with them.
Resolution: in W0, state that `other`, the note text and blank reasons do not exist yet. Assign them (data, sync format, any migration) to W4d and W4e, or to a W0 amendment, with the order.

### F-5 · check 1 / facts · should-fix
Location: `L2-W2` line 61, `L2-W4e` line 39, `L2-W5` line 29 ("R-7"); `L2-W3` line 65, `L2-W4e` line 51 ("R-1"); `traceability.md` G-b-5 ("R-5"), G-e-16 ("R-1"), G-g-18 ("R-2").
Evidence: in the table, R-7 is "Base: integration branch from web/roadmap-engine-r1", R-1 is "Name: 'the new design'", R-5 is "short public ID", R-2 is "Cleanup". The plans mean placeholders (table R-20), mock review gating (R-12), Progress retired (R-16) and Pro History (R-13). These references use the restart log's handoff decision numbers, which collide with the table's R- numbering.
Resolution: replace with the table IDs (R-20, R-12, R-16, R-13). Use one numbering scheme.

### F-6 · check 2 · should-fix
Location: `L2-W1` §1 and §3 "Routes"; `L2-W4b` §3; `L2-W4d` §3; `L2-W4e` §3.
Evidence: W1 retires "`/progress` as a tab, `/plan/dossier/:mockId`, `/mock-exam`, `/quiz/results/:attemptId`". W4b also retires "the `/progress` branch ... `/plan/dossier/:mockId`", W4d "`/quiz/results/:attemptId`", W4e "`/mock-exam` placeholder". Two owners per retirement, no stated split.
Resolution: W1 removes the routes; each W4 family deletes the screens and widgets behind them. Say so in both places.

### F-7 · check 2 · should-fix
Location: `L2-W1` §3 "Routes"; `L2-W4a..g` §8 ("its routes in `lib/app/router.dart`", "routes"); `L2-W4g` §3.
Evidence: seven W4 families edit `lib/app/router.dart` and run in parallel; no plan states an order (W4b states one only inside itself). W1: "families add routes under their own prefix and may not change another family's." W4g adds `/record/wrapped` (W4b's `/record`) and `/settings/about/shared-links` (W4f's `/settings`). W4c's S0-16 quick quiz lives at `/quiz/quick/:examId`, which W4d §3 lists as its own route.
Resolution: state a merge order for `router.dart` (or per-family route files registered once by W1). Record the W4g prefix exceptions with W4b and W4f. Give `/quiz/quick/:examId` one owner (see F-9).

### F-8 · check 2 / level 1 · should-fix
Location: strategy B2 W4 row ("Owns (contracts): Routes per family; nothing shared"); `L2-W4e` §3; `L2-W4f` §3; `L2-W4h` §3; `L2-W4a` §9.
Evidence: W4e owns "Per-exam scoring rule; mock card content model consumed by W4d". W4f owns "Reminder service kinds and schedule; notification tap routing", used by W3, W4a and W4b. W4h owns "The pattern rules below; `StateView` usage guide for families". W4f reuses W4a's exam picker. Each plan still says "nothing shared".
Resolution: amend strategy B2 first ("changes go up first"), or move these contracts to W1, W2 or W3.

### F-9 · check 2 · should-fix
Location: `L2-W4c` §1, §3, §4; `L2-W4d` §3, §8; traceability S0-16, G-d-4, G-h-30.
Evidence: W4c "owns only the entry button and the lesson-scoped question set" and the quick quiz (S0-16). The selection code is `lib/features/quiz/domain/picker/inline_lesson_picker.dart`, and the quick-quiz route and code are in `lib/features/quiz/`. Both are W4d's directory; W4c §8 lists only `lib/features/lesson/` and `lib/core/ui/figures/`. W4c and W4d run in parallel with no order.
Resolution: move the lesson-scoped set and the quick quiz to W4d (W4c keeps the buttons), or add the quiz files to W4c with an order.

### F-10 · check 2 · should-fix
Location: `L2-W4a` §3; `L2-W4g` §4; `L2-W4b` §8; `L2-W4f` §4, §8; `L2-W3` §1 item 5, §8.
Evidence of file overlaps with no stated order:
- W4a retires `/notifications/rationale`; the page is `lib/features/notifications/presentation/permission_rationale_page.dart` (W4f directory).
- W4g removes the Wrapped push (S0-8); the router is `lib/features/notifications/application/wrapped_trigger_notification_router.dart` (W4f directory). W4f and W4g have no order.
- W4b deletes `lib/features/progress/`, which holds `application/table_order_prefs.dart`. W4f's Appearance "Remember table order" needs it. W4b and W4f have no order.
- W3 (before W4f) owns `TrialEndingScheduler.sync`, but W4f owns the `trialEnding` notification kind in `lib/features/notifications/`. Today the branch has only `TrialReminderScheduler` with a no-op implementation.
- W3 §8 "`lib/core/` entitlement providers if moved" is unbounded while W3 runs in parallel with W1, which edits `lib/core/ui/` and `lib/core/time/`.
Resolution: give each file one owner and an order. Bound W3 to `lib/core/entitlement/`.

### F-11 · check 3 · should-fix
Location: consumer plans' §3 "Consumed by reference".
Evidence: these consumed contracts are not defined, by name, in their owner's plan:
- W4e consumes "W3 `coversExam` and the mock limit". W3 defines no mock limit; W4e §4 defines it itself.
- W4e consumes "W4d mock card slot". W4d defines none.
- W4c consumes "W4b day context". W4b defines none.
- W4a consumes "W4f reminder settings storage (same keys as the Reminders screen)". W4f defines no keys, and W4f runs after W4a (W4f §9).
- W4f consumes "W4a exam picker". W4a §3 names no picker contract.
- W4g consumes "W4b Your record row" and "W4f About row". Neither plan defines them.
- W4a §7 "Terms acceptance records the policy version (G-a-18, W0 contract)". W0 has no such contract.
- W4b reads "Remember table order ... (W4f)". W4f names no value.
Resolution: name each interface in its owner's §3, or move it to the consumer.

### F-12 · check 4 · should-fix
Location: `L2-W1` §3 "Motion".
Evidence: MOTION.md: "Map each CSS curve one to one; never swap in a named Flutter curve that looks close", listing `(.2,.8,.25,1)` and `(.2,1,.35,1)` (slides) and `(.3,1.4,.5,1)` and `(.3,1.5,.5,1)` (pops). `PantasCurves` defines one curve per family (`slide` (0.22,1,0.36,1), `pop` (0.34,1.56,0.64,1)). A board using a variant then has no curve contract to use.
Resolution: add the variants to `PantasCurves`, or allow `Cubic` built from the board's values.

### F-13 · check 4 · should-fix
Location: `L2-W1` §7.
Evidence: W1: "If a board's color differs from the README token, the README wins for the token and the difference is reported." README "For Claude Code": "If a board seems to conflict with this README or with `DECISIONS.md`, ask instead of guessing." Every W4 plan's §7 also says "the board wins" for copy.
Resolution: replace with "stop and ask the lead", per README.

### F-14 · check 4 · should-fix
Location: `L2-W2` §3 `PantasSheet`, §7.
Evidence: W2: "used only where a board draws a sheet (questions grid, reader contents, bookmarks, Today row sheets)", and the stop "A board shows a sheet in a place this plan does not list: stop". The list omits two sheets the handoff names: DECISIONS line 42 "Reminders (daily time pill + optional Follow up switch; wheel time sheet)" (O_Notify, O_Notify_v2) and line 69 "Setting the exam date from Home uses the same month-first picker as onboarding (in a sheet)". W2's own `MonthFirstDatePicker` row says "used by onboarding, Home sheet and Settings".
Resolution: add both to the `PantasSheet` list.

### F-15 · check 4 · should-fix
Location: amendment spec B4 ("Placeholders | W4e (mock setup), content formats via W0"); `L2-W0` §4 ("No placeholder figures"), §3; `L2-W4e` §4, §7.
Evidence: the spec routes the placeholder data through W0's content formats. W0 contracts have no placeholder marker, and W0 says "No placeholder figures". On 765c5dc0, `content/mock/` holds only `upcat.yaml`, so no plan says where the CSE per-subject counts and the ACET time live. The restart log (decision 7) says "listed in the plan"; W4e defers the list to level 3.
Resolution: in W0 or W4e, name the data location and the marker. List the placeholder fields at level 2 (CSE subjects, ACET aptitude time).

### F-16 · check 4/5 · should-fix
Location: `L2-W4f` §2 (boards ST_ProNCE, ST_ProNCENoDate, ST_ProLET, ST_ProPMA, ST_ProPMAPass), §4 "Pro pages per tier and pass"; `L2-W3` §1 out of scope.
Evidence: decision log Oct 6: "Licensure, academy exams and PSHS-NCE stay Coming soon and sell nothing." W3: "Licensure, academy and PSHS-NCE sales (Coming soon; nothing sold)". DECISIONS line 225: those exams "can't be picked". W4f still lists their Pro pages as boards to build 1:1, and those pages are unreachable at launch.
Resolution: state whether these pages are built now (unreachable) or deferred. If deferred, mark the rows; if this is a scope question, ask Aedwon.

### F-17 · check 1/2 · should-fix
Location: `traceability.md` G-a-18, G-c-28, G-g-21 (owner W0); `L2-W0` §2, §8.
Evidence: W0 owns "keep recording the policy version", "keep backend bookmark sync for Pro; no UI" and "keep consent-gated analytics events" (wrapped_revealed, wrapped_shared). W0's plan lists these IDs in §2 only and says "No `lib/` or `test/` edits". The code lives in W4a, W4c and W4g directories, which those families rebuild.
Resolution: move each row to the family that rebuilds the code, as a constraint. Or add them to W0's "Recorded-only data" contract so consumers must keep them.

### F-18 · check 5 · should-fix
Location: `traceability.md` G-e-16 (W4e), G-g-15 (W4g); `L2-W4g` §4.
Evidence: G-e-16 lead default: "after Pro lapses, the Free rule applies" to reviews of mocks taken during Pro. G-g-15: "the row shows the Pro tag after a lapse"; W4g §4 "saved Wrappeds kept after a lapse". Both decide what a lapsed paying student can still open. DECISIONS line 231: "nothing a student made is ever paywalled". SUBAGENTS 7b sends anything touching entitlement to tier 1. Neither is covered by stage 0 items 33 to 42.
Resolution: put both to Aedwon as product questions before level 3.

### F-19 · check 5 · should-fix
Location: `traceability.md` G-b-21 (W4b), G-b-8 (W4b); `L2-W4b` §4.
Evidence: G-b-21: "write the missing cause sentences in the History style" (exam switched, date passed, no date, topic order loop). This is new student-facing copy with no board. README rule 1: "Copy is final ... Do not add explanatory text"; plans say "report any board without copy". G-b-8 sets the notice priority "service message, trial ending, welcome to Pro, no date, month only", which decides what students see first. Neither is covered by stage 0 items 33 to 42.
Resolution: list the drafted sentences and the priority order for Aedwon's approval, or at least for his information, before level 3.

### F-20 · check 1/4 · should-fix
Location: `traceability.md` A-B1 ("rule: each level 2 plan cites it for its family"); all W4 plans §2.
Evidence: `grep -n "B1\|superseded" L2-*.md` finds only W0's "Correction to strategy B1". No W4 plan cites the amendment spec B1 table of superseded older-spec sections.
Resolution: add to each W4 §2 the B1 rows for that family.

### F-21 · facts · should-fix
Location: `L2-W0` §1 ("the dev seed (`assets/seed/v1.json`)"), §7 ("W0 stops after the merge and the dev seed").
Evidence: on 1f79d880 no `assets/seed/v1.json` exists. `pubspec.yaml` ships `assets/seed/content.db`, `content.manifest.json` and `content.manifest.sig`. `tools/build_dev_seed/build_dev_seed.dart` says "SUPERSEDED ... never a Flutter/runtime asset" and writes `tools/build_content_export/historical_v1.json`. AGENTS.md warns against restoring retired data paths. Without the signed rebuild, the app keeps reading the old content.db, so the merged questions would not reach the app.
Resolution: correct the path and state what W0 can verify in the app without signing authorization.

### F-22 · check 3 · note
Location: `L2-W1` §3 "Icons".
Evidence: "one named getter per IC_Final row (for example ...)". IC_Final has 46 rows (45 after removing `lock`). W1 names 43; the next-month chevron and the Settings "Pantas Pro" sparkle are unnamed. "For example" is not an exact contract.
Resolution: list every getter and drop "for example".

### F-23 · check 4 · note
Location: `L2-W1` §3 "Type", "Shapes".
Evidence: README gives ranges: "page title 28–30/700", "caption 11–10/500–600", "floating bars and cards 22–24". W1 fixes `pageTitle` 30, `caption` 11/500, `captionStrong` 10/600, `floatingRadius` 22.
Resolution: level 3 confirms each choice against the boards that use it, or adds the second value.

### F-24 · facts · note
Location: `L2-W4d` §3, §8; `L2-W0` §1, §3.
Evidence:
- W4d calls `/quiz/flagged/:examId` "new"; it exists (router line 327, `flagged_list_page.dart`).
- `lib/features/review/` holds only `.gitkeep` files; `/review` renders `QuizResultsPage` from `lib/features/quiz/`.
- W0 "one test fixture": the diff touches `test/fixtures/content/e02_export.json.gz` and `test/fixtures/questions/science/biology/cell-structure.yaml`, plus `test/core/content/content_providers_test.dart`.
- W0 "Drift schema version 25": the app database (`lib/core/storage/data/app_database.dart:77`) is 25; the content database (`lib/core/content/content_database.dart:37`) is 9. Name the database.
Resolution: correct the wording.

### F-25 · facts · note
Verified correct on 1f79d880 / 765c5dc0:
- Merge base 1f79d880; 214 commits; 328 files; 158 question YAML files.
- 158 lesson files; every question path matches a lesson path; `meta.subtopic` equals the file slug in all 158 (69 differ only by YAML quoting).
- `schemaVersion => 25` (app DB).
- `REVOKE_PRO_EVENTS = new Set(['EXPIRATION', 'TRANSFER_OUTGOING'])` (`functions/src/revenuecatPolicy.ts:24`).
- Products `pantas_pro_weekly`, `pantas_pro_monthly`, `pantas_pro_yearly`.
- Every route each plan keeps or retires exists in `lib/app/router.dart`, including the `/more` and `/settings/subscription` redirects and `/study?topicId=`.
- Present as stated: `SourceSans3` in pubspec; no `phosphor_flutter` yet; `onReorder` in `bookmarks_sheet.dart:238`; `app_error_view.dart`, `update_required_page.dart`, `lib/core/ui/figures/`, `lib/core/time/`, `lib/core/notifications/`.
- `content-signing-v1`, `tools/build_content_package`, `tools/verify_content_package` and `formatVersionV2` exist.
- Release-first cuts (E10 once, Redmi smoke, A05 and A06 smoke) match the Oct 1 log.

### F-26 · check 4 · note
Location: strategy B2 "Depends on" column; `L2-W4b`, `W4d`, `W4e`, `W4g` headers.
Evidence: B2 says only "(f) also W3", but four more W4 plans depend on W3. The B6 order (W3 before W2 ends) makes this safe.
Resolution: update B2 for consistency.

### F-27 · check 3 · note
Location: `L2-W3` §3 "Entitlement".
Evidence: "Existing `proIsActive` becomes `coversExam(activeExam)`." `grep -rn proIsActive lib` finds 113 references across features and the router, outside W3's files.
Resolution: say whether the getter keeps its name (no caller edits) or every caller changes, and who edits them.

### F-28 · check 4 · note
Location: `L2-W4d` §4.
Evidence: "never within the paywall cool-off" (S0-19 says "never near a Pro page"). The paywall flow is retired (S0-24).
Resolution: define the cool-off relative to the Settings Pro page.

### F-29 · check 5 · note
Location: `traceability.md` G-b-23 (none).
Evidence: "streak freeze has no board and is dropped". Freeze logic exists (`lib/features/quiz/domain/streak/streak_evaluator.dart`, `freezesRemaining` column), granted only by the dev demo switch. Decision record item 4: missing items go to Aedwon. No owner removes the code.
Resolution: list for Aedwon's information, or mark it dormant and leave it in place.

### F-30 · check 5 · note
Location: `traceability.md` G-g-19; `L2-W4g` §1.
Evidence: "keep the existing web page as built" for pantas.app/wrapped/<id>. WORKFLOW: "Aedwon personally writes and approves website copy." Wrapped sharing will now publish to that page.
Resolution: list it for Aedwon's information.

### F-31 · check 4 · note
Location: `L2-W4e` §4; DECISIONS line 193; branch `mock_attempts_table.dart:28`.
Evidence: UPCAT deductions "may be a decimal: 10.25, 17.5", while `scoreRaw` is an `IntColumn`. W4e stops on a schema change, but this need is foreseeable now.
Resolution: decide at level 2 whether the score is derived from right, wrong and blank counts (no migration) or stored (W0 amendment).

### F-32 · check 2 · note
Location: `L2-W2` §3 `StateView`; `L2-W4h` §1, §3, §8.
Evidence: W2's `StateView` includes "the app-wide 'Something went wrong. / Nothing you've done is lost.'". W4h owns that screen and replaces `lib/core/ui/components/app_error_view.dart` in W2's directory. The order (W4h after W2) is stated; the owner of the screen is not.
Resolution: W2 owns the component; W4h owns the screen and its triggers.

### F-33 · structure · note
Location: all 13 plans.
Evidence: every plan has §1 Purpose and scope (each with "Out of scope"), §2 Inputs, §3 Contracts, §4 Behavior, §5 Motion, §6 Acceptance, §7 Risks and stop conditions, §8 Files and directories, and §9 Order.
- W1 has no "Contracts consumed" line.
- §4 of W1, W2, W4a and W4h states no Free and Pro rule and no placeholder status, which B4 asks for. W4c says only "free for all".
Resolution: add one line each ("Free and Pro: same", "Placeholders: none").

### F-34 · check 1 · note
Location: `traceability.md` D-12, D-14, D-44, D-90; `L2-W3` §2, header.
Evidence:
- D-14 ("Then rows: Your Record, Your Tendencies, How You Work") and D-12 are superseded by D-74 and D-59 but marked "assigned".
- D-44 and D-90 carry W4a and W4b with non-build statuses ("out of program", "record").
- W3 claims "S0-35 states" and the range "G-f-12 to G-f-19", which includes G-f-17. The table owns S0-35 and G-f-17 under W4f. The split (W3 logic, W4f screen) is reasonable but unrecorded.
Resolution: tidy the statuses; record the W3/W4f split on S0-35.

### F-35 · check 5 · note
Location: `L2-W4f` §4 ("copy variants kept"); traceability G-b-22, G-f-28.
Evidence: the daily reminder copy variants (mock day, back after break, first plan) come from pre-design specs. Amendment spec B2 does not mention them, and no board draws them. Low risk, given the "no guilt, no unmeasured figure" rule.
Resolution: list the kept strings for Aedwon's information.

### F-36 · check 2 · note
Location: `L2-W2` §8 ("`lib/features/dev/` or the existing debug page").
Evidence: `lib/features/dev/` does not exist. The existing debug page is `lib/features/settings/presentation/pages/debug_settings_page.dart` (route `/settings/_debug`), which is in W4f's directory.
Resolution: name one location.

---

## Check summaries

- Check 1: passes mechanically (counts above); F-1, F-5, F-17, F-20, F-34.
- Check 2: F-1, F-6, F-7, F-8, F-9, F-10, F-32, F-36.
- Check 3: F-2, F-4, F-11, F-22, F-27.
- Check 4: F-3, F-12, F-13, F-14, F-15, F-16, F-20, F-23, F-26, F-28, F-31.
- Check 5: F-3, F-16, F-18, F-19, F-29, F-30, F-35. The other lead-default rows (61 in all) read as implementation detail or as keeping existing behavior.
- Facts: F-2, F-4, F-21, F-24; verified-correct list in F-25.

Not checked:
- Board motion: `timeline.py` was not run on any board. Motion sections were checked only for structure and board names.
- Boards were read as text for ST_Reminders_v2, O_Notify_v2, IC_Final, L_Rules and ST_Appearance only. Other boards were not compared against plan behavior.
- SCREENS.md was read for structure and the route column only, not row by row.
- The stage 0 gap files were checked only for row counts against G- rows (a 40/40, b 29/29, e 21/21, g 21/21, h 30/30; c, d and f use numbered lists and were not counted).
- Pre-October specs cited in amendment B1, the roadmap engine spec, the giveaways log (beyond the ID format lines), `docs/content-key-access.md`, the offline posture spec and the E04 to E14 plan were not read.
- No builds, tests or analyzers were run; this is a document gate.
- Functions behavior beyond the revoke set was not traced.
- The 61 lead-default rows were judged on their table text only, without reading the gap evidence behind each.
