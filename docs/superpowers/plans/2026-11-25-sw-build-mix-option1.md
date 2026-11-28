# Service worker build-mix fix, option 1 (E-184)

Written Nov 25 by the CSE release lead r8 (integrator). Policy read from main c0ce2891f and later.

## Authority

- Aedwon, about 11:30 PM Manila Nov 25, relayed by the manager: "ok" to fixing the service worker gap before
  opening. The Nov 14 rule "No new worker or hosting migration ships" is lifted for this one change.
- Manager, verbatim: "Build your option 1, the fingerprint list, with only the full startup set cached before
  takeover and old caches deleted after. That's about 1 day, with two Codex Sol High audits through codex-pick
  (only account b works). Your parked failing tests are on their branch. Do it after P10 and P7, and before
  P12, so the loop runs exercise the new worker."
- Defect, evidence and the failed minimal fix: handoff `docs/superpowers/handoffs/2026-11-25-cse-release-lead-r4-ui-ship.md`,
  "Service worker gap". Parked tests: branch `fix/sw-build-mix-r1` ecdc85656 (`test/web/pantas_sw_build_mix.test.mjs`,
  fixture `test/web/fixtures/pantas_sw_prod_a.js`, six tests fail by design on today's worker).

Low-impact exception does not apply (every web user's boot path). This plan is the spec's agent section; the
outcome he approved is the line above. No UI change.

## Goal and acceptance

A student's app never boots one build's shell with another build's Dart code, online or offline, across a
deploy, a rollback (B to C to B), edge or HTTP cache skew, or the move from today's prod worker. Going offline
at any moment never leaves an installed app unable to boot when it could boot before.

Accepted when: the six parked tests and the new tests below pass on the new worker; a real-browser rollout from
today's prod worker passes; two Codex GPT 6.2 Sol High audits end with no Blocker or High open; staging proof
passes through the Cloudflare Worker.

## Design (decided)

1. **Fingerprint list.** `tool/web/stamp_worker_version.mjs` (run after `flutter build web`) writes into
   `build/web/pantas_sw.js` a constant: the build id and the SHA-256 of every file in the startup set, keyed by
   path relative to the scope. The worker script's bytes therefore differ per build, so the browser installs a
   new worker for each build. The source `web/pantas_sw.js` carries a placeholder the stamp replaces; an
   unstamped worker (dev) keeps today's behavior only when the placeholder is still present, and the release
   scripts refuse to deploy an unstamped worker.
2. **Startup set.** Everything the app needs to boot to Home offline: the page (`''` and `index.html` as served),
   `flutter_bootstrap.js`, `flutter.js`, `main.dart.js` and every `main.dart.js_*.part.js`, the `pantas_*.js`
   files, `manifest.json`, `drift_worker.js`, `sqlite3.wasm`, `assets/AssetManifest*`, `assets/FontManifest.json`,
   the fonts and assets the first frame loads, the renderer files the build uses (`canvaskit/` if present), icons
   the manifest names. The stamp derives it from the build output with an explicit include list; the
   implementor documents any file left out and why. `version.json` is not in the set: it is network-only and
   never stored (the app uses it to detect a new build).
3. **Install.** Fetch each file in the set with `cache: 'reload'`, hash the bytes with `crypto.subtle`, and
   compare with the list. Store into this build's cache only when every file matches. Any mismatch or network
   failure fails the install (throw), so the browser keeps the current worker and retries at the next update
   check. `skipWaiting()` only after the full set is stored and verified.
4. **Activate.** `clients.claim()`, then delete every `pantas-` cache except this build's. Never delete before
   this build's cache is complete (guaranteed by step 3).
5. **Fetch.** Files in the set: served from this build's cache only (cache-first, no network-first mix). A miss
   in the set (should not happen) goes to the network and is not stored. Files outside the set: network
   pass-through, never stored. Bypass rules stay (other origins, `__/`, `wrapped/`, credentials, ranges,
   `no-store`). Navigations: the cached page of this build; online or offline the same.
6. **Updates.** A new build reaches the page only through a new worker that verified its whole set. The existing
   update flow in `pantas_pwa.js` (page waits for the matching worker) stays; the implementor checks it still
   holds with cache-first navigations and reports any change it needs.
7. **Edge check.** The implementor confirms the Cloudflare Worker (`tool/cloudflare-app/worker.mjs`) and the
   headers files never alter response bodies of files in the set. If they do, stop and report.
8. **Rollback.** A rollback is a normal deploy of the earlier build: its worker installs and verifies its own set.
   Rolling back to a build with today's worker is allowed and returns today's behavior.

## Tests (write first, see them fail on today's worker)

- Un-skip the six parked tests; they must pass.
- New, in the same Node harness: install fails and the old worker stays on any hash mismatch; a partial cache
  never activates; old caches are deleted only after activation; B to C to B rollback never mixes; a response
  outside the set is never stored; offline boot works immediately after activation; `version.json` is never
  stored; the stamp writes a list that matches the build output and is stable when run twice.
- Real-browser rollout (headless Chromium with `--use-mock-keychain --password-store=basic`, local static
  server, no hosted calls): serve build A with today's prod worker (fixture), load; deploy build B with the new
  worker; reload online, then offline; assert every boot file of each load comes from one build. Repeat for a
  B to A rollback. Close the browser after.

## Order and roles

1. Sonnet 5.5 implementor on `fix/sw-build-mix-r1` (merge main first), after P10 or P7 frees a worker slot.
2. Codex GPT 6.2 Sol High audit 1 (codex-pick, account b), read-only, on the diff and tests.
3. Fixes by the implementor; Codex audit 2. No Blocker or High open.
4. Lead review, CI, staging build (lead runs the Flutter build under the build lock), staging proof through the
   Worker: online, offline, and an update from the previous staging build.
5. Merge to main before P12; P12's loop runs use this worker. Prod with the opening ship.

## Rule 7

No hosted calls in the tests. Staging deploy and proof: Worker requests only (free 100,000 a day); no Firestore
or functions beyond one sign-in-free boot. Counted again before the staging proof.

## Limits

Phones that stay on today's worker until they next connect keep today's exposure; the new worker reaches them
on their next online visit.

## Revision 1 (Nov 26): option A after audit 1 FAIL

Authority: Aedwon, verbatim, "go with your reco" (launch log, Nov 26): option A, and yes on side effect 1.
Audit 1 (Codex GPT 6.2 Sol High) failed with 2 Blockers, 4 High, 3 Medium; Fable 5.2 advised the design
below. It replaces Design items 2, 5 and 6 where they differ; items 1, 3, 4, 7 and the header rule stay.

1. **Build folders (closes Blocker 2).** The stamp moves every file a page loads into `b/<id>/`: the
   `pantas_*.js` helpers, `flutter_bootstrap.js`, `flutter.js`, `main.dart.js` and parts, `drift_worker.js`,
   `sqlite3.wasm`, `assets/`, and the renderer files. The page names those URLs (Flutter 3.44.6
   `entrypointBaseUrl` and asset base; the Dart side resolves the database worker and wasm against the build
   folder, not the document base). The site root keeps only the page, the worker, `version.json`,
   `manifest.json` and icons. No Dart or helper files at the root. Today's prod worker matches bare root
   paths only, so it can neither store nor serve a `b/` file.
2. **Waiting worker (closes Blocker 1).** No `skipWaiting` while clients of another stamped build are open.
   The page asks a waiting, verified worker to take over only before Flutter starts or at the existing apply
   point, and only when it is the sole window. Old caches are deleted on activate. From today's worker
   (no other stamped cache), the new worker takes over at once.
3. **No page wait.** With build folders the page needs no worker to load correctly; the 4-second wait and
   its fallback are removed.
4. **Highs:** the build id covers final bytes and the cache name includes a hash of the list (restamp);
   updates never unregister or delete caches, they switch to a verified waiting worker; renderer local
   (`--no-web-resources-cdn` in the staging and prod build steps; list both renderer variants, install only
   the one this browser uses); the deploy guard checks a required-file list on the staged folder.
5. **Mediums:** "update available" means a verified waiting worker exists (no reload loop); install refuses
   `private` or `no-store` responses; the worker's own 503 carries the security headers. Deferred, with a
   limit: a headers-only deploy reaches installed phones only with a new build, so a CSP change ships with one.
6. **`b/` files** need no `cache: 'reload'` (the hash protects them).
7. **Side effects accepted:** the download percent rarely shows on updates (updates download in the
   background); first visits keep the spinner. The first release with this worker rolls forward only: the
   deploy guard refuses a build with today's worker after it, and the ship plan says so.
8. **Proof tests (real Chromium, a build marker in every file):** Blocker 1: hold a B tab open, deploy C,
   wait until C is installed, load a deferred part offline: it must be B's; a second tab must not let apply
   take over. Blocker 2: today's worker with its original helper and bootstrap, warmed; B's install throttled
   past 10 s; cut the network before, during and after takeover and on a navigation slower than 4 s: every
   load is all A, all B, or no boot. Node: today's worker claims no `b/` path. One offline boot of a real
   Flutter build with zero off-origin requests (the lead runs the build).
9. **Time:** about 2 working days to a second-audit-ready branch, then audit 2 and staging.
