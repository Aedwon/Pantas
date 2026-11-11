# How Aedwon works with the operations manager

Written November 11, 2026, at Aedwon's request: "are you able to document how we work together
rn? you as my sort of Operations Manager, managing orchestrators." It describes the arrangement in
use since November 9. AGENTS.md, WORKFLOW.md and SUBAGENTS.md still win where they differ.
`orchestrator.md` describes how one lead runs a build; this file describes the layer above it.

## The four layers

| Layer | What it is | Runs on | Lives for |
|---|---|---|---|
| **Aedwon** | Owner. Decides product, design, money, legal sign-off, and every prod ship. | | |
| **Operations manager** | One T3 Code thread, "Operations Manager". The only thread Aedwon talks to day to day. | Claude Opus 5.5 | The whole project; its memory is compacted into a summary when it gets long |
| **Leads** (Aedwon calls them orchestrators) | Separate top-level T3 threads, one per lane of work. Each has its own branch, worktree and full working memory. | Claude Opus 5.5 | Until the lane is finished; they stay open between tasks |
| **Workers** | Subagents a lead starts for one bounded job: build, review, render, read. | Sonnet 5.5 (build), Haiku 5.5 (bulk), Fable 5.2 (advice), Codex Sol or Astra through `codex-pick` (build or audit) | One job, then they report and stop |

So the leads handle the other threads, and the leads spawn the workers. The workers are the
subagents. In the T3 sidebar, a worker shows as a child of its lead.

## What each layer does

**Operations manager**
- Launches a lead for each lane, with a brief: role, branch, what to read, rules, stop points.
- Relays Aedwon's decisions to the right lead in his exact words. Messages from it start "Manager:".
- Reads each lead's report and passes Aedwon only the outcome, his decisions, and time estimates.
- Runs the schedules, pauses and resumes the lanes, and routes alerts (for example, a beta monitor
  error goes to the lead who owns that code).
- Does no build work itself. Small one-off jobs (consult Fable, log an approval, write a brief) go
  to a short delegated task, which also shows as its child in the sidebar.
- Never ships to prod, sends an email, or changes billing without Aedwon's explicit word.

**Leads**
- Own their lane end to end: plan, brief workers, review every result, merge, log to main.
- Follow WORKFLOW.md and `orchestrator.md` inside the lane.
- Report to the manager, then end their turn and wait.
- Only one lead is the integrator. It alone merges into the release line and main.

**Workers**
- Get a written brief, do one job, return a short summary (pass or fail, errors, files touched).
- Never talk to Aedwon, never merge, and never start work outside their brief.

## Lanes as of November 11

| Lane | Role |
|---|---|
| DS4 release candidate | The integrator. Release line, main, staging and prod deploys after "ship it". |
| DS4 completion | Built the unbuilt components, the exam date picker and the age step. Idle. |
| Founder app spec | The founder app. Aedwon talks to it directly. |
| Beta monitor | Read-only. Reads tester feedback and app health, writes a digest. |
| SSOT keeper | Keeps the Pantas Master SSOT Google Doc current. |

## How a request travels

1. Aedwon tells the manager what he wants.
2. The manager sends it to the lead that owns it, or launches a new lead for a new lane.
3. The lead logs an estimate, starts workers, reviews their work, merges, and logs actuals.
4. The lead reports to the manager and ends its turn.
5. The manager reads the report and tells Aedwon the outcome and anything he must decide.
6. Aedwon's answer goes back down the same way.

The manager is not notified automatically when a lead finishes. It finds out by waiting on that
lead or by reading its thread. That is why some reports reached Aedwon late. The manager now
checks every lead's latest report each time Aedwon writes, and waits on a lead whose result he is
expecting.

## Scheduled work

The T3 scheduler opens a fresh thread on a timer. That thread messages a standing lead, waits for
its answer, and posts a short summary.

- Beta monitor pass: every 6 hours.
- SSOT update: daily.
- Security and cost-abuse audit: once, Saturday November 14, 2:00 PM Manila.

Schedules run only while the laptop is awake and online. On November 11 both failed while Aedwon
was out with the laptop, because they could not reach GitHub; the manager reran them on his return.

## Shared memory

Threads do not share chat history. Everything that must survive lives on GitHub main:
- AGENTS.md, WORKFLOW.md, SUBAGENTS.md: the rules. Every lead and worker rereads them at start.
- The launch log (`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`): every decision, with
  Aedwon's exact words.
- The velocity log (`docs/superpowers/estimates/velocity-log.md`): estimate before, actuals after.
- Plans and specs under `docs/superpowers/`.

The manager also keeps private notes on Aedwon's preferences in Claude Code memory on this laptop.

## Pausing

When Aedwon says pause, the manager tells every running lead to stop its workers, commit partial
work on its own branch with nothing merged, start nothing new, and end its turn. Leads resume only
when the manager says so.

## Known weak spots

- **Late relays.** See "How a request travels"; the manager checks leads on every message.
- **Laptop offline.** Schedules and leads stop with it.
- **Manager memory.** The manager's long conversation is compacted into a summary, so details can
  drop. The logs on main are the record, not the manager's memory.
- **Cost.** Every lead and the manager run on Opus. Idle leads cost nothing, but a busy lane with
  many workers uses quota quickly.
