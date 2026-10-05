# Level 2 gate review 5 (closing check)

Reviewer: independent tier-2 reviewer (SUBAGENTS Part 7b); not an author of the reviewed documents. Date: October 6, 2026.
Policy revision read: origin/main 4aa276a2 (SUBAGENTS.md Part 1, 2, 7b; AGENTS.md and WORKFLOW.md present at that revision). Main checkout clean, HEAD equal to origin/main (4aa276a2).
Code branch checked: `integration/new-design-r1` worktree at 1f79d880.
Scope: review 4 items N4-1 to N4-6, and `git diff 8ebd26ad 4aa276a2` (6 files; the review 4 file itself excluded).
Nothing was edited, committed or pushed in the repository.

Totals: part A: 4 resolved, 0 partly, 2 not resolved (both notes, unchanged and accepted as level 3 items). Part B: 0 blockers, 0 should-fix, 2 notes.

---

## Part A. Review 4 items

| ID | Severity in review 4 | State | Evidence |
|---|---|---|---|
| N4-1 | should-fix | resolved | W0 §8 l.124-125: "`lib/features/mock_exam/domain/mock_results.dart` (adds the mock JSON field declarations only; W4e computes and writes the counts and reasons; before W4e)". W4e §4 l.33: "Fills the W0 JSON fields: per-part `wrong` and `blank` counts (`compute_results.dart`, `submit_mock.dart`) and the review reasons." W4e §8 l.99 owns `lib/features/mock_exam/`, so both use-case files are in W4e's list. Code check: `MockAnswer` and `SectionResult` are both declared in `mock_results.dart` (l.8, l.54), so a declarations-only W0 change stays inside its named file. The W0/W4e overlap on `mock_results.dart` is ordered ("before W4e"). |
| N4-2 | should-fix | resolved | W4g l.5 "Traceability: 39 rows with workstream `W4g` (12 boards, 27 other items)"; l.18 "Other traceability rows (27): ... G-h-14, G-h-28." Script: W4g header (39, 12, 27), listed 12/27, table 12/27, 0 missing, 0 extra. |
| N4-3 | should-fix | resolved | W4g §4 l.50-52: "The old globe icon on the share note and the reveal bar's bookmark icon are removed: the share note is text only (WR_Share) and the reveal bar holds Share and Done (WR_Mock, WR_Streak, WR_Exam) (G-h-28)." Traceability G-h-28: "assigned: follow WR_Share and the reveal boards; the old globe and bookmark icons are removed (no mapping needed)". Boards: WR_Mock, WR_Streak, WR_Exam each carry exactly one "Share" and one "Done" text. WR_Topic also has that bar but is "dropped ... do not build" (traceability B-WR_Topic; W4g §1 R-14), so leaving it out of the list is correct. The status now describes building as drawn, which matches the "assigned" legend. See N5-1 for the remainder of the gap row. |
| N4-4 | note | resolved | W4g §4 l.54-55: "After Pro lapses: saved Wrappeds are kept and renewing restores (Aedwon, Oct 6, gate F-18); the history row shows the Pro tag after a lapse (lead default)." Matches traceability G-g-15. |
| N4-5 | note | not resolved (accepted) | W0 §7 l.113-114 unchanged: "`MistakeTag` gains a fallback for unknown values so an older build syncing an item tagged `other` does not fail to decode (gate N3-9)." Not in the diff or the restart log entry. It remains a level 3 item for W0 as review 4 proposed; it does not block level 2. |
| N4-6 | note | not resolved (accepted) | W2 §9 close-out unchanged. Review 4 marked the resolution optional (name `exam_date_sheet.dart`, `topic_scope_index.dart`, `settings_value_row.dart` at level 3). The close-out's "no retired import remains" check still covers them. |

---

## Part B. The delta

### Traceability (script evidence)

Script `scratchpad/trace2.py` rerun on 4aa276a2.

- 833 rows, 0 malformed, 0 duplicate IDs.
- Counts: W4b 151, W4f 149, W4e 98, W4d 94, W4c 85, none 76, W4a 59, W4g 39, W1 27, W2 16, W3 14, W4h 13, W0 9, W5 3 (unchanged from review 4).
- Every non-`none` row cites `L2-<its own plan>.md §n` and that `## n.` exists; every `none` row has no section; level 3 column empty. Violations: `[]`.
- W4a to W4h: §2 board list and "Other traceability rows" equal the table, and header counts equal the table:
  - W4a 59 (17, 42); W4b 151 (61, 90); W4c 85 (30, 55); W4d 94 (46, 48); W4e 98 (41, 57); W4f 149 (66, 83); W4g 39 (12, 27); W4h 13 (2, 11). 0 missing, 0 extra in every plan.
- 290 board files equal 290 B- rows; 0 files without a row, 0 rows without a file.
- Plan references with no row: D-18, D-89, D-102, D-160 (unchanged; heading lines, harmless).

### Findings

#### N5-1 · traceability · note
Location: `traceability.md` G-h-28 status (l.879); source `stage0/gap-h-shell-states.md` l.70.
Evidence: the gap row covers four icons: the globe, the collections-bookmark, "expand-less and expand-more on the topic scope list, drag-handle on bookmarks". The old status ended "(W4g share screens; other screens use W2 components when rebuilt)". The new status names only the globe and the bookmark. The last two are still covered by the gap row's own resolution column, "IC_Final (reorder icon and caret-right cover the last two)", and their screens belong to W4c (bookmarks sheet, R-21) and the W2 component `topic_scope_index.dart`. A builder reading only the status would not see them.
Resolution: optional; append "expand and drag-handle icons: IC_Final caret-right and reorder" to the G-h-28 status, or leave it to level 3 of W4c and W2.

#### N5-2 · contract wording · note
Location: `L2-W0-integration.md` §1 l.27-29; `L2-W4e-mock-exam.md` §4 l.33.
Evidence: W0 §1 still says "Old rows parse with the new fields null" and "W4d and W4e write them". After the N4-1 fix, W0 declares only. On the branch, the mock JSON is decoded in W4e files: `presentation/pages/mock_results_route.dart:49` (section results) and `domain/mock_session_snapshot.dart:172` (answers). So the old-row parse rule is carried out in W4e code, while W4e's new line says only "computes and writes". Both files are inside W4e §8, so there is no unowned file and no order problem; only the reading side is not named.
Resolution: optional; at level 3, W4e names the decode with null defaults for old rows.

### Other checks on this diff

- Contradictions: none found. W0 "declarations only" and W4e "fills" agree; W4g §4 and G-h-28 agree; W4g §4 and G-g-15 agree.
- Names: W4e l.40 consumes the same field names W0 §3 fixes (`SectionResult.wrong`, `SectionResult.blank`, `missReason`, `blankReason`, `reasonNote`); file names in W4e l.33 exist on the branch.
- File overlaps without order: none. `mock_results.dart` is shared by W0 and W4e with "before W4e".
- Untraceable decisions: none new. Removing the reveal page's app bar icon also removes its route to "My shared cards" (`wrapped_reveal_page.dart:40`); the design's entry point is shared links in About (W4g §1, WR_Links), so this follows the approved boards.
- Restart log entry (l.566-571) matches the diff.

## Check summaries

- Part A: N4-1 to N4-4 resolved; N4-5 and N4-6 unchanged notes, accepted for level 3.
- Traceability script: passes for all plans.
- Blockers: 0. Should-fix: 0. Notes: N5-1, N5-2, plus N4-5, N4-6 carried.

Not checked:
- Boards read as text, not rendered.
- Plans and sections outside the diff were not re-read beyond W0 §1, §7, §8, W4e §2, §4, §8, W4g §1, §2, §4, and the gap row B#28.
- No builds, tests or analyzers were run; this is a document gate.

Gate verdict: pass
