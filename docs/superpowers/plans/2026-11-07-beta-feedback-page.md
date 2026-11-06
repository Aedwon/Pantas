# Feedback (Beta) page: implementation plan

Date: November 7, 2026. Lead: Claude (Opus 5.5). Policy revision: origin/main 6c0f79cc0.
Spec: `docs/superpowers/specs/2026-11-07-beta-feedback-page.md` (behavior approved by Aedwon in
chat on Nov 7: "balanced is approved + attachments. let's build it", rest-day rule and Dec 31,
2027 deadline: "go with your reco"). Base: `web/visual-check-fixes-r1` at 943411098.
Design: canvas https://claude.ai/artifact/Qomyc2zSW8ngMgwQieHbRL. The client lane starts only
after Aedwon approves the boards; it then matches them 1:1.

## Global constraints

- `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from origin/main apply.
- No deploys, no pushes by workers, no merges by workers. Commit on your own branch only.
- No AI attribution in commits. Messages say why.
- Philippine time is Asia/Manila (+08:00, no DST). All windows are server constants.
- Never invent a figure: the only numbers shown are the tester's own day count and dates.

## Lanes, worktrees and file ownership (collision map)

| Lane | Worker | Branch / worktree | Owns | Must not touch |
|---|---|---|---|---|
| S: server | Codex GPT 6.1 Sol | `web/beta-feedback-r1` / `Pantas-wt-beta-feedback-r1` | `functions/src/**`, `functions/test/**`, `firestore.rules`, `storage.rules`, `firebase.json` (only if needed) | `lib/`, `test/`, `pubspec.*`, `web/` |
| C: client | Sonnet 5.5 | `web/beta-feedback-ui-r1` / `Pantas-wt-beta-feedback-ui-r1` (branched from lane S once S is committed) | `lib/features/beta_feedback/**` (new), `lib/features/settings/**` (row + routes), `lib/app/routes/settings_routes_*.dart`, the day-report hook (see C3), `test/features/beta_feedback/**`, `pubspec.yaml` (one picker package) | `functions/`, rules files |

Other active work on `web/visual-check-fixes-r1`: Home plan task 2 of
`docs/superpowers/plans/2026-11-06-load-speed-minimal.md` (Home and roadmap read paths) is
unassigned. Lane C must keep its day-report hook out of Home widgets (put it beside quiz
completion and the roadmap day repository) to avoid that collision. The lead merges S, then C,
into `web/visual-check-fixes-r1`.

## Dependencies

S1 → S2..S5 (shared module). C starts after S is committed and the boards are approved. C1 → C2
→ C3/C4/C5 (C3 independent of the page UI).

## Interfaces lane C depends on (exact)

All callables: region `asia-southeast1`, App Check limited-use token, signed-in named user.

- `sendBetaFeedback({feedbackId: string /[A-Za-z0-9]{20,32}/, text: string, attachments:
  {path: string, contentType: 'image/png'|'image/jpeg'|'image/webp'}[] (0..3), userAgent?:
  string, appVersion?: string, examId?: string})` → `{feedbackId, createdAt: number}`.
  Upload path: `betaFeedback/{uid}/{feedbackId}/{index}` with index 0..2.
- `recordBetaDay({kind: 'plan'|'restDay'})` → `{recorded: boolean, reason?: 'outside', days:
  string[]}`.
- `submitBetaSurvey({answers: {usage: 'every_day'|'most_days'|'few_days'|'once', ease: 1..5,
  usefulness: 1..5, continue: 'yes'|'maybe'|'no', recommend: 0..10, improve: string,
  other?: string}})` → `{submittedAt: number}`. Errors: `failed-precondition` (window),
  `already-exists`.
- `activateBetaReward({})` → `{startsAt: number, endsAt: number, exams: number}` where
  `startsAt` is the earliest start and `endsAt` the latest end across the per-exam reward
  grants, and `exams` the number of grants written. `getBetaReward` reports the same aggregate
  as `rewardStartsAt` / `rewardEndsAt`. Errors:
  `failed-precondition` with message naming the unmet condition.
- `getBetaReward({})` → `{days: string[], betaDays: string[7], surveyOpensAt, surveyClosesAt,
  surveySubmitted: boolean, eligible: boolean, activatedAt: number|null, rewardStartsAt:
  number|null, rewardEndsAt: number|null, activationDeadline: number}` (ms epoch).
- Sent list: client reads `users/{uid}/betaFeedback` ordered by `createdAt` desc (owner-read
  rule). Images: Storage download URLs for the owner.

## Lane S tasks (server)

- **S1** `functions/src/betaReward.ts`: window constants, `manilaDate(ms)`, `isBetaDay`, survey
  window, deadline; unit tests at each +08:00 midnight edge.
- **S2** `sendBetaFeedback` with Storage metadata checks (Admin SDK `file.getMetadata()`: exists,
  content type, size <= 5 MB), idempotent by `feedbackId`, limit 40/day. Tests.
- **S3** `recordBetaDay`, `getBetaReward`. Tests: outside window, duplicate date, 5-day count.
- **S4** `submitBetaSurvey`. Tests: each field's validation, window edges, single submission.
- **S5** `activateBetaReward` and the reward grants. Lead ruling (Nov 7, after Codex found that
  one tier grant cannot cover both NCE and the other tiers, `revenuecatCoverage.ts` `coversExam`):
  the reward is **one grant per exam in the catalog at activation time**, at
  `users/{uid}/grants/beta_reward_{examId}`, `source: 'beta_reward'`, `product: 'beta_reward'`,
  `tier` = that exam's tier, `examId` set. Coverage treats `beta_reward` exactly like `beta`
  (a per-exam pass in `passes`), so no tier or claims model change. Start per exam = max(now,
  the latest end of live coverage that already covers that exam, excluding `beta` grants): paid
  or trial tier coverage of equal or higher rank (NCE only by NCE), store subscriptions or
  promotions, and passes for that exam. End = start + 1 calendar year in Asia/Manila. Make sure
  entitlement claims become correct when a queued reward grant's start time arrives (follow how
  queued paid grants get their claims refreshed; if nothing does, recompute on `getBetaReward`
  and on `getWebEntitlement`, and say which). Exams added to the catalog after activation are not
  covered; note that limit in a code comment. `beta_reward` grants do not count against
  web-trial eligibility (same rule as `beta`). Add `'beta_reward'` to every source union
  (`grants.ts`, `revenuecatCoverage.ts` `LedgerGrant`) and handle it wherever `'beta'` is
  special-cased. Write all grants in one transaction with `state.activatedAt`; a second
  activation returns the existing result. Tests: not eligible (days, survey), deadline, double
  activation, queued after an active paid grant (start equals paid end), NCE and non-NCE exams
  both covered, trial eligibility unchanged, claims after the queued start.
- **S6** Rules: Firestore owner-read/no-write for `users/{uid}/betaFeedback/*` and
  `users/{uid}/betaReward/*`; Storage `betaFeedback/{uid}/{feedbackId}/{0|1|2}` owner create
  only, <= 5 MB, png/jpeg/webp, owner read. Rules tests in the existing style.
- **Checks:** `npm test` in `functions/` green; lint if present.

## Lane C tasks (client), after board approval

- **C1** Data layer: gateway for the five callables (use `callFirebaseFunction` /
  `callableOptionsFor` as in `beta_pro_provider.dart`), feedback list stream, Storage upload with
  progress, Riverpod providers. Tests with fakes.
- **C2** Settings row (visible when `betaAccessProvider` is true, including after Nov 16), route
  `/settings/beta-feedback` in web and native route lists and the wide-web layout, and the page
  with every board state, copy and motion 1:1. Widget tests per board state, hidden for
  non-testers.
- **C3** Day-report hook: when `DaySnapshots.originalDone` first becomes true for today's
  snapshot, call `recordBetaDay(kind: 'plan')`; on a rest day, after a streak-eligible session
  completes (`SessionOrigin.isStreakEligible`, `session.isComplete`), call
  `recordBetaDay(kind: 'restDay')`. Once per local date (remember locally), only for selected
  testers, only local dates Nov 8 to 16; failures silent, retried next app open the same day.
  Tests for each trigger and no repeat.
- **C4** Image picking: one maintained package with web support (`image_picker` preferred),
  5 MB refusal, png/jpeg/webp only.
- **C5** Survey and activation flows per boards; error states for each callable error.
- **Checks:** `flutter analyze` clean, focused `flutter test` for touched areas,
  `dart run tool/checks/run_checks.dart` clean. Full suite runs on hosted CI after the lead merges.

## Lead verification

Review each lane's diff against the spec and boards; run the combined checks; deploy rules and
functions to pantas-prod (needs Aedwon's go per the beta release authority already given, Nov 6:
"if you can do something without needing me, please do it"); build and deploy the web app; update
the guide and emails; dry-run the results email.
