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
