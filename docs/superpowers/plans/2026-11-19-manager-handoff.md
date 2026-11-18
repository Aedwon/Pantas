# Operations manager handoff, 19 November 2026

From the T3 Code operations manager thread to a new manager in the Claude Code desktop
app, on Aedwon's second Claude account. Written 18 Nov 2026 about 17:30 UTC (19 Nov PHT).

Read first, in order: `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`,
`docs/workflow/operations-manager.md` (standing rules and takeover checklist),
`docs/workflow/process-improvement.md` (rules 5 to 9 and the Nov 15 to 17 entries),
`docs/superpowers/backlog.md`.

## What changes with the move

- **The leads live in T3 Code threads.** The desktop app cannot message them, read them, or
  run T3 scheduled tasks. A new manager either works directly in the repo, or starts fresh
  leads (subagents or new sessions) from this file and the specs named below.
- **T3 scheduled reminders are paused** (heartbeat, cache keep-alive, daily sweep,
  housekeeping, beta monitor, SSOT update), because the first account's weekly usage hit
  98%. Four one-off reminders are still enabled in T3 and run only if T3 is open
  (see "Dates"). Re-create anything you need with the desktop app's own scheduling.
- **Codex:** Aedwon resets accounts manually when one hits its weekly limit. No 90% alert
  is needed. Weekly use on 18 Nov: a 90%, b 82%, c 82%; all reset Sun 22 Nov about 13:40 PHT.
  Run Codex only through `~/.local/bin/codex-pick`. Never Codex for UI. GPT 6.2 Sol and
  Astra are not available on these accounts yet (tested 18 Nov); keep 6.1 Sol and 6 Astra.

## Waiting on Aedwon

1. **"Ship it" for two builds on staging** (one "ship it" can cover both):
   - **S-12 checkout fix**: a failed checkout no longer locks a plan. Main `cd959981a`,
     Fable-ruled, Codex-reviewed, staging proof passed (log `50a496585`, `73ee023b6`).
     Functions deploy.
   - **Figure answer choices (Minimal)**: painter fixes `cbee44e9a` (series 0018 ray,
     matrices 0008 dots, numbered shape rows) and 2-by-2 figure tiles `150afa3ce`.
     Staging web 2226885836-7abd7148d600. Golden sheets in `test/goldens/files/figure_choice_tiles_*.png`.
     Tiles show on no live question until generator data reaches staging about 1 Dec.
2. **Under-13 accounts**: board picks on https://claude.ai/artifact/PqxcZvKQheCogaXH6LidPM
   (1A, 2A, 3A, 4B, 6B, 7A, 8A, 9A recommended) by 23 Nov to keep prod about 11 Dec;
   legal sign-off on the multi-child change; signed child privacy assessment before child
   accounts open. Decided: guardian holds the account; up to 5 children per email;
   second child full price ₱1,499. Spec on `spec/under-13-accounts` (`09f46ff87` or later).
3. **Web plan renewals**: today web checkout charges once per period and nothing renews.
   Recommendation: keep prepaid periods for launch (PSHS-NCE pass is one-time). Adding
   renewals is 3 to 5 days plus screens and legal text. Answer in the tracker below.
4. **PayMongo support request**: send the drafted message in
   `docs/payments/2026-11-18-paymongo-support-request.md` (Subscriptions on Maya and cards,
   GCash question, QR Ph refunds). Update its tracker as replies arrive.
5. **CET content resume**: recommended right after the Codex reset on 22 Nov (ACET test
   16 Jan 2027). Verification build and founder app wait until under-13 and figure work finish.
6. **PSHS-NCE partials** (backlog D21 grammar and science, D22 dots-in-shapes figure kind):
   decide before the 8 Dec go/no-go; both need Codex after 22 Nov.
7. **Disk**: 24 GB free, under the 40 GB floor. He declined removing the Android SDK.
   Caches (`~/Library/Caches`, `~/.cache`) were offered, not answered.

## Lanes and where their work is

| Lane | State | Where |
|---|---|---|
| Question generator | Phase 1 done: 28 abstract reasoning types approved, figure sheets reviewed. Two held types wait for the Codex reset. Phase 2 (app and server) starts 23 Nov; data on staging about 1 Dec | `gen/question-generator-r1`; spec `docs/superpowers/specs/2026-11-17-question-generator-design.md`; plan `docs/superpowers/plans/2026-11-17-question-generator.md` |
| Under-13 accounts | Spec, legal draft and boards done; build 8.5 to 10 working days after board picks | `spec/under-13-accounts` |
| Figure answer choices | Built, on staging, waits on "ship it" | spec `docs/superpowers/specs/2026-11-18-figure-answer-choices-design.md` on main |
| Security and billing | S-12 on staging. Old secret versions on staging and prod are destroyed about 18:23 and 18:27 UTC 18 Nov (backup reminder 18:32 UTC); then verify `node tool/checks/free_tier_live.mjs` shows secrets OK. Staging read budget now counted per Pacific day | security-fixes worktree; `docs/OPERATIONS.md` |
| PSHS-NCE content | Two abstract lessons written and checked; science, verbal, abstract mapped to the official 2024 sample | `content/pshs-nce-r1` |
| Integrator | Ships to staging and prod; logs every ship in the launch log | `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` |
| Beta | Credited days close 22 Nov; survey to 24 Nov 00:00 PHT. Almost no tester study since 12 Nov. Reward list due 22 Nov | `/Users/aedwon/Documents/Projects/Pantas-private/beta/digest.md` (private) |

Shipped this session (all under his "ship it"): five prod figure question fixes (content
root `646326517`), the account-switch leak fix and guardian-contact erase (prod web
1533709692-7d81e80cdc55, main `5e57e3a45`, 18 Nov 05:59 UTC).

## Dates (next 14 days)

- 18 Nov 18:32 UTC: T3 backup reminder to destroy old secrets (still enabled in T3).
- 21 Nov 06:10 UTC: turn on prod Firestore App Check if staging stayed clean (T3 reminder still enabled).
- 22 Nov: Codex weekly resets; beta credited days close; reward list (T3 reminder 16:15 UTC).
- 22 Nov 02:00 UTC: free-tier gate check before the 24 Nov 00:00 PHT CI gate (T3 reminder).
- 23 Nov: under-13 board picks needed; generator Phase 2 starts.
- 24 Nov 00:00 PHT: survey closes; warm-up stops; free-tier CI gate.
- 1 Dec 02:00 UTC: monthly cost check (T3 reminder).
- 8 Dec: PSHS-NCE go/no-go.

## Standing rules to keep

- No prod deploy without his explicit "ship it". Destructive or external changes need his
  approval unless delegated.
- Rule 7: only real users may cost money. Rule 9: privacy changes are emailed before they
  take effect after launch. Every email goes to him first.
- Never print secrets; Cloudflare token lives in `~/.config/pantas/cloudflare.env`.
- Public repo: no tester names, emails or account ids; those go in Pantas-private.
- No AI or Co-Authored-By trailers in commits.
- Decisions that are not his (not "ship it", legal sign-off, purchases or physical steps)
  go to a Fable 5.2 ruling. Content edits go through the approval gate before export.
- Replies to him: plain, short, no em dashes, files as clickable links.
