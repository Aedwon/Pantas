# Pantas shared workflow

Policy revision: September 25, 2026. The rules below record the accepted workflow
audit decisions. They apply to every provider, model, and harness.

## Start with the same instructions

On every new or resumed task, retrieve the current `AGENTS.md` and `WORKFLOW.md`
from `Aedwon/Pantas` on `main`. Workers also retrieve the current `SUBAGENTS.md`.
Read policy documents linked from them at that same main revision. This policy
source is independent of the branch containing the code. It supersedes older
workflow instructions in that branch or conversation. Do not merge main into a
feature branch merely to obtain its policy.

With local Git, fetch origin main and read these files with
`git show origin/main:<path>` without switching the code branch. With GitHub-only
access, retrieve the files with `ref=main`. Record the policy commit in the task's
handoff or verification record. Read them again after a policy change or when
resuming an older conversation. Do not rely on automatically refreshed context.

Read the current task's spec, plan, and later product decisions from the agreed
workstream revision, not from main by default. Read relevant documents in full.
Read the actual workstream source before describing its behavior. Recover its
current status, approved scope, verification
evidence, outstanding decisions, and pause state. Never infer current release
readiness from an old PASS entry. A frozen branch or paused task stays that way
until Aedwon explicitly changes it. If the required instructions or current
decision record cannot be retrieved, state the gap and stop dependent work.

These repository documents are the project policy. Provider entry files contain
only pointers to them. Do not add separate project rules in local memory, global
provider instructions, or a provider's project settings. Record decisions here
and in the relevant repository decision log. Historical documents explain prior
choices; they do not silently restore superseded instructions.

Explicit current user instructions and mandatory platform rules still apply.
A platform limitation is a capability gap, not permission to change the workflow.
Report the gap and use an authorized execution path, or stop the affected step.
Never claim a check was performed merely because another tool could perform it.

## Conversation and complexity

For a new goal, briefly recommend continuing the current task, starting a separate
task, or using the relevant project or research environment. Keep follow-ups and
corrections in the same task. Prepare the handoff yourself when a move is needed.
Do not make Aedwon reconstruct earlier decisions.

Inspect existing decisions, implementation, constraints, and risks before offering
complexity options. Ask minimal, balanced, or hardened when meaningful scope
alternatives exist. Recommend one case by case, with a clear outline of its scope, inclusions,
tradeoffs, delivery effort, verification, maintenance costs, and uncertainty. Separate planning time from
implementation time. Wait for his choice before implementation. Small fixes within
settled scope do not need the same menu again.

Minimal means the smallest complete solution suitable to keep. It does not mean a
throwaway prototype or reduced correctness. Do not add speculative infrastructure.
There is no standing preference for balanced or another level. Recommend the
simplest option that satisfies the task's actual requirements and risks after
inspecting the existing context. Aedwon still chooses before implementation.
Existing approved requirements remain binding; do not relabel earlier work.

Brainstorm through persistent, probing clarification after inspecting available
facts. Planning with Aedwon takes time; do not rush to a spec, impose a fixed
question count, or stop because an initial checklist looks complete. Explore his
intent, alternatives, consequential behavior, risks, and unresolved concerns until
there is shared understanding and he has finished clarifying the design. Then
write the brainstorm spec. Ask about choices he owns, with costs and a
recommendation. Follow his requested question cadence, including grouped questions
when requested. Resolve routine technical details within agreed constraints.
Show enough of the whole design to explain a local choice. UI-affecting specs use
the visual companion below during brainstorming, before spec approval.

Decide learning and study-method questions from evidence, not from Aedwon's
preference. This covers scheduling, spacing, review order, pacing, practice
testing, and similar mechanics. Research high-quality sources, decide, and state
the evidence, its strength, and its sources in the reply and the decision record.
Ask him only when no clear evidence decides the question, and say so. How the app
looks and feels remains his decision.

Answer informational questions directly. A question alone does not approve a
product change. Continue work already authorized in the conversation; do not
reopen settled approvals because the user asked a follow-up question.

## Write for Aedwon

- Use direct, simple, clear, concise, semantically dense prose. Include outcomes,
  material tradeoffs, and decisions he needs to make. Keep enough context for easy
  reading. Avoid awkward compression, metaphors, filler, pompous language, and jargon.
- Keep replies under 150 words unless he asks for depth. Design options may need
  more space. Put implementation detail in agent documents, not routine replies.
- Avoid file, class, and function names unless he asks or is about to open the file.
  No headings, tables, or scattered bold in a short reply. Use lists when clearer.
- Explain a reason only when it changes his understanding or decision. Use ordinary
  words and clear sentences. Do not end sentences with clever reversals or side comments.
- Push back plainly when warranted. When wrong, correct it in one sentence and proceed.
- No em dashes. Use American spelling. Exact historical quotations stay unchanged.

This style applies to the spec section he approves. Content for students has its
own audience-specific rules in `AGENTS.md` and the content style guides.

In-app copy and external marketing copy are separate. Apply the app's teaching,
quiz, interface, and vocabulary rules only to their intended in-app audiences.
Do not infer marketing direction from them or impose a strict website style guide.
Aedwon personally writes and approves website copy. Preserve his approved wording;
do not draft or revise it unless specifically asked, and obtain his approval of
any proposed wording before publishing it. His communication preferences are not
a substitute for his direction on either product or marketing content.

## From idea to completed work

1. Recover the current context, clarify the intended outcome, and agree on scope.
2. Brainstorm alternatives and write the spec in `docs/superpowers/specs/`.
3. Review and refine the spec for completeness, consistency, and simplicity. Put
   every consequential scope, behavior, cost, risk, and maintenance decision in its
   plain-language approval section. Put technical detail in a separate agent
   section that agrees with it. Explain how completion will be judged.
4. Aedwon approves the plain-language spec section.
5. The agent writes the implementation plan in `docs/superpowers/plans/`, reviews
   it against the spec, and fixes gaps before execution. Check coverage, constraints,
   dependencies between tasks, failure cases, verification, and unnecessary complexity.
6. Implement within the approved scope. Follow the verification and review rules
   below. Report the outcome and any remaining limitation honestly.
7. Complete authorized local saving, integration, and working-branch uploads under
   the completion permissions below. Publication is a separate decision.

There is no separate human implementation-plan approval, execution-method menu,
or routine request to begin already-approved implementation. A material change
to the spec returns to Aedwon as a specific revision. Explicit planning-only
requests and pauses remain binding.

Separate spec and plan documents may be omitted only for a low-impact change
with an unambiguous, already-settled outcome. Briefly state the intended change
and why its impact is low. Judge impact by consequences, not patch size: a short
edit affecting payments, security, student data, or answer correctness is not
low-impact merely because it is small. If impact or scope is uncertain, use the
normal spec-and-plan process. Relevant checks and applicable review still apply.
This exception supersedes blanket document requirements in supporting guidance;
it does not waive task authorization, existing requirements, or pause boundaries.

These steps carry the project's adopted Superpowers workflow without requiring
an installed plugin. An available skill may support a step, but must follow these
project overrides. Do not add another human gate, stack alternative execution
paths, or omit a required review because a provider lacks the named skill.

## Plan detail and simplicity

Scale plan detail to the work. Ordinary tasks need clear steps, assigned files and
responsibilities, expected behavior, constraints, and concrete verification
commands and outcomes. Full implementation and test code are not mandatory in
every plan. Specify exact interfaces where separately assigned tasks depend on
them. Sensitive or difficult work needs precise failure, recovery, and verification
instructions. Existing explicit release requirements remain binding.

Do not leave vague placeholders or unresolved product decisions to workers.
Workers may resolve routine implementation details within stated boundaries.
A contradiction, unresolved requirement, or necessary departure goes to the lead.
The lead records and reviews needed technical plan revisions before affected code
changes. Material spec revisions return to Aedwon. Do not silently edit the spec
or plan during implementation.

Include simplicity in the existing spec and plan reviews. Reuse suitable existing
capabilities and remove additions unsupported by the agreed requirements. Preserve
correctness, security, recovery, accessibility, and required verification. Do not
add a recurring simplicity review or another human approval. This adopts Ponytail's
principles without requiring its plugin or activating persistent modes.

## Roles and execution

The lead owns context, design, unresolved decisions, integration, and final
acceptance. An implementor executes a bounded assignment. An independent reviewer
checks work they did not author. These responsibilities do not depend on a vendor.

Keep small or tightly coupled tasks with the lead. Delegate only bounded,
independent work. Give each worker the objective, relevant context, approved spec,
exact scope, constraints, assigned files, expected output, verification commands,
and stop conditions. Tell workers to preserve other agents' changes. The lead
inspects every result and owns verification of the combined work.

Every dispatch and resumption handoff includes the startup instruction from
`docs/workflow/startup.md` and the policy revision. This includes workers and
standalone web conversations outside a configured project. Before executing a
saved assignment, refresh the policy from main. Do not reuse an old dispatch's
workflow as authority merely because its product task remains valid.

Check available capacity and ownership before dispatch. Isolate workers in
separate worktrees. Serialize shared devices, accounts, browser profiles, and
generated outputs. Do not launch duplicate workers to recover an uncertain dispatch.
Independent review requirements remain in `SUBAGENTS.md`.

The current execution arrangement is documented separately in
`docs/superpowers/decisions/2026-09-25-chatgpt-web-relay-routing.md`. It is an
availability choice shared by every lead, not a different workflow for that
provider. Aedwon's canceled Google subscription does not prevent another provider
from following this policy; it prevents assuming that canceled worker service is
available. Do not incur a new subscription or substitute unavailable paid services.

## Computer control

Do not use computer-control tools to operate browsers or desktop apps. Aedwon
prefers to avoid their usage cost. Use available non-UI tools for authorized work.
When a step requires computer control, give him clear, numbered instructions to
perform it himself, then wait for the necessary result. Do not substitute another
UI automation tool to bypass this preference.

## Verification and visual checking

For ordinary work, run focused checks while implementing and all required checks
on the completed feature. The lead owns final combined verification. Follow
`SUBAGENTS.md` for evidence, independent review, and content checks. Do not rerun
unchanged full suites merely because the reviewer changed. Evidence must still
apply to the actual inputs and acceptance object. Fixes require relevant new checks.

Approved release and high-risk verification requirements remain binding. Do not
replace local execution with hosted Actions by default. Apply the compatible
resource rules in
`docs/superpowers/decisions/2026-08-23-github-actions-minute-conservation.md`.

Aedwon performs visual checking. Do not initiate app screenshot capture or an
autonomous visual-review workflow. He supplies screenshots when he wants
corroboration; inspect those images when asked. His visual judgment is separate
from automated results. Record relevant findings in `docs/ui-audit.md`.

Use the visual design companion during brainstorming when a spec affects UI.
Show the existing and proposed presentation for changes, or distinct options for
new UI, before spec approval. The approved presentation is an implementation
requirement: the implementation must match it 1:1 in the represented screens,
states, content, layout, styling, and interactions. Do not silently substitute an
approximation. Any necessary difference must be shown and resolved with Aedwon
before implementing that difference. If faithful previewing is not possible,
explain the specific gap and agree on how to represent it; never claim fidelity
that has not been established. Follow `docs/workflow/visual-companion.md`. This
preference does not authorize computer control or autonomous screenshot checking.

## Completion permissions

After authorized work is complete and required review and verification pass,
commit it locally without another prompt. The lead integrates it into the agreed
local development branch. Workers never merge their own work. Automatically upload
completed, reviewed, verified work to its agreed GitHub working branch, including
establishing the matching remote branch. Use a normal push and preserve others'
changes. Uploads may trigger configured automated checks.

Create a working branch without another permission request when approved work
needs one. Reuse an appropriate existing branch when possible. Explain why a new
branch is necessary and use a descriptive, provider-neutral name. This permission
covers necessary branch creation only; it does not authorize unrelated branches,
branch deletion, updates to main, or resuming paused work.

Establish the integration target from accepted workstream decisions. Do not assume
it is main. Preserve freezes, pauses, explicit task limits, and unrelated changes.
Do not integrate incomplete work, failed checks, unresolved review findings, or
conflicts needing a decision. Stop the affected step and report the specific issue.

Automatically clean up completed working branches and their separate worktrees
only after verifying that the work is merged into the agreed development branch,
which need not be main. Verify that no unsaved or unique unmerged work remains,
and no active or paused task depends on the branch or worktree. Preserve required
evidence before removal. Check the actual local and remote state before deleting
any corresponding branch; do not infer safety from an old completion report.
If any condition is uncertain, leave it intact and report the gap. Discarding
unmerged work requires separate, explicit authorization. This permission is for
completion cleanup, not a general purge of existing branches or worktrees.

Once Aedwon explicitly lifts the current application-code freeze, automatically
merge completed approved work into main and upload it after required checks and
reviews pass, including required visual acceptance where applicable. Respect any
specific workstream integration sequence and later freeze or pause. Do not ask for
a routine main-update approval after those conditions are met. This standing
permission does not lift the current freeze or authorize release publication.

Force pushes, history rewriting, deletion outside the cleanup conditions above,
unrelated branch creation or remote changes, issues and pull requests, and release
publication need matching authorization.
Requests merely to discuss, plan, prototype, or report progress do not authorize
later unrelated mutations. Tool permission lists do not grant task authorization.

**Workflow rollout exception, September 25, 2026:** Aedwon authorized publishing
these audited workflow and instruction documents on main and updating startup
pointers so existing and future work uses them. This is a documentation-only
exception to the main freeze. It does not authorize changes to application code,
release artifacts, or paused engineering. Future policy changes still require
agreement on their substance; do not silently change an approved requirement.

Commit messages explain why. Never add AI attribution, credit trailers, or similar
markers. Follow the repository attribution check. Stage only the reviewed task
changes. Any authorized correction to history must preserve others' work.

## Decision history and handoffs

Append decisions as they happen to `docs/superpowers/decisions/`. Keep the date,
options and costs, choice, exact user comment, what changed, and mistakes or
reversals. Preserve rejected approaches and their reasons for the later retrospective.
Never rewrite an earlier entry to make the conclusion look inevitable.

Update the existing current project status/SSOT immediately when each task is
completed, before reporting completion. Do not defer updates to a later milestone,
handoff, or batch. Preserve task-level detail: what changed, the affected revision,
what was checked and its actual results, what remains unverified, blockers, pause
state, and next steps. Distinguish implemented, reviewed, integrated, tested,
artifact accepted, and published states; record only states supported by evidence.
Delegated task completion must be recorded without presenting it as acceptance of
the combined work. The lead owns that distinction.

Record every user decision and its exact wording as it occurs, with the offered
options, costs, context, and resulting action. Do not replace verbatim comments
with a compressed summary. Keep the detailed chronological record alongside the
current status so another task can recover both the present state and its reasons.
Reuse existing records, not a new parallel tracking system. Where the SSOT is
external, keep the relevant current checkpoint and decision history accessible
through the repository as well. If a required update is unavailable, report that
specific record as pending; do not claim that the SSOT was updated.

Record ideas when offered. Distinguish an idea from approved implementation.
Do not reject or expand an idea before understanding what Aedwon wants from it.

Handoffs identify the controlling spec, plan, later decisions, current candidate,
verified state, unresolved work, permissions, and next action. Preserve the current
pause state. Current context must not exist only in one provider's private memory.

If a required decision is still only in an external record or local conversation,
retrieve it and record the relevant decision in the repository before relying on
it for a handoff. If it is unavailable, report what is missing. Do not invent it or
claim that repository-only recovery has been verified when it has not.
