# Brief: ustet source check, level 1

## Startup and boundary

Read current main AGENTS.md, WORKFLOW.md, SUBAGENTS.md and docs/workflow/startup.md, then the full approved audit spec, plan and October 4 decision log. Policy commit cb48097bedf15bec2cfbe4fb3aa7e957753b1727 was verified against live main with git ls-remote. Fetch is blocked by read-only git metadata; read policy with git show origin/main:path. Spec: docs/superpowers/specs/2026-10-03-exam-content-coverage-audit-design.md. Plan: docs/superpowers/plans/2026-10-04-exam-content-coverage-audit.md. Decisions: docs/superpowers/decisions/2026-10-01-question-explanations-log.md.

Level 1 only. No lesson body reading, overlap analysis, structure checks, standards checks, content changes, git mutations, computer control, or browser automation. Web search and source page reading allowed. You are not alone in the audit worktree. Preserve others' changes; own only your named output. No further subagents. Source policy and profile template come from current main.

## Assignment

Use gpt-6-luna, low effort. Check every claim in docs/content/audit/coverage-r1/requirements/ustet.md against its cited sources. Do not research new topics or alter requirements. Open every numbered source and confirm each cited claim, not just one claim per source. Record source access failures honestly. Official means organizer-owned; strong secondary needs a reputable publisher describing official material; unofficial reviewers/recollections/uploads are weak. DepEd is tier 2 curriculum support, not the organizer's exam blueprint. Read docs/content/source-policy.md and docs/content/exam-format-profiles.md from main.

Save a DRAFT check output before opening sources; update after each source group. Do not mark PASS while claims remain unchecked. Write exactly docs/content/audit/coverage-r1/source-checks/ustet.md. Include policy/input identity, source access table (source number, loads, label correct, corrected label, note), claim-problem table (exact claim, citation, issue, source-supported correction under 25 words), and RESULT: PASS or RESULT: FLAGS <count>. Unverifiable claims are flags unless already unknown or explicitly limited. Separate failed URL access from successful retained-document verification. Retained official DepEd PDFs, if needed, are under /private/tmp/claude-501/-Users-aedwon-Documents-Projects-Pantas/ffa15c93-3f59-4a5a-806e-6b31558edb9e/scratchpad/: Science-CG_with-tagged-sci-equipment_revised.pdf, Math-CG_with-tagged-math-equipment.pdf, SHS-Core_General-Math-CG.pdf. Verify actual covers/pages before using. Do not write intermediate extracts. Direct urllib with User-Agent Mozilla/5.0 sometimes succeeds after web403.

No em dashes. American spelling. Record actual dates and current-cycle limitations. Return a concise summary and unresolved flags after saving the one output.

## Interpretation of curriculum labels

Separate publication provenance from exam-scope confidence. "Official curriculum" identifies a government curriculum publication, not organizer-confirmed exam scope. Check the tier-2 curriculum claim against DepEd; flag any claim promoted to confirmed exam requirements without organizer evidence. Profile confidence cells must use official, strong secondary, weak, or unknown; limitations belong in the value/note. Record the input file SHA-256 so later changes cannot inherit stale verification. Keep the check bounded: one source fetch can support all its claims; do not repeatedly download a full guide per claim.
