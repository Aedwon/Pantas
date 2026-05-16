# Selected Exam Dashboard Phase 1 Design Spec

**Date:** 2026-05-15  
**Status:** Revised after product clarification  
**Sub-project:** Assessment sub-project 2, expanded to selected-exam dashboard phase 1  
**Mockup:** `docs/superpowers/mockups/assessment-home-study-plan/index.html`

---

## Goal

Turn the app shell into a selected-exam experience and replace the `/home` stub with the first real dashboard module: an assessment-driven study plan for the user’s selected exam. The app should feel simple: the user chooses an exam during onboarding, then Home, Study, and Quiz are all tailored to that exam until they deliberately switch in More/Settings.

## Product Direction

The long-term Home tab is an exam dashboard. It should eventually show streak, due reviews, weekly quiz performance, lesson progress, and Pro dynamic profile recommendations. This sub-project implements only Dashboard Phase 1:

- selected exam context;
- assessment-not-taken prompt;
- assessment-based study plan after completion;
- shell alignment so Home, Study, and Quiz all operate inside selected exam focus.

Do not add future dashboard cards, “coming soon” modules, dynamic Pro recommendations, reassessment, streak, weekly quiz performance, or lesson progress summaries in this sub-project.

## Locked UX Decisions

- First launch onboarding is expected to select the exam focus. Full onboarding UI is a follow-up unless implemented elsewhere.
- Selected exam focus is app-level context, not a Home-only concern.
- Home, Study, and Quiz are scoped to the selected exam.
- Exam switching lives in More/Settings only.
- Bottom nav becomes four tabs: `Home | Study | Quiz | More`.
- Rename `/learn` to `/study` while development is still early.
- Use a floating bottom nav style.
- Use a clean large dashboard header for Home, not the existing blue main-tab header.
- Home Phase 1 has no search.
- Future dashboard modules are omitted until they work.
- Before assessment, Home shows a focused hero card with a diagnostic/find-weak-spots illustration placeholder.
- The final illustration asset will be provided later; implementation should reserve layout space and use a local placeholder asset first.
- Before assessment, primary CTA is `Start assessment`; secondary CTA is `Quiz for now`.
- After assessment, Home shows `Assessment last taken on {date}` and `Your study plan`.
- Completed Home shows top 3 topics from the assessment result.
- Each topic row has one adaptive action: weak/moderate topics use `Study`; strong topics use `Quiz`.
- First topic row has minimal emphasis only through position and primary action weight. No left accent and no `Start here` label.
- Topic row metadata is percent only, e.g. `33%`.
- `View full results` remains a text link.

## Navigation

Bottom tabs:

```text
Home   Study   Quiz   More
```

Routes:

```text
/home
/study
/study/topic/:topicId?examId=:examId
/quiz
/quiz/quick/:examId
/assessment/:examId
/assessment/:examId/results
/more
```

Implementation may preserve existing secondary routes if needed during migration, but user-facing app navigation should use `/study`.

Home CTA behavior:

- `Start assessment` -> `/assessment/:selectedExamId`
- `Quiz for now` -> `/quiz/quick/:selectedExamId`
- Topic row `Study` -> `/study/topic/:topicId?examId=:selectedExamId`
- Topic row `Quiz` -> `/quiz/quick/:selectedExamId?topicId=:topicId`
- `View full results` -> `/assessment/:selectedExamId/results`
- Missing exam focus `Choose exam` -> `/onboarding`

## Selected Exam Focus

The selected exam is persisted locally. The implementation should use the existing Drift-centered local-first architecture rather than in-memory state.

Resolution rules:

1. If selected exam id exists and matches an active local exam, use it.
2. If selected exam id is missing and exactly one active exam exists, use that exam as a defensive fallback.
3. If selected exam id is missing and multiple active exams exist, show the choose-exam fallback.
4. If selected exam id points to an exam that no longer exists, show the choose-exam fallback.

The Home header displays the selected exam name as context. It is not a switcher.

## Home States

### Missing Exam Focus

Defensive state only.

Content:

```text
Home
Choose exam

Choose your exam
Pick the exam you are reviewing for.

[Choose exam]
```

Route: `/onboarding`.

### Assessment Not Taken

Use a focused hero card.

Content:

```text
Home
Civil Service Exam

Build your study plan
Take the assessment to find what to study first.

[Start assessment]
[Quiz for now]
```

Visual:

- diagnostic/find-weak-spots illustration placeholder inside the card;
- no `Assessment not taken` badge;
- no long explanation bullets;
- no search;
- no future cards.

### Assessment Complete: Weak or Moderate Topics

Content:

```text
Home
Civil Service Exam

Assessment last taken on May 12, 2026
Your study plan

Vocabulary              0%    [Study]
Grammar                 33%   [Study]
Reading                 40%   [Study]

View full results
```

Rules:

- Top 3 topics come from `AssessmentResultsLocal`, sorted weakest-first.
- Weak/moderate rows use `Study`.
- First row action is primary; subsequent row actions are quieter.
- Percent only in each row.
- No mastery label or badge in rows.

### Assessment Complete: All Strong

Content:

```text
Home
UPCAT

Assessment last taken on May 12, 2026
Keep sharp

Algebra                 78%   [Quiz]
Geometry                82%   [Quiz]
Biology                 85%   [Quiz]

View full results
```

Rules:

- If all recommended topics are strong, use `Keep sharp`.
- Strong rows use `Quiz`.
- Keep the same compact row structure.

## Study Tab

Study replaces Learn as the user-facing concept.

Phase 1 behavior:

- Study shows only selected-exam subjects/topics.
- It should not list all exams.
- Topic tap routes to `/study/topic/:topicId?examId=:selectedExamId`.
- If selected exam focus is missing, show the same choose-exam fallback pattern.

Existing lesson list and lesson page behavior should be preserved, but route names and copy should use Study.

## Quiz Tab

Quiz becomes a bottom tab.

Phase 1 behavior:

- Quiz shows selected-exam quiz entry only.
- It should not list all exams.
- Primary action can start quick quiz for selected exam.
- Existing quiz nudge behavior may remain if still relevant, but it must not force all-exam selection.
- If selected exam focus is missing, show choose-exam fallback.

## Visual Design

Direction:

- clean, modern, iOS-like, low text density;
- avoid over-explaining;
- one obvious next action per visible module;
- floating 4-tab nav;
- dashboard header with `Home` and selected exam subtitle;
- no blue Home app bar for this dashboard;
- use app tokens where possible, but Home is allowed to revise the earlier main-tab-header rule.

The mockup is a decision artifact, not final production UI. Flutter implementation should use existing theme tokens and components where they fit, and add small shell/dashboard components only where needed.

## Data Source

Assessment recommendations come only from `AssessmentResultsLocal`.

For this sub-project:

- Do not infer weak topics from quiz attempts.
- Do not infer weak topics from lesson progress.
- Do not build Pro dynamic profile.
- Do not add reassessment.

## Testing Strategy

Tests should cover:

- selected exam focus resolution;
- `/home` no longer renders a stub;
- four-tab shell labels and navigation;
- `/learn` user-facing route replaced by `/study`;
- Study tab filters to selected exam;
- Quiz tab filters to selected exam;
- no-assessment Home hero state;
- completed weak/moderate study plan rows and adaptive actions;
- all-strong `Keep sharp` rows and adaptive actions;
- Home CTA routes;
- missing focus fallback.

## Acceptance Criteria

- Main shell has `Home | Study | Quiz | More`.
- Home, Study, and Quiz are selected-exam scoped.
- `/home` renders a selected-exam dashboard Phase 1 module, not a placeholder.
- `/study` replaces `/learn` in user-facing navigation and CTAs.
- Home no-assessment state is simple, visual, and assessment-first.
- Home completed state shows top 3 assessment-derived topics with one action per row.
- Future dashboard modules are not shown.
- No Pro dynamic profile, reassessment, streak, weekly quiz performance, or lesson progress dashboard is implemented.

## Self-Review

- No placeholder requirements.
- Scope is broader than the original Home-only draft and explicitly includes shell, Study, and Quiz scoping.
- Long-term dashboard vision is documented without implementing future modules.
- The spec avoids low-level storage details except where needed for product behavior.
