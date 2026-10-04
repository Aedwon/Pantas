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
