# Settings, brainstorm brief

Written 3 August 2026 so the round can start cold. Same purpose as
`2026-07-30-progress-tab-brainstorm-brief.md`: it is what stops a fresh session
re-deriving what is already known, and it carries the constraints that make this screen
hard.

---

## Why this round exists

**Six specs written in the last two weeks each hand Settings a row, and none of their
authors saw the screen.** That is the same shape the paywall consolidation had on 2 August,
and it will fail the same way if nobody draws the whole thing.

**The existing design predates the identity by two months.** Spec 8,
`specs/2026-05-22-settings-account-design.md`, was brainstormed 22 May. The Ink & Rule
redesign is 18 July. Its screen-by-screen section specifies a Material 3 large app bar,
chips for the theme control, and iOS-style switches, all of which are either banned now or
were never reconciled.

## What is inbound, and from where

| Row or page | Source spec | Notes |
|---|---|---|
| **Name** | `2026-08-02-onboarding-name-and-date-design.md` §5 | Editable after onboarding. Empty and absent are the same state |
| **Exam date** | same, §4 | Must offer the **same three answers** as onboarding, day / month / none, or the two surfaces disagree. The old Spec 8 row assumes a plain date picker |
| **Settings → Exam page** | `2026-08-02-exam-switching-design.md` | A whole sub-page, not a row. Carries switching and the carry-over rule |
| **Carry over progress** | same | A switch. Governs figures and history, never scheduling. Changeable any time |
| **How sessions are built** | `2026-07-28-quiz-tab-design.md` §5 | Three-way ordering, blocked / tail / mixed, with a **recommended** marker on the default |
| **Remember how the table is sorted** | `2026-07-30-progress-tab-design.md` §6 | Governs persistence, **never visibility**. That distinction was decided 2 August and must survive |
| **Subscription panel** | `2026-08-03-paywall-pricing-and-flow-design.md` | Now **three** SKUs. Any lifetime state is gone |
| **Custom exam track** | `2026-08-02-custom-exam-track-design.md` | Has an entry point here |

**Already in Spec 8 and still wanted:** theme, daily reminder, strict mock mode, help
improve the app, account, backup, about, send feedback, and the hidden debug screen.

**That is roughly seventeen rows across two levels.** The design question is not "where does
each row go", it is **what the top level is for**, because seventeen flat rows is a wall.

## Constraints that bind this round

- **Settings has no tab.** It is reached by the gear in Home's masthead, per the redesign
  spec. It is a pushed route outside the tab shell, so `context.push`.
- **Ink & Rule.** No Material large app bar, no chips, no iOS switches by default, no
  cards, no tinted callouts, no large radii. Grouping is hairline rules and plates.
- **The kit already has the row types.** `InkTableRow`, and Progress plan 1 adds
  `DataRowTile` and `NavigationalRow`. Check `lib/core/ui/components/` before drawing
  anything.
- **Settings governs persistence and defaults, never visibility.** Decided 2 August on the
  Progress table. Controls appear when they can do something; a setting never hides one.
- **Voice.** Grade-5-simple English, no em dashes, sentence case, scores are "points".
- **This spec describes the destination.** Nothing in `lib/features/settings/` constrains
  it. Code observations belong in the plan.

## Open questions to put to Aedwon

1. **What is the top level for?** Seventeen rows flat, or four or five plated groups, or a
   short top level where most rows live one tap down. This is the whole round.
2. **Does the exam date row reuse onboarding's three-answer control**, or is a simpler one
   acceptable here given the student already answered once?
3. **Do the two "how it behaves" rows sit together?** Session ordering and table order are
   both preferences about how a surface arranges itself, and they arrived from different
   specs a week apart.
4. **Does the debug screen survive**, and if so what unhides it.

## What not to reopen

- The trial is Yearly only, and the ladder is Weekly ₱29 / Monthly ₱99 / Yearly ₱999.
- Carry-over governs figures and history, not scheduling.
- The quiz ordering default is the interleaved tail, exposed as three values with a
  recommended badge.
- Retained table order is on by default.

## Related

- `specs/2026-05-22-settings-account-design.md`, the design being replaced
- `specs/2026-07-18-ui-redesign-design.md`, the identity
- `plans/2026-07-25-onboarding-polish.md`, unexecuted, whose Task 6 wires the exam date row
- `docs/superpowers/2026-08-02-work-checkpoint.md`, the backlog
