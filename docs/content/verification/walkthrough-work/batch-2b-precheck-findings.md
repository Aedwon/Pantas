# Blind pre-check, Math batch 2b (Worker 1)

Target: working tree of the content-lesson-walkthrough worktree at commit `f32bbe894` (Math batch 2b: pre-check brief).
Method: pilot brief steps 1 to 7 on each `:::check` and `:::try`; broad-rule list run per lesson from the main tools
checkout (main `8ed6a0b4f`) and every printed line read; every ILLUSTRATION marker read with its SVG (11 pictures).
Paths below are under `content/lessons/mathematics/`.

My solves of the 13 checks and 13 tries all matched the printed keys, and no item has a second defensible answer.
Checks: 4/15; 45%; 25; 55; 70; -12a+8b-20; order and 108; -9; 14; 300; 14; 25%; 2 hours.
Tries: 1/2 cup; 1.00; 36; 33; 14.5; 84,700; 1,715; 8/5; 70,000; 120; 27,000; 2:5; 150 km.
No picture shows or makes copyable the key of a check or try. No picture contradicts its lesson text. All picture
numbers match the beside text and the drawn proportions are correct (pie angles 126/108/72/54 degrees; ratio bar 9 equal
parts; clerk bar 1/3 and 2/3; facility bar 40/60; factory bars 440 and 320 on a 0.46 px per unit scale, unlabeled).

## Findings

Format: `Severity | file:line | item | problem | fix`

Major | arithmetic-number-sense/fractions-and-mixed-forms.md:62 | rule sentence | "Convert every number into the same form ... Changing everything to decimals is usually quickest." A repeating fraction such as $\dfrac{1}{3}$ gives an inexact decimal, and line 148 says to keep the exact fraction then, so the two lines pull apart. | Add the condition: "usually quickest when every fraction ends cleanly; otherwise change everything to fractions."
Major | data-interpretation/chart-scales-and-differences.md:107 | Example 1 step 1 | "each small tick is 20 units" is stated with no line showing $100\div 5=20$ (the core text shows that division only for a different axis). The picture shows 4 small ticks per gap, so the student must count spaces to see 20. | Add the display $\dfrac{100}{5}=20$ under step 1.
Major | data-interpretation/inverse-proportion-and-ratio-parts.md:43 | clerk stem | "$8$ clerks can finish a batch in $15$ hours ... $2$ clerks leave" never says all clerks work at the same steady rate. Equal workers appears only in the notes at lines 58 and 66. | Add "all at the same steady rate" to the stem.
Major | data-interpretation/inverse-proportion-and-ratio-parts.md:69 | `:::check` | Same frame as the machine example at lines 23 to 33 with numbers swapped: multiply for total work, divide by the new time, subtract the starting count. Every step is printed above. | Change the frame, for example give the new time and ask for the workers left over after some leave, or waive under the same-kind rule.
Major | algebra/motion-meeting-and-separation.md:85 | `:::check` stem | "Two runners start $24\text{ km}$ apart and run toward each other at $5\text{ kph}$ and $7\text{ kph}$" does not say they start at the same time or run at steady speeds. Line 54 says a later start changes the distance used. | Say "start at the same time" and "at steady speeds".
Major | algebra/motion-meeting-and-separation.md:54 | rule sentence | "For moving apart, $d$ is the final gap, minus the gap at the moment the second one starts if it starts later" is long and hard to parse, and no example or pair shows a late start. A student cannot test it. | Split into two sentences, one per case, or add a one-line late-start example.

Minor | arithmetic-number-sense/adding-and-multiplying-fractions.md:80 | why | "two fractions smaller than $1$ give an even smaller answer" holds for positive fractions only. | Say "two positive fractions smaller than $1$".
Minor | arithmetic-number-sense/adding-and-multiplying-fractions.md:92 | pair note | "a part of $\dfrac{3}{5}$ must be less than $\dfrac{3}{5}$" needs the fraction to be less than $1$ and the amount positive. | Say "because $\dfrac{7}{12}$ is less than $1$".
Minor | arithmetic-number-sense/fractions-and-mixed-forms.md:43 | why | "$3$ wholes shared among $8$ equal parts" mixes shares and parts. | Say "$3$ wholes shared equally among $8$".
Minor | arithmetic-number-sense/operation-priority-and-left-to-right.md:50 | rule sentence | "An exponent tells how many copies of the base to multiply" holds for whole-number exponents only. | Say "a whole-number exponent".
Minor | arithmetic-number-sense/operation-priority-and-left-to-right.md:52 | rule sentence | "A root undoes a power" does not say $\sqrt{49}$ is the positive root only. | Say "the square root is the positive number whose square is $49$".
Minor | arithmetic-number-sense/operation-priority-and-left-to-right.md:85 | why | "turns dividing by $3$ and multiplying by $2$ into dividing by $6$" reads as if that were correct. | Say "would wrongly divide by $3\times 2=6$".
Minor | arithmetic-number-sense/grouping-and-fraction-bars.md:88 | why | Uses $\dfrac{48}{6+2}$ before the text introduces it at line 91. | Move the sentence after line 91 or open the why with the expression.
Minor | arithmetic-number-sense/commutative-and-associative-properties.md:88 | `:::check` | Two-way choice. The pair note at line 84 ("Only the parentheses moved ... not the order") lets a student answer "order" by elimination. The value $108$ still needs a solve. | Accept, or ask for a value only.
Minor | data-interpretation/averages-and-pie-chart-shares.md:53 | `:::check` | Repeats the zero trap of the pair directly above (lines 39 to 43, "Include every recorded period") with new numbers. | Accept under the same-kind rule.
Minor | data-interpretation/inverse-proportion-and-ratio-parts.md:45 | core worked chain | Displays $8\times15=120$, $8\times5=40$, $120-40=80$ have no lead-in; line 53 names them as clerk-hours only after the chain. | Put the "clerk-hours" sentence before the chain.
Minor | data-interpretation/percentages-and-ratios-of-groups.md:49 | rule sentence | "two branches" and "two percentages" refer to nothing introduced in the lesson. | Say "two groups of different sizes".
Minor | algebra/motion-meeting-and-separation.md:62 | core worked chain | $180=60t$ appears with no line saying $d=180$, $r=60$ and that $t$ is hours. | Add "Use $d=rt$ with $d=180$ and $r=60$; $t$ is the hours".
Minor | algebra/motion-meeting-and-separation.md:140 | checklist | Lines 140 and 141 say nearly the same thing (opposite directions, add speeds). | Merge into one line, freeing a slot.

Pictures (marker line | svg | finding):

Minor | arithmetic-number-sense/distribution-and-common-factors.md:27 | 01 rectangle | Area picture is true only for a positive $x$ (a width). | Add "for a positive $x$" to the picture caption or the line above.
Minor | data-interpretation/averages-and-pie-chart-shares.md:97 | 01 table | Picture comes before "Use the table." that introduces it. | Put the stem first, then the picture.
Minor | data-interpretation/averages-and-pie-chart-shares.md:115 | 02 pie | Same placement: picture before "Use the pie chart." | Put the stem first.
Minor | data-interpretation/chart-scales-and-differences.md:101 | 02 factory bars | Same placement: picture before "Use the bar chart." | Put the stem first.
Minor | data-interpretation/inverse-proportion-and-ratio-parts.md:55 | 01 clerk bar | The right part is labeled "Left 120 - 40 = 80". "Left" means remaining but sits on the right of the bar. | Label it "Remaining".
Minor | algebra/motion-meeting-and-separation.md:58 | 01 apart and meeting (top) | Shows "25 + 35 = 60 kph" before the display line at 60 introduces it. | Move the picture after line 60.
Minor | algebra/motion-meeting-and-separation.md:58 | 01 apart and meeting (bottom) | The "Meeting" half states "gap closes at speed 1 + speed 2", the method of the check at line 85, with no numbers. The key is not shown, so not a Blocker. | Accept.

## Per lesson (Blockers/Majors/Minors, lesson text only)

- adding-and-multiplying-fractions: 0/0/2
- fractions-and-mixed-forms: 0/1/1
- multiplying-and-dividing-decimals: OK
- operation-priority-and-left-to-right: 0/0/3
- grouping-and-fraction-bars: 0/0/1
- distribution-and-common-factors: OK
- commutative-and-associative-properties: 0/0/1
- additive-and-multiplicative-inverses: OK
- averages-and-pie-chart-shares: 0/0/1
- chart-scales-and-differences: 0/1/0
- inverse-proportion-and-ratio-parts: 0/2/1
- percentages-and-ratios-of-groups: 0/0/1
- motion-meeting-and-separation: 0/2/2

## Per picture (11)

- adding-and-multiplying-fractions/01: OK
- multiplying-and-dividing-decimals/01: OK
- distribution-and-common-factors/01: 1 Minor
- averages-and-pie-chart-shares/01: 1 Minor
- averages-and-pie-chart-shares/02: 1 Minor
- chart-scales-and-differences/01: OK
- chart-scales-and-differences/02: 1 Minor
- inverse-proportion-and-ratio-parts/01: 1 Minor
- inverse-proportion-and-ratio-parts/02: OK
- percentages-and-ratios-of-groups/01: OK
- motion-meeting-and-separation/01: 2 Minors

PRECHECK VERDICT: PASS (0 Blockers; 6 Majors, 20 Minors)
