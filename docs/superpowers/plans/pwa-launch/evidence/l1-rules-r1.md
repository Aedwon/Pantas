# L1 rules review, round 1

Date: 2026-10-30. Branch `web/l1-rules-r1` from `3e89ec10`. Files reviewed: `firestore.rules`, `storage.rules`.
Method: grepped every Firestore and Storage path in `lib/` (client) and `functions/src/` (Admin SDK), then
compared with the rules. Tests: `functions/test/l1-rules.rules.mjs`, `functions/test/l1-storage.rules.mjs`.

## Path table (Firestore)

| Path | Read | Write | Validated | Client needs it |
|---|---|---|---|---|
| `users/{uid}` | named owner | owner create (`createdAt` = server time only); update of 5 profile fields; no delete | Update now typed and bounded (see F1) | Reads only (`publicId`, `claimsChangedAt`). The client never writes it. |
| `users/{uid}/passes/*` | owner, named or anonymous | none | n/a | Yes, read (pass ledger) |
| `users/{uid}/grants/*` | owner, named or anonymous | none | n/a | Yes, read (web grant ledger). Cannot be closed. |
| `users/{uid}/server/**` (entitlement, trial, answers, answer totals, mocks, reviews, lesson reads, settings, roadmap, study insights) | none | none | n/a | No |
| `users/{uid}/pendingCheckouts/*`, `users/{uid}/limits/*` (read) | none | none (`limits/syncGeneration` write is the Sync stage guard) | stage guard exact | No |
| `users/{uid}/sync_state/current` | Pro owner | none | n/a | Yes, read |
| `users/{uid}/limits/syncGeneration` | none | Pro owner, only with a matching staging generation in the same batch, 5 minute window | exact keys, server time | Yes, write |
| `users/{uid}/sync_generations/{id}` | Pro owner, not deleting | create staging (exact keys); update `preferences` only | `preferences` map of 200 keys or fewer, device id 128 chars or fewer (F2) | Yes |
| `.../sync_generations/{id}/{10 row collections}/*` | Pro owner, not deleting | Pro owner, active or staging generation only; no delete | exact key allowlist, server `updatedAt`, `schemaVersion` 1, `deleted` bool, device and mutation id 1 to 128 chars (F2) | Yes |
| `users/{uid}/proDossiers/*` | none (was Pro owner) | none | n/a | No, nothing writes it (F3) |
| `examTracks/*/proContent/*` | none | none | n/a | No |
| `content/**`, `contentPro/*` (incl. `content/gaps/items/tags`) | none | none | n/a | No (`getContent` callable) |
| `audit_logs`, `publicIds`, `retiredPublicIds`, `passOwners` | none | none | n/a | No |
| `paymongoOrders`, `paymongoCheckouts`, `paymongoPayments`, `paymongoFollowUps`, `paymongoRevocations`, `paymongoSittingMoves`, `webhookEvents`, `webhookRateLimits`, `trialUsedIdentities`, `config/testers` | none | none | n/a | No (default deny) |
| `wrapped_shares/{shareId}` | none | any signed-in user (anonymous too) creates own; owner may only set `revoked` true | id 32 hex, owner, storage path, `revoked` false; keys now limited (F4) | Yes, create and revoke |

## Path table (Storage)

| Path | Read | Write | Validated |
|---|---|---|---|
| `wrapped/{uid}/{fileName}` | none (served by `renderWrappedPage`) | signed-in owner (anonymous too) creates or replaces; owner deletes | now `{32 hex}.png`, `image/png`, 1 byte to 5 MiB (F5) |
| `exports/{uid}/*` | none | none | n/a |
| everything else | none | none | n/a |

## Findings

| # | Severity | Path | Gap | Fix |
|---|---|---|---|---|
| F1 | Medium | `users/{uid}` update | Five allowed fields had no type or size check; an owner could store large or wrong-typed values. | Each field is absent, null, or the right type; strings 128 and 2048 chars; `preferences` map of 200 keys or fewer. |
| F2 | Low | sync rows and generations | `originDeviceId`, `mutationId`, `createdByDeviceId` unbounded; generation `preferences` untyped. | Identifiers 128 chars or fewer (client sends UUIDs); `preferences` must be a map of 200 keys or fewer. |
| F3 | Low | `users/{uid}/proDossiers` | Pro owners could read a path no code writes. | Closed to all clients. Layout test still finds the match block. |
| F4 | Low | `wrapped_shares` create | Extra fields allowed. Any anonymous account could store arbitrary data in a share. | `hasOnly` the five fields the client sends; `archetypeId` 64 chars or fewer; `createdAt` a timestamp. Existing access test unchanged and passing. |
| F5 | Medium | Storage `wrapped/{uid}/*` | Any file type, any name, any size. Open file hosting for anonymous accounts. | Name `{32 hex}.png`, content type `image/png`, size up to 5 MiB. Delete stays owner-only. Client card is 1080x1920 PNG. |

## Not changed, for the lead

- `users/{uid}/grants` and `passes` stay owner-readable. The web client reads both. Closing them breaks the ledger.
  Grant rows are the data the client needs; payment indexes (`paymongoPayments`, `passOwners`, revocations) stay server-only.
- `users/{uid}` update and create are not used by any client code. They could be closed outright, but an existing test
  ("named Free account-root owner behavior remains allowed") expects them. Product decision; not taken here.
- Sync payload fields (`itemsJson` and others) are not type-checked. Firestore's 1 MiB document limit bounds them, and the
  allowlist blocks unknown keys. Typing each field risks rejecting nullable client values; no gap found worth that risk.
- 5 MiB is a ceiling, not a measured size. If real cards approach it, raise it here.
- App Check remains the gate for anonymous Wrapped uploads (L2).

## Tests added

`l1-rules.rules.mjs` (14): server-only matrix (about 40 paths, six client kinds, read, create, update, delete), list denial,
default deny, user root (owner, other, anonymous, signed out, types, sizes, server-owned fields, create shape, no delete),
passes and grants, `sync_state`, row shape and identifier bounds, generation preferences, `wrapped_shares`.
`l1-storage.rules.mjs` (5): owner named and anonymous upload, other and signed out denied, bad type, name, empty and
oversize denied, 5 MiB accepted, no reads, owner delete, `exports` and unlisted paths denied.
Red check: against the old rules, 6 of 19 fail (proDossiers, field typing, identifier bounds, generation preferences,
share keys, Storage shape). All 19 pass on the new rules.
