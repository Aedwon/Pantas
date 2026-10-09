# Level 3 structure counting check

Status: **PASS for frozen lesson/topic/requirement accounting.** This is a mechanical evidence check. It does not accept teaching judgments or close the Level 3 lead gate.

## Pinned inputs

- Policy commit: `1aaebad9814ba7bd9404d8b43fc010281abb97cf` (`origin/main` was at this commit in the assigned worktree). The dispatch lead independently confirmed current `main` and corpus identity. My attempted `git fetch origin main` returned `error: cannot open .../FETCH_HEAD: Operation not permitted`; it did not change a ref or worktree file.
- Read-only corpus: `/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2`, commit `765c5dc0fa5586281047bf4f7b30d09ab3707887`.
- Audit branch: `docs/content-coverage-audit-r1`, worktree `/Users/aedwon/Documents/Projects/Pantas-wt-content-coverage-audit-r1`.
- Frozen input manifest: `docs/content/audit/coverage-r1/structure-final-input-manifest.json`, SHA-256 `1da3feaac8c16b0088855e1ea1b31480a73183ae71d0120189d3784b9ebeb72e`. It names 39 files. All 39 exist and match their recorded SHA-256 values.
- The corpus paths and body SHA-256 values for all 158 manifest lessons match the pinned corpus. The 25 topic-output hashes in both integrated data and tag recommendations match the current topic files.

## Independent accounting

I rebuilt the lesson inventory from corpus Markdown paths and `_id` frontmatter. The corpus contains 158 lesson files, 158 unique IDs, no duplicate or missing IDs, and exact ID and path parity with the 158 manifest lessons.

The accepted requirement map contains 535 unique records: 453 skills, 36 subjects, 42 context records, and 4 scope constraints. All 535 source paths and line numbers resolve to nonblank source lines. Integrated requirement accounting contains the same 535 IDs. Context and scope constraints remain separately classified; they are not missing teaching requirements.

All 25 topic outputs contain one valid JSON appendix and are marked complete. Their assigned lesson IDs occur once each, for 158 unique lessons. The supporting checker also verified full-read ranges, pinned body hashes, evidence paths and line bounds, valid requirement references, prerequisite targets, both-end evidence, self-link absence, and graph acyclicity.

The integrated findings preserve local teaching facets and their source references separately from examples, prior knowledge, deferred Level 5 practice, and unknown runtime or required depth. The integrated data records 373 rows with observed local facets under source limits. Practice remains deferred and runtime availability remains unknown. This count check makes no teaching or exam-depth judgment.

The outline accounts for 158 existing lesson IDs. Its recorded structure counts are 126 retain, 19 split-candidate, 9 reorder, and 4 merge-candidate verdicts. The merge candidates form two source-unit pairs. No new lesson ID is proposed as an existing ID.

Prerequisite JSON has 158 lesson keys, 31 edges, and 24 linked consumers. The graph has no self-links or cycles. The Markdown table has 24 consumer rows and each link carries consumer and foundation evidence. The no-prerequisite list has 125 `none-found` lessons. The JSON has 134 empty arrays because it also includes eight `missing-foundation` and one `unresolved` lesson; the Markdown shows those caveats separately. Thirteen lessons have 14 missing-foundation entries. Four of those lessons also have verified prerequisite links.

The source ledger reports 196 fact/scope rows and one separate access-only note. Its 13 non-ID group labels are preserved with existing lesson IDs or evidence paths. The separate `chemistry-topic` row is the access-only note, not a fact/scope record. The Level 3 integration counts record 25 topics, 158 lessons, 31 links, 24 consumers, 196 ledger rows, and one access note.

The 158 lesson tag recommendations preserve the accepted provisional tags and lesson paths. Each referenced requirement ID exists, and each recommendation distinguishes scoped body evidence from confirmed exam scope. All 158 body assessments are complete-phase evidence records; they do not assert practice or runtime checks. The accepted `lesson-exam-tags.json` was not changed.

The accepted ten-input requirement manifest has no missing files or hash mismatches. The filled branch profile matches both its accepted SHA-256 and the durable audit copy byte-for-byte. The separate policy fingerprint in `structure-input-manifest.json` refers to the main template, not the filled branch profile. The requirement map and overlap artifacts match their audit-checkpoint hashes.

## Commands and actual results

Command:

```text
python3 docs/content/audit/coverage-r1/check_level3_outputs.py
```

Actual result:

```json
{
  "level": 3,
  "completeTopics": 25,
  "expectedTopics": 25,
  "completeLessons": 158,
  "expectedLessons": 158,
  "pending": [],
  "errors": [],
  "mechanicalAccountingReady": true,
  "gateReady": false
}
```

The checker also printed all 25 completed topic keys. `gateReady` is false because the lead semantic gate is not accepted. This check does not change that gate.

Independent inventory command used Python `pathlib`, frontmatter `_id` parsing, and SHA-256 comparisons against the frozen manifest and pinned corpus. Actual result:

```text
corpus lesson files 158 unique frontmatter IDs 158 duplicate IDs 0 missing IDs 0
manifest IDs 158 set equality True path equality True
unmanifested corpus IDs 0 missing corpus IDs 0
requirement source rows 535 source line errors 0 []
```

Independent prerequisite result:

```text
lessons exact unique 158; prerequisite JSON keys exact True
empty JSON arrays 134; nonempty 24
status: none-found 125; links-found 24; missing-foundation 8; unresolved 1
missingFoundation: 13 lesson rows, 14 entries; 8 missing-foundation, 4 links-found, 1 unresolved
table/JSON target membership parity: 24 rows match; two multi-link rows list the same targets in a different order
invalid targets []; self-links []; both-end evidence errors []; cycles []
```

Independent accepted-tag result:

```text
recommendation IDs equal accepted-tag IDs: True (158)
lesson path mismatches: 0
original provisional-tag mismatches: 0
invalid requirement references: 0
body assessment status: complete evidence 158; practice deferred Level 5; runtime unknown
```

Accepted Level 1 identity check:

```text
accepted requirement inputs 10; missing/hash mismatches []
profile current matches accepted manifest: True
branch profile SHA-256: 9dcc230d6c3a7fced854485a3309d3b35ddecebe6d12d8898749056c84661937
durable audit copy SHA-256: 9dcc230d6c3a7fced854485a3309d3b35ddecebe6d12d8898749056c84661937; byte-equal True
```

`structure-input-manifest.json`'s `d709f3f0944c59ae1906a4e03cfb3718df7ec8a8` value is the main policy template's Git blob fingerprint. The filled audit-branch profile is a separate artifact, as recorded in the accepted requirement manifest.

The canonical Dart attribution checker scans all tracked files and has no scoped-path option. Running it would read outside this assignment's audit output list. I inspected its current marker patterns and exemptions. I used those exact prose-marker patterns and exemptions on the scoped audit output list, plus a scoped em-dash and spelling scan. That is an explicitly identified equivalent, not a Dart checker pass.

Actual scoped scan command: an inline Python scan applying those exact marker patterns and exemptions to the 39 frozen-manifest files plus this report. Actual output:

```text
scoped files 40 missing []
em_dashes []
non_American_spelling_hits []
attribution_marker_hits []
```

No files were changed except this assigned report. No question bodies were read. No findings were fixed.

## Final acceptance-metadata confirmation

Policy and workstream identity were refreshed from cached `origin/main` at `1aaebad9814ba7bd9404d8b43fc010281abb97cf`; audit `HEAD` remains `c8983d6d7f36a87f618f0654321cb84a030f57c5`. No Git fetch or mutation was performed.

Current manifest: `docs/content/audit/coverage-r1/structure-final-input-manifest.json`, SHA-256 `8a5b2624f109dafdfa54c82b2703accf4bf1aa87fb48d4356d2d20eaf9fb57b3`. Reviewed prior manifest: `docs/content/audit/coverage-r1/structure/structure-final-reviewed-input-manifest.json`, SHA-256 `1da3feaac8c16b0088855e1ea1b31480a73183ae71d0120189d3784b9ebeb72e`.

I rebuilt both 39-file hash sets. Their paths match exactly. All 39 current files match the current manifest. The six declared metadata changes each match their recorded after hash. Reversing each exact replacement once in memory reconstructs the recorded before hash and the prior reviewed manifest hash byte-for-byte. The other 33 files retain their prior hashes. Result: no unexpected content or evidence changes.

I independently checked the accepted input manifests: requirement inputs 10/10, map inputs 13/13, and overlap inputs 8/8 match, with no missing files or hash mismatches. The refreshed acceptance record reports 25 topic samples PASS, zero FLAGS or PENDING, and lead semantic PASS. Its stated scope and counts agree with the inputs reviewed here.

Fresh supporting command:

```text
python3 docs/content/audit/coverage-r1/check_level3_outputs.py
```

Actual result: `completeTopics=25`, `expectedTopics=25`, `completeLessons=158`, `expectedLessons=158`, `pending=[]`, `errors=[]`, `mechanicalAccountingReady=true`, `gateReady=true`.

The scoped document scan covers the six metadata-edited files, `review/structure-acceptance.md`, and this report. It uses the exact prose marker patterns and exemptions in `tool/check_no_ai_attribution.dart`, SHA-256 `d6fc3df8958ad28148987ebd508cbb8996df3f9828fa3732a98d51eb72125fa7`. The canonical Dart command remains unexecuted.

Actual bounded scan output:

```text
scoped_files 8 missing [] attribution_hits [] em_dash_hits [] non_American_spelling_hits []
```

The seven non-report inputs and checked SHA-256 values were:

```text
469ceabb23f10f5a8e4a90acdab423b39ba13d589725feba205e398efb9983ca  structure-input-manifest.json
cdf36b3c4b5d92748db9ff36f970d344d6625a710a8dc3056b55ecee612dc2df  lesson-structure-data.json
1eb008fd23dceed135408bf6e6fc51e72c1b48496434af1b2ef14186b98fd43e  lesson-exam-tag-recommendations.json
689fda0bdd8eaaca6de229f8aea2d0e6c0dd13bc9f0f7db46582a198be68e445  requirement-reconciliation-decisions.json
86ce65586f58c7993e1c3ed91d210115f4e362129b818af40c96356c81e936cb  lesson-prerequisites.md
f9f5b78edd0eac1cbe5957f946d415e33c76e4d00182e6ac618b827a0c2024f9  lesson-structure.md
aac9151e8c558d85cc6387f2965b82ae6fbe5162b0bb11cd9cf8eed972c3c45b  review/structure-acceptance.md
```

This status-only confirmation is PASS for the exact current frozen inputs. The lead gate is mechanically ready; the current acceptance record stops at the Level 4 approval gate. This check does not authorize later-level work.
