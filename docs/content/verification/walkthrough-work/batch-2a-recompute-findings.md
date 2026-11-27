# Batch 2a independent recompute (Worker 2)

Target: working tree at commit `ddc80213e` (Math batch 2a: 14 pictures drawn ...). Read-only. Every display line, step,
pair Right/Wrong line, check, try, Why, Speed Trick and checklist value in the 12 lessons was recomputed from the stem. Every
number and label in the 11 batch pictures and the 3 pilot picture lessons (6 pilot pictures) was recomputed and compared with
the lesson text beside its marker. Bar widths compared where the bars are to scale. Values checked per lesson are counted by
hand and are approximate (plus or minus 2).

Format: `Severity | file:line | value | your value | note`. Line numbers are file line numbers (front matter included).

## Arithmetic and text findings

None. Every recomputed value equals the printed value, every Wrong line is wrong the way its note says, and every check and
try has exactly one answer with the stated unit.

## Picture findings

Minor | content/lessons/mathematics/arithmetic-number-sense/percentage-base-and-fraction-division.md:23 | picture 01 shows "140 (70%)" | 200-60=140, 70% is correct | The text beside the marker (lines 19-25) has 200, 60, 30%, 100% but not 140 or 70%. Correct but not in the adjacent text. Fix: add "the other $140$ ($70\%$)" to line 25, or accept as a derived label.
Minor | content/lessons/mathematics/arithmetic-number-sense/markup-on-cost.md:25 | picture 01 shows "125% of cost" | 1,000/800=125%, correct | 800, 200, 1,000 and 25% are in the example below the marker, but 125% appears only in the Why at line 47-49, after the example and the pair. Fix: none needed if the lead accepts nearby text.
Minor | content/lessons/mathematics/arithmetic-number-sense/compound-interest.md:33 | picture 01 simple-interest bar "= Php 1,200" and "100 (Year 2)" | 1,000+100+100=1,200, correct | The adjacent text (line 31) has 100 and 110 but 1,200 appears only in the pair at line 47. Fix: none needed if the lead accepts nearby text.

No picture has a wrong value, a wrong relation, or a label that contradicts the text beside it.

## Citation check (pair Wrong line against `walkthrough-trap-evidence.json`)

All 38 cited questions exist, and each cited wrong choice is a real, incorrect choice in its question. The Wrong line shows
the cited wrong choice exactly in 30 cases. In 8 cases the Wrong line makes the same mistake with the lesson's own numbers,
so the printed number differs from the cited choice.

Minor | simple-interest.md:61 and 91 | ok | matches 3,750 and 54,500 | exact
Minor | successive-percentages-and-increases.md:22 | Wrong 700 (20%+10%=30%) | cited 16800/23 and 2.5% | same mistake (adding percents), different number
Minor | successive-percentages-and-increases.md:34 | Wrong 600 | cited 977.50 | same mistake (second percent on the original), lesson numbers
Minor | direct-proportion-and-travel.md:54 | Wrong 22.5 liters | cited 18 liters | same mistake (reversed ratio), lesson numbers
Minor | inverse-proportion-and-remaining-work.md:76 | Wrong 15 days | cited 24 and 27 days | same mistake (total work over new crew), lesson numbers
Minor | partitive-proportion-and-differences.md:36 | Wrong 23 liters | cited 19 passengers and 33 meters | same mistake (add ratio number to amount), lesson numbers
Minor | partitive-proportion-and-differences.md:72 | Wrong 49 m | cited 49 meters | exact
Minor | coin-and-digit-problems.md:140 | checklist id `place-value-in-two-digit-numbers` has no pair block | n/a | the checklist anchors to a pair id that does not exist; the other 11 lessons have a pair for every checklist id

(The first row is an exact match listed for completeness; the 7 rows after it that say "same mistake" or "no pair" are the
items for a ruling.)

## Pictures recomputed

| Picture | Values checked | Result |
|---|---|---|
| simple-interest 01 | 9 (4,000, 1,080, 2,920, 18,000, 15,080, bar split 86.4/320 = 27% = 1,080/4,000, shaded 51.9/320 = 16.2% = 2,920/18,000) | OK, to scale |
| compound-interest 01 | 12 (1,000, 100, 100, 1,200, 110, 1,100, 1,210; Year 2 block 99 vs 90 = 110:100; Php 1,000 block drawn short with break marks) | OK |
| commission-and-sales-tax 01 | 8 (110,000; 40,000; 40,000; 30,000; 3, 5, 8%; widths 116.4, 116.4, 87.2 = 40:40:30 of 320) | OK, to scale |
| markup-on-cost 01 | 7 (800, 200, 1,000, 100%, 25%, 125%; widths 256:64 = 4:1 = 800:200) | OK, to scale |
| markup-on-cost 02 | 8 (20, 5, 25, 25%, 20%; widths 256:64; brackets span 20-276 and 20-340) | OK, to scale |
| successive-percentages 01 | 8 (200, 240, 440, 100%, 120%, 220%; 145.5 per 100%, 174.5 per 120%, 320 per 220%) | OK, to scale |
| inverse-proportion 01 | 8 (120, 40, 80, 10 x 12, 10 x 4, 8 x 10; done 106 and left 214 of 320 vs 106.7 and 213.3) | OK, to scale within 0.7 px; remaining is twice done |
| partitive 01 | 8 (800, 4 boxes of 200, 600, 200; shaded 240 of 320) | OK, to scale |
| partitive 02 | 12 (3 and 5 boxes of 9, 54 px per box, 2 extra boxes = 18, 8 x 9 = 72) | OK, to scale |
| motion-chase 01 | 6 (0 km, 60 kph, 40 km, 40 kph, head start 40, 60-40=20) | OK |
| motion-meeting 01 | 5 (25, 35, 60 kph; lower half has no numbers, as the lead said) | OK |
| pilot: percentage-base 01 | 6 (200, 60, 140, 30%, 70%; split 96/320 = 30%) | OK, to scale; one Minor above |
| pilot: percentage-base 02 | triangle labels Part / Rate x Base | OK, matches the three covering rules |
| pilot: discounted-prices 01 | 6 (800, 25%, 200, 75%, 600; split 80/320 = 25%) | OK, to scale |
| pilot: mixture 01 | 7 (x, 20-x, 20 L, 30%, 10%, 20%, 0.30x, 0.10(20-x), 0.20(20)=4) | OK, matches lines 62-66 |
| pilot: percentage-change 01 | 4 (100, 80, 100, -20 = -20% of 100, +20 = +25% of 80) | OK, matches the Why |
| pilot: age 01 | 7 (a, 4a, +6, gap 3a, a = 12; Ana 28 px, mother 112 px, +6 = 14 px = a/2 = 6 of 12, gap 84 px both times) | OK, to scale |
| pilot: work-rate 01 | 7 (12 parts of 26 px, A 78 px = 3, B 26 px = 1, 3/12+1/12=4/12=1/3, 3 hours) | OK, to scale |
| pilot: decimal 01 | 7 (0.0625 digits 0, 6, 2, 5; four places; 625/10,000) | OK |

## Per lesson

simple-interest.md: about 34 values checked, 0 mismatches
compound-interest.md: about 24 values checked, 0 mismatches (1 picture Minor)
commission-and-sales-tax.md: about 32 values checked, 0 mismatches
markup-on-cost.md: about 36 values checked, 0 mismatches (1 picture Minor)
successive-percentages-and-increases.md: about 34 values checked, 0 mismatches
direct-proportion-and-travel.md: about 36 values checked, 0 mismatches
inverse-proportion-and-remaining-work.md: about 34 values checked, 0 mismatches
partitive-proportion-and-differences.md: about 38 values checked, 0 mismatches
unit-rates-and-direct-proportion.md: about 28 values checked, 0 mismatches
coin-and-digit-problems.md: about 30 values checked, 0 mismatches (1 checklist-anchor Minor)
motion-chase-problems.md: about 26 values checked, 0 mismatches
motion-meeting-and-separation.md: about 30 values checked, 0 mismatches
Pilot picture lessons (7): 0 mismatches; percentage-base-and-fraction-division has 1 picture Minor

Totals: 0 Blockers, 0 Majors, 3 picture Minors, 7 citation or anchor Minors for the lead's ruling. No arithmetic, unit,
rounding, sign or key error found.

RECOMPUTE VERDICT: PASS (0 value mismatches); 3 picture-adjacency Minors and 7 citation or anchor Minors listed above
