Task: plan Task 1.2, "checker". Build exactly what that task lists. Task 1.1 is merged: reuse its model (tool/generator/lib/src/model.dart) and test layout (test/tool/generator/, flutter_test, run with `flutter test test/tool/generator --no-test-assets` because fresh worktrees lack assets/seed/content.db).

Design notes from the lead:
- Independence: everything under tool/generator/lib/src/check/ may import model.dart and nothing under rules/. Add a test that scans the check/ sources and fails on any import of rules/.
- Solvers are keyed by rule name and live in check/solvers/: a math solver evaluates the answer from the variant's slots; a figure solver says whether candidate figure data completes the shown figures under its rule. Mistake solvers are keyed by (rule name, mistake id) and return the value or figure that mistake produces. A type whose rule has no solver fails the check. No real solvers yet: tests use test-only rules and solvers under test/tool/generator/.
- The "library" for check 1 is every registered figure solver whose figure kind matches the type's figure kind.
- Signature canonicalization for figures (check 3) works on figure data, rotating and mirroring the whole question. Write it per figure kind behind one function; implement it for a generic test kind now and leave a clear failure ("no canonicalizer for kind X") for kinds without one, so Task 1.3 adds them.
- Check 6 (merged questions reproduced exactly) compares against the hand-written question YAML; take the question source through a parameter (a map of id to parsed question) so tests can supply fixtures and the CLI can read prod content via `git show`.
- CLI: `dart run tool/generator/bin/check.dart [--types content/types] [--questions-ref origin/content/bite-sized-cse-algebra-r1]`, exit 1 on any failure, one line per failure: `<type id> #<index> <check>: <reason>`.
- Wire into tool/checks/run_checks.dart. With no content/types/ directory it passes with a note.

Lead ruling (Nov 16 23:50 UTC), on the two blockers in FINDINGS.md. Continue from the worktree; do not restart.

1. Range validation is per rule, not a shared schema. Each solver in check/solvers/ also implements `List<String> validateRanges(ProblemType type, Variant variant)`: it reads the type's `params` in the meaning its own rule documents and returns one reason per out-of-range value (empty list = pass). The checker calls it for check 4. A rule documents its params in a doc comment on the rule class, and the solver writer reads that comment, not the rule's code. For the test-only math rule, `params.max` bounds both `slots.a` and `slots.b`. Check 4's generic part stays shared: no `{slot}` left after filling the type's templates with the variant's slots, and the markup check below.
2. Markup: no parser dependency. A small standalone check in check/markup.dart: unescaped `$` delimiters pair up; braces balance inside each math span; a `\frac` at the top level of a math span fails (use `\dfrac`), while `\frac` nested inside another fraction's argument passes. Tests for each.
3. Fresh-worktree prerequisite: run `dart run build_runner build --delete-conflicting-outputs` once before `run_checks.dart`. Its outputs are gitignored, which is allowed; never hand-edit them.
4. Path: check/solvers/ as the brief says; update the plan wording only by reporting it, not editing the plan.
