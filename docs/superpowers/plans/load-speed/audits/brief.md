# Pantas web load-speed audit brief (Nov 7, 2026)

Policy: AGENTS.md, WORKFLOW.md, SUBAGENTS.md from Aedwon/Pantas main at 8d81dad6f.
Source under audit (READ ONLY): /Users/aedwon/Documents/Projects/Pantas-wt-vc-fixes-r1
at 571eea1aa (branch web/visual-check-fixes-r1, the build live at https://app.pantas.study).
Flutter web (dart2js + CanvasKit), Firebase (Hosting, Auth, App Check, Firestore,
Functions v2 in asia-southeast1, Remote Config), project pantas-prod on the Blaze plan.

## Goal

The returning-visitor splash (logo + "Pantas" wordmark, `web/pantas_splash.js`) stays
too long on first load. Find what makes time-to-usable-Home slow, and anything else
that makes the app feel slow after Home (screen switches, lesson/quiz open, reloads).
Closed beta starts Nov 9: rank by gain per hour of safe work.

## Hard constraints for any recommendation

- No security weakening: App Check, auth, Firestore rules, signed content packages,
  beta gate, rate limits stay as strong as now.
- Stay inside Blaze no-cost quotas where possible (Functions 2M invocations/month,
  Firestore 50k reads/day free, Hosting 10 GB/month transfer, 3 free Scheduler jobs).
  Say the cost impact of every recommendation in numbers. minInstances costs money:
  only recommend it with a cost figure.
- No visible design change without Aedwon's approval (flag it as "needs board").
- Do not re-derive the prior review (prior-sol-review.md in this folder). Verify,
  correct, or go deeper on it, and find what it missed.

## Already measured live (curl, Nov 7 16:38 PHT, from Manila)

- index.html 15 KB, no-cache. main.dart.js 7.23 MB raw, 1.53 MB brotli, `no-cache`
  (not fingerprinted), 2.1 s download here.
- CanvasKit loads from www.gstatic.com (chromium variant ~1.6 MB). A self-hosted copy
  exists at /canvaskit/ with max-age=3600.
- Fonts and assets: max-age=3600, brotli.
- flutter_bootstrap.js awaits pantasPwa.registerWorker (up to 4 s on return visits)
  before `_flutter.loader.load`.
- Splash is removed only when the first route reports settled data (`ready()`).
- Already live from the Nov 6 minimal batch: preconnect hints in index.html,
  `keepCallablesWarm` scheduled pings (every 5 min), Home plan and questions prepared
  side by side (commit 8ee3d54c0).
- Nov 6 production logs: cold callables 2 to 5.4 s, warm 0.07 to 0.3 s.

## How to work: WRITE AS YOU GO (mandatory)

Your output file is named in your prompt. Within your first few minutes, create it
with a one-line header. Then APPEND each finding the moment you confirm it, before
investigating the next one. Never hold findings for a final summary. If you run out
of budget, what is already in the file is the deliverable. A final summary at the end
is optional and short.

Finding format (one block each, appended):

```
## F<n>. <one-line title>
- Where: path:line (on 571eea1aa), plus the call chain that makes it block
- What happens now: ...
- Change: ...
- Gain: <seconds or %>, label MEASURED / ESTIMATED, and for which visit (first, return, after deploy)
- Cost on Blaze: ...
- Security impact: none / describe
- Risk and effort: <hours>, beta-safe yes/no, needs board yes/no
```

Read code, do not run builds or deploys, do not edit any file except your own output.
Stop after about 12 solid findings or when your area is exhausted.
