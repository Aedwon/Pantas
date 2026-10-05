# The new design: behavior amendment

Date: October 5, 2026. Status: awaiting Aedwon's approval of Part A.
Policy revision read: origin/main 476b689f.
Controlling plan: `docs/superpowers/2026-10-05-engineering-restart-strategy.md` (stage 0, B3 step 3).
Decision record: `docs/superpowers/decisions/2026-10-05-engineering-restart-log.md`.
Inputs: the design handoff in `docs/design/` (boards, `SCREENS.md`, `DECISIONS.md`, `MOTION.md`),
the restart log, and the stage 0 answers (`docs/superpowers/plans/new-design/stage0-decisions.md`).
Visual companion: `docs/design/proposals/reminders-2026-10-05.html` (Reminders, version 1),
boards `ST_Reminders_v2` and `O_Notify_v2`.

This spec amends the pre-October specs where the new design or Aedwon's decisions change
behavior. It adds no visual rules of its own: the boards are the visual source, matched 1:1.

---

## Part A. Plain-language summary for approval

### What this spec does

It is the one place that says which old behavior changes for the new design. The level 2 and
level 3 plans build from it. Everything you decided today and on October 5 is in here; nothing
below is new except the three questions in "What needs your decision".

### The design is the authority

- The boards are built as drawn. Where they change an older screen, the board wins. About 310
  such changes were listed for your information in the stage 0 decision set.
- Old features with no board are kept or dropped exactly as you answered in stage 0 (items 5 to
  32). Screens and states with no board are built from the shared design rules (items 33 to 42).
- Tabs become Home, Study, Quiz, Settings. The Progress tab and its routes are retired. Your
  performance, Your record and Your tendencies open from Home. Your plan is its own screen.
- Pro buttons open the Settings Pro page and come back. The separate three-screen Try Pro flow is
  retired.

### Behavior changes already decided

1. **Mock review.** Free and Pro both see every question with the right answer and its
   explanation. Free keeps that until their next mock opens (14 days); after that their record
   shows only the score and the breakdown. Pro reopens any mock any time. Notes on misses are Pro
   only.
2. **Pro History.** The History section of Your plan ships. Its entries stay on the phone and are
   lost on reinstall until sync exists.
3. **Wrapped.** Three moments: first mock or a new best; a streak of 7, 30, 100 or 365 days; the
   day after the exam. There is no "topic turned strong" moment, even though one board still
   draws it.
4. **Dates.** "Nov 11, 2026"; this year "Oct 17"; with the weekday "Sat, Oct 17"; headings
   "Saturday, October 3"; month only "November 2026". Weeks run Sunday to Saturday.
5. **Placeholder figures.** CSE per-subject item counts and the ACET aptitude time use placeholder
   values marked in code and listed in the plans. This is a development-only exception to "never
   invent a figure". Replacing them is a release blocker.
6. **Exam switching.** The student chooses Count Them or Start My Numbers Fresh, as on the
   Settings boards.
7. **Mock results.** No best-mock pill, no confetti, no comparison sentence.

### Reminders and notifications (your answers 4, 6 to 9, 25)

| Notification | When | Student control |
|---|---|---|
| Daily reminder | Study days, at the chosen time (default 7:00 PM) | Switch and time |
| Follow up | Study days when Today is not started, at its own time (default 9:00 PM). Replaces the old streak-save reminder | Switch and its own time row (new) |
| Exam countdown | 30, 14, 7, 3, 2 and 1 days before the exam, and on exam day | Switch (new). Needs an exact exam day |
| Come back | Once, after 3 study days in a row with no session. Names a real subject and score, or is not sent | None, automatic |
| Trial ending | 24 hours before the first charge of a Monthly trial | None, automatic |

- Onboarding copy drops "Nothing else." It reads: "One daily study reminder, and a follow-up if
  you haven't started."
- No Wrapped notification. There is no one-a-day limit.
- No notification sells Pro, uses guilt, or shows a figure the app did not measure.
- Preview of the Reminders screen: `docs/design/proposals/reminders-2026-10-05.html`.

### Recorded but not shown (answers 12, 13, 28)

- The app keeps recording time per question and the inputs behind "why you miss questions"
  (your notes, whether you had it right before, how fast you answered). No screen shows them yet.
- Mocks avoid questions from the student's last two mocks. No screen involved.

### iPhone testing (answer 49)

iPhone testing is in scope for release checks, using Xcode wireless debugging because your
phone's USB-C port does not carry data. The September iPhone QA design feeds the release
checks. Wireless pairing is untested until we try it, and the iOS build itself has not been
checked in this program yet.

### What needs your decision

1. **Two study notifications in one evening.** Without a daily limit, a countdown day can bring
   the countdown, the daily reminder and the follow-up. Options:
   - (a) The countdown replaces that day's daily reminder (one message at the reminder time); the
     follow-up still comes if Today is not started. **Recommended.** It keeps the countdown's
     useful line without stacking two messages at the same minute.
   - (b) Send all of them. Simplest, but two notifications arrive at the same time.
   The same choice applies to the come-back day: (a) it replaces that day's daily reminder.
2. **Countdown when the daily reminder is off.** Options: (a) the countdown follows only its own
   switch and arrives at 7:00 PM (exam day at 7:00 AM). **Recommended.** (b) The countdown stops
   when the daily reminder is off.
3. **Follow up time.** Options: (a) the wheel only offers times after the daily reminder time.
   **Recommended**, since a follow-up before the reminder makes no sense. (b) Any time.

### Cost and risk

- The notification set adds a small amount of work to Settings and the reminder service; most of
  it already exists in code.
- iPhone testing adds an iOS build check and wireless setup to the release checks. If the iOS
  build has problems, that becomes new work found at level 2.
- Retiring the Progress tab and the Try Pro flow removes code; the plans must confirm nothing else
  depends on it.

### How completion is judged

Each screen matches its board 1:1 in the states drawn, checked by you on your phones. Behavior
in this spec is covered by automated tests named in the level 3 plans. Every board, decision and
gap answer maps to one task in the traceability table, and both gate reviews pass.

---

## Part B. Agent section

### B1. Superseded sections of older specs

Older specs keep their behavior, content, figures and Free and Pro rules except where listed.
Visual sections of every pre-October spec are already superseded (AGENTS.md, visual direction).

| Older spec | Superseded part | By |
|---|---|---|
| `2026-07-26-home-and-navigation-design.md` | Masthead, tab set (Progress tab, Settings via gear), Up next, Practice panel, stats band, tendencies deck | Home boards; A "design is the authority" |
| `2026-07-30-progress-tab-design.md` | The tab itself, Your pace, Time column, Why you miss questions (display only), table sort and filter | DT_*, YR_*, YO_* boards; stage 0 items 11 to 13 |
| `2026-08-04-study-plan-forward-calendar-design.md` | Plan screen layout, Free/Pro split, untappable days, Monday weeks | DP_* boards |
| `2026-05-17-quiz-engine-and-modes-design.md` | Commit on tap, verdict line, return promise, post-answer toast | QV_*, QN_* boards; stage 0 item 14 |
| `2026-07-28-quiz-tab-design.md` | Session panel, study-first sheet, flagged section form, debrief layout, miss cause lines | QZ_*, QV_End* boards; items 5, 14, 17 |
| `2026-07-28-mock-exam-ui-design.md`, `2026-05-17-mock-exam-design.md` | Setup, clock, proctor times, part transitions, strict grace (5 s to 10 s), results, review gating, flag offer | MK_* boards; A1, A2 |
| `2026-08-03-settings-design.md`, `2026-05-22-settings-account-design.md` | Root structure, sheets, sign-out wipe copy, delete flow layout | ST_* boards |
| `2026-08-03-paywall-pricing-and-flow-design.md`, `2026-05-21-paywall-entitlement-design.md` | `/paywall` flow, plan recommendation, cost-through-exam, trial on Yearly, milestone sign-in prompts | ST_Pro* boards, `docs/pricing.md`; items 23 to 24 |
| `2026-08-03-notification-engagement-amendment-design.md` | Section 4 ceiling (removed), Section 6 single control (replaced by switches), `streakSave` (replaced by Follow up) | Part A, Reminders |
| `2026-06-10-user-facing-metrics-design.md` | Lately atoms on Home, mastery-crossing Wrapped, Wrapped slide arcs and share card | Item 10; WR_* boards; restart log decision 3 |
| `2026-05-11-assessment-flow-design.md` | Up to 35 questions, tap commits, results by topic, revisitable results, nudge | AS_* boards (30 questions); item 18 |
| `2026-05-16-onboarding-exam-selection-design.md`, `2026-08-02-onboarding-name-and-date-design.md` | Step order, no back, wheels, name Skip, reminders as a separate page | O_* boards |
| `2026-07-27-study-tab-and-reader-design.md` | Head block, coverage, reader type, pull handle, endings layout | ST_*, RD_*, BM_* boards |

### B2. Notification rules (exact)

- Kinds: `dailyReminder`, `followUp` (replaces `streakSave`), `examCountdown`, `comeBack`,
  `trialEnding`. `wrapped` push is removed; Wrapped opens in app on the next launch after its
  event. The ceiling in `notification_ceiling.dart` is removed.
- Daily reminder: study days only, chosen time, default 19:00.
- Follow up: study days only; fires at its time if no session started that day; default 21:00;
  time picker limited to after the daily time (pending decision 3); shown only while on.
- Exam countdown: ladder 30, 14, 7, 3, 2, 1, 0 days, day precision only (`ExamDate.day` non-null);
  fires on any day, study day or not. Copy per the August amendment Section 2: count line, then one
  real thing to do or nothing; exam day "Today's the day." / "Good luck." Time per decision 2.
  Interaction with the daily reminder per decision 1.
- Come back: after 3 consecutive study days with no session; once until a session happens; at the
  daily reminder time (or 19:00 if off); names a measured subject and score or is not sent. Per
  decision 1 it replaces that day's daily reminder.
- Trial ending: local, 24 hours before the first Monthly trial charge, text matches HP_Trial
  ("Google Play charges ₱99 on Oct 2 to keep Pro. Cancel any time before then."). Cancelled when
  the trial is cancelled or converts.
- Permission denied: nothing is sent; Reminders shows the approved blocked state.
- Tap routing: daily, follow up and come back open Home; countdown opens Home; trial ending opens
  Settings › Pantas Pro.

### B3. Data recorded without a screen

- Keep per-attempt response time and per-session timing (already stored); keep mistake tags
  including `other` with optional text (DECISIONS "Quiz screens"); keep blank reasons from mock
  review. Do not drop inputs that `miss_causes_provider.dart` and the Time column read, even
  though their widgets are deleted.
- Mock sampler recency filter: pass the question ids of the student's last two finished mocks for
  the same exam (today an empty set is passed).

### B4. Workstream mapping

| Part A item | Workstream |
|---|---|
| Tabs, retire Progress routes, retire `/paywall` | W1 (shell), W4b, W4f |
| Mock review gating, mock results, recency filter | W4e |
| Pro History, Your plan | W4b |
| Wrapped three moments, WR_History row fix | W4g |
| Date format helpers | W1 |
| Placeholders | W4e (mock setup), content formats via W0 |
| Exam switching choice | W4f, W3 for entitlement on pricier exams |
| Notifications and Reminders screen | W4f (screen), W4b (Home tap targets), W3 (trial-ending trigger) |
| Recorded-only data | W0 confirms storage; W4b and W4d keep writes |
| iPhone testing | W5 |

### B5. Open items carried to level 2

- iOS build state on `integration/new-design-r1` is unverified; W5 level 2 records the check.
- Lesson-scoped in-lesson quiz needs lesson ids on questions; W0 confirms whether
  question-qa-r2 content carries them.
- `DECISIONS.md` and `SCREENS.md` still say four Wrapped moments; plans follow this spec.
