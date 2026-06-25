# The execution pipeline

**The single document a dispatcher reads before sending anything to an implementor.**
Rewritten 3 August, late, to carry the three-tier split and the work state as it actually is.

It supersedes the execution order in `2026-08-02-work-checkpoint.md`.

**Companions.** `SUBAGENTS.md` is the contract a dispatched run works under, Part 7b for the
verifier tier. `2026-08-03-execution-resourcing.md` says who runs what and sizes the beta.
`2026-08-03-next-rounds.md` carries paste-ready prompts for the rounds that are not plans yet.
`2026-08-03-launch-checklist.md` is everything between here and a paid install.

---

## Part 1: The three tiers

| Tier | Model | Work |
|---|---|---|
| **C** | Claude | Design rounds, specs, conflict rulings, merge decisions, the money path. |
| **P** | Gemini 3.1 Pro | **Verifies F.** Implements schema, sync and entitlement. |
| **F** | Gemini 3.6 Flash | Bulk generation and assembly. |

**Every item below carries its tier.** A verifier reports evidence and never fixes what it
finds: `SUBAGENTS.md` Part 7b.

### The dispatch line

Prompts are three lines. The plans already carry every rule, and restating them pays for the
same words twice.

```
Execute `docs/superpowers/plans/<PLAN>.md`, <scope>.
Follow `SUBAGENTS.md`, Part 4 for content or Parts 3 and 5 for code.
Do not commit. Report the gate command's pasted output and any findings.
```

### The verifier line

```
Verify the work just done under <path> against `docs/superpowers/plans/<PLAN>.md`.
Follow `SUBAGENTS.md` Part 7b. Report evidence, not assertions. Do not fix anything.
```

---

## Part 2: Done, so it stops being re-planned

| | State |
|---|---|
| **Foundations 01**, tasks 1 to 3 | Merged. Error boundary, telemetry seam, consent gate defaulting to off. |
| **Six plan conflicts** | Ruled and landed across 13 plans. |
| **Readiness sweep** | 47 plans carry a model-agnostic preamble, cite `AGENTS.md` and their spec, and state the analyzer invariant. |
| **Content: Mathematics** | **674 questions**, 43 of 44 subtopics. Only `real-imaginary-numbers` open. |
| **Content: Language Application** | 45 questions, closing that manifest. |
| **Attribution gate** | Rewritten, green for the first time, and it reads commit messages. |
| **Validator** | Quiet and scoped; names the file and missing key instead of crashing at 255. |

**Corpus today:** Science 777, Mathematics 674, Language 319, Reasoning 208, Reading
comprehension 0.

---

## Part 3: Do these first, in this order

### 1. Connect the content to a shipping build. **Nothing else matters until this lands.**

**1,918 questions are authored and 1,117 are in the committed seed.** Everything written since
25 July is invisible in a release build. `assets/seed/v1.json` is a dev artifact its own tool
says not to commit, and the production path through `content.db` is an `AGENTS.md` landmine:
undeclared asset, no `SeedInstaller` callers, throwing provider.

| | Plan | Tier | Tasks |
|---|---|---|---|
| 1a | `2026-08-02-content-seed-delivery.md` | **P** | 2 |
| 1b | `2026-08-03-content-upgrade-seeder.md` | **P** | 5 |

**Why P and not F:** 1b migrates a schema and must not touch a student's progress. A migration
that writes the wrong table is data loss found by a student.

**1a first, then 1b.** Both touch `seeder.dart`. Read Section 8 of
`specs/2026-08-03-content-delivery-and-seed-upgrade-design.md` before either: 1a owns
`content.db` for blueprints and mocks, 1b owns `v1.json` for questions and lessons.

*Deferred by Aedwon on 3 August as "the connecting work". It stays listed first because the
whole corpus is unreachable without it.*

### 2. The passage pipeline, which unblocks a whole subject

| | Plan | Tier | Tasks |
|---|---|---|---|
| 2 | `2026-08-03-passage-pipeline.md` | **P** | 6 |

Reading comprehension ships in v1 and sits at zero. Nothing models a passage today. Tasks 1 to
4 depend on nothing; **Task 5 needs Quiz 4 and says to stop if it is absent.**

Takes the next schema version after 1b. Confirm the current value first.

### 3. Then the content behind it

| | Plan | Tier | Scope |
|---|---|---|---|
| 3a | `2026-08-03-question-generation-reading-comprehension.md` | **F** | Comprehension Skills, 8 rows |
| 3b | same | **F** | Text Types, 5 rows |
| 3c | `2026-08-03-question-generation-mathematics.md` | **F** | `real-imaginary-numbers`, 1 row |

**3a and 3b are separate agents, different directories, no collision.** Each gets a P verifier
afterward, checking passage word counts, set sizes, and that no distractor is filler.

---

## Part 3b: The two that unblock everything else

**Added 4 August 2026 by an audit across all 89 plans. Neither was called out anywhere, and
both gate more work than anything else in the queue.**

| | Plan | Why it comes first |
|---|---|---|
| **X1** | `onboarding-flow-and-new-steps.md` **Task 1 only** | Creates `ExamDate` with precision. **Eight plans read it**, and the study plan and paywall 02 stop dead without it. Today the stored date is a bare `DateTime?` with no precision, so anything that prints a countdown is either blocked or inventing one |
| **X2** | `settings-01-the-kit.md` | Adds five type sizes that **do not exist** in `AppTextStyles`. **Four plans stop and say so** without them: both paywall plans, the study plan and mock 03 |

**Both are small. Both are cheap. Run them before Lane C.**

---

## Part 4: What runs in parallel

**Four independent lanes once Part 3 is moving.** Nothing in one lane blocks another.

### Lane A: Finish Phase 0

| | Plan | Tier | Tasks | Waits on |
|---|---|---|---|---|
| A1 | `foundations-01-observability.md` **Task 4 only** | **F** | 1 | nothing |
| A2 | `foundations-02-app-check-and-force-update.md` | **P** | 3 | nothing |
| A3 | `offline-posture.md` | **P** | 3 | nothing |

A1 emits eleven events and absorbs the orphaned `CrashReporter`. A3 is P because its Task 1 is
the entitlement rule: fail closed there and a paying student loses Pro in a dead zone.

### Lane B: The seams every UI thread reads

| | Plan | Tier | Tasks |
|---|---|---|---|
| B1 | `settings-01-the-kit.md` | **F** | 5 |
| B2 | `settings-02-storage.md` | **F** | 4 |
| B3 | `quiz-tab-02a-frame-and-panel.md` | **F** | 3 |
| B4 | `study-01-foundations.md` | **P** | 7 |
| B5 | `home-02-assessment-attempt-row.md` | **F** | 3 |

**B4 is P: it takes schema 15 and must confirm the current value first.** B5 is a live defect
as much as a seam: the assessment writes no attempt row, so Progress is blind to its 21
questions.

### Lane C: The UI threads, after Lane B

Each is a chain. **One agent per plan, in order, with a P verifier between links.**

- **Onboarding and Settings:** onboarding-flow → onboarding-polish (9 tasks) → settings-03 →
  04 → 05 → 06 → exam-switching (2 tasks). All **F**.
- **Quiz:** 02b (**P**, selector wiring) → 02c → 03 → 04 → 05 → 06. Rest **F**.
- **Study:** 02 → 03a and 03b in parallel → 04 → 05. All **F**.
- **Home:** 01 → 03 → **05** → 04, 06. All **F**. **Corrected 4 August 2026 from "04, 05, 06 in
  parallel":** Plan 5 owns `topicAccuracyProvider` and Plan 4 reads it. Run in parallel, both
  find it absent and both write a ranking, which is the collision map's `topicAccuracyProvider`
  row happening for real.
- **Progress:** G1 first, it deletes machinery → G2 to G6 in parallel. All **F**.

### Lane D: Content, always parallel-safe

**Content agents write `content/` and `assets/seed/`; code agents write `lib/` and `test/`.**
They never conflict, so Lane D runs alongside everything above.

---

## Part 5: Last

| | Plan | Tier | Waits on |
|---|---|---|---|
| Z1 | `mock-01-the-paper.md`, `mock-02-the-endings.md` (3 tasks) | F | Part 3 item 1, Quiz 4 and 6 |
| Z2 | `custom-track-a` (schema 16), `custom-track-b` (schema 17) | **P** | Lane C |
| Z3 | `notifications-countdown-and-comeback.md` | F | onboarding, settings-04 |
| Z4 | `foundations-03-l10n-feedback-and-review.md` | F | home-03, settings-06, **and two dependency decisions** |
| Z5 | `foundations-04-accessibility.md` Tasks 2 and 3 | F | the kit has stopped changing |

**Pull `foundations-04` Task 1 forward into Lane A.** It is documentation: it puts four
accessibility rules into every unexecuted UI plan so components are built right rather than
swept later.

---

## Part 6: Needs Claude, not an agent

Nothing here can be dispatched. Prompts are in `2026-08-03-next-rounds.md` Part 1.

| | Why it is tier C |
|---|---|
| **The Pro specimen fallback**, then the paywall plan | Undesigned, and it blocks the purchase screen. `purchases_flutter` is imported by zero files and the only gateway returns Free from `purchase()`, so **the app cannot take money.** |
| **The study plan feature** | Spec and plan predate the identity by two months; providers throw. Two shipped plans reserved a shape for it. |
| **The mock's five missing screens** | Setup, pause, forfeit, section transitions, history. May be a confirm round rather than a redraw; decide that first. |
| **Any finding a verifier reports** | And any "stop and say so" an implementor hits. |

---

## Part 7: Blocked on Aedwon

| Blocked | On |
|---|---|
| `url_launcher` and `in_app_review` | One dependency decision covering both. Two tasks stop and ask. |
| Three blueprints | `sectionalTiming` for ACET, DCAT, MSU-SASE. |
| The feedback row | The community group URL, plus a developer contact email Play requires separately. |
| Question approval | Every generated file has `approved:` unset by design. Question Studio is yours. |
| Illustrations | 11 Geometry figure slugs are logged with described stems, so nothing is blocked, but the pictures are yours. |

---

## Part 8: The collision map

**Read the row before dispatching either plan.**

| Symbol | Named by | The failure if ignored |
|---|---|---|
| `topicAccuracyProvider` | H4, H5, **and G3** | Home calls a topic weak, Progress calls it strong. |
| `severityFor` | H5 defines, G3 moves to `lib/core/ui/severity.dart` | Two colorings of one figure. |
| `InkCheckbox` | Created by study-03a; referenced by Quiz 3, 5 and custom-track A | Two checkboxes, or three. |
| `InkTableRow` | study-01 Task 7, then study-03a Task 3 | The second change reverts the first. |
| `entitlementProvider` | offline-posture Task 1, and the paywall rebuild | **The paywall must not undo the cached-wins rule.** |
| `seeder.dart` | 1a and 1b | Both touch it. Order matters. |
| `schemaVersion` | study-01 = 15, custom-track-a = 16, custom-track-b = 17, plus 1b and the passage pipeline | **Every one confirms the current value before bumping.** Assigned numbers rot. |
| `lib/app/router.dart` | **25 plans** | Merge noise, not logic. Never let an agent resolve a router conflict. |

**Resolved and recorded, so nobody re-derives them:** one `ExamDate` on onboarding's names;
Quiz 6 owns the review component and mock-02 Task 2 is struck; Settings absorbed six
duplicated tasks from onboarding-polish and exam-switching; quiz-2b's settings page is struck.

---

## Part 9: Health, measured today

| Check | Result |
|---|---|
| `flutter analyze` | **Zero issues under `lib/` or `test/` outside `test/tool/`.** That is the invariant; the raw count drifts with `tools/`. |
| `flutter test` | Green |
| `dart run tool/check_layering.dart` | 7, the accepted baseline |
| `dart run tool/check_no_ai_attribution.dart` | 0, and it reads commit messages |
| Content validator | 0 across the corpus |
| Unresolved plan conflicts | 0 |

---

## Part 10: If you only do five things

1. **Connect the content to a shipping build.** 1,918 questions currently reach nobody.
2. **The passage pipeline**, then reading comprehension behind it.
3. **Design the Pro specimen fallback and plan the paywall**, including the live gateway.
4. **Lane B**, the five seams every UI thread reads.
5. **Approve the generated questions in Question Studio.** Nothing ships unapproved, and it is
   the one step no agent can do.
