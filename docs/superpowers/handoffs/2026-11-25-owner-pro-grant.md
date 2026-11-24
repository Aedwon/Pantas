# Owner Pro grant on prod: stopped before the write (E-150)

Policy: main 0ab1bd61d (AGENTS, WORKFLOW, SUBAGENTS, process-improvement rule 7). Code read on main, which is what prod serves (functions from the Nov 24 main ship; web from 0db28d00f).

Request (Aedwon, Nov 25 about 12:35 AM Manila, relayed by the operations manager): "please grant highest possible Pro access to my email [his own address, kept private] on prod".

## Outcome

No prod write. Stopped for the manager's choice because no existing grant shape gives Pro for every exam in the app that prod serves.

## Findings (verified on the code)

- Server (`coverageAt`): a `beta` or `beta_reward` grant with an `examId` covers that exam for any catalog exam. 18 catalog exams: 11 Student, 4 Civil Service, 2 Licensure (LET, PNLE), 1 PSHS-NCE.
- App on web (`entitlementFromGrants`): maps `beta`/`beta_pro` only for exam_cse_pro and exam_cse_sub; ignores `beta_reward` rows entirely (audit ENT-06, planned as T17, not built on any branch); maps `web_trial` only as a 7-day-style trial ("Trial, N days left", clamped to 7); otherwise needs a known product, and the highest product tier in the app is Civil Service. No Licensure or NCE product exists. So no data-only write can show Pro for LET, PNLE or PSHS-NCE.
- A `trial` source row also feeds Study insights' trial-ending logic, and a paid SKU without a payment would look like a purchase. Both rejected.
- Nothing sweeps or revokes `beta`/`beta_reward` grants: no scheduled job, the purge treats an active grant as Pro running, `reanchorQueued` does not move them, `extend_beta_pro.mjs` only matches the old cutoff. `activateBetaReward` rewrites ids `beta_reward_<exam>` with 1-year rows if he ever activates his own tester reward (his reward state has a survey and no activation), so a write should use other ids.
- The Settings Beta Pro row needs `betaProUntil`, which is null since the beta ended, so no tester notice shows.
- His account: Google sign-in, one expired `beta` CSE Professional grant (ended Nov 23 Manila), no passes, no store facts. Private record: `Pantas-private/releases/2026-11-25-owner-pro-grant/before.json`.

## Options given to the manager

1. Recommended: 18 `beta_reward` rows (each exam's own tier, 10 years, ids `owner_<examId>`) in one transaction, claims recomputed and copied. Server covers all 18 at once; the app shows it when T17 ENT-06 ships, which testers' rewards need anyway (High).
2. 18 `beta`/`beta_pro` rows plus an app change dropping the CSE-only filter. CSE shows now; may collide with T11's beta-surface removal.
3. New `comp` source on server and app. Cleanest label, most work (server and web deploy, tests, review).

## Cost (rule 7)

Prod this quota day before the probe: 6,996 reads, 854 writes. Probe: about 5 reads. Option 1 live: about 10 reads and 20 writes plus a dry run of about 5 reads.

Velocity E-150 timer paused (waiting on the manager).
