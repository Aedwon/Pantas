# Plan: serve the app's static files from Cloudflare (security fixes step 5, S-01)

Status: proposed by the security fixes lead, Nov 14, 2026, for the manager before any change.
Approved order and Aedwon's goal: launch log, Nov 14, "security fixes and billing cap".

## Why

Firebase Hosting bills $0.15 per GiB served and has no cap or rate limit. One rented server
downloading the 7.45 MB app bundle flat out costs about $63 an hour. Cloudflare Workers static
assets are "free and unlimited" (Cloudflare billing docs), so moving the files there removes the
largest money risk without an outage.

## What changes

1. **A Worker per environment** (`pantas-app` for prod, `pantas-app-staging`), on the Cloudflare
   Free plan, serving the Flutter `build/web` folder as static assets:
   - `not_found_handling: "single-page-application"`, the same as the Firebase rewrite of `**` to
     `/index.html`.
   - A `_headers` file generated from `firebase.json`, so Cache-Control is identical: hashed files
     immutable for a year; `index.html`, `/`, `flutter_service_worker.js`, `manifest.json`,
     `version.json` and top-level `*.js` revalidated every time. A test fails if the two drift.
   - Same origin and same paths, so installed apps and their service workers keep working, and the
     safe-point reload from the "updates take effect at once" release keeps reading `version.json`.
2. **The sign-in pages stay on Firebase.** Prod signs in through `app.pantas.study/__/auth/*`.
   The Worker script runs only for `/__/*` (`run_worker_first`) and forwards those requests to
   `pantas-prod.firebaseapp.com`, which keeps serving Firebase's sign-in handler. Staging signs in
   through `pantas-staging.firebaseapp.com`, so it does not use the forwarding; it is still deployed
   there and checked by comparing responses.
3. **DNS** (the lead): replace the DNS-only CNAME `app.pantas.study` → `pantas-prod.web.app` with
   the Worker's custom domain (same for `staging.pantas.study`).
4. **Firebase Hosting keeps the full build at first**, so rollback is one DNS change. After 48 hours
   of clean serving from Cloudflare, the integrator deploys a tiny page (about 200 bytes, linking to
   app.pantas.study) as `index.html` and `404.html` on Firebase Hosting, so `pantas-prod.web.app` and
   `.firebaseapp.com` have nothing large to serve. Firebase's sign-in pages are reserved paths and
   keep working with any site content. This last step is what actually closes S-01.

## Who does what

- Lead (security fixes): Worker config, the forwarding script, the `_headers` generator and their
  tests, a deploy script; the DNS changes and their rollback; the checks.
- Integrator: builds the app and runs the Worker deploy on staging, then prod (app deploys are its
  job), and adds the Worker upload to its release steps; later deploys the tiny Firebase page.
- Aedwon, on prod right after the switch (about 10 minutes): sign in on a real phone with Google,
  with an email code, and from Messenger's in-app browser; open the installed app once.

## Order and checks

1. Build and test locally: headers match `firebase.json`; `/__/*` is forwarded with method, body
   and headers intact; every other path is a static file or `index.html`.
2. Staging: deploy, switch `staging.pantas.study`, then run the browser journeys, compare
   `/__/auth/handler`, `/__/auth/iframe` and `/__/firebase/init.json` through the Worker with
   Firebase's own, and check response headers on the main files.
3. Prod, at a time Aedwon can do the phone checks: switch `app.pantas.study`, run the same checks,
   watch sign-in errors and client reports for 30 minutes.
4. After 48 clean hours: the tiny Firebase Hosting page on prod (and staging).

## Risks and rollback

- **Sign-in lockout** if the forwarding breaks. Rollback: remove the custom domain and restore the
  CNAME; Cloudflare applies it in about a minute (DNS-only, short TTL). Firebase still holds the full
  build until step 4.
- **Free-plan limit on the forwarding:** requests that run the Worker script count against 100,000 a
  day; above it they get 429, so new sign-ins would fail until midnight UTC (static files are
  unaffected). Beta sign-ins use a tiny fraction. Mitigation now: the Free plan's one rate-limiting
  rule on `/__/*` per address. If it is ever needed, Workers Paid is $5 a month (not proposed now).
- **A wrong header** could make browsers cache `index.html` and miss updates. Covered by the
  headers test and the step 2 header check.
- No cost. No user-visible change. Staging journeys run against the Worker.

## Estimate

About 1.5 hours of lead work plus the integrator's two deploys and Aedwon's 10-minute phone check;
the tiny Firebase page after 48 hours.
