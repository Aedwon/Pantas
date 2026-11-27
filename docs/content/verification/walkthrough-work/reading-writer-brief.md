# Reading Comprehension writer brief (session 5, Nov 27, E-198)

Lead: Claude lesson lead. Policy read: `origin/main` `3fd9fdf0e`. This brief adds the Reading Comprehension rules to the lane's writer brief. Read these in full, in this order, and follow all of them:

1. `docs/content/verification/walkthrough-work/worker-rules.md` (hard limits, the standard, Filipino rules).
2. `docs/content/verification/walkthrough-work/writer-brief.md` (shape of each rewritten lesson, report format).
3. `docs/content/verification/walkthrough-work/pattern-checklist.md` (P1 to P5: the five defect classes the Grammar audits found). Apply them while you write, not afterward.
4. This file.

Shape reference: the approved grammar sample (`git show origin/tools/walkthrough-checks-r1:docs/content/walkthrough-samples/finding-subjects-and-matching-verbs.md`) and two passage-based lessons that passed their audit (Batch 2 Reasoning): `content/lessons/reasoning/verbal-logic/best-supported-conclusions.md` and `content/lessons/reasoning/verbal-logic/recognizing-bias.md`. Do not edit them.

## Scope: the 40 CSE Reading Comprehension lessons

All are in `content/lessons/reading-comprehension/comprehension-skills/`. They are the lessons linked from the 8 CSE-tagged question files in `content/questions/reading-comprehension/comprehension-skills/`. The large unsplit parents in the same folder (`main-idea.md`, `fact-vs-opinion.md`, `choosing-a-title.md` and the like, about 1,000 to 2,000 words) are retired or not in scope: never edit them. Edit only the files your task names.

## What a worked example looks like in a reading lesson

The chain is passage to clue to answer, not equation to value.

- Each example and each `:::check` and `:::try` has its own short ORIGINAL passage (2 to 6 sentences), in a blockquote or quotation marks. Never copy or lightly reword a quiz passage or stem. Never reuse a passage already used earlier in the same lesson (rule 5a): each check and try gets a new passage.
- One short lead-in names what we are finding and in which passage, for example: "Let's find the main idea of the passage about the school garden:".
- Each numbered step quotes the exact passage words it uses (the clue) and says in a few words what that clue shows. One clue per step. No narration beyond that.
- The chain ends at the finished answer as a full statement (for example: "Main idea: The garden club turned an empty lot into a food source for the canteen."), not at a letter or a choice number (P2).
- `**Check:**` tests the answer a different way in one line: every sentence still supports it; the title covers the whole passage, not one paragraph; swap in the wrong reading and show which passage words it contradicts.
- Multiple-choice examples: give 4 choices on separate lines with a blank line between them (worker rules, option lines). Wrong choices reflect real reading errors (too narrow, too broad, a detail, not stated, opposite tone). Exactly one defensible answer (P3).
- Headings are neutral (rule 5b): a heading never names the answer type the check asks for (for example, not "### A Persuasive Passage" above a check asking for the purpose).

## Truth and figures

- Passages are about neutral, everyday Philippine settings (school, barangay, market, family, local office). Do not state real-world facts, statistics, laws, dates or named real people as true unless you are certain they are correct. Prefer clearly made-up local situations.
- Any numbers in a passage, table or chart are sample data inside an exercise ("a class survey", "the canteen's sales log"), never presented as real statistics.
- A chart lesson (`visual-data-conclusions`) shows data as a small Markdown table. Do not invent an image.
- Never add an `<!-- ILLUSTRATION: ... -->` marker (lead, Nov 27 3 PM): main's content export fails on a marker with no drawn figure. If a figure would truly help, write `<!-- FIGURE WANTED: description -->`, which the export ignores. Keep any ILLUSTRATION marker already in a lesson exactly as it is.

## Rules carried from the Grammar and Vocabulary audits (do these from the start)

- Every worked example ends with `**Check:**`. A required Check is never cut to save words.
- Every check and try has exactly one defensible answer, and nothing printed above it (heading, list, lead-in) gives it away (P1, P3).
- Scope words on any rule that has exceptions ("usually", "often", "in most passages"): for example, the main idea is not always the first sentence; a signal word such as *however* usually, not always, marks a contrast (P4).
- When you state a rule twice (core, pair note, checklist), the statements agree (P5).
- Pairs: 2 or 3 per lesson, each matching a real non-correct choice of a question whose `lesson:` is this lesson, quoted exactly. Read the question's correct answer and explanation first so the mistake note names the real error.
- Pre-tap words: 150 to 900. Aim near the middle; the reader should not scroll through narration.
- Filipino lessons: simple Filipino, no Taglish in teaching prose, passages in Filipino, the first-use English gloss rule for hard terms (worker rules, Filipino section). KWF spelling (ng/nang, din/rin, raw/daw).

## Report

As in the writer brief (under 600 words), plus for each lesson: the number of checks and tries, and confirmation that every check and try uses its own new passage.
