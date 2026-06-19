# What Pro is: the single entitlement table

**Date:** 2 August 2026
**Status:** Approved by Aedwon
**Decision log:** `docs/superpowers/decisions/2026-08-02-paywall-consolidation-log.md`
**Supersedes:** every per-surface Free and Pro table in the specs listed in Section 6.
**Does not change:** the RevenueCat pipeline, entitlement architecture, webhook or
security model. This spec says what Pro *is*. `2026-08-03-paywall-pricing-and-flow-design.md`
says how it is priced and sold.

**Assumes nothing in the tree survives.** Like every spec in this project it describes the
destination, not a diff against what exists. Code observations belong in plans.

---

## Problem

The Free and Pro rule was being decided independently on five surfaces: Spec 7, the Quiz
tab, the Progress tab, Home, and the mock UI. They had already contradicted each other
badly enough to need a formal reversal, when the mock UI spec struck Spec 5's D11 because
two documents disagreed about whether a Free user sees the per-question review.

The drift was still accelerating. On 2 August the Home redesign added a sixth exception,
three free topic-level accuracies, which contradicted Progress's rule that topic level is
the Pro grant.

**This spec is the source of truth. Every other document cites it and none of them
restates it.**

---

## Section 1: Three gates and one constraint

There is not one gate in this app. There are three, and naming them separately is what
stops them contradicting each other.

> **Gate 1. Pro interprets.** Free sees what happened. Pro sees what it means.
>
> **Gate 2. Pro gets the instrument.** Free gets the answer. Pro gets the surface that
> lets you ask your own questions.
>
> **Gate 3. Pro lifts the volume cap.** This exists on the mock exam and nowhere else.
>
> **Over all three: nothing the student produced themselves is ever paywalled.** Their
> record, their totals, their flags, their bookmarks, their notes.

### Why gate 2 is "the instrument" and not "granularity"

The Progress spec sold Topic and Lesson level as depth. That reading collides with gate 1
head on, because **a topic's accuracy is a record**, and gate 1 says records are free. It
is what forced Home's three free topic rows to be written as an exception.

Under the instrument framing there is no collision and no exception. Home's three worst
topics are **the answer**: which topics to work on. Progress's table is **the tool**: every
row, at three grains, sorted and filtered however you ask. Free is told where it stands.
Pro is handed the instrument for interrogating it.

**The alternative was to keep depth sold as depth**, which was considered and rejected: it
takes Home's diagnosis away on the first screen from a free user who has nothing else to
act on.

### What gate 3 does not become

**Volume caps exist on the mock only.** They were considered for flags and Study bookmarks
and rejected, for reasons the Quiz spec sets out and this spec keeps: a storage cap
punishes the most engaged free users at the moment of their enthusiasm, its failure mode
is either blocking them or evicting their oldest flags, and both read as petty. What Pro
buys on flags is what they **mean**, which is gate 1.

---

## Section 2: The table

**This is the source of truth. Cite it; do not copy it.**

| Surface | Free | Pro adds | Gate |
|---|---|---|---|
| **Lessons, the reader, the Study map** | Everything | Nothing | none |
| **Bookmarks and flags** | Unlimited, and practice sessions from them | Patterns across them, custom ordering, notes | 1 |
| **The practice picker, today's session, Your mistakes** | Unlimited, uncapped | Nothing | none |
| **The answer reveal** | The mark, the verdict, note A, the interval | Note B, addressed to the choice you made | 1 |
| **The session debrief** | The score, the figures, every miss, the return promise | The inferred cause per miss, and the tagging | 1 |
| **Either review screen**, practice or mock | Every question, the correct answer, note A | Note B | 1 |
| **Mock exam** | One every 14 days, per student | Unlimited | 3 |
| **Home: Practice panel** | Three weakest topics, with figures | Nothing | none |
| **Home: tendency deck** | All four cards, both comparison labels, figures redacted | The figures | 1 |
| **Progress: Your pace** | Everything | Nothing | none |
| **Progress: Performance** | Subject rows, both figure columns | Topic and Lesson levels, and the subject filter that comes with them | 2 |
| **Progress: Why you miss questions** | Redacted whole | The three counts, the per-topic concentration, the misreads you noted yourself | 1 |
| **Progress: How you work** | Five headings, ten comparison labels, figures redacted | The figures, and "When you work" | 1 |
| **Progress: Your record** | Everything | Nothing | none |

### Three readings of the table worth stating

- **Four surfaces are wholly free**, and two of them are analytical. Free is not a demo.
- **"Why you miss questions" is the only section redacted whole**, and the endowment
  principle is why the narrower rule is fair: Free users never produce mistake tags,
  because the debrief's tagging invitation is itself Pro, so nothing of theirs is withheld.
- **The mock review is free on both tiers except note B**, which formally reversed Spec 5's
  D11. The argument that decided it was checked rather than assumed:
  `AttemptsRepository.recentIncorrects` queries `attempts_local` only, mock attempts live
  in `mock_attempts`, and D4 keeps mocks out of the scheduler on purpose. **Mock misses
  never reach "Your mistakes" and never come back.** Gate the review and a Free user's 38
  wrong answers have nowhere left to go at all.

---

## Section 3: How a gate looks

**One treatment, everywhere, and it is already built.**

- **`FaintBars` where the figures would sit.** 7px paper-toned bars at `ruleFaint`, radius
  2, 5px vertical margins.
- **The heading and both comparison labels always print.** Knowing what is being compared
  is what creates the want. A blank panel converts nobody.
- **"Unlock with Pro" in board green**, in the section header's trailing slot.
- **No lock icons. No blur. No banners. No interstitials. No shimmer.**

**One teaser per screen, maximum.** Placed **after** the free content, never before it,
never twice on one screen.

**A gate is never drawn as a whole redacted panel**, except "Why you miss questions",
which is the only section gated whole. Everywhere else the redaction is per-figure inside
live content, with real headings and real labels around it. **A component that owns both
the heading and the body cannot express that**, which is why the treatment is a rule here
rather than a widget.

**A Pro-only route hit by a Free user goes to the paywall, not to a 404.** Unchanged from
Spec 7.

---

## Section 4: The trial disclosure step

**Moved 3 August to `2026-08-03-paywall-pricing-and-flow-design.md` Section 6**, which
owns the whole three-screen flow. The rule it establishes stays here because it is a
tier rule rather than a layout one:

> **The trial is Yearly only, at 7 days.** Weekly at ₱29 is its own low-risk trial;
> Monthly has none. The disclosure screen is therefore a step shown only when Yearly is
> chosen, never a panel on the plans screen, because two of the four states it would
> need do not exist.

---

## Section 5: Rules for anyone adding a Pro feature later

1. **Name its gate.** If it is not 1, 2 or 3, it does not ship until this spec grows a
   fourth gate with a reason.
2. **Check the constraint.** If the student produced it, it is free. No exceptions.
3. **Add a row here.** Do not write a Free and Pro table in your own spec. Cite this one.
4. **Count the teasers on the screen.** If there is already one, yours does not go there.

---

## Section 6: Amendments to other specs

1. **`2026-05-21-paywall-entitlement-design.md` (Spec 7).** Its feature-level Free and Pro
   claims are superseded by Section 2. Its SKUs, pricing, RevenueCat pipeline, webhook,
   custom claim, `entitlementProvider`, server-side gating and security model all stand
   unchanged. **D2 stands**: the trial is offered contextually, never unsolicited. **D10
   stands** and gains the fourth channel in Section 4.
2. **`2026-05-17-mock-exam-design.md` (Spec 5).** D11 was already struck by the mock UI
   spec. Section 2 is now the statement of record.
3. **`2026-07-28-quiz-tab-design.md` Section 7.** Its table becomes a citation of Section
   2. Its rule "Free records, Pro interprets" survives as gate 1 and its "no cap on Free"
   reasoning survives under gate 3.
4. **`2026-07-30-progress-tab-design.md` Section 7.** Its table becomes a citation. **Its
   "granularity" framing is replaced by gate 2, the instrument**, and the stated exception
   for Home's three rows is **deleted rather than kept**, because under gate 2 no exception
   is needed.
5. **`2026-07-26-home-and-navigation-design.md` Section 4.** Its Free and Pro subsection
   becomes a citation.
6. **`2026-06-10-spec-11-progress-amendment-design.md` Amendment D.** Already superseded
   for Progress; now superseded everywhere.

---

## Verification

- Exactly one Free and Pro table exists in `docs/superpowers/specs/`. Every other mention
  is a citation.
- No screen in the app shows two teasers.
- No surface uses a lock icon, a blur, a banner or an interstitial to mark a gate.
- Selecting Weekly, Monthly or Lifetime never shows a trial timeline.
- Selecting Yearly always shows it, and the date printed on Day 7 matches the charge date
  Play will use.
- A Free user's mock review shows every question and the correct answer.
- Home's Practice panel shows three topic accuracies to a Free user, and Progress's table
  still opens at Subject for the same user.
