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
   verified, leave it out rather than guess.

## Finding the next lessons

The master list is `tools/lesson_author/outline.json`
(subjects → topics → lessons, with slugs and required `sections`).
A lesson is DONE when its file exists at:

```
content/lessons/<subjectSlug>/<topicSlug>/<lessonSlug>.md
```

List missing lessons by comparing the outline against existing files.
Work in outline order (Mathematics first, then Science, Language
Proficiency, Reading Comprehension, Reasoning).

## Per-batch procedure

Work in batches of about 5 lessons per iteration:

1. Pick the next ~5 missing lessons from the outline.
2. Write each lesson per the style guide. If the outline entry has
   `sections`, cover each one (usually as `###` headings).
3. Verify each file before moving on:
   - frontmatter matches the style guide shape, slugs from outline.json;
   - no `\frac` (only `\dfrac`), no tables/links/code fences/`---` rules;
   - numbers in prose wrapped in `$...$`;
   - section titles exactly as specified; example/trap headings `### #N:`;
   - re-solve every example and confirm the stated answers.
4. Commit the batch: `git add content/lessons && git commit` with a plain
   message like `content(math): add geometry lessons 1-5`. No attribution.
5. Report progress (e.g. "72/141 done") and continue with the next batch.

## Subject-specific notes

- Language Proficiency & Reading Comprehension: pure English, no Taglish
  for now. Filipino-specific items in the outline (Nang vs. Ng, Sawikain
  at Tayutay) still explain the Filipino concepts — in simple English.
- Reasoning (figure series, paper folding, etc.): these are visual topics
  but images are NOT available yet. Describe patterns verbally and with
  simple notation, and mark every spot where a figure belongs with an
  `<!-- ILLUSTRATION: ... -->` placeholder (see the style guide). Write
  the best text-only version regardless — the text must stand alone.
- Math/Science: exam-level examples should reach real UPCAT/DOST
  difficulty by the last example.

## When everything is done

When all 141 lessons exist: run the verification sweep over ALL lesson
files (step 3 checks), fix anything found, commit, and report completion.
Stop any recurring authoring run when the authorized work is complete.
