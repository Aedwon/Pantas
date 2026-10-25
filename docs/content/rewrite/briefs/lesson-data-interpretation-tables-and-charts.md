# Brief: Reading Data from Tables and Charts

Lesson id: `lesson-data-interpretation-tables-and-charts`
Lesson path: `content/lessons/mathematics/data-interpretation/tables-and-charts.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dost-sei, pupcet, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-data-interpretation-tables-and-charts|B03|0`
- Rule: B03
- Fix size: large
- Quote:
> 3. The average monthly revenue is $50,000$ pesos.
- Problem: The mathematics lesson ends after Examples and omits the required "Speed Tricks & Shortcuts" and "Traps to Watch For" sections. Mnemonics are optional, but these two standard mathematics sections are required.
- Triage reason: Mathematics lesson lacks Speed Tricks & Shortcuts and Traps to Watch For.

### 2. `lesson-data-interpretation-tables-and-charts|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> A table shows quarterly office expenses in thousands of pesos: Quarter 1 is $12$, Quarter 2 is $15$, Quarter 3 is $18$, and Quarter 4 is $11$. What is the total expense for the year in pesos?
- Problem: The learning goal includes reading the meaning and scale of numerical categories, but this example supplies every supposed table value directly in prose. The student never has to locate a row-column value or otherwise read an actual table.
- Triage reason: The lesson is about reading tables, yet Example 1 shows no table and gives every value in the question text.

### 3. `lesson-data-interpretation-tables-and-charts|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> A bar chart shows production output for two factories. Factory A produced $450$ units and Factory B produced $320$ units. How many more units did Factory A produce than Factory B?
- Problem: The chart example repeats both plotted values in the question text, so the student can answer without reading the chart or its scale. This leaves the chart-reading part of the learning goal without a genuine worked scenario.
- Triage reason: The chart example restates both values in the stem, so the student never reads the chart or its scale.

### 4. `lesson-data-interpretation-tables-and-charts|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Candidates must accurately read quantities, compute totals, and evaluate differences between categories.
- Problem: This teaching sentence uses formal words such as "Candidates," "quantities," and "evaluate" instead of the very simple English expected for a Grade 5 reader.
- Triage reason: "Candidates," "quantities," and "evaluate" are too formal for a Grade 5 teaching sentence.

### 5. `lesson-data-interpretation-tables-and-charts|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> Calculate values directly from the tabulated figures without rounding unnecessarily.
- Problem: "Tabulated figures" and "rounding unnecessarily" are unnecessarily formal phrasing for the required Grade 5 teaching voice.
- Triage reason: "Tabulated figures" and "rounding unnecessarily" are too formal for Grade 5.

### 6. `lesson-data-interpretation-tables-and-charts|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> 1. **Read Column and Row Headers:** Understand what each row and column represents before calculating.
- Problem: This names the table-reading action but does not explain how row and column categories combine to identify a value, and no worked example demonstrates that process. The reading part of the lesson's own learning goal is therefore not fully taught.
- Triage reason: The lesson only names the header-reading step and never shows how a row and column pick out one value.

## CSE teaching to add

### 1. `mathematics-data-interpretation#10`
- Facet: Row/column headers and unit-scale reading
- Verdict: thin
- Tier: official
- Missing ideas:
  - Numerical quarter values and thousands scale are supplied in prose; no actual row/column intersection lookup is demonstrated.

### 2. `mathematics-data-interpretation#13`
- Facet: Arithmetic mean across time periods
- Verdict: thin
- Tier: official
- Missing ideas:
  - Mean procedure is first introduced in example; core states general exact arithmetic rather than the mean relation (L17 readiness).

### 3. `mathematics-data-interpretation#14`
- Facet: Decode graphical axis graduations and unstated values
- Verdict: absent
- Tier: official
- Missing ideas:
  - A chart marker supplies authoring data, but no current task requires decoding an unstated plotted value. Actual rendered/runtime display remains unknown.

### 4. `mathematics-data-interpretation#15`
- Facet: Interpret pie-chart parts of a whole
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Statistics Data Analysis teaches the separate angle/proportion relationship. No global absence or duplicate addition is recommended.

## Optional, fix only if editing that passage anyway

- `lesson-data-interpretation-tables-and-charts|B08|0` (B08): The numerals in "Quarter 1," "Quarter 2," "Quarter 3," and "Quarter 4" are numbers in prose but are not wrapped in inline math delimiters. Reason: "Quarter 1" is a label name, not a quantity, so wrapping the digit in math is pedantic.
- `lesson-data-interpretation-tables-and-charts|B08|1` (B08): The numerals in "Month 1," "Month 2," and "Month 3" are numbers in prose but are not wrapped in inline math delimiters. Reason: "Month 1" is a label name, not a quantity, so wrapping the digit in math is pedantic.
- `lesson-data-interpretation-tables-and-charts|L17|0` (L17): Example 3 uses the arithmetic-mean relation by summing the values and dividing by the number of periods, but Core Concept never introduces that formula or relation before the example uses it. Reason: Mean is basic Grade 5 arithmetic and Example 3 states the steps; this is not a new formula.
- `lesson-data-interpretation-tables-and-charts|L25|0` (L25): The student is asked for an average before the lesson has explained what an average or arithmetic mean means. With no prerequisite lesson identified, that necessary term is introduced too late. Reason: Average is a Grade 5 term and the solution says it is the mean; a short definition is optional.

## Figures

None.

## Rules cited

| B03 | Required content is present: outline sections, required figures | Blocker | Compare with the outline entry and figure needs | LSG: Section structure, Illustration placeholders |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
