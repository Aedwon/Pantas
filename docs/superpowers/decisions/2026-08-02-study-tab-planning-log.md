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

### One copy problem the plan refuses to bury

The spec's error message is "Could not load your topics. **Pull down to try again.**" There
is no pull-to-refresh on this screen and the plan does not build one. Plan 2 says outright:
either wire a `RefreshIndicator` in Task 7 or change the copy to "Try again". **Shipping the
sentence without the gesture is a lie printed to a student**, which is the same class of
problem as an invented figure.
