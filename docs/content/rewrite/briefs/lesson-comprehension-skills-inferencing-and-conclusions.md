# Brief: Inferencing and Drawing Conclusions

Lesson id: `lesson-comprehension-skills-inferencing-and-conclusions`
Lesson path: `content/lessons/reading-comprehension/comprehension-skills/inferencing-and-conclusions.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-comprehension-skills-inferencing-and-conclusions|L02|0`
- Rule: L02
- Fix size: medium
- Quote:
> An **inference** is a conclusion supported by evidence that is not simply stated as the answer in the same explicit form. It combines textual information with ordinary reasoning and, when appropriate, limited background knowledge needed to understand the text.
- Problem: This teaching prose is substantially above the Grade 5 simplicity target. Phrases such as "same explicit form," "textual information," and "limited background knowledge" are abstract, and the sentences carry several ideas at once.
- Triage reason: The definition of inference is abstract (explicit form, textual information); rewrite in simple words.

### 2. `lesson-comprehension-skills-inferencing-and-conclusions|L05|0`
- Rule: L05
- Fix size: medium
- Quote:
> Maria checked her watch for the third time in five minutes, glanced repeatedly at the entrance, and tapped her foot.
- Problem: Example #1 supplies only stimulus text and then immediately gives the inference. It never asks an exam-style question, so the learner does not practice authentic question wording. Examples #3 and #4 follow the same pattern.
- Triage reason: Examples 1, 3 and 4 show a text and an answer with no exam-style question.

### 3. `lesson-comprehension-skills-inferencing-and-conclusions|L19|0`
- Rule: L19
- Fix size: medium
- Quote:
> (B) is best supported. The timing and price movement support a negative market reaction. (A) invents a cause for the resignation; (C) makes a much stronger future claim than the evidence supports.
- Problem: The only example explicitly labeled with a Solution gives its reasoning as one prose paragraph rather than numbered solution steps. The other examples also move directly from stimulus text to an answer or explanation without the required numbered worked-solution structure.
- Triage reason: Solutions are prose, and most examples have no Solution label or numbered steps.

### 4. `lesson-comprehension-skills-inferencing-and-conclusions|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> The company's stock price fell 15% after the CEO's resignation was announced, and trading volume increased.
- Problem: The number 15% appears in prose outside inline math delimiters, contrary to the rule that every number in prose must be wrapped in $...$.
- Triage reason: The sample passage has 15% as a bare number; the rule wraps prose numbers in math.

### 5. `lesson-comprehension-skills-inferencing-and-conclusions|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> The kitchen light was still on at 3 a.m. Textbooks covered the table beside empty coffee cups, and a laptop showed an unfinished document.
- Problem: The number 3 appears in prose outside inline math delimiters, contrary to the rule that every number in prose must be wrapped in $...$.
- Triage reason: The sample passage has 3 a.m. as a bare number; the rule wraps prose numbers in math.

### 6. `lesson-comprehension-skills-inferencing-and-conclusions|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> The company's stock price fell 15% after the CEO's resignation was announced, and trading volume increased.
- Problem: The example introduces the specialized finance term "trading volume" without explaining it or pointing to prior teaching. A student who does not already know the term may need outside domain knowledge to understand all of the supplied evidence.
- Triage reason: Trading volume is unexplained and part of the evidence; gloss it or choose a simpler example.

## CSE teaching to add

### 1. `reading-comprehension-comprehension-skills#45`
- Facet: Analytical argument: identify indispensable assumptions
- Verdict: absent
- Tier: official
- Missing ideas:
  - Premise/conclusion structure, unstated assumptions and a method for testing necessity.

### 2. `reading-comprehension-comprehension-skills#59`
- Facet: Nonlinear/data reading: diagrams, maps, tables, graphs and visual-data conclusions
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Interpret actual nonlinear/visual information and connect it with prose or solve graph-data problems.

### 3. `reading-comprehension-comprehension-skills#71` [FILIPINO SECTION]
- Facet: Filipino: infer unstated main ideas, implications and justified judgments
- Verdict: absent
- Tier: official
- Missing ideas:
  - Unstated Filipino main-point/inference and evaluation examples.

## Optional, fix only if editing that passage anyway

None.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
