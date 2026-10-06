# Level 3 gate review 5 (closing check)

Reviewer: independent tier-2 reviewer (SUBAGENTS Part 7b); not an author of the reviewed documents. Date: October 6, 2026.
Policy revision read: origin/main aa73bd25 (SUBAGENTS.md Part 7b). Main checkout clean, HEAD equal to origin/main after fetch.
Code branch checked: `origin/integration/new-design-r1` with `git show "${B}:path"`.
Scope: review 4 items L3R4-1 to L3R4-6, L3R2-6 (marked partly), and `git diff e2fb6c3d aa73bd25` (6 plan and log files plus the review 4 file). Settled items outside the diff were not reopened.
Nothing was edited, committed or pushed in the repository.

Totals: Part A: 7 resolved, 0 partly, 0 not resolved (7 items). Part B: 0 blockers, 0 should-fix, 3 notes.

Gate verdict: Gate passes.

---

## Hygiene evidence

- Em dashes in added lines outside the gates folder: 0 (`git diff e2fb6c3d aa73bd25 -- . ':!docs/superpowers/plans/new-design/gates' | grep '^+' | grep -c "—"` gives 0). The one hit in the full diff is the quoted command inside the review 4 file.
- aa73bd25 is the only commit in the range; it has no attribution trailer (same as reviews 3 and 4 noted for earlier commits).

---

## Part A. Review 4 items and L3R2-6

| ID | State | Evidence |
|---|---|---|
| L3R4-1 | resolved | L3-W4f T6: "Plans for the active exam's tier from W3, offered when `proForActiveExamProvider` is false (test: a Student Pro subscriber on CSE sees the Civil Service plans and pass)". W4f header: "Whether the Pro page offers the active exam's plans and pass or shows the owned state follows W3's `proForActiveExamProvider`"; plan name, Your plan rows and Manage keep the any-plan flag. W3 T8 bullet now limits `pro_page.dart` to "plan name, Your plan rows and the direct Manage link only" and names the offer-or-owned choice as W4f's only active-exam read. L2 W3 §8 adds the same split. Code: `pro_page.dart:96` `if (!entitlement.proIsActive)` (the offer read now covered), `:26`, `:150`. Map l.22 already has W3 to W4f for `proForActiveExamProvider`; no new edge needed. |
| L3R4-2 | resolved | L3-W4f T6 now reads "When W3's `switchOutcome` (Task 6) carries `studentPlanStillRenews`"; L3-W3 T6 test: "the outcome carries `studentPlanStillRenews`" on `switchOutcome`. One type named in both. |
| L3R4-3 | resolved | L3-W3 T8 adds "Update `test/app/mock_entitlement_override_test.dart` for the active-exam override" and its checks now run `test/app`. The test exists on the code branch (imports `package:pantas/app/bootstrap.dart`, asserts `mockEntitlementProvider.proIsActive`). Map l.60 orders the file W1 Task 7, then W3; no conflict. |
| L3R4-4 | resolved | L3-W0 T4b: existing tests "resolves image marker by lesson and sequence" and the sparse-marker case "gain a matching credit entry; one existing case becomes the drop case". Both tests exist (`markdown_portable_text_test.dart:145`, `:323-375`) and assert exact image-block maps, so the update is required as stated. |
| L3R4-5 | resolved | L2 W3 §8: "Each W4 family switches its own gates to `proForActiveExamProvider`; plan status (Settings Pro row, Pro page plan name and Manage) keeps the any-plan flag, and the Pro page's offer-or-owned choice reads the new provider." Residual wording gap: L3R5-1. |
| L3R4-6 | resolved | L3-W4h T4: "The greps are a backstop to each family's own inventory; they miss strings split across lines." |
| L3R2-6 | resolved | Residual was L3R4-2, resolved above. Open decision still names Aedwon and the start of level 4 in W3 T6 and W4f T6. |

---

## Part B. New problems in the delta

| ID | Severity | Plan and task | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L3R5-1 | note | L2 W3 §8 | L2 lists plan status as "Settings Pro row, Pro page plan name and Manage"; L3-W3 T8 and the W4f header add "Your plan rows". L2 is narrower than L3 by one item. | L2-W3 l.123-125; L3-W3 T8 bullet; L3-W4f l.19-21. | Add "Your plan rows" to L2 W3 §8. |
| L3R5-2 | note | L2 W3 §8 | The wording issue from review 4 is still present: "(amended (level 3 gate review 2))" (nested parentheses). The review 4 addition also carries no amendment marker, and line 123 is 156 characters, out of step with the file's wrap. Cosmetic. | L2-W3 l.123. | Write "(amended in level 3 gate reviews 2 and 4)" and rewrap. |
| L3R5-3 | note | L3-W0 Task 4b | "Existing image tests ... gain a matching credit entry; one existing case becomes the drop case" does not say which case drops. Read literally, both tests gain credit and one also drops. The sparse case has two images, so one natural reading is that one of its two images loses its credit entry. A worker can resolve this, but naming it removes a guess. | L3-W0 l.91-93; `markdown_portable_text_test.dart:323-375` (two images, keys #2 and #4). | Name the drop case, for example "in the sparse case, image #4 has no credit entry and is dropped". |

---

## Other checks

- Commands in the diff: W3 T8 `flutter test test/features/mock_exam test/features/roadmap test/app test/tool/paywall_release_guard_test.dart`; all paths exist on the code branch (`test/app/` has 12 files including `mock_entitlement_override_test.dart`). Not run; document gate.
- Contradictions with the map: none. Map l.22 (W3 to W4f, `proForActiveExamProvider`), l.60 (`mock_entitlement_override_test.dart` order), l.65 (`pro_page.dart` W3 Task 3 then W4f Tasks 6 and 7), l.75 (`bootstrap.dart` W3 Task 8 then W4h Task 2) agree with the diff.
- Restart log entry for review 4 matches the diff.

Not checked:
- Boards were not rendered (ST_ProCSE_v2, ST_ProPro).
- No builds, tests or analyzers were run.
- Settled items outside the diff were not reopened.
