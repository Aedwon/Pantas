# Legal + RA10173 Implementation Notes

Date: 2026-05-23

Status: local implementation complete; live legal, Sanity, and Firebase validation
remain manual release blockers.

## Implemented Locally

- `/legal/privacy` and `/legal/terms` render in-app fallback legal documents.
- Settings About uses the centralized DPO contact source and does not expose an
  in-app "Export my data" row.
- Account deletion cancels local notifications before named account deletion or
  anonymous local data wipe.
- `AuthRepository.deleteAccount()` requires fresh auth, calls the `deleteAccount`
  callable, wipes local user data, signs out, and starts a fresh anonymous
  session.
- The `deleteAccount` callable is region `asia-southeast1`, App Check enforced,
  replay-token consuming, recent-auth guarded, audit-logged, and recursively
  deletes the Firestore `/users/{uid}` subtree.
- Firestore rules block client deletes of `/users/{uid}`; deletion is callable
  owned.

## Manual Release Actions

- Replace tentative DPO/support/contact identity with production-approved values.
- Complete legal review for the Privacy Policy and Terms of Service.
- Publish approved Privacy Policy and Terms of Service in Sanity, then verify the
  app renders those published documents instead of fallback copy.
- Configure App Check for dev/prod and deploy Functions in `asia-southeast1`.
- Validate the `deleteAccount` callable with a throwaway account: named sign-in,
  recent reauth, local notification cancellation, Firestore user subtree deletion,
  audit log write, local wipe, sign-out, and fresh anonymous session recovery.
- Define DPO inbox handling and SLA for export, correction, objection, and other
  RA10173 requests.

## Scope Kept Parked

- Spec 11 Progress dashboards, analytics, score-impact views, and progress UI.
- v1.1 FCM/server push, FCM token storage, notification sender functions, and
  iOS/APNs setup.
- Self-serve in-app export. For v1, portability requests are handled through the
  DPO email path unless a later authoritative Spec 10 document reinstates
  self-serve export.
- Live Firebase callable validation, RevenueCat subscriber deletion validation,
  production App Check validation, and device QA.

## Data Boundaries

- `app.db` is user data and participates in local wipe/sync behavior.
- `content.db` is regenerable Sanity content only and must not sync as user data.
- Sanity holds legal/content publication data only; no user personal data is sent
  to Sanity by this implementation.
