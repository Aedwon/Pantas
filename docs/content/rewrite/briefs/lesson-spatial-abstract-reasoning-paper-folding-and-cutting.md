# Brief: Paper Folding and Cutting Rules

Lesson id: `lesson-spatial-abstract-reasoning-paper-folding-and-cutting`
Lesson path: `content/lessons/reasoning/spatial-abstract-reasoning/paper-folding-and-cutting.md`

Tagged exams: acet, cse-professional

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-spatial-abstract-reasoning-paper-folding-and-cutting|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> The layers have all been cut, but the copies **coincide or connect at the center** rather than becoming four separated holes.
- Problem: The word "coincide" is unnecessarily difficult for Grade 5 teaching prose and is not explained in simple language at this point. A common word such as "overlap" would be easier to read.
- Triage reason: Coincide is a rare word and is used repeatedly; use overlap or land on the same spot.

### 2. `lesson-spatial-abstract-reasoning-paper-folding-and-cutting|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> Reflecting the cut across either fold maps it onto itself at the intersection. The layers have all been cut, but the copies **coincide or connect at the center** rather than becoming four separated holes.
- Problem: Example #3 gives its worked solution as a prose paragraph instead of the required numbered solution steps.
- Triage reason: Example 3 has two or more reasoning steps and is vague; number them and state the single center opening.

### 3. `lesson-spatial-abstract-reasoning-paper-folding-and-cutting|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> reflect the cut across each fold line.
- Problem: Reflection is the central operation students must perform, but the lesson never explains what reflecting across a fold line means geometrically, such as placing the copy on the opposite side at the same distance from the fold.
- Triage reason: Reflecting across a fold line is the core move but never explained; add a mirror copy at equal distance.

### 4. `lesson-spatial-abstract-reasoning-paper-folding-and-cutting|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> Reflect the cut across the last fold first, then the previous fold, until the sheet is fully opened.
- Problem: This tells students the order in which to reflect cuts but not how the reflection changes a cut's position and orientation. The core method is therefore named procedurally without fully explaining how it works.
- Triage reason: The order is given but not how a reflection moves a cut; the same sentence fixes this and L25.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-spatial-abstract-reasoning-paper-folding-and-cutting|B01|0` (B01): The Example #4 figure label says the eight reflected holes are evenly spaced. Symmetry from exact half-folds does not guarantee equal spacing; the spacing depends on the punch location within the folded packet. Reason: Equal spacing depends on the punch spot; fix the label only if the drawn punch does not give equal spacing.
- `lesson-spatial-abstract-reasoning-paper-folding-and-cutting|L17|0` (L17): Reasoning lessons are required to use the reduced Core Concept → Examples → Traps to Watch For layout and drop Speed Tricks & Shortcuts. This material appears inside a Speed Tricks & Shortcuts section, so the subject-specific section fit is not followed. Reason: Speed Tricks includes a real method but is mostly caution; layout change is optional.
- `lesson-spatial-abstract-reasoning-paper-folding-and-cutting|L18|0` (L18): The examples cover cuts through all available layers and cuts on fold lines, but none works the distinct layer-location case where a cut crosses only some layers, such as near an irregular packet boundary. That case is explicitly taught as something students must check and is part of the learning goal's layer conditions. Reason: A cut that crosses only some layers is mentioned in a trap; a worked case is nice but rare.
- `lesson-spatial-abstract-reasoning-paper-folding-and-cutting|L19|1` (L19): Example #4 ends with prose around a display equation instead of presenting the worked solution as a numbered list of steps. Reason: Example 4 is one counting step with the equation displayed; numbered steps add little.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
