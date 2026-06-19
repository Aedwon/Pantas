# Study tab, planning decision log

Chronological. Later entries append; they never edit earlier ones. Source spec:
`specs/2026-07-27-study-tab-and-reader-design.md`, approved and closed on 27 July.

---

## 2 August 2026, evening: I started implementing instead of planning

Aedwon asked me to read the work checkpoint, list the implementation plans I could work
on, then "work on the first thing, commit, and push". I read that as *execute* the first
plan in the execution queue, `2026-08-02-content-seed-delivery.md`, and got three steps
into it: I wrote `test/core/content/bundle/content_asset_test.dart`, watched it fail,
declared `assets/seed/content.db` in `pubspec.yaml`, and had just found that the plan's
expected SQLite magic string was wrong when he stopped me.

**Verbatim:**

> no i didn't tell you to execute! i wanted you to WRITE the plans. implementation plans
> only not implementation itself

**What I got wrong.** The division of labour in `CLAUDE.md` is explicit: we brainstorm, I
write the spec, then the plan, and other models execute. "The first thing" meant the first
thing *I* can do, which is a planning job, not the first row of the execution queue. Both
changes were reverted; the tree was clean before any planning began.

One thing found in passing and worth keeping, because it will bite whoever does execute
that plan: **`content-seed-delivery` Task 1 asserts the wrong SQLite header.** It expects
`'SQLite format 3 '` with a trailing space. The real 16-byte magic ends in a NUL,
`0x00`, verified against `assets/seed/content.db` with `xxd`. The test as written fails at
offset 15.

## 2 August 2026: five plans, not two

**The options.**

| Option | Cost |
|---|---|
| Two plans, the map then the reader, as the work checkpoint guessed | The bookmarks table, the sync mapper, the `ordering` column and the `InkTableRow` change all land inside a UI plan, so a reviewer cannot reject the map's composition without also rejecting the storage under it |
| Five plans, following the spec's own seams | Four more handoffs, and the foundations plan has no visible surface for Aedwon to look at |

**Chosen: five.** The spec's closing section already names them in dependency order:
foundations, the map, bookmarks and search, the reader, the endings. The checkpoint's
"likely two plans" was written on 2 August before anyone had re-read the spec, and the
spec's own breakdown is the more considered one. The Quiz tab, a comparable surface, came
out at seven.

## 2 August 2026: three calls made inside plan 1, each with its cost

Recorded because none of them was put to Aedwon and each is cheap to reverse.

1. **`lessons.ordering` defaults to 0 rather than being nullable.** Sorting on a nullable
   integer means every query carries a `NullsOrder` and every comparison has a null branch.
   Cost: "unplaced" and "first" are the same stored value, so nothing can tell them apart in
   SQL. Mitigated by the builder numbering every file, so zeros only exist on databases
   seeded before this lands.
2. **The dev seed builder numbers each topic's files from 1 in glob order** when the
   frontmatter has no `ordering:`. Cost: it makes the accidental alphabetical-by-slug order
   explicit rather than leaving it implicit, which could read as an endorsement of it. The
   alternative, emitting nothing, would have changed what students see today for no reason.
   The editorial pass over 141 lessons stays Aedwon's.
3. **The last-opened lesson and the open topic are device preferences, not account
   preferences.** `PreferencesMapper` syncs `account_prefs` only. Cost: signing in on a
   second device opens Study collapsed rather than where the phone was. The trade is
   deliberate: "which topic is expanded" is a property of one screen on one device, and
   syncing it means a tablet scrolling because a phone was tapped. Two lines to reverse.

**Left out of plan 1 deliberately, with a reason that is not scope.** The content database's
`content_lessons` does not get an `ordering` column. `ContentDatabase` declares
`onCreate` and **no `onUpgrade` at all**, so bumping its schema version against a file
already on a device throws rather than migrates. That file is replaced wholesale when it is
regenerated, so the column belongs to the regeneration pass. Adding it in a migration would
have been a live defect, not a tidy-up.

**One plan-level invention, flagged rather than buried.** The spec gives the chevron's
geometry but no duration for its rotation. Plan 1 specifies 200ms on `Curves.easeOutCubic`
and says so in a "Decided without asking" section. The identity's settled constant, 400ms on
`cubic-bezier(.22, 1, .36, 1)`, is right for an ink rise across a whole glyph and slow for a
12px caret.

## 2 August 2026: plan 2 found a hole in the spec that would have shipped a crash

**Spec Section 8.4 says `_studyPath` is deleted** because "with Home no longer routing to
topics, both callers go". That is true of the **redesigned** Home, which is unimplemented and
unplanned. On the tree as it stands there are **four live call sites** into
`/study/topic/:topicId`:

- `assessment_home_tab.dart:209`, the "Continue studying" button
- `assessment_home_tab.dart:238`, every focus topic row
- `assessment_results_page.dart:122`, the weak-topic action
- `assessment_results_page.dart:203`, every mastery row

Deleting the route as written would have left four buttons on shipped screens throwing
go_router's unknown-location error. **Plan 2 Task 8 repoints all four** at
`/study?topicId=<id>`, which opens the topic on the map. Recorded because it is the second
time a Study spec statement assumed the Home redesign had landed.

**A second thing found while planning:** `assessment_results_page.dart:122` uses
`context.push` for what is now a tab route. Pushing a shell branch over a full-screen results
page leaves the student inside the Study tab with the results page underneath it. Changed to
`context.go` in the same task.

### Calls made inside plan 2, each with its cost

1. **`?topicId=` on `/study` rather than a route.** Opening a topic is a state on one page,
   already stored per exam, and there is no topic screen left to push. Cost: a query
   parameter is applied once on arrival and then ignored, which is a rule someone has to
   remember. The plan states it in the code comment.
2. **Under an hour, "left to read" prints minutes.** The spec says whole hours, which prints
   "0h" for anyone with 45 minutes left. Cost: two units on one figure.
3. **Lesson rows keep `InkTableRow`'s `bodyMedium`** instead of the spec's 13.5px. Cost: the
   indented rows are half a point larger than drawn. Adding a font size override to a shared
   row for one screen is how a component starts carrying a screen's preferences.
4. **The Bookmarks section moves to plan 3.** The spec draws it on the map, but nothing can
   create a bookmark until the reader has the ribbon in plan 4, and its "See all" opens the
   sheet, which is plan 3. Built in plan 2 it would be a block that can never appear.
5. **`?examId=` is dropped from every repointed call site.** The map reads the selected exam
   itself, so the parameter was never doing anything.

### One copy problem the plan refuses to bury (plan 2)

The spec's error message is "Could not load your topics. **Pull down to try again.**" There
is no pull-to-refresh on this screen and the plan does not build one. Plan 2 says outright:
either wire a `RefreshIndicator` in Task 7 or change the copy to "Try again". **Shipping the
sentence without the gesture is a lie printed to a student**, which is the same class of
problem as an invented figure.

## 2 August 2026: seam 3 became two plans, and plan 1 was amended in place

**Split.** The spec's third seam is "bookmarks and search". Written as one plan it came to
twelve tasks and two unrelated review surfaces, so it is now `study-03a-bookmarks.md` and
`study-03b-search.md`. They share nothing but the app bar they sit in.

**Plan 1 was amended, not superseded.** Writing 3b showed that the search field's empty state
is a "Recently opened" kicker over the **last three** lessons opened, and plan 1 Task 6 stored
a single lesson id. Storing one would have made the state unbuildable without a second
migration. Task 6 now stores a comma-joined list capped at three, under the key
`recent_lessons_<examId>`, with `lastOpenedLessonId` reading its head so plan 2 is unchanged.
Plan 1 is written but unexecuted, so correcting it in place is cheaper than a follow-up plan;
this is the same treatment `quiz-tab-01` got when its own errors were found during execution.

### Calls made inside 3a and 3b, with costs

1. **The chosen bookmark order lives in `account_prefs`, so it syncs.** Cost: a fourth synced
   preference key. The alternative, device-local, would deliver a hand-arranged order to a
   second device with no setting to display it in.
2. **A bookmark whose lesson has left the corpus is dropped, and the count follows the
   visible rows.** Cost: a bookmark can disappear silently after a content update. The
   alternative is a row that cannot be opened.
3. **`InkTableRow` gains a `leadingMeta` widget slot** so the ribbon has somewhere to sit on
   a topic row. Cost: a shared component grows a slot for one screen. The alternative was a
   `Stack`, where the glyph does not participate in layout and collides with the fraction on
   long topic names.
4. **Undo restores the removed bookmarks but not their hand positions.** `mark()` writes a
   fresh timestamp and a top-of-list `sortIndex`, so an undone bulk removal returns at the
   top. Snapshotting every row's `sortIndex` before the delete is the fix if Aedwon wants it.
5. **The search placeholder counts the active exam.** It reads "Search 16 lessons" on CSE
   Professional rather than the spec's 141, which is UPCAT's number.
6. **A summary match is rendered as a body match.** The spec only distinguishes "in the
   title" from "not in the title".

### The thing 3b is really built around

The `LIKE` runs over `bodyJson`, which is serialised Portable Text, so searching for "block"
would match the `_type` of every block in all 141 lessons and "strong" would match every
bolded word. **The SQL scan can only narrow.** Every hit is confirmed against the flattened
plain text before it becomes a row, and there is a test that searching for "block" returns
nothing. Without that step the feature looks like it works and returns the whole corpus for
a dozen common words.

### Still owed by 3a

`InkCheckbox` is now named by **four** plans and built by none of them specifically: Quiz 3,
Quiz 5, custom track A, and Study 3a. Each says to check first. Two of them running in
parallel is where this collides.

## 2 August 2026: plans 4 and 5, and what the study plan stub costs them

**The reader's bar has two compositions in the spec** and only one can be built. From Home in
a plan it shows a tappable "2 of 3" counter that opens the day as a sheet; from Study with no
plan it shows the contents glyph. **The study plan feature is stubbed**: its providers throw
and its entry row was hidden on 25 July, so there is no plan to be 2 of 3 of. Plan 4 builds
the Study composition, reserves the second value on the bar's enum, and says so rather than
shipping it quietly. Same for the rail: the single-lesson variant is built and the ticked
"in a plan" variant is left open.

**Plan 5 builds `DayFinished` anyway.** It cannot fire for the same reason, but its copy is
settled, it is one centred line, and the alternative is rewriting the closing page when plans
become real. There is a test asserting the contraction in "That's enough for today." survives,
because that is exactly the thing a later tidy-up corrects into something that no longer
sounds like a person.

### Calls made inside plan 4, with costs

1. **The dwell floor is 15 seconds.** The spec says "conservative rather than strict" and
   gives no number. Cost: a number the spec did not authorise, which is why it is a named
   constant, `readDwellFloor`, and why it is here. Long enough that a flick from top to bottom
   of a ten minute lesson does not count; short enough that rereading something known is
   never denied the mark.
2. **"At the end" is within 24px of `maxScrollExtent`.** Without the slack, a rubber-band
   overscroll or a rounding difference denies the mark on a lesson someone did finish.
3. **A lesson shorter than the viewport is at its end at offset zero.** `maxScrollExtent` is
   0 there, so the naive check makes short lessons permanently unreadable. There is a test.
4. **The exam id comes from the selected exam, not the route.** Plan 2 stopped passing
   `?examId=`, and the coda needs one. A reader that cannot resolve an exam draws **no coda**
   rather than routing to a broken path.
5. **`?from=` carries the origin word, defaulting to Study.** The map is the sole entrance to
   all 141 lessons now, so a wrong origin word is a smaller failure than a null.
6. **The reader's bar is 56, not 52.** Listed as open in the spec. `AppBarTheme` is themed
   once and the map is 56.

### What plan 5 refuses to put on the plate

**No figure at all except the footing sentence.** Recorded because it will be tempting later:
"11 lessons" restates what the reader just did and what the map already shows, and a large
numeral is what made an earlier draft read as a stats card. Any time figure would be
`estimatedMinutes`, which describes the material, and **printing an estimate under someone's
name on a page meant to feel earned is the worst thing in the app to be approximate about**.
The next-topic line says "of material", never "of your time", for the same reason.

**The headline stays deleted.** "The end of Algebra" was removed rather than rewritten,
because the plate states the fact and a headline has no job. Plan 5 has a test asserting no
headline comes back.

## 2 August 2026: the Study set as it now stands

Five plans, all written, none executed:

| Plan | Tasks | Waits on |
|---|---|---|
| `study-01-foundations` | 7 | nothing |
| `study-02-map` | 8 | 01 |
| `study-03a-bookmarks` | 7 | 01, 02 |
| `study-03b-search` | 5 | 01, 02 |
| `study-04-reader` | 6 | 01, 02, 03a |
| `study-05-endings` | 4 | 04 |

03a and 03b are independent of each other. Everything else is a chain.
