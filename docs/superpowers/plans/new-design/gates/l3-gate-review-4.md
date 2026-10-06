# Level 3 gate review 4 (closing check)

Reviewer: independent tier-2 reviewer (SUBAGENTS Part 7b); not an author of the reviewed documents. Date: October 6, 2026.
Policy revision read: origin/main e2fb6c3d (AGENTS.md, WORKFLOW.md, SUBAGENTS.md Part 7b). Main checkout clean, HEAD equal to origin/main.
Code branch checked: `origin/integration/new-design-r1` at 1f79d880 (`git show`, `git grep`, and a `git archive` snapshot in the scratchpad for running greps).
Scope: review 3 items L3R3-1 to L3R3-11, the items review 3 marked "partly" (L3R2-1, L3R2-2, L3R2-5, L3R2-6, L3R2-8, L3-6, L3-20), and `git diff 8973cda5 e2fb6c3d` (11 files plus the review 3 file). Gate rules: strategy B5.
Nothing was edited, committed or pushed in the repository.

Totals: Part A: 17 resolved, 1 partly, 0 not resolved (18 items). Part B: 0 blockers, 1 should-fix, 5 notes.

Gate verdict: does not pass (1 should-fix).

---

## Hygiene evidence

- Added lines: 0 em dashes (`git diff 8973cda5 e2fb6c3d | grep '^+' | grep -c "—"` gives 0); no British spellings from the AGENTS list.
- Commit e2fb6c3d is the only commit in the range; it has no attribution trailer (same as review 3 noted for 8973cda5).

---

## Part A. Review 3 items and the items it marked "partly"

| ID | State | Evidence |
|---|---|---|
| L3R3-1 | resolved | L3-W3 T8 now lists "the mock entitlement wiring in `bootstrap.dart` (the override that builds `MockEntitlementSnapshot`...)" under W3's own switches; sync eligibility now names only `sync_runtime_bootstrap.dart`. Map row split: "`lib/app/bootstrap.dart` / W3 Task 8 (mock entitlement override), then W4h Task 2". L2 W3 §8 adds `lib/app/bootstrap.dart (mock entitlement override)`. Code claim confirmed: `bootstrap.dart:77-83` `mockEntitlementOverrides` reads `ref.watch(entitlementProvider).valueOrNull?.proIsActive`. Order: W3 waves 2 and 3, W4h wave 4; no cycle. Residual check gap: L3R4-3. |
| L3R3-2 | resolved | W3 T8 "Keep the any-plan flag (plan status, not gates): `settings_providers.dart` (`proRowValueProvider`, the Settings Pro row), `pro_page.dart` (plan name and the direct Manage link)". The W4f switch list no longer names `pro_page.dart` or the Settings row ("W4f has no gate"). W4f header rewritten to "Plan status ... reads the any-plan entitlement; any Pro gate reads W3's `proForActiveExamProvider`". Code claims confirmed: `settings_providers.dart:194` `proRowValueProvider`; `pro_page.dart:26` `canLinkDirectly = entitlement.proIsActive && ...`, `pro_page.dart:150` `_planName`. New gap in the reclassification: L3R4-1. |
| L3R3-3 | resolved | L3-W4f T6 adds: when the outcome carries `studentPlanStillRenews`, the Pro page shows the Student plan still renews with Manage in Google Play, with a test; waits for Aedwon's decision and copy at the start of level 4; stop if he chooses otherwise. Open decision names who and when. Naming mismatch with W3: L3R4-2. |
| L3R3-4 | resolved | L3-W0 T4b test now: "with no match, the export drops that image block (no credit, no image) and logs the lesson path"; stop condition repeats "the export drops it". The two statements now agree. Existing tests affected: L3R4-4. |
| L3R3-5 | resolved | L2 W0 §1 adds "Figure credits in lesson image blocks from `content/illustrations/sources/*.yaml` (W0 Task 4b ...)"; fragment rewritten to "The package is `assets/seed/content.db`, `content.manifest.json` and `content.manifest.sig` at the next release sequence"; §7 "((" fixed; §8 adds `tools/content/markdown_portable_text.dart`. |
| L3R3-6 | resolved | L2 W5 §3: "Contracts consumed: W0 baseline; the release package (W5 Task 1); W3 products and test track; every W4 route." |
| L3R3-7 | resolved | L3-W5 T1: "inside the scoped key shell, `dart run tools/verify_content_package/verify_content_package.dart assets/seed/content.db assets/seed/content.manifest.json assets/seed/content.manifest.sig` exits 0". Confirmed: tool requires exactly 3 args in order payload, manifest, signature (`verify_content_package.dart:11-15`) and reads `PANTAS_CONTENT_BOOTSTRAP_KEY_V1_B64` (l.21), which "scoped key shell" covers (`docs/content-key-access.md` l.25-58). The three paths are the gitignored package paths used by `release.sh:16-18` and `content_package_verifier.dart:10-11`. W0 T6 shorthand is outside the diff (unchanged). |
| L3R3-8 | resolved | L3-W4h T4 now uses `'\b(e\|err\|error\|exception)\.toString\(\)'` and a third grep `"Text\([^)]*\\\$\{?(e\|err\|error\|exception)\b"`. Run on the 1f79d880 snapshot with both `/usr/bin/grep` (BSD 2.6.0) and the default shell grep: 18 hits for the bounded pattern (all real errors, same as before); 6 hits for the Text pattern, all `Text('Error...: $e/$err')` displays, including `debrief_page.dart:70` which the `'Error: $'` grep misses. A synthetic file confirmed `Text('$exam')` does not match and `Text('$e')`, `Text('Failed: ${error}')` do. Residual: L3R4-6. |
| L3R3-9 | resolved | L2 W3 §8 now names `lib/app/bootstrap.dart` and `settings_routes.dart`. The parenthetical still reads "(amended (level 3 gate review 2))" for review 3 additions; cosmetic, not counted. |
| L3R3-10 | resolved | The W4c header line is removed. `grep -i "\bpro\b" L3-W4c*.md`: no Pro gate; L2 W4c says "Free and Pro: same (D-145)". The map needs no W3 to W4c row. |
| L3R3-11 | resolved | W4b now names `how_you_work_page.dart`, `why_you_miss_section.dart`; W4d names `debrief_page.dart` "including its direct `entitlementProvider` read", `debrief_providers.dart`, `session_debrief.dart`; `router.dart` `_isProRoute` and `/review` go with W1 Task 7. `git grep -l "proIsActive\|entitlementProvider" lib` on 1f79d880 (35 files): every remaining read is named, covered by "rebuilt performance and plan screens" (`performance_section.dart`, deleted with `lib/features/progress/` in W4b), deleted by W4f T7 (`paywall_page.dart`, `subscription_panel.dart`), or is the provider and data layer itself (`paywall_providers.dart`, `entitlement.dart`, `revenuecat_sdk.dart`). |
| L3R2-1 | resolved | Remaining parts were L3R3-4 and L3R3-5, both resolved above. |
| L3R2-2 | resolved | Remaining parts were L3R3-6 and L3R3-7, both resolved above. |
| L3R2-5 | resolved | Remaining parts were L3R3-1 and L3R3-2, both resolved above. |
| L3R2-6 | partly | The open decision is recorded with Aedwon and "the start of level 4" in W3 T6 and now in W4f T6 (L3R3-3 resolved). Residual: W4f says "purchase outcome" where W3 puts the flag on the switching outcome (L3R4-2). |
| L3R2-8 | resolved | Remaining part was L3R3-9, resolved above. |
| L3-6 | resolved | Follows L3R2-1. |
| L3-20 | resolved | Follows L3R2-5 and L3R2-6; the L3R2-6 residual is a note-level naming gap, not a missing owner. |

---

## Part B. New problems in the delta

| ID | Severity | Plan and task | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L3R4-1 | should-fix | L3-W3 Task 8 "Keep the any-plan flag" bullet and "W4f has no gate"; L3-W4f header and Task 6 | The diff files `pro_page.dart` as a whole under "Keep the any-plan flag (plan status, not gates)" and states "W4f has no gate", but classifies only two of the page's three reads (plan name, Manage link). The third decides whether the page offers a purchase: `if (!entitlement.proIsActive)` shows the buy entry. On the rebuilt page the same choice decides whether a Student Pro subscriber viewing CSE sees the CS plans and pass (ST_ProCSE_v2, ST_SwitchUpgrade) or a "you have Pro" page (ST_ProPro). Read with the any-plan flag, that student is offered nothing to buy for CSE and cannot reach the Season Pass case W4f T6 now builds. W4f T6 says "Plans for the active exam's tier from W3" but does not say which signal picks the owned versus offer layout. Touches money and entitlement (Part 7b: tier 1). | `pro_page.dart:96` `if (!entitlement.proIsActive) SettingsValueRow(title: 'Try Pro', ...)`; `pro_page.dart:26`, `:150` (the two classified reads). L3-W3 T8: "W4f has no gate; it keeps the any-plan flag above." L3-W4f l.19-20 and T6. W3 T3 provides `coversExam(examId)`. | State in W4f T6 (and the W3 T8 bullet) that whether the tier page shows its plans and pass, or the owned state, follows `coversExam(activeExam)` (`proForActiveExamProvider`); only the plan name, Your plan rows and Manage link read the any-plan entitlement. Add a test: Student Pro on CSE sees the CS plans. |
| L3R4-2 | note | L3-W4f Task 6; L3-W3 Task 6 | W4f T6 reads "When W3's purchase outcome carries `studentPlanStillRenews`". W3 puts the flag in Task 6, the switching rule (`switchOutcome`), with the test "the outcome carries `studentPlanStillRenews`"; purchase results are Task 7's six typed results, which do not mention it. A worker cannot tell which type to read. | L3-W3 l.96-104 (Task 6), l.108-118 (Task 7). L3-W4f l.85-88. | Name one type in both plans: either W3 T7's purchase result carries the flag, or W4f reads it from `switchOutcome`. |
| L3R4-3 | note | L3-W3 Task 8 checks | W3 T8 now edits `bootstrap.dart`'s override, whose test is `test/app/mock_entitlement_override_test.dart` (imports `package:pantas/app/bootstrap.dart`; asserts `mockEntitlementProvider.proIsActive` from a Monthly entitlement alone). The switched override also needs the active exam, so this test changes, and the map orders it "then W3". W3 T8's checks run `test/features/paywall`, `mock_exam`, `roadmap` and the guard test, not `test/app`. | `test/app/mock_entitlement_override_test.dart:3,14,21,33`; map l.60; L3-W3 T8 Checks line. | Add `test/app/mock_entitlement_override_test.dart` (or `test/app`) to W3 T8's checks and name the test update. |
| L3R4-4 | note | L3-W0 Task 4b | The drop rule changes current behavior: today an image with an asset-map entry and no credit is emitted. Existing tests assert exactly that ("resolves image marker by lesson and sequence"; the sparse-marker gravity test), so `flutter test test/tool test/tools` goes red unless they are rewritten. The plan lists only new tests, which invites narrowing the rule to keep old tests green. | `test/tools/markdown_portable_text_test.dart:145-181` (asset map without `creditKey`, expects the image block), l.324-375. | Say that the existing image tests gain a matching credit entry, and one existing case becomes the drop case. |
| L3R4-5 | note | L2 W3 §8; L3-W3 Task 8 | L2 W3 §8 still ends "Each W4 family switches its own screens to `proForActiveExamProvider`"; L3 now says families switch their gates and "W4f has no gate". L3 is narrower than L2. | L2-W3 l.124; L3-W3 T8. | Change L2 W3 §8 to "its own gates" and note W4f keeps plan status on the any-plan flag. |
| L3R4-6 | note | L3-W4h Task 4 | The new Text grep is line-based, so `Text(` with the string on the next line (common after `dart format` on long strings) is missed, as is a raw error passed to a SnackBar or helper through a variable. On 1f79d880 there are no such cases (a broader search for interpolated `$e`, `$err`, `$error` in presentation strings finds only a `debugPrint` and a `StateError`). The check is a sweep that backs each family's own inventory, so the gap is small. | Snapshot greps; L3-W4h T4. | Optionally add `grep -rnE "^\s*['\"][^'\"]*\\\$\{?(e\|err\|error\|exception)\b"` or state the grep is a backstop to the family inventories. |

---

## Other checks

- Deadlocks: none. New edge W3 Task 8 before W4h Task 2 on `bootstrap.dart`: W3 in waves 2 and 3, W4h in wave 4. The dependency table has no W3 to W4h row, but the shared-files row and the "Waits inside a wave" rule cover it.
- Open decisions for Aedwon: Season Pass case (W3 T6, W4f T6) and the Sanity upload (W0 T4b) each name Aedwon and the start of level 4. Acceptable.
- Code claims confirmed: `bootstrap.dart:77-83` override; `settings_providers.dart:194` `proRowValueProvider`; `pro_page.dart:26`, `:96`, `:150`; `verify_content_package.dart` three arguments and bootstrap key variable; `build_content_package.dart` writes `content.manifest.json` and `.sig` to its output directory; package paths gitignored at `.gitignore:63-66`.

Not checked:
- Boards were not rendered, so ST_ProCSE_v2 and ST_ProPro content was not inspected; L3R4-1 relies on their names and the plan text.
- No builds, tests or analyzers were run; this is a document gate.
- Settled items outside the diff were not reopened.
