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

## 3 August 2026: the pricing changed mid-design, and it broke the recommendation

Raised by Aedwon unprompted while reviewing the paywall drawings. Verbatim:

> i want to remove the lifetime purchase, for reasons that the app has a very long roadmap
> and that they will be paying less than what they're getting in the long term. bad for
> business. also I want to raise the yearly to 999.

**Both taken.** Lifetime costs nothing to remove because no SKUs exist in Play Console or
RevenueCat yet, so there is nobody to migrate.

**What I told him before drawing anything, because it could not wait.** At ₱499 against
₱99 a month, Yearly won after five months, which is why the 18 July buckets read "22 days
to 5 months → Monthly, 5 months and up → Yearly". **At ₱999 the crossover is ₱999 ÷ ₱99 =
10.1 months.** So a student with an exam six months out would have been recommended Yearly
at ₱999 when Monthly costs them ₱594: a ₱405 overcharge recommended by a surface this
project calls a coach. The same spec already refuses to recommend Weekly past three weeks
on exactly that ground, so the buckets had to move with the price.

**Also stated because it is not obvious:** the ladder still descends, ₱126 → ₱99 → ₱83, but
the Yearly saving falls from 58% to 16%. Yearly is now a convenience option rather than a
bargain and no copy may imply otherwise.

**Chosen:** buckets move to a 10-month crossover, and **the no-date default moves from
Yearly to Monthly**, because most students prep three to six months and Yearly is no longer
the honest guess for an unknown. Verbatim:

> yes to monthly default

## 3 August 2026: his paywall notes, and the three that could not be applied

He pasted notes from UX channels covering multi-page flows, timing, strategic friction,
social proof, price anchoring and testing, with:

> i'm not necessarily saying for you to apply them all, just take what you can and apply
> them and show me the options.

**Applied:** the multi-page flow, which he had already asked for; contextual timing, which
D2 already commits to; and the offer timeline, already decided on 2 August.

**Refused, with reasons, rather than quietly skipped:**

- **Social proof.** Pre-launch. No reviews, no ratings, no user count. Printing any is a
  fabricated figure. A "later, when true", not a no.
- **Selling the outcome.** The reference example sells years of life saved. Pantas's
  equivalent is a score or a pass, and this project banned score projection when it
  reserved "readiness". **The outcome we can sell is understanding, not results**, and that
  constrains every headline on the benefits page.
- **Strategic friction**, demanding card details upfront to filter out non-serious users.
  It filters out exactly the students the ₱29 weekly SKU exists to reach, who budget on
  prepaid load and GCash.

**Price anchoring was put to him as genuinely open**, and he asked what it was:

> idk about the anchor what is it

I explained it and **recommended against it**, on tone: "about one milk tea a month" lands
as a rebuke on a student who cannot spare it, and that is the same reader Weekly exists
for. **The review-center anchor stays open** and would be the strongest line on the page,
but it needs a real published figure for what a UPCAT or CSE course costs. Without one it
is invented and cannot ship. He took the recommendation.

## 3 August 2026: five rounds on screen 1, and what he rejected each time

Worth keeping in full, because four of the five rejections were mine to have avoided.

**Round 1, the feature table.** I drew a "what you get" list as data rows with grey
right-hand scope labels, over four plan rows with radio marks. Verbatim:

> isn't there a more elegant way to show the right-hand part. looks very ugly and
> unconvincing

He was right. It was a feature table with radio buttons, which is a form, not an argument,
and it was monotone: everything at the same weight, so nothing led.

**Round 2, three directions.** The specimen, the rate card, and one claim with one sample.
He picked the redaction-filled specimen and rewrote the headline himself:

> go with B. also change the copy "You have been seeing the labels. Pro fills them in." ->
> You'll understand yourself better with Pro.
>
> then please don't add the "what you see now" what pro sees bullshit. just say Free and
> Pro. and also no need for the "and in four more places like really? just list them down.
> be simple and direct, yet inspiring about it

**Round 3, his list copy**, which is now the shipped wording. He also caught that the list
had no indent and no hierarchy.

**Round 4, the plus.** His idea, and it is better than either of mine:

> "Pro also adds" means you can use + for each item on the list
>
> you can also do the emphasis on the first word thingy on option 3

The plate says "adds", so the marker restates the verb instead of decorating the line.
Two devices doing two jobs: the plus gives the indent, the bold noun gives the scan.

**Round 5, the type scale, and this one was a rule I had already been given.** Verbatim:

> okay but the font style and size don't match because the section header is smaller than
> the list items. please view this entire screen as a whole and establish visual hierarchy
> as necessary

**The Progress spec states it outright** in Section 8: "Section headers: serif 16/700, one
step above navigational rows so a header always outranks its own rows." I had the plate at
13 over items at 15.5. Rebuilding the screen on one scale also found that **"Under
pressure" was being printed twice**, once inside each tier block, which nobody had noticed
through four rounds of drawing it.

**The figure size was put to him as a judgement call** and he settled it:

> the figure being the biggest means it catches users attention first so it's a good thing
> for me

## 3 August 2026: screen 2 became arithmetic instead of a price list

> i still want to see the price listings page because last time you rendered it it was so
> ugly and not befitting of an app of this quality

**The idea that fixed it: a student is not choosing a price, they are choosing a term.**
The app knows their exam date, so it prints what each plan costs them until that date
rather than making them work it out. ₱319, ₱297, ₱999.

**Checked against Section 1 of the Progress spec before drawing it.** It multiplies a
published price by a date the student asserted. Both terms are facts, so it is not a
measurement combined with an assumption, and it is the same class of statement as Your
pace's "at three lessons a week you finish nine days after the exam". The recommendation
logic already performs this arithmetic internally to choose a bucket.

**The Yearly row says it runs 294 days past their exam.** That looks like it damages the
most expensive SKU and it is exactly what makes the other two figures believable.

**Approved, and then he found the hole:**

> also consider that some users will have month-year as inputs only so

Correct, and it breaks the headline outright: at month precision `ExamDate.day` is null by
design, so "Your exam is in 71 days" and "Until 12 October" are both unprintable.

| Option for month precision | Cost |
|---|---|
| **The last day of the month** | Up to 30 days of extra horizon, which can tip a student at 9.2 months from Monthly into Yearly |
| The first day | Cheaper, and it can leave a student uncovered if the exam is on the 28th |
| A range, "₱198 to ₱297" | The most honest and the least Grade-5 |

**Chosen: the last day**, one date for both the printed figures and the recommendation
bucket, with the column head disclosing it as "Through October". A student needs cover
*through* their exam and the day is unknown, so the month is the only choice that
guarantees it. It errs toward cover rather than toward a cheaper recommendation, which is
the safer direction to be wrong in.

## 3 August 2026: one thing raised once and kept

**"Your mastery down to the lesson"** is his wording on screen 1's list. I flagged that the
Progress tab prints **Score** and accuracy and never says mastery, because mastery is a
construct laid over a measurement, and that the paywall would promise a word the
destination does not use. He did not change it. **Kept as his product language**, recorded
here so nobody reopens it later without knowing it was raised.

---

## 4 August 2026: the specimen fallback, and Aedwon closing it by changing the question

The round was called to design one open state: `2026-08-03-paywall-pricing-and-flow-design.md`
Section 4 says a student with no mock and few attempts cannot fill screen 1's Pro block, and
that the state is not designed.

### What was put to him, on the visual companion

Four options, each drawn as a phone at the real type scale and real tokens, against a
reference phone showing screen 1 as specced.

| | Option | Cost |
|---|---|---|
| A + C | Ladder to the strongest specimen their data can fill; at true zero, no specimen | Honest in every state. Three or four specimen shapes to build plus a reduced screen. |
| **B** | One authored sample whenever data is thin, plated as a sample | Cheapest, one shape, always makes the full argument. A stranger's numbers, and the second headline line has to change. |
| A + B | Ladder, then a sample only at true zero | Always argues fully, but builds both mechanisms and still needs the headline exception. |
| C | No ladder; drop the specimen whenever it cannot be filled | Simplest and always honest. Most early students would never see the argument at all. |

**I recommended A + C**, on the grounds that the sub-headline "Every figure below is measured
from your own answers" is the differentiator and a sample contradicts it.

### What he chose, and the argument I had missed

**B**, extended past what was asked. Verbatim:

> "B but say it's just a sample. actually do that to all screens so that we're not giving away
> Pro features for free"

**The reasoning is his and it is better than mine.** Screen 1 as specced fills a real blank with
the student's real numbers, which means **the paywall gives away one genuine Pro insight in
order to sell Pro.** I had weighed the sample only against honesty and never against leakage. A
sample does not leak the product.

**It also dissolves the problem the round was convened for.** No ladder, no data thresholds, no
reduced screen, no true-zero case: one shape for every student, always the full argument. The
open state in Section 4 stops existing rather than getting an answer.

### What I got wrong in the drawing, corrected in the same round

1. **I said the headline had to change. It does not.** "You'll understand yourself better with
   Pro." makes no claim about measurement. Only the second line does. Proposed replacement:
   *"This is an example. Pro measures every figure from your own answers."* which keeps the
   differentiator as a promise about the product rather than a claim about the numbers shown.
2. **I marked the sample too weakly.** I drew a small `SAMPLE` tag plus a caption under the
   figure. That is too late to be read: every other figure in Pantas is the student's own, so
   the default reading of a familiar panel is "this is me", and a label below the numbers
   arrives after they have been read. The marking belongs in the plate's trailing slot, where
   real gated sections put "Unlock with Pro".

### Scope, as read back to him and open to correction

"All screens" bites only on screen 1. Screen 2 prints a published price times a date the
student asserted, and screen 3 is the trial timeline. Neither carries a measured figure.

### Still open after this round

- The sample's own numbers have to be authored and they must never read as measured. Marking
  is settled above; the values are not chosen yet.
- Section 4's "fallback, still open" paragraph is now superseded and the spec needs the edit.

### 4 August, continued: the plate he asked to see in detail, and what it turned up

He asked for the revised screen drawn "to the detail" so he could check it. Every value was
traced to a real component before drawing, per the standing rule that both rejected plates in
the Progress work were rejected for inventing something already decided.

**Approved with "lgtm proceed".** Spec amended immediately after.

**Two things the tracing turned up, neither of them the thing the round was about.**

1. **Section 7 claimed a type scale the app does not have.** It read "Every size is one this
   app already sets. Nothing here is new." **Five of seven rows did not hold** against
   `AppTextStyles`: there is no serif 24, no serif 16 section header (it is 15), no serif
   14/700, no sans 13/400 and no 11.5 caption. Only the 30 figure matched. The claim is
   withdrawn in the amendment and replaced with a table stating what exists.
2. **The 1.6px ink plate rule does not exist and its citation was wrong.** `1.6` appears
   nowhere in `lib/core/ui/`, `RuledSection` draws a 1px rule in `rule` rather than `ink`, and
   the "Progress Section 8" the spec cited as its home does not contain it either.

**Resolution taken, and it was my recommendation rather than his instruction.** Add the missing
sizes to `AppTextStyles` rather than move the spec onto whatever sizes happen to exist, on the
grounds that the sizes were chosen against live mockups and the type scale is the identity. He
was shown the choice and said proceed. **It is wider than the paywall and belongs to
`settings-01-the-kit`, which owns `AppTextStyles`.** Cheap to reverse if he wants the other
direction.

**Two details decided in the writing, both flagged rather than buried:**

- **`Sample` is `inkMuted`, not board green.** Board green is budgeted to one element per
  screen and the button has it. `SectionHeader` already renders a non-tappable trailing slot in
  `inkMuted`, so this is the existing treatment, not a new device.
- **The Pro sentence stays in the second person.** "You score 14 lower under time than
  practising" demonstrates the sentence Pro writes *to them*, and a third-person rewrite would
  sell a report about a stranger. It is also the place the sample leans hardest on its marking,
  which is why the marking is structural and sits above the figures.

**Also corrected while in the file:** `2026-08-02-pro-entitlement-consolidation-design.md` still
verified that "Weekly, Monthly or Lifetime" never shows a trial timeline. Lifetime was removed
on 3 August.

**Noted, not fixed:** `practising` is British and the project rule is American spelling. It is
the label the tendency deck ships, so the paywall quotes it rather than diverging from the
surface it illustrates. The label is wrong wherever it lives and that is a separate job.
