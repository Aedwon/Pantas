# Level 2 gate review 4 (strategy B4, delta)

Reviewer: independent tier-2 reviewer (SUBAGENTS Part 7b); not an author of the reviewed documents. Date: October 6, 2026.
Policy revision read: origin/main 8ebd26ad (AGENTS.md, WORKFLOW.md, SUBAGENTS.md Part 7 and 7b). Main checkout clean, HEAD equal to origin/main (8ebd26ad).
Code branch checked: `integration/new-design-r1` worktree at 1f79d880.
Scope: delta only. Inputs: review 3 (N3-1 to N3-10); restart log entry "October 6, 2026: level 2 gate review 3 (not passed, no blocker) and fixes" (l.553 to 564); `git diff 6d0bb731 8ebd26ad` (17 files, review 3 file excluded from review). Opened as needed: W0 §1, W2 §1, §7 to §9, W4e §8 to §9, W4g §2 and §4, W1 §3 Icons row, `stage0/gap-h-shell-states.md` (B#28 and bottom-sheet call sites), amendment spec B2 tap routing, W4g boards (as text).
Nothing was edited, committed or pushed in the repository.

Totals: part A: 6 resolved, 4 partly resolved, 0 not resolved. Part B: 0 blockers, 3 should-fix, 3 notes.

---

## Part A. Review 3 items

| ID | State | Evidence |
|---|---|---|
| N3-1 | resolved | W0 §3 Recorded-only row now "mistake tags (`AttemptItem.mistakeTag` with `other`, `AttemptItem.mistakeNote`); mock `missReason`, `blankReason`, `reasonNote`; `SectionResult.wrong`, `SectionResult.blank` (all JSON fields, app schema 25)". `grep "schema 26"` over the plans and Oct specs: 0 hits. |
| N3-2 | partly, see N4-1 | W0 §8 adds "`lib/features/mock_exam/domain/mock_results.dart` (adds the mock JSON fields and fills the per-part counts; before W4e)". The counts are not filled in that file: `SectionResult` is built in `lib/features/mock_exam/domain/use_cases/compute_results.dart:56` and encoded to `sectionResultsJson` in `domain/use_cases/submit_mock.dart:22,37`. Neither is in W0 §8. |
| N3-3 | resolved | W2 §6 now "`flutter analyze` clean for W2's own files"; W2 §9 "Close-out task (owned by W2, run after the last W4 family lands): delete `ink_sheet.dart` and every Ink component with no caller, then check no retired import remains ... The level 4 gate for W4 completion requires this task." W4a to W4h §4 each add "Replaces every retired Ink component and `showInkSheet` call in its own screens". Every `showInkSheet` caller on the branch (8 files) and every feature directory importing an Ink component (assessment, home, lesson, mock_exam, onboarding, progress, quiz, settings, wrapped) maps to a W4 family that now carries the line. See N4-6. |
| N3-4 | partly, see N4-2, N4-3 | Traceability G-h-28 now W4g §4, "assigned: map to W1's existing getters"; W4g §4 "map to one of W1's 45 getters (`share`, `bookmark`); none added (G-h-28)". Both getters exist in W1 §3. But W4g §2 was not updated, and the mapping adds icons the boards do not show. |
| N3-5 | resolved | W4c §4 l.52 "Removes the `onReorder` deprecation when rebuilding the bookmarks sheet (R-21)"; W4f §4 l.62 "Notification tap routing per amendment B2 (A-B2b): daily, follow up, come back and countdown open Home; trial ending opens Settings › Pantas Pro." Matches amendment spec l.161-162. |
| N3-6 | partly (note) | SCREENS.md registers ST_ProCSE_v2 and ST_ProCSEPass_v2 and marks the originals "Superseded 6 Oct by ..."; both v2 `<title>`s drop "(proposal 6 Oct)"; the tier spec link resolves. `docs/design/index.html` still lists neither v2 board (0 matches); the log says so ("the canvas gallery `index.html` is not regenerated"). Acceptable as a recorded gap. |
| N3-7 | resolved | W0 §7 "Level 3 fixes the catalog storage form (columns or `catalogJson`) and its reader API name before any consumer writes a reader (gate N3-7)." |
| N3-8 | resolved | W3 §7 "Level 3 states how stored pass end dates are updated when a catalog date moves later (a new export, a functions deploy with Aedwon's approval, and a recompute of affected passes; gate N3-8)." Consistent with the tier spec ("the pass moves with it"). |
| N3-9 | partly, see N4-5 | W0 §7 "`MistakeTag` gains a fallback for unknown values so an older build syncing an item tagged `other` does not fail to decode (gate N3-9)." |
| N3-10 | partly, see N4-4 | Traceability G-g-15 fixed: "decided (Aedwon, Oct 6): saved Wrappeds kept; Free rules after a lapse; renewing restores. Lead default: the history row shows the Pro tag after a lapse; empty history shows the row's empty state". W4g §4 not updated. |

---

## Part B. The delta

### Traceability (script evidence)

Script `scratchpad/trace2.py` rerun on 8ebd26ad.

- 833 rows, 0 malformed, 0 duplicate IDs.
- Counts: W4b 151, W4f 149, W4e 98, W4d 94, W4c 85, none 76, W4a 59, W4g 39, W1 27, W2 16, W3 14, W4h 13, W0 9, W5 3 (W2 17 to 16 and W4g 38 to 39, the G-h-28 move).
- Every non-`none` row cites `L2-<its own plan>.md §n` and that `## n.` exists; every `none` row has no section; level 3 column empty. 0 violations.
- W4a to W4f and W4h: §2 board list and "Other traceability rows" equal the table (0 missing, 0 extra); header counts match.
- **W4g fails:** header "38 rows ... (12 boards, 26 other items)", list "Other traceability rows (26)"; table has 39 rows, 27 other. Missing from the plan list: `G-h-28`. (N4-2)
- 290 board files equal 290 B- rows.
- Plan references with no row: D-18, D-89, D-102, D-160 (unchanged; heading lines, harmless).

### Findings

#### N4-1 · file overlap · should-fix (carries N3-2)
Location: `L2-W0-integration.md` §8 (l.124-125).
Evidence: W0 §8 says `mock_results.dart` "adds the mock JSON fields and fills the per-part counts". On the branch, `mock_results.dart` only declares `SectionResult` (l.54-71, plain class). The counts are computed in `lib/features/mock_exam/domain/use_cases/compute_results.dart:56` and written to JSON in `lib/features/mock_exam/domain/use_cases/submit_mock.dart:22,37`; the stored JSON is decoded in `presentation/pages/mock_results_route.dart:49`. W0 cannot fill `wrong` and `blank` without touching the two use-case files, which are W4e's directory and not in W0's list (SUBAGENTS Part 2). Order exists (W0 before W4e), so only the list is wrong, as in review 3.
Resolution: add `compute_results.dart` and `submit_mock.dart` (and the decoder if W0 reads the fields back) to W0 §8, or say W0 adds the fields only and W4e fills the counts.

#### N4-2 · traceability · should-fix
Location: `L2-W4g-wrapped-and-sharing.md` §2 (l.5 header, l.18 list).
Evidence: script output above. G-h-28 moved to W4g in traceability but W4g's header still reads 38 rows, 26 other items, and the list omits G-h-28. The gate's equality check fails for W4g.
Resolution: add G-h-28 to the list; header 39 rows (12 boards, 27 other items).

#### N4-3 · decision not traceable to the design · should-fix
Location: `L2-W4g-wrapped-and-sharing.md` §4 (l.50-51); traceability G-h-28 status.
Evidence: W4g §4 maps "globe on the share note, the reveal bar icon" to "`share`, `bookmark`". The approved boards show neither icon in those places. WR_Share's public-link line is text only: "Sharing publishes this to a pantas.app link anyone can view. Remove it any time in About." with no svg beside it (same for WR_ShareExam, WR_ShareOffline). The reveal bar on WR_Mock, WR_Streak, WR_Topic, WR_Exam holds only "Share" (with the Phosphor share glyph) and "Done"; no bookmark glyph appears on any W4g board (path match). AGENTS.md: "take every visual decision from the approved Claude Design screens, matched 1:1". Mapping the code's globe and collections-bookmark to new glyphs keeps two icons the design removed. The status also reads "assigned", which the table legend defines as "built as drawn or written"; this is a lead choice. The other half of the gap row (topic scope expand icons, bookmarks drag handle) is covered by "other screens use W2 components when rebuilt" and the gap row's own "IC_Final (reorder icon and caret-right cover the last two)".
Resolution: W4g §4 and G-h-28 say these screens follow WR_Share and the reveal boards (no icon on the share note; reveal bar is Share and Done), so no mapping is needed; or ask Aedwon.

#### N4-4 · attribution · note (carries N3-10)
Location: `L2-W4g-wrapped-and-sharing.md` §4 l.53-54.
Evidence: "After Pro lapses: saved Wrappeds are kept and history shows the Pro tag; renewing restores (Aedwon, Oct 6, gate F-18)." Traceability now marks the Pro tag part "Lead default"; the plan still attributes it to Aedwon. Traceability is binding, so a builder gets the right status, but the two disagree.
Resolution: mark "history shows the Pro tag" as lead default in W4g §4.

#### N4-5 · facts · note (carries N3-9)
Location: `L2-W0-integration.md` §7 (l.113-114).
Evidence: the fallback is added in the new build, but the failure case is an older build decoding `other`. An older build does not have the new fallback, so the stated purpose cannot be met by this change. It only matters if an older build is installed alongside the new one; no record of a released build was found in the decisions log or pricing.md.
Resolution: level 3 of W0 records either that no older build syncs with the new one (so the fallback is for future values only), or how older builds are kept from pulling `other`.

#### N4-6 · scope · note
Location: `L2-W2-shared-components.md` §9 close-out.
Evidence: the close-out names `ink_sheet.dart` and "every Ink component with no caller". Three non-Ink components in `lib/core/ui/components/` also import Ink components or `showInkSheet`: `exam_date_sheet.dart`, `topic_scope_index.dart`, `settings_value_row.dart`. All their callers are in W4f, W4d and W4e directories. W2 §8 "retired ones deleted when their last caller moves" covers them in general, and the close-out's "no retired import remains" check would catch them. No plan names them.
Resolution: optional; name them in the close-out task at level 3.

---

## Check summaries

- Part A: 6 resolved, 4 partly (N3-2, N3-4 as should-fix; N3-6, N3-9, N3-10 as notes; N3-6 accepted as a recorded gap).
- Traceability script: passes except W4g §2 (N4-2).
- Contracts named differently by owner and consumer: none found (W0 JSON field names, A-B2b routing vs amendment B2, TrialEndingNotifier unchanged).
- File overlaps without order: none new; N4-1 is an incomplete list with order.
- Decisions not traceable to Aedwon's words or an approved design: N4-3 (should-fix), N4-4 (note). The W3 pass-date recompute and the W2 close-out are process directions consistent with the tier spec and W2 §7.
- Restart log entry matches the diff, except the claims "G-h-28 icon mapping moved to W4g" (W4g §2 not updated) and "G-g-15 marks the Pro tag after a lapse as a lead default" (traceability only, not W4g §4).

Not checked:
- Boards were read as text and matched by svg path; not rendered. A bookmark glyph drawn with a different path would not be found.
- `docs/design/index.html` was checked only for the two v2 boards.
- Plans outside the diff were not re-read beyond the sections named above; review 3 items already resolved were not re-derived.
- W0 to W3 and W5 have no row lists in §2, so only section existence was checked for their rows.
- Whether any older app build is installed by students was not checkable from the repository.
- Google Play replacement modes were not checked (left to level 3 by the tier spec).
- No builds, tests or analyzers were run; this is a document gate.

Gate verdict: not passed
