# Decision log: the plan audit round, 3 August 2026

Covers the audit of every spec and plan in `docs/superpowers/`, the conflicts it found, and
the rulings on them. Audit document: `2026-08-03-plan-audit.md`. Checklist:
`2026-08-03-launch-checklist.md`.

Appended to as the round goes. Earlier entries are never rewritten.

---

## Round 1, 3 August: six conflicts put to Aedwon

I put five conflicts to him with options and costs, and noted a sixth that needed no ruling.

### C1: `ExamDate` is defined twice, incompatibly

`2026-08-02-onboarding-flow-and-new-steps.md` Task 1 and `2026-08-03-settings-02-storage.md`
Task 1 both **create** `lib/features/settings/domain/exam_date.dart` with different
constructors and different getters. Six plans read one API or the other.

| Option | Cost |
|---|---|
| **A. Union type on onboarding's names.** `onDay` / `inMonth` / `day`, plus settings' `monthStart`. | Amend settings 02, 03, 04. |
| B. Union type on settings' names. `day(` / `month(` / `exactDay`, plus `daysUntil`, `year`, `month`. | Amend onboarding-flow, home-03, progress-02. |
| C. Settings 02 consumes onboarding's type. | Creates a hard ordering dependency where none exists. |

**Recommended A**, because `ExamDate.day(...)` sitting beside a getter called `exactDay` is
exactly the confusion the type exists to prevent.

**Chosen: A.** His comment, verbatim: `1. ok`

### C2: Two plans both claim schema version 15

`custom-track-a` Task 3 raises 14 to 15. `study-01-foundations` declares
`schemaVersion => 15` with its own `if (from < 15)` branch. `custom-track-b` then takes 16.
The tree is at 14.

Stated cost: this does not fail to compile. The second plan's migration is skipped in silence
on an existing install, which is a broken database found by a student rather than a test.

| Option | Cost |
|---|---|
| A. Assign numbers now against a fixed order. | Rots when the order changes. |
| B. Tell each plan to read the current value and take the next. | Needs a judgment call from a Flash implementor. |
| **C. Both.** Assign numbers, and add a step that asserts the current value before bumping. | One extra step per plan. |

**Recommended C**, with study-01 at 15, custom-track-a at 16, custom-track-b at 17.

**Chosen: C.** His comment, verbatim: `2. ok`

### C3: Two shared review components

`quiz-tab-06` creates `lib/core/ui/components/review_list.dart`. `mock-02-the-endings`
Task 2 creates `lib/core/ui/components/question_review_list.dart`. Both are in `core/ui`,
both define a model called `ReviewEntry`, and both give the same reason for the location.

Recommended: quiz-06 owns it, mock-02 adds grouping and a header slot.

**Not decided.** His comment, verbatim: `3. i'm not sure about this, enlighten me`

**What I got wrong in how I put it.** I framed C3 as a choice between two owners, which
implied the two plans build comparable things. Re-reading both plans in full to answer him,
they do not. **`quiz-tab-06` already builds all three configurations of the review, including
the mock's**, cites `2026-07-28-mock-exam-ui-design.md` Sections 5 and 6 as its source spec,
carries a table of the three differences the data forces, and creates `mock_review_page.dart`
itself. Its `ReviewEntry.chosenChoiceId` is nullable specifically because a mock question can
be left blank.

`mock-02` Task 2 was written as though quiz-06 did not exist. So this is not a merge, it is a
**strike**: quiz-06 owns the component outright and mock-02 keeps only the two widgets that
are genuinely its own, `score_headline.dart` and `exam_marks_offer.dart`, and passes the
offer into quiz-06's component. Revised recommendation put to him in round 2.

### C4: The Settings thread collides with three plans that are in the order

`settings-03` Task 4 deletes four widgets that `onboarding-polish`, `exam-switching` and
`quiz-tab-02b` write against, and six pieces of work are built twice across the two groups:
the exam selection row, the exam page, the reminder and date rows, the carry-over preference
(two storage homes), the carry-over prompt, and the carryable count.

| Option | Cost |
|---|---|
| A. Settings runs first, amend the other three. | Onboarding, which he chose as next on 2 August, slips behind six plans. |
| B. Keep the order, rewrite settings 02, 04, 05 to modify rather than create. | The Spec 8 widgets get built against and then deleted. The exam page is built twice. |
| **C. Strike the duplicated tasks and fold them into Settings.** | Three plans edited once, no work built twice. |

**Recommended C.**

**Chosen: C.** His comment, verbatim: `4. ok`

### C5: `/settings/sessions` and `/settings/ordering` are the same preference

`quiz-tab-02b` Step 4 builds a whole page for choosing how sessions are built.
`settings-04` builds a sheet for the same three values and `settings-02` owns the key.

Recommended: delete quiz-2b's page and row, keep only the session builder **reading**
`settings.session_ordering`.

**Chosen.** His comment, verbatim: `5. ok`

### C6: The collisions already in the checkpoint

Verified as still accurate, with one correction: `topicAccuracyProvider` is defined by
**three** plans (home-04, home-05, progress-03), not the two the checkpoint names. No ruling
needed.

---

## Round 1, other instructions

**Content generation is his.** Verbatim: `i will work on generating the remaining questions
so don't worry about it.` This closes Gate 1 of the launch checklist as a model concern.
The Mathematics decision in Gate 0, which I had put to him as "static content plan or ship
without", is therefore his to make while generating, not a blocker on the plan work.

**The paywall goes on the list.** Verbatim: `add the generation of the paywall flow spec to
the todo things.` Noting for the record that the **spec exists and is approved**
(`specs/2026-08-03-paywall-pricing-and-flow-design.md`); what is missing is the **plan**, plus
one undesigned piece inside the spec, the Pro specimen fallback for a student with no mock.
Both are now tracked.

**He asked for a wider view.** Verbatim: `also, let's take a wider view on things. is there
some aspects of app development in general that we might have missed? anything that the app
should have but we didn't talk about? notifications perhaps? or some other things?`
Answered in round 2 below.

---

## Round 2, 3 August: C3 settled, and the wider view answered

### C3, revised recommendation accepted

Put to him again as a strike rather than a merge: quiz-tab-06 owns the review component
outright, mock-02 Task 2 is struck, mock-02 keeps `score_headline.dart` and
`exam_marks_offer.dart` and passes the offer into quiz-06's header slot.

**Chosen.** His comment, verbatim: `okay let's go with your revised reco`

### Localization: English UI for v1, Filipino later

I asked whether the UI is English-only for v1, and recommended striking the unused l10n
scaffolding if so.

**His answer, verbatim:** `I think the only part not English is the "Magandang [time of day]",
so yeah more Filipino parts will be rolled out over future versions`

**Ruling recorded, and I am revising my own recommendation on the back of it.** Because
Filipino is coming rather than being ruled out, **striking the scaffolding would be wrong.**
Deleting `generate: true` now and restoring it in v1.1 costs more than leaving it. The
correct move is the opposite: **finish the scaffolding rather than remove it**, so the first
Filipino string has somewhere to go. That is `l10n.yaml`, one `app_en.arb`, and the greeting
moved into it. Everything else stays hardcoded until there is a second language.

Noting that the greeting is a live constraint on the Home masthead, which
`2026-08-02-home-03-masthead-and-band.md` builds.

### Content updates ship with app updates

**His question, verbatim:** `new questions come with app updates, this will be easier right?
and it won't take that much storage to update, say, 100 questions? some revised some added`

**He is right on size and wrong on mechanism, and the mechanism is a blocker.**

Measured from `assets/seed/v1.json` on 3 August: questions average **1.09 KB each**, so 100
questions is about **110 KB** of JSON before compression. Lessons are the heavy part at
**16.29 KB each**. Storage and download are a non-issue.

**But `Seeder.maybeSeed()` cannot deliver an update.** `lib/core/storage/data/seeder.dart:14`
reads the exams table and **returns immediately if it is not empty.** So a student who
already has the app installed receives the new `v1.json` in the update and never sees a
single new question. Only a fresh install is ever seeded. Questions carry a `version` column
and nothing reads it on upgrade.

This was not in the checkpoint, not in any spec, and not in any plan. It makes every content
pass Aedwon is about to generate undeliverable to the people who already have the app.

### Offline, and notifications for engagement

Both put to him in round 2 with recommendations. Awaiting his call.


---

## Round 3, 3 August: the go-ahead, and what landed

**His instruction, verbatim:** `go ahead with all specs based on your recommendation. then
amend what you need to amend, create what you need to create, so that the pipeline for
executing the implementation plans are holistic, fluent, and robust`

### Four specs written

| Spec | What it settles |
|---|---|
| `2026-08-03-offline-and-network-posture-design.md` | Studying is never blocked by the network, only account and money are. Six surfaces need one. Four lines of copy and no connectivity plugin. **The entitlement never fails closed.** |
| `2026-08-03-content-delivery-and-seed-upgrade-design.md` | Content ships in the build, his call. A `contentVersion`, an upgrade pass that writes content and never progress, and withdrawal by marking rather than deleting. |
| `2026-08-03-platform-foundations-design.md` | Crash reporting, analytics with six named questions and nothing else, App Check, force update, the l10n scaffolding, accessibility, feedback and the review prompt. |
| `2026-08-03-notification-engagement-amendment-design.md` | Two new kinds, `examCountdown` and `comeBack`, plus a one-a-day ceiling over all four and a list of banned patterns. |

### Seven plans written

`foundations-01-observability`, `foundations-02-app-check-and-force-update`,
`foundations-03-l10n-feedback-and-review`, `foundations-04-accessibility`,
`content-upgrade-seeder`, `offline-posture`, `notifications-countdown-and-comeback`.

### Thirteen plans amended, for the five rulings

C1 renamed the `ExamDate` call sites in settings 02, 03, 04 and 05 and made
onboarding-flow Task 1 canonical with a new `monthStart`. C2 assigned schema 15, 16 and 17
and gave each a Step 0 that confirms the current value first. C3 struck mock-02 Task 2 and
gave quiz-06 the header slot and explicit grouping. C4 struck four tasks from
onboarding-polish and two from exam-switching. C5 struck quiz-2b's settings page.

### The readiness sweep

All **47** plans now open with a model-agnostic preamble that names no harness-specific skill,
requires `AGENTS.md` in full before Task 1, repeats the do-not-redesign rule, states the
27-issue analyzer baseline, and forbids writing outside the worktree and committing generated
files. All 47 cite their source spec by path, up from 42.

### A correction I owe on the SQLite header

I repeated the work checkpoint's claim that `content-seed-delivery` Task 1 asserted
`'SQLite format 3 '` with a trailing space. **It did not.** It carried a **literal NUL byte**,
which is the correct value for the sixteenth byte of the magic. The assertion was right; the
**encoding** was the problem, because a raw NUL made the markdown file register as binary and
broke every grep across it, and a Dart implementor copying it could silently lose the byte. It
is now written as the escape `\x00` and the file is plain text.

Neither the checkpoint nor I had actually looked at the bytes before asserting what was wrong
with them.

### One thing found while writing the offline spec, and it is the biggest

**The app cannot take money.** `purchases_flutter` is in `pubspec.yaml` and imported by
**zero** files in `lib/`. The only implementation of `RevenueCatGateway` is
`DisabledRevenueCatGateway`, whose `purchase()` and `restorePurchases()` both return
`Entitlement.free()`.

The work checkpoint of 2 August says Spec 7 is "largely built" on the strength of seventeen
files in `lib/features/paywall/`. The presentation and domain layers are real; the gateway is
a stub. **That correction is mine to own: I read the file count and did not read the files.**

### The pipeline document

`2026-08-03-execution-pipeline.md` replaces the checkpoint's execution order. Five phases,
46 unexecuted plans, the collision map with the five resolved rows and the eight still live,
and a health table. Gates verified after the sweep and unchanged: analyzer 27 issues all
under `tools/`, layering 7, and no new AI-attribution hits.

---

## Round 4, 3 August: the feedback destination

**His decision, verbatim:** `for the feedback, I'm planning to create a Facebook group or
Discord server and have feedback and discussions consolidated there. it's easier for the
common Filipino given FB's ubiquity in PH`

**This reverses what I specced.** `2026-08-03-platform-foundations-design.md` Section 8 said
a mail intent to a real address, prefilled with the build and the device. It is now a
**community group**, and the row opens a URL.

**His reasoning is better than mine was.** I chose the mail intent on the grounds that it is
the correct size for one person supporting a launch. That is true about volume and wrong
about the market: Facebook is where these students already are, and one-to-one email
scatters both the feedback and the answers, where a group consolidates them and lets students
answer each other.

**Four consequences, recorded because three of them are not obvious:**

1. **It needs `url_launcher`**, which is not in `pubspec.yaml`. **Same dependency the
   force-update button needs**, so it is one decision covering both, and both tasks now say
   to stop and ask.
2. **The prefill disappears.** No build number, no device model, nothing sent. This is the
   more private option of the two, which was not why it was chosen but is worth having.
3. **Play still requires a developer contact email on the listing**, separately from anything
   in the app. A group does not satisfy that, and it stays on the launch checklist as his.
4. **A group is a moderation commitment**, and a public one is a place where a student can
   post something identifying about themselves. Raised, not an objection: it is the normal
   cost of the format.

**Facebook or Discord is not settled and does not need to be.** The row opens a URL and does
not care which. Spec Section 8 and `plans/2026-08-03-foundations-03-l10n-feedback-and-review.md`
Task 2 both amended.
