# Brief: Math pilot fixes after Codex read 1 (E-204)

Read `docs/content/verification/walkthrough-work/pilot-slim-brief.md` in full first. All of its rules, hard limits, checks
and assignments (Writer A and Writer B, the same five lessons each) still apply. This brief adds the fix round.

Findings: `docs/content/verification/walkthrough-work/codex-math-pilot-r1.md` (Codex read 1, FAIL 3 Blockers, 44 Majors).
Fix every Blocker and Major row for your five lessons, by pattern across the whole lesson, not only the line named. Then
re-read each lesson top to bottom once as a student and check that no new problem of the same kind remains. Minors: leave
them unless the fix of a Major touches the same line.

Not yours: the two `content/questions/**` Blockers (the release lead gets them). Do not edit question files.

## Patterns and the lead's rulings

1. One move per display line (spec rule 2). Split any display line that does more than one move: one conversion, one
   operation, or one simplification per line, each line ending at its value. Start each chain from its expression; a
   display line does not start with a word label ("Discount $=$ ..."); the lead-in names the quantity. Keep it to the moves;
   no narration between them.
2. Lead-ins. Every worked example, worked line in Core Concept ("Try this ...", "Suppose ...") and pair setup says in one
   short sentence what we find and from what, before the numbers. Example: "Find Maya's age from the total and the gap."
3. Pairs in context. A pair sits at the step whose mistake it shows, uses that step's numbers where the cited mistake
   allows, and otherwise opens with a one-line setup naming the problem. Do not switch stories inside a pair.
4. Rule scope. Add the condition the finding names, in a few words: percents "by volume" in mixture rules and prompts;
   "steady rate" and "each worker alone" for work rates, and rate addition for any number of workers; a positive starting
   value for ordinary percentage change (keep the zero case); later minus earlier for an increase over time, with a negative
   result showing a fall; a target halfway between two concentrations takes equal amounts; "If you know the rate as a
   percent, write it as a decimal or fraction before you multiply or divide by it"; simple interest on a fixed principal.
5. A check or try must test a step the lesson shows. Either add one short worked line that shows the step (with other
   numbers), or change the check. Mixture: show "concentration = pure amount / total" once. Simple interest: show a decimal
   rate written as a percent once, before the try.
6. Checks too close to the pair above (decimal-and-percent line 52, simple-interest line 79): rewrite the check so the
   student makes a different taught decision (for example, the decimal check gives a fraction and asks for the decimal; the
   simple-interest check asks for the time or the rate from the other values). Same rules as before: fresh numbers, key not
   printed above or in its stem, one answer, re-solved by you.
7. Skills the linked quiz asks that the lesson never shows (discounted reverse price, percentage points, combined growth
   from starting amounts and rates, a missing table entry from a total, a payment that first covers interest, the discount
   offer conditions): manager ruling, Nov 27 evening: add one only if it fits as a short rule with one example, in the rule
   section it belongs to, with numbers not used by any quiz question, and the lesson stays at or under 900 words before a
   tap. Otherwise do not add it; list it in your report "for later". This pilot proves the format, not new teaching.
8. Lead ruling, no change: the three rows that say a pair's Wrong line uses other numbers than the cited wrong choice
   (discounted line 63, percentage-base line 81, identities line 89). A pair shows the same mistake as the cited choice;
   the citation lives in `content/walkthrough-trap-evidence.json`, and a note to the student about the quiz would be noise.
   The lead's brief told Codex to expect a note; that was the lead's error.
9. Blocker, discounted-prices line 150: end the numeric chain at $28$, then say in words that this is a $28\%$ single
   discount. Check every other chain in your lessons for the same slip (a value set equal to a percent).
10. Wordiness rows (mixture line 38, discounted line 71): cut as the finding says.

Words before a tap stay at or under 900. New lines for patterns 5 and 7 may add words; everything else should cut. Report
words before and after.

## Report (short, under 350 words)

Per lesson: each row fixed how (one line) or why not; new or changed checks and tries with your re-solve; every new number
you added with its arithmetic; words before and after; the three checks' output lines for your lessons.
