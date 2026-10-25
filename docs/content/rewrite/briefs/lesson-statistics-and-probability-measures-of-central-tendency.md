# Brief: Measures of Central Tendency (Mean, Median, Mode)

Lesson id: `lesson-statistics-and-probability-measures-of-central-tendency`
Lesson path: `content/lessons/mathematics/statistics-and-probability/measures-of-central-tendency.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-statistics-and-probability-measures-of-central-tendency|L18|2`
- Rule: L18
- Fix size: medium
- Quote:
> For $20,22,25,26,300$, the mean is $78.6$ while the median is $25$.
- Problem: The outlier case is supplied only as a finished result in the traps section. There is no worked example requiring the student to compute or justify which center better represents such a distribution.
- Triage reason: Choosing mean or median for skewed data is a learning goal, but only a finished result appears in the traps.

### 2. `lesson-statistics-and-probability-measures-of-central-tendency|L26|0`
- Rule: L26
- Fix size: medium
- Quote:
> A student earns $90$ in a $3$-unit subject, $85$ in a $2$-unit subject, and $80$ in a $5$-unit subject. Find the weighted mean grade.
- Problem: Weighted mean is part of the recorded learning goal, but Core Concept never explains what weighted averaging means or why larger weights give a value more influence. The worked procedure alone does not supply the required concept explanation before use.
- Triage reason: Core Concept never explains weighted averaging or why larger weights count more; add a short explanation.

### 3. `lesson-statistics-and-probability-measures-of-central-tendency|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> The median depends mainly on order, so an extreme value's exact magnitude has much less effect on it.
- Problem: This teaching sentence uses the abstract phrase "exact magnitude" and a relatively complex causal construction instead of the very simple Grade 5 English required by the lesson standard.
- Triage reason: "Exact magnitude" and the long causal sentence are too abstract for Grade 5.

### 4. `lesson-statistics-and-probability-measures-of-central-tendency|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> For a mean of nearby numbers, a convenient reference value can reduce arithmetic.
- Problem: The terms "convenient reference value" and "reduce arithmetic" are unnecessarily abstract for Grade 5 teaching prose and are not immediately restated in simpler language.
- Triage reason: "Convenient reference value" is abstract and not restated simply; explain the shortcut in plain words.

### 5. `lesson-statistics-and-probability-measures-of-central-tendency|L17|0`
- Rule: L17
- Fix size: small
- Quote:
> Multiply each value by its weight.
- Problem: The weighted-mean calculation rule is introduced for the first time inside Example #5. Core Concept gives only the ordinary mean formula and never introduces the weighted-mean formula or procedure before the example uses it.
- Triage reason: The weighted-mean method is taught only inside Example 5, not in Core Concept.

### 6. `lesson-statistics-and-probability-measures-of-central-tendency|L18|1`
- Rule: L18
- Fix size: small
- Quote:
> A set may have one mode or several modes when multiple values tie for the highest frequency.
- Problem: The lesson teaches tied highest frequencies and multiple modes, but no worked example covers a data set with two or more modes.
- Triage reason: The lesson says a set can have several modes, but no example shows one; extend Example 3.

### 7. `lesson-statistics-and-probability-measures-of-central-tendency|L22a|0`
- Rule: L22a
- Fix size: small
- Quote:
> Which measure best represents the center depends on the data and the purpose. The mean uses every numerical value and is sensitive to extreme values. The median depends mainly on order, so an extreme value's exact magnitude has much less effect on it. For a strongly skewed data set or one with extreme outliers, the median is often a better description of a typical center.
- Problem: This paragraph contains four sentences, exceeding the formatting rule that paragraphs contain one to three short sentences.
- Triage reason: This paragraph has four sentences, over the three-sentence limit; split or trim it.

### 8. `lesson-statistics-and-probability-measures-of-central-tendency|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> A student earns $90$ in a $3$-unit subject, $85$ in a $2$-unit subject, and $80$ in a $5$-unit subject. Find the weighted mean grade.
- Problem: The lesson reaches the weighted-mean example without first explaining what a weight means or what a weighted mean represents. There is no prerequisite lesson to supply that meaning.
- Triage reason: Weighted mean is used in Example 5 without saying what a weight means.

### 9. `lesson-statistics-and-probability-measures-of-central-tendency|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> If you choose $8$ for $4,7,8,10,11$, the deviations are $-4,-1,0,+2,+3$, which sum to $0$, so the mean is exactly $8$.
- Problem: The term "deviations" is used as necessary shortcut vocabulary without being defined or briefly explained before the student is expected to interpret the listed positive and negative values.
- Triage reason: "Deviations" is used without saying it means how far each value is from the chosen number.

## CSE teaching to add

### 1. `mathematics-statistics-and-probability#33` [weak tier: add only if it fits]
- Facet: Weighted mean
- Verdict: thin
- Tier: weak
- Missing ideas:
  - Weighting principle/procedure first introduced inside example, not Core Concept (L17 readiness).

## Optional, fix only if editing that passage anyway

- `lesson-statistics-and-probability-measures-of-central-tendency|L03|0` (L03): The exam verb "describe" appears without the required one-line explanation of what the student is expected to do. Reason: "Describe the mode" is clear from the question and its solution; a gloss is unnecessary.
- `lesson-statistics-and-probability-measures-of-central-tendency|L15|0` (L15): This begins a run of three consecutive Core Concept paragraphs opening with "The" (The mean, The median, The mode), which breaks the requirement to vary sentence openings and rhythm. Reason: Definitions naturally start with "The" and this is a minor rhythm issue with no learning cost.
- `lesson-statistics-and-probability-measures-of-central-tendency|L18|0` (L18): Odd-sized median selection is a distinct exam-relevant case taught in Core Concept, but there is no worked example that makes the student sort an odd-sized set and select its median. Reason: The odd-count median is a trivial case already stated in Core Concept; a separate example is optional.
- `lesson-statistics-and-probability-measures-of-central-tendency|L19|0` (L19): The verification computation is embedded inline inside the numbered step instead of being placed on its own display-math line as required for worked-solution computations. Reason: The check is a brief inline verification after the shown answer, not a skipped step.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L15 | No stock AI phrasing; varied sentence openings; a plainly varied summary | Minor | Search for the listed phrases; read openings | LSG: Emphasis and de-AI rules |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L22a | Paragraphs are one to three short sentences; bullet lists are sparing | Minor | Scan paragraphs | LSG: Formatting rules |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
