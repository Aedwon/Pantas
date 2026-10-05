# L2 W4c: Study and reader

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main b52757bf.
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2.
Traceability: 86 rows with workstream `W4c` (30 boards, 56 other items).

## 1. Purpose and scope

Rebuild the Study map (search, Last opened, Bookmarks, subjects and topics), the lesson reader
(bar, title strip, progress line, contents, figures, end, pull to the next lesson, endings), and
Bookmarks, as the Study page draws them.

Out of scope: In-lesson quiz screens (W4d; this family owns only the entry button and the lesson-scoped question set), Home's day context data (W4b passes it).

## 2. Inputs

Boards (30): ST_Map, ST_MapEmpty, ST_TopicOpen, ST_Pinned, ST_Search, ST_NoMatch, RD_RealScroll, RD_Real, RD_Figure, RD_Resume, RD_Contents, RD_Plan, RD_End, RD_TopicDone, RD_TopicShort, RD_DayDone, ST_Loading, ST_Error, ST_NoLessons, ST_NoExam, RD_Error, RD_ImageFail, RD_DayEnd, BM_MarkTeal, BM_Open, BM_Order, BM_Edit, BM_One, BM_Empty, BM_ScreenReader.

Other traceability rows (56): D-117, D-118, D-119, D-120, D-121, D-122, D-123, D-124, D-128, D-129, D-130, D-131, D-132, D-133, D-134, D-135, D-137, D-138, D-139, D-140, D-141, D-142, D-145, D-146, D-147, D-148, D-149, D-150, D-151, S0-16, S0-30, S0-41, G-c-2, G-c-3, G-c-4, G-c-5, G-c-6, G-c-7, G-c-8, G-c-9, G-c-10, G-c-11, G-c-12, G-c-13, G-c-14, G-c-15, G-c-16, G-c-19, G-c-20, G-c-23, G-c-24, G-c-25, G-c-26, G-d-4, G-h-15, G-h-30.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior.

## 3. Contracts

Owned (routes and screen-local state only; nothing shared):
- `/study` root (W1) with optional `?topicId=`; `/lesson/:lessonId` with `from` (`study`, `home`,
  or the screen it came from) and the day context from Home; `/study/ending/:topicId` reached from
  the pull.
- Open-topic memory per exam; bookmark order and sort per exam.

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W0 lesson id contract (lesson quiz); W4b day context.

## 4. Behavior

- Map per D-117 to D-125 and D-140 to D-141: no counts on subjects and topics, ring per topic,
  read lessons as a plain check, Today tag, one topic open at a time with the pinned bar, Resume
  where you left off, Last opened hidden until a lesson was opened (S0-41).
- Search per D-124: matches lessons and topic names (S0-41); empty query with no recents shows
  nothing (G-c-3).
- Reader per D-127 to D-139: Geist text, Source Serif 4 math, bar layout by origin, title strip and
  progress line (across the day from Home), contents sheet, figures with credit and full screen,
  code-drawn figures and tables framed the same (S0-41), skipped described-but-missing figures,
  read on reaching the end after 15 seconds (G-c-8), "Quiz yourself, 5 questions" scoped to the
  lesson, pull to the next lesson with a tappable circle, endings plates, finished day.
- Next lesson means the next in topic order, read or not; the last topic of the exam shows its
  plate with no pull; the back label names the screen it returns to (G-c-11 to G-c-13).
- Quick quiz only behind "Try a Quick Quiz" on ST_NoLessons (S0-16).
- Bookmarks per D-145 to D-151, free for all; no bookmark ribbon on topics and no notes (S0-30).
- States per D-142 and W4h patterns.

## 5. Motion

Boards ST_Pinned, ST_Search, RD_RealScroll, RD_Plan, RD_Figure, RD_End, RD_TopicDone, RD_DayEnd, BM_MarkTeal, BM_Open, BM_Order, BM_Edit animate.
Run `python3 docs/design/tools/timeline.py docs/design/boards/<Board>.html` for every animated board
and build from the tap, start to last change; reduce motion shows the last frame.

## 6. Acceptance

- Every board listed below matches 1:1 at rest, in each drawn state, in light mode; dark mode uses
  W1 tokens. Motion matches `docs/design/tools/timeline.py` output for each animated board.
- Widget tests for each screen state listed in section 4, including reduce motion (last frame) and
  large text without overflow; unit tests for every rule in section 4.
- Old screens, routes and widgets this family replaces are deleted; no dead route remains.
- Full required checks on the integrated family (SUBAGENTS Part 5).
- Aedwon: visual check on his phones against the boards (Android, and iPhone per S0-49).

## 7. Risks and stop conditions

- A board contradicts this plan, the amendment spec or the decision record: stop; the lead decides
  and records it before code changes (README: "ask instead of guessing").
- A figure with no measured or published source: stop (AGENTS.md), except the recorded placeholders.
- A needed shared component or contract is missing from W1, W2 or W3: stop; do not build a local copy.
- A schema change is needed: stop; W0 owns the data layer and needs an amendment first.
- Copy differs from the board: the board wins (README rule 1); report any board without copy.
- Lesson authoring order is not set in content yet (D-143); "next" uses the current corpus order and the level 3 plan names it.

## 8. Files and directories

`lib/features/lesson/`, its routes, `lib/core/ui/figures/` (frame only), tests.

## 9. Order and parallelism

After W2. Parallel with other families; shares the reader with W4b only through the route contract.
