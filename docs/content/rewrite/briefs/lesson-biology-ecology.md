# Brief: Ecology

Lesson id: `lesson-biology-ecology`
Lesson path: `content/lessons/science/biology/ecology.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-biology-ecology|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> A **food web** combines many connected feeding relationships in an ecosystem. Because many organisms eat at more than one trophic level, real food webs are not always neat four-step ladders.
- Problem: The learning goal includes interpreting ecosystem feeding, but the worked examples cover only a single chain and never show a branching food web or a consequence of changing one member.
- Triage reason: Food web is taught but only a single chain is worked; add one branching-web example showing a change in one member.

### 2. `lesson-biology-ecology|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> The **water cycle** moves water through reservoirs such as oceans, atmosphere, land, groundwater, and living organisms.
- Problem: Matter cycling is part of the learning goal, yet the examples work only the nitrogen cycle; there is no worked carbon, phosphorus, or water-cycle interpretation to cover those distinct scenarios.
- Triage reason: Carbon and water cycles are taught but no example works them; add a short cycle-interpretation example.

### 3. `lesson-biology-ecology|L26|0`
- Rule: L26
- Fix size: medium
- Quote:
> The **water cycle** moves water through reservoirs such as oceans, atmosphere, land, groundwater, and living organisms.
- Problem: This only names reservoirs and says water moves among them; it does not explain the processes that make the water cycle work, such as evaporation, condensation, precipitation, or return flow.
- Triage reason: The water cycle is only a list of reservoirs; it never explains evaporation, condensation, precipitation and return flow.

### 4. `lesson-biology-ecology|L26|1`
- Rule: L26
- Fix size: medium
- Quote:
> The **phosphorus cycle** is dominated by movement through rocks, soils, organisms, and water and has no major atmospheric gaseous reservoir comparable with the carbon or nitrogen cycles.
- Problem: This gives reservoirs and one limitation but does not explain how phosphorus actually moves through the cycle, so the concept is named more than it is taught.
- Triage reason: The phosphorus cycle gives reservoirs but not how phosphorus moves, such as weathering, uptake, decay and runoff.

### 5. `lesson-biology-ecology|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> The familiar **10% rule** is a classroom approximation, not a universal constant.
- Problem: The number 10% appears in prose outside inline math; the notation rule requires prose numbers to be inside `$...$`.
- Triage reason: Prose writes 10% outside inline math; the notation rule requires $10\%$.

### 6. `lesson-biology-ecology|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> This is an estimate based on the problem's 10% assumption, not a law that all ecosystems obey exactly.
- Problem: The number 10% appears in prose outside inline math instead of the required `$10\%$` form.
- Triage reason: Prose writes 10% outside inline math; the notation rule requires $10\%$.

### 7. `lesson-biology-ecology|B08|2`
- Rule: B08
- Fix size: small
- Quote:
> For trophic-energy calculations, use 10% only when the lesson/problem presents it as an approximation or explicitly instructs you to assume it.
- Problem: The number 10% appears in prose outside inline math instead of the required `$10\%$` form.
- Triage reason: Prose writes 10% outside inline math; the notation rule requires $10\%$.

### 8. `lesson-biology-ecology|B08|3`
- Rule: B08
- Fix size: small
- Quote:
> Trophic transfer efficiency varies; 10% is a useful rule of thumb for simple problems.
- Problem: The number 10% appears in prose outside inline math instead of the required `$10\%$` form.
- Triage reason: Prose writes 10% outside inline math, including inside the trap blockquote; use $10\%$.

### 9. `lesson-biology-ecology|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> A **biome** is a large ecological region characterized mainly by climate and dominant vegetation, with associated animal and microbial communities. A biome contains many ecosystems rather than being a single ecosystem scaled up.
- Problem: This teaching prose uses long sentences and advanced words such as "characterized," "dominant vegetation," and "microbial communities," which is above the required Grade 5 reading level.
- Triage reason: Long sentences with 'characterized', 'dominant vegetation' and 'microbial communities' are above Grade 5 level.

### 10. `lesson-biology-ecology|L03|2`
- Rule: L03
- Fix size: small
- Quote:
> Classify these simplified relationships: (a) a tapeworm drawing nutrients from a dog and harming it; (b) a pollinator receiving food while pollinating a plant; (c) an organism gaining shelter while measurements show no detectable effect on its host.
- Problem: The exam verb "Classify" first appears here without the required one-line explanation.
- Triage reason: 'Classify' is an exam verb used for the first time with no one-line meaning.

### 11. `lesson-biology-ecology|L05|0`
- Rule: L05
- Fix size: small
- Quote:
> Atmospheric $N_2$ contains a strong triple bond and is chemically unavailable to most organisms.
- Problem: This worked-solution sentence is not in the required simple language; "chemically unavailable" is unnecessarily difficult for the Grade 5 teaching benchmark.
- Triage reason: 'Strong triple bond' and 'chemically unavailable' are too hard for a Grade 5 solution; say plainly why plants cannot use it.

### 12. `lesson-biology-ecology|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> A problem tells you to assume $10\%$ trophic transfer efficiency. Producers contain $10{,}000$ kJ of usable production. Under that stated assumption, estimate the energy transferred to primary and then secondary consumers.
- Problem: The unit abbreviation "kJ" is used without first explaining that it means kilojoules, and there is no prerequisite lesson identified to supply that explanation.
- Triage reason: The unit kJ is used without saying it means kilojoules, a unit of energy.

### 13. `lesson-biology-ecology|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> Nitrogen-fixing prokaryotes convert $N_2$ to ammonia.
- Problem: The term "prokaryotes" appears in the worked explanation without being defined or briefly reminded beforehand, despite there being no prerequisite lesson to supply its meaning.
- Triage reason: 'Prokaryotes' is never defined; say bacteria or add a short meaning.

## CSE teaching to add

### 1. `science-biology#28`
- Facet: Population and community dynamics
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Not taught in this biology body; other-topic absence is not claimed.

### 2. `science-biology#29`
- Facet: Biodiversity and ecosystem consequences
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Not taught in this biology body; other-topic absence is not claimed.

### 3. `science-biology#30`
- Facet: Human impacts on ecosystems
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Not taught in this biology body; other-topic absence is not claimed.

### 4. `science-biology#31`
- Facet: Species/resource conservation and environmental management
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Not taught in this biology body; other-topic absence is not claimed.

## Optional, fix only if editing that passage anyway

- `lesson-biology-ecology|L03|0` (L03): The exam verbs "Arrange" and "identify" first appear here without the required one-line explanations of what the student must do. Reason: 'Arrange' and 'identify' are plain everyday words, not real exam verbs needing a gloss.
- `lesson-biology-ecology|L03|1` (L03): The exam verb "estimate" first appears here without a one-line explanation of what the instruction means. Reason: 'Estimate' is plain and the example itself shows what to do; a gloss is optional.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
