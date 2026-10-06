# L2 W5: release checks

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main b52757bf.
Parent: strategy B2, B4. Depends on: all of W4 complete, and W3.
Spec: amendment spec (approved Oct 5); release-first cuts
(`docs/superpowers/decisions/2026-10-01-release-first-cuts-log.md`); the E04 to E14 plans
(`docs/superpowers/plans/2026-09-07-e04-e14-content-protection-quiz-launch-release-plan.md`).
Traceability rows: every row with workstream `W5` (A-B5a, S0-43, S0-49, X-18 added Oct 6).

## 1. Purpose and scope

Produce the release evidence for internal beta on the new design: the checks that were already
required, retargeted to the new screens, plus iPhone testing.

In scope:
- E09 functional phone checks #22 to #28 on the new screens, and the Redmi responsiveness smoke
  check (replaces the low-end performance gate, Oct 1).
- E10 release end-to-end once (not three times, Oct 1), E11 to E14 including exact signed-artifact
  verification (E12, E13).
- Content protection identity proof (CP-T5) redone on the release package W5 builds (amended (level 3 gate review 2)).
- A01 sync and account, A02 App Check, A03 purchase and restore on the test track, covering the tier
  spec cases: each Student and Civil Service plan, the Monthly trial and its absence after a lapse,
  a Student to Civil Service upgrade, a pass purchase and its end date, refusal of a pass with no
  published sitting, and restore, A04 device smoke, A07 deletion and privacy; A05 accessibility and A06 notifications and
  device runtime as smoke checks (Oct 1).
- The four kept release end-to-end tests (Firebase sync, mock resume, quiz state and delete,
  shipping cold start) from `archive/pre-restart-kept-work`, retargeted to the new routes (S0-43).
- iPhone testing over Xcode wireless debugging (S0-49): the iOS build on the integration branch,
  pairing, and the same functional checklist on the iPhone; the September iPhone QA design
  (`web/ios-physical-qa-enablement-r1`) is the starting point.
- Abuse checks (added Oct 6, abuse review 1): release builds use Dart `--obfuscate` with
  `--split-debug-info` (symbols kept privately for crash reports); every abuse case in W3, W4g and
  W6 (AC ids) re-checked on the final build, with evidence; the accepted risks (patched app unlocks
  local features, content extraction, local Free mock limits, copied shares, new Google accounts for
  trials, fresh share-link limits for new anonymous accounts, refund-then-stay-offline keeping Pro until the old paid-period end plus 3 days: up to
  a year on Yearly), and, as an open decision with the lead's recommendation to accept, clock
  setbacks hidden by a reboot before every session (W3 AC-1) listed for Aedwon's acceptance at E14 with the bootstrap-key risk; the deployed
  functions, Firestore rules and storage rules revision for each Firebase project recorded and
  compared with the integrated commit (gate L2A-21). Re-check on the final build that RevenueCat's webhook URL points at the deployed function and that claims match RevenueCat (the first-deploy checks are W3's deploy steps).
- Release blockers: every `PlaceholderFigure` replaced by Aedwon's values (R-20); `functions` tests
  green.

Out of scope: fixes. A check that finds a defect creates a new work item that enters at the level
its change requires (strategy B2).

## 2. Inputs

The E04 to E14 plan and its evidence formats; release-first cuts; amendment spec; tier pricing spec
(`specs/2026-10-06-tier-pricing-design.md`); release package
identity (W5 Task 1); W3 test-purchase setup; traceability rows above.

## 3. Contracts owned

| Contract | Definition |
|---|---|
| Release evidence format | One record per check in `docs/superpowers/plans/new-design/release-evidence/`: check id, exact source SHA, artifact hash, device and OS, steps, result, pasted output or Aedwon's screenshot reference, date. Evidence from before the new design is not reused as a pass. |
| Blocker list | The placeholder list, open defects and missing evidence, kept in one table that the SSOT links. |

Contracts consumed: W0 baseline; the release package (W5 Task 1); W3 products and test track; every W4 route.

## 4. Behavior

No product behavior. Device checks need Aedwon's phones and hands: the lead writes numbered
instructions and Aedwon performs them (WORKFLOW "Computer control"); the lead never captures app
screenshots. Wireless iPhone pairing is unverified until tried (S0-49).

## 5. Motion

None.

## 6. Acceptance

Every check in section 1 has a passing record for the exact candidate artifact, or a recorded
defect that blocks release. Independent review of the evidence before the release decision, which
remains Aedwon's.

## 7. Risks and stop conditions

- A check needs a value only Aedwon has (placeholder figures, store setup): stop and ask.
- The iOS build fails on the integration branch: record it as new work at level 2 (likely W1 or W0
  scope) before continuing iPhone checks.
- Any deploy (functions, rules, Remote Config) or store upload needs Aedwon's approval.
- Publication is a separate decision (WORKFLOW "Completion permissions").

## 8. Files and directories

`integration_test/release/`, `test_driver/` if needed, `docs/superpowers/plans/new-design/release-evidence/`,
`tools/release/android/release.sh` (obfuscation flags, abuse review 1), iOS project settings only as the iPhone check requires (any change is a reported finding first). Amended Oct 6 (level 3 gate review 1) (L3-7): `lib/app/firebase_bootstrap.dart` (iOS options per the September iOS design) and the generated iOS Firebase options files.

## 9. Order and parallelism

Last. Starts when every W4 family and W6 have integrated and the combined checks pass.
