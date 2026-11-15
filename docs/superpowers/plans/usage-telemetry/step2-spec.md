# Usage telemetry step 2: screen counts in the speed and error reports, behind an off flag (Nov 14)

Manager scope (Aedwon set the goal; legal sign-off pending): anonymous-to-the-account screen counts for everyone,
added to the existing speed and error reports. Each report carries only the screen name, whether it was first or last
in a visit, and a count. No account ID and no chain of screens. The existing Settings switch for those reports also
stops the counts. Built behind a flag that is off. Nothing ships on until Aedwon signs off
`step2-legal-draft.md` (notice wording and the under-18 option).

## Build (lead decisions, final)

1. Flag. One compile-time or config flag, default off, named for what it does (for example
   `screenCountsInClientReports`). Use the app's existing flag pattern if one exists; otherwise a single `const bool`
   in the telemetry folder with a comment naming this spec and the legal sign-off it waits for. With the flag off:
   nothing is collected, and the report payload is exactly what it is today (no new key).
2. Collection. Reuse step 1's closed screen-id set and route-to-id mapping (lib/core/telemetry/screen_ids.dart) and
   the same route hook; do not add a second mapping. Per visit, keep a map screen id -> count, the first screen's id,
   and the current screen's id. Repeated views of the same screen in a row count once, as in step 1.
3. Report. When the existing ClientReporter builds a report (lib/core/telemetry/client_report.dart) and the flag is
   on, add `screens: [{s, first, last, n}]`: one entry per screen opened since the last report in this visit, `s` the
   screen id, `first` true only for the visit's first screen (in the report that carries it), `last` true only for the
   current screen when the report is sent on page hide or close, `n` the count. No account id, no visit id, no
   timestamps, no order (entries sorted by screen id so the array order says nothing). Counts reset after each sent
   report so the same view is never counted twice.
4. Switch. `ClientReporter.enabled` (the Settings switch for speed and error reports, settings_providers.dart ~112 and
   bootstrap.dart ~481) also stops collection: with it off, nothing is counted and any pending counts are dropped at
   once. The optional usage-sharing switch does not affect the counts (they are a separate basis), and step 1 is not
   changed.
5. Server. functions/src/clientTelemetry.ts `validateClientReport` accepts an optional `screens` array: at most 80
   entries, each exactly `{s, first, last, n}` with `s` in the same closed screen-id set as step 1's usageVisit.ts
   (share the list, do not copy it), `first` and `last` booleans, `n` an integer 1 to 1000; at most one `first: true`
   and one `last: true` per report. Rebuilt from known fields only; absent `screens` stays valid and logs as today.
   Tests like the existing clientTelemetry tests.
6. Digest. Extend tools/telemetry/usage_digest.mjs (or add a sibling) with an optional section from `client_telemetry`
   lines that carry `screens`: views per screen, how often each is a visit's first and last screen, across everyone.
   Same private output folder rules.
7. Notice text: do NOT change lib/features/legal/ or any version stamp. The wording is a draft for sign-off only.

## Tests (first, each seen failing)

Flag off: no key, no collection. Flag on: counts, first and last, reset after send, sorted entries, no other fields;
switch off drops pending counts and stops collection; page hide marks `last`; server accepts valid, rejects unknown
screen, extra keys, two firsts, out-of-range counts, and accepts absence.
