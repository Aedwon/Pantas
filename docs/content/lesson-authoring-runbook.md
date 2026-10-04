# Lesson Authoring Runbook

How to generate the remaining lessons for the Pantas Learn tab. Applies to any
assigned content worker. Read `AGENTS.md`, `WORKFLOW.md`, and `SUBAGENTS.md` first.

## Ground rules

1. Read `docs/content/lesson-style-guide.md` first and follow it exactly.
2. NEVER add AI attribution anywhere, including commit messages.
   The repo enforces this (`tool/check_no_ai_attribution.dart`).
3. Accuracy beats speed. Solve every example yourself before writing the
   solution; re-check every arithmetic step. A reviewer app that teaches a
   wrong answer is worse than none.
4. Ground facts with web search. Math derivations you verify by solving,
   but FACTUAL claims must be checked against searched sources before
   writing when they are the kind of detail that gets misremembered:
   scientific constants and values, taxonomy and anatomy details, dates
   and names (astronomy/earth science history), Filipino grammar rules
   and examples (Nang vs. Ng, sawikain, tayutay), and any claim about
   specific exam formats (UPCAT/DOST/ACET coverage). Use the available search
   and page-reading tools, prefer authoritative sources, and if a claim cannot be
   verified, leave it out rather than guess. Follow `source-policy.md` for which
   source wins and record each checked fact in the round's source ledger.

## Finding the next lessons

The master list is `tools/lesson_author/outline.json`
(subjects → topics → lessons, with slugs and required `sections`).
A lesson has been authored when its file exists at:

```
content/lessons/<subjectSlug>/<topicSlug>/<lessonSlug>.md
```

File existence does not establish validation, approval, or inclusion in the shipped
content. Record those states separately using the existing content QA records.

List missing lessons by comparing the outline against existing files.
Work in outline order (Mathematics first, then Science, Language
Proficiency, Reading Comprehension, Reasoning).

## Per-batch procedure

Work in batches of about 5 lessons per iteration:

1. Pick the next ~5 missing lessons from the outline.
2. Record each lesson's learning goal per `source-policy.md`, then write the
   lesson per the style guide. If the outline entry has `sections`, cover each
   one (usually as `###` headings).
3. Verify each file before moving on:
   - frontmatter matches the style guide shape, slugs from outline.json;
   - top-level fractions use `\dfrac`; nested fractions may use `\frac`;
     no tables/links/code fences/`---` rules;
   - numbers in prose wrapped in `$...$`;
   - section titles exactly as specified; example/trap headings `### #N:`;
   - re-solve every example and confirm the stated answers;
   - every checked fact has a source ledger entry;
   - the lesson passes `content-checklist.md` with no blocker or major.
4. Commit the batch: `git add content/lessons && git commit` with a plain
   message like `content(math): add geometry lessons 1-5`. No attribution.
5. Report progress (e.g. "72/141 done") and continue with the next batch.

## Subject-specific notes

- Language Proficiency & Reading Comprehension: English lessons are pure
  English, no Taglish. Lessons that teach Filipino (Nang vs. Ng, Sawikain at
  Tayutay) follow the style guide's Filipino-language section: simple Filipino
  prose, English glosses for hard terms.
- Reasoning (figure series, paper folding, etc.): follow the assigned workstream's
  current illustration contract. Do not assume images are unavailable. Mark any
  missing required figure with an `<!-- ILLUSTRATION: ... -->` authoring placeholder
  and report it as incomplete. A placeholder or verbal description does not complete
  a question whose answer depends on seeing the figure.
- Math/Science: exam-level examples should reach real UPCAT/DOST
  difficulty by the last example.

## When everything is done

When the assigned lessons exist: run the verification sweep over all of them
(step 3 checks), fix anything found, commit, and report completion.
Stop any recurring authoring run when the authorized work is complete.
