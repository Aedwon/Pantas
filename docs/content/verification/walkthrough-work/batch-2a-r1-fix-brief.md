# Brief: Math batch 2a fixes after Codex read 1 (E-206)

Read `docs/content/verification/walkthrough-work/batch-2a-slim-brief.md` in full first, and the briefs it names. All of its
rules, hard limits and checks still apply. This brief adds the fix round. Lead's policy commit `be4ec2f41`.

Findings: `docs/content/verification/walkthrough-work/codex-math-2a-r1.md` (FAIL, 3 Blockers, 19 Majors, 17 Minors). Fix
every Blocker and Major row for your lessons by pattern across the whole lesson, not only the line named. Then re-read each
lesson top to bottom once as a student, and check that no new problem of the same kind remains. Minors: leave them unless a
Major fix touches the same line. "For later" Minors: no change. Line numbers are at `a20eeb961`.

Not yours: the question-file Blocker (`ratio-and-proportion.yaml` 0020) goes to the release lead. Do not edit question files
or `content/walkthrough-trap-evidence.json`.

## Patterns and the lead's rulings

1. Multiplier versus amount (Blocker). Never set a multiplier equal to an amount. Write
   $(1+1.20)\times\text{base}=2.20\times\text{base}$, not "$1+1.20=2.20\times$ base". Check every chain in your lessons
   for the same slip.
2. Missing conditions (Majors). Add the condition in a few words wherever a rule, stem or checklist line depends on it:
   both movers leave the same point at steady speeds, and distance is measured from that point (chase rule, chase Quick
   Check (the Blocker), the distance shortcut); summed speeds only while both objects move in opposite directions along the
   same path, and a later start begins from the gap at that moment (meeting); every worker at the same steady rate
   (worker-day recipe and its checklist line); simple annual interest with no earlier payments (simple-interest pair
   setups), and the interest stays the same each year only while the principal and rate stay the same (its Why); the rate
   stays the same and no money goes in or out (compound formula); the item sells at the listed price (markup profit prompt,
   step 2 and checklist); a positive rate when "both go up" (unit rates); "when the total count is given" (coin rule and
   checklist); "to find the overall percent change when the starting price is unknown, let it be 100" (successive).
3. "Never the sum" (inverse proportion): say "Check the product. Equal sums alone do not show inverse proportion."
4. A Quick Check must not repeat the Why or example right above it with only one number changed (successive). Ask for a
   different unknown, for example the single overall percent change after a cut and a tax, with no starting price given.
   Fresh numbers, key not printed above or in its stem, one answer, re-solved by you.
5. One move per display line (coin): expand and collect on separate lines; show the division that isolates $u$.
6. Labels and lead-ins (commission line 31, partitive pair line 83): a short lead-in naming what is found; label each
   computed amount (profit, commission, wages) in the lead-in or a short word before the line, never a word label at the
   start of a display line.
7. Picture placement (Majors). A picture sits after the text that introduces its numbers. Move the marker line, unchanged:
   chase marker to right after the jeepney and van setup and gap (about line 38); meeting marker to right after the boat
   setup (about line 56); inverse-proportion marker to right after the worked 120, 40 and 80 worker-day lines. A marker is
   never inside a `:::` block. Do not edit SVG files; that is Fixer B's picture task below.

## Assignment

Under `content/lessons/mathematics/`. Each fixer edits only its own lessons.

- Fixer A: `arithmetic-number-sense/simple-interest.md`, `arithmetic-number-sense/compound-interest.md`,
  `arithmetic-number-sense/commission-and-sales-tax.md`, `arithmetic-number-sense/markup-on-cost.md`,
  `arithmetic-number-sense/successive-percentages-and-increases.md`,
  `arithmetic-number-sense/inverse-proportion-and-remaining-work.md`, `arithmetic-number-sense/partitive-proportion-and-differences.md`.
  Also sweep `arithmetic-number-sense/direct-proportion-and-travel.md` for patterns 1, 2 and 5 (no row was filed on it).
- Fixer B: `data-interpretation/unit-rates-and-direct-proportion.md`, `algebra/coin-and-digit-problems.md`,
  `algebra/motion-chase-problems.md`, `algebra/motion-meeting-and-separation.md`. Then two picture fixes, following
  `docs/content/verification/walkthrough-work/figure-draw-brief.md` hard rules and checks (Edit or Write only):
  - `content/illustrations/mathematics/algebra/mixture-word-problems/01-two-solutions-into-one.svg`: draw the three
    containers so fill heights are to scale with the volumes the text beside it uses (the two inputs x and 20 - x are not
    known, so draw them as schematic containers without waterlines, or draw the 20 L mixture visibly larger, and say which).
    Keep every label.
  - `content/illustrations/mathematics/arithmetic-number-sense/inverse-proportion-and-remaining-work/01-total-job-done-and-remaining.svg`:
    put the 40:80 split at exactly one third of the bar.

## Report (under 350 words)

Per lesson: each row fixed how (one line) or why not; any new or changed check or try with your re-solve; every new number
with its arithmetic; words before and after; the three checks' output lines; for Fixer B, the SVG validator line.
