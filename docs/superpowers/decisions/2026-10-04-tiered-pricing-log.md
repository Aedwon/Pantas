# Tiered pricing by exam: decision log

**Date:** 4 October 2026
**Decided by:** Aedwon
**Current prices:** `docs/pricing.md`. That file wins over this log if they differ.

## Decision

Pantas drops the single Pro price for every exam. Price follows the selected exam's
tier: Student, Civil Service, Licensure, and PSHS-NCE. Each tier has its own
paywall. The Student tier keeps ₱29 weekly, ₱99 monthly, ₱799 yearly.

## Aedwon's premise

- One ₱99 monthly price for every exam is wrong.
- Adults have more purchasing power than students. A CET student should not pay
  the same as an adult taking the CSE.
- PSHS-NCE parents treat a PSHS scholarship as an investment and will pay more.
  Earlier agent discussions recommended a season pass, not a subscription.
- Government partners asked for PMA, PNPA, and MAAP. PMMA, NAPOLCOM, and AFPSAT
  were added because they overlap.

## Evidence used (fetched 4 October 2026)

- CSE reviewer apps: ₱49 to ₱199 a month; CSC Exam Philippines ₱799 a year.
  Sources: apps.apple.com/ph/app/csc-exam-philippines/id869762507, csebuddy.com,
  cseexamreview.com.
- LET: an AI reviewer at ₱249 to ₱449 a month; LEAP programs ₱6,000 to ₱8,000.
  Sources: leptreviewer.com/blog/best-lept-reviewer-app, info.leapreviewapp.com.
- PNLE review centers: ₱8,000 to ₱40,000 a cycle. Sources:
  supertutor.ph NLE 2026 guide, cevasphilippines.com NLE page.
- PSHS-NCE review centers: about ₱7,900 to ₱12,900 for about five months.
  Sources: iknowacademichub.com, acad1.ph.
- PMA and PNPA entrance exams are free; PMMA ₱500; MAAP ₱400. Applicants are
  senior high graduates, so the academy exams sit in the Student tier.
- NAPOLCOM competitors: one-time ₱129 app; $5.99 a month subscription. Takers are
  working-age adults, so NAPOLCOM and AFPSAT sit in the Civil Service tier.
- Abstract reasoning is a scored part of PSHS-NCE, PMA, and PMMA. MAAP tests IQ
  and aptitude. PNPA coverage was not confirmed from an official source.

## Alternatives rejected

- **Keep one blanket price.** Undercharges adults and parents.
- **Weekly plan for Civil Service.** Adults preparing over months rarely want
  weekly billing.
- **Season pass that unlocks every exam.** A high-priced PSHS pass would otherwise
  unlock unrelated adult content, and a cheap pass would leak upward.
- **Nesting without direction.** Without "higher includes lower", an adult could
  buy the Student plan and switch to CSE.

## Release requirement (added 4 October 2026)

Aedwon made the abstract reasoning procedural generation engine a release
requirement for the academy exams and PSHS-NCE. Those prices do not go live until
it ships. Details: `docs/pricing.md`.

## Open items

Listed in `docs/pricing.md`, "Not yet settled". The exam-switching behavior there
is a direction; it needs a design spec before implementation.

## Prices this supersedes

Every earlier price in repository specs, plans, checkpoints, `docs/TERMS.md`, the
year-1 projection, and the Pantas Master SSOT research tabs, including Yearly
₱499, ₱599, and ₱999, any lifetime product, the ₱499 NCE Season Pass, and the
₱1,999 parent tier.

## Trial moves from Yearly to Monthly (added 4 October 2026)

Aedwon's comment:

> hello i don't know which files these are located but can you ensure future
> agents and models recognize that the final subscription with the 7-day trial
> is the monthly

Every record before this put the 7-day trial on Yearly only (18 July amendment,
confirmed 2 August in `2026-08-02-paywall-consolidation-log.md`). The agent
pointed out that reversal and asked two questions.

- Which Monthly plans get the trial? Options: every tier's Monthly, or Student
  Monthly only. **Chosen: "Every tier's Monthly"** (Student ₱99, Civil Service
  ₱149, Licensure ₱249).
- Does Yearly keep a trial? Options: no, Monthly only; or both. **Chosen: "No,
  Monthly only".**

What changed: `docs/pricing.md` gained a "Free trial" section and lists the Yearly
trial as superseded. `AGENTS.md` states the rule under Pricing.

Not yet changed, needs separate approval: `docs/TERMS.md` (says "yearly only"),
the app's Pro page (shows the trial on ₱799 Yearly), the paywall's trial screen
routing (Yearly only), and the Play Console trial offer on `pantas_pro_yearly`.
The reason for the move was not stated.

## PSHS-NCE pass-only check (added 4 October 2026)

Aedwon asked why PSHS-NCE has only a season pass and whether ₱1,499 is
data-backed. No written reason existed beyond the premise above. The agent first
suggested adding a monthly plan, then reversed after the research below. Aedwon
kept PSHS-NCE pass-only at ₱1,499.

Research fetched 4 October 2026:

- **One attempt per child.** Applicants must be Grade 6 pupils who have not
  previously applied to PSHS. Source: pshs.edu.ph, PSHS-NCE 2026 application page.
  Each family buys for one season of about five months.
- **Review programs:** iKnow Academic Hub ₱9,999 online live, 5 months; ACAD1
  ₱7,900 to ₱12,900 in person; Achievers Review ₱5,800 to ₱14,900 online
  simulated exams (achieversreview.com). Achievers Gold, ₱5,800 for diagnostics
  and mock exams, is the closest comparison.
- **General app:** ReviewNatin PH lists PSHS-NCE among many exams at ₱149 a month
  or ₱1,490 a year (reviewnatinph.com).
- **Print reviewers:** about ₱200 to ₱450 (2021 blog source, dated).
- **Not found:** a PSHS-only app with a published price, a mock-exam-only package,
  or any credible survey of parent spending on entrance-exam prep.

Reasoning: ₱1,499 is about a quarter of the cheapest comparable online program.
A monthly plan would sit next to ReviewNatin's ₱149 and pull the price down. With
one attempt and a fixed season, a pass matches how parents buy. The price remains
a competitor-based starting point, not measured willingness to pay.
