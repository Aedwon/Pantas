# Loading skeletons r1

Rule: decision log "2026-10-30 Returning-visitor splash (B5) and loading skeletons". Policy read from origin/main. Board followed where one exists: L_PlanSlow (Home wide), L_ProgressSlow (Tendencies wide), L_DebriefSlow (debrief).

Shared parts: `lib/core/ui/components/skeleton.dart` (SkeletonPulse: 300ms delay, pulse, still under reduced motion, nested pulses defer; SkeletonBlock, SkeletonCard, SkeletonSurface, SkeletonSection, SkeletonGroup(s), SkeletonQuestionPage, SkeletonResultsPage, WebSkeletonEyebrow). `LoadingShapes` now sits on it and stays as the generic fallback.

## Inventory (screen, tiers, result)

Fixed, compared against the loaded widget in `test/core/ui/skeleton_layout_test.dart` (390 and 1440, light and dark):
- Home phone (page, masthead, Today, performance, More about you): was one generic 3-line block. Now mirrors week card, greeting, Today, performance, More. Compared.
- Home wide: already matched L_PlanSlow; rebuilt on shared blocks, now also used for page-level loading. Compared to board heights 66/330/96/520.
- Your record phone and wide: wide wrongly reused the Tendencies board. Now its own two-column skeleton (9 cards). Compared.
- Your tendencies phone and wide: wide follows L_ProgressSlow (112 + 4x180). Compared to board.
- Your plan phone and wide: generic block before. Now Today, Coming up, History; wide uses the 13:10 split. Compared (phone heights, wide split).

Fixed, built from the loaded code, not compared by test (listed as gaps):
Performance phone/wide, Topic detail, plan day/week/history, Study map phone and wide, Last opened, Bookmarks, Quiz tab (page, Today, Today rows, More ways, Mock panel, sheet; phone and wide), What's included, practice picker, flagged list, search results (phone and web), lesson contents, bookmarks sheet, topic ending, lesson reader, mock setup (phone/wide), mock/quiz/assessment question screens, mock review, mock/quiz/assessment results (phone), preparation page, exam picker (phone, settings, wide), custom track subjects, debrief (wide, rebuilt on shared blocks).

Left generic on purpose: app bootstrap and deferred route (no known layout), onboarding progress, finishing and exam-date steps (transitional), Wrapped (deferred, not built).

## Known mismatches left
- Conditional blocks (Last opened, performance for users with no answers, Pro-only tendency layout) cannot be known while loading; the skeleton draws the common case.
- Row counts for Coming up and subject lists use a typical count.
- Tests assert section count, height within 12 percent or 14px, and width. The remaining screens are unverified against loaded fixtures.
