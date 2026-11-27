# Three live content fixes for the launch-day content upload (CSE release lead r10, E-203)

Nov 27, 2026. Branch `content/cse-question-fixes-r1`, on 22b8ccc2f. Policy main 890325dee.
Source: the manager's r10 brief (all three confirmed by the manager on 22b8ccc2f). Agent findings,
not Aedwon's request.

## Manager's words (verbatim, r10 brief)

- (a) "Question q-grammar-and-structure-pronoun-antecedent-agreement-0005 gives its answer away
  (manager confirmed it on 22b8ccc2f). Its stem says 'not its individual members' and 'the pronoun
  referring to its policy' before asking for the blank, whose key is 'Its'. Fix the stem only,
  through the question process (blind solve, approve.dart), on content/cse-question-fixes-r1. The
  key stays."
- (b) "Question q-language-application-sentence-completion-0028 ... the stem does not force a
  contrast, so 'dahil' or 'sapagkat' also reads ('Ipinagpatuloy ang pagpupulong dahil hindi pa
  dumarating ang ulat'). Fix the stem only, through the question process: state that the missing
  report was expected to stop the meeting, and ask for the connector that shows they continued
  despite it. The key 'ngunit' stays."
- (c) "Live lesson content/lessons/reasoning/spatial-abstract-reasoning/figure-turns-and-positions.md,
  Example 3 'Growing Turns' ... teaches a false rule (manager confirmed). The arrows up,
  upper-right, lower-right, lower-left turn 45, 90 and 90 degrees, but the solution says 45, 90 and
  135 and answers upper-right. Delete Example 3 and its illustration marker from the live lesson,
  renumber the example references in that lesson (its trap text cites 'Example $6$'; make every
  reference point at an example that exists), run the lesson checks, and add the removed figure to
  the figure worklist. Do not invent a replacement example."

## Changes

| Item | Before | After |
|---|---|---|
| (a) pronoun-antecedent-agreement-0005 stem | Treat the company as one organization, not its individual members. Choose the pronoun referring to its policy: "The company announced ___ new policy yesterday." | Treat the company as one organization acting as a unit. Choose the pronoun that refers to the company: "The company announced ___ new policy yesterday." |
| (b) sentence-completion-0028 stem | Piliin ang angkop na pang-ugnay: "Ipinagpatuloy ang pagpupulong ___ hindi pa dumarating ang hinihintay na ulat; taliwas ito sa inaasahang pagpapaliban." | Inaasahang ipagpapaliban ang pagpupulong kapag wala pa ang ulat. Piliin ang pang-ugnay na nagpapakitang itinuloy ang pulong sa kabila nito: "Ipinagpatuloy ang pagpupulong ___ hindi pa dumarating ang hinihintay na ulat." |
| (c) figure-turns-and-positions.md | Example 3 "Growing Turns" with its illustration marker and solution (45, 90, 135 degrees; answer upper-right); a stray editor line under Core Concept ("The trap calls this Example $6$ from the original lesson; it is Example $3$ here."); trap: "Others use growing turns, as in Example $6$." | Example 3, its marker and the stray line deleted. Trap: "Some series use equal turns, as in Example $1$. Others use growing turns." Examples 1 and 2 unchanged. No replacement example. |

The retired parent `figure-series.md` (status retired, replaced by the three parts) carries the
same example as its #6, and `lesson_checks.dart` fails a part that drops a parent block
("lesson-spatial-abstract-reasoning-figure-series: missing: ### Growing Turns ..."). The parent gets
the same cut: #6 Growing Turns and its marker deleted, #7 Two Mixed Patterns becomes #6, the trap
line matches the part. Its figure 07 (the arrows) is deleted and 08 is renamed 07, so files keep
matching marker order (README invariant). The parent is not served.

Found, not fixed (outside this brief): the live part `combined-and-mixed-figure-patterns.md` line 21
carries the same kind of stray editor line ("The trap calls this Example $4$ from the original
lesson; it is Example $1$ here.") and its trap line 68 cites "Example $4$", which is its Example 1.

Keys, choices, rationales and explanations are unchanged in (a) and (b). In (a) the stem keeps the
one-unit convention, which the "Their" note relies on ("follow the stated one-unit convention"),
and matches sibling 0006 ("Treat the class as one unit"); the word "its" no longer appears in it.
In (b) the stem now states that the missing report was expected to postpone the meeting, so a
cause reading ("dahil", "sapagkat") no longer fits.

## Removed figure

The lesson's fourth marker is gone: "arrows pointing up, upper-right, lower-right, and lower-left in
four equal frames, followed by a blank; choices arrows pointing down, up, upper-right, and
upper-left; do not label turn angles", drawn as
`content/illustrations/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/04-arrows-pointing-up-upper-right.svg`.
It is the last marker, so no other figure of the lesson renumbers. Both figure worklists
(`docs/content/illustrations/worklist.tsv`, `docs/content/question-figures/worklist.tsv`) are
generated from markers and question files ("No manual editing"), and the illustration inventory
check fails on a worklist row missing from its manifest, so the removed figure is recorded in the
"Removed figures" list of `docs/content/illustrations/README.md` instead.

## Independent blind solve (key, explanation and notes hidden; choices reordered)

One Sonnet 5.5 solver, given only the two new stems and shuffled choices.

| Question | Blind solve | Key | Second defensible answer | Verdict |
|---|---|---|---|---|
| pronoun-antecedent-agreement-0005 | Its | Its | none ("Their" only in informal or British usage, ruled out by the stem) | AGREE |
| sentence-completion-0028 | ngunit | ngunit | none ("dahil", "sapagkat" would make the missing report the reason the meeting went on) | AGREE |

The solver said both stems point at the answer: (a) through "one organization acting as a unit",
(b) through "sa kabila nito". Lead ruling: kept. Neither stem contains a choice's word; both state
the condition the item tests, which the brief asked for in (b) and which the corpus uses for
collective nouns in (a) (0006). The original defect in (a) was the key word "its" printed twice in
the stem.

## Checks (main 890325dee tools, root this branch)

- `dart run tool/content/approve.dart --root <branch>/content --ids <2 ids> --evidence <this file>`:
  both approved, exit 0.
- `dart run tool/content/lesson_checks.dart --root <branch>/content`: exit 0 (exit 1 before the
  parent was cut, on the three missing Growing Turns blocks).
- `dart run tools/import_questions/import_questions.dart --root content/questions/language-proficiency`:
  exit 0. Em dashes in the four touched files: 0.
- `python3 tools/audit/run_all.py`: 618 errors on 22b8ccc2f, 616 after; the two fewer are the
  removed markers. All are the illustration audit's existing marker-inventory errors; none new.
