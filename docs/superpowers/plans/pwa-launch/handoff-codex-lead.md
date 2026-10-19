# Handoff to the Codex lead: PWA launch changes to the W4 sequence

Paste everything below the line into the Codex lead chat (01a1410a-77a3-7733-bea4-ca54ecc10be1).

---

Aedwon has changed the launch direction. Before your next step, read from GitHub main:
`docs/superpowers/specs/2026-10-19-pwa-launch-design.md`, `docs/superpowers/plans/2026-10-19-pwa-launch.md`
(Part A answers, B0 roles and ownership, Lane A) and
`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` (all entries). They supersede earlier sequencing where they conflict.

What changes for you:

1. Pantas launches first as a web app (PWA) on Firebase Hosting at `pantas.study`, on the finished new
   design. The application-code freeze is lifted for the PWA launch scope.
2. Your October 16 one-branch-at-a-time rule is relaxed: run the remaining W4 families in 2
   parallel lanes, in the `L3-parallel-map.md` order, with one engineering audit per family at
   the end. Aedwon may raise this to 3 later.
3. W4g (Wrapped and sharing) moves after launch.
4. PWA adjustments in Lane A of the plan: no reminders (park W4f Task 1 on its branch, hide the
   Reminders screen and the onboarding reminders step on web); only CSE Professional and
   Subprofessional selectable at launch; the Pro page on web uses the PayMongo plans from Lane C.
5. Pro is enforced on the server (plan C7 to C10): content, mock papers, the mock allowance (Free:
   one per rolling 30 days, account required), the roadmap and Pro insights will come from Cloud
   Functions. Before changing W4b, W4c, W4d or W4e code that assumes all content or the roadmap is
   computed locally, coordinate with the Claude lead, who owns Lanes B, C and L.
6. You remain integration owner of `integration/new-design-r1` and holder of the `STATUS.md` lock.
   When you next hold the lock, add a "PWA launch" section to `STATUS.md` with one row per plan
   task, as plan B0 asks. The Claude lead works on `web/pwa-foundation-r1` and `web/paymongo-r1`
   and hands verified branches to you for integration.
7. Keep the W4c source after `7223e931` local until its family audit, as before.

Reply with your updated next step and the two W4 lanes you will run first, then continue.
