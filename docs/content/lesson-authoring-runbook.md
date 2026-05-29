# Lesson Authoring Runbook

How to generate the remaining lessons for the Pantas Learn tab. Written
for a Claude Code session working autonomously (e.g. via /loop).

## Ground rules

1. Read `docs/content/lesson-style-guide.md` first and follow it exactly.
2. NEVER add AI/Claude attribution anywhere — commit messages included.
   The repo enforces this (`tool/check_no_ai_attribution.dart`).
3. Accuracy beats speed. Solve every example yourself before writing the
   solution; re-check every arithmetic step. A reviewer app that teaches a
   wrong answer is worse than none.

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
  simple notation; where a lesson truly cannot teach without a figure,
  write the best text-only version and add a single HTML comment at the
  end of the body: `<!-- TODO: needs figures -->`.
- Math/Science: exam-level examples should reach real UPCAT/DOST
  difficulty by the last example.

## When everything is done

When all 141 lessons exist: run the verification sweep over ALL lesson
files (step 3 checks), fix anything found, commit, and report completion.
If running under /loop, stop the loop.
