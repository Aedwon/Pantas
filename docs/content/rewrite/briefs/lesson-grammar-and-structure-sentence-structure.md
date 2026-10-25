# Brief: Sentence Structure (Simple, Compound, Complex, Compound-Complex)

Lesson id: `lesson-grammar-and-structure-sentence-structure`
Lesson path: `content/lessons/language-proficiency/grammar-and-structure/sentence-structure.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-grammar-and-structure-sentence-structure|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> | **Simple** | 1 independent clause | The dog barked. |
- Problem: The numeral 1 appears in lesson prose outside inline math delimiters, contrary to the required math-notation rule.
- Triage reason: The numeral is outside inline math; removing the banned table fixes all four table findings.

### 2. `lesson-grammar-and-structure-sentence-structure|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> | **Compound** | 2+ independent clauses | The dog barked, and the cat ran. |
- Problem: The numeric expression 2+ appears outside inline math delimiters instead of being wrapped in dollar signs.
- Triage reason: The "2+" is outside inline math; removing the banned table fixes it.

### 3. `lesson-grammar-and-structure-sentence-structure|B08|2`
- Rule: B08
- Fix size: small
- Quote:
> | **Complex** | 1 independent + 1+ dependent clauses | Because the dog barked, the cat ran. |
- Problem: The numeric expressions 1 and 1+ appear outside inline math delimiters instead of being written as inline math.
- Triage reason: The numerals are outside inline math; removing the banned table fixes it.

### 4. `lesson-grammar-and-structure-sentence-structure|B08|3`
- Rule: B08
- Fix size: small
- Quote:
> | **Compound-complex** | 2+ independent + 1+ dependent clauses | Because the dog barked, the cat ran, and it hid under the bed. |
- Problem: The numeric expressions 2+ and 1+ appear outside inline math delimiters instead of being written as inline math.
- Triage reason: The numerals are outside inline math; removing the banned table fixes it.

### 5. `lesson-grammar-and-structure-sentence-structure|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Despite having a compound subject ("teacher and students") and a compound verb ("prepared and rehearsed"), there is only one clause overall (one complete thought, no dependent clause attached).
- Problem: This teaching sentence is long and dense, with several technical phrases and two parenthetical explanations packed into one sentence, which does not meet the very simple Grade 5 prose standard.
- Triage reason: The step packs two parenthetical explanations into one long sentence.

### 6. `lesson-grammar-and-structure-sentence-structure|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> A **simple sentence** has exactly one independent clause and no dependent clause.
- Problem: The student must already understand "clause," "independent clause," and "dependent clause" to use this definition, but there is no prerequisite lesson and these terms are not explained before this point.
- Triage reason: "Clause" is never defined before simple sentence is defined by it.

### 7. `lesson-grammar-and-structure-sentence-structure|L27|0`
- Rule: L27
- Fix size: small
- Quote:
> **Watch for subordinating words** (*although*, *because*, *since*, *when*, *if*, *while*) to spot a dependent clause quickly: their presence signals the sentence is at least complex, or compound-complex if multiple independent clauses are also present.
- Problem: The shortcut omits the condition that these words must actually be functioning as subordinating conjunctions introducing dependent clauses. Words such as "since" and "while" can have other grammatical functions, so students are told to rely on a marker mechanically.
- Triage reason: Words like since and while can be prepositions or adverbs, so the marker shortcut needs a condition.

## CSE teaching to add

### 1. `language-proficiency-grammar-and-structure#62`
- Facet: Filipino langkapan
- Verdict: thin
- Tier: official
- Missing ideas:
  - Explicit choice/formation method beyond the local statement or illustration.
  - A reasoned application of this facet, rather than a label or illustrative form.

### 2. `language-proficiency-grammar-and-structure#63`
- Facet: Filipino coordinating connectors in structure
- Verdict: thin
- Tier: official
- Missing ideas:
  - Explicit choice/formation method beyond the local statement or illustration.
  - A reasoned application of this facet, rather than a label or illustrative form.

### 3. `language-proficiency-grammar-and-structure#64`
- Facet: Filipino causal connectors in structure
- Verdict: thin
- Tier: official
- Missing ideas:
  - Explicit choice/formation method beyond the local statement or illustration.
  - A reasoned application of this facet, rather than a label or illustrative form.

### 4. `language-proficiency-grammar-and-structure#106`
- Facet: Filipino sequencing/narrative connector selection
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Connectors illustrate clause types; ordering events and narrative links are not taught.

## Optional, fix only if editing that passage anyway

- `lesson-grammar-and-structure-sentence-structure|B01|0` (B01): Mere presence of one of these words does not guarantee a dependent clause because some have other grammatical uses. Merriam-Webster lists "since" as a preposition, adverb, and conjunction, so the shortcut can misclassify a sentence: https://www.merriam-webster.com/thesaurus/since. Reason: Shortcut can misfire on 'since' as a preposition; one caveat line fixes it.
- `lesson-grammar-and-structure-sentence-structure|B01|1` (B01): The packet's Level 3 record says this exact Filipino illustration is uncertain because the second subject is omitted and says source-backed clarification is needed. B01 requires an unconfirmed claim to be left out rather than presented as definitive. Reason: Filipino clause example with an omitted subject; needs a Filipino source check before any change.
- `lesson-grammar-and-structure-sentence-structure|L03|0` (L03): "Classify" is used as an exam command but is never given the required one-line explanation of what the student must do. Reason: "Classify" is clear from the sentence given.
- `lesson-grammar-and-structure-sentence-structure|L08|0` (L08): The lesson begins teaching Filipino grammar terminology with English explanatory prose. The standards require lessons that teach Filipino grammar to use simple Filipino teaching prose. Reason: This is an English lesson with a short Filipino section; English framing is defensible but the guide wants Filipino.
- `lesson-grammar-and-structure-sentence-structure|L12|0` (L12): Beyond the allowed one-time English gloss "simple," the Filipino grammar teaching continues in English with "one complete thought" instead of using Filipino teaching prose. Reason: Same as L08: the gloss is fine and the English prose is the real question.
- `lesson-grammar-and-structure-sentence-structure|L18|0` (L18): The recorded learning goal includes recognizing the local Filipino structure labels and illustrations, but every worked example is English. There is no worked Filipino clause analysis for payak, tambalan, hugnayan, or langkapan. Reason: A Filipino worked analysis would help, but the lesson is English and the section is short.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L08 | Filipino lessons teach in simple Filipino at the Grade 5 standard | Major | Read as a Grade 5 student | LSG: Filipino-language lessons |
| L12 | No Taglish in Filipino teaching prose | Minor | Flag English words that are not the common term | LSG: Filipino-language lessons |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
