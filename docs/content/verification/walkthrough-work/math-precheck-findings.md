# Math pre-check findings (session 5, Nov 27, E-198)

Verifier: Claude (independent, read-only). Policy read: `origin/main` `05993f914`. Lessons read at `a2b132670`. Scope: algebra (6), arithmetic-number-sense (42), data-interpretation (7) = 55.

Format: `Severity | file:line | item | how it is given away or why the key is wrong | fix`

Severity convention used here (Math checks are free response, so a student cannot copy a choice):
- Blocker: wrong key, a second defensible answer, an item that cannot be solved from what is shown, or an item whose answer is printed above it.
- Major: a check that clones the story or frame of the worked example or pair directly above with only numbers or nouns swapped (la-precheck-fix-brief rule 3), or a try whose answer is a plain copy of printed values. A check that is only a new computation of the same skill is not flagged.
- Scope note: "Finish the last step" tries whose last visible line is the equation and whose ask is one stated division are the lesson template; they are not flagged unless the printed values already give the answer.

## algebra

Major | algebra/age-word-problems.md:40 | Check 1 (Liza and Marco) | Copies the frame of the worked example directly above (Ben is 4 older than Maya, sum 24) with only the numbers swapped (3 older, sum 21). The student can repeat the demo steps without the rule (la-precheck-fix-brief rule 3). | Change the structure, e.g. give the difference and one later age, or ask for the older person from "sum and ratio".
Major | algebra/age-word-problems.md:100 | Check 3 (Rico and uncle, r=9, uncle 5r) | Same frame as the example just above it (b=6, Ana is 3b), a number swapped and the time shift dropped; the answer is one multiplication and the pair above already says "match the person". | Make the person-and-time choice real: give an equation result and ask for a different person at a different time.
age-word-problems.md: 2 Majors. Keys recomputed OK (m=10, a=12, wrong 18, b=6/Ana 18, Mia 11, c-4 and 52-c, 45).

Major | algebra/coin-and-digit-problems.md:151 | Try, Example 2 last step (t=3, u=6) | The try prints t=3 and u=6 and asks for the number; writing the two digits in order gives 36 without 10t+u. | Ask for the reversed number, or give u and t in the other order.
coin-and-digit-problems.md: 1 Major. Keys recomputed OK (t=12, f=8; y=8; 84; 59/95; 36, 63-36=27; value equation (15-y)+5y=47, y=8).

Major | algebra/motion-meeting-and-separation.md:43 | Check 1 (bus 120 km at 40 kph) | Same frame as the tricycle example and its pair directly above (distance over speed gives hours) with only the numbers swapped; the student repeats the printed division. | Use a different shape, e.g. give time and speed and ask for distance, or give distance and time and ask for speed.
motion-meeting-and-separation.md: 1 Major. Keys recomputed OK (1.5; 3; 3; 2 (24/12); 2.5 with 150+200=350; 3 with 150+120=270). Check 2 (runners meeting) changes the case from the boats example, so not flagged.

Major | algebra/mixture-word-problems.md:36 | Check 1 (pure sugar in 40 L of 15%) | Same frame as the vinegar example directly above (percent of a total) with the numbers swapped (0.15 x 40). | Ask for the percent from a pure amount, or the total from a pure amount.
Blocker | algebra/mixture-word-problems.md:78 | Check 2 (4 L of 50% plus x L of 10% to make 20%): "expression for the pure amount in the final mixture" | Second defensible answer: the pure amount in the final mixture is also 0.50(4)+0.10x (= 2+0.10x), which is not the keyed 0.20(4+x). It also copies the printed pair (0.50(8)+0.20x=0.30(8+x)) with new numbers. | Ask for the whole equation, or ask specifically for "the pure amount from the final concentration".
mixture-word-problems.md: 1 Blocker, 1 Major. Keys recomputed OK (6; x=10 for 20 L; x=16 with 7.2/24=0.30; w=10; 12 x 0.25=3, 30-12=18).

Major | algebra/motion-chase-problems.md:72 | Check (cyclist 15 kph, 10 km head start, chaser 20 kph) | Same frame as the jeepney and van example and as Example 1 below (slow ahead, fast behind, subtract speeds, divide gap), only the head start is given in km instead of hours. | Add a twist the demo does not show, e.g. ask for the distance the chaser rides, or give the head start in minutes.
motion-chase-problems.md: 1 Major. Keys recomputed OK (2; 2.5 hours not asked; van catches in 2 h; 40/20=2 with 180-140=40; 60 x 2=120).

Major | algebra/work-rate-problems.md:90 | Check 2 (two printers together 2 h, X alone 6 h, find Y) | Same frame as the Ana and Bea example and the two pairs directly above (shared time, one solo time, find the other) with only the numbers swapped. | Change the structure, e.g. give one worker's rate in "jobs per hour" and ask for the time of the second.
Major | algebra/work-rate-problems.md:54 | Check 1 (Worker A 6 h, Worker B 6 h) | Same frame as the two-pipes example above, two solo times, add rates, flip; equal times only shorten the arithmetic. | Use two different times, or add a third worker.
work-rate-problems.md: 2 Majors. Keys recomputed OK (1/3 and 3; 3 for Y; 3 h pipes; 4.8 h; 15 h for Pump B; 2 h; ab/(a+b)=2).

## arithmetic-number-sense

adding-and-multiplying-fractions.md: OK. Keys recomputed (5/12; 1/4; 5/4 with 9+8-2=15; 1/2; 7/20; 71/60).

Blocker | arithmetic-number-sense/additive-and-multiplicative-inverses.md:94 | Check 3 ("Can any real number s make 0 x s = 5 true?") | The lead-in prints "0 x r = 1 has no real solution" and the pair prints "0 has no multiplicative inverse". The check swaps 1 for 5 and the answer "no" is the printed conclusion. | Ask for a value that does work, e.g. "Which real number s makes 0 x s = 0 true?" or a yes/no with a different equation shape such as 0 x s + 3 = 3.
additive-and-multiplicative-inverses.md: 1 Blocker. Keys recomputed OK (5/6; -1/5; no; -8/5 then 8/5; D).

arithmetic-sequence-terms.md: OK. Keys recomputed (58; d=5; 12 terms; a15=61; a1=3; 4,10,16,22,28; 39 terms; a25=76; 20 terms).

Major | arithmetic-number-sense/arithmetic-series-sums.md:104 | Check 3 (9 terms, middle term 14) | Same frame as the pair directly above (7 terms, middle term 12, sum 7 x 12) with the numbers swapped; the printed Right line is the method. | Give the first and last term and the count and ask for the middle term or the sum, so the student must see the average.
arithmetic-series-sums.md: 1 Major. Keys recomputed OK (78; 152 by listing 5..33; 126; 175; 190 wrong line; 720 with a8=48; a6=15).

Major | arithmetic-number-sense/commission-and-sales-tax.md:54 | Check 1 (revenue 40,000, costs 28,000, 5% on net profit) | Clone of the store assistant example and its pair directly above (revenue minus costs, then rate), numbers swapped. | Change the base, e.g. give profit as a percent of revenue, or ask for net profit after commission.
Major | arithmetic-number-sense/commission-and-sales-tax.md:98 | Check 2 (taxable price 1,500, 4% tax) | Same wording as the 2,400 and 5% example above ("taxable price of Php ... a ...% sales tax is added"), numbers swapped. | Ask for the tax rate from a total, or use a quantity and a unit price.
commission-and-sales-tax.md: 2 Majors. Keys recomputed OK (2,800; 600; 2,520; 3,180; 1,560; 5,600; 366).

commutative-and-associative-properties.md: OK. Keys recomputed (swap terms; 4 x (7 x 5)=140; 4 and 12; associative then commutative; 1,715).

Major | arithmetic-number-sense/compound-interest.md:52 | Check 1 (Php 2,000 at 5% compounded annually for 2 years) | Same stem as the Php 1,000 at 10% example directly above ("Php ... earns ...% interest compounded annually for 2 years"); the two printed multiplications are repeated with new numbers. | Use 3 years, or ask for the interest earned, or give the final balance and ask for the rate.
compound-interest.md: 1 Major. Keys recomputed OK (2,205; 1.03 and 8; 12 years; 10,824 since 1.02^4=1.0824; 10,800 simple).

Major | arithmetic-number-sense/coprime-divisibility-tests.md:92 | Check 3 (21x4y divisible by 45, y=5, find x) | The worked case directly above (32x1y, step 3, y=5, digit sum 11+x, 18, x=7) is the same item with new digits; the student repeats the printed steps. | Give only "divisible by 45", ask for the possible pairs, or use 36 so the last-two-digit test is needed.
coprime-divisibility-tests.md: 1 Major. Keys recomputed OK (9 and 11 yes, 3 and 6 no; 5 and 9; (3,0) and (7,5); 21645/45=481; x+y=6 with 52,344/72=727; 13 with 74,736/36=2,076).

complex-products-and-quotients.md: OK. Keys recomputed (-5+12i; 25; 22-7i; 1+i; 26+7i; -1/2 + 5/2 i with check 2+3i).

Blocker | arithmetic-number-sense/digit-sums-and-six.md:135 | Example 2 try ("pick the choice whose digit sum is divisible by 3") | The keyed choice B, 24,534, is printed as "Right: 24,534 passes 6 because it is even and 2+4+5+3+4=18" in the pair above (and 24,536 as the wrong one), so the student copies it. The step above also lists all four sums, so the try only picks 18. | Use different numbers in the example (not 2453x), and leave the sums for the try.
digit-sums-and-six.md: 1 Blocker. Keys recomputed OK (yes, 6,813=9 x 757; 3,414; x=7 with 47,781/9=5,309; B; d=0,3,6,9; x=6).

discounted-prices.md: OK. Keys recomputed (0.35; 100; 1,020; 1,440; 1,200; 20,400 with 32%; 28%; 720).

direct-proportion-and-travel.md: OK. Keys recomputed (yes ratio 5; 42 km; 45 min; x=10; 22.5 wrong line; 14 cups; 2 h 24 min with 90+18=108).

divisibility-by-seven-and-eleven.md: OK. Keys recomputed (203=7 x 29; 9,174=11 x 834; 2,541=7 x 363; b=1 with 354,211/11=32,201; 2,728; 1,331).

Blocker | arithmetic-number-sense/decimal-and-percent-conversions.md:131 | Example 2 try ("simplify 35/100 to lowest terms") | The core concept above prints "0.35 = 35/100 = (35 / 5)/(100 / 5) = 7/20", the exact simplification the try asks for, and step 1 of the example prints 0.35. The whole key is printed above. | Use a percent not printed in the lesson (for example 45%), and keep 0.35 out of the concept section.
decimal-and-percent-conversions.md: 1 Blocker. Keys recomputed OK (6/25; 8.5%; 1/8; 0.35 and 7/20; 51/40 and 1/16 in the pairs; 0.025).

distribution-and-common-factors.md: OK. Keys recomputed (10x-15; -6m+18; 3,500; 6x-22y with x=y=1 giving -16; 84,700; 87(0)=0).

finding-number-patterns.md: OK. Keys recomputed (21; 31 with differences 2,4,6,8; 83; 61; 57; 150; 37 for 2,5,10,17,26; 37 for 4,7,14,17,34).

geometric-sequence-terms.md: OK. Keys recomputed (r=3; 108; a6=96; a5=1; x=+/-12; -384 with doubling list to 384).

fibonacci-type-sequence-terms.md: OK. Keys recomputed (19; 29; 11 and 18; 4; 3a+3; 5a-1 with a=3 giving 14).

harmonic-sequence-terms.md: OK. Keys recomputed (4,9,14 with d=5; 1/15; 1/18; 1/17; 6,3,2 gives 3/2).

Blocker | arithmetic-number-sense/inverse-proportion-and-remaining-work.md:94 | Check 2 (camp, 30 hikers, 12 days, 5 leave after 2 days) | The key, 12 days, is also the number printed in the stem ("food for 30 hikers for 12 days"), so a student who copies it is right with no work. The item is also a clone of the 10-workers example and its pair directly above (leave after some days, subtract finished work, divide). | Change the numbers so the answer is not any printed number (for example 30 hikers for 12 days, 6 leave after 3 days: 360-90=270, 270/24=11.25 is unfriendly, so pick numbers that give a whole answer such as 20 hikers for 18 days, 5 leave after 6 days: 360-120=240, 240/15=16).
inverse-proportion-and-remaining-work.md: 1 Blocker. Keys recomputed OK (10 minutes; 12 days (the Blocker above); 10 days; 80/8=10; 26 2/3 with 30 x 26 2/3=800; 12 hours for 5 pumps).

Major | arithmetic-number-sense/operation-priority-and-left-to-right.md:69 | Check 2 (evaluate sqrt(64) + 3^2) | Same shape as the example and the pair directly above (sqrt(49) + 2^3, root plus power), with the numbers swapped; it tests nothing the printed line does not already show. | Add one more operation so the order matters, e.g. 5 x sqrt(64) - 3^2.
operation-priority-and-left-to-right.md: 1 Major. Keys recomputed OK (16; 17; 2; 35; 15; 12; 14; 11 with the wrong 5; 33 with the wrong 51).

Major | arithmetic-number-sense/finite-geometric-series.md:86 | Check 2 (9 terms, first term 7, r=1, sum of the last 4 terms) | Clone of the sentence directly above it (12 terms, first term 18, r=1, sum of the last 5 terms = 5 x 18 = 90) with the numbers swapped. | Ask for the sum of the middle 3 terms, or give the 9th term and r and ask for the sum of the last 4.
finite-geometric-series.md: 1 Major. Keys recomputed OK (75; 28; 80; 605 and 405; 189 with 3+6+12+24+48+96; 40).

fractions-and-mixed-forms.md: OK. Keys recomputed (0.35 and 35%; 0.35; 0.3125 and 31.25%; 1.00; 37.5%; 43.75%).

greatest-common-factor.md: OK. Keys recomputed (12; 20; 14; 36 with 2 and 3 left; 42 with 2, 3, 5 left; 720 and 2,520 wrong lines; 5 items per box).

Blocker | arithmetic-number-sense/identities-and-like-terms.md:46 | Check 1 ("Find the value of x that makes (x+0)(1) = -9 true") | The key, -9, is the number printed in the stem. A student copies it without the identity rule. | Make the answer differ from every printed number, e.g. "(x+0)(1)+5 = -4, find x" or "x + 0 = 3 x 1".
identities-and-like-terms.md: 1 Blocker. Keys recomputed OK (-9; 3m^2+3m+4; 73; 5x^2+5x-5 with x=2 giving 25; 3a^2-3a-5; 11xy).

last-digit-divisibility.md: OK. Keys recomputed (yes for 4 and no for 8 for 7,324; 6,482+8=6,490; d=5; 6,348 yes for 4 and no for 8; 48,672/8=84).

Major | arithmetic-number-sense/same-remainder-numbers.md:99 | Check 2 (smallest integer greater than 20 leaving remainder 5 when divided by 6 and 9) | Clone of the worked case directly above (smallest number greater than 10 leaving remainder 2 when divided by 4 and 6: LCM, test k=0 too small, k=1) with the numbers swapped. | Use three divisors and a limit that makes k=2 the first valid one, or ask for the largest such number below a limit.
same-remainder-numbers.md: 1 Major. Keys recomputed OK (24; 23; 36k+2; 14; 61 with 4 x 15+1, 6 x 10+1, 10 x 6+1).

infinite-geometric-series.md: OK. Keys recomputed (diverges, r=-2; 20; 18; 32/3; 27 with partial 26 2/3; diverges, 3/(1-2)=-3 never a sum).

grouping-and-fraction-bars.md: OK. Keys recomputed (18; 5; 8; 7; 100 and 400; 24; 29/2; 15).

Major | arithmetic-number-sense/imaginary-unit-and-powers.md:97 | Check 3 (simplify sqrt(-49) x sqrt(-25)) | Same shape as the worked line directly above it (sqrt(-4) x sqrt(-9) = 2i x 3i = 6i^2 = -6), with the numbers swapped. | Use a quotient or three roots, e.g. sqrt(-81) / sqrt(-9), so the student must decide the order.
imaginary-unit-and-powers.md: 1 Major. Keys recomputed OK (-5 and 7; -1; -35; 1-i with 143=4(35)+3 and 2024=4(506); 6i; i^57=i; 3i).

Major | arithmetic-number-sense/markup-on-cost.md:52 | Check 1 (shirt costs Php 400, 30% markup on cost, listed price) | Same stem and steps as the Php 800 canned goods example directly above (cost, rate on cost, markup, add), numbers swapped. | Give the listed price and the rate and ask for the cost, or ask for the markup rate from cost and listed price.
Major | arithmetic-number-sense/markup-on-cost.md:114 | Check 3 (cost 300, sells 400, percent of selling price) | Key 25% is the same percent printed as the markup rate throughout the lesson (25% on cost in every example), so "25%" is a good guess; the noodles example above is the same frame with different numbers. | Pick numbers whose answer is not 25% or 20%, e.g. cost 350, sells 500 (markup 150, 30% of selling price).
markup-on-cost.md: 2 Majors. Keys recomputed OK (520; 110; 25%; 1,500; 37.5% with cost 1,250; profit 115; 5/25=20%).

odd-and-even-position-patterns.md: OK. Keys recomputed (32 and 3; 12 and 25; 36 with 43-7 then 36-7=29; 20 with 20+5=25 and even terms 4,8,16,32; 11).

simple-interest.md: OK. Keys recomputed (960; 600 with 1.5 years; 1,500 and 11,500; 900; T=5; R=8% with 3,000/37,500; 53,750 and 54,500 in the pair).

least-common-multiple.md: OK. Keys recomputed (36; 8:30 AM; 20; 72; 24; 84; 12:00 PM with 300 minutes; 80; 30 versus 900).

prime-factors-and-powers.md: OK. Keys recomputed (31; 2 x 5^2; 2^3 x 3^2 x 5 with 8 x 9 x 5=360; 180=2^2 x 3^2 x 5; 72=2^3 x 3^2).

partitive-proportion-and-differences.md: OK. Keys recomputed (400; 14; 60,000 with 24,000+36,000+60,000; 55 m with 15 and 40; 77 m; 15:20:24).

Major | arithmetic-number-sense/percentage-base-and-fraction-division.md:56 | Check 1 ("If 20% of a number is 54, what is the number?") | Same stem as the worked line directly above ("when 40% of a number is 72 ... Base = 72 / 0.40"), numbers swapped. | Hide the base: "A shop sold 54 shirts, 20% of its stock" with the question asked as how many shirts were not sold.
Major | arithmetic-number-sense/percentage-base-and-fraction-division.md:96 | Check 2 ("What percent of 3/4 is 9/20?") | Same stem as the worked case directly above ("what percent of 4/5 is 3/5?"), with the fractions swapped. | Reverse the roles, e.g. "What percent of 9/20 is 3/4?", so the base is the second fraction.
percentage-base-and-fraction-division.md: 2 Majors. Keys recomputed OK (270; 60% via 36/60; 180 and 27; 40%; 75%).

multiplying-and-dividing-decimals.md: OK. Keys recomputed (0.135; 40; 0.048 with 64 x 75=4,800; 36 pieces; 0.84; 0.008).

Major | arithmetic-number-sense/real-number-sets.md:80 | Check 2 ("Is sqrt(25) rational or irrational?") | Clone of the printed "sqrt(9) = 3, which is rational" line and its pair directly above, with 25 for 9. | Use a root that needs simplifying first, such as sqrt(50) or sqrt(0.25), or a decimal that repeats.
Major | arithmetic-number-sense/real-number-sets.md:110 | Example 1 try (which statement is false: A to D) | Steps 1 and 2 already remove A and C. B repeats the printed Wrong line ("sqrt(9) is irrational because it has a square root sign") with 49, and D repeats the printed fact that repeating decimals are rational, so the student can pick B by matching. | Make the false statement one the lesson does not print, e.g. "sqrt(2) x sqrt(8) is irrational".
real-number-sets.md: 2 Majors. Keys recomputed OK (-8; rational 5/1; B false since sqrt(49)=7; sqrt(2) x sqrt(8)=4).

substituting-negative-numbers.md: OK. Keys recomputed (-13; -16; -27; 16 with the wrong line -20; 14).

signed-integer-operations.md: OK. Keys recomputed (15; -15; -6; -10; -9; 32; 1 with -15+12+4; 7 and the wrong 3).

successive-percentages-and-increases.md: OK. Keys recomputed (132; 700; 720 and 28%; 605 and 600 wrong; 40% single discount; 450 and 750; 0.80 x 1.12=0.896).

## data-interpretation

inverse-proportion-and-ratio-parts.md: OK. Keys recomputed (3 additional machines; 13 1/3 hours; 80 folders; 4 hours; 48,000 (84,000/7=12,000); 4 hours; 27,000).

Blocker | data-interpretation/chart-scales-and-differences.md:115 | Example 1 try (Factory A minus Factory B, bar chart) | The drawn chart does not match the key. In the SVG (`content/illustrations/mathematics/data-interpretation/chart-scales-and-differences/01-bar-chart-titled-factory-output.svg`) the axis runs 0 at y=292 to 500 at y=62 (0.46 px per unit). Factory A's bar top is at y=89.6, which reads 440 (2 small ticks above 400), not the 460 the marker, step 2 and the key use. Factory B's bar top at y=144.8 reads 320, as stated. A student reading the picture gets 440 - 320 = 120, not 140. | Redraw Factory A to 460 (bar top y=80.4, height 211.6), or change the text and key to 440 and 120.
Major | data-interpretation/chart-scales-and-differences.md:90 | Check 2 (Office A 2 ticks above 6, Office B 1 tick below 6, hundreds) | Clone of the reservoir example and the pair directly above (2 ticks above a line, 1 tick below it, add the distances, tick step times units), with the numbers swapped (40 to 6, step 5 to 0.5, thousands to hundreds). | Use a different layout, e.g. both points above the line, or ask for the percent change.
chart-scales-and-differences.md: 1 Blocker, 1 Major. Keys recomputed OK (10 and 180; 150 applications; 15,000 liters; 240 visitors; Factory B 320; 7 steps x 20 = 140 matches the text but not the drawing).

averages-and-pie-chart-shares.md: OK. Keys recomputed (8 million; 54,000; 50,000; 70,000; 10; 120,000). Both illustrations checked against the text: the table shows 40,000, 50,000, 60,000; the pie wedge angles measure 126, 108, 72 and 54 degrees (35, 30, 20, 15 percent) with the labels on the right wedges and "Total budget: 200,000 pesos" printed.

Blocker | data-interpretation/percentage-change.md:100 | Check 2 ("Weekly sales go from 0 units to 15 units. Can you compute an ordinary percentage increase?") | The example directly above is the same case (0 volunteers to 12) and its pair prints "Right: Undefined, because the starting count is 0". The answer is the printed conclusion with new numbers. | Test the rule in a new form, e.g. "Sales went from 5 to 0. What is the percentage change?" (-100%) next to a 0-start case with a different stem, or give three starting values and ask which has no percentage change.
percentage-change.md: 1 Blocker. Keys recomputed OK (25%; 15%; undefined; 28% with totals 50 and 64; 30%; -15%).

table-values-and-totals.md: OK. Keys recomputed (8,000,000 pesos; 360 metric tons with 1,350 and 990; 27,000; 56,000; 38,000; 550). Both table illustrations match the text (Administration 12, 15, 18, 11; Operations 20, 24, 27, 23; Training 8, 10, 9, 12; unit "in thousands of pesos").

percentages-and-ratios-of-groups.md: OK. Keys recomputed (40%; 3:5 with 25 girls; 25%; 3:2; 60%; 2:1; 2:3).

Major | data-interpretation/unit-rates-and-direct-proportion.md:62 | Check 1 (180 bottles in 15 minutes, bottles per hour) | Clone of the scanner example and the "missing hour conversion" pair directly above (N items in M minutes, per-minute rate, times 60), with the numbers swapped. | Give the per-hour rate and ask for the number in 40 minutes, or start from a per-second rate.
unit-rates-and-direct-proportion.md: 1 Major. Keys recomputed OK (720; 108; 40 boxes per hour; 300; 675; 420; 6.30 per envelope).

## Summary

PRECHECK VERDICT: FAIL (8 Blockers, 25 Majors)

Per lesson (55 lessons):
- algebra: age-word-problems 2 Majors; coin-and-digit-problems 1 Major; motion-meeting-and-separation 1 Major; mixture-word-problems 1 Blocker, 1 Major; motion-chase-problems 1 Major; work-rate-problems 2 Majors.
- arithmetic-number-sense (42): additive-and-multiplicative-inverses 1 Blocker; arithmetic-series-sums 1 Major; commission-and-sales-tax 2 Majors; compound-interest 1 Major; coprime-divisibility-tests 1 Major; digit-sums-and-six 1 Blocker; decimal-and-percent-conversions 1 Blocker; inverse-proportion-and-remaining-work 1 Blocker; operation-priority-and-left-to-right 1 Major; finite-geometric-series 1 Major; identities-and-like-terms 1 Blocker; same-remainder-numbers 1 Major; imaginary-unit-and-powers 1 Major; markup-on-cost 2 Majors; percentage-base-and-fraction-division 2 Majors; real-number-sets 2 Majors. The other 26 are OK: adding-and-multiplying-fractions, arithmetic-sequence-terms, commutative-and-associative-properties, complex-products-and-quotients, discounted-prices, direct-proportion-and-travel, divisibility-by-seven-and-eleven, distribution-and-common-factors, finding-number-patterns, geometric-sequence-terms, fibonacci-type-sequence-terms, harmonic-sequence-terms, fractions-and-mixed-forms, greatest-common-factor, last-digit-divisibility, infinite-geometric-series, grouping-and-fraction-bars, odd-and-even-position-patterns, simple-interest, least-common-multiple, prime-factors-and-powers, partitive-proportion-and-differences, multiplying-and-dividing-decimals, substituting-negative-numbers, signed-integer-operations, successive-percentages-and-increases.
- data-interpretation (7): chart-scales-and-differences 1 Blocker, 1 Major; percentage-change 1 Blocker; unit-rates-and-direct-proportion 1 Major; inverse-proportion-and-ratio-parts, averages-and-pie-chart-shares, table-values-and-totals, percentages-and-ratios-of-groups OK.

Blockers needing the lead first: wrong figure in chart-scales-and-differences (drawing shows 440, text and key say 460); printed answers in digit-sums-and-six, decimal-and-percent-conversions, additive-and-multiplicative-inverses and percentage-change; the key equal to a stem number in inverse-proportion-and-remaining-work and identities-and-like-terms; a second defensible key in mixture-word-problems (Check 2).

Not verified: the `<!-- FIGURE WANTED -->` comments (not shown to students; no item in these 55 lessons needs one to be solved). Among the 55 lessons, the only `<!-- ILLUSTRATION -->` markers are the five checked (factory bar chart, monthly revenue table, training pie, two quarterly expense tables). Three other lessons in these folders carry markers outside my 55 (`counting-squares-by-size`, `growing-square-borders`, `tables-and-charts`) and were not read.
Policy commit read: `origin/main` `05993f914` (AGENTS.md, WORKFLOW.md, SUBAGENTS.md read in full).

