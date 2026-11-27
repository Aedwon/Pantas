# Math batch 2a, Codex full read 1 of at most 2 (Codex GPT 6.2 Sol high, read-only)

Follow `codex-math-pilot-r1.brief.md` in this folder in full (startup, hard rules, the format, the audit standard 1 to 5,
severities, finding format), with these changes:

- Target: worktree `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, branch
  `content/lesson-walkthrough-cse-r1`, the commit named in the run prompt. Write findings to `batch-2a-r1.md` in your
  working directory, appending after each lesson. End with `BATCH VERDICT: PASS` (0 Blockers) or
  `BATCH VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`.
- Twelve lessons, under `content/lessons/mathematics/`: `arithmetic-number-sense/simple-interest.md`,
  `arithmetic-number-sense/compound-interest.md`, `arithmetic-number-sense/commission-and-sales-tax.md`,
  `arithmetic-number-sense/markup-on-cost.md`, `arithmetic-number-sense/successive-percentages-and-increases.md`,
  `arithmetic-number-sense/direct-proportion-and-travel.md`, `arithmetic-number-sense/inverse-proportion-and-remaining-work.md`,
  `arithmetic-number-sense/partitive-proportion-and-differences.md`, `data-interpretation/unit-rates-and-direct-proportion.md`,
  `algebra/coin-and-digit-problems.md`, `algebra/motion-chase-problems.md`, `algebra/motion-meeting-and-separation.md`.
- Pictures (spec revision point 5): every `<!-- ILLUSTRATION -->` marker is a drawn SVG at
  `content/illustrations/mathematics/<topic>/<lesson>/NN-*.svg` (NN is the marker's order in the lesson). Read each SVG's
  text and shapes as visible lesson content at the marker's spot. Audit each picture: every number and label correct; each
  equal to, or one stated step from, the text beside the marker; bars said to be to scale are to scale; the picture shows a
  relation the text needs and does not decorate; it does not show or make copyable the key of a check or try (Blocker).
- Pilot pictures, pictures only: these pilot lessons passed two Codex reads and their text is not in scope, except the
  lines right beside each picture and one added sentence under the Percentage Base triangle ("Cover the one you want: the
  other two show whether to multiply or divide."). Audit their pictures as above:
  `arithmetic-number-sense/percentage-base-and-fraction-division.md` (2), `arithmetic-number-sense/discounted-prices.md`,
  `algebra/mixture-word-problems.md`, `data-interpretation/percentage-change.md`, `algebra/age-word-problems.md`,
  `algebra/work-rate-problems.md`, `arithmetic-number-sense/decimal-and-percent-conversions.md`.
- Rulings carried from the pilot (manager-accepted): a pair may show the cited wrong choice's mistake with other numbers; do
  not flag a pair for that, and do not ask for a note to the student about the quiz. Do flag a pair whose Wrong line shows a
  different mistake. A skill a linked quiz question asks but the lesson's key points do not cover is a Minor marked "for
  later". A short rule added for such a skill is audited like any other line.
- Simple interest: its pilot read 2 Blocker (a pair note said to add the interest to the original principal for "the final
  balance", false after a payment) is fixed; check that every sentence about a total or balance is true for both the
  no-payment and the payment case.
- Lead's checks at the target (do not rerun): the app's walk-through parser passes all 12; `lesson_checks.dart` from
  `tools/walkthrough-checks-r1` `9cd88773b` reports nothing for them; every lesson at or under 900 words before a tap;
  `check_lesson_svgs.py --validate-only` 0 failures. A blind pre-check (0 Blockers; its 4 Majors fixed) and an independent
  recompute (0 mismatches) ran before this read: `batch-2a-precheck-findings.md` and `batch-2a-recompute-findings.md` in
  `docs/content/verification/walkthrough-work/`.
