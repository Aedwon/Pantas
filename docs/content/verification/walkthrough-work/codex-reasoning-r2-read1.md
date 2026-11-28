# R2 logic walkthrough audit

Target `7ea6b5850` on `content/walkthrough-reasoning-r1`. Policy `origin/main` at `a269f8cbd`. Lesson, figure, evidence, and question references are to the target blobs. Quiz numbers below use the suffixes in the assigned banks.

## deductive-group-arguments.md

Major | deductive-group-arguments.md:78 | The Wrong line says to call the lemon argument sound because a premise is false. The cited “Valid, sound” distractor ignores the false premise. The “Invalid, unsound” distractor lets that premise change the validity verdict. | State the two mistakes separately and tie each to the corresponding verdict.
Major | 03-a-circle-labeled-birds-inside.svg:11 | The outer circle reads “Can fly as the first premise assumes.” The paired solution calls it “Can fly” at lines 105 and 107. | Use “Can fly” as the circle label and keep the assumption in the description and marked premise.

Recomputed the approved-report overlap, the invalid dog argument, both validity examples, the snake Quick Check (no snakes have fur), and the permit-holder try (some are outside the licensed group). Figure 01 shows containment, separation, and a witness inside both circles. Figures 02 and 03 place the witness inside both circles under the stated premises. Figure 03 has the label mismatch above. The remaining pair citations match the scope and validity errors in 0001, 0002, and 0008. Recomputed all 10 linked quiz keys.

## valid-conditional-forms.md

Major | valid-conditional-forms.md:38 | The Right line asks for a validity verdict from the pump rule and the empty tank alone. Validity judges an inference, and this line leaves out the conclusion to judge. | Add “therefore the pump was not working under those conditions” before the verdict.
Major | valid-conditional-forms.md:39 | The real-world-doubt pair matches 0005. The cited 0013 choice says nothing can be concluded about the shape and its rationale overlooks the negative inference. It supplies no outside exception. | Cite 0005 alone for this pair.
Major | valid-conditional-forms.md:60 | The parcel example combines two backward deductions on one line. | Show not acknowledged giving not logged, then show not logged giving not scanned on the next line.
Major | valid-conditional-forms.md:65 | “Follow the arrows in one direction only” blurs the difference between reversing a rule as written and using its valid negative form, which line 53 just taught. | Say “To work backward, deny the result to rule out its condition.”
Major | valid-conditional-forms.md:81 | The premises describe a file, then the Right and Wrong lines switch to “the original” without identifying it as the same object. | Call it “the original document” throughout the pair.
Major | 01-a-circle-labeled-alarms-working.svg:13 | The label adds “properly” to the stem's condition “working under these conditions” at line 100. | Use “Alarms working under these conditions.”

Recomputed the two direct forms, both directions of the parcel chain, the key location, and Examples 1 to 3 (all valid). Quick Check: the ticket lacked a stamp. Try: the records were incomplete, and decisions sent and unsent both fit the rules. Figure 01 nests working alarms inside ringing alarms with the tested alarm outside both. Figure 02 excludes the whole Cabinet A region and places the document in the B-only region. The reverse-chain and rule-out-both citations match 0017 and 0018. Recomputed all 7 linked quiz keys.

## invalid-conditional-forms.md

Blocker | invalid-conditional-forms.md:59 | The Why block says an empty room proves nobody walked through a particular door. Someone could have entered and then left. The example does not preserve the conditional rule it uses to teach modus tollens. | Say “If someone used door P, the entry log lists them. Their name is missing, so they did not use door P.” Use the same rule to show why someone who skipped door P could still appear in the log.
Blocker | invalid-conditional-forms.md:117 | Option 4 says boarding was allowed. The key adds that the visitor actually boarded to contradict the guard's claim about people who board. Permission leaves actual boarding open, so the printed options do not establish the keyed counterexample. | Ask which case breaks the claim “Everyone allowed to board has a stamped pass.” Keep permission as Q throughout the stem, choices, and solution, and show the guard's claim as Q implying P.
Major | invalid-conditional-forms.md:64 | The pair addresses whether “it did not rain” contradicts the first premise. The cited “Invalid: premise contradicted” rationale instead rejects the second premise itself. | Explain that this distractor rejects the given fact that it did not rain, and that the verdict comes from accepting both premises.
Major | invalid-conditional-forms.md:122 | “Everyday exception” can suggest an exception to the stated rule. A counterexample has to satisfy all the premises, even if the scenario is unusual. | Say “Find a case where every premise is true and the conclusion is false.”

Recomputed both invalid forms with a false condition and true result, the card and rain cases, and the Maria and Leo arguments. The Quick Check is valid because a locked door denies the result. The try eliminates 1 and 3 as intended, but 4 still needs the extra boarding fact noted above. Figure 01 shows a possible Maria placement within the pass group and outside the study group, with matching labels. Evidence 0003 and the “Valid: result denied” choice from 0004 match their pairs. Recomputed all 3 linked quiz keys.

## truth-tables-and-connectives.md

Blocker | truth-tables-and-connectives.md:28 | The worked prompt asks for “the row that must change.” Either row 2 or row 4 can be replaced with (F, F), so neither individual row must change. | Ask for the missing pair and one row it could replace. Accept either repeated row.
Major | truth-tables-and-connectives.md:82 | Example 1 reuses the exact inputs and connective evaluations from lines 42 to 54. Two complete ordered pairs also appear in the preceding trap pairs. | Make assembling a table from the earlier results the stated task, or work a fresh expression in the table.
Major | truth-tables-and-connectives.md:119 | The try asks the reader to find the second row, but line 54 already prints the exact computation F or F = F. Comparing the two rows still takes a step. | Give both row results and ask how the output compares with P. Hide only that comparison.
Minor | truth-tables-and-connectives.md:94 | The answer prints its ordered truth-value pairs as plain text. | Put each pair in inline math, as in the steps above.

Recomputed all four input pairs and both connective tables. The two-column result is (T, T), (F, T), (F, T), (F, F). Rina's statement and the Joy Quick Check are true. The try output equals P for either value of P. Pair evidence matches 0021, 0002, and 0001. Recomputed all 6 linked quiz keys. In quiz 0021, option text offers only one working correction, so its multiple-choice key is unique.

## conditional-truth-values.md

Blocker | conditional-truth-values.md:103 | The rewritten try still asks for two reversed-rule evaluations that appear above it. Day 3 has P=F and Q=T, so Example 2 at line 89 gives the exact requested Q → P result, F. Day 4 has P=F and Q=F, so the Right line at 35 already gives the other requested Q → P result, T. | Fade a comparison or deduction from the table values, such as deciding which days make the forward and reversed rules disagree and explaining how the two days differ.
Major | conditional-truth-values.md:78 | The heading says the reverse direction has a false if-part. In this example its if-part is Q, which is true. P is the false if-part in the forward direction. | Use “A False If-Part in the Forward Direction.”

Recomputed the four material-conditional cases, the swap demo, and Examples 1 and 2 as (T, T) and (T, F). Across all four days, the reversed rule is T, T, F, T. The Monday Quick Check uniquely implies late and no note. The lead's same-kind ruling applies to that check. Pair evidence matches 0006 and 0007. Recomputed all 3 linked quiz keys.

## combined-truth-values.md

Blocker | combined-truth-values.md:48 | The rule says a negation without parentheses covers only the letter beside it. In the double negation taught above and tested in quiz 0003, the first NOT sits beside another NOT and flips that inner expression's result. | Say “A NOT flips the statement that follows it. If another NOT comes next, work from the inside out. Parentheses can make a whole group the statement to flip.”
Major | combined-truth-values.md:37 | The same display line evaluates the inner group and applies the outer operation. This also occurs at lines 38, 52, and 53. These are successive moves. | Show the evaluated inner value on one line and the result of the outer operation on the next.
Major | combined-truth-values.md:43 | The cited 0012 choice regroups the first expression as the second. Merely dropping the first parentheses would leave the AND-first evaluation and would still give T. | Show the Wrong evaluation as P and (Q or R) for both expressions, then explain which grouping was moved.
Minor | combined-truth-values.md:117 | Example 4 repeats the same inner conditional with the same inputs as Example 3, reducing coverage across the two examples. | Change one of the inputs in Example 4 and recompute its three values.

Recomputed the Core Concept results as (T, F) for each pair. Examples 1 to 4 give (F, T, F), F, T, and (F, T, T). The Quick Check gives T. The try supplies the two group results and leaves the outer OR as the new last step. Evidence 0003 and 0013 matches, and 0012 needs the more precise Wrong explanation above. Recomputed all 12 linked quiz keys.

All 41 linked quiz keys were recomputed. No question-file Blockers found. The six figures were checked against their lesson markers. The parser, export, lesson checks, and SVG preflight use the lead's supplied results.

BATCH VERDICT: FAIL (5 Blockers, 15 Majors, 2 Minors)
STAGE-DONE
