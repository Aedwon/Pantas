# Math batch 2a, full read 1

Copied by the lead from the Codex run folder (codex-pick account b, Nov 28 about 1:17 to 1:40 AM Manila). Unchanged below this line.

Target: a20eeb9613dc551479ef51310f9e381559f47251 on content/lesson-walkthrough-cse-r1. Policy and revised walkthrough standard: local origin/main at 6be9a0631c240157dd49c8c137eef69b07175be4. Read target blobs by commit. Recomputed lesson and picture values and checked linked quiz items. Automated lead checks were taken from the brief.

## Simple Interest

Major | content/lessons/mathematics/arithmetic-number-sense/simple-interest.md:55 | The Why question states equal growth each year without naming the condition. Its placement directly after the payment example makes the scope easy to misread. At the same rate, next year's interest on Php 15,080 would be Php 904.80, down from Php 1,080. | Anchor the Why to the Php 10,000 loan and say the interest stays the same each year while the principal and rate stay the same. In the rule at line 22, say the principal is fixed for the period being calculated.

Major | content/lessons/mathematics/arithmetic-number-sense/simple-interest.md:58 | Two repayment-pair stems leave the no-payment condition implicit and omit the annual rate period. The section now teaches partial payments, and the answer depends on both assumptions. | Say “simple annual interest” and “with no earlier payments” in the pair setups at lines 58 and 88.

Recomputed: Php 1,500 interest and Php 11,500 due, Php 1,080 interest plus Php 2,920 applied to principal leaving Php 15,080, Php 53,750 due in both repayment pairs, and Php 900 versus Php 10,800 in the month-unit pair. Check Php 29,785. Examples 5 years and 4%. The repayment note and checklist now correctly state the no-payment condition. SVG 01 matches the example, with 86.4/320 for the interest share of the payment and 51.9/320 for the principal reduction share. It gives neither practice key.

Pair evidence (q-arithmetic-number-sense-business-math-): interest-instead-of-total 0008 Php 3,750.00, months-as-years 0003 Php 10,800.00, months-as-decimal-years 0008 Php 54,500.00. All three match.

## Compound Interest

Major | content/lessons/mathematics/arithmetic-number-sense/compound-interest.md:35 | The formula's final-balance claim leaves its cash-flow and rate assumptions unstated. The linked balance item explicitly holds deposits and withdrawals at zero. | Introduce the formula with “Use this when the rate stays the same and no money goes in or out.”

Minor | content/lessons/mathematics/arithmetic-number-sense/compound-interest.md:61 | “Growth factor” appears before it is named as the multiplier. | Say “the number the balance is multiplied by each period” at first use.

Recomputed: Php 1,100, then Php 1,210, versus Php 1,200 with simple interest. Quarterly rate 2%, factor 1.02, four periods. Check Php 5,304.50. Rule of 72 gives 9 and 8 years, with the reversed quotient 1/8 year. Example uses 1.02^4 = 1.08243216, so the supplied rounded factor gives Php 10,824. The check calculates a balance where the preceding work only found the rate, factor and period count. The SVG compares equal first-year gains and 90:99 second-year widths for 100:110, with a break in each principal block. It gives neither practice key.

Pair evidence (q-arithmetic-number-sense-business-math-): simple-instead-of-compound 0016 1200, wrong-quarterly-period-rate 0018 1.04, rule-of-72-direction 0020 1/8 year. All three match.

## Commission and Sales Tax

Major | content/lessons/mathematics/arithmetic-number-sense/commission-and-sales-tax.md:31 | The four-operation worked example has a dense lead-in, and the two different Php 400 amounts switch roles without labels in the chain. | Keep the task lead-in short and label the computed amounts “profit,” “commission,” and “wages” on their respective lines.

Recomputed: Php 5,100 standard commission, Php 10,000 net profit, Php 400 commission, Php 2,400 wages, Php 2,800 combined, and Php 3,800 with the wrong base. Check Php 900. The two tax examples total Php 2,520 and Php 3,180. Tiered example commission is Php 1,200 + Php 2,000 + Php 2,400 = Php 5,600. The last example's taxable price is Php 3,900, tax Php 234 and bill Php 4,134. Try Php 366. SVG 01 divides 320 px into approximately 116.4, 116.4, and 87.2 px for sales of Php 40,000, Php 40,000 and Php 30,000. The rates and labels agree with the stem, and the SVG gives neither practice key.

Pair evidence (q-arithmetic-number-sense-business-math-): wrong-commission-base 0005 Php 3,800.00, subtract-sales-tax 0021 Php 2,820, stop-before-adding-tax 0021 Php 3,000. All three match.

## Markup on Cost

Major | content/lessons/mathematics/arithmetic-number-sense/markup-on-cost.md:71 | The profit prompt gives the markup and expenses but does not say the item sells at the listed price. Step 2 silently equates the two prices, although line 19 allows a discount. The first checklist line at 172 uses the same shortcut for any selling price. | Say the item sold for its listed price in the prompt and step 2. In the first checklist line, use “asked for the listed price.”

Minor | content/lessons/mathematics/arithmetic-number-sense/markup-on-cost.md:99 | For later: business-math 0013 asks students to work backward from a markup rate on selling price. The lesson only works backward from a rate on cost. | Show that a markup of 20% of the selling price leaves cost at 80% of that price.

Minor | content/lessons/mathematics/arithmetic-number-sense/markup-on-cost.md:69 | For later: business-math 0010 requires finding a unit price when some of the purchased stock cannot be sold. | Divide the total revenue needed to cover cost and target profit by the quantity that can be sold.

Recomputed: Php 800 + Php 200 = Php 1,000, Php 900 / 1.20 = Php 750, and Check Php 150 (Php 650 / 1.30 = Php 500 cost). Profit example Php 115 with the listed-price assumption. Php 5 is 25% of Php 20 and 20% of Php 25. Examples Php 1,500 and 37.5% (Php 750 / Php 2,000). Both figures have 256:64 px segments, correctly showing 800:200 and 20:5. Neither figure gives a practice key.

Pair evidence (q-arithmetic-number-sense-business-math-): markup-only-not-price 0001 Php 200.00, markup-is-not-profit 0002 Php 160, wrong-percentage-base 0006 25%. All three match.

## Successive Percentages and Increases

Blocker | content/lessons/mathematics/arithmetic-number-sense/successive-percentages-and-increases.md:68 | The displayed equality sets (1 + 1.20) equal to 2.20 times the base. The left side is a multiplier and the right side is the new amount. With the lesson's base of 200, it says 2.20 = 440. | Write $(1+1.20)\times\text{base}=2.20\times\text{base}$.

Major | content/lessons/mathematics/arithmetic-number-sense/successive-percentages-and-increases.md:51 | Picking 100 is presented as a rule for any problem with only percents. It can give the percent change, but it cannot recover an unknown price. | Say “To find the overall percent change when the starting price is unknown, let the starting price be 100.”

Major | content/lessons/mathematics/arithmetic-number-sense/successive-percentages-and-increases.md:58 | The directly preceding Why works a start-at-100, increase-then-decrease example to its final price. The Check gives the same starting value and the same two operations, changing only the increase rate. | Use a different task, such as finding the single percent change after a price cut and a tax, with no starting price given.

Minor | content/lessons/mathematics/arithmetic-number-sense/successive-percentages-and-increases.md:53 | For later: fractions-decimals-percentages 0008 asks for the percent rise that restores an original price. The Why shows unequal changes in amount but does not show how to find the restoring rate from the reduced base. | Show that the restoring rise divides the lost amount by the reduced price.

Minor | content/lessons/mathematics/arithmetic-number-sense/successive-percentages-and-increases.md:39 | For later: fractions-decimals-percentages 0015 asks about total revenue with changes to both price and saleable weight. | State that revenue equals unit price times quantity, so a factor on either part changes total revenue.

Recomputed: Php 720 and a 28% drop after two discounts (additive error gives Php 700), Php 605 after the two increases (wrong base gives Php 600), 96 after the equal up/down demonstration, and Check 88. Of 200 gives 240 and more than 200 gives 440. Examples 40% discount and 450/750 forms. Reverse multiplier 0.896. SVG 01 shows 200, 240 and 440 at approximately 145.5, 174.5 and 320 px, with correct rates and labels. It gives neither practice key.

Pair evidence (q-arithmetic-number-sense-fractions-decimals-percentages-): add-successive-percents 0013 Php 16800/23 and 0014 2.5%, apply-second-to-original 0005 Php 977.50, percent-more-as-of 0019 multipliers 1.20 and 1.20. All match.

## Direct Proportion and Travel

Minor | content/lessons/mathematics/arithmetic-number-sense/direct-proportion-and-travel.md:76 | For later: ratio-and-proportion 0007 asks for actual area from a linear map scale. The map Check covers one length. | State that both side lengths must be scaled before multiplying them to find area.

Minor | content/lessons/mathematics/arithmetic-number-sense/direct-proportion-and-travel.md:89 | For later: ratio-and-proportion 0012 requires reading a unitless map scale in the same length units and converting centimeters to kilometers before using km/h. The lesson's unit conversions cover time only. | Add a short map-to-travel example that converts the scaled distance into kilometers.

Minor | content/lessons/mathematics/arithmetic-number-sense/direct-proportion-and-travel.md:109 | For later: ratio-and-proportion 0013 changes both the number of servings and the size of each serving. The recipe example fixes the per-serving amount. | Show how to scale both the serving count and the amount per serving.

Recomputed: constant ratio 3, nonconstant ratios 4 and 2.5, paint 10 liters versus 22.5 with the reversed ratio, and map Check 4.5 cm. At 50 km/h, 48 minutes is 0.8 hour and gives 40 km. Examples 14 cups and 2 hours 24 minutes. No illustration markers.

Pair evidence (q-arithmetic-number-sense-ratio-and-proportion-): increasing-not-direct 0016 y = x + 3, reverse-ratio-order 0002 18 liters, hours-to-minutes 0012 80 minutes. All three match.

## Inverse Proportion and Remaining Work

Major | content/lessons/mathematics/arithmetic-number-sense/inverse-proportion-and-remaining-work.md:67 | The worker-day recipe divides by a head count without limiting it to workers with the same constant individual rate. Both linked remaining-work questions state that condition. | Start the recipe with “If every worker works at the same steady rate.” Apply the same condition in the checklist.

Major | content/lessons/mathematics/arithmetic-number-sense/inverse-proportion-and-remaining-work.md:50 | “Never the sum” can be read as a claim that equal sums rule out inverse proportion. The inverse pairs (2, 8) and (8, 2) have both equal products and equal sums. | Say “Check the product. Equal sums alone do not show inverse proportion.”

Minor | content/illustrations/mathematics/arithmetic-number-sense/inverse-proportion-and-remaining-work/01-total-job-done-and-remaining.svg:9 | The explicitly to-scale 40:80 split spans 106:214 px, so the remaining section is slightly more than twice as long. | Put the split and divider at x = 126.7 on the 320 px bar that starts at x = 20.

Recomputed: 60 pump-hours, 12 hours versus 8 1/3, products 16 and 24 versus sums of 10, and Check 9 painters. The mid-job SVG labels agree with 120 total, 40 done, 80 left, and 8 workers for 10 more days. The examples give 10 days and 26 2/3 more days. The Check solves for crew size and the Try for time. The picture gives neither key.

Pair evidence (q-arithmetic-number-sense-ratio-and-proportion-): direct-instead-of-inverse 0017 8 1/3 hours, constant-product-not-sum 0018 2 + 8 = 4 + 6, use-total-not-remaining 0019 24 days and 0021 27 days. All match.

## Partitive Proportion and Differences

Major | content/lessons/mathematics/arithmetic-number-sense/partitive-proportion-and-differences.md:83 | The first line of the pair opens a new ratio and unit without saying what the ratio describes or what the student is finding. | Add “Find the full length of a wire split in the ratio 4:7, with each part worth 7 meters.”

Minor | content/lessons/mathematics/arithmetic-number-sense/partitive-proportion-and-differences.md:19 | “Think of the ratio numbers as equal boxes” can make 3 and 1 sound like two equal shares. The intended model is that the numbers count the boxes. | Say “Each ratio number tells how many equal boxes a share gets.”

Minor | content/lessons/mathematics/arithmetic-number-sense/partitive-proportion-and-differences.md:41 | For later: ratio-and-proportion 0006 needs distance-weighted shares for groups of different sizes. | Find each group's total distance before taking its share of the combined distance.

Minor | content/lessons/mathematics/arithmetic-number-sense/partitive-proportion-and-differences.md:89 | For later: ratio-and-proportion 0008, 0011 and 0015 ask students to track amounts by color when adding one color, mixing two batches, or replacing part of a well-mixed batch. The lesson teaches the starting split and final ratio order. | Add a short rule to find the amounts of each color first, then update those amounts before forming the new ratio.

Recomputed: Php 600 and Php 200, 32 liters versus 23 from a raw part, Check Php 240, 72 from the 18-unit difference, 77 m versus 49 m for one share, 9:11 for blue to yellow, examples Php 60,000 and 55 m, and combined ratio 15:20:24. SVG 01 has four equal 80 px boxes. SVG 02 uses equal 54 px boxes, with 162:270 px bar widths and a correctly marked 108 px difference. The figures give neither practice key.

Pair evidence (q-arithmetic-number-sense-ratio-and-proportion-): add-parts-to-amount 0004 19 passengers matches. The 0020 citation labels the same error but its stated calculation misses the cited number (see question-file findings). One-share-not-total 0020 49 meters and reverse-ratio-order 0011 11:9 both match.

## Using Unit Rates and Direct Proportion

Major | content/lessons/mathematics/data-interpretation/unit-rates-and-direct-proportion.md:69 | The definition says quantities in direct proportion move in the same direction. That wording needs the positive rate used in these examples and already stated in the checklist. | Define direct proportion by the constant rate and common multiplier. Say that at a positive rate, increasing one quantity increases the other.

Minor | content/lessons/mathematics/data-interpretation/unit-rates-and-direct-proportion.md:38 | “Why does pesos go on top” has a subject-verb mismatch. | Write “Why do pesos go on top?”

Recomputed: 200 envelopes and Php 6.30 per envelope, with the wrong quotient 200 / 1,260 rounding to 0.16 envelopes per peso. Scanner rate 7 pages/minute and 420 pages/hour. Check 900 / 120 = 7.5 liters/minute, using the stated 60-minute equality and the taught unit-rate division. Pump rate 37.5 liters/minute for 18 minutes gives 675 liters (300 with the inverse factor). Examples 40 boxes/hour and Php 300. No illustration markers.

Pair evidence (q-data-interpretation-rates-ratios-and-percentages-in-context-): wrong-unit-rate-order 0022 Php 0.16, missing-hour-conversion 0021 7 pages, reverse-direct-scale 0024 300 liters. All three match.

## Coin and Digit Problems

Major | content/lessons/mathematics/algebra/coin-and-digit-problems.md:19 | The rule presents a total-count equation as a feature of all coin problems. Linked questions word-problems 0012 and 0018 give only a money total and relations between counts. | Say “When the total count is given, write a count equation and a value equation.” Use the same cue in the checklist.

Major | content/lessons/mathematics/algebra/coin-and-digit-problems.md:127 | The reversed-number example distributes the minus and combines like terms in one jump. The earlier digit example likewise jumps from 3u = 12 to u = 4 without showing division. | Show the expansion and the collected equation on separate lines. Show the division that isolates u at lines 67 and 69.

Minor | content/lessons/mathematics/algebra/coin-and-digit-problems.md:21 | For later: word-problems 0012 and 0018 require writing one coin count in terms of another and using it in the value equation, including with three coin types. | Add a short example of a stated relationship such as f = 2t + 8 going into the value equation.

Recomputed: 8 five-peso and 12 ten-peso coins in Core Concept. Check has 7 five-peso coins and 5 twenty-peso coins, giving Php 35 for the requested denomination. Core digit example produces 84 (reversed 48). Examples 8 five-peso coins and the original number 36, with the reversal 63. The Check asks for a subtotal in pesos after solving the counts. No illustration markers.

Pair evidence (q-algebra-word-problems-): missing-coin-value 0006 5f + 10t = 20, reversed-digits 0019 48. Both match.

## Motion Problems (Chase)

Blocker | content/lessons/mathematics/algebra/motion-chase-problems.md:73 | The Check never says the cyclists leave from the same point. Following on the same road does not fix their starting positions. If the second cyclist starts 8 km farther along, the initial gap is 16 km and they meet 72 km from the first cyclist's start, instead of 96 km. | Say both cyclists leave the same point, in the same direction, at the stated constant speeds. Measure the catch-up distance from that point.

Major | content/lessons/mathematics/algebra/motion-chase-problems.md:28 | The time-head-start rule assumes both vehicles leave the same point and that the lead vehicle travels at a steady speed. The distance shortcut at line 102 also assumes the measurement starts where the chaser started. | State the shared starting point and steady speeds in the rule. Name the chaser's starting point explicitly in the distance shortcut.

Major | content/lessons/mathematics/algebra/motion-chase-problems.md:26 | The picture shows the van, jeepney, speeds, gap and closing-rate arithmetic before any of those values appear in the text. | Move the marker after line 38, once the story and the gap are known. The speed difference is then one subtraction from the setup.

Recomputed: 40 km head start and 20 km/h closing rate give 2 hours of chase and 3 hours from the first departure. Wrong methods give 0.4 or 2/3 hour. Check gives 96 km under the shared-start assumption (24 km gap, 4 km/h closing rate, 6 hours). Try 2.5 hours for 50 km at 20 km/h. Shortcut example 120 km. SVG 01 matches the later worked story, with both arrows pointing right and the faster arrow longer. It gives neither practice key.

Pair evidence (q-algebra-word-problems-): add-speeds-in-chase 0008 0.4 hour, use-only-chaser-speed 0008 2/3 hour, head-start-clock 0008 3 hours. All three match.

## Motion Problems (Meeting and Moving Apart)

Major | content/lessons/mathematics/algebra/motion-meeting-and-separation.md:54 | Using the full gap and one time with the summed speeds assumes both objects are moving throughout that time. If they leave the same spot at different times, one travels alone at first. The checklist also leaves out the opposite-direction condition for adding speeds when a gap grows. | Say to use the sum for the time both objects move in opposite directions along the same path. If one starts later, begin at the gap when the second object starts and use the change in that gap.

Major | content/lessons/mathematics/algebra/motion-meeting-and-separation.md:52 | The upper panel gives 25 kph, 35 kph and their 60 kph sum before the boats or their speeds are introduced at line 56. | Move the paired figure after the boat setup, or use generic speed labels in both panels.

Recomputed: 45 / 30 = 1.5 hours and 30 / 45 rounds to 0.67 in the reversed pair. The boats separate at 60 km/h and take 3 hours (18 with subtraction, 6 with averaging). Check 2 hours. Examples 2.5 hours and 150 km (3 hours at 50 km/h). The picture shows the correct opposing arrow directions and sum in both cases, and gives neither practice key. The average-speed rule at line 29 is relevant to linked word-problems 0017 (24 km in 1.2 hours gives 20 km/h).

Pair evidence (q-algebra-word-problems-): speed-over-distance 0002 0.67 hours, subtract-instead-of-add 0014 18 hours, average-speeds-mistake 0014 6 hours. All three match.

## Pilot pictures: Percentage Base and Fraction Division

SVG 01 shows 60 = 30% of 200 and 140 = 70% of 200, with widths 96 and 224 px out of 320. SVG 02 puts Part above the divider and Rate × Base below. The added sentence points to the visible operations, and the three formulas immediately above show how to read each cover. Neither figure gives the 216-shirt or 87.5% key.

## Pilot pictures: Discounted Prices

SVG 01 splits Php 800 into Php 200 off and Php 600 paid, with widths 80 and 240 px out of 320. The rates and labels match the example at the marker. The image separates money saved from money paid and gives neither the Php 480 nor the Php 20,400 key.

## Pilot pictures: Mixture Word Problems

Major | content/illustrations/mathematics/algebra/mixture-word-problems/01-two-solutions-into-one.svg:12 | Three identical vessels have the same fill height, visually implying three equal volumes. In this example the first two volumes are 10 L each and the resulting volume is 20 L. | Give the 20 L mixture twice the filled height of a 10 L input in identical vessels, or use schematic containers without waterlines.

The concentration shading, plus sign and arrow connect the input solutions to the mixture. The pure-salt labels are correct: 0.30x and 0.10(20 - x) sum to 0.20 × 20 = 4 L. The figure gives neither the 39% nor the 5 L key.

## Pilot pictures: Percentage Change

Minor | content/lessons/mathematics/data-interpretation/percentage-change.md:43 | The 100 to 80 to 100 case matches the adjacent collapsed Why. The visible lines just before it are about a different starting value, with no line introducing the change of example. | Add a short visible setup naming the fall from 100 to 80 and rise back to 100.

SVG 01 labels the left-to-right fall as 20 units or 20% of 100 and the rise as 20 units or 25% of 80, with the correct signs. It shows why the base changes and gives neither the minus 10% nor the minus 15% key.

## Pilot pictures: Age Word Problems

SVG 01 makes the mother's current bar four times Ana's (112 versus 28 px). It adds the same 14 px to each for six years when a = 12. The difference stays 84 px, or 3a. Labels match the adjacent text and the figure gives neither the 70-year sum nor Mia's age of 11.

## Pilot pictures: Work Rate Problems

SVG 01 divides 312 px into 12 equal 26 px cells. The 78 px and 26 px contributions show 3/12 and 1/12. Together they fill 4/12 per hour, so the whole tank takes 3 hours. The labels agree with the adjacent math. The figure gives neither the 1/10 fence per hour and 10 hours key nor the 15-hour key.

## Pilot pictures: Decimal and Percent Conversions

SVG 01 puts 0, 6, 2 and 5 in the tenths through ten-thousandths boxes and highlights the zero. Four places give 625/10,000, which equals 0.0625. The figure gives neither the 153/50 nor the 9/20 key.

## Picture placement follow-up

Major | content/lessons/mathematics/arithmetic-number-sense/inverse-proportion-and-remaining-work.md:73 | The picture appears before the worker example and shows the full chain down to 8 workers for 10 more days. That last result is several stated operations from the adjacent stem. | Place it beside the worked 120, 40 and 80 worker-day split and the calculation for the 8 workers.

Minor | content/lessons/mathematics/arithmetic-number-sense/markup-on-cost.md:25 | The picture uses 125% for the listed price, while the explanation that connects 100%, 25% and 125% only appears in the later collapsed Why. | State beside the bar that 100% of cost plus 25% of cost makes 125% of cost.

## Batch-wide notation

Minor | content/lessons/mathematics/arithmetic-number-sense/simple-interest.md:24 | All 12 lessons use double dollars for standalone equations. The audit brief calls for single dollars, while the project lesson style guide expressly uses double dollars for displays. | Resolve the brief and style-guide difference before changing the fences. Preserve standalone display rendering.

## Question-file findings

Blocker | content/questions/mathematics/arithmetic-number-sense/ratio-and-proportion.yaml:454 | In question q-arithmetic-number-sense-ratio-and-proportion-0020, the rationale for 33 meters says to add both ratio numbers to the 21-meter difference. The stated mistake yields 4 + 7 + 21 = 32, not 33. The correct key of 77 meters is sound. | Change the distractor to 32 meters and update its linked walkthrough citation.

The verdict includes the question-file finding above. The audit stayed pinned to a20eeb961 when the worktree HEAD advanced. Picture findings come from source inspection. App rendering and lead checks were outside this read.

BATCH VERDICT: FAIL (3 Blockers, 19 Majors, 17 Minors)
STAGE-DONE
