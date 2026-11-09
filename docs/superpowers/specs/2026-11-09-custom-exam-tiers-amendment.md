# Custom exams get a price tier from their subjects: spec amendment

**Date:** 9 November 2026
**Status:** Draft for Aedwon's approval. Nothing is built.
**Decision that started it (Aedwon, verbatim, relayed by the manager):** "i was thinking if they make their own custom exam, they have a student-only, professional-only or something like that kind of tiering so that we can limit and thus properly price their Pro subscription". Offered A (the subjects decide) or B (the student picks a category). Aedwon: "okay A." Logged on main at b362ba69b, launch log entry "Custom exams get a price tier".
**Amends:** `docs/superpowers/specs/2026-08-02-custom-exam-track-design.md` Section 1 and `docs/superpowers/specs/2026-11-04-custom-exams-on-web-design.md` choice 2 (1.3), 2.5, 2.7, 2.8, 2.9, 2.17 picks 2 and 6.
**Prices and tier rules:** `docs/pricing.md` (approved 4 October 2026) and `docs/superpowers/specs/2026-10-06-tier-pricing-design.md`. This amendment adds no price.
**Policy revision read:** origin/main eea141566 (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, `docs/workflow/orchestrator.md`, `docs/workflow/process-improvement.md`).
**Content read at:** `ds4/custom-exam-r2` with `origin/web/custom-exam-r1` merged in (merge not yet committed; content files had no conflicts). Hosted content was not read.

---

# Part 1. Plain-language section for Aedwon

## 1.1 What changes

- A custom exam now has a price tier, the same way a listed exam does.
- Each subject belongs to the lowest tier of any exam that uses it. The custom exam takes the highest tier among the subjects the student keeps.
- Studying stays free. A Free student on a custom exam gets the same Free features as on a listed exam.
- Pro for a custom exam is sold at its tier's prices from `docs/pricing.md`. A higher plan covers a lower exam, as it does today.
- This reverses the 4 November choice that a custom exam is always Free.

## 1.2 Which subject is which tier

Read from the exam tags on the real question sets.

| Subject | Exams that use it | Tier |
|---|---|---|
| Mathematics | UPCAT, ACET, DLSU-CET, USTET, PUPCET, CSE Professional, CSE Subprofessional | Student |
| Science | UPCAT, DLSU-CET, USTET, DOST | Student |
| Language Proficiency | UPCAT, ACET, DLSU-CET, USTET, DOST, CSE Professional, CSE Subprofessional | Student |
| Reading Comprehension | UPCAT, ACET, DLSU-CET, USTET | Student |
| Reasoning | DOST, ACET, USTET, CSE Professional, CSE Subprofessional | Student |
| General Information | CSE Professional, CSE Subprofessional only | Civil Service |

So today a custom exam is Student unless it keeps General Information. Then it is Civil Service. No subject is Licensure or PSHS-NCE yet.

When content is added, the table is rebuilt from the tags, and a check fails until it is current. A tier never changes without a reviewed commit.

## 1.3 What the student sees

**While choosing subjects** (onboarding and Settings):

- General Information carries a "Civil Service" tag on its row. Student subjects carry no tag.
- One line under the list updates as the student ticks: "Studying is free. Pro for this exam uses Student plans." or "... Civil Service plans."
- No price is printed here. The Pro page shows prices before any purchase, as the Terms already say.

**On the Pro page,** a custom exam gets the normal paywall of its tier, with the exam's own name. One line says why: "PUP CET uses Civil Service plans because it includes General Information." The free card ("PUP CET is free to study. Pro plans come with a listed exam.") is removed. A custom exam never sells a season pass, because a pass belongs to one listed exam and its published date.

**Mock limit, every tier:** Free gets one mock every 30 days on web (14 on the phone), counted across all of the student's exams, as now. Pro that covers the custom exam's tier has no mock cooldown, as on a listed exam.

**This also closes the held "no limits" question.** The free card that raised it is gone. The sales rows are the listed exam's rows, and each is true once Pro covers the exam.

## 1.4 When a later edit raises the tier

Example: a Student custom exam, and the student ticks General Information in What's Included.

- Free student: the tier line changes. Saving works as before.
- Pro that already covers Civil Service: nothing extra happens.
- Student Pro: before saving, a dialog says the exam becomes Civil Service and the Student plan does not cover it. Choices: Keep Current Subjects (first), Save on Free, See Civil Service Plans (the upgrade paywall). This matches the existing rule for switching to a pricier listed exam.
- If the student later removes General Information, the exam is Student again, and Student Pro covers it again at once.
- Lowering the tier never asks anything. Pro stays.
- Nothing is deleted at any point. Narrowing still only filters.

Switching a paying student from a listed exam to a custom exam follows the same tier rule. The old warning "On PUP CET you'll be on Free" is replaced: same or lower tier keeps Pro with no warning, and a higher tier shows the upgrade paywall or lets the student switch on Free. A pass holder still sees the existing warning that the pass stays with its exam.

## 1.5 How the server enforces it

- The server works out the tier itself from the subjects the student keeps. The app never sends a tier.
- Every place that checks Pro for an exam today checks the custom exam's tier the same way. That covers mock starts and limits, results and review, the plan's later days, study figures and the trial.
- Pro notes on each question already follow that question's own exam tags. A Student plan therefore never unlocks notes on a Civil Service-only question, whatever the custom exam's tier.

## 1.6 Terms

The current Terms say plans depend on the exam the student selects. They say nothing about custom exams. Three additions are needed before Pro for a custom exam goes on sale:

1. A custom exam's plans follow the highest tier among its subjects, and the app shows them before purchase.
2. Changing a custom exam's subjects can move it to a higher tier. The current plan then stops covering Pro features on that exam until the student upgrades or changes the subjects back. Refunds follow the store's and the law's rules only.
3. A season pass never covers a custom exam.

Per your 9 November rule, an agent drafts this text, GPT 6.1 Sol High critiques it, and you check the draft.

## 1.7 Decisions for you

1. **Approve this section.** It includes the Pro page change and the closing of the "no limits" question.
2. **Five Civil Service-only sets inside Student subjects.** Two Mathematics sets (data interpretation) and three Reasoning sets (clerical ability, verbal logic) are tagged only for CSE.
   - A. Keep the subject rule as you chose it (recommended). Those sets stay in a Student custom exam. Their Pro notes still need Civil Service Pro, so the only thing a Student plan gives on them is mock and plan access. Cost: none to build.
   - B. Price by topic instead. Data interpretation and clerical ability become Civil Service. Cost: about one more day, a tier tag on topic rows in What's Included, and a Mathematics or Reasoning tick that can quietly raise the tier.
3. **How the tier shows on the subjects step.** Options, drawn on a Claude Design board before building:
   - A. The line under the list only. Cheapest. The student cannot see which subject raises the tier.
   - B. The line, plus a tag on rows above Student (recommended). One tag today, on General Information.
   - C. A tag on every row. Five "Student" tags that tell the student nothing.
4. **The raise-tier dialog** in 1.4: its wording and three actions, on the same board.

## 1.8 Cost, risk and how it will be judged

- About 3 working days after the current merge lands: subject table and its check (half a day), server coverage (one day), setup line, dialog, Pro page and switch rule (one and a half days). Terms drafting runs in parallel. The board needs your pick first.
- Risk: every Pro check on the server gains a custom branch. A missed one makes a paying student look Free on one screen. Each has a test (2.6), and the audit covers it.
- Done when: a Student custom exam is covered by Student Pro; adding General Information is refused coverage on Student Pro and covered on Civil Service Pro; removing it restores Student coverage; a Free student sees the 30-day limit; no request from the app can change the tier; listed exams show no change in any response; you accept the screens.
- The custom exam row stays hidden on web until the manager says to show it. Pro for a custom exam does not go on sale before the Terms update is published.

---

# Part 2. Agent section

## 2.1 Verified facts this rests on

| Fact | Where |
|---|---|
| Tiers and inclusion: Student < Civil Service < Licensure; PSHS-NCE covers only PSHS-NCE; a pass covers only its exam | `docs/pricing.md`; `functions/src/revenuecatCoverage.ts:4,13-15,97-99` |
| Exam tier is the `priceTier` string per exam in `content/exams/catalog.json` | catalog; string-to-enum maps in `mockAccess.ts:8`, `studyInsights.ts:37`, `betaReward.ts:198`, `grants.ts:34` |
| `mockCoverage().coversExam(examId)` looks up the catalog and returns false for any id not in it, so a custom id is never covered today | `functions/src/mockAccess.ts:24-28` |
| `access.coversExam(examId, requestedTier)` already takes a tier: pass for that exact id, or subscription or grant tier at or above | `revenuecatCoverage.ts:97-99` |
| Question-set Pro depth follows the set's own `meta.exams` tags against coverage, not the selected exam | `functions/src/content.ts:97-114` |
| The setup screen's "subject" is a subject name that groups topic ids across exams; the track stores the complement as `excludedTopicIds` and `excludedLessonIds` | `custom_track_subjects_step.dart:27-53,89,133-135`; track doc in `_customTrack.ts:12-13`, written in `roadmap.ts` `saveExamSettings` |
| Subject names come from `tools/lesson_author/outline.json`: Mathematics, Science, Language Proficiency, Reading Comprehension (owner UPCAT), Reasoning, General Information (owner CSE Professional). Verbal Ability is inactive and not offered | `tools/build_content_export/build_content_export.dart:117-162` |
| Tags in use: upcat, acet, dlsucet, ustet, pupcet, dost-sei, cse-pro, cse-sub. All live. No set is tagged for a coming-soon exam, and none for sm-foundation | `content/questions/**/*.yaml` `meta.exams`, 158 sets |
| Free mock window 30 days, counted over all of the student's mocks | `mock.ts:19,277-282`; `mockReader.ts:100-105` |
| Beta grant tier is `civilService` | `betaPro.ts:52` |
| Web prepaid plans are listed by tier, not by exam; only passes carry an `examId` | `webPlans.ts:14,42-45` |

Set counts per subject and tag are in the research note `tier-map.md` (session scratchpad, not committed). The plan step T1 regenerates them from the tree.

## 2.2 Lead rulings

1. **Subject identity is the subject name**, the same grouping the setup screen and What's Included use. A subject counts as kept while at least one of its topics is included.
2. **Subject tier** = the lowest tier, by the subscription ladder, among the exams tagged on any active question set in that subject. Coming-soon exams count, because their tier is published in the catalog. A subject whose only tags are PSHS-NCE is not offered in a custom exam until Aedwon decides, since that tier sells passes only. None exists today.
3. **Custom exam tier** = the highest subject tier among kept subjects. An exam with no kept subject cannot be saved, as today.
4. **Computed, never stored as truth.** The server derives the tier from the authoritative exclusions (`settings` while active, else the track document) and the generated table, at each check. `getCustomTracks` returns it for display. A stored copy would go stale when the table changes.
5. **Passes never cover a custom id.** `access.coversExam` is called with an id no pass can carry. The paywall omits the pass card.
6. **Beta grants** cover a custom exam by their `civilService` tier, as they already cover Student exams. The beta row stays hidden on a custom exam (`setBetaPro` remains CSE only).
7. **Native** uses the same table through the client copy. Phones are not publicly released, so native purchase flows are checked with the native release work.
8. **No change to question-level gating** in `content.ts`. It already prevents a Student plan from unlocking Civil Service-only notes.

## 2.3 The subject table

- New tool `tools/custom_tiers/build_custom_tiers.dart` reads `content/questions/**/*.yaml` (`meta.subject`, `meta.topic`, `meta.exams`, inactive questions skipped), `tools/lesson_author/outline.json`, and `content/exams/catalog.json`. It writes `content/exams/custom_subject_tiers.json`:

```json
{"version": 1,
 "subjects": [{"name": "General Information", "tier": "Civil Service", "topicIds": ["topic_upcat_..."]}]}
```

- Topic ids are the catalog ids the client and server already share (`topic_upcat_*`).
- `functions` build copies it next to `examCatalog.json` (`package.json` build script). The app reads it as an asset beside the catalog.
- New check `tool/checks/custom_subject_tiers.dart`: regenerates in memory and fails if the file differs, naming the subject. Test on a sample with a stale row, shown failing first (process-improvement rule 1).
- A topic absent from the table (new content before the table is rebuilt) takes the tier of the highest-tier exam tagged on its sets, never the lowest, so an unmapped topic cannot lower a price. The check makes this state short-lived.

## 2.4 Server

**`functions/src/_customTrack.ts`:** `customTier(excludedTopicIds: string[]): PriceTier` from the table. Pure, unit tested.

**`functions/src/mockAccess.ts`:** `mockCoverage` gains `coversCustom(tier: PriceTier): boolean`, which calls `access.coversExam('', tier)` so no pass can match. `coversExam(examId)` keeps its behavior for listed ids. Callers with a custom id read the exclusions they already read and call `coversCustom(customTier(...))`.

**Call sites, each with its test:**

| Site | Today for custom | After |
|---|---|---|
| `mock.ts` `beginMock` cooldown (around 277-282) | always Free window | Free window only when `!coversCustom` |
| `mockReader.ts` availability and `summary` (`proCovered`, around 74, 93-105) | false | `coversCustom` |
| `mockReader.ts` / `updateMockReview` | refused | allowed when covered |
| `roadmap.ts` `studyContext` `context.pro` | false | `coversCustom`; `comingUp`, `history`, future days follow the listed rules |
| `studyInsights.ts` `pro`, `actualTrial` (around 37-40) | false, null | tier from `customTier`; trial resolves as for a listed exam of that tier |
| `sessionDiagnosis.ts` `pro` (40, 71) | false | `coversCustom` |
| `customTracks.ts` `readCustomTracks` | no tier | adds `priceTier` per track, computed |
| `content.ts` | per set tags | unchanged |

**Listed exams:** no response, digest or cache key changes. The existing listed regression fixtures stay byte-identical.

**Cache keys:** insights `sourceRevision` already includes the custom exclusions, so a tier change refreshes it. Add the tier string for custom ids only.

## 2.5 Client

All UI uses design system 4.0 components (`design/system/`), built 1:1 from the approved Claude Design board. No raw Material controls (guardrails plan).

**Subjects step** (`custom_track_subjects_step.dart`, onboarding and the Settings path), and **What's Included** (`whats_included_page.dart`) for custom exams:

- Tier per row: system `Tag` (default tint) with the tier name, on rows above Student only (decision 3 B). On the wide `SelectableTile` and the phone `ListRow.checkbox`.
- Tier line: body text under the list, `text-secondary`, updated on each tick from the client table. Strings: "Studying is free. Pro for this exam uses Student plans." / "... Civil Service plans." / "... Licensure plans."
- The client table is display only. The server decides coverage.

**Raise-tier dialog** (What's Included save, and the subjects step from Settings): system `Dialog`, shown only when `entitlement.proIsActive` and the current plan's tier is below the new tier. Title "This makes PUP CET a Civil Service exam". Text "Your Student plan covers Student exams. Pro features stop on PUP CET unless you upgrade." Actions in Dialog README order: Keep Current Subjects, Save on Free, See Civil Service Plans (opens the Pro page in upgrade mode). Wording is decision 4.

**Pro page** (`pro_page.dart`): remove `_CustomFreeCard` and the `showOffers = !custom` rule. A custom track resolves its tier from `getCustomTracks` (web) or the client table (native) and shows that tier's paywall, the same component path as `PriceTier.fromCatalog` for a listed exam, with no pass card. Header uses the track name. One line under the header: "PUP CET uses Civil Service plans because it includes General Information." For Student: "PUP CET uses Student plans."

**Switching** (`settings_routes_native.dart` around 384-392, `ChangeExamPage`): compute `to` from the custom tier instead of null. Remove the pick 6 A dialog. Same and lower tier: no warning. Higher: the existing upgrade board (`ST_SwitchUpgrade`). Pass holders: existing `ST_SwitchPassWarn`.

**Mock card** (`mock_card.dart`): unchanged text. It already prints the Free interval.

## 2.6 Tests

Functions (emulator unless marked plain):

- Plain: `customTier` for every subject, for an unmapped topic, for all-excluded.
- Plain: the table check fails on a stale sample.
- `custom-track.emulator.mjs`: Student custom exam covered by Student Pro, Civil Service Pro, Licensure Pro and the beta grant; Civil Service custom exam not covered by Student Pro, covered by Civil Service Pro; a pass for CSE Professional never covers a custom exam; a client-sent `priceTier` field is ignored.
- `mock-paper.emulator.mjs`: covered custom exam starts a second mock inside 30 days; uncovered is refused with the existing message.
- `mock-reader.emulator.mjs`: availability `cooldown` only when uncovered; review edits allowed when covered.
- `study-roadmap.emulator.mjs`: covered custom exam gets `comingUp` and `history`; adding General Information on Student Pro removes them on the next read; removing it restores them.
- `carry-over-figures.emulator.mjs` and insights: Pro fields present when covered.
- Listed regression fixtures unchanged.

Client:

- `custom_track_steps_test.dart`: tag only on General Information; line text follows ticks.
- `whats_included_page_test.dart`: dialog for Student Pro adding General Information; no dialog for Free or Civil Service Pro; Save on Free saves; Keep Current Subjects saves nothing.
- `pro_page_custom_test.dart` (rewritten): Student and Civil Service paywalls by name, no pass card, no free card, the why line.
- `router_settings_test.dart`: switch to a higher-tier custom exam shows the upgrade board; same tier shows nothing.
- Golden for the subjects step and the dialog per the guardrails plan, one sheet each.

## 2.7 Plan

Runs after the current merge of `origin/web/custom-exam-r1` and the design system 4.0 rebuild of the custom screens land on `ds4/custom-exam-r2`. Implementers Sonnet, bulk Haiku, review per `SUBAGENTS.md`. This touches entitlement, so an independent review is required and the lead decides every finding.

| Task | Files | Depends on |
|---|---|---|
| T0 Board | Claude Design board with decision 3 options and the dialog; Aedwon picks | approval of Part 1 |
| T1 Table and check | new tool, new JSON, new check and its test, `functions/package.json` build copy, app asset entry | Part 1 approval, decision 2 |
| T2 Server coverage | `_customTrack.ts`, `mockAccess.ts`, `mock.ts`, `mockReader.ts`, `roadmap.ts`, `studyInsights.ts`, `sessionDiagnosis.ts`, `customTracks.ts`, tests in 2.6 | T1 |
| T3 Client | subjects step, What's Included, Pro page, switching route, client table reader, tests in 2.6 | T0, T1 |
| T4 Terms | agent draft in `docs/legal/drafts/`, Sol High critique through `codex-pick`, Aedwon checks | Part 1 approval |
| T5 Checks and review | hosted CI full set, functions `npm test` on hosted Actions, independent review | T2, T3 |

Stop conditions: a Pro check found that 2.4 does not list; a subject whose only tags are PSHS-NCE; any listed-exam response change.

## 2.8 What this supersedes

- 2 August spec Section 1 "Free, uncapped": studying stays free and uncapped; Pro is now sold for a custom exam at its tier. Section 6's cooldown rule stands for Free.
- 4 November spec 1.2 first bullet and 1.3 choice 2 (2A, always Free); 2.5 "`pro` is false"; 2.7 "`updateMockReview` stays Pro only, so it refuses on a custom paper under choice 2A"; 2.8 in full; 2.17 picks 2 and 6; 2.15 rows that assert Free-only depth for custom; A1 audit question "Can a custom id reach `coversExam` as true" becomes "can a custom id be covered by a tier below its own, or by a pass".
- The held "no limits" question on the custom Pro card (launch log, 5 November): closed by removing that card, if Aedwon approves Part 1.
