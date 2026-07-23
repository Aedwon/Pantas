# Study tab and lesson reader redesign

> **Typography, amended 11 August 2026.** Every mention of a serif below is
> superseded. **The app uses one family, Source Sans 3, everywhere**: the serif
> was retired because Aedwon found it an eyesore, and a reader noticing the
> type is not reading the lesson. Read a "serif 16/700" here as "16/700".
> The round is in `decisions/2026-08-10-typeface-log.md`.
>
> **What the serif carried, the rest of the identity now carries alone**: the
> hairline rules, the underlined section heads, the tabular figures, and the
> absence of tinted callouts, rounded cards and drop shadows.



**Date:** 2026-07-27
**Status:** Approved by Aedwon, validated interactively against live mockups in
`.superpowers/brainstorm/64324-1785062431/content/`
**Supersedes:** `2026-07-26-study-tab-brainstorm-state.md`
**Amends:** `2026-07-26-home-and-navigation-design.md`,
`2026-07-18-ui-redesign-design.md`, `2026-05-10-plan-06-lesson-reader-design.md`
**Closes:** UI-012 (by removal), open items 1 to 3 of the 2026-07-26 handoff

## Problem

The Study tab is a flat list of topic names and nothing else. Every row is
`InkTableRow(title: topic.name)`. Lesson reads are stored per lesson and nothing
rolls up, `readCountForTopicProvider` (`storage.dart:98`) is written and consumed
by nothing, error states print raw `SqliteException` text to students, and the
tab always opens at the top of the same list with no memory of where anyone was.

The lesson reader is 113 lines: a bare `AppBar()` carrying only a back arrow, one
`SingleChildScrollView`, no paging, no rail, no counter, and a board green "Mark
as read" button that makes every downstream coverage figure a count of button
presses.

The Home redesign removed Home's only route into a topic, so the Study map is now
the sole entrance to all 141 lessons.

## Scope

`/study`, the lesson reader at `/lesson/:lessonId`, search across the corpus,
bookmarks end to end, and the closing pages that end a run. The topic page at
`/study/topic/:topicId` is deleted.

Out of scope: Home, the Quiz tab, Progress, the study-plan feature, and the
acknowledgment system described under Deferred.

---

## Section 0: Corrections to the record

Everything below was verified against the code rather than recalled. Five prior
statements are wrong.

1. **Subjects and topics already sort.** `listExams` sorts subjects by `ordering`
   (`content_repository.dart:41`) and `topicsBySubject` sorts topics the same way
   (`:58`). Only `lessonsByTopic` (`:85`) returns rows untouched. The earlier
   claim that "nothing sorts anything" is half wrong.
2. **The lesson order students see is alphabetical by filename slug.** No
   `ordering` exists in the schema or the seed, so SQLite returns rowid order,
   which is seed array order, which is the file glob. Verified against
   `content/lessons/mathematics/algebra/`. *Sets and Set Notation* therefore sits
   at 8 of 11 and *Word Problems* lands last by luck.
3. **`_studyPath` is deleted, not fixed.** With Home no longer routing to topics,
   both callers go (`assessment_home_tab.dart:209` and `:242`). This closes
   UI-012 by removal rather than by patching `go` to `push`.
4. **Subtopics do not exist.** `SubtopicId? subtopicId` is declared on `Lesson`,
   `content_lessons`, `content_questions` and `quiz_sessions_table`, and nothing
   assigns one. There is no subtopics table and no names.
   `drill_subtopic_browser.dart` lists **topics** with every subtitle hardcoded to
   "General bucket". The level in question is the **lesson** level, which is fully
   authored.
5. **`estimatedMinutes` is content length, not time spent.**
   `lesson_progress_local` stores `lessonId`, `readAt` and `syncState` only, so
   the app cannot know how long anyone read. No surface may present an estimate as
   a personal figure.

Two constraints that follow:

- **"Flag" is taken.** `MockSessionState.flags` is the set of question ids flagged
  inside a timed mock. The reading feature is called **Bookmarks**, a word used
  nowhere in `lib/` or any spec.
- **Exam size is not a design constraint.** CSE Professional's 1 subject, 1 topic
  and 3 lessons is unfinished content, not a shape to design around. Design for
  the complete corpus. No per-exam rules, no thresholds, no collapsing bands.

---

## Section 1: The Study map, `/study`

Composition, top to bottom: app bar, exam name, head block, "Last opened",
Bookmarks, then one subject heading per subject with its topic rows.

### App bar

Height 56, `background`, no elevation, no scroll shadow. Title "Study" in
`headlineMedium` (Source Serif 4, 18/700). One trailing element, the **search
glyph**: a magnifier at 19px, stroke 1.6, `inkMuted`, drawn as a circle of radius
6.5 centered at (10.5, 10.5) with a handle from (15.3, 15.3) to (20, 20).

The bar has exactly one trailing element and never more.

### Exam name

The exam short name in `displaySmall` (serif 22/700, tracking -0.2), 6px below the
bar, at the 20px page gutter.

### Head block

Two figures, ruled top and bottom with 1px `rule`, 14px padding above and 15
below, split by a vertical 1px `rule` divider.

| Figure | Value | Label |
|---|---|---|
| Left | `read / total * 100`, serif 22/700 with a 12px sans `%` suffix in `inkMuted` | "covered" |
| Right | remaining `estimatedMinutes` summed over unread lessons, in whole hours, serif 22/700 with a 12px sans `h` | "left to read" |

Labels are `bodySmall` (12) in `inkMuted`, lowercase, centered, 3px beneath the
figure.

**Recorded caveat:** "covered" is arithmetically Home's lessons-read figure with
the division carried out. Accepted deliberately rather than overlooked.

**Honesty note:** "left to read" is derived from `estimatedMinutes` and describes
the material, not the student. It is acceptable here because it is labelled as a
property of what remains, not of what was done. It becomes exact once reading
duration is captured (see Deferred).

### "Last opened"

A row beneath the head block, 13px vertical padding, closed by a 1px `rule`.

- Left: label "Last opened" in `bodySmall` `inkMuted`, over the lesson title in
  `bodyMedium` `ink`.
- Right: a `BoardButton` labelled "Resume", radius 5, padding 9 by 15, 13/600.

Hidden entirely when nothing has been opened yet.

Requires a stored last-opened lesson id, which does not exist today. Read state
records *that* a lesson was read, not which one was open last.

### Bookmarks

Rendered only when at least one bookmark exists. No empty state, no placeholder,
no "you have no bookmarks yet". A block that teaches itself by nagging is worse
than one that appears the moment it has something to say.

- Heading "Bookmarks" in `headlineSmall` (serif 15/700), the total count in
  `bodySmall` `inkMuted` beside it, and **"See all"** in 12/600 `board` as the
  trailing action, shown only when the count exceeds three.
- A 1px `rule` beneath the heading row.
- **Exactly three rows**, whatever the total. The head must have a ceiling so the
  index always starts in the same place however heavily a student bookmarks.
- Each row: the ribbon glyph leading in `inkMuted`, the lesson title in
  `bodyMedium`, the topic and minutes beneath in `bodySmall` `inkMuted`
  ("Chemistry, 13 min"), a trailing chevron.
- The three shown follow whatever order the sheet is set to (see Section 3).

### The index

For each subject, in `ordering`:

- A heading row: subject name in `headlineSmall`, the subject's read fraction in
  `bodySmall` `inkMuted` right-aligned, 20px above and 2px below.
- A 1px `rule` beneath the heading.
- Its topic rows, in `ordering`.

### Topic rows

Minimum height 44, 8px vertical padding, 10px gaps, closed by a 1px `ruleFaint`.

- **Leading glyph column, 12px wide, always reserved.** Filled only by a board
  `✓` when the topic is fully read. A started topic gets **no glyph**: the
  fraction already says it, and a bullet is the same fact told louder. This keeps
  every title on the same vertical line down the page, which is what a ruled table
  is for.
- Title in `bodyMedium`. A fully read topic sets its title in `inkMuted`.
- A ribbon in `inkMuted` when the topic holds at least one bookmarked lesson.
- The read fraction, "6 / 9", in `bodySmall` `inkMuted`, tabular figures.
- **A chevron on the right**, 12px, stroke 1.4, `inkMuted`. It rotates to a
  downward caret when the topic is open.

### Topics open in place

A topic expands into its lesson rows rather than navigating anywhere.

- **One topic open at a time.** Opening one closes the previous. This is what
  bounds the page: fully expanded UPCAT would be 164 rows, roughly 7,450px and
  10.5 screens at 390 by 760. One at a time caps it at about 2.8 screens.
- Lesson rows are indented 22px, carry a board `✓` when read, the title at 13.5,
  the minutes right-aligned in `bodySmall` `inkMuted`, and a chevron.
- **Nothing else sits inside an open topic.** No "Start here" recommendation, no
  quiz line, no per-topic accuracy.

### The pinned topic bar

While a topic is open, its row persists directly beneath the app bar for as long
as it stays open. This is **not** a sticky header: `position: sticky` unpins the
moment its own section scrolls away, which is exactly when the bar is needed.

- Appears once the topic's own row has scrolled above the viewport.
- Content: the kicker "open" in 11px `inkMuted`, the topic name at 14, the read
  fraction, and the rotated caret.
- 11px vertical padding, closed by a 1px `rule`.
- **Tapping the row scrolls back to the topic.** **Tapping the caret collapses
  it.** The caret needs its own 48dp target carved out of the row.

It works only because one topic is open at a time, so there is never a stack.

### The tab remembers what was open

The open topic survives leaving and returning to the tab. Under one-at-a-time this
is a single stored topic id.

### Other states

| State | Treatment |
|---|---|
| Loading | `FaintBars`: 7px paper-toned bars at `ruleFaint`, radius 2, 5px vertical margins. Never gray blocks, never shimmer |
| Error | `ErrorBanner` in its `error` variant: 3px `rust` accent, 10px vertical padding, rules top and bottom, message "Could not load your topics. Pull down to try again." Never the exception string |
| No topics | `EmptyState`: serif headline "Nothing to study yet", body "This exam has no lessons on your device yet. Check back after the next content update.", secondary CTA "Try a quick quiz" |
| No exam chosen | The existing fallback: "Choose your exam" over "Pick the exam you are reviewing for." and a board "Choose exam" |

Both screens currently hand-roll their `Scaffold` and their empty states.
`PageScaffold` and `EmptyState` exist and are used only by
`quiz_results_page.dart`. Adopt them.

---

## Section 2: Search

### Scope of the index

**Titles, summaries and lesson bodies.**

No search infrastructure is required. 141 titles and summaries are roughly 15KB,
filtered in Dart in well under a millisecond, and a `LIKE` scan over 141 body rows
is tens of milliseconds. FTS5 would only earn its place for ranking and snippet
extraction, and it is not available in any case: the app opens `NativeDatabase`
against the OS SQLite with no `sqlite3_flutter_libs` bundled.

Matching is case-insensitive substring, no stemming, no fuzzy matching.

**Why bodies matter, measured against the real corpus:**

| Query | Titles | + summaries | + bodies |
|---|---|---|---|
| venn | 1 | 1 | 1 |
| gemdas | 1 | 1 | 1 |
| buoyan | 1 | 1 | 1 |
| isotope | 1 | 1 | 1 |
| swap | 0 | 0 | 1 |

Four of five land from the title alone, because the parentheticals authors wrote
into titles are an index nobody set out to create: *Order of Operations
(PEMDAS/GEMDAS)*, *Basic Trigonometric Ratios (SOH-CAH-TOA)*, *Sets and Set
Notation (Unions, Intersections, Subsets, Venn Diagrams)*. "swap" is the case that
justifies bodies: the mnemonic *"Less than means swap the plan"* lives in the text
of a lesson titled *Algebraic Expressions*, and a trick is what a student actually
half-remembers.

### Where it lives

The search glyph in the app bar. Tapping it **replaces the bar in place**: the
title gives way to a full-width field, with **Cancel** in 12/600 `board` at the
right. No route is pushed, so the tab bar stays and the back stack is untouched.
Cancel restores the map at its previous scroll position.

The field: a 1px `ink` bottom rule, 6px vertical padding, the magnifier leading in
`inkMuted`, input at `bodyLarge` (15 to 16), placeholder "Search 141 lessons" in
`inkMuted`. The count in the placeholder is the corpus size for the active exam.

### Results

**A flat list with the matched text.**

- A kicker above the list: "N lessons" in 11.5 `inkMuted`.
- Each row: the title with the matched substring wrapped in `ink` at w700 and the
  rest at normal weight, the topic beneath in `bodySmall` `inkMuted`, the minutes
  right-aligned, a trailing chevron.
- **When the match is not in the title**, a third line carries the sentence it
  came from, in `bodySmall` `inkMuted`, with the match in `ink` w700 and an
  ellipsis on each truncated side. Roughly 34 characters of lead and 46 of trail.
  Without this a body match is a row with no visible reason to be there.
- Highlighting uses weight and color only. No background fill: `mark` is
  transparent.

### Search states

| State | Treatment |
|---|---|
| Field open, empty query | "Recently opened" kicker over the last three lessons opened, each a tappable row |
| No matches | Centered, serif 18 "Nothing matched “swap”", body "Try a shorter word, or part of one." |

Ordering of results is corpus order (subject, then topic, then the lesson's
authored `ordering` once it exists). No relevance ranking.

---

## Section 3: Bookmarks

### The mark

A **ribbon**, drawn in a 12 by 16 viewBox rendered at 15 by 18.

- Unset: outline, stroke 1.4, `inkMuted`, path `M1.6 1.6h8.8v12.8l-4.4-3.9-4.4 3.9z`
- Set: solid fill, `ink`, no stroke, path `M1 1h10v14l-5-4.4-5 4.4z`

The same glyph appears on Study map rows, in the head section, in the sheet, and
in the reader. One mark, four surfaces, so the feature explains itself.

It cannot be board green: the budget spends board on the primary action, progress
indicators and done checks, and the reader's rail sits directly beneath the
control.

### The ink rise

The set transition is an ink rise, matching the navigation bar's, with one
deliberate difference.

- **The fill falls from the top**, where the nav's rises from the bottom. A tab
  rises from the bottom because it sits there; a ribbon falls from the top because
  it hangs there. The notch filling last is the better final beat.
- 400ms on `cubic-bezier(.22, 1, .36, 1)`, the settled navigation constant.
- **Unsetting drains instantly**, matching the rule that an outgoing tab does not
  animate.
- Disabled under reduce-motion, falling back to a plain swap.

### Bookmarks are lesson level

Set and unset from the reader. Not topic level: "I read this and did not absorb
it" is about a lesson, and the control lives on a screen showing one lesson.

### The sheet

Opened by "See all" from the Study map. A bottom sheet, not a route.

- 8px top radius per `bottomSheetTheme`, 1px `rule` top border, capped at 74% of
  the screen, drag down to dismiss, tap the wash to close.
- **Wash: `ink` at 34%.** The page behind settles 10px down and loses a hair of
  scale on the same curve. No blur: it is a glass metaphor in a paper identity and
  a per-frame GPU pass on budget Androids.
- A 34 by 3 grab handle in `rule`, radius 2, 9px above and 2px below.
- Header: "Bookmarks" in serif 18/700, and **Edit / Done** in 13/600 `board` on
  the right. **Not "Save"**: drags and deletions apply immediately, so "Save"
  would promise a Cancel that does not exist.

### The order control

Four labels on one row, closed by a 1px `rule`:

**Recent · By subject · Oldest · Custom**

12.5px, `inkMuted`, the active one in `ink` at w700, separated by 1px by 12px
`rule` ticks with 10px margins either side. **No pills**, which the identity bans.
Every option is visible rather than hidden behind a picker, because Custom is the
feature and nobody finds a feature inside a menu they never open.

- **Default: Recent**, newest first. Needs nothing but the timestamp the table
  carries anyway, and the section is a shortcut back to what just lost you.
- "By subject" was called "Index", which was ambiguous and implied a lesson
  ordering that does not exist. Within a topic, ties fall back to the authored
  lesson order once it exists.
- **The Study map's three rows follow this order.** Only three surface, so a
  custom order is the student choosing which three the Study tab shows them. If
  the order did not govern the head, arranging it would change nothing anyone
  looks at.

### Custom order and drag

- **Drag is always live in Custom**, with a grip on every row. No mode to enter.
- A new bookmark **lands at the top** in Custom. Appending to the bottom of a
  hand-sorted list makes a fresh bookmark invisible.
- **Positions are retained silently** when the order is switched away and back.
  No dialogue, ever: a prompt on every sort change punishes exploring. An explicit
  **"Reset order"** lives in the sheet for anyone who wants it gone.

### Edit mode

Entered with "Edit", left with "Done".

- Rows gain a 15 by 15 checkbox, radius 3, 1.4px `inkMuted` border, filling
  `board` with a white check when selected.
- In Custom, grips remain, so a row can carry both. This is the platform
  convention and needs no explanation.
- A footer closed by a 1px `rule` top: "N selected" in `bodySmall` `inkMuted`, a
  secondary "Select all", and **"Remove"** as a secondary button bordered and
  lettered in `rust`.
- **Undo on bulk removal**, as a ruled banner reusing `ErrorBanner`'s variant and
  action slot: "3 bookmarks removed" with "Undo". No undo on reordering, because
  "undo which drag" has no clear answer. A single bookmark is trivially recovered
  by reopening the lesson, so undo exists for the bulk case.
- Rows carry a chevron outside Edit mode, since each opens its lesson. Inside Edit
  mode a tap selects, so the chevron is not drawn.

---

## Section 4: The reader, `/lesson/:lessonId`

### The bar

Height 56, `background`. Two possible compositions, differing only in the context
control.

**Leading:** a back chevron at 15px, stroke 1.6, plus the origin word in 13.5
`inkMuted`. Two origins only, **"Home"** and **"Study"**, now that the topic page
is gone. The back arrow is the only exit, since the reader is pushed outside the
tab shell.

**Trailing, in this order, bookmark always outermost:**

| Origin | Context control | Then |
|---|---|---|
| From Home, in a plan | "2 of 3" in 12.5 `ink`, tabular, tappable | the ribbon |
| From Study, no plan | the contents glyph | the ribbon |

The order rule is **[context] [bookmark]**, so the ribbon never moves.

**The contents glyph**: three hairline rules of decreasing length, drawn at 21 to
23px with stroke 1.5 and round caps, paths `M4 7h16`, `M4 12h12`, `M4 17h8`.
Rejected: dots with rules, which is one step from the vertical-dots overflow menu
and will be tapped expecting settings. Rejected: stacked pages, which collides
with the Progress tab's folded sheet.

**The counter is tappable** and opens the day as a sheet, with the finished
lessons ticked and the current one marked "reading". Telling someone they are 2 of
3 invites "what is the third", and there was no way to find out without leaving.

**The contents glyph** opens the topic's lessons as the same sheet component.

### The collapsing title

**The lesson title never appears in the bar.** It appears only in a strip beneath
it, which has zero height and grows to 30px over the first 90px of scroll, fading
in on the same fraction. Title set in serif 13/700, single line, ellipsised.

Drawing the title in the bar *and* the strip was the crowding that made the
trailing controls unreadable. One title, one place.

### The rail

Directly beneath the strip. 3px tall, `ruleFaint` track, `board` fill.

- **In a plan:** `(lessons done + progress through this one) / total`, with 1px by
  5px `rule` ticks at lesson boundaries.
- **With no plan:** tracks progress through the single lesson, no ticks.

### The body

Rendered by `PortableTextRenderer` as today: `h2` at `displaySmall` (serif 22),
`h3` at `headlineMedium` (serif 18), blockquotes at `bodyLarge` italic with a 2px
`rule` left border, normal blocks at `bodyMedium` (sans 14, height 1.5). Page
gutter 20px, 18px above the title.

### Marking a lesson read

**Automatic only. There is no button.**

A lesson is marked read on reaching the end of the body past a dwell floor.

**Because there is no manual override, the floor must be conservative rather than
strict.** Reaching the end of the body already excludes the accidental case of
opening and backing out, so the floor exists only to catch a flick to the bottom.
A strict floor would leave a fast reader with permanently unread lessons and make
coverage under-report for exactly the students most likely to look.

The gap states it plainly: a board `✓`, the word "Read", and "marked
automatically" right-aligned in 11.5 `inkMuted`.

This is the fix for every downstream figure. Today they all count button presses.

### The quiz coda

An **outlined** button in the gap, above the pull handle: 1px `ink` border, radius
5, padding 11 by 15, 13/600, full width, reading **"Quiz yourself, 5 questions"**.

Not a filled block, which would compete with advancing, and not a text link, which
nobody would see. It routes to `/quiz/inline/:examId/:lessonId`, which is already
wired. Spec 4's terms hold: 5 questions, lesson-scoped, feeds FSRS, no streak
credit.

### The pull

**The pull always advances to the next lesson**, in both origins. One gesture, one
meaning. With no plan it advances through the topic's authored lesson order.

This fires the upgrade the earlier reader spec already sanctioned in writing once
ordering is authored, and it retires the pull-up "rest of the topic" sheet, whose
job moves to the contents glyph in the bar.

**Mechanics, the "plain rise":**

- Two stacked widgets on one page driven by an `AnimationController` off a
  `GestureDetector`. No route transition, so the back stack stays clean.
- Range 150px, **threshold 90px**.
- The incoming page tracks the pointer, translating from 100% to 0.
- The outgoing page moves up at **1.6x** the pointer and fades **linearly**.
- The handle is 36 by 3 in `rule`, radius 2, becoming **52 by 3 in `board`** when
  armed, transitioning over 120ms linear.
- The label beneath reads "Pull up for **Real and Imaginary Number Systems**",
  with the lesson name in `ink` w600, turning `board` when armed.
- Release short of the threshold settles back over 320ms on
  `cubic-bezier(.22, 1, .36, 1)`. Release past it commits on the same curve.

Rejected: the "refined" variant with a drag-coupled rail and held opacity.

---

## Section 5: The endings

**Ceremony scales with rarity.** A day ends daily. A topic ends eighteen times in
an entire UPCAT campaign. Treating both the same makes the daily one exhausting
within a week and drains the rare one of meaning.

**The ending is a page in the chain.** The last pull works one final time and
lands on it, so the gesture never dies on a handle that goes nowhere. **There is
no pull on the closing page itself**: if the pull also started the next topic the
run would never end, which would spend the ending entirely.

### The closing page's bar

**Back control only.** No bookmark, since there is no lesson to act on. No
contents glyph, because "Back to Study" already lands on the map with the topic
still expanded and every lesson one tap away, so a sheet would be duplicate
navigation.

The rail runs to 100% as the page arrives, 120ms after entry, over 550ms on
`cubic-bezier(.22, 1, .36, 1)`.

### A finished topic: the bookplate

A hairline box, 1px `rule`, padding 28 by 20, centered. It fades in and rises 8px
over 500ms on the standard curve, 160ms after entry.

```
              Aedwon
    ─────────────────────────
      Arithmetic & Number Sense
        UPCAT, Mathematics
    ─────────────────────────
         9 lessons, all read
            27 July 2026
```

| Line | Style |
|---|---|
| Name | serif 14, `inkMuted`, closed by a 1px `ruleFaint`, 16px below |
| Topic | serif 31/700, tracking -0.6 |
| Exam and subject | 11.5, `inkMuted`, 5px below the topic |
| Footing | 12, `inkMuted`, opened by a 1px `ruleFaint` 14px above |
| Date | 12, `inkMuted`, italic, on its own line |

**The box is a deliberate exception** to the identity's rule that grouping comes
from whitespace and hairline rules rather than boxes. The ban exists to stop cards
being used as generic grouping. This is not grouping: it is a single object, once,
at the end of a run, and an object is what gives it edges to become an artifact.

**There is no figure.** Every honest figure was unavailable and every available
one said nothing. "11 lessons" restates what the reader just did and what the map
already shows, and a 52px numeral is what made the plate read as a stats card.
Any time figure would be `estimatedMinutes`, which describes the material, not the
student, and printing an estimate under someone's name on a page meant to feel
earned is the worst possible thing to be approximate about.

**The name comes from onboarding.** The Home spec adds a name step after the exam
picker, currently only to fill a greeting. It is skippable, so the composition must
work with the name line absent and not look truncated.

### A topic stopped short

The same plate, with the footing reading **"6 of 9 lessons read"** and the date.

**No headline.** The line "The end of Algebra" is deleted rather than rewritten:
the plate states the fact, so a headline has no job. Nothing on this page reads as
a scolding.

Beneath, a block: the kicker "Still unread" in 11.5 `inkMuted`, then the remaining
lessons as rows with their minutes and a chevron each.

### What follows a finished topic

A block opened by a 1px `rule`:

```
Next
Geometry
Eight lessons, about an hour and forty of material.
```

Kicker 11.5 `inkMuted`, name serif 17/700, meta 12.5 `inkMuted`, with a **static
chevron** on the right. It is a link, not the pull. Finishing a topic is the best
moment there will ever be to make the next one look small, and "eight lessons,
about an hour and forty" is what makes it look small.

### A finished day

No plate. One line, centered, with 26px above:

> **That's enough for today.**

Serif 22 (`displaySmall`), tracking -0.2, and **nothing beneath it**. No facts, no
count, no minutes.

Every other candidate reports; this one releases. For a student opening the app
late at night with a countdown in Home's masthead, being told they have done
enough is the rarest thing the app can say, and it manages it with no praise, no
adjective and no exclamation.

**Two things this depends on.** Home's "Keep going" affordance must stay a real
offer, or the line is the app sending someone to bed. And the contraction is a
deliberate copy exception: the identity bans em dashes, emoji and all-caps but
says nothing about contractions, and this line has to sound like a person.

### The exit

A ruled row opened by a 1px `rule`, 15px vertical padding, centered, reading "Back
to Home" or "Back to Study" in 14/600 **`board`**.

Within the color budget rather than an exception: the closing page has exactly
one action, so this is its primary action. A filled green button would be shouting
about the door on a page whose primary act is already done. The full row width
carries the 48dp target.

---

## Section 6: Kit changes

These land on every list in the app, not only Study.

### The chevron rule

The prior rule was "a chevron marks a row that is its own destination". A topic
row is no longer a destination and still earns one, so:

> **A chevron marks a row that does something when tapped. A chevron that rotates
> is a disclosure. A chevron that does not is a link.**

Chevrons are 12px at stroke 1.4 in `inkMuted`, sitting after the meta column.
This amends the earlier 1.2px figure.

### `InkTableRow`

- Gains a trailing chevron slot.
- The glyph column is **always reserved** when any row in a list can carry one, so
  titles align down the page whether or not a given row has a glyph. The current
  implementation reserves it only when `state != plain`, which shifts titles 22px
  and is why a started topic looked wrong.
- `InkRowState.active` stops rendering `○`. A started item is signalled by its
  meta, not by a bullet in the gutter.

### The nav bar

Unchanged from the Home spec, and the source of the ink-rise constants the
bookmark inherits. Glyphs confirmed: house **with a doorway cut out**, open book
with a spine, single answer bubble, folded-corner sheet with a rising line. 23px,
stroke 1.50, outline `inkMuted` inactive, filled `ink` active.

---

## Section 7: Data and storage

### New

| Need | Shape | Notes |
|---|---|---|
| Lesson order | `ordering` integer on lessons | Frontmatter, seed builder, schema, domain model, and an `ORDER BY` in `lessonsByTopic`. Subjects and topics already have this |
| Last opened | one stored lesson id per exam | A preference, not a table |
| Bookmarks | `lesson_bookmarks_local`: `lessonId` text PK referencing `Lessons`, `markedAt` datetime, `sortIndex` integer nullable, `syncState` text defaulting to `pending` | Mirrors `lesson_progress_local` exactly, plus a sync mapper on the existing pattern |
| Open topic | one stored topic id per exam | A preference |

Bookmarks may **not** live on `lesson_progress_local`: `readAt` is non-nullable and
a row there means "read", so marking an unread lesson would require making it
nullable and changing what every existing row means.

`sortIndex` is null until someone drags, so Recent order needs nothing.

### Unused today, to be consumed

`readCountForTopicProvider` (`storage.dart:98`) computes exactly the topic
rollup the map needs and is referenced nowhere.

### Content work

Authoring `ordering` across 141 lessons in 18 topics is editorial judgment, not
code. It is now load-bearing: with "Start here" dropped and the pull advancing
forward only, the authored sequence is the **only** guidance a student receives
about where to begin.

---

## Section 8: Amendments to other specs

1. **`2026-07-26-home-and-navigation-design.md`** still documents "Weakest areas"
   with "Practice these" pointing into Study. The Quiz anchor decision replaced
   that on the same day: the panel is **Practice**, its rows fire
   `start_today_session(topic, mode: perTopic)`, and its action is "See all"
   pointing at the Quiz tab. Home no longer routes to a topic at all.
2. **`2026-07-18-ui-redesign-design.md`** gains the bookplate as a named exception
   to "grouping by whitespace and rules, not boxes", and the chevron rule above.
3. **`2026-05-10-plan-06-lesson-reader-design.md`** is superseded for the reader's
   chrome, its motion and its endings.
4. **Route table:** `/study/topic/:topicId` and `LessonListPage` are deleted.
   `_studyPath` in `assessment_home_tab.dart` is deleted with them.

---

## Deferred, with reasons

- **Real reading time.** Auto-marking already has to time the session against a
  dwell floor, so the total is the same timer plus one column. It would make the
  bookplate's figure honest and let the map stop estimating "hours left". Same
  slot, so nothing is redesigned when it arrives. Edge cases to handle: the app
  backgrounded, the screen off, a lesson left open overnight.
- **The acknowledgment system.** Trophies for finished subjects, an exam-level
  artifact, a shareable card. **The bookplate is the seed**: the same composition
  at a larger size, carrying a name, a subject and a date, *is* the card. That is
  also the answer to UI-013, where `wrapped_share_card.dart` still renders a purple
  and navy gradient with nothing of this identity in it.
- **A quiz entrance in Study.** Five `SectionHeader` action slots sit empty and the
  map has no door to Quiz.
- **Per-topic accuracy**, which lost its home when the topic page was deleted.
- **Night mode review.** Every surface has been drawn in both themes but only
  glanced at in dark. The sheet's `ink` scrim at 34% is the known weak point:
  ink on near-black separates poorly, and it may need the `background` token in
  dark instead.

## Open

1. **The day line's size**, 22px `displaySmall` against 18px `headlineMedium`.
2. **The reader's bar height.** The mockups drew it at 52 while the Study map used
   56. `AppBarTheme` is themed once, so both should be 56 unless the reader
   deliberately deviates.

## A note on plan size

This is too large for one implementation plan. The natural seams, in dependency
order:

1. **Foundations.** Lesson `ordering` end to end, the bookmarks table and its sync
   mapper, the last-opened and open-topic preferences, and the `InkTableRow`
   changes. Everything else depends on these and none of it is visible.
2. **The Study map.** Composition, expansion, the pinned bar, states, and the
   deletion of `LessonListPage`, `/study/topic/:topicId` and `_studyPath`.
3. **Bookmarks and search.** The sheet, the order control, edit mode and undo,
   then search in the bar.
4. **The reader.** Chrome, paging, the pull, auto-marking, the coda.
5. **The endings.** Both closing pages and their motion.

The content work, sequencing 141 lessons across 18 topics, runs alongside 1 and
must land before 4, since the pull advancing forward only makes the authored order
the sole guidance a student receives.
