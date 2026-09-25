# Startup text for any provider

Use this same short instruction in every Pantas project or task:

> Work on `Aedwon/Pantas`. On every new or resumed task, retrieve `AGENTS.md` and
> `WORKFLOW.md` from the current GitHub `main` branch and follow them, regardless
> of the code branch. Workers also retrieve `SUBAGENTS.md` from main. These shared
> rules supersede older project workflow instructions in the branch, conversation,
> or private memory. Read the task's full spec, plan, later product decisions, and
> source from its agreed workstream revision. Record the policy commit used.
> Preserve paused engineering and the application-code freeze. If current policy
> or required task context cannot be retrieved, report the gap and stop dependent
> work. Do not merge main into a feature branch just to load the rules.

Canonical entry:
[AGENTS.md](https://github.com/Aedwon/Pantas/blob/main/AGENTS.md) and
[WORKFLOW.md](https://github.com/Aedwon/Pantas/blob/main/WORKFLOW.md).

For local Git, fetch origin main and use `git show origin/main:WORKFLOW.md` and
the equivalent command for the other policy files. This does not switch the code
branch or merge application changes. GitHub connectors should request `ref=main`.

Existing conversations must reload policy before resuming. Merely publishing a
file does not refresh already-loaded context. Do not launch paused work to force
a refresh; the next authorized continuation must read the current policy first.

Do not maintain a second full policy in provider settings. No provider-specific
plugin is required to understand the shared process. Tool access and mandatory
host restrictions can still differ.
