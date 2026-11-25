# Service worker option A: fix list after Codex audit 2 (Nov 26)

Paused by Aedwon's decision (Nov 26, "go with reco"): the app opens on today's worker; this branch resumes after the opening and reaches prod only after a clean Codex audit and a 48-hour staging soak. Plan: docs/superpowers/plans/2026-11-25-sw-build-mix-option1.md (Revision 1). Audit texts: Pantas-private/releases/2026-11-26-sw-option-a/.


Recommendation: (ii) open on today's worker, finish option A after the opening, 48 h staging soak. (i) is reasonable only if the opening is 5+ days out.

Fix list if A continues (branch fix/sw-build-mix-r1 87b0f977b):
1. drift_worker.js stays at the root address, in the verified set (bytes unchanged since the first web commit, so today's worker serves an identical copy). Before any Drift upgrade, add a lock that refuses to open while another worker version holds the database.
2. Serve any b/... path from whichever build cache holds it (the address carries the build).
3. Delete nothing at activation; prune at the end of a successful install, keeping the new and the active build (closes cache growth and the deleted-successor case).
4. First release: serve root deferred parts from today's cache to tabs still on today's build.
5. RevenueCat root script: deploy check that its bytes equal prod's; no worker change.
6. Catch offline fetch failures with the secured 503; store a verified miss; Dart honors the apply result.
Classification: cold offline boot hang on Firebase SDK and fonts is pre-existing (test gap: the real-build test claimed zero off-origin). Drift mechanism per audit is partly wrong: browsers key shared workers by URL plus name; Chrome shows an open error (or, on a simultaneous probe, an empty IndexedDB db); Safari shared IndexedDB mode could overwrite (unverified).

## Audit 2 findings still open (Codex GPT 6.2 Sol High, branch 87b0f977b)

- Blocker 1 PARTLY: two tabs strand a build; a navigation racing the sole-window check can boot a page whose cache was deleted.
- Blocker 2 PARTLY: today's worker serves its cached RevenueCat root script to a new-build page; the new build claims live old tabs and deletes the cache they need for later root requests.
- High 5 PARTLY: renderer variant picked by Intl in the worker may differ from Flutter's choice (Blink and ImageDecoder): pin both to full CanvasKit or cache both.
- High 6 PARTLY: the deploy guard accepts a stamped build missing a deferred part, a font or RevenueCat, and changed Dart bytes at the same immutable URL; no target flavor; the Firebase rollback path bypasses it.
- Medium 7 PARTLY: Dart discards the apply result; a two-tab refusal is recorded as attempted; a late reply can reload after startup.
- Medium 8 PARTLY: an offline fetch rejection bypasses the secured 503.
- Medium 9 PARTLY: browser tests accept the HTML marker alone, reuse an already-requested part, and keep the HTTP cache warm.
- New High: Drift worker URL changes per build (see item 1 above).
- New High (pre-existing in today's app): cold offline boot can hang on the Firebase SDK and fonts from gstatic; the real-build test must assert app and storage readiness with a cold HTTP cache and off-origin requests blocked.
- New High: caches grow past three builds with a tab held open; an activation can delete a successor's in-progress cache.
- New Medium: the page url() rewrite misses forms such as url( ./assets/font.ttf ).
