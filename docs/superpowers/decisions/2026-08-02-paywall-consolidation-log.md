# Paywall consolidation, decision log

Chronological. Later entries append; they never edit earlier ones. Source specs:
`specs/2026-05-21-paywall-entitlement-design.md` (Spec 7) and its 18 July weekly-SKU
amendment, plus the four tab specs that each grew their own Free and Pro rule.

---

## 2 August 2026: why this round exists

Named in the 2 August work checkpoint as "the Free and Pro rule is currently decided in
four places and they already disagree". By the time this round opened it was **five**:
Spec 7, the Quiz spec's Section 7, the Progress spec's Section 7, the Home spec's Section
4, and the mock UI spec's Section 5. On 2 August I added a **sixth** exception myself,
Home's three free topic rows, while redesigning the Practice panel.

The drift is not hypothetical. The mock UI spec had to **formally reverse Spec 5's D11**
rather than quietly ignore it, because two documents disagreed about whether a Free user
sees the per-question review.

I recommended this ahead of the study plan on the grounds that it is one short round and
the only outstanding item that gets worse while we work on other things.

## 2 August 2026: Aedwon's notes from UX channels, and what survived contact

He opened the round with a screenshot of a free-trial disclosure pattern: a vertical
timeline reading Today, Day 5, Day 7, under the heading "How your free trial works", with
"Start my free trial now" and "No commitment, cancel anytime". His annotation:
**"transparency bias. disclosure/reminder of when their free trial will end. causes higher
trust"**. His own caveat, verbatim:

> though i think this is just one screen since we'll also have to show the options right

**What I told him.** The pattern is already half-decided here. Spec 7's **D10** says the
trial-end charge must never be a surprise and names three channels: an in-app banner from
day 5, a local push 24h before the charge, and Play's automatic email. His timeline is the
**fourth and earliest** channel, at the moment of commitment rather than after it. Same
principle, better placement.

**The constraint he had not seen, and it is the one that shaped the answer: the trial is
Yearly only.** The 18 July amendment puts a 7-day trial on `pro_yearly` and nothing else,
with the reasoning that "at ₱29, Weekly is its own low-risk trial". So three of the four
SKUs have no Day 5 and no Day 7, and a timeline cannot be a universal step.

**What does not transfer:** the drawing. Purple, gradient, pills, elevated cards and the
rounded chip are all banned by name. What does transfer is that a vertical rule with marks
and dates beside it is a printed device, and it sits more comfortably in this identity
than in the reference.

### The options put to him, on where the timeline lives

| Option | Cost |
|---|---|
| **A. A second step, shown only when Yearly is selected** | One extra tap on the highest-value SKU, and two purchase flows to build and test |
| B. Inline on the one screen, under the Yearly card when selected | The screen already carries eight things, and this one makes it jump on selection |
| C. Every SKU gets a timeline, non-trial ones reading "Today: charged ₱29" | Honest and even, but it turns a three-line card into a screen for SKUs that need no explaining |

**Chosen: A**, as recommended. He also confirmed the trial **stays Yearly only**, asked
without being prompted to reopen it.

**Verbatim:**

> A, yes trial stays yearly only, and draw that table first

## 2 August 2026: drawing the table found three gates, not one

The consolidation was framed as "write the list down". Drawing it found something else:
**there are three gate mechanisms in this app and two of them contradict each other.**

| Mechanism | Where it is used | Example |
|---|---|---|
| Interpretation | Quiz, Home, most of Progress | Note B, mistake causes, tendency figures |
| Granularity | Progress Section 7 | Free fixed at Subject; Topic and Lesson are the Pro grant |
| Volume | Mock | One every 14 days against unlimited |

**The collision.** The Quiz spec's rule is "Free records. Pro interprets." **A topic's
accuracy is a record.** Progress sells it as granularity. Home gives three topic
accuracies away free. The exception I wrote on 2 August was not really an exception, it
was the seam between two rules written six weeks apart.

**The resolution: the granularity gate was misnamed rather than wrong.** What Progress
sells is not depth, it is the **instrument**: the whole table, sortable, at every level.
Home's three worst topics are the answer; Progress's table is the tool for asking your own
questions. Under that framing all five documents agree and no exception is needed.

**The alternative was to keep depth sold as depth**, which would have cost Home its three
free rows and therefore its diagnosis, on the first screen, for a free user with nothing
else to act on.

**Chosen: the instrument framing.** Aedwon, verbatim, in the same message as the
Performance request below:

> go with the instrument framing.

### The three gates as settled

1. **Pro interprets.** Free sees what happened. Pro sees what it means.
2. **Pro gets the instrument.** Free gets the answer; Pro gets the surface that lets you
   ask your own questions.
3. **Pro lifts the volume cap**, which exists only on the mock.

Over all three: **nothing the student produced themselves is ever paywalled.**

## 2 August 2026: PaywallTeaserPanel, asked and answered

He asked what it is supposed to do. Recorded because "retired" appears in the Progress
spec with no explanation of what is being retired.

It is 33 lines: a `SectionHeader` whose trailing slot reads "Unlock with Pro", then three
`FaintBars` at widths 0.92, 0.70 and 0.83. **Its only caller is `progress_page.dart:82`**,
so it is Progress-only and Progress plan 1 can delete it with no app-wide question. My
earlier "it may have callers elsewhere, confirm before deleting" was answered by grep, not
by a decision.

**Its treatment is right and survives. Its shape is wrong.** It owns both the heading and
the body, so it can only redact a whole panel. The new design does that in exactly one
place, "Why you miss questions". Everywhere else the redaction is per-figure inside live
content with real headings and real labels around it, which a component that owns the
heading cannot express.
