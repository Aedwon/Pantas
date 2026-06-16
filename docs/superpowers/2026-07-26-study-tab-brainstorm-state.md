# Study tab redesign: brainstorm state

**Date:** 2026-07-26
**Status:** brainstorming, no spec written yet, no code changed
**Skill:** `superpowers:brainstorming` with the visual companion

Resume from here. Nothing in `lib/` was touched. `assets/seed/v1.json` was already
modified before this session started and is unrelated.

---

## Visual companion

Running on the LAN so it can be opened from an iPhone on the same WiFi.

```
http://192.168.1.92:59254/?key=6d81bfd49ce81f5fc0533e2ea804deb9582cea0c61beac8128f3890c98c35e73
```

Session dir: `.superpowers/brainstorm/45653-1785048649/`
Restart, keeping the same port so open tabs reconnect:

```
~/.claude/plugins/cache/superpowers-marketplace/superpowers/6.1.1/skills/brainstorming/scripts/start-server.sh \
  --project-dir /Users/aedwon/Documents/Projects/Pantas --host 0.0.0.0 --url-host 192.168.1.92
```

Restarting creates a **new** session dir. Copy `content/*` across or the screens are lost.
Never edit a screen file in place: the watcher only pushes on new files.

Screens, newest last: `study-tab-current-state`, `planned-vs-built`, `specced-vs-built`,
`head-block`, `study-destination`, `topic-page-v2`, `cross-topic`, `edges-and-pullup`,
`reader-motion`, `reader-motion-v2`, `reader-motion-v3`, `reader-header`, `reader-header-v2`,
`reader-header-v3`, `topic-sheet`, `plan-lifecycle`, `home-full`, `home-full-v2/v3/v4`,
`home-panel-load`, `weakest-alternatives`, `quiz-anchor`, `quiz-anchor-v2`, `c-details`,
`c-details-v2`, `row-affordance`, `upnext-chain`.

---

## Where the Study tab stands today

Two screens in the tab, one outside it.

| Route | Widget | File |
|---|---|---|
| `/study` | `StudyTabHome` | `lib/features/lesson/presentation/learn_tab_home.dart:24` |
| `/study/topic/:topicId` | `LessonListPage` | `lib/features/lesson/presentation/lesson_list_page.dart:13` |
| `/lesson/:lessonId` | `LessonPage`, outside the shell | `lib/features/lesson/presentation/lesson_page.dart` |

Findings from the audit that drive the redesign:

- **Progress stops at the lesson.** Reads are stored and rendered per lesson. Nothing rolls
  up. `readCountForTopicProvider` (`lib/core/storage/storage.dart:98`) exists, works, and is
  consumed by nothing.
- **Nothing sorts anything.** Neither `topicsBySubject` nor `lessonsByTopic` in
  `lib/core/storage/data/repos/content_repository.dart` has an ORDER BY. Topics carry an
  `ordering` field that is hydrated then ignored. Lessons have no ordering field at all.
  This blocks any "next lesson" outside a plan.
- **The accordion was built and then lost.** Shipped 2026-05-10 (`4bfacc9`) as an
  `ExpansionTile`, removed 2026-07-19 in the Ink & Rule sweep (`32f1425`) because the kit had
  no collapsible primitive. Collateral damage, not a decision.
- **PageScaffold and EmptyState go unused**; both screens hand-roll Scaffolds and empty states.
- **Errors print raw SQLite exceptions to students.**
- Only two exams are active: UPCAT (5 subjects, 18 topics, 141 lessons) and CSE Professional
  (1 subject, 1 topic, 3 lessons). The same screen must hold both.

---

## Decided

### Navigation and destinations

- Home's **topic-level** entries land on a new **topic page**: the accuracy that sent them,
  coverage, recommended lessons, the full lesson list, and a quiz door.
- Home's **lesson-level** entries (Up next rows) go straight to that lesson.
- `_studyPath` in `assessment_home_tab.dart:215` currently sends weak topics to a bare
  `/study/topic/:id`. That is the weak link being fixed.

### The reader

- **Paged lessons, not one continuous document.** Each lesson is its own page so the bar and
  rail always know where you are.
- **Advancing is deliberate.** Scrolling to the end reveals a panel; it never carries you over.
- **Drag-driven transition, "plain rise":** next page tracks the pointer, outgoing page moves
  up faster and fades linearly. Threshold 90px of a 150px range; handle turns board green when
  armed. Rejected the "refined" variant (drag-coupled rail, held opacity).
- In Flutter this is two stacked widgets on one page driven by an `AnimationController` off a
  `GestureDetector`. No route transition, so the back stack stays clean.
- **Quiz offer in the gap:** an outlined button, "Quiz yourself, 5 questions". Not a block, not
  a text link. This is the specced inline coda (Spec 4, `start_inline_lesson_quiz.dart`,
  5 questions, lesson-scoped, feeds FSRS, no streak credit).
- **After the quiz, the same pull handle** advances to the next lesson.

### The reader header

- **Back label follows origin:** Home, Study, or the topic name. The back arrow is the only
  exit, since the reader is pushed outside the tab shell.
- **Collapsing title:** the strip has zero height and grows 0 to 30px on the same scroll
  fraction that brings the title in. No blank space reserved before it is earned.
- **Counter top right in the bar**, opposite the back control: "2 of 3". Hidden when there is
  no plan.
- **Rail under the header, scroll-linked:** in a plan it reads
  `(lessons done + progress through this one) / total` with ticks at lesson boundaries. With no
  plan it tracks the single lesson.

### No plan (arrived from the Study map)

- No counter, no ticks, no "Back to X" button at the end.
- **Pull up reveals the rest of the topic** as a sheet: remaining lessons with read marks, the
  first annotated as closest to what they just read. Chosen over pull-to-next because lesson
  order does not exist yet. Upgrades to a straight next-lesson pull if ordering is authored.
- **Paper wash behind the sheet:** scrim in the paper colour at 82%, no blur, plus the reader
  settling 10px down and losing a hair of scale. Blur was rejected: it is a glass metaphor in a
  paper identity, and it is a per-frame GPU pass on budget Androids.
- Sheet: 8px top radius per `bottomSheetTheme`, header with count and total time, scrollable,
  capped at 74% height, drag down to dismiss, tap behind to close.

### The plan's lifecycle

- **Computed, never stored.** Derived when Home builds; the resolved lesson ids travel into the
  reader as route arguments so the chain is stable while walked and fresh next time.
- **Frozen for the local day.** Clearing it shows a finish state, not a refill.
- **"I want to keep going"** as a quiet secondary that generates more on request. Board green
  sits on the finish, not the extension.
- This honours the daily new-material cap Spec 4 already enforces. Sizing the day from the exam
  date (Spec 6) drops in later without redesigning anything.

### Reading is measured differently

- **Auto-mark read** on reaching the end of the body past a dwell floor, roughly a third of
  `estimatedMinutes`. The explicit button stays as an override. Without this, every downstream
  feature measures button taps rather than reading.

### Edge cases settled

1. **One-topic exam (CSE Pro):** subject labels appear only when the set spans more than one
   subject. Never render the block empty.
2. **No assessment:** Home already falls through to the assessment invitation
   (`assessment_home_tab.dart:287`). Up next exists only post-assessment. No invented plan.
3. **All read, still weak:** Up next shows a finish state, "Nothing left to read in your weak
   topics", and stops there. It was originally decided that the block would "change currency from
   lessons to practice", but the Practice panel now sits directly beneath it and already carries
   that offer, so restating it here would duplicate the panel one scroll apart. Revised
   2026-07-26 when the Quiz anchor was settled.
4. **Read outside the plan:** dropped silently on the next computation, skipped inside a live
   chain. No interstitial.

### Home

- **Up next is "the day, as lessons":** three lesson titles with minutes, under one sentence
  carrying the subject mix and total time ("Algebra, Geometry and Chemistry today. About 28
  minutes."). No subject label per row. 8 things to read instead of 16.
- **Accuracy figure carries direction:** `64% ↑6`, labelled "accuracy this week". The per-topic
  rows give the breakdown, the band gives the movement.
- **The streak is stated once**, in the Lately line. The done state states the work instead.
- **The countdown lives in the masthead only.** In the no-assessment state the stats band is
  dropped entirely rather than half filled.
- **Weakest areas stays**, but not as specced. See "Home's Quiz anchor" below, which supersedes
  the "Practice these" link.

### Home's Quiz anchor (settled 2026-07-26)

The problem: Up next and Weakest areas name the same three topics every day, by construction,
and **both send the student into Study**. Up next rows open lessons in Algebra, Geometry and
Chemistry; Weakest rows open the topic pages for the same three. Home's only door to Quiz was a
10.5px link in a plate. A merged "Where to work" panel was built and rejected as too much
information; dropping Weakest areas was rejected too.

What Spec 4 plans for the Quiz tab, which shaped the answer:

- §7.1 makes it a **per-topic queue**, not a single button. Topic rows carrying
  `12 due · 4 weakness · 2 new`, tapped to start a focused ten question session.
- The queue is ordered by **backlog**; Up next is ordered by **weakness**. Different rankings.
- D2 means **there is no empty state**. With nothing due a session rebalances to 70% weakness
  and 30% new, and caught up topics still render with a check. Weakness is a permanent bucket,
  so a weakness-keyed panel never needs a fallback.
- D8 means **Drill earns no streak**. This decides the call below.

Decided, drawn on `quiz-anchor-v2`, `c-details-v2`, `row-affordance` and `upnext-chain`:

- **Weakest areas becomes the Practice panel.** Same three rows, same meters, same percentages,
  same height. Plate reads **Practice**, with the lead line "Ten questions on whichever you tap."
  The two panels stop being duplicates the moment they stop sharing a destination.
- **A row fires `start_today_session(topic, mode: perTopic)`**, the same call the Quiz tab's own
  rows make. Not `start_drill`: per D8 a drill earns no streak, so Home's most prominent practice
  affordance would silently fail to feed the streak. With the right call the row inherits the
  60/30/10 composition, streak credit, resume and nudge rules.
- **The plate action is "See all"**, pointing at the Quiz tab. "Practice these" is retired: once
  the rows carry the verb, the link repeated it. "See all" also patches the one hole in this
  design, since the weakest three are not always the three with the largest backlog, and the
  queue is where that recommendation lives.
- **Home no longer routes to the topic page.** Its only entrance becomes the Study tab map.
  Accepted: browsing a topic is a Study job, and Up next already skips the topic page.

### Rows that can be tapped carry a mark

`InkTableRow` (`lib/core/ui/components/ink_table_row.dart`) has **no trailing affordance at all**:
a state glyph on the left, meta on the right, tappability signalled only by the ripple. A tappable
row and a dead row are pixel identical. This is a kit change, so it lands on every list in the app.

- **A chevron, stroked 1.2px, `inkMuted`, sitting after the meta.** Rows keep an aligned column of
  percentages, inset from the panel edge by the chevron's fixed width rather than flush to it.
- **The rule: a chevron marks a row that is its own destination.** The Practice rows earn one
  because each is an independent session. The Up next rows do not, because they are three steps
  of one action that "Continue lesson" owns. Both are tappable; only one kind is a destination.
  Without this rule the mark drifts onto every list and stops meaning anything.

### Tapping an Up next row enters the chain

"Continue lesson" resolves the day into three lesson ids and passes them to the reader as route
arguments. That chain is what pays for the counter, the boundary ticks and pull to advance, so a
row that opens a lone lesson drops the student into the reader's no plan mode without telling them.

- **A row tap enters the chain at that position**, by adding a start index to the arguments that
  already travel. Tap the second row and the reader opens on "2 of 3", the ticks survive, and the
  pull up still advances to the third lesson.
- Entering at row two **skips** row one for the day rather than queueing it behind, which is how
  the plan already behaves when something is read out of order.

---

## Open

### 1. Topic page "Start here" with several recommendations

Ordered plan, one lesson with the rest marked inline, or marks only with no block. Drawn on
`topic-page-v2`, never chosen.

### 2. Do we author lesson order?

A content and schema question. If yes, pull-to-next works outside a plan and both Study lists
stop being accidental. If no, sequence stays plan-only.

### 3. Is the "2 of 3" counter tappable?

Would open the plan and give a second way out. Cheap, but adds a surface.

---

## Constraints any of this inherits

- **Colour budget:** board green only on the primary action, progress indicators and done
  checks. One primary action per screen. Rust and amber are semantic only.
- **Type:** Source Serif 4 for display, Source Sans 3 for everything else.
- **Dimensions:** radii 5 and 8, no pills, 1px hairlines, 3px progress bars.
- **Copy:** no em dashes, sentence case, no emoji, "readiness" reserved.
- **Panels are ruled, not carded:** 1px rule border, square corners, plated serif heading with
  a 1.6px ink underscore.

## Specs that govern

- `docs/superpowers/specs/2026-07-26-home-and-navigation-design.md` — Home composition, nav
  icons, scopes Study out
- `docs/superpowers/specs/2026-07-18-ui-redesign-design.md` — Ink & Rule tokens and kit
- `docs/superpowers/specs/2026-05-10-plan-06-lesson-reader-design.md` — the original reader plan
- `docs/superpowers/specs/2026-05-11-lesson-progress-design.md` — read state, the reserved icon
  slot that was never built
- `docs/superpowers/specs/2026-05-17-quiz-engine-and-modes-design.md` — the inline coda, the
  daily new-material cap
- `docs/ui-audit.md` — UI-009 to UI-013

## Next step

The Quiz anchor is settled. Work open items 1 to 3, starting with the topic page "Start here",
then write `docs/superpowers/specs/2026-07-26-study-tab-design.md` and hand off to `writing-plans`.

Note that item 1 is entangled with item 2: whether "Start here" can offer an ordered run depends
on whether lesson order is authored.
