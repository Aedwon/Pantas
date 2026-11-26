# CSE opening plan (checklist G3), Nov 26, 2026

Written by the CSE release lead r9 (integrator) for the manager, who confirms it with Aedwon before the
beta gate comes off. Policy main 57e075ef6 and later. Controlling records: the release checklist
(`2026-11-22-cse-public-release-checklist.md`, sections 4 and 7), the launch log entries of Nov 25 ("legal
texts approved; opening 'when ready'", "the gate-off build proven on staging", "legal publish gate H5",
"legal Sol High round 6", "homepage seller line approved") and Nov 26 (live payments, batched update).

## For Aedwon (plain language)

**What changes at the opening.** Anyone can sign up at app.pantas.study (no beta screen). The new Terms,
Privacy Policy and Notice for teens go live in the app and on www.pantas.study, dated the opening day.
The website footer shows the business details he approved. Anyone can buy Pro (QR Ph). Two small fixes
ride along (Study title height, report message read aloud for screen readers), and the Pro "Free" flicker
fix and the past-mistakes fix if they are ready and proven.

**Hour: Saturday, Nov 28, 6:00 AM Manila** (Nov 27 22:00 UTC), his words (Nov 26): "make it Saturday 6 AM". Was proposed: Friday, Nov 27, 6:00 AM. Prod traffic over the last 7 days is
lowest from 5 to 10 AM Manila. Until the new service worker ships, every web update can make a student
who goes offline right after it see the app fail to start; the morning window keeps that to the fewest
people. It also leaves Thursday and Friday for the staging proof.

**What only he gives (3):**
1. The homepage words. www.pantas.study still says "Join the beta" (top bar, phone menu, a lower section)
   and "Beta applications are closed", with no way into the app. Website copy is his: what the button and
   any line should say, and whether the lower beta section goes. We place his words exactly.
2. ~~His check~~ Done ("ok", Nov 26) of the three legal passages changed after his Nov 25 approval (round 6: the trial-code
   deletion schedule, accounts made before publication, trial after deletion), in
   `docs/legal-drafts/2026-11-22-public-launch/change-summary.md`, "Round 6". Skip if already done.
3. ~~Confirm the hour~~ Done: Saturday 6 AM.

**Time:** about 3 h of preparation today; the opening itself about 1 h 30 min including a 30-minute watch.

**If something goes wrong:** each part switches back on its own (table below). The quickest full undo
puts the beta gate back by switching the app to today's version (about a minute).

## Preconditions (all before the opening; the lead stops if any fails)

| # | Precondition | State now |
|---|---|---|
| A | His three inputs above. | Waiting on him. |
| B | Legal PR #110 up to date with main, stray backup file removed, CI green, merged. Go-live stamp set to 2026-11-28 in one commit (done: e5981bd4e): `legalTextsVersion` and `legalTextsPublishedAt` (app) and `LEGAL_TEXTS_VERSION` (functions/src/guardianConsent.ts), plus the website pages' "Version" lines. | **Done.** Merged d6b792d32 (head 04817e487, CI green on run 45755501105). |
| B2 | No deploy from main, before the opening, of the guardian callables or createPaymongoCheckout: main now carries the Nov 28 stamp, and the prod app sends Nov 12, so such a deploy would refuse checkouts and guardian answers. | Told the manager (Nov 26) to hold every lane to this. |
| C | Batched fixes on main: PR #147 (Study title, report announcement). | Merged 4b9d7378b, CI green. |
| D | Security lead's Pro flicker fix (C15): green PR, test fails first, plus an account-switch test (the gateway must not keep the old account's database). | **Done.** PR #149 merged f32d05e46 (18 checks green; the database is never replaced while the app runs). Proven in the staging run G. |
| E | Past-mistakes fix: the 4:10 PM diagnostic run finds the cause. If it is the stale Quiz tab count (cause 1), the fix is built test first and merged. Otherwise it does not ride, and the manager gets the cause and size. | Diagnostic after the 08:00 UTC quota reset. |
| F | P12 remaining: CSE Sub resume and offline loops; update loop (today's staging build to the candidate). | After the reset. |
| G | Staging proof of the exact opening candidate (Thursday evening or Friday) (main after B, D, E), built without BETA_GATE: new visitor to Welcome with no beta screen; 17 blocked, 25 continues; onboarding to CSE Home; Free lesson and quiz; mock setup (anonymous visitor gets the sign-up card); Pro page plans; checkout page opens with the tick, the seller line "Sold by Pantas Online Tutorial Services" and the Terms link (staging test keys, no purchase); in-app Terms, Privacy and Teen notice show the new texts and the opening date; guardian page accepts with matching versions (functions stamp deployed to staging together). Rule 7 counted first. | After E and F, same evening. |
| H | Website: `legal/public-pages-r1` (e625511, dated Nov 28) plus his homepage words, tests green (192 now), merged to pantas-web main. Not deployed until the opening. | **Ready.** UX lead's `web/home-opening-r1` 06dfb0e, built on e625511 to his approved board: approved words, one button on screen at a time, full-width top bar, bottom beta section and beta status call removed. Lead check: 200 of 200 tests, no beta wording on the homepage. If he approves the Free and Pro section before the opening, the UX lead adds it on top and the lead rechecks. Kept on the branch until the opening (manager, Nov 26); merged to pantas-web main at step 4. |
| I | Rule 7 for the whole day: staging about 17,000 reads planned (P12 Sub, Pro diagnostic, update loop, candidate proof) against 40,000; prod opening steps under 200 reads. | Staging 30,168 used before the reset (resets 08:00 UTC). |

## The opening, step by step (Saturday, Nov 28, from 6:00 AM Manila)

1. **Rollback points, checked right before:** app.pantas.study serves Worker d2a72e17 (build 1774060561);
   www.pantas.study serves version e10acf80; guardian functions' current revisions and createPaymongoCheckout
   00024-viz recorded in `Pantas-private/releases/2026-11-28-opening/`. If the app does not serve d2a72e17,
   stop (two-session rule, Nov 25).
2. **Functions, legal stamp:** deploy every function that reads `GUARDIAN_DOCUMENT_VERSIONS` (pinned CLI,
   `--only`, from the origin/main tip): the guardian callables in `guardianConsent.ts` (sendGuardianLink,
   answerGuardianRequest, getGuardianStatus, getGuardianRequest, getGuardianManage, setGuardianSharing,
   withdrawGuardianPermission, markGuardianAdult) **and createPaymongoCheckout**, which refuses a checkout
   whose declaration carries another Terms version (`paymongoCheckout.ts:93`). The checkout switch stays
   false here. The app and functions stamps must match: until step 3 lands, the guardian page asks to
   reload (nobody under 18 can sign up, option C) and admin checkouts from the old app are refused; step 3
   follows at once.
3. **App:** prod build from the same main commit, `lib/main_prod.dart`, no BETA_GATE, SCREEN_COUNTS=true,
   SELLER_* loaded privately (lengths only in the record); deploy the Worker; compare 92 of 92; check
   version.json with a cache-busting query.
4. **Website:** merge `web/home-opening-r1` (06dfb0e, or the UX lead's later head) into pantas-web main, run the tests, then `npx wrangler deploy` from main (legal pages, footer, his homepage words and layout).
5. **Smoke on prod (no money, under 200 reads):** a new visitor reaches Welcome; Terms, Privacy and Teen
   notice in the app and on the website show the opening date; the website button opens the app; a
   throwaway account reaches Home, and its Pro page shows plans with "Payments open soon." (checkout still
   closed). Throwaway account deleted after.
6. **Checkout on for everyone:** `PAYMONGO_CHECKOUT_OPEN=true` in `functions/.env.pantas-prod`, redeploy
   createPaymongoCheckout only. Then the throwaway's checkout page opens a live QR Ph session (not paid,
   left to expire), and is deleted.
7. **30-minute watch:** no ERROR or 5xx on any prod Cloud Run service; payment webhook quiet or 200; 401 rate
   normal; sign-in mail count.
8. **First-hour checks (G6):** sign-ups, onboarding finishes, quiz saves, a mock, alarm emails quiet. His own
   live checkout is optional (he already paid once on the live key).
9. Record everything in the launch log; checklist G1 to G6 updated; manager told in one message.

## Rollback per part

| Part | How to undo | Time | Note |
|---|---|---|---|
| App (gate off, batch, fixes) | `npx -y wrangler@4.162.0 rollback d2a72e17-f423-4042-8d8d-e953a2a992bd -c tool/cloudflare-app/wrangler.prod.jsonc` | about 1 min | Puts the beta gate back. Students who opened the new build keep it until their next safe point. |
| Checkout open | `PAYMONGO_CHECKOUT_OPEN=false` and redeploy createPaymongoCheckout | about 3 min | Security lead: the pre-live revisions no longer work (their secret version is destroyed). |
| Guardian legal stamp and checkout stamp | route traffic back to the recorded guardian revisions; for createPaymongoCheckout, redeploy with the old stamp and the switch false (its pre-live revisions no longer work) | about 5 min | Must move together with the app rollback: old app plus new checkout stamp refuses every checkout. |
| Website | `npx wrangler rollback e10acf80-257a-4c56-a898-c49788117036` in pantas-web | about 1 min | Restores the beta homepage and the Nov 12 legal pages. |
| Content | none changes at the opening | | P10 mock text is already on prod. |

## Every user-visible change and what covers it

| Change | Where | Covered by |
|---|---|---|
| No beta sign-in screen; Welcome and onboarding for everyone | App | His Nov 25 "when ready" (the opening); onboarding boards; E-168 staging proof. |
| Beta-only surfaces gone (G4 rows 1 to 9, 12 to 15); earned-reward rows kept | App | QA ui-2 findings G4 list; E-168 proof; r4 ruling to keep earned rewards. |
| Anonymous visitor on mock setup gets the sign-up card | App | His Nov 5 approval of the mock sign-up card (QA Polish Picks); PR #131. |
| New Terms, Privacy Policy, Notice for teens, dated the opening day | App and website | His legal sign-off Nov 24 and "legal is fully approved" Nov 25; round 6 passages need his check (item 2). |
| Seller line beside Pay: "Sold by Pantas Online Tutorial Services" | App checkout | His Nov 25 words (business name, not the owner); legal round 5. |
| Website footer business line | Website | His "yes on that" (Nov 25, 10:20 PM). |
| Homepage button and line into the app, beta wording removed | Website | His words (item 1). Not built until he gives them. |
| Pro checkout opens for everyone (QR Ph); "Payments open soon." no longer shown | App | Checkout and declaration boards (Guardian Manage and Minor Checkout; D2 tick ruling); #91 wording ruling; his real payment Nov 26. |
| Study title 2 px higher on phone web | App | His Nov 26 staging-pass call ("align them to look equal to Settings"). |
| Report confirmation read aloud by screen readers | App | No visual change; P12 finding. |
| No "Free" flash on Pro during an exam switch | App | No new screen; removes a defect (C15). Rides only if D holds. |
| Past mistakes count right on a second device | App | No new screen; restores the built behavior. Rides only if E holds. |
| Link-preview image without the beta mark | App metadata | Already on prod since Nov 26 (#134, approved board). |

## Not part of the opening (recorded so nobody widens scope)

- Service worker option A (after the opening, 48-hour staging soak, clean audit).
- The BIR seal badge on the website (L10): **dropped** (his words, Nov 26: "okay take it off"). Display is
  voluntary under RMC 113-2026, and scanning it shows his name and TIN digits. Revisit only if BIR makes
  display mandatory again. The UX lead removes it from the homepage branch; the lead rechecks the new head.
- One-time in-app notice of the new Terms for accounts made before publication (round 6 follow-up).
- Under-18 sign-up stays closed (option C); other exams stay "Coming soon".
