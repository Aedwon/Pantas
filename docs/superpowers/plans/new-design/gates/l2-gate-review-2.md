# Level 2 gate review 2 (strategy B4)

Reviewer: independent tier-2 reviewer (SUBAGENTS Part 7b); not an author of the reviewed documents. Date: October 6, 2026.
Policy revision read: origin/main fcd680a0 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Main checkout clean, equal to origin/main.
Code branch checked: `integration/new-design-r1` at 1f79d880 (worktree `Pantas-wt-integration-new-design-r1`, equal to origin); `origin/content/question-qa-r2` at 765c5dc0.
Inputs read in full: review 1, restart log (all Oct 6 entries), strategy, amendment spec, tier pricing spec, `docs/pricing.md`, the 13 L2 plans, STATUS.md, stage0-decisions.md, `docs/design/README.md`, `DECISIONS.md` (Onboarding, Settings, Free and Pro, Redesign, Last gaps, Quiz lines 183 to 197, Home notices), `MOTION.md`. Traceability scanned by script.
Nothing was edited, committed or pushed in the repository.

Totals: part A: 30 resolved, 5 partly resolved, 0 not resolved, F-25 needs no action. Part B: 1 blocker, 14 should-fix, 11 notes.

---

## Part A. Review 1 findings

| ID | State | Evidence |
|---|---|---|
| F-1 | resolved | Rows B-AS_Question/Picked/Leave/Results now `W4a` (traceability 294-297); W4a §2 lists them; W4d §2 does not. Script: W4a 59 rows (17+42), W4d 94 (46+48), both match the table. |
| F-2 | resolved | W0 §3 "Exam catalog ... `priceTier`, `group` ..., `comingSoon`, and `publishedSittings` (each with first and last day and the published source) ... An exam with no published sitting has none; nothing is inferred." Dates: log Oct 6 item 1 "Aedwon supplies each with its source link". New storage defect: N-5. |
| F-3 | resolved, see N-1 | Tier spec written; status "Part A approved by Aedwon on October 6"; W3 §7 "Store price points at launch (₱49, ₱149, ₱1,199, ₱499) must be confirmed ... if one is not, stop and ask." Part A was changed after the approval (N-1). |
| F-4 | resolved, see N-6, N-7 | W0 §1 "app database schema 25 to 26 ... `MistakeTag.other` plus a nullable `mistakeNote` ... nullable `blankReason` on mock answers ... the sync payload carries them. W4d and W4e write them." W4d §3 and W4e §3 consume schema 26 by name. |
| F-5 | resolved | W2 l.61, W4e l.37/45/57, W5 l.29 cite R-20; W3 l.68 R-12; W4b §2 R-13, R-16; W4g R-14; table G-b-5 "R-16", G-e-16 "R-12", G-g-18 "R-13". All match table rows 578-586. (G-g-18's meaning is a separate problem: N-3.) |
| F-6 | resolved | W1 §3 Routes: "removes the retired routes in section 1. Each W4 family ... deletes the screens behind its retired routes." Every W4 §3 repeats it. (Which routes W1 removes is inconsistent: N-11.) |
| F-7 | partly resolved | Fixed: W1 §3 per-family route files, W4g prefix exceptions, `/quiz/quick/:examId` owned by W4d. Left: W4a §8 "its routes in `lib/app/router.dart`"; W4b §9 "a stated order on `router.dart`"; W4d §9 "no shared files with W4e beyond `router.dart`"; W1 §8 omits `lib/app/routes/` (N-10). |
| F-8 | resolved | Strategy B2 W4 row: "Amended Oct 6 (level 2 gate): a family may own a family-specific contract ... (a) exam picker screen; (b) day context, table order setting, Your record slot; (d) ...; (e) mock card; (f) ...; (g) ...; (h) app-wide state patterns". Minor omission: N-24. |
| F-9 | resolved | W4c §1 "this family owns only the 'Quiz yourself' and 'Try a Quick Quiz' buttons, which call W4d's `startLessonQuiz(lessonId)` and `startQuickQuiz()`"; W4d §3 owns both; S0-16, G-d-4, G-h-30 are W4d. Landing order missing: N-9. |
| F-10 | partly resolved | Fixed: rationale page and Wrapped push router deleted by W4f (W4f §4 l.70-71); W3 bounded to `lib/core/entitlement/` "(currently empty; only if providers move)"; trial-ending split stated. Left: W4f writes W4b's `tableOrderRememberedProvider` with no order between W4b and W4f (N-9); trial-ending interface has two owners (N-8). |
| F-11 | resolved | Each named contract now exists in its owner: W3 `mockLimit(examId)`; W4e `MockCardModel`/`MockCard`; W4b `LessonDayContext`; W4f `ReminderPrefs` with the same five fields W4a consumes; W4a `ExamPickerScreen`; W4g `WrappedRecordRow`/`SharedLinksRow`; W0 recorded-only includes the Terms policy version; W4b `tableOrderRememberedProvider`. |
| F-12 | resolved | W1 §3 Motion lists 13 named cubics matching every MOTION.md curve, plus "A board curve not in this list is built as `Cubic` from the board's exact values and added here." (`steps(n)` missing: N-25.) |
| F-13 | resolved | W1 §7 "stop and ask the lead (README 'ask instead of guessing')"; every W4 §7 has the same line. |
| F-14 | resolved | W2 §3 `PantasSheet`: "... the onboarding reminder time wheel (O_Notify, D-42), and the Home exam date picker (D-69)". |
| F-15 | resolved, see N-12 | W0 §3 Mock blueprints: "`content/mock/<exam>.yaml`. A value with no published source carries `placeholder: true` and a `placeholderNote` ... Known placeholders: CSE ... per-subject item counts; ACET aptitude time (R-20)." W4e §3 repeats. |
| F-16 | resolved, see N-2 | Rows ST_ProNCE, ST_ProNCENoDate, ST_ProLET, ST_ProPMA, ST_ProPMAPass: `none`, "deferred until that exam launches (Aedwon, Oct 6, gate F-16)"; W4f §4 l.66-67. |
| F-17 | partly resolved | Rows moved: G-a-18 W4a, G-c-28 W4c, G-g-21 W4g; W0 §3 recorded-only lists them as constraints. Left: W0 §2 still lists "G-a-18, ... G-c-28, G-g-21" as its inputs; the policy-version write is in `lib/features/settings/data/settings_repository.dart` (W4f directory), not W4a's (N-12). |
| F-18 | resolved, see N-2 | W4e §4 "After Pro lapses: the Free rule applies, nothing is deleted, renewing restores access (Aedwon, Oct 6, gate F-18)"; W4g §4 same. Row G-e-16 still says "pending Aedwon" (N-17). |
| F-19 | resolved, see N-2 | W4b §4 notice order and four History sentences "(Aedwon, Oct 6, gate F-19)"; W4f §4 l.73 Follow up copy. |
| F-20 | resolved | Every W4 §2: "Superseded sections of older specs for this family: amendment spec B1 (rows naming this family's screens); those sections are not built." Generic pointer, adequate for row A-B1. |
| F-21 | partly resolved | §1 fixed: "There is no separate dev seed: `tools/build_dev_seed` is superseded and must not be restored." §7 l.97-98 still: "Without it, W0 stops after the merge and the dev seed". |
| F-22 | resolved | W1 §3 Icons: "exactly these 45 getters"; counted 45, including `nextMonth` and `proSettings`. |
| F-23 | resolved | W1 §4 last bullet: level 3 checks each README range against the boards. |
| F-24 | resolved | W4d §3 "`/quiz/flagged/:examId` (exists; new list design)"; "`/review`, both served by `QuizResultsPage` ...; the empty `lib/features/review/` folder is deleted"; W0 names both fixtures and both databases (app 25, content 9). |
| F-25 | no action | Re-verified: merge base 1f79d880, 214 commits, 328 files, 158 question YAML; non-content, non-doc files are exactly `tools/import_questions/converter.dart` and 7 test or fixture files; app schema 25, content schema 9. |
| F-26 | resolved | Strategy B2 W4 "Depends on": "W1, W2; (b), (d), (e), (f), (g) also W3". |
| F-27 | resolved, see N-23 | W3 §3 "The existing `proIsActive` getter keeps its name and returns `coversExam(activeExam)`, so its 113 callers need no edit." 113 references confirmed. |
| F-28 | resolved, see N-22 | W4d §4 "never within 24 hours after the Settings Pro page was opened". |
| F-29 | partly resolved | Log Oct 6 item 6 "streak freeze code stays dormant". Row G-b-23 (l.728) still says "streak freeze has no board and is dropped" (N-17). |
| F-30 | resolved | W4g §4 "The public pantas.app page is website copy, which Aedwon writes; it is kept as built and listed for his review (gate F-30)." |
| F-31 | resolved, see N-6 | W4e §3 "Scores are derived from stored right, wrong and blank counts per part ... `scoreRaw` stays an integer count, no migration." |
| F-32 | resolved | W2 §3 `StateView` and W4h §4: "W2 owns `StateView`; this family owns the app-wide screen, its triggers and the retirement of `app_error_view.dart`." |
| F-33 | resolved | W1 "Contracts consumed: W0 baseline only."; W1, W2, W4a, W4c, W4h §4 each state Free and Pro and placeholders. |
| F-34 | resolved | D-12, D-14 "superseded by ..."; D-44, D-90 now `none`; S0-35 status "W3 owns the entitlement states (logic), W4f the screens and copy"; W3 §3 "State split". |
| F-35 | resolved | Log Oct 6 item 6 "existing daily reminder messages stay"; W4f §4 "copy variants kept". |
| F-36 | resolved, see N-10 | W2 §8 "`lib/core/ui/gallery/` (debug-only gallery screen, route `/settings/_gallery` in the `dev` route file; W4f adds a link to it from the existing debug page)". |

---

## Part B. Five checks on the current set

### Check 1: traceability (script evidence)

Script: `scratchpad/trace2.py` parses every 7-column row of `traceability.md` and cross-checks the 13 plans.

- 832 rows (831 plus B-ST_ProCSE_v2), 0 malformed, 0 duplicate IDs.
- Counts: W4b 152, W4f 149, W4e 98, W4d 94, W4c 84, none 74, W4a 59, W4g 38, W1 27, W2 18, W3 14, W4h 13, W0 9, W5 3.
- Every non-`none` row cites `L2-<its own plan>.md §n` and that `## n.` exists; every `none` row has no section; level 3 column empty. 0 violations.
- W4a to W4h: §2 board list and "Other traceability rows" list equal the table's rows for that workstream exactly (0 missing, 0 extra, 0 duplicates); header counts match the lists and the table for all eight.
- 289 board files in `docs/design/boards/` equal the 289 B- rows.
- Plan references with no row: D-18 (W4e), D-89 and D-102 (W4b), D-160 (W4d). All are heading lines inside cited ranges; harmless.

Mechanically passes. Ownership problems the script cannot see: N-3, N-13, N-17.

### Findings

#### N-1 · check 5 · blocker
Location: `specs/2026-10-06-tier-pricing-design.md` Part A items 1 and 3 and status line; `docs/design/boards/ST_ProCSE_v2.html`; `docs/design/proposals/cse-pro-2026-10-06.html`; traceability l.239; `L2-W4f` §2, §4 l.68-69; `L2-W3` §3 Products.
Evidence: Aedwon's recorded words are "1. a / 2. ok / 3. ok" (approving Part A as it then stood: Civil Service Monthly and pass only) and, after asking for figures, "weekly 49 yearly 1199". Commit ab554e23 then edited Part A to add two permanent product IDs (`pantas_cs_weekly`, `pantas_cs_yearly`) and a new page layout ("The CSE Pro page uses the academy-exam layout ... (ST_ProCSE_v2)"), created the board and the preview in the same commit, and marked them approved ("proposal 6 Oct, approved", traceability l.239; W3 "tier spec, approved Oct 6"). No recorded words approve the layout or the two IDs. The preview cannot have shown the layout: both phone frames are empty (`<div class="phone"></div>`, no iframe or script). The board says "(proposal 6 Oct)" in its own title and is absent from `SCREENS.md` and `index.html`. pricing.md calls product IDs "permanent", and WORKFLOW requires the visual companion before approval of UI.
Resolution: show Aedwon a working preview; record his exact approval of the CSE layout and of `pantas_cs_weekly` and `pantas_cs_yearly`. Until then mark B-ST_ProCSE_v2 and the two IDs "proposed", and keep W3 level 3 product creation blocked on them.

#### N-2 · check 5 · should-fix
Location: restart log, Oct 6 "answers to gate review 1" ("Resulting decisions (items not answered take the stated recommendation, per the reply convention)"), items 3 to 6; consumers W4b §4, W4e §4, W4f §4 l.66-67 and l.73, W4g §4.
Evidence: F-16, F-18 (entitlement after a lapse) and F-19 (notice order, four History sentences, Follow up copy) were not answered in Aedwon's words; they took recommendations. The convention is recorded only for stage 0 (`stage0-decisions.md` l.10). The earlier log entry lists the topics but not the options, recommendations or proposed strings ("Open for Aedwon: ... F-18 (what a student keeps after Pro lapses), F-19 (notice order, History sentences and Follow up copy)"). A search of `docs/` finds "Still time today" only in W4f. So the plans attribute exact copy and an entitlement rule to Aedwon that no record shows he saw. WORKFLOW: record "the offered options, costs, context".
Resolution: add to the log the exact message sent to Aedwon (options, recommendations, proposed strings, and the reply convention it stated), or get his explicit confirmation.

#### N-3 · check 5 · should-fix
Location: traceability G-g-18 (l.847): "settled: R-13 accepted the loss; no wording"; `L2-W4g` §4 History.
Evidence: R-13 is Aedwon's answer about the Your plan History. He scoped it: "What Pro history is this? in the roadmap screen? if that's what you're talking about it should ship". G-g-18 is Wrapped's Pro history (gap-g-wrapped). On the branch, Wrapped artifacts are only in the local table `userMetricsArtifactsLocal` (`lib/core/sync/local_state_wiper.dart:72`); the sync registry has no Wrapped collection, so Pro Wrapped history is lost on reinstall. That loss of a Pro feature's content was not decided by Aedwon.
Resolution: list it for Aedwon as a missing item (keep local and lose on reinstall, or sync), per restart decision 4.

#### N-4 · check 4 (level 1) · should-fix
Location: strategy B2 W0 row (l.92); amendment spec B4 "Recorded-only data | W0 confirms storage".
Evidence: B2 still says W0 owns "Content and question file formats as built; data layer as merged". W0 now changes application code: app schema 26 and migration, sync payload, the exam catalog fields, and the mock blueprint marker (W0 §1, §3, §8). The strategy rule is "Changes go up first". The decision log records the W0 change, but the level 1 definition was not amended (only W4's row was).
Resolution: amend B2's W0 row (scope and owned contracts) and log it.

#### N-5 · check 3 / facts · should-fix
Location: `L2-W0` §3 Data layer and Exam catalog, §8.
Evidence: Exam catalog: "W0 adds the fields to the exam metadata format and content database export". Data layer, same table: "content database (`lib/core/content/content_database.dart`) schema 9, unchanged". On the branch, `ContentExams` (`lib/core/content/tables/content_exams.dart`) has no tier, group, coming soon or sittings column, and exam metadata is hard-coded in `tools/build_content_export/build_content_export.dart` (l.16-60). The app can only read the new fields through a changed content table (content schema 10 and migration) or an existing JSON column, and `lib/core/content/` is not in W0 §8. The nine Coming soon exams also have no rows yet.
Resolution: in W0, name the storage (new content schema version and migration, or a JSON field), add `lib/core/content/` to §8, and say who adds the Coming soon exam rows.

#### N-6 · check 3 / facts · should-fix
Location: `L2-W4e` §3 ("Scores are derived from stored right, wrong and blank counts per part"), consumed "W0 data (right, wrong, blank per part; schema 26 `blankReason`)"; `L2-W0` §1, §3.
Evidence: W0's data-layer contract names no per-part right, wrong or blank counts. On the branch, `SectionResult` stores `correct`, `total`, `retiredCount`, `timeSeconds` only (`lib/features/mock_exam/domain/mock_results.dart:54-72`); answers live in `answersJson` (`mock_attempts_table.dart:25`). W0's "nullable `blankReason` on mock answers" does not say whether it is a column or a field inside `answersJson` (which would need no schema version), and the "other plus text" note for blanks has no field name. W4e consumes a contract its owner does not define.
Resolution: W0 names where per-part wrong and blank counts and the blank reason and its text are stored, with the exact names W4e consumes.

#### N-7 · check 3 · should-fix
Location: `L2-W3` §3 l.62-63.
Evidence: "Contracts consumed: W0 data layer (schema 25, no migration expected; a new local table needs a W0 amendment first)." W0 §3: "App database ... schema 26 after W0", and W3 runs after W0. W3 also uses the W0 exam catalog (`tierForExam(examId)` "from the W0 exam catalog"; Season Pass end "from the W0 exam catalog's `publishedSittings`") but does not list it as consumed.
Resolution: consume "schema 26" and the exam catalog by name.

#### N-8 · check 2/3 · should-fix
Location: `L2-W3` §3 Trial-ending trigger; `L2-W4f` §3; `L2-W3` §8.
Evidence: W3: "hands it to W4f's reminder service (`ReminderService.scheduleTrialEnding(at)` / `cancelTrialEnding()`) ... W3 lands first with an interface; W4f implements the service side." W4f §3 owns "`ReminderService` (kinds, schedule, tap routing, and the trial-ending side of W3's `TrialEndingScheduler`)" and names neither method. W3 §8 has no notifications directory, so where W3's interface lives is undefined. The interface has two owners.
Resolution: one plan defines the interface name, methods and file; the other references it with identical names.

#### N-9 · check 2 · should-fix
Location: §9 of W4b, W4c, W4d, W4e, W4f, W4g, W4h.
Evidence: family contracts are consumed across parallel families with no landing order, except W4a and W4f (which state one):
- W4c consumes W4b `LessonDayContext` and W4d `startLessonQuiz`, `startQuickQuiz`; W4c §9 "Parallel with other families".
- W4d consumes W4e `MockCard`; W4d §9 and W4e §9 state no order.
- W4f consumes W4b `tableOrderRememberedProvider` (moved out of `lib/features/progress/`) and W4g `SharedLinksRow`; W4f §9 names only W4a's picker.
- W4g consumes W4f's About slot while W4f consumes W4g's row; W4g §9 "After W2, W3 and W4b's Your record." The pair has no order.
- W4h owns the patterns all families apply; W4h §9 "Early among W4 families" is not an order, and only W4a and W4c name W4h as consumed.
Resolution: state a task-level landing order for each consumed family contract in both plans, as W4a and W4f do.

#### N-10 · check 2 · should-fix
Location: `L2-W1` §3 Routes, §8; `L2-W4a` §8; `L2-W4b` §9; `L2-W4d` §9; `L2-W2` §8.
Evidence: W1 creates `lib/app/routes/<family>_routes.dart`, but W1 §8 lists only "`lib/app/router.dart` (shell, roots, redirects, retirements only)". W4a §8 "its routes in `lib/app/router.dart`"; W4b §9 "a stated order on `router.dart`"; W4d §9 "no shared files with W4e beyond `router.dart`" all contradict W1 ("W1 owns `router.dart` ... Each W4 family edits only its own route file"). W2 adds `/settings/_gallery` to "the `dev` route file", which is not in W2 §8, and no plan owns the `dev` file or says whether `/settings/_debug` (router.dart:523) goes in `settings` or `dev`.
Resolution: add `lib/app/routes/` to W1 §8; fix the three W4 lines; name the `dev` route file's owner and add it to W2 §8.

#### N-11 · check 2 · should-fix
Location: `L2-W1` §1 l.22-24; `L2-W4a` §4 l.66; `L2-W4b` §3; `L2-W4d` §3; `L2-W4f` §3.
Evidence: W1 removes "the Progress tab branch, `/progress` as a tab, `/plan/dossier/:mockId`, `/mock-exam`, `/quiz/results/:attemptId`". W4a says "`/notifications/rationale`: W1 removes the route", but W1's list does not include it. `/review` (W4d), `/paywall` (W4f), `/progress/how-you-work` and `/progress/your-record` (W4b) are retired by families whose §3 says "W1 removes retired routes", and W1 does not list them.
Resolution: one complete list of retired routes, with one remover for each.

#### N-12 · check 2 · should-fix
Location: `L2-W0` §3 Recorded-only data; `L2-W4a` §8; `L2-W2` §1, §8; `L2-W4e` §3, §8; strategy B2 "Content track".
Evidence: files are touched outside their workstream's file list, with no stated order:
- W0 assigns "Terms acceptance records the policy version (`settings_repository.dart`, W4a)". The file is `lib/features/settings/data/settings_repository.dart`, a W4f directory; W4a §8 is `lib/features/onboarding/`, `lib/features/assessment/`.
- W2 owns R-21 (the `onReorder` fix) in `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart` (W4c directory), and its scope includes "retiring ... the six `showInkSheet` callers plus the subject scope, custom mock wheel and other sheet call sites", which are in feature directories. W2 §8 lists only `lib/core/ui/components/`, `lib/core/ui/gallery/`, tests. W2 runs before W4, so order exists, but the files are not W2's to stage (SUBAGENTS Part 2).
- W4e owns "The CSE Professional, CSE Subprofessional and ACET blueprints in `content/mock/`"; W4e §8 is `lib/features/mock_exam/`, routes, tests. Strategy B2: "no workstream changes [content formats] without telling that track".
Resolution: move the policy-version constraint to W4f or give W4a the file with an order; add the W2 and W4e files to their §8 (and note the content track).

#### N-13 · check 1/2 · should-fix
Location: traceability A-B2b (l.597) owner W4b §4; `L2-W4f` §3.
Evidence: A-B2b "Notification tap routing (Home; trial ending opens Settings › Pantas Pro)" is assigned to W4b, but W4b's plan never mentions notification tap routing. W4f §3 owns `ReminderService` "(kinds, schedule, tap routing ...)". Two claimants, and the assigned one is silent.
Resolution: give the row one owner and carry it in that plan's §4.

#### N-14 · check 4 · should-fix
Location: `L2-W5` §1, §2; tier spec "Cost and risk" l.65.
Evidence: tier spec: "The main risk is Play's upgrade handling between tiers; W5's test purchases on the test track check every case before beta." W5 §1: "A03 purchase and restore (Student and Civil Service, test track)". W5 does not list the upgrade, a pass purchase and its end date, pass rejection without a published sitting, or trial eligibility after a lapse, and does not cite the tier spec (W5 policy revision b52757bf, written before it).
Resolution: list the tier cases in W5 §1 and cite the tier spec in §2.

#### N-15 · check 4 · should-fix
Location: `L2-W4f` §2, §4 l.68-69, §6; traceability l.237-238, 279.
Evidence: ST_ProCSEPass (the picked-pass state: "Buy Season Pass", "₱499 once. Ends after your exam on <date>.") is "superseded by ST_ProCSE_v2", and ST_ProPMAPass (the academy picked-pass state) is deferred. ST_ProCSE_v2's text has no "Buy Season Pass" state. The CSE picked-pass state now has no buildable board. W4f §2 also still lists ST_ProCSE and ST_ProCSEPass under §6 "Every board listed below matches 1:1".
Resolution: name the board for the CSE picked-pass state (with N-1's approval), and exclude superseded boards from the 1:1 list.

#### N-16 · check 4 · note
Location: `ST_ProCSE_v2` "SAVE 33%"; approved `ST_ProFree` "SAVE 32%".
Evidence: Student: 1 − 799/1,188 = 32.7%, shown 32% (rounded down). CSE: 1 − 1,199/1,788 = 32.9%, shown 33% (rounded to nearest). One formula cannot match both boards. The per-month figures (₱67, ₱100) both round to nearest.
Resolution: fix one rounding rule for the savings figure in W4f (rounding down keeps the approved Student board; CSE then shows 32%).

#### N-17 · check 1 · note
Stale statuses and headers: G-e-16 (l.793) "lead default pending Aedwon (gate F-18)"; G-b-8 (l.713) and G-b-21 (l.726) still "lead default" after the F-19 decision; G-b-23 (l.728) "streak freeze ... is dropped" against log item 6 "stays dormant"; W0 §2 still lists G-a-18, G-c-28, G-g-21; W3 header "level 3 of W3 waits for Aedwon's approval of it" after approval.

#### N-18 · facts · note
`docs/pricing.md` "Not yet settled" still says tiers "need a design spec" (it now exists); its price-point list omits ₱49 and ₱1,199; "Switching exams (direction, not yet a design spec)". W3 §7 carries the full price-point list, so nothing is blocked.

#### N-19 · facts · note
Tier spec B3 l.89: "Subscriptions in one Play subscription group so replacement works". Subscription groups are an App Store concept. Google Play replaces any subscription in the same app. Part A says Play "credits the unused part" while B3 picks "charge prorated price", which keeps the old billing cycle. Not verified against current Play documentation (no web access used). Level 3 should confirm the replacement mode for Student Yearly to CS Weekly and similar pairs.

#### N-20 · check 3 · note
Tier spec B2: the pass end date is "Computed server-side from the catalog version shipped in the app's content package". The catalog is a signed client asset; no plan says how functions read it (W3 §8 lists only `functions/src/revenuecat*.ts`, `publicId*.ts`).

#### N-21 · facts · note
W0's new marker `placeholder: true` and `placeholderNote` sits beside the existing blueprint fields `source` and `sourceNote` (`content/mock/upcat.yaml` "source: reported"; `content_mock_blueprints.dart:29-32`). Two ways to mark an unpublished value; decide one.

#### N-22 · check 5 · note
W4d §4 "never within 24 hours after the Settings Pro page was opened" is a lead-chosen number inside S0-19 ("never near a Pro page"). List it for Aedwon's information.

#### N-23 · facts · note
`proIsActive` exists twice: `lib/features/paywall/domain/entitlement.dart:48` and `lib/features/paywall/data/revenuecat_sdk.dart:48`. `Entitlement` is a value object with no active exam, so "returns `coversExam(activeExam)`" needs the active exam injected. Level 3 must say how.

#### N-24 · check 2 · note
Strategy B2's family-contract list omits W4e's "Per-exam scoring rule" and its blueprint authoring (W4e §3).

#### N-25 · check 4 · note
MOTION.md lists `steps(n)` (typing) as a curve; W1 `PantasCurves` and `PantasEffects` have no stepped primitive. G-h-28 (icons with no IC_Final entry) is owned by W2 while W1 fixes exactly 45 icon getters; the mapping must stay inside W1's list or amend W1.

#### N-26 · check 4 · note
Amendment spec B2 fixes the trial-ending text to HP_Trial's "Google Play charges ₱99 ...". A Civil Service trial charges ₱149. W3 §4 "Prices come from the store, never typed in code" covers the build, but the spec text reads as fixed copy.

---

## Check summaries

- Check 1: passes mechanically (above). N-3, N-13, N-17.
- Check 2: N-8, N-9, N-10, N-11, N-12, N-13, N-24; F-7, F-10 partly open.
- Check 3: N-5, N-6, N-7, N-8, N-20.
- Check 4: N-4, N-14, N-15, N-16, N-25, N-26.
- Check 5: N-1, N-2, N-3, N-22.
- Facts: N-5, N-6, N-18, N-19, N-21, N-23; F-25 re-verified.

Not checked:
- Board motion: `timeline.py` was not run on any board.
- Boards were read as text only for ST_ProCSE_v2, ST_ProFree and ST_ProPMA (price strings). Other boards were not compared against plan behavior.
- SCREENS.md was not read row by row; DECISIONS.md was read for the sections named above only.
- Stage 0 gap files: only gap-g row 18 was opened.
- Pre-October specs, the roadmap engine spec, the giveaways log, `docs/content-key-access.md`, the offline posture spec and the E04 to E14 plan were not read.
- Google Play Billing replacement modes and subscription grouping were not checked against current documentation (N-19).
- Whether the lead showed Aedwon anything outside the repository (chat images) was not checkable; N-1 and N-2 rest on the repository record only.
- No builds, tests or analyzers were run; this is a document gate.

Gate verdict: not passed
