# CSE release lead r9: opening prepared, final staging proof Friday 8 PM, opening Saturday 6 AM

Written Nov 26, about 11:20 UTC (7:20 PM Manila) by the CSE release lead r9 (integrator). Read this instead of the r9 thread. Policy read from main 57e075ef6 and refreshed through 8acb6f0a9. Manager thread: mcp:launch:aec6f0b94357a6bdd55f540c8424f611aeda70dba0b2000f468126a93604918c (took over Nov 26; the old one, mcp:launch:00976645…, is retired). Every step is in the launch log (Nov 26 entries from "next batched web update rides the opening build" on).

## His decisions that govern the next steps (verbatim, all in the launch log)

- Opening hour: "make it Saturday 6 AM" (Saturday, Nov 28, 6:00 AM Manila = Nov 27 22:00 UTC).
- After the update-loop findings: "A": open Saturday on today's service worker; after it, no prod web update until service worker option A passes its audit and the 48-hour staging soak, unless a fix is urgent and he approves it through the manager; content uploads stay allowed.
- Legal round 6: "ok". Homepage: "okay with your recommendations on Home" plus his refinements; later "just maybe make Everything in Free its own item?". BIR badge: "okay take it off". Performance: "okay with the performance page". Pro wording and green: "pass".

## State now

- **Prod** is unchanged since r8 (web build 1774060561, Worker d2a72e17, BETA_GATE=true). Content: the "kuwento" answer-key fix (q-vocabulary-spelling-rules-0012) is live (05:33 UTC; root `content/cse-key-fixes-r1` 0f5a846a4).
- **Main** 0fbcf844f (CI green, run 45807737680) holds the whole opening build: legal texts dated 2026-11-28 (#110), batched fixes (#147 Study title, report announcement), Pro flicker (#149), Performance (#154), Pro wording and wide green (#157), walk-through renderer (#160, old lessons byte-identical on the prod tree), Quiz tab counts follow local attempt and flag changes (#161, replaces #158's sync-only watch).
- **Staging**: web 1524122686-9787c0b702ce (main 7da707763) and the nine stamp-carrying functions from 7da707763. First proof: 8 of 10 pass, the count defect then fixed in #161.
- **Website**: pantas-web `web/home-opening-r1` 179613d (rechecked: built on the legal pages e625511, 208 of 208 tests, his ten lines, no beta wording, no badge). Not published. Live site version e10acf80 is the rollback.
- **Hold for every lane** until the opening: no deploy from main of createPaymongoCheckout or any guardian function (main carries the Nov 28 Terms date; the live app sends Nov 12, and checkout refuses a mismatch).

## Next, in order

1. **Friday 7:30 PM Manila** (a one-shot reminder is bound to the r9 thread; if you are a fresh session, do it yourself): recheck any newer homepage head from the UX lead (deadline Friday 9 PM); rule 7 count; rebuild the staging web build from origin/main in a fresh worktree (housekeeping removed `cse-candidate` on Nov 26: create it again with `git worktree add --detach`, copy the gitignored `assets/seed` from `/Users/aedwon/.t3/worktrees/Pantas/qa-cse-content-fixes-r1-e2be285e666bb7e9/assets/seed`, run `npm ci` in `functions/` before any functions deploy) through the flutter lock (commands in `tool/deploy/staging_web.sh`, without its deploy line), redeploy the nine functions to staging only if functions changed since 7da707763, deploy web, compare.
2. **Friday 8:00 PM Manila: final staging proof.** One Sonnet worker on `scratchpad/proof-brief.md` (r9 scratchpad; copy it if gone: the ten checks are in the opening plan's change table) plus: an old-format lesson renders as before; a Free quiz finished from a lesson shows the right Quiz tab count without a reload. Report the result and the hour to the manager.
3. **Saturday 6:00 AM Manila: the opening**, exactly as `docs/superpowers/plans/2026-11-26-cse-opening-plan.md` "The opening, step by step": rollback points checked right before; the nine functions (guardian callables and createPaymongoCheckout, switch still false) then the prod web build without BETA_GATE (SELLER_* private, SCREEN_COUNTS=true) at once; website (merge `web/home-opening-r1` into pantas-web main, tests, `npx wrangler deploy`); smoke with no money; `PAYMONGO_CHECKOUT_OPEN=true` and redeploy createPaymongoCheckout last; 30-minute watch; first-hour checks; launch log. Rollback per part is in the plan.
4. **After the opening steps: the stacked-line content fix to prod** (manager ruling, rule 4, Nov 26: "do a mechanical content fix now on the prod content root for the 45 CSE lessons (skip the 6 science lessons): a blank line between stacked lines, or list items where paragraph spacing reads too loose; no wording changes"). Lines ending in two trailing spaces with the next line under them render as one run-on paragraph (both converters join a paragraph's lines with a space). **Done to staging by r9:** `content/cse-key-fixes-r1` 7dcc42ad6 (45 lessons: 40 as bullet items, the confusing-words family of 5 with blank lines; word diff shows only added "-" markers; lesson checks and content gate exit 0); export from main's tools; staging plan 45 updates, 1,436 unchanged, 0 Pro or question changes; uploaded; re-plan 0 differences. **For r10, after the opening steps:** export again from main's tools on 7dcc42ad6 (plus main's three files, already in the worktree uncommitted), prod plan (expect exactly 45 lesson updates), upload with `--project pantas-prod --live`, re-plan 0 differences, rule 7 counted, launch log. Rollback: re-upload the root at 0f5a846a4. The Claude lesson lead adds the check and keeps the fix in its rewrites.
5. After the opening: no prod web update (his "A"); service worker option A (fix list on `fix/sw-build-mix-r1`) is the next build work.

## Lessons from r9

- Prove a content-format change on the tree prod serves (`content/cse-key-fixes-r1`), not main's `content/lessons`.
- A fix that adds a watch on a shared signal: check it emits a first value for every student (Free, signed out), or the screen can hang.
- Golden artifacts: `gh run download <run> -n goldens -D <dir>`; read every changed image before accepting it.
- Rules tightened Nov 26: files only with Edit or Write; Bash only for plain read-only commands and git add, commit, push; no redirection, scripts or shell tricks, even in scratch. Put the same line in every worker brief.
- The update loop on today's worker mixes builds online and can hang the splash on slow links; it is why no web update follows the opening until option A.

## Worktrees (keep until the opening)

Kept: `cse-key-fixes-r1` (prod content root, with main's three files uncommitted), `pantas-web-legal` (website; the homepage branch `web/home-opening-r1` is on origin), `cse-sw` (service worker option A), `cse-r9-docs` (docs to main, recreated), `qa-cse-content-fixes-r1-e2be285e666bb7e9` (build/web holds the current prod build; seed files). Housekeeping removed the merged ones on Nov 26 (cse-candidate, cse-batch-r1, cse-perf-wide, cse-pro-wording, cse-sync-guard, cse-counts-local, cse-renderer, legal-publish-r1); all their work was on origin first.
