# M4b: per-account sync quotas and a server-owned entitlement (design)

Owner: security and billing lead (r2). Gate M4b in the CSE public release checklist. Manager, verbatim
(Nov 22): "A and B. One paid account cutting billing for the whole app is a public-launch risk ... B needs the
Flutter slot for its build. Ask me when you reach that step". Source finding: S-15 (private merged report,
Nov 14).

## Problem

1. **Volume.** A Pro account may write any number of sync rows. The prod alarms now cut billing at 100,000
   writes an hour, so one account can take the whole app offline within an hour.
2. **Refunds.** Sync rules trust `pro` and `proUntil` in the caller's ID token, so a refunded account keeps
   sync for up to one token lifetime (an hour).

## Facts that shape the design

- The app writes each sync row in its own transaction (`push_pipeline.dart`: `commitRowIfBaseMatches` per row,
  up to 500 rows a flush). A first push after a new install sends every local row (thousands for a long-time
  student: FSRS cards and review logs).
- Rules already read `users/{uid}/sync_state/current` for every row write (`isActiveGeneration`). Fields added to
  that server-owned document cost no extra read.
- Rules cannot count the writes in a batch or transaction, so an honest per-row count needs either a counter
  tied to the row path or the server.

## Options

| | A. Counter in rules | B. Push through a callable | C. Server-side count with a suspend flag (recommended) |
|---|---|---|---|
| How | Each row transaction also bumps `users/{uid}/limits/syncWrites` (day, rows, last row path); rules require exactly one bump naming this row, and rows under the daily cap | The app sends batches of rows to a `syncPush` callable that checks entitlement and quota and writes them | A Firestore trigger on sync row writes adds to a per-account daily count (sharded by minute); past the cap it sets `suspendedUntil` on `sync_state/current`; rules refuse writes while suspended |
| Stops an abuser | Exactly at the cap | Exactly at the cap | Within seconds of the cap (trigger lag) |
| App change | Yes: every row transaction writes the counter | Yes: the push pipeline is rewritten to call the server | Small: show "Sync paused until tomorrow" on that refusal |
| Extra cost per synced row | 2 rule reads + 1 write | 1 function call per batch, server writes | 1 function call + about 1 write |
| Risk | One document written per row: Firestore's about-1-a-second sustained limit per document makes a first full push slow or fail | Largest change to working sync code | Trigger cost grows with abuse until the flag lands (bounded by the cap and the trigger's instance cap) |

**Entitlement (all options).** Payment and beta-Pro code writes `proUntil` and an `entitlementVersion` to
`sync_state/current` whenever access changes (grant, refund, expiry, beta change); rules check
`get(sync_state/current).data.proUntil > request.time` instead of the token claim. A refund ends sync at the
next write. No extra read, no app change.

**Caps (to confirm from real use before launch):** 5,000 rows and 20 MB a day per account; a first push after
a new install (a new generation) gets its own allowance of 50,000 rows. Above the cap the account is paused
until 00:00 UTC, never deleted.

## Recommendation

Option C plus the entitlement fields. It needs no change to how rows are written, so the app change is one
message on a refusal (the Flutter slot for one build), and it stops an abuser within seconds at a cost that only
grows while someone abuses it. The trigger has its own instance cap, and the existing billing alarms stay as the
backstop.

Estimate: about 2.5 days (server trigger, rules, entitlement writes in four payment and beta paths, tests,
staging proof with a scripted abuse run under the rule 7 count, one app build for the refusal message).
