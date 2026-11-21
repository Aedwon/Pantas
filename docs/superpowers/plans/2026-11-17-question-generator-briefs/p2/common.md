You are a Codex worker on Pantas, question generator Phase 2 (app and server). Startup: read AGENTS.md, WORKFLOW.md and SUBAGENTS.md from origin/main (`git show origin/main:<path>`; policy revision 0172e8dfb or later). Then read, in this worktree (branch gen/question-generator-app-r1, which already contains the Phase 1 branch): the plan docs/superpowers/plans/2026-11-17-question-generator.md (Global constraints, Parts 1 to 3b and Phase 2), the spec docs/superpowers/specs/2026-11-17-question-generator-design.md (Revision 1 at the top of Part A, and Part B), the decision log docs/superpowers/decisions/2026-11-17-question-generator-log.md, and the Phase 2 map docs/superpowers/verification/question-generator/p2-map.md once it exists. Where the map's "Lead rulings" section exists it is binding.

Hard rules:
- Work only in this worktree. Stage nothing and commit nothing; the lead commits. Preserve changes you did not make.
- Tests first: write the failing test, run it, see it fail for the expected reason, then implement.
- No UI or screen change of any kind (no widget, layout, styling or copy change). If one seems needed, stop and say so.
- Never hand-edit generated files (`*.g.dart`, `*.freezed.dart`, `functions/src/generated/pantas_core.js`); regenerate them with their tools. No new dependency.
- Do not edit content/questions/ or content/types/ data. Do not deploy anything, and touch no hosted project (no staging, no prod). Emulators are fine.
- The new field is `variantIndex` everywhere, never "version" (`questionVersion` already means content revision).
- Never print secrets. No em dashes, American spelling in any text you write.
- Append each finding, decision or blocker to FINDINGS-<your family>.md at the worktree root the moment you have it, not at the end, so a usage-limit stop keeps the work.
- If the plan, spec, map and code disagree, or a product decision is needed, write it under "Needs the lead" in your findings file. A blocker on one item never stops the rest; stop the whole task only when the blocker affects all of it.

Verification (run what your task touches, paste the summary lines in your final message):
- flutter test <the test files and folders your task touches>
- flutter analyze
- dart format --output=none --set-exit-if-changed lib test tool
- dart run tool/check_layering.dart
- dart run tool/check_no_ai_attribution.dart
- for functions changes: the functions test commands named in the map (plain and emulator)

Final message: pass/fail per command with summary lines, files touched, anything left undone. Under 300 words.
