# GitHub Actions minute conservation

Date: 2026-08-23
Status: Approved

## Incident

During the lesson-illustration completion and review workflow, ChatGPT web used
GitHub-hosted Actions as the main runtime bridge because the web session could inspect
and edit GitHub but could not run the private Flutter repository locally.

The workflow created several disposable verification branches and pull requests to
`main`. A pull request to `main` also triggered the repository's normal PR CI, which
runs code generation, content building, formatting, analysis, layering and attribution
checks, the Flutter suite with coverage, backend tests, coverage checks, gitleaks,
Semgrep, and OSV. Focused temporary verification workflows often ran alongside those
normal jobs.

That made one narrow verification request fan out into multiple GitHub-hosted jobs.
Repeated debugging runs multiplied the cost further.

On 2026-08-23, the account warning showed 1,800 of 2,000 included Actions minutes used
for the billing cycle, or 90%, with the monthly reset due on 2026-09-01. This is an
incident snapshot, not a permanent threshold in repository policy.

## Contributing cause

The orchestration policy had optimized too strongly for conserving Codex usage.
Because ChatGPT web has no local Flutter/Dart runtime for this private repository,
local execution was replaced too often with GitHub-hosted CI.

This traded one scarce resource for another:

- less Codex/local-agent usage;
- much more GitHub Actions usage.

GitHub Actions then became an interactive debugging loop instead of a final or
high-value verification gate.

## Bridge reliability finding

The earlier 5.6 Luna Light problem was a bridge problem, not evidence that Luna was
implementing Pantas badly and not evidence that the invoked Gemini workers were weak.

In that workflow, Luna Light was used only as a thin local terminal bridge. The web
orchestrator gave it a terminal-only control prompt that explicitly forbade independent
repository inspection, review, interpretation, source editing, extra commands, and
merging. The bridge's job was to fetch the prepared control task and execute it exactly.

The preserved control task describes the same role as a `local terminal bridge`. It
launches a prepared shell script. That script performs the deterministic repair and
verification steps and invokes Gemini 3.1 Pro High through `agy` for the judgment-heavy
verification step.

A successful bridge handback from that flow had the six-line shape:

```text
EXECUTION COMPLETE
RUNNER_EXIT: 0
RESULT_BRANCH_SHA: 9e3d887e871fc8054d482d831fefc6a03ec7cc76
REPAIR_BRANCH_SHA: 726580e79e49202243d1e2daee1c0e0ee185bcc5
INTEGRATION_SHA: 04f038a4df140df8dbde966bb1460
MAIN_SHA: 3a1ac087fd88bce1e1903d5c7996371054b36094
```

The repeated correction turns around that workflow therefore must be diagnosed at the
correct layer. A thin bridge can fail to follow an exact control task, can return an
incomplete handback, or can mishandle the execution chain even when the underlying
Gemini task is sound.

Do not use a bridge failure as evidence against the Gemini model that the bridge was
supposed to invoke. Track these separately:

- orchestrator/control-task quality;
- bridge execution reliability;
- deterministic script behavior;
- Gemini worker or verifier quality;
- CI/runtime environment behavior.

Escalate the layer that actually failed.

## Available execution capacity reported at the incident

At the time of this decision, Aedwon reported:

- about 24% Codex usage remaining;
- Antigravity IDE installed;
- Google AI Pro available through Antigravity;
- substantial Gemini 3.1 Pro High and Gemini 3.7 Flash High capacity.

These percentages and subscription details are time-sensitive. Future sessions must
not assume the same remaining quota. The durable fact is that Antigravity/Gemini may
be available as a local execution lane and should be considered before spending
GitHub-hosted Actions minutes.

## Decision

When ChatGPT web coordinates Pantas, GitHub-hosted Actions are a scarce verification
resource. They are not the default substitute for a local terminal.

Use the following execution order.

### 1. ChatGPT web and GitHub for work that needs no runtime

Use the web orchestrator and GitHub connector for:

- repository inspection;
- diff and PR review;
- branch and integration work;
- static contract checks;
- deterministic reasoning over repository files;
- external web research;
- narrow file edits that do not require local execution to make safely.

Do not start CI merely to confirm something visible directly in the repository.

### 2. Antigravity/Gemini for settled implementation and local verification when available

When local repository execution is needed and Antigravity is available, prefer:

- Gemini 3.7 Flash High for well-specified implementation, mechanical repairs, test
  scaffolding, and repetitive work;
- Gemini 3.1 Pro High for expensive-to-miss correctness work, independent review,
  complicated settled repairs, and verification where a plausible wrong result is
  hard to detect.

Prompts must still follow the detailed worker contract in
`2026-08-23-web-orchestrator-model-routing.md`.

The web orchestrator remains responsible for acceptance from the actual GitHub diff
and evidence.

### 3. Codex for local execution or as a stronger bridge when needed

Codex is no longer treated as something to avoid at all costs.

Use Codex when:

- local Flutter/Dart/browser execution is required and Antigravity is unavailable or
  unsuitable;
- a thin bridge has repeatedly failed to execute an exact prepared control task or
  return the required handback;
- the cost of another failed bridge attempt plus CI rerun is likely greater than the
  Codex usage;
- local debugging genuinely needs a capable agent to inspect runtime behavior.

A stronger Codex model may still be used only as the bridge. It does not need to take
over implementation or review if the prepared task already delegates those parts to
Gemini or deterministic scripts.

Continue to conserve Codex by keeping prompts precise and scope narrow. Do not spend
Codex context rediscovering requirements the web orchestrator already knows.

### 4. Self-hosted GitHub runner for routine automated local checks

A self-hosted runner on Aedwon's Mac is the preferred long-term automation option if
it is configured safely for this private repository.

It preserves GitHub-triggered automation while moving Flutter, Dart, Node, and browser
execution to the local machine instead of GitHub-hosted runners.

Until a self-hosted runner is configured, do not pretend one exists. Use Antigravity,
Codex, or carefully rationed hosted Actions instead.

### 5. GitHub-hosted Actions for high-value gates

Use hosted Actions when one of these is true:

- the check specifically needs GitHub's hosted environment;
- an independent clean-machine run is important evidence;
- the repository's required CI must run before an authorized integration or release;
- no suitable local execution lane is available.

Hosted Actions should be a verification gate, not the primary development REPL.

## Hosted Actions rules

### Do not create CI-only pull requests to `main` just to trigger a focused check

A disposable PR to `main` triggers the normal repository PR workflow in addition to
any temporary workflow. This is too expensive for routine orchestration.

If a temporary hosted check is truly needed, prefer a narrowly scoped `push`-triggered
workflow on an isolated disposable branch so only the intended job runs.

Never merge the temporary workflow.

### One focused run after static preparation

Before spending hosted minutes:

1. inspect the relevant diff and contracts;
2. make all reasonable static corrections first;
3. choose the smallest command set that proves the uncertain behavior;
4. run it once;
5. use the failure log to make a targeted repair.

Do not use hosted Actions for trial-and-error debugging when local execution is
available.

### Reuse valid evidence

Maintain acceptance evidence by commit and affected path.

If a check passed on the same commit, or the files that can affect that check have
not changed, reuse the result instead of rerunning it merely for ceremony.

Rerun when:

- the relevant implementation changed;
- integration can affect the behavior;
- the prior environment was invalid;
- the evidence does not actually cover the required contract.

### Prefer job-level reruns

If one job fails and GitHub permits it, rerun only the failed job instead of the
whole workflow. Do not repeat successful expensive jobs without a reason.

### Cancel obsolete runs

Repository workflows should use concurrency cancellation where safe so a new commit
cancels the obsolete run for the same branch or PR.

Recommended pattern:

```yaml
concurrency:
  group: ci-${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true
```

This should be added through a normal infrastructure change when the current branch
and release policy permit it. Do not silently alter CI while implementing an unrelated
feature.

### Split fast checks from full acceptance

Future CI infrastructure should separate cheap PR checks from expensive acceptance
checks. Use path filters and affected-test selection where safe.

A small tooling or documentation change should not automatically rebuild and test
unrelated application areas unless the repository contract requires it.

## Execution-chain escalation rule

Do not continue the same correction loop indefinitely merely to save quota.

After two material misses of the same settled contract, first identify which layer
failed:

1. the web orchestrator's prepared task or prompt;
2. the local bridge executing that task;
3. the deterministic script;
4. the Gemini implementor or verifier;
5. the CI/runtime environment.

Escalate only the failing layer when possible.

For example, if Luna Light fails as a terminal bridge but the prepared script and
Gemini prompt are sound, use a stronger bridge or a direct local invocation. Do not
switch away from Gemini solely because the bridge failed. If Gemini's actual output is
wrong, then change the Gemini model or task specification.

A third attempt through the same failing layer requires a specific reason.

This rule is about total resource use and correctness, not model prestige.

## Quota-aware coordinator checklist

Before dispatching work that needs execution, the web orchestrator asks:

1. Can this be proven through repository inspection with no runtime?
2. Can Antigravity/Gemini run it locally?
3. Is Codex useful as the local executor or a more reliable thin bridge?
4. If something already failed, which layer actually failed?
5. Is there already valid evidence for the current affected commit?
6. If hosted Actions are still needed, what is the smallest single job that proves
   the uncertain behavior?
7. Will a PR to `main` accidentally trigger unrelated expensive workflows?

The coordinator should also ask for current quota information when the answer would
materially change routing. Do not assume old percentages remain current.

## Repository safety

This decision changes execution routing only. It does not change branch or publication
rules.

- Do not merge to `main` without the authorization that applies to the workflow.
- Do not publish or upload anything to Sanity without explicit authorization.
- Temporary verification workflows and branches remain disposable.
- Final acceptance still requires the actual diff and appropriate evidence.
