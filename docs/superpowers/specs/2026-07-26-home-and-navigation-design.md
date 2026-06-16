# Home and Navigation Redesign

**Date:** 2026-07-26
**Status:** Approved by Aedwon, validated interactively against live mockups in
`.superpowers/brainstorm/72587-1784988095/content/`
**Closes:** UI-009, UI-010, UI-011 (partially), and the masthead half of UI-012's context

## Problem

Three findings from the 2026-07-25 manual pass, recorded in `docs/ui-audit.md`:

- **UI-009**: the bottom navigation is text only and slow to hit by thumb.
- **UI-010**: the masthead greets the user with the exam short name, not a name.
- **UI-011**: Home shows one content block where the approved mock had four.

Working through them surfaced two further problems: the app never captures an
exam date, and Home's blocks read as a waterfall with no grouping.

## Scope

Bottom navigation, the onboarding fields Home depends on, and the Home tab's
full composition. Out of scope: the Study, Quiz and Progress tabs; the study
plan feature; the projection model discussed under "Deferred" below.

---

## Section 1: Bottom navigation

The approved mock used text-only labels. Aedwon's objection was recognition
speed, not decoration, so a decorative active marker was rejected as answering
the wrong question. Icons are added.

| Property | Value |
|---|---|
| Size | 23px |
| Stroke | 1.50 |
| Inactive | Outline glyph, `inkMuted` |
| Active | Filled glyph, `ink`, label at w700 |
| Transition | Ink rise (fill sweeps bottom to top) |
| Duration | 400ms, `cubic-bezier(.22, 1, .36, 1)` |

Glyphs: **Home** a house, **Study** an open book, **Quiz** a single answer
bubble, **Progress** a folded sheet with a rising line.

Three rules the implementation must hold:

1. The rise plays **only on the tab being activated**. The outgoing tab drains
   instantly. Two glyphs animating at once reads as busy.
2. The animation is **disabled under reduce-motion**, falling back to a plain
   swap. This is an accessibility requirement, not a preference.
3. **No board green anywhere in the bar.** The colour budget reserves board for
   primary actions, progress indicators and done-checks. Marking navigation with
   it would cost the primary button meaning.

The bubble glyph was chosen over a question mark or a checklist because the fill
animation *is* the metaphor: ink rising into a bubble is a pencil shading an
answer, and UPCAT and CSE are both shaded answer sheets. The checkmark was
rejected because it already means "done" on lesson and topic rows.

400ms is longer than the platform norm. Aedwon selected it against a live
duration slider rather than from a description. Re-check it on the emulator once
the page transition is also in play, since perceived latency compounds. It is a
single constant.

## Section 2: Onboarding captures name and exam date

Home cannot render its masthead or its countdown without two fields the app
never asks for.

**Name.** A new step **after the exam picker**, so the ask lands once the user
has invested. No prefill from `AuthUser.displayName`: the name is chosen, not
assumed, and signed-out users are the majority during onboarding. The step is
skippable. Storage is a new string key in `SettingsPrefKeys` with a matching
field on `UserSettings`. A Settings row allows editing later.

**Exam date.** Captured on the **same step as the name**, not a separate one:
two short fields after the exam picker, rather than growing onboarding to five
screens. Both fields are optional. `UserSettings.examDate`
and `DriftSettingsRepository.updateExamDate` already exist and validate that the
date is at least tomorrow, but **nothing in the app writes to them**:
onboarding never touches `examDate`, and the Settings row is unwired
(onboarding-polish Task 6, unexecuted). Until this ships, `examDate` is null for
every user and the countdown cannot render for anyone.

**No-name state.** Users with no name stored, which is every existing install
plus anyone who skips, see an "Add your name" invitation in the masthead slot
that taps through to set it. This is self-healing and needs no migration prompt.
The countdown line degrades the same way: with no exam date it shows the exam
short name alone.

## Section 3: Home composition

### Masthead

Kicker over serif name over a muted meta line:

```
Magandang gabi,
Aedwon
UPCAT · 42 days to go
```

The gear stays as the only right-side element. The meta line carries both the
active exam and the countdown, which frees a stats band slot and keeps the
countdown visible without a permanent streak dateline.

The kicker is time-based, as `_greeting()` already implements
(umaga / hapon / gabi).

### Blocks and their separation

Home carries four blocks, each enclosed in a **ruled panel**: a 1px `rule`
border, square corners, on the same paper as the page.

A ruled panel is not a card. What makes a card read as generic is elevation
(shadow), a large radius, a white surface floating above tint, and a coloured
header strip. The identity bans those by name. It never banned drawing a box,
and a hairline rectangle around a group of rows is the oldest grouping device in
print. This gives hard separation with nothing borrowed.

Each panel opens with a **plated heading**: serif title underscored by a 1.6px
`ink` rule. Roman numeral prefixes were tried and rejected as meaningless.

Block order:

1. **Stats band** plus the "Lately" line
2. **Up next**
3. **Weakest areas**
4. **Your tendencies** (Section 4)

### Stats band

Two figures, **centred**: accuracy, and lessons read against total. Days to exam
lives in the masthead meta line instead, so it is not repeated here.

Centring amends both the approved mock (`text-align: left`) and the shipped
widget (`StatsBand` uses `CrossAxisAlignment.start`). This is a deliberate
choice for balance against the centred tendency card beneath it, not a drift.

The "Lately" metric atom sits beneath the band, **centred**, separated by a
faint rule.

### Up next

Three unread lessons drawn from the user's weakest topics, each row showing
title and estimated minutes, with "Continue lesson" as the block's action.

This is the **single primary action on Home**. Board green appears nowhere else
except section-header actions, which the reference sweep already sanctions.

### Weakest areas

Topic rows with an inline meter and a percentage, coloured by severity (rust
below 50, amber below 70, ink above). "Practice these" as the header action.
Semantic colour on semantic values, within budget.

## Section 4: "Your tendencies"

A Pro-gated panel presenting four behavioural insights, one at a time.

The name matters. The redesign spec reserves the word "readiness" until a real
projection model backs it, so the panel avoids it. "Your tendencies" is accurate:
these are patterns that repeat, not scores.

### The four insights

| Insight | Signal | Source | Prerequisite |
|---|---|---|---|
| Under pressure | X1 | `test_mode_delta_signal.dart` → `PressureDelta` | One full mock plus practice on matching topics |
| Stamina | P4 | `mock_stamina_signal.dart` → `StaminaDelta` | One completed full-length mock |
| What works for you | D1 | `read_then_quiz_signal.dart` → `WorkflowRatio` | One lesson read, then a quiz on that topic |
| How you answer | P1 | `per_question_speed_signal.dart` → `LatencyDistribution` | Any quiz with response timing |

All four signals are already written. None of them duplicates anything else on
Home, which was the deciding criterion: a paywall over information already on
screen converts nobody. Variants that restated the band or the weakest-areas
rows were discarded for exactly this reason.

### Presentation

A flat card inside the ruled panel, with **no inner card**. The panel is already
the enclosure; nesting one would be a card in a card.

- **Fixed height, 112px.** All four insights share one shape (a label, two
  compared figures, one sentence), so the height falls out of the content rather
  than being imposed by padding or truncation. Locked cards use the same box, so
  nothing jumps mid-swipe.
- **Swipe only.** No auto-advance: nothing moves while it is being read, and
  reduce-motion is satisfied without a special case.
- **Worst first.** Ordered by points at stake, descending. Cards blocked by a
  missing prerequisite sort last.
- **Content is centred**, matching the stats band above it.
- Dots show position; hollow dots mark cards not yet unlocked.

### Prerequisite state

An insight without enough data shows its name, "Not enough data yet", and the
specific action that unlocks it ("Finish one full-length mock"). This is muted
text, never board, so it does not compete with the single primary action.

This turns the two mock-dependent insights into a nudge toward sitting a mock,
which is the behaviour the app wants anyway. A new user sees "How you answer"
immediately and three signposts.

### Free and Pro

Free users **swipe the full deck**. Each card shows the insight's name and both
comparison labels ("practising" against "under time") with rules where the
figures go. Knowing what is being compared is what creates the want. Four
moments of curiosity beat one blank panel.

This introduces Pro gating to Home for the first time. The teaser treatment is
Spec 11 Amendment D's: faint paper-toned bars, "Unlock with Pro" in board green
in the header slot, no lock icons, no blur, no banners.

### "See full details" goes to Progress

Not to a new page. Spec 11 makes Progress the analytical dashboard, and its
trend and weakness panels currently render "Charts land here in an upcoming
update". The tendency work fills those in; Home surfaces one insight and hands
off. Two analytics destinations would drift apart.

## Section 5: Data dependencies

Ships on data the app already stores:

- **Lessons read** counts `lesson_progress_local` rows against `lessons` for the
  active exam.
- **Up next** is unread lessons in the weakest topics, the same two tables asked
  a different question.
- **Accuracy** and **weakest areas** come from `AssessmentResult.topicMasteries`,
  already wired.
- **All four tendencies** come from signals already written in
  `lib/features/metrics/signals/`.

Blocked until Section 2 ships:

- **Days to exam**, which needs `examDate` to be written by something.

**Deferred, not designed here:**

- **"Today's plan"** and its "2 of 3 done". The only block of the original mock
  that cannot be derived from stored data: a daily plan must decide how much a
  user should do today and track completion, which is mastery scoring, review
  scheduling and daily targets. That remains its own project, tracked as UI-003.
  It does not render at all until then. Nothing is faked in its place.
- **A projected score range.** The most-wanted answer to "am I ready" and the
  one that needs a model mapping practice performance onto exam outcomes.
  Keep it on the roadmap as the eventual headline; it is what would finally
  release the reserved word "readiness".

## Section 6: Amendments this design makes

Each of these contradicts something already approved. Recorded so the change is
deliberate rather than drift.

1. **Bottom nav gains icons.** The approved mock and reference-sweep plan both
   specify text-only labels.
2. **Stats band figures are centred.** The mock and `StatsBand` are left-aligned.
3. **The masthead gains a meta line.** The approved composition was kicker over
   name, with the gear as the only other element.
4. **Home blocks are enclosed.** The identity previously grouped by rules and
   whitespace alone.
5. **Signals P4, X1 and D1 appear on Home.** The metrics spec assigns them to
   "archetype/Wrapped only, no atom file". They appear here in a panel, not as a
   daily atom, so the atom rule is intact, but the surface allocation is new.
6. **Home carries Pro gating.** Previously all gating lived on Progress.

## Section 7: Copy rules

- **No em dashes in UI copy.** They read as machine-written. Use a colon, a
  comma, or a full stop. The metric atom line becomes `Lately: day 6 streak,
  your longest this month.`
- Sentence case throughout. Stat labels lowercase. No emoji, no all-caps.
- Never promise what the data cannot support. "Readiness" stays reserved.

## Verification

Per the redesign spec's standing rule: run on the `pantas_pixel` emulator,
screenshot light and night, check against the colour budget. Specifically:

- The nav bar at 1.50 stroke on a real screen, both modes, and the 400ms rise
  once page transitions are also running.
- The tendency deck at each of its four cards, plus the prerequisite state, plus
  the Free teaser, confirming the panel never changes height.
- The masthead with a name, without a name, with an exam date, and without one.
- Home with no assessment result at all, which must not render an empty shell.

## Related

- `docs/ui-audit.md`, findings UI-009 through UI-012
- `docs/superpowers/specs/2026-07-18-ui-redesign-design.md`, the identity this
  amends
- `docs/superpowers/specs/2026-06-10-user-facing-metrics-design.md`, the signal
  layer
- `docs/superpowers/specs/2026-06-10-spec-11-progress-amendment-design.md`,
  which owns the analytics surface
- `docs/superpowers/plans/2026-07-25-onboarding-polish.md`, which gains the name
  and exam-date steps
- Mockups: `.superpowers/brainstorm/72587-1784988095/content/`, notably
  `home-tendencies-v3.html` (final Home), `quiz-gallery.html` (glyph field),
  `home-separation.html` (grouping options)
