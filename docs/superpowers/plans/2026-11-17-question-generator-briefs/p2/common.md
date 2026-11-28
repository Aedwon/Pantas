You are a worker on Pantas, question generator Phase 2 (app and server). Startup: read AGENTS.md, WORKFLOW.md and SUBAGENTS.md from origin/main (`git show origin/main:<path>`; policy revision 3ce9b32ca or later). Then read, in this worktree (cut from gen/question-generator-app-r1, which contains Phase 1 and today's main): the Phase 2 plan docs/superpowers/plans/2026-11-28-question-generator-phase2.md (all of it; it is the controlling plan and replaces the older plan's Phase 2 where they differ), the Phase 2 map docs/superpowers/verification/question-generator/p2-map.md (its "Lead rulings" L1 to L10 are binding; its line numbers are from Nov 21 and stale, so re-read the files), the older plan docs/superpowers/plans/2026-11-17-question-generator.md Part 3 (formats), and the spec docs/superpowers/specs/2026-11-17-question-generator-design.md Part B.

Hard rules:
- Work only in this worktree. Stage nothing and commit nothing; the lead commits. Preserve changes you did not make.
- Tests first: write the failing test, run it, see it fail for the expected reason, then implement.
- No UI or screen change of any kind (no widget, layout, styling or copy change). If one seems needed, stop and say so.
- Never hand-edit generated files (`*.g.dart`, `*.freezed.dart`, `functions/src/generated/pantas_core.js`); regenerate them with their tools. No new dependency.
- Do not edit content/questions/ or content/types/ data. Do not deploy anything, and touch no hosted project (no staging, no prod, no Firestore outside the emulator). Emulators are fine.
- The new field is `variantIndex` everywhere, never "version" (`questionVersion` already means content revision).
- Change files only by editing them directly (your patch or edit tool). Shell commands are for reading, running tests and existing tools with plain arguments, and nothing else: no heredocs, no `>` or `>>` into files, no `sed -i`, no python, perl or node one-off scripts.
- Never print secrets. No em dashes, American spelling in any text you write.
- The app is live to the public since Nov 28. Old installed clients exist. Anything a current-main client would read must keep working (L7).
- Append each finding, decision or blocker to FINDINGS-<your family>.md at the worktree root the moment you have it, not at the end, so a usage-limit stop keeps the work.
- If the plan, spec, map and code disagree, or a product decision is needed, write it under "Needs the lead" in your findings file. A blocker on one item never stops the rest; stop the whole task only when the blocker affects all of it.

Verification (run what your task touches, paste the summary lines in your final message):
- flutter test <the test files and folders your task touches> (one flutter command at a time)
- flutter analyze <the paths you touched>
- dart format --output=none --set-exit-if-changed <the Dart paths you touched>
- dart run tool/check_layering.dart
- dart run tool/check_no_ai_attribution.dart
- for functions or upload changes, from functions/: `npm run build && node --test test/*.test.mjs`, `node --test ../tools/upload_content/*.test.mjs`, and the emulator suite named in the map if you touched rules or emulator paths

Final message: pass/fail per command with summary lines, files touched, anything left undone. Under 300 words. End with a line STAGE-DONE.
