# Plan: design system 4.0 in the web app (Nov 8, 2026)

Spec: `docs/superpowers/specs/2026-11-08-design-system-4-in-app-design.md` (approved). Map:
`docs/superpowers/plans/design-system-4/map.md`. Branch `web/design-system-4` (base `web/speed-r1`
b6eb981ba plus 43e2fc48f and 80b66b876), worktree `../Pantas-wt-design-system-4`. Policy: main.

## Execution

- Lead: Opus (this session). Builders: Sonnet subagents, one family at a time on the branch (families
  share theme files). Reviewer: a fresh Sonnet subagent that did not build the family, read-only.
  Codex is low until Nov 11; use it only if a Sonnet family fails twice.
- Every brief: startup (read AGENTS.md, WORKFLOW.md, SUBAGENTS.md from origin/main), worktree path,
  scope, files, hard rules below, verification commands, "stage nothing, the lead commits".
- Lead per family: read the builder and reviewer summaries, `git status`, spot-check hard-rule diffs,
  run focused checks, commit with a why-message (no AI trailer), push (CI runs the full set on
  hosted runners), deploy to staging when the staging site is live, log on main.

## Hard rules (all families)

- Look only changes. Behavior, content, data, Free and Pro rules, routes and analytics stay as they
  are. Phones and wide screens both follow the system.
- Values only from the generated token classes. No new literals; the drift check enforces it.
- Visual source order: design system 4.0 (`design/system/`), then the approved boards where it is
  silent. Do not invent visuals; report gaps to the lead.
- Accessibility: WCAG 2.0 AA contrast, 44pt targets, visible focus, text scale to 2.0 without overflow.
- No app screenshots by agents. Widget tests at 390 and 1440 wide, light and dark, text scale 1.0 and
  2.0, asserting no overflow, for each screen a family touches.
- `flutter analyze` clean, `dart format` clean, layering and attribution checks pass.

## Verification commands

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test tool
dart run tool/check_layering.dart
dart run tool/check_no_ai_attribution.dart
dart run tool/checks/run_checks.dart
flutter test <focused paths>          # full suite runs in CI on push
python3 design/system/tools/build_css.py --check && python3 design/system/tools/validate.py \
  && python3 design/system/tools/contrast.py && python3 design/system/tools/flutter_names.py
dart run tool/design_system/generate_tokens.dart --check
```

## Families (in order)

A. Foundation (L). Vendor the system to `design/system/`. Generator
   `tool/design_system/generate_tokens.dart` reads `design/system/tokens.json` and writes the 12 token
   classes per `design/system/tools/flutter_names.py` into `lib/core/ui/theme/tokens/` (`--check`
   mode for CI). Replace legacy `PantasColors`, `PantasType`, `PantasCurves`, `PantasDurations` with
   the contract; one file `legacy_theme_shim.dart` keeps old names compiling, marked for deletion at
   the end. `WebTokens` forwards to the one palette. Breakpoints per D136. App-root text clamp 2.0
   with the OS scaler captured first (D190 item 11). Fonts: Source Serif 4 (D91); icons: confirm
   Phosphor coverage (D41). Update theme pin tests. CI job for the Python checks and the generator.
B. Shared components (L). Bring `core/ui/components/*` and `core/ui/web/web_components.dart` to the
   system's 65 components (map section 4), create the five missing named widgets.
C. Shell and navigation (L). Sidebar from 1024 (compact to 1439), TabBar below, page headers, beta
   gate and sign-in pages.
D. Home (L). E. Quiz (L). F. Study and reader (L). G. Mock exam (L, includes the D170 phone layout).
H. Settings (M). I. Onboarding, assessment, guardian (M). J. Pro and paywall (S to M).
K. Beta feedback (M). L. Wrapped and misc (S). M. Close-out: delete the legacy shim, drift
   allowlist empty, full check set, final staging deploy.

Drift check (with A, tightened per family): `tool/checks/` check plus failing-sample test that bans
color, font size, spacing, radius and curve literals outside the theme and token files; an allowlist
of not-yet-migrated folders shrinks with each family and is empty after M.

## Staging (parallel to A, lead-owned)

`firebase.staging.json` (hosting target `app` on `pantas-staging-app`, prod headers plus
`X-Robots-Tag: noindex`), deploy rules, indexes and storage; Aedwon runs the secrets script; deploy
functions; upload content; App Check key; Auth domains and OAuth redirect; custom domain via the
Hosting API plus Cloudflare DNS; build with `-t lib/main_staging.dart` and `BETA_GATE=false`.

## Stop conditions

A behavior change would be needed; a value the system and an approved board disagree on with no
system decision; a test that encodes behavior (not a look) fails; two failed builder runs on one
family (the lead takes over).
