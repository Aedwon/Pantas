# Gap pass: family b-home

Policy revision: origin/main 6d508d70.
Worktree read: integration/new-design-r1 at 1f79d880. Paths starting `lib/` are in that worktree. Spec paths are `docs/superpowers/specs/` in the same worktree unless marked (main).
Board ids confirmed against `docs/design/SCREENS.md`, `DECISIONS.md` and the board HTML text.

Context facts that shape both lists:
- The current app has no Today checklist, no week strip, no notices, no plan screen and no History. `lib/features/roadmap` is engine only. Home still shows the old Up next / Practice / Tendencies panels (`lib/features/home/presentation/home_tab.dart:62-95`).
- `/progress` is still a bottom tab (`lib/app/router.dart:228`) and `/plan` does not exist. `/plan/dossier/:mockId` is a stub (`lib/app/router.dart:255`).

## A. Changed by the design

old behavior | new behavior | board id(s) | evidence

Navigation and top of Home
- Bottom tabs Home, Study, Quiz, Progress | Home, Study, Quiz, Settings (gear). Progress is merged into Home. | HP_Free, HP_Pro | `lib/app/router.dart:228`; DECISIONS "Navigation"
- Home top is a text masthead: greeting line, exam short name as headline, "42 days to go", and a gear that pushes /settings | Compact Sun-to-Sat week strip with today centered, then an exam chip "UPCAT 11 NOV 42 days". No gear or person button. | HP_Free, HP_Pro | `lib/features/home/presentation/widgets/home_masthead.dart:23-67`; DECISIONS "Home" top bullet
- Greeting prints the name on the same line ("Magandang gabi, Aedwon"); spec also promised an "Add your name" invitation in the masthead | Greeting only ("Magandang gabi"), "Welcome back" after missed days. "Add your name" now lives on the profile card. | HP_Free, HE_BackAfterBreak, YO_ProNew | `home_masthead.dart:91-94`; `2026-07-26-home-and-navigation-design.md` Section 2 "No-name state"
- Date states: day = "42 days to go"; month only = "Your exam is in November 2026"; no date = line is blank | Chip states: day count; month only shows "in Nov" with a notice strip to pick the day; no date shows "+ Add date" with a notice; exam day shows "Today"; passed shows "Passed" | HP_Free, HP_MonthOnly, HP_NoDate, HP_ExamDay, HP_ExamPassed | `home_masthead.dart:105-119`
- Exam date passed: nothing special; masthead goes blank | Card "Did you take UPCAT?" with Set a New Date and Switch Exams, in place of Today | HP_ExamPassed | `home_masthead.dart:109-110`; roadmap spec (main) Section 7 "Exam date"
- Day marks and day taps do not exist | Week strip day marks (done dot, half dot, missed, day off grey, today ring); tapping a day opens the day screen | HP_Free, DP_DayPast, DP_Day | DECISIONS "Home" day marks; "View full plan" Tapping a day

Today section
- "Up next" panel: lead sentence "Algebra, Geometry and Chemistry today. About 28 minutes.", up to three lesson rows with minutes, "Continue lesson", "See all" to Study | TODAY checklist: lesson rows with ring/check and "Read" or minutes, Reviews "12 of 18", New questions "3 of 7", Continue Lesson, link "View full plan". Every row opens its own sheet. | HP_Pro, HP_Day, HE_ManyLessons | `lib/features/home/presentation/widgets/up_next_panel.dart:17-27,70-96`; DECISIONS "Home page"
- Up next is always three unread lessons from the weakest topics, ignoring the exam date and exclusions | Today comes from the roadmap engine (lessons per day, reviews, new questions, mock). Free has no cap and looks the same as Pro. | HP_Free, HP_Pro | `lib/features/home/application/up_next_provider.dart:100-134`; roadmap spec (main) Section 1
- Many lessons: all N rows listed | 4 or more lessons: "Up next" lesson plus one Lessons row ("3 of 10 read") that opens a sheet grouped by subject | HE_ManyLessons | `up_next_panel.dart:82-89`; DECISIONS "Many lessons (4+)"
- Empty state "Nothing left to read in your weak topics." (only when every lesson is read) | "Nothing due today", "Day off", "That's all for today." and "You've covered everything in your plan." cards, with "Practice Weakest Topics" or "I Want to Advance" per case | HE_NothingDue, HE_NothingDueReview, HE_DayOff, HE_ReviewWeek, HE_LastDay | `up_next_panel.dart:53-65`; DECISIONS "Empty-day states"
- Today has no mock row; mock lives on the Quiz tab | On mock day the "Mock exam / UPCAT simulation / 2 hr 45 min" row leads Today; a skipped mock moves to the next study day with "Your UPCAT simulation moved to today." | HE_MockDay, HE_MockMoved, HE_MockDropped, HE_Everything | `up_next_panel.dart` (no mock row); roadmap spec (main) Section 5 item 5
- Planned "Do more each day" switch | "I Want to Advance" on Today when done; "From tomorrow" items; offer repeats; hidden when it adds nothing | HP_Day, HE_AdvanceAgain, HE_DayOff | `2026-08-04-study-plan-forward-calendar-design.md` Section 3 "student's own control"; DECISIONS "Advancing"
- Missed days: no message | One calm line "Items you missed are in today's reviews."; big review counts read "60 due · 6 sessions of 10"; carried items note "Unfinished items are added to today." | HE_BackAfterBreak, HE_CarryOver | roadmap spec (main) Section 5 item 3
- Lesson left halfway: row just opens the lesson | Row says "Resume"; button reads "Resume Lesson" | HE_Resume | `up_next_panel.dart:91-95`

Accuracy and performance on Home
- Stats band: accuracy % read from the frozen assessment result, centered, with "lessons read x/y" | "YOUR PERFORMANCE": half ring of overall accuracy, no "x right of y". Counts every finished session (daily plan, picker practice, drills, retakes, lesson quizzes, assessment, mocks), so it moves live. | HP_Pro, DT_TopicsA | `lib/features/home/presentation/widgets/home_stats_band.dart:30-35`; Home spec Section 8 "figures were frozen"; DECISIONS "Overall accuracy counts every finished session"
- "Practice" panel: three weakest topics with meter and severity-colored %, tap starts a topic quiz, "See all" goes to Progress | Not on Home. "Needs practice" is See all sorted weakest first. Subject rows with quiet grey bars and plain %. Footer "See all topics and lessons ›" (Free adds a Pro tag). | HP_Pro, HP_Free, DT_SortFlow | `lib/features/home/presentation/widgets/practice_panel.dart:30-62`; DECISIONS "Needs practice ... not on Home"
- Free saw three topic rows free on Home as a teaser | Free sees subjects only; Topics and Lessons are one "Go deeper with Pro" card | HP_Free, DT_Free | Home spec Section 3 "Free and Pro"; DECISIONS "Free and Pro" Your performance
- "Your tendencies" deck on Home: swipeable pages with dots, Free cards with "Unlock with Pro", Pro "See full details" to /progress | Home shows two rows under "More about you": "Your record" (no streak value) and "Your tendencies" | HP_Pro, HP_Free | `lib/features/home/presentation/widgets/tendencies_panel.dart:35,71`; DECISIONS "More about you (Home)"
- Progress tab "Go deeper" rows "How you work" and "Your record" with verdict subtitles ("Night-Owl Sprinter. Sharpest at 9 pm...", "N days active. Best mock 68%") | No subtitles. How you work is folded into Your tendencies. | HP_Pro, YO_Pro | `lib/features/progress/presentation/progress_page.dart:228-247`
- Before the assessment: Home shows "Build your study plan", "Take the assessment to find what to study first.", Start the assessment | Week strip, greeting and one card "First, a short assessment" / "We check your strengths and weak spots first, so your plan is built around you." / Start Assessment. Nothing else. | HE_BeforeAssessment | `lib/features/home/presentation/home_tab.dart:121-155`
- Progress day one: "Nothing to report yet" empty state | Progress tab is retired; the same state is Home before the assessment | HE_BeforeAssessment | `progress_page.dart:117-143`; `2026-07-30-progress-tab-design.md` Section 9 "Day one"
- Progress error: "Could not load your progress. Pull down to try again." banner | Per screen: faint icon, "Could not load your plan." / "...your performance." / "...your progress.", tinted Try Again | DP_Error, DT_Error, YO_Error | `progress_page.dart:150-170`; `how_you_work_page.dart` error text

Your performance (old Progress "Performance" panel)
- Level control: text labels Subject · Topic · Lesson with ticks | Subjects / Topics / Lessons segmented switch | DT_TopicsA, DT_TopicsView, DT_LessonsView | `lib/features/progress/presentation/widgets/level_control.dart:34-66`
- Sort: tap SCORE or TIME column heads, caret shows direction, default Score ascending | One square button cycling weakest first, strongest first, A to Z; quiet label "8 TOPICS · WEAKEST FIRST"; rows slide | DT_SortFlow | `lib/features/progress/presentation/widgets/table_head.dart:63-75`
- Subject filter: dotted-underline head cell "All topics" opens a sheet "Show which topics" with topic counts per subject | Quiet picker label "ALL SUBJECTS" with up-down chevron; lists only subjects that have answers | DT_FilterFlow | `lib/features/progress/presentation/widgets/subject_scope_sheet.dart:39-81`; `performance_section.dart:171-189`
- Table collapsed to six measured rows with "Show N more" / "Show N not started" / "Show less" | Full list; rows with no answers do not appear at all and nothing explains it | DT_TopicsA, DT_TopicsView, DT_LessonsView | `performance_section.dart:39,72-74,284-293`; DECISIONS "No data, no show"
- Severity colors: rust below 50, amber below 70, ink above | Soft teal that deepens with accuracy, no red or green, no verdict | DT_TopicsA, DT_TopicsView | `performance_section.dart:210-216`
- Subject rows are flat table rows with a "60 of 180 questions" subtext (published paper size) | Subject cards: topic count, accuracy, quiet bar. The paper-size figure is gone. | DT_TopicsA | `lib/features/progress/application/performance_provider.dart:254-274`; progress spec Section 3 "subtext"
- Row taps: only Lesson-level rows open the reader; subject and topic rows are inert | Tapping a subject slides to Topics with that subject picked (Free too, then the Pro card); tapping a topic opens its page (accuracy, answered, lessons read, lessons, Practice This Topic) | DT_SubjectTap, DT_SubjectTapFree, DT_Topic | `performance_section.dart:128-130`; progress spec Section 6 "Row destinations"
- Free: Topic and Lesson labels dimmed, tap goes to /paywall | Switch slides to Topics/Lessons and shows one "Go deeper with Pro" card with Unlock with Pro; sort button dims | DT_Free | `performance_section.dart:89`; `level_control.dart:48-53`
- Dedicated Progress tab with exam name line, scrolling sections, pull to refresh | Screen reached from "See all topics and lessons" on Home, opening with the half ring | DT_TopicsA | `progress_page.dart:40-76`

Your record
- Accuracy-across-prep: panel draws nothing under two weekly points; line has gridlines, no figure | Dark line with "this week" figure and start date; below two weeks a dotted placeholder with "Your line starts after two weeks of answers." | YR_Full, YR_FirstWeek | `lib/features/progress/presentation/widgets/accuracy_line.dart:74-76`
- Weekly buckets start Monday | Weeks run Sunday to Saturday everywhere | YR_Full | `lib/features/progress/application/record_provider.dart:239`; DECISIONS "Weeks run Sunday to Saturday everywhere"
- "time in sessions" prints minutes only ("2130m") | "35h 30m" | YR_Full | `lib/features/progress/presentation/pages/your_record_page.dart:68`
- Mock rows named from the blueprint name | "UPCAT simulation" with date and % | YR_Full | `your_record_page.dart:100-107`
- Loading is a spinner; error prints "Error: $err" | Placeholder tiers; error follows the shared error style | YO_Error | `your_record_page.dart:22-23`
- Last row after Your mocks does not exist | Pro: "YOUR WRAPPED · Watch them again · N"; Free: same row with small Pro tag | YR_Wrapped, YR_WrappedFree | DECISIONS "Pro's Wrapped history"

Your tendencies (old "How you work")
- Page title "How you work"; panel "Your profile" with centered serif name, archetype, line | Page "Your tendencies": dark profile card with name, label, identity line and a large bleeding icon; "Add your name" when no name | YO_Pro, YO3_Profiles, YO_ProNew | `lib/features/progress/presentation/pages/how_you_work_page.dart:41-90`
- 12 archetypes (Night-Owl Sprinter, Early Bird Marathoner, Game-Day Player, Pressure Tightener, Bookmark Strategist, Time Master, Closer, Wordsmith, Numbers Person, Generalist, Scholar, Long Memory), lines carry figures ("Your mock accuracy runs 6 pts below practice.") | 12 new labels (Levelheaded, Deep Thinker, Night Owl, Early Bird, Math Wizard, Wordsmith, All-Rounder, Scholar, Strong Recall, Thorough Reviewer, Time Master, Closer) with fixed identity lines and no figures | YO3_Profiles | `lib/features/metrics/archetypes/archetype_catalog.dart:11-132`; `archetype_templates.dart:12-75`
- Five tendencies always shown in fixed order; gap-first big figure (34/700) plus caption of two figures; losses in rust | Sections "What we found" (clear, full color) and "Needs more usage data"; each card has a small heading, a no-figure sentence and a picture (dots on a track, time bars, read vs answered shares, two memory figures, line graph); orange only for a clear loss | YO_Pro, YO4_Picks | `lib/features/progress/application/how_you_work_provider.dart:196-396`
- Sentences carry {n}: "Accuracy drops 6% under exam pressure.", "You spend 14s longer...", memory "what you learn holds about nine days..." | "Your accuracy drops under exam pressure.", "You take longer on questions you get wrong.", "You retain information for days before needing to refresh.", "Your accuracy drops in the second half of a mock." | YO_Pro | `how_you_work_provider.dart:119-120,156-157,228-229`
- Heading "How you answer"; "How you study" shown as counts (12 vs 4) | "How long you answer"; "How you study" as shares summing to 100% | YO_Pro, YO4_Picks | `how_you_work_provider.dart:231-246,193-206`
- Figures shown even for early or forming tendencies | Figures hidden until the tendency is clear: "Too early to tell.", "No clear difference so far.", or "Not enough data yet" plus what is missing | YO_ProNew | `how_you_work_provider.dart:129-138`; `lib/features/metrics/domain/tendency_confidence.dart`
- "When you work" rows: Peak hour, Session length ("Average sit duration"), Total sits, each with a subtext | Peak hour, Average session, Total sessions, no subtitles | YO_Pro | `how_you_work_provider.dart:396-418`
- Free: five headings and labels over FaintBars, then "Unlock complete insights..." and Unlock with Pro | Free: profile card, every tendency as a grey shape with "left vs. right" labels, same Unlock line and button | YO_Free | `how_you_work_page.dart:117-143`

Plan screen and History
- Plan (Aug spec): pushed "Your plan" page: big "25 questions today. 18 to review, 7 new.", the rest of this week day by day with counts, weekly dates, pacing sentence ("Seven new questions a day finishes the material by 5 October..."), wholly Free, no taps | Opens with Today as one line (ring + "2 of 4 done"); "Coming up" timeline (weeks with topic names, New material stops, Mock exam, exam) is Pro; History is Pro; Free sees grey shapes and one Unlock with Pro | DP_PlanA, DP_PlanFree | `2026-08-04-study-plan-forward-calendar-design.md` Sections 4, 5
- Plan days not tappable; "next mock unlocks" marker for Free only | Weeks and days are tappable (plan, week, day); the mock is a scheduled timeline row for all | DP_Drill, DP_Week, DP_Day | same spec Section 4 "What is not interactive"
- Plan weeks in the Aug spec were Monday based | Sunday to Saturday; rest days read "Rest day" and are not tappable; footer "You study Monday to Saturday." with Change to Settings | DP_Week, DP_WeekCustom | `2026-08-04-study-plan-forward-calendar-design.md` Section 4; DECISIONS "A week opened"
- May plan: Home plan card, pace curve, intensity | Removed; replaced by Today and the plan screen | DP_PlanA | `2026-05-18-study-plan-design.md` Sections 4.3, 5.1, 5.4
- "What changed" log (Pro) (roadmap spec, UI deferred) | Renamed History: date left, one truncated line, tap to open in place, 5 shown then "See more" adds 10, ends with "That's everything since you started." | DP_History, DP_HistoryEnd | roadmap spec (main) Section 6; DECISIONS "History"

Notifications shown by Home
- Notification permission handled on its own page "I'll be your coach." with Sounds good / Not right now | Reminders step in onboarding, then the Android permission dialog | O_Notify | `lib/features/notifications/presentation/permission_rationale_page.dart:53-79`; `lib/app/router.dart:250`; DECISIONS "Onboarding (APPROVED 1 Oct)"
- Home has no notices | Thin outlined strip under the week, one at a time: no date, month only, trial ending, welcome to Pro, service message; X is 44x44, "Got It"/"Later"/"Not Yet" | HP_NoDate, HP_MonthOnly, HP_Trial, HP_ProWelcome, HP_Service | DECISIONS "Home notices (APPROVED, option C)"

## B. Missing from the design

item | where it exists now | what it does for the student | nearest board

Home
- Lessons-read count against total ("3/46") on Home | `lib/features/home/presentation/widgets/home_stats_band.dart:60-66`; Home spec Section 3 "Stats band" | Shows reading coverage at a glance | YR_Full has "lessons read" (count only, no total); DT_Topic has "2 of 5 lessons read" per topic
- "Lately" line under the stats band: one rotating daily insight (sharpest hour, average sit length, day streak, speed vs accuracy, subject deltas, syllabus touched %, strong-memory lapse %), each with a Pro depth label | `home_stats_band.dart:67-92`; `lib/features/metrics/atoms/home_atoms.dart:32-191`; `lib/features/metrics/atoms/atom_rotation.dart`; `2026-06-10-user-facing-metrics-design.md` | A small daily fact for motivation; Pro depth views | none
- "Choose your exam" fallback when no exam is selected (Get started to /onboarding on Home; "Choose exam" to /settings/exam on Progress) | `home_tab.dart:99-114`; `progress_page.dart:68-90` | Recovers a user with no active exam | HP_NoContent covers an exam with no content, not "no exam"
- Home-level loading and failure ("Could not load your home. Pull down to try again." with Try again) | `home_tab.dart:155-185` | Tells the student Home failed and retries | DP_Error (plan only), DT_Error, YO_Error
- Pull-to-refresh on Progress sections | `progress_page.dart:57,154` | Reloads figures | none
- "Try a quick quiz" secondary button before the assessment; "Or take a mock exam" link on Progress day one | `home_tab.dart:143-147`; `progress_page.dart:128-141` | Lets a new student practice without the assessment | HE_BeforeAssessment has only Start Assessment
- Practice start failures: snackbars "No questions are ready right now." and "Could not prepare this quiz." | `lib/features/home/presentation/widgets/practice_panel.dart:100-119` | Explains a topic practice that cannot start. Needed for Practice This Topic and Practice Weakest Topics. | DT_Topic, HE_NothingDue (button only)
- Which notice shows first when more than one applies (service message, trial ending, welcome to Pro, no date, month only), and Manage / See What's New destinations | DECISIONS "one at a time" only | Avoids two strips or the wrong one winning | HP_NoDate, HP_Trial, HP_ProWelcome, HP_Service
- Greeting rules: which hour bands pick umaga/hapon/gabi and when "Welcome back" replaces it | `home_masthead.dart:73-84` | Sets the greeting text | HE_BackAfterBreak (one state only)

Your pace (old Progress)
- "Your pace" panel: % of lessons read, days left, and the arithmetic sentence ("At 3 lessons a week you finish 9 days after the exam. 4 a week closes the gap."; "You have not read a lesson in four weeks"); wholly Free | `lib/features/progress/presentation/widgets/your_pace_panel.dart:48-148`; `lib/features/progress/application/pace_provider.dart`; `2026-07-30-progress-tab-design.md` Section 3; `2026-08-04-study-plan-forward-calendar-design.md` Section 3 | Tells the student if their reading rate finishes the material before the exam | DP_PlanA ("42 days until UPCAT" only). The roadmap engine now sets the pace, so this may be moot, but no entry says so.

Your performance (old Progress)
- "Time" column: seconds per question, measured from timed mocks only, a Time sort head, and the line "Your pace per question appears here after your first full length mock..." | `performance_section.dart:98-140`; `table_head.dart:69-75`; `performance_provider.dart:366-389`; progress spec Section 3 | Shows speed against a real clock per subject, topic, lesson | DT_SortFlow (sort states omit Time); DT_TopicsA rows show accuracy only
- "Why you miss questions" (Pro, Free redacted): counts "had it right before", "never seen it", "answered too fast", an interpreting sentence, Pro adds topic concentration and misreads the student noted; Free sees Unlock with Pro | `lib/features/progress/presentation/widgets/why_you_miss_section.dart:27-176`; `lib/features/progress/application/miss_causes_provider.dart`; progress spec Section 3, 7 | Tells the student why they miss questions | QV_MissPro (note input only). DECISIONS says "Progress counts 'other' separately and shows your words when the question comes back" but no Progress board shows it.
- Lesson-level availability rule: Lessons level absent until questions carry a lesson id | `performance_provider.dart:169-170`; `level_control.dart:37` | Hides an empty Lessons view | DT_LessonsView (assumes data)
- Chart screen-reader summaries ("Accuracy history. Up 4 percentage points overall, from 55 percent to 61 percent...") | `accuracy_line.dart:83-121` | Lets a screen-reader user read the chart | YR_Full (picture only)

Your record and tendencies
- Your record has no error state; no empty state when the record cannot load | `your_record_page.dart:22-23` | Handles a failed load | YO_Error (tendencies page only)
- Spaced-repetition explainer paragraph on How you work ("Pantas shows a question again just before you would forget it...") | `2026-07-30-progress-tab-design.md` Section 4 (spec only, not in code) | Explains why questions return | YO_Pro (absent)
- Tendencies when the profile has no label yet (name present, no archetype) | `how_you_work_page.dart:63-82` | Defines what the profile card shows before a label is earned | YO_ProNew (shows only "Add your name")

Plan and History
- Behavior of the Pro mock "dossier" route from the plan timeline | `lib/app/router.dart:255-258` (stub); `2026-05-18-study-plan-design.md` D9 | Pro detail for a scheduled mock | DP_PlanA (Mock exam row, no tap defined)
- Tap behavior of the Today line, "New material stops", "Mock exam" and exam rows in Coming up (only week rows drill down) | DECISIONS "View full plan" | Defines what each row opens | DP_Drill, DP_PlanA
- Plan screen when there is no exam date, month only, exam passed, no content, or before the assessment ("42 days until UPCAT" subtitle and the timeline need a date) | `lib/features/roadmap/domain/roadmap.dart:5-12` | Keeps the plan screen valid in every Home state | DP_PlanA, HP_NoDate, HP_MonthOnly, HP_ExamPassed, HP_NoContent (Home only)
- History sentences for causes with no sample: exam switched, exam date passed, no exam date set, topic order loop (prerequisite cycle), content removed | `lib/features/roadmap/domain/roadmap.dart:85-100`; `roadmap_diff.dart:80-86` | Tells the student why the plan changed | DP_History (12 sample causes only)

Notifications and prompts
- Daily reminder copy variants (standard, mock day, back after break, calm, first plan) | `lib/features/notifications/domain/notification_body_composer.dart:48-76` | Text of the phone reminder | ST_Reminders, O_Notify (switches and time only)
- Streak-save reminder copy by streak length, and streak freeze ("your streak's freeze will save it, N left this month") | `notification_body_composer.dart:84-124`; `lib/features/notifications/domain/streak_save_policy.dart`; streak reader is a stub (`lib/features/notifications/application/notifications_providers.dart:100`) | Warns before a streak breaks. Streak freezes appear nowhere in DECISIONS. | ST_Reminders ("Follow up" switch, unspecified)
- Which reminder "Follow up" controls (streak-save, come-back, or both) | DECISIONS "Reminders" | Defines the switch | ST_Reminders
- Exam countdown notifications (30, 14, 7, 3, 2, 1, 0 days; flagged-question count in the body) | `lib/features/notifications/domain/exam_countdown_schedule.dart:5`; `notification_body_composer.dart:126-147` | Reminds the student as the exam nears | none
- Come-back notification after the third missed study day, naming the subject and last score | `lib/features/notifications/domain/lapse_policy.dart:10-55`; `notification_body_composer.dart:149-` | Brings back a lapsed student | none
- One notification per day, fixed priority; losers dropped | `lib/features/notifications/domain/notification_ceiling.dart:9-33` | Avoids notification spam | none
- Notification tap routing (opens /quiz, /home, Wrapped share) | `lib/features/notifications/presentation/notification_tap_router.dart:1-68` | Decides where a tap lands now that Home is the plan | none
- In-app store review prompt: asked once ever, only after a session with 80% or more right, never within 24 hours of the paywall (not wired to any caller yet) | `lib/features/review_prompt/domain/review_eligibility.dart:22-31`; `lib/features/review_prompt/application/review_prompt_controller.dart:25-47`; `2026-08-11-contact-and-review-prompt-log.md` | Collects store ratings | none

Not checked:
- `docs/superpowers/decisions/2026-07-29-progress-tab-decision-log.md`, `2026-08-02-home-weakest-areas-log.md`, `2026-08-11-contact-and-review-prompt-log.md`, and the three notifications specs (`2026-05-22-notifications-fcm-design.md`, `2026-06-10-spec-09-...`, `2026-08-03-notification-engagement-amendment-design.md`) were not read in full. Notification rows rest on code only.
- `2026-06-10-user-facing-metrics-design.md`, `2026-06-10-spec-11-progress-amendment-design.md` and `2026-08-02-pro-entitlement-consolidation-design.md` were not read; their effects were taken from the Home and Progress specs.
- `2026-10-01-you-screens-reference.md`, `2026-10-01-tendency-confidence-design.md` and the plan files were not read (dated 1 October or later, or not behavior specs).
- Board HTML was read as extracted text only (no images, motion or still frames). Boards for MK_Past*, WR_History, QV_* and ST_Reminders belong to other families and were not opened.
- Sections of `DECISIONS.md` outside Home, More about you, View full plan, Your performance, Free and Pro and Settings reminders were skimmed, not read in full.
- `lib/core/ui/components/` and `lib/features/metrics/signals/*` internals were not read.
