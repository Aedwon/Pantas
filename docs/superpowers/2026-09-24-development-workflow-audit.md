# Pantas collaboration and development workflow audit

Date: September 24, 2026
Status: Core workflow published on main and retrieval verified on September 25, 2026. The wider audit interview remains open. Current adopted policy is in `WORKFLOW.md`.

## What the audit establishes

The process contains useful safeguards, existing simplifications, and contradictory instructions. Its main weakness is that agents must reconstruct the current rules from several generations of documents and handoffs. That creates inconsistent behavior before implementation even starts.

The strongest evidence for the Codex/web difference is direct: Codex has a standing complexity-choice rule in its global instructions. The Pantas ChatGPT project's Instructions field was empty when inspected. The September 15 web handoff tells the next agent to follow the repository's complexity rules, but the checked repository does not define that choice. A historical content-protection decision does record Aedwon choosing balanced. The choice has therefore occurred, but its delivery is not reliably established across entry points.

The release work is more demanding than an ordinary feature change for specific reasons. It combines encrypted content, migration and recovery, quiz performance, exact release artifacts, and preservation of student progress. Several expensive checks belong to that work. They should not become automatic requirements for every edit.

The most useful first improvement is to reconcile the existing system and make its current rules available in both tools. Choosing a new complexity default or adding another mandatory skill before doing that would leave the underlying inconsistency intact.

## Scope, method, and limits

This is a process audit, not a fresh product-security assessment or release acceptance. Evidence includes:

- Complete project collaboration instructions, local Codex global instructions, worker contract, and selected historical routing, resource-allocation, layering, and plan-consistency decisions.
- Installed Superpowers planning and execution mechanics, local grilling, and primary sources for Ponytail and Matt Pocock's current grilling skills.
- The relay's reusable ChatGPT worker instructions, relevant relay documentation, and the September 15 recovery handoff.
- The September 5 release-E2E design and plan, September 7 ordered execution plan and content-protection/quiz execution documents, and September 8 policy rulings.
- The current Google Doc SSOT's readiness, security/content protection, beta operations, founder operations, architecture research, web-copy instructions, and approved-copy record.
- Selected recent Codex/web task histories concerning recovery, reconciliation, readiness, beta scope, and skills.
- Live remote-main identity, local worktree inventory, relevant source/dependency checks, CI definitions, content-writing guides, and the actual web project's instruction field.

This is an exhaustive review of the identified workflow surfaces, not a claim to have read every historical conversation, feature spec, source file, or research tab. The original September 6 quiz document was not found in the inspected checkouts. Its later reconciliation is recorded in the September 15 handoff, and the September 7 execution contract plus September 8 rulings were available.

No Flutter suite, device campaign, paid implementation wave, deployment, or release operation was run. Historical PASS statements are documentary evidence, not fresh verification. No present CI-minute or model-token savings were measured.

The Pantas project's empty web instruction field was verified after the project name loaded, including the field's actual value. Account-wide web custom instructions, project-source injection, and the full effective context of every standalone chat were not audited. The empty field establishes a missing project-level instruction source. It does not prove web chats have no other instructions.

Local and remote main both pointed to `b642e2d169e0a03120d4f71cc6e10a6148cc5ef0` during initial inspection. Application code on main remains frozen. Aedwon later authorized publishing this workflow documentation there so all code branches can retrieve current policy. The active engineering lineage and later SSOT checkpoints differ. Main's application source does not establish the latest release behavior.

The latest inspected readiness entry records engineering paused at the user's direction. This audit does not resume it or waive any release requirement.

## Preferences already established

1. Keep the minimal/balanced/hardened choice and make it available in both Codex and web.
2. Ask when there are meaningful scope alternatives. Small fixes follow their existing scope.
3. Minimal means the smallest complete solution suitable to keep, with appropriate correctness checks. A throwaway prototype is separate.
4. Do not choose a default until the whole process and the purpose of its existing complexity are understood.
5. Preserve chronological decision history, including rejected options, costs, exact comments, and mistakes.
6. Keep the interview deliberate and probing.
7. Examine both the product requirements that drive engineering work and the process used to deliver them. Existing requirements remain in effect unless Aedwon explicitly changes them.
8. Preserve immediate offline study after installation. A required first-use content download is not the selected direction.
9. Keep the goal of making easy copying of the whole collection harder. Complete prevention against a skilled person is not the selected goal. This confirms product intent, not release-specific acceptance or proof that the present implementation is proportionate.
10. Aedwon approves the spec produced through brainstorming. The agent then creates the implementation plan from that approved spec, reviews and improves it using the applicable workflow and skills, and implements. There is no separate user approval of the implementation plan and no routine request to authorize coding again after spec approval.

11. The spec has a plain-language approval section for Aedwon and a separate technical section for agents. Write direct, simple, clear, concise, semantically dense prose for him. Include only information useful to understanding or deciding. Avoid metaphors, filler, jargon, and implementation names unless requested. Do not omit necessary context or hide consequential decisions in the technical section.
12. Include simplicity checks in the existing spec and plan reviews. Do not add a separate recurring review or another human approval. Reuse suitable existing capabilities and remove unnecessary additions without weakening approved requirements or required safeguards. This is not activation or installation of the full Ponytail skill.
13. Aedwon's content-language instructions were already distinct: lesson teaching content uses plain English understandable to a Grade 5 student; Quiz questions and choices use realistic target-exam language across Mock, normal quizzes, and in-lesson quizzes. Wrong choices must reflect meaningful reasoning errors or misconceptions. The contrary worker wording was an instruction-recording error, not a contradiction in his intent. Local authoring guidance has been corrected; no existing content was rewritten.
14. Quiz answer explanations also use plain English understandable to a Grade 5 student. This applies across Mock, normal quizzes, and in-lesson quizzes. Preserve accuracy when explaining difficult terms or reasoning.
15. Retire Gemini delegation because Aedwon no longer has Google AI Pro. ChatGPT web workers through the existing relay replace it. Preserve the lead agent's coordination and acceptance responsibilities, independent review, and task authorization boundaries. Do not ask for Gemini quota or use Gemini-backed relay actions. See the [accepted routing decision](/Users/aedwon/Documents/Projects/Pantas/docs/superpowers/decisions/2026-09-25-chatgpt-web-relay-routing.md).
16. For ordinary changes, run focused checks during implementation and all required checks on the completed feature. The lead owns verification of the combined work. The blanket all-checks-after-every-task rule is retired. Release and high-risk contracts retain their applicable requirements.
17. Aedwon performs visual checking himself. He will provide screenshots when he wants corroboration. Agents may inspect supplied screenshots when asked; they do not initiate app capture or autonomous visual review. His final visual judgment remains separate from automated test results. No screenshot-delivery repair is part of the selected workflow.
18. Completed authorized work is committed locally and integrated by the lead into the agreed local development branch after required review and testing pass. No additional permission request is needed for those steps. Preserve task restrictions, pauses, freezes, and unrelated changes. GitHub uploads, publication, branch creation/deletion, and history rewriting are not authorized by this choice.
19. Automatically upload completed, reviewed, verified work to its agreed GitHub working branch. This can establish that branch's matching remote destination. Uploads may trigger configured checks. Updates to main and publishing releases remain separate decisions. This does not authorize force pushes, unrelated remote changes, or resuming paused work.
20. Scale implementation-plan detail to the work. Ordinary tasks get clear steps, responsibilities, expected behavior, constraints, and checks. Sensitive or difficult work gets precise instructions. Full implementation and test code are not mandatory in every plan. Workers may resolve routine details within the approved scope; consequential decisions and required verification remain explicit. Agent plan review remains mandatory, with no additional user approval.
21. One repository-owned workflow applies to every provider and harness. Remove provider-specific project policies and private-memory overrides. Provider entry files may only point to the shared rules. Tools can differ, but scope, approval, writing, planning, and verification must follow the same contract. A provider with only GitHub access must retrieve that contract and report missing context or execution capability.
22. Publish the shared workflow on main under a documentation-only exception to its freeze. Every new or resumed task retrieves current policy from main, regardless of the code branch. Task-specific product documents and source remain on their agreed workstream revision. Update startup instructions in local providers and web chat. Do not merge unfinished product branches, alter application code, or resume paused engineering as part of this rollout.

The accepted rules are consolidated in `WORKFLOW.md`, with technical standards in `AGENTS.md` and worker requirements in `SUBAGENTS.md`. Local provider globals and the saved Pantas web-project startup instruction point to current policy on main. A Pantas-only web custom instruction also covers standalone chats; customization was previously disabled and its instruction field was empty. Complexity recommendations are now chosen case by case, with clear scope, inclusions, and tradeoffs. Separate specs and plans may be omitted only for low-impact changes with settled outcomes. Remaining copy-rule inconsistencies and external-action permissions remain under review. Existing release checks stay binding. The shared workflow no longer depends on installing a provider-specific skill.

### Agreed spec-to-implementation sequence

Brainstorm together → write and refine the spec → Aedwon approves the spec → agent writes the implementation plan → agent reviews and improves the plan → agent implements and verifies.

The approved spec is the basis for implementation planning. Aedwon should not have to read or approve the technical plan. Agent review should catch contradictions, unnecessary complexity, missing steps, and verification gaps before execution. Improving the plan does not authorize silently changing the approved spec. A material change to the spec must return as a specific proposed revision, not as a request to review the whole technical plan.

This project rule is an explicit exception to the installed Superpowers human plan-review gate. It does not resume paused engineering or authorize unrelated implementation. Local commits and integration follow preference 18; GitHub working-branch uploads follow preference 19. Updates to main, other remote changes, and publication remain separate decisions.

## Workflow at the start of the audit

This table records the inspected baseline. The accepted preferences above and the September 25 routing decision supersede its Gemini instructions and additional human plan-review steps.

| Stage | Current behavior and qualification | Main problem |
|---|---|---|
| Request and context | Route the request; distinguish discussion from authorized action; recover the current feature, candidate, decisions, and pause state | Context recovery depends heavily on handoffs and historical reading |
| Complexity | Codex global policy asks minimal/balanced/hardened before nontrivial work; some historical web decisions do the same | No reliable shared definition or delivery mechanism |
| Brainstorming | Clarify needs and compare approaches; Superpowers separately classifies spike, bounded, and architectural work | Process classification can be confused with the user's solution scope |
| Specification | Pantas requires a written spec before implementation; decisions are logged as they happen | Blanket rule can exceed the needs of a small settled change |
| Implementation planning | Often detailed enough for a cheaper worker to execute without design judgment | Detail can be valuable or wasteful depending on the worker and uncertainty |
| Execution | Codex owns high-level judgment; settled work is often assigned to Gemini. Web can coordinate local execution through the relay | Older model and transport instructions no longer describe all available routes |
| Verification and review | Focused work checks, broader integration checks, and task-specific acceptance; some instructions still require all gates per task | Conflicting frequency, stale pass baselines, potentially duplicated reviews |
| Integration and release | Source acceptance, branch integration, exact artifact acceptance, release decisions, and publication are separate | Authorization and completion language sometimes collapse these states |
| Recovery and operations | Existing registry, SSOT, local handoffs, beta triage, and retained evidence | Current status is mixed with old status and proposals |

Your six-step description captures the broad design sequence. It omits the current-state check before design, ongoing decision logging, verification/review after execution, and the separate release/publication decisions.

Web does not only edit the remote repository. The newer relay allows web workers to inspect, edit, and test local work on the Mac. Codex does not exclusively implement through built-in subagents. The initial policy prescribed Gemini execution for settled work; Aedwon has now replaced it with ChatGPT web relay workers. Tool transport and the responsibilities assigned to each model remain distinct.

## Why the strictness was introduced

### Detailed plans supported cheaper implementation

The August execution-resourcing decision deliberately moved difficult reasoning ahead of cheaper Gemini execution. Exact interfaces, code, tests, and expected results reduced the judgment required from an implementor. Planning itself had consumed scarce quota, so this was an economic tradeoff.

Removing that detail while keeping the same worker assumptions could increase repair and review costs. Conversely, forcing a capable inline implementor to consume a code-complete plan for a small reversible edit can duplicate effort. The September 25 switch to ChatGPT web workers retires the original Gemini-specific economic premise. Future plan detail should be assessed against the new workers' actual needs; the change alone does not justify discarding useful precision.

The appropriate plan detail depends on what remains uncertain and who will execute it. It should not be determined only by the number of files.

### Isolation and verification addressed observed agent failures

The worker contract records changes made outside the assigned worktree and false reports of clean checks. Isolation, exact outputs, and coordinator acceptance address real incidents.

Later execution guidance already reduced full-suite repetition after workers timed out and lost work. Its implementor template uses focused tests and leaves full gates to the coordinator. That optimization should be reconciled into the standing contract, not proposed as if it never existed.

### Release checks protect different objects

The September release sequence distinguishes:

- Product source and behavior.
- Installed encrypted content and device recovery.
- Performance on representative hardware.
- Six integrated user journeys.
- The exact signed release artifact.
- Founder acceptance of residual risk and upload eligibility.

A source pass cannot prove what a later AAB contains. A correctly encrypted installed database cannot prove that no plaintext seed was packaged. A widget test cannot establish low-end phone performance. These are different questions.

The three E2E runs also have a stated purpose: repeatability and isolation, including a restart before the third run. The audit does not establish that the approved count is either optimal or unnecessary.

### Simpler operating models already exist

The beta program was explicitly reduced after Aedwon said the process was too much for a solo founder. It emphasizes ordinary use, lightweight feedback, internal triage, blockers, closeout, and a decision. It does not require testers to follow the engineering checklist.

The founder operating document also separates phases and escalates consequential decisions. Neither document requires implementing every suggested future control now. These are useful examples of proportional process already present in Pantas.

## Findings and recommended changes

### 1. Shared collaboration rules are not reliably delivered

**Evidence:** The local global instruction requires the complexity choice. The inspected Pantas web project has no instructions. Repository role rules, web overrides, relay rules, and handoffs live separately. The September 15 handoff references complexity guidance without providing its definition.

**Consequence:** Behavior depends on the entry point and which history happens to be loaded. A more elaborate skill cannot reliably repair an absent instruction source.

**Recommendation:** One short, versioned Pantas collaboration contract for shared behavior. Codex and web should have small entry instructions that identify it and explain how to retrieve it. If web needs a pasted copy, label its version and update it deliberately. Do not assume a repository file is automatically loaded by web chat.

Keep tool-specific execution instructions separate. Match scope choices, question handling, accepted decisions, reporting, and approval semantics across tools.

**Cost:** A small maintained entry instruction in each environment. Avoid a new synchronization service until manual versioning proves insufficient.

**Accepted September 25:** Aedwon selected one shared repository policy and explicitly asked to remove provider-specific rules. `WORKFLOW.md` now holds common behavior. `AGENTS.md` is the shared entry and technical standards document. `CLAUDE.md` and `GEMINI.md` contain identical discovery pointers. A reusable web startup pointer is prepared in `docs/workflow/startup.md`. The lesson-authoring runbook and worker roles no longer assign behavior by provider.

**Additional evidence:** The local Claude and Gemini global policies retained older delegation and mutation instructions, while Codex had the audit's newer preferences. The project also had an ignored Claude settings file with 193 permission entries: 172 shell entries, 11 read entries, six page-fetch entries, two skill entries, one search entry, and one browser entry. All three globals now defer to the repository for Pantas; the project-only permission override was removed with a backup. Global account, tool, plugin, model, and security settings were not deleted.

Claude's Pantas memory directory contained 55 Markdown files. The index and selected detailed notes exposed old main-branch guidance, canceled Gemini quota procedures, a device-restart completion rule, and a mandatory visual spec-review offer. The entire directory was moved out of active memory loading into a dated local archive, with matching SHA-256 hashes, and replaced by a repository pointer. Not every historical note was revalidated against the present product. The archive preserves evidence; it is not current policy.

The local archive is `/Users/aedwon/.codex/audit-backups/pantas-workflow-2026-09-25/`. Current shared decisions must not depend on retrieving it. Historical product notes still need checking against current specs when relevant; this audit does not claim every old implementation observation was migrated into a verified repository checkpoint.

A fourth instruction source, the ancestor `/Users/aedwon/AGENTS.md`, was also inspected and made to defer to repository policy for Pantas. The inspected Codex configuration contained no instruction, prompt, or hook override keys. Claude's inspected global settings contained no prompt or hook keys; its runtime permission modes and plugin selection remain platform configuration. Existing nested worktrees retain their own Git revisions and were not rewritten. They must adopt the published policy through an authorized handoff or update before being used for new work.

Document validation passed: shared entry targets exist, the two provider discovery files are identical, accepted workflow requirements remain present, all inspected local instruction sources defer to the repository, the project-only permission override is absent, and all 55 archived memory hashes match. No fresh-provider behavior or product tests were claimed from these checks.

**Distribution:** Main is now the authorized policy source, including for work on older code branches. Startup instructions require retrieval on new and resumed work, and handoffs carry the policy revision. This avoids merging application changes merely to get current instructions. The GitHub publication and retrieval checks are recorded in the rollout entry of the decision log.

**Limits:** No paused engineering conversation was resumed to test model behavior. A private repository must be accessible through the session's authorized connector. Provider system instructions, tool availability, and mandatory security controls cannot be made identical by project Markdown. The contract requires the same process and honest reporting of capability gaps; it cannot guarantee identical model behavior or automatically replace context in a running turn.

### 2. Historical complexity labels do not have stable meanings

**Evidence:** The security SSOT records a choice among minimal documentation/encryption requirements, balanced packaging/key/migration/extraction work, and hardened server-controlled delivery/abuse detection. The quoted time ranges were for documentation, not implementation. Balanced carried build-key management, migration work, physical testing, and residual-risk acceptance.

That historical minimal option differs from the complete, keepable minimal solution Aedwon defined in this audit.

**Recommendation:** Show what each choice buys for the actual task. Include implementation, validation, user-visible tradeoffs, ongoing maintenance, and uncertainty. Distinguish the cost of the current planning step from the likely full delivery effort. Do not present a planning estimate as the cost of the feature.

Keep the default undecided until concrete cases have been reviewed. Do not relabel the approved security work or infer that balanced was accidentally hardened.

**Cost:** Better discovery before proposing options. Avoid false precision when implementation effort is not yet known.

### 3. Four decisions are being compressed into one label

The following are related but distinct:

1. What product outcome and optional features to include.
2. What uncertainty requires investigation before a reliable design.
3. What failures and release exposure require evidence.
4. What execution arrangement is economical and reliable.

A small access-control repair can need careful testing. A large repetitive content batch can have simple implementation but require strong answer validation. A prototype can require expensive investigation while remaining disposable.

**Recommendation:** Keep these distinctions in the agent's reasoning. Present only the meaningful user choices. Superpowers process labels should not become a second menu the user must manage.

**Cost:** The agent must explain why a check or implementation mechanism is necessary. “Hardened” cannot serve as the entire justification.

### 4. Current rules and historical rationale are mixed together

**Evidence:** The worker collision-map reference points to Part 4, while the map is in Part 9. Historical analyzer/layering counts survive after later decisions changed the expected gate. Readiness contains old headings, percentages, and NOT STARTED statements alongside later evidence and a pause instruction.

**Recommendation:** Retain history verbatim. Give each active workstream a short current checkpoint that identifies controlling decisions, superseded statements, exact candidate, acceptance state, blockers, and next action. Use existing SSOT and registry locations.

The current view should point to history. Implementors should not have to infer the current rule from chronology every time.

**Cost:** Update the checkpoint when a decision or acceptance state changes. This replaces repeated reconstruction; it should not become a second independently maintained project tracker.

### 5. Approval boundaries contradict each other

**Evidence:** Global instructions require explicit branch and merge authorization. Pantas also says to merge finished work locally by default, forbids unrequested commits, and requires per-task worker commits. The relay's general execution capabilities include actions that a particular task may not authorize.

**Recommendation:** Resolve these contradictions into one task authorization model. Carry existing matching authorization through handoffs. Distinguish discussion, plan approval, implementation, commit, push, merge, and publication where the user wants those distinctions.

A technical failure within approved work should not automatically reopen the whole design. A material scope or product change should return with the exact decision needed.

**Resolution so far:** On September 25, Aedwon authorized automatic local commits and lead integration of completed, reviewed, verified work into the agreed development branch, followed by automatic uploads to its GitHub working branch. Local policies record those permissions. Frozen main and paused engineering remain protected. Updates to main, publication, and broader branch setup remain separate decisions; relay capabilities are not authorization.

**Cost:** Further user decisions about the remaining boundaries. Generic worker instructions cannot supply missing permission.

### 6. Plan detail is not matched to execution

**Evidence:** Pantas requires specs and plans universally. Superpowers supports lighter bounded design. The historical Gemini strategy benefits from exact plans, while native execution can often resolve routine implementation details locally.

**Recommendation:** Scale the artifact to the handoff:

- Small, already-settled change: brief acceptance description and affected checks.
- Bounded feature: concise spec and implementation sequence.
- Ambiguous, cross-boundary, or high-consequence work: detailed design, interfaces, failure behavior, and verification.
- Cheap mechanical worker: enough precision to avoid assigning it unresolved design decisions.

A full plan is justified when it removes real ambiguity. Do not duplicate source code mechanically when the duplication adds no reliable constraint.

**Accepted September 25:** Aedwon selected scaled plan detail. The local project, design-partner, and worker instructions now implement this exception to Superpowers' blanket code-complete plan requirements. Existing explicit requirements stay binding; this does not authorize silently shortening release plans or skipping spec approval for small changes.

**Cost:** Less plan detail increases implementor judgment, which must match model capability. Keep exact instructions where ambiguity would cause costly mistakes.

### 7. The verification contract conflicts with its own optimization

**Evidence:** SUBAGENTS mandates broad checks per task. Later execution templates explicitly centralize full checks to avoid worker timeouts. The Actions-conservation decision permits evidence reuse for unchanged relevant inputs.

**Recommendation:** Publish one current division of checks:

- Implementor: affected tests and required local checks.
- Coordinator: integration and broader checks at a meaningful boundary.
- Release verifier: the approved release-specific matrix.
- Content reviewer: semantic correctness and applicable content validators.

Retain failing output and honest exceptions. Retire historical numeric baselines as operational pass criteria.

Reuse evidence only when relevant source, configuration, generated content, dependencies, environment, and acceptance object remain valid. A matching commit alone is insufficient for a dirty harness or regenerated encrypted payload.

**Cost:** Requires a clear dependency judgment. No unconditional “one test is enough” shortcut.

### 8. Review can duplicate work without adding independent evidence

**Evidence:** Superpowers has alternative native and subagent execution paths with their own reviews. Additional review skills and relay review modes can be layered on top. The relay can request repeated Gemini visual reviews.

**Recommendation:** Give each review a stated question: spec compliance, code correctness, content truth, visual usability, or exact artifact acceptance. Combine compatible questions in a bounded review. Use a separate reviewer where failure is expensive or independent acceptance is already required.

Do not count repeated agreement from the same model as independent proof. Do not remove the current E11 acceptance review because another task's review was redundant.

**Cost:** Some risks deserve multiple reviewers. Assign them intentionally instead of stacking every available workflow.

### 9. Execution routing has changed faster than its instructions

**Evidence:** Older web guidance assumes a Codex bridge and treats self-hosted execution as future work. The relay now provides local execution and a worker registry. Earlier agy dispatch guidance also records failure when routed through an unsuitable subagent layer.

**Recommendation, updated September 25:** State current roles independently of product names: coordinator, implementor, verifier, and human decision-maker. Use the existing ChatGPT web relay for delegated work in place of Gemini. Keep the lead responsible for acceptance. Do not make built-in subagents mandatory for every Codex task.

Parallelize independent file ownership only when shared worktrees, devices, emulator state, accounts, browser profiles, and generated outputs are also isolated.

**Cost:** The relay still requires coordination and verification. Verify supported model configuration and capacity at dispatch. Do not preserve retired Gemini quota questions or fixed concurrency rules.

### 10. Recovery depends too much on conversational context

**Evidence:** Recent tasks repeatedly recover inaccessible web orchestrators. The September handoff needed local-only patches, dirty harness state, protected package identity, remote refs, and preserved device installs. Git alone did not contain all relevant work.

**Recommendation:** Maintain the existing durable checkpoint during work. Record source implemented, independently accepted, integrated, device tested, artifact built, artifact accepted, and published as distinct states.

Checkpoint at a meaningful change or completed work boundary. Start a fresh chat from that record when context becomes unreliable. The agent should prepare the handoff.

**Cost:** Brief ongoing recordkeeping. Do not create another registry or turn every tool call into a status update.

### 11. Branch and CI recommendations must target the actual candidate

**Evidence:** Main is frozen. The E09 workflow already removes the dormant hosted macOS integration job. The September 22 reconciliation preserved local-only branches and dirty work while matching the tracked branch pairs. Many worktrees remain, but their count alone proves no defect.

The inspected PR workflow has broad checks without path filters or cancellation. No actual spend was measured.

**Recommendation:** Reconcile policy on the intended active lineage. Consider conservative path filtering and cancellation for superseded PR runs where it cannot skip relevant code, assets, backend, or release checks. Keep shared-device jobs serialized.

Worktree retirement needs ownership, preserved evidence, and explicit cleanup authorization. Do not recommend mass deletion or resynchronization simply because inventory is large.

**Cost:** Incorrect filtering can miss regressions. Measure wasted runs before investing in elaborate CI optimization.

### 12. “Source of truth” includes proposals and research

**Evidence:** The master document consolidates 22 source documents as snapshots. It is not a live two-way sync. Its architecture research discusses mechanisms that do not match the inspected app dependencies and Firestore implementation. The copy log retains open proposals before later approvals.

**Recommendation:** Distinguish research, proposed decision, accepted behavior, implemented state, and verified state. Add status and supersession at the relevant section or current checkpoint. Keep unsupported research claims out of implementation requirements and marketing claims.

Do not treat an architectural research paper in the SSOT as proof that Pantas uses that architecture. Do not treat old PASS records as fresh results.

**Cost:** Editorial reconciliation. This does not require redesigning the app or rewriting the historical research.

### 13. Communication and content rules conflict by audience

**Evidence:** The question guide preserves authentic exam-register stems while the worker contract broadly asks for grade-5 stems. The lesson guide allows one em dash per paragraph while global instructions forbid them. Its fraction rule omits the later nested-fraction exception. Old authoring instructions say no images, despite later illustration work.

Other differences are legitimate: lesson analogies can help students, while Aedwon dislikes metaphors in assistant replies. Website About copy explicitly explains FSRS and algorithms, while those terms are banned in app UI.

**Recommendation:** Separate the audience rules and identify their scope. Keep approved product wording and factual constraints explicit. Reconcile genuine contradictions once.

**Cost:** Some wording decisions require Aedwon's preference. Do not simplify exam material automatically or spread the UI vocabulary ban to research, engineering, and approved website explanations.

### 14. Content completion can be mistaken for file completion

**Evidence:** The old lesson runbook tracks lesson-file existence. Content guides also require mathematical solving and source verification. These establish different kinds of completion.

**Recommendation:** Use existing content QA records to distinguish authored, validated, approved, and included in the shipped corpus. Preserve answer correctness, explanation quality, figure validity, source provenance, and seed consistency. File existence alone cannot close semantic review.

Run affected validation while authoring and aggregate checks at the content boundary. Reserve independent solving for content where a plausible wrong answer is hard to detect.

**Cost:** Semantic review remains real work. A simplicity skill should reduce unnecessary machinery, not replace educational quality assurance.

### 15. Web screenshot review needs a verified image-delivery path

**September 25 follow-up:** The relay worker instructions allow app-scoped image evidence and document uploading it with `gh issue comment --attach`. The locally installed GitHub CLI identifies itself as version 2.96.0, and its command help does not expose that attachment option. The relay's built-in visual-review action invokes Gemini through Antigravity, so that path is excluded by Aedwon's new routing decision.

The available GitHub connector includes a private-user-image download capability, but its presence here does not establish that every web worker has it or that the relay can currently deliver a captured image through it. Local command execution can support app capture when device access and task authorization permit it. Capture, image delivery, and model inspection are separate requirements.

**Decision after discussing feasibility:** Aedwon will perform visual checking and provide screenshots when he wants corroboration. Autonomous web screenshot review and image-delivery repair are not part of the chosen workflow. If this is revisited later, verify one authorized app screenshot reaches the web worker as an actual viewable image before claiming support. A filename or text output is not visual inspection.

No screenshot was taken, uploaded, or reviewed for this read-only capability check. The local rules now reflect Aedwon's selected manual visual-review process.

## Copy and communication proposal

This is a proposed organization, not a rewrite of approved copy.

| Audience | Preserve | Revisit |
|---|---|---|
| Replies to Aedwon | Plain direct language, short default, American spelling, no em dashes, honest pushback, detail in documents | Mechanical sentence rules that produce unnatural clipped prose; repeated offers to proceed during already-authorized work |
| App UI | Familiar terms, points/questions, honest states, no invented student figures, existing visual identity | Scope of technical-term bans and whether exceptions are ever useful |
| Question stems and passages | What the exam is testing, authentic register, correct terminology | Blanket grade-5 simplification that changes the task |
| Explanations and lessons | Simple explanations, valid math, subject-specific teaching structure | Resolve dash/fraction/image contradictions; preserve useful analogies where approved |
| Website and marketing | Approved claims and exact approved wording, audience-appropriate explanations | Apply app bans only when appropriate; distinguish current features from proposals |
| Specs, plans, and decisions | Technical precision, exact contracts, narrative decision history | Operational summaries should state current truth without deleting earlier entries |

Do not weaken the rule against invented student-facing figures. Engineering targets are allowed to be proposed and tested as targets. They should not become scientific claims about students.

Preserve the current Ink and Rule identity until Aedwon chooses to revisit it. Reusing the existing component kit directly reduces both visual inconsistency and redundant code.

## How the three levels should be evaluated in context

The following are discussion cases. They do not select a default or change approved scope.

| Pantas case | What a smaller complete solution can mean | What additional scope costs | Verification implication |
|---|---|---|---|
| Correct an approved UI phrase | Change the phrase consistently in its affected surface | Unrequested terminology or visual redesign would expand the task | Affected display/format check; no new architecture |
| Bounded UI behavior | Reuse existing components and routes to deliver the requested behavior | Additional states, customization, or new reusable infrastructure | Relevant interaction, navigation, and accessibility checks |
| Quiz loading | Remove demonstrated redundant loading while preserving selection, order, resume, and history | Prepared launch or caching can add invalidation, lifetime, memory, and recovery responsibilities | Actual device measurements and correctness evidence for the chosen mechanism |
| Content protection | Must first satisfy the agreed offline/commercial-protection goal; documentation alone is not a kept implementation | The approved balanced scope adds packaging, signatures, per-install keys, recovery, and release evidence; server-controlled provisioning changes product access and operations | Security-specific evidence remains necessary even if the implementation is compact |
| Beta operation | Natural use, light feedback, internal triage, clear blockers and closeout | Formal participant instrumentation and heavier operations | Existing simplified beta plan already makes a deliberate tradeoff |

For each real choice, the agent should first establish the current implementation, relevant accepted decisions, constraints, and unresolved risks. Then present concrete alternatives with the difference in product behavior, delivery work, validation, maintenance, and uncertainty.

A level is a shorthand for that comparison. It is not permission to omit correctness or add speculative infrastructure. “Balanced” is not a permanent maximum. “Hardened” is not permission to make offline access or sign-in changes without a product decision.

## Skills: what to retain and what to adapt

Keep Superpowers as the existing foundation while reconciling its Pantas-specific use. Do not stack every planning, execution, and review path. Its native and subagent execution modes are alternatives.

Two installed Superpowers copies expose the same names. The four compared workflow files are byte-identical today. That is a maintenance risk, not evidence that different versions caused the current inconsistency.

Ponytail's reuse-first reasoning and challenge to unnecessary requirements fit this audit. Its full/ultra behavior, shortest-diff emphasis, and generic verification prescription need adaptation. It also preserves requested requirements and important safeguards. Use its ideas as a short design/review check. Do not let it silently reduce accepted scope or override Pantas testing. [Ponytail source](https://github.com/DietrichGebert/ponytail/blob/main/skills/ponytail/SKILL.md).

The review-only variant offers a narrower complexity review. It does not replace correctness, security, or performance review. [Ponytail review source](https://github.com/DietrichGebert/ponytail/blob/main/skills/ponytail-review/SKILL.md).

Matt Pocock's current grill-me delegates to grilling. Upstream grilling groups independent questions into rounds; the installed local skill asks one question at a time. Choose the interaction deliberately. More questions help only when they resolve user-owned decisions after available facts have been inspected. [Grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md), [grilling](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md).

Proposed simplicity questions inside existing design and review:

1. Which requested outcome requires this mechanism?
2. What existing component or capability can satisfy it?
3. What can be omitted while still delivering the agreed behavior?
4. Which new state, dependency, or maintenance obligation does it add?
5. What evidence would justify adding it later?
6. Does the simplification preserve correctness, accessibility, data, and approved product behavior?

This should not introduce another approval stage. Skill installation remains undecided.

## Recommended order of improvement

| Order | Work | Benefit | Cost or constraint |
|---|---|---|---|
| 1 | Reconcile shared behavior and give both tools a reliable entry instruction | Directly addresses the user's first priority | Decide current authority and how standalone web chats load it |
| 2 | Define concrete complexity presentations using real project cases | Makes choice and cost understandable | Default remains open until the interview resolves it |
| 3 | Reconcile artifact detail, worker checks, model routing, and review ownership | Removes duplicate work while preserving incident-driven safeguards | Must align worker capability with remaining judgment |
| 4 | Separate current state from history in existing SSOT/registry | Reduces recovery and contradictory instructions | Requires concise updates at actual state changes |
| 5 | Resolve audience-specific copy rules | Prevents mechanically wrong writing | Preserve exact approved content and deliberate exceptions |
| 6 | Integrate a short simplicity check; evaluate whether a skill adds value | Challenges unnecessary complexity | Avoid permanent aggressive simplification modes |
| 7 | Pilot and measure before broad automation or CI changes | Tests whether the process is actually better | Needs representative authorized tasks and a baseline |

Use one small settled edit, one bounded feature, and one high-consequence change when those tasks naturally arise. Observe avoidable user interruptions, reopened settled decisions, context-recovery work, rejected worker output, verification reruns, and defects caught. Do not manufacture release work merely to test the process.

No arbitrary percentage saving is claimed. If the new process produces less paperwork but more repair work or lost decisions, it has failed.

## Interview order from here

Resolve dependencies in this order:

1. What a complexity choice must disclose about the full workload, using the actual balanced content-protection decision.
2. Which user decisions should be identical across Codex and web, and which execution details the agent should handle.
3. Spec approval now carries through agent planning, plan improvement, and implementation. Resolve the remaining external-action and release boundaries without adding a separate implementation-plan approval.
4. Which artifacts are useful to him and which exist only to support worker reliability.
5. Which existing checks feel disproportionate once their purpose and applicable scope are visible.
6. Assistant voice, student copy, exam language, and website exceptions.
7. Question cadence and a stopping rule for brainstorming.
8. Model/quota tradeoffs and skill adoption.
9. Complexity recommendation/default, tested against the agreed examples and costs.

Questions should stress-test these choices. They should not ask Aedwon to discover repository facts, reconstruct a lost chat, or defend an existing safeguard before the agent reads its rationale.

## Evidence links

### Shared and local rules

- [Codex global collaboration policy](/Users/aedwon/.codex/AGENTS.md)
- [Pantas build/collaboration rules](/Users/aedwon/Documents/Projects/Pantas/AGENTS.md)
- [Pantas shared workflow](/Users/aedwon/Documents/Projects/Pantas/WORKFLOW.md)
- [Provider startup text](/Users/aedwon/Documents/Projects/Pantas/docs/workflow/startup.md)
- [Worker contract](/Users/aedwon/Documents/Projects/Pantas/SUBAGENTS.md)
- [Execution resourcing decision](/Users/aedwon/Documents/Projects/Pantas/docs/superpowers/2026-08-03-execution-resourcing.md)
- [Execution pipeline and focused-check dispatch template](/Users/aedwon/Documents/Projects/Pantas/docs/superpowers/2026-08-04-execution-pipeline.md)
- [Web routing decision](/Users/aedwon/Documents/Projects/Pantas/docs/superpowers/decisions/2026-08-23-web-orchestrator-model-routing.md)
- [Actions conservation decision](/Users/aedwon/Documents/Projects/Pantas/docs/superpowers/decisions/2026-08-23-github-actions-minute-conservation.md)
- [September 15 recovery handoff](/Users/aedwon/Documents/Projects/Pantas-handoffs/2026-09-15/web-orchestrator-prompt-current.md)
- [Relay worker instructions](/Users/aedwon/Documents/Projects/chatgpt-terminal-relay/docs/CHATGPT_PROJECT_INSTRUCTIONS.md)

### Current workstream contracts and records

- [Ordered release sequence](/Users/aedwon/Documents/Projects/Pantas-wt-web-e09-security-performance-verification-r1/docs/superpowers/2026-09-07-internal-beta-ordered-execution-plan.md)
- [Content-protection and quiz execution spec](/Users/aedwon/Documents/Projects/Pantas-wt-web-e09-security-performance-verification-r1/docs/superpowers/specs/2026-09-07-e03-content-protection-quiz-launch-execution-spec.md)
- [Release execution plan](/Users/aedwon/Documents/Projects/Pantas-wt-web-e09-security-performance-verification-r1/docs/superpowers/plans/2026-09-07-e04-e14-content-protection-quiz-launch-release-plan.md)
- [Execution decisions](/Users/aedwon/Documents/Projects/Pantas-wt-web-e09-security-performance-verification-r1/docs/superpowers/decisions/2026-09-07-e03-content-protection-quiz-launch-decision-log.md)
- [Later quiz policy rulings](/Users/aedwon/Documents/Projects/Pantas-wt-web-e09-security-performance-verification-r1/docs/superpowers/decisions/2026-09-08-quiz-product-policy-rulings.md)
- [Release E2E design](/Users/aedwon/Documents/Projects/Pantas-wt-web-e09-security-performance-verification-r1/docs/superpowers/specs/2026-09-05-release-e2e-design.md)
- [Readiness SSOT](https://docs.google.com/document/d/1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4/edit?tab=t.yiktacyhvpnd)
- [Security and recorded balanced scope](https://docs.google.com/document/d/1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4/edit?tab=t.n718nq6hax4h)
- [Simplified beta operations](https://docs.google.com/document/d/1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4/edit?tab=t.ajvcv4a101hf)
- [Founder operations](https://docs.google.com/document/d/1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4/edit?tab=t.fko9xyf9fu4k)
- [Architecture research snapshot](https://docs.google.com/document/d/1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4/edit?tab=t.ug4felr7yae6)

### Writing and audit history

- [Question style guide](/Users/aedwon/Documents/Projects/Pantas/docs/content/question-style-guide.md)
- [Lesson style guide](/Users/aedwon/Documents/Projects/Pantas/docs/content/lesson-style-guide.md)
- [Lesson authoring runbook](/Users/aedwon/Documents/Projects/Pantas/docs/content/lesson-authoring-runbook.md)
- [Web copy scope](https://docs.google.com/document/d/1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4/edit?tab=t.mqygsrnsollx)
- [Approved website copy](https://docs.google.com/document/d/1LzdBQjPmRYXV1LSrLnK7F6_eadQi7cb1fj8mg7yuZg4/edit?tab=t.mw285tycvsoc)
- [This audit's chronological discussion](/Users/aedwon/Documents/Projects/Pantas/docs/superpowers/decisions/2026-09-24-development-workflow-audit-log.md)

## Work completed and still open

Completed: the process evidence review, direct web-project instruction inspection, correction of the initial workflow description, identification of rule conflicts and existing simplifications, and a prioritized recommendation set.

Open: current-status recordkeeping, remaining content-rule inconsistencies, and the stopping rule for brainstorming. After Aedwon explicitly lifts the current freeze, completed approved work may update main automatically once required checks, reviews, and applicable visual acceptance pass. Release publication remains separate. Completion cleanup is automatic only after verifying that work is merged into the agreed development branch, no unsaved work remains, and no active or paused task depends on the branch or worktree. Necessary working-branch creation is authorized for approved work, with a descriptive provider-neutral name and an explanation of need. The accepted core workflow is published. Complexity recommendations are case by case. Earlier open-default references above record the audit before that decision.

Accepted collaboration rules now live in the repository's shared workflow. Provider-specific project policy was removed, local globals defer to current main policy for Pantas, and old private memory was retired with a verified archive. The Pantas web project and a Pantas-only global web instruction now carry the same startup requirement. Installed Superpowers files were not edited. This documentation revision is authorized for main publication; application source and release state remain unchanged. Publication evidence belongs in the rollout log. A live engineering run under the new process is intentionally deferred until Aedwon resumes that work.
