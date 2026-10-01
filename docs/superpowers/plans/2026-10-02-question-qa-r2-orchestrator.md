# Question QA round r2: orchestrator handoff (Codex)

**Date:** 2 October 2026. **For:** a Codex CLI orchestrator (gpt-6.1-sol, high reasoning) run with
`/goal`, taking over from the Claude Code lead.
**Decision log:** `docs/superpowers/decisions/2026-10-01-question-explanations-log.md` (approval,
rules, lead rulings). **Worker brief:** `docs/content/audit/question-qa-r2/worker-brief.md`.
**Rules:** `docs/content/question-style-guide.md`, `docs/content/question-authoring-runbook.md`,
`docs/content/question-blueprints/<subject>.md`, `AGENTS.md` Voice and Maths.

## Goal

Every active question in the UPCAT-family bank (all subjects under `content/questions/`, 158
lessons) is audited and reshaped to the 1 October rules, and every lesson has at least 20 active
questions, on branch `content/question-qa-r2`, pushed. Then the importer enforces a note on every
wrong choice. Aedwon said the lead does not review the workers' content; the orchestrator verifies
only the mechanical gates below and reports.

## Policy

Read `git show origin/main:AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` in full first. Aedwon has
authorized: parallel workers (up to 3 at a time, on disjoint subjects), `--dangerously-bypass-approvals-and-sandbox`,
committing and pushing the `content/question-qa-r2*` branches once their gates pass. Not
authorized: merging into `web/roadmap-engine-r1` or `main`, rebuilding or re-signing
`assets/seed` (needs Aedwon's signing key), deleting branches or worktrees, any app code change
other than Step 3. Commit messages carry no attribution trailer of any kind.

## State at handoff (2 October 2026, about 03:10)

| Group | Subjects | Worktree | Branch | Lessons committed | Note |
|---|---|---|---|---|---|
| math | mathematics | `/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2-math` | `content/question-qa-r2-math` | 10 | 2 uncommitted files: an interrupted lesson |
| science | science | `.../Pantas-wt-content-qa-r2-science` | `content/question-qa-r2-science` | 14 | 2 uncommitted files: an interrupted lesson |
| other | language-proficiency, reasoning, reading-comprehension and general-information | `.../Pantas-wt-content-qa-r2-other` | `content/question-qa-r2-other` | 17 | clean |

All three branch from `content/question-qa-r2` (= `web/roadmap-engine-r1` at 1f79d880; worktree
`.../Pantas-wt-content-qa-r2`). All four are pushed. Each worktree has `.dart_tool/package_config.json`
copied in so `dart run` works without `pub get`. Ledgers are in each worktree under
`docs/content/audit/question-qa-r2/<subject>/<topic>/<lesson>.tsv`; a group is finished when it
has committed `docs/content/audit/question-qa-r2/<group>-summary.md`.

The three CSE vocabulary lessons (placeholder questions) are out of scope.

## Step 1: run the workers to completion

For each unfinished group, render the worker brief and launch a worker with the shell (proven in
this job; prefer it over in-process subagents so each worker has its own process, context and
log, and a usage-limit failure in one does not stop the orchestrator):

```zsh
G=math; S="mathematics"     # or science / "science"; other / "language-proficiency, reasoning, reading-comprehension and general-information"
W=/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2-$G
B=content/question-qa-r2-$G
L=$HOME/.codex/qa2-logs; mkdir -p $L
git show origin/main:docs/content/audit/question-qa-r2/worker-brief.md \
  | sed -e "s#__WT__#$W#g" -e "s#__BR__#$B#g" -e "s#__SUBJECTS__#$S#g" -e "s#__GROUP__#$G#g" > $L/$G.brief.md
n=$(date +%s)
codex exec -m gpt-6.1-sol -c model_reasoning_effort=high --dangerously-bypass-approvals-and-sandbox \
  -C $W -o $L/$G.report.$n.md "$(cat $L/$G.brief.md)" < /dev/null > $L/$G.log.$n 2>&1
```

Run the three in parallel (background each). Loop until each group's summary is committed:

- **Usage limit.** A pass that ends with "You've hit your usage limit ... try again at <time>"
  in its log made no progress. Wait until that time, then relaunch. Read current usage from the
  newest session file under `~/.codex/sessions/` that contains `"primary":{"used_percent"`
  (`primary` is the 5-hour window, `secondary` the week, each with `resets_at` in epoch seconds).
  Never launch while `primary` is at 100 before its reset. Aedwon has banked weekly resets: when
  the weekly (`secondary`) limit is reached, tell him so he can redeem one, then keep retrying
  every 10 minutes.
- **Interrupted lesson.** Relaunching is safe; the brief tells the worker to finish uncommitted
  work first and to skip lessons whose ledger is complete.
- **Worker stops with a question.** Read its report. Decide it yourself when the decision log,
  style guide or blueprint answers it, or when it is a routine content call within the approved
  rules; append the ruling to the worker brief on main (docs commit, `[skip ci]`) and to the
  decision log's "Lead rulings" section, then relaunch. Earlier rulings already in the brief:
  figures (existing renderable `figureSpec` kinds only), General Information has no blueprint,
  `NEEDS AEDWON` questions keep their substance but get the explanation, notes and formatting
  fixes. A product decision (what the app shows, Free and Pro, scope) goes to Aedwon.
- **Runaway.** If a group makes no new lesson commit over 3 consecutive passes that did not end
  on a usage limit, stop relaunching it and report to Aedwon.
- Push each group branch after each pass (`git -C $W push origin $B`).

## Step 2: merge the groups

When all three summaries are committed: in `.../Pantas-wt-content-qa-r2`, on
`content/question-qa-r2`, `git merge --no-ff` each group branch. The groups touch disjoint
paths; any conflict is a stop condition (report, do not resolve by guessing).

Gates on the merged branch (paste output in the report):

1. `dart run tools/import_questions/import_questions.dart --root content/questions > /dev/null` exits 0.
2. A script check over `content/questions/` (excluding CSE): every lesson file has at least 20
   questions the importer emits with `isActive: true`; every wrong choice has a non-empty
   `rationale`; no `\frac` without `d`; no U+2014; no choice text "All of the above", "None of the
   above", or "Both A and B"; ids are unique and no pre-existing id from `1f79d880` was removed or
   renumbered (compare id sets with `git show 1f79d880:<file>`). Lessons that the figure ruling kept
   under 20 are listed, not failed.
3. `dart run tool/check_no_ai_attribution.dart`.

## Step 3: enforce the note in the importer (worker task, test first)

One worker on `content/question-qa-r2`: in `tools/import_questions/converter.dart`, reject a
wrong choice without a non-empty `rationale` with a `FormatException` naming the question id and
choice number, like the existing choice checks. Add a failing test first under
`test/tool/import_questions/` (a question with a wrong choice missing its rationale fails; the
correct choice needs none), then the change. Gates: that test file, the importer run from Step 2,
`flutter analyze --no-pub` (only the accepted `bookmarks_sheet.dart` onReorder info),
`dart format --output=none --set-exit-if-changed` on the changed files, attribution check. The
`test/tool/` tests that spawn `dart run` are flaky under parallel load; run them alone.

## Step 4: finish and report

Push `content/question-qa-r2`; verify the remote SHA equals local. Write a combined summary at
`docs/content/audit/question-qa-r2/summary.md` on the branch (totals, HIGH findings, NEEDS
AEDWON items, lessons under 20 with reasons) and commit it. On main (docs only, `[skip ci]`),
append to the decision log: completion, branch and SHA, totals, and the open items for Aedwon.

Then report to Aedwon in plain language, under 150 words: done, totals, how many answer keys
were wrong and fixed, the NEEDS AEDWON items, lessons under 20, and the next steps that need him:

- Merge `content/question-qa-r2` into `web/roadmap-engine-r1` (his go-ahead).
- Rebuild and re-sign the protected content package with his signing key
  (`tools/build_content_package/`); the E09 package hashes change, and the phone checks after the
  UI connection then run on the new package.
- The app's reveal still shows only the picked choice's note after a miss; the on-request list
  of every note is built with the UI round from his Claude Design screens.
