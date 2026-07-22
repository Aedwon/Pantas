# Settings

> **Typography, amended 11 August 2026.** Every mention of a serif below is
> superseded. **The app uses one family, Source Sans 3, everywhere**: the serif
> was retired because Aedwon found it an eyesore, and a reader noticing the
> type is not reading the lesson. Read a "serif 16/700" here as "16/700".
> The round is in `decisions/2026-08-10-typeface-log.md`.
>
> **What the serif carried, the rest of the identity now carries alone**: the
> hairline rules, the underlined section heads, the tabular figures, and the
> absence of tinted callouts, rounded cards and drop shadows.



**Date:** 3 August 2026
**Status:** Approved by Aedwon
**Decision log:** `docs/superpowers/decisions/2026-08-03-settings-log.md`
**Brief:** `docs/superpowers/2026-08-03-settings-brainstorm-brief.md`
**Supersedes:** `2026-05-22-settings-account-design.md` (Spec 8) on everything the student
sees. Spec 8's non-visual work stands where this spec does not contradict it: the
synced-versus-device split, the analytics consent gate, the deletion Cloud Function
contract, and its cross-spec dependency list.

**This spec describes the destination.** Nothing in `lib/features/settings/` constrains
it. Code observations belong in the plan.

---

## Problem

Six specs written in the last two weeks each handed Settings a row, and none of their
authors saw the screen. That is the shape the paywall consolidation had on 2 August and it
would have failed the same way.

Underneath that, the existing design predates the identity by two months. Spec 8 was
brainstormed 22 May; the Ink & Rule redesign is 18 July. Spec 8 specifies a Material large
app bar, chips for the theme control and iOS-style switches, all of which are banned now
or were never reconciled. **Four rows have had no control at all since 18 July**, because
the switch they were specified with was struck and nothing replaced it.

---

## Section 1: The rules this screen obeys

**1. Settings governs persistence and defaults, never visibility.** Decided 2 August on the
Progress table and it holds everywhere here. A control appears when it can do something. No
row on this screen hides a control on another screen.

**2. Pantas filters, it does not purge.** Nothing on this screen deletes a student's work.
Narrowing an exam's subjects hides questions; switching exams leaves every attempt where it
is; turning carry-over off changes what the figures count and not what exists. The only
destructive surface in Settings is account deletion, which is legally required and lives
behind its own confirmation screen.

**3. A control edits a value in place. A choice with reasons is reading.**
This is the rule that decides where each interaction happens, and it is stated because two
surfaces here look like the same problem and are not:

| Kind | Where it happens | Examples |
|---|---|---|
| A control | In the row itself, or a sheet if it needs a wheel | The switch, the theme control, the exam date |
| A choice with reasons | A sheet with room for the reasons | How sessions are built |
| A destination | A pushed page | Exam, Pro, Account, Backup, About |

**4. Icons are permitted only where the control's subject is the appearance itself.**
The theme control carries a sun, a moon and a half-filled circle. **They are the only
icons in the application.** A theme switch is the one control whose meaning is visual, so
the marks are the subject rather than decoration. Nothing else in Settings qualifies and
this rule may not be generalized.

**5. American spelling, throughout.** Settled 3 August and it is a project rule rather than
a Settings rule: practice, color, behavior, analyze, gray, center. It applies to UI copy,
to specs and to prose.

**6. Voice.** Grade-5-simple English. No em dashes. Sentence case. Scores are "points".

---

## Section 2: How Settings is reached

The gear in Home's masthead, per `2026-07-26-home-and-navigation-design.md`. It is the only
right-side element there. **Settings has no tab.**

It is a pushed route outside the tab shell, so `context.push`, per the navigation rule that
`context.go` from outside the shell strands the student with no back arrow.

---

## Section 3: The top level

Twelve rows in five groups. Everything is visible on one scroll; sub-pages exist only where
a surface has states or a list too long for a row.

```
‹  Settings

You                                          serif 17/700, 1px ink rule
  Name                              Aedwon
  Exam                               UPCAT  ›
  Exam date                    12 Oct 2026

How you practice
  How sessions are built   Interleaved tail  ›
  Strict mock mode                    [off]
  Daily reminder                    7:00 PM

What you see
  Remember table order                 [on]
  Theme                     [☀ | ☾ | ◐]

Your account
  Pro                               Yearly  ›
  Account                        Signed in  ›
  Backup                             Saved  ›

About                                       ›
```

The final group is a heading with a single row under it, which is deliberate: About is a
destination and a heading, not a row inside another group.

### The grammar, and every number in it is load-bearing

- **The bar.** A back chevron at 19px `inkMuted`, then a serif 17/700 title, 10px apart,
  with 18px beneath it. No Material app bar, large or otherwise, and no elevation.
- **Group heading.** Serif 17/700, letter-spacing -0.15, 7px of space beneath it, then a
  **1px `ink` rule**, full width. The rule under a heading is ink, not `rule` and not
  `ruleFaint`. This is where the heading's authority comes from and it is the single fix
  that made the plain list win.
- **Rows.** Sans 14.5/400 title. No rule between rows inside a group.
- **Values.** Right-aligned, sans 13/600, `inkMuted`, tabular figures. A value that means
  "on" is `ink` rather than `inkMuted`; every other value is muted.
- **Row box.** 38 tall, 10px above the baseline row and 9 below. Tappable rows keep the
  same visual box and reach 44 of touch target with `MaterialTapTargetSize.padded`, the
  same move `DataRowTile` makes.
- **Chevron column.** A fixed 11px column at the right edge, present on every row whether
  or not that row pushes. **Every value in the group lands on one right edge**, which is
  what stops the list looking ragged when only some rows have a destination.
- **Between groups.** 24px.
- **Page gutter.** 20px each side, `PageScaffold`'s default.

### Why not a shorter top level

Four navigational doors was drawn and rejected: every preference costs a tap and a student
hunting for the daily reminder has to guess which door owns it. An identity plate over the
name, exam and date was drawn and rejected: one "Edit" would have to cover a text field, a
wheel sheet and a whole sub-page, so its chevron would lie about where it goes.

### Why "About" is a group and not a row in "The app"

There is no "The app" group. Analytics consent moved into About, next to the privacy
policy where it belongs, and Send feedback moved into About because it is an outbound email
rather than a setting. Theme moved into "What you see". With those three gone the group had
nothing left in it.

---

## Section 4: The controls

### 4.1 The switch

A hairline rectangle that fills solid when on.

| State | Box | Square inside |
|---|---|---|
| **Off** | 32x18, 1.2px `rule` outline, 1px radius, no fill | 12x12 at the left, 2px inset, 1.2px `rule` outline, no fill |
| **On** | Same box, 1.2px `ink` outline, filled `ink` | 12x12 at the right, no outline, filled `background` |

**Off is entirely hollow and on is entirely solid.** The state is carried by the whole
object rather than by a small block moving a small distance, which was the fault in every
alternative drawn.

The off outline sits at `rule`, one step lighter than `inkMuted`, so an off row recedes
into the page's ruling and the on state is the only ink in the column. The whole row is the
tap target; there is nothing to drag.

**Rejected:** the iOS oval of Spec 8 (banned), a Material switch (banned), the word "On" or
"Off" in the value column (a word where every other row keeps a value), and a checkbox (a
checkbox means "include this in a set", these rows mean "this behavior is on").

### 4.2 The theme control

The same grammar at three positions. A hairline enclosure with 1.2px `rule` dividers
between segments; the live segment is filled `ink` with its mark in `background`.

- Height 22. Each segment is 30 wide and holds a 12px icon, centered. Overall 90x22.
- **Light** is a sun: a circle with eight rays. **Dark** is a crescent. **Follow the
  phone** is a circle with its left half filled.
- Icons only, no words. This is the exception in Section 1 rule 4 and it goes no further.
- Every segment carries a semantics label, "Light theme", "Dark theme", "Follow my phone",
  because the marks carry no text for a screen reader to read.

It sits in the row. There is no theme page and no theme sheet.

**Rejected:** words only, which loses the visual subject; icon plus word, which is 168px
wide and leaves 86px for the row title.

### 4.3 The sheet

Used by the exam date and by "How sessions are built".

- Raised from the bottom over the list, which stays in place behind it.
- **A 1px `ink` rule across its top**, square corners, no radius, no shadow, no card.
- Padding 15 top, 18 sides, 18 bottom.
- **An ink wash over everything behind it**: `rgba(38, 34, 27, 0.42)` on paper,
  `rgba(0, 0, 0, 0.55)` in the dark. Tapping the wash dismisses.

### 4.4 The chooser rows, inside a sheet

- A 13px ring at the left, 11px from the text. Unselected is a 1.3px `inkMuted` outline;
  selected is `ink` with a filled center.
- Title sans 14.5/400, and **600 when it is the selected one**.
- Reason beneath, sans 12, `inkMuted`.
- A 1px `ruleFaint` rule between rows, none after the last.
- **The choice takes effect on tap. No Save and no Cancel**, because nothing is lost by
  changing your mind.

### 4.5 The wheels

**The date sheet** holds three inline wheels, day, month and year, lifted from onboarding
step 4 into `lib/core/ui/` and shared by both surfaces. **The day column carries a dash
above 1**, and resting on the dash means the day is unset. The existing validator refuses
anything earlier than tomorrow, so the wheels do not offer a past date; at month precision
the check is against the month, so the current month stays selectable while it has days
left.

**The reminder sheet** holds the same wheel component at two columns, hour and minute in
five-minute steps, with a third column for AM and PM. No validation, since every time is
valid. Saving schedules the local notification and, if the OS permission is not granted,
the sheet's dismissal is followed by the permission request rather than a silent failure.

### 4.6 The text field

Used by the name sheet, and it is onboarding step 5's field unchanged: **a 1px `rule`
beneath the text, page gutter to page gutter.** Not a filled Material box and not an
outlined one. The sheet carries the field, a board button reading "Save", and nothing
else. Clearing the field and saving is how a student removes their name, since empty and
absent are the same state.

---

## Section 5: The rows, one at a time

### You

| Row | Value shown | What it does |
|---|---|---|
| **Name** | The name, or `Add your name` in `inkMuted` | Opens the text-field sheet of Section 4.6. Empty and absent are the same state. |
| **Exam** | The exam's short name | Pushes the Exam page. |
| **Exam date** | See below | Opens the date sheet. |

**The exam date's value obeys precision**, and this is the evidentiary rule rather than a
copy preference:

| Precision | Value column |
|---|---|
| `day` | `12 Oct 2026` |
| `month` | `October 2026` |
| none | `Not set`, in `inkMuted` |

**No day count appears in this column at any precision.** The countdown is Home's, it is
governed by `2026-08-02-onboarding-name-and-date-design.md` Section 4, and a day count
derived from a month is a figure made of a measurement and an assumption.

**The sheet offers the same three answers as onboarding**: an exact date, a month with the
day on the dash, or "I don't know yet" as a board text action beneath the primary button.
If Settings offered fewer, a student who said "October, no day" could not say it again,
editing would silently promote them to day precision, and Home would print a day count
built on an assumption.

### How you practice

| Row | Value shown | What it does |
|---|---|---|
| **How sessions are built** | The chosen ordering's name | Opens the ordering sheet. |
| **Do more each day** | The switch | Toggles in place. **Carries a subtitle, see below.** Read by the study plan to raise the daily pace. |
| **Strict mock mode** | The switch | Toggles in place. **Carries a subtitle, see below.** Read by the mock exam to gate pause and to gate ending a part early. |
| **Daily reminder** | `7:00 PM`, or `Off` | Opens the reminder sheet of Section 4.5. If the OS permission is denied the value reads `Notifications are off` and the tap routes to OS settings instead of opening the sheet. |

**"Do more each day" was added 4 August 2026**, and it fixes a control that was stored in the
tree and reachable from nothing. It also **replaces** the 5/10/20/30/50 new-card selector that
`2026-05-17-quiz-engine-and-modes-design.md` D7 asked for. **Two controls for one number is how
they end up disagreeing.**

> **Do more each day**
> Your plan already paces you to finish everything before your exam. Turn this on to go faster
> and leave yourself more time to review.

**It is a switch, not a three-way choice, and that was decided rather than defaulted.** A
Light, Standard and Intense sheet was drafted first. **Two of its three options did nothing:**
the plan's pace is already the minimum that finishes the material in time, so there is no
slower setting to offer, and naming three when one acts would be a lie. **A switch is the
honest shape of a control that has exactly two states.**

**Off is the default**, and off is not a lesser mode. It is the pace that keeps the promise.

**Two switches on this screen carry a subtitle**, this one and strict mock mode, and they are
the only two. Both change what the app will do rather than what it looks like.

**Strict mock mode's subtitle:**
Added 4 August 2026. The row previously showed a name and nothing else, so a student had no way
to learn what they were turning on except by turning it on. **A restriction a student meets
only when they hit it is a bug from their side of the screen.**

> **Strict mock mode**
> Mock exams run like the real room. You cannot pause, and you cannot end a part early.
> Leaving the app hands the paper in.

**All three consequences are named, in the order they bite.** Pausing is the one a student
reaches for first, ending a part early is the one this subtitle was written for, and leaving the
app is the harshest and therefore last. **The word "strict" is never used to explain itself.**

**The setup screen before a paper repeats this** whenever the switch is on, because a setting
changed weeks ago is not a warning. See `2026-07-28-mock-exam-ui-design.md`.

**The ordering sheet:**

> **How sessions are built**
> Each session has one main topic. This sets how much comes from other topics.
>
> ○ **One topic only**
>    All 10 questions from your topic.
> ● **Interleaved tail**  *Recommended*
>    7 from your topic, 3 from others. Harder now, easier on exam day.
> ○ **All mixed up**
>    No two in a row from the same topic.

The reason is on its own line beneath the title, per Section 4.4. **No em dash appears in
any of it**, which is the standing rule and is worth stating here because a label followed
by an explanation is exactly where one gets typed by reflex.

**"Interleaved tail" keeps its name** while the other two were plainened. It is the badged
default, "interleaved" is the real learning-science word, and the badge is making an
authority claim that a plain phrase would not carry.

The recommended marker is `board`, sans 10.5/700, on the same line as the title.

The stored values keep the spec's vocabulary, `blocked` / `interleavedTail` /
`fullyMixed`, so only the labels are plain. The default is the interleaved tail, per
`2026-07-28-quiz-tab-design.md` Section 5.

### What you see

| Row | Value shown | What it does |
|---|---|---|
| **Remember table order** | The switch | On by default. |
| **Theme** | The three-position control | Changes in place. |

**"Remember table order", not "Remember how the table is sorted."** The longer phrasing
from `2026-07-30-progress-tab-design.md` Section 6 does not fit the value column on a
290px screen, and that column is not negotiable because it is what keeps every value on
one right edge. The Progress spec is amended.

It **governs persistence, never visibility.** When it is on, the Progress table's sort,
direction, level and subject filter survive leaving and returning. When it is off, the
table opens at its default every time. It never hides a control.

### Your account

| Row | Value shown | What it does |
|---|---|---|
| **Pro** | The plan name, or `Free` | Pushes the Pro page. |
| **Account** | `Signed in`, or `Not signed in` | Pushes the Account page. |
| **Backup** | `Saved`, `Backing up`, `Offline`, `Couldn't back up`, or `Not backed up` | Pushes the Backup page. |

**The Account row shows a state, not an email.** An email address does not fit the value
column and truncating one is worse than not printing it. The address is on the page.

### About

One row, pushing the About page. No value.

---

## Section 6: The Exam page

Three rows under the exam's own name as the heading.

```
‹  Exam

UPCAT                                        serif 17/700, 1px ink rule
  Change exam                    6 available  ›
  Carry over progress                   [on]
  Answers from your other exams count toward this one.
  Nothing is ever deleted.
  What's included               All subjects  ›
```

**"Change exam" pushes the onboarding exam picker screen itself**, not a second roster
built here. `ExamSelectionRow` is being lifted into `lib/core/ui/` for exactly this, so the
reuse is a layering fact rather than an aspiration. Aedwon asked for this directly: the
screen a student already met during onboarding is the screen they should meet again.

**The switch prompt fires on the way back**, when the exam has actually changed, exactly as
`2026-08-02-exam-switching-design.md` Section 4 specifies it:

> **You're not starting from zero**
>
> 412 of the questions you've answered are also on UPCAT. We'll count them toward your
> UPCAT progress so you can pick up where you are, not where you started.
>
> [ Count them ]
> Start my numbers fresh

The count is measured from the student's own attempts, so it is a figure this app may
print.

**Carry over progress** is changeable at any time and defaults to on. It **governs figures
and history and never governs scheduling**: Progress figures, the Home stats band and
weakest areas respect it; today's session, every due date and the flagged list do not. The
lede beneath the row states the second half of that in the student's own terms, because
the state it produces is coherent but surprising: with carry-over off, Progress can report
0 answered while today's session serves questions that are not due for months.

**What's included** pushes the subject and topic index from
`2026-08-02-custom-exam-track-design.md` Section 5, which is the Quiz picker's index lifted
into `lib/core/ui/`. Its value column names the state: `All subjects`, or the count of
ticked subjects. Available to every track, not only custom ones.

**Why the roster is not on this page.** Roster-first was drawn and rejected: carry-over is
the row a student returns to and switching is rare, so putting the whole roster above it
puts the rare thing first and the frequent thing off the bottom of the screen.

---

## Section 7: The pushed pages

These follow their source specs. This spec owns their frame, not their content: the ledger
grammar of Section 3, a back chevron with a serif title, `PageScaffold`'s gutters.

### Pro

Content is `2026-08-03-paywall-pricing-and-flow-design.md`. Three SKUs, Weekly ₱29 /
Monthly ₱99 / Yearly ₱999, the trial on Yearly only. **No screen mentions or implies a
lifetime purchase.** The page carries current plan and renewal date, "Manage in Google
Play", and "Restore purchases". A Free student sees what Pro adds and a way in, per that
spec's Screen 1.

### Account

Content is Spec 8 §5.2 to §5.4, unchanged in substance. Signed-out and signed-in variants;
sign-out is a dialog; **account deletion is a dedicated confirmation screen, not a
dialog**, with plain-language consequences and a subscription-aware line. Spec 8's Lifetime
row is struck, since no such SKU exists.

### Backup

Content is Spec 8 §5.6. Five states, plain-language status as the primary line, raw
diagnostics behind an expand.

### About

Absorbs two rows that were on the top level in Spec 8.

```
‹  About

Pantas
Version 1.0.0 (build 142)

Legal
  Privacy policy                              ›
  Terms of service                            ›

Your data
  Help improve the app                    [on]
  Shares anonymous usage data. Crash reports are always sent.
  Contact our DPO                             ›

Get in touch
  Send feedback                               ›

Debug                                         ›   flag builds only
```

"Send feedback" opens a `mailto:` with the version and device stubbed into the body.
"Debug" is a heading with one row under it, the same shape About itself has on the top
level, so a build without the flag simply has no such heading.

**"Help improve the app" lives here**, next to the privacy policy, because that is where a
student looking for what the app collects will be. Default on; gates Firebase Analytics
only. Crashlytics is independent and the lede says so.

**The debug row appears when `--dart-define=DEBUG_SETTINGS=true` is set, and nothing else
reveals it.** Spec 8's long-press on the version row is struck: it is a second gate on a
screen already invisible in release, and an undocumented gesture we would forget. The flag
stays reject-on-build in release. Contents are Spec 8 §5.9: wipe local data, the raw
entitlement state, force resync, and the last-sync timestamp with queue size.

---

## Section 8: States

| State | What Settings shows |
|---|---|
| No name | Name row reads `Add your name` in `inkMuted`. Self-healing, no migration prompt. |
| No exam date | Exam date row reads `Not set`. |
| Month-precision date | `October 2026`. Never a day count. |
| Not signed in | Account row reads `Not signed in`; Backup row reads `Not backed up`. |
| Free | Pro row reads `Free`. Every other row is unchanged: **no row on this screen is hidden, disabled or badged by entitlement.** |
| Offline | Every row still works. Writes are local first and sync when the network returns. |
| Notification permission denied | Daily reminder's value reads `Notifications are off` and the tap routes to OS settings. |
| Custom track | The Exam page's heading is the student's track name. "Change exam" still reaches the picker. |

---

## Section 9: Storage

Spec 8's principle stands: **preferences about the student sync, preferences about the
device do not.**

**Synced**, on the account preferences row, last-writer-wins by `updated_at`:

| Key | Type | Default |
|---|---|---|
| `settings.name` | string | absent |
| `settings.exam_date` | `YYYY-MM-DD` | absent |
| `settings.exam_date_precision` | `day` or `month` | absent |
| `selected_exam_id` | string | from onboarding |
| `settings.carry_over_progress` | bool | `true` |
| `settings.session_ordering` | `blocked` / `interleavedTail` / `fullyMixed` | `interleavedTail` |
| `settings.retain_table_order` | bool | `true` |
| `settings.strict_mock_mode` | bool | `false` |
| `settings.daily_reminder_time` | `HH:mm` | absent |
| `settings.help_improve_app` | bool | `true` |
| track scope | the ticked subjects and topics | all |

**Device-local**, never synced:

| Key | Type | Default |
|---|---|---|
| `theme_mode` | `light` / `dark` / `system` | `system` |

`settings.exam_date` and its precision are two keys but **one value type**. Per
`2026-08-02-onboarding-name-and-date-design.md`, `UserSettings.examDate` carries its own
precision so a caller physically cannot read a day off a month-precision value. A boolean
beside the date would work exactly until the first reader forgot to check it, and that
failure is silent and prints a wrong number to a student.

`settings.session_ordering` replaces `quiz_today_interleaved`, which is a boolean with no
UI that writes it, so it widens to three values.

The four Progress table-order keys are governed by `settings.retain_table_order` and are
specified in `2026-07-30-progress-tab-design.md` Section 6.

---

## Section 10: Amendments to other specs

1. **`2026-05-22-settings-account-design.md` (Spec 8)** is superseded on everything the
   student sees: D1's theme chips, D2's information architecture, D7's section order and
   D10's iOS switch are all struck. Its Lifetime handling is struck, since the SKU is gone.
   Its synced-versus-device split (D8), analytics consent scope (D9), delete-flow shape
   (D6) and export decision (D11) stand.
2. **`2026-07-30-progress-tab-design.md` Section 6.** The Settings row is titled **"Remember
   table order"**. The longer phrasing does not fit the value column.
3. **`2026-07-28-quiz-tab-design.md` Section 5.** The three orderings are labeled **One
   topic only / Interleaved tail / All mixed up** in the UI. The stored values keep the
   spec's names.
4. **`2026-07-25-onboarding-polish.md` Task 4** builds the Exam page to Section 6 of this
   spec, three rows, not a roster. Its Task 3 lift of `ExamSelectionRow` is what "Change
   exam" pushes to.
5. **`2026-08-02-onboarding-name-and-date-design.md` Section 4.** Its wheel control is
   lifted to `lib/core/ui/` and used by both onboarding and the Settings date sheet.
6. **Project voice.** American spelling is added to the standing rules in `AGENTS.md`
   alongside no em dashes and Grade-5-simple English, and the existing specs need a sweep.

---

## Section 11: Not building

- **A Settings tab.** The gear in Home's masthead is the only entrance.
- **Any row that hides another screen's control.** Section 1 rule 1.
- **Icons anywhere but the theme control.** Section 1 rule 4.
- **A language toggle.** No localization infrastructure; English at v1.
- **Reset progress.** Different semantics from delete, no v1 need, and it contradicts
  "Pantas filters, it does not purge".
- **Rate this app.** Surfacing it from Settings drifts toward a dark pattern.
- **Profile editing beyond the name.** Duplicates Google account management.
- **In-app data export.** RA 10173 portability is satisfied through the DPO email.
- **Studying two exams at once.** Deferred with reasons in
  `2026-08-02-exam-switching-design.md`.

---

## Verification

- Every group heading is serif, sentence case and sits on a 1px `ink` rule. None is boxed
  and none is all-caps.
- Every value in a group lands on one right edge, whether or not its row has a chevron.
- An off switch is entirely hollow and an on switch is entirely solid. Neither state is
  told apart by position alone.
- The only icons in the whole application are the three in the theme control.
- The exam date row prints `October 2026` at month precision and never a day count, at any
  precision, anywhere in Settings.
- The date sheet offers all three onboarding answers, including "I don't know yet".
- "Change exam" reaches the same screen onboarding used, not a second roster.
- Turning carry-over off changes Progress figures and changes no due date.
- No row is hidden, disabled or badged because the student is Free.
- The debug row is absent from any build without `DEBUG_SETTINGS=true`, and the flag is
  rejected at build time in release.
- No UI string uses British spelling, and no string contains an em dash.
