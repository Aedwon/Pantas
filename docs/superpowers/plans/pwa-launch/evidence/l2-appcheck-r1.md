# L2 evidence: web App Check enforcement (code side)

Branch `web/l2-appcheck-r1`, based on 3e89ec10. Policy read from `origin/main`.
Console work (key, enforcement) is Aedwon's and is not done here.

## 1. Function inventory (functions/src, deploy entry index.ts)

Callables (27). All set `enforceAppCheck: true`. "Consume" means `consumeAppCheckToken: true`
plus a reject-if-used check (`assertFreshAppCheck`, added in this change).

| Callable | Consume | Notes |
|---|---|---|
| createPaymongoCheckout | yes | payment |
| startWebTrial | yes | trial |
| deleteAccount | yes | destructive |
| exportData | yes | |
| recomputePassEnds | yes | admin |
| startMock | yes | paid mock start |
| updateMockReview | yes | |
| getContent, ingestSession, activateSyncGeneration, recordSignInEvent | no | |
| getMockPaper, controlMock, submitMock, getMockAvailability, getMockResults, getMockHistory | no | |
| setExamSettings, getRoadmap, advanceRoadmap, getRoadmapDay, getRoadmapWeek | no | |
| recordLessonRead, getStudyInsights, getSessionDiagnosis | no | |
| listWebPlans, getWebEntitlement | no | |

HTTP functions (3). None uses App Check, by design.

| Function | Own check |
|---|---|
| paymongoWebhook | PayMongo signature with the webhook secret |
| revenuecatWebhook | RevenueCat authorization and signing secret |
| renderWrappedPage | public page, no credential |

Not client-callable: onUserCreated (Firestore trigger) and the scheduled jobs
(cleanupOrphanAnons, cleanupSyncData, cleanupWrappedOrphans, purgeOldAuditLogs,
repairEntitlementClaims, checkRecentEntitlementClaims).

## 2. Findings and fixes

1. Server: every client-called callable already enforced App Check. No gap.
2. Server defect: seven callables set `consumeAppCheckToken` but nothing read
   `request.app.alreadyConsumed`, so a replayed token was still accepted. Fixed with
   `assertFreshAppCheck` at the top of each of the seven handlers.
3. Client defect found by that fix: no call asked for limited-use tokens, so the second call
   from one browser would have been refused once (2) is in. All callable calls now go through
   `callableOptionsFor(name)`, which asks for limited-use tokens for the seven names only.
4. Client activation (`activateAppCheck`):
   - web with a site key: reCAPTCHA Enterprise, any build mode (already so);
   - web, no key, debug or profile build: web debug provider (token printed in the browser
     console, registered in the Firebase console), so local runs still work;
   - web, no key, release build: throws `AppCheckConfigurationException` with the message
     "This web build has no App Check site key. Rebuild with
     --dart-define=APP_CHECK_WEB_SITE_KEY=...". Startup shows the generic full-screen failure
     with Try Again; the exact message is in the browser console. The failure screen does not
     print error text (existing component rule), so the message is console-only;
   - native: unchanged (flavor based). Native staging builds still use the Android debug
     provider, which is an earlier decision and not changed here.
5. No key is in source. The value is `--dart-define=APP_CHECK_WEB_SITE_KEY`.

No change touches the emulator or local dev flow: calls without an App Check header in the
emulator tests still pass (no `request.app`), and debug web builds fall back to the debug
provider.

## 3. Tests

- `functions/test/app-check.test.mjs`: the source scan matches the deployed callables exactly;
  every callable enforces; the seven consume and reject replays; webhooks and the page do not
  use App Check and keep a signature or secret check; each callable returns 401 with no
  token; the replay helper. Mutation check: removing `enforceAppCheck` from getContent made
  "every callable enforces App Check" fail.
  Limit: the "no token returns 401" test cannot tell enforcement from a handler's own sign-in
  check, so the source-scan test is the one that proves enforcement.
- `test/core/platform/app_check_test.dart`: web provider per build mode, fail-closed release
  build, native passes no web provider.
- `test/core/platform/callable_options_test.dart`: limited-use set, and it matches the server
  callables that consume the token.

## 4. Steps for Aedwon (staging project `pantas-staging`; repeat for dev and prod later)

1. Google Cloud console, project `pantas-staging`: enable the reCAPTCHA Enterprise API.
2. Firebase console, Build > App Check > Apps > the web app > reCAPTCHA Enterprise. Let it
   create the key (or paste one created in reCAPTCHA Enterprise with type Website). Allowed
   domains: `pantas-staging-app.web.app`, `pantas-staging-app.firebaseapp.com`, any custom
   domain, and `localhost` only if you want reCAPTCHA (not the debug provider) locally.
   Copy the site key. It is public.
3. Build with the key: `flutter build web --release -t lib/main_staging.dart
   --dart-define=APP_CHECK_WEB_SITE_KEY=<site key>`. The build value name is
   `APP_CHECK_WEB_SITE_KEY`. A release build without it shows the startup failure.
4. Deploy functions first (this change), then the web build.
5. Smoke test on the deployed site: sign in, open a lesson, start a trial or checkout. In
   Firebase console > App Check > APIs, the Cloud Functions row should show verified
   requests from the web app before step 6.
6. Turn on enforcement per product, in this order and only after step 5 shows verified web
   traffic: Cloud Functions first. Cloud Firestore and Cloud Storage only if the web app and
   the native apps send App Check tokens for them (both do via the Firebase SDK once
   activated); check the metrics before enforcing. Callables enforce App Check in code
   regardless of this console switch, so the switch only adds the console-side metrics and
   blocking for Firestore and Storage.
7. Debug tokens for testers: run a debug web build, copy the token from the browser console,
   register it under App Check > Apps > Manage debug tokens. Never put it in a release build.
