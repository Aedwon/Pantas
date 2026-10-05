# New design: traceability table

Strategy B3 step 4. Every input item maps to exactly one owning workstream here; level 2 fills the
section column and level 3 the task column. The gate reviews check this table.

Built October 6, 2026 by the scheduled resume run (lead). Policy revision: origin/main 2d983cfb.
Inputs: `docs/design/SCREENS.md` (286 boards), `docs/design/DECISIONS.md` (every bullet, by line),
the restart log, the amendment spec, and `stage0-decisions.md` items 1 to 51.

## How to read it

- **ID.** `B-` board, `D-<line>` a DECISIONS.md bullet at that line, `R-` restart log decision,
  `A-` amendment spec item not covered elsewhere, `S0-` stage 0 item, `G-` gap pass section B row.
- **Workstream.** Per strategy B2 and amendment spec B4. `none` means no build work: done, record,
  canvas only, out of program, content track, or a program rule that every plan applies and the
  gates check.
- **Status.** `assigned` means it is built as drawn or written. `discard` rows still own the removal
  of existing code. `superseded` names what replaces it. A note after "assigned" is a constraint the
  owning level 2 plan must carry.
- Board ownership follows the screen family of its SCREENS.md section. Loading boards go to the
  family whose flow they draw; `L_Rules` and the loading tiers go to W2. Dark mode boards go to W1,
  which owns the dark values; each family still matches them on its screens.

## Notes for level 2

- W2's component list gains the subject, topic and lesson picker (D-221: "any place that picks
  subjects, topics or lessons reuses it"), used by Customize your own (W4d) and What's included (W4f).
  Strategy B2 lists W2's components as examples ("15 to 20"), so this is not a level 1 change.
- Cross-family patterns with one owner: notice strip and button order (W2, D-67, D-68), loading,
  error and empty patterns (W4h, S0-33, S0-34), Pro tag and Free/Pro rule (W2, D-231, S0-3).
  Every family consumes them; the gate checks that no family redefines them.
- Duplicates point at one another (D-182 and D-169, S0-24 and R-18, A-B3b and S0-28) and share one
  level 3 task.

## Table

| ID | Item | Source | Workstream | Level 2 section | Level 3 task | Status |
|---|---|---|---|---|---|---|
| B-O_Flow | O_Flow: The whole flow, start to Home | SCREENS.md, Onboarding › Start to Home | W4a |  |  | assigned |
| B-O_Launch | O_Launch: 1 · Launch to Welcome | SCREENS.md, Onboarding › Getting started | W4a |  |  | assigned |
| B-O_Age | O_Age: 2 · Age check (and under 13) | SCREENS.md, Onboarding › Getting started | W4a |  |  | assigned |
| B-O_Consent | O_Consent: 3 · Terms and Privacy | SCREENS.md, Onboarding › Getting started | W4a |  |  | assigned |
| B-O_Picker | O_Picker: 4 · Exam picker (can't load, loading, list) | SCREENS.md, Onboarding › Getting started | W4a |  |  | assigned |
| B-O_Custom | O_Custom: 4b · My exam isn't listed (also when the list is empty) | SCREENS.md, Onboarding › Getting started | W4a |  |  | assigned |
| B-O_DateKnown | O_DateKnown: 5 · Exam date (known date, or month then day) | SCREENS.md, Onboarding › Your exam date and study days | W4a |  |  | assigned |
| B-O_DateChange | O_DateChange: 5b · Exam date: changing your mind | SCREENS.md, Onboarding › Your exam date and study days | W4a |  |  | assigned |
| B-O_DateToday | O_DateToday: 5c · Exam date: when the month has started | SCREENS.md, Onboarding › Your exam date and study days | W4a |  |  | assigned |
| B-O_Days | O_Days: 6 · Study days (and an exam too soon) | SCREENS.md, Onboarding › Your exam date and study days | W4a |  |  | assigned |
| B-O_Name | O_Name: 7 · Your name | SCREENS.md, Onboarding › Finishing up | W4a |  |  | assigned |
| B-O_Notify | O_Notify: 8 · Reminders, then the system dialog | SCREENS.md, Onboarding › Finishing up | W4a |  |  | assigned; copy per amendment spec Part A (drop "Nothing else.") and ST_Reminders_v2/O_Notify_v2 |
| B-O_SignIn | O_SignIn: Later · Signing in from Settings | SCREENS.md, Onboarding › Finishing up | W4f |  |  | assigned |
| B-HP_Free | HP_Free: Home · Free | SCREENS.md, Home › Home, Free and Pro | W4b |  |  | assigned |
| B-HP_Pro | HP_Pro: Home · Pro | SCREENS.md, Home › Home, Free and Pro | W4b |  |  | assigned |
| B-HP_Day | HP_Day: The day: start, progress, done, advance | SCREENS.md, Home › The day | W4b |  |  | assigned |
| B-HP_NoDate | HP_NoDate: Notice · No exam date | SCREENS.md, Home › Notices · thin strip under the week | W4b |  |  | assigned |
| B-HP_MonthOnly | HP_MonthOnly: Notice · Month only: pick the day | SCREENS.md, Home › Notices · thin strip under the week | W4b |  |  | assigned |
| B-HP_Trial | HP_Trial: Notice · Pro trial ending | SCREENS.md, Home › Notices · thin strip under the week | W4b |  |  | assigned |
| B-HP_ProWelcome | HP_ProWelcome: Notice · Welcome to Pro (once) | SCREENS.md, Home › Notices · thin strip under the week | W4b |  |  | assigned |
| B-HE_BeforeAssessment | HE_BeforeAssessment: Before the assessment | SCREENS.md, Home › States · Today itself changes | W4b |  |  | assigned |
| B-HP_ExamDay | HP_ExamDay: Exam day | SCREENS.md, Home › States · Today itself changes | W4b |  |  | assigned |
| B-HP_ExamPassed | HP_ExamPassed: 5 · Exam date passed | SCREENS.md, Home › States · Today itself changes | W4b |  |  | assigned |
| B-HP_NoContent | HP_NoContent: No lessons for this exam yet | SCREENS.md, Home › States · Today itself changes | W4b |  |  | assigned |
| B-HE_ManyLessons | HE_ManyLessons: Every row opens: lessons, reviews, new questions | SCREENS.md, Home › Busy days | W4b |  |  | assigned |
| B-HE_BackAfterBreak | HE_BackAfterBreak: Back after missed days | SCREENS.md, Home › Busy days | W4b |  |  | assigned |
| B-HE_MockDay | HE_MockDay: Mock day: the mock leads | SCREENS.md, Home › Busy days | W4b |  |  | assigned |
| B-HE_Everything | HE_Everything: Mock day, after a break, lots of lessons | SCREENS.md, Home › Busy days | W4b |  |  | assigned |
| B-HE_NothingDue | HE_NothingDue: 4 · Nothing due: everything covered | SCREENS.md, Home › Empty days | W4b |  |  | assigned |
| B-HE_NothingDueReview | HE_NothingDueReview: 3 · Nothing due: review-only stretch | SCREENS.md, Home › Empty days | W4b |  |  | assigned |
| B-HE_DayOff | HE_DayOff: 2 · Day off (advance only if it adds something) | SCREENS.md, Home › Empty days | W4b |  |  | assigned |
| B-HE_ReviewWeek | HE_ReviewWeek: 1 · Today done, review-only stretch (no advance) | SCREENS.md, Home › Empty days | W4b |  |  | assigned |
| B-HE_LastDay | HE_LastDay: 1 · Today done, last study day (no advance) | SCREENS.md, Home › Empty days | W4b |  |  | assigned |
| B-HE_Resume | HE_Resume: A lesson left halfway | SCREENS.md, Home › Mid-day and skipped mocks | W4b |  |  | assigned |
| B-HE_CarryOver | HE_CarryOver: Unfinished items carried into today | SCREENS.md, Home › Mid-day and skipped mocks | W4b |  |  | assigned |
| B-HE_AdvanceAgain | HE_AdvanceAgain: Finished tomorrow's too: advance again | SCREENS.md, Home › Mid-day and skipped mocks | W4b |  |  | assigned |
| B-HE_MockMoved | HE_MockMoved: Skipped mock: moved to the next study day | SCREENS.md, Home › Mid-day and skipped mocks | W4b |  |  | assigned |
| B-HE_MockDropped | HE_MockDropped: Skipped mock: moved, even to the day before the exam | SCREENS.md, Home › Mid-day and skipped mocks | W4b |  |  | assigned |
| B-HE_LongTitle | HE_LongTitle: Long lesson titles truncate to one line | SCREENS.md, Home › Mid-day and skipped mocks | W4b |  |  | assigned |
| B-DP_PlanA | DP_PlanA: Your plan · Pro | SCREENS.md, Home › View full plan | W4b |  |  | assigned |
| B-DP_History | DP_History: History · open an entry, See more | SCREENS.md, Home › View full plan | W4b |  |  | assigned |
| B-DP_HistoryEnd | DP_HistoryEnd: History · the end | SCREENS.md, Home › View full plan | W4b |  |  | assigned |
| B-DP_PlanFree | DP_PlanFree: Your plan · Free | SCREENS.md, Home › View full plan | W4b |  |  | assigned |
| B-DP_Error | DP_Error: Your plan · could not load | SCREENS.md, Home › View full plan | W4b |  |  | assigned |
| B-DP_Drill | DP_Drill: Plan → week → day | SCREENS.md, Home › A week, then a day | W4b |  |  | assigned |
| B-DP_Week | DP_Week: A week (Sunday first) | SCREENS.md, Home › A week, then a day | W4b |  |  | assigned |
| B-DP_WeekCustom | DP_WeekCustom: A week, fewer study days | SCREENS.md, Home › A week, then a day | W4b |  |  | assigned |
| B-DP_Day | DP_Day: A day (same as Today on Home) | SCREENS.md, Home › A week, then a day | W4b |  |  | assigned |
| B-DP_DayRead | DP_DayRead: A day: read a lesson early | SCREENS.md, Home › A week, then a day | W4b |  |  | assigned |
| B-DP_DayPast | DP_DayPast: A past day (from the week strip) | SCREENS.md, Home › A week, then a day | W4b |  |  | assigned |
| B-DT_TopicsA | DT_TopicsA: Subjects view · Pro | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_TopicsView | DT_TopicsView: Topics view · Pro | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_LessonsView | DT_LessonsView: Lessons view · Pro | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_SortFlow | DT_SortFlow: Sorting: one button, three states | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_FilterFlow | DT_FilterFlow: Pick a subject | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_SubjectTap | DT_SubjectTap: Tap a subject (Pro) | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_SubjectTapFree | DT_SubjectTapFree: Tap a subject (Free) | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_Topic | DT_Topic: A topic opened · Pro | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_Free | DT_Free: Your performance · Free | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-DT_Error | DT_Error: Your performance · could not load | SCREENS.md, Home › Your performance | W4b |  |  | assigned |
| B-YR_Full | YR_Full: Your record · six weeks in, two mocks | SCREENS.md, Home › Your record | W4b |  |  | assigned |
| B-YR_RestDay | YR_RestDay: Your record · streak crossed a rest day: no "since" date | SCREENS.md, Home › Your record | W4b |  |  | assigned |
| B-YR_FirstWeek | YR_FirstWeek: Your record · first week: no mocks, no line yet | SCREENS.md, Home › Your record | W4b |  |  | assigned |
| B-YO_Pro | YO_Pro: Your tendencies · Pro | SCREENS.md, Home › Your tendencies | W4b |  |  | assigned |
| B-YO_ProNew | YO_ProNew: Your tendencies · Pro, first week (nothing clear yet) | SCREENS.md, Home › Your tendencies | W4b |  |  | assigned |
| B-YO_Free | YO_Free: Your tendencies · Free | SCREENS.md, Home › Your tendencies | W4b |  |  | assigned |
| B-YO_Error | YO_Error: Your tendencies · could not load | SCREENS.md, Home › Your tendencies | W4b |  |  | assigned |
| B-YO3_Profiles | YO3_Profiles: Profile card · all 12 labels | SCREENS.md, Home › Reference · profile card and tendency pictures | W4b |  |  | assigned |
| B-YO4_Picks | YO4_Picks: Tendency pictures · clear, and before it's clear | SCREENS.md, Home › Reference · profile card and tendency pictures | W4b |  |  | assigned |
| B-ST_Map | ST_Map: Study · the map (Free and Pro alike) | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-ST_MapEmpty | ST_MapEmpty: Study · the map, no bookmarks yet | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-ST_TopicOpen | ST_TopicOpen: Study · tap a topic: its lessons open in place | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-ST_Pinned | ST_Pinned: Study · an open topic pins to the top as you scroll; tap it to close | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-ST_Search | ST_Search: Study · search: recent lessons, then results as you type | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-ST_NoMatch | ST_NoMatch: Study · search, nothing matched | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_RealScroll | RD_RealScroll: Reader · the top of a real lesson: the title moves into the strip over the first 90px, the rail follows the lesson | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_Real | RD_Real: Reader · a real lesson from the corpus, full length (Layers of the Earth and Composition) | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_Figure | RD_Figure: Reader · tap an illustration: full screen, pinch to read the labels, close | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_Resume | RD_Resume: Reader · Resume opens the lesson where you left off | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_Contents | RD_Contents: Reader from Study · the contents button opens the topic’s lessons | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_Plan | RD_Plan: Reader from Home · “2 of 2” opens today’s lessons; the rail spans the day | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_End | RD_End: Reader · the end: it counts as read on its own; keep pulling up until the circle fills, let go for the next lesson | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_TopicDone | RD_TopicDone: Ending · a finished topic: the plate; keep pulling up for the next topic | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_TopicShort | RD_TopicShort: Ending · a topic stopped short: the plate, the unread lessons, pull up for the next topic | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-RD_DayDone | RD_DayDone: Ending · a finished day: one line, back to Home | SCREENS.md, Study › Study | W4c |  |  | assigned |
| B-ST_Loading | ST_Loading: Study · loading, only if slow (shapes pulse) | SCREENS.md, Study › Study and reader · states | W4c |  |  | assigned |
| B-ST_Error | ST_Error: Study · could not load | SCREENS.md, Study › Study and reader · states | W4c |  |  | assigned |
| B-ST_NoLessons | ST_NoLessons: Study · no lessons on the device yet | SCREENS.md, Study › Study and reader · states | W4c |  |  | assigned |
| B-ST_NoExam | ST_NoExam: Study · no exam chosen | SCREENS.md, Study › Study and reader · states | W4c |  |  | assigned |
| B-RD_Error | RD_Error: Reader · could not load the lesson | SCREENS.md, Study › Study and reader · states | W4c |  |  | assigned |
| B-RD_ImageFail | RD_ImageFail: Reader · an illustration fails to load (the frame keeps its place) | SCREENS.md, Study › Study and reader · states | W4c |  |  | assigned |
| B-RD_DayEnd | RD_DayEnd: Reader from Home · the day’s last lesson: pull up to finish, it lands on “That’s enough for today.” | SCREENS.md, Study › Study and reader · states | W4c |  |  | assigned |
| B-BM_MarkTeal | BM_MarkTeal: Bookmark · grey icons at rest; bookmarking pops into teal like a check; tap again, it empties at once | SCREENS.md, Study › Bookmarks | W4c |  |  | assigned |
| B-BM_Open | BM_Open: Bookmarks · See all opens the sheet (Recent first); tap outside to close | SCREENS.md, Study › Bookmarks | W4c |  |  | assigned |
| B-BM_Order | BM_Order: Bookmarks · Recent, Oldest, By subject, Custom (your hand order, kept whatever you switch to) | SCREENS.md, Study › Bookmarks | W4c |  |  | assigned |
| B-BM_Edit | BM_Edit: Bookmarks · Edit: the switch dims; select, Remove, Undo; drag a row and the switch moves to Custom (Reset order appears) | SCREENS.md, Study › Bookmarks | W4c |  |  | assigned |
| B-BM_One | BM_One: Bookmarks · only one: no sort switch, no grips | SCREENS.md, Study › Bookmarks | W4c |  |  | assigned |
| B-BM_Empty | BM_Empty: Bookmarks · everything removed: the empty sheet (Undo still offered) | SCREENS.md, Study › Bookmarks | W4c |  |  | assigned |
| B-BM_ScreenReader | BM_ScreenReader: Bookmarks · with a screen reader: in Edit, swipe down to “Move up”, double tap to move the row (no dragging) | SCREENS.md, Study › Bookmarks | W4c |  |  | assigned |
| B-QZ_Tab | QZ_Tab: Quiz · a normal day (Pro): Today's questions, the mock, more ways to practice | SCREENS.md, Quiz › Quiz tab | W4d |  |  | assigned |
| B-QZ_Free | QZ_Free: Quiz · Free: the mock is waiting out its 14 days | SCREENS.md, Quiz › Quiz tab | W4d |  |  | assigned |
| B-QZ_Resume | QZ_Resume: Quiz · a session left partway: Resume or discard; the mock and Customize your own wait until it's done | SCREENS.md, Quiz › Quiz tab | W4d |  |  | assigned |
| B-QZ_Done | QZ_Done: Quiz · today's questions done ("That's all for today.") | SCREENS.md, Quiz › Quiz tab | W4d |  |  | assigned |
| B-QZ_First | QZ_First: Quiz · before the assessment | SCREENS.md, Quiz › Quiz tab | W4d |  |  | assigned |
| B-QZ_Picker | QZ_Picker: Practice picker · tap a topic to pick it all, the caret to open its lessons; the floating bar keeps count | SCREENS.md, Quiz › Quiz tab | W4d |  |  | assigned |
| B-QZS_1 | QZS_1: Bottom panel 1 · a floating bar: what you picked, the size, Start | SCREENS.md, Quiz › Customize your own: the floating bar and How long? | W4d |  |  | assigned |
| B-QZS_1b | QZS_1b: How long · Questions per lesson: you set the questions, time follows; Algebra counts as its 5 lessons | SCREENS.md, Quiz › Customize your own: the floating bar and How long? | W4d |  |  | assigned |
| B-QZS_1c | QZS_1c: How long · Total time: you set the time, questions follow (split evenly by lesson) | SCREENS.md, Quiz › Customize your own: the floating bar and How long? | W4d |  |  | assigned |
| B-QZS_1d | QZS_1d: How long · Adjust: set the split by hand; Reset goes back to even | SCREENS.md, Quiz › Customize your own: the floating bar and How long? | W4d |  |  | assigned |
| B-QZE_Many | QZE_Many: Edge · 8 lessons: one row each; the list scrolls past four | SCREENS.md, Quiz › How long? · edge cases | W4d |  |  | assigned |
| B-QZE_ManyTime | QZE_ManyTime: Edge · 8 lessons on Total time: the rows show the uneven split | SCREENS.md, Quiz › How long? · edge cases | W4d |  |  | assigned |
| B-QZE_Short | QZE_Short: Edge · too little time for 8 lessons: times that can't give every lesson a question are struck out | SCREENS.md, Quiz › How long? · edge cases | W4d |  |  | assigned |
| B-QZE_RunsShort | QZE_RunsShort: Edge · a lesson has fewer questions than asked: its row shows what it has; the total drops | SCREENS.md, Quiz › How long? · edge cases | W4d |  |  | assigned |
| B-QZE_Long | QZE_Long: Edge · a very long quiz | SCREENS.md, Quiz › How long? · edge cases | W4d |  |  | assigned |
| B-QZE_One | QZE_One: Edge · one lesson | SCREENS.md, Quiz › How long? · edge cases | W4d |  |  | assigned |
| B-QZE_None | QZE_None: Edge · nothing picked: the bar asks for a pick; Start is off | SCREENS.md, Quiz › How long? · edge cases | W4d |  |  | assigned |
| B-QV_Answer | QV_Answer: Answering · tap a choice to pick it (you can change it); Check confirms; the bar turns green or red and Check becomes… | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_MissPro | QV_MissPro: A miss (Pro) · the bar turns light red; a note on the answer and one on what you picked | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_MissFree | QV_MissFree: A miss (Free) · the same, with the note on the answer only | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_Last | QV_Last: The last question · once checked, Next becomes Finish and opens the end of the session | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_Long | QV_Long: Long content · long choices wrap; the page always keeps room under the last one so the bar never covers it (shown scr… | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_Figure | QV_Figure: A question with a figure · the figure sits on a white card between the question and the choices | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_Flag | QV_Flag: Flag · in the bar, before or after answering; pops teal; the first time, a toast with Undo | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_Grid | QV_Grid: Questions sheet · where you are has a dark edge and a bold number. Tap 2: the sheet just closes and 2 opens read-only | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_GridBack | QV_GridBack: Questions sheet, while looking back at 2 · the dark edge sits on 2; its color stays | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_GridMock | QV_GridMock: The same sheet in a mock (later) · six across, by part; answered is gray, never right or wrong; flags shown | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_Leave | QV_Leave: Leaving · the X asks once; nothing is lost either way | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_EndPro | QV_EndPro: End of a session (Pro) · the half ring fills as your ten answers replay; tap any circle or mistake to open it | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_EndFree | QV_EndFree: End of a session (Free) · the same, without the notes invitation | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_EndPerfectB | QV_EndPerfectB: All ten right · the ring closes and the mistakes section simply isn't there | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_EndLowB | QV_EndLowB: Many mistakes · the first three, then "See all 8 mistakes" | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_EndLastToday | QV_EndLastToday: No session after this one (the last of the day, a lesson's quiz, your own quiz) · Done is the main button | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_All | QV_All: See all questions · every question in the order you answered it; each opens on its own | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QV_Sources | QV_Sources: Where a quiz starts · one set of screens; only the end screen's line and where Done returns change | SCREENS.md, Quiz › Quiz screens | W4d |  |  | assigned |
| B-QN_Wrong | QN_Wrong: Viewer bar, a wrong answer (Pro) · scroll freely; Add Note turns the bar into the choices; pick one, Add Note, back to a | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_WrongOpen | QN_WrongOpen: Viewer bar · the choices open: Add Note stays off until you pick one; Cancel closes it | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_Correct | QN_Correct: Viewer bar, a right answer · light green; no note icon, so the counter sits in the middle | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_WrongFree | QN_WrongFree: Viewer bar, a wrong answer (Free) · light red; no note icon, so the counter sits in the middle | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_EditNote | QN_EditNote: Changing a note · Noted opens the card on your note; Update stays off until you pick another; Remove clears it | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_OwnWords | QN_OwnWords: Type my own · a field opens under the choices and the keyboard lifts the card; saved as "Other" with your words | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_Report | QN_Report: Report · from the top right; the bar becomes a one-field form above the keyboard; Send; thanks in the bar; the icon stay | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_ReportOffline | QN_ReportOffline: Report with no connection · the same Send; the bar says it's saved and will send once you're online (no separate toast) | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_ReportAgain | QN_ReportAgain: Report again · the icon is teal, but tapping it opens the form as usual, with a line saying you reported it before | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-QN_ReportLimit | QN_ReportLimit: Report, daily limit reached · the form still opens but says why it can't send today; no keyboard | SCREENS.md, Quiz › Question viewer and the bottom bar | W4d |  |  | assigned |
| B-MK_Setup | MK_Setup: Before you start · a table of sections, items and time; how it runs as a note; strict mode as a switch (off) | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_SetupStrict | MK_SetupStrict: Before you start, strict mode on · the switch starts from your Settings and can be changed here | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_Paper | MK_Paper: Answering · clock centered, pause on the right, a time line under it; the part named above the question; ‹, grid, cou… | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_Proctor | MK_Proctor: The proctor · "10 minutes left in this subject." sits above the bar for 2.5 seconds with three short buzzes, then goes | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_FiveMin | MK_FiveMin: Under 5 minutes · the time bar and the clock turn amber; the proctor calls 10, 5 and 1 minutes left | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_LastMinute | MK_LastMinute: The last minute · the time bar and the clock turn red | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_Sheet | MK_Sheet: Questions sheet in a mock · this part only, six across; answered is gray, never right or wrong; flags show; the next… | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_LastQ | MK_LastQ: The last question of a part · the bar stays the same; tapping › asks whether to end the part | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_LastQStrict | MK_LastQStrict: The last question of a part, strict on · no pause; › is dimmed and a quiet line says why | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_EndEarly | MK_EndEarly: Ending a part early · › on the last question opens this; time left and blanks; the time doesn't carry over | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_BetweenA | MK_BetweenA: Time is up · the part's questions as shaded circles (blank ones stand out), then the parts with an arrow moving to th… | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_PauseA | MK_PauseA: Paused · the hourglass holds as much sand on top as there is time left in the part (here 21 of 75 min); it tips now a… | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_Discard | MK_Discard: Discarding · the only destructive step in the mock, so a red confirm | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_PartEnded | MK_PartEnded: A part ended early · the same screen, titled "Part 3 ended." | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_Forfeit | MK_Forfeit: Not finished (strict on, left the app) · the score still shows, with a calm line saying what happened; no comparison | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_PauseWarn | MK_PauseWarn: Before pausing · a warning with "Don't show this again"; once ticked, pause goes straight through | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_PauseFlow | MK_PauseFlow: Pause, animated · the warning first; then a big hourglass falls, stops, shrinks into place; Resume grows it, it falls… | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_Results | MK_Results: Your score · the half ring, performance breakdown, past results (only with earlier mocks), every question | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_Finale | MK_Finale: The end, for exams with no deduction · the score lands, the bars grow, a scroll down and Today joins Past results | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_FinaleUPCAT | MK_FinaleUPCAT: The end, UPCAT · right minus ¼ of each wrong: the reds drop into their own ball and strike after the green, taking ba… | SCREENS.md, Quiz › Mock exam screens | W4e |  |  | assigned |
| B-MK_ReviewWrong | MK_ReviewWrong: All questions · Wrong (opens first): wrong and blank by part; the number in red, no circle; Finish the Notes on top | SCREENS.md, Quiz › Mock exam · All questions | W4e |  |  | assigned |
| B-MK_ReviewAll | MK_ReviewAll: All questions · All: every question in order, by part; teal right, red wrong | SCREENS.md, Quiz › Mock exam · All questions | W4e |  |  | assigned |
| B-MK_ReviewFlagged | MK_ReviewFlagged: All questions · Flagged: the 12 you flagged during the mock, right or wrong; the offer to save them sits on top | SCREENS.md, Quiz › Mock exam · All questions | W4e |  |  | assigned |
| B-MK_ReviewQ | MK_ReviewQ: A row opened · the same viewer as quizzes: ‹ "30 of 79" ›, light red, the note icon (Pro); ‹ › move through the tab y… | SCREENS.md, Quiz › Mock exam · All questions | W4e |  |  | assigned |
| B-MK_ReviewQNote | MK_ReviewQNote: The note icon tapped · "Why did you miss it?", the same card as quizzes | SCREENS.md, Quiz › Mock exam · All questions | W4e |  |  | assigned |
| B-MK_ReviewBlank | MK_ReviewBlank: A blank one opened · no pick shown, only the right answer; the note card asks why you left it blank | SCREENS.md, Quiz › Mock exam · All questions | W4e |  |  | assigned |
| B-MK_SetupDCAT | MK_SetupDCAT: An exam the app can't fully include (DCAT) · the note under the table says what the mock leaves out | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_SetupCSE | MK_SetupCSE: One block (CSE Professional) · items per subject, no time per subject; counts are placeholders until sourced | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_SheetCSE | MK_SheetCSE: One block, the questions sheet · the whole paper in one grid, blanks as empty circles; Submit the Exam lives here | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_SubmitCSE | MK_SubmitCSE: One block, › on the last question · asks to submit; the time left and the blanks; nothing changes after | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_ReviewWrongFree | MK_ReviewWrongFree: All questions, Free · Wrong, without the notes prompt (notes are Pro); every question still opens with its answer and… | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_ReviewQFree | MK_ReviewQFree: A row opened, Free · the right answer and its explanation; no note icon, so the counter sits in the middle | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_ResultsFree | MK_ResultsFree: Your score, Free · the same screen; a quiet line under "See all 250 questions" says how long the questions stay open | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_PastFreeOpen | MK_PastFreeOpen: From your record, Free, before the next mock opens · the same screen; the questions still open, with the date they close | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_PastFreeLocked | MK_PastFreeLocked: From your record, Free, after the next mock opens · score and breakdown stay (your record); the questions need Pro | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-MK_PastPro | MK_PastPro: From your record, Pro · the whole results screen again, any time, with every question | SCREENS.md, Quiz › Mock exam · other exams and Free | W4e |  |  | assigned |
| B-ST_Root | ST_Root: Settings · the profile (account and backup) on top, Pro, four areas, About; values show what each is set to | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_Exam | ST_Exam: Your exam · exam, date and study days (Sunday first) on one screen, edited in place; carry over and topics with their… | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_ExamDate | ST_ExamDate: Exam date tapped · the date opens right in the list: exact day, month only, or I don't know | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_Practice | ST_Practice: Practice · session length (5, 10, 20, All; 10 by default), how sessions are built, strict mode; all in place | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_Reminders | ST_Reminders: Reminders · daily reminder with its time in place (shown only while on), and the follow-up | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_RemindersOff | ST_RemindersOff: Reminders, phone notifications blocked · "Notifications are off"; the row opens the phone's settings | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_Appearance | ST_Appearance: Appearance · light or dark by looking; text size slider; remember table order | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_Name | ST_Name: Name (from Account) · its own screen, no sheet; saved as you go back; clearing it removes the name | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_About | ST_About: About · version; legal; your data (with Shared links); send feedback opens the Pantas Facebook group (the row says so) | SCREENS.md, Settings › Settings | W4f |  |  | assigned |
| B-ST_Account | ST_Account: Account and backup, Free · name and sign-in; Pantas ID, tap to copy; backup says "This phone only" and how Pro adds i… | SCREENS.md, Settings › Settings · Pantas ID, tap to copy | W4f |  |  | assigned |
| B-ST_AccountIDCopied | ST_AccountIDCopied: Pantas ID tapped · the number is copied; the row says Copied with a check for 2 seconds, then the number comes back | SCREENS.md, Settings › Settings · Pantas ID, tap to copy | W4f |  |  | assigned |
| B-ST_AccountPro | ST_AccountPro: Account and backup, Pro · Pantas ID, tap to copy; the backup state up top (Saved), when it last ran, details behind a… | SCREENS.md, Settings › Settings · Pantas ID, tap to copy | W4f |  |  | assigned |
| B-ST_AccountOut | ST_AccountOut: Account, not signed in · the onboarding copy; one button to sign in; no Pantas ID until you sign in | SCREENS.md, Settings › Settings · Pantas ID, tap to copy | W4f |  |  | assigned |
| B-ST_ExamSwitch | ST_ExamSwitch: After picking another exam · UPCAT holds the green, CSE Professional is empty; no numbers; Count Them, or start your… | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_ExamSwitchCount | ST_ExamSwitchCount: Count Them tapped · everything else drops away; the green drains from UPCAT through the tube into CSE Professional; a… | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_Included | ST_Included: What's included · the same picker as Customize your own: subjects as headings, topics ticked, the caret opens lessons | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_IncludedOpen | ST_IncludedOpen: What's included, a topic opened · Circles unticked, so Geometry shows a dash; Trigonometry left out whole | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_ProFree | ST_ProFree: Pantas Pro, Student exams (UPCAT) · the hero, clean; Weekly ₱29, Monthly ₱99 with 7 days free, Yearly ₱799 | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_ProCSE | ST_ProCSE: Pantas Pro, Civil Service (CSE Professional) · Monthly ₱149 with 7 days free, or a ₱499 Season Pass; no weekly | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_ProCSEPass | ST_ProCSEPass: Season Pass picked · one payment; the line says when it ends and that it never renews | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_ProNCE | ST_ProNCE: Pantas Pro, PSHS-NCE · a Season Pass only (₱1,499); no subscription, so no trial | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_ProPro | ST_ProPro: Pantas Pro, Pro · the same hero says thanks; your plan and renewal; Manage in Google Play | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_ProRestoreOffline | ST_ProRestoreOffline: Restore purchases with no connection · a short note at the bottom; nothing else changes | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_SignOut | ST_SignOut: Sign Out tapped · a short confirm; Free is told progress stays on this phone (Pro: it's backed up) | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_DeleteAccount | ST_DeleteAccount: Delete account · what goes, each with a red struck-through icon; a line when a subscription is active; Delete My Data… | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_BackupDetails | ST_BackupDetails: Backup details (Pro) · a plain list: when, what's waiting, since when, which phone; Back Up Now under it | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_BackupNow | ST_BackupNow: Back Up Now tapped · the status turns to Backing up with a spinner; the button rests until it's done, then Saved and… | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_BackupNowOffline | ST_BackupNowOffline: Back Up Now with no connection · dimmed, with one line saying why | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_Privacy | ST_Privacy: Privacy policy · a plain reading page in the app with the date it changed; Terms of service looks the same | SCREENS.md, Settings › Settings · the other screens | W4f |  |  | assigned |
| B-ST_RootNoName | ST_RootNoName: No name · the card says "Add your name" with the plain person; tapping it goes to Account | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_RootSignedOut | ST_RootSignedOut: Not signed in · the card reads "Not signed in"; tapping it goes to Account to sign in | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_RootPro | ST_RootPro: Pro · Pantas Pro shows the plan ("Yearly"); during the trial it reads "Trial, 3 days left" | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_RootTrial | ST_RootTrial: Pro trial ending · the value counts the days left; nothing else changes | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_ProLapsed | ST_ProLapsed: Pro ended · Pantas Pro says when, that nothing was lost, and offers the plans again (no trial a second time) | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_ExamMonth | ST_ExamMonth: Exam date, month only · the wheel loses the day; the row reads "November 2026" | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_ExamUnknown | ST_ExamUnknown: Exam date, I don't know · no wheel; the row reads "Not set" | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_ExamPassed | ST_ExamPassed: Exam date has passed · the date turns red and the note asks for the next one | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_ExamCustom | ST_ExamCustom: Your own track · the Exam row shows the track's name | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_DaysLast | ST_DaysLast: Turning off the last study day · it won't go: the circle shakes and a short line says why | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_RemindersOffSwitch | ST_RemindersOffSwitch: Daily reminder turned off · the time row goes; Follow up dims, since it needs the daily reminder | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_BackupStates | ST_BackupStates: Backup, every other state (Pro) · backing up, offline, couldn't back up (Try Again), not signed in | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_AccountOffline | ST_AccountOffline: Offline · signing in and restoring purchases wait for a connection; every other row still works and syncs later | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_LargeText | ST_LargeText: Largest text size · rows grow taller and the value moves under the label instead of being cut off | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_DarkRoot | ST_DarkRoot: Dark mode · the same screen; black background, dark gray groups, a slightly brighter teal | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_DarkPractice | ST_DarkPractice: Dark mode · Practice, to see the controls (segments, checklist, switch) on dark | SCREENS.md, Settings › Settings · every state and edge case | W4f |  |  | assigned |
| B-ST_ExamPick | ST_ExamPick: The exam picker from Settings · exams not out yet are gray with "Coming soon" and can't be tapped; tapping a live one… | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_SwitchUpgrade | ST_SwitchUpgrade: Pro (student exams) picks CSE Professional · its plans as an upgrade, no trial; or switch and use CSE Professional on… | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_SwitchPassWarn | ST_SwitchPassWarn: Season Pass holder picks another exam · warned before it happens: the pass stays with its exam; the new one is on Free | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_PassEnded | ST_PassEnded: Season Pass ended (after the exam) · says when and that nothing was lost; taking it again: a new pass to the next pub… | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_IncludedLast | ST_IncludedLast: Unticking the last topic · it won't go: the box shakes and a short line says why (like the last study day) | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_AccountIDWait | ST_AccountIDWait: Pantas ID not made yet · signed in, but offline since: "Not ready yet"; it fills in once online | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_RestoreDone | ST_RestoreDone: Restore purchases, found · the page turns into the Pro page with a short note | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_RestoreNone | ST_RestoreNone: Restore purchases, nothing found · a short note; the plans stay | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_ProPassHave | ST_ProPassHave: Pro on a Season Pass · Plan, Exam, Ends (no Renews, nothing to manage in Google Play) | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_PassNoDate | ST_PassNoDate: No published date yet (between exams) · the Season Pass can't be bought and says why; Monthly still can | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_ProNCENoDate | ST_ProNCENoDate: PSHS-NCE with no published date · its only plan waits; the button is off | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_PassSoon | ST_PassSoon: Buying a pass days before the exam · the card says how long it really lasts (Ends in 5 days), so nobody is surprised | SCREENS.md, Settings › Settings · more edge cases: paid exams, passes, coming soon | W4f |  |  | assigned |
| B-ST_ProLET | ST_ProLET: Pantas Pro, Licensure (LET, PNLE and later PRC exams) · Monthly ₱249 with 7 days free, or a ₱1,499 Season Pass to the… | SCREENS.md, Settings › Settings · Pro pages for the other exam groups | W4f |  |  | assigned |
| B-ST_ProPMA | ST_ProPMA: Pantas Pro, academy exams (PMA, PNPA, PMMA, MAAP) · the student plans, plus a ₱299 Season Pass as a wide card under them | SCREENS.md, Settings › Settings · Pro pages for the other exam groups | W4f |  |  | assigned |
| B-ST_ProPMAPass | ST_ProPMAPass: Academy exam, Season Pass picked · Buy Season Pass; the line says when it ends | SCREENS.md, Settings › Settings · Pro pages for the other exam groups | W4f |  |  | assigned |
| B-ST_Avatars | ST_Avatars: The profile picture · Google photo first; else the first letter; an emoji stays an emoji; no letter at all gives a pl… | SCREENS.md, Settings › Settings · the profile picture | W4f |  |  | assigned |
| B-IC_Final | IC_Final: The icon set (approved 4 Oct) · Phosphor regular, with nine of ours kept at the same weight | SCREENS.md, Icons › The icon set | W1 |  |  | assigned |
| B-L_Rules | L_Rules: Loading rules | SCREENS.md, Loading › Loading | W2 |  |  | assigned |
| B-L_Restore | L_Restore: Restoring progress after sign-in | SCREENS.md, Loading › Steps: long or can't be undone | W4f |  |  | assigned |
| B-L_Delete | L_Delete: Deleting the account | SCREENS.md, Loading › Steps: long or can't be undone | W4f |  |  | assigned |
| B-L_MockStart | L_MockStart: Starting a mock: setting out the paper | SCREENS.md, Loading › Steps: long or can't be undone | W4e |  |  | assigned |
| B-L_Purchase | L_Purchase: Purchase: confirming after Google Play | SCREENS.md, Loading › On the button: one wait, one action | W4f |  |  | assigned |
| B-L_RestorePurchase | L_RestorePurchase: Restoring a purchase (Settings) | SCREENS.md, Loading › On the button: one wait, one action | W4f |  |  | assigned |
| B-L_SignIn | L_SignIn: Signing in with Google | SCREENS.md, Loading › On the button: one wait, one action | W4f |  |  | assigned |
| B-L_Share | L_Share: Creating a Wrapped share link | SCREENS.md, Loading › On the button: one wait, one action | W4g |  |  | assigned |
| B-L_PlanSlow | L_PlanSlow: First plan of the day (only if slow) | SCREENS.md, Loading › Brief, only if slow (past 300 ms) | W4b |  |  | assigned |
| B-L_ProgressSlow | L_ProgressSlow: Figures from your history (only if slow) | SCREENS.md, Loading › Brief, only if slow (past 300 ms) | W4b |  |  | assigned |
| B-L_DebriefSlow | L_DebriefSlow: Session debrief and results (only if slow) | SCREENS.md, Loading › Brief, only if slow (past 300 ms) | W4d |  |  | assigned |
| B-L_ChangeExam2 | L_ChangeExam2: Changing exam, polished (current) | SCREENS.md, Loading › Brief, only if slow (past 300 ms) | W4f |  |  | assigned; carry-over choice per stage 0 #1 (wait and date-kept screen kept) |
| B-AS_Question | AS_Question: Assessment · the same question screen; no flag, no Check: pick and Next; answers show at the end | SCREENS.md, Redesign › The assessment | W4d |  |  | assigned |
| B-AS_Picked | AS_Picked: Assessment, a choice picked · Next turns on; you can change your pick until you tap it | SCREENS.md, Redesign › The assessment | W4d |  |  | assigned |
| B-AS_Leave | AS_Leave: Leaving the assessment · the X asks once; leaving loses this attempt, so Leave is red | SCREENS.md, Redesign › The assessment | W4d |  |  | assigned |
| B-AS_Results | AS_Results: Assessment results (once) · the ring fills, subjects weakest first, where the plan starts; then Home takes over | SCREENS.md, Redesign › The assessment | W4d |  |  | assigned |
| B-CM_Setup | CM_Setup: Your own mock (custom track) · how many questions and how long; each opens in place, like Settings | SCREENS.md, Redesign › Your own mock, for a custom track | W4e |  |  | assigned |
| B-CM_Wheel | CM_Wheel: Questions tapped · the wheel opens in the list (10 to 240, in fives) | SCREENS.md, Redesign › Your own mock, for a custom track | W4e |  |  | assigned |
| B-CM_Breakdown | CM_Breakdown: The section breakdown open · one row per subject (items and minutes); the totals stop being editable and add up the s… | SCREENS.md, Redesign › Your own mock, for a custom track | W4e |  |  | assigned |
| B-CM_Ceiling | CM_Ceiling: More questions than your subjects hold · the number stays, in red; Tick More Subjects opens What's included; Save waits | SCREENS.md, Redesign › Your own mock, for a custom track | W4e |  |  | assigned |
| B-SY_Error | SY_Error: Something went wrong · replaces the red error screen; one line in the app's voice; Try Again | SCREENS.md, Redesign › Errors and updates | W4h |  |  | assigned |
| B-SY_Update | SY_Update: Update required · the one screen nobody can close: one line, one button to Google Play (if the check can't run, the a… | SCREENS.md, Redesign › Errors and updates | W4h |  |  | assigned |
| B-WR_Mock | WR_Mock: Wrapped · after a first mock or a new best: score, pace, strongest part, subjects, then the label (5 slides) | SCREENS.md, Redesign › Wrapped · four moments, each a row of slides | W4g |  |  | assigned |
| B-WR_Streak | WR_Streak: Wrapped · a streak of 7, 30, 100 or 365 days: the count, every day kept, your best day, when you study (by the hour),… | SCREENS.md, Redesign › Wrapped · four moments, each a row of slides | W4g |  |  | assigned |
| B-WR_Topic | WR_Topic: Wrapped · a topic turns from weak to strong: which one, then and now, how long it took, how far you've come | SCREENS.md, Redesign › Wrapped · four moments, each a row of slides | W4g |  |  | dropped: restart log handoff decision 3 (no topic moment); do not build |
| B-WR_Exam | WR_Exam: Wrapped · the day after the exam (once per prep): totals, strongest week, who you were, your prep in one line | SCREENS.md, Redesign › Wrapped · four moments, each a row of slides | W4g |  |  | assigned |
| B-WR_Share | WR_Share: Share tapped · its own screen: the exact image that goes out, three switches (all off), a line saying the link is pub… | SCREENS.md, Redesign › Wrapped · sharing | W4g |  |  | assigned |
| B-WR_ShareExam | WR_ShareExam: A switch on · the image updates as you flip it ("UPCAT" appears) | SCREENS.md, Redesign › Wrapped · sharing | W4g |  |  | assigned |
| B-WR_ShareOffline | WR_ShareOffline: Share with no connection · Share rests; the offline line from the network spec | SCREENS.md, Redesign › Wrapped · sharing | W4g |  |  | assigned |
| B-WR_Links | WR_Links: Shared links (About › Your data) · each image you shared, when, and its link; Remove takes it down | SCREENS.md, Redesign › Wrapped · shared links, in About › Your data | W4g |  |  | assigned |
| B-WR_LinkRemove | WR_LinkRemove: Remove tapped · a short confirm | SCREENS.md, Redesign › Wrapped · shared links, in About › Your data | W4g |  |  | assigned |
| B-WR_LinksEmpty | WR_LinksEmpty: Shared links, none yet · one line | SCREENS.md, Redesign › Wrapped · shared links, in About › Your data | W4g |  |  | assigned |
| B-ST_ProPending | ST_ProPending: Payment pending (GCash, over the counter) · the plans step aside for one card: what you picked and how to finish; not… | SCREENS.md, Redesign › Last gaps: payment pending, subscribing offline, Pro's Wrapped history, the service message | W4f |  |  | assigned |
| B-ST_ProSubOffline | ST_ProSubOffline: Subscribing with no connection · the same short note as Restore; nothing else changes | SCREENS.md, Redesign › Last gaps: payment pending, subscribing offline, Pro's Wrapped history, the service message | W4f |  |  | assigned |
| B-WR_History | WR_History: Your Wrapped (Pro, from Your record) · every Wrapped you've had, newest first; tap one to watch it again or share it | SCREENS.md, Redesign › Last gaps: payment pending, subscribing offline, Pro's Wrapped history, the service message | W4g |  |  | assigned; omit the drawn "turned strong" row (restart log handoff decision 3) |
| B-YR_Wrapped | YR_Wrapped: Your record, Pro · a last row: Your Wrapped, with how many so far | SCREENS.md, Redesign › Last gaps: payment pending, subscribing offline, Pro's Wrapped history, the service message | W4b |  |  | assigned |
| B-YR_WrappedFree | YR_WrappedFree: Your record, Free · the same row with the small Pro tag (Free sees each Wrapped only when it happens) | SCREENS.md, Redesign › Last gaps: payment pending, subscribing offline, Pro's Wrapped history, the service message | W4b |  |  | assigned |
| B-HP_Service | HP_Service: Notice · a service message (set remotely): one line, a close button, nothing to open | SCREENS.md, Redesign › Last gaps: payment pending, subscribing offline, Pro's Wrapped history, the service message | W4b |  |  | assigned |
| B-DK_Home | DK_Home: Dark · Home (Pro) | SCREENS.md, Redesign › Dark mode on the main screens | W1 |  |  | assigned |
| B-DK_Quiz | DK_Quiz: Dark · the Quiz tab | SCREENS.md, Redesign › Dark mode on the main screens | W1 |  |  | assigned |
| B-DK_Study | DK_Study: Dark · the Study map | SCREENS.md, Redesign › Dark mode on the main screens | W1 |  |  | assigned |
| B-DK_Reader | DK_Reader: Dark · the lesson reader (a long, real lesson) | SCREENS.md, Redesign › Dark mode on the main screens | W1 |  |  | assigned |
| B-DK_Miss | DK_Miss: Dark · a miss, with the light red bar | SCREENS.md, Redesign › Dark mode on the main screens | W1 |  |  | assigned |
| B-DK_MockEnd | DK_MockEnd: Dark · the end of a mock | SCREENS.md, Redesign › Dark mode on the main screens | W1 |  |  | assigned |
| B-ST_Reminders_v2 | ST_Reminders_v2: Settings Reminders with Follow up time row and Exam countdown switch | amendment spec, visual companion (docs/design/proposals/reminders-2026-10-05.html) | W4f |  |  | assigned; supersedes the reminders parts of ST_Reminders/O_Notify |
| B-O_Notify_v2 | O_Notify_v2: Onboarding reminders with the amended copy | amendment spec, visual companion (docs/design/proposals/reminders-2026-10-05.html) | W4a |  |  | assigned; supersedes the reminders parts of ST_Reminders/O_Notify |
| D-5 | Direction B "Clarity": Apple principles, no liquid glass. Geist everywhere; Source Serif 4 only for math in lessons. Tint #0B7A68, one ac... | DECISIONS.md:5 (Preamble) | W1 |  |  | assigned; board-drawing notes in this paragraph are canvas only |
| D-7 | Tabs: Home, Study, Quiz, Settings (gear). Progress is merged into Home. Settings is a tab (no back button). | DECISIONS.md:7 (Navigation) | W1 |  |  | assigned |
| D-9 | Top: compact week calendar Sun to Sat, today centered, then "... UPCAT 11 NOV 42 days". No person button at the top. | DECISIONS.md:9 (Home) | W4b |  |  | assigned |
| D-10 | Day marks: done = dot; partly done = half dot; missed = plain date, no dot; day off = grey date; today = progress ring around the circle;... | DECISIONS.md:10 (Home) | W4b |  |  | assigned |
| D-11 | Greeting, then Today checklist. When today is done: "I Want to Advance"; tapping collapses today and shows "From tomorrow" items. | DECISIONS.md:11 (Home) | W4b |  |  | assigned |
| D-12 | How you're doing: half ring overall accuracy (rounded ends, no "x right of y" caption), then subject accuracy rows. Free: "Topics and les... | DECISIONS.md:12 (Home) | W4b |  |  | assigned |
| D-13 | "Needs practice" (weakest topics) is the same screen as See All sorted weakest first; it is not on Home. | DECISIONS.md:13 (Home) | W4b |  |  | assigned |
| D-14 | Then rows: Your Record, Your Tendencies, How You Work. | DECISIONS.md:14 (Home) | W4b |  |  | assigned |
| D-15 | Overall accuracy counts every finished session: daily plan sessions, picker practice and drills, retakes, lesson quizzes, the assessment... | DECISIONS.md:15 (Home) | W4b |  |  | assigned |
| D-17 | Onboarding step after exam date; nothing preselected; at least one day to continue. Settings "Study Days" row opens a sheet. Engine alrea... | DECISIONS.md:17 (Study days) | W4a |  |  | assigned (onboarding step); the Settings sheet is superseded by line 208 (no sheets) |
| D-19 | Opens with "Checking 170 answers", then the half ring (same as Home) with the % as hero (69.4%), "118 of 170 right" under it. | DECISIONS.md:19 (Mock score) | W4e |  |  | assigned |
| D-20 | No pass line anywhere. Sentence compares with the last mock (app keeps earlier mock scores). | DECISIONS.md:20 (Mock score) | W4e |  |  | superseded by stage 0 #2 (no comparison sentence) |
| D-21 | Subject rows quiet grey bars, plain % text; teal only on the overall ring. | DECISIONS.md:21 (Mock score) | W4e |  |  | assigned |
| D-22 | Confetti only for a new best mock ("Your best mock yet"). Assumption: the first mock has nothing to beat, so no pill. | DECISIONS.md:22 (Mock score) | W4e |  |  | superseded by stage 0 #2 (no confetti, no best-mock pill) |
| D-23 | B_MockResults (static, Redesign page) still shows the old layout; replace with this when we get there. | DECISIONS.md:23 (Mock score) | W4e |  |  | superseded: build the 3 Oct MK results boards, not B_MockResults |
| D-25 | Confirm sheet: everything carries over (all data). Button does the waiting. Then a confirmation screen with the exam date kept and "Chang... | DECISIONS.md:25 (Change exam) | W4f |  |  | partly superseded by stage 0 #1 (student chooses Count Them or Start My Numbers Fresh) |
| D-27 | Three tiers: steps (long or irreversible), on the button (single wait), placeholders only if slower than 300 ms. Never fake waits. | DECISIONS.md:27 (Loading) | W2 |  |  | assigned |
| D-29 | Exam picker grouped: College entrance / Civil service / Licensure / Uniformed services; licensure and uniformed marked "Soon". | DECISIONS.md:29 (Other) | W4a |  |  | assigned |
| D-30 | Exam date step (APPROVED): prefilled "Is this your exam day?" card when the exam date is known; otherwise month first (year header, past... | DECISIONS.md:30 (Other) | W4a |  |  | assigned |
| D-31 | No-day note: "No day yet? We'll plan from 1 <Month> and ask later." If that month has already started: "...plan from today and ask later.... | DECISIONS.md:31 (Other) | W4a |  |  | assigned |
| D-32 | Logo: tassel in original position, app colors. Welcome: "Welcome to Pantas" + "Your personal review companion for Philippine exams." One... | DECISIONS.md:32 (Other) | W4a |  |  | assigned |
| D-34 | Exam today: allowed; goes to the exam-day screen. Under a week away: allowed, one calm line ("We'll focus on what matters most."). | DECISIONS.md:34 (Exam date edge rules) | W4a |  |  | assigned |
| D-35 | Last day of a month / 31 Dec: rows that are fully past are hidden; past days greyed; today marked "Today". | DECISIONS.md:35 (Exam date edge rules) | W4a |  |  | assigned |
| D-36 | No year limit (approved). Leap years: Feb 2028 has 29. | DECISIONS.md:36 (Exam date edge rules) | W4a |  |  | assigned |
| D-37 | Switching month always clears the day. Coming back to the step restores year, month and day as left. | DECISIONS.md:37 (Exam date edge rules) | W4a |  |  | assigned |
| D-38 | Prefilled date already passed: skip the "Is this your exam day?" card, open the picker. | DECISIONS.md:38 (Exam date edge rules) | W4a |  |  | assigned |
| D-39 | Study days must include at least one day before the exam; otherwise Continue is off and the card says which days to add. | DECISIONS.md:39 (Exam date edge rules) | W4a |  |  | assigned |
| D-40 | Multi-day exams: ask for the first day. Large text: day chips grow taller, never clip. | DECISIONS.md:40 (Exam date edge rules) | W4a |  |  | assigned |
| D-42 | Launch -> Welcome (Get Started only) -> Age (wheel; under 13 blocked) -> Terms and Privacy (usage data first, terms last enables Continue... | DECISIONS.md:42 (Onboarding) | W4a |  |  | assigned |
| D-43 | Sign-in is later, from Settings. Progress bar counts 6 steps. | DECISIONS.md:43 (Onboarding) | W4a |  |  | assigned |
| D-44 | Later: a guided first-run demo, after the other screens are final. | DECISIONS.md:44 (Onboarding) | W4a |  |  | out of program: idea for later (guided first-run demo) |
| D-46 | Boards: HP_Free, HP_Pro (full length), HP_Day (pure CSS timeline: start, progress, done, I Want to Advance), and date/account situations:... | DECISIONS.md:46 (Home page) | W4b |  |  | assigned |
| D-48 | Home: above the advance prompt, a line "That's all for today." | DECISIONS.md:48 (Home page) | W4b |  |  | assigned |
| D-49 | Today checklist: items in progress show a progress ring (like today's circle in the week), which becomes the check when finished. | DECISIONS.md:49 (Home page) | W4b |  |  | assigned |
| D-50 | Advancing: allowed again and again (after finishing tomorrow's items, the offer returns). | DECISIONS.md:50 (Home page) | W4b |  |  | assigned |
| D-51 | Free has no cap on Today; Free and Pro Today look the same. | DECISIONS.md:51 (Home page) | W4b |  |  | assigned |
| D-52 | Skipped mock (APPROVED, corrected): always moves to the next study day, with no cutoff, even if that's the day before the exam. Note: "Yo... | DECISIONS.md:52 (Home page) | W4b |  |  | assigned |
| D-53 | Busy days: three lessons show, the rest fold behind "N more lessons" (opens in place); big review counts read "60 due · 6 sessions of 10"... | DECISIONS.md:53 (Home page) | W4b |  |  | assigned |
| D-54 | Quiet days: "Nothing due today" / "Day off" cards with optional Practice; review-only week and last study day show "That's all for today.... | DECISIONS.md:54 (Home page) | W4b |  |  | assigned |
| D-55 | Many lessons (4+): Today shows "Up next" (the lesson Continue opens) and one Lessons row with a ring and "3 of 10 read" + chevron; the fu... | DECISIONS.md:55 (Home page) | W4b |  |  | assigned |
| D-56 | Every Today row is tappable (chevron) and opens its own sheet: Lessons (grouped by subject), Reviews (sessions, then where the questions... | DECISIONS.md:56 (Home page) | W4b |  |  | assigned |
| D-57 | Sheets keep only: title + one figure, rows with a tick/ring, a name, and at most one number or time. No group counts, no subtitles. | DECISIONS.md:57 (Home page) | W4b |  |  | assigned |
| D-58 | Copy (user): "Items you missed are in today's reviews."; the mock row reads "Mock exam" / "{EXAM} simulation" (e.g. "UPCAT simulation") w... | DECISIONS.md:58 (Home page) | W4b |  |  | assigned |
| D-59 | Copy: the Home section heading is "YOUR PERFORMANCE" (was "How you're doing"). | DECISIONS.md:59 (Home page) | W4b |  |  | assigned |
| D-60 | Quiet days can advance (the next study day's lesson moves to today); only the review-only week can't. "Nothing due today" = a study day w... | DECISIONS.md:60 (Home page) | W4b |  |  | assigned |
| D-61 | Empty-day states (from the plan engine, APPROVED): 1 Today done -> "That's all for today." + I Want to Advance. 2 Day off -> streak safe;... | DECISIONS.md:61 (Home page) | W4b |  |  | assigned |
| D-62 | Copy: carried-over note is "Unfinished items are added to today." Carried items carry no "from yesterday" label. | DECISIONS.md:62 (Home page) | W4b |  |  | assigned |
| D-63 | Before the assessment: Home shows only the week strip, greeting and the assessment card (no Today, no Your Performance, no rows). | DECISIONS.md:63 (Home page) | W4b |  |  | assigned |
| D-64 | Copy: assessment card body "We check your strengths and weak spots first, so your plan is built around you." | DECISIONS.md:64 (Home page) | W4b |  |  | assigned |
| D-65 | Home situations split: NOTICES sit above Today (no date, month only, trial ending, welcome to Pro); STATES replace Today (before assessme... | DECISIONS.md:65 (Home page) | W4b |  |  | assigned |
| D-66 | Home notices (APPROVED, option C): a thin outlined strip under the week, one at a time. Row 52pt tall, whole row taps to open in place (c... | DECISIONS.md:66 (Home page) | W4b |  |  | assigned |
| D-67 | Buttons, app-wide: stacked = primary on top; side by side = primary on the RIGHT, the other on the left. | DECISIONS.md:67 (Home page) | W2 |  |  | assigned |
| D-68 | Notice strips use only secondary (tinted) and tertiary (text) actions, never a solid button. | DECISIONS.md:68 (Home page) | W2 |  |  | assigned |
| D-69 | Setting the exam date from Home uses the same month-first picker as onboarding (in a sheet). Save stays grey until a month (or, in the mo... | DECISIONS.md:69 (Home page) | W4b |  |  | assigned |
| D-71 | Home page holds: Free, Pro, The day (CSS timeline), Notices (strip), States, Busy days, Empty days, Mid-day and skipped mocks. Notice opt... | DECISIONS.md:71 (Home) | W4b |  |  | assigned |
| D-72 | Next: Your Performance section. | DECISIONS.md:72 (Home) | W4b |  |  | assigned |
| D-73 | Your Performance (Home): subject bars are quiet grey (5pt), percentages in plain dark text; teal only on the overall ring. Footer (Free a... | DECISIONS.md:73 (Home) | W4b |  |  | the open Free-to-paywall step is resolved by stage 0 #24 (Pro buttons open the Settings Pro page) |
| D-74 | More about you (Home): two rows, sentence case: "Your record" (no streak value on the row) and "Your tendencies". How you work is folded... | DECISIONS.md:74 (Home) | W4b |  |  | assigned; "confirm with Claude Code" is answered by building it (How you work merged into tendencies) |
| D-76 | Your record (Free and Pro alike): Since you started (weeks in; day streak with orange flame; "since {date}" only when every day of the st... | DECISIONS.md:76 (More about you) | W4b |  |  | assigned |
| D-77 | Streak: not on Home. It lives in Your record and the streak reminder; the week strip's dots already show studied days. | DECISIONS.md:77 (More about you) | W4b |  |  | assigned |
| D-78 | Your tendencies order: profile card, "What we found" (clear tendencies, full color), "Needs more usage data" (everything not clear yet),... | DECISIONS.md:78 (More about you) | W4b |  |  | assigned |
| D-79 | Profile card: dark card; name, label on one line, line below; 20px padding, same height for every label; a large icon in solid #3A3A3D (n... | DECISIONS.md:79 (More about you) | W4b |  |  | assigned |
| D-80 | Profile labels and lines (identity, no figures): Levelheaded "Exam-day pressure doesn't shake you." · Deep Thinker "You take your sweet t... | DECISIONS.md:80 (More about you) | W4b |  |  | assigned |
| D-81 | Icons: Levelheaded anchor, Deep Thinker lightbulb, Night Owl moon, Early Bird sunrise, Math Wizard math signs, Wordsmith "Aa", All-Rounde... | DECISIONS.md:81 (More about you) | W4b |  |  | assigned |
| D-82 | Tendency cards: small uppercase heading with icon, a headline sentence with no figures, then the picture. Headings: Under pressure, How l... | DECISIONS.md:82 (More about you) | W4b |  |  | assigned |
| D-83 | Pictures: Under pressure = two dots on one accuracy track (40 to 80%), the drop in orange; How long you answer = two time bars on one sca... | DECISIONS.md:83 (More about you) | W4b |  |  | assigned |
| D-84 | Sentences: "Your accuracy drops under exam pressure.", "You take longer on questions you get wrong.", "You usually read the lesson first.... | DECISIONS.md:84 (More about you) | W4b |  |  | assigned |
| D-85 | Not clear yet (early, forming or no data), Pro too: no figures. Generic grey shape under "Too early to tell." (early), "No clear differen... | DECISIONS.md:85 (More about you) | W4b |  |  | assigned |
| D-86 | Error: page title stays; faint icon, "Could not load your progress.", tinted Try Again. | DECISIONS.md:86 (More about you) | W4b |  |  | assigned |
| D-87 | Motion: bars grow, dots slide, the line draws, the profile icon drifts in (looping CSS timeline on the canvas). | DECISIONS.md:87 (More about you) | W4b |  |  | assigned |
| D-88 | For Claude Code: rename the 12 labels and replace their line templates; drop {n} from the tendency sentences; new memory sentence; How yo... | DECISIONS.md:88 (More about you) | W4b |  |  | assigned |
| D-90 | The lesson reader shown in DP_DayRead is a stand-in, not the final design; it gets its own round later. | DECISIONS.md:90 (View full plan) | W4b |  |  | record: the reader is designed in the Study section (lines 126 to 143) |
| D-91 | Opens with Today as one line (ring + "2 of 4 done"), not the checklist again. | DECISIONS.md:91 (View full plan) | W4b |  |  | assigned |
| D-92 | Header subtitle: "42 days until UPCAT". Topics and lessons has no subtitle. | DECISIONS.md:92 (View full plan) | W4b |  |  | assigned |
| D-93 | Coming up (Pro): a timeline to the exam. Every row is the same height: node, title in regular weight with a small grey label ("This week"... | DECISIONS.md:93 (View full plan) | W4b |  |  | assigned |
| D-94 | Your plan entrance: sections rise in one after another, Today's ring fills, the timeline draws, then History's rows slide in. | DECISIONS.md:94 (View full plan) | W4b |  |  | assigned |
| D-95 | History (renamed from What changed, Pro): each entry is the date on the left (Today, Yesterday, Sep 24, Aug 21) and the description on on... | DECISIONS.md:95 (View full plan) | W4b |  |  | assigned |
| D-96 | Free: Today, then Coming up and History as grey shapes (exam date visible), one Unlock with Pro: "See every week up to your exam, and eve... | DECISIONS.md:96 (View full plan) | W4b |  |  | assigned |
| D-97 | Tapping a day in Home's week strip opens the same day screen: past days show what was done (real counts, Home's done style), today is Hom... | DECISIONS.md:97 (View full plan) | W4b |  |  | assigned |
| D-98 | Weeks run Sunday to Saturday everywhere (Coming up rows: Sep 27 – Oct 3, Oct 4 – 10, ...). | DECISIONS.md:98 (View full plan) | W1 |  |  | assigned |
| D-99 | A week opened (proposed): title is just the dates ("Oct 4 – 10"), no subtitle. "Lessons by day" lists Sunday to Saturday; days that aren'... | DECISIONS.md:99 (View full plan) | W4b |  |  | assigned |
| D-100 | A day opened (proposed): a pushed screen built from Home's Today section, so it looks and behaves the same: title "Tuesday, Oct 6", secti... | DECISIONS.md:100 (View full plan) | W4b |  |  | assigned |
| D-101 | Canvas fix: timeline animations on every board now have their own names (boards share one page on the canvas, so n1, n2... clashed and mo... | DECISIONS.md:101 (View full plan) | none |  |  | canvas only: no app work |
| D-103 | Pro: a Subjects / Topics / Lessons switch on top, then a sort chip (Weakest first, Strongest first, A to Z, from a small menu) and the Al... | DECISIONS.md:103 (Your performance) | W4b |  |  | assigned |
| D-104 | A topic opened (APPROVED): accuracy, answered, lessons read; its lessons with read state ("Today" tag on today's); Practice This Topic, w... | DECISIONS.md:104 (Your performance) | W4b |  |  | assigned |
| D-105 | Free (2 Oct): "See all topics and lessons" (with its small Pro tag) opens this same screen. The half ring, the Subjects view and the sort... | DECISIONS.md:105 (Your performance) | W4b |  |  | assigned |
| D-106 | Layout (2 Oct): Home's half ring (overall accuracy, fills on load) on top, sitting on the page with no card; then the Subjects / Topics /... | DECISIONS.md:106 (Your performance) | W4b |  |  | assigned |
| D-107 | A row in the Lessons view opens the lesson reader (the reader gets its own round). | DECISIONS.md:107 (Your performance) | W4b |  |  | assigned |
| D-108 | Tapping a subject (Free and Pro alike): the switch slides to Topics with that subject picked ("MATHEMATICS"), weakest first. Free gets th... | DECISIONS.md:108 (Your performance) | W4b |  |  | assigned |
| D-109 | Errors: "Could not load your plan." and "Could not load your performance." in the same style as Your tendencies (title stays, faint icon,... | DECISIONS.md:109 (Your performance) | W4b |  |  | assigned |
| D-110 | No data, no show (2 Oct): subjects, topics and lessons with no answers don't appear at all, and nothing on screen explains it. The subjec... | DECISIONS.md:110 (Your performance) | W4b |  |  | assigned |
| D-111 | Accuracy bars are a soft teal that deepens with accuracy (light at 40% and below, deeper toward 80%). No red or green, no verdict. Home's... | DECISIONS.md:111 (Your performance) | W2 |  |  | assigned |
| D-112 | Sorting (your idea): the Subjects / Topics / Lessons switch, then ONE square button on its right with three states, cycled by tapping: we... | DECISIONS.md:112 (Your performance) | W4b |  |  | assigned |
| D-113 | Options and steps not picked (Plan B and C, Topics B, the chip sort and its menu, the five sort options, the weakest-three sheet, the New... | DECISIONS.md:113 (Your performance) | none |  |  | canvas only: no app work |
| D-115 | Home and everything it opens is approved and locked: the Home page (Free, Pro, the day, notices, states, busy and empty days), Your plan... | DECISIONS.md:115 (Home: COMPLETE) | none |  |  | record |
| D-117 | Free for everyone. Top to bottom: "Study" title, search field, Last opened, Bookmarks, then each subject with its topics. | DECISIONS.md:117 (Study map) | W4c |  |  | assigned |
| D-118 | Last opened: "LAST OPENED", the lesson ("Circles"), its topic ("Geometry"), teal Resume. Resume opens the lesson where you left off. | DECISIONS.md:118 (Study map) | W4c |  |  | assigned |
| D-119 | No coverage card: no "lessons read" count, no "left to read" hours. | DECISIONS.md:119 (Study map) | W4c |  |  | assigned |
| D-120 | Text only on lessons: subjects and topics show no counts. Topics keep their ring (empty, filling, or the filled teal check when done). | DECISIONS.md:120 (Study map) | W4c |  |  | assigned |
| D-121 | Lessons: a read lesson is a plain teal check (no circle) with its name in grey and no "Read" text; unread lessons show minutes; today's l... | DECISIONS.md:121 (Study map) | W4c |  |  | assigned |
| D-122 | Topics open in place, one at a time. Scrolling inside an open topic pins its row to the top as a bar; tapping the bar closes the topic. B... | DECISIONS.md:122 (Study map) | W4c |  |  | assigned |
| D-123 | Bookmarks: three rows at most, then "See all". Empty: the section stays with a faint bookmark and "Bookmark a lesson to keep it here." Bo... | DECISIONS.md:123 (Study map) | W4c |  |  | assigned |
| D-124 | Search: tapping the field folds the title away and shows Cancel; empty field shows RECENTLY OPENED (last three lessons); results are "N L... | DECISIONS.md:124 (Study map) | W4c |  |  | assigned |
| D-125 | Boards ST_Map, ST_MapEmpty, ST_TopicOpen, ST_Pinned, ST_Search, ST_NoMatch. | DECISIONS.md:125 (Study map) | none |  |  | record |
| D-127 | Type: the app font (Geist) for everything, lesson text included. Serif (Source Serif 4) only for math, LaTeX style: numbers upright, vari... | DECISIONS.md:127 (Lesson reader) | W1 |  |  | assigned |
| D-128 | Bar: back ("Study" or "Home") on the left; on the right the contents button (from Study) or the day counter "2 of 2" (from Home's plan),... | DECISIONS.md:128 (Lesson reader) | W4c |  |  | assigned |
| D-129 | Scrolling: over the first 90px a strip under the bar opens and the title moves into it; a thin teal line under the strip follows your pla... | DECISIONS.md:129 (Lesson reader) | W4c |  |  | assigned |
| D-130 | Contents button: the topic's lessons as a sheet (lesson checks, "Reading" tag on the current one, minutes on unread). "2 of 2": today's l... | DECISIONS.md:130 (Lesson reader) | W4c |  |  | assigned |
| D-131 | Lesson content (real corpus, "Layers of the Earth and Composition"): section headings, subheadings, examples numbered in grey with each S... | DECISIONS.md:131 (Lesson reader) | W4c |  |  | assigned |
| D-132 | Illustrations: rounded frame, expand button, credit line under every image (CC BY-SA needs it). The corpus description becomes the image'... | DECISIONS.md:132 (Lesson reader) | W4c |  |  | assigned |
| D-133 | The end: reaching the bottom counts the lesson as read on its own (check and "Read" pop in; no button). Then a grey "Quiz yourself, 5 que... | DECISIONS.md:133 (Lesson reader) | W4c |  |  | assigned |
| D-134 | Next lesson, Webtoon style: keep pulling up past the end. A circle with an up arrow fills as you pull ("Pull up for Polygons"); when it's... | DECISIONS.md:134 (Lesson reader) | W4c |  |  | assigned |
| D-135 | Endings: a finished topic shows a plate (topic, "UPCAT · Mathematics", "11 lessons, all read", date) and the same pull straight into the... | DECISIONS.md:135 (Lesson reader) | W4c |  |  | assigned |
| D-136 | Earlier scroll board with sample text is on Archive ("Lesson reader (earlier rounds)"). | DECISIONS.md:136 (Lesson reader) | none |  |  | canvas only: no app work |
| D-137 | For Claude Code: drop the reader's serif body type; render $math$ in serif; show image credits from illustrations/sources/*.yaml; pull-to... | DECISIONS.md:137 (Lesson reader) | W4c |  |  | assigned |
| D-138 | The pull's circle is also tappable (same look), so screen reader users can move on without the gesture. | DECISIONS.md:138 (Lesson reader) | W4c |  |  | assigned |
| D-139 | A figure the corpus describes but has no image for is skipped silently. | DECISIONS.md:139 (Lesson reader) | W4c |  |  | assigned |
| D-140 | Kept as is (2 Oct): no exam name heading on the map; search placeholder "Lessons, topics"; the pinned bar closes the topic on tap. | DECISIONS.md:140 (Lesson reader) | W4c |  |  | assigned |
| D-141 | The Study tab remembers which topic was open when you leave and come back (Claude Code). | DECISIONS.md:141 (Lesson reader) | W4c |  |  | assigned |
| D-142 | States (APPROVED 2 Oct): Study loading (shapes pulse, only if slow), "Could not load your topics." with Try Again, "Nothing to study yet"... | DECISIONS.md:142 (Lesson reader) | W4c |  |  | assigned |
| D-143 | Corpus notes: the seismic-waves figure in Layers of the Earth has a spec but no image; lessons have no authored order yet (next lesson is... | DECISIONS.md:143 (Lesson reader) | none |  |  | content track: seismic-waves figure, lesson order, em dash in a lesson |
| D-145 | Free for everyone: marking, sorting, removing, reordering. | DECISIONS.md:145 (Bookmarks) | W4c |  |  | assigned |
| D-146 | The reader's bar: grey icons at rest (contents, "2 of 2", bookmark); only the back link is teal. Bookmarking pops into teal like a check... | DECISIONS.md:146 (Bookmarks) | W4c |  |  | assigned |
| D-147 | See all opens a sheet (74% of the screen); the Study page behind settles slightly down and smaller under a dark wash; tap outside or drag... | DECISIONS.md:147 (Bookmarks) | W4c |  |  | assigned |
| D-148 | Sort switch: Recent · Oldest · By subject · Custom. Recent is the default. The selected order sets the three bookmarks shown on the Study... | DECISIONS.md:148 (Bookmarks) | W4c |  |  | assigned |
| D-149 | Edit: "Edit" turns to "Done"; each row gets a checkbox (left) and a drag handle (right); the switch dims while editing. Footer: "N select... | DECISIONS.md:149 (Bookmarks) | W4c |  |  | assigned |
| D-150 | Edge cases: one bookmark = no switch, no handles (BM_One); everything removed = "No bookmarks yet" / "Bookmark a lesson to keep it here."... | DECISIONS.md:150 (Bookmarks) | W4c |  |  | assigned |
| D-151 | For Claude Code: unbookmark then bookmark again lands at the top of Custom; Undo restores exact positions; new bookmarks land at the top... | DECISIONS.md:151 (Bookmarks) | W4c |  |  | assigned |
| D-152 | Earlier versions (first ribbon animation, black option, Custom-with-grips, Free proposal) are on Archive ("Bookmarks (earlier rounds)"). | DECISIONS.md:152 (Bookmarks) | none |  |  | canvas only: no app work |
| D-154 | The Study map, search, the lesson reader and its endings, all states, and Bookmarks are approved and locked, on the Study page. | DECISIONS.md:154 (Study: COMPLETE) | none |  |  | record |
| D-156 | Title "Quiz". TODAY: the question half of Home's Today (Reviews "12 of 18", New questions "3 of 7", same rings and sheets), Continue Revi... | DECISIONS.md:156 (Quiz tab) | W4d |  |  | assigned |
| D-157 | MOCK EXAM card: "UPCAT simulation" with its length; Last score and Last attempt; the tier line always shown: Free "Free includes one mock... | DECISIONS.md:157 (Quiz tab) | W4d |  |  | assigned |
| D-158 | MORE WAYS TO PRACTICE: Your past mistakes (count), Customize your own (sliders icon), Flagged questions (count). Icons teal (Home's row i... | DECISIONS.md:158 (Quiz tab) | W4d |  |  | assigned |
| D-159 | States: paused ("You paused. Every answer was saved.", Resume, "Discard this session"; the mock says "Finish your quiz session first."; C... | DECISIONS.md:159 (Quiz tab) | W4d |  |  | assigned |
| D-161 | The list: subjects, then topics with a round checkbox and an arrow; the arrow opens the topic's lessons ("Unread" in orange on unread one... | DECISIONS.md:161 (Customize your own) | W4d |  |  | assigned |
| D-162 | Every lesson counts the same: picking a topic picks all its lessons; ticking every lesson of a topic fills the topic. | DECISIONS.md:162 (Customize your own) | W4d |  |  | assigned |
| D-163 | A floating bar: "6 lessons picked", "60 questions · ~54 min ⌄", Start (off with "Nothing picked yet / Pick a topic or a lesson"). Tapping... | DECISIONS.md:163 (Customize your own) | W4d |  |  | assigned |
| D-164 | How long?: two separate modes, "Questions per lesson" ("You set the questions. Time follows.") and "Total time" ("You set the time. Quest... | DECISIONS.md:164 (Customize your own) | W4d |  |  | assigned |
| D-165 | Edge cases: many lessons scroll; uneven Total time splits show in the rows; times too short for one question per lesson are struck out on... | DECISIONS.md:165 (Customize your own) | W4d |  |  | assigned |
| D-166 | For Claude Code: questions are mixed across lessons; practice skips questions answered in the last 7 days, topping up with older ones bef... | DECISIONS.md:166 (Customize your own) | W4d |  |  | assigned |
| D-167 | Options not picked (tile layouts, the "Your quiz" sheet, the slim line, icon choices) are on Archive ("Quiz (earlier rounds)"). | DECISIONS.md:167 (Customize your own) | none |  |  | canvas only: no app work |
| D-169 | "Session", never "Sitting": one run of questions is a session; a long day of reviews is split into sessions ("Reviews · Session 1 of 2",... | DECISIONS.md:169 (Wording) | W4d |  |  | assigned |
| D-171 | One set of screens for every quiz: today's reviews, today's new questions, a lesson's quiz, Customize your own, Your past mistakes, Flagg... | DECISIONS.md:171 (Quiz screens) | W4d |  |  | assigned |
| D-172 | Top: X (leave) on the left, Report on the right. Everything else lives in a floating bottom bar: the counter "4 of 10 ⌄" (opens the quest... | DECISIONS.md:172 (Quiz screens) | W4d |  |  | assigned |
| D-173 | Answering: tap a choice to pick it (teal outline, still changeable); a gray Check turns green once something is picked; Check confirms. T... | DECISIONS.md:173 (Quiz screens) | W4d |  |  | assigned |
| D-174 | Flag: in the bar; pops teal; first time only, a toast "Flagged. Find it in the Quiz tab." with Undo, sitting above the bar. | DECISIONS.md:174 (Quiz screens) | W4d |  |  | assigned |
| D-175 | Long questions, long choices, math (Source Serif 4) and figures (on a white card between the question and the choices): the page always k... | DECISIONS.md:175 (Quiz screens) | W4d |  |  | assigned |
| D-176 | Questions sheet (from the counter): a grid of circles, five across (six in the mock, grouped by part). Answered right = soft teal, wrong... | DECISIONS.md:176 (Quiz screens) | W2 |  |  | assigned |
| D-177 | Leaving: the X asks once, "Leave this session?", Keep Going / Leave; every answer is already saved. | DECISIONS.md:177 (Quiz screens) | W4d |  |  | assigned |
| D-178 | End of a session: "Session finished." and its line (e.g. "Reviews · Session 1 of 2"); Home's half ring fills while the circles for every... | DECISIONS.md:178 (Quiz screens) | W4d |  |  | assigned |
| D-179 | Question viewer (from any row, circle or Finish the Notes): the question read-only, with the same bottom bar: ‹ "1 of 10" ›, light green... | DECISIONS.md:179 (Quiz screens) | W4d |  |  | assigned |
| D-180 | Report (top right, quiz and viewer): the bottom bar becomes a one-field form above the keyboard; Send is off until you type; after Send,... | DECISIONS.md:180 (Quiz screens) | W4d |  |  | assigned |
| D-181 | Lists truncate long titles to one line with "…", never wrap. | DECISIONS.md:181 (Quiz screens) | W2 |  |  | assigned |
| D-182 | "Session", never "Sitting". | DECISIONS.md:182 (Quiz screens) | W4d |  |  | assigned; duplicate of line 169 |
| D-183 | For Claude Code: the picked reason is one nullable column on the attempt (misread, slipped, unknown, other) plus an optional text for "Ty... | DECISIONS.md:183 (Quiz screens) | W4d |  |  | assigned |
| D-184 | Options not picked (the travelling ring and its moves, other "current" marks, Add Note treatments and icons, tap-to-commit, the earlier e... | DECISIONS.md:184 (Quiz screens) | none |  |  | canvas only: no app work |
| D-186 | Before you start: the exam's parts in a table (Section, Items, Time) with "250 total items · 3 hr 50 min" on the total row; how it runs i... | DECISIONS.md:186 (Mock exam screens) | W4e |  |  | assigned |
| D-187 | While the clock runs: the clock centered at the top with a thick time bar under it (amber under 5 minutes, red in the last minute), pause... | DECISIONS.md:187 (Mock exam screens) | W4e |  |  | assigned |
| D-188 | Last question of a part: › stays; tapping it asks "End Part 3 now?" (strict mode: dimmed, with a quiet line). Ending early loses the left... | DECISIONS.md:188 (Mock exam screens) | W4e |  |  | assigned |
| D-189 | Time is up (or a part ended early): answered and blank dots only (no flags), and the parts list with an arrow at where you are. The clock... | DECISIONS.md:189 (Mock exam screens) | W4e |  |  | assigned |
| D-190 | Pause (strict off): first a warning, "Real exams don't pause.", with "Don't show this again"; then the big hourglass falls, stops and shr... | DECISIONS.md:190 (Mock exam screens) | W4e |  |  | assigned |
| D-191 | Strict mode: a 10-second grace period when leaving the app; after that the mock ends there ("Not finished") and everything answered befor... | DECISIONS.md:191 (Mock exam screens) | W4e |  |  | assigned |
| D-192 | The end, as one animation: Time is up, the dots shrink into an answer sheet, the other parts join, a sweep reveals each answer (teal righ... | DECISIONS.md:192 (Mock exam screens) | W4e |  |  | assigned |
| D-193 | UPCAT (right minus ¼ of each wrong): the answered wrongs drop into their own red ball (sized against the green), both balls gather at onc... | DECISIONS.md:193 (Mock exam screens) | W4e |  |  | assigned |
| D-194 | Your score: the half ring, the number with only the % smaller, the line under it, PERFORMANCE BREAKDOWN (correct / items and % per part,... | DECISIONS.md:194 (Mock exam screens) | W4e |  |  | assigned |
| D-195 | For Claude Code: score each exam with its own rule (UPCAT: right − wrong ÷ 4; blanks 0); store right, wrong and blank per part. Exams tha... | DECISIONS.md:195 (Mock exam screens) | W4e |  |  | assigned |
| D-196 | All questions after a mock (Pro; row "Mock exam · All questions"): tabs All 250 · Wrong 79 · Flagged 12, Wrong opens first. Rows grouped... | DECISIONS.md:196 (Mock exam screens) | W4e |  |  | assigned |
| D-197 | Free and Pro after a mock (APPROVED 4 Oct): flags are not gated (both tiers flag and keep flags). Free sees every question with the right... | DECISIONS.md:197 (Mock exam screens) | W4e |  |  | assigned |
| D-198 | Other exams (APPROVED 4 Oct): one-block exams (CSE) list items per subject (placeholders until a source exists) with no time per subject;... | DECISIONS.md:198 (Mock exam screens) | W4e |  |  | assigned |
| D-199 | Motion on static boards: screens drawn still (Free results, revisits, other exams, Free viewer, CSE sheet and submit, DCAT and CSE setup)... | DECISIONS.md:199 (Mock exam screens) | W4e |  |  | assigned |
| D-201 | Phosphor, regular weight, everywhere (Flutter: phosphor_flutter). Lucide was compared and set aside (Archive). | DECISIONS.md:201 (Icons) | W1 |  |  | assigned |
| D-202 | Nine of ours stay, redrawn at Phosphor's line weight (1.5 at 24, round ends): the questions sheet (a 3x3 grid of circles, like the sheet... | DECISIONS.md:202 (Icons) | W1 |  |  | assigned |
| D-203 | Settings: Your exam is target, Practice is brain. Icons sit on the row without a tile, each in its own color. | DECISIONS.md:203 (Icons) | W4f |  |  | assigned |
| D-204 | The "next month" arrow on the exam date calendar is a plain chevron (caret-right), like every other ›. | DECISIONS.md:204 (Icons) | W1 |  |  | assigned |
| D-205 | Boards drawn before 4 Oct still show the old hand-drawn icons; build from IC_Final, not from those boards. | DECISIONS.md:205 (Icons) | W1 |  |  | assigned |
| D-207 | Settings is a tab. Top level: the profile card (opens Account and backup), Pantas Pro, then Your exam, Practice, Reminders, Appearance, t... | DECISIONS.md:207 (Settings) | W4f |  |  | assigned |
| D-208 | Your exam: Exam (opens the onboarding exam picker; "You're not starting from zero" after a change), Exam date (opens in the list: Exact d... | DECISIONS.md:208 (Settings) | W4f |  |  | assigned |
| D-209 | Practice: Session length 5 / 10 / 20 / All (default 10; sets the sitting, not the day's amount). How sessions are built: One topic only (... | DECISIONS.md:209 (Settings) | W4f |  |  | assigned |
| D-210 | "Do more each day" is removed. "I want to advance" on Today replaces it (roadmap spec); it's drawn on Home (approved). | DECISIONS.md:210 (Settings) | W4f |  |  | assigned |
| D-211 | Reminders: Daily reminder (switch; the time row shows only while it's on; "Reminders only come on your study days.") and Follow up (switc... | DECISIONS.md:211 (Settings) | W4f |  |  | assigned; amended by stage 0 #4 (Follow up time row) and #6 (Exam countdown switch) |
| D-212 | Appearance: Light and Dark previews with Automatic (follows the phone); Text size slider (engineering tests very large fonts); Remember t... | DECISIONS.md:212 (Settings) | W4f |  |  | assigned |
| D-213 | Account and backup (from the profile card): Name (its own screen), Signed in with Google, Backup, Sign Out, Delete Account (a confirmatio... | DECISIONS.md:213 (Settings) | W4f |  |  | assigned |
| D-214 | About: version; Privacy policy, Terms of service; Help improve the app (switch), Contact our data protection officer (mail app); Send fee... | DECISIONS.md:214 (Settings) | W4f |  |  | assigned |
| D-215 | Profile picture: Google photo, else the first letter of the name (any letter), an emoji stays an emoji, otherwise a plain person on gray.... | DECISIONS.md:215 (Settings) | W4f |  |  | assigned |
| D-216 | Free sees every row; nothing is hidden, disabled or badged. Offline, every row still works and syncs later. | DECISIONS.md:216 (Settings) | W4f |  |  | assigned |
| D-217 | Pro prices follow the exam (docs/pricing.md, 4 Oct; that file wins). Student (UPCAT, other CETs, DOST, SM): Weekly ₱29, Monthly ₱99, Year... | DECISIONS.md:217 (Settings) | W4f |  |  | assigned |
| D-218 | Dark mode: switches keep a white knob on a gray (off) or teal (on) track; the picked segment is a lighter gray. | DECISIONS.md:218 (Settings) | W2 |  |  | assigned |
| D-219 | Pantas ID (APPROVED 4 Oct; giveaways log, 4 Oct): its own group on Account under Name and Signed in with. "Pantas ID" with a copy icon. T... | DECISIONS.md:219 (Settings) | W4f |  |  | assigned |
| D-220 | Delete account: each thing that goes has a red icon with Phosphor's slash (user, cloud, phone). (APPROVED 4 Oct) | DECISIONS.md:220 (Settings) | W4f |  |  | assigned |
| D-221 | What's included uses the Customize your own picker: subjects as headings, topics with round boxes, the caret opens lessons; a partly pick... | DECISIONS.md:221 (Settings) | W2 |  |  | assigned |
| D-222 | After picking another exam: no numbers. The old exam is a vessel full of green, the new one empty, joined by a tube; Count Them drops eve... | DECISIONS.md:222 (Settings) | W4f |  |  | assigned |
| D-223 | Backup details gets Back Up Now under the list: while it runs the status reads Backing up with a spinner and the button rests; offline it... | DECISIONS.md:223 (Settings) | W4f |  |  | assigned |
| D-224 | Exam switching and paying (4 Oct): same or cheaper exam, Pro stays and only the transfer shows. A pricier exam shows that exam's plans as... | DECISIONS.md:224 (Settings) | W4f |  |  | assigned |
| D-225 | Exams not out yet (PSHS-NCE, NAPOLCOM, AFPSAT, PMA, PNPA, PMMA, MAAP, LET, PNLE) show in the picker grayed with "Coming soon" and can't b... | DECISIONS.md:225 (Settings) | W4f |  |  | assigned |
| D-226 | A Season Pass that ended says when ("It ended after your exam on Mar 1, 2027."), and offers a new pass for the next exam date (or Monthly... | DECISIONS.md:226 (Settings) | W4f |  |  | assigned |
| D-227 | Season Pass dates are ours, never the student's: a pass runs to the published exam date (the last day if the exam runs several days), and... | DECISIONS.md:227 (Settings) | W3 |  |  | assigned |
| D-228 | Paywalls: never after onboarding and never for Free users switching exams; Pro shows only when someone taps a Pro button. The one switchi... | DECISIONS.md:228 (Settings) | W4f |  |  | assigned |
| D-229 | Pro pages for the other groups (APPROVED 4 Oct): Licensure, Monthly ₱249 (7 days free) or a ₱1,499 Season Pass to the board exam. Academy... | DECISIONS.md:229 (Settings) | W4f |  |  | assigned |
| D-231 | Rule: nothing a student made is ever paywalled. Free sees what happened; Pro sees why, goes deeper, and has no mock limit. No locks, blur... | DECISIONS.md:231 (Free and Pro) | W2 |  |  | assigned |
| D-232 | Today, lessons, the Study map, the reader, Bookmarks, Customize your own, flags: the same for both. | DECISIONS.md:232 (Free and Pro) | none |  |  | record: rule applied in each family |
| D-233 | Mock exams: Free one every 14 days (the Quiz card says when the next opens); Pro as many as they like. Boards QZ_Free, QZ_Tab. | DECISIONS.md:233 (Free and Pro) | W4e |  |  | assigned |
| D-234 | After a mock: both see every question with the right answer and explanation; Free keeps them until their next mock opens, then the record... | DECISIONS.md:234 (Free and Pro) | W4e |  |  | assigned |
| D-235 | Notes on misses: Pro only. Free gets no note prompt and no note icon (the counter sits in the middle). Boards QV_MissFree / QV_MissPro, Q... | DECISIONS.md:235 (Free and Pro) | W4d |  |  | assigned |
| D-236 | Your performance: both see the half ring and subjects; topics and lessons are Pro (Free gets one Pro card in their place). Boards DT_Free... | DECISIONS.md:236 (Free and Pro) | W4b |  |  | assigned |
| D-237 | Your plan: both see Today; Coming up and History are Pro (Free sees grey shapes and one Unlock with Pro). Boards DP_PlanFree, DP_PlanA. | DECISIONS.md:237 (Free and Pro) | W4b |  |  | assigned |
| D-238 | Your tendencies: Free sees the profile card and the labels as grey shapes; Pro sees the findings and When you work. Boards YO_Free, YO_Pr... | DECISIONS.md:238 (Free and Pro) | W4b |  |  | assigned |
| D-239 | Backup and sync: Pro only (and signed in). Free reads "This phone only". Boards ST_Account, ST_AccountPro, ST_BackupDetails. | DECISIONS.md:239 (Free and Pro) | W4f |  |  | assigned |
| D-240 | Prices by exam and the Season Pass rules are under Settings above (docs/pricing.md wins). | DECISIONS.md:240 (Free and Pro) | none |  |  | record: see lines 217 and 227 |
| D-242 | The assessment: the approved question screen, without flag or Check: pick, then Next; "8 of 30" with no caret (no jumping); "Answers show... | DECISIONS.md:242 (The rest of the app) | W4d |  |  | assigned |
| D-243 | Your own mock (custom track): Questions and Time open in place (wheels, no sheets); "I know the section breakdown" opens one row per subj... | DECISIONS.md:243 (The rest of the app) | W4e |  |  | assigned |
| D-244 | Something went wrong (replaces the red error screen): "Something went wrong." / "Nothing you've done is lost." / Try Again. Update requir... | DECISIONS.md:244 (The rest of the app) | W4h |  |  | assigned |
| D-245 | Wrapped: four moments (first mock or a new best; a streak of 7, 30, 100 or 365; a topic turning from weak to strong; the day after the ex... | DECISIONS.md:245 (The rest of the app) | W4g |  |  | assigned; three moments only (restart log handoff decision 3), not four |
| D-246 | Sharing: its own screen, "Before you share": the exact image that goes out, switches for Exam name, Week of prep and Your name (all off),... | DECISIONS.md:246 (The rest of the app) | W4g |  |  | assigned |
| D-247 | Shared links live in About › Your data (a row with the count): each shared image with its date and link, Remove with a confirm, and an em... | DECISIONS.md:247 (The rest of the app) | W4g |  |  | assigned |
| D-249 | Payment pending (GCash, over the counter): the Pro page swaps the plans for one card, "Waiting for your payment" with the plan and price... | DECISIONS.md:249 (Last gaps) | W4f |  |  | assigned |
| D-250 | Subscribing with no connection: the same short note as Restore, "No internet connection. Please try again." | DECISIONS.md:250 (Last gaps) | W4f |  |  | assigned |
| D-251 | Pro's Wrapped history: Your record gets a last row, YOUR WRAPPED, "Watch them again" with three thumbnails and the count; it opens "Your... | DECISIONS.md:251 (Last gaps) | W4g |  |  | assigned |
| D-252 | Service message (Remote Config): a Home notice in the same place and style as the others, one line and a close button, nothing to open. | DECISIONS.md:252 (Last gaps) | W4b |  |  | assigned |
| D-253 | Dark mode on the main screens (Home, Quiz, Study, the reader, a miss, the end of a mock) uses the Settings dark rules: black background,... | DECISIONS.md:253 (Last gaps) | W1 |  |  | assigned |
| D-254 | Fixed: the trial-ending notice on Home now says ₱99 on Monthly ("Google Play charges ₱99 on Oct 2 to keep Pro."). | DECISIONS.md:254 (Last gaps) | W4b |  |  | assigned |
| D-256 | Full date "Nov 11, 2026"; this year drops the year: "Oct 17"; with the weekday when the day matters: "Sat, Oct 17"; long headings "Saturd... | DECISIONS.md:256 (Dates) | W1 |  |  | assigned; approved 5 Oct (restart log, date format approved) |
| D-258 | Missed mock questions come back as reviews in the following days, like any answer (roadmap spec, 30 Sep). | DECISIONS.md:258 (Mock answers) | W4e |  |  | assigned |
| D-260 | Quiz is fully approved (4 Oct). Settings is fully approved (4 Oct). | DECISIONS.md:260 (Next) | none |  |  | record |
| D-261 | Content, before those blueprints ship: CSE per-subject item counts need a source (the screens show placeholders); ACET's 27-minute aptitu... | DECISIONS.md:261 (Next) | W4e |  |  | assigned; placeholders per restart log handoff decision 7 |
| D-262 | Canvas pages (2 Oct): Decisions, Onboarding, Home (Home, Plan and Your performance, More about you, each under its own heading), Study (m... | DECISIONS.md:262 (Next) | none |  |  | canvas only: no app work |
| D-263 | Still open from earlier: question 0002 says continental crust is 70 km thick, the lesson says 35 km (content, later). | DECISIONS.md:263 (Next) | none |  |  | content track: question 0002 crust thickness |
| D-266 | Onboarding reminders: "Let's build your study habits." with no sample notification above it. | DECISIONS.md:266 (Copy pass) | W4a |  |  | assigned; plus amendment spec copy (drop "Nothing else.") |
| D-267 | Pro page hero: "See exactly what's losing you points." with no subtitle. Features: Unlimited mock exams; Notes on why your answer was wro... | DECISIONS.md:267 (Copy pass) | W4f |  |  | assigned |
| D-268 | Pro lapsed: "It ended on Sep 30, 2026." Restore offline and subscribe offline: "No internet connection. Please try again." | DECISIONS.md:268 (Copy pass) | W4f |  |  | assigned |
| D-269 | Account: backup footer "Your progress stays on this phone only. With Pro, it's backed up and syncs across your devices." Delete Account h... | DECISIONS.md:269 (Copy pass) | W4f |  |  | assigned |
| D-270 | Your exam footer: "When you change your exam date or study days, the roadmap rebuilds your plan right away. At least one day should be se... | DECISIONS.md:270 (Copy pass) | W4f |  |  | assigned |
| D-271 | After switching exams: "Some content on UPCAT is on CSE Professional too. Count them and continue where you are." | DECISIONS.md:271 (Copy pass) | W4f |  |  | assigned |
| D-272 | What's included: subtitle is the exam name only ("UPCAT"); footer "Untick what you don't need. It gets removed from your plan, and your a... | DECISIONS.md:272 (Copy pass) | W4f |  |  | assigned |
| D-273 | Practice: "How many questions in one quiz session. It doesn't change how much is due for the whole day." Interleaving: "Studies show that... | DECISIONS.md:273 (Copy pass) | W4f |  |  | assigned |
| D-274 | Upgrade from student Pro: "CSE Professional has its own price tier" / "Your Pro covers UPCAT and other student exams only. Pro for CSE Pr... | DECISIONS.md:274 (Copy pass) | W4f |  |  | assigned |
| D-275 | Mock pause warning: "Use this only when you really have to. The clock stops, but you won't get this during the real exam." | DECISIONS.md:275 (Copy pass) | W4e |  |  | assigned |
| D-276 | "Why did you miss it?" has no "Pantas noticed" line; the card is shorter to match (quizzes and mock review). | DECISIONS.md:276 (Copy pass) | W4d |  |  | assigned |
| D-277 | Home lists truncate long lesson titles to one line with "…", like every other list. | DECISIONS.md:277 (Copy pass) | W4b |  |  | assigned |
| D-278 | Signing in later from Settings starts on the approved signed-out Account screen (Continue with Google), then Restoring your progress. | DECISIONS.md:278 (Copy pass) | W4f |  |  | assigned |
| R-1 | Name: "the new design"; never "Clarity" in project writing | restart log, restart decisions | none |  |  | rule: checked at gates |
| R-2 | Cleanup of contained branches, worktrees and stashes | restart log, restart decisions 1 | none |  |  | done (cleanup performed, 5 Oct) |
| R-3 | Pause lifted: the new design work | restart log, restart decisions 2 | none |  |  | record: authorizes this program |
| R-4 | Pre-beta fix: subscription cancellation keeps Pro until expiry | restart log, restart decisions 2 | W3 |  |  | assigned |
| R-5 | Pre-beta fix: short public ID for giveaways (Pantas ID) | restart log, restart decisions 2 | W3 |  |  | assigned; UI is D-219 (W4f) |
| R-6 | Merge question-qa-r2 code and content | restart log, restart decisions 2 | W0 |  |  | assigned |
| R-7 | Base: integration branch from web/roadmap-engine-r1 | restart log, restart decisions 3; baseline | W0 |  |  | done: integration/new-design-r1 at 1f79d880 |
| R-8 | Complexity: balanced | restart log, restart decisions 4 | none |  |  | record |
| R-9 | Screens and dark mode with no board: built from the shared design rules, no preview | restart log, restart decisions 5 | none |  |  | rule: every W4 level 2 plan applies it; checked at gates |
| R-10 | Content coverage audit continues on its own track | restart log, restart decisions 6 | none |  |  | out of program |
| R-11 | Attribution trailers removed from main history | restart log, attribution | none |  |  | done |
| R-12 | Mock review gating: Free full review until next mock opens; Pro any time; notes Pro only | restart log, handoff 1 | W4e |  |  | assigned |
| R-13 | Pro History (Your plan History) ships; local only until sync | restart log, handoff 2 | W4b |  |  | assigned |
| R-14 | Wrapped: three moments; no topic weak-to-strong moment | restart log, handoff 3 | W4g |  |  | assigned |
| R-15 | Design is authoritative; gap pass; bottom sheets only where a board shows one | restart log, handoff 4 | none |  |  | rule: every W4 level 2 plan applies it; checked at gates |
| R-16 | Retire old Progress screens and routes; Progress lives on Home | restart log, handoff 5 | W4b |  |  | assigned |
| R-17 | Tabs Home, Study, Quiz, Settings in the shell | amendment spec B4 | W1 |  |  | assigned |
| R-18 | Retire /paywall and the Try Pro flow | amendment spec B4; stage 0 #24 | W4f |  |  | assigned |
| R-19 | Date format approved and its helpers (Sunday to Saturday weeks) | restart log, handoff 6; date format approved | W1 |  |  | assigned |
| R-20 | CSE item counts and ACET time as marked placeholders; replacing them is a release blocker | restart log, handoff 7 | W4e |  |  | assigned; W5 checks the release blocker |
| R-21 | Baseline: fix analyzer info (deprecated onReorder, bookmarks sheet) | restart log, baseline | W2 |  |  | assigned |
| R-22 | Baseline: functions tests (node --test) not run | restart log, baseline | W0 |  |  | assigned: W0 full checks include them |
| R-23 | Strategy approved; unattended running through levels 2 and 3 | restart log, strategy approved | none |  |  | record |
| R-24 | Execution arrangement for level 4 (Claude Code subagents; no Gemini) | restart log, execution arrangement | none |  |  | record: applies at level 4 |
| R-25 | Kept-work cleanup and archive branch | restart log, kept-work cleanup | none |  |  | done: archive/pre-restart-kept-work at 2bdde4fd |
| R-26 | Countdown and come-back each replace that day's daily reminder; follow-up still applies | restart log, amendment approved 1 | W4f |  |  | assigned |
| R-27 | Countdown follows only its own switch; 7:00 PM when daily is off; 7:00 AM on exam day | restart log, amendment approved 2 | W4f |  |  | assigned |
| R-28 | Follow-up time wheel offers only times after the daily reminder | restart log, amendment approved 3 | W4f |  |  | assigned |
| R-29 | Resume task every 10 minutes; 2-hour stale lock | restart log, resume task | none |  |  | record |
| A-B2a | Notification kinds: remove wrapped push and the ceiling; followUp replaces streakSave | amendment spec B2 | W4f |  |  | assigned |
| A-B2b | Notification tap routing (Home; trial ending opens Settings › Pantas Pro) | amendment spec B2 | W4b |  |  | assigned; Home tap targets per amendment B4 |
| A-B2c | Permission denied: nothing sent; Reminders blocked state | amendment spec B2 | W4f |  |  | assigned |
| A-B3a | Confirm storage of response time, session timing, mistake tags, blank reasons | amendment spec B3 | W0 |  |  | assigned |
| A-B3b | Mock sampler recency filter (last two finished mocks) | amendment spec B3; stage 0 #28 | W4e |  |  | assigned; same work as S0-28 |
| A-B5a | iOS build state on integration/new-design-r1 unverified | amendment spec B5 | W5 |  |  | assigned |
| A-B5b | Lesson ids on questions for the lesson-scoped in-lesson quiz | amendment spec B5 | W0 |  |  | assigned: W0 confirms; content track owns the data |
| A-B1 | Superseded sections of older specs (table B1) | amendment spec B1 | none |  |  | rule: each level 2 plan cites it for its family |
| S0-1 | Switching exams. The older board (L_ChangeExam2, 1 Oct) carries everything over with no choice. The Settings boards (ST_ExamSwitch, 4 Oct... | stage0-decisions.md #1 | W4f |  |  | assigned |
| S0-2 | Mock score. The 1 Oct note asks for confetti, a "Your best mock yet" pill and a sentence comparing with the last mock. The 3 Oct note and... | stage0-decisions.md #2 | W4e |  |  | assigned |
| S0-3 | The icon board lists a lock icon for "Locked until Pro". The Free and Pro rule says no locks anywhere. | stage0-decisions.md #3 | W2 |  |  | assigned (Pro tag, no lock icon) |
| S0-4 | Reminders. Onboarding shows Follow up "at 9:00 PM" and "Tap a time to change it". Settings shows only a switch. The old streak-save remin... | stage0-decisions.md #4 | W4f |  |  | assigned (Follow up time row; replaces streak-save) |
| S0-5 | Flagged questions list: see, remove and practice flags | stage0-decisions.md #5 | W4d |  |  | assigned |
| S0-6 | Exam countdown notifications (30, 14, 7, 3, 2, 1 days, exam day) | stage0-decisions.md #6 | W4f |  |  | assigned (countdown kept); onboarding copy is B-O_Notify_v2 (W4a) |
| S0-7 | Come-back notification after 3 missed study days | stage0-decisions.md #7 | W4f |  |  | assigned |
| S0-8 | Wrapped-ready notification | stage0-decisions.md #8 | W4g |  |  | discard: remove the Wrapped push |
| S0-9 | One-notification-a-day limit | stage0-decisions.md #9 | W4f |  |  | discard: remove the ceiling |
| S0-10 | "Lately" line on Home: one rotating fact a day (sharpest hour, streak, pace) | stage0-decisions.md #10 | W4b |  |  | discard: remove the Lately line |
| S0-11 | Lessons read out of total on Home ("3/46") and the "Your pace" panel ("At 3 lessons a week you finish 9 days after the exam") | stage0-decisions.md #11 | W4b |  |  | discard: remove lessons-read total and Your pace |
| S0-12 | Time per question column in performance tables (from mocks) | stage0-decisions.md #12 | W4b |  |  | assigned: remove the Time column, keep recording (A-B3a) |
| S0-13 | "Why you miss questions" section (Pro): had it right before, never seen it, answered too fast, plus the student's own notes | stage0-decisions.md #13 | W4b |  |  | assigned: remove Why you miss, keep inputs (A-B3a) |
| S0-14 | Pro cause line under each miss at the end of a session ("You answered in 4 seconds. You usually take 21.") and "You'll see all three agai... | stage0-decisions.md #14 | W4d |  |  | discard: remove cause lines and "back in X days" |
| S0-15 | Spaced-repetition explainer paragraph ("Pantas shows a question again just before you would forget it") | stage0-decisions.md #15 | W4d |  |  | discard: remove the explainer |
| S0-16 | "Try a quick quiz" before the assessment | stage0-decisions.md #16 | W4c |  |  | assigned: quick quiz only on Study "Nothing to study yet"; removed from Home and Quiz |
| S0-17 | "Study first for better results" sheet before the first quiz | stage0-decisions.md #17 | W4d |  |  | discard: remove the study-first sheet |
| S0-18 | Assessment nudge after quizzes 1, 3 and 5; "Your plan is ready" moment after onboarding | stage0-decisions.md #18 | none |  |  | discard: never built; nothing to do |
| S0-19 | Store rating prompt: asked once, after a session with 80% or more right, never near a Pro page | stage0-decisions.md #19 | W4d |  |  | assigned (store rating prompt kept) |
| S0-20 | Choice after sign-in when both the phone and the account hold progress: Keep my account / Keep this device | stage0-decisions.md #20 | W4f |  |  | assigned (centered dialog) |
| S0-21 | "Delete my data" for a student who never signed in | stage0-decisions.md #21 | W4f |  |  | assigned |
| S0-22 | In-app data export | stage0-decisions.md #22 | W4f |  |  | discard: no export; DPO row in About |
| S0-23 | Sign-in prompts at milestones (after the first mock, after a 3-day streak) | stage0-decisions.md #23 | none |  |  | discard: never built; nothing to do |
| S0-24 | Separate three-screen "Try Pro" flow (what Pro adds, plans with cost through your exam date, trial timeline) and the plan recommended by... | stage0-decisions.md #24 | W4f |  |  | assigned; same work as R-18 |
| S0-25 | Trial-ending phone notification 24 hours before the charge | stage0-decisions.md #25 | W3 |  |  | assigned (trial-ending trigger, amendment B4) |
| S0-26 | Mock: "Next blank" and "Next flagged" shortcuts in the questions sheet | stage0-decisions.md #26 | W4e |  |  | discard: remove unwired shortcuts |
| S0-27 | Mock: a "Strict" badge on a finished mock | stage0-decisions.md #27 | W4e |  |  | discard |
| S0-28 | Mock: avoid repeating questions from the student's last two mocks | stage0-decisions.md #28 | W4e |  |  | assigned |
| S0-29 | Mock: line on setup when the question bank cannot fill a part ("This mock has 230 questions instead of 250") | stage0-decisions.md #29 | W4e |  |  | assigned |
| S0-30 | Bookmark ribbon on a Study topic that holds a bookmark; bookmark notes for Pro | stage0-decisions.md #30 | W4c |  |  | discard |
| S0-31 | Wrapped: a small message after an ordinary mock (not first, not a new best) | stage0-decisions.md #31 | W4g |  |  | discard |
| S0-32 | Choose your exam fallback on Home and Quiz when no exam is active | stage0-decisions.md #32 | W4h |  |  | assigned |
| S0-33 | Loading, error and empty states on screens without a board (Home, Quiz tab, Your record, search, flagged list, Wrapped, Shared links, leg... | stage0-decisions.md #33 | W4h |  |  | assigned (pattern; each family applies it) |
| S0-34 | Save failures (onboarding steps, answers, mock progress, exam pick) | stage0-decisions.md #34 | W4h |  |  | assigned (pattern; each family applies it) |
| S0-35 | Pro page states not drawn: trial running, canceled but active until a date, a giveaway grant, an unknown plan, a billing problem, store e... | stage0-decisions.md #35 | W4f |  |  | assigned |
| S0-36 | Account edges: sign-in canceled or failed, sign-out while offline, fresh sign-in required before deletion, deletion failed, after deletion | stage0-decisions.md #36 | W4f |  |  | assigned |
| S0-37 | Mock edges: system back during a paper, reopening the app mid-mock, time ran out while closed, broken saved mock, exams with unpublished... | stage0-decisions.md #37 | W4e |  |  | assigned |
| S0-38 | Mock setup choices: the strict switch on setup applies to this mock only; "Don't show this again" is remembered on the phone | stage0-decisions.md #38 | W4e |  |  | assigned |
| S0-39 | Custom-track mock card on the Quiz tab ("Set one up", "Change the setup") and reopening a saved setup with its values | stage0-decisions.md #39 | W4e |  |  | assigned (includes the saved-values bug) |
| S0-40 | Wrapped edges: how it first opens (on the next app open after the event), tap or swipe through slides with a close button, slides with no... | stage0-decisions.md #40 | W4g |  |  | assigned |
| S0-41 | Study edges: Resume hidden until a lesson was opened, search also matches topic names, tables and passages in lessons, code-drawn figures... | stage0-decisions.md #41 | W4c |  |  | assigned |
| S0-42 | Navigation: tapping the active tab returns to its top; each tab keeps its place; old links redirect | stage0-decisions.md #42 | W1 |  |  | assigned (shell navigation) |
| S0-43 | Keep: four release end-to-end tests (Firebase sync, mock resume, quiz state and delete, shipping cold start), the 6 Sept quiz-loading spe... | stage0-decisions.md #43 | W5 |  |  | assigned: four end-to-end tests to W5; refresh fix is S0-43b (W4d); spec saved as record |
| S0-43b | 5-line fix that refreshes Today after a custom assessment | stage0-decisions.md #43 | W4d |  |  | assigned |
| S0-44 | Discard: 30 items fully contained in the integration branch, superseded by it, or generated noise (including uncommitted work in two old... | stage0-decisions.md #44 | none |  |  | done (archived, then removed) |
| S0-45 | Phone benchmark harness from the low-end performance work (untracked) | stage0-decisions.md #45 | none |  |  | done (archived) |
| S0-46 | Extra accessibility checks for inline math (70 lines, uncommitted) | stage0-decisions.md #46 | W2 |  |  | assigned (math rendering tests) |
| S0-47 | Backup branch from today's attribution rewrite | stage0-decisions.md #47 | none |  |  | done |
| S0-48 | Beta consolidation planning documents (Sept) | stage0-decisions.md #48 | none |  |  | done (archived) |
| S0-49 | iPhone QA enablement design (Sept, not started) | stage0-decisions.md #49 | W5 |  |  | assigned (iPhone testing over Xcode wireless debugging) |
| S0-50 | Landing page design documents (Sept) | stage0-decisions.md #50 | none |  |  | out of program (website) |
| S0-51 | Illustration visual review ledgers (Aug) | stage0-decisions.md #51 | none |  |  | done (archived) |

## Gap pass section B rows

Pending: step B3.4b adds one `G-` row per section B row of `stage0/gap-*.md`, with the stage 0
decision number (1 to 42) it falls under and its workstream. Rows that fit no decision are flagged
for Aedwon.
