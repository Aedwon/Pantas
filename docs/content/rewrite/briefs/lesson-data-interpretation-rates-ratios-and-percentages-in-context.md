# Brief: Rates, Ratios, and Percentages in Context

Lesson id: `lesson-data-interpretation-rates-ratios-and-percentages-in-context`
Lesson path: `content/lessons/mathematics/data-interpretation/rates-ratios-and-percentages-in-context.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-data-interpretation-rates-ratios-and-percentages-in-context|B03|0`
- Rule: B03
- Fix size: medium
- Quote:
> The simplified ratio is $3:2$.
- Problem: The required Mathematics section "Speed Tricks & Shortcuts" is missing between the Examples section and Traps to Watch For.
- Triage reason: Mathematics keeps all five sections; Speed Tricks & Shortcuts is missing.

### 2. `lesson-data-interpretation-rates-ratios-and-percentages-in-context|L17|0`
- Rule: L17
- Fix size: medium
- Quote:
> The simplified ratio is $3:2$.
- Problem: The Mathematics section fit is incomplete because the required "Speed Tricks & Shortcuts" section is omitted before Traps to Watch For.
- Triage reason: Mathematics lessons keep all five sections, and Speed Tricks & Shortcuts is missing.

### 3. `lesson-data-interpretation-rates-ratios-and-percentages-in-context|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> An agency budget increased from $50$ million pesos in 2020 to $65$ million pesos in 2021. Find the percentage increase.
- Problem: The only worked percentage-change example is an increase. The recorded skill set also includes percent decrease and signed change, but the lesson gives no worked example for that distinct exam-relevant case.
- Triage reason: Only a percent increase is worked; a percent decrease with a negative sign is a distinct exam case.

### 4. `lesson-data-interpretation-rates-ratios-and-percentages-in-context|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> "A to B" and "B to A" are reciprocal ratios, not interchangeable descriptions.
- Problem: The terms "reciprocal ratios" and "interchangeable descriptions" are unnecessarily advanced for the required Grade 5 teaching-prose standard.
- Triage reason: "Reciprocal ratios" and "interchangeable descriptions" are too advanced for Grade 5 teaching prose.

### 5. `lesson-data-interpretation-rates-ratios-and-percentages-in-context|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> State the absolute change or use a different, explicitly defined comparison measure.
- Problem: This sentence uses abstract wording such as "explicitly defined comparison measure" instead of simple Grade 5 language.
- Triage reason: "Explicitly defined comparison measure" is abstract; say plainly to report the actual amount of change.

### 6. `lesson-data-interpretation-rates-ratios-and-percentages-in-context|L21|0`
- Rule: L21
- Fix size: small
- Quote:
> $$\text{Percentage Change}=\dfrac{\text{New Value}-\text{Original Value}}{\text{Original Value}}\times100\%$$
- Problem: This display equation is too wide for a typical phone screen because both numerator and denominator contain long text labels on one line.
- Triage reason: The long word labels in one display line are likely too wide for a phone; shorten or split the equation.

### 7. `lesson-data-interpretation-rates-ratios-and-percentages-in-context|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> For integer counts, a ratio such as $60:40$ can be simplified by dividing both terms by their greatest common divisor.
- Problem: The term "greatest common divisor" is needed to use the stated simplification method, but the lesson never explains what that term means before students must use it.
- Triage reason: "Greatest common divisor" is not explained; say the largest number that divides both terms.

## CSE teaching to add

### 1. `mathematics-data-interpretation#5`
- Facet: Lowest-term integer ratio and common-divisor selection
- Verdict: thin
- Tier: curriculum
- Missing ideas:
  - The divisor20 is supplied in the worked solution; its greatest-common-divisor meaning/selection is not developed. Numerical division procedure is local, so richer GCF teaching is optional preparation.

### 2. `mathematics-data-interpretation#6`
- Facet: Unit rates and rate/time normalization
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Rates in the title do not establish per-unit speed/work/cost or duration normalization teaching. Other arithmetic/rate lessons are reconciliation leads.

### 3. `mathematics-data-interpretation#7`
- Facet: Direct-proportion scaling model
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Simple part-percent arithmetic does not teach scaling related quantities, inverse relations or dividing a total into ratio parts. Separate local facets remain absent/partial rather than a whole broad-row verdict.

### 4. `mathematics-data-interpretation#8`
- Facet: Inverse-proportion model
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Simple part-percent arithmetic does not teach scaling related quantities, inverse relations or dividing a total into ratio parts. Separate local facets remain absent/partial rather than a whole broad-row verdict.

### 5. `mathematics-data-interpretation#9`
- Facet: Partitive allocation from a ratio
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Simple part-percent arithmetic does not teach scaling related quantities, inverse relations or dividing a total into ratio parts. Separate local facets remain absent/partial rather than a whole broad-row verdict.

## Optional, fix only if editing that passage anyway

- `lesson-data-interpretation-rates-ratios-and-percentages-in-context|B01|0` (B01): This sign interpretation is not generally correct when the original value is negative. With a negative original value, the percentage-change formula can produce a negative result even when the new value is numerically greater. Reason: Sign rule fails only for a negative starting value; add 'when the original value is positive'.
- `lesson-data-interpretation-rates-ratios-and-percentages-in-context|B08|0` (B08): The prose numbers 2020 and 2021 are outside inline math delimiters, contrary to the rule that every number in prose must be inside $...$. Reason: Years are labels, not quantities; wrapping 2020 and 2021 in math would be pedantic.
- `lesson-data-interpretation-rates-ratios-and-percentages-in-context|L26|0` (L26): The lesson names the greatest-common-divisor method but does not explain how to find the divisor or why dividing both ratio terms by it produces an equivalent lowest-term ratio. Reason: Example 3 shows the divide-by-20 step; a full method for finding the divisor belongs to a prerequisite lesson.
- `lesson-data-interpretation-rates-ratios-and-percentages-in-context|L27|0` (L27): The lesson omits the condition needed for this sign shortcut: it works as stated when the original reference value is positive, but can reverse the interpretation when the original value is negative. Reason: The negative original value is a real but rare edge; exam percent-change items use positive bases.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| B03 | Required content is present: outline sections, required figures | Blocker | Compare with the outline entry and figure needs | LSG: Section structure, Illustration placeholders |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L21 | Display equations fit a phone screen | Minor | Look for long display lines | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
