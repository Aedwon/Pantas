# Reasoning blind giveaway pre-check findings (E-198)

Verifier: Claude Sonnet 5.5, read-only. Policy read: `origin/main` `0234382b8`. Lessons read at `3cf5cf08e` (unchanged on disk).
Method: `giveaway-precheck-brief.md`. Every item re-solved independently.

Severity | file:line | item | how it is given away or why the key is wrong | fix

## clerical-ability (9)

Blocker | clerical-ability/suffixes-titles-and-filing-ties.md:39 | Quick Check 1 (Cruz, Ramon, Sr. vs Jr.) | The visible lead-in sort (line 30) already states "Jr. precedes Sr." and line 23 says "J before S" under the same rule. The check asks the same comparison and the student only copies it. | Use a different pair (for example II vs III, or Jr. vs II) or ask a three-way sort the lead-in does not already show.

- character-string-filing: OK
- filing-patterns-and-surname-particles: OK
- integer-subcode-filing: OK
- oldest-and-newest-date-order: OK
- personal-name-filing-units: OK
- suffixes-titles-and-filing-ties: 1 flagged
- terminal-digit-filing-order: OK
- whole-number-and-decimal-filing: OK
- year-first-and-stated-date-formats: OK

## logical-verbal-reasoning (13)

Blocker | logical-verbal-reasoning/conditional-truth-values.md:40 | Quick Check 1 (P true, Q true, evaluate P → Q) | The printed four-case line above already reads "$T \rightarrow T = T$". The keyed value is copied from a visible line. | Use a different ask, such as "which of the four rows makes P → Q false and why", or a worded case where the student must first assign T and F.
Major | logical-verbal-reasoning/conditional-truth-values.md:61 | Quick Check 2 (P false, Q true, both directions) | The keyed pair "(T, F)" is printed verbatim in the "Wrong" line of the pair above ("(P → Q, Q → P) equals (T, F)"), and the four-case line gives both values. A student can copy it without the rule. | Change the inputs or the wording so the keyed pair is not the pair printed as the wrong example.
Major | logical-verbal-reasoning/deductive-group-arguments.md:82 | Quick Check 2 ("All fish live in trees..." valid? sound?) | Same shape as the visible pair "All birds can fly; a penguin is a bird" with the keyed label "valid, unsound" printed word for word. The student matches the pattern (obviously false premise, same form). | Swap in a case with a different label, such as a true-premise argument with a bad link (invalid), or make the false premise less obvious.
Major | logical-verbal-reasoning/invalid-conditional-forms.md:42 | Quick Check 1 (Baguio / Luzon, valid?) | The heading "Affirming the Consequent" and the line "This form is invalid" sit directly above. Every item in this lesson is invalid, so the answer is always "no". | Add one valid contrast item (modus ponens or tollens) so "invalid" is not constant, or ask which form it is without the heading above.
Major | logical-verbal-reasoning/invalid-conditional-forms.md:74 | Quick Check 2 (no sale, line not long, valid?) | The heading "Denying the Antecedent" and "This form is invalid" sit directly above, and the answer is again "no". | Same as above: mix in a valid form or move the check below a neutral heading.
Blocker | logical-verbal-reasoning/truth-tables-and-connectives.md:58 | Quick Check 2 (P false, Q true, evaluate P ∧ Q) | The printed line directly above reads "$F \land T = F$". The keyed value is copied from a visible line. | Ask for a case not printed (for example a three-part expression, or "which row gives T") or a worded and-statement.
Major | logical-verbal-reasoning/truth-tables-and-connectives.md:84 | Quick Check 3 (pen and pencil, inclusive or) | The line "It is also true when both statements are true", the printed "$T \lor T = T$" and the pair's Right line all state the key (the Why block is not counted as visible). | Change the case so the student must decide, for example neither item brought, or one of three items brought.

- analogy-functions-users-and-work: OK
- analogy-meanings-and-double-pairs: OK
- analogy-parts-types-and-products: OK
- combined-truth-values: OK
- conditional-truth-values: 2 flagged (1 Blocker, 1 Major)
- deductive-group-arguments: 1 flagged (1 Major)
- invalid-conditional-forms: 2 flagged (2 Major)
- sequence-earlier-terms: OK
- sequence-letter-patterns: OK
- sequence-moves: OK
- sequence-positions-and-operations: OK
- truth-tables-and-connectives: 2 flagged (1 Blocker, 1 Major)
- valid-conditional-forms: OK

## spatial-abstract-reasoning (17)

Blocker | spatial-abstract-reasoning/combined-and-mixed-figure-patterns.md:68 | Quick Check 2 (up triangle, circle 1 dot, right triangle, circle 2 dots, down triangle, 6th position) | The keyed "circle with 3 dots" is printed in the pair above ("pick Circle with three dots") for the same interleaved shape-and-dot structure (circle with 1 dot, circle with 2 dots, next is 3). | Change the dot step or the track (for example circle dots 2, 4 then 6, or a fill track) so the keyed figure is not printed above.
Major | spatial-abstract-reasoning/cuts-at-two-fold-lines.md:36 | Quick Check 1 (vertical fold, semicircle on the fold, openings and shape) | Step 3 above says the cut becomes "1 connected circular opening", and the pair says "One connected central opening". The count and shape are printed; the student restates them. | Use a cut that gives a different shape or count (for example a triangle cut whose base lies on the fold, or a cut that touches the fold only at one point).
Blocker | spatial-abstract-reasoning/cuts-at-two-fold-lines.md:66 | Quick Check 2 (V, H, V folds, notch on the horizontal crease only, connected openings) | The keyed "four connected openings" is printed word for word in the pair above ("Four connected openings") for the same vertical, horizontal, vertical packet. A student can copy "four" without working the folds. (Key is correct: 4.) | Change the fold sequence or the touched crease so the answer differs from the printed one (for example notch on the first vertical crease only, answer 2).
Major | spatial-abstract-reasoning/figure-counts-and-fills.md:85 | Quick Check 3 (white, gray, black, white, gray, sixth fill) | The stem names the cycle ("repeats the fill cycle white, gray, black"), so "black" is read straight from the stem. | Remove "repeats the fill cycle" and show only the series, or use a cycle with a repeated fill (black, black, white).
Blocker | spatial-abstract-reasoning/figure-turns-and-positions.md:35 | Quick Check 1 (arrow up, right, down, next) | The clockwise definition just above reads "top to right to bottom to left". The check gives the first three words of that list and the keyed word "left" is the next one. | Use a start that is not top-first (for example arrow left, up, right, next) or a 45-degree step.
Major | spatial-abstract-reasoning/figure-turns-and-positions.md:129 | Example 3 (not an item) | The ILLUSTRATION marker and its SVG show frame 4 as lower-left and choices down, up, upper-right, upper-left. The text says frame 4 is "left" and the answer is "right", which is not among the drawn choices. The student cannot match text to figure. | Redraw frame 4 as left and the choices as down, right, up, upper-left (or change the text to match the figure).
Major | spatial-abstract-reasoning/folded-layers-and-separate-holes.md:68 | Quick Check 2 (3 folds, open only the last fold, locations) | The pair above prints "Two locations" and the text says opening one fold "doubles the 1 punch into 2 visible hole locations". The answer is the same constant 2 whatever the layer count. | Ask for the count after opening two folds, or name a fold that is not the last.
Major | spatial-abstract-reasoning/folding-and-checking-cube-nets.md:76 | Quick Check 2 (row of 4, E above A, F above C, folds into a cube?) | The heading "Rejecting Nets That Overlap" and the failing row shown above set up "no". The only yes/no item under that heading can only be "no". (Key is correct.) | Rename the heading to a neutral one, or add a valid net so the answer is not constant.
Major | spatial-abstract-reasoning/grouping-outlines-and-symmetry.md:73 | Quick Check 2 (rectangle, isosceles triangle, regular hexagon, scalene triangle, no reflection axis) | The stem explains only the correct figure ("scalene triangle with three unequal sides"), so it is the only choice with a hint. | Describe all four figures the same way or none.
Major | spatial-abstract-reasoning/parallel-light-and-solid-shadows.md:106 | Try, Example 3 (sphere turned, shadow after the turn) | Step 1 above already says "every cross-section is a circle ... so the shadow is a circle". The key "It stays a circle" repeats that word. | Ask about a solid that does change (for example a cube turned to a corner), or ask the student to state why the sphere's shadow cannot change.
Major | spatial-abstract-reasoning/testing-a-figure-group-rule.md:36 | Quick Check 1 (small circle, large square, small triangle, large pentagon; which rule works) | The visible pair and step 2/3 reject "small outline" and keep "contains N dots". The check has the same template with the dot count changed, and the stem already offers "small outline" to reject. | Change the feature (for example side count or fill) so the visible template does not apply.
Blocker | spatial-abstract-reasoning/testing-a-figure-group-rule.md:60 | Quick Check 2 (square, two rectangles, slanted parallelogram; rule that groups three) | Ambiguous key. "Four square corners" is keyed, but "has a reflection axis" also groups the square and both rectangles and excludes a slanted parallelogram, and the lesson's own Example 2 uses reflection axes as a rule. | Add "about angles" to the stem, or make it multiple choice with one defensible rule.
Major | spatial-abstract-reasoning/turning-solids-without-mirror-flips.md:107 | Try, Example 2 (corner order after the turn, starting from top) | The keyed order "star, triangle, dot" is the order the three faces are named in steps 1 to 3 above (star stays on top, triangle moves to right, dot moves to front). The student can copy the order. (Key is correct; I re-derived it.) | Reorder the steps (name the front face first) or turn the other way so the clockwise order differs from the order named.
Major | spatial-abstract-reasoning/unfolding-cuts-across-a-fold.md:33 | Quick Check 1 (folds H, V, H; order to open) | The lead-in step 2 prints the same answer for V, H, V: "last vertical, then horizontal, then first vertical". Swapping the two words gives the key. | Use a sequence with no mirror in the lead-in (for example V, V, H).
Blocker | spatial-abstract-reasoning/unfolding-cuts-across-a-fold.md:64 | Quick Check 2 (arrow cut points up, 3 cm from a horizontal fold, copy direction and distance) | The bullet above reads "Across a horizontal fold, an upward cut reflects into a downward cut", and the pair repeats it. The check is the same case, and the distance is in the stem. | Use a diagonal or sideways pointing cut across a horizontal fold, or a cut across a vertical fold with a different direction and a mixed distance.

- combined-and-mixed-figure-patterns: 1 flagged (1 Blocker)
- cuts-at-two-fold-lines: 2 flagged (1 Blocker, 1 Major)
- figure-counts-and-fills: 1 flagged (1 Major)
- figure-turns-and-positions: 2 flagged (1 Blocker, 1 Major; the Major is an example/figure mismatch)
- folded-layers-and-separate-holes: 1 flagged (1 Major)
- folding-and-checking-cube-nets: 1 flagged (1 Major)
- grouping-outlines-and-symmetry: 1 flagged (1 Major)
- grouping-regions-and-inside-details: OK
- matrix-keeping-all-features: OK
- matrix-keeping-shared-features: OK
- matrix-row-and-column-rules: OK
- matrix-turns-and-counts: OK
- parallel-light-and-solid-shadows: 1 flagged (1 Major)
- testing-a-figure-group-rule: 2 flagged (1 Blocker, 1 Major)
- turning-solids-without-mirror-flips: 1 flagged (1 Major)
- uneven-folds-and-cut-layers: OK
- unfolding-cuts-across-a-fold: 2 flagged (1 Blocker, 1 Major)

## verbal-logic (8)

Major | verbal-logic/best-supported-conclusions.md:40,66,87 | Quick Checks 1, 2, 3 | All three keys are "no". The lesson is about what is not supported, so a student who answers "no" to every "does X prove Y?" passes all three without the rule. | Make one check a "yes" (a case where the facts do support the claim).
Major | verbal-logic/best-supported-conclusions.md:137 | Try, Example 3 (later-hours trial) | Choice (C) is the only hedged choice ("some workers") and the only one that repeats the stem's words ("workers", "use the library"); (B) carries "prove" and "all". Step 2 above already dropped (A) on the same words. | Rewrite (B) and (C) so both repeat stem words and both hedge, and differ only in what the trial measured.
Major | verbal-logic/compound-assumptions.md:65 | Quick Check 2 (barrel or cistern, false) | The heading "Negating an Or Statement", the printed rule "A or B negates to Neither A nor B" and the worked example give the key form "neither ... nor" with the nouns swapped. | Use a nested or three-part or-claim, or ask for the negation of a worded and/or mix not shown above.
Major | verbal-logic/compound-assumptions.md:133 | Try, Example 3 (negate "at least one sensor calibrated") | (C) is the only choice with "neither", and the visible core steps and checklist print "at least one" becoming "neither" for the same kind of claim. (Key is correct.) | Make both (B) and (C) use "neither" or "none" in different positions, so the student must place it.
Major | verbal-logic/must-be-true-conclusions.md:34,57,82 | Quick Checks 1, 2, 3 | All three keys are "no". The lesson is about what does not have to be true, so "no" passes every check. Check 1 also copies the printed bullet ("If heavy rain, move indoors" plus "moved indoors"). | Make one check a "yes" (a conclusion that must follow).
Major | verbal-logic/must-be-true-conclusions.md:134 | Try, Example 3 (cataloged shells) | (C) repeats the stem's "Some ... shells" and "cataloged", while (A) carries the extreme "Every". Step 3 above already drops (B) on "some allows all". | Give (A) and (C) the same quantifier so the student must test the premise link.
Major | verbal-logic/needed-assumptions.md:35 | Quick Check 1 (identify the conclusion of the canteen passage) | The conclusion is the first sentence and the only sentence with "should", exactly as in the visible library example. It is copied word for word from the stem. | Put the conclusion last or after "so", or use a passage where the first sentence is a premise.
Major | verbal-logic/needed-assumptions.md:124 | Try, Example 3 (landfill) | Choice (A) contains "only", and the visible text above tells the student to "watch extreme words like every, all, or only". The key (C) is the only choice without an extreme word. (B) is already dropped.  | Remove the extreme word from (A) or add one to (C) so the extreme-word cue does not decide it.
Blocker | verbal-logic/negating-assumptions.md:88 | Quick Check 3 (why "No night guard" is not the negation of "No day guard") | The heading "Keeping the Same Group and Condition" and the line "Never swap sides" already state the answer, and the stem names the two groups it differs on. | Ask for the negation of a new statement and choose from options where one swaps the group.
Major | verbal-logic/negating-assumptions.md:144 | Try, Example 3 (every returned form has a parent signature) | Step 2 above says "Every fails when one such form fails". (C) is the only choice that names one form; (B) uses "No form ... any" (an extreme). The step already gives the form of the answer. | Reword step 2 to leave the form unstated, or give (B) a single-form wording.
Blocker | verbal-logic/none-and-may.md:50 | Quick Check 1 (plants for sale vs on loan, which label is an error) | The stem names the two lists "for sale" and "on loan". Only the label "For sale and on loan" repeats both list names, so it can be picked by matching the stem alone. | Name the lists differently from the label wording, or add a third label that also repeats a list name.
Major | verbal-logic/none-and-may.md:72 | Quick Check 2 ("classes may shift online", does it confirm?) | The heading "Keeping 'May' as Possibility" and the printed line "Never turn may into will or must" give the answer "no" directly. | Ask for what follows from a "may" statement in a new setting (for example may with a stated condition) or use options that include "will".
Blocker | verbal-logic/none-and-may.md:118 | Try, Example 3 (supervisors, trainees, mentors) | The visible Core worked case (judges, speakers, observers) has the same form, and its conclusion "Some observers are not speakers" is printed. Choice (C) "Some mentors are not trainees" is that line with the nouns swapped, and (A) is the printed wrong move ("No observer...") swapped too. | Use a different quantifier pattern (for example "All" plus "No") or change the core worked case so it does not match.
Blocker | verbal-logic/recognizing-bias.md:34 | Quick Check 1 (Grade 10 "confident speakers" vs Grade 9 "loud show-offs") | The visible sign 2 prints the same case: "Unequal terms for equal groups ... 'experienced vendors' ... 'people protecting their turf'". The keyed phrase "unequal terms" appears word for word. | Use a different bias sign (for example selective evidence) or reword the sign list so it does not carry the same case.
Major | verbal-logic/recognizing-bias.md:57 | Quick Check 2 (only residents of one street interviewed) | The visible sign "One-sided sources: inviting only members of an anti-fee club..." has the same form, and the key restates it ("favored one viewpoint"). | Change the scenario so the bias is less direct (for example speakers equal in number but chosen by one side).
Blocker | verbal-logic/recognizing-bias.md:128 | Try, Example 3 (curfew rule, (B) or (C)) | The visible neutral revision above prints the pattern "A proposed drainage plan for residents". (C) "A proposed curfew rule for families" is the only choice with that pattern. | Print a different neutral form in the core, or give (B) the same "A proposed ... for ..." shape with a judgment word.
Major | verbal-logic/unsupported-causes-and-motives.md:36,80 | Quick Checks 1 and 3 | Both yes/no items are "no". The lesson's rule is "not supported", so "no" passes both. | Make one a "yes" (a case with a stated reason or a controlled test).
Major | verbal-logic/unsupported-causes-and-motives.md:134 | Try, Example 3 (rain and attendance) | Choice (C) is the only one using the lesson's own term "associated" (printed in the heading and text above), and (A) carries "the only reason". (B) is already dropped. | Phrase (C) without "associated" (for example "attendance was lower on rainier days") and (A) without "only".

- best-supported-conclusions: 2 flagged (2 Major)
- compound-assumptions: 2 flagged (2 Major)
- must-be-true-conclusions: 2 flagged (2 Major)
- needed-assumptions: 2 flagged (2 Major)
- negating-assumptions: 2 flagged (1 Blocker, 1 Major)
- none-and-may: 3 flagged (2 Blockers, 1 Major)
- recognizing-bias: 3 flagged (2 Blockers, 1 Major)
- unsupported-causes-and-motives: 2 flagged (2 Major)

## Notes

- Not flagged but borderline (answer is the printed rule applied to new content, with no copyable line): analogy word-role cues (person, category word) in the three analogy lessons; negating-assumptions Quick Check 1 and 2; compound-assumptions Quick Check 1 and 3.
- `:::why` blocks were treated as not visible, as the brief says.
- FIGURE WANTED comments: no flagged item depends on one. Every Quick Check and try in the 47 lessons is solvable from text.
- Re-derived keys (all correct): cuts-at-two-fold-lines Quick Check 2 (4), cube-net staircase (D), cube-net Example 3 (A, B, C), turning-solids Example 2 corner order (star, triangle, dot), uneven-folds Quick Check 2 ((2, 2)), figure-turns Quick Checks 1 and 3, folded-layers Quick Check 1 (32).

PRECHECK VERDICT: FAIL (13 Blockers, 28 Majors)
