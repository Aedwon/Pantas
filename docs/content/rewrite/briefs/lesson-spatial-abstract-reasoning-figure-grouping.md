# Brief: Figure Grouping (Identifying the Odd-One-Out)

Lesson id: `lesson-spatial-abstract-reasoning-figure-grouping`
Lesson path: `content/lessons/reasoning/spatial-abstract-reasoning/figure-grouping.md`

Tagged exams: acet, dcat, sm-foundation, cse-professional

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-spatial-abstract-reasoning-figure-grouping|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> **Curved vs. straight lines**: are most figures made entirely of straight lines (or entirely of curves), while one mixes both or uses the opposite type?
- Problem: Curve-versus-straight grouping is taught as a common shared-feature category but has no worked example, so a distinct exam-relevant scenario named by the lesson is uncovered.
- Triage reason: Curved versus straight is a listed category with no worked example; one example would cover it.

### 2. `lesson-spatial-abstract-reasoning-figure-grouping|B01|0`
- Rule: B01
- Fix size: small
- Quote:
> The fourth figure's lines do not pass through the center, creating an uneven split (an odd number of regions, $3$), breaking the "lines through center create even regions" pattern.
- Problem: This states a false causal rule. Two lines that miss the center do not necessarily create an odd number of regions; two off-center chords can intersect and create four regions. The specific prompt gives three regions, but being off-center alone does not imply that result.
- Triage reason: Off-center lines do not always make an odd number of regions; state the rule for this figure only.

### 3. `lesson-spatial-abstract-reasoning-figure-grouping|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Since the rule is not stated, approach this systematically by checking figures against a checklist of common shared-feature categories:
- Problem: The sentence uses abstract wording such as "systematically" and "shared-feature categories" that is harder than the required Grade 5 teaching voice.
- Triage reason: Systematically and shared-feature categories are above Grade 5; a plain lead-in is easy.

### 4. `lesson-spatial-abstract-reasoning-figure-grouping|L27|1`
- Rule: L27
- Fix size: small
- Quote:
> The fourth figure's lines do not pass through the center, creating an uneven split (an odd number of regions, $3$), breaking the "lines through center create even regions" pattern.
- Problem: The explanation omits the condition that the exact arrangement of the off-center lines matters; missing the center by itself does not guarantee three or any odd number of regions.
- Triage reason: Off-center lines do not always give an odd count; the real rule is the region count, so the reasoning is wrong.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-spatial-abstract-reasoning-figure-grouping|L17|0` (L17): This reasoning lesson includes a Speed Tricks & Shortcuts section, but the subject-fit rule requires the reduced Reasoning layout of Core Concept, Examples, and Traps to Watch For, dropping Speed Tricks. Reason: The checklist is strategy more than a shortcut, but keeping it harms no student.
- `lesson-spatial-abstract-reasoning-figure-grouping|L18|1` (L18): The lesson warns about misleading size or orientation but gives no worked example where visual salience conflicts with the real grouping rule, leaving this stated edge case unpracticed. Reason: The trap is explained in words; a separate worked example is optional.
- `lesson-spatial-abstract-reasoning-figure-grouping|L18|2` (L18): The examples only confirm rules that work immediately. None shows a candidate rule failing and being revised, or two plausible all-member rules competing, so validation is not practiced at target difficulty. Reason: Showing a rule fail and be revised is nice to have but not required coverage.
- `lesson-spatial-abstract-reasoning-figure-grouping|L22a|0` (L22a): This paragraph uses two long, clause-heavy sentences instead of the required short teaching sentences, making it denser than the formatting rule allows. Reason: The opening paragraph is two sentences with a semicolon; readable, so a split is optional.
- `lesson-spatial-abstract-reasoning-figure-grouping|L23|0` (L23): The figure specification is not specific enough for the symmetry question: it does not require an equilateral triangle or a blob with no reflection axis, so an artist or renderer could draw a figure that does not support the intended answer. Reason: The triangle and blob forms are named; stating an equilateral triangle in the note is cheap but minor.
- `lesson-spatial-abstract-reasoning-figure-grouping|L25|0` (L25): The term "orientation" is needed to understand this trap but is never explained, and there is no prerequisite lesson that supplies its meaning. Reason: Orientation is a common word; a few words such as which way it points would help but are optional.
- `lesson-spatial-abstract-reasoning-figure-grouping|L27|0` (L27): The lesson presents the method as if one clear rule will always isolate one figure, but it never explains the limitation that more than one plausible grouping rule can fit the same set or make a question underdetermined. Reason: The lesson already says exactly one figure must not fit; the multiple-rules caveat is optional.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L22a | Paragraphs are one to three short sentences; bullet lists are sparing | Minor | Scan paragraphs | LSG: Formatting rules |
| L23 | Each placeholder is one specific line an artist could draw from; the prose teaches without the image except where the figure is the question (missing required figures fall under B03) | Major | Read each placeholder | LSG: Illustration placeholders |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
