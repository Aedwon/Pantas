# Sentence Completion: Split Plan (lap-b)

Policy: origin/main 14f99e7541aab6120b16ec3699439ad6a721e3cd.

Scope: sentence-completion.md only. Preserve source teaching text verbatim. No bridging sentences are needed. Cut at the existing core subsections; divide Grammar Clues at its time paragraphs. Examples and traps move whole and restart at #1.

## Part 1: Meaning Clues for Blanks
- File: `completion-meaning-clues.md`; id: `lesson-language-application-completion-meaning-clues`.
- One idea: Use sentence clues to check the meaning of every blank.
- Teaching-word estimate: 377.
- Core: opening and Meaning Clues.
- Original examples: 1, 2, 3, 12.
- Original traps: 2, 4.
- Speed Tricks paragraphs: 1, 3.
- Key point 1: Use signal words and connected ideas to choose a meaning.
- Key point 2: Check every blank in a pair or group.

## Part 2: Word Forms for Blanks
- File: `completion-word-forms.md`; id: `lesson-language-application-completion-word-forms`.
- One idea: Use the subject and the job of a blank to choose a word form.
- Teaching-word estimate: 384.
- Core: Grammar Clues: definitions, word form, agreement, and verb patterns.
- Original examples: 4, 5, 7.
- Original traps: 1.
- Speed Tricks paragraphs: none.
- Key point 1: Identify subjects, verbs, nouns, adjectives, and adverbs.
- Key point 2: Match the verb to its subject.
- Key point 3: Choose the form that follows a verb.

## Part 3: Past Time for Blanks
- File: `completion-past-time.md`; id: `lesson-language-application-completion-past-time`.
- One idea: Use the full timeline to choose a past verb form.
- Teaching-word estimate: 291.
- Core: Grammar Clues: simple past, progressive, and perfect.
- Original examples: 6.
- Original traps: 3.
- Speed Tricks paragraphs: 2.
- Key point 1: Distinguish finished, ongoing, and earlier past actions.

## Part 4: Articles, Prepositions, and Lists
- File: `completion-articles-and-lists.md`; id: `lesson-language-application-completion-articles-and-lists`.
- One idea: Use context, fixed phrases, and matching forms to fill blanks.
- Teaching-word estimate: 308.
- Core: Articles, Prepositions, and Lists.
- Original examples: 9, 10, 11.
- Original traps: 5.
- Speed Tricks paragraphs: none.
- Key point 1: Choose articles by sound and context.
- Key point 2: Use the preposition that fits the phrase and meaning.
- Key point 3: Match forms in lists and comparisons.

## Part 5: Natural Word Combinations
- File: `completion-natural-phrases.md`; id: `lesson-language-application-completion-natural-phrases`.
- One idea: Choose word combinations and idioms that fit the sentence.
- Teaching-word estimate: 150.
- Core: Natural Word Combinations.
- Original examples: 8, 13.
- Original traps: none.
- Speed Tricks paragraphs: 4.
- Key point 1: Recognize common word combinations.
- Key point 2: Read an idiom as a whole expression.

## Part 6: Pagkumpleto ng Pangungusap
- File: `pagkumpleto-ng-pangungusap.md`; id: `lesson-language-application-pagkumpleto-ng-pangungusap`.
- One idea: Piliin ang salitang akma sa kahulugan, panahon, at likas na gamit.
- Teaching-word estimate: 230.
- Core: Filipino: Pagkumpleto ng Pangungusap.
- Original examples: 14, 15, 16.
- Original traps: none.
- Speed Tricks paragraphs: none.
- Key point 1: Piliin ang anyong akma sa panahon ng kilos.
- Key point 2: Piliin ang pang-ugnay na akma sa ugnayan ng ideya.
- Key point 3: Piliin ang pariralang likas at akma sa kahulugan.

## Question map

| Question id | Part | Key point |
|---|---|---|
| q-language-application-sentence-completion-0001 | 1 | 1 |
| q-language-application-sentence-completion-0002 | 1 | 1 |
| q-language-application-sentence-completion-0003 | 1 | 2 |
| q-language-application-sentence-completion-0004 | 1 | 1 |
| q-language-application-sentence-completion-0005 | 1 | 1 |
| q-language-application-sentence-completion-0006 | 1 | 2 |
| q-language-application-sentence-completion-0007 | 1 | 1 |
| q-language-application-sentence-completion-0008 | 1 | 1 |
| q-language-application-sentence-completion-0009 | 1 | 2 |
| q-language-application-sentence-completion-0010 | 2 | 1 |
| q-language-application-sentence-completion-0011 | 1 | 1 |
| q-language-application-sentence-completion-0012 | 1 | 2 |
| q-language-application-sentence-completion-0013 | 1 | 1 |
| q-language-application-sentence-completion-0014 | 1 | 1 |
| q-language-application-sentence-completion-0015 | 1 | 2 |
| q-language-application-sentence-completion-0016 | 4 | 2 |
| q-language-application-sentence-completion-0017 | 5 | 1 |
| q-language-application-sentence-completion-0018 | 3 | 1 |
| q-language-application-sentence-completion-0019 | 1 | 2 |
| q-language-application-sentence-completion-0020 | 1 | 2 |

## Pool gaps

All questions share meta.exams: upcat, acet, dlsucet, ustet, dost-sei, cse-pro, cse-sub. The following gaps apply to every one of those exams. This map describes coverage, not approval.

- Part 1: no key-point gap; 16 mapped questions, computed quiz size 2.
- Part 2: key points 2 and 3 have no question; one mapped question, computed quiz size 3.
- Part 3: no key-point gap; one mapped question, computed quiz size 2, so one more is needed.
- Part 4: key points 1 and 3 have no question; one mapped question, computed quiz size 3.
- Part 5: key point 2 has no question; one mapped question, computed quiz size 2.
- Part 6: all three key points have no question; no mapped questions, computed quiz size 3.

## Outline and prerequisites

Insert six outline rows after the original row. Use ordering 2.01 through 2.06, after the original position 2. Topic-wide ordering is deferred. Move the original prerequisite list to part 1. Each later part requires the previous part. Redirect any dependencies on the original to part 6. The original has no outgoing dependents in the current prerequisite file.

## Verification

Checker-method teaching words (all whitespace-separated body tokens): parts 1 to 6: 426, 417, 330, 337, 166, 250. The estimates above exclude headings and count word tokens.

`lesson_checks.dart` was run from the code worktree against this content worktree. Exit 1: pool gaps remain until the separate re-tagging and lead approval jobs. No size or split-coverage findings name these parts. Original body unchanged; zero missing source paragraphs; question files unchanged. Em dash scan printed nothing.
