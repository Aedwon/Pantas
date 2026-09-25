# Replace Gemini delegation with ChatGPT web relay workers

Date: September 25, 2026
Status: Accepted routing preference; recorded locally. No workers launched by this change.

## Decision

Aedwon stated:

> you can drop the Gemini subagents. I no longer have a Google AI Pro subscription. instead what we'll use is the ChatGPT Web Chat relay

Use ChatGPT web workers through the existing `Aedwon/chatgpt-terminal-relay`
dispatcher and local execution service in place of Gemini workers. No Gemini
subscription, quota check, Antigravity execution, or Gemini visual review is part
of the Pantas workflow now.

This supersedes model-routing directions in the August 3 execution-resourcing
document, August 23 web-routing decision, older plans, and the former worker-tier
table. Preserve those historical decision records. Their still-applicable product
requirements, isolation rules, and verification obligations are not waived.

## Responsibilities

- The lead Codex session coordinates when work starts in Codex. An assigned web
  orchestrator coordinates when work starts in ChatGPT web.
- The lead owns design, unresolved decisions, integration, and final acceptance.
- Delegate bounded, independent settled work to ChatGPT web workers. Small or
  tightly coupled work can stay with the lead.
- Independent review remains independent of authorship. Do not replace required
  review with the implementor's own assurance or create extra review stages merely
  because another worker can be dispatched.
- Use the supported model and capacity configuration available at dispatch time.
  This decision selects no new model version, reasoning level, concurrency count,
  or guaranteed quota saving.

## Existing transport

Read these current files from the relay repository before dispatch:

- `README.md`
- `docs/CHATGPT_PROJECT_INSTRUCTIONS.md`
- `docs/CHATGPT_WEB_WORKER_DISPATCH_RUNBOOK.md`

The browser dispatcher assigns ChatGPT web conversations and records coordination
in `[worker]` registry issues. Those issues do not execute local commands. Web
workers use `[relay]` requests for the existing self-hosted Mac execution path.
Use the registry's supported handbacks and live state. Do not infer success from
an ended conversation or a closed relay request.

Check current executor state, worktree ownership, and available capacity before
an actual wave. Worktree isolation does not isolate shared phones, emulators,
accounts, browser profiles, or generated assets. Serialize shared resources and
preserve dirty local work. Do not launch duplicate workers to recover an uncertain
dispatch.

The relay documentation also describes `workspace_visual_review`, which invokes
Gemini through Antigravity. Do not use that action for Pantas. This routing change
does not alter the separate project rules about screenshots or human visual
acceptance, and does not require editing the shared relay service.

## Approval and scope

The approved spec remains the basis for agent planning, plan improvement,
implementation, and verification. There is no extra human implementation-plan
approval. A worker receives the approved scope and the exact relevant constraints.

Relay capabilities are not task authorization. Preserve applicable commit, push,
merge, publication, data-preservation, and pause boundaries. Do not enable a
service, change accounts, bypass restrictions, or start paused engineering merely
because the execution provider changed.

## Cost and follow-through

This removes the dependency on the canceled Google subscription. The relay still
has coordination, availability, and verification costs. Existing code-complete
plans can still be used, but future plan detail should match the actual ChatGPT
worker's needs rather than a retired Gemini tier.

Local project and Codex routing instructions were updated. Remote instruction
distribution and the wider workflow audit remain unfinished. No relay jobs,
service changes, branch operations, or publications were performed.

## Later clarification: provider-neutral workflow

During the same audit, Aedwon selected one repository-owned policy for every
provider and asked to remove provider-specific rules. `WORKFLOW.md` now governs
roles and acceptance. Any provider may act as the lead; this supersedes the
provider-named lead assignments above. The implementor and reviewer roles are
also defined by their assignment, not their vendor.

The earlier choice of ChatGPT web relay workers remains the currently available
delegation arrangement. It does not impose different scope, approval, writing,
planning, or verification rules on a lead using another provider. The canceled
Google subscription remains unavailable. Follow the shared workflow through
available authorized tools; missing capability must be reported, not treated as
permission to skip a step.
