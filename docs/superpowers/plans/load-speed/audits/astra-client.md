# Client startup audit: 571eea1aa

Scope: source HEAD verified as `571eea1aa875152a1ff4d63734fa83353ff379ce`; policy read at the brief's pinned `8d81dad6f`. Read-only source audit, no build, deploy, or browser measurements. Live numbers below are supplied by the brief; all proposed savings are estimates, not additive.

## F1. The four-second worker wait is not the whole returning-visit network barrier
- Where: `web/index.html:68,71,244,246,273`; `web/pantas_sw.js:182-217`; `web/flutter_bootstrap.js:10`; `web/pantas_pwa.js:33-80` (571eea1aa). Navigation → parser-blocking helpers → async bootstrap → matching worker → Flutter.
- What happens now: navigation and each of four synchronous head helpers use network-first with a 4,000ms fallback, even when cached. Bootstrap is network-first too. Requests can overlap through browser speculative fetching, so this is not six guaranteed serial four-second delays; nevertheless navigation precedes parsing and helper execution precedes loader invocation. The worker registration timeout starts only afterward. Without a cached response, the service worker returns the original network promise after timeout, so 4s is not an overall upper bound. Same-version worker registration normally resolves early; first uncontrolled visits register without waiting.
- Change: keep fresh release discovery, but serve release-specific helper/bootstrap URLs from a consistent immutable manifest and cache. Bundle the tiny early helpers while retaining history/install listeners before Flutter. Do not simply remove registration waiting or cache mutable bootstrap forever.
- Gain: ESTIMATED 0.1–0.8s healthy returning visit; up to several separate 4s fallback stages on stalled-network returns, not a guaranteed total. First visit benefits only from fewer helper requests.
- Cost on Blaze: 0 extra Functions invocations and 0 Firestore reads; bundling saves 3 helper requests/load. Immutable reuse reduces Hosting transfer by the reused helper bytes; no added recurring service.
- Security impact: none if API/auth bypass and release consistency remain intact.
- Risk and effort: 4–8h, beta-safe only with offline/update regression coverage; needs board no.

## F2. New-worker activation waits for icons and manifests, not just executable startup
- Where: `web/pantas_sw.js:30-42,104-136`; `web/pantas_pwa.js:47-80` (571eea1aa). Returning deploy → register → install allSettled → skipWaiting → delete old caches → claim → loader.
- What happens now: eleven precache GETs start in parallel, but every one must settle before activation; a slow Icon-512, favicon, or manifest can hold the matching worker. There is no timeout on these install fetches. The page releases its barrier at 4s anyway, potentially while the old controller still serves mutable cache-first app filenames. The stated guarantee that files never mix builds is therefore conditional, not absolute. First visits also compete with these eleven reload-mode requests while Flutter downloads.
- Change: after versioned release consistency is secured, move nonessential icons/manifests to post-activation/background caching. Keep mandatory offline shell checks and explicitly handle timeout without mixing releases.
- Gain: ESTIMATED 0–4s after deploy when a nonessential fetch is the slow tail; usually small on unchanged returning visits; reduced initial bandwidth contention.
- Cost on Blaze: 0 extra callable invocations or Firestore reads; same maximum 11 initial files, with deferral potentially avoiding unneeded transfers. No paid warm instances.
- Security impact: none; preserve static-only caching and existing request exclusions.
- Risk and effort: 3–6h with F1, beta-safe conditional on update/offline tests; needs board no.

## F3. Returning users replay their entire accumulated content cache before mounting
- Where: `lib/app/bootstrap.dart:325-330,390-393`; `lib/core/content/remote/content_mirror.dart:61-75,128-149` (571eea1aa). Auth → mirror.start → storedItems → sorted sequential enqueue of every catalog, lesson and question item → subsequent bootstrap.
- What happens now: confirms prior finding, with an important distinction: the 10s timeout wraps only a cache-miss catalog refresh. Cached-item replay is outside that timeout and grows with previous study, so a heavily used returning account can start more slowly despite zero network content misses. A cached index triggers background refresh only after all replay finishes. First visits refresh index, then all exam catalogs, then catalog parts in dependent stages, not only the selected exam. A timeout does not cancel the background refresh.
- Change: restore catalog/index and selected exam metadata first; lazily hydrate stored lesson bodies/question sets on demand. Preserve item verification, ownership/downgrade handling and fetch-hook correctness; do not merely drop required catalog rows.
- Gain: ESTIMATED 1–6s on a large returning cache, device-dependent; first visits can avoid part of the current up-to-10s catalog wait. Actual per-stage timing needed before promising seconds.
- Cost on Blaze: lazy local replay itself adds 0 reads/calls/transfer. Keep cache-hit reads local to avoid turning this into repeat server fetches. Selected-exam catalog loading can reduce fetched catalogs from N exams to 1 plus index, and their associated content transfer; server read totals depend on batch implementation.
- Security impact: none if existing verification and access-change clearing precede exposing protected data.
- Risk and effort: 8–16h, beta-safe no as a rushed rewrite; needs board no.

## F4. Remote Config can overlap storage without changing minimum-version enforcement
- Where: `lib/app/bootstrap.dart:250-284`; `lib/core/platform/remote_flags_providers.dart:22-48`; `lib/core/storage/storage.dart:65`; `lib/core/content/content.dart:53` (571eea1aa).
- What happens now: Firebase → App Check → study database → content database → Remote Config all await serially. Remote Config config/settings/defaults/fetch each have a separate 3s timeout, not one overall 3s budget. Normally only fetch is material, but nearly 9s is possible if all three operations finish just inside their individual deadlines. Minimum fetch interval is already one hour, so “a network fetch on every reload” is incorrect.
- Change: launch Remote Config once Firebase/App Check are ready alongside independent database opening, then join all prerequisites before container/router construction. Retain exactly the current flag result and enforcement timing relative to first route. Treat dual-database overlap separately with proper cleanup if one fails.
- Gain: ESTIMATED min(Remote Config time, storage initialization time), roughly 0.1–1s on normal cold browser startup; up to the overlapping storage duration during a 3s fetch timeout. First and return visits where both are material.
- Cost on Blaze: 0 additional Remote Config fetches, callable invocations, Firestore reads, or transferred bytes; only scheduling changes.
- Security impact: none; do not switch to cached/fallback flags earlier or weaken the minimum-version gate.
- Risk and effort: 2–4h plus failure/cleanup tests, beta-safe yes; needs board no. High gain per safe engineering hour relative to cache redesign.

## F5. Both proposed Home parallelizations already shipped; the join still blocks visibility
- Where: `lib/features/home/application/home_today.dart:49-66,82-154`; `lib/features/home/application/today_questions.dart:102-133,181-240`; `lib/features/home/presentation/home_today_screen.dart:419-427` (571eea1aa).
- What happens now: correction to prior review #2: Home already starts question preparation beside metadata assembly, and review/new hydration already uses Future.wait while saved batch progress and preferences load. Both share the held roadmap provider. Home still joins pendingWork before returning data. The question side also reads full planned new-question IDs, then lesson metadata/read progress and topic titles, even when only some new questions remain. The metadata side serially reads lesson metadata → topics → subjects → each lesson readFraction → flags/exam/settings. Home ready waits for the whole request (or a final error), not just the server plan.
- Change: first try batching independent local progress/session reads and reducing hydration to data genuinely required for the displayed groups, preserving exact ordering/count semantics. Separating Home presentation from prepared quiz bodies is a second, larger change that needs approved loading/error behavior. Do not budget savings for already-shipped parallelization.
- Gain: ESTIMATED 0.05–0.5s from local batching on larger plans, first/return Home; potentially 0.5–3s for removing remaining body hydration from Home readiness on cache misses, requiring measurement.
- Cost on Blaze: batching local SQL adds 0 Firestore reads/callables. Deferred hydration adds 0 calls if coalesced/cached and can avoid question transfers for users who never start; careless separate loaders could duplicate requests and must be prevented.
- Security impact: none if account/exam guards and authoritative plan membership remain unchanged.
- Risk and effort: local batching 2–4h beta-safe yes; split readiness 6–12h beta-safe conditional, needs board yes for changed loading/error presentation (no for pure batching).

## F6. Splash timing does not measure time-to-usable-Home
- Where: `lib/app/bootstrap.dart:197-202,348-361`; `lib/core/platform/first_screen_ready.dart:56-80`; `web/pantas_splash.js:8-12,55-95`; `lib/features/home/presentation/home_today_screen.dart:422-427` (571eea1aa).
- What happens now: a temporary loading app runs early, but sendAppStarted is emitted only immediately before the real App runApp, after all awaited bootstrap work. Only then does the 8s timer begin. Normal removal needs a Flutter post-frame callback, two browser animation frames, then a 400ms fade; reduced motion skips the fade. Home errors also count as settled unless held for retry. The 60s timer starts when the head helper executes, not navigation start. Thus an 8s fallback can uncover loading/error rather than usable Home, and a 60s fallback can uncover bootstrap still running.
- Change: add local Performance marks for navigation/helpers/loader, each awaited bootstrap stage, real runApp, route, Home plan/hydration join, ready and actual DOM removal. Rank actual critical-path durations; retain current approved fade and cover until an alternative has board approval.
- Gain: ESTIMATED 0s directly; eliminates misattribution of the guaranteed normal 0.4s fade and the late 8s timer to network. Optional earlier uncovering saves only visual cover time, not usability, and is not recommended as the primary fix.
- Cost on Blaze: browser-local marks add 0 invocations, 0 reads and 0 network bytes; no telemetry upload required.
- Security impact: none; record stage labels/durations only, no user tokens or content.
- Risk and effort: 1–2h, beta-safe yes; needs board no for invisible instrumentation, yes to change splash timing/motion.

## F7. “RevenueCat bootstrap” hides a mandatory web entitlement callable on the critical path
- Where: `lib/app/bootstrap.dart:335`; `lib/features/paywall/application/revenuecat_bootstrap.dart:167-179,119-129`; `lib/features/paywall/application/paywall_providers.dart:90-103`; `lib/features/paywall/data/web_payment_gateway.dart:228-240,422-430,549-550` (571eea1aa).
- What happens now: on web this is WebPaymentGateway, not the native RevenueCat SDK. It hydrates local entitlement, associates the current UID (including anonymous), then awaits getWebEntitlement before real runApp. The misleading readGrantsFromFirestore name actually invokes a callable. Failure is swallowed only after the request fails; “optional infrastructure” does not mean it is off the critical path. Claims-change subscription installation follows; its later token refresh is unawaited. This callable was absent from the prior cold-start shortlist.
- Change: measure this separately and overlap its existing initialization/read with content restoration after auth, while still awaiting identity/entitlement before publishing the app or starting entitlement-dependent sync. Preserve owner clearing, authoritative acceptance and downgrade behavior. Do not replace current server enforcement with optimistic Pro.
- Gain: ESTIMATED 0.1–0.5s warm or 1–3s cold when hidden behind content work, both first and returning visits; actual getWebEntitlement latency not measured in this audit.
- Cost on Blaze: same 1 entitlement callable per initial UID association, 0 additional Firestore reads or Hosting bytes. Overlap saves latency, not billing. No minInstances recommendation.
- Security impact: none if identity clear/install order and join before entitlement consumers are preserved; requires careful account-switch tests.
- Risk and effort: 4–6h, beta-safe conditional; needs board no. Higher-value than removing local dev no-ops from bootstrap.

## F8. Beta loading can remove the splash before Home, so the prior readiness claim is too broad
- Where: `lib/app/router.dart:40-49,82-90`; `lib/core/auth/beta_access.dart:80-83`; `lib/app/beta_gate.dart:55-85,125-141`; `lib/app/sign_in/sign_in_parts.dart:104-116` (571eea1aa).
- What happens now: startup's settleGates awaits age/focus/onboarding only, not beta access. On a fresh app instance with BETA_GATE active, router watches start the signed-in beta callable; loading redirects to /beta. Its loading skeleton is wrapped in SignInFrame → FirstScreenReady with ready=true. This can emit the one-shot splash-ready before beta access and Home are ready. It also releases HTML Welcome with holdForTap=false. Home still cannot mount until beta permission succeeds. Therefore “splash removed only after Home settled” is false on this route path; an early beta skeleton can own removal instead. An anonymous first visitor gets sign-in without a beta callable.
- Change: start the existing beta provider earlier after auth/container setup, only when the same gate is active, sharing the same provider result with the router. Keep router access enforcement. Instrument first readiness owner to distinguish beta from Home. Any change to covering the beta skeleton requires board approval.
- Gain: ESTIMATED up to min(beta-check time, remaining bootstrap work), around 0.1–0.5s warm or 1–3s cold for signed-in beta returns. No benefit from beta prefetch for anonymous visitors or disabled gate.
- Cost on Blaze: 0 additional getBetaAccess invocations if the same non-autoDispose provider is reused; no duplicated token exchange/read. Existing 1 check per signed-in app instance remains. 0 additional Hosting bytes.
- Security impact: none; preserve limited-use tokens, server check and deny-while-loading redirect. Do not persist permission as an offline bypass.
- Risk and effort: 2–4h, beta-safe yes with enabled/disabled/identity-transition tests; needs board no for prefetch, yes for cover changes.

## F9. Font startup includes 630KB of math faces plus an engine fallback font
- Where: `pubspec.yaml:108-134`; `web/index.html:82-87`; `web/pantas_welcome.js:53-61`; `web/pantas_splash.js:32-37` (571eea1aa). Supporting local artifact: `build/web/assets/FontManifest.json`; installed Flutter engine `initialization.dart:158-159,224`, `canvaskit/fonts.dart:100-123` (SDK evidence, not repository lines).
- What happens now: local manifest contains 20 KaTeX faces totaling 630,372 raw bytes, four Geist faces totaling 510,404 bytes, MaterialIcons 10,888 and Phosphor 13,660. Engine downloads manifest fonts concurrently and waits for all, alongside renderer initialization; it also requests Roboto fallback when absent from the manifest. HTML starts three Geist weights on first visits or bold on return visits. These use the same asset URLs as Flutter, so do not assume a second full network transfer: browser/cache coalescing may reuse bytes, although DOM and CanvasKit both process fonts. Native seed assets are excluded from web already.
- Change: profile font waterfall and investigate explicit lazy math-font registration before math routes, with a packaging solution that actually removes the package faces from startup FontManifest. Deferred Dart imports alone do not remove declared font assets. Keep Geist appearance and test every math face/symbol before rollout; do not blindly delete engine fallback behavior.
- Gain: ESTIMATED 0.2–1s cold first/after-deploy load from deferring math fonts; 0–0.2s on hot cached returns. 630,372 bytes is MEASURED local raw size, not compressed live transfer or measured latency.
- Cost on Blaze: at most 0.630MB raw asset transfer avoided per cold visitor who never opens math, about 0.630GB per 1,000 such visitors before compression; 0 Functions invocations/Firestore reads. Math users transfer it later. Preserve cache reuse.
- Security impact: none.
- Risk and effort: 6–12h, beta-safe no without math/render regression validation; needs board no if identical rendering, yes for any substitution or changed text appearance.

## F10. Deferred chunks are fetched eagerly only on a controlled main-bundle cache miss
- Where: `web/pantas_sw.js:220-245`; `firebase.json:46-50,91-96`; `web/flutter_bootstrap.js:13` (571eea1aa).
- What happens now: on cache miss the worker returns main.dart.js without awaiting chunk warming, but concurrently reads its entire response text, extracts every numbered part, and fetches all parts with Promise.allSettled. The local build's deferred parts total 703,194 raw bytes. These requests compete with fonts/Firebase/content on controlled cold loads or new releases. On a pristine first visit the main request may occur before worker control, so warming is not guaranteed. On same-worker cache hits warming does not run. The prior review overgeneralized this as every reload. Root no-cache headers do not force main.dart.js to network when a service-worker cache hit serves it.
- Change: trigger bounded warmup after the first usable route via a worker message, keeping demanded chunks immediately available and explicitly deciding offline preloading policy. Do not remove the deployment stamp or mutable-asset freshness safeguards.
- Gain: ESTIMATED 0–0.5s to Home on bandwidth-constrained controlled cold loads, 0s on unchanged main-cache hits. Delays later offline readiness until background warmup finishes.
- Cost on Blaze: same eventual bytes if all parts warm; up to 0.703MB raw/load avoided for early exits, about 0.703GB/1,000 before compression. 0 Functions invocations/Firestore reads.
- Security impact: none; static-only worker caching unchanged.
- Risk and effort: 2–4h, beta-safe yes with offline route tests; needs board no.

F9 arithmetic correction (verified by summing the manifest files in Python): KaTeX totals **640,372 bytes**, not 630,372. Read F9's title as 640KB, and its raw transfer ceilings as 0.640MB/visitor and 0.640GB/1,000 visitors. All other family totals stand. These local artifacts were inspected, not rebuilt or proven byte-identical to production.

F7 cold-start context: `functions/src/keepWarm.ts:6-8` already includes getWebEntitlement among the seven scheduled targets. Do not add another warming job for it. The missed issue is its serial placement, not absence from the existing warmup. Scheduled OPTIONS traffic is not a measurement or guarantee of warm authenticated execution.

## F11. First visitors pay the full study bootstrap before they can sign in or start onboarding
- Where: `web/pantas_welcome.js:121-139,154-162`; `lib/app/bootstrap.dart:250-348`; `lib/app/router.dart:74-90,128-134`; `lib/features/onboarding/presentation/onboarding_page.dart:201-227` (571eea1aa).
- What happens now: first visit is determined only by localStorage pantas.welcome.seen, not account history or service-worker state. Welcome hides the splash entirely and remains over background startup. Get Started marks seen immediately, displays Starting…, and starts its own 60s escape timer. The app still anonymously authenticates, builds content catalogs, reads entitlement, recovers sync projection and settles gates before discovering the initial route. With beta active, an anonymous visitor reaches sign-in first, which uncovers Welcome automatically; with beta inactive/allowed, a new student reaches onboarding, which waits for progress and reports ready holding for the tap. Legal/guardian links skip Welcome but still pay bootstrap. First usable screen is therefore often sign-in/onboarding, not Home.
- Change: a route-aware bootstrap could initialize auth/config and essential local state first, and defer study content work until the permitted study/onboarding path needs it. Preserve the gate, guardian requirements and selected-exam correctness. This is separate from merely parallelizing independent prerequisites.
- Gain: ESTIMATED 1–6s to first sign-in/initial onboarding on cold first visits, potentially avoiding much of the catalog's 10s timeout path. This does not reduce later time to usable Home by the same amount.
- Cost on Blaze: 0 extra calls if deferred work starts once and is reused. Abandoned first sessions can avoid catalog batches and 1 entitlement call if safely unnecessary; exact content request reduction depends on catalog batches. No paid service needed.
- Security impact: none only if beta/auth/guardian/minimum-version checks stay authoritative before protected routes and data access.
- Risk and effort: 8–16h, beta-safe no as a rushed startup redesign; needs board no for identical screens, yes if handover/loading presentation changes.

## F12. Home has a second hidden wait: six settling retries total 7.25s before request time
- Where: `lib/features/home/application/settling_retry.dart:13-19,46-68`; `lib/features/home/presentation/home_today_screen.dart:140-150,169-172,422-427`; `lib/features/home/data/study_snapshot_reader.dart:51-66`; `lib/features/home/application/study_remote_providers.dart:129-136` (571eea1aa).
- What happens now: unavailable/deadline-exceeded/unauthenticated and identity/provider-settling failures hold the loading state and retry after 150+300+600+1200+2000+3000ms = 7.25s, excluding each attempt's latency. Home does not report ready during these holds. Its request can first await pending settings retry and observation flush before getRoadmap on a cache miss; missing server settings can then add setExamSettings → getRoadmap recovery. A cached public roadmap yields before these network stages, so they are not inevitably on every returning Home critical path. Incoming roadmap values trigger Home's _retry, potentially repeating local assembly/hydration while background sync/context also settles. Provider/cache sharing limits network duplication; the source does not prove seven independent roadmap calls.
- Change: instrument retry reason/count and separate real network failures from transient identity readiness. Prefer resuming after the required state becomes ready to repeatedly rebuilding the whole request. Batch/reuse completed preparation where the same owner/plan is still valid; never disable guards or skip durable observation/settings ordering.
- Gain: ESTIMATED 0s for healthy loads; 0.15–7.25s retry-timer component recoverable on specific avoidable settling races, first and return Home. Network outage itself cannot be optimized away.
- Cost on Blaze: 0 additional calls; can reduce up to 6 repeated loader attempts in a persistent failure episode, but actual saved Functions invocations/reads may be 0 because providers share results. No extra Hosting bytes.
- Security impact: none if ownership guards, paid-field expiry, server plan and durable delivery sequencing remain intact.
- Risk and effort: instrumentation 1–2h beta-safe yes; event-driven retry repair 4–8h only after reproduction, beta-safe conditional; needs board no for unchanged behavior, yes for altered error/loading policy.

## Startup timeline, serial dependencies versus parallel work

Arrows below mean awaited dependencies, not equal-duration stages. `||` means concurrent work. CPU work can still contend on the browser thread. “First visit” to Welcome (localStorage flag) and “uncontrolled visit” to the worker (controller absent) are independent predicates.

### HTML and engine, common path

1. Navigation obtains index.html. With a controlling worker this is network-first, up to 4s before cached fallback; no fallback means still waiting. Supplied live measurement: about 15KB, no-cache.
2. Parser encounters preconnect hints, then **history helper → PWA helper → Welcome helper → splash helper**, all synchronous head scripts. Downloads can overlap through preload scanning; execution is ordered. History only unwraps state; PWA only records install events until registration is called. Welcome reads localStorage, starts Geist font requests and installs tap handlers. Splash either stays hidden for Welcome or starts bold-font load and its 60s timer. HTML/CSS logo animation is not an awaited Flutter prerequisite.
3. Async flutter_bootstrap.js executes once fetched. `registerWorker(version)` precedes loader: **no controller: background register, immediate continuation**; **controller: matching-version registration/control or 4s race**. New-worker install fetches 11 shell files in parallel, then skipWaiting → cache deletion → clients.claim. Neither main.dart.js nor CanvasKit is in precache.
4. `_flutter.loader.load({})` starts **CanvasKit JS/WASM || main.dart.js**. The inspected generated loader starts CanvasKit before injecting the Dart script; its default entrypoint callback performs initializeEngine → engine runApp. Current local generated config is dart2js/CanvasKit with gstatic engine revision `83675ed27633283e7fc296c8bca22e841224c096`. Supplied live main transfer: 1.53MB Brotli and 2.1s; this is not an additional measured 2.1s on cache hits. Worker-controlled main misses may also start deferred warmup (F10).
5. Engine initialization obtains FontManifest and downloads **all font faces in parallel**, concurrently with renderer initialization, then joins. Fonts include engine Roboto fallback (F9). Then Dart main_prod executes. Engine runApp here means invoking the Dart application entrypoint; it is distinct from either Dart widget runApp below.

### Dart bootstrap before the real App, exact production-web sequence

Source: `lib/main_prod.dart:7-10`, `lib/app/bootstrap.dart:146-219,239-361`.

```text
main_prod: binding + path URL strategy → bootstrap(prod)
  install error recovery + bundled font-license registration
  runApp(temporary loading MaterialApp)                  [not real router]
  remember initial URL/local startup markers
  await Firebase.initializeApp
    core JS import → component JS imports in parallel
    App Check plugin initialization → other plugin initializers in parallel
    local-emulator connector returns in normal prod
  await explicit activateAppCheck(prod)
  await study storage opening
    Drift worker + WASM/storage selection → SELECT 1/migration readiness
    unsupported/damaged storage has explicit recovery/error branches
  await content database opening
    second WASM runtime in main thread + in-memory ContentDatabase
  await Remote Config
    settings → defaults → fetchAndActivate (each with 3s timeout)
  construct shared ProviderContainer
  await ensureAnonymous
    existing session: immediate; absent session: signInAnonymously
  start PWA install/storage persistence listener                 [not awaited]
  await mirror.start
    storedItems → sort → each enqueue awaited in order
    cached index: background catalog refresh, return
    no index: index → exam catalogs → parts, bounded 10s wait
  install content-access bridge                               [not awaited]
    entitlement changes debounce 5s → possible content refresh in background
  await persisted telemetry consent
    userSettings → opt-out identity clear → disable analytics
    OR enable analytics for previously granted consent
    Crashlytics absent on web, not a web report-upload barrier
  await registerDevProSwitch / registerDevDemoSwitch            [prod no-ops]
  await payment bootstrap
    local entitlement init → auth state → owner association
    → getWebEntitlement → persist authoritative state
    → install claims-change listener (later token refresh is background)
  await sync bootstrap
    local pending custom-track projection recovery
    → stable device ID read/create → install runtime and listeners
    actual runtime.update queued by auth/entitlement listeners [not joined]
  await localStudent loader                                   [prod no-op]
  register local onboarding presets                          [local/debug aid]
  await local panel bridge                                   [prod no-op]
  await age gate || active exam focus || onboarding complete
    shared 3s overall timeout; exam focus depends on content exam list
  install notifications lifecycle observer                    [no awaited permission]
  sendAppStarted                                              [8s splash timer starts]
  runApp(real App inside shared provider scope)
```

Corrections to prior review: **sync bootstrap does not await a complete cloud sync**, only local projection recovery/runtime creation. `SyncRuntimeBinding` schedules `.update()` but bootstrap never calls `.settle()` (`sync_runtime_bootstrap.dart:79-90,143-148`). These background context updates can later invalidate guarded Home work. Two SQLite runtimes do not imply two fresh network transfers: both reference sqlite3.wasm, with worker/HTTP cache reuse possible. No native protected-content install or native lesson-links asset load runs on this web path. Removing compile-time dev no-ops is not a meaningful speed fix.

### Router and returning Home

`App.build` starts study-delivery lifecycle, constructs router, reads theme and notifications; the root also wraps routes with sync reconciliation UI. `/` maps to `/home`; a valid direct path remains that path, subject to explicit cold-start remaps (`start_location.dart:51-126`). Router ordering is **minimum-version → exempt guardian/legal/email-link paths → beta → guardian restrictions → age/exam/onboarding**. Missing selected exam or incomplete onboarding goes to onboarding. A returning student is not guaranteed to land on Home.

For an authorized, onboarded returning student reaching Home:

```text
HomeTab waits activeExamFocus (usually already settled)
 → HomeTodayScreen captures auth/exam/owner guard
 → hold roadmapToday provider + start question launcher
 → shared roadmapToday
      study core epoch → auth/exam/owner/context
      cached public snapshot, if present, yields first
      background or cache-miss: pending settings retry → observations flush
        → getRoadmap [→ setExamSettings → getRoadmap only for missing settings]
 → after plan, concurrent branches:
      A: lesson metadata → topics → subjects → per-lesson read fractions
         → canAdvance + exam/settings + extras
      B: review hydration || all planned new-question hydration
         || current batch → per-session progress → quiz preferences
         → hydration join → ordering → lesson metadata/read IDs/topic names
 → join A + B → final owner guard → HomeTodayData
 → FutureBuilder done and not holding a settling retry
 → Flutter post-frame → one-shot JS ready → two animation frames
 → 400ms fade → splash DOM removal (0ms fade under reduced motion)
```

Roadmap stream updates trigger `_retry()` and can refresh this work; the cached roadmap is public-only and strips paid fields (`study_read_cache.dart:33-61`). Keep that restriction. Other Home widgets can fetch their own data while Today loads; Today readiness is not proof that every Home panel or background sync has finished. A reconciliation-required dialog can also make Home non-usable even after readiness (`sync_reconciliation_gate.dart:17-29`). The 8s fallback can uncover a skeleton before this join; the 60s fallback can uncover even earlier bootstrap.

**Active-beta variant:** fresh beta status commonly starts loading, redirects to `/beta`, and the beta SignInFrame can win the one-shot ready signal before Home (F8). Subsequent Home readiness then does not control splash removal. This is why field timing needs the identity of the first route, not only the DOM-removal event.

### First visit

```text
no Welcome mark → HTML Welcome visible; splash CSS never enabled
  Get Started can happen any time while engine/bootstrap run in background
  early tap: mark seen + Starting… → wait for appReady or 60s from tap
  late tap after appReady(holdForTap=true): remove immediately
real router:
  beta active + anonymous → beta/sign-in frame
    post-frame appReady(false) → HTML afterPaint → Welcome removed, even without tap
  beta inactive/allowed + new student → onboarding progress load
    construct resumed flow → post-frame appReady(true)
    wait for tap if not already tapped → remove Welcome → leave hook advances flow
  onboarding already complete but Welcome mark absent:
    App post-frame appReady(false), independent of Home data completion
```

An untouched Welcome has no automatic 60s escape until the tap; its timer is created in `start()`. A tap followed by closing the tab sets seen already, so the next visit shows the returning splash even if onboarding never finished. Guardian/legal links bypass Welcome but still use splash and their own route readiness. First-visit time-to-Home additionally includes sign-in/onboarding user actions and cannot be compared directly with returning splash duration.

## Priority for the November 9 beta

1. **F6 instrumentation**, 1–2h, then **F4 overlap Remote Config with storage**, 2–4h: strongest small, behavior-preserving first steps.
2. **F8 start the same beta check earlier**, 2–4h; **F7 overlap entitlement with content**, 4–6h with identity/downgrade tests. These target avoidable serial server work without weaker gates or added calls.
3. **F10 defer worker chunk warming**, 2–4h, if the controlled cold-load waterfall shows contention. **F5 local read batching**, 2–4h, if SQL/worker overhead is material.
4. F1/F2 release-consistent caching, F3 lazy content replay, F9 font packaging and F11 route-aware bootstrap are larger changes. Do not rush them immediately before beta based on unmeasured estimates. F12 requires a captured settling-race reason before changing retries.

No new paid warm instance, scheduler job, or service is recommended. All concurrency changes reuse existing operations; gains overlap and must not be summed. Byte savings are raw local-file ceilings, not production billing estimates. The brief's 10GB/month Hosting and 50k/day Firestore limits make avoiding duplicate fetching more useful than speculative prefetching.

Verification/limits: 12 findings appended during investigation. Source checkout has no tracked changes (`git status --short` reports only pre-existing `?? .claude/`). Only this output file was edited. No builds, tests, deploys, live browser journeys or production trace were run. Local build/SDK evidence is explicitly separated from pinned repository source; supplied live measurements were not independently repeated. Production BETA_GATE/WARMUP_ENABLED values and per-account cache/entitlement/sync states were not read. Those determine which conditional timeline a real visit takes.
