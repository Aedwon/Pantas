# Release-first cuts and prerequisite links

Date: 1 October 2026. Continues `2026-09-30-adaptive-roadmap-log.md`.

> "what else can be cut? i think my goal should be to release first and not really fully
> optimize to edge devices. i need to put it out there and start generating revenue.
> optimizations can come at later updates"

> "you decide for me considering what's best for the student and the app (backed by evidence
> if possible)"

## Release cuts (lead decision, delegated by Aedwon)

Options offered with cost and risk; all four chosen:

1. **Low-end device performance is not a release gate.** QLP-5's formal campaign on a 3 to 4 GB
   phone moves to a later update. Before release, a smoke check on the Redmi that Today, Start
   and Next feel responsive. Saves several days and a device. Risk: stutter on budget phones.
2. **Final Release E2E runs once, not three times** (E10). Saves hours. Risk: flakiness slips
   through; low for an internal beta.
3. **Roadmap change log stays on the device** (plan Task 11 deferred). Saves a task and a rules
   and Cloud Function deploy. Risk: a Pro student who reinstalls loses log history; no screen
   shows the log until the UI round.
4. **Accessibility (A05) and notifications/device runtime (A06) become smoke checks** instead
   of full passes. Saves about a day. Risk: TalkBack or reboot edge cases surface later.

Kept, because failure costs money, student data or Play standing: exact signed-artifact
verification (E12, E13), RevenueCat purchase and restore (A03), sync and account (A01), deletion
and privacy (A07), App Check (A02), device smoke (A04).

## Prerequisite links (lead decision, delegated by Aedwon)

Codex's audit proposed 12 links. Approved 4:

- Algebra after Arithmetic & Number Sense
- Trigonometry after Geometry
- Pre-Calculus & Basic Calculus after Algebra
- Language Application after Grammar and Structure

Dropped 8 (Geometry after Algebra; Statistics, Data Interpretation after Arithmetic; Chemistry
after Algebra; Physics after Algebra and Trigonometry; Vocabulary after Grammar; Mechanical
Reasoning after Trigonometry): each rests on one or two worked examples, and prerequisites
chain, so Physics would have forced four mathematics topics ahead of a weak Physics student.

**Evidence and its strength:** cognitive load research supports teaching material that builds
directly on earlier schemas after those schemas exist (Sweller, van Merriënboer and Paas 2019,
Educational Psychology Review, "Cognitive Architecture and Instructional Design: 20 Years
Later"); prior knowledge is among the strongest predictors of later learning (Simonsmeier,
Flaig, Deiglmayr, Schalk and Schneider 2022, Educational Psychologist, meta-analysis). No study
decides these specific topic pairs; the calls apply the spec's approved rule, "only where a
topic cannot be understood without the other", to the lesson evidence in the audit. The dropped
links keep weak topics first, which the spec's ordering already chose.
