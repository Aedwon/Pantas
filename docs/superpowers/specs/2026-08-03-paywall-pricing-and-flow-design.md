# The paywall: pricing, and the flow that sells it

**Date:** 3 August 2026
**Status:** Approved by Aedwon, validated against live mockups in
`.superpowers/brainstorm/33932-1785675929/content/`
**Decision log:** `docs/superpowers/decisions/2026-08-02-paywall-consolidation-log.md`
**Companion spec:** `2026-08-02-pro-entitlement-consolidation-design.md` says **what Pro
is**. This spec says **how it is priced and sold**. Neither restates the other.
**Supersedes:** `2026-07-18-weekly-sku-pricing-amendment-design.md` on pricing and
recommendation, and Spec 7's single-screen paywall composition.

---

## Section 1: The ladder, changed

| SKU ID | Type | Price | Effective /mo | Trial |
|---|---|---|---|---|
| `pro_weekly` | Subscription, P1W | **₱29 / week** | ≈₱126 | None |
| `pro_monthly` | Subscription | **₱99 / month** | ₱99 | None |
| `pro_yearly` | Subscription | **₱999 / year** | ≈₱83 | **7 days** |

**`pro_lifetime` is removed.** Aedwon's reasoning, and it is sound: the roadmap is long,
so a lifetime buyer pays once for years of work still to come. **Nothing has to be
migrated**, because no SKUs exist in Play Console or RevenueCat yet.

**Yearly rises from ₱499 to ₱999.** The trial stays on Yearly and nowhere else; at ₱29,
Weekly remains its own low-risk trial.

### What the rise does to the ladder, stated because it is not obvious

**The per-month ladder still descends**, ₱126 → ₱99 → ₱83, so "each step up buys a better
rate" survives. But **the Yearly saving falls from 58% to 16%.** Yearly is now a
convenience option, not a bargain, and no copy anywhere may imply otherwise.

**The crossover moves from 5 months to 10.1 months.** ₱999 ÷ ₱99 = 10.09. Monthly is
cheaper than Yearly for anything under ten months.

## Section 2: The recommendation, corrected

**The old buckets are now dishonest at the new price** and must move with it. Under the
18 July buckets, a student with an exam six months out was recommended Yearly at ₱999 when
Monthly costs them ₱594. That is a ₱405 overcharge recommended by a surface this project
calls a coach, and the same spec already refuses to recommend Weekly past three weeks on
exactly that ground.

| Time to exam | Recommended | Badge |
|---|---|---|
| ≤ 21 days | **Weekly** | "Best for your exam date", or "Best for 12 Oct" where the day is known |
| 22 days to 10 months | **Monthly** | as above |
| Over 10 months | **Yearly** | as above |
| **No date, or a past date** | **Monthly** | "Best for most" |

**The no-date default moves from Yearly to Monthly.** Most students prep for three to six
months, and at a 10-month crossover Yearly is no longer the honest guess for an unknown.

**21 days is unchanged and still correct**: three weekly renewals cost ₱87 against
Monthly's ₱99; four cost ₱116.

## Section 3: The flow, not the screen

**Three screens, in order, then Google Play.**

| | Screen | Job |
|---|---|---|
| 1 | **What Pro adds** | Make the want. Shown to everyone |
| 2 | **Plans** | Make the choice. Shown to everyone |
| 3 | **How your free trial works** | Remove the risk. **Only when Yearly is chosen** |

**Multi-page rather than one screen**, per the gradual-disclosure argument in Aedwon's
notes and because the single screen it replaces asked for money before saying what for.

**Entry is contextual only.** Spec 7's D2 stands: the paywall is reached by tapping a
gated surface, never pushed unsolicited.

---

## Section 4: Screen 1, what Pro adds

**Headline, verbatim:**

> **You'll understand yourself better with Pro.**
> Every figure below is measured from your own answers.

The second line is the differentiator a reviewer book can never claim, and it grounds the
headline in method rather than in adjectives.

### The specimen

**One plated section, the name of a real gated panel**, then the same panel twice: as the
student sees it now, and as Pro sees it.

```
Under pressure                    (plate, serif 16/700, 1.6px ink rule)

FREE                              (10/700 caps, inkMuted)
practising  vs.  under time
▬▬▬▬▬▬▬▬
▬▬▬▬▬

PRO                               (10/700 caps, ink)
practising 68%  vs.  under time 54%
14   You score 14 lower under time than practising.
     That is the biggest gap in your work.
```

**This is the argument, and it is made in the app's own vocabulary.** Every gated surface
already shows a labelled blank; this screen fills one in. No new persuasion device is
invented, and the payoff is a curiosity the app has been building for weeks.

**`FREE` and `PRO` are the only tier words on the screen.** Not "what you see now" and
"what Pro sees". Free is `inkMuted`, Pro is `ink`, which is exactly how the level control
marks its active label.

**The figure is the largest thing on the screen at serif 30/700**, larger than the
headline. That is deliberate: figures outrank headings everywhere in this app, and Aedwon
chose it so the proof catches the eye first. Progress renders the same component at 34, so
this is a reduced specimen.

### The list

```
Pro also adds                     (plate, serif 16/700, 1.6px ink rule)

+  Explanation to your wrong answers
+  Reasons you keep missing
+  Your mastery down to the lesson
+  Unlimited mock exams
```

- **The marker is a serif plus**, not a Material icon, because the plate says "adds". The
  marker restates the verb rather than decorating the line.
- **The first word of each item is `ink` at 700 and the rest is `inkMuted` at 400.** Two
  devices doing two jobs: the plus gives the indent, the bold noun gives the scan.
- **No hairlines between items.** The four hang under the plate as one block. The plate is
  the only ruled thing, which is what a plate is for.

**"Your mastery down to the lesson" is Aedwon's wording and was queried once.** The
Progress tab prints **Score** and accuracy and never uses "mastery", which is a construct
laid over a measurement. He kept his wording. Recorded so nobody reopens it without
knowing it was raised.

**Footer:** board `See plans`, then `From ₱29 a week. Cancel any time.`

### The fallback, still open

A student with no mock and few attempts cannot fill the Pro block convincingly. **This
state is not designed.** It needs either a weaker specimen chosen from whatever data does
exist, or an authored sample. Do not ship screen 1 without answering it.

---

## Section 5: Screen 2, the plans

**A student is not choosing a price, they are choosing a term.** The app knows their exam
date, so it does the arithmetic rather than making them do it.

### Three states, by exam-date precision

| Precision | Headline | Right column head |
|---|---|---|
| `day` | `Your exam is in 71 days.` | `Until 12 October` |
| `month` | `Your exam is in October 2026.` | `Through October` |
| none | `Choose how long you need it.` | `Price` |

The month headline is the exact copy Home's masthead uses, so the two surfaces agree.

**At month precision, compute against the last day of the stated month.** One date, used
for both the printed figures and the recommendation bucket, and the column head discloses
it. A student needs cover *through* their exam and the day is unknown, so the month is the
only choice that guarantees it.

**Accepted cost:** the last day adds up to 30 days of horizon, which can tip a student at
9.2 months from Monthly into Yearly. It is disclosed on screen and it errs toward cover
rather than toward a cheaper recommendation, which is the safer direction to be wrong in.

### The rows, at day precision

```
Plan                                    Until 12 October

○  Weekly                                          ₱319
   ₱29 a week. Renews every week.             11 renewals

●  Monthly                                         ₱297
   ₱99 a month. Renews monthly.                  3 months
   Cheapest for your date

○  Yearly                                          ₱999
   ₱999 a year. First 7 days free.   294 days past your exam
```

**Why printing this is allowed.** It multiplies a published price by a date the student
asserted. Both terms are facts, so it is not a measurement combined with an assumption. It
is the same class of statement as Your pace's "at three lessons a week you finish nine days
after the exam", and the recommendation logic already performs this arithmetic internally
to choose a bucket.

**Yearly's line says it runs past the exam, and that is the point.** It looks like it
damages the most expensive SKU and it is exactly what makes the other two figures
believable.

**With no date, the right column carries effective-monthly figures instead**, ≈₱126 and
≈₱83, and one line of fine print offers the date: "Tell us your exam date and we will show
what each plan costs you." That is the only nudge on the screen and it offers something
rather than asking for something.

### Composition rules

- **Stable order, Weekly → Monthly → Yearly.** Never reordered by recommendation, so the
  screen cannot feel arranged around the student.
- **Selection is a 12px ring**, filled when chosen, with a 1.6px `ink` bottom rule on the
  chosen row. **Never a tinted fill and never a rounded box.**
- **The term is spelled out in plain words on every row.** Renewal is the thing people get
  wrong about subscriptions.
- **"First 7 days free" is part of Yearly's term line**, in the same weight as every other
  renewal fact. It is a fact, not a sticker.
- **The column head is smaller than the rows**, 10/700 caps against serif 16/700. A column
  label is not a section header, which is how Progress's table already works.
- **CTA states the price**: `Get Pro. ₱99 a month.` When Yearly is chosen it reads
  `Start my free trial` and goes to screen 3.
- **Fine print:** `Cancel any time. Paid through Google Play.`

---

## Section 6: Screen 3, the trial timeline

**Moved here from `2026-08-02-pro-entitlement-consolidation-design.md` Section 4**, which
now points at this section. Shown **only when Yearly is chosen**, because it is the only
SKU with a trial.

```
How your free trial works
Full access to everything in Pantas. The first 7 days are free, then ₱999 a year.

  ○  Today    Everything unlocks. Every explanation, every level of your
              progress, and mock exams with no waiting.

  ○  Day 5    We remind you here in the app that the trial is ending.

  ○  Day 7    Your first charge of ₱999 begins on 10 August 2026.
              Cancel any time before then and you pay nothing.

              [ Start my free trial ]
              No commitment. Cancel any time.
```

**It earns its extra tap.** Spec 7's D10 already commits to three channels so the charge
is never a surprise: an in-app banner from day 5, a local push 24h before, and Play's
automatic email. **All three fire after the commitment.** This is the fourth and the only
one that fires before it.

**Drawing rules.** A vertical 1px `rule` with three unfilled hairline marks, not a card
stack and not a stepper. Day labels serif 14/700, bodies sans 11.5 `inkMuted`. **The date
is computed and printed, never "in 7 days"**, because a named date is what makes the
disclosure checkable. The price appears twice, in the lede and on Day 7, deliberately. One
board button. No em dashes, no emoji, no icons in the marks.

---

## Section 7: The type scale, for all three screens

Every size is one this app already sets. Nothing here is new.

| Rank | Size | Where it already lives |
|---|---|---|
| Headline | serif **24/700** | Progress's "Your profile" name |
| Figure | serif **30/700** | `StatsBand` numerals. Rust for a loss |
| Section header | serif **16/700**, plated with a 1.6px `ink` rule | Progress Section 8, "a header always outranks its own rows" |
| Tier tag / column head | **10/700** uppercase | The Performance table head |
| Rows and list items | serif **14/700** | Progress's navigational rows |
| Body | sans **13/400** | |
| Caption and fine print | sans **11.5/400** `inkMuted` | |

**One board green per screen**, the button. The recommendation badge is the only other
permitted use and it earns it by being a recommendation.

---

## Section 8: What Aedwon's paywall notes could not be applied, and why

Recorded so a later reader does not think they were overlooked.

- **Social proof.** Pantas is pre-launch. There are no reviews, no ratings and no user
  count, and printing any would be a fabricated figure. **Not a no, a "later, when true".**
- **Selling the outcome.** The reference example sells years of life saved. Pantas's
  equivalent is a score or a pass, and this project banned score projection when it
  reserved "readiness". **The outcome sold is understanding, not results.**
- **Strategic friction**, such as demanding card details upfront to filter out
  non-serious users. It filters out exactly the students the ₱29 weekly SKU was created
  to reach, who budget on prepaid load and GCash. Play already requires a payment method
  for a trial.
- **Price anchoring to an everyday cost**, "about one milk tea a month". Rejected on tone:
  it lands as a rebuke on a student who genuinely cannot spare it, which is the same
  reader Weekly exists for. **The review-center anchor stays open** and would be the
  strongest line on the page, but it needs a real published figure. Without one it cannot
  ship.

---

## Section 9: Faults in the built paywall, found 2 August

`lib/features/paywall/` is largely built against Spec 7. These are wrong against this spec
and must be fixed by whoever plans it.

1. **"Try Pro" is the app bar title.** It promises a trial to everyone when only Yearly
   has one.
2. **There is no "what you get" content at all**, only one muted line. Spec 7's "See all
   of Pro" affordance was never built.
3. **The selected card is a tinted, rounded, bordered box**: `boardTint` fill, `board`
   border, `radiusButton`. Tinted callouts and large radii are banned by name.
4. **Board green appears four times** on one screen: the badge, the "7 days free" tag, the
   selected card and the button.
5. **₱126 and ₱42 are hardcoded** in `paywall_package_card.dart` while the price beside
   them comes from `package.priceString`. A price change in Play makes the line lie.
   **₱42 is now wrong regardless**, since Yearly is ₱999.
6. **The badge logic is inverted.** `hasExamDate: recommendedSku != PaywallSku.yearly` in
   `paywall_page.dart:84`. A student with a date whose bucket is Yearly reads "Best value
   for most" instead of "Best for your exam date".
7. **`ctaCopyFor` uses a hyphen as a dash**, "Get Pro - ₱29/week". Neither a hyphen nor an
   em dash belongs. Use a full stop.
8. **Chrome is Material**: `Icons.close`, a plain `AppBar` title, a `TextButton` for
   Restore.
9. **`PaywallSku.lifetime`, `EntitlementPlan.lifetime` and `isLifetime` must be removed**,
   along with the subscription panel's lifetime state and the "never auto-recommended"
   clause.

---

## Section 10: Amendments to other specs

1. **`2026-07-18-weekly-sku-pricing-amendment-design.md`** is superseded on the SKU
   ladder, the price of Yearly, the recommendation buckets and the paywall composition.
   Its rationale for Weekly's existence and its effective-monthly honesty guardrail stand.
2. **`2026-05-21-paywall-entitlement-design.md` (Spec 7).** The single-screen paywall of
   its §5 is superseded by Section 3. **D2 stands** (contextual only) and **D10 stands**,
   gaining the fourth channel in Section 6. Its four-SKU list drops to three.
3. **`2026-08-02-pro-entitlement-consolidation-design.md` Section 4** moves here and that
   section becomes a pointer.
4. **`plans/2026-05-21-paywall-live-validation.md`** drops `pro_lifetime` from the products
   to create, and the yearly price changes to ₱999.

---

## Verification

- No screen offers, mentions or implies a lifetime purchase.
- A student with an exam six months out is recommended **Monthly**, not Yearly.
- A student with no exam date is recommended **Monthly**, badged "Best for most".
- At month precision no screen prints a day count, and the plans column head names the
  month it computed through.
- The three cost figures on screen 2 always equal price times whole renewal periods to the
  stated date. No figure is rounded in the app's favour.
- Screen 3 appears only when Yearly is chosen, and the date on Day 7 matches the charge
  date Play will use.
- Exactly one board green element per screen, plus the badge.
- `grep -rn "lifetime\|Lifetime" lib` returns nothing outside migrations.
- `grep -rn "₱126\|₱42\|₱499" lib` returns nothing.
