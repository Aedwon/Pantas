# Design system 4.0 in the web app, on staging (Nov 8, 2026)

Status: waiting for Aedwon's approval of Part 1. Workstream: new branch `web/design-system-4` from
`web/speed-r1` at b6eb981ba (the build live at https://app.pantas.study). Policy: main at 88c48a821.

Sources: design system 4.0.0 (https://claude.ai/artifact/N4y4tGXPS2mecemzAMd5dJ, version 12, durable copy
in the lead's side-session notes `design-system-4.0.0/`), the review canvas
(https://claude.ai/artifact/MEvzCRie6ks5N57ZbR7zrJ), the approved Pantas Web boards where the system is
silent, and the code map `docs/superpowers/plans/design-system-4/map.md`.

---

## Part 1: For approval (plain language)

### What Aedwon asked for

- "can you do it for me here hehe", then "go balanced. i'll give you all the permissions that you need
  so that next time you can do it without me".
- On staging: "i want this implemented in another subdomain maybe staging.pantas.study? wdyt".
- Design decisions are delegated: "decide for me based on the design system and whichever is the best
  for UX", with WCAG 2.0 AA and Apple HIG as the bar.

### The real size

The map found more than the first estimate assumed. The app has about 45,000 lines of screen code in
12 groups, two separate color palettes, and about 660 hand-typed spacings, 216 corner sizes and 100
colors outside any shared value. Balanced as chosen now looks like **8 to 10 working days**, not 3 to 4.
Most of the cost is the screen migration, not the setup.

### What changes

1. **Staging site.** staging.pantas.study runs the redesigned app on the separate staging project, with
   its own sign-in and data, hidden from search engines. Payments stay in test mode. Prod and the beta
   testers are untouched.
2. **One set of design values in the app.** Colors, type, spacing, corners, shadows, sizes and motion
   come from the system's values. The two palettes become one.
3. **Checks that stop drift.** A check in CI fails when new code types its own color, size, spacing or
   font instead of a system value.
4. **Every screen moves onto the system**, in this order, each batch deployed to staging for you to look
   at: shared parts and the app frame (sidebar, tab bar, headers), Home, Quiz, Study and the reader,
   Mock exam, Settings, Onboarding and the first assessment, Pro and paywall, beta feedback, and the
   rest.
5. **The three open items** land on the way: icon files, the serif font for math, and the phone layout
   of the Mock exam.

### What does not change

What screens do, their content, their data, and Free and Pro rules. Only how they look and move.

### What I need from you (once)

1. The Cloudflare DNS token, saved as agreed.
2. For the staging backend, about 10 minutes: one script I give you sets the staging secrets (it makes
   random keys for you; you paste only the PayMongo test keys), then three console steps with exact
   values: a reCAPTCHA key, the sign-in domains, and the Google sign-in address.

### How completion is judged

- Every screen uses system values only; the drift check passes with no exceptions left.
- All existing tests and checks pass; tests that pinned old colors are updated to the system values.
- Each screen keeps working at phone and desktop widths, light and dark, normal and 200% text (automated
  tests at those sizes; no layout overflow).
- You look at each batch on staging. Your call from using it overrides a board.

### Your choices (defaults followed unless you say otherwise)

1. Keep balanced at the new size (default), or stop after Home and Quiz and decide then.
2. The beta testers stay on the current look until you decide to ship the redesign (default).

---

## Part 2: Agent section

- Base: `web/speed-r1` b6eb981ba. Cherry-pick 50619b39a and 783d9d572 (apply cleanly). Never merge main;
  read policy with `git show origin/main:<path>`.
- Class-name clash (lead ruling): the system's Flutter contract (`tools/flutter_names.py`) is the API.
  Replace `PantasColors`, `PantasType`, `PantasCurves`, `PantasDurations` in place with the contract's
  fields; migrate callers family by family through a temporary legacy-name shim kept in one file and
  deleted at the end. `WebTokens` charcoal overrides fold into the one dark palette (D50, D51, D112,
  D123, D124). Missing widgets the system's Flutter sections name (`BackChevron`, `PageScaffold`,
  `TabHeader`, `InkTableRow`, `PantasTextLink`) are created where a family needs them.
- Breakpoints follow D136 (sidebar from 1024, compact to 1439, full from 1440).
- Text scaling: app-root clamp to 2.0 with the OS scaler captured first for the reader (D190 item 11);
  tab labels cap at 12 (D181).
- Drift check: a new `tool/checks/` check (existing pattern, with a failing-sample test) that bans
  `Color(0x`, `Colors.<hue>`, numeric `fontSize:`, numeric `EdgeInsets`/`SizedBox`/`BorderRadius`
  literals and `Cubic(` outside `lib/core/ui/theme/` and the generated token files, with an allowlist
  that shrinks to zero by the last family. The system's four Python checks run in CI on the vendored
  system copy.
- Families: A foundation, B shared components, C shell and nav, D Home, F Quiz, E Study and reader,
  G Mock exam, H Settings, J Onboarding/assessment/guardian, K Pro and paywall, I beta feedback, L
  wrapped and misc. Builders: Sonnet subagents (Codex accounts are low until Nov 11); a different
  model reviews each family; the lead commits.
- Staging: `firebase.staging.json` (hosting target `app` on `pantas-staging-app` plus
  `X-Robots-Tag: noindex`), rules, indexes, storage, functions with staging secrets, content upload,
  App Check key passed at build, `BETA_GATE=false`, custom domain via Firebase Hosting API and
  Cloudflare DNS.
- Tests: update theme and color pin tests to the system values; add per-family widget tests at 390 and
  1440 wide, light and dark, text scale 1.0 and 2.0, asserting no overflow. No screenshot capture by
  agents (WORKFLOW visual checking).
- Contradictions resolved by the system's decisions; where the system is silent, the approved boards;
  Aedwon's lived use overrides both.
