# Walk-through Math pilot plan

Date: November 27, 2026, from about 5:10 PM Manila. Lead: walk-through Math pilot lead (E-204).
Policy read: `Aedwon/Pantas` main `890325dee` (velocity row pushed as `14f9af21a`).
Spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` on main, including "Revision, November 27, 2026".
Decisions: launch log entry "Nov 27, about 3:50 to 4:10 PM Manila"; process-improvement entries of Nov 26 and 27.
Aedwon's words for this lane: "i do not want to waste any more usage than necessary"; "okay go ahead with your reco";
"would the 6 am part take a lot of tokens? if not you can proceed with the lessons".

Branches: lessons on `content/lesson-walkthrough-cse-r1` (starts at `ab81cf657`); checks on `tools/walkthrough-checks-r1`
(starts at `3048ee151`, its own worktree). The integrator merges both after the opening. Nothing else in this lane runs:
Grammar, Vocabulary, Language Application, Reading Comprehension and Reasoning stop, and their drafts stay unused.

Hard stop: 3:00 AM Manila Saturday (scheduled task at 2:50 AM). Workers stop, partial work is committed as WIP, one
report goes to the manager, the turn ends.

## The 10 lessons and why

All are CSE Math rewrites already on the branch. None needs a question-file change, so the integrator copies lesson
files and their trap-evidence entries only.

| # | Lesson | Folder | Nov 27 pre-check | Why it is in |
|---|---|---|---|---|
| 1 | age-word-problems | algebra | 2 Majors | word problem; longest algebra lesson, tests the 900 cap |
| 2 | mixture-word-problems | algebra | 1 Blocker (two answers), 1 Major | word problem; the two-answer Blocker class |
| 3 | work-rate-problems | algebra | 2 Majors | word problem; frame-clone class |
| 4 | discounted-prices | arithmetic-number-sense | OK | approved sample; the reference shape |
| 5 | percentage-base-and-fraction-division | arithmetic-number-sense | 2 Majors | percent, core CSE skill; frame-clone class |
| 6 | identities-and-like-terms | arithmetic-number-sense | 1 Blocker (key is a stem number) | the key-in-stem class |
| 7 | decimal-and-percent-conversions | arithmetic-number-sense | 1 Blocker (key printed above) | the printed-answer class |
| 8 | simple-interest | arithmetic-number-sense | OK | clean control |
| 9 | percentage-change | data-interpretation | 1 Blocker (printed conclusion) | printed-conclusion class; data topic |
| 10 | table-values-and-totals | data-interpretation | OK | drawn figures; proves main's export with figures |

Left out on purpose: the split pair `signed-integer-operations` and `substituting-negative-numbers` (they bring a retired
parent, moved questions and new pool-gap questions, which widens the integrator's job), and `chart-scales-and-differences`
(its figure was redrawn by text change only on Nov 27).

The Blockers above were rewritten in `de02e682d` but never re-checked. The pilot treats them as open until the checks and
the pre-check pass.

## Step 2: automatic checks (checks branch, before any lesson edit)

Each check gets a test that fails first on a real bad sample, quoted from git history (`a2b132670`, before the Math fixes)
or from the Codex Grammar round 8 and Language Application round 3 reports.

1. **Giveaway check** (`tool/checks/walkthrough_giveaway_check.dart`, wired into `lesson_checks.dart` and `run_checks.dart`).
   For each `:::check` and `:::try`, the key is the text after "The answer is" in its `:::answer`. "Visible above" means the
   lesson text before the block, with every `:::answer`, `:::why` and comment removed. It fails when:
   - a. the key is a choice and that choice appears word for word in the visible lines above;
   - b. the stem offers choices and only one of them appears in a list printed above (Grammar r8 class);
   - c. the key equals a number printed in the block's own stem;
   - d. a non-trivial key (a fraction, a number of 4 or more characters, or a word answer such as "undefined") appears in a
     visible line above in the same `###` section or in any pair's Right line.
   Bad samples that must fail first: `identities-and-like-terms` Check 1 (key -9 in the stem), `decimal-and-percent-conversions`
   try (7/20 printed above), `digit-sums-and-six` try (choice B printed in the pair), `percentage-change` Check 2
   ("Undefined" in the pair), and the round 8 Blockers in `aspekto-at-paksa-sa-filipino.md` and
   `tinutukoy-at-pagmamay-ari-sa-panghalip.md` (process-improvement entry of Nov 27, fix 3). Tuning: run over the 55 Math
   lessons at `a2b132670`; every hit is either one of the pre-check's printed-answer findings or is reported as a false
   alarm and the rule is narrowed. A rule that cannot be tuned below a handful of false alarms is dropped and the reason is
   written in the check's comment.
2. **Over-broad-rule list** (`tool/content/broad_rule_list.dart --root <dir> [--lesson <path>]...`). Not a pass or fail
   gate: it prints `file:line | sentence` for every teaching line (outside quiz stems and choices) that uses every, always,
   never, only, all, none, no, or a bare "X means Y", for the verifier to judge. Its test fails first by showing it lists
   two real over-broad rules from Codex Language Application round 3 and the round 8 `aspekto-at-paksa-sa-filipino.md:84`
   line.
3. **Slim-format check** (replaces `walkthrough_example_check_line_check.dart`, which required the dropped rule 7 Check
   lines). For an active walk-through lesson: at most one `:::check`; no `**Check:**` line anywhere. Fails first on the
   current `discounted-prices` (5 checks, 2 Check lines).

Verification: `flutter test test/tool/checks/` for the new tests; `dart run tool/content/lesson_checks.dart --root` on a
scratch root holding main's content plus the 10 pilot lessons (see step 5). Other walk-through drafts on the lesson branch
will fail the slim-format check; they are unused and are not exported.

## Step 3: slim the 10 lessons (by pattern, not by row)

One writer worker (Sonnet 5.5), Edit tool only, this worktree. Rules applied to every lesson whole:

- Keep rules 1 to 5 and 8 to 11 of the standard: worked numbers under each rule, one move per line, Why? for extra reasoning,
  2 or 3 pairs at their steps backed by the trap evidence, the checklist, the faded last step as the one `:::try`.
- Drop every `**Check:**` line (examples, check answers, try answers).
- Keep one `:::check` per lesson, after the rule the lesson's quiz tests most. Delete the others. Its stem is a fresh
  instance: same kind of problem as the example with new numbers or a new context is allowed; it must not reuse the
  example's frame word for word, must not print its answer anywhere above, and its key must not be a number in its stem.
- A pair's Right line must not print the answer of a later example, check or try.
- Every worked example opens with one lead-in naming what is found, and every chain ends at its value (Nov 26 rule).
- No new narration. Words before a tap at or under 900; lessons may only shrink, except a rewritten check (up to 20 words).
- Every rule line with every, always, never, only or "X means Y" is scoped to the cases the lesson shows.
- No pair or checklist line changes its quiz citation; `content/walkthrough-trap-evidence.json` stays valid.

The writer runs the giveaway, slim-format and size checks on its own lessons and stops when they pass. The lead reads every
diff.

## Step 4: pre-check, solver, Codex

1. Checks green on the 10 lessons (parser from `ux/walkthrough-renderer-r1`, `lesson_checks.dart`).
2. One blind pre-check (one Sonnet verifier, read-only): every check and try solved with the answer hidden; copyable answers,
   wrong keys, second answers, frame clones, and the over-broad list judged. A separate solver (the second worker slot)
   recomputes every number in the 10 lessons without reading the answers. Gate: 0 Blockers. Majors found here are fixed by
   the lead before Codex.
3. Codex full read 1 through `codex-pick`, one run at a time, brief adapted from `codex-math-r4-full.brief.md` to the slim
   format and the 10 lessons. If Blockers are 0, Majors are fixed once by the lead, checked by the lead, and the pilot
   passes with no further read.
4. If read 1 has Blockers: fix by pattern, rerun checks, Codex read 2 (the last). Blockers 0: fix Majors once, lead check,
   PASS. Any Blocker in read 2: stop, send the manager the findings with options.

## Step 5: hand-off

Scratch worktree of current main plus the checks branch's `tool/checks/` and `tool/content/lesson_checks.dart`, with the 10
lesson files and their trap-evidence entries laid on top. Main's content export
(`tools/build_content_export/build_content_export.dart`) must pass there. The manager gets the exact file paths and the
commits.

## Stop points (report to the manager)

- After this plan (path), before step 2.
- After the pre-check.
- After each Codex read.
- At a second-read Blocker (findings plus options), or at 3:00 AM.

## Manager acceptance and the limit rule (Nov 27, about 5:30 PM Manila)

Manager: "plan accepted, including the slim-format check and leaving out the signed-integer pair. Go with step 2."
Added rule from Aedwon, relayed: "the 6 AM opening must not lose Claude usage to the pilot. If you or a worker hits a Claude
limit at any point before 3 AM, stop for the night at once, commit WIP, tell me in one line, and do not resume until I
message you after the opening."

Manager, later the same evening: the opening moved to 12:05 AM Saturday. The stop task (same id) now fires at 11:40 PM
and is a pause: a Codex read already running may finish, no new Claude work starts after 11:40 PM, and the lane resumes on
the manager's message after the opening (about 1 AM). The 3:00 AM stop no longer applies.

## Caps

At most 2 Claude workers at once; 1 Codex run at a time through `codex-pick`; files changed only with Edit or Write; one
Flutter run at a time through `flutter-locked.sh`, the release lead's builds first.
