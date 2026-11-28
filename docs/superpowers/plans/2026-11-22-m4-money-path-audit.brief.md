# M4 money-path audit: Codex brief and command (ready to run after Aedwon's Codex reset)

Owner: security and billing lead (r2). Plan: `docs/superpowers/plans/2026-11-22-m4-security-pass.md`, part 5.
Manager (Nov 22): "Codex weekly room is spent until Aedwon's reset, so do the Codex money-path audit right
after it; leave a ready-to-run command and brief."

## Before running

1. Run `~/.local/bin/codex-pick --status`. Start only when an account shows 5-hour room, and count active
   Codex runs across lanes: the machine-wide cap is 2 at once (process-improvement, Nov 21).
2. Create two fresh read-only worktrees at the current `origin/main`:
   `git worktree add --detach ~/.t3/worktrees/Pantas/m4-audit-pay origin/main` and the same for
   `m4-audit-ent`. Each run appends findings to `FINDINGS.md` in its own worktree root as it finds them,
   so a stop on a usage limit keeps the work.
3. Each run is sized for one account's 5-hour window (about 930 and 970 lines of code).

## Commands

```sh
B=docs/superpowers/plans/2026-11-22-m4-money-path-audit.brief.md
for part in pay ent; do
  W=~/.t3/worktrees/Pantas/m4-audit-$part
  CODEX_PICK_PARALLEL=1 ~/.local/bin/codex-pick exec -m gpt-6.2-sol -c 'model_reasoning_effort="high"' \
    -s workspace-write -C "$W" --skip-git-repo-check -o "$W/audit.out" \
    "$(sed -n '/^## Brief: common/,/^## Brief: end/p' "$W/$B"; sed -n "/^## Scope: $part/,/^## Scope: end $part/p" "$W/$B")" \
    < /dev/null > "$W/audit.log" 2>&1 &
done; wait
```

On exit 75 (every account full), commit nothing, note which accounts are full, and tell the manager. The
lead then verifies every finding in code before it counts, and fixes go test first on `web/security-m4-r1`.

## Brief: common

You are a read-only security auditor for the Pantas repository (a Flutter web PWA with a Firebase backend in
`functions/`, TypeScript). Read `AGENTS.md` and `SUBAGENTS.md` first. Do not edit any tracked file, run no
deploy, gcloud, Firebase or network command, and print no secrets. Never fix anything.

Audit the money path in your scope for anything that lets a student get paid access without paying, keep it
after a refund or chargeback, pay and not receive access, be charged twice, or lets anyone else read, change or
grant another account's entitlement or payment data. Check in particular: webhook signature checks and replay
(timestamps, event ids, livemode), idempotency of grants and refunds, partial and full refunds, amounts and
currency against `functions/src/products.json` and `docs/pricing.md`, product and exam binding, prepaid
periods and pass sittings, trial abuse (one trial per account and per parent email), concurrency (two
webhooks or a webhook and a checkout at once; transactions and their retries), account deletion and account
switching while a grant is pending, entitlement claims in ID tokens and their refresh, error paths that grant
or revoke by mistake, and any client input that reaches a money decision.

Append each finding to `FINDINGS.md` in the worktree root the moment you find it: id, severity (Blocker,
High, Medium, Low), file:line, the exact failing scenario with inputs, why the code allows it, and the smallest
fix. Do not fix it. Write a line `PROGRESS: <area> done` after each area. End with a summary table and the
line `STAGE-DONE`.

## Brief: end

## Scope: pay

Scope: PayMongo checkout, webhook, grants and refunds: `functions/src/paymongoCheckout.ts`,
`paymongoWebhook.ts`, `paymongoGrants.ts`, `paymongoPolicy.ts`, `paymongoClient.ts`, `grants.ts`, and every
helper they call. Include the manual QR Ph refund path in `docs/OPERATIONS.md` ("Manual QR Ph refund").

## Scope: end pay

## Scope: ent

Scope: RevenueCat, passes and web entitlement: `functions/src/revenuecatWebhook.ts`, `revenuecatSubscriber.ts`,
`revenuecatClaims.ts`, `revenuecatPasses.ts`, `revenuecatPolicy.ts`, `revenuecatCoverage.ts`, `webPlans.ts`,
`webEntitlement.ts`, `entitlementInputs.ts`, the trial and beta reward callables, and the Firestore rules for
`users/{uid}/grants` and `users/{uid}/passes`.

## Scope: end ent
