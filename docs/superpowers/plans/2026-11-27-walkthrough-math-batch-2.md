# Walk-through Math batch 2 plan

Date: November 27, 2026, from about 11:00 PM Manila. Lead: walk-through Math lead, batch 2 (E-206).
Policy read: `Aedwon/Pantas` main `1bceef609` (AGENTS.md, WORKFLOW.md, SUBAGENTS.md; velocity row pushed as `18eaf30ed`).
Spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` on main, "Revision, November 27, 2026", points 1 to 5.
Decisions: launch log from "Nov 27, about 3:50 to 4:10 PM Manila" to the end; process-improvement rules and the Nov 26 and 27 entries.
Pilot: `docs/superpowers/plans/2026-11-27-walkthrough-math-pilot.md`; 9 lessons final at `99feedd99`.

Aedwon's words for this lane: "lesson content is good enough" (release order "A": each batch goes live as it passes);
"okay both. moving forward if a lesson needs a visual (for the learners' benefit) can you add them? there are some things
better illustrated than just in words"; "okay with cost, better value for users"; "since the content is settled, why don't
you proceed with the other subjects / i mean lessons".

Branch: `content/lesson-walkthrough-cse-r1` (this worktree), from head `a24dd85d5`. Checks: `tools/walkthrough-checks-r1`
`9cd88773b` (not yet on main; laid on top for every check and export, as in the pilot).

Hard stop tonight: 11:40 PM Manila. Task `scheduled-task:6913067b-ced2-4fdd-a31e-89de5994d83c` (11:35 PM, bound to this
thread). Workers stop, WIP is committed, one report goes to the manager, the turn ends. Resume only on the manager's message
after the 12:05 AM opening. A Claude limit hit at any time stops the night at once (pilot rule, still in force).

## Scope

46 lessons: the 55 CSE Math walk-through drafts on the branch minus the 9 pilot lessons. That includes simple interest (read 2
Blocker open: an older pair note gives a final balance of Php 19,080 where it is Php 15,080 after a payment) and three lessons
the pilot left out on purpose (below).

State of the drafts (survey of the branch, Nov 27): every one of the 45 non-pilot drafts is in the old format: 1 to 5
`:::check` blocks and 0 to 4 `**Check:**` lines each (the pilot lessons have 1 and 0). Simple interest is already slim.
So each batch needs the pilot's slim pass before its checks.

## Batches

Grouped by topic so one brief and one set of patterns serves a batch. Each batch is one Codex unit.

| Batch | Lessons | Count | Notes |
|---|---|---:|---|
| 2a Money and rates | simple-interest, compound-interest, commission-and-sales-tax, markup-on-cost, successive-percentages-and-increases, direct-proportion-and-travel, inverse-proportion-and-remaining-work, partitive-proportion-and-differences, unit-rates-and-direct-proportion, coin-and-digit-problems, motion-chase-problems, motion-meeting-and-separation | 12 | Closest to the pilot's percent and word-problem patterns; simple interest fixed first (its Blocker) |
| 2b Fractions, operations, data | adding-and-multiplying-fractions, fractions-and-mixed-forms, multiplying-and-dividing-decimals, operation-priority-and-left-to-right, grouping-and-fraction-bars, distribution-and-common-factors, commutative-and-associative-properties, additive-and-multiplicative-inverses, averages-and-pie-chart-shares, chart-scales-and-differences, inverse-proportion-and-ratio-parts, percentages-and-ratios-of-groups | 12 | chart-scales was left out of the pilot because its figure was redrawn by text change only; under point 5 it gets a real figure |
| 2c Number theory and number sets | coprime-divisibility-tests, digit-sums-and-six, divisibility-by-seven-and-eleven, last-digit-divisibility, greatest-common-factor, least-common-multiple, prime-factors-and-powers, same-remainder-numbers, real-number-sets, complex-products-and-quotients, imaginary-unit-and-powers | 11 | Three files above 1,000 words whole; the 900 pre-tap cap is checked by `lesson_checks.dart` |
| 2d Sequences and signed numbers | arithmetic-sequence-terms, arithmetic-series-sums, geometric-sequence-terms, finite-geometric-series, infinite-geometric-series, harmonic-sequence-terms, fibonacci-type-sequence-terms, finding-number-patterns, odd-and-even-position-patterns, signed-integer-operations, substituting-negative-numbers | 11 | The signed pair is a split: it brings a retired parent, moved questions and new pool-gap questions, which widens the integrator's job. Last on purpose, so batches 2a to 2c ship as lesson-file copies only |

Order: 2a, 2b, 2c, 2d. A batch starts its Codex read only after the batch before it has finished its reads, so one Codex
run is ever in flight. Slim passes of the next batch may run while Codex reads the current one, inside the 2-worker cap.

## Steps for each batch (the pilot's, unchanged except pictures)

1. **Slim pass and picture list** (2 Sonnet 5.5 writers, Edit only, this worktree; brief adapted from the pilot's step 3).
   Rules applied to every lesson whole: drop every `**Check:**` line; keep one `:::check` after the rule the quiz tests most,
   as a fresh instance (new numbers or context allowed; no reused frame; key not in its stem; answer not printed above);
   one `:::try` as the faded last step; 2 or 3 pairs at their steps with unchanged citations; every lead-in names the unknown;
   every chain ends at its value; broad words scoped; no new narration; at or under 900 words before a tap. The pilot's read 1
   and read 2 patterns are written into the brief as "do not" items (combined moves on one line, lead-ins that do not name the
   unknown, pairs without setup, rules missing a condition, checks testing an unshown step, untaught quiz skills, notation
   such as "= 28%" for a value). An untaught quiz skill is added only as a short rule with one example within 900 words, or
   listed for later (manager ruling). Each writer also fills the picture list for its lessons (step P1 below).
2. **Checks**: `lesson_checks.dart --root` on a scratch root (main's content plus the batch), the giveaway and slim-format
   checks, the parser. Writers fix until green. The lead reads every diff.
3. **Pre-check** (1 Sonnet verifier, answers hidden) and **recompute** (1 Sonnet solver, every number, figures included).
   Gate: 0 Blockers. The lead fixes Majors found here before Codex. **Report to the manager.**
4. **Codex read 1** through `codex-pick`, brief from `codex-math-pilot-r1.brief.md` adapted to the batch, with the figure
   specs in scope (each figure's labels and numbers are read as text against the lesson). **Report.**
5. If read 1 has Blockers: fix by pattern (whole Quick Check or try rewritten for any repeated finding), rerun checks,
   **Codex read 2**, the last. **Report.** A lesson that still has a Blocker after read 2 drops to the next batch, as
   simple interest did. If the batch's Blockers plus Majors do not drop from read 1 to read 2, the batch stops and goes to
   the manager with options (process-improvement entry, Grammar fix 2).
6. Majors fixed once after the last read; the lead checks each fix. No further read for Majors.
7. **Export**: the pilot's step 5 scratch root (main's tools plus the checks branch, the content root, the batch's lesson
   files, `content/walkthrough-trap-evidence.json`, and the batch's figure files). `build_content_export.dart` exit 0 and
   `lesson_checks.dart --root` exit 0. The figure checks below exit 0. **Send the manager the exact file paths, figure files
   included.**

## Pictures (spec revision point 5)

### P0. Pipeline first, on the first case (one Claude worker, before any other figure)

Found so far: lesson pictures are code-drawn figures (`lib/core/ui/figures/`, registry and concept, chart and geometry
kinds; style D with theme colors per the launch log of Oct 25 and Oct 29), placed by markers in the lesson, inventoried by
`tools/audit/list_illustrations.py` into `docs/content/illustrations/worklist.tsv` (generated; hand-added rows fail),
classed in `docs/content/illustrations/strategy.tsv`, and checked by `tools/audit/check_lesson_illustrations.py`
(`inventory`, `review-ready`, `complete` phases; `inventory` asserts the approved row breakdown) with
`test/tools/check_lesson_illustrations_test.dart`, plus `tool/checks/figure_classes.dart`. Removed figures are listed in
`docs/content/illustrations/README.md`.

P0 worker (Sonnet 5.5, read-only first): writes `docs/content/verification/walkthrough-work/figure-pipeline-notes.md`
with the exact steps to add one code figure to a lesson that ships: marker form, which figure kind fits (or whether a new
kind is needed, which would be app code and goes to the manager first), how the strategy row and the approved breakdown in
the inventory check change, how the two-theme preview is built, and which checks must exit 0. It names any step that needs
a release lead, a board or Aedwon. The lead reads it and rules.

Then the first case, Percentage Base and Fraction Division (pilot, already passed):
- a part-and-whole bar where the hidden note sits (line 23 today): the base bar split into part and remainder with rate
  labels, numbers taken from the lesson's own worked numbers at that spot, recomputed (the pilot moved the core worked
  numbers to 25% of 60, so the note's "Base = 200, Part = 60, 30%" may no longer match; the figure follows the lesson);
- a part, rate and base triangle right after the three formulas, each formula readable from it by covering one corner.

If no existing kind can draw them, the lead stops and tells the manager before any app-code work: a new figure kind is a
UI change, needs his visual check (rule 3 boards for UI), and goes to the UX lane.

### P1. Where a picture helps: the list

Rule 10 applies: a picture must explain a relation words carry poorly, never decorate. Starting list from the hidden
"FIGURE WANTED" and "ILLUSTRATION" notes on the branch; the writers confirm or remove each and add any others in step 1.

Pilot lessons (9):

| Lesson | Picture | Source |
|---|---|---|
| percentage-base-and-fraction-division | part-and-whole bar; part, rate and base triangle | his ask, hidden note |
| discounted-prices | price bar split into discount and price paid (Php 800, 25%, Php 200, Php 600) | hidden note |
| mixture-word-problems | three containers: 8 L at 50%, x L at 20%, (8 + x) L at 30%, pure amounts | hidden note |
| percentage-change | 100 to 80 (-20%) and 80 back to 100 (+25%) arrows | hidden note |
| table-values-and-totals | its two tables (already marked ILLUSTRATION; P0 checks whether they are drawn) | marker |
| age-word-problems, work-rate-problems, identities-and-like-terms, decimal-and-percent-conversions | none listed; the writer of batch 2a judges age (then-and-now table) and work-rate (one job split per hour) | lead |

Batch 2 lessons with a hidden note today (one each unless shown): motion-chase, motion-meeting-and-separation,
adding-and-multiplying-fractions, arithmetic-sequence-terms, commission-and-sales-tax, compound-interest,
divisibility-by-seven-and-eleven, infinite-geometric-series, inverse-proportion-and-remaining-work, least-common-multiple,
markup-on-cost, multiplying-and-dividing-decimals, odd-and-even-position-patterns, partitive-proportion-and-differences,
prime-factors-and-powers, real-number-sets, successive-percentages-and-increases, chart-scales-and-differences,
inverse-proportion-and-ratio-parts, substituting-negative-numbers, averages-and-pie-chart-shares (2),
signed-integer-operations (2). The other 24 have none; each writer states "none" or names one, with the reason.

The full list (lesson, spot, what it shows, numbers, kind) is kept in
`docs/content/verification/walkthrough-work/batch-2-figure-list.md` and grows batch by batch.

### P2. Drawing and checks

- Claude workers only (Sonnet 5.5); never Codex or Gemini for figures.
- Every number and label in a figure is recomputed by the batch's recompute worker against the lesson text.
- The figure checks from P0 exit 0 on the export root; the inventory is regenerated, never hand-edited.
- Pilot figures (9 lessons) ride with batch 2a: they go through 2a's recompute and Codex reads as figure-only items, and
  ship with 2a. The pilot lessons' text does not change except where a marker becomes a figure.
- Aedwon sees the figures on staging with the batch (his read is the visual check; agents do not screenshot).

## Stop points (report to the manager, "Math lead:")

- After this plan (path), before any lesson or figure write.
- After P0 (pipeline notes and the first-case ruling).
- After each pre-check, after each Codex read, at a second-read Blocker that drops a lesson, at a batch that does not
  improve between reads.
- For each passing batch: exact file paths, figure files included, with main's export passing.
- 11:40 PM tonight (pause for the opening).

## Caps

At most 2 Claude workers at once; 1 Codex run at a time through `codex-pick`; files changed only with Edit or Write (no
shell file edits); one Flutter run at a time through `flutter-locked.sh`, the release lead's builds first. For each Agent
worker, a registered background wait on its report file or commit (process-improvement, Nov 26 fix).

## Estimate

E-206: 12 h active, 20 h wall (8 Codex reads, the opening pause, quota waits). Pilot basis: 3 h 46 min active for 10 slimmer
drafts. Tonight: plan only, plus P0 if the manager approves before about 11:15 PM; no lesson writes before the pause.
