# Brief: SM Foundation scholarship examination requirements and format profile (Task 2)

## Startup

You are a Codex worker on the Pantas repository. Before anything else, read
`AGENTS.md`, `WORKFLOW.md`, and `SUBAGENTS.md` from main with
`git show origin/main:<file>` (run `git fetch origin main` first). Policy
commit at dispatch: `a8445c5ab328b2058c50eb5bf5181261d5dc80c6`. Follow them. Do
not use computer control or browser automation. Use web search and page reading
only.

## Objective

Establish what the SM Foundation college scholarship qualifying examination
currently requires and how its items look, from the best available sources, for
the current or most recent admission cycle. You report findings only. You do
not judge Pantas content.

## Read first

- `docs/content/source-policy.md` and `docs/content/exam-format-profiles.md` on
  main (`git show origin/main:<path>`). Follow the source hierarchy and
  confidence labels exactly.
- No internal benchmark exists for this exam. Start from the organizer.

## What to produce

Write exactly one file:
`docs/content/audit/coverage-r1/requirements/sm-foundation.md` in this worktree. Write
nothing else. Do not commit.

Sections, in order:

1. **Sources.** A numbered list: title, URL, publisher, access date
   (October 4, 2026), and confidence (official, strong secondary, weak). Prefer
   SM Foundation pages and documents. Unofficial reviewers, forums,
   and document-sharing uploads are weak.
2. **Subtests.** Each subtest's name and language(s), with the source numbers.
3. **Required topics and skills.** Per subtest, a list of topics, and under each
   topic the specific skills, each line ending with source numbers and a
   confidence. Separate four kinds clearly:
   - **Confirmed:** stated by an official or strong secondary source.
   - **Supported, curriculum:** in the DepEd curriculum all takers met by the
     test date (tier 2). Open the DepEd curriculum guides (K to 12 Science and
     Mathematics, Senior High School core subjects, and the language subjects)
     and use them for every topic they cover. Inferred, not an exam statement.
   - **Supported, weak:** reviewer or other tier 4 evidence only.
   - **Unknown:** areas you looked for and could not establish.
   Never present a guess as a requirement. An organizer's silence does not
   prove a topic is excluded.
4. **Format profile.** A table with the entries in `exam-format-profiles.md`:
   choices per item, item types per subtest, "none of the above" style, "all of
   the above" style, negative stems, language per subtest, timing that affects
   item length, subtest mix by proportion, topic weights. Also add rows for
   delivery (paper, computer, or other) and scoring (how scores are computed
   and any wrong-answer penalty). Each with value,
   source numbers, date checked, confidence. Subtest mix and topic weights only
   from a published or verified source; otherwise `unknown`. Never estimate.
5. **Version and cycle notes.** Any changes between recent cycles that affect
   content, with sources.
6. **Open questions.** Anything the lead must resolve.

## Rules

- Every claim cites at least one numbered source.
- If two sources conflict, report both and which wins under the hierarchy.
- Plain, precise prose. No em dashes. American spelling.
- Stop and write the reason in Open questions if a needed source cannot be
  reached, or if instructions conflict. Do not fill gaps with assumptions.

## Done when

The file exists with all six sections, every claim is sourced or marked
unknown, and you have written nothing else.

Other exams are researched by separate agents at the same time. Research only the SM Foundation scholarship examination. If this exam shares an organizer document with another exam (for example the two CSE levels), still report this exam's requirements separately.


## Current dispatch supplement, October 4, 2026

Use Codex gpt-6.1-sol at high effort. Read current main policy, startup text, the approved audit spec and plan, and October 4 decisions before research. `git fetch` is blocked by read-only metadata; the lead verified live main via `git ls-remote` and local origin/main matches `a8445c5ab328b2058c50eb5bf5181261d5dc80c6`. Recheck with read-only remote lookup if needed; do not mutate git metadata. This is level 1 only. Do not read or evaluate lesson bodies, overlap, lesson structure, lesson standards, or quizzes. No browser automation or computer control.

You are not alone in this worktree. You own exactly the requirement output named above. Preserve all other agents' work; do not edit shared outputs, briefs, status, content, or policy. This audit's explicit single-output assignments govern the shared audit worktree. Do not spawn further agents. Write evidence directly into your output, including the actual access outcome for each source. Open sources, do not rely on search snippets alone. Distinguish source publication date, admission cycle, actual tool clock/access date, and project date if they differ. Never claim a future cycle was verified when it is not in the accessible source. When DepEd guides represent track-specific preparation, label that limitation; do not say every taker studied a STEM-only subject.
