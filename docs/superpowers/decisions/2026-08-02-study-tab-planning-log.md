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
