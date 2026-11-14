# Apply web updates at safe points

Owner approval: Aedwon supplied this bounded build assignment on November 14,
2026, on web/update-at-once-r1, based on web bridge commit 4e61f0e74.

His approved requirements:

> a new deploy reaches every open app quickly; the app never swaps versions in
> the middle of a quiz or lesson, it switches at the next safe point: app open,
> Home, or the end of a session; no data loss.

> App-side logic only: no new screen, prompt, banner, wording or layout change
> (any visible UI change is out of scope for you; if you think one is needed,
> stop and say so).

> Do not push, do not deploy, no Firebase. Commit with plain messages,
> NO Co-Authored-By or any AI trailer.

Implement a web-only coordinator with a fakeable bridge and native no-op. Home's
first appearance covers startup. Route changes to Home, quiz results and lesson
endings are safe points. Quiz, mock, reader, onboarding, checkout and unsaved
modal input defer an update. Check again after asynchronous writes finish.
Local transactions, writes and sync enqueue operations must finish and flush to
storage before apply. Do not wait for network sync or clear any storage.
Apply at most once per detected version. Report apply failures through existing
client telemetry with tag `update.apply` and continue normally.

Required tests: available update at Home, deferral during quiz until session end,
deferral during writes until completion, per-version throttle, native no-op.
Show tests failing before implementation. Required checks: format changed Dart,
`flutter analyze lib test`, design lint, layering, new and affected routing/Home/
quiz tests. One active Flutter job at a time, inspect `pgrep -f flutter_tester`.
Local commit only. Report hooks, durability, exact evidence/counts and files.
