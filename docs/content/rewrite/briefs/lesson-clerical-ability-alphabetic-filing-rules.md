# Brief: Alphabetic Filing Rules

Lesson id: `lesson-clerical-ability-alphabetic-filing-rules`
Lesson path: `content/lessons/reasoning/clerical-ability/alphabetic-filing-rules.md`

Tagged exams: cse-subprofessional

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-clerical-ability-alphabetic-filing-rules|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> A common personal-name convention is to index by surname first, then given name, then middle name or initial:
- Problem: The worked examples never show the key successive-unit cases where two records share a surname and must be ordered by given name, or share surname and given name and must be ordered by middle name. Those are distinct cases inside the lesson's stated method and learning goal.
- Triage reason: Sorting by given name after equal surnames is the core method and has no worked example.

### 2. `lesson-clerical-ability-alphabetic-filing-rules|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> The current public CSE clerical-ability scope includes **filing**, but it does not publish one universal indexing manual for every filing item.
- Problem: This opening uses long, abstract wording such as "clerical-ability scope," "universal," and "indexing manual" before the learner has been given simpler language for the idea, making the teaching prose harder than the Grade 5 standard.
- Triage reason: Opening sentence uses abstract words; split and simplify.

### 3. `lesson-clerical-ability-alphabetic-filing-rules|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> Names containing particles such as *De, de, Del, De la, van, von,* or *San* should be filed according to the governing filing rule and the person's established surname.
- Problem: This sentence relies on difficult terms such as "particles," "governing," and "established surname" in one long construction instead of explaining the idea in short, simple Grade 5 language.
- Triage reason: Particles sentence is long and uses "governing" and "established"; rewrite in short plain sentences.

### 4. `lesson-clerical-ability-alphabetic-filing-rules|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> Under the stated city tie-break rule, **Boston** comes before **Chicago**. Without such an instruction or established filing convention, location is not automatically the universal tie-breaker.
- Problem: Example 3 presents its worked solution as an unnumbered paragraph. The examples standard requires worked solutions to show their steps as a numbered list.
- Triage reason: Example 3 solution is a paragraph; put it in numbered steps.

### 5. `lesson-clerical-ability-alphabetic-filing-rules|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> Suffixes such as *Jr., Sr., II,* and *III* can be used as later filing units when necessary to distinguish otherwise identical names. Exact treatment depends on the filing system being used.
- Problem: The section is titled "Suffixes and titles," but this teaching explains only suffixes. It never explains what a title means for the filing key or how title handling works under a stated filing system.
- Triage reason: Heading says titles but only suffixes are taught; teach titles briefly or rename the heading.

## CSE teaching to add

### 1. `reasoning-clerical-ability#1`
- Facet: Infer a convention from demonstrations
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure/application for the named variant.

### 2. `reasoning-clerical-ability#5`
- Facet: Identify established name components
- Verdict: thin
- Tier: official
- Missing ideas:
  - Explicit component identification or ordering explanation beyond the local statement.

### 3. `reasoning-clerical-ability#11`
- Facet: Suffix as later filing unit
- Verdict: thin
- Tier: official
- Missing ideas:
  - Explicit component identification or ordering explanation beyond the local statement.

### 4. `reasoning-clerical-ability#12`
- Facet: Title handling
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure/application for the named variant.

### 5. `reasoning-clerical-ability#27` [weak tier: add only if it fits]
- Facet: Organization/business-name indexing
- Verdict: absent
- Tier: weak
- Missing ideas:
  - No business/organization-name key construction or comparison application.

### 6. `reasoning-clerical-ability#28` [weak tier: add only if it fits]
- Facet: Hyphenated personal-name indexing
- Verdict: absent
- Tier: weak
- Missing ideas:
  - Particle treatment is taught conditionally, but no hyphenated personal-name comparison rule/application.

### 7. `reasoning-clerical-ability#30` [weak tier: add only if it fits]
- Facet: Abbreviation treatment in alphabetic filing
- Verdict: absent
- Tier: weak
- Missing ideas:
  - No abbreviation-specific comparison/expansion convention taught.

### 8. `reasoning-clerical-ability#31` [weak tier: add only if it fits]
- Facet: Numeral treatment in alphabetic filing
- Verdict: absent
- Tier: weak
- Missing ideas:
  - No rule for spelled-out versus literal numeral names in alphabetic comparison.

## Optional, fix only if editing that passage anyway

- `lesson-clerical-ability-alphabetic-filing-rules|L17|0` (L17): The lesson is tagged as subject-reasoning, but the Reasoning section fit requires the reduced Core Concept → Examples → Traps to Watch For layout and says to drop Speed Tricks. This extra section breaks that required subject layout. Reason: Approved ruling (Oct 25): keep Speed Tricks only if it holds a real shortcut.
- `lesson-clerical-ability-alphabetic-filing-rules|L18|1` (L18): The lesson teaches suffixes as a later filing-unit case but gives no worked example that applies a suffix to break an otherwise identical-name tie, leaving this exam-relevant variation uncovered. Reason: Suffix handling varies by system, so an example would need an invented rule; optional.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
