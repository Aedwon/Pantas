# Level 2 gate review 3 (strategy B4, delta)

Reviewer: independent tier-2 reviewer (SUBAGENTS Part 7b); not an author of the reviewed documents. Date: October 6, 2026.
Policy revision read: origin/main 6d0bb731 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Main checkout clean, HEAD equal to origin/main.
Code branch checked: `integration/new-design-r1` at 1f79d880 (worktree equal to origin).
Scope: delta only. Inputs: review 2; restart log Oct 6 entries (lines 501 to 551); `git diff fcd680a0 6d0bb731 -- docs` (24 files); full reads of the W2 plan sections 2 to 9, W3 section 8, `docs/pricing.md` lines 1 to 85, both v2 boards (as text) and the CSE preview page.
Nothing was edited, committed or pushed in the repository.

Totals: part A: 31 resolved, 0 partly resolved, 0 not resolved (the 5 partly resolved review 1 items and N-1 to N-26). Part B: 0 blockers, 4 should-fix, 6 notes.

---

## Part A. Review 2 items

| ID | State | Evidence |
|---|---|---|
| F-7 | resolved | W4a §8 "`lib/app/routes/onboarding_routes.dart`"; W4b §9 "all editing only `lib/app/routes/home_routes.dart` in a stated order"; W4d §9 "no shared files with W4e (each edits only its own route file)"; W1 §8 "`lib/app/routes/` (creates the per-family route files, then each family owns its file)". |
| F-10 | resolved | W4b §9 "the `tableOrderRememberedProvider` move before W4f's Appearance task and before `lib/features/progress/` is deleted"; W4f §9 repeats it. Trial-ending interface has one owner (N-8). |
| F-17 | resolved | W0 §2 now "G-b-11, G-b-12, G-b-13, G-h-27 and amendment B3"; W0 §3 "Terms acceptance records the policy version (`lib/features/settings/data/settings_repository.dart`; W4f keeps the write, W4a calls it)"; W4f §3 "Keeps the Terms policy-version write"; W4a §4 consumes it. |
| F-21 | resolved | W0 §7 "Without it, W0 stops after the merge and the data changes". No "dev seed" text remains in any plan. |
| F-29 | resolved | Traceability G-b-23 "streak freeze code stays dormant (Aedwon, Oct 6, for information)". |
| N-1 | resolved, see N3-6 | Log Oct 6: "Then asked: (1) approve the CSE layout and the names `pantas_cs_weekly`, `pantas_cs_yearly`" and Aedwon's answer "1. yes". The preview was fixed first ("the preview now shows the approved page, the proposal, and the proposal's pass-picked state"). Preview verified: three phone frames, each holding inline board markup (0 empty frames). |
| N-2 | resolved | Log records the message sent after review 1 (reply convention, options, recommendations, all proposed History and Follow up strings) and asks "(2) confirm the items above that took recommendations"; answer "2. yes". See N3-10 for one row that claims more than the message held. |
| N-3 | resolved | Asked "(3) Wrapped history on reinstall: keep on the phone for beta (recommended) or sync"; answer "3. keep on phone". G-g-18 and W4g §4 "Wrapped history stays on the phone and is lost on reinstall until sync exists (Aedwon, Oct 6)". |
| N-4 | resolved | Strategy B2 W0 row: "Amended Oct 6 (level 2 gates): also the data the design adds ..., the exam catalog (content database schema 10, Coming soon exam rows, functions copy) and the mock blueprint placeholder marker"; owned column "Content and question file formats; data layer; exam catalog; blueprint format". Logged in the Oct 6 entry. |
| N-5 | resolved, see N3-7 | W0 §1 "content database schema 9 to 10 with its migration ... W0 adds the exam rows for the Coming soon exams"; W0 §8 adds `lib/core/content/`. |
| N-6 | resolved, see N3-1, N3-2 | W0 §3 Data layer names `AttemptItem.mistakeNote`, `missReason`, `blankReason`, `reasonNote`, `SectionResult.wrong`, `SectionResult.blank`; W4d §3 and W4e §3 consume the same names. Code confirms `answersJson` and `sectionResultsJson` are text columns (`mock_attempts_table.dart:25,30`) and the sync mappers copy them as raw strings (`mock_attempt_mapper.dart:33,38`). |
| N-7 | resolved | W3 §3 "Contracts consumed: W0 data layer (app schema 25, content schema 10) and the W0 exam catalog, including `functions/src/examCatalog.json`". |
| N-8 | resolved | W3 §3 "W3 owns the interface `TrialEndingNotifier` in `lib/features/paywall/application/trial_ending_notifier.dart` with `schedule(DateTime chargeAt, String priceText)` and `cancel()`"; W4f §3 "the implementation of W3's `TrialEndingNotifier`" and consumes it by that name. W3 §8 covers `lib/features/paywall/` application. |
| N-9 | resolved | Every consumed family contract now has an order stated in both plans: W4b→W4c `LessonDayContext`; W4d→W4c starts; W4e→W4d `MockCard`; W4b→W4f table order; W4f→W4a reminders; W4b→W4g Your record slot; W4f→W4g About slot; W4h pattern task stated in W4a to W4g §9 and W4h §9 "lands before any other family's state screens". |
| N-10 | resolved | W1 §8 adds `lib/app/routes/`; W1 §3 "creates the `dev` route file, which holds `/settings/_gallery` ...; `/settings/_debug` stays in the `settings` file"; W2 §8 "`lib/app/routes/dev_routes.dart`". |
| N-11 | resolved | W1 §1 "W1 removes every retired route: `/progress` branch with `/progress/how-you-work` and `/progress/your-record`, `/plan/dossier/:mockId`, `/mock-exam`, `/quiz/results/:attemptId`, `/review`, `/paywall`, `/notifications/rationale`". Checked against every path in `lib/app/router.dart` and every W4 "Retired" line: complete, no extras. |
| N-12 | resolved, see N3-2, N3-3, N3-4 | Policy version moved to W4f (F-17); W2 §1 "W2 does not edit feature files"; W4e §8 adds "`content/mock/` (CSE Professional, CSE Subprofessional, ACET blueprints only)" and §9 "the content track is told before they land". |
| N-13 | resolved, see N3-5 | Traceability A-B2b owner W4f; W4f §3 "notification tap routing per amendment B2 including A-B2b"; W4b §2 no longer lists it (script: W4b 151 rows, matches). |
| N-14 | resolved | W5 §1 "covering the tier spec cases: each Student and Civil Service plan, the Monthly trial and its absence after a lapse, a Student to Civil Service upgrade, a pass purchase and its end date, refusal of a pass with no published sitting, and restore"; W5 §2 cites the tier spec. |
| N-15 | resolved | New board `ST_ProCSEPass_v2` ("Buy Season Pass ₱499 once. Ends after the exam on Mar 1, 2027."), row B-ST_ProCSEPass_v2 W4f; ST_ProCSE and ST_ProCSEPass now `none` "superseded"; W4f §2 lists only the v2 boards. |
| N-16 | resolved | W4f §4 "Savings figures round down ("SAVE 32%" on both Student and CSE)"; both v2 boards now read "SAVE 32%" (1 − 1,199/1,788 = 32.9%, rounded down). |
| N-17 | resolved | G-e-16 "decided: Free rule applies after a lapse ..."; G-b-8, G-b-21 "decided ... (Aedwon, Oct 6)"; G-b-23 fixed (F-29); W0 §2 fixed (F-17); W3 header "approved by Aedwon Oct 6". |
| N-18 | resolved | pricing.md "**Switching exams** (designed in the tier spec and the approved switching boards)"; price points list "₱49, ₱149, ₱1,199, ..."; "Tiers needed a design spec (now ..., approved 6 October 2026)". |
| N-19 | resolved | Tier spec B3 "Google Play can replace any subscription in the app; level 3 confirms the replacement mode for each pair against current Play Billing documentation before W3 implements it (gate N-19)"; upgrade wording now "a replacement mode that credits the unused part ... (Part A item 5)". |
| N-20 | resolved, see N3-8 | Tier spec B2 "Computed server-side from `functions/src/examCatalog.json`, written by the W0 content export"; W0 §1 and §8 own the file. |
| N-21 | resolved | W0 §3 "The blueprint-level `source` and `sourceNote` stay the citation for the whole blueprint. A single value with no published source carries `placeholder: true` ... (N-21: field-level ...)". |
| N-22 | resolved | Log: "For information: the store rating prompt never appears within 24 hours of opening the Pro page." |
| N-23 | resolved | W3 §3 "two definitions: `entitlement.dart:48`, `revenuecat_sdk.dart:48` ... W3 makes the provider-level value equal `coversExam(activeExam)` by injecting the active exam ..., and level 3 lists each definition's change". |
| N-24 | resolved | Strategy W4 row "(e) mock card, per-exam scoring rule, CSE and ACET blueprints". |
| N-25 | resolved, see N3-4 | W1 §3 Motion "and `steps(n)` for typing (N-25)". The G-h-28 half is now a separate problem (N3-4). |
| N-26 | resolved | Amendment spec B2 "text follows HP_Trial (...) with the price and date of the student's own plan from the store (clarified Oct 6, gate N-26; Civil Service charges ₱149)". Consistent with pricing.md "Free trial". |

---

## Part B. The delta

### Traceability (script evidence)

Script `scratchpad/trace2.py` rerun on 6d0bb731.

- 833 rows (832 plus B-ST_ProCSEPass_v2), 0 malformed, 0 duplicate IDs.
- Counts: W4b 151, W4f 149, W4e 98, W4d 94, W4c 85, none 76, W4a 59, W4g 38, W1 27, W2 17, W3 14, W4h 13, W0 9, W5 3.
- Every non-`none` row cites `L2-<its own plan>.md §n` and that `## n.` exists; every `none` row has no section; level 3 column empty. 0 violations.
- W4a to W4h: §2 board list and "Other traceability rows" list equal the table exactly (0 missing, 0 extra); header counts equal the lists and the table for all eight.
- 290 board files equal 290 B- rows.
- Plan references with no row: D-18, D-89, D-102, D-160 (unchanged from review 2; heading lines, harmless).

Mechanically passes. Section accuracy the script cannot see: N3-5.

### Findings

#### N3-1 · contracts · should-fix
Location: `L2-W0` §3 table, "Recorded-only data" row (l.69).
Evidence: the Data layer row in the same table says "App database ... schema 25, unchanged" and section 1 says "the app database stays at schema 25". The Recorded-only row still says "mistake tags (`misread`, `slipped`, `unknown`, and from schema 26 `other` plus note text); mock blank reasons (schema 26)". The owner's contract contradicts itself; a level 3 author reading this row would add a schema 26.
Resolution: replace both "schema 26" mentions with the JSON field names from the Data layer row.

#### N3-2 · file overlap · should-fix
Location: `L2-W0` §1, §8; `L2-W4e` §8.
Evidence: W0 adds `missReason`, `blankReason`, `reasonNote` to each mock answer and `wrong`, `blank` to `SectionResult`. On the branch both classes live in `lib/features/mock_exam/domain/mock_results.dart` (`MockAnswer` l.8, `SectionResult` l.54), a W4e directory. W0 §8 lists only "`lib/core/storage/domain/` (JSON models)", which holds `AttemptItem` but not the mock models. The file is touched by W0 without being in its list (SUBAGENTS Part 2). Order exists (W0 before W4e), so only the list is wrong.
Resolution: add `lib/features/mock_exam/domain/mock_results.dart` (and whatever computes `SectionResult`, if W0 fills the counts) to W0 §8, or say W4e adds the fields and W0 only names them.

#### N3-3 · contradiction · should-fix
Location: `L2-W2` §1, §6, §7, §8, §9.
Evidence: §1 now says "W2 does not edit feature files ... W4c removes the `onReorder` deprecation ... W2 deletes an Ink component or `showInkSheet` once no caller remains." §6 Acceptance still requires "No remaining imports of retired Ink components or `showInkSheet`; `flutter analyze` clean (the `onReorder` info gone)". W2 runs before every W4 family, so its acceptance cannot pass when W2 lands. §7 and §9 move the check to "the end of W4" ("the gate checks none remain at the end of W4"; "Retirement of old components finishes when the last W4 family lands"), but no plan owns the final deletion of `ink_sheet.dart` and the Ink components after W2 is closed, and no W4 plan mentions replacing its sheet call sites or Ink components.
Resolution: move the "no remaining Ink imports" and "onReorder gone" checks out of W2 acceptance; name the owner and moment of the final deletion (for example the last W4 family to land, or a W5 or level 4 gate task); add one line to each W4 plan with call sites in `gap-h-shell-states.md` saying it replaces them.

#### N3-4 · ownership · should-fix
Location: traceability G-h-28 (l.879), owner W2 §4; `L2-W2` §1; `L2-W1` §3 Icons.
Evidence: G-h-28 "Icons in the app with no IC_Final entry: globe (Icons.public) on the share privacy note, collections-bookmark on the Wrapped reveal bar, ..." with "lead default: map each to its Phosphor equivalent on IC_Final". The icons are used in feature screens (Wrapped and sharing). After the N-12 fix W2 "does not edit feature files", and W2's plan never mentions G-h-28. W1 fixes "exactly these 45 getters", so a mapping that needs a new getter must amend W1. The row's owner cannot do the work and is silent on it.
Resolution: move G-h-28 to the families that own the screens (W4g at least) or to W1 if a getter is added, and state that each mapping uses one of W1's 45 getters.

#### N3-5 · traceability · note
Location: traceability R-21 (cites `L2-W4c §4`), A-B2b (cites `L2-W4f §4`).
Evidence: R-21's text is only in W4c §9 ("Removes the `onReorder` deprecation when rebuilding the bookmarks sheet (R-21)"); A-B2b is only in W4f §3 Contracts. The cited §4 exists, so the script passes, but the section named does not carry the item.
Resolution: cite §9 and §3, or add one line to each §4.

#### N3-6 · registry · note
Location: `docs/design/boards/ST_ProCSE_v2.html`, `ST_ProCSEPass_v2.html` titles; `docs/design/SCREENS.md` l.369-370; `docs/design/index.html`.
Evidence: both v2 titles still read "(proposal 6 Oct)" after approval. SCREENS.md and index.html list only ST_ProCSE and ST_ProCSEPass, with no superseded mark, and do not list either v2 board. Traceability is binding, so a builder following it is correct; one reading SCREENS.md builds the superseded layout.
Resolution: register the v2 boards and mark the originals superseded in SCREENS.md and index.html; drop "(proposal 6 Oct)" from the titles.

#### N3-7 · contracts · note
Location: `L2-W0` §1 "adding the catalog fields to `content_exams` (or a `catalogJson` column)".
Evidence: the storage form is still a choice. Consumers (W3, W4a, W4f) read the catalog through W0's named fields, so this does not block level 2, but level 3 of W0 must pick one before consumers write readers.
Resolution: level 3 of W0 fixes the form and the reader API name.

#### N3-8 · design gap · note
Location: tier spec B2; `L2-W3` §3 Season Pass end.
Evidence: "If the date moves later, the pass moves with it." The end date is computed by the webhook at purchase from `functions/src/examCatalog.json`. A later date arrives only through a new export and a functions deploy, and nothing recomputes the stored `endsAt` of passes already bought. No plan names that step.
Resolution: level 3 of W3 states how stored pass end dates are updated when the catalog date moves later.

#### N3-9 · facts · note
Location: `L2-W0` §1 (JSON fields instead of schema 26).
Evidence: `AttemptItem` is a freezed and json_serializable class (`lib/core/storage/domain/attempt.dart:11-28`) with `MistakeTag { misread, slipped, unknown }` and no unknown-value fallback. Sync copies `itemsJson` raw. An older app build on a student's second device that pulls an item tagged `other` fails to decode it. Moving from a schema bump to JSON removed the migration gate that would otherwise have surfaced this.
Resolution: level 3 of W0 adds an unknown-value fallback or records that no older build will sync with the new one.

#### N3-10 · attribution · note
Location: traceability G-g-15 (l.845).
Evidence: status now "decided: saved Wrappeds kept; history shows the Pro tag after a lapse; renewing restores (Aedwon, Oct 6)". The message Aedwon confirmed (log, item 3) said "Free rules for mock reviews and Wrapped history; nothing deleted; renewing restores". "Shows the Pro tag after a lapse" was the lead default and is not in that message. The previous status also covered the empty history state, which the new text drops.
Resolution: mark the Pro tag part "lead default" and restore the empty-state clause.

---

## Check summaries

- Part A: every review 2 item resolved.
- Traceability script: passes; N3-5 for section accuracy.
- Contracts named differently by owner and consumer: none found (TrialEndingNotifier, JSON field names, route files, family contracts all match). N3-1 is the owner contradicting itself.
- File overlaps without order: N3-2, N3-3, N3-4.
- Decisions not traceable to Aedwon's words: N3-10 (note). N-1, N-2, N-3 now trace to "1. yes / 2. yes / 3. keep on phone".
- CSE preview: three non-empty phone frames, scaled to fit (900 × 0.8 = 720, 1000 × 0.8 = 800).

Not checked:
- The CSE preview was checked from its source, not rendered in a browser.
- Plans and specs outside the diff were not re-read except the sections named above; findings from review 2 already resolved were not re-derived.
- W0 to W3 and W5 plans have no row lists in §2, so only section existence was checked for their rows; G-h-28 was found by reading.
- Board motion (`timeline.py`) was not run; v2 boards were read as text only.
- Google Play replacement modes were not checked against current documentation (left to level 3 by the tier spec).
- Whether Aedwon saw anything outside the repository was not checkable; Part A rests on the restart log.
- No builds, tests or analyzers were run; this is a document gate.

Gate verdict: not passed
