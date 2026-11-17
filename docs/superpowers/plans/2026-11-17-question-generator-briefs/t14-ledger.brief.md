Task: the ledger part of plan Task 1.4. Problem types get approval entries in the existing ledger, and the content gate fails on an unapproved or edited active type.

Read first: tool/content/approve.dart, ledger.dart, question_hash.dart, content_gate.dart, shipping_questions.dart, tool/checks/content_approval_check.dart, and their tests under test/tool/content/. Follow their patterns; add no dependency.

Build (tests first):
1. Problem type hash: covers the type file bytes, the rule name and ruleVersion, and the variant list bytes. Any change to one variant changes the hash.
2. Approval: `dart run tool/content/approve.dart --root <repo> --types <qt-id,...> --evidence <path>` records a type entry, with the evidence path, in the same ledger file questions use (or a sibling file if the ledger format cannot hold a second kind; say which in FINDINGS.md). Lead-only, same as questions.
3. Gate: every active type (content/types/**, with a list) must have a matching approved entry, else the content gate fails with "not approved" or "edited after approval", the same reasons questions use. Held types (content/types-held/) are not gated.
4. Planted tests: unapproved type fails; approved type passes; editing one variant after approval fails; a held type without approval passes.
5. Do NOT approve any real type. The lead approves after review. The gate will therefore fail on this branch's 15 active types once wired: wire the gate behind the existing check, and in your final message state the exact approve command the lead should run.
