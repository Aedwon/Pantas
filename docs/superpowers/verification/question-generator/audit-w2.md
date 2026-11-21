
# Task 1.4 sheet-fix re-audit, worker w2

Policy: origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, descendant of 1295c1866. Read AGENTS.md, WORKFLOW.md and SUBAGENTS.md from that ref. Scope: 13 assigned matrix types, read-only; this audit file is the only write target. Root FINDINGS.md and velocity edits are superseded by this explicit assignment.

Needs the lead: git fetch origin main failed because the sandbox cannot write the shared Git FETCH_HEAD. The requested origin/main policy is readable and meets the minimum revision; continuing with that supplied ref.

Candidate: HEAD 73bca376ac013e41e24ab4bbb6c4ad9a9163a1c1, initially clean. Network freshness check also failed: git ls-remote origin cannot resolve github.com. Prior fix-sheet-findings records a size-dots hold, but the actual candidate has size-dots active with 55 variants. This corrects the earlier progress update. Audit follows candidate source; the lead owns resolution of the historical floor discrepancy.

qt-spatial-abstract-reasoning-matrix-ray-intersection | Blocker | The four cardinal-extreme counterexamples from audit-r2 are gone, but diagonal directional selection still gives a different offered answer. At index 43 the example inputs contain SW+NE and SW+S, and output SW. Keeping the ray closest to lower-left explains that row just as simply as intersection. Target inputs W+SE and W+SW then select SW under the same rule, exactly second-exclusive, while the key is W. Both selections are unique, and row outlines stay unchanged. Independent eight-direction projection scan finds NE cases at 1,39,60,70,73,76; SE at 14,19,20,26,30,31,36,55,56,74,79,85,92; SW at 43,57,91; NW at 42,49,84,98. No N/E/S/W competing wrong answer remains. The generator and independent library test only the four cardinal projections. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.variants.yaml, index 43 (also lists above); tool/generator/lib/src/rules/figure_matrices/matrices.dart:565; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart:121; tool/generator/lib/src/check/solvers/solver.dart.

Needs the lead: ray-intersection's earlier specific cardinal Blocker is closed, but the broader unique-answer Blocker remains open for the diagonal cases. Audit only; no fix, regeneration, or approval authorized. Continue the other twelve types.

## Verification limitation, recorded when encountered

All five requested commands returned exit 1 before execution. Each wrapper attempts to write the shared Flutter SDK cache outside the worktree. Actual common stderr:

```text
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 71: /opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>: Operation not permitted
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 78: /opt/homebrew/share/flutter/bin/cache/engine.realm: Operation not permitted
```

- FAIL `flutter test test/tool/generator` (pid 11390).
- FAIL `flutter analyze tool/generator test/tool/generator` (pid 11392).
- FAIL `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator` (pid 11393).
- FAIL `dart run tool/checks/run_checks.dart` (pid 11398).
- FAIL `dart run tool/check_no_ai_attribution.dart` (pid 11391).

Needs the lead: rerun these checks where the SDK cache is writable. No code/test/checker PASS is claimed. Continuing independent read-only content checks, not modifying SDK permissions, dependencies, protected assets, or generated outputs.

Source context: read the requested prod-ref figure-matrices.yaml using git show. Its local ref remains 88f38e698, so question 0009 has the superseded first-exclusive distractor. Part 2, resync brief and fix-sheet record explicitly adopt fixed root 646326517; compare that source for ray-intersection closure. Do not restore the old source or change questions.

Independent all-variant Python semantic sweep, no generator/solver imports: 1011 variants. 0 description, intended-answer, named-mistake, stated-track, duplicate-choice, note-slot, or scanned voice errors. Counts: {'intended-answer': 1011, 'unique-figures': 1011, 'unique-text': 1011, 'shown-tracks': 3297, 'description-arrow': 120, 'choice-voice': 4044, 'named-mistake': 3033, 'note-slots': 3033, 'rendered-voice-and-slots': 5055, 'description-form': 3644, 'description-fill': 224, 'description-dot': 400, 'description-count': 1420, 'description-half': 48, 'description-rays': 2280, 'description-size': 1020}. This checks stored data and prose semantics, not a Dart checker PASS.

Measured list summary: type, list length, stored ruleKeys, raw shown-plus-answer tasks, tasks with outline omitted, largest exact normalized answer multiplicity, uniquely-longest key indexes.
```text
('arrow-column', 30, 6, 30, 6, 2, [])
('binary-fill-row', 32, 32, 32, 12, 4, [])
('corner-reflection', 100, 100, 100, 8, 8, [])
('dot-sum', 100, 77, 100, 77, 17, [])
('fill-union', 24, 12, 24, 12, 4, [])
('form-ray', 100, 100, 100, 54, 7, [])
('growing-turn', 70, 14, 70, 14, 2, [])
('ray-intersection', 100, 100, 100, 100, 6, [])
('ray-turn', 100, 100, 100, 66, 5, [])
('ray-union', 100, 100, 100, 98, 5, [])
('size-dots', 55, 18, 55, 18, 3, [])
('size-transfer', 100, 81, 100, 81, 2, [])
('sized-ray-union', 100, 72, 100, 72, 2, [])
```

Resolved historical size-dots status: fix-sheet-findings.md:196 explicitly records the Nov 17 12:00 UTC lead ruling, "matrix-size-dots ships at 55 under Revision 1 (floor 20, not 100); moved back to content/types/." This controls the older hold/floor entries above. No current floor blocker is raised by this audit.

qt-spatial-abstract-reasoning-matrix-corner-reflection | Minor | OPEN from reaudit-b: all 100 variants still reduce to eight dot-position tasks when row outline names are removed. For example, indexes 10,20,30,59 all show bottom-right to bottom-left in the completed row and top-left to blank in the target row. Changing row shapes preserves distinct full tasks but repeats the same movement. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-corner-reflection.variants.yaml, indexes 10,20,30,59; whole list 0..99.

qt-spatial-abstract-reasoning-matrix-dot-sum | Minor | OPEN from reaudit-c and audit-r1b: the target calculation still uses only two input pairs, 1+3 or 2+3. Completed rows vary, with 77 distinct shown count grids in 100 variants, but the target calculation and numeric choices recur. Indexes 0,10,20,30,50,59,69,79,99 use 1+3; 40 and 89 use 2+3. Permitted constant outlines account for the remaining full-task variety. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml, indexes listed and whole list 0..99.

## Source fidelity and historical closure checks

```text
arrow-column: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
binary-fill-row: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
corner-reflection: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
dot-sum: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
dot-sum independent row/column operation conflicts: []; target pairs {(1, 3): 55, (2, 3): 45}
fill-union: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
form-ray: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
growing-turn: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
ray-intersection: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
ray-turn: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
ray-turn independent four-reflection conflicting-answer scan: []
ray-union: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
size-dots: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
size-dots countable-draw cap violations at indexes [0] (index 0 explicitly retained source exception)
size-transfer: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
sized-ray-union: source index 0 {'figure': True, 'choices': True, 'stem': True, 'lesson': True, 'keyPoint': True}
SOURCE ERRORS []
```

All source data was read with git show, not from worktree content/questions. Source comparisons cover figure data, exact choice wording and order/correctness, stem, lesson and key point. All 13 match, using the explicitly fixed root for intersection. The fixed source has no offered alternative selected by any of the eight directional projection rules; its earlier source-specific highest-ray defect is closed.

Sample indexes read with grids and all choice text, explanations and notes:
- matrix-arrow-column: 0,3,6,9,12,14,17,20,23,26,29.
- matrix-binary-fill-row: 0,3,6,9,12,16,19,22,25,28,31.
- matrix-corner-reflection: 0,10,20,30,40,50,59,69,79,89,99.
- matrix-dot-sum: 0,10,20,30,40,50,59,69,79,89,99.
- matrix-fill-union: 0,2,5,7,9,12,14,16,18,21,23.
- matrix-form-ray: 0,10,20,30,40,50,59,69,79,89,99.
- matrix-growing-turn: 0,7,14,21,28,34,41,48,55,62,69.
- matrix-ray-intersection: 0,10,20,30,40,50,59,69,79,89,99.
- matrix-ray-turn: 0,10,20,30,40,50,59,69,79,89,99.
- matrix-ray-union: 0,10,20,30,40,50,59,69,79,89,99.
- matrix-size-dots: 0,5,11,16,22,27,32,38,43,49,54.
- matrix-size-transfer: 0,10,20,30,40,50,59,69,79,89,99.
- matrix-sized-ray-union: 0,10,20,30,40,50,59,69,79,89,99.

## Per-type audit judgments and earlier verdicts

- matrix-arrow-column: earlier PASS holds. Quarter turns down both columns yield one offered arrow; copying its same-row counterpart yields the same key. Restarting at the top, reversing the middle arrow, and repeating the arrow above are plausible mistakes. Every blank is bottom-row, so the shared notes remain true. Thirty tasks contain six arrow/blank arrangements on five constant outlines, a disclosed cosmetic variety limit.
- matrix-binary-fill-row: earlier PASS holds. Alternation and matching same-column fills determine the same missing fill. Averaging black/white, repeating a neighboring fill, and changing the constant outline remain the named plausible errors. The neighbor remains visible for every blank. All 32 shown-plus-key tasks are distinct; wrong-outline-only changes no longer manufacture versions. Twelve arrangements remain without outline names. The former duplicate Major stays closed.
- matrix-corner-reflection: earlier PASS holds with its recorded Minor. Left/right reflection keeps each row outline and dot height. Copying the example position, holding the target dot, or copying the example outline produces the stored three wrong choices for all 100 variants. None of those notes contains a changing shape, count, or direction. The old eight-arrangement variety limit remains.
- matrix-dot-sum: earlier PASS holds with its recorded Minor. All 100 keys equal the input sum, and all 300 mistakes match continuation 2b-a, copying the second count, or absolute difference. Row/column arithmetic scans found no offered wrong alternative under sum, product, difference, maximum, minimum, either quotient, either signed subtraction, average, or continuation. The old fixed-plus-two Major and arithmetic ambiguity Blockers remain closed. Limited target variety remains 55 uses of 1+3 and 45 uses of 2+3.
- matrix-fill-union: earlier PASS holds. Complementary halves combine to black while preserving row size. Erasing combined fill, retaining only the first half, and retaining only the second half are plausible operation/omission errors. Both half notes stay orientation-neutral, and every changed left/right or top/bottom caption matches the actual rotation. Twenty-four tasks contain twelve arrangements without cosmetic outlines.
- matrix-form-ray: earlier PASS holds. Each row keeps its own outline; columns share the same line directions. Copy-middle-form and copy-top-form reference visible rows distinct from the target. Freeze-ray copies a real same-row neighbor, including left-column blanks. The wrap-to-previous-row Major remains closed across all 100 variants. Fifty-four direction/blank tasks remain when outline names are removed.
- matrix-growing-turn: earlier PASS holds. Equal turns within each row grow by a common amount between rows. Reusing the smallest row turn, holding the neighbor, and copying the actual top-middle direction are plausible errors. The note does not falsely call every top-middle line diagonal. All blanks are bottom-right. Seventy tasks contain fourteen start/step arrangements over five constant outlines; source-style longest-key guard reduces the prior 80 to 70 without an unresolved floor issue.
- matrix-ray-intersection: earlier FAIL remains FAIL, for the new diagonal-direction cases recorded above. Cardinal cases from audit-r2 and the old highest-ray source case are closed. The key is always the true intersection, and all 300 wrong figures match their named union/copy-second/exclusive operations. Those are plausible mistakes with true three-part notes, but second-exclusive is defensibly correct on the reported diagonal cases. All 100 shown ray tasks remain distinct even without outlines.
- matrix-ray-turn: earlier PASS holds. Every key applies the completed-row turn to the target line, retaining the target outline. Holding the line, copying the example line, and copying its outline remain plausible and accurately described. Independent all-list checks found no offered alternative under the four historical reflection transforms. Their earlier Blockers remain closed. Sixty-six direction tasks remain without outline names.
- matrix-ray-union: earlier PASS holds. The key keeps both row inputs. Omitting either input and copying the example pair remain plausible and match all 300 mistake figures. All changed direction descriptions match their rays. Ninety-eight tasks remain without outline names.
- matrix-size-dots: earlier PASS holds under the explicit floor-20 ruling. Row size and column dot count jointly determine each key. All 165 mistakes match the neighboring count or the actual middle/top-row sizes, including left-column blanks. The previous wraparound Major remains closed. Every non-source variant satisfies the new countability cap; source index 0 deliberately retains the small triangle with three dots, as authorized. Fifty-five tasks contain eighteen arrangements without outlines. This is data/constraint verification, not a rendered visual pass.
- matrix-size-transfer: earlier PASS holds. Row size stays constant while dots rise and edge lines fall by one across columns. Both freeze choices copy the true same-row neighbor, including left-column blanks; the middle-size choice references the visible middle row. All 300 notes/choice figures remain true, closing the old wraparound Major. Eighty-one arrangements remain without outline names.
- matrix-sized-ray-union: earlier PASS holds. The key combines both input rays and the target row size. Copy-middle-size and either omitted input remain plausible mistakes whose notes match all variants. Seventy-two arrangements remain without outlines; the remaining variety is permitted constant-outline widening.

Read the relevant matrix rule, literal sources, independent matrix solver, library solver and registry, plus the requested earlier audit reports. Read all four claimed lessons and key points from the prod-content ref. The intended rules fit their claimed lessons; the reflection type continues the approved source's position-change behavior within Matrix Turns and Counts. Every type uses the source's realistic generic matrix stem. The explanations use short, plain English and address only the correct rule. All 39 note templates name the error, give its appeal, and give a check. No new filler diagnosis or false fixed changing value was found. These judgments do not prove uniqueness against every possible rule.

No uniquely longest correct choice exists in any of the 1,011 variants. Every list meets R6 when measured by its exact normalized answer figure, including constant outlines, and every raw shown-plus-answer task is distinct. Stored signatures and ruleKeys were inspected/count-checked, not independently cryptographically recomputed. This audit does not claim a new capacity enumeration or whole-task geometric canonicalization proof.

## Remaining work and scope boundary

Needs the lead: rule on the diagonal intersection counterexamples and route any fix/hold through a separate assignment. Rerun checker, blind solve and this audit after an affected fix. Renew the changed type approvals separately. The two retained variety Minors remain nonblocking. Rerun all five failed-to-start commands in a writable SDK environment. Network ref freshness remains unverified here.

Only this findings file was written. No implementation, test authoring, content/questions, generated files, dependencies, UI, screenshots, protected-content builds, staging or commits. The named cube-net lead belongs to a different type and is outside this assignment. No visual acceptance or separate blind solve was performed. The lead owns integration, logs and final B6 acceptance.

## Verdicts

PASS means no open Blocker or Major in this content audit, not executable-gate PASS or approval.

qt-spatial-abstract-reasoning-matrix-arrow-column | PASS
qt-spatial-abstract-reasoning-matrix-binary-fill-row | PASS
qt-spatial-abstract-reasoning-matrix-corner-reflection | PASS
qt-spatial-abstract-reasoning-matrix-dot-sum | PASS
qt-spatial-abstract-reasoning-matrix-fill-union | PASS
qt-spatial-abstract-reasoning-matrix-form-ray | PASS
qt-spatial-abstract-reasoning-matrix-growing-turn | PASS
qt-spatial-abstract-reasoning-matrix-ray-intersection | FAIL
qt-spatial-abstract-reasoning-matrix-ray-turn | PASS
qt-spatial-abstract-reasoning-matrix-ray-union | PASS
qt-spatial-abstract-reasoning-matrix-size-dots | PASS
qt-spatial-abstract-reasoning-matrix-size-transfer | PASS
qt-spatial-abstract-reasoning-matrix-sized-ray-union | PASS
