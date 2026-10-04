# Brief: USTET requirements and format profile (Task 2)

## Startup

You are a Codex worker on the Pantas repository. Before anything else, read
`AGENTS.md`, `WORKFLOW.md`, and `SUBAGENTS.md` from main with
`git show origin/main:<file>` (run `git fetch origin main` first). Policy
commit at dispatch: `3a84a5d614830972b60ba67efddc26f891eeac4f`. Follow them. Do
not use computer control or browser automation. Use web search and page reading
only.

## Objective

Establish what the University of Santo Tomas Entrance Test (USTET)
currently requires and how its items look, from the best available sources, for
the current or most recent admission cycle. You report findings only. You do
not judge Pantas content.

## Read first

- `docs/content/source-policy.md` and `docs/content/exam-format-profiles.md` on
  main (`git show origin/main:<path>`). Follow the source hierarchy and
  confidence labels exactly.
- Lead only, not evidence: `docs/content/audit/benchmarks/ustet.md` in
  `/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2`. It is an older
  internal summary. Use it to know where to look. Never cite it as a source.

## What to produce

Write exactly one file:
`docs/content/audit/coverage-r1/requirements/ustet.md` in this worktree. Write
nothing else. Do not commit.

Sections, in order:

1. **Sources.** A numbered list: title, URL, publisher, access date
   (October 4, 2026), and confidence (official, strong secondary, weak). Prefer
   University of Santo Tomas Office for Admissions pages and documents. Unofficial reviewers, forums,
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

Other exams are researched by separate agents at the same time. Research only the USTET. If this exam shares an organizer document with another exam (for example the two CSE levels), still report this exam's requirements separately.
