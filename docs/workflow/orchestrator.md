# Orchestrator playbook

How the lead runs a large build through Codex with little lead (Claude) usage and few interruptions
for Aedwon. Written October 30 from the web layout build, at Aedwon's request ("i like how we're
working rn. can you write an ochestrator.md to preserve whatever we're doing here?"). AGENTS.md,
WORKFLOW.md and SUBAGENTS.md still win where they differ.

## Roles

- **Lead (Claude, main thread):** owns scope, briefs, rulings, review, commits, merges and the
  decision log. Reads summaries, not logs. Never takes app screenshots.
- **Builder:** Codex Sol (`gpt-6.1-sol`, low effort) through `codex-pick`, one family per run.
- **Reviewer and fixer:** two more Sol runs per family (below). They use Codex quota, not Claude.
- **Bulk reading:** a Sonnet or Haiku subagent (board inventories, mapping a design to the code,
  building a preview page). It returns one report file and a one-paragraph summary.
- **Audit:** Codex Astra (`gpt-6-astra`, read-only) for payments, security or answer keys, rarely.
- **Aedwon:** approves specs and visual previews, answers product decisions, does all visual checks.

## Flow for a large build

1. **Map first.** A subagent maps the source (design boards, spec) to the existing code and writes a
   report: every item with a verdict (build, needs a feature, skip with reason, motion), the
   contradictions, and where tokens and components live. The lead reads only the counts and the
   contradictions.
2. **Spec.** The lead writes the spec: a plain-language section for Aedwon (scope, what is skipped,
   numbered decisions waiting for him with the default being followed) and an agent section with
   lead rulings on every contradiction. Commit it to main. If Aedwon is away, work proceeds on the
   stated defaults and the decisions wait for him.
3. **Families.** Split the work into families that share files (foundation first, then one area at
   a time). Families run one after another on one branch when they touch shared files (router,
   shell, theme); independent families may run in parallel worktrees.
4. **Brief per family.** A shared `common.md` (startup rules, worktree, what to read, hard rules,
   verification commands, "stage nothing, the lead commits") plus a short `<name>.brief.md` that
   points to the map and spec rather than restating them.
5. **Pipeline per family:** `run_family.sh <name>` runs build, review and fix as three Sol runs
   (`docs/workflow/orchestrator/run_family.sh`). Each stage ends with `STAGE-DONE`; a rerun skips
   finished stages, so it resumes after a failure.
6. **Lead check per family.** Read the run status and the fix stage's verification lines, and look
   at `git status`. Spot-check one or two diffs only where a hard rule or another platform could
   break (for example "phones unchanged", "Free never sees Pro data", "stored values unchanged").
   Then commit with a why-message, push, and start the next family in the same command.
7. **Finish.** Merge the base branch in, run the full check set once (analyze, format, layering,
   attribution, full test suite, web build, Functions plain and emulator), then merge into the
   integration or staging branch and push. Record results and rulings on main.

## When a family does not finish cleanly

- **Build stage exit 1 (cut off, model at capacity):** commit what passed review and fix, then run a
  second pass whose brief says: list every item of this family, mark what is built, finish the rest.
- **Worker stops on a scope or test conflict:** the lead rules in one paragraph, appends it to the
  brief as "Lead ruling", deletes that stage's output and reruns. Rulings that matter later go into
  the plan's rulings section on main.
- **An item needs data or a feature the app lacks:** do not invent it. Add it to Aedwon's list.
- **Two failures in a row on the same family:** the lead takes it over.

## Codex limits

- Always `codex-pick`, never bare `codex` or `~/.codex`; stdin closed, prompt as an argument.
- `codex-pick --status` shows each account's 5-hour and weekly use without spending quota.
- Exit 75 means all accounts are full: the pipeline writes `CODEX_FULL` with the reset time. The lead
  adds a resume note to the brief (partial work is in the worktree; continue, do not restart) and
  schedules a one-shot resume a few minutes after the reset.
- A ping (`CODEX_HOME=~/.codex-<x> codex exec "Reply ok"`) starts an idle account's 5-hour window; it
  cannot restart a running one.

## Keeping the lead cheap

- A recurring heartbeat at :03 and :58 keeps the session's prompt cache warm (gap under 55 minutes);
  when nothing needs doing it replies "ok" with no tool calls.
- Background every long command; never poll. React to completion notices.
- Check only at family boundaries. Read tails and grep for verification lines, not whole logs.
- Delegate reading of more than a couple of files to a subagent with a one-paragraph return.

## Talking with Aedwon

- Short status lines; numbered decisions with the default and a recommendation.
- Record each answer in the decision log with his exact words before relying on it.
- Visual decisions: a subagent builds a preview page from the real design source and code; serve it
  on localhost through the browser pane (a `.claude/launch.json` entry running a small Node server
  that reads the file) so Aedwon can view it. Approved previews are copied to main as the
  implementation reference.
- Things only he can do (secrets, consoles, mailboxes, publishing copy) are listed, never attempted.
