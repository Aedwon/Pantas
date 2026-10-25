# Brief: Visual Media (Comic Strips, Editorial Cartoons, Charts, and Graphs)

Lesson id: `lesson-text-types-visual-media`
Lesson path: `content/lessons/reading-comprehension/text-types/visual-media.md`

Tagged exams: acet, cse-professional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-text-types-visual-media|L05|0`
- Rule: L05
- Fix size: medium
- Quote:
> A three-panel comic shows a man carefully building an elaborate sandcastle, the completed castle, then a wave washing it away while he watches with a resigned expression.
- Problem: The worked examples give stimuli or data but no exam-style question stem asking the student what to identify, infer, rank, or interpret before the solution appears.
- Triage reason: The four examples describe a visual and give an answer, with no exam-style question.

### 2. `lesson-text-types-visual-media|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> By contrast, a **line chart** emphasizes position and change, so its vertical axis does not necessarily need to begin at zero.
- Problem: Line-chart interpretation is taught as a distinct quantitative case, but there is no worked line-chart example applying position, trend, or nonzero-axis interpretation.
- Triage reason: Line charts are taught as a distinct case but no worked line-chart example exists.

### 3. `lesson-text-types-visual-media|L19|0`
- Rule: L19
- Fix size: medium
- Quote:
> Because the bar lengths begin visually at 80, the displayed length ratio greatly exaggerates the actual magnitude ratio 85:81. Check the numerical scale instead of judging only from the apparent bar sizes.
- Problem: This worked solution is a prose paragraph rather than numbered steps, and it does not show the truncated bar lengths or ratio comparison with display equations.
- Triage reason: The truncated-axis solution is one paragraph; it needs numbered steps showing the bar lengths.

### 4. `lesson-text-types-visual-media|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> Monthly sales are January 50, February 70, March 60, and April 90 thousand pesos.
- Problem: The numbers 50, 70, 60, and 90 appear in prose outside inline math delimiters, contrary to the lesson math-notation rule.
- Triage reason: Sales figures are bare numbers in prose; the rule wraps prose numbers in math.

### 5. `lesson-text-types-visual-media|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> A bar chart starts at 80 and compares values 85 and 81.
- Problem: The numbers 80, 85, and 81 appear in prose outside inline math delimiters.
- Triage reason: The axis start and values are bare numbers in prose; the rule wraps them in math.

### 6. `lesson-text-types-visual-media|B08|2`
- Rule: B08
- Fix size: small
- Quote:
> Because the bar lengths begin visually at 80, the displayed length ratio greatly exaggerates the actual magnitude ratio 85:81. Check the numerical scale instead of judging only from the apparent bar sizes.
- Problem: The number 80 and the ratio 85:81 appear in prose outside inline math delimiters.
- Triage reason: The number 80 and the ratio are bare in prose; the rule wraps them in math.

### 7. `lesson-text-types-visual-media|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> The scale should match the analytical purpose and make changes interpretable without distortion.
- Problem: This teaching sentence uses abstract words such as analytical, interpretable, and distortion without simpler wording, making it harder than the Grade 5 reading standard.
- Triage reason: Analytical, interpretable and distortion are hard words in a Grade 5 lesson; simplify.

### 8. `lesson-text-types-visual-media|L22a|0`
- Rule: L22a
- Fix size: small
- Quote:
> A **bar chart** uses bar length to represent magnitude. Because length is measured from a baseline, truncating the quantitative axis can exaggerate differences; a zero baseline is normally appropriate when bar lengths encode absolute magnitudes. By contrast, a **line chart** emphasizes position and change, so its vertical axis does not necessarily need to begin at zero. The scale should match the analytical purpose and make changes interpretable without distortion.
- Problem: This paragraph contains four sentences, exceeding the required one-to-three-sentence paragraph limit.
- Triage reason: The bar and line chart paragraph has four sentences; the limit is three.

### 9. `lesson-text-types-visual-media|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> Editorial cartoons comment on public issues using techniques such as symbolism, caricature, analogy, labeling, juxtaposition, irony, and exaggeration.
- Problem: The lesson names analogy, juxtaposition, irony, and exaggeration as necessary cartoon-analysis terms but does not explain their meanings before students are expected to use the technique list.
- Triage reason: Analogy, juxtaposition, irony and exaggeration are listed with no meaning; add short definitions.

### 10. `lesson-text-types-visual-media|lead-add|0`
- Rule: lead-added
- Fix size: small
- Quote:
(no quote)
- Problem: Stray chat citation text ("citeturn...") left in the lesson in two places; delete it.
- Triage reason: Found during triage; not in the audit read.

## CSE teaching to add

### 1. `reading-comprehension-text-types#83`
- Facet: Rank magnitudes from bar-chart data
- Verdict: thin
- Tier: official
- Missing ideas:
  - Highest/second-highest supplied from the stated values; ranking procedure short and actual extraction from bars unverified.

### 2. `reading-comprehension-text-types#87`
- Facet: Line-chart trends and change interpretation
- Verdict: thin
- Tier: official
- Missing ideas:
  - Change/position function stated; no plotted trend or difference computation.

### 3. `reading-comprehension-text-types#88`
- Facet: Pie/angle/area chart interpretation
- Verdict: named-only
- Tier: official
- Missing ideas:
  - Angle/area listed as channels; no actual pie sector or area reading.

### 4. `reading-comprehension-text-types#90`
- Facet: Table reading and text-table transfer
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - No table here; existing Data Interpretation inventory is a reconciliation lead, not global absence.

## Optional, fix only if editing that passage anyway

- `lesson-text-types-visual-media|L01|0` (L01): The recorded goal requires keeping verbal inference distinct from actual visual extraction, but the comic is supplied entirely as prose and the lesson never explicitly teaches that distinction. Reason: The comic is a placeholder for a drawn figure; teaching the verbal versus visual reading distinction is nice but optional.
- `lesson-text-types-visual-media|L03|0` (L03): The exam verb "Interpret" is used as an instruction without the required one-line explanation of what the verb asks the student to do. Reason: Interpret is plain teaching language here and the next sentence already explains what to do.
- `lesson-text-types-visual-media|L18|1` (L18): Several distinct cartoon techniques are introduced, but the worked cartoon example covers only the labeled boulder scenario; caricature, analogy, juxtaposition, and irony receive no worked application. Reason: One cartoon example cannot show every technique; add a second example only if space allows.
- `lesson-text-types-visual-media|L26|0` (L26): Angle, area, and color are named as quantitative visual channels but the lesson never explains how those encodings represent values or how a student should read them. Reason: Angle, area and color are named but the lesson teaches only bar and line charts; trimming the list is enough.

## Figures

### `lesson-text-types-visual-media|B03|0` (B03)
- Quote:
> A three-panel comic shows a man carefully building an elaborate sandcastle, the completed castle, then a wave washing it away while he watches with a resigned expression.
- Problem: This visual-media worked example requires the comic itself as a load-bearing question figure, but the lesson provides only an HTML illustration placeholder rather than a completed figure.
- Triage reason: The placeholder is the expected state before E6; draw the comic in E6, not a rewrite item.

### `lesson-text-types-visual-media|B03|1` (B03)
- Quote:
> A cartoon shows a large boulder labeled "taxes" rolling toward a worried figure labeled "citizens."
- Problem: This visual-media worked example requires the editorial cartoon itself as a load-bearing question figure, but the lesson provides only an HTML illustration placeholder rather than a completed figure.
- Triage reason: The placeholder is the expected state before E6; draw the cartoon in E6, not a rewrite item.

## Rules cited

| B03 | Required content is present: outline sections, required figures | Blocker | Compare with the outline entry and figure needs | LSG: Section structure, Illustration placeholders |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L01 | A learning goal is recorded and the lesson serves it | Major | Find the goal in the audit records; compare with the content. Not checked while no goals are recorded (Aedwon, 25 October 2026) | LSG: Learning goal |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L22a | Paragraphs are one to three short sentences; bullet lists are sparing | Minor | Scan paragraphs | LSG: Formatting rules |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
