# The execution pipeline

**The single document a dispatcher reads before sending anything to an implementor.**
**Rewritten 4 August 2026**, after a day in which four worktrees merged, three design rounds
closed, five plans were written and every plan was audited for contradictions.

It supersedes the execution order in `2026-08-02-work-checkpoint.md`.

**Companions.** `SUBAGENTS.md` is the contract a dispatched run works under, Part 7b for the
verifier tier. `2026-08-03-execution-resourcing.md` says who runs what and sizes the beta.
`2026-08-04-plan-consistency-audit.md` is what an audit across all 89 plans found and fixed.
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

```
Execute `docs/superpowers/plans/<PLAN>.md`, <scope>.
Follow `SUBAGENTS.md`, Part 4 for content or Parts 3 and 5 for code.
Run every command in the FOREGROUND and wait for it. Never background one.
Report the gate command's pasted output and any findings.
```

**That third line is not optional and it was learned expensively.** On 4 August three runs
stalled part way and stranded their work because Gemini launched `flutter test` in the
background and then idled. Adding the line fixed it: both resumed runs finished clean.

### Quota, which cannot be checked automatically

**`agy` exposes no usage command and nothing on disk records it.** Verified 4 August rather than
assumed. The only signals are Aedwon's reading of it and an error back from the CLI.

- **Ask him for headroom before each wave.**
- **Below roughly a quarter left, do not start a plan with unfinished tasks.** A run that dies
  mid-task strands its work, which is what cost most of 4 August.
- **When headroom is thin, do the zero-Gemini work instead:** verify and merge finished
  worktrees, rebuild the seed, or design.
- **Confirm which way a percentage runs.** "At 20%" meant 20% consumed; "at 81%" meant 81%
  remaining. Both were misread on 4 August, in opposite directions.

### Dispatching, mechanically

**Never dispatch through a subagent.** The permission classifier refuses the required flag
inside a subagent's context and the run stalls every time, whatever the prompt says. **Dispatch
directly from the orchestrator**, one git worktree per plan.

---

## Part 2: Done, so it stops being re-planned

| | State |
|---|---|
| **Foundations 01**, tasks 1 to 3 | Merged. Error boundary, telemetry seam, consent gate. |
| **Content delivery** | **Merged 4 August.** The corpus now reaches a release build. This was the thing everything else was waiting behind. |
| **Study 01 foundations** | **Merged 4 August.** `schemaVersion` **16**, bookmarks, lesson ordering, `InkTableRow`'s chevron and gutter. |
| **Offline posture** | **Merged 4 August.** The cached-wins entitlement rule is live: a paying student keeps Pro in a dead zone. |
| **Mathematics** | **Complete, 689 questions across all 44 subtopics.** |
| **Six plan conflicts, the readiness sweep, the attribution gate, the validator** | As before. |

**Corpus today:** Science 777, Mathematics 689, Language 319, Reasoning 208, Reading
comprehension 0. **Total 1,993.**

**Health on `main`, measured 4 August:** 1063 tests pass, zero analyzer issues under `lib/` and
`test/` outside `test/tool/`, formatter clean, layering 7, attribution 0, content validator 0.

---

## Part 3: The two that unblock everything else

**Found by the 4 August audit. Neither was called out anywhere, and both are small.**

| | Plan | Tier | Why first |
|---|---|---|---|
| **X1** | `onboarding-flow-and-new-steps.md` **Task 1 only** | **P** | Creates the exam date with its precision. **Eight plans read it.** The study plan and paywall 02 stop dead without it |
| **X2** | `settings-01-the-kit.md` | **F** | Adds five type sizes that do not exist. **Four plans stop and say so** without them |

**Run these before Lane C. They are cheap and they gate about a third of the queue.**

---

## Part 4: Then, in this order

### 1. Finish what is in flight

| | Plan | Tier | State |
|---|---|---|---|
| 1a | `foundations-01` **Task 4** | F | **Stalled in a worktree** with 19 uncommitted files and no commits. Resume it, do not re-dispatch cold |

### 2. The rest of the content path

| | Plan | Tier | Notes |
|---|---|---|---|
| 2a | `content-upgrade-seeder.md` | **P** | Reads the live schema, takes the next number |
| 2b | `passage-pipeline.md` | **P** | Same. Task 5 needs Quiz 4 and says to stop if absent |
| 2c | `question-generation-reading-comprehension.md` | **F** | Two agents, different directories. Reading comprehension is at zero and ships in v1 |
| 2d | `content-three-passes.md` | **F**, Task 1 is **P** | The lesson link is derivable and needs no authoring. The reasons and labels are a generation pass |

### 3. The money path, now planned

| | Plan | Tier |
|---|---|---|
| 3a | `paywall-01-ladder-and-live-gateway.md` | **P** |
| 3b | `paywall-02-the-three-screens.md` | **F**, after X1 and X2 |

**Until 3a lands the app cannot take money.** `purchases_flutter` is declared and imported by
zero files, and the only gateway returns Free from `purchase()`.

---

## Part 5: The parallel lanes

**Nothing in one lane blocks another.**

### Lane A: Finish Phase 0

| | Plan | Tier | Waits on |
|---|---|---|---|
| A1 | `foundations-02-app-check-and-force-update.md` | **P** | nothing |
| A2 | `foundations-04` **Task 1** | F | nothing. It is documentation: it puts four accessibility rules into every unexecuted UI plan |

### Lane B: The seams every UI thread reads

| | Plan | Tier |
|---|---|---|
| B1 | `settings-02-storage.md` | **F** |
| B2 | `quiz-tab-02a-frame-and-panel.md` | **F** |
| B3 | `home-02-assessment-attempt-row.md` | **F** |

**B3 is a live defect:** the assessment writes no attempt row, so Progress is blind to its 21
questions.

### Lane C: The UI threads, after Lane B

Each is a chain. **One agent per plan, in order, with a P verifier between links.**

- **Onboarding and Settings:** onboarding-flow (the rest) → onboarding-polish → settings-03 →
  04 → 05 → 06 → exam-switching. All **F**.
- **Quiz:** 02b (**P**, selector wiring) → 02c → 03 → 04 → 05 → 06. Rest **F**.
- **Study:** 02 → 03a and 03b in parallel → 04 → 05. All **F**.
- **Home:** 01 → 03 → **05** → 04, 06. All **F**. **Corrected 4 August:** Plan 5 owns
  `topicAccuracyProvider` and Plan 4 reads it. In parallel, both find it absent and both write a
  ranking, which is the collision map's own warning happening for real.
- **Progress:** G1 first, it deletes machinery → G2 to G6 in parallel. All **F**.
- **Study plan:** `study-plan-forward-calendar.md`, **after X1**. **F**.
- **Mock:** mock-01 → mock-02 → **mock-03**. All **F**, after X2.

### Lane D: Content, always parallel-safe

**Content agents write `content/` and `assets/seed/`; code agents write `lib/` and `test/`.**
They never conflict.

---

## Part 6: Last

| | Plan | Tier | Waits on |
|---|---|---|---|
| Z1 | `custom-track-a`, then `custom-track-b` | **P** | Lane C. **Both now read the live schema rather than expecting a number** |
| Z2 | `notifications-countdown-and-comeback.md` | F | X1, onboarding, settings-04 |
| Z3 | `foundations-03-l10n-feedback-and-review.md` | F | home-03, settings-06, **and one dependency decision** |
| Z4 | `foundations-04` Tasks 2 and 3 | F | the kit has stopped changing |

---

## Part 7: Needs Claude, not an agent

**All three design rounds closed on 4 August.** What is left here is smaller than it was.

| | Why it is tier C |
|---|---|
| **Any finding a verifier reports**, and any "stop and say so" an implementor hits | Six plans carry one deliberately |
| **Merge decisions and conflict rulings** | Never let an agent resolve a router conflict |
| **The Pro specimen's authored figures** | The design is settled; the sample's own numbers still need choosing and they must never read as measured |

**Closed 4 August:** the Pro specimen fallback and the paywall plan, the study plan, and the
mock's five missing screens.

---

## Part 8: Blocked on Aedwon

| Blocked | On |
|---|---|
| `url_launcher` and `in_app_review` | Two decisions, not one. `url_launcher` is needed by the feedback row **and** the force-update button, and there is no alternative. `in_app_review` only pops a rating prompt and is deferred out of the beta anyway |
| The feedback row | The community group URL, plus a developer contact email Play requires separately |
| Question approval | Every generated file has `approved:` unset by design. Question Studio is yours |
| Illustrations | 11 Geometry figure slugs are logged with described stems, so nothing is blocked, but the pictures are yours |
| **ACET's aptitude timing** | Derived from a rate, not published. It implies 12 seconds an item. **Confirm before that blueprint ships** |

**Closed 4 August:** `sectionalTiming` for all three exams.

---

## Part 9: The collision map

**Read the row before dispatching either plan.**

| Symbol | Named by | The failure if ignored |
|---|---|---|
| `topicAccuracyProvider` | **H5 owns it.** H4 and G3 read it | **Ordered on 4 August.** Run H4 in parallel with H5 and both write a ranking |
| `severityFor` | H5 defines, G3 moves it | Two colorings of one figure |
| `InkCheckbox` | Created by study-03a; referenced by Quiz 3, 5 and custom-track A | Two checkboxes, or three |
| `entitlementProvider` | **Owned by offline posture, now merged.** Both paywall plans say do not touch it | The paywall must not undo the cached-wins rule |
| `seeder.dart` | content delivery, now merged, and the upgrade seeder | Order matters |
| `schemaVersion` | **No plan names a number any more.** Every one reads the live value and takes the next | **Assigned numbers rot, twice now** |
| `AppTextStyles` | X2 owns it. Four plans stop without it | Hand-rolled sizes that disagree with the kit |
| `lib/app/router.dart` | **25 plans** | Merge noise, not logic. Never let an agent resolve a router conflict |

---

## Part 10: If you only do five things

1. **X1 and X2**, the exam date and the type sizes. Small, and they gate a third of the queue.
2. **Reading comprehension**, which ships in v1 and sits at zero.
3. **The paywall**, because the app still cannot take money.
4. **The lesson link**, which is one line and no authoring, and which fills the deepest level of
   Progress, the reader's ending and the practice picker's lesson filter.
5. **Approve the generated questions.** Nothing ships unapproved, and it is the one step no
   agent can do.
