# Usage telemetry step 1: opt-in screen views and a private usage digest (Nov 14)

Aedwon asked: "at what screen does a user stop using the app? what do they tend to check first? how much do they
use this feature?" Manager scope: record screen views under the existing opt-in ("Help improve Pantas by sharing
usage data") through the existing telemetry module; build a report that answers the three questions; keep tester data
out of the public repo. The in-app notice already covers "the screens and features you use", so it does not change.

## Facts found (lead, from the code and the project)

- The opt-in gate is `GatedTelemetry` (lib/core/telemetry/gated_telemetry.dart) over `FirebaseTelemetry`, which sends
  events to Firebase Analytics (GA4, prod measurement id G-H9VNWM6S32). Events are a closed enum, `TelemetryEvent`,
  with properties checked by `assertPropertiesAllowed`.
- No BigQuery export exists for pantas-prod (`bq ls` is empty), so GA4 events cannot be read back per visit; the GA4
  Data API has no exit screen. A report built only on GA4 cannot answer "where do they stop".
- The speed and error reports go through the `reportClientTelemetry` callable (functions/src/clientTelemetry.ts),
  which validates a fixed contract and writes one structured Cloud Logging line (kind `client_telemetry`), never the
  caller's identity. `gcloud logging read` works from Aedwon's Mac (account aerol.balayon@gmail.com).

## Design (lead decision)

1. Screen names. One closed set of screen ids derived from route templates, never concrete ids or text (for example
   `home`, `study`, `lesson`, `quiz_session`, `mock_session`, `progress`, `settings`, `pro`, `onboarding_age`, ...).
   One function maps a route location to its screen id; unknown routes map to `other`. List every id and its route.
2. Recording. A new `TelemetryEvent.screenViewed` (wire name `pantas_screen_view`; `screen_view` is reserved by GA4)
   with one property `screen`. A router observer (or the existing route shell hook, see lib/app/web_route_shell.dart,
   which already logs `tabOpened`) logs it on every screen change, through the `Telemetry` seam only, so the consent
   gate applies. Repeated views of the same screen in a row count once.
3. Readable copy, still opt-in only. Inside the Telemetry implementation that sits behind the gate, also append the
   screen to a per-visit usage record and send it to a new callable `reportUsageVisit` when the page is hidden or
   closed, and at most every 20 screens: `{v: 1, build, visit_id, screens: [{s, t}]}` where `visit_id` is 16 random
   hex characters made at app start (never stored, never an account id), `s` a screen id from the closed set, `t` the
   milliseconds since the visit started, at most 100 screens per record. No uid, no account id, no free text. On a
   phone build without the callable path, the GA4 event alone is sent.
4. Backend. `reportUsageVisit` in a new functions file beside clientTelemetry.ts, same pattern: App Check, account
   access as the other callables, a validator that rebuilds the record from known fields only (closed screen set,
   bounds), the same per-caller rate limit, one log line with kind `usage_visit`. Tests like the existing
   clientTelemetry tests. It must be added to functions/src/index.ts.
5. The digest. `tool/telemetry/usage_digest.mjs` (Node, no new dependencies): reads `usage_visit` lines with
   `gcloud logging read` for a date range (default the last 7 days), groups by visit_id, and writes a Markdown digest
   with: (a) where visits end: the last screen of each visit, counted and as a share of visits; (b) what they check
   first: the first screen after the shell (and after onboarding for returning visits), counted; (c) how much each
   screen or feature is used: views, visits that reached it, and median time on it. It writes to a private folder
   outside the repository (default `~/Library/Application Support/Pantas/usage-digests/`, overridable by
   `PANTAS_PRIVATE_DIR`), never under the repo, and prints only the file path and the totals. The aggregation is a pure
   function with a unit test on fixture data (fake visits only).
6. Docs: a short `docs/OPERATIONS.md` entry on how to run the digest. No tester data in the repo, ever.

Out of scope here: anonymous counts for everyone (step 2), any change to the notice or the consent switch.
