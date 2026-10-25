# Brief: Noting Specific Details (Skimming and Scanning)

Lesson id: `lesson-comprehension-skills-noting-specific-details`
Lesson path: `content/lessons/reading-comprehension/comprehension-skills/noting-specific-details.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-comprehension-skills-noting-specific-details|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> A passage states: "The bridge, completed in 1932, spans 1,280 meters and was, at the time, the longest suspension bridge in the world." What year was the bridge completed?
- Problem: The prose contains the numbers 1932 and 1,280 outside inline math. B08 requires numbers in prose to be wrapped in $...$.
- Triage reason: Years and counts in the passage and solution are bare numbers; the rule wraps prose numbers in math.

### 2. `lesson-comprehension-skills-noting-specific-details|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> 3. The passage directly states "completed in 1932." The answer is 1932.
- Problem: The two uses of 1932 in prose are outside inline math. B08 requires prose numbers to be wrapped in $...$.
- Triage reason: Years and counts in the passage and solution are bare numbers; the rule wraps prose numbers in math.

### 3. `lesson-comprehension-skills-noting-specific-details|B08|2`
- Rule: B08
- Fix size: small
- Quote:
> A passage states: "The festival, historically held in March, was moved to April in 2015 due to scheduling conflicts, and has remained in April ever since." In what month is the festival currently held?
- Problem: The year 2015 appears in prose outside inline math. B08 requires numbers in prose to be wrapped in $...$.
- Triage reason: Years and counts in the passage and solution are bare numbers; the rule wraps prose numbers in math.

### 4. `lesson-comprehension-skills-noting-specific-details|B08|3`
- Rule: B08
- Fix size: small
- Quote:
> 1. The passage mentions both March (the historical month) and April (the month after the 2015 change).
- Problem: The year 2015 appears in prose outside inline math. B08 requires numbers in prose to be wrapped in $...$.
- Triage reason: Years and counts in the passage and solution are bare numbers; the rule wraps prose numbers in math.

### 5. `lesson-comprehension-skills-noting-specific-details|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> **Skimming** means reading quickly through a passage to get a general sense of its content and structure, without reading every word carefully. Skimming is useful before answering questions, to build a rough mental map of where different topics appear in the passage (introduction, examples, conclusion).
- Problem: This teaching uses several abstract phrases and long multi-clause sentences, including "general sense," "content and structure," and "rough mental map," so it is harder than the required Grade 5 simple-English style.
- Triage reason: Phrases like general sense and rough mental map are abstract; use shorter, plainer sentences.

### 6. `lesson-comprehension-skills-noting-specific-details|L27|0`
- Rule: L27
- Fix size: small
- Quote:
> The key skill for detail questions: identify the exact keyword or phrase from the question (a name, number, or unique term), then scan the passage for that keyword, rather than re-reading the entire passage from the beginning.
- Problem: This presents exact keyword matching as the key method but never states the important limitation that a question may paraphrase the passage. The shortcut can fail when the requested detail is expressed with different words.
- Triage reason: Exams often paraphrase the passage, so keyword matching can fail; the lesson never says so.

## CSE teaching to add

### 1. `reading-comprehension-comprehension-skills#37`
- Facet: English: actual long-passage skimming/scanning under varied wording
- Verdict: thin
- Tier: curriculum
- Missing ideas:
  - Full long passage to skim, locating a section from actual text and matching paraphrased requests.

### 2. `reading-comprehension-comprehension-skills#70` [FILIPINO SECTION]
- Facet: Filipino: locate specific details and explain read text
- Verdict: absent
- Tier: official
- Missing ideas:
  - Filipino detail retrieval and explanation examples.

## Optional, fix only if editing that passage anyway

- `lesson-comprehension-skills-noting-specific-details|B01|0` (B01): This hard-to-remember historical premise is not reliable as written. The 1,280-meter span and former world-record description match the Golden Gate Bridge, but the Golden Gate Bridge District says it opened in 1937 and set the 1,280-meter span record then, not in 1932. Source: https://www.goldengate.org/exhibits/facts-and-figures-about-the-bridge/ Reason: A made-up passage need not be true, but it copies Golden Gate figures with a wrong year; change the details.
- `lesson-comprehension-skills-noting-specific-details|L05|0` (L05): This is a meta-description of a passage rather than an authentic reading-comprehension passage or exam-style item. It supplies each paragraph's topic instead of making the student skim actual text to discover the structure. Reason: This is a strategy example, not an exam item; it works as written, though real paragraph openings would be better.
- `lesson-comprehension-skills-noting-specific-details|L18|0` (L18): The only worked example for using a passage overview gives the paragraph topics directly instead of providing a longer passage to skim. That leaves the passage-overview part of the learning goal without a worked example at realistic target-exam difficulty. Reason: Giving paragraph topics is a simplification; real first sentences to skim would help but the skill is still shown.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
