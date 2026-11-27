# Brief: Math pilot checks (E-204, step 2)

Lead: walk-through Math pilot lead. Plan: `docs/superpowers/plans/2026-11-27-walkthrough-math-pilot.md` on
`content/lesson-walkthrough-cse-r1` (read "Step 2" in full). Spec: `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`, Part A "Revision, November 27, 2026" and Part B "Markup".

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from current GitHub main (`git fetch origin -q; git show origin/main:<path>`) and follow them. Also read `git show origin/main:docs/workflow/process-improvement.md`, section "Choosing the fix" and the entry "Grammar walk-through lessons fail every Codex audit round (Nov 27)". Lead's policy commit: `890325dee`. Record yours.

## Where you work

Worktree `/Users/aedwon/.t3/worktrees/Pantas/walkthrough-checks-r1`, branch `tools/walkthrough-checks-r1` (head `3048ee151`). Only you write there. Read the existing checks first: `tool/checks/walkthrough_fresh_instance_check.dart` (closest relative: it parses `:::check` / `:::try` stems), `tool/checks/walkthrough_example_check_line_check.dart`, `tool/checks/lesson_size_check.dart` (`readCheckLessons`, the pre-tap word count), `tool/checks/check.dart`, `tool/content/lesson_checks.dart`, `tool/checks/run_checks.dart`, and their tests in `test/tool/checks/`. Reuse their parsing helpers and style.

## Hard limits

- Do not start subagents.
- Change files only with the Edit or Write tool. Bash only for plain read-only commands (grep, ls, cat, git show, git diff, git status, git log, date), git add and git commit on this branch, and the test commands below. No `>` or `>>`, no heredocs, no sh, python, perl, awk or sed scripts, no `-c` shells. Do not push; the lead pushes.
- Every Flutter or Dart run goes through the machine lock, one at a time: `/Users/aedwon/.t3/worktrees/Pantas/qa-cse-release-r1-485b9ecb7345be22/build/audit/flutter-locked.sh <command>`. Run only focused tests (`flutter test test/tool/checks/<file>`) and the lesson check commands below. No full suite.
- No vendor or AI names in `tool/` or `test/` (attribution check). No AI trailers in commit messages.
- If you hit a Claude usage limit, stop at once and report what is committed.

## Tasks, in order, each test first and shown failing (SUBAGENTS Part 3)

### 1. Slim-format check: `tool/checks/walkthrough_slim_format_check.dart`

Replaces `walkthrough_example_check_line_check.dart` (it requires the per-example `**Check:**` line that the Nov 27 revision dropped). Delete that check and its test, and swap it out of `lesson_checks.dart` and `run_checks.dart`.

For an active lesson that has any `:::` walk-through block: fail when the lesson has more than one `:::check` block, and fail on every `**Check:**` line anywhere in the body (examples, `:::answer` bodies, anywhere). One violation per problem, with `id:line`. Origin text: the Nov 27 spec revision (rule 6 becomes one Quick Check per lesson; rule 7 dropped).

Failing sample: the current `content/lessons/mathematics/arithmetic-number-sense/discounted-prices.md` on `content/lesson-walkthrough-cse-r1` (5 checks, 2 Check lines; `git show content/lesson-walkthrough-cse-r1:<path>`). Put a trimmed copy in the test. A passing sample: the same with one check and no Check lines.

### 2. Giveaway check: `tool/checks/walkthrough_giveaway_check.dart`

For each `:::check` and `:::try`: the stem is the text before its `:::answer`; the key is the text after "The answer is" up to the first sentence end (strip `$`, `*`, trailing period; normalize math the way the fresh-instance check does; numbers compare by value, so `7,200` equals `7200`, `0.40` equals `0.4`, `\dfrac{7}{20}` equals `\frac{7}{20}`). Some answers give a choice letter ("The answer is (B)", "The answer is B, 24,534"): then the key is that choice's text from the stem. If a key cannot be read, skip the block (do not guess).

"Visible above" = lesson body text before the block, with HTML comments and every `:::answer` body and `:::why` body removed (hidden until a tap). Pair lines are visible (pairs are always open).

Rules (one violation each, `id:line`, naming the rule and the matched text):
- a. Choice copy: the stem offers choices (lines `(A) ...`, `A) ...`, or an inline `(x / y / z)` group) and the correct choice's full text appears word for word in the visible text above.
- b. Only listed choice: the stem offers choices and exactly one of them appears word for word in a list or series printed above (a bullet list, a `Right:` line, or a stem/lead-in that prints the forms), while the others do not.
- c. Key in its own stem: the numeric key equals a number printed in the block's own stem.
- d. Printed key: the key is non-trivial (a fraction, a number with 4 or more characters, a decimal, a percent, or a word answer such as "undefined" or "no real number") and appears in the visible text above, either in the same `###` section or in any `Right:` pair line in the lesson.

Bad samples that must each fail, taken from git history (copy the needed lines into the test as trimmed fixtures, keeping the real text):
- `git show a2b132670:content/lessons/mathematics/arithmetic-number-sense/identities-and-like-terms.md`, Check 1 at line 46 (key $-9$ is in the stem: rule c).
- `git show a2b132670:content/lessons/mathematics/arithmetic-number-sense/decimal-and-percent-conversions.md`, the Example 2 try at line 131 (7/20 printed in Core Concept: rule d).
- `git show a2b132670:content/lessons/mathematics/arithmetic-number-sense/digit-sums-and-six.md`, the Example 2 try at line 135 (choice B 24,534 printed in a Right line: rule a or d).
- `git show a2b132670:content/lessons/mathematics/data-interpretation/percentage-change.md`, Check 2 at line 100 ("Undefined" in the pair's Right line: rule d).
- `git show ecc329dd1:content/lessons/<path>/aspekto-at-paksa-sa-filipino.md` lines 62 to 68 (only choice A keeps the verb printed in the sentence: rule a or b) and `.../tinutukoy-at-pagmamay-ari-sa-panghalip.md` lines 42 and 111 to 113 (the prompt prints the three forms: rule b). Find the paths with `git show ecc329dd1 --stat` or `git ls-tree -r --name-only ecc329dd1 | grep <name>`. Codex's reasons are in `docs/content/verification/walkthrough-work/codex-grammar-r8-full.md` (lines 24 and 51 on the lesson branch).

If a rule cannot catch its sample without false alarms, say so in the report; do not bend the rule to one sample.

Tuning (required, report the numbers): run the check over two roots and list every hit.
- Root A: `/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/a0b12a19-1dc0-47c5-b136-c30710a95094/scratchpad/wt-a2b/content` (lesson branch at `a2b132670`, before the Math fixes). The Nov 27 Math pre-check (`docs/content/verification/walkthrough-work/math-precheck-findings.md` on the lesson branch) names the real printed-answer Blockers there. Every Math hit must be one of those or a real giveaway you can explain; anything else is a false alarm.
- Root B: `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1/content` (lesson branch now).
To run one check over a root, add a `main` like `lesson_checks.dart` has (`dart run tool/checks/walkthrough_giveaway_check.dart --root <dir>`), through the lock. Target: no more than 3 false alarms across all Math lessons at root A. Narrow a rule that alarms more (for example limit rule d to the same `###` section, or raise the length floor) and say what you narrowed. A rule that cannot get there is dropped, with the reason in a code comment.

Wire it into `lesson_checks.dart` and `run_checks.dart` with an origin line naming the Nov 27 process entry.

### 3. Over-broad-rule list: `tool/content/broad_rule_list.dart`

Not a gate (exit 0 unless the arguments are wrong). Usage: `dart run tool/content/broad_rule_list.dart --root <content dir> [--lesson <relative path>]...`. With `--lesson`, only those lessons; without, every active walk-through lesson. Prints one line per hit: `<lesson path>:<line> | <word> | <sentence>`.

A hit is a teaching sentence (Core Concept prose, `:::why`, pair notes, checklist lines, Speed Tricks, `:::answer` explanations; not quiz stems, not choice lines, not `Right:` / `Wrong:` lines, not display math, not headings, not front matter) that contains, as a whole word, any of: every, always, never, only, all, any, none, whenever, no (as a determiner before a noun is fine to over-include), or a bare "X means Y" sentence. Filipino equivalents too: lahat, palagi, laging, kailanman, tanging, lamang (as "only"), wala, hindi kailanman. Over-include rather than miss; the verifier judges.

Test, failing first: it must list these real over-broad rules (fixtures copied from history):
- `git show 033329008:<path>/clause-punctuation-checks.md` line 66 area (Codex LA round 3 Blocker: the comma rule stated for all opening dependent clauses).
- `git show 033329008:<path>/past-time-checks.md` line 20 (the passive rule "whenever the subject receives the action").
- `git show ecc329dd1:<path>/aspekto-at-paksa-sa-filipino.md` line 84 if its wording carries a listed word; if it does not, say so and use another real line from `codex-grammar-r8-full.md` that Codex flagged as too broad.
Plus a negative fixture: a quiz stem or a `Right:` line with "only" is not listed.

## Verification before you report

- `flutter-locked.sh flutter test test/tool/checks/walkthrough_slim_format_check_test.dart test/tool/checks/walkthrough_giveaway_check_test.dart test/tool/content/broad_rule_list_test.dart` (or wherever you put the test): paste the summary line.
- Show each new test failing before its code existed (paste the failure line).
- `flutter-locked.sh dart run tool/content/lesson_checks.dart --root <root A>` and `--root <root B>`: paste the counts per check name (not the full list) and the full giveaway hits.
- `flutter-locked.sh flutter analyze tool/checks tool/content test/tool`: paste the tail.
- `flutter-locked.sh dart format --output=none --set-exit-if-changed tool test/tool`.
- Commit on `tools/walkthrough-checks-r1`, one commit per task, messages that say why.

## Report (short, under 400 words)

Pass or fail per task; the pasted lines above; the giveaway tuning table (rule, hits at root A, real, false alarm); what you narrowed or dropped; commits; files touched; anything unresolved.
