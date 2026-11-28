# Operations manager handoff (Nov 28, about 2:20 PM Manila)

Outgoing manager thread: `c517ddef-dfdb-4aa6-9f0a-401e7c34873d` ("Operations Manager Handoff"; context nearly full, Aedwon asked for a new session). Retire it after takeover. Follow `docs/workflow/operations-manager.md`, "Taking over as operations manager", steps 0 to 7. Read first, from main: AGENTS.md, WORKFLOW.md, operations-manager.md, process-improvement.md (every Nov 27 and 28 entry), the backlog's "Aedwon's requests" table, and the launch log from Nov 27 on.

## State

- **CSE opened Nov 28, 12:09 AM Manila.** App, homepage (his approved version) and checkout (12:18 AM, live QR Ph) are live. Watch clean. Prod web is FROZEN until the service worker fix passes (his "A", Nov 26); content uploads are allowed.
- **Pace (his words Nov 28, about 4 AM: "obviously i want you to slow down"):** one build lane at a time plus short one-off jobs, 1 Claude worker per lead. At about 2:10 PM he resumed PSHS-NCE ("resume now"), so two lanes run now: the release lead and the generator lead, 1 worker each. Usage words: Nov 27 "i do not want to waste any more usage than necessary".
- **Claude 5-hour limit** ran out once at about 4:20 AM (reset 4:30 AM). Keep lanes few.

## Lanes

| Lane | Thread | State and next |
|---|---|---|
| CSE release lead r11 (integrator) | `mcp:launch:55d23bdfde1cbdbac9638f0f42400f367a941a688ddb9d6bea85cda3646e2cd2` (fresh session r11 from `2026-11-28-cse-release-lead-r10-to-r11.md`) | After 4 PM (database day reset; its wake-up task `scheduled-task:0c3c0e83-...` is bound to its thread): ONE combined content upload of Math 2b, 2c, 2d and the five held 2a lessons, illustration check on staging (light, dark, placement) before prod; then the signed-integer split (`content/cse-math-split-r1` c872e24d9) as its own upload. Then service worker **revision 2 "wait, then sweep"** (his "A", Nov 28 about 2:10 PM): Safari lock check first, then build, one scoped audit, staging and a 48-hour soak. Audits 3 and 4 failed; Fable consult at `~/Documents/Projects/Pantas-private/releases/2026-11-26-sw-option-a/fable-after-audit4.md`. |
| Generator lead (PSHS-NCE path) | `mcp:09b2a2c5-80a9-422e-827e-188156b04c2e` (fresh session sent about 2:15 PM) | His "resume now" for PSHS-NCE. Order: review and test the held-types fix stage on `gen/question-generator-r1` 54bb472ce, Phase 1 ready for the integrator, Phase 2 plan with estimate sent to the manager BEFORE building, and a plain answer on whether Phase 2 can be live by early January (Dec 8 go or no-go; exam Jan 30). Handoff: `docs/superpowers/handoffs/2026-11-27-pshs-nce-resume.md`. Under-13 and PSHS content stay paused until the manager messages them. |
| Security and billing lead | `mcp:launch:e29d46394b524c9bb1b3efca97421eeae55d54872d03697127a873b07e99ebc5` | One-off job sent about 2:20 PM: a sending-only Resend key and exact Gmail "Send mail as" steps (smtp.resend.com) in ONE file under `~/Documents/Projects/Pantas-private/email/`, so his support@ replies align before D16. His words: "yes, is that possible, can I configure that? and can I use the native gmail app logged in with my personal email but I can send through that alias?". Answer him: yes, set once on Gmail web, the phone app then offers the alias in From. D16 (DMARC p=quarantine) moved to Dec 12, reports now also go to Cloudflare DMARC Management. |
| SSOT keeper | `mcp:launch:090551797b35853669c8ebd7de5efe6916d32449b94f9aee953dc8be9dddbe59` | Caught up to Nov 28 4 AM; daily schedule re-enabled. |
| Math lead | `mcp:launch:d0b92d05876bd9854657cafae346820c99095f72f43494be336846fad3ba9c63` | PAUSED. CSE Math batch 2 done (46 lessons, 43 illustrations). Next when he names it: Math for CET and PSHS-NCE (batch 3 plan, not started). |
| UX lead | `mcp:d8548b12-d7ea-4fd6-8dc3-919a8b8c0570` | PAUSED. Staging UI fixes merged to main and on staging (spacing, option A, subsection spacing, sign out to Welcome, "Already have an account? Sign in", Terms skip on returning sign-in). Nested-sets figure fix merged. Held: Lesson Author update (option A, about 7 h, ruled; his "update the lesson author thanks / queue it though"). |

Paused by him: under-13, PSHS content, dots. Closed: General Information Gemini lead and every older lead listed in operations-manager.md.

## Waiting on Aedwon

- **His staging check after 4 PM** of the UI fixes (reminder task `scheduled-task:b69545fb-...` at 4:05 PM posts the steps into the OLD manager thread; rebind it). His word "ok".
- The Gmail alias setup, once the security lead's file is ready (his physical step).
- Which paused lane resumes next (Math batch 3, Lesson Author).

## Decisions today (all in the launch log or to be logged by the leads)

Opening moved to 12:05 AM ("okay, 12:05 AM it is"); creator early access and a year of Pro, no email sent ("dont send"); pilot release order "A"; lessons ship with their illustrations ("okay both...", "okay with cost, better value for users"); card in card option A; returning students re-enter age and exam, Terms skipped ("just let users input age again and select their exam"); UI close-up "lgtm"; Lesson Author queued; SSOT catch-up "A"; slowdown; service worker revision 2 "A"; PSHS-NCE "resume now"; support@ alias "yes". The manager must log the last three in the launch log if the leads have not.

## Schedules bound to the old manager thread (rebind all)

Heartbeat `scheduled-task:4977b14d-8d5e-4065-b7a7-f0dfdbedfb73` (re-enabled; its lane list is stale: update it for two lanes and the generator lead), daily sweep 10 AM `a2e255b3-...`, housekeeping 4 AM `3a5d4170-...`, staging-check reminder 4:05 PM `b69545fb-...`, Dec 1 alarm price check, Dec 5 plan cost check `ec505c07-...`. Keep-awake: `caffeinate` runs to about noon Nov 28 + 10 h from 2:17 AM, so it ends about 12:15 PM; restart it detached if lanes run overnight.

## Process lessons from this session (all in process-improvement.md)

Grammar audit loop; walk-through loop and the two-read cap; clock times versus events (three repeats: name what a wait protects); spacing rhythm check; uploads over the free tier (the tool now refuses); four leads at once.
