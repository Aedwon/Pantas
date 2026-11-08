# Handover: design system 4.0 guardrails and open items (Nov 9, 2026)

This handover is for the T3 Code session Aedwon starts. The Claude Code lead session wrote it.
Read `AGENTS.md`, `WORKFLOW.md` and `SUBAGENTS.md` from `origin/main` first, as policy requires.
Then read `guardrails.md` in this folder. It is the plan Aedwon is implementing.

## Where things stand

- **Branch `web/design-system-4`.** Every screen is on design system 4.0. Families A to M are merged,
  and the close-out commit is f49b99300. The full suite (`test/core`, `test/features`, `test/app`)
  shows 9986 passing. CI run 42503472179 passed, except `osv` (see below).
- **Staging.** https://staging.pantas.study serves f49b99300 (Firebase project `pantas-staging`, site
  `pantas-staging-app`, `X-Robots-Tag: noindex`). Deploy it from a checkout that is detached at the
  branch head. Check the SHA before building:
  `git checkout --detach origin/web/design-system-4 && test "$(git rev-parse HEAD)" = <sha> && flutter pub get && bash tool/deploy/staging_web.sh`.
  Untracked files in the deploy checkout once made `git checkout` abort silently, so a stale build
  was read as success. Keep the SHA check.
- **Prod.** https://app.pantas.study still runs `web/speed-r1`, and the beta testers are untouched.
  Nothing ships to prod without Aedwon's go. Main is under the app-code freeze. Log entries go to
  `docs/superpowers/decisions/2026-10-19-pwa-launch-log.md` on main with `[skip ci]`.
- **Never add AI or Co-Authored-By trailers.** CI scans history and blocks them.

## Work in flight when this was written (the "fix this" sweep, layer 0 of the plan)

Four Sonnet builders were running in local worktrees, none committed yet:

| Worktree | Branch | Scope |
|---|---|---|
| `../Pantas-wt-ds4-sweep-a` | `ds4/sweep-a` | Replace raw Material controls in `lib/features/home`, `lib/features/quiz` |
| `../Pantas-wt-ds4-sweep-b` | `ds4/sweep-b` | The same in `lib/features/mock_exam`, `lib/features/lesson`, plus the reader top bar back (chevron IconButton named "Back to Study", per the ReaderTopBar README) |
| `../Pantas-wt-ds4-sweep-c` | `ds4/sweep-c` | The same in settings, onboarding, assessment, guardian, beta_feedback, wrapped, shell, legal, `lib/app` |
| `../Pantas-wt-design-system-4` | `web/design-system-4` | Material component theme fallbacks in `app_theme.dart`, plus an audit of `lib/core/ui` (the text-search raw-control check was dropped) |

- Their brief is `sweep-brief.md` in this folder, copied from the lead's scratchpad.
- Unavoidable raw controls carry `// ds-raw: <reason>`.
- The lead session reviews each, commits it to its branch, pushes the branch, and adds a line below.
- Only if the lead session can't, T3 takes over:
  1. Check each worktree's `git status`.
  2. Run an independent review.
  3. Commit and merge into `web/design-system-4`, resolving `tool/checks/design_token_allowlist.txt`
     conflicts (it should stay empty).
  4. Run the full checks, then deploy to staging.

Sweep status: (the lead session appends here)

## Open items for Aedwon

- His visual pass on staging.
- The Keyboard Shortcuts switch, which the system specifies (WCAG 2.1.4). It would be a new setting,
  so it is not built.
- Shipping the redesign to prod.
- Merging `deps/functions-osv-fixes` (c0f3766), which clears the 31 `osv` advisories in
  `functions/package-lock.json`. All 849 functions tests pass, and prod's branch has the same
  advisories.
- The staging OAuth console step, needed only if staging's authDomain moves to staging.pantas.study.

## Not built (also listed per family in the launch log)

- **Keyboard and components:** WeekStrip and segment arrow keys; Select search and loading rows;
  DatePicker grids and typed field; the Sheet landscape rule; Popover typeahead; reduced-motion fade
  for Drawer and Dialog; Tooltip hover-onto.
- **Quiz:** the explanation drawer below 1134; the 6-column question list.
- **Reader:** note and trap icons; the inset solution panel; the figure zoom badge; search overlay type
  groups; Source Serif 4 for math (test it with the math engine first, D91).
- **Not rebuilt on shared components:** Mock exam cells (DataTable, Chart, Navigator) and Home
  Performance rows (DataTable, StatRow).

## Useful facts

- The design system is vendored in `design/system/`. It has 65 component READMEs with previews,
  `tokens.json`, decisions D1 to D191, and four Python checks in `design/system/tools/`.
- Tokens are generated into `lib/core/ui/theme/tokens/` by `tool/design_system/generate_tokens.dart`.
  Run it with `--check` in CI.
- Screen-facing theme names live in `lib/core/ui/theme/theme_names.dart`. The legacy shim is deleted.
- The current text-search value check is `tool/checks/design_token_literals.dart`. The allowlist must
  stay empty. The `// ds-geometry: <reason>` marker exempts only drawing geometry. Layer 2 of the plan
  replaces this check with a real lint.
- Lead rulings kept on purpose:
  - quiz gauge timings 400, 1600 and 1500 ms;
  - Plan past-day popover at 128 and 150;
  - passage pane height 560;
  - exam date-mode width 424;
  - reader rhythm per the ReaderLayout README;
  - sidebar measured width of 220 to 244.
- Worktrees need the gitignored `assets/seed/*` copied in, and `build_runner`, before tests run.
  Run `dart` and `flutter` only from a worktree root, because running them inside `lib/` subfolders
  leaves stray `.dart_tool` folders that break `test/tool/firebase_indexes_layout_test`.
