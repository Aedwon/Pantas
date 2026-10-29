# Web layout from the design handoff

Status: written by the Claude lead on October 30 at Aedwon's request ("i also added a web view design
in design/ for you to implement. there will be some screens not applicable so skip them."). Aedwon
was asleep; the lead chose balanced complexity. Section 1 is for his review in the morning.

## 1. Plain-language summary (for Aedwon)

What gets built: the web app at desktop widths looks like the handoff boards
(`web-design/pantas-handoff/`, 305 boards). Phones and the narrow web view keep today's layout.

- Scope: 273 boards are built. 18 are skipped: Wrapped (deferred), the parked install screen, older
  variants of newer boards, and note boards. 7 boards need features the app does not have on web
  (reminders, pending GCash payment) and wait for you. The 7 motion boards are built last.
- Where it applies: the web build at 1024 px wide and above. Below that, and on Android and iOS,
  nothing changes.
- Colors: the web build uses the handoff tokens, including the charcoal dark mode. The phone apps
  keep their current black dark mode until you decide otherwise.
- The handoff's hard rules are followed as written (natural-width buttons, text-link secondary
  navigation, results layout, fine print under its button, red only for destructive or wrong, reader
  top bar, mock list toggle and flag, no pre-mock Start screen, proctor warning on the clock, UPCAT
  scoring).
- Where a board and an approved app decision disagree, the approved decision stays and the item is
  listed below. Where boards disagree with each other, the newest board and the handoff win.
- You do the visual check. The lead does not take screenshots.

Decisions waiting for you (work proceeds without them):
1. Should the phone apps also move to the charcoal dark mode?
2. HM_Trial says "You'll be charged ₱99"; the approved web copy says "You won't be charged" (the web
   trial is prepaid). The approved copy stays.
3. Boards show UPCAT, LET, NCE and PMA; web sells CSE only. Web keeps CSE only; the other exam
   boards and the UPCAT mock finale are built only when web adds those exams.
4. Reminders on web (6 boards) and the pending GCash state (ST_ProPending): not built.
5. ST_Pro shows Manage Subscription; web has no store page to open. Hidden on web.
6. Mistake reasons: boards say "I forgot"; the app says "I knew it, I just slipped". App wording stays.
7. Math font: the handoff names Source Serif 4; the app and the lesson figures use KaTeX fonts.
   KaTeX stays.

How completion is judged: each area matches its boards (copy, layout, spacing, colors, states,
light and dark) in Aedwon's visual check; all tests, analysis and builds pass; no hard rule is
broken.

## 2. Agent section

- Branch `web/web-layout-r1` from `web/staging-candidate-r1` b9e29947. Board map with every board's
  verdict: `docs/superpowers/plans/pwa-launch/web-layout-board-map.md`.
- Layout switch: one helper decides web wide layout (`kIsWeb && width >= 1024`). Screens keep their
  providers and logic; only the presentation forks. No new routes except where a board is a page
  the app lacks (PL_History).
- Tokens: a web token set (light, dark) from HANDOFF.md, including the dark red overrides. Base
  components from `web/shared/pantas.css` (.btn .btn2 .btn3 .btnw .card .row .fbar .kc .seg .opt
  .sub .sm .eb .h1 and type scale). Buttons natural width, 44 and 50 px.
- Shell: X_Side sidebar, top bars, .fbar bottom action bar.
- Order: tokens and components, shell, then Home, Study and Reader, Quiz and answers, Mock, Results,
  Performance and Record, Settings and Paywall, Onboarding, Plan, More, then motion.
- Keyboard: build the shortcuts the boards show (.kc hints).
- Lead rulings on contradictions (board map section 3): handoff wins over board notes (2, 3, 10, 13);
  newest real-data boards win (17); PL_History becomes a page (18); proctor warning on the clock (9);
  no pre-mock Start screen on web, loading uses the L_ state (11); SY_Update reloads (15); SD_Error
  and SD_NoExam belong to Study (21).
- Review: per area, a Codex review compares the code with the boards and the hard rules; the lead
  reads its summary. Aedwon checks visually.
