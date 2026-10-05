# Stage 0 decisions: gap pass and kept work

Date: October 5, 2026. Strategy B3 steps 1 and 2. Policy revision: origin/main 6d508d70.
Status: waiting on Aedwon.

Sources: eight gap passes (one per screen family) and one kept-work inventory, gathered by
Sonnet workers and merged by the lead. The raw lists, with file and board evidence for every row,
are in `stage0/` next to this file.

How to answer: reply with the numbers you change. Anything you do not mention takes the
recommendation. "All recommendations" is a valid answer.

---

## Part A. Your decisions

### A1. Places where the design disagrees with itself

| # | Conflict | Recommendation |
|---|---|---|
| 1 | Switching exams. The older board (L_ChangeExam2, 1 Oct) carries everything over with no choice. The Settings boards (ST_ExamSwitch, 4 Oct) offer Count Them or Start My Numbers Fresh. | Use the 4 Oct Settings boards: the student chooses. Keep the older board's "Rebuilding your plan" wait and the "date kept" confirmation. |
| 2 | Mock score. The 1 Oct note asks for confetti, a "Your best mock yet" pill and a sentence comparing with the last mock. The 3 Oct note and every results board show none of these. | Follow the 3 Oct boards: no pill, no confetti, no comparison sentence. A new best is celebrated by its Wrapped. |
| 3 | The icon board lists a lock icon for "Locked until Pro". The Free and Pro rule says no locks anywhere. | No lock icon. Use the small Pro tag as drawn. |
| 4 | Reminders. Onboarding shows Follow up "at 9:00 PM" and "Tap a time to change it". Settings shows only a switch. The old streak-save reminder is not mentioned anywhere. | Follow up replaces the old streak-save reminder. It fires at 9:00 PM on study days when Today is not started. Its time is fixed, so no time row in Settings. |

### A2. Old features with no board: keep or discard

| # | Feature today | What it does | Recommendation |
|---|---|---|---|
| 5 | Flagged questions list: see, remove and practice flags | The only place to manage flags. The quiz boards point to it ("Done goes back to Flagged questions") but never draw it. | **Keep.** Build it like the mock's All questions list. The current "Practice these" button is already broken. |
| 6 | Exam countdown notifications (30, 14, 7, 3, 2, 1 days, exam day) | Reminds the student as the exam nears | **Discard.** The approved onboarding copy promises "One daily study reminder, and a follow-up if you haven't started. Nothing else." |
| 7 | Come-back notification after 3 missed study days | Brings back a student who stopped | **Discard**, same reason as 6. |
| 8 | Wrapped-ready notification | Opens a Wrapped from the phone | **Discard**, same reason as 6. A Wrapped opens the next time the student uses the app. |
| 9 | One-notification-a-day limit | Avoids spam | **Discard.** With 6 to 8 gone, only the reminder and its follow-up remain. |
| 10 | "Lately" line on Home: one rotating fact a day (sharpest hour, streak, pace) | Small daily motivation | **Discard.** Home was redesigned without it. Recorded as an idea for later. |
| 11 | Lessons read out of total on Home ("3/46") and the "Your pace" panel ("At 3 lessons a week you finish 9 days after the exam") | Shows reading coverage and whether the pace is enough | **Discard.** The roadmap now sets the pace, and the Study map dropped coverage on purpose. |
| 12 | Time per question column in performance tables (from mocks) | Speed by subject, topic, lesson | **Discard for now.** Your performance shows accuracy only. Idea for later. |
| 13 | "Why you miss questions" section (Pro): had it right before, never seen it, answered too fast, plus the student's own notes | Explains patterns in mistakes | **Discard for now.** Notes are still collected (Pro). Showing them back is an idea for later. |
| 14 | Pro cause line under each miss at the end of a session ("You answered in 4 seconds. You usually take 21.") and "You'll see all three again tomorrow." | Explains a miss; says when it returns | **Discard.** The design shows no cause line and bans "back in X days". |
| 15 | Spaced-repetition explainer paragraph ("Pantas shows a question again just before you would forget it") | Explains why questions come back | **Discard.** No board has it. |
| 16 | "Try a quick quiz" before the assessment | Lets a new student practice without the assessment | **Discard on Home and Quiz**, as drawn. Keep the quick quiz only behind "Try a Quick Quiz" on the "Nothing to study yet" Study screen, which a board shows. |
| 17 | "Study first for better results" sheet before the first quiz | Nudges reading first | **Discard.** No board, and the plan already puts lessons first. |
| 18 | Assessment nudge after quizzes 1, 3 and 5; "Your plan is ready" moment after onboarding | Pushes the assessment; marks the plan | **Discard.** Neither was ever built, and the new Home shows only the assessment card until it is done. |
| 19 | Store rating prompt: asked once, after a session with 80% or more right, never near a Pro page | Collects Play Store ratings | **Keep.** It is the phone's own dialog, so it needs no board. Your August note asked to test it in beta. |
| 20 | Choice after sign-in when both the phone and the account hold progress: Keep my account / Keep this device | Stops the app overwriting the wrong copy of a student's progress | **Keep.** Build it as a centered dialog from the shared rules. |
| 21 | "Delete my data" for a student who never signed in | Lets anyone erase their data (Data Privacy Act) | **Keep.** Add the row to the signed-out Account screen, using the delete screen as drawn, with the phone-only line. |
| 22 | In-app data export | Data portability | **Discard**, as decided in May: requests go to the data protection officer row in About. |
| 23 | Sign-in prompts at milestones (after the first mock, after a 3-day streak) | Invites a student to sign in | **Discard.** Your 1 Oct decision: sign-in happens only from Settings. |
| 24 | Separate three-screen "Try Pro" flow (what Pro adds, plans with cost through your exam date, trial timeline) and the plan recommended by exam date | Sells Pro | **Discard.** Every Pro button opens the Settings Pro page as drawn and returns to where the student was. Google Play shows its own trial terms at checkout. |
| 25 | Trial-ending phone notification 24 hours before the charge | Prevents a surprise charge | **Discard.** The Home notice "Google Play charges ₱99 on Oct 2" covers it, and 6 explains the one-reminder promise. |
| 26 | Mock: "Next blank" and "Next flagged" shortcuts in the questions sheet | Finds unanswered questions fast | **Discard.** Never wired, and the sheet shows blanks already. |
| 27 | Mock: a "Strict" badge on a finished mock | Records the strict setting | **Discard.** Not drawn. |
| 28 | Mock: avoid repeating questions from the student's last two mocks | Keeps repeat mocks fresh | **Keep.** No screen involved. |
| 29 | Mock: line on setup when the question bank cannot fill a part ("This mock has 230 questions instead of 250") | Honest length before the clock starts | **Keep**, as one line under the setup table. |
| 30 | Bookmark ribbon on a Study topic that holds a bookmark; bookmark notes for Pro | Marks topics; lets Pro annotate | **Discard.** Not drawn; bookmarks are free and simple. |
| 31 | Wrapped: a small message after an ordinary mock (not first, not a new best) | Acknowledges every mock | **Discard.** Not drawn. |
| 32 | Choose your exam fallback on Home and Quiz when no exam is active | Recovers a broken setup | **Keep**, using the Study "Choose your exam" board on every tab. |

### A3. States the boards do not draw, built from the shared rules

These have one sensible answer. Approving this item approves all of them. Details are in the
agent section, B3.

| # | Group | Lead's default |
|---|---|---|
| 33 | Loading, error and empty states on screens without a board (Home, Quiz tab, Your record, search, flagged list, Wrapped, Shared links, legal pages, custom-track subjects, assessment) | Shapes only if slower than 300 ms. Failures show "Could not load your X." and Try Again. Never show raw error text. |
| 34 | Save failures (onboarding steps, answers, mock progress, exam pick) | One calm line in place with Try Again. Nothing the student did is lost. |
| 35 | Pro page states not drawn: trial running, canceled but active until a date, a giveaway grant, an unknown plan, a billing problem, store errors, "Manage" failing to open | Same Pro page layout; the Your plan rows say what is true ("Ends Nov 30", "Trial, charges Oct 2", "Gift, ends Dec 31"). |
| 36 | Account edges: sign-in canceled or failed, sign-out while offline, fresh sign-in required before deletion, deletion failed, after deletion | Plain line with Try Again. After deletion the app returns to Welcome. |
| 37 | Mock edges: system back during a paper, reopening the app mid-mock, time ran out while closed, broken saved mock, exams with unpublished timing | Back acts like pause (strict off) or is blocked with a line (strict on). Reopening resumes the paper with the clock having run. Time ran out while closed goes to results. A broken saved mock offers Discard. Unpublished timing runs as one block. |
| 38 | Mock setup choices: the strict switch on setup applies to this mock only; "Don't show this again" is remembered on the phone | As stated. |
| 39 | Custom-track mock card on the Quiz tab ("Set one up", "Change the setup") and reopening a saved setup with its values | Keep both. The current form forgets saved values, which is a bug. |
| 40 | Wrapped edges: how it first opens (on the next app open after the event), tap or swipe through slides with a close button, slides with no data are skipped, no name means no name switch, no exam date hides "Week of prep", sharing again reuses the same link, deleting the account removes shared links | As stated. |
| 41 | Study edges: Resume hidden until a lesson was opened, search also matches topic names, tables and passages in lessons, code-drawn figures get the same frame and expand as images, a lesson counts as read after reaching the end and 15 seconds on screen | As stated. |
| 42 | Navigation: tapping the active tab returns to its top; each tab keeps its place; old links redirect | As stated. |

### A4. Kept branches, worktrees and stashes

From 43 items: 6 keep, 30 discard, 7 for you. Nothing is deleted until you answer, and every
discarded item's unique changes are first saved to one archive branch so they stay recoverable.

| # | Item | Recommendation |
|---|---|---|
| 43 | Keep: four release end-to-end tests (Firebase sync, mock resume, quiz state and delete, shipping cold start), the 6 Sept quiz-loading spec from stash 0, and a 5-line fix that refreshes Today after a custom assessment | **Keep.** Move them into the integration branch's plan: tests to W5, the fix to W4d, the spec to `docs/` as a record. |
| 44 | Discard: 30 items fully contained in the integration branch, superseded by it, or generated noise (including uncommitted work in two old worktrees, whose later versions are in the integration branch) | **Discard**, after saving their patches to the archive branch. |
| 45 | Phone benchmark harness from the low-end performance work (untracked) | **Archive, then discard.** The low-end gate was dropped on 1 Oct; the Redmi smoke check needs no harness. |
| 46 | Extra accessibility checks for inline math (70 lines, uncommitted) | **Keep** in W2's math rendering tests. |
| 47 | Backup branch from today's attribution rewrite | **Discard.** Every commit is on main. |
| 48 | Beta consolidation planning documents (Sept) | **Archive, then discard.** History only. |
| 49 | iPhone QA enablement design (Sept, not started) | **Archive, then discard**, unless iOS testing is in scope for beta. Tell me if it is. |
| 50 | Landing page design documents (Sept) | **Leave untouched.** They belong to the website, which you direct, not to this program. |
| 51 | Illustration visual review ledgers (Aug) | **Archive, then discard.** The outcomes are already applied. |

---

## Part B. Agent section

### B1. Changed by the design, for information

Built as drawn; listed so nothing changes silently. Full rows with evidence: `stage0/gap-*.md`,
section A of each (about 310 rows). The most consequential:

- Tabs become Home, Study, Quiz, Settings; Progress is retired into Home; Settings is a tab.
- Home is rebuilt around the roadmap: week strip, Today checklist with sheets, notices, I Want to
  Advance, Your plan with Coming up and History (Pro), Your performance, Your record, Your
  tendencies. The weakness bucket left today's plan in the 30 Sep roadmap spec.
- Onboarding gains Back, a progress bar, Study days, Name, Reminders; Terms is its own step; the
  exam picker is grouped with Coming soon rows; exam today is allowed.
- The assessment is 30 questions, pick then Next, results by subject, shown once.
- Quiz: pick then Check; floating bottom bar; no verdict words; sessions of the chosen length;
  Customize your own counts every lesson the same; Report a question is new.
- Mock: setup table with a strict switch; centered clock and time bar; proctor calls at 10, 5, 1;
  a between-parts screen; pause with "Don't show this again"; strict grace 10 s; per-exam scoring
  (UPCAT minus a quarter per wrong); new results and finale; Free review until the next mock;
  notes and blank reasons in review (Pro).
- Settings: new structure, study days, session length, text size, Appearance, Pantas ID,
  backup states and Back Up Now, tiered prices with trial on Monthly only, Season Pass, upgrade
  on switching to a pricier exam, no sheets.
- Wrapped: three moments with their own slide arcs, a share screen with three switches, shared
  links in About, Pro history in Your record.
- Loading in three tiers; one app-wide error screen; update screen with the logo; Phosphor icons;
  dark mode on the main screens.

Lesson figures, passages, and tables keep working through the new reader.

### B2. Defects found in the current app (fixed by building the design)

- Flagged list "Practice these" opens a route that does not exist.
- Study map "See all" bookmarks does nothing; the bookmarks sheet is unreachable.
- The topic ending pages have no caller; the last lesson has no pull.
- Home never opens the reader with the Home origin, so the day counter and day rail never show.
- The lesson quiz uses the topic's first five questions, so every lesson in a topic gets the same
  quiz.
- The mock pause warning shows every time because its seen flag is never stored.
- Several screens print raw exception text to students.
- The custom mock form forgets saved values.

### B3. Detail for A3 defaults

Every row in section B of `stage0/gap-*.md` maps to a decision above or to an A3 group. The
traceability table (B3 step 4) records one row per gap item with its decision number, so the
mapping is checkable. Items in no decision above: none intended; the traceability build will flag
any it finds.

Copy for A3 states follows the nearest approved board: titles stay, a faint icon, one line,
tinted Try Again (the Your tendencies error board), and "Something went wrong. / Nothing you've
done is lost." for whole-app failures.

### B4. Also noted for the spec update

- `docs/design/DECISIONS.md` and `SCREENS.md` still say Wrapped has four moments, and board
  WR_History draws a "turned strong" row. Both follow the restart log (three moments) when built.
- RD_Plan's pull label after the day's last lesson follows the 2 Oct states rule ("Pull up to
  finish today").
- The reader's lesson quiz becomes lesson-scoped, which needs lesson ids on questions; the content
  track owns that data.
