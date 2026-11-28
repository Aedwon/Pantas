# Task 1.4 ledger findings

- Policy: origin/main f417e5f6c438b6f0043386e1124af2a006f20318, confirmed equal to remote main by git ls-remote. Fetch could not write FETCH_HEAD outside the sandbox; cached policy is current.
- Existing approved.json accepts arbitrary IDs and entry fields. Reuse content/question-ledger/approved.json, with kind: problemType on type entries; preserve question entries.
- Existing content-approval check already invokes runContentGate. Extend that gate rather than add a separate check.
- Type approval uses --root <repo>, as assigned. Existing question approval retains --root <content dir>.
- Required Flutter tests cannot build assets: assets/seed/content.db is absent in this fresh worktree. These tool tests use no app assets; use --no-test-assets for focused verification and report the exact required command as blocked. No seed package regeneration.
- RED: flutter test --no-test-assets test/tool/generator/type_approval_test.dart: 3 passed, 7 failed. Active types are ignored by the gate; --types is rejected as usage. This confirms the missing behavior before implementation.
- GREEN: 37 tests passed across the new type approval tests and existing test/tool/content tests, with --no-test-assets. Tests cover unknown IDs, evidence, ledger preservation, multiple IDs, held/disabled/no-list types, byte-only edits, rule name/version and one-variant edits.
- Hash uses byte-exact type and variant data, framed alongside explicit rule name and ruleVersion. It deliberately does not normalize whitespace as question hashes do.
- No real type approved. Type approvals write only the existing ledger, never YAML checkboxes.
- Initial run_checks cannot compile because generated Question/Choice files are missing in the fresh worktree. Generate through build_runner, never by hand, then rerun the check.
- Required scoped analyze: No issues found! (ran in 5.6s). Required format: Formatted 56 files (0 changed). Attribution: check_no_ai_attribution: OK.
- Tool suite with --no-test-assets: 00:49 +254: All tests passed! (test/tool/generator and test/tool/content together).
- Direct content gate reports exactly 15 active types as not approved, with no other findings. This is intentional pending lead review.
- build_runner completed in 46s; generated files remain ignored and are not part of the change.
- Extended content analyze: No issues found! (ran in 3.7s). Additional content formatting: Formatted 13 files (0 changed). git diff --check clean.
- Required flutter test test/tool/generator: FAIL before tests, "No file or variants found for asset: assets/seed/content.db." Alternate verification passed all 254 tests above.
- Required dart run tool/checks/run_checks.dart: expected FAIL content-approval (15), all other checks OK. The 15 findings each say "not approved". Nothing was bypassed or approved.

## Needs the lead

- Review and approve real active types only after the required checker, blind solve and audit. The ledger is deliberately unchanged; content-approval remains red until that approval.
- The asset-dependent required test command cannot pass without the seed asset. Tool tests passed without test assets; no seed package was regenerated.

After review, from this repository root, run:

```bash
dart run tool/content/approve.dart --root . --types "$(rg --files content/types -g '*.yaml' -g '!*.variants.yaml' | sed 's|.*/||; s/\.yaml$//' | sort | paste -sd, -)" --evidence docs/superpowers/verification/2026-11-17-question-generator-ar-types.md
```

This selects the current 15 active type filenames. Held types are outside content/types. Recheck the selection if types are disabled or new files are added before approval.

- Task 1.4 ledger implementation complete, uncommitted and unstaged. Files touched: tool/content/approve.dart, content_gate.dart, question_hash.dart, shipping_questions.dart; test/tool/generator/type_approval_test.dart; FINDINGS.md. No UI, dependency, content question, or real ledger edits.

- Verification follow-up: review supplied NO FINDINGS, so no code fixes requested or rejected. Remote main confirmed f417e5f6c438b6f0043386e1124af2a006f20318 with git ls-remote. Fetch still cannot write the external worktree FETCH_HEAD; cached policy matches remote. Rerunning all five required commands in the current sandbox.
- Follow-up required test command exited 1: No file or variants found for asset: assets/seed/content.db; Failed to build asset bundle. SDK writes now work. No protected seed regenerated. Required format exited 0: Formatted 56 files (0 changed) in 0.07 seconds.
- Follow-up analyze exited 0: No issues found! (ran in 3.6s). Attribution exited 0: check_no_ai_attribution: OK. git diff --check clean. Source HEAD 109065507e11eff736770b910e233fe0a35b1237; existing four modified tool/content files and untracked type_approval_test.dart preserved without edits.
- Follow-up run_checks exited 1 as required by the brief: OK generated-types; FAIL content-approval (15), each active type not approved; every other check OK. No type approved or check bypassed.
- Follow-up alternate test run exited 0: flutter test --no-test-assets test/tool/generator test/tool/content. All tests passed; see summary recorded below. Only FINDINGS.md changed in this follow-up; no implementation edits, staging, commits, or approvals.
- Actual alternate test summary: 00:46 +254: All tests passed!
