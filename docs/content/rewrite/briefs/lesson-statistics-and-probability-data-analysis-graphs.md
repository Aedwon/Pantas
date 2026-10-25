# Brief: Data Analysis and Graph Interpretation (Pie Charts, Bar Graphs, Scatter Plots)

Lesson id: `lesson-statistics-and-probability-data-analysis-graphs`
Lesson path: `content/lessons/mathematics/statistics-and-probability/data-analysis-graphs.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-statistics-and-probability-data-analysis-graphs|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> A scatter plot can still contain a nonlinear relationship even when its linear correlation is weak or zero, so inspect the shape instead of assuming that "no linear correlation" means "no relationship of any kind."
- Problem: This teaching sentence is too long and uses several advanced terms at once, including nonlinear relationship, linear correlation, and inspect, so it does not meet the very simple Grade 5 reading standard.
- Triage reason: This sentence is long and uses advanced words like nonlinear and linear correlation.

### 2. `lesson-statistics-and-probability-data-analysis-graphs|L05|0`
- Rule: L05
- Fix size: small
- Quote:
> The plot alone does not establish that more sleep **caused** the reduction in mistakes. Other variables may be involved, and causation requires stronger study design than an observed association.
- Problem: The example stem is adequately specified, but this solution explanation uses advanced wording such as reduction, variables, causation, study design, and observed association, so the solution does not return to simple Grade 5 language.
- Triage reason: The solution uses words like causation, variables, and study design, not simple Grade 5 English.

### 3. `lesson-statistics-and-probability-data-analysis-graphs|L17|1`
- Rule: L17
- Fix size: small
- Quote:
> Percent increase uses the starting value as the denominator.
- Problem: The percent-change method is first introduced inside Example 5 instead of Core Concept, even though the solution then uses change divided by the original value.
- Triage reason: Percent change is a formula first stated inside Example 5; add it to Core Concept or point to the earlier lesson.

### 4. `lesson-statistics-and-probability-data-analysis-graphs|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> A truncated axis can make visual differences look larger, but it is not automatically invalid; judge whether the scale and labels allow an accurate interpretation.
- Problem: This introduces the concept of a truncated axis without first explaining what makes an axis truncated. The later trap mentions a nonzero baseline, but the earlier teaching does not point forward to that explanation.
- Triage reason: "Truncated axis" is used without saying the axis does not start at zero; the meaning appears only in the traps.

## CSE teaching to add

### 1. `mathematics-statistics-and-probability#24`
- Facet: Extract numerical values from graphical scales/axes
- Verdict: thin
- Tier: official
- Missing ideas:
  - No application requires decoding an axis graduation or extracting an unstated plotted value. Figure markers do not verify actual display/runtime availability.

## Optional, fix only if editing that passage anyway

- `lesson-statistics-and-probability-data-analysis-graphs|L17|0` (L17): The mean calculation formula is first introduced inside Example 3. Core Concept does not first teach the mean as the sum of the values divided by the number of values. Reason: The mean is basic arithmetic and Example 3 shows the steps; it is not a new formula.
- `lesson-statistics-and-probability-data-analysis-graphs|L18|0` (L18): All bar values are supplied in the question text, so this example does not require the student to decode an axis scale or extract an unstated plotted value, leaving that recorded skill without a worked case. Reason: The figure is shown with the question; repeating values in the stem is acceptable for a bar graph.
- `lesson-statistics-and-probability-data-analysis-graphs|L18|1` (L18): The lesson explains truncated-axis risk only as teaching and a trap. It has no worked example comparing the same numerical values on different scales, so the visual-scale portion of the learning goal lacks a distinct worked scenario. Reason: The truncated-axis point is taught and trapped; a worked scale-comparison example is optional.
- `lesson-statistics-and-probability-data-analysis-graphs|L25|0` (L25): The term mean is needed in the question before the lesson has explained what a mean is or how it is found, and the packet identifies no prerequisite lesson that supplies that explanation. Reason: The mean is basic arithmetic and the solution computes it step by step.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
