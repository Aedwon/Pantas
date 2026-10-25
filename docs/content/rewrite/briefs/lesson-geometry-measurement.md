# Brief: Measurement

Lesson id: `lesson-geometry-measurement`
Lesson path: `content/lessons/mathematics/geometry/measurement.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-geometry-measurement|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> - **Triangle** with base $b$ and height $h$: area $\dfrac{1}{2}bh$. The height must be perpendicular to the base.
- Problem: The lesson teaches the perpendicular-height distinction but provides no worked triangle or parallelogram example that makes the student choose the true height over a slanted side.
- Triage reason: The lesson warns about slant sides but no example makes the student pick the perpendicular height.

### 2. `lesson-geometry-measurement|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> If every side of a figure is scaled by $k$, the perimeter scales by $k$, the area scales by $k^2$, and the volume scales by $k^3$.
- Problem: Scaling is part of the lesson's exam-relevant content, but it has no worked example covering a measured scaling problem or an inverse-scale case.
- Triage reason: The scaling shortcut is called a whole family of exam questions, yet no example applies it.

### 3. `lesson-geometry-measurement|L18|3`
- Rule: L18
- Fix size: medium
- Quote:
> - **Sphere**: volume $\dfrac{4}{3}\pi r^3$, surface area $4\pi r^2$.
- Problem: The three-dimensional coverage omits worked cases for several distinct taught solids, including sphere and pyramid, so the examples do not cover every distinct relation introduced in the lesson.
- Triage reason: Sphere and pyramid formulas are taught but never worked; add an example for at least one of them.

### 4. `lesson-geometry-measurement|B01|0`
- Rule: B01
- Fix size: small
- Quote:
> summary: "The perimeter, area, surface area, and volume formulas for the figures that appear on every exam."
- Problem: The absolute claim that these figures appear on every exam is not confirmed anywhere in the packet and should be omitted under the rule for unconfirmed facts.
- Triage reason: 'Appear on every exam' is an unconfirmed absolute; remove.

### 5. `lesson-geometry-measurement|B01|1`
- Rule: B01
- Fix size: small
- Quote:
> Computing $\pi r^2 h$ for a cone gives an answer three times too big, and that answer is always among the choices.
- Problem: The calculation is three times too large, but the claim that this wrong answer is always among the choices is an unsupported absolute about exam construction.
- Triage reason: 'Always among the choices' is an unconfirmed absolute; soften.

### 6. `lesson-geometry-measurement|B01|2`
- Rule: B01
- Fix size: small
- Quote:
> For shaded regions, do not hunt for a special formula. It is always whole minus hole: outer area minus inner area.
- Problem: This is mathematically overbroad. A shaded region is not always one outer region minus one inner region; some require adding pieces or handling overlaps.
- Triage reason: 'Always whole minus hole' is false for some shaded regions; add the adding-pieces case.

### 7. `lesson-geometry-measurement|L17|0`
- Rule: L17
- Fix size: small
- Quote:
> $$\ell^2 = 6^2 + 8^2 = 36 + 64 = 100$$
- Problem: The Pythagorean relation used to calculate slant height appears for the first time inside Example 6. Mathematics formulas must appear in Core Concept before an example uses them.
- Triage reason: Pythagorean theorem is used in Example 6 but never stated in Core Concept; add a one-line reminder.

### 8. `lesson-geometry-measurement|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> A cone has a radius of $6$ cm and a height of $8$ cm. Find its volume in terms of $\pi$, and find its slant height.
- Problem: "Slant height" is required to understand what Example 6 asks for, but the term is not defined before the question and no prerequisite lesson is identified.
- Triage reason: "Slant height" is used in Example 6 without being defined in Core Concept.

### 9. `lesson-geometry-measurement|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> A cone is one third of a cylinder, and its slant height comes from the Pythagorean theorem.
- Problem: The Pythagorean theorem is named and then used numerically, but the lesson never explains the general right-triangle relationship or how it determines slant height.
- Triage reason: The Pythagorean relationship is named and used but not stated; fix with the L17 finding.

### 10. `lesson-geometry-measurement|L26|1`
- Rule: L26
- Fix size: small
- Quote:
> If every side of a figure is scaled by $k$, the perimeter scales by $k$, the area scales by $k^2$, and the volume scales by $k^3$.
- Problem: The scaling rule is stated as a result without explaining how one, two, or three scaled dimensions produce the powers $k$, $k^2$, and $k^3$.
- Triage reason: The k, k squared, k cubed rule has no reason; one line on lengths, areas, and volumes would explain it.

### 11. `lesson-geometry-measurement|L27|0`
- Rule: L27
- Fix size: small
- Quote:
> For shaded regions, do not hunt for a special formula. It is always whole minus hole: outer area minus inner area.
- Problem: The shortcut gives no condition for when subtraction applies and incorrectly states it as universal; shaded regions can also require adding pieces or handling overlaps.
- Triage reason: "Always whole minus hole" is false: some shaded regions need adding pieces; state when subtraction applies.

### 12. `lesson-geometry-measurement|L27|1`
- Rule: L27
- Fix size: small
- Quote:
> - **Cone**: volume $\dfrac{1}{3}\pi r^2 h$. A cone is one third of its cylinder.
- Problem: The one-third comparison does not state the needed matching condition: the comparison cylinder must have the same base radius and perpendicular height as the cone.
- Triage reason: The one-third rule is true only when the cylinder has the same base and height; state that condition.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-geometry-measurement|L03|0` (L03): The command verb "Find" is used in the first worked question without the required one-line explanation on first use. Reason: "Find" is an everyday verb; a gloss is unnecessary.
- `lesson-geometry-measurement|L04|0` (L04): This analogy appears in an example solution, but the rule permits at most one analogy and requires the analogy to be in Core Concept. Reason: "Two lids plus the label" is a plain description of parts, not a true analogy.
- `lesson-geometry-measurement|L18|2` (L18): Mixed-unit measurement is warned about but never worked through, so the examples do not cover the conversion scenario before area or volume is calculated. Reason: The mixed-unit trap is stated in the Traps section; a worked conversion would help but is optional.
- `lesson-geometry-measurement|L19|0` (L19): This key diameter-to-radius computation is kept inline instead of being shown as a display equation as required for worked-solution computations. Reason: The radius step is a one-line inline fact; nothing is skipped.
- `lesson-geometry-measurement|L19|1` (L19): The three face-area computations are key solution calculations but are written inline instead of as display equations. Reason: The face areas are short inline arithmetic and the sum is displayed; nothing is skipped.
- `lesson-geometry-measurement|L19|2` (L19): A key cone-volume computation is presented inline rather than as a display equation. The reasoning is present, so this is a formatting breach rather than a skipped step. Reason: The cone arithmetic is shown inline and nothing is skipped; display math is optional.
- `lesson-geometry-measurement|L25|0` (L25): The term "inscribed" is needed to understand the geometry of Example 3, but it is not explained earlier in this lesson and there is no prerequisite lesson to supply that meaning. Reason: The question itself says the circle touches all four sides, which explains "inscribed" in context.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L04 | At most one analogy, in Core Concept | Minor | Count analogies | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
