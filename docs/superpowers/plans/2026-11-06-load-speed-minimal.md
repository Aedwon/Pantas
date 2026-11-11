# Load speed, minimal batch (Nov 6, 2026)

Aedwon chose the minimal batch and the free warm-up over paid minimum instances.
The balanced batch (content mirror, startup overlap, cached plan, splash release)
waits until after the beta-start review. Source: production logs on Nov 6 and the
Codex Sol review (`sol-perf`, ranks 2, 5 and the head-script note).

## Measured baseline (production logs, Nov 6)

| Callable | Cold | Warm |
|---|---|---|
| getBetaAccess | 3.9 to 5.4 s | 0.16 s |
| getRoadmap | 3.6 to 4.3 s | not seen |
| getMockAvailability | 3.2 to 4.0 s | not seen |
| getStudyInsights | 2.7 s | not seen |
| getWebEntitlement | 1.9 to 2.3 s | 0.07 s |
| setExamSettings, getContent | 3.7 s | 0.3 s |

## Task 1: keep the Home callables warm (functions)

- New scheduled function `keepCallablesWarm` in `functions/src/keepWarm.ts`,
  `onSchedule` every 5 minutes, region `asia-southeast1`, exported from `index.ts`.
- It sends one CORS preflight to each Home callable's Cloud Run URL
  (`https://asia-southeast1-<project>.cloudfunctions.net/<name>`): getBetaAccess,
  getRoadmap, setExamSettings, getWebEntitlement, getMockAvailability,
  getStudyInsights, getContent. The request is `OPTIONS` with
  `Origin: https://app.pantas.study` and `Access-Control-Request-Method: POST`.
  Tested on Nov 6: it starts a cold instance (2.8 s) and is answered 204 by the
  CORS layer, logging one INFO line. A GET was rejected and logged an ERROR each
  time, so GET and POST pings are not allowed. Nothing is verified, read or written.
- Requests run in parallel with a 10 s timeout each. Failures are logged once per
  run at warning level and never throw.
- Off switch: `WARMUP_ENABLED` (defineBoolean, default false). `.env.pantas-prod`
  sets it true for the beta. Turning it off after Nov 15 is one env change.
- Project id from `process.env.GCLOUD_PROJECT`; no URLs are hard-coded per project.
- Tests: the URL list, parallel calls with an injected fetch, the off switch, a
  failing target does not throw.
- Cost: one Cloud Scheduler job (inside the free three), about 2,000 tiny
  invocations a day.

## Task 2: show the plan before quiz content (app)

- `lib/features/home/application/home_today.dart:49` awaits the question launcher
  before Home can render. Home's plan, lessons and counts come from the server
  plan; question bodies are only needed to start a session.
- Render Home from the plan first. Prepare question bodies after the first frame,
  and when the student starts a session await that same preparation.
- In `today_questions.dart`, run the review and new-question hydration together
  instead of one after the other, keeping order, counts and the owner guard.
- Tests: Home renders with plan data while question preparation is still pending;
  starting a session waits for it; counts and order unchanged; an owner change
  mid-preparation still aborts.

## Task 3: start connections early (web)

- In `web/index.html`, add `preconnect` (with `crossorigin` where the request is
  CORS) for `https://www.gstatic.com`, `https://asia-southeast1-pantas-prod.cloudfunctions.net`,
  `https://content-firebaseappcheck.googleapis.com`, `https://securetoken.googleapis.com`,
  `https://identitytoolkit.googleapis.com` and `https://www.google.com`.
- No `preload` of `main.dart.js` or CanvasKit: the service worker and the engine
  revision path make a mismatched double download likely.
- Test: the existing web tests still pass; add one asserting the hints exist.

## Rules for the implementer

Follow AGENTS.md, WORKFLOW.md and SUBAGENTS.md on main. No visual change. No em
dashes. Do not touch sign-in, the beta gate or the service worker.

## Done means

All checks pass; deployed; after deploy, production logs show the scheduler hitting
each target and a warm `getRoadmap` under 1 s on Aedwon's next Home load; the
Home path reaches the plan without `FAILED_PRECONDITION` errors.
