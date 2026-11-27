# Batch 2b independent recompute (Worker 2)

Target: working tree at commit `f32bbe894` (Math batch 2b: pre-check brief). Read-only. Every display line, step, pair
Right/Wrong line, check, try, Why, Speed Trick and checklist value in the 13 lessons was recomputed from the stem (checks and
tries solved before reading their answers). Every number and label in the 12 batch pictures was recomputed and compared with
the lesson text beside its marker; bar widths, pie angles and axis positions were computed from the SVG coordinates. Counts
per lesson are by hand and approximate (plus or minus 3).

Format: `Severity | file:line | value | your value | note`. Line numbers are file line numbers (front matter included).
Paths are under `content/lessons/mathematics/`.

## Arithmetic and text findings

No arithmetic mismatches. Every printed value equals my recomputation, every Wrong line is wrong the way its note says, and
every check and try has exactly one answer with the stated unit.

Minor | data-interpretation/averages-and-pie-chart-shares.md:91 | rule "subtract the two percentages first, then multiply once by the total" | correct only when the total amount of the pie is given | The sentence does not say "when the total is given" (line 63 does for the main formula). Fix: add "when the total is known".
Minor | data-interpretation/inverse-proportion-and-ratio-parts.md:43 | stem "8 clerks can finish a batch in 15 hours" | 120, 40, 80, 13 1/3 all correct | The stem does not say the clerks work at the same steady rate; line 19 states it for the section, and the check at line 70 states it. Fix: add "at the same steady rate" to the stem.
Minor | algebra/motion-meeting-and-separation.md:85 | check stem "Two runners start 24 km apart and run toward each other at 5 kph and 7 kph" | 2 hours, one answer | Correct, but the stem does not say they start at the same time or run at steady speeds, which the rule at line 45 requires. Fix: add "at the same time, at steady speeds".
Minor | algebra/motion-meeting-and-separation.md:62 | "$180=60t$" | 3 hours, correct | The boats example uses $t$ before saying it is the hours after leaving (example 1 at line 102 does say it). Fix: add "Let $t$ be the hours after leaving."

## Picture findings

All 12 pictures recompute with no wrong value and no wrong relation.

Picture checks by lesson:
- adding-and-multiplying-fractions 01 (bars 3/4 and 9/12): both bars 312 wide; 3 interior lines make 4 parts of 78, 11 lines make 12 parts of 26; both shaded widths 234 = 3x78 = 9x26. Matches lines 105-109. Pass.
- multiplying-and-dividing-decimals 01 (point hops): 0.72 to 720 and 0.015 to 15, 3 hops each, 720 / 15 = 48. Matches lines 71-75. Pass.
- distribution-and-common-factors 01 (rectangle): 4 x 3x = 12x, 4 x 7 = 28, 4(3x + 7) = 12x + 28; declared "Widths not to scale" (160 vs 128) and the marker says so. Matches lines 21-25. Pass.
- averages-and-pie-chart-shares 01 (table): 40,000, 50,000, 60,000, Month 1 to 3, title and row label match lines 97-105; column centers sit mid-cell. Pass. The table is the data source, so it correctly sits before the question.
- averages-and-pie-chart-shares 02 (pie): arc endpoints give 126, 108, 72 and 54 degrees = 35, 30, 20, 15 percent (checked sin/cos from the center), labels sit on the right slices, total 200,000 pesos matches line 121. Pass.
- chart-scales-and-differences 01 (reservoir line): ticks 50, 45, 40, 35 at 50 px each; Monday 50 is 2 ticks above 40, Friday 35 is 1 tick below; 2+1=3 ticks, 3x5=15, 15,000 liters. Matches lines 51-67. Pass.
- chart-scales-and-differences 02 (factory bars): 0 to 500 at 0.46 px per unit, labeled every 100 (46 px), 4 small ticks between (20 units each, 9.2 px); Factory A top at 440, Factory B top at 320. Matches lines 107-116. The picture prints no bar values, so it does not give the reading away. Pass.
- inverse-proportion-and-ratio-parts 01 (clerk-hours bar): drawn to scale, 104 of 312 wide = 40 of 120 and 208 of 312 = 80; labels 8x15=120, 8x5=40, 120-40=80, 80/6 = 13 1/3 match lines 45-51. Pass.
- inverse-proportion-and-ratio-parts 02 (folders bar): 9 equal parts of 34; A 68 wide (2 parts), B 102 (3), C 136 (4); 80, 120, 160 match line 91. Pass.
- percentages-and-ratios-of-groups 01 (combined bar): 124.8 and 187.2 of 312 = 40 and 60 percent = 120 and 180 of 300; 180 / 300 = 0.60 matches lines 29-39. Pass.
- motion-meeting-and-separation 01 (two diagrams): top half 25 kph left, 35 kph right, arrows opposite, "gap grows at 25 + 35 = 60 kph"; bottom half arrows face each other, "speed 1 + speed 2". Numbers match lines 56-64.

Minor | algebra/motion-meeting-and-separation.md:58 | picture shows "25 + 35 = 60 kph" | 60, correct | The marker sits one display line before the line that computes $25+35=60$ (line 60), so the picture shows that sum slightly before the text does. The numbers 25, 35 and 180 are introduced at line 56. Fix: move the marker below the `$$t=\dfrac{180}{60}=3$$` line, or accept.

No bars said to be to scale are off: the clerk-hours bar (40:80 = 104:208), the combined-total bar (40:60 = 124.8:187.2), the folders bar (2:3:4 = 68:102:136) and the fraction bars all compute exactly.

## Citation check (pair Wrong line against `content/walkthrough-trap-evidence.json`)

All 38 cited entries across the 13 lessons exist, each question id is in `content/questions/mathematics/`, and each cited
wrong choice is present in its question. The Wrong line shows the cited choice exactly in 30 cases. In 8 cases the Wrong line
makes the same mistake with the lesson's own numbers:
- fractions-and-mixed-forms divide-upside-down (cited 800/3 %, shown 266.7 %), forget-percent-divide (cited 13.375, shown 12.5)
- multiplying-and-dividing-decimals count-both-decimal-places (cited 28.2 and 3.6, shown 8.4), extra-leading-zero (cited 0.0036, shown 0.0008)
- grouping-and-fraction-bars fraction-bar-not-grouped (cited "A=B", shown 48 / 6 + 2 = 10)
- commutative-and-associative-properties subtraction-order and division-grouping (cited sentence choices, shown as the same claim in the lesson's own words)
- additive-and-multiplicative-inverses zero-has-no-reciprocal (cited "r=0", shown "the inverse of 0 is 0")

Minor | all 8 above | ok | same mistake, own numbers | no change needed.

## Per-lesson counts (values checked, mismatches)

- adding-and-multiplying-fractions: about 45 values checked, 0 mismatches
- fractions-and-mixed-forms: about 55, 0
- multiplying-and-dividing-decimals: about 50, 0
- operation-priority-and-left-to-right: about 55, 0
- grouping-and-fraction-bars: about 65, 0
- distribution-and-common-factors: about 50, 0
- commutative-and-associative-properties: about 50, 0
- additive-and-multiplicative-inverses: about 40, 0
- averages-and-pie-chart-shares: about 60 plus 2 pictures, 0 (1 Minor wording)
- chart-scales-and-differences: about 60 plus 2 pictures, 0
- inverse-proportion-and-ratio-parts: about 60 plus 2 pictures, 0 (1 Minor wording)
- percentages-and-ratios-of-groups: about 50 plus 1 picture, 0
- motion-meeting-and-separation: about 50 plus 1 picture, 0 (2 Minor wording, 1 Minor picture placement)

Mismatches: 0 in numbers, 0 in pictures. Minor notes: 5 text or placement, 8 citation notes.

RECOMPUTE VERDICT: PASS (0 mismatches)
