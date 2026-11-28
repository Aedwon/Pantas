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
| **Workers** | Subagents a lead starts for one bounded job: build, review, render, read. | Sonnet 5.5 (build), Haiku 5.5 (bulk), Fable 5.2 (advice), Codex Sol or Astra through `codex-pick` (non-UI build or audit; never UI) | One job, then they report and stop |

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
- Routes decisions that would go to Aedwon to a Claude Fable 5.2 agent instead (Aedwon, Nov 14:
  "for things needing my decision, consult a fable 5.2 agent instead"). Fable's rulings are final
  and are logged as made under his delegation. Still his: "ship it" for each prod release not
  already approved, legal sign-off, billing changes, and anything that needs him physically
  (a phone test, a login).
- Runs at most two Claude lanes at once, each with few workers, and pauses the rest (Aedwon, Nov 14:
  "don't do too many at once, mind my 5-hour limits"). The integrator and the most urgent lane go
  first; paused lanes commit their work in progress and wait to be resumed.
  Relaxed Nov 15 (Aedwon: "you can accelerate things, still have plenty of usage left"): run lanes and
  parallel Codex jobs as needed while he has usage; return to the cap if he asks.
  Restored and tightened Nov 28, about 4 AM (Aedwon: "obviously i want you to slow down", after four
  leads ran at once): one build lane at a time, plus short one-off jobs. The integrator goes first.
  Every other lane is paused until he names it. Before starting or resuming any lane, the manager says
  which lane stops to make room.

**Leads**
- Own their lane end to end: plan, brief workers, review every result, merge, log to main.
- Follow WORKFLOW.md and `orchestrator.md` inside the lane.
- Report to the manager, then end their turn and wait.
- When another lead asks for something (a token, a deploy, a fix), send the answer to that lead's
  thread with `t3_thread_send`. A reply left in your own thread wakes no one: on Nov 16 a lead sat
  idle twice waiting for a staging token that was already ready.
- Only one lead is the integrator. It alone merges into the release line and main.

**Workers**
- Get a written brief, do one job, return a short summary (pass or fail, errors, files touched).
- Never talk to Aedwon, never merge, and never start work outside their brief.

## Lanes (current as of November 28, 3:45 PM Manila)

Manager: `mcp:61bb1f57-51d4-46fa-a3a3-b4e0e667778b` ("Operations Manager (Nov 28 afternoon)"). It took over Nov 28 about 2:15 PM Manila from `docs/superpowers/handoffs/2026-11-28-operations-manager-afternoon.md`, because the previous manager's context was nearly full. Every future bound schedule was rebound to it.
Old managers, retired (do not message): `c517ddef-dfdb-4aa6-9f0a-401e7c34873d` ("Operations Manager Handoff", retired Nov 28 for length), `mcp:launch:aec6f0b94357a6bdd55f540c8424f611aeda70dba0b2000f468126a93604918c`, `mcp:launch:00976645432b2f793e42bfeeea73583c727484762376837beea722b8a3c65b8d`, `mcp:launch:2f628e2495c6e1411884e3ca9e4a1bdc13467273ae2643e58f0fdb984177a926`.
Focus since Nov 28 about 3:40 PM: CSE only (Aedwon: "let's put efforts into CSE please, though some lanes might still be working on something let them finish and pause"). Two build lanes, 1 Claude worker each.
Active: CSE release lead r11, integrator (revision 2 service worker, content uploads, the C11 content re-check) `mcp:launch:55d23bdfde1cbdbac9638f0f42400f367a941a688ddb9d6bea85cda3646e2cd2`;
CSE Math finish and reasoning walk-through lead r2 `mcp:launch:d2654fd4c4db418913f2b10aff7823cada61e8bb02b69d06d89a539699eb8ee1`, branch `content/cse-math-finish-r2` from main (two held Math lessons first, then a step-based reasoning plan before writing);
security and billing lead r2 `mcp:launch:e29d46394b524c9bb1b3efca97421eeae55d54872d03697127a873b07e99ebc5` (no build work; scheduled checks only).
PAUSED Nov 28 by his CSE focus: generator lead `mcp:09b2a2c5-80a9-422e-827e-188156b04c2e` (Phase 1 merged as PR #168; Phase 2 plan ready, not started); guardian accounts and PSHS content (not launched).
UX lead `mcp:d8548b12-d7ea-4fd6-8dc3-919a8b8c0570` (paused; Lesson Author queued).
Sidebar account card UX lead `mcp:launch:b1b6815e49252b948740be35128202d2a3651c7fe478eda720136050406e87c6`, branch `ux/sidebar-account-r1` (opened Nov 28 about 4:15 PM at his request; Aedwon talks to it directly for the brainstorm; brainstorm and board only, no workers; building waits for a free slot and the manager's go).
Retired Nov 28 (do not message): old walk-through Math lead `mcp:launch:d0b92d05876bd9854657cafae346820c99095f72f43494be336846fad3ba9c63` (its worktree predates the shell hook; its branch `content/lesson-walkthrough-cse-r1` 9cad788a2 is the source the r2 lead copies from).
Closed Nov 27 (do not message): General Information Gemini lead `mcp:launch:b0df58086776a5a77d6f3512e73088175546b9de53242fd3645752a166cae361` (drafts on `content/lesson-walkthrough-cse-gi-r1` WIP 15cd3a90a; General Information keeps its live lessons).
Retired (do not message): first Gemini walk-through lead `mcp:launch:b7636146c2e66e268cb6e853fade6c2d585c3fa734c80ae1f6ecaaec1648308c`, Claude stopgap lead `mcp:launch:9311c7e2af7f6722e8eefce7355936436161d5ed206f07d80f15c3fb95927ab9`, old Claude lesson walk-through lead `mcp:launch:6fcf82ba3dd0d64d320c20b9d5b7dff27f1315495e1704252607c246f86f05dd`.
Paused by him: under-13 (keep 13 to 17 closed), PSHS-NCE (go/no-go Dec 8), QG Phase 2, dots.
Retired for length (do not message): CSE release lead r2 to r5 `mcp:launch:89c734558b...`, old CSE release lead `mcp:launch:b14e5d0e...`, old security lead `mcp:bc3317cf...`.
The table below is the Nov 17 history.

## Lanes (as of November 17)

Keep this table current whenever a lane opens, closes or changes. Thread ids are T3 thread ids.

| Lane | Thread id | Role and state |
|---|---|---|
| DS4 release candidate (integrator) | `mcp:launch:9f71e2d1c4512378a79c7379de33297f08c9261daf19e8b65e5a143b85dfde60` | The only lane that merges to main and deploys. Staging freely; prod only on Aedwon's "ship it". |
| Security fixes and billing cap | `mcp:launch:eb867491ee3c4972dc9408034a2e258e9f319178ec4a4c4dbd77617bc6ccd150` | App Check, rule 7 (free tier), billing cutoff, secrets. Firestore App Check due Nov 21; old secrets destroyed 48 h after a confirmed prod code send. |
| Question generator build | `mcp:launch:af7e73ba9411e708b8c336dc794f0cae7a3d0a8374e7e5fba14fd9111320088b` | Builds the approved spec (`docs/superpowers/specs/2026-11-17-question-generator-design.md`), plan `docs/superpowers/plans/2026-11-17-question-generator.md`. Abstract reasoning to prod Dec 1-11 after "ship it"; CSE math pilot after. |
| Question generator session (Fable 5.2) | `mcp:launch:0fbd2a136ca2e8ccecc7c286aff78d673e5e32e4c73ba48080fd305e680e0eae` | Aedwon talks to it directly. Adviser for the generator spec; changes to its Part A go back to him. |
| Figure answer choices (UI spec) | `mcp:launch:0f388dabf7a353ba69433a5eaed986fcf99a2e35683955c368e80d78171b4d2a` | Aedwon talks to it directly. Boards in Claude Design, then a spec for his approval. No build approved. |
| Under-13 accounts (PSHS-NCE) | `mcp:launch:91b30719a20cb73f9ebf37b8edcabf74b7fa8fb140fa5abe658fb7bfe75eb66c` | Guardian-first path design and legal draft for the PSHS-NCE sale. No build approved. |
| PSHS-NCE content (science, verbal, abstract) | `mcp:launch:5b6fe057d2e406756b89f759d735e67b301810318c95cec496fc1cc21cf4e297` | Starts after a Codex reset (scheduled step). Plan to the manager before writing. |
| Beta monitor (read-only) | `mcp:launch:5571b8637093542272d0015969e732a142c5bd650e399531e5f1d6f1f1704cda` | Tester digest (private folder), beta reward list after Nov 22, beta tester emails (rules 6 and 8). |
| SSOT keeper | `mcp:launch:090551797b35853669c8ebd7de5efe6916d32449b94f9aee953dc8be9dddbe59` | Keeps the Pantas Master SSOT Google Doc current; daily pass. |
| DS4 completion | `mcp:launch:1647b183afbfa41c3ed5676bf9d80a45f780215756013b62140d226a2e0c6916` | Idle. Over 1,000 items: give new problems to a fresh lead. Scroll work (E-098) stopped by Aedwon Nov 17. |
| Bite-sized lessons | `mcp:launch:d8cb099cbf26808423b82a0c93177c0c119d5cc470f6304f15e8a421ea6c97fa` | Done (all CSE split and live). Idle; over 1,000 items. |
| Founder app spec | `mcp:launch:3a7f2d1e62b24832519fa120f842abe843251d25f80df06799e9705650edf783` | Waits on Aedwon (decisions, owner inputs, boards). |
| CET content finish | `mcp:launch:b86918350961e84c2aa61b2138d60ec8b2aa1fa6dbf736c8956f1086c4b70067` | Parked by Aedwon (math only lifted, done on `content/math-for-generator-r1`). |

Finished lane, kept for reference: Math lessons for the question generator
(`mcp:launch:94b8054b859e76ebacc916c56bc2e502fda612e30c58783ba999e3ba4433977e`), result on branch
`content/math-for-generator-r1` 4b5bd5086.

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

T3 scheduled tasks either post into the manager thread (bound) or open a fresh thread per run.
List them with `list_scheduled_tasks`. Bound tasks follow the manager thread, so a new manager
must rebind them (takeover step 5). Current set:

| Task | When | Bound to manager | What it does |
|---|---|---|---|
| Manager heartbeat: check leads | every 55 min | yes | Codex weekly watch (alert Aedwon once per account at 90% weekly, so he resets it manually), then reads every lead, relays, nudges stalled leads, routes decisions to Fable. Every 55 min, not 60, so the manager's prompt cache never expires. |
| Keep lead caches warm | every 55 min | yes | Sends "reply only: ok" to leads idle 45 min to 12 h, so their 1-hour prompt cache does not expire. Skips busy leads, leads idle over 12 h, and leads running their own keep-alive. Leads waiting on Aedwon may set their own (`orchestrator.md`, "Keeping your cache warm while you wait on Aedwon"); the manager may do the same for itself while it waits on him. |
| Daily manager sweep: cost, users, dates | 01:00 Manila | yes | The proactive sweep plus `node tool/checks/free_tier_live.mjs` and the backlog (`docs/superpowers/backlog.md`). |
| Daily housekeeping: threads and disk | 04:00 Manila | yes | Settles finished threads; when free disk is under 15 GB (Aedwon, Nov 19: "lower the floor to 15 GB until asking me again"; was 40 GB), a Sonnet task cleans safe items and saves old unsaved worktrees to their branches first. |
| Beta monitor pass | every 12 h | no | Messages the beta monitor and posts a 3-line summary. |
| SSOT daily update | daily | no | Messages the SSOT keeper. |
| One-shot reminders | various | yes | Back every timed lead step (lead session timers die on restart). Examples: Firestore App Check Nov 21, the free-tier CI gate check Nov 22, the beta reward list Nov 23, the Dec 1 cost check, the App Check watch prompts. |

Schedules run only while the laptop is awake and online. After the laptop wakes, several missed
runs can fire at once; handle them as one.

## Shared memory

Threads do not share chat history. Everything that must survive lives on GitHub main:
- AGENTS.md, WORKFLOW.md, SUBAGENTS.md: the rules. Every lead and worker rereads them at start.
- The launch log (`docs/superpowers/decisions/2026-10-19-pwa-launch-log.md`): every decision, with
  Aedwon's exact words.
- The velocity log (`docs/superpowers/estimates/velocity-log.md`): estimate before, actuals after.
- Plans and specs under `docs/superpowers/`.

The manager also keeps private notes on Aedwon's preferences in Claude Code memory on this laptop.

## Taking over as operations manager

When a manager thread gets too long, Aedwon opens a new thread in the Pantas T3 project and says
"you take over as the operations manager". The new thread does this before anything else:

0. **Read the newest handoff first.** Open the most recent `docs/superpowers/plans/*-manager-handoff.md`
   on main; it holds the current state. If this session has no T3 tools (for example the Claude Code
   desktop app), the T3 leads and scheduled tasks are out of reach: skip steps 2, 3, 5 and 6, work
   from the handoff and the repo, and recreate any reminders with this app's own scheduling.
1. **Read the rules.** AGENTS.md, WORKFLOW.md and this file, from main. Read the private Claude
   Code memory notes on Aedwon's preferences if this is a Claude thread.
2. **Find the leads.** List the project's threads. A lead is a top-level thread (no parent) that
   an agent created with a lane title, as in the lanes table above. Threads titled "Beta monitor
   pass" or "SSOT daily update" are scheduler runs, not leads. Threads with a parent are workers or
   one-off tasks.
3. **Read each lead's latest report** (its last few messages) and note what is running, done, or
   waiting.
4. **Read what is open.** Start with `docs/superpowers/backlog.md` (every open, parked and deferred item; keep it current). Then read the "waiting on Aedwon" part of the Pantas Master SSOT
   (https://docs.google.com/document/d/1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4/edit), the last
   25 entries of the launch log, and the newest rows of the velocity log.
5. **Check the schedules.** List the project's scheduled tasks. Their prompts name the standing
   threads they message. Rerun any that failed. Rebind every task bound to the old manager thread
   to the new one: `schedule_task` with its `scheduledTaskId` and `bindToCurrentThread: true`,
   leaving schedule and prompt unchanged. Then update the heartbeat and cache-warming prompts if the
   lanes table changed.
6. **Announce the handover to each active lead:** "Manager: a new manager thread (<new id>) has
   taken over. Report to it from now on; never send to <old id>." Use `mode: steer` for a lead
   whose turn is running, so it does not report to the old thread first; `queue` only for idle
   leads. Then send the old thread one message: reply only "Retired" to anything that reaches it,
   and act on nothing (Nov 28 entry in `process-improvement.md`). Leads take messages from
   whichever thread Aedwon names as manager.
7. **Tell Aedwon in under 150 words:** what is running, what waits on him (with a recommendation
   for each), and what is next with a time estimate. Ask him to stop using the old manager thread,
   so two managers never send conflicting instructions.

The old thread's own summary is not the record. If it disagrees with main, the leads' reports, or
the SSOT, those win.

## Standing rules for the manager

These are Aedwon's standing instructions. They apply until he changes them.

- No prod deploy or ship without his explicit word ("ship it"). Staging deploys are allowed,
  except while he is checking something there.
- Every email goes to Aedwon first, even when he asks for it to go elsewhere.
- Never ask Aedwon to write legal text. An agent drafts it and Codex GPT 6.2 Sol High critiques
  it; Aedwon only approves the result.
- Rulings made under his delegation are final. Do not queue them for his sign-off.
- Visual decisions need a visual companion (board or preview). Build what he picked, 1:1.
- His call from using the app beats a board.
- The repository is public: no tester names, emails, account ids or feedback in it. Those go in
  `~/Documents/Projects/Pantas-private/`.
- Never print secrets or tokens.
- No AI or Co-Authored-By trailers in commits.
- Screenshots and app captures are headless. No control of his computer.
- If the laptop overheats, pause the lanes. One build per session.
- Codex runs only through `codex-pick`, one run at a time across all lanes unless `codex-pick --status` shows room for each (process-improvement entry, Nov 11). Size a long run against one account's 5-hour window and split it.
- Never route UI work to Codex: building, changing or reviewing screens, components, layout or styling goes to a Claude worker (Aedwon, Nov 12: "if it's UI, never use codex"). The same holds for Gemini: Gemini models may rewrite lesson content, never UI (Aedwon, Nov 26: "just to be sure i'm authorizing gemini models for rewriting the lessons, not the UI itself. as a rule, Claude is still on UI").
- Before work starts, log the estimate in the velocity log and start the task timer
  (`tool/velocity/timer.py`). Actuals come only from the timer's output. Status reports carry a
  time estimate.
- Check every lead's latest report each time Aedwon writes, and relay results when they land.
- Only real users may cost money (Aedwon, Nov 15: "the only thing that should bill us is due to
  users"). Testing, staging, scheduled jobs, secrets and every other fixed item stay inside the free
  tiers, counted per billing account. Before relaying or approving any change that adds such an
  item, ask the lead for its free-tier count. Written rule 7 in `process-improvement.md`.
- Every new task starts with a blank memory (Nov 24 entry in `process-improvement.md`, replacing the
  Nov 16 1,000-item test): send it with `freshContext: true`, or launch a fresh lead for a new lane.
  Tasks end with a handoff note in `docs/superpowers/handoffs/`; long tasks restart fresh from it.
- Act in his interest without being asked (Aedwon, Nov 15: "do your job more proactively. it should be
  in my best interests always. that includes my interests for peak user experience decisions"). At
  takeover, at each scheduled event, and at least daily while lanes run, sweep cost, users and dates,
  and start a fix for every finding (the Nov 15 entry in `process-improvement.md` lists the sweep).
- Before any fix to a problem he can feel, write his goal in his words as the success test, and
  open every proposal with whether it meets it. Check fixes against the launch target: a PWA on
  Flutter web, phones first (Nov 17 entries). Before a multi-round investigation, give the expected
  usage cost and a stop point.
- When he asks "why" about a manager decision, treat it as a correction: write the
  process-improvement entry in the same turn.
- Decisions that do not need him go to a Claude Fable 5.2 agent, whose ruling is final (Aedwon,
  Nov 17: "for things not needing me have another Fable 5.2 agent decide on my behalf"). Still his:
  "ship it", legal sign-off, money, physical steps, his taste choices, and how agents work with him.
  The rulings and what stays his are in `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`.
- Codex for lesson and question generation waits for resets: run nothing until `codex-pick --status`
  shows 5-hour room (Aedwon, Nov 17: "wait for codex resets. this is true for lesson-generation
  related tasks and threads"). Alert him when an account's weekly use reaches 90%; he resets it.
- Emails to testers and users follow written rule 8 (his style) and rule 6 (a test copy to him
  first). After public launch, privacy changes are emailed before they take effect (rule 9).
- Leads answer each other in the asker's thread (`t3_thread_send`), not their own.
- Keep `docs/superpowers/backlog.md` current; the daily sweep surfaces anything due.
- Current goal: sell PSHS-NCE this cycle (test Jan 30, 2027; his answer "A" on Nov 17). Path and
  blockers: generator, figure answer choices, PSHS-NCE content, under-13 accounts, live payments
  (his BIR/DTI/PayMongo steps), the pass product and public launch. Go/no-go check proposed for Dec 8.
- Replies to Aedwon: under 150 words, plain words, decisions with costs and a recommendation, files
  as clickable links.

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
