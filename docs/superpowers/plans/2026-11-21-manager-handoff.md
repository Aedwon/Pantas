# Operations manager handoff, 21 November 2026

For a fresh operations manager. Written 21 Nov 2026 about 07:00 UTC (15:00 PHT) from main
`78182690a`. It replaces the 19 Nov handoff. Work done on Aedwon's second Claude account (Pro
plan) since 19 Nov is folded in from the launch log; where the repo does not say, this file says
"unknown, check".

Read first, in order: `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`,
`docs/workflow/operations-manager.md` (standing rules and takeover checklist),
`docs/workflow/process-improvement.md` (rules, and the Nov 19 entry on the Pro account's usage
cap), `docs/superpowers/backlog.md` (last swept 19 Nov; stale, see "First tasks"), and the launch
log `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` from "Nov 19 (Manila)" onward.

## Usage limits (read before starting anything)

- **Claude Pro account:** one Claude lane at a time, at most 2 workers per lead, Sonnet or Haiku
  workers by default, pause lanes when the 5-hour limit passes 70%. Bulk reading and writing go to
  Codex. Fable 5.2 has no usage credits on this account: the lead's own ruling stands in for a
  Fable ruling, and is logged as such.
- **Codex:** default model is GPT 6.2 Sol everywhere (Aedwon, 19 Nov: "use 6.2 Sol as the default
  everywhere"). Astra stays GPT 6 Astra but the CET lane dropped it. Run only through
  `~/.local/bin/codex-pick`. Never Codex for UI. On exit 75, commit work in progress and tell Aedwon
  which accounts are full; he resets them by hand (he has manual resets left). No 90% alert needed.
- Codex at 21 Nov 07:00 UTC: a 41%, b 30%, c 31% weekly; weekly resets Fri 27 Nov about 01:00 UTC.

## Decisions waiting on Aedwon

1. **Prod Firestore App Check is held.** The security lead found 5 refused sign-in requests on
   prod (18 Nov 06:01, 06:06, 17:41 twice; 20 Nov 18:06 UTC), all from one Mac desktop browser.
   Ask him: was that his own browser (or an agent's browser check)? If yes, enforce Firestore and
   keep Auth on. If it is an unknown real user, the lead proposes the next step (possibly an Auth
   rollback). The lead is waiting on this.
2. **Disk:** 10 GB free on 21 Nov, under his 15 GB floor ("lower the floor to 15 GB until asking
   me again"). Housekeeping is paused, so nothing cleans. Ask before cleaning; he declined
   removing the Android SDK; caches (`~/Library/Caches`, `~/.cache`) were offered, not answered.
3. **PSHS-NCE partials** (backlog D21 grammar and science, D22 dots-in-shapes figure kind):
   decide before the 8 Dec go/no-go.
4. **Under-13 notice wording** on rate-limit record retention (30 days): he confirms at staging.
5. **Signed child privacy assessment** before child accounts open.

## Lanes

| Lane | State | Where |
|---|---|---|
| Under-13 accounts build | In progress. T1 to T8 and T11 merged (server: 748 unit, 910 emulator tests pass). Next: T9 (boards 3A, 4B, 4 confirms, 5, the parent delete link, checkout box screen), then T10, T12, T13. Codex 6.2 Sol High reviews server, switching and code gate. All boards picked (1A 2A 3A 4B 6B 7A 8A 9A; 7A shorter description; 8A reuses the beta sign-in code entry 1:1). Legal multi-child change signed off. Estimate E-124, 8.5 to 10 working days | draft PR #76, `claude/under-13-build-386afc`; plan `docs/superpowers/plans/under-13-accounts/2026-11-19-build-plan.md` on that branch |
| CET content | Done and on prod (20 Nov 17:51 UTC): 189 sets, 4,427 questions, six mocks fill on prod. CET exams stay "Coming soon"; opening them is his separate decision | `content/cet-bite-r1` d97de9415; `docs/superpowers/plans/2026-11-19-cet-bite-sized-finish.md` |
| Security and billing | Prod usage alarms now feed the billing cutoff (live, 21 Nov). Old secrets destroyed (4 active versions). Warm-up stops in code at 23 Nov 16:00 UTC (shipped). Firestore App Check held (decision 1) | `docs/OPERATIONS.md`; launch log |
| Question generator | Phase 1 done (28 types). Phase 2 (app and server) due to start 22 Nov 16:30 UTC by a T3 reminder; on desktop, start it by hand. Uses Codex; T3 brief still names 6.1 Sol, use 6.2 Sol | `gen/question-generator-r1`; spec `docs/superpowers/specs/2026-11-17-question-generator-design.md`; plan `docs/superpowers/plans/2026-11-17-question-generator.md` |
| PSHS-NCE content | Idle since 17 Nov: two abstract lessons written; science, verbal and abstract mapped to the 2024 sample (45 covered, 21 partial, 4 missing). Its 5 new lessons still need the bite-sized treatment | `content/pshs-nce-r1` 68968b3e0 |
| Payments | PayMongo upgraded to Sole Proprietor; GCash, Maya, cards requested; support request sent 19 Nov, no reply logged. Launch keeps prepaid periods (decided 19 Nov). Prod still on PayMongo test keys | `docs/payments/2026-11-18-paymongo-support-request.md` (tracker) |
| Beta | Credited days close 22 Nov; exit survey to 24 Nov 00:00 PHT. Reward list due 22 Nov (5 days plus a sent survey). Names stay private | `/Users/aedwon/Documents/Projects/Pantas-private/beta/digest.md` |
| Integrator | Ships to staging and prod; logs every ship | launch log |

Shipped since 19 Nov, all under his "ship it": S-12 checkout fix and figure answer choices
(prod web 166853056-ca9fc113d66f, 18 Nov 17:33 UTC); CET release (prod web
1275724943-da801388b12a, 20 Nov 17:56 UTC). Rollback points are in the launch log.

Stray branch: `work/cet-algebra-restore` holds WIP from the 19 Nov pause. Unknown whether it was
folded into the CET release; check before deleting anything (deleting needs his approval).

## Dates (next 14 days)

- 22 Nov: beta credited days close; reward list (T3 reminder 16:15 UTC). Staging read overage
  from 15 Nov ages out of the 7-day window.
- 22 Nov 02:00 UTC: free-tier gate check before the 24 Nov CI gate (T3 reminder). Secrets and
  warm-up are both shipped, so the gate should pass; run `node tool/checks/free_tier_live.mjs`.
- 22 Nov 16:30 UTC: question generator Phase 2 start (T3 reminder).
- 23 Nov 16:00 UTC: warm-up stops in code.
- 24 Nov 00:00 PHT: exit survey closes; free-tier CI gate.
- 27 Nov about 01:00 UTC: Codex weekly reset.
- 1 Dec 02:00 UTC: monthly cost check (T3 reminder).
- 8 Dec: PSHS-NCE go/no-go.

The T3 reminders above run only if T3 Code is open. In the desktop app, recreate the ones you
need with its own scheduling.

## First tasks for the new manager

1. Ask Aedwon decision 1 (the refused browser) and decision 2 (disk).
2. Sweep `docs/superpowers/backlog.md`: mark CET (A11) shipped, S-12 and figure choices shipped,
   under-13 boards and legal sign-off done, PayMongo request sent, renewals decided.
3. Confirm the next lane with him under the one-lane rule: under-13 T9 (Claude) is the default;
   generator Phase 2 and PSHS-NCE run on Codex alongside it.

## Standing rules

- No prod deploy without his explicit "ship it". Destructive or external changes need his
  approval unless delegated.
- Rule 7: only real users may cost money. Rule 9: privacy changes are emailed before they take
  effect after launch. Every email goes to him first.
- Never print secrets; the Cloudflare token lives in `~/.config/pantas/cloudflare.env`.
- Public repo: no tester names, emails or account ids; those go in Pantas-private.
- No AI or Co-Authored-By trailers in commits.
- Content edits go through the approval gate before export.
- Never ask him to write legal text.
- Replies to him: plain, short, no em dashes, files as clickable links.
