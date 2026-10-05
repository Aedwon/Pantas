# Level 2 independent overlap counting check

Status: PASS for mechanical counts and source-link integrity against the frozen Level 2 inputs below. This check does not validate semantic equivalence or lesson-body reuse. No Level 3 work is included.

## Identity and inputs

- Policy: `cb48097bedf15bec2cfbe4fb3aa7e957753b1727` (current `origin/main`).
- Audit checkpoint: `2cc836b1e1cca4c2533c29531057b668b4696f81`.
- Corpus metadata: `765c5dc0fa5586281047bf4f7b30d09ab3707887`.
- Accepted Level 1 manifests: `map-input-manifest.json` (13 file hashes) and `requirement-input-manifest.json` (10 file hashes). Every listed file existed and matched its recorded SHA-256.
- Frozen Level 2 manifest: `overlap-input-manifest.json` (6 file hashes). Every listed file existed and matched its recorded SHA-256.
- `overlap-data.json` also lists 25 input hashes. All 25 matched the current files.
- `level1-publication-readback.json` confirms 200 nonempty paragraphs, exact draft text, 158 lesson bullets, zero style/bullet mismatches, and exact preservation of the original tab.

Key SHA-256 values at check time:

| Input | SHA-256 |
|---|---|
| `overlap-data.json` | `10d7f14fb4e1c8e59721ac1fecd533be3c480f822c7f54b6a60e1fa688bbaa8e` |
| `overlap-input-manifest.json` | `07c58b02729c221c9befb819cb94ca8a7d599e8110249cc6d4d90536432a4304` |
| `map-input-manifest.json` | `7033ba5feae5a2780da176e20f9714cf56a92fd1e33732f4118ba2f0c465976c` |
| `requirement-input-manifest.json` | `f47c0ee3481607a26619e2f66d1d054ccc7a869e80b98de911c95fd8fbf36531` |
| `lesson-exam-tags.json` | `9ea1b39172e722f0297f432766f094c717279df636255fac0302e5964a3d3e74` |
| `requirement-map.json` | `023a24c7c6b21ae809d38542869b81b9f466cf089bc5f50927d34b1e192a3493` |
| `inventory-lessons.json` | `4c26a6655ab6f288a0c758eeccd3ceb308e58ae83251773dd57ea4a939edc414` |
| `level1-publication-readback.json` | `a1dbc9f567ee316122b7ac7e54adf34b6b5d6c1659480c09dc98c47fd32a45f5` |
| `overlap.md` | `ad01e39a210c6f21527b51c37779693cfcda804fe47cf7f57a1ef0f0a3a2aa3f` |
| `overlap-lessons.md` | `a92ebe7a5935570b19c54eb70ddef0e72762abbbf34fb0d238687e6c4d1d9520` |

## Independent method and commands

I derived each exam's candidate lesson set directly from `lesson-exam-tags.json`, then recomputed all intersections, differences, per-subject and per-topic sets. I compared those sets with `overlap-data.json`, both Markdown reports, the requirement map, and the inventory. I did not import or run the lead generator.

Commands used:

- Inline Python 3 check (`python3 - <<'PY'`): independently derive sets; validate pair symmetry, subject/topic sets, lesson rows and evidence; compare report tables; validate CSE references, manifests, input hashes, and publication proof.
- `shasum -a 256` on the ten files listed above.

The two unmapped lesson rows say “none assigned” in the Markdown ledger. The parser was adjusted to recognize that literal; the corrected comparison found no mismatch. The pair-table extraction was likewise scoped to the pair table labels; all 36 values then matched. These were parser-scope corrections, not input or report defects.

## Counts and comparisons

- Lessons: 158 unique tag rows, with exactly the same 158 ID/path pairs in the inventory, overlap data, and Markdown lesson ledger.
- Membership partition: 2 have no candidate edge; 19 have one; 137 have multiple; 34 appear in all nine exam maps.
- Candidate memberships: 819 across UPCAT, DCAT, ACET, USTET, PUPCET, DOST-SEI, SM Foundation, CSE Professional, and CSE Subprofessional.
- Pairs: all 36 unordered exam pairs appear exactly once. Every shared set equals the recomputed intersection. Both map-only sets equal their directional differences. The 36 report rows match the three stored pair counts.
- Subject and topic sets: all 6 subject sets and 25 topic sets match their per-exam recomputation. The report's 6 subject rows and 25 topic rows match the data, including candidate counts.
- Lesson evidence: all 158 ledger entries match the accepted tag IDs and paths. All 408 distinct referenced requirement-record IDs exist in the 535-row evidence index and retain the correct exam identity. No unknown, context, constraint, or out-of-scope status creates a candidate edge.
- CSE common core: 13 named topics, each with one valid record for each CSE exam; all 26 references exist in the evidence index.
- Publication proof: positive as recorded above.
- Errors after parser corrections: 0.

No mechanical discrepancy remains. The counts establish candidate-set overlap only. They do not establish equal tested depth, full lesson coverage, exclusivity, or full-body reuse. The separate semantic review's requested annotations remain outside this counting result; if accepted Level 2 inputs change, rerun this check against their new hashes.

## Targeted recheck after Level 2 annotations

Status: PASS against the revised eight-file manifest. This addendum supersedes the earlier six-file target hashes above for current acceptance. It rechecks mechanical memberships and references only; semantic interpretation remains with the independent Sol reviewer.

Policy and corpus identities remain `cb48097bedf15bec2cfbe4fb3aa7e957753b1727` and `765c5dc0fa5586281047bf4f7b30d09ab3707887`. Audit checkpoint remains `2cc836b1e1cca4c2533c29531057b668b4696f81`.

The current `overlap-input-manifest.json` lists eight targets. Each file exists and matches its listed hash:

| Target | SHA-256 |
|---|---|
| `overlap.md` | `7ff5a1df75844d9b4ef64959808b3d7253edccfc61f517272b4d718c9ba417be` |
| `overlap-data.json` | `53e9dd5b7499e2a84ab0bdee1e237e3dcdbb2227530a4679f37d47d23af56d08` |
| `overlap-lessons.md` | `cf8b1ca519c98421de17477b07bce9541a1092211ebcd6e4a813fcf4f18508e5` |
| `build_level2_overlap.py` | `ab897cc30196270d96a088ef86eda0e3bf283377b69be37172454405437b1513` |
| `overlap/cet-scholarship-scope.md` | `ded3f7df7691a2fa44780517813018445bf037e08b8b2e7f2653d8babfc9ada4` |
| `overlap/cse-scope.md` | `b34814c6993a7e803b2685d1c44a3fc8dce9801cca3ac4e5ae96235cc971fbf4` |
| `enrich_level2_overlap.py` | `c08a8b1ad9c6607f66eda419392c2c9257524d1e40957b3f3ae9aacd07cb4d62` |
| `overlap-pairs.md` | `a32171af63e2f40774fa148757103ac4a7716f74fbf9f2933fa003966c4949a6` |

The accepted 25 input fingerprints and 23 Level 1 map/requirement manifest files remain unchanged and match their recorded hashes.

Recheck commands:

- Inline Python 3 check (`python3 - <<'PY'`): verify eight manifest hashes; independently recompute candidate sets and counts; validate every pair's bilateral facet edge, exam-specific scope/language references, single-map facet edges, visible report and ledger text, source index, and subject/topic sets.
- `shasum -a 256` on the eight manifest targets.

Results:

- All 36 bilateral contrast facets point to the stated lesson and to one accepted positive edge for each pair exam. Each scope and language reference exists in the 535-row source index and belongs to its stated exam.
- All 19 single-map report rows identify distinct one-map lessons. Each row's cited record is a positive accepted edge for that exam. Each facet statement and record is visible in its matching lesson-ledger row and in the report table.
- The source index has exactly the same 535 IDs as the accepted requirement map. Every checked per-exam source reference has the correct exam identity.
- Counts remain 158 lessons, 36 pairs, 819 candidate edges, 137 multi-map candidates, 19 single-map candidates, 2 unmapped lessons, 34 all-nine candidates, 25 topics, and 6 subjects. Pair intersections/differences and subject/topic sets still match independent recomputation. Existing pair, subject, and topic report counts remain in parity.
- Errors after correction: 0.

One first-pass text lookup produced 19 false “not visible” flags because it matched lesson IDs against a partial line pattern. I reran the check by extracting each ledger ID/path record; all 19 facet statements and references were present. This was a checker lookup error, not a missing annotation.

Final result for this recheck: PASS. No semantic conclusion is made about whether the stated facets capture organizer intent. No content-body, Level 3, or standards check was performed.

## Narrow R1/R2 wording and citation recheck

Status: PASS against the latest eight-file manifest. This preserves both earlier recheck records and verifies the latest singleton wording and paired scope citations. It did not rerun upstream source research or inspect lesson bodies.

The eight current manifest hashes all match:

| Target | SHA-256 |
|---|---|
| `overlap.md` | `b1e9584b71674cd5793fc22ea1491f7f150f4013947f758f0e3320a20e144ef2` |
| `overlap-data.json` | `d9e6aeb4b7775bcad005d5096262f1dee37597c9f85606658f9ae67c7604d179` |
| `overlap-lessons.md` | `3d04f12a691e3977da11eec150b834ebe1b82c5d41568aa118e3410299928ace` |
| `build_level2_overlap.py` | `ab897cc30196270d96a088ef86eda0e3bf283377b69be37172454405437b1513` |
| `overlap/cet-scholarship-scope.md` | `ded3f7df7691a2fa44780517813018445bf037e08b8b2e7f2653d8babfc9ada4` |
| `overlap/cse-scope.md` | `b34814c6993a7e803b2685d1c44a3fc8dce9801cca3ac4e5ae96235cc971fbf4` |
| `enrich_level2_overlap.py` | `e4e302d0b499873f83ad2492ddb438ba4f604256fe1e154aa4aff1763f0197b6` |
| `overlap-pairs.md` | `67719ff823a4fa55668d311424c78163677578f1b3d6cd625c068d0d8a2c672b` |

The 25 accepted fingerprints and 23 accepted map/requirement manifest files still match. The publication proof remains positive: 200 nonempty paragraphs, 158 lesson bullets, exact draft text and original preservation, and zero style/bullet mismatches.

Checks run:

- Inline Python 3 validation (`python3 - <<'PY'`) checked all eight manifest hashes, the 25 and 23 unchanged input hashes, recomputed candidate sets and report tables, checked pair evidence and per-exam source identities, and compared the report, ledger, companion, and generator configuration.
- The generator configuration was parsed with Python `ast` and `ast.literal_eval`; the generator was not executed.
- `shasum -a 256` checked the eight current manifest targets.

The latest annotations pass these checks:

- The four added references have correct roles and exam identities: `upcat-L185` and `upcat-L196` appear in eight UPCAT scope groups each; `cse-professional-L091` appears in eight CSE Professional scope groups; `acet-L042` appears in eight ACET scope groups. Every reference exists in the accepted 535-row source index.
- All 36 helper/data pair configurations agree on common-facet records and scope/language summaries and reference sets. Record order differs in some lists, so comparison used sets. All 36 companion sections display their configured facet, scope, and language records.
- All 19 singleton notes agree across helper configuration, structured data, report, and the matching lesson-ledger row. Their cited records are positive edges for the listed exam.
- Recomputed totals and tables remain unchanged: 158 lessons, 36 pairs, 819 memberships, 137 multi-map, 19 single-map, 2 unmapped, 34 all-nine, 25 topics, and 6 subjects. Pair intersections/differences, subject/topic sets, and the 36/6/25 report table rows match.
- Errors after order-insensitive helper comparison: 0.

A first helper comparison required identical list ordering and reported 24 false mismatches. The entries contained the same records in different orders. Set comparison resolved them without changing inputs. A separate verifier invocation then hit an undefined variable in its final print statement after its assertions; the complete corrected invocation finished with zero errors. These were verifier issues, not input discrepancies.

Final result at the latest hashes: PASS. This confirms mechanical consistency and source-reference identity. It does not judge the semantic quality of the findings. No Level 3 or content-body check was performed.

## Final presentation identity and continued count PASS

Status: PASS at the final presentation hashes. The final presentation changed only the Level 2 status fields and report header/check/gate text. Pair, lesson, facet, evidence, and count content remains unchanged.

The eight current Level 2 target hashes all match `overlap-input-manifest.json`. Key current hashes:

- `overlap-input-manifest.json`: `1f55fc62691694c84fc2e248fc17879c75f46cb38a86afdeeee2d4ff5a707b76`
- `overlap.md`: `4f10e7c0d64115dac5c3e28f22e2bdcaa22f06172ec7e0c4590c4fdcec1051ab`
- `overlap-data.json`: `77b838650fe0f97f6b1c109b38da89d45284d28def569941d0aeb19d40834e11`
- `level1-publication-readback.json`: `a1dbc9f567ee316122b7ac7e54adf34b6b5d6c1659480c09dc98c47fd32a45f5`

To check that the comparison data did not change, I loaded `overlap-data.json` in memory, restored its prior status string, serialized it with the recorded JSON formatting, and hashed those bytes. SHA-256 `d9e6aeb4b7775bcad005d5096262f1dee37597c9f85606658f9ae67c7604d179` exactly matches the reviewed-content manifest. No file was reverted or written.

The accepted 25 input fingerprints and 23 Level 1 map/requirement files still match. Independent recomputation retains 158 lessons, 36 pairs, 819 memberships, 137 multi-map candidates, 19 single-map candidates, 2 unmapped lessons, 34 all-nine candidates, 25 topics, and 6 subjects. All pair intersections/differences and the report's 36 pair, 6 subject, and 25 topic rows match. The evidence index still matches all 535 accepted requirement-map record IDs.

The audited-tab readback remains positive for tab `t.38uf83creimq` and corpus `765c5dc0fa5586281047bf4f7b30d09ab3707887`: 200 nonempty paragraphs, 158 lesson bullets, exact draft text, exact original preservation, and zero style/bullet mismatches. All 19 local report links resolve to existing targets and headings.

Current command evidence: inline Python 3 (`python3 - <<'PY'`) for the status-reversal hash, current manifests, counts, pair/topic/subject parity, source index, publication proof, and report links; `shasum -a 256` for the current manifest, report, data, and publication proof. Errors: 0. No full source reexecution, body reading, or Level 3 check occurred.

Final result: PASS for Level 2 counting and presentation identity. This check does not make a semantic claim beyond the independent review record.
