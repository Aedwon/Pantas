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

## In flight

**Quiz tab, Plan 1 of 6.** The spec ends by stating it is too large for one plan and
names six seams in dependency order: content and storage, the tab, the picker, the
reveal, the debrief, the review component. Plan 1, the storage layer, is written to
`plans/2026-08-02-quiz-tab-01-storage-and-content-fields.md`. Plans 2 to 6 are not
written yet. Aedwon's intent is to have a background implementor execute each plan while
design work continues in the foreground.
