# Level 3 gate review 3 (closing check)

Reviewer: independent tier-2 reviewer (SUBAGENTS Part 7b); not an author of the reviewed documents. Date: October 6, 2026.
Policy revision read: origin/main 8973cda5 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md Part 7b). Main checkout clean, HEAD equal to origin/main.
Code branch checked: `origin/integration/new-design-r1` at 1f79d880 (read with `git show`, `git grep`, and a `git archive` snapshot in the scratchpad for running greps).
Scope: review 2 items L3R2-1 to L3R2-13, the review 1 items review 2 marked "partly", and `git diff cd66ea22 8973cda5` (19 files plus the review 2 file). Gate rules: strategy B5.
Nothing was edited, committed or pushed in the repository.

Totals: Part A: 11 resolved, 7 partly, 0 not resolved (18 items). Part B: 0 blockers, 4 should-fix, 7 notes.

Gate verdict: does not pass (4 should-fix).

Count note: review 2's header says 6 review 1 items were "partly", but its table marks five (L3-6, L3-8, L3-12, L3-16, L3-20). All five are checked below.

---

## Script and hygiene evidence

- Review 1 script `t3.py` rerun on 8973cda5: 833 rows, 0 malformed, 0 violations. Counts unchanged from review 2 (W4a 62, W4d 92).
- Board and other split by awk on `traceability.md`: W4a 17 boards, 45 other; W4d 46 boards, 46 other. Matches the amended L2 headers.
- Added lines: 0 em dashes, no British spellings from the AGENTS list. Commit 8973cda5 has no attribution trailer.

---

## Part A. Review 2 items and review 1 "partly" items

| ID | State | Evidence |
|---|---|---|
| L3R2-1 | partly | Fixed: L3-W0 T4b now names `tools/content/markdown_portable_text.dart` (exists; imported by `build_content_export.dart:8` and `build_dev_seed.dart:15`), the test `test/tools/markdown_portable_text_test.dart` (exists), the command with an output argument (`build_content_export.dart:62-64` accepts 1 or 2 args, so `"$TMPDIR/export.json"` is valid; a missing `assets.json` gives an unconfigured map, `build_content_export.dart:425-427`, `lesson_asset_map.dart:90-94`), checks `test/tool test/tools` (both folders exist), the `assets.json` fact, and the Sanity stop with Aedwon and "start of level 4" named. Open: the test contradicts the "does not ship" rule (L3R3-4); L2 W0 §1 "In scope" still omits the credit work and L2 W0 §8 still names only `lesson_asset_map.dart` (L3R3-5). |
| L3R2-2 | partly | L2 W0 §1, §6, §7 amended (optional build; conditional verify; W0 completes without it). L2 W5 §1 and §2 amended. L3-W5 T1 gained a Checks line with verify, sequence and placeholder test (`placeholders_test.dart` is created by L3-W2 l.74). Residual: L2 W5 §3 still says "Contracts consumed: W0 package" (L3R3-6); the verify step is not a runnable command (L3R3-7). |
| L3R2-3 | resolved | L3-W4h T4: `grep -rnF 'Error: $'` and `grep -rnE '(e\|err\|error\|exception)\.toString\(\)'`, single quoted. On a 1f79d880 snapshot: 5 and 18 hits, all real error displays or error-state writes, including `mock_start_route.dart:584` `error.toString()`. Residual word-boundary gap: L3R3-8. |
| L3R2-4 | resolved | Map row now "W4b `/paywall` removals / W4f Task 7 deletions / any still left go in W4f Task 9"; W4f T7 says "W4g has none"; W4f T9 adds the leftover deletion "now that W4b has landed". W4b is wave 4, W4f T9 is wave 5. No W2 fallback text remains (`grep -i paywall L3-W2*.md L2-W2*.md`: none). |
| L3R2-5 | partly | W3 T8 now lists call sites with owners, the contradictory "both getters' call paths" sentence is gone, headers added to W4c, W4e, W4f, W4g, and L2 W3 §8 names the roadmap files and route files. But the list misclassifies the mock gate wiring in `bootstrap.dart` as sync eligibility (L3R3-1), and it both keeps and switches the Settings Pro row and switches the Pro page (L3R3-2). |
| L3R2-6 | partly | W3 T6 records the lead default, names Aedwon and "the start of level 4", and gives a stop rule if he chooses otherwise; the restart log records it. This is an acceptable open decision. But no W4f task draws the line the default requires (L3R3-3). |
| L3R2-7 | resolved | L2 W4a l.5 "62 rows (17 boards, 45 other items)"; L2 W4d l.5 "92 rows (46 boards, 46 other items)". Matches the counts above. |
| L3R2-8 | partly | Map rows for `quiz_routes.dart`, `mock_routes.dart` (W3 Task 8 first) and `settings_routes.dart` (W3 Task 3 first) added. L2 W3 §8 names `quiz_routes.dart` and `mock_routes.dart` but not `settings_routes.dart` (L3R3-9). |
| L3R2-9 | resolved | L3-W1 T2 has one Checks line. |
| L3R2-10 | resolved | W3 T3 adds `test/features/settings` (holds `pro_page_payments_test.dart`); W4a T4 adds `test/features/settings`; W4d T6 adds `test/core/storage`; W4e T2 adds `test/features/metrics`. All folders exist on 1f79d880. |
| L3R2-11 | resolved | W0 T2 test renamed to `mock_results_test.dart` (constructor defaults; new file, `SectionResult` is in `mock_exam/domain/mock_results.dart:54`); demo writer left alone is stated (`lib/core/dev/dev_demo_switch.dart`). W0 T2 checks run `test/features/mock_exam`. |
| L3R2-12 | resolved | W4e T5 names MK_LastQStrict and its dimmed › line; W4a T5 repeats the back rule (G-a-19); W4b T7 wires Task 2's week-strip tap. |
| L3R2-13 | resolved | W3 T4: "W4f Task 7 deletes the file". |
| L3-6 | partly | Follows L3R2-1. |
| L3-8 | resolved | The two wrong commands named in review 2 (W4h T4, W0 T4b) are fixed. The W5 verify shorthand is a new note (L3R3-7). |
| L3-12 | resolved | Part (b) fixed through L3R2-4; parts (a), (c) to (f) were resolved in review 2. |
| L3-16 | resolved | L2 W0 and L2 W5 now match the L3 decision (W0 build optional, release package built once in W5). Residual stale line: L3R3-6. |
| L3-20 | partly | Follows L3R2-5 and L3R2-6. |

---

## Part B. New problems in the delta

| ID | Severity | Plan and task | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L3R3-1 | should-fix | L3-W3 Task 8; map `bootstrap.dart` row; L2 W3 §8 | W3 T8 puts `bootstrap.dart` under "Keep the any-plan flag ... (sync eligibility)". The read in `bootstrap.dart` is the mock entitlement wiring, the only source of `MockEntitlementSnapshot.proIsActive`, which gates mocks and feeds the roadmap's mock day. Following the plan, a Student Pro student on CSE keeps unlimited mocks, and W3 T8's own test cannot pass through the real wiring. Touches entitlement (Part 7b: tier 1). | `bootstrap.dart:77-83`: `mockEntitlementOverrides = [mockEntitlementProvider.overrideWith((ref) => MockEntitlementSnapshot(proIsActive: ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false))]`, with the comment that `features/mock_exam` cannot import `features/paywall`, so "the wiring lives here". `mock_availability_provider.dart:12` defaults to `proIsActive: false`. `roadmap_inputs_reader.dart:184` reads `mockEntitlementProvider`. No sync code in `bootstrap.dart` (`git grep proIsActive` shows only l.80-81); sync eligibility is `sync_runtime_bootstrap.dart:260`. Map l.75 gives `bootstrap.dart` to W4h Task 2 only; L2 W3 §8 does not list it. | Move `bootstrap.dart` to the W3 list: the override reads `proForActiveExamProvider`. Add W3 Task 8 before W4h Task 2 in the map row and add the file to L2 W3 §8. |
| L3R3-2 | should-fix | L3-W3 Task 8; L3-W4f header and Task 6 | W3 T8 lists `settings_providers.dart` (Settings label) under "Keep the any-plan flag", then tells W4f to switch "the Settings Pro row" to the new provider. Both name `proRowValueProvider`. W3 T8 also tells W4f to switch `pro_page.dart`, and the W4f header says "never `proIsActive`". The Pro page reads the flag for the plan name and the Manage link, not for a gate. Switched, a Student subscriber viewing CSE would see "Free" and lose the direct Manage link, which contradicts ST_SwitchUpgrade ("It replaces your ₱99 plan") and the L3R2-6 default (Manage in Google Play). Touches entitlement and money. | `settings_providers.dart:191-196` `proRowValueProvider` returns `'Pro'` or `'Free'` from `entitlement.proIsActive`. `pro_page.dart:26` `canLinkDirectly = entitlement.proIsActive && ...`; `pro_page.dart:150` `if (!entitlement.proIsActive) return 'Free';`. L3-W3 l.132 and l.137-138. | Pick one for the Settings row and state it once. Keep the any-plan flag for Pro page plan status and Manage. Limit the W4f header rule to gates. |
| L3R3-3 | should-fix | L3-W3 Task 6; L3-W4f Task 6 | The Season Pass default says "the Pro page shows that the Student plan still renews, with Manage in Google Play". W3 may change only switch cases in `pro_page.dart` (map row). W4f Task 6 builds the Pro page and does not mention the line, `studentPlanStillRenews`, or the pending decision. If Aedwon confirms the default, nobody builds it. The open decision itself is acceptable (Aedwon, start of level 4). | Map: "`pro_page.dart` ... W3 Task 3 (switch cases only), then W4f Tasks 6 and 7". L3-W4f T6 text (no pass-over-subscription case). L3-W3 T6 l.224-229 of the diff. | Add to W4f Task 6: when the outcome carries `studentPlanStillRenews`, show the approved line with Manage, with a test; wait for Aedwon's copy and decision. |
| L3R3-4 | should-fix | L3-W0 Task 4b | The task's test asserts that an image with no credit match is emitted with `credit` absent and a log line. The same task says "An image with no credit entry does not ship (D-132: CC BY-SA needs the line)". If the upload includes all seven committed images, the three reading-comprehension images ship without the required credit. | L3-W0 T4b: "with no match, `credit` is absent and the export logs the lesson path" and "An image with no credit entry does not ship". Review 2 evidence: three of seven images have no sources entry. | Choose one: the export drops (or fails on) an image block with no credit, with that test; or the upload excludes images without a sources entry, stated as a step with its owner. |
| L3R3-5 | note | L2 W0 §1, §8 | L2 W0 §1 "In scope" still omits the credit work (the diff added it to §6 acceptance only). §8 names `lesson_asset_map.dart` but not `markdown_portable_text.dart`, which L3 now names as the main file. The amended §1 bullet ends in a sentence fragment ("The rebuild (`assets/seed/content.db`, ... next release sequence).") and §7 has "((level 3 gate review 2))". | L2-W0 l.17-21, l.94-95, l.109, l.129. | Add the credit bullet to §1, the converter to §8, and repair the fragment. |
| L3R3-6 | note | L2 W5 §3 | "Contracts consumed: W0 package and baseline" is stale after the §1 and §2 amendments. | L2-W5 l.50. | Say "W0 baseline; release package (W5 Task 1)". |
| L3R3-7 | note | L3-W5 Task 1 | "`tools/verify_content_package` exits 0" is a folder, not a command. The tool takes exactly three arguments. The same shorthand in W0 T6 is outside the diff. | `verify_content_package.dart:11-13`: `if (args.length != 3)`, usage `dart run tools/verify_content_package/verify_content_package.dart` with payload, manifest, signature (`args[0..2]`). | Write the full command with the three package files. |
| L3R3-8 | note | L3-W4h Task 4 | The second grep has no word boundary, so any identifier ending in `e`, `err` or `error` matches, for example `score.toString()` or `date.toString()`. It also misses raw errors interpolated without the "Error: " prefix, such as `Text('$e')`. On today's branch it has no false hits; new W4 code may add some, and "expected: empty output" would then fail. | Snapshot run: 18 hits, all `e.` or `error.`. Pattern text in L3-W4h T4. | Use `'\b(e\|err\|error\|exception)\.toString\(\)'`, add a third grep for a bare interpolated error (`$e`, `$err`, `$error` inside a `Text(` string), or list the allowed hits. |
| L3R3-9 | note | L2 W3 §8 | §8 now names `quiz_routes.dart` and `mock_routes.dart` but not `settings_routes.dart`, which the map gives to W3 Task 3 first. With L3R3-1 it should also list `bootstrap.dart`. | L2-W3 l.117-123; map l.62. | Add both files. |
| L3R3-10 | note | L3-W4c header; map dependencies | W4c now says its Pro gates read W3's provider, but the map has no "W3 (all) / W4c" row. W4c has no Pro gate in its plan (`grep -i "\bpro\b" L3-W4c*.md`: only the new header) and runs in wave 5, after W3, so nothing breaks. | Map l.22. | Add W4c to the row or drop the header line. |
| L3R3-11 | note | L3-W3 Task 8 | The call-site list says "Call sites on 1f79d880" but leaves some reads unnamed: `how_you_work_page.dart:26`, `why_you_miss_section.dart:24` (W4b, covered only by "rebuilt performance and plan screens"), `debrief_page.dart:45` reading `entitlementProvider` directly, and `session_debrief.dart`/`debrief_providers.dart` taking the flag (covered by `debrief_*` only if read broadly). `router.dart:114` (`_isProRoute`) and the `/review` builder are removed by W1 T7, so they need no owner. | `git grep -n proIsActive` on 1f79d880 (full list in this review's working notes). | Name the remaining files under their owners. |

---

## Other checks

- Deadlocks: none. New order edges: W3 Task 3 before W4f on `settings_routes.dart`; W3 Task 8 before W4d and W4e on `quiz_routes.dart` and `mock_routes.dart`. W3 runs in waves 2 and 3, after W1 integrates (dependency row "W1 integrated / W3's router edits"); W4d, W4e and W4f start in wave 4. W4f Task 9's new leftover deletion waits for W4b (wave 4) and runs in wave 5. With L3R3-1 fixed, `bootstrap.dart` gets W3 (wave 2 or 3) then W4h Task 2 (wave 4): no cycle.
- Open decisions left for Aedwon: the Season Pass case (W3 T6) and the Sanity upload for `assets.json` (W0 T4b) each name Aedwon and "the start of level 4" (restart log l.633-643). Acceptable as recorded. The implementation gaps around them are L3R3-3 and L3R3-4.
- Code claims the diff relies on, confirmed: `markdown_portable_text.dart` exists and both export tools import it; `test/tools/markdown_portable_text_test.dart` exists; `build_content_export.dart` takes `<output.json> [root]`; `lesson_asset_map.dart` has `creditKey`; `entitlement.dart:48` and `revenuecat_sdk.dart:48` getters as quoted; `dev_demo_switch.dart` is at `lib/core/dev/`. Disproved: `bootstrap.dart` as sync eligibility (L3R3-1).

Not checked:
- Boards were not rendered. No builds, tests or analyzers were run; this is a document gate.
- Settled items outside the diff were not reopened.
