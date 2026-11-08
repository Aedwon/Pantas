Startup (required): read the policy from GitHub main without switching branches: `git show origin/main:AGENTS.md`, then `origin/main:WORKFLOW.md`, `origin/main:SUBAGENTS.md`, `origin/main:docs/superpowers/specs/2026-11-08-design-system-4-in-app-design.md`, `origin/main:docs/superpowers/plans/design-system-4/plan.md` and `origin/main:docs/superpowers/plans/design-system-4/map.md` (sections 4 to 6).

Rules for your worktree:
- It is your own copy, on its own local branch, starting at cfe147386.
- Other builders are working in parallel in other copies, on other files. Touch only the files in your scope, plus your scope's lines in `tool/checks/design_token_allowlist.txt`.
- Never switch branches, merge, stash, reset, stage, commit or push. The lead commits and merges.
- No app screenshots, no browser or computer control, no dev servers. Close any process you start before you finish.
- Run `dart` and `flutter` only from your worktree root.

Already done, and yours to use:
- Generated tokens in `lib/core/ui/theme/tokens/`. The drift check is `tool/checks/design_token_literals.dart`, with its allowlist.
- Shared components in `lib/core/ui/components/` and `lib/core/ui/web/`. The test helper is `test/helpers/ds_matrix.dart`.
- Shell and navigation, with the D136 breakpoints in `lib/core/ui/web/web_layout.dart`.
- Home, Quiz, and Study with the reader. Copy their patterns.
Do not restyle shared components or files outside your scope. If one lacks something, report it.

Sources:
- The system is vendored in `design/system/`. Each component has a README at `design/system/components/<name>/README.md`. Decisions D1 to D191 are in `design/system/README.md`. Patterns are in `design/system/patterns/`.
- Visual source order: the system first, then the approved boards where it is silent.
- Do not invent visuals. Report gaps.

Values:
- Use only generated token classes.
- Do not hide new values in arithmetic on tokens, in local named constants, or in helper functions that return numbers. Use an existing token, or the nearest one, and list it.
- The only named-constant exceptions are positions anchored to other layout, and board heights the system does not set. List each one.

Hard rules:
- Look only. Behavior, routes, content, copy, data, analytics, persistence, and Free and Pro rules stay exactly as they are.
- WCAG 2.0 AA contrast, 44pt targets, visible focus, text scale 2.0 without overflow, and correct screen-reader names.
- Decorative eyebrow pill labels are banned. Status tags and pill buttons stay.
- Stop and report if a behavior change would be needed, or if a test that encodes behavior (not a look) fails.

Tests:
- Matrix widget tests for each screen in scope at 390, 1100 and 1440 wide, in light and dark, at text scale 1.0 and 2.0, with no overflow.
- Update tests that pinned old looks. Never weaken behavior assertions.
- Remove your scope's entries from the drift allowlist once they are clean.

Verification (all must pass):
flutter analyze
dart format --output=none --set-exit-if-changed lib test tool
dart run tool/check_layering.dart
dart run tool/check_no_ai_attribution.dart
dart run tool/checks/run_checks.dart
dart run tool/design_system/generate_tokens.dart --check
The focused tests for your scope, then `flutter test test/core test/features test/app` once at the end (run it in the background).

Finish with a report under 250 words:
- What changed and any API changes.
- Test pass and fail counts.
- What is not done.
- Doubts for the lead, listing every snapped value and named constant.
- Files touched.
End with STAGE-DONE.
