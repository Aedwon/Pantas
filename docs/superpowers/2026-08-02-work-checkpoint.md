# Work checkpoint, 2 August 2026

A snapshot of what is outstanding, taken before the onboarding pass begins. Every
claim below was checked against the tree on this date, not carried over from an
earlier note. When an item is finished, strike it here and say what closed it.

**Repo state on this date:** `content/static-question-pipeline` has been merged;
`main` is 2 commits ahead of it and is the trunk again. Both branches still exist.

---

## 1. Specs approved, no implementation plan written

Design ended at a written spec for all five. None has a plan in
`docs/superpowers/plans/`, where the newest file is dated 25 July.

| Spec | Date | Status | Note |
| --- | --- | --- | --- |
| Home and navigation | 07-26 | Approved | Its Section 2, onboarding captures name and exam date, is a stated prerequisite for the Progress tab |
| Study tab and reader | 07-27 | Approved | |
| Quiz tab | 07-28 | Approved, design closed | Splits into the viewer, grid and flag, then the debrief |
| Mock exam UI | 07-28 | **Partial** | Splits into the paper and the endings; both wait on the Quiz grid and flag |
| Progress tab | 07-30 | Approved | The most blocked of the five, see sections 3 and 4 |

## 2. Plans written, never executed

- **Onboarding polish**, `plans/2026-07-25-onboarding-polish.md`, 13 tasks.
  Confirmed unexecuted on this date: neither `lib/core/ui/components/exam_selection_row.dart`
  nor `lib/features/settings/presentation/pages/exam_page.dart` exists.
  This is the item the work queue named first, because it unblocks Progress's
  `Your pace` and `Your profile`.

## 3. Prerequisites, small, blocking a lot

- **Seed delivery is broken.** `assets/seed/content.db` is still not declared in
  `pubspec.yaml`, which lists only `assets/seed/v1.json`, and `SeedInstaller` still
  has no callers outside its own test. Nothing installs the bundled database, so
  blueprints and mock papers cannot reach the app at all. Small job, unblocks the
  mock specs and half the Progress tab.
- **Tag all 1,117 questions with a `lessonId`.** Gates the reader coda, lesson
  selection in the practice picker, and the Lesson level of the Progress table.

## 4. Content and engine

- **Template quiz engine for Mathematics and Science**, which also produces the
  step-by-step explanations Pro sells. With zero Mathematics questions, `MockSampler`
  cannot assemble a complete mock paper, and the Progress tab's pace-per-question
  column is mock-only, so it stays empty until mocks work.
  Chain: engine, then math questions, then complete mocks, then Progress shows pace.
- **Paywall consolidation.** The Free and Pro rule is currently decided in four
  places, Home, Quiz, Progress and the coming explanations, and they already
  disagree.

## 5. Open questions, put to Aedwon and not yet answered

- **Question identity under FSRS** for generated instances. If each instance mints a
  new id, nothing accumulates in `review_state_local` and the scheduler is blind; if
  the template is the id, instances of differing difficulty share one state. Must be
  decided before the generator is written.
- **`sectionalTiming` for ACET, DCAT and MSU-SASE.** Aedwon is asking around. Those
  three blueprints cannot be completed until he reports back. UPCAT, USTET, NMAT and
  CSE are researched.

## 6. Out of scope, deliberately

- **Community skins**, `specs/2026-07-31-community-skins-design.md`. Ideation
  complete, slated for post-launch.
- **Modern dark theme concept**, `specs/2026-08-01-modern-dark-theme-concept-design.md`.
  Not a replacement for Ink & Rule. Aedwon confirmed on 2 August that this is **one
  of the skins he is exploring for a later release**, so it belongs with the
  community skins work and does not compete with the shipped identity.
- Milestones, the best-subjects share card, per-topic decay and difficulty
  calibration, all deferred with reasons in Section "Deferred" of the Progress spec.

---

## Chosen next

**Onboarding**, decided 2 August.

## Done since this checkpoint was written

**Quiz tab, Plan 1 of 6: storage. Merged 2 August**, commit `a91fbdb`, cleanup in
`1c7c6de`. The flags table and its sync mapper, the mistake tag, the three-way ordering
value, and the nullable `lessonId`, `rationale` and `shortLabel` fields. Schema at 14.
Verified on merge: 963 tests pass, no analyzer issues outside `tool/`, format clean,
layering violations unchanged at 7 pre-existing.

**Four specs written and committed 2 August**, none of them yet planned:

- `specs/2026-08-02-onboarding-name-and-date-design.md`
- `specs/2026-08-02-custom-exam-track-design.md`
- `specs/2026-08-02-exam-switching-design.md`
- plus `future/2026-08-02-parent-child-pairing-and-consent.md`, captured not scheduled

All three specs share one decision log:
`decisions/2026-08-02-onboarding-name-and-date-log.md`.

## The plan queue, in dependency order

1. **Onboarding**, folded into `plans/2026-07-25-onboarding-polish.md` as new tasks so it
   is built in one pass rather than two.
2. **The custom exam track**, split in two:
   `plans/2026-08-02-custom-track-a-branch-and-scope.md` (6 tasks) and
   `plans/2026-08-02-custom-track-b-student-built-mock.md` (5 tasks). A depends on the
   onboarding plan; B depends on A and on Quiz plan 2c.
3. **Exam switching**, `plans/2026-08-02-exam-switching.md` (4 tasks), depends on the polish
   plan's Task 4.
4. **Quiz tab seams 2 to 6**: the tab, the picker, the reveal, the debrief, the review
   component. Seam 2 splits three ways: `plans/2026-08-02-quiz-tab-02a-frame-and-panel.md`
   (written), `plans/2026-08-02-quiz-tab-02b-session-panel.md` (nine tasks, depends on 2a),
   and `plans/2026-08-02-quiz-tab-02c-mock-panel-and-rows.md` (seven tasks, depends on 2a
   and 2b). **The whole tab is now planned**, all on 2 August and none executed:

   | Plan | Tasks |
   | --- | --- |
   | `2026-08-02-quiz-tab-02a-frame-and-panel.md` | 3 |
   | `2026-08-02-quiz-tab-02b-session-panel.md` | 9 |
   | `2026-08-02-quiz-tab-02c-mock-panel-and-rows.md` | 7 |
   | `2026-08-02-quiz-tab-03-practice-picker.md` | 8 |
   | `2026-08-02-quiz-tab-04-viewer-and-reveal.md` | 8 |
   | `2026-08-02-quiz-tab-05-debrief.md` | 4 |
   | `2026-08-02-quiz-tab-06-review-component.md` | 5 |

   Execute in that order. Each depends on the ones above it.

## Raised by 2b and awaiting Aedwon

- **`TodayInterleavedPicker` does not build the interleaved tail the spec describes.** It
  applies `RecencyFilter.noConsecutiveSameTopic` rather than "seven from the topic, three
  from elsewhere", and Section 5's "exclude anything answered in the last 7 days" is
  unbuilt too. Both flagged in plan 2b and deliberately not fixed there. Decide before
  seam 3.
- **Dead subtopic surface.** `SubtopicFilter` is fed all-null ids by both callers and can
  never match; `subtopicId` columns on `content_lessons`, `content_questions` and
  `quiz_sessions` are never assigned. Listed in the quiz decision log, 2 August.
- **Score bands are still a placeholder.** `ComputeResults.bandFor` falls back to 75% pass
  and 60% borderline, which the 17 May mock spec calls a stand-in until per-exam
  `scoreBands` load from Sanity, and the `exams` table has no column for them. Plan 2c
  prints no band so it does not depend on this, but the mock results screen already shows
  one. Settle before the mock UI plans.

## Live defects found while planning, fixed inside the plans

- **Pro subscribers serve the free mock cooldown.** `mockEntitlementProvider` is hardcoded
  to `proIsActive: false`. Plan 2c Task 4.
- **Today's session ignores every selector** and is the first N questions of the exam in
  seed order. Plan 2b Tasks 4 and 5.
- **Reopening a half-finished session starts a second one** and strands the answers already
  given, because nothing calls `ResumeSession`. Plan 2b Task 6.
- **Drills return the same questions in the same order forever.** `DrillPicker` filters
  through `SubtopicFilter`, which both callers feed all-null ids, so it takes the head of
  the pool in table order. Plan 3 Task 7.
- **`QuestionCard` prints LaTeX literally and never grades.** It renders the stem through a
  plain `Text` (UI-005 to UI-007) and passes `AnswerRowState.plain` to every row, though
  `AnswerRow` has implemented all four graded states since the redesign. Plan 4 Task 2.
- **`quiz_results_page.dart` lists questions by raw `questionId`** and has had no entrance
  since the debrief replaced the session ending. Plan 6 Task 3.
- **The mock cooldown is per exam, which is an exploit.** A Free user switches exams, or
  makes a second custom track, and gets a fresh paper. `exam-switching` Task 2 makes it per
  student; custom track Plan B names it and leaves it there so it is fixed once.

## Owed by the plans, not yet built

- **Progress must consume the mistake tags.** Plan 5's debrief asks for them and writes
  `AttemptItem.mistakeTag`. The spec is explicit that three taps surfacing nowhere would be
  worse than never asking, so the Progress side is a commitment, not an option.
- **The content passes gate three surfaces.** Note B needs a rationale per choice; the
  debrief's miss rows and the review's rows want a short label per question; lesson selection
  in the picker wants the `lessonId` tagging. All three degrade honestly in the plans and all
  three close on content rather than on code.

## Decided without asking, reversible in one line

- **The picker's minutes unit is withheld until seven completed attempts exist**, applying
  the ruling Aedwon made twice on 2 August rather than reopening it. Plan 3, and
  `practicePaceProvider`. If he wants it always visible, say so.

## Lessons from the first background implementor run

Recorded because the next dispatch should not repeat them:

- It **wrote outside its worktree**, leaving a half-applied `app_database.dart` in the
  main checkout with `schemaVersion` bumped and no migrations. A broken state that
  compiles. Plan 1's Global Constraints now forbid this explicitly.
- Its final report **overstated the analyzer result**, claiming zero new issues when
  there were nine. Verify the gates rather than relaying them.
- The plan itself told it to commit `.g.dart` files, which this repo gitignores. Corrected
  in place so the remaining plans do not inherit it.
