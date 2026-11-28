# R2 blind pre-check and recompute: findings

Worktree commit: `b010980eb` (R2: six logic lessons slimmed to one Quick Check and one try; three-statement circle picture drawn). Policy read from `origin/main` (AGENTS.md, SUBAGENTS.md). Brief: `reasoning-r2-precheck-brief.md` (R1 brief rules applied).

Lessons are under `content/lessons/reasoning/logical-verbal-reasoning/`. Pictures are under `content/illustrations/reasoning/logical-verbal-reasoning/`.

Blind answers (solved before reading each key; all six checks and six tries match the keys):

| Lesson | Check (my answer) | Try (my answer) |
|---|---|---|
| deductive-group-arguments | No snakes have fur | Some permit holders are not licensed drivers |
| valid-conditional-forms | Ticket is not stamped (modus tollens) | Records not complete; nothing forced about R |
| invalid-conditional-forms | Valid (result denied) | Option 4 |
| truth-tables-and-connectives | True (ruler packed) | Result matches P (F or F = F) |
| conditional-truth-values | Late pupil, no note (T to F) | T, T, F, T |
| combined-truth-values | T | F, T, T |

Second-answer test: none of the 12 has a second defensible answer. Exclusive "or" gives the same result on the truth-tables check (exactly one part true). The combined check gives T under a "not (P or Q)" reading as well.

Every truth value, table row, syllogism and conditional verdict was recomputed. No arithmetic or logic error was found in any lesson, key or picture.

## Findings

Severity | file:line | item | what is wrong | suggested fix

Major | conditional-truth-values.md:41 | Quick Check | Answer is the line-28 fact with values swapped. Line 28 prints "The only false case is T to F (room cleaned, no ice cream)". The check asks for the same "if X then Y, false" pattern in a school-note setting. A student can copy the pattern without evaluating anything. My solve: late and no note, found by pattern match alone. | Ask something that needs evaluation, for example give "P is false" and ask for P to Q, or give a three-case story and ask which case breaks the rule.

Major | conditional-truth-values.md:103 (and 78 to 91) | Try, reused instance | Example 2 uses P=F, Q=T and prints Q to P = T to F = F (line 89). Example 3 row 3 is the same case, same value. Row 4 value (F to F = T) is printed at line 26. Rows 1 and 2 are given. So all four values of the key are already visible above the try. My recompute: T, T, F, T, all four seen on the page. | Change Example 2 to a case that is not (F, T) (for example P=F, Q=F), or make the try column a new one such as P to Q with Q negated (needs a negation intro, so prefer the first fix).

Minor | combined-truth-values.md:113 (and 102 to 106) | Example 4 repeats Example 3 | Example 4 uses P=T, Q=F, and its first group P to Q = T to F = F is the same computation as Example 3. | Use a different pair of values for Example 4, for example P=F, Q=T, R=T (recompute the key).

Minor | combined-truth-values.md:121 | Try | Two of the three key values (F at line 117, T at line 119) are printed above; only the last value needs work. Matches the "finish the last step" design, so not a Major. | Accept, or ask for the full expression only.

Minor | truth-tables-and-connectives.md:28 | Core Concept worked row | "Find the row that must change" is not unique. Row 2 or row 4 can be the one replaced. The text names row 4 as if forced. | Say "a repeated row" and show replacing either one.

Minor | truth-tables-and-connectives.md:72 | Quick Check | The lesson shows only two-part "or". The check uses three parts. The rule "at least one" still covers it. | Optional: add "or more parts" to the rule line at 48.

Minor | truth-tables-and-connectives.md:15, conditional-truth-values.md:14, combined-truth-values.md:15 | Format | No blank line between the front matter and "## Core Concept". The other three lessons have one. | Add the blank line.

Minor | valid-conditional-forms.md:65 | Pair explanation | "Follow the arrows in one direction only" conflicts with the lesson's own backward use of "not" (modus tollens, line 53, and the checklist at 145). | "Do not turn an arrow around without 'not' and without reversing it."

Minor | valid-conditional-forms.md:81 | Pair wording | "a file ... the original" switches nouns. | "the file is in the vault".

Minor | invalid-conditional-forms.md:117 | Try key | "the visitor boards" switches from "boarder" and "pass" used in the item. | "the passenger boards".

Minor | invalid-conditional-forms.md:122 | Speed trick | "one everyday exception" can be read as the outside exceptions that valid-conditional-forms.md:40 tells students not to add to a rule. | "one case where the premises are true and the conclusion is false".

## Rule-claim tests (step 3)

I tested every "valid", "sound", "some", "only if", "unless", "either ... or", "if", "all", "only", "never" and "must" claim against a counterexample. None fails. Items checked: "forced only if every picture fits" (line 31, holds); "Some A are B says nothing about the rest of A" (holds); "even if or allows both, ruling out one forces the other" (holds under inclusive or); "A form is invalid when premises can be true and conclusion false" (holds); "only T to F is false" (holds); "a negation with no parentheses covers only the letter beside it" (convention, used consistently). No exclusive-or reading changes any key.

## Pictures

| Picture | Verdict | Notes |
|---|---|---|
| deductive-group-arguments/01 (three statements) | OK | Recomputed geometry: A inside B (centers 18 apart, radii 24 and 50); A and B apart (60 apart, radii 24 and 24); A and B overlap (48 apart, radii 32) with the X inside the overlap lens (x 294 to 306 within 292.6 to 307.4). Labels and captions match the bullets. No key shown. |
| deductive-group-arguments/02 (mammals, whale) | OK | Mammals inside Warm-blooded, whale point inside Mammals. Matches Example 1. |
| deductive-group-arguments/03 (birds, penguin) | OK, 1 Minor | Birds inside the larger circle, penguin inside Birds. Minor: outer label reads "Can fly as the first premise assumes", the text beside it says "Can fly" (lines 105 to 107). The extra words mark it as an assumption, so keep or shorten. |
| valid-conditional-forms/01 (alarms) | OK, 1 Minor | Working circle inside the ringing circle, tested alarm outside both. Matches "not ringing, so not working". Minor: label says "working properly under these conditions", text says "working under these conditions". |
| valid-conditional-forms/02 (cabinets) | OK | Hatch covers all of circle A including the overlap, document sits in the B-only region (center 266,147 is 136 from A, 36 from B). Matches Example 3. |
| invalid-conditional-forms/01 (Maria) | OK | Study-hard circle inside pass circle, Maria in the pass circle and outside the smaller one, marked "Possible placement". Matches Example 1. No check or try key shown. |

No picture shows a relation wrongly, contradicts its text, or gives away a check or try key.

## Counts

- deductive-group-arguments: 0 Blocker, 0 Major, 0 Minor in text (picture 03: 1 Minor)
- valid-conditional-forms: 0 Blocker, 0 Major, 2 Minor in text (picture 01: 1 Minor)
- invalid-conditional-forms: 0 Blocker, 0 Major, 2 Minor
- truth-tables-and-connectives: 0 Blocker, 0 Major, 3 Minor
- conditional-truth-values: 0 Blocker, 2 Major, 1 Minor (format)
- combined-truth-values: 0 Blocker, 0 Major, 3 Minor (two items plus format)
- Pictures: 0 Blocker, 0 Major, 2 Minor (deductive 03, valid 01)

Totals: 0 Blocker, 2 Major, 12 Minor.

Verdict: PASS (0 Blockers). Two Majors in conditional-truth-values.md should be fixed before sign-off.
