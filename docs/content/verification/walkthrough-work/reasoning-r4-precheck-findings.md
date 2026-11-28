# Blind pre-check and recompute, R4 verbal logic (E-216, step 3)

Worktree commit: 0da5cab88 ("R4: four verbal logic lessons slimmed to one Quick Check and one try; demos no longer reuse linked quiz items").
Policy read from origin/main (AGENTS.md, WORKFLOW.md, SUBAGENTS.md). Briefs: reasoning-r4-precheck-brief.md over reasoning-r1-precheck-brief.md.
Lessons: 4 under `content/lessons/reasoning/verbal-logic/`. Questions read: all 30 lines of `assumptions-and-conclusions.yaml` whose `lesson:` is one of the four (needed 10, negating 6, must-be-true 8, none-and-may 6).
Each lesson has exactly one `:::check` and one `:::try`. No pictures. No em dashes. No British spelling.

Blind answers (solved with the answer covered, then compared): checks needed B, negating C, must-be-true C, none-and-may C. Tries needed C, negating C, must-be-true C, none-and-may C. All eight keys match mine. Every demo, pair, example, check, try and checklist verdict re-derived: no wrong key.

Pair ruling needed: the brief lets a pair keep a quiz's cited wrong choice. Every pair in lessons 1 to 4 also copies the quiz's passage and correct answer word for word (listed once per lesson below). I scored these Major under a strict reading. If the manager rules that whole-item pairs are allowed, downgrade them to Minor.

Format: Severity | file:line | item | what is wrong | suggested fix

## needed-assumptions.md

Major | needed-assumptions.md:45-58 | Core demo and pair #helpful-not-needed (art-room lamps) | Same argument, correct answer and wrong choice as quiz 0017 (library reading-room lamps: "replacement lamps will provide usable light" right, "more energy-efficient" wrong). Only the room and the verb changed. The pair may keep the wrong choice; the demo and the Right line may not. | Change the demo to a different gap (for example a plan that needs a supply, not light) and keep only the quiz's wrong choice in the pair.
Major | needed-assumptions.md:109-127 | Example #3 and its try (breakfast program) | Re-skin of quiz 0008 (landfill program). Same conclusion "caused at least some", same three choices in the same roles (largest change = "only thing that changed", "attendance rose after" = "landfill fell after", "other changes did not cause all" = key). The try answer is the quiz answer. | Use a different causal gap, for example an argument whose needed assumption is a link between steps, not "other changes".
Major | needed-assumptions.md:99-107 | Example #2 lead-in | "Decide whether [promise] assumes [electronic tracking]" gives no argument and no stated reason, yet step 2 of the lesson's test is "test the negation against the stated reason". Step 2 of the solution uses outside facts (paper forms). | Give a short argument with a stated reason, then ask whether the assumption is needed.
Major | needed-assumptions.md:68-78 | Check (ramp) | Solvable by elimination from printed rules: (A) is the "every" trap from the pair at 60-66, (C) is a plainly unrelated bonus from the pair at 54-58. (B) is the only choice no printed rule rejects, so the negation test is not needed. | Make the wrong choices need the negation test, for example a "some" version of the extreme choice and a bonus that sounds needed.
Minor | needed-assumptions.md:60-66 | Pair #extreme-universal-claim | Right answer is a paraphrase of quiz 0002's key ("some car trips shift"); Wrong is quiz 0002's wrong choice verbatim (allowed). | Optional: reword the Right line.
Minor | needed-assumptions.md:29-33 | Pair #premise-as-conclusion | Passage says "customers"; the Wrong line says "workers" and copies quiz 0019's wording. | "Wrong: Many customers work on weekdays."
Minor | needed-assumptions.md:37 | "A necessary assumption does not prove the conclusion alone" | Stated as a general rule; an assumption can also be enough alone in a short argument. | "...usually does not prove the conclusion alone."
Minor | needed-assumptions.md:77 | Check answer | Says "pupils"; the check says wheelchair users. | Use "wheelchair users".
Minor | needed-assumptions.md:99 | Example #2 title | "Helpful but Not Necessary" but nothing is shown as helpful. | Retitle "An Unneeded Assumption".

Counts: Blocker 0, Major 4, Minor 5.

## negating-assumptions.md

Major | negating-assumptions.md:36-40, 54-58, 70-74 | Pairs #all-to-none-overnegation, #some-to-not-all, #flip-wrong-group | Each copies quiz 0022, 0021 and 0040 word for word (passage, Right and Wrong). Only the Wrong choice may be kept. | Keep the quiz's wrong choice; change the passage and the Right line.
Major | negating-assumptions.md:124-144 | Example #3 and its try (field-trip slips) | Re-skin of quiz 0050 (forms with parent signature). Same structure "every X had at least one Y", same distractor set (No X had one = too far; one-signature case = still meets), same key "an X had none". | Change the structure, for example nest "some" inside "every".
Major | negating-assumptions.md:76-85 | Check (Room 4) | Same form as the locker demo at 26-30 with values swapped, and the template "All A are B negates to At least one A is not B" is printed at 23. The answer is a direct substitution. | Use a form no demo shows, for example "No Room 4 student missed the quiz".
Minor | negating-assumptions.md:107-122 | Example #2 | Same shape as pair #some-to-not-all and quiz 0021 ("some can" negates to "none can", "not every" wrong). | Optional: change the quantifier trap.
Minor | negating-assumptions.md:32-34 | Why block | "both 'none passed' and 'all passed' are false" is hard to read: neither is the exact negation of the other. | "Half pass, half fail: 'all passed' is false and 'none passed' is also false, so 'none' cannot be the negation of 'all'."
Minor | negating-assumptions.md:146-148 | Speed trick | The lesson never shows "some A are not B" negating to "all A are B", the form quiz 0031 needs ("at least one receipt lacks a signature"). The pairing "some pairs with none" solves it but only if the student rewrites "lacks a signature" as a property. | Add one line for "some are not".

Counts: Blocker 0, Major 3, Minor 3.

## must-be-true-conclusions.md

Major | must-be-true-conclusions.md:28-32, 45-49, 76-79 | Pairs #one-requirement-to-all, #reverse-or-deny-rule, #some-means-some-not | Each copies quiz 0003, 0007 and 0013 word for word (passage, Right, Wrong). | Keep the quiz's wrong choice; change the passage and the Right line.
Major | must-be-true-conclusions.md:84-100 | Example #1 (science club microscope) | Re-skin of quiz 0011 (licensed engineers). Same "only X may do Y; person did Y within the rule", same distractors (every member did it; owns something), same key. | Use a different gap, for example "only X may" with a person who did not act.
Major | must-be-true-conclusions.md:112-131 | Example #3 and its try (cart, labeled, novels) | Re-skin of quiz 0039 (specimens, cataloged, shells). Same premises, same choices in the same roles ("other than a shell" = "not a novel"), same key. | Use a different pair of quantifiers, for example "No" plus "some".
Major | must-be-true-conclusions.md:51-61 | Check (guards, badge) | The key (C) "may or may not" has the same form as the pair directly above ("undetermined"), and the rule "it does not run backward" is printed at 36. A student copies the "undetermined" pattern without reasoning. | Make the deciding feature different, for example an "only" rule where the answer is a definite statement.
Minor | must-be-true-conclusions.md:104-110 | Example #2 | Parallel to quiz 0009 (cutoff, score meets it). The boundary difference ("at least 75" with 75) is the only change. | Optional.
Minor | must-be-true-conclusions.md:142 | Checklist | "(or after the result)" is unclear; it means affirming the rule's result. | "Outside an *all* group, or with only the result known: leave status undetermined."

Counts: Blocker 0, Major 4, Minor 2.

## none-and-may.md

Blocker | none-and-may.md:66-76, line 52 | Check (picnic) | The answer (C) "The notice makes no promise about the place" is printed at 52: "When its condition is absent, the sentence promises nothing." The key's own reason repeats that line. Copyable from a visible line above. | Rewrite the check so the deciding fact is not printed (for example the condition is present and the question asks what is certain), and trim line 52.
Major | none-and-may.md:52 | Rule "may means possible, not permission" | Scoped "in these questions", but must-be-true Example #1 (line 86) says "Only science club members may borrow", where "may" is permission and the key depends on that. Quiz 0011 uses "permits only". Counterexample inside the same topic. | "In a sentence like 'X may happen if Y', *may* means possible. After 'only', it means permitted."
Major | none-and-may.md:28-32 | Pair #reverse-none-rule | Drops the quiz's premise "Every vehicle inside was admitted in full compliance". Without it, "Vehicle A is inside" does not force "Vehicle A is registered" (an unregistered vehicle could be inside against the rule), so "must" fails. | Add "Every vehicle inside was admitted under that rule."
Major | none-and-may.md:28-32, 44-48, 60-64 | Pairs #reverse-none-rule, #stretch-some-to-none, #may-to-must-certainty | Each copies quiz 0006, 0052 and 0025 word for word. | Keep the quiz's wrong choice; change the passage and the Right line.
Major | none-and-may.md:90-98 | Example #2 (clinic may open Monday) | Re-skin of quiz 0043 (health center "may resume Friday", host "will resume"). Same key "the host made it sound certain". | Use a different pair (for example "may" compared with "can't") or drop the quiz's two-speaker setup.
Minor | none-and-may.md:118-122 | Try, choice (B) | The key rejects (B) because the premises never say an under-18 volunteer exists. A fair reader of "No volunteer under 18 is a driver" may assume such volunteers exist. The lesson never states that "no" claims do not guarantee members. | Add "A *no* statement does not say the group has members" to the Core Concept.
Minor | none-and-may.md:100-122 | Example #3 | Same form as pair #stretch-some-to-none (no X is Y; some Z are X) with nouns changed. | Optional.

Counts: Blocker 1, Major 4, Minor 2.

## Notes (no finding)

- Example #3 in each lesson stops after dropping one choice by design; the try finishes it. Not counted.
- Rules tested with one counterexample each ("some", "all", "none", "may", "must", "needed", "negation"). Every quiz line of the four lessons (30) is consistent with the lessons' rules except as listed above (none-and-may line 52 against must-be-true Example #1).
- Math notation, `\dfrac` use and dollar delimiters fine. No fractions present.

## Verdict

FAIL. 1 Blocker (none-and-may check). Majors: needed-assumptions 4, negating-assumptions 3, must-be-true-conclusions 4, none-and-may 4 (15 total; 6 of them are pair-reuse or re-skin rulings the manager may downgrade).
