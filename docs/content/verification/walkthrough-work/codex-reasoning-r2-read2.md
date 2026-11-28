# R2 logic walkthrough audit, final read

Target `f2d147248` on `content/walkthrough-reasoning-r1`. Policy from local `origin/main` at `0e242ee38`. Lesson, question, trap evidence, and SVG references use the target blobs. Quiz IDs below use their bank suffixes.

## deductive-group-arguments.md

Major | deductive-group-arguments.md:38 | The parenthetical “Not all” can read as a second conclusion that some submitted reports are unsigned. The premises leave that open. | Say “The premises do not tell us whether all submitted reports are signed.”
Major | deductive-group-arguments.md:63 | The invalid dog argument says the premises do not force Dogs inside Mammals, but skips the circle placement that shows why. | Put the two smaller circles side by side inside Animals. Point out that both premises still hold and the conclusion fails.

Recomputed the report overlap, invalid dog argument, lemon verdict, whale and penguin examples, snake check, and permit-holder try. The check forces snakes away from the fur group. The try forces at least one permit holder outside the licensed group. The lemon pair now distinguishes the two soundness and validity errors in 0007. The other pairs match 0001, 0002, and 0008.

Figures 01 to 03 match their markers. Figure 01 shows containment, separation, and a witness in the overlap. Figure 02 puts the whale in both groups. Figure 03 puts the penguin in both groups under the stated premises and labels the outer circle “Can fly.” None shows a check or try key.

Recomputed all 10 linked quiz keys. No question-file Blockers found.

## valid-conditional-forms.md

Major | valid-conditional-forms.md:39 | “Because real pumps fail” does not show the cited mistake. A pump failure fits the conclusion that the pump was not working. The distractor imagines the result could fail while the condition still holds. | Give a concrete outside exception, such as imagining a working pump leaving the tank empty because of a leak.
Major | valid-conditional-forms.md:140 | “Follow arrows one way” can be read as forbidding backward deductions, which the same shortcut teaches. | Use “Follow each rule forward or work backward by denying its result.”

Recomputed the two basic forms, both directions of the parcel chain, the key location, and Examples 1 to 3, all valid. The check forces the ticket to be unstamped. The try rules out complete records. Both a sent and an unsent decision fit. The pump pair now gives the conclusion and cites 0005 alone. The reverse-chain and location pairs match 0017 and 0018. The backward parcel steps and original-document wording are fixed.

Figure 01 nests working alarms inside ringing alarms and puts the tested alarm outside both. Its label now matches the stem. Figure 02 hatches the whole Cabinet A region, including the overlap, and puts the document in the B-only region. Neither shows a check or try key.

Recomputed all 7 linked quiz keys. No question-file Blockers found.

## invalid-conditional-forms.md

Major | invalid-conditional-forms.md:59 | The entry-log example uses $P$ as the door's name and as the statement about using that door. The shared label obscures what “not $P$” means. | Name the door “Door A” and map $P$ to “used Door A” and $Q$ to “is listed in the log.”

Both prior Blockers are closed. At line 59, the entry-log rule makes a missing name imply the person skipped the door. A person who skipped it can still appear in the log. At lines 102 to 117, the rule and claim both use boarding permission. Options 1 and 2 satisfy both rules, Option 3 violates the original rule, and only Option 4 satisfies the rule while breaking the claim.

Recomputed the two invalid forms, the access-card and rain demonstrations, and all three examples. The locked-door check is valid by denying the result. Both pairs match their cited choices in 0003 and 0004, including the separate error of rejecting the given no-rain premise. Figure 01 places Maria in the pass circle and outside the study circle, marked as one possible placement. It matches the text and gives no check or try key.

Recomputed all 3 linked quiz keys. No question-file Blockers found.

## truth-tables-and-connectives.md

Major | truth-tables-and-connectives.md:28 | The row repair puts the repeated pair, missing pair, and replacement in one paragraph. These are successive moves. | Give the list first, then give each move its own line.
Major | truth-tables-and-connectives.md:94 | Example 1 asks the reader to build a table, then ends with an output list that leaves the inputs implicit. | Use four labeled list rows. Show each $(P,Q)$ input pair next to the two connective results.
Major | truth-tables-and-connectives.md:105 | Rina's example substitutes the values and evaluates OR in the same display line. | Write the substituted expression on one line and its value on the next.
Major | truth-tables-and-connectives.md:111 | Example 3 asks for the result in each row. The visible steps complete that task, and the try introduces a different question about how the results compare with $P$. | Ask for both the row results and the comparison in the original stem.
Major | truth-tables-and-connectives.md:133 | “One true input” could include a known true input with the other input still unknown. That alone cannot settle AND. | Say “Exactly one true input in an AND: the other input is false, so the result is false.”

The prior Blocker is closed at line 28. Only $(F,F)$ is missing, and either row 2 or row 4 can be replaced. Recomputed both connective rules and all four result pairs, $(T,T)$, $(F,T)$, $(F,T)$, and $(F,F)$. Rina's statement and the Joy check are true. The try still requires comparing the two outputs with $P$. Its answer is that the output equals $P$ in both cases. All three pairs match 0021, 0002, and 0001. The closing ordered pairs at line 94 are in inline math.

Recomputed all 6 linked quiz keys. In 0021, only one of the offered corrections works. No question-file Blockers found.

## conditional-truth-values.md

Major | conditional-truth-values.md:72 | The swap demo and the first two examples substitute inputs and evaluate the conditional in the same line. This occurs at lines 52, 53, 72, 74, 87, and 89. | Show the substituted conditional first and evaluate it on the next line. The two directions can be shown in parallel at each move.

The prior Blocker is closed at lines 95 to 107. The visible rows give forward and reverse results of $(T,T)$, $(F,T)$, $(T,F)$, and $(T,T)$. The try asks the reader to compare those values. Only Days 2 and 3 differ, and that comparison is hidden.

Recomputed the four basic cases, the swap demonstration, and Examples 1 and 2 as $(T,T)$ and $(T,F)$. The Monday check uniquely gives late and no note. The lead's same-kind practice ruling applies. Both pairs match 0006 and 0007, and the revised medal heading identifies the forward direction correctly.

Recomputed all 3 linked quiz keys. No question-file Blockers found.

## combined-truth-values.md

Blocker | combined-truth-values.md:60 | The Why block still gives the general rule that a NOT inside parentheses flips only the letter beside it. In $(\neg\neg P) \land Q$, the first NOT inside the parentheses flips the value of $\neg P$. It can also be followed by a group. | Tie the explanation to the written forms. In $\neg(P \land Q)$ the NOT flips the group's result. In $(\neg P) \land Q$ it flips $P$.
Blocker | combined-truth-values.md:126 | Steps 1 to 3 already give $F$ and $T$. The only remaining move is the exact outer OR printed at lines 38 and 45, $F \lor T = T$. All three requested values can be copied. | With $P=T$ and $Q=F$, show the full expression's result for both values of $R$. Fade the comparison that the full expression always equals $R$ in those cases.
Major | combined-truth-values.md:85 | The basic negation demo, Example 1, and later examples still combine substitution and evaluation on one line. This occurs at lines 23, 25, 85, 87, 89, 99, 100, and 110. | Show the substituted expression first, then evaluate it on the next line.

The revised core rule at line 50 correctly covers a single statement, stacked NOTs, and a whole group. The scope Blocker stays open because the Why block gives the narrower rule as a general claim. The checklist cue at line 140 names the two specific forms.

Recomputed the three Core Concept pairs as $(T,F)$ each. Examples 1 to 4 give $(F,T,F)$, $F$, $F$, and $(F,T,T)$. The check gives $T$. The regrouping pair now explains the moved parentheses and matches 0012. The other pairs match 0003 and 0013. Example 3 and Example 4 now use different input pairs for the conditional.

Recomputed all 12 linked quiz keys. No question-file Blockers found.

## Final tally

Audited six target lessons, six SVGs, 16 trap pairs, and 41 linked quiz keys. Four of the five prior Blockers are closed. The fifth fix corrects the main negation rule, but the Why block still teaches the bad scope rule. The last-step giveaway in the same lesson is a separate Blocker.

The parser, lesson checks, export, and SVG preflight results come from the lead's record. No Dart or Flutter commands were run.

BATCH VERDICT: FAIL (2 Blockers, 12 Majors, 0 Minors)
STAGE-DONE
