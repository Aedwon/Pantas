PASS for main's staging export and offline upload checks.
Main tools and policy fd6789a45. Content base 13bd2a316. No stage, commit, push, or upload.
- Gap tags. Fixed 56 failures. Retargeted 39 tags, with 1 updated choice reference. Removed 17 stale or in-lesson tags. Added 28 helpful links.
- PSHS-NCE grid pool. Added figure-free question q-geometry-practical-measurement-0021. Pool 2, quiz size 2. The existing lesson marker has an SVG. Lesson SVGs do not fill question figure slots.
- Figure checks. Added 4 copied PNG credits and updated 2 legacy checksums. Removed 11 surplus figure files per the integrator and 146 stale markers from 57 retired lessons.
- Custom exam tiers. Restored 2 main catalog files required by the functions build. Regenerated the tier table for the current exam tags. One topic changed to Civil Service.
- Bold-stem check. Named the target word in 5 passage questions. Re-ran approval after an independent solve matched all five keys.
- Independent grid solve. The reviewer found 112 square centimeters from (35 - 3 - 4) × 4 and confirmed the stem works without a figure.
- Legacy illustration audit exit 1. Log went from 751 lines to 607. Its inventory still expects the pre-split layout and flags a removed marker on a retired lesson.
- Flutter SVG rendering and placeholder tests could not start. The sandbox denied the loopback socket. SVG preflight passed.
- Copied credit sources. https://commons.wikimedia.org/wiki/File:Simple_distillation_apparatus.svg and https://commons.wikimedia.org/wiki/File:Alfa_beta_gamma_radiation_penetration.svg
- Copied credit sources. https://commons.wikimedia.org/wiki/File:Earth_cutaway_schematic-en.svg and https://commons.wikimedia.org/wiki/File:Earth_internal_structure.svg

CHANGED-QUESTIONS
q-comprehension-skills-context-clues-in-passages-0021
q-comprehension-skills-context-clues-in-passages-0022
q-comprehension-skills-context-clues-in-passages-0023
q-comprehension-skills-context-clues-in-passages-0024
q-comprehension-skills-context-clues-in-passages-0025
Independent passage solve in ID order. Unable to settle the question, unreadable, label again, maingat at maayos, and hinanap nang mabuti. All five match the existing keys.
Check commands below omit log redirections. W is this worktree, X is ../cet-exp, F is ../cet-finish-443d02, S is /private/tmp/cet-fix-check/main, and E is /private/tmp/claude-501/exp/out.json. Used a temporary Dart launcher for X/F scripts because the shared hook cache was read-only.
- `/private/tmp/claude-501/-Users-aedwon-Documents-Projects-Pantas--claude-worktrees-cet-finish-443d02/11ada5c4-d082-4678-82e2-530f5bce567e/scratchpad/ef/export_check.sh "$W"` → `1117 links and 204 tags`, `export exit 0`.
- In F, `dart run tool/content/lesson_checks.dart --root "$W/content"` → `lesson checks exit 0`.
- `dart run "$X/tool/content/content_gate.dart" --root "$W/content"` → `content gate exit 0`.
- `dart run "$X/tools/import_questions/import_questions.dart" --root "$W/content/questions"` → `question validator exit 0`.
- In S, `dart run tools/custom_tiers/build_custom_tiers.dart` → `custom tiers exit 0`. `dart run tool/checks/run_checks.dart` → `OK    legal-text-drafting`, `run checks exit 0`.
- In S, `npm --prefix functions run build` → `functions build exit 0`. `node --test tools/upload_content/*.test.mjs` → 33 pass, 0 fail.
- In S, `node tools/upload_content/upload_content.mjs --root "$W/content" --export "$E" --dry-run` → `dry run: no database was read or written`, `dry run exit 0`.
- In S, `node tools/upload_content/upload_content.mjs --root "$W/content" --export "$E" --out-dir /private/tmp/cet-fix-check/upload-docs` → `out dir exit 0`.
- In S, `dart run tools/build_content_export/build_content_export.dart build/export.json --assets-out assets/seed` → `1117 links and 204 tags`, `asset export exit 0`. The export matched E byte for byte.
- In S, `dart run tools/build_content_seed/seed_writer.dart build/export.json assets/seed/content.db` → `seed exit 0`.
- In S, `dart run tools/build_content_package/build_content_package.dart build/export.json ../package-final ../package-final/seed_version.dart 1` → `package build exit 0` (local check sequence).
- In S, `dart run tools/verify_content_package/verify_content_package.dart ../package-final/content.db ../package-final/content.manifest.json ../package-final/content.manifest.sig` → `content package verified: 8313b78e598c8d49 a23098bb478f82b64ec7500e3aaacbde9fba2f1e1860429adaa9a0d35190e082`, `package verify exit 0`.
- `python3 "$X/tools/check_lesson_svgs.py" "$W/content/illustrations" --validate-only` → `SVG preflight: 427 files, 0 failures`. In S, `python3 tools/check_lesson_svgs_test.py` → 7 tests, `OK`. `python3 tools/check_lesson_svgs.py tools/svg_fixtures/fail --validate-only` → 29 expected failures.
- In S, with B9_SVG_ROOT set to the candidate illustrations or tools/svg_fixtures/pass, `flutter test --no-pub tools/check_lesson_svgs_render_test.dart --reporter expanded` → exit 1. `flutter test --no-pub test/core/ui/placeholders_test.dart --reporter expanded` → exit 1. Both report `Failed to create server socket`.
- In S and the starting-content comparison, `PYTHONDONTWRITEBYTECODE=1 python3 tools/audit/run_all.py` → exit 1. Raw logs are in /private/tmp/cet-fix-check/audit.log and audit-baseline.log.
- `dart run "$X/tool/content/approve.dart" --root "$W/content" --ids <ID file> --evidence "$W/docs/content/bite-sized/cet/export-fix-summary.md"` → all 6 IDs approved in two runs.
- `git diff --check` → clean. Per-file `grep -c` → 67 current files and 11 removed files checked, zero em dash lines.

STAGE-DONE
