# Brief: Essays, Editorials, Opinion Pieces, and News Articles

Lesson id: `lesson-text-types-essays-editorials-articles`
Lesson path: `content/lessons/reading-comprehension/text-types/essays-editorials-articles.md`

Tagged exams: acet, cse-subprofessional, dcat, pupcet, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-text-types-essays-editorials-articles|L05|0`
- Rule: L05
- Fix size: medium
- Quote:
> "City officials announced yesterday that the new bridge project will be completed six months ahead of schedule, according to a press release issued Tuesday."
- Problem: The example supplies only an excerpt and then explains it; it does not give an exam-style question asking the student to classify or interpret the text. The other examples use the same non-question format.
- Triage reason: The four examples show an excerpt and explanation with no exam-style question.

### 2. `lesson-text-types-essays-editorials-articles|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> A passage can also blend reporting, analysis, and commentary. Use the evidence in the passage itself and any available label or byline.
- Problem: The lesson identifies blended texts and label/byline evidence as important classification cases, but no worked example requires the student to handle either case. The examples therefore do not cover the full set of distinct scenarios taught.
- Triage reason: Blended texts and label or byline evidence are taught, yet no example uses them.

### 3. `lesson-text-types-essays-editorials-articles|L19|0`
- Rule: L19
- Fix size: medium
- Quote:
> This sentence attributes a checkable claim to a source and does not itself advocate a position. In context, it fits **news reporting**.
- Problem: The worked answer is given as ordinary prose rather than a numbered solution. The same unnumbered answer format is used for all four examples, so the required stepwise solution format is absent.
- Triage reason: Examples give unnumbered prose answers; the guide requires a Solution label and numbered steps.

### 4. `lesson-text-types-essays-editorials-articles|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> A news report may say, "Officials estimate the policy will raise ₱2 million annually." An opinion piece may argue, "The policy unfairly burdens working families and should be repealed."
- Problem: The numeral 2 appears in prose as ₱2 outside inline math delimiters. The math-notation rule requires numbers in prose to be wrapped in `$...$`.
- Triage reason: The amount in pesos is a bare number in prose; the rule wraps prose numbers in math.

### 5. `lesson-text-types-essays-editorials-articles|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Text types overlap, so classify a passage from its **purpose, authorship, structure, evidence, and stance**, not from one signal word.
- Problem: This opening packs several abstract terms, including authorship and stance, into one sentence before explaining them. That is not very simple Grade 5 teaching prose.
- Triage reason: Authorship and stance are abstract words packed into one opening sentence; simplify.

### 6. `lesson-text-types-essays-editorials-articles|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> Reporting still involves editorial judgment about relevance, sourcing, framing, and context, so "objective" should not be understood as having no human choices at all.
- Problem: This sentence is long and concept-dense, with several abstract journalism terms and a qualified idea about objectivity. It exceeds the lesson's Grade 5 simplicity target.
- Triage reason: The sentence on objectivity is long and abstract for Grade 5; split and simplify.

### 7. `lesson-text-types-essays-editorials-articles|L22a|0`
- Rule: L22a
- Fix size: small
- Quote:
> A **news report/article** primarily reports verified information about events or issues. Many professional news organizations distinguish news reporting from opinion/commentary and expect the two to be clearly labeled. Reporting still involves editorial judgment about relevance, sourcing, framing, and context, so "objective" should not be understood as having no human choices at all. The key distinction is that straight reporting does not present the writer's personal advocacy as the article's main purpose.
- Problem: This paragraph contains four sentences, exceeding the rule's maximum of three sentences per paragraph.
- Triage reason: The news paragraph has four sentences; the limit is three.

### 8. `lesson-text-types-essays-editorials-articles|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> Use the evidence in the passage itself and any available label or byline.
- Problem: The lesson relies on a byline as a classification cue but never explains what a byline is before students are asked to use it.
- Triage reason: Byline is used as a cue and never explained.

### 9. `lesson-text-types-essays-editorials-articles|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> **Look at attribution and evidence.** Straight news commonly identifies sources for contested claims; opinion writing may also cite evidence but uses it to argue a stated position.
- Problem: Attribution is introduced as a necessary reading cue without being defined or briefly explained, leaving an important term unexplained.
- Triage reason: Attribution is used as a cue and never explained.

## CSE teaching to add

### 1. `reading-comprehension-text-types#14`
- Facet: Filipino informational/opinion text interpretation
- Verdict: absent
- Tier: official
- Missing ideas:
  - All examples/teaching here are English. Strategy transfer is not a demonstrated Filipino text application or global Filipino absence.

## Optional, fix only if editing that passage anyway

- `lesson-text-types-essays-editorials-articles|L03|0` (L03): The exam verb "classify" first appears here without a one-line explanation of what the student is being asked to do. Reason: Classify is used as ordinary teaching language, not as an exam command needing a gloss.
- `lesson-text-types-essays-editorials-articles|L18|0` (L18): Only the personal-essay case receives a worked example. Expository, analytical, and argumentative essay interpretation are distinct cases named by the lesson but are not worked. Reason: Essay subtypes are not usually separated by exams; one personal essay example is enough for the goal.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L22a | Paragraphs are one to three short sentences; bullet lists are sparing | Minor | Scan paragraphs | LSG: Formatting rules |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
