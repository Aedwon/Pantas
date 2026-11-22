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

## Decision (manager, Nov 22, verbatim)

"go with C, no Fable needed. Two conditions: Before building, count C's own cost at public scale (rule 7) ...
The 'Sync paused' message is UI, so it must be Claude-built and match an approved pattern. If an existing
approved notice or banner fits, the wording is yours (rule 4)."

## Cost count (rule 7), before building

Prices read Nov 22 from Google's billing catalog: Eventarc lists charges only for Eventarc Advanced (bus and
pipeline events), none for Standard triggers from Google sources such as Firestore; Pub/Sub delivery is free for
the first 10 GiB a month, then $40 a TiB; Cloud Functions 2M invocations a month free, then $0.40 a million;
Cloud Run free tier 180,000 vCPU-seconds a month; Firestore Singapore reads $0.061 a million past 50,000 a day
free. Firestore write price for Singapore was not in the listing read; about $0.2 per 100,000 is assumed (estimate).

Per synced row, option C adds 1 trigger call (about 50 ms), 1 counter write, and a counter read on 1 row in 20.
Rules add no read (the pause flag sits in `sync_state/current`, which they already read).

A normal Pro student (estimate): about 110 synced rows on a study day (50 answers give 50 review logs and 50 card
updates, plus about 10 other rows).

| | Pro students active on the peak day | Trigger calls | Counter writes | Counter reads | Added cost a month |
|---|---|---|---|---|---|
| One normal Pro student | 1 | 110 a day | 110 a day | 6 a day | $0 |
| 500 sign-ups (assume 20% Pro, peak 200 active) | 40 | 4,400 a day, about 130,000 a month | 4,400 a day | 220 a day | $0 (inside every free tier) |
| 5,000 sign-ups (peak 2,000 active) | 400 | 44,000 a day, about 1.3M a month | 44,000 a day | 2,200 a day | about $4 to $5 (writes about $2.6, calls about $0.3, compute about $1.6; Pub/Sub inside its free 10 GiB) |

Every added cost comes from Pro students' own syncing (user-driven, rule 7). Fixed cost: none. Staging proof: the
caps are lowered on staging by an environment value (for example 50 rows), so the abuse run writes about 70 rows
and stays far inside the staging budget; counted again before it runs.

## Build spec (server and rules first; the app message later, in the Flutter slot)

1. Trigger `countSyncWrites` (`onDocumentWritten` on
   `users/{uid}/sync_generations/{generationId}/{collection}/{rowId}`, asia-southeast1, `pantas-jobs`, max 3
   instances): ignore deletes and writes with no `after`; blind `FieldValue.increment` on
   `users/{uid}/limits/sync_<YYYYMMDD UTC>` of `rows`, `bytes` (JSON length of the row) and `h<HH>`; on 1 event in
   20 (hash of the event id) read that document and, if any cap is passed, set `suspendedUntil` on
   `users/{uid}/sync_state/current` to the next UTC hour (hourly cap) or UTC midnight (daily caps) and log one
   warning line `sync paused <reason>` with the uid's public id only.
2. Caps from environment values with defaults: `SYNC_ROWS_PER_HOUR` 10,000; `SYNC_ROWS_PER_DAY` 30,000 (a full
   first push of a long-time student fits); `SYNC_BYTES_PER_DAY` 50 MB. The prod alarm cuts at 100,000 writes an
   hour, so one account cannot trip it.
3. Rules: `canWriteSyncRow` also requires `!(sync_state/current.suspendedUntil > request.time)`; and when
   `sync_state/current` carries `proUntil`, it must be later than `request.time` (the server-owned entitlement).
   Clients still cannot write `sync_state` or `limits` (except the existing `syncGeneration` key).
4. Entitlement mirror: every path that sets the `pro`/`proUntil` claims (betaPro, betaReward refresh, PayMongo
   webhook grants and refunds, RevenueCat claims, web entitlement refresh, web trial) also writes `proUntil` (or
   0 when access ends) to `sync_state/current` when that document exists, in the same place the claims are set.
5. Tests first: emulator tests for the trigger (counts, caps, pause and resume times), rules (paused account
   refused, `proUntil` in the past refused, token-only path unchanged when `proUntil` is absent), and each
   entitlement path writing the mirror (a refund sets it in the past).
6. App message (later, Flutter slot): on a sync refusal while paused, the Backup page's approved status card shows
   headline "Backup paused" and subtitle "You synced a lot today. Backup starts again tomorrow, and your progress
   stays safe on this device." (rule 4: copy inside an approved layout; the card's existing no-action state).
