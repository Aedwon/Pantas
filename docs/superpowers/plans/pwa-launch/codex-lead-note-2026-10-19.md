# Note to the Codex lead: resume after the usage limit (October 19, 2026 evening)

From the Claude lead (cloud session). Aedwon asked to resume you. Your last run stopped at
18:07 on a usage limit while "preparing audit completion" for W4c; nothing was pushed after it.

## State you left (checked on the Mac at about 20:40)

- No `codex exec` process. The `STATUS.md` lock (held since 18:06) is stale under its 2-hour
  rule: take it again by the rule.
- W4c: 7 local commits ahead of `origin` (f495a8dd); still local-only until its family audit.
- W4d: 2 uncommitted files. W4f: 29 uncommitted files. W4a: 5 uncommitted files. W4b and W4e at
  their remote heads (b99c1679, e3ba3785). Preserve all of it.

## Server contracts now ready (Claude-owned; read, do not edit)

Branch `web/pwa-staging-r1` at 2c2332e0 (pushed). Design: `web/README.md` there, and
`pwa-launch/C7-client-ruling.md` on main.

- Content (C7): `getContent` kinds `lessons`, `questions`, `catalog`. On web the app reads
  through an in-memory `ContentDatabase` filled from a server catalog; `ContentRepository`,
  `LessonRepo` and `QuestionRepo` gained an optional `fetchHook` (web only). Screens keep reading
  the existing repositories.
- Mocks (C8b): `startMock`, `getMockPaper`, `controlMock`, `submitMock` in `functions/src/mock.ts`:
  server-pinned paper, server clock, strict time-out, non-strict pause and discard, Free one per 30
  days counted at submission, named accounts only. CSE blueprints are in `content/mock/`.
- Roadmap (C10, no insights yet): `setExamSettings` (exam date, study days) and `getRoadmap`
  (Free gets Today; Pro also Coming up and History) in `functions/src/roadmap.ts`; recomputed when
  `ingestSession` stores a session.
- The app wiring for mocks, settings and roadmap does not exist yet. It belongs to the W4
  families that own those screens (W4e mock, W4b roadmap). Reconcile before any local-computation
  change, as your plan says. Pro insights on the server (C10 signals refactor) still needs
  coordination with W4b: propose how you want it ordered.

## Files likely to conflict at integration

- `lib/core/storage/storage.dart` (W4d changes it; staging passes `fetchHook` there).
- `lib/app/bootstrap.dart` (W4h changes it; staging adds the web content bootstrap and App Check).

## Not available yet

- Staging deploy is blocked: no Firebase project has the Blaze plan (Aedwon's cards were declined).
  Do not plan on deployed functions until Aedwon reports billing.

Records: `pwa-launch/RESUME.md` and `decisions/2026-10-19-pwa-launch-log.md` on main.

## Addendum, October 19 late evening: approved copy for W4e

Aedwon approved one added line on the mock setup screen (`MockSetupPage`), placed right after the
paper-rule text, same style as its secondary neighbors (`type.subhead`, `colors.secondaryLabel`,
10 px gap):

- CSE Professional: "The real exam also has 15 personal-information items. They are not scored, so
  this mock leaves them out."
- CSE Subprofessional: the same with 20.

Take the count from the blueprint (a new optional field, for example `unscoredItems`, beside the
existing fields; no line when absent), not from hard-coded text. The CSE blueprints on
`web/pwa-staging-r1` no longer set `totalPublishedItems`, so the screen shows 155 and 145 total
items. Approved preview: https://claude.ai/artifact/VWUTUbGtQoK7iruAaBiME9 (private to Aedwon).

## Addendum 2, October 19 late evening: W4e has moved to Claude

Aedwon moved W4e (mock screens) to a Claude builder while Codex was out of usage. Do not work W4e.
Lane 1 stays yours (W4c audit and integration, then W4b); in Lane 2 you take W4d. The Claude lead
pushes W4e from its worktree (including your local commit 3b454b3a) and records progress in
`pwa-launch/RESUME.md`. Coordinate any W4e question through that file or the decision log.
