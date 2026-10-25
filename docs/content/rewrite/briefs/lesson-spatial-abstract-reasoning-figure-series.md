# Brief: Figure Series (Predicting the Next Shape in a Pattern)

Lesson id: `lesson-spatial-abstract-reasoning-figure-series`
Lesson path: `content/lessons/reasoning/spatial-abstract-reasoning/figure-series.md`

Tagged exams: acet, dcat, sm-foundation, cse-professional

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-spatial-abstract-reasoning-figure-series|L05|1`
- Rule: L05
- Fix size: medium
- Quote:
> Small black triangle → medium white triangle → large black triangle.
- Problem: This is not a determinate question: it omits both an explicit prompt and the answer choices or defined size scale needed to determine the next size.
- Triage reason: Example 4 has no question and no answer choices, so the next figure is not determinate as written.

### 2. `lesson-spatial-abstract-reasoning-figure-series|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> **Track one feature at a time.** Separate orientation, count, fill, size, and position before combining them.
- Problem: Position is named as a feature to track, but there is no worked example that teaches or practices a changing-position series.
- Triage reason: Position is listed as a feature and shown only in a figure, but no worked example uses it.

### 3. `lesson-spatial-abstract-reasoning-figure-series|L18|3`
- Rule: L18
- Fix size: medium
- Quote:
> Rotation by a constant angle, alternating states, incremental counts, and interleaved rules are common item structures.
- Problem: Interleaved rules are named but never worked, and the rotation coverage stays limited to one constant-angle case rather than including a changing-angle or other nonconstant transformation.
- Triage reason: Interleaved rules are named as a common structure but never worked; one example would teach it.

### 4. `lesson-spatial-abstract-reasoning-figure-series|L18|4`
- Rule: L18
- Fix size: medium
- Quote:
> **Use the choices to test the intended rule.** The correct candidate should preserve every relevant feature transformation.
- Problem: No worked example supplies an actual answer-choice set, so students never practice the stated strategy of testing a candidate rule against choices.
- Triage reason: Strategy says to test answer choices, yet no example shows choices; Example 4 especially needs them.

### 5. `lesson-spatial-abstract-reasoning-figure-series|B01|0`
- Rule: B01
- Fix size: small
- Quote:
> Rotation by a constant angle, alternating states, incremental counts, and interleaved rules are common item structures.
- Problem: The claim that these are common item structures is a prevalence claim, and the packet provides no source confirming it; Level 3 explicitly records this prevalence statement as unverified.
- Triage reason: 'Common item structures' is an unsourced prevalence claim; soften.

### 6. `lesson-spatial-abstract-reasoning-figure-series|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> The simple count pattern is $3,4,5$, so the intended continuation is a **hexagon** with 6 sides.
- Problem: The number 6 appears in prose outside inline math; the notation rule requires prose numbers to be wrapped in dollar signs.
- Triage reason: The numeral 6 in the hexagon sentence is outside inline math, which the notation rule requires.

### 7. `lesson-spatial-abstract-reasoning-figure-series|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Verify a candidate rule against **every shown transition** and use the answer choices to resolve ambiguity.
- Problem: Terms such as "candidate rule," "transition," and "resolve ambiguity" make this teaching sentence harder than the required Grade 5 simple-English standard.
- Triage reason: Candidate rule, transition and resolve ambiguity are not Grade 5 words; plain wording is easy.

### 8. `lesson-spatial-abstract-reasoning-figure-series|L05|0`
- Rule: L05
- Fix size: small
- Quote:
> Black circle → white circle → black circle.
- Problem: This worked example gives only a sequence and does not state a question sentence asking the student what to determine.
- Triage reason: Example 3 gives a sequence with no question sentence, so the task is unstated.

### 9. `lesson-spatial-abstract-reasoning-figure-series|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> Rotation by a constant angle, alternating states, incremental counts, and interleaved rules are common item structures.
- Problem: The necessary term "interleaved rules" is introduced as a pattern type but never explained before students are expected to recognize or use it.
- Triage reason: Interleaved rules are named without a definition; one sentence on two alternating patterns would fix it.

### 10. `lesson-spatial-abstract-reasoning-figure-series|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> symmetry or other relationships among parts.
- Problem: The lesson names symmetry and part relationships as features but does not explain what patterns in those relationships look like or how to track them.
- Triage reason: Symmetry and part relationships are named with no explanation; explain briefly or remove them.

### 11. `lesson-spatial-abstract-reasoning-figure-series|L26|1`
- Rule: L26
- Fix size: small
- Quote:
> Rotation by a constant angle, alternating states, incremental counts, and interleaved rules are common item structures.
- Problem: Interleaved rules are only named; the lesson never explains how an interleaved series is organized or how to follow its separate subsequences.
- Triage reason: Interleaved series are only named; the same added example or sentence explains how to split them.

## CSE teaching to add

### 1. `reasoning-spatial-abstract-reasoning#72`
- Facet: Transfer of count progression to named numerical sequences
- Verdict: thin
- Tier: official
- Missing ideas:
  - Underlying count rule is taught, but exact CSE number-sequence difficulty and acceptance of figural/dot stimuli remain unknown. No full numerical-family coverage claim.

## Optional, fix only if editing that passage anyway

- `lesson-spatial-abstract-reasoning-figure-series|L17|0` (L17): Reasoning lessons must use the reduced Core Concept → Examples → Traps layout and drop Speed Tricks; this teaching appears inside a Speed Tricks & Shortcuts section. Reason: Speed Tricks holds general strategy, not a real shortcut, but keeping it harms no student.
- `lesson-spatial-abstract-reasoning-figure-series|L18|1` (L18): Dot or mark count is listed as a feature, but no worked example covers a dot-count or mark-count progression. Reason: Dot count works like side count in Example 2, so a separate example adds little.
- `lesson-spatial-abstract-reasoning-figure-series|L18|2` (L18): Symmetry and part relationships are listed as features, but no worked example covers either kind of progression. Reason: Symmetry is a minor listed feature; dropping it or one clause would do instead of an example.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
