# Pantas payment client hardening checkpoint — 28 August 2026

This checkpoint records the final client-side RevenueCat hardening repair before
integration. It supplements the older project handover without rewriting its
historical state.

## Repository state

- Integration branch: `codex/payments-integration`
- Integration SHA verified unchanged: `3a1ac087fd88bce1e1903d5c7996371054b36094`
- Repair branch: `codex/payments-client-hardening-r1`
- Repair starting SHA: `960d405466a1b2540696ace28749e3d2bfbb3328`
- Regression-test commit: `0f3a4aaba5d4645c9be259c0ce0af97bdf09dd83`

The focused regression file was run locally against the test-only commit after
regenerating ignored Drift output and `assets/seed/content.db`. All six original
regressions failed for the intended production reasons: purchase and restore were
classified as unknown failures when entitlement persistence threw, authoritative
Free threw before updating memory, bootstrap lost an active Pro result when the
local write failed, and inactive CustomerInfo without freshness metadata revoked
persisted Pro.

## Repair contract

The client repair keeps RevenueCat store truth separate from local persistence:

- authoritative entitlement changes update in-memory state and listeners before
  device-preference persistence;
- preference-write failures are retained as pending persistence state and do not
  erase successful purchase, restore, or bootstrap results;
- later authoritative updates retry persistence;
- the real `CustomerInfo.requestDate` from `purchases_flutter` 10.8.0 is carried
  into the client snapshot;
- active Pro may affirm Pro regardless of CustomerInfo age;
- inactive CustomerInfo may revoke an already confirmed Pro only when its request
  date is not in the future and is no more than five minutes old;
- missing or stale inactive request dates preserve the previously confirmed Pro;
- configure, listener updates, login, purchase, and restore use the same authority
  rule;
- purchase and restore keep their typed operation status even when stale inactive
  data is not allowed to revoke the existing confirmed Pro.

## Verification required before integration

Do not integrate this branch until the focused payment tests, relevant broader
paywall tests, analyzer, formatter check, `git diff --check`, and
`tool/check_no_ai_attribution.dart` all pass from the final repair SHA. The
integration branch must remain untouched during this repair.
