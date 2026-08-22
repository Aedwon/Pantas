# Web orchestrator model routing

Date: 2026-08-23
Status: Approved

## Context

Pantas can be coordinated from a ChatGPT web session while implementation and local
verification still need repository and terminal access. Codex usage is limited and
should not be spent on work that can be done by the web orchestrator, Gemini through
`agy`, or deterministic scripts.

The repository already routes settled implementation work to Gemini. This decision
makes that routing explicit for ChatGPT web orchestration and narrows Codex to the
smallest local role possible.

This decision supersedes the `AGENTS.md` model-routing section when a ChatGPT web
session is actively coordinating the work. The older routing remains the fallback
when no web orchestrator is active.

## Decision

When a ChatGPT web session is the orchestrator, responsibilities are split as
follows.

### ChatGPT web owns coordination and acceptance

The web orchestrator owns the reasoning-heavy coordination work that does not
require a local terminal:

- read the approved specs, plans, decision logs, and repository instructions;
- divide work into isolated branches and file-ownership scopes;
- write implementation and verification prompts;
- decide which Gemini model should run;
- inspect actual GitHub commits, diffs, pull requests, and handbacks;
- resolve requirements against the approved documents;
- decide whether findings require repair;
- decide integration order and review integration diffs;
- make the acceptance decision from the actual diff, raw command evidence, and
  independent review evidence.

Do not spend Codex context repeating work the web orchestrator can do from GitHub.

### Gemini 3.7 Flash High is the default settled implementor

Use `gemini-3.7-flash-high` through `agy` for work that is already decided and can
be described precisely, including:

- mechanical code changes;
- settled feature implementation;
- test scaffolding;
- content batches;
- repetitive edits;
- straightforward repairs with a known cause and known acceptance criteria.

### Gemini 3.1 Pro High handles expensive-to-miss errors

Use `gemini-3.1-pro-high` through `agy` when a plausible wrong result would be
expensive to detect, including:

- correctness-heavy implementation;
- independent static review of another worker's output;
- factual or scientific review;
- schema, sync, entitlement, or migration work;
- complicated repairs where the required behavior is settled but implementation
  mistakes are hard to spot.

Gemini Pro does not replace the web orchestrator's final acceptance decision. Its
report is evidence that the web orchestrator checks against the actual repository
state.

### Codex is a minimal local execution bridge

When the web orchestrator is active, Codex should do as little independent reasoning
as possible.

Codex may be used to:

- fetch remote refs;
- create or enter the exact isolated worktree already specified by the orchestrator;
- invoke `agy` with an exact prompt file prepared by the orchestrator;
- run a deterministic verification script prepared by the orchestrator;
- copy already identified ignored local artifacts into a disposable worktree when
  required for tests;
- save raw stdout and stderr to a named result file;
- commit and push only the explicitly authorized branch when the prepared task says
  to do so;
- report a simple command failure that prevents the prepared task from running.

Codex should not independently:

- reread the whole project to rediscover requirements already captured in the
  prepared task;
- redesign the task;
- rewrite or summarize the Gemini prompt;
- perform a broad static review that Gemini Pro or the web orchestrator can do;
- interpret a long verification log when the web orchestrator can inspect the raw
  result;
- compose a large handback when Gemini or a script can write the result file;
- decide whether a branch passes acceptance;
- spend context on information already available in the prepared prompt file.

Escalate to real Codex reasoning only when the web orchestrator, Gemini, and
prepared deterministic checks cannot safely resolve a local-only problem.

## Gemini prompt contract

Gemini prompts must be unusually detailed and self-contained. Do not assume Gemini
will infer repository conventions, ownership, or hidden acceptance rules.

Every implementation or review prompt should include, when relevant:

1. exact repository name;
2. exact branch name;
3. exact base commit;
4. exact target or integration commit if verifying;
5. exact files the worker may modify;
6. exact files and areas it must not modify;
7. required repository instructions, specs, plans, and decisions to read;
8. the frozen behavior or content contract;
9. known edge cases and previous defects that must not regress;
10. implementation requirements in concrete terms;
11. examples or formulas where a wrong interpretation is plausible;
12. test requirements;
13. exact commands to run;
14. expected counts, hashes, summaries, or other invariants;
15. commit and push rules;
16. Sanity or other external-write prohibitions;
17. stop conditions for genuine ambiguity;
18. an exact structured handback format.

The prompt should explain tricky requirements enough that Gemini does not invent a
reasonable-looking substitute.

## File-based handoff for Codex

Prefer a file-based handoff whenever Codex is only needed to provide local shell
access.

The intended flow is:

1. The web orchestrator writes the complete Gemini task or verifier prompt into a
   branch-visible file.
2. Codex receives only the path, model choice, worktree instruction, output path,
   and any exact shell command needed to invoke it.
3. Codex invokes `agy` without independently reconstructing the task.
4. Gemini writes or returns its full handback.
5. Codex saves the raw result to the requested file and pushes only when explicitly
   authorized.
6. The web orchestrator reads the result and the actual GitHub diff and decides what
   happens next.

When a handoff file exists only to move information between local execution and the
web orchestrator, keep it on the task branch and remove it before integration unless
there is an explicit reason to retain it as project documentation.

## Verification split

Verification should be split into three layers.

### Deterministic local checks

Use prepared scripts or exact commands for things that do not need model judgment:

- tests;
- analyzer;
- formatter checks;
- audit scripts;
- marker and strategy counts;
- file-scope checks;
- hashes;
- Git ancestry and cleanliness;
- dry-run upload summaries;
- policy gates.

Save raw commands, exit codes, stdout, and stderr. Codex does not need to interpret
them.

### Gemini Pro independent review

Use Gemini Pro for review that needs judgment, such as:

- implementation correctness;
- factual relationships;
- visual-brief compliance visible in source or rendered evidence;
- suspicious copied composition;
- architecture or ownership violations within a settled design;
- whether a changed reference actually supports the displayed claim.

The verifier must be read-only. It reports findings and does not fix them.

### Web orchestrator acceptance

The web orchestrator checks:

- the actual pushed diff;
- the Gemini review report;
- the deterministic command log;
- any required external references available through web tools.

The web orchestrator then accepts, rejects, requests a narrow repair, or integrates
the branch.

## Codex conservation rule

Before assigning any reasoning task to Codex, the web orchestrator must ask in this
order:

1. Can the web orchestrator do it through GitHub or web tools?
2. Can Gemini Flash implement it from a detailed settled prompt?
3. Can Gemini Pro implement or independently review it?
4. Can a deterministic script or exact command produce the needed evidence?
5. Can Codex merely launch the Gemini job or script and save the result?

Use Codex reasoning only if these routes are insufficient.

If the user reports scarce Codex quota, treat conservation as a hard execution
constraint. Do not hard-code a temporary percentage or reset date into project
policy.

## Repository safety

This routing decision does not weaken the existing repository safety rules.
Workers still must:

- use isolated branches and worktrees;
- preserve explicit file ownership;
- never edit generated files by hand;
- never merge into `main` without the authorization that applies to the current
  workflow;
- never upload or publish to Sanity unless the user explicitly authorizes that
  operation;
- never add AI attribution to commits or files;
- stop on a real requirement conflict instead of inventing a solution.
