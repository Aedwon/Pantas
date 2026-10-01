# Pantas UI round: design brief for the adaptive roadmap

**Date:** 1 October 2026
**For:** the UI round (Claude Design and the visual companion). This is input, not an approved
design. Nothing here fixes layout, wording or placement; those are Aedwon's.
**Grounded in:** the approved roadmap spec
`docs/superpowers/specs/2026-09-30-adaptive-roadmap-design.md`, the Free/Pro source of truth
`docs/superpowers/specs/2026-08-02-pro-entitlement-consolidation-design.md`, the account
boundary `docs/superpowers/specs/2026-08-28-firebase-runtime-account-boundary-design.md`, and the
built engine on branch `web/roadmap-engine-r1` (`lib/features/roadmap/`).

---

## 1. What the student should feel

- They open the app and see today's plan. Nothing to set up or decide.
- The plan adjusts quietly. A missed day spreads its work over the days left; extra work makes
  later days lighter. No messages about it on the main surfaces.
- Today stays put: once built it never reshuffles while they work. Items tick off as done.
- Motivation comes from facts, not verdicts: today done, days in a row, how much of the material
  is covered.

---

## 2. Rules every design must keep

### Figures and words

- **Never invent a figure.** A number on screen is measured from the student's own use, published
  by the testing body, or the output of the plan's stated arithmetic. Nothing projected.
- **No number for any week after the current one.** Later weeks show topics only.
- **Banned words anywhere a student reads:** "behind", "ahead", "on track", "ready", "mastery".
  Also "FSRS", "stability", "retention", "retrievability", "algorithm", "cards" (use
  "questions"), "marks" (use "points").
- Simple English, short sentences, American spelling, no em dashes.

### How a Pro gate behaves

These are tier rules from the entitlement spec and stay:

- The heading and the comparison labels always show; only the gated figures or content are
  withheld.
- An "Unlock with Pro" action appears once per screen at most, after the free content, never
  before it.
- Never a whole hidden panel, except "Why you miss questions" on Progress.
- A Free student who opens a Pro-only route goes to the paywall, never a 404.

---

## 3. The app today (navigation)

- **Bottom tabs:** Home, Study, Quiz, Progress.
- **Settings** is a pushed screen (`/settings`, with sub-screens: sessions, exam, exam change,
  included topics, account, account delete, Pro, subscription, backup, about, legal).
- **Other full screens:** onboarding (exam, custom track name and subjects, name, exam date),
  assessment and its results, lesson reader and study ending, quiz session, debrief, results,
  review, flagged, practice picker and run, retake, inline lesson quiz, mock setup, start,
  resume, custom setup, results, review, mock history, paywall, Wrapped, update required,
  notification rationale.
- **Removed in this build:** the old `/plan` page (it never worked). The roadmap screen is new.
- **Placeholder, untouched:** `/plan/dossier/:mockId` (a Pro mock dossier stub).

Proposed and not yet decided: merge Progress into Home, and make Settings its own tab (Section 12).

---

## 4. What the engine gives the UI

Everything below exists in code now. Designs may show any of it; none of it may be restated
with invented extras.

### Every day

| Item | Meaning | Free | Pro |
|---|---|---|---|
| Today's lessons | Ordered list of lessons to read today (titles, subject, minutes) | Yes | Yes |
| Today's reviews | Questions due today, most likely remembered first | Yes | Yes |
| Today's new questions | Unseen questions for today, after their lessons | Yes | Yes |
| Counts | Lessons, reviews, new questions; each ticks down as done | Yes | Yes |
| Sittings | The day's questions split into sittings of the student's session length (5, 10, 20 or All; default 10) | Yes | Yes |
| Mock day flag | True on the day the plan schedules the mock | Yes, on the day | Yes |
| Today done | All of today's own items are done | Yes | Yes |
| "I want to advance" | Available only when today is done; pulls in tomorrow's lessons and new questions (never reviews) | Yes | Yes |
| Exam date and days left | From Settings; days left is a real count | Yes | Yes |

### Beyond today (Pro only on screen)

| Item | Meaning |
|---|---|
| Weeks ahead | For each week until review-only days start: which topics come, in order. Topic names only, no counts |
| Review-only date | The day new material stops; only reviews and the mock after that |
| Mock date in advance | The scheduled mock day |
| Change log | What changed and why (causes in Section 7), newest first, with the day's counts before and after where they were real |

Free students still get all of this behavior; they just do not see ahead or see the log.

### Timing facts the design should respect

- The review-only stretch is the last 7 days or the last quarter of the time left, whichever is
  shorter, and it stays fixed once the plan starts.
- The mock falls 1 to 6 days before the exam, never on exam day. Free students' one-mock-per-14-
  days limit can move or remove it.
- A day starts at local midnight, the same as the streak.
- **Study days.** The student picks which weekdays they study (at least one). Rest days get no
  work at all. New material is spread over study days only; reviews that come due on a rest day
  wait for the next study day; the mock always lands on a study day (if its window has none, no
  mock is scheduled). Students who never picked have all seven days.

---

## 5. Every state the roadmap can be in

Each needs a designed appearance on every surface that shows the plan.

| State | When | What the plan does | UI needs |
|---|---|---|---|
| Needs assessment | The student has not taken the short assessment | No plan | The existing "take the assessment" start; the plan cannot show counts |
| No content | The chosen exam has no lessons or questions | No plan | The existing unavailable state |
| Planning | Normal days before the review-only date | Lessons, reviews, new questions | The normal day |
| Review only | On or after the review-only date | Reviews and the mock only; leftovers spread over the last days if behind | A calm review-only day; no new-material counts |
| All covered | Every lesson read and question seen | Reviews only | Covered state; advance has nothing to add |
| Exam date is a month, and that month has started | Month-only date, month in progress | Plans to the month's last day | Ask once for the exact day (design the prompt) |
| Exam date passed | Day is past, or the month is over | Reviews only | Ask once whether they took it: new date, or switch exams (design the prompt) |
| No exam date | Should not happen after onboarding | Reviews only, no pacing | A fallback that asks for a date |
| Exam today | Exam is today | Reviews only | Exam-day state |
| Mock day | The scheduled mock day | Today includes the mock | Mock-day emphasis on today |
| Rest day | Today is not one of the student's study days | Nothing: no lessons, new questions, reviews or mock | A rest-day Today; advance offered at once; practice and lessons still open |

Also design:

- **Day in progress:** some items done, counts ticking down.
- **Today done:** the "today done" moment, then the advance action.
- **Advanced:** extra items added after today was done. If the student stops partway, what they
  did counts and today still counts as done. Advanced items never turn a day into missed work.
- **Nothing scheduled on a study day:** possible in the review-only stretch, once everything is
  covered, on exam day and after it, when no reviews are due and it is not the mock day. This is
  not "today done" (work was scheduled and finished); the two need different wording.
- **Whether advance is offered:** the engine says whether advance would add anything right now
  (it would not in the review-only stretch, once everything is covered, or before today's work
  is done). Show advance only when it would. In the review-only stretch or when everything is
  covered, offer free practice of the weakest topics instead (outside the plan; it does not earn
  a streak day). After the exam date, the "did you take it?" prompt takes that place.
- **Advance on a rest day:** brings in the next study day's lessons and new questions, plus
  reviews already due. Whatever the student does counts, including toward the streak.
- **Backlog after an absence:** today holds as many reviews as the student usually does in a day;
  the rest wait. Nothing tells them they fell behind.

---

## 6. Every surface the roadmap touches

### Quiz tab: today's session panel (exists)

States, in the order the panel checks them:

1. **In progress:** a sitting was left partway. Shows position and total, topic name. Resume.
2. **Needs assessment:** shows the assessment's real question count. Start the assessment.
3. **Available:** the next sitting. Shows its makeup (for example "4 due, 6 new") and question
   count, and the student's own average minutes once they have 7 finished sessions (never an
   estimate before that). Start.
4. **Caught up (today done):** answered and correct today. Today this is where advance belongs.

Open for the UI round: showing the whole day (for example "33 questions today, 4 sittings")
above the sitting, and where advance sits.

### Home (exists)

- **Up next:** today's remaining lessons from the plan, in plan order, with subject and minutes.
  When all of today's lessons are read it empties; a separate state says every lesson in scope is
  read.
- **Practice panel:** three weakest topics with figures (free). Tapping one starts practice for
  that topic, outside the plan.
- **Tendency deck:** four cards; Free sees labels, Pro sees figures.

### The roadmap screen (new; not designed yet)

Free:
- Today section: the same day as the Quiz tab, in more detail.
- "Coming up" and "What changed" headings with their content withheld, and one "Unlock with Pro".
- On mock day only, the mock appears under today.

Pro:
- Today section.
- Weeks ahead: topics per week, no counts, nothing placed on rest days; the review-only date; the mock date; the exam.
- What changed: the log (causes in Section 7), newest first.

Decide: where it lives (its own tab, inside Home, or pushed from Home and Quiz), and how the
student reaches it.

### Lesson reader (exists)

- A lesson counts as read only when the student reaches the end and has stayed at least 15
  seconds. Reading one from Study counts toward the plan.
- Reserved for the UI round: "2 of N" showing its place among today's lessons.

### Daily reminder (exists)

- Uses today's remaining review count; a mock-day version on mock day. Copy is for the UI round
  and must avoid the banned words.
- Fires on study days only, as does the "save your streak" reminder. The "come back" reminder
  counts only missed study days. The exam countdown is unchanged.

### Streak (exists)

- Rest days are invisible to the streak: skipping one neither breaks it, adds to it, nor uses a
  freeze. Working on a rest day counts as a streak day.

### Onboarding: study days (new; Aedwon has designed it)

- "Which days will you study?": seven weekday toggles, Sunday first, none picked at first.
- Continue is disabled until at least one day is picked; "Every Day" picks all seven.
- With days picked, a summary of the count and what happens to off days.

### Settings (exists)

- **Session length:** 5, 10, 20, All. This sets sitting size, not the day's amount.
- **How sessions are built:** one topic only, mostly one topic with some others (default), fully
  mixed. Copy must now describe proportions of a sitting, not "all 10 questions" or "seven from
  the topic, three from others". Vocabulary questions are always kept together.
- **Exam date:** a day or a month. Changing it rebuilds the plan at once.
- **Study days (new):** the same seven toggles; at least one must stay picked (the last picked
  day cannot be turned off). Changing them rebuilds today at once; what was done still counts.
- **Included topics:** excluding a topic removes it from the plan.
- There is no "Do more each day" switch; advance replaces it.

### Mock (exists)

Availability states: available; in progress (resume); cooldown for Free (next mock in N days,
a real count); no mock for this exam. Custom tracks use their own mock. Mock answers now count as
ordinary answers: missed mock questions come back as reviews in the following days.

### Progress (exists)

Accuracy and questions answered now include mock answers. The Pro/Free rows are in Section 8.

---

## 7. Change log causes (Pro)

The engine records one of these for each change. Wording is for the UI round; each entry may
show the day's lesson, new-question and review counts before and after, and the first topics in
the order before and after. None states a verdict.

| Cause | Plain meaning |
|---|---|
| New day | A new day's plan was made |
| Missed work | Yesterday had items left; they were spread over the days left |
| Advanced | The student added tomorrow's items to today (and how many they finished) |
| Exam date changed | The date moved; days were resized |
| Exam changed | The student switched exams |
| Topics changed | Topics were included or excluded |
| Content changed | New or removed lessons or questions |
| Order changed | Recent results moved which topic comes first |
| Reviews capped | More reviews were due than one day holds; the rest wait |
| Assessment done | The first plan was made from the assessment |
| Exam passed | The exam date has passed |
| Study days changed | The student changed their study days; days were resized |
| Mock answers recorded | Missed mock questions joined the reviews |
| Prerequisite loop, no exam date | Internal safeguards; likely never shown to students |

Example of acceptable wording (tone only): "Away 5 days. New questions went from 14 to 15 a day."

---

## 8. Free and Pro, every surface

Three gates: **Gate 1, Pro interprets** (Free sees what happened, Pro sees what it means).
**Gate 2, Pro gets the instrument** (Free gets the answer, Pro gets the tool to ask their own
questions). **Gate 3, Pro lifts the volume cap** (mock only). **Nothing the student produced is
ever paywalled.**

| Surface | Free | Pro adds | Gate |
|---|---|---|---|
| Lessons, reader, Study map | Everything | Nothing | none |
| Bookmarks and flags | Unlimited, and practice from them | Patterns across them, custom ordering, notes | 1 |
| Practice picker, today's session, Your mistakes | Unlimited | Nothing | none |
| Answer reveal | The mark, the verdict, note A, when it comes back | Note B, addressed to the choice they picked | 1 |
| Session debrief | Score, figures, every miss, when each comes back | Likely cause per miss, and tagging | 1 |
| Review screens (practice or mock) | Every question, correct answer, note A | Note B | 1 |
| Mock exam | One every 14 days | Unlimited | 3 |
| Home: practice panel | Three weakest topics, with figures | Nothing | none |
| Home: tendency deck | Four cards, both labels, figures redacted | The figures | 1 |
| Progress: Your pace | Everything | Nothing | none |
| Progress: Performance | Subject rows, both figure columns | Topic and lesson levels, subject filter | 2 |
| Progress: Why you miss questions | Redacted whole | Three counts, where misses cluster, misreads they noted | 1 |
| Progress: How you work | Five headings, ten labels, figures redacted | The figures, and "When you work" | 1 |
| Progress: Your record | Everything | Nothing | none |
| **Roadmap: today** | Everything: amounts, order, backlog handling, sittings, advance, the mock on its day | Nothing | none |
| **Roadmap: weeks ahead, review-only date, mock date in advance** | Heading only | All of it | 1 |
| **Roadmap: change log** | Heading only | All of it | 1 |
| **Study days** (onboarding, Settings, rest days in the plan, streak, reminders) | Everything | Nothing | none |
| Cloud backup and sync | No (history lives on the phone) | Yes, with a Google sign-in | account |
| Mock dossier (`/plan/dossier/:mockId`) | Paywall | Placeholder, no design yet | n/a |

Remember one teaser per screen: a roadmap screen with both "Coming up" and "What changed" gated
still gets only one "Unlock with Pro".

### Account and tier states

| State | Plan | Backup | Notes |
|---|---|---|---|
| Anonymous Free | Full today | None | Default first run |
| Signed-in Free | Full today | None | Signing in does not turn on backup |
| Pro without sign-in | Full today, weeks ahead, log | None until signed in | Only if purchase without sign-in is allowed; check the paywall flow spec. If so, a prompt to sign in for backup |
| Signed-in Pro | Everything | On | Change log backs up in a later build (deferred this build) |
| Pro expired | Back to Free view | Stops; nothing deleted | Returning to Pro reconnects |
| Yearly trial | Pro | As Pro | Trial is Yearly only, 7 days |

Pricing: Weekly ₱29, Monthly ₱99, Yearly ₱799 (Yearly trial 7 days). No lifetime option.

---

## 9. Generic states every new or changed screen needs

- **Loading:** the plan is built on the phone and loads fast; it still needs a loading state.
- **Error:** the existing error banner; the plan is built on the phone, so errors are rare.
- **Offline:** everything in the plan works offline. Only backup and purchases need a connection.
- **First run:** before the assessment there is no plan.
- **Empty:** no content for the exam; all covered; today done.
- **Disabled or hidden actions:** advance appears only when today is done (hidden, not greyed,
  before that unless the design argues otherwise); Start is replaced by Resume when a sitting is
  open; the mock start is unavailable during Free cooldown and shows the real date it opens.
- **Accessibility:** TalkBack labels, large text up to 200 percent, 48dp touch targets, contrast.
  Existing screens were built to these; release acceptance of them is still open (SSOT A05), and
  new screens must meet them too.

---

## 10. Numbers: allowed and not

Allowed: today's counts, days left to the exam, the review-only date, the mock date, days in a
row, lessons read, questions answered, the student's own average minutes after 7 sessions,
counts before and after in a log entry.

Not allowed: any count for a future week, a projected score or pass chance, "ready" percentages,
estimated minutes before 7 sessions, a "how far behind" figure.

---

## 11. Decisions the UI round still owns

- Where the roadmap screen lives and how it is reached.
- The "today done" moment and where advance sits; final wording for advance.
- Showing the whole day versus the next sitting on the Quiz tab.
- The change log viewer: list, grouping, wording per cause.
- The month-started and exam-passed prompts, and whether switching exams asks for a new date.
- The reader's "2 of N".
- Settings copy for "How sessions are built".
- Whether to merge Progress into Home and make Settings a tab (Section 12).
- The rest-day Today on every surface that shows the plan, and the Settings study-days control.

---

## 12. Proposed navigation change: notes for the designer

Merging Progress into Home and making Settings a tab is technically straightforward. Keep in mind:

- Home already carries Up next, the practice panel and the tendency deck; Progress adds Your pace,
  Performance, Why you miss questions, How you work and Your record. Plan for length and for the
  one-teaser-per-screen rule, which becomes harder with more gated sections on one screen.
- The roadmap screen may compete for the same space; decide both together.
- Settings as a tab is unusual for a study app but acceptable; it has many sub-screens today.
- Every approved design becomes an implementation requirement matched 1:1, so each state above
  needs to be shown in the visual companion before it is built.
