# Development workflow audit discussion

## September 24, 2026: requested outcome

Aedwon requested an exhaustive audit of interaction in Codex and web chat and the Pantas development process. He asked to revisit copywriting rules, reduce overengineering, investigate Ponytail or a similar skill, and ask clarifying questions relentlessly.

His wording:

> for a general idea, I want to streamline our current process, because right now, as strict as it is in terms of engineering, there are some parts that i think have been over-engineered to the point that i hate it. i also think on top of the superpowers skills, we should also add the ponytail skill or anything similar that prevents over-engineering.

## First priority

Options presented:

1. Too many questions, approvals, and documents. Recommended first because approval friction affects every task. Cost: engineering and writing rules would be examined afterward.
2. Solutions become too complicated. Cost: interaction differences would be examined afterward.
3. Codex and web chat behave inconsistently. Cost: approval and implementation simplification would be examined afterward.

Aedwon chose:

> Codex and web chat behave inconsistently

This selects the interview order. It does not approve a replacement workflow or a skill installation.

The next question requests a recent contrasting example and which response he preferred. It remains unanswered at this checkpoint.

## Complexity choice should also happen in web chat

Aedwon answered the example question:

> the one where it asks me to specify minimal balanced or hardened. i wish it also happens to the web chat

Keep the minimal/balanced/hardened choice and include it in the proposed shared workflow for web chat. Do not treat this choice itself as unwanted approval friction. The trigger, timing and meaning of each level still need clarification. No operational instruction has been changed.

Next question: should the choice appear only when scope has meaningful alternatives, or for every coding request? Recommendation: meaningful alternatives, with small fixes staying within their existing scope. Cost: the agent must judge when a choice is meaningful; asking every time gives more explicit control but adds interruptions.

## Trigger for the complexity choice

Presented choices:

1. Ask when there are meaningful scope choices, such as a new feature or substantial change. Small fixes follow the existing scope. Recommended. Cost: the agent judges whether the scope choice is significant.
2. Ask for every coding request, including small fixes. Cost: more interruptions for greater explicit control.

Aedwon answered:

> 1

The proposed workflow will ask in both tools when scope has meaningful alternatives. Small fixes do not require another complexity choice.

Next question: does minimal mean the smallest complete solution suitable to keep, or a temporary prototype? Recommendation: the smallest complete solution, with appropriate correctness checks and fewer optional features. Cost: slower than a disposable demonstration, but avoids treating unfinished work as a kept implementation. A prototype can be requested separately.

## Meaning of minimal

Presented choices:

1. The smallest complete solution we can keep, with fewer features and moving parts and appropriate correctness checks. Recommended. Cost: more time than a disposable demonstration.
2. A temporary prototype to explore the idea. Cost: it may need rebuilding before it can be kept.

Aedwon answered:

> 1

Minimal means a complete solution suitable to keep. Prototypes are a separate choice.

Next question: recommend the smallest sufficient option for the actual task, or retain balanced as the automatic recommendation? Recommendation: smallest sufficient, with concrete reasons for any additions. Cost: some useful optional features may be deferred and require another change later. All three options remain available when meaningful.

## Correction: assess the whole system before selecting a default

Aedwon responded:

> wait, let's not decide on that on a vacuum. the system was created with the other complexities in mind

The recommendation-default question was premature. The assistant was steering toward minimal before examining the purpose of balanced and hardened and their relationship to the existing development process. No default change was selected. Earlier preferences remain recorded, but they do not justify choosing minimal by default.

Next work: compare all three levels in context, including brainstorming, documentation, implementation, review, verification and maintenance. Start from a concrete part of Pantas that Aedwon considers overengineered. Trace why its complexity was introduced and what simplifying it would remove before recommending a policy change.

## Second correction: do the broader investigation first

Aedwon responded:

> this is exactly why i wanted this audit in the first place. you are making mistakes without considering the bigger picture

The assistant's next step still made Aedwon supply the diagnosis before the assistant had completed the wider evidence review. The correction applies to the audit method: inspect existing decisions and their dependencies first, then ask questions about choices that only Aedwon can make. Do not treat the prior two selections as approval for a new default or a general reduction in safeguards.

Aedwon subsequently instructed:

> please continue your work

This continues the workflow audit. It does not resume the separately paused release work or authorize policy implementation.

## Broader evidence review

The assistant reviewed the release sequence, the security scope, current readiness and beta records, founder operations, writing guides, actual web-project settings, historical execution economics, and current relay capabilities.

The evidence changes the initial interpretation:

- Detailed plans supported cheaper mechanical workers. Removing detail without changing worker expectations could increase errors.
- The execution pipeline already restricts implementors to focused checks. The standing worker contract was not reconciled with that optimization.
- The release gates protect different objects: source behavior, installed content, performance, integrated journeys, and the exact artifact. They cannot all be classified as repeated checking.
- The beta process was already simplified after Aedwon objected to its burden.
- The loaded Pantas web project had an empty Instructions field. Historical handoffs and account-level context are separate sources; the empty field does not establish their contents.
- The security SSOT records a balanced selection with time estimates for documentation only. Its implementation scope included packaging, keys, migrations, recovery, and release checks. Historical minimal meant documentation/encryption requirements, which differs from the keepable minimal solution defined in this audit.
- Writing rules genuinely conflict in some places and deliberately differ by audience in others.

The report was rewritten to include these findings and the reasons for preserving useful safeguards. No default has been chosen. No replacement policy has been approved.

## Audit scope includes product requirements

After the broader review, the assistant offered:

1. Examine both product commitments and process. Recommended. Cost: a longer discussion, with the opportunity to identify complexity that process changes alone cannot remove.
2. Preserve existing commitments and simplify their delivery. Cost: fewer opportunities to reduce engineering work, with a narrower discussion.

The example was first-use offline study and protection against copying the content collection. The assistant used unclear wording. Aedwon asked:

> what's "full first-launch offline content plus extraction resistance" please use simple words

The assistant explained that students could use lessons and questions on their first launch without internet, while the app would make copying the whole collection harder. The clarification restated the choice as reconsidering requirements too, or keeping them and simplifying planning, building, and testing.

Aedwon chose:

> okay let's go with your recommendation

The audit will examine both requirements and delivery process. This authorizes examining tradeoffs, not changing any product commitment, implementing a new workflow, or resuming paused engineering.

Next question tests the existing offline requirement: after installing Pantas, must a student be able to study immediately without internet, or is one initial content download acceptable? Recommendation: preserve immediate offline study for now, because required online provisioning would introduce download and recovery work. Its cost is keeping the collection in the installed app and retaining the limitations of protecting content stored on a student's device. A required first download changes the access promise and introduces network-dependent setup; it does not by itself prevent copying after download.

## Preserve immediate offline study

The assistant asked whether a student must be able to study immediately without internet after installing Pantas. Options were:

1. Yes. Recommended. Preserve the experience and avoid a required download step. Cost: the collection remains inside the app and protection against copying has limits.
2. One initial download is acceptable. Cost: internet before first study, download/interruption/recovery work, and no automatic prevention of copying afterward.

Aedwon answered:

> 1

Preserve immediate offline study after installation. This confirms the existing product requirement. It does not select a complexity default or approve a particular protection implementation.

Next question: is the current protection goal sufficient, meaning making easy copying of the whole collection harder while acknowledging that a skilled person may still recover it? Recommendation: retain that bounded goal. Cost: it does not promise complete prevention. The alternative is to investigate stronger protection, with added work and possible conflict with the offline requirement. This question concerns the product goal; it is not the release-specific residual-risk acceptance required later.

## Keep the bounded content-protection goal

The assistant presented:

1. Make easy copying harder. Recommended. Fits immediate offline use. Cost: someone determined and skilled may still copy the content.
2. Investigate stronger protection. Cost: additional work and possible conflict with immediate offline use. Tradeoffs would be examined before proposing changes.

Aedwon answered:

> 1

The two answers retain the current offline and content-protection goals. They do not establish that every mechanism in the implementation is necessary, approve its current state, or satisfy release-specific risk acceptance. The audit should examine simplification against these retained goals.

Next discussion moves to the shared Codex/web approval process. After Aedwon approves a feature's behavior and tradeoffs, should the agent prepare and review the technical implementation plan and begin authorized coding without a separate plan approval, or always bring the plan back? Recommendation: the agent handles the technical plan, with a return to Aedwon for material changes to behavior, scope, cost, risk, or maintenance. Cost: less direct control over technical details. Separate plan approval offers that control but adds an interruption and more technical reading. This is a proposed future workflow, not authorization to implement this audit or resume release work.

## Aedwon approves the spec, then agents plan and implement

Aedwon clarified:

> um, i should only approve the SPEC that is the basis of the agents making the implementation plan. cuz that's the pipeline right, we brainstorm a spec, then the implementation plan is made based on that spec. so at most I only read and approve the spec. the agent can make the implementation plan, self-improve (based on what the superpowers workflow require and other skills), then implement

The assistant had described approval as approving behavior and tradeoffs without clearly identifying the spec as the actual approved document. That obscured the pipeline Aedwon wants to retain.

Agreed sequence for both tools: brainstorm the spec together, obtain Aedwon's spec approval, then let the agent write, review, improve, and execute the implementation plan. Aedwon does not separately approve the plan. Spec approval should not be followed by a routine request to start the implementation already contemplated by that approval.

Plan improvement remains constrained by the approved spec. A change to the spec requires a specific revision decision. This does not decide commit, push, merge, publication, or release-risk permissions, and does not resume paused engineering.

Next question concerns how much technical material Aedwon should have to read in the spec. Recommendation: a plain-language approval section covering behavior, included/excluded scope, tradeoffs, and observable completion criteria, with necessary technical detail in a clearly separate agent section. Cost: the agent must keep the two sections consistent. The alternative is one detailed spec read end to end, which gives direct visibility into technical choices but costs more reading.

## Clarification: installed Superpowers adds a plan review gate

Aedwon asked:

> i'm correct in assuming that's the superpowers workflow right? or am i wrong

The assistant rechecked the installed Superpowers 6.4.1 brainstorming and writing-plans instructions. The sequence does match: brainstorming, spec approval, implementation plan, agent self-review, execution. However, the architectural path also explicitly requires human review of the written implementation plan before implementation. The writing-plans handoff preserves that review even when an execution method was already supplied.

Aedwon's spec-only approval preference is therefore a deliberate project exception to the installed skill, not an exact description of its default approval gates. His explicit instruction takes precedence over skill guidance. The assistant should have distinguished those facts when confirming the pipeline. The spec-format question remains unanswered; this clarification does not select a format.

## Plain-language approval section and executive prose

Aedwon chose the plain-language approval section and authorized the project exception to Superpowers:

> okay yes we can modify that part of the superpowers workflow. let's go with the plain-language section. again, please record my preference. i want direct, simple, clear, concise, and semantically dense prose. no metaphors, and other slop. no jargon or mention of functions, variables and whatnot. this should be treated as if an executive in a company were reading it, so don't bore me with unnecessary details

This selects the first format option. Aedwon reads and approves the plain-language section. Agents receive the necessary technical detail separately and must keep it consistent. The rejected alternative was reviewing one detailed document throughout, which offered more direct technical visibility at the cost of more reading.

The prose preference applies to replies and approval material for Aedwon. It requires useful information in few clear words, not awkward compression. Details belong only where they support understanding or a decision. Technical agent material can retain the precision required for implementation, but no consequential decision may be hidden there.

Implementation of these selected rules: the local project instructions now state the spec-only approval exception and the spec format. The local Codex global instructions also record the general writing preference. Installed Superpowers files were left intact; the project-level instruction is the override. No remote push, web-project settings change, or cloud-document update was made. The remaining audit decisions are still open.

## September 25, 2026: placement of the simplicity review

Aedwon instructed:

> continue

The assistant checked the local approval and prose changes. The next decision concerns where to check for unnecessary complexity. Proposed checks: reuse existing capabilities, remove work unsupported by an approved need, and preserve required correctness, security, recovery, and verification.

Options to discuss:

1. Include simplicity in the existing spec and plan reviews. Recommended. Cost: reviewers must assess both adequacy and unnecessary complexity, but no separate recurring review stage is added.
2. Add a dedicated simplicity review for every implementation plan. Cost: another review and more model usage; its narrower assignment may identify issues a broader review misses.

Both choices preserve the approved spec and require a specific user decision before reducing its requirements. Neither introduces another human approval stage. Skill installation or adaptation is still undecided.

## Integrate simplicity into existing reviews

Aedwon chose:

> go with 1. also is this how the ponytail skill operates?

The selected approach adds simplicity checks to existing spec and plan reviews. No separate recurring review or additional human approval is added. This preference was recorded in the local project instructions and audit. The alternative dedicated review remains unselected.

The assistant checked the primary Ponytail and Ponytail Review sources again. Ponytail is a persistent design/coding mode with three intensity settings, not only a review checklist. Its separate review skill examines unnecessary complexity without applying changes and excludes other review concerns. The agreed Pantas approach adopts relevant principles inside existing reviews; it does not install or activate either skill or adopt their generic testing and output prescriptions.

Sources: https://github.com/DietrichGebert/ponytail/blob/main/skills/ponytail/SKILL.md and https://github.com/DietrichGebert/ponytail/blob/main/skills/ponytail-review/SKILL.md.

## Confirm anti-overengineering intent and review student language

Aedwon confirmed:

> okay as long as we're implementing its anti-over-engineering principle. let's proceed

This accepts the integrated principles without requiring wholesale installation of Ponytail. The interview continues with student-writing rules, which were explicitly included in the original audit request.

The assistant reread the conflicting passages: the question style guide preserves authentic exam wording and uses simpler explanations, while the worker contract requires grade-5-simple language in question text. The next question asks which should govern.

1. Use realistic exam language in questions and simple language in explanations. Recommended. Preserves preparation for the actual exam and language skills being tested. Cost: some questions are harder to read.
2. Simplify question language too. Cost: easier reading can make the practice less representative of the exam, especially when vocabulary or comprehension is the skill being tested.

This is a choice about future authoring rules, not authorization to rewrite the existing corpus.

## Correction: lesson and quiz rules were already distinct

Aedwon corrected the assistant:

> the writing rules do not disagree as I instructed it.
>
> for the Lesson content, it should be in plain, simple English. I think the specific benchmark I stated was that it should be written simple enough that a Grade 5 student would understand.
>
> for the Quiz content (this includes Mock, normal quizzes, in-lesson quizzes), it should be realistic exam language. additionally the choices for these also have quality cognitive/misconception distractors

The assistant had presented an incorrectly recorded worker instruction as though Aedwon needed to choose between conflicting preferences. His intended distinction was already clear. This is a correction to the transcription and application of his rules, not a new tradeoff he must approve.

Lesson teaching content must be understandable to a Grade 5 student. Quiz questions and choices must use realistic target-exam language in all three named contexts. Wrong choices must be plausible and based on meaningful reasoning errors or misconceptions. Local project rules, worker guidance, and the lesson/question guides were aligned on this distinction. No content corpus edits or remote updates were made.

The existing question guide separately uses simple language for answer explanations. The next clarification asks whether Grade 5-level English should govern those explanations too. Recommendation: yes, so the question reflects the exam and the explanation remains easy to learn from. Cost: explaining difficult terms plainly can take more words. No new explanation-language preference has yet been inferred from this correction.

## Grade 5-level language for quiz explanations

Aedwon answered:

> yes on your reco

Quiz answer explanations must also use plain English understandable to a Grade 5 student. Questions and choices retain realistic exam language. Clear explanations may require more words to unpack difficult terms, and subject accuracy must be preserved. The local project rule and question guide now record this distinction. No existing questions, lessons, or explanations were rewritten.

The next question concerns the existing model-routing tradeoff: whether conserving Codex quota through Gemini execution remains preferable to keeping most implementation in Codex. The historical detailed-plan approach was built around cheaper workers; changing that execution preference affects how much planning and handoff work is worthwhile. Recommendation: retain Gemini for well-defined independent work and Codex for judgment and final acceptance. Cost: additional coordination and verification. The alternative uses Codex for most implementation, reducing cross-tool handoffs while consuming more Codex usage for that work. Neither choice implies that web and Codex should use different approval rules.

## Replace Gemini with ChatGPT web relay workers

Aedwon supplied a third direction:

> you can drop the Gemini subagents. I no longer have a Google AI Pro subscription. instead what we'll use is the ChatGPT Web Chat relay

The subscription assumption behind the assistant's recommendation was no longer valid. Retire Gemini and Antigravity delegation and quota questions. Use ChatGPT web workers through the existing relay as the replacement. The lead keeps coordination, design decisions, and final acceptance; required independent verification remains.

The assistant checked the existing relay worker contract and browser-dispatch runbook. They describe a ChatGPT web worker dispatcher with a durable registry, plus a separate local Mac command-execution path. The relay also exposes a Gemini-based visual-review action, which must not be used under the new direction.

The accepted operational decision is recorded in `2026-09-25-chatgpt-web-relay-routing.md`. Local project routing, worker roles, and the global Gemini recommendation were updated. Historical decisions remain intact. No Gemini tool was uninstalled, relay code was changed, service was activated, or worker was launched. No remote instructions were published.

This changes the basis for future plan detail: it should support the actual ChatGPT workers, not a retired Gemini tier. It does not establish that all existing detailed plans are unnecessary or change the approved spec's requirements.

## Focused checks during work, full required checks at feature completion

The assistant presented two approaches for ordinary changes:

1. Run focused checks during work, then all required checks on the completed feature. Recommended. Cost: some problems between parts may surface later, with less repeated verification.
2. Run all checks after every small task. Cost: more repeated work and longer waits, with the possibility of finding interactions earlier.

Aedwon answered:

> 1

The local project and worker instructions now consistently use focused checks during implementation and all required checks on the completed feature. The lead owns verification of the combined work. Fixes and changed material inputs still require relevant new evidence; approved release and high-risk contracts keep their explicit requirements.

The superseded worker rule required every full gate after every task. It also recorded approximately 25 analyzer issues and seven layering violations as August 3 expectations. Those historical counts were removed as standing pass criteria. Current outcomes must follow actual checks and any explicitly accepted exception for the relevant candidate. Applicable existing evidence can be inspected instead of repeating unchanged checks, consistent with the previously inspected Actions-conservation decision. Independent review is retained.

No product tests were run for these instruction-only edits. Document checks were run. No release gate was waived or paused work resumed.

## Visual-review choice remains pending: check web feasibility first

The assistant offered:

1. Agents inspect app screenshots for obvious defects first; Aedwon judges the design. Recommended. Cost: agent checks can still miss visual defects.
2. Aedwon keeps all visual checking. Cost: more manual work, with direct control.

Aedwon asked:

> for 1, can web chat through github relay do the screenshot checking?

The assistant checked the relay instructions and execution policy, the available GitHub private-image download tool description, and the installed GitHub CLI help. The relay documentation describes image capture and attachment, but the installed `gh issue comment` command has no documented `--attach` option. The built-in visual reviewer depends on Gemini and is unavailable under the new routing rule.

The supported pieces suggest a possible Mac capture to GitHub image to web inspection flow, but no end-to-end execution proof was established. The answer must distinguish feasibility from a working current integration. An image's filename or textual output does not demonstrate that the web worker inspected its pixels.

No live capture, upload, worker dispatch, relay implementation, or policy change was performed. Aedwon's visual-review selection remains pending until this capability question is answered.

## Aedwon retains visual checking

After the assistant explained that screenshot delivery to web chat was not verified and the existing reviewer depended on Gemini, Aedwon decided:

> hmm okay then I will personally do the visual checking on my end. I will send screenshots as needed if I need corroboration on my personal findings

Aedwon will do visual checking himself. Agents may review screenshots he supplies when he requests corroboration, with final visual judgment remaining his. The selected workflow does not require automated app capture or a relay image-delivery repair. This trades more personal checking for avoiding additional screenshot infrastructure.

Local project, design-partner, and worker instructions now state this distinction. Automated verification remains separate from visual acceptance. No screenshot was captured or uploaded, and no relay work was started.

## Automatic local saving and integration

The assistant offered these choices after work passes review and testing:

1. Automatically save it in project history and combine it with the agreed development version. Recommended. Fewer interruptions, but changes are incorporated before Aedwon inspects them.
2. Ask before taking those steps. More control, more approvals after the spec.

The question explicitly kept uploading changes to GitHub and publishing releases separate.

Aedwon answered:

> 1

This grants standing permission in Pantas for local commits of completed authorized work and lead integration into the agreed development branch after required review and verification pass. It removes the extra local completion prompt. It does not authorize committing unfinished audit work, merging into frozen main, resuming paused engineering, uploading to GitHub, publishing, branch creation or deletion, or history rewriting. Explicit task restrictions and unrelated changes remain protected. Workers still do not merge their own work.

The local project completion rule and Codex global policy now record the same scoped permission. The old unconditional local-main destination and contradictory commit-on-request-only line were replaced. No commit, merge, branch operation, or remote mutation was performed.

## Automatic GitHub working-branch uploads

The assistant asked how GitHub updates should work:

1. Automatically upload completed, verified work to its working branch. Recommended. Codex and web can access the same saved work with fewer interruptions. Uploads may trigger configured automated checks.
2. Ask before each upload. More control over what reaches GitHub, but more interruptions and possible delays between Codex and web.

The question explicitly kept updating main and publishing releases separate.

Aedwon answered:

> 1

Completed, reviewed, verified work may now be pushed automatically to its agreed GitHub working branch. This includes establishing the matching remote branch when uploading it. It does not permit force pushes, updates to main, unrelated branch operations or remote changes, publishing releases, or resuming paused work. The existing Actions-conservation guidance still applies. Broader branch setup is not decided by this choice.

The local project and global Pantas exception now record the upload permission. No upload, commit, merge, or branch operation was performed during this update. The audit remains unfinished, and its cross-tool distribution is not yet complete.

## Scale implementation-plan detail to the work

The assistant explained that earlier plans gave Gemini exact instructions to limit implementation mistakes. With ChatGPT workers replacing Gemini, it offered:

1. Scale detail to the work. Recommended. Ordinary tasks get clear steps, responsibilities, and checks. Sensitive or difficult work gets precise instructions. Less planning overhead, but workers exercise more judgment.
2. Keep fully prescribed plans for every task. Less worker discretion, but longer planning and more documents to maintain.

The assistant confirmed that Aedwon still approves only the spec under either option.

Aedwon answered:

> 1

The local project, design-partner, and worker instructions now require plan detail proportionate to the work. Ordinary plans do not need full implementation and test code. They still need concrete assignments, behavior, constraints, and verification. Exact interfaces remain necessary where separately assigned tasks depend on them. Sensitive or difficult work retains precise failure, recovery, and verification requirements.

Workers may resolve routine implementation details within the plan's boundaries. They cannot invent product decisions or silently depart from the plan. The lead resolves necessary technical revisions before affected implementation; material spec changes return to Aedwon. This decision does not remove agent plan review, required evidence, or existing explicit release obligations. It does not decide whether small changes may omit separate specs or plans.

The installed Superpowers writing-plans skill was checked: it requires code blocks for code steps and actual test code. The new Pantas exception deliberately replaces that blanket requirement. Installed skill files and historical plans were not edited. Only local instruction and audit documents changed; document validation passed.

## One repository policy for every provider

The assistant offered:

1. Use one shared set of project rules. Recommended. Both tools must read the current version before substantive work. Web needs an extra retrieval step and must flag when it cannot access the rules.
2. Keep complete instructions separately in Codex and web. Faster startup, but every policy change needs matching updates in both places. Differences can return.

It recommended short startup instructions pointing to the shared rules.

Aedwon answered:

> go 1. also, i don't know if this is true but there might be codex-only or claude-only (i.e. specific) configurations that cause divergence. i'd like to avoid that. if the web chat (or any other model provider like gemini, claude, etc for that matter) only has access to the github repo, then all of those must work the same way. delete any provider-specific rules so that work is consistent regardless of the harness or model used

The assistant checked repository entry files, hidden configuration surfaces, local provider global policies, and Claude's Pantas memory inventory. Claude and Gemini still had older global instructions. A project-only Claude settings file contained 193 permission entries. Claude's 55 local memory files included old branch, delegation, approval, and device-testing instructions. The assistant inspected the index and selected full notes; it did not revalidate every historical product statement.

Shared collaboration policy now lives in `WORKFLOW.md`, with the same technical and worker contracts for every provider. The provider-named entry files are identical pointers, not separate rule sets. The design rules formerly in `CLAUDE.md` moved into shared documentation. Roles are provider-neutral. The existing ChatGPT relay remains the currently selected execution arrangement, without assigning its provider special authority. No provider-specific plugin is required to understand the shared workflow.

The three local provider globals now exclude Pantas from their duplicated policies and point to the repository. The ignored Claude project permission file was removed. All 55 memory files were moved out of active loading, preserved under `/Users/aedwon/.codex/audit-backups/pantas-workflow-2026-09-25/claude-project-memory/`, and verified against their original SHA-256 hashes. A repository pointer replaces the active memory index. Original instruction and permission files were also backed up there. This preserves history without retaining private active rules. Other projects' global policies and account/tool/security configurations were not removed.

The shared startup instruction is prepared for any GitHub-capable provider. It requires the agreed workstream revision and stops dependent work if instructions or current context cannot be retrieved. These edits remain local. No GitHub upload, project-settings update, or fresh-provider execution proof has happened. Mandatory platform instructions and actual tool capabilities remain outside repository control; the assistant must report their limitations rather than claim identical execution.

An ancestor instruction file at `/Users/aedwon/AGENTS.md` was also found, backed up, and made to defer to repository policy for Pantas. Other projects retain their existing preferences. Existing nested worktrees were not rewritten. The worker contract's old collision-map reference was corrected from Part 4 to Part 9, and the false blanket claim that content and code work never conflict was replaced with the already-agreed shared-resource rule.

Validation confirmed the shared entry links, identical provider pointers, retained accepted workflow clauses, provider deferral, removal of the project permission override, and byte-for-byte preservation of all 55 archived memories. `git diff --check` passed after removing an extra final blank line. The work is ready for an audit-branch publication decision; the wider interview and fresh-provider verification remain open.

## Publish the workflow where every branch can use it

The assistant proposed a new `codex/shared-workflow` branch. Aedwon challenged both the extra branch and the provider-specific name:

> do you really need a branch for that? and why name it under codex if it should be provider and model agnostic

The assistant explained that the prefix was a harness default and acknowledged that a provider-neutral name would fit better. Aedwon then asked:

> remind me, why is the branch frozen?

The assistant checked the release records. The September 5 instruction explicitly prohibited modifying main during the separate release repair and verification program. Later plans retained the freeze. That history did not establish a technical need to exclude workflow documentation.

Aedwon identified the distribution problem:

> if you create a branch, will working on another existing branch resuming work after the fact use what we're working on right now? i just want it so that any work continued hereafter uses this newly audited workflow

The assistant acknowledged that publishing an isolated branch would not update existing work. It proposed publishing only workflow documentation on main, making main the policy source for every code branch, and requiring policy refresh in new and resumed tasks. It asked for that documentation-only exception to the freeze.

Aedwon responded:

> well then the answer is obvious. the reason i had the workflow updated is so that it would be used in the remaining and future engineering work. it would be very dumb to have used this time and effort and not utilize it in the end

This authorizes the proposed documentation-only main publication and startup configuration. The assistant's earlier isolated-branch proposal did not satisfy the purpose of the audit. Application code, release artifacts, and paused engineering remain unchanged. No new branch is needed for this rollout.

Policy now comes from current main independently of the assigned code branch. New tasks, resumed conversations, workers, and handoffs must reload it. Product specs, plans, source, and acceptance evidence still come from the agreed engineering workstream. Local provider startup pointers have been updated accordingly. Old branch copies are not merged just to obtain the policy.

Main publication includes only the audited instruction, content-guide, startup, and audit-history documents. Product tests and builds are not required for these documentation changes; document checks and the attribution gate apply. The publication commit uses the CI skip marker to avoid the main workflow's unrelated application builds and device jobs. This does not waive any product or release verification requirement.

The Pantas ChatGPT project instruction field was saved with the shared-main startup requirement. Standalone web chats also needed that pointer. Account customization was disabled and the custom instruction field was empty; customization was enabled and a Pantas-only repository pointer was saved. The UI confirmed “Custom instructions updated.” Nickname, occupation, personal details, memory settings, and other project behavior were not changed. Local Codex, Claude, Gemini, ancestor, and memory entry points now request current main policy on new or resumed work. No engineering conversation was started or resumed by this change.

## Computer control and usage cost

Aedwon instructed:

> could you please NOT use computer use? you're burning too many tokens/usage with that

> if you need something that needs computer use, then ask it from me. give me step-by-step instructions

The assistant stopped computer control. Shared policy now requires non-UI tools
where available and clear, numbered instructions for steps Aedwon must perform
himself. No further browser interaction was used for this rollout. The web startup
saves described above had already completed. Reopening those settings was omitted;
the project save was observed, and the account save showed its success confirmation.
