# Reasoning pre-check, round 2 (E-198, Nov 27)

Verifier: Claude Sonnet 5.5. I did not write or fix these lessons.
Policy read: `origin/main` `05993f914b0491fd3f619f56789b0268a2802572` (AGENTS.md, WORKFLOW.md, SUBAGENTS.md, read in full).
Lessons read at `b8b4fcdbf` (disk unchanged). All 47 lessons under `content/lessons/reasoning/` with a `:::` block. Every check and try was solved blind first, then keyed. Rules applied: the giveaway brief, plus ruling rules 3 (frames) and 4 (signal words) from `la-precheck-fix-brief.md`.

Format: `Severity | file:line | item | how it is given away or why the key is wrong | fix`. Paths are under `content/lessons/reasoning/`. Line numbers point at the `:::check` or `:::try` line.

Severity rule used: Blocker = the answer can be copied from a visible line, or the visible frame (demo or pair directly above) is reused with only words swapped so the answer pattern transplants, or the key is wrong or ambiguous. Major = a partial cue or a same-shape frame that still needs one small computation.

## Findings

### clerical-ability

Blocker | clerical-ability/character-string-filing.md:70 | Check 2 (B-30, B-3, B-4) | Same shape as the M-4, M-40, M-5 demo and `longer-prefix-first` pair above (X-n, X-n0, X-next). The order short, long, other transplants. | New check where the shorter code is not simply first, e.g. three codes that tie at position 1 and differ at position 2 with a letter.
Major | clerical-ability/filing-patterns-and-surname-particles.md:36 | Check 1 (Lina Gomez, Marco Tan, then Nora Bautista) | Same frame as the sample-inference demo directly above (two samples, surname first, apply to a third name). *Bautista* is also reused from Example 1. | Show samples with a different pattern (e.g. surname in capitals, or a middle initial kept) and a new name.
Major | clerical-ability/filing-patterns-and-surname-particles.md:72 | Check 2 (Dela Paz vs Delfin) | Same shape as the De la Cruz / Delgado / De la Rosa demo above: shared "del", fourth letter *a* beats another letter. The spaced name wins, as in the demo. | Use a pair that ties through letter 4, or where the spaced name comes second.
Blocker | clerical-ability/integer-subcode-filing.md:55 | Check (14.3 vs 14.012) | Same frame and same answer shape as the 31.2 vs 31.015 demo and `dot-as-decimal` pair above (a plain second part beats a leading-zero second part). Student copies the pattern. | Pick numbers where the whole-number order reverses the pattern shown, e.g. 14.20 vs 14.015.
Major | clerical-ability/oldest-and-newest-date-order.md:76 | Check 2 (Aug 28 vs Sep 2, 2024) | Same frame as the `day-beats-month` pair directly above (later month, smaller day, which is older). | Use a tie that needs year, then month, e.g. two dates in different years with the later year's month earlier.
Blocker | clerical-ability/personal-name-filing-units.md:44 | Check 1 (Elena Mae Torres, index it) | The *Juan Antonio Santos* demo directly above does exactly this with the same format printed. Only the names change. | Give a name that needs a decision: a two-word surname, or a name the stem writes surname first.
Major | clerical-ability/personal-name-filing-units.md:78 | Check 2 (Garcia, Nico vs Garcia, Beth) | Same frame as the Adams, Arthur / Adams, Benjamin pair above (shared surname, compare given names). | Use a shared surname and given name that differ only on the middle name.
Major | clerical-ability/suffixes-titles-and-filing-ties.md:39 | Check 1 (Lim, Dan, Sr. / Dan, III / Daniel, II) | Same shape as the Santos Leo Jr. / Leo Sr. / Leon Jr. demo above (two short-given-name entries with suffixes, one longer given name). | Change the structure, e.g. the longer given name starts earlier in the alphabet, or add a title.
Major | clerical-ability/year-first-and-stated-date-formats.md:39 | Check 1 (what date is 2025-08-06) | The lead-in prints "2024-03-05 means March 5, 2024" and the YYYY, MM, DD key. The check asks the same conversion. | Ask which of two year-first dates is newer, or use a date whose month and day could be swapped (e.g. 2025-11-04).

### logical-verbal-reasoning

Major | logical-verbal-reasoning/analogy-functions-users-and-work.md:56 | Check 2 (telescope : astronomer :: stethoscope : ___) | Only *doctor* is a person; the others are a thing and two places, so word role alone answers it. Frame mirrors *microscope : biologist* above. | Add a second person choice that fails the direction test (e.g. *patient*) and change the first pair.
Major | logical-verbal-reasoning/analogy-parts-types-and-products.md:157 | Example 4 try (Chapter is to book vs Orchard is to trees) | The `reverse-part-whole` pair above already says "pages : novel reverses container to contents". The reversed choice is the same trap with new nouns. | Use a reversed choice that is not a part of a whole (e.g. a place that holds versus a worker).
Major | logical-verbal-reasoning/combined-truth-values.md:33 | Check 1 (P true, ¬P and ¬¬P) | The lead-in states "if P is T, then ¬P is F" and the demo does P=F with the same two expressions. Student only flips the values. | Use ¬¬¬P, or give P in words.
Major | logical-verbal-reasoning/conditional-truth-values.md:40 | Check 1 (full bus, driver stops anyway) | Same frame as the clean-your-room, no-ice-cream promise above (condition happens, promise not kept). The broken-promise wording points to F. | Describe a false if-part (bus not full, driver stops) so the student must use "false if-part is T".
Blocker | logical-verbal-reasoning/conditional-truth-values.md:61 | Check 2 (P false, Q true; Q→P then P→Q) | The key **(F, T)** is printed in the `reversed-conditional-values` pair directly above ("Right: ... (F, T)"). Student copies it. | Use a case whose pair is not printed above, e.g. P true, Q true in the order Q→P, P→Q ((T, T)), or add a third expression.
Blocker | logical-verbal-reasoning/invalid-conditional-forms.md:42 | Check 1 (air parcel, two days) | Same form and same answer as the `confirm-result-trap` pair directly above (study hard, pass, Maria passed). The heading names the form and says it is invalid. | New surface: reorder the premises, or phrase the conclusion so it is not "therefore P".
Major | logical-verbal-reasoning/invalid-conditional-forms.md:123 | Example 3 try (options 1, 2, 4) | The stem says "allowed boarding does not guarantee a stamped pass", which spells the answer. Option 4 is the only one with both "unstamped" and "allowed". | Ask without the answer words ("which case obeys the rule yet shows the claim can fail?") and add a second plausible option.
Major | logical-verbal-reasoning/sequence-earlier-terms.md:38 | Check 1 (2, 5, 8, 11; twice the last minus the one before) | The sequence is also arithmetic (+3), so a student who ignores the stated rule still gets 14. | Use a start that is not arithmetic, e.g. 3, 4, 6, 9 (rule gives 12).
Major | logical-verbal-reasoning/sequence-earlier-terms.md:64 | Check 2 (Fibonacci-type 2, 4, 6, 10, 16) | The stem names the pattern and the heading above spells its rule (sum of the last two). No recognition needed. | Drop "Fibonacci-type" from the stem.
Major | logical-verbal-reasoning/sequence-letter-patterns.md:32 | Check 1 (D, H, L, P) | The `off-by-one-position` pair directly above prints "T=20". The answer's position and letter are printed. | End at a letter not printed above (e.g. C, G, K, O gives S).
Blocker | logical-verbal-reasoning/sequence-letter-patterns.md:57 | Check 2 (U, X, A, D) | Same +3 wraparound frame as the W, Z, C, F demo and the `wraparound-miscount` pair directly above. | Use a different jump (+4, or backward) wrapping at a different place.
Major | logical-verbal-reasoning/sequence-letter-patterns.md:79 | Check 3 (S, M, T, W, T) | The lead-in lists "months of the year, days of the week, or number words". Days of the week is the group tested. | Use a group the lead-in does not print and the rule covers (e.g. planets from the sun).
Major | logical-verbal-reasoning/sequence-moves.md:32 | Check 1 (12, 18, 24, ..., 36) | Same frame as the 31, 24, ..., 10, 3 demo directly above (arithmetic, one missing middle term). | Hide a term in a pattern where the student must decide difference or ratio.
Blocker | logical-verbal-reasoning/sequence-moves.md:57 | Check 2 (5, 15, 45, 135) | Same ratio (×3) and same ask (next term) as the `2, 6, 18, 54` pair directly above. | Use a ratio not printed (×4, ×5) or a halving pattern.
Blocker | logical-verbal-reasoning/sequence-positions-and-operations.md:36 | Check 1 (7th term of 20, 2, 18, 5, 16, 8) | Same frame as the 1, 10, 3, 8, 5, 6 demo and pair directly above (six terms, find the 7th, odd track continues). | Ask for the 8th term, or use a longer interleaved list.
Major | logical-verbal-reasoning/sequence-positions-and-operations.md:77 | Check 3 (double and subtract 1: 3, 5, 9, 17) | Same frame as the "double and add 1" demo and pair above. Only the sign changes, and the stem states the rule. | State no rule and use a different pair (e.g. ×3 then −2).
Major | logical-verbal-reasoning/truth-tables-and-connectives.md:36 | Check 1 (missing pair in (T,T), (T,F), (T,F), (F,F)) | Same frame as the (T,T), (F,T), (T,F), (F,T) demo directly above (one pair repeated, one missing). | List all rows of a three-letter table, or ask for the missing row of a table that has a different error.
Major | logical-verbal-reasoning/valid-conditional-forms.md:43 | Check 1 (red card, Box 1) | Same frame as the triangle modus tollens line above (not Q, so not P). | Phrase the rule with "only if" or reorder the premises.
Blocker | logical-verbal-reasoning/valid-conditional-forms.md:68 | Check 2 (rain, wet road, traffic slows) | Same frame as the parcel chain directly above (two rules, "not R" gives not Q and not P). Only the story changes. | Give a chain of three rules with the middle one denied, or a chain with a result confirmed.
Blocker | logical-verbal-reasoning/valid-conditional-forms.md:92 | Check 3 (Monday or Tuesday, not Tuesday) | Same frame as the key in Desk 1 or Desk 2 demo and the `rule-out-both` pair above. The answer is the other named option. | Use three options with two ruled out, or a statement where "or" hides one option in a phrase.
Major | logical-verbal-reasoning/valid-conditional-forms.md:149 | Example 4 try (follow P to Q to R) | The chain is printed in step 1 with arrows. The answer is its last item. | Ask which statement follows from a fact in the middle of the chain.

### spatial-abstract-reasoning

Blocker | spatial-abstract-reasoning/cuts-at-two-fold-lines.md:36 | Check 1 (triangle with one whole side on the fold) | Wrong or ambiguous key. The opening is a kite only if the angles at both ends of the side on the fold are acute. A right angle there gives a triangle, an obtuse angle gives a dart. The stem says only "a triangle". The lesson never teaches this shape. | Name the triangle (e.g. an equilateral triangle gives a rhombus) or ask only for the number of openings.
Major | spatial-abstract-reasoning/figure-counts-and-fills.md:31 | Check 1 (squares with 1, 3, 5 dots) | The lead-in directly above does "2, 4, 6 dots, each step adds 2, next has 8". Same frame, new numbers. | Use a count that falls then rises, or a decoy feature that suggests a different rule.
Major | spatial-abstract-reasoning/figure-turns-and-positions.md:35 | Check 1 (lower-left, upper-left, upper-right) | The answer word **lower-right** is printed in the demo and the `double-turn-angle` pair directly above. | Use a series whose next direction is not printed above (e.g. one that ends at left).
Major | spatial-abstract-reasoning/figure-turns-and-positions.md:59 | Check 2 (left, up, left, up; two more steps) | Same frame as the up, right, up, right demo and pair above. The answer word *up* is printed there. | Use a three-state cycle or an alternating turn of different size.
Major | spatial-abstract-reasoning/grouping-outlines-and-symmetry.md:48 | Check 1 (kite, square, trapezoid, octagon) | Same frame as the parallelogram, rectangle, hexagon, rhombus demo above (three four-sided shapes, one with more). | Use a rule that is not side count (e.g. parallel sides, or an equal number of sides but one curve).
Major | spatial-abstract-reasoning/grouping-outlines-and-symmetry.md:73 | Check 2 (no reflection axis) | The correct choice is the only description that says "no" (no equal sides), matching "no reflection axis" in the stem. | Describe the figures by name only, or give two figures with no equal sides but different symmetry.
Major | spatial-abstract-reasoning/matrix-keeping-all-features.md:62 | Check 2 (row 3 starts 2 and 4 dots, add) | Same frame as the dot-count line directly above ("row 3 starting with 1 dot and 3 dots gives 1+3=4"). | Use a rule that is not "add the first two", e.g. subtract, or add and keep the larger.
Major | spatial-abstract-reasoning/matrix-keeping-shared-features.md:68 | Check 2 (corner dots, shared only) | Same frame as the row 3 corner-dot demo directly above (three corner dots in each cell, keep the shared ones). | Use four dots in one cell and two in the other, with one shared.
Major | spatial-abstract-reasoning/matrix-row-and-column-rules.md:66 | Check 2 (sizes small, medium, large shifted) | Same frame as the one-of-each shape grid and the `repeat-in-latin-row` pair above, with sizes instead of shapes. | Use a grid where the row rule and column rule differ (e.g. rows shift, columns also change fill).
Major | spatial-abstract-reasoning/matrix-turns-and-counts.md:65 | Check 2 (2, 4, 6 / 4, 6, 8 / 6, 8, ?) | Same layout as the 1, 2, 3 / 2, 3, 4 / 3, 4, ? demo and `add-row-and-column-twice` pair directly above. Only the step changes. | Use a grid where counts fall across rows and rise down columns.
Major | spatial-abstract-reasoning/parallel-light-and-solid-shadows.md:106 | Example 3 try (sphere turned in place) | Step 1 already says the rim "is the same distance from the center in every direction", which defines a circle. The try only names it. | Remove that clause from step 1 or ask about a solid whose shadow does change when turned.
Major | spatial-abstract-reasoning/testing-a-figure-group-rule.md:36 | Check 1 (gray square, white rectangle, gray rhombus, white triangle) | More than one rule fits: "has four sides" and "has parallel sides" both leave out only the triangle. The key names one. | Give the rule choices as options, or name the feature ("a rule about sides").
Major | spatial-abstract-reasoning/testing-a-figure-group-rule.md:60 | Check 2 (square, two rectangles, parallelogram) | Same frame as the three triangles and one rhombus demo above (a broad rule fits all, narrow it to leave out one). | Use a different broad rule (e.g. "closed outline") and a different narrower feature.
Major | spatial-abstract-reasoning/turning-solids-without-mirror-flips.md:71 | Check 2 (A, B, C; B, C, A or B, A, C) | Same frame as the `reversed-corner-order` pair above (circle, square, triangle; one shifted view, one reversed). Letters swapped. | Use four faces at a corner, or a corner list that is already shifted.
Major | spatial-abstract-reasoning/uneven-folds-and-cut-layers.md:37 | Check 1 (14 cm, 5 cm strip) | Same frame as the 16 cm sheet, 6 cm fold demo directly above. Same formula, new numbers. | Use a flap wider than half the sheet so the overlap is capped at the right edge.
Blocker | spatial-abstract-reasoning/uneven-folds-and-cut-layers.md:71 | Check 2 (punch at (8, 2), fold at 5) | Same frame as the (10, 3) across a fold at 6 pair above, and the reflected x is also **2**, the number printed in that pair. Student keeps the height and copies 2. | Choose numbers whose reflected x is not printed above, e.g. fold at 5, punch at (7, 2) gives (3, 2).

### verbal-logic

Major | verbal-logic/best-supported-conclusions.md:40 | Check 1 (English and Filipino log) | The stem says "with no first-language data", which gives the answer. Only two answers (yes or no). | Remove the clause and ask what the log supports, with three claims to choose from.
Major | verbal-logic/best-supported-conclusions.md:87 | Check 3 (Ana short tests, Ben long tests) | The stem says "with no test counts". Same cue. Also the same pattern as Example 2 below. | Remove the clause and give a combined-total claim to judge.
Major | verbal-logic/best-supported-conclusions.md:139 | Example 3 try ((B) vs (C)) | (C) "use the library" repeats the stem phrase ("used the library"). (B) adds "read more books". The only choice that repeats the stem wins. | Add a third wrong choice that also repeats the stem but widens the group or the time.
Major | verbal-logic/compound-assumptions.md:65 | Check 2 (open Saturday or Sunday or holiday) | Same frame as the "submitted online or delivered in person" demo above (negate "or" as "neither"). The third option is the only change. | Negate an "or" that sits inside an "and", or ask which of three findings makes the claim false.
Major | verbal-logic/compound-assumptions.md:88 | Check 3 (generator or at least one solar battery) | Same frame as the "battery and at least one of its two memory cards" demo above. The answer reuses "neither ... charged". | Use "all of" or "none of" inside the compound.
Major | verbal-logic/must-be-true-conclusions.md:57 | Check 2 (taller than 120 cm) | The lead-in directly above prints the same idea with 80%: "above 80% excludes 80% itself". Same question, new number. | Use a cutoff written in words ("under the age of 18") or a "from 5 up to 10" range.
Blocker | verbal-logic/must-be-true-conclusions.md:82 | Check 3 (some books are dictionaries; must one not be?) | The lesson prints "Some A are B never forces Some A are not B" and the inspectors bullet "every inspector could be an auditor". The check asks the same question. | Ask about a different consequence of "some", e.g. "Must some dictionaries be on the top shelf?" with an added premise that tempts "none".
Blocker | verbal-logic/needed-assumptions.md:74 | Check (rooftop solar, every school power need) | Same trap and same answer as the `extreme-universal-claim` pair directly above, and the key repeats the pair's sentence ("still lets some ... replace"). | Use an argument where the extreme word is a needed assumption, so the answer is yes.
Blocker | verbal-logic/negating-assumptions.md:88 | Check 3 (No Grade 6 pupil has a library card) | The correct choice and both wrong choices copy the `all-to-none-overnegation` pair directly above (at least one has / every has). Only (A) is new. | Negate an "all" with a named group and make every wrong choice a different near-miss (not the pair's).
Major | verbal-logic/none-and-may.md:50 | Check 1 (plant 7, "Also sold at the stall") | The correct choice is the only one that repeats a phrase from the stem ("sold at the stall"). | Make every note share a phrase with the stem (e.g. "Lent to a school again", "Sold at the stall earlier", "Sold in June").
Blocker | verbal-logic/none-and-may.md:72 | Check 2 (ferry may leave late) | Same frame as the `may-to-must-certainty` pair directly above ("may ... if ..."). Choice (A) is the pair's wrong line and (B) is its right line. | Use "may" in a different position (e.g. "The class may end early") and different wrong choices.
Blocker | verbal-logic/none-and-may.md:128 | Example 3 try ((B) vs (C)) | Same frame as the judges, speakers, observers demo and `stretch-some-to-none` pair above. (C) "Some X are not Z" is the printed template. This is the redone item. | Use a third premise shape the lesson has not shown, e.g. "No volunteer under 18 is a driver; some drivers are volunteers".
Major | verbal-logic/recognizing-bias.md:34 | Check 1 (new manager a hero) | Same frame as the lazy and responsible attendance example above (praise and insult with no evidence). The stem also says "no records". | Use unequal wording for equal facts (both managers have the same records, different adjectives).
Blocker | verbal-logic/recognizing-bias.md:57 | Check 2 (market fee, six speakers, all accurate) | The `why` block above prints this case: accurate quotes, one side picks the speakers. The market-fee story matches the "anti-fee club" example. | Use a different source of one-sidedness (e.g. a survey placed only at one site) so the student must find the cue.
Blocker | verbal-logic/recognizing-bias.md:130 | Example 3 try ((B) vs (C)) | (C) "A proposed curfew rule for families" copies the printed neutral revision "A proposed drainage plan for residents". (B) copies the pair's wrong pattern. | Rewrite the biased phrase in a different shape and make the neutral choice not start with "A proposed".
Major | verbal-logic/unsupported-causes-and-motives.md:36 | Check 1 (bakery delivery) | The claim repeats the owner's quote word for word ("because customers kept asking"). | Put the stated reason in a different wording and add a similar but unstated claim.
Blocker | verbal-logic/unsupported-causes-and-motives.md:62 | Check 2 (new textbook morning vs old afternoon) | The `why` block above prints the answer: repeating the mixed test on more plots fails, test both trays at one elevation. Same two choices. | Ask which change to the plan would isolate the factor, with three options that each fix a different problem.
Major | verbal-logic/unsupported-causes-and-motives.md:80 | Check 3 (Mariel took down her poster) | Same frame as the flexible-hours motive demo above (action after an event, guessed reason). | Give a stated reason in a different part of the stem so the student must tell stated from guessed.
Major | verbal-logic/unsupported-causes-and-motives.md:136 | Example 3 try ((A) vs (C)) | (C) repeats the stem sentence ("rainier days had lower attendance"). The stem also says "No causes were tested". | Add a wrong choice that repeats the data but adds a cause, and drop "no causes were tested".

## Per lesson

OK means no flagged item. Number = flagged items (Blockers, Majors).

clerical-ability
- character-string-filing: 1 (1B)
- filing-patterns-and-surname-particles: 2 (2M)
- integer-subcode-filing: 1 (1B)
- oldest-and-newest-date-order: 1 (1M)
- personal-name-filing-units: 2 (1B, 1M)
- suffixes-titles-and-filing-ties: 1 (1M)
- terminal-digit-filing-order: OK
- whole-number-and-decimal-filing: OK
- year-first-and-stated-date-formats: 1 (1M)

logical-verbal-reasoning
- analogy-functions-users-and-work: 1 (1M)
- analogy-meanings-and-double-pairs: OK
- analogy-parts-types-and-products: 1 (1M)
- combined-truth-values: 1 (1M)
- conditional-truth-values: 2 (1B, 1M)
- deductive-group-arguments: OK
- invalid-conditional-forms: 2 (1B, 1M)
- sequence-earlier-terms: 2 (2M)
- sequence-letter-patterns: 3 (1B, 2M)
- sequence-moves: 2 (1B, 1M)
- sequence-positions-and-operations: 2 (1B, 1M)
- truth-tables-and-connectives: 1 (1M)
- valid-conditional-forms: 4 (2B, 2M)

spatial-abstract-reasoning
- combined-and-mixed-figure-patterns: OK
- cuts-at-two-fold-lines: 1 (1B)
- figure-counts-and-fills: 1 (1M)
- figure-turns-and-positions: 2 (2M)
- folded-layers-and-separate-holes: OK
- folding-and-checking-cube-nets: OK
- grouping-outlines-and-symmetry: 2 (2M)
- grouping-regions-and-inside-details: OK
- matrix-keeping-all-features: 1 (1M)
- matrix-keeping-shared-features: 1 (1M)
- matrix-row-and-column-rules: 1 (1M)
- matrix-turns-and-counts: 1 (1M)
- parallel-light-and-solid-shadows: 1 (1M)
- testing-a-figure-group-rule: 2 (2M)
- turning-solids-without-mirror-flips: 1 (1M)
- uneven-folds-and-cut-layers: 2 (1B, 1M)
- unfolding-cuts-across-a-fold: OK

verbal-logic
- best-supported-conclusions: 3 (3M)
- compound-assumptions: 2 (2M)
- must-be-true-conclusions: 2 (1B, 1M)
- needed-assumptions: 1 (1B)
- negating-assumptions: 1 (1B)
- none-and-may: 3 (2B, 1M)
- recognizing-bias: 3 (2B, 1M)
- unsupported-causes-and-motives: 4 (1B, 3M)

## Other checks

Keys re-solved and correct (no wrong key found except the cuts-at-two-fold-lines item above). Keys I re-derived by hand: the staircase cube net (D is opposite A), the 8-layer corner cut (two openings), the top-front-right corner order (star, triangle, dot), the 5-fold partial unfold (8 locations), and every sequence, filing and truth-value item.

Fix side effects: none of the round-1 fixes left an old instance named in a later line. The fixed items that now fail are copies of the frame above them (none-and-may Example 3, recognizing-bias Example 3, personal-name-filing Check 1, and the unfolding Checks in the logic lessons). Example 1 of `combined-truth-values` is word for word the lead-in demo (not a check, not counted).

Figures. Every `<!-- ILLUSTRATION -->` marker has an SVG in marker order, and the drawn figure matches the text:
- deductive-group-arguments (2), invalid-conditional-forms (1), valid-conditional-forms (2): circles nest as the text says; Maria sits outside the inner circle; Cabinet A is hatched and the document is in the B-only part.
- combined-and-mixed-figure-patterns (2): sizes small to extra large and fills match choices A to D; eight cells match the odd and even tracks.
- cuts-at-two-fold-lines (1), folded-layers-and-separate-holes (3): fold order, hole counts and reflected positions match (the 3-fold holes are unevenly spaced, as the marker asks).
- figure-counts-and-fills (2), figure-turns-and-positions (3): shapes, fills, arrow directions, dot corners and choices match.
- grouping-outlines-and-symmetry (3), grouping-regions-and-inside-details (3), matrix-keeping-all-features (1), matrix-keeping-shared-features (1), matrix-row-and-column-rules (2), matrix-turns-and-counts (2), testing-a-figure-group-rule (1): match.
- turning-solids-without-mirror-flips (1): Candidate A keeps the clockwise order long, medium, short; Candidate B reverses it. Match.
- uneven-folds-and-cut-layers (1), unfolding-cuts-across-a-fold (1): 12 cm sheet, fold at 4, punch at (10, 3), one hole; the isosceles notch opens to a four-equal-sided diamond. Match.
- The `<!-- FIGURE: {...} -->` cube-net and shadow figures (cube nets, parallel light) match their labels. `<!-- FIGURE WANTED -->` comments are hidden; the text of each affected example stands alone.

Not verified: how the app renders the cube-net and geometry-diagram figure markers (I read the marker data only).

PRECHECK VERDICT: FAIL (20 Blockers, 45 Majors)
