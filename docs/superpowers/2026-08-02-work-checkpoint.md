# Work checkpoint, 2 August 2026

A snapshot of what is outstanding, taken before the onboarding pass begins. Every
claim below was checked against the tree on this date, not carried over from an
earlier note. When an item is finished, strike it here and say what closed it.

**Repo state on this date:** `content/static-question-pipeline` has been merged;
`main` is 2 commits ahead of it and is the trunk again. Both branches still exist.

---

## 1. The five design specs, and where each one stands

**Updated 2 August, evening.** The Quiz tab is now planned end to end. The other four are
not, and they are not all blocked by the same thing.

| Spec | Date | Design status | Plan status |
| --- | --- | --- | --- |
| Home and navigation | 07-26 | ~~Weakest areas superseded~~ **Closed 2 August.** Reopened, redesigned as "Practice", spec amended | None yet. Now plannable |
| Study tab and reader | 07-27 | Approved, closed | **6 plans, 37 tasks.** Written 2 August, none executed |
| Quiz tab | 07-28 | Approved, closed | **7 plans, 44 tasks.** See the queue below |
| Mock exam UI | 07-28 | **Partial.** The paper and the endings are still open design | None, and a plan is premature: it needs a design round, not a planning round |
| Progress tab | 07-30 | Approved | None. Plan it **last**, see the dependency map |

**Updated 2 August, late.** Study is now planned end to end, so **no spec is left that can be
planned as written**. Home needs one section reopened as design, the mock UI needs its design
finished, and Progress consumes decisions from both.

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
- **The assessment writes no attempt row.** Added 2 August, found while redesigning
  Home's Practice panel. `CompleteAssessment` writes `assessment_results_local` and
  seeds FSRS, and never inserts into `attempts_local`. So every metrics signal and
  the whole Progress Performance table are blind to the assessment's 21 questions,
  and Home's new live panel would be empty the moment after the assessment. Fix is a
  new `SessionOrigin.assessment` plus the row. **Its hazard is part of the fix:**
  `MetricAttemptItem.responseMs` is required and the assessment captures no timing,
  so the speed signals must exclude that origin until it does, or
  `PerQuestionSpeedSignal` reads 21 answers at zero milliseconds and Progress's
  "answered too fast" count inherits it.

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

**Onboarding**, decided 2 August. Design then moved through the Quiz tab instead, and by the
evening of 2 August every plan in the queue below was written. Nothing has been executed.

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

## The plan queue

**Superseded 2 August, evening.** The order below replaces the earlier one, which said
onboarding, then custom track, then exam switching, then the Quiz seams.

**That order was wrong and it is worth saying why**, because it was written before the plans
existed and the plans revealed the dependency. **Custom track Plan A depends on Quiz plans 2b
and 3**: its Task 5 lifts the topic index out of `practice_picker_page.dart`, which Quiz 3
creates, and its Task 6 rewrites `today_providers.dart` and `practice_picker_providers.dart`,
which Quiz 2b and Quiz 3 create. Executed in the old order, three of its six tasks have
nothing to modify.

### Execution order

| # | Plan | Tasks | Waits on |
| --- | --- | --- | --- |
| 1 | `2026-08-02-content-seed-delivery.md` | see file | nothing. Unblocks mocks and half of Progress |
| 2 | `2026-07-25-onboarding-polish.md` | 13 | nothing |
| 3 | `2026-08-02-onboarding-flow-and-new-steps.md` | 10 | 2, interleaved. Read its "How this plan interleaves" section |
| 4 | `2026-08-02-exam-switching.md` | 4 | 2, for the Settings → Exam page its Task 4 builds |
| 5 | `2026-08-02-quiz-tab-02a-frame-and-panel.md` | 3 | quiz-tab-01, merged |
| 6 | `2026-08-02-quiz-tab-02b-session-panel.md` | 9 | 5 |
| 7 | `2026-08-02-quiz-tab-02c-mock-panel-and-rows.md` | 7 | 5, 6 |
| 8 | `2026-08-02-quiz-tab-03-practice-picker.md` | 8 | 5 |
| 9 | `2026-08-02-quiz-tab-04-viewer-and-reveal.md` | 8 | 8 |
| 10 | `2026-08-02-quiz-tab-05-debrief.md` | 4 | 9 |
| 11 | `2026-08-02-quiz-tab-06-review-component.md` | 5 | 7, 9, 10 |
| 12 | `2026-08-02-custom-track-a-branch-and-scope.md` | 6 | 3, 6, 8 |
| 13 | `2026-08-02-custom-track-b-student-built-mock.md` | 5 | 7, 12 |

**Steps 1 to 4 and 5 to 11 are independent of each other** and could run in parallel by two
people. 12 and 13 need both threads finished.

### The Study thread, added 2 August, late

A **third** independent thread. It touches `lib/features/lesson/`, `core/storage`'s lesson
tables and three kit components, and shares nothing with the queue above except
`InkTableRow` and `InkCheckbox`.

| # | Plan | Tasks | Waits on |
| --- | --- | --- | --- |
| S1 | `2026-08-02-study-01-foundations.md` | 7 | nothing |
| S2 | `2026-08-02-study-02-map.md` | 8 | S1 |
| S3a | `2026-08-02-study-03a-bookmarks.md` | 7 | S1, S2 |
| S3b | `2026-08-02-study-03b-search.md` | 5 | S1, S2 |
| S4 | `2026-08-02-study-04-reader.md` | 6 | S1, S2, S3a |
| S5 | `2026-08-02-study-05-endings.md` | 4 | S4 |

S3a and S3b are independent of each other; everything else is a chain.

**Two collisions to watch if the threads run in parallel:**

- **`InkTableRow`** is changed by S1 Task 7 (reserved gutter, chevron slot, `active` stops
  drawing `○`) and again by S3a Task 3 (a `leadingMeta` slot). Quiz 2c and the Home spec read
  the same component.
- **`InkCheckbox`** is now named by **four** plans and built by none specifically: Quiz 3,
  Quiz 5, custom track A and Study 3a. Whichever runs first promotes it.

## The dependency map

Three kinds of dependency run through this work and they behave differently. Content
dependencies degrade; code dependencies break.

### Content, which the plans already degrade around

| Content pass | Gates | What happens without it |
| --- | --- | --- |
| `lessonId` on all 1,117 questions | the reader coda, lesson selection in the picker, the Lesson level of Progress | The picker shows no carets, the coda hands every lesson in a topic the same five questions |
| A rationale per choice | note B on the reveal and in the review, the debrief's "slipped" second sentence | The note is simply absent, which is the drawn appearance for Free anyway |
| A short label per question | the debrief's miss rows, the review's rows | They fall back to the stem clamped to two lines, through the renderer |
| Seed delivery, `content.db` | every blueprint and every mock paper | No mock can run at all, except a custom track's, whose blueprint is local |
| Mathematics questions, via the template engine | complete mock papers | `MockSampler` cannot fill a paper, so Progress's pace column stays empty |

**None of these block writing a plan and none block executing one.** Every plan that touches
them says what it renders in their absence.

### Shared components, which one plan builds and several read

| Component | Built by | Read by |
| --- | --- | --- |
| `RuledPanel` | Quiz 2a | Quiz 2b, 2c, and the Home spec's panel device |
| `StatsBand` gaining `centred` and `compact` | Quiz 2b | Quiz 2c, and Home's stats band |
| `InkCheckbox`, promoted out of the picker | **Quiz 3 or Quiz 5 or custom track A**, whichever runs first | all three |
| `TopicScopeIndex`, lifted out of the picker | custom track A | the picker itself, and Settings |
| `PennantMark` | Quiz 4 | Quiz 6, the mock's grid and its review |
| `QuestionGridSheet` | Quiz 4 | the mock paper, at six columns |
| `AnswerReveal` | Quiz 4, in `core/ui` | Quiz 6, and the mock review through it |

**`InkCheckbox` is named in three plans and built by none of them specifically.** Whichever
runs first promotes it; the other two say to check first. Watch for two of them being written
in parallel.

### Tabs

- **Home** needs nothing from the others to be planned. Its Weakest areas hole was
  closed on 2 August; the panel is now "Practice" and the spec is amended.
- **Study** needs nothing. Its dependencies are the two content passes above, and both
  degrade.
- **Progress** is downstream of almost everything: the onboarding name and date (Home spec
  Section 2), the mistake tags Quiz 5 commits to producing, the carry-over filter from exam
  switching, and mocks working for its pace column.
- **The mock UI** waits on the Quiz grid and flag, which Quiz 4 now specifies, and on the
  score-band question below.

## Path for the remaining plans, recommended

Writing plans, not executing them.

1. ~~**Study tab and reader.**~~ **Done 2 August**, as six plans rather than the two guessed
   here: foundations, the map, bookmarks, search, the reader, the endings. The guess was
   wrong because it was made before the spec's own "note on plan size" was re-read, and that
   note names five seams. Bookmarks and search then split, because together they were twelve
   tasks across two unrelated review surfaces. Decisions in
   `decisions/2026-08-02-study-tab-planning-log.md`.
2. ~~**Home's Weakest areas, as design.**~~ **Done 2 August.** The section is now
   "Practice": live topic accuracy from attempts rather than the frozen assessment result,
   rows starting a topic session in one tap, "See all" to Progress, figures free as the
   table's teaser. Spec Section 3 rewritten plus a new Section 8; Progress Section 7 gains
   the reciprocal exception. Decisions in `decisions/2026-08-02-home-weakest-areas-log.md`.
   **It exposed two prerequisites**, both listed in Section 3 below.
3. **Home and navigation.** Now unblocked. It reads `RuledPanel` and the centred `StatsBand`
   from the Quiz plans, so its plan should be written after those exist, which they now do.
4. **The mock exam UI, as design first.** The paper and the endings are still open. Settle
   the score bands question below in the same pass, since a results screen cannot print a
   band it has no threshold for.
5. **Progress tab.** Last, deliberately. It consumes the Weakest areas decision from 2, the
   mistake tags from Quiz 5, the carry-over filter from exam switching, and the mock pace
   column from 4 plus the content engine.

**Revised again 2 August, late.** Study is done and Home is now unblocked. **The mock UI
still needs a design round** and Progress should still wait for the others' decisions.

## Found while planning Study, and owed elsewhere

- **`content-seed-delivery` Task 1 asserts the wrong SQLite header.** It expects
  `'SQLite format 3 '` with a trailing space; the real 16-byte magic ends in a NUL. Verified
  with `xxd` against `assets/seed/content.db`. The test as written fails at offset 15. Fix it
  before executing that plan.
- **Four live call sites reach `/study/topic/:topicId`.** The Study spec says they are gone
  with the Home redesign, which is unimplemented. `assessment_home_tab.dart:209` and `:238`,
  `assessment_results_page.dart:122` and `:203`. Study Plan 2 Task 8 repoints all four; until
  it runs, that route must not be deleted.
- **Home's "Keep going" affordance is now load-bearing.** Study Plan 5's day line, "That's
  enough for today.", depends on Home still making a real offer, or the app is sending
  someone to bed. A note for whoever plans Home.
- **The reader cannot draw its plan counter.** The study plan's providers throw, so Study
  Plan 4 builds the Study composition only and reserves the second value. When plans become
  real, the counter and the ticked rail drop into the shapes left for them.

## Raised by 2b and awaiting Aedwon

- **`TodayInterleavedPicker` does not build the interleaved tail the spec describes.** It
  applies `RecencyFilter.noConsecutiveSameTopic` rather than "seven from the topic, three
  from elsewhere", and Section 5's "exclude anything answered in the last 7 days" is
  unbuilt too. Both flagged in plan 2b and deliberately not fixed there. Decide before
  seam 3.
- **A topic-scoped session loses its topic under the default ordering.** Added 2 August
  from the Home round, which now depends on this call.
  `start_today_session.dart:89` writes the session's `topicId` only when ordering is
  `blocked`, and null otherwise. Passing a `topicId` also narrows the pool to that one
  topic, so `TodayInterleavedPicker` interleaves it with itself. Home's Practice rows and
  the picker both hit this. Belongs to the Quiz thread, beside the tail item above.
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
