# Science question QA round r2 summary

## Scope and source

- Assignment: question audit and expansion, tasks 1 through 4, science only.
- Approved decision: `docs/superpowers/decisions/2026-10-01-question-explanations-log.md`, retrieved from current `origin/main`.
- Policy commit: `244d74b661c4aa5a88ddb216c29056a45dca3b75`. Read `AGENTS.md`, `WORKFLOW.md`, and `SUBAGENTS.md` from this revision in full on resumption.
- Audit baseline: `1f79d880264e9c80c7507c95a365126d251c3837`.
- Verified content revision before this summary: `cf70e0e7d88b6aebd3d1784090bd9a48f2786458`.
- Branch: `content/question-qa-r2-science`.
- Worktree: `/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2-science`.
- At resumption, local and remote branch heads matched `38227eeda8dffb61fc828569104de3afe297cf8a`. The interrupted patch contained only authorized physics question and ledger changes. Those corrections were finished and committed per lesson before completing this summary.

## Completed work

All 51 science lessons have complete per-question ledgers. There are 777 existing questions audited and 246 new questions, for 1,023 active questions. Every lesson has at least 20 active questions. None is figure-pending.

All wrong choices have nonempty notes. Correct choices have no notes. Existing question IDs and approval values are preserved. Every new question has `approved: false`. Questions outside lesson scope keep their original stems, choice texts, and answer keys as required by the assignment. Their explanations and notes were checked again during resumption.

The final scan repaired two malformed LaTeX strings that passed YAML import: vector notation in `q-physics-momentum-and-impulse-0015` and the reaction arrow in `q-chemistry-acids-bases-ph-0017`. The final scan found no remaining unmatched or split math delimiters, control characters, bare `\frac`, or em dashes.

No exact duplicate stems remain. The lesson audits recorded rewrites of repeated scenarios and weak distractors. No position-dependent choice wording was found in the final check.

## Status counts

| Status | Count |
| --- | ---: |
| VERIFIED | 107 |
| CORRECTED | 637 |
| NEW | 246 |
| NEEDS AEDWON | 33 |

## Severity counts

Severity records the issue found before correction. A HIGH count is not a count of remaining wrong keys. Seven HIGH rows are still awaiting Aedwon because the assignment protects out-of-lesson stems, choices, and keys.

| Severity | Count |
| --- | ---: |
| NONE | 348 |
| LOW | 82 |
| MEDIUM | 389 |
| HIGH | 204 |

## Final per-lesson active counts

The importer emitted `isActive: true` for every question counted here. Imported counts match the ledger and YAML counts.

| Topic / lesson | Active | Existing audited | Added |
| --- | ---: | ---: | ---: |
| biology/botany | 20 | 16 | 4 |
| biology/cell-biology | 20 | 16 | 4 |
| biology/cellular-metabolism | 20 | 14 | 6 |
| biology/cellular-reproduction | 20 | 15 | 5 |
| biology/characteristics-of-life | 20 | 14 | 6 |
| biology/ecology | 20 | 18 | 2 |
| biology/evolution | 20 | 14 | 6 |
| biology/genetics-and-heredity | 20 | 15 | 5 |
| biology/human-anatomy-physiology | 20 | 15 | 5 |
| biology/taxonomy-and-classification | 20 | 14 | 6 |
| chemistry/acids-bases-ph | 20 | 15 | 5 |
| chemistry/atomic-structure | 20 | 15 | 5 |
| chemistry/basic-organic-chemistry | 20 | 14 | 6 |
| chemistry/chemical-bonding | 20 | 15 | 5 |
| chemistry/chemical-nomenclature | 20 | 15 | 5 |
| chemistry/chemical-reactions | 20 | 15 | 5 |
| chemistry/gas-laws | 20 | 15 | 5 |
| chemistry/history-of-the-atom | 20 | 14 | 6 |
| chemistry/matter | 20 | 16 | 4 |
| chemistry/mixtures-and-separation | 20 | 15 | 5 |
| chemistry/mole-concept | 20 | 14 | 6 |
| chemistry/nuclear-chemistry | 20 | 14 | 6 |
| chemistry/periodic-table | 20 | 15 | 5 |
| chemistry/quantum-numbers-electron-configuration | 20 | 14 | 6 |
| chemistry/solutions | 20 | 14 | 6 |
| chemistry/stoichiometry | 20 | 14 | 6 |
| chemistry/thermodynamics-and-kinetics | 20 | 14 | 6 |
| earth-science-astronomy/earths-motions | 20 | 14 | 6 |
| earth-science-astronomy/earths-subsystems | 20 | 15 | 5 |
| earth-science-astronomy/eclipses-and-moon-phases | 20 | 16 | 4 |
| earth-science-astronomy/fossils-and-geologic-time | 21 | 21 | 0 |
| earth-science-astronomy/heavenly-bodies | 20 | 16 | 4 |
| earth-science-astronomy/layers-of-the-earth | 20 | 16 | 4 |
| earth-science-astronomy/minerals-and-rocks | 20 | 18 | 2 |
| earth-science-astronomy/origin-of-the-universe | 20 | 15 | 5 |
| earth-science-astronomy/plate-tectonics | 20 | 20 | 0 |
| earth-science-astronomy/water-cycle-oceanography | 20 | 17 | 3 |
| earth-science-astronomy/weather-and-climate | 22 | 22 | 0 |
| physics/dynamics | 20 | 15 | 5 |
| physics/electricity-and-magnetism | 20 | 15 | 5 |
| physics/fluid-mechanics | 20 | 14 | 6 |
| physics/gravity-and-keplers-laws | 20 | 14 | 6 |
| physics/kinematics | 20 | 14 | 6 |
| physics/light-and-optics | 20 | 15 | 5 |
| physics/momentum-and-impulse | 20 | 14 | 6 |
| physics/scalars-and-vectors | 20 | 14 | 6 |
| physics/thermodynamics | 20 | 15 | 5 |
| physics/two-dimensional-motion | 20 | 14 | 6 |
| physics/units-and-measurements | 20 | 14 | 6 |
| physics/waves-and-sound | 20 | 15 | 5 |
| physics/work-energy-power | 20 | 15 | 5 |

## Every HIGH finding

- `q-biology-botany-0002` (VERIFIED): Explanation incorrectly described all xylem cells as dead.
- `q-biology-botany-0003` (VERIFIED): Explanation incorrectly treated all xylem cells as dead and discussed a wrong choice.
- `q-biology-botany-0006` (CORRECTED): Explanation said all xylem cells were dead; other choices were implausible.
- `q-biology-botany-0010` (VERIFIED): Wrong-choice note incorrectly said roots show negative gravitropism.
- `q-biology-botany-0011` (CORRECTED): Original stem described both negative phototropism and positive gravitropism; explanation overgeneralized root light responses.
- `q-biology-botany-0012` (CORRECTED): Marked answer and explanation overgeneralized negative root phototropism.
- `q-biology-cell-biology-0001` (CORRECTED): Explanation falsely said mitochondria do not hold DNA.
- `q-biology-cell-biology-0008` (CORRECTED): Original stem and explanation wrongly called walls, chloroplasts, and vacuoles plant-only across all life.
- `q-biology-cell-biology-0009` (CORRECTED): Explanation incorrectly described the structures as unique to plants across all organisms.
- `q-biology-cell-biology-0016` (CORRECTED): Explanation said all active transport directly needs ATP; stem left passive permeability unstated.
- `q-biology-cellular-metabolism-0007` (CORRECTED): Original stem wrongly attributed all oxygen animals breathe to plants, excluding algae and cyanobacteria.
- `q-biology-cellular-metabolism-0008` (CORRECTED): Original correct choice could read as saying animal cells also perform photosynthesis.
- `q-biology-cellular-metabolism-0010` (CORRECTED): Explanation incorrectly said mitochondria occur in nearly all cells and restricted chloroplasts to plant-type cells.
- `q-biology-cellular-metabolism-0012` (CORRECTED): Original key and explanation treated the pathways as exact mirror-image reactions.
- `q-biology-cellular-reproduction-0002` (CORRECTED): Original broad sperm-production stem could include mitosis; explanation restricted all meiosis to gamete production.
- `q-biology-cellular-reproduction-0003` (CORRECTED): Original explanation claimed meiosis always produces four daughter cells, ignoring unequal oogenesis.
- `q-biology-cellular-reproduction-0009` (CORRECTED): Original question and explanation treated mitosis as identical to division into daughter cells.
- `q-biology-cellular-reproduction-0012` (CORRECTED): Original stem confused an abbreviated description with proof of missing biological stages.
- `q-biology-characteristics-of-life-0001` (CORRECTED): Original made-of wording also allowed molecules as a defensible answer.
- `q-biology-characteristics-of-life-0007` (CORRECTED): Original note falsely said viruses lack membranes; many viruses have envelopes.
- `q-biology-characteristics-of-life-0012` (CORRECTED): Original gravity distractor implied gravity cannot be a biological stimulus; plant gravitropism shows otherwise.
- `q-biology-characteristics-of-life-0013` (NEEDS AEDWON): Lesson does not teach this distinction; preserved keyed choice incorrectly requires two parents and remains longest. Explanation now qualifies self-fertilization; false sexual-bacterial claim removed from notes.
- `q-biology-characteristics-of-life-0014` (CORRECTED): Original item treated every property as mandatory in each individual and assigned evolution to one organism.
- `q-biology-ecology-0008` (CORRECTED): Wrong note falsely said 1 kilocalorie came from three 10% steps; item repeated the same forward calculation.
- `q-biology-ecology-0011` (CORRECTED): Explanation incorrectly called nitrate a direct product of fixation; distractors were unrelated.
- `q-biology-ecology-0012` (CORRECTED): Correct choice and explanation incorrectly called nitrate a direct fixation product.
- `q-biology-ecology-0018` (CORRECTED): Original stem and explanation overstated a four-or-five-level limit not taught as a fixed rule.
- `q-biology-evolution-0001` (CORRECTED): Original stem and explanation incorrectly dated the first proposal of natural selection to 1859.
- `q-biology-evolution-0003` (CORRECTED): Original imposed a nonrequired causal order and falsely said inheritance follows selection.
- `q-biology-evolution-0006` (CORRECTED): Original explanation made isolated populations inevitably form separate species through selection alone.
- `q-biology-evolution-0007` (CORRECTED): Original explanation reduced finch diversification to an absolute one-island geographic-speciation story.
- `q-biology-evolution-0008` (CORRECTED): Original had implausible distractors and claimed selection never changes an individual’s traits during life.
- `q-biology-evolution-0011` (CORRECTED): Original treated resistance as necessarily predating exposure without evidence; item duplicated pesticide scenario.
- `q-biology-evolution-0012` (CORRECTED): Original explanation treated selection as the sole mechanism leading to speciation.
- `q-biology-evolution-0014` (CORRECTED): Original explanation made speciation a guaranteed result of geographic isolation.
- `q-biology-genetics-and-heredity-0010` (CORRECTED): Original stem lacked model assumptions and explanation falsely ruled out all dominant inheritance.
- `q-biology-genetics-and-heredity-0014` (CORRECTED): Original duplicate pedigree item falsely said unaffected parents cannot have a child with a dominant condition.
- `q-biology-human-anatomy-physiology-0004` (CORRECTED): Original note wrongly said all skeletal muscle requires conscious signaling.
- `q-biology-human-anatomy-physiology-0009` (CORRECTED): Original denied specificity in innate defenses and used implausible no-response distractor.
- `q-biology-human-anatomy-physiology-0014` (CORRECTED): Original claimed only adaptive immunity builds memory without qualifying antigen-specific clonal memory.
- `q-biology-taxonomy-and-classification-0003` (CORRECTED): Original presented Protista as a settled modern kingdom and used rank-name filler.
- `q-biology-taxonomy-and-classification-0004` (CORRECTED): Original key called leo the whole species name while another choice correctly named the binomial.
- `q-biology-taxonomy-and-classification-0005` (CORRECTED): Original falsely credited Linnaeus with simply creating all of binomial nomenclature.
- `q-biology-taxonomy-and-classification-0006` (CORRECTED): Original claimed a scientific name always refers to exactly the same species without revision.
- `q-biology-taxonomy-and-classification-0008` (CORRECTED): Original called the specific epithet alone the species name and used British spelling in notes.
- `q-biology-taxonomy-and-classification-0009` (CORRECTED): Original explanation claimed every domain contains several kingdoms and treated Protista as settled.
- `q-biology-taxonomy-and-classification-0011` (CORRECTED): Original falsely said the whole species name is lowercase.
- `q-biology-taxonomy-and-classification-0013` (CORRECTED): Original treated count of shared ranks as an exact measure of relatedness.
- `q-chemistry-acids-bases-ph-0001` (CORRECTED): Original applied the pH-7 divider without a temperature condition.
- `q-chemistry-acids-bases-ph-0002` (CORRECTED): Original claimed pH 7 is always neutral without stating temperature.
- `q-chemistry-acids-bases-ph-0003` (CORRECTED): Original applied the pH-7 divider without a temperature condition.
- `q-chemistry-acids-bases-ph-0011` (CORRECTED): Original repeated the pH-ratio scenario and oversimplified acidity to concentration alone.
- `q-chemistry-acids-bases-ph-0013` (CORRECTED): Original marked choice falsely claimed every neutralization produces salt and water.
- `q-chemistry-acids-bases-ph-0014` (CORRECTED): Original explanation treated salt formation as ions combining; choices used safety and no-ion filler.
- `q-chemistry-atomic-structure-0008` (CORRECTED): Original isotope distractor falsely implied changing proton count creates isotopes; item duplicated electron-change classification.
- `q-chemistry-basic-organic-chemistry-0007` (CORRECTED): Original described saturation as maximum hydrogen filling, excluding saturated cycloalkanes.
- `q-chemistry-basic-organic-chemistry-0008` (CORRECTED): Original OH-only wording could include other hydroxyl-containing classes, including carboxylic acids.
- `q-chemistry-basic-organic-chemistry-0010` (CORRECTED): Original keyed wording treated functional groups as the only determinant of chemical behavior.
- `q-chemistry-basic-organic-chemistry-0011` (CORRECTED): Original saturation definition wrongly required every possible position to hold hydrogen.
- `q-chemistry-basic-organic-chemistry-0013` (CORRECTED): Original stated longest-chain selection as a universal IUPAC rule without limiting it to simple alkanes.
- `q-chemistry-basic-organic-chemistry-0014` (CORRECTED): Original repeated longest-chain framing and claimed all IUPAC naming always starts with the longest chain.
- `q-chemistry-chemical-bonding-0001` (CORRECTED): Original explanation treated every metal/nonmetal pair as necessarily ionic.
- `q-chemistry-chemical-bonding-0002` (CORRECTED): Original explanation treated nonmetal/nonmetal bonding as a definition rather than a shortcut.
- `q-chemistry-chemical-bonding-0003` (CORRECTED): Original note falsely required a metal and nonmetal for every ionic compound.
- `q-chemistry-chemical-bonding-0004` (CORRECTED): Original used conflicting rigid cutoffs and excluded defensible weak polarity at the 0.4 boundary.
- `q-chemistry-chemical-bonding-0005` (CORRECTED): Original claimed a large electronegativity difference always produces complete transfer.
- `q-chemistry-chemical-bonding-0012` (CORRECTED): Original duplicated metal/nonmetal classification and falsely said it always gives ionic bonding.
- `q-chemistry-chemical-bonding-0014` (CORRECTED): Original explanation treated octet completion as the main general cause and omitted lower-energy conditions.
- `q-chemistry-chemical-nomenclature-0001` (CORRECTED): Potassium(I) bromide was an unnecessary but defensible Stock-style distractor.
- `q-chemistry-chemical-nomenclature-0006` (CORRECTED): Nitrogen(V) oxide was a defensible alternate Stock name.
- `q-chemistry-chemical-nomenclature-0012` (CORRECTED): Original falsely treated -ite as universally one oxygen fewer with unchanged charge.
- `q-chemistry-chemical-nomenclature-0013` (CORRECTED): Original claimed every compound of two nonmetals always uses Greek prefixes.
- `q-chemistry-chemical-reactions-0002` (VERIFIED): Original note falsely restricted all combustion to hydrocarbons yielding CO2 and water.
- `q-chemistry-chemical-reactions-0012` (CORRECTED): Original explanation treated any symbolic compound swap as a real double replacement.
- `q-chemistry-gas-laws-0007` (CORRECTED): Original described 0 K as literally no thermal energy and used 273 as exact.
- `q-chemistry-gas-laws-0008` (CORRECTED): Original omitted fixed temperature and amount, so the result was not guaranteed.
- `q-chemistry-gas-laws-0009` (CORRECTED): Original rejected using the ideal gas law at both states, a valid method.
- `q-chemistry-history-of-the-atom-0003` (CORRECTED): Original nucleus-plus-orbits description also fit Bohr.
- `q-chemistry-history-of-the-atom-0004` (CORRECTED): Original quantized-level description also fit modern quantum mechanics.
- `q-chemistry-history-of-the-atom-0005` (CORRECTED): Original attributed the entire modern probability model to one researcher.
- `q-chemistry-history-of-the-atom-0007` (CORRECTED): Original explanation required literal collision and used weak distractors.
- `q-chemistry-history-of-the-atom-0008` (CORRECTED): Original note incorrectly dated the plum pudding model to 1897; correct answer was longest.
- `q-chemistry-history-of-the-atom-0010` (CORRECTED): Original credited the modern quantum model to Schrödinger alone.
- `q-chemistry-history-of-the-atom-0011` (CORRECTED): Original used an absolute all-particles prediction and a false charge-independence note.
- `q-chemistry-history-of-the-atom-0012` (CORRECTED): Original generalized Bohr’s spectral success to all atoms.
- `q-chemistry-matter-0001` (VERIFIED): Original element definition omitted the ordinary-chemical-reaction limit.
- `q-chemistry-matter-0003` (VERIFIED): Original note claimed mixtures have no chemical bonds, an overgeneralization.
- `q-chemistry-matter-0007` (CORRECTED): Original called the CO2 gas misty; visible dry-ice mist is condensed water droplets.
- `q-chemistry-matter-0009` (CORRECTED): Original claimed becoming less ordered always requires absorbing energy.
- `q-chemistry-matter-0010` (CORRECTED): Original claimed becoming more ordered always releases energy.
- `q-chemistry-matter-0013` (CORRECTED): Original note assigned all rust the formula Fe2O3; rust composition is more complex.
- `q-chemistry-mixtures-and-separation-0001` (CORRECTED): No visible coffee grounds did not establish molecular homogeneity; coffee can contain colloids.
- `q-chemistry-mixtures-and-separation-0007` (CORRECTED): Original explanation wrongly said one component evaporates first alone and promised both pure liquids.
- `q-chemistry-mixtures-and-separation-0010` (CORRECTED): Original last distractor was a defensible restatement of why ordinary filtration fails.
- `q-chemistry-mixtures-and-separation-0012` (CORRECTED): Original falsely treated distillation as components boiling away one after another.
- `q-chemistry-mixtures-and-separation-0013` (CORRECTED): Original claimed farther travel proves weaker paper attraction alone.
- `q-chemistry-mixtures-and-separation-0015` (CORRECTED): Original promised safe drinking water despite unspecified dissolved contaminants and rejected a feasible reversed sequence.
- `q-chemistry-mole-concept-0005` (CORRECTED): Original last note claimed 45 times NA produced 8.1e24; the arithmetic was wrong.
- `q-chemistry-mole-concept-0006` (CORRECTED): Original marked answer falsely prohibited valid combined dimensional-analysis conversions.
- `q-chemistry-mole-concept-0008` (CORRECTED): Original asserted exact numerical transfer and conflated tabulated atomic mass with a single atom.
- `q-chemistry-mole-concept-0009` (CORRECTED): Original called 6.022e23 the full value and asserted an unsupported exam-wide rounding rule.
- `q-chemistry-mole-concept-0012` (CORRECTED): Original repeated grams-to-entities and gave an incorrect number for molar mass times NA.
- `q-chemistry-mole-concept-0013` (CORRECTED): Original 84 g/mol note gave arithmetic unrelated to that answer; g/mol terminology corrected.
- `q-chemistry-nuclear-chemistry-0005` (CORRECTED): Original unspecified beta could mean beta-minus or beta-plus; mass number is exactly unchanged.
- `q-chemistry-nuclear-chemistry-0006` (VERIFIED): Original note implied fission fragments must be roughly equal; the definition does not require that.
- `q-chemistry-nuclear-chemistry-0007` (CORRECTED): Original described two solar hydrogen nuclei directly forming helium and claimed unqualified greater fusion energy.
- `q-chemistry-nuclear-chemistry-0011` (CORRECTED): Original stated thick lead or concrete blocks gamma rays completely.
- `q-chemistry-nuclear-chemistry-0014` (CORRECTED): Original compared fusion and fission energy without specifying per event or per fuel mass.
- `q-chemistry-periodic-table-0004` (CORRECTED): Original applied same-valence-count rule to all groups without transition-metal or helium qualifications.
- `q-chemistry-periodic-table-0010` (CORRECTED): Original bundled electron affinity into an upper-right rule and claimed radius varies continuously.
- `q-chemistry-periodic-table-0011` (CORRECTED): Original treated electron affinity as the same sign-free, exception-free trend.
- `q-chemistry-periodic-table-0012` (CORRECTED): Original implied no diagonal comparison can be straightforward even when both trends agree.
- `q-chemistry-periodic-table-0014` (CORRECTED): Original higher-affinity claim omitted sign convention and ignored major exceptions.
- `q-chemistry-quantum-numbers-electron-configuration-0001` (VERIFIED): Original explanation falsely called s the smallest orbital capacity; all individual orbitals hold at most two.
- `q-chemistry-quantum-numbers-electron-configuration-0002` (CORRECTED): Original key gave six for a single p orbital; repaired through explicit orbital/subshell comparison.
- `q-chemistry-quantum-numbers-electron-configuration-0003` (CORRECTED): Original key gave ten for one d orbital; new framing distinguishes orbital count from electron capacity.
- `q-chemistry-quantum-numbers-electron-configuration-0006` (CORRECTED): Original implied 4s is always below 3d without occupancy or atom context.
- `q-chemistry-quantum-numbers-electron-configuration-0007` (CORRECTED): Original described a p orbital as holding six and confused orbital and subshell capacities.
- `q-chemistry-solutions-0005` (CORRECTED): Original generalized one observation to most solids and confused dissolution rate with capacity.
- `q-chemistry-solutions-0014` (CORRECTED): Original fixed only solvent mass and did not establish unchanged solute amount.
- `q-chemistry-stoichiometry-0006` (CORRECTED): Original explanation implied an apparent yield above 100% necessarily rejects a reported result.
- `q-chemistry-thermodynamics-and-kinetics-0005` (CORRECTED): Original notes treated increased concentration as always increasing rate and excluded zero-order behavior.
- `q-chemistry-thermodynamics-and-kinetics-0007` (CORRECTED): Original duplicated catalyst speed and falsely claimed catalysts never change final product amounts in any context.
- `q-chemistry-thermodynamics-and-kinetics-0010` (CORRECTED): Original asserted only speed can ever change and every final product amount is universally fixed.
- `q-chemistry-thermodynamics-and-kinetics-0012` (CORRECTED): Original reduced thermodynamics to heat exchange and used a longest answer.
- `q-chemistry-thermodynamics-and-kinetics-0013` (CORRECTED): Original Paper never releases energy unless on fire distractor was defensible in context; correct answer was longest.
- `q-chemistry-thermodynamics-and-kinetics-0014` (CORRECTED): Original duplicated catalyst speed and claimed no catalyst can ever affect product quantity outside a defined equilibrium.
- `q-earth-science-astronomy-earths-motions-0002` (CORRECTED): Original note incorrectly measured the 23.5-degree tilt from the orbital plane rather than its perpendicular.
- `q-earth-science-astronomy-earths-motions-0004` (CORRECTED): Original did not specify tilt reference and falsely claimed zero tilt eliminates every possible seasonal variation.
- `q-earth-science-astronomy-earths-motions-0009` (CORRECTED): Original wrongly aligned Philippine March-May hot season with Australian winter; longest choice shortened. Source: https://www.pagasa.dost.gov.ph/information/climate-philippines
- `q-earth-science-astronomy-earths-motions-0011` (CORRECTED): Original called every solar day exactly 24 hours; this is the mean, not every apparent solar day.
- `q-earth-science-astronomy-earths-motions-0013` (CORRECTED): Original stated every-four-years leap days without the Gregorian century exceptions.
- `q-earth-science-astronomy-earths-motions-0014` (CORRECTED): Original duplicated the opposite-hemisphere example and assigned Philippine local weather solely to tilt.
- `q-earth-science-astronomy-earths-subsystems-0002` (CORRECTED): Original treated water-vapor classification as universally exclusive and called cloud droplets water vapor.
- `q-earth-science-astronomy-earths-subsystems-0007` (CORRECTED): Original rejected a defensible separate cryosphere convention and used a nonexistent-ice distractor.
- `q-earth-science-astronomy-eclipses-and-moon-phases-0013` (CORRECTED): Original partly-covered description also allowed annular central viewing, not solely penumbra; context now excludes that ambiguity.
- `q-earth-science-astronomy-fossils-and-geologic-time-0002` (NEEDS AEDWON): Lesson does not teach fossil preservation by rock-formation conditions. Stem/choices/key preserved; original explanation wrongly excluded every metamorphosed fossil.
- `q-earth-science-astronomy-fossils-and-geologic-time-0006` (CORRECTED): Original assumed every fossil equals its containing layer’s age and incorrectly assigned mammal appearance mainly to Cenozoic.
- `q-earth-science-astronomy-fossils-and-geologic-time-0007` (CORRECTED): Original falsely claimed radiometric dating is the only possible numerical-dating method.
- `q-earth-science-astronomy-fossils-and-geologic-time-0009` (CORRECTED): Original assumed every daughter is immediately stable and every isotope result is automatically the actual rock age.
- `q-earth-science-astronomy-fossils-and-geologic-time-0010` (CORRECTED): Original incorrectly defined half-life as decay directly into a stable form.
- `q-earth-science-astronomy-fossils-and-geologic-time-0013` (CORRECTED): Original said real finite samples can never reach zero; explanation now states only the ideal halving result.
- `q-earth-science-astronomy-fossils-and-geologic-time-0019` (CORRECTED): Original falsely treated all dinosaurs as extinct and used a dinosaur-never-existed distractor.
- `q-earth-science-astronomy-fossils-and-geologic-time-0020` (CORRECTED): Original falsely said only small shrew-like mammals existed in Mesozoic; reworking and non-avian scope clarified.
- `q-earth-science-astronomy-fossils-and-geologic-time-0021` (NEEDS AEDWON): Lesson lacks early-fish/Paleozoic teaching; isotope clock unspecified and not necessarily layer-deposition age. Stem/choices/key and longest cue preserved.
- `q-earth-science-astronomy-heavenly-bodies-0007` (CORRECTED): Original unqualified tail claim ignored ion/dust differences and orbital effects.
- `q-earth-science-astronomy-heavenly-bodies-0008` (CORRECTED): Unqualified tail claim and contradictory motion distractor corrected.
- `q-earth-science-astronomy-heavenly-bodies-0009` (CORRECTED): Original falsely ruled out tails on every asteroid; duplicate replaced.
- `q-earth-science-astronomy-layers-of-the-earth-0002` (CORRECTED): Original key used 70 km as typical continental thickness instead of about 35 km.
- `q-earth-science-astronomy-layers-of-the-earth-0003` (CORRECTED): Original gave 70 km as typical continental thickness and 5 km for oceanic crust; weak distractors replaced.
- `q-earth-science-astronomy-layers-of-the-earth-0015` (CORRECTED): Original explanation wrongly treated 70 km as typical continental thickness.
- `q-earth-science-astronomy-minerals-and-rocks-0017` (CORRECTED): Original incorrectly turned granite-derived sediment into limestone and marble.
- `q-earth-science-astronomy-minerals-and-rocks-0018` (NEEDS AEDWON): Hardness/streak absent from lesson; equal nominal reference hardness makes scratch bounds inconsistent; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0001` (CORRECTED): Original explanation falsely pictured all space as one tiny spatial point.
- `q-earth-science-astronomy-origin-of-the-universe-0002` (NEEDS AEDWON): History is untaught; 1927 expanding-universe work is conflated with 1931 primeval-atom proposal; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0004` (CORRECTED): Original claimed observations prove a single point in pre-existing space.
- `q-earth-science-astronomy-origin-of-the-universe-0007` (NEEDS AEDWON): History is untaught; retained key conflates 1927 expansion work with later Big Bang origin proposal; overlaps 0002.
- `q-earth-science-astronomy-plate-tectonics-0003` (NEEDS AEDWON): Named/date history untaught; 1959 date is unsupported by checked USGS chronology (model 1960, publication 1962); stem, choices, key preserved.
- `q-earth-science-astronomy-plate-tectonics-0005` (CORRECTED): Original claimed one 1959 discovery supplied the entire force and acceptance mechanism.
- `q-earth-science-astronomy-plate-tectonics-0016` (VERIFIED): Original explanation falsely described wholesale melting of the subducting plate.
- `q-earth-science-astronomy-weather-and-climate-0015` (CORRECTED): Original treated frequent typhoons as defining Habagat and implied rigid dates.
- `q-earth-science-astronomy-weather-and-climate-0016` (CORRECTED): Original wrongly presented Amihan as generally dry without the eastern rainfall distinction.
- `q-earth-science-astronomy-weather-and-climate-0017` (CORRECTED): Original used typhoon conditions as a monsoon definition; duplicate identification replaced.
- `q-earth-science-astronomy-weather-and-climate-0018` (CORRECTED): Original reinforced universally dry Amihan; now tests regional rainfall.
- `q-earth-science-astronomy-weather-and-climate-0020` (CORRECTED): Original key incorrectly described greenhouse action as trapping incoming solar heat.
- `q-earth-science-astronomy-weather-and-climate-0022` (CORRECTED): Original assigned a typhoon to a monsoon; replaced with year-round cyclone interpretation.
- `q-physics-dynamics-0011` (CORRECTED): Original stated N=mg without requiring zero vertical acceleration; duplicate normal-force item replaced.
- `q-physics-electricity-and-magnetism-0011` (CORRECTED): Original conditional equal-resistance choice was also defensible; now specifies unequal resistors.
- `q-physics-electricity-and-magnetism-0014` (CORRECTED): Original viewing instruction contradicted upward current viewed from above; clarified perspective.
- `q-physics-fluid-mechanics-0006` (CORRECTED): Original presented lower pressure at higher speed as universal and called it an inverse relation.
- `q-physics-fluid-mechanics-0007` (CORRECTED): Original notes claimed curvature forces faster airflow; replaced with measured pressure difference.
- `q-physics-fluid-mechanics-0008` (CORRECTED): Original explanation said no object property affects buoyancy; displaced volume does depend on immersion.
- `q-physics-fluid-mechanics-0010` (CORRECTED): Original unqualified Bernoulli claim ignored height, pumps, and flow assumptions.
- `q-physics-gravity-and-keplers-laws-0004` (CORRECTED): Original explanation excluded circles even though they are a special case of ellipses.
- `q-physics-gravity-and-keplers-laws-0006` (CORRECTED): Original used undefined average distance instead of semimajor axis.
- `q-physics-gravity-and-keplers-laws-0008` (CORRECTED): Original used ambiguous three times longer and undefined distance for different unspecified central masses.
- `q-physics-gravity-and-keplers-laws-0011` (CORRECTED): Original applied variable speed to all ellipses without the circular special case.
- `q-physics-kinematics-0005` (CORRECTED): Original wrong-choice note named arithmetic that did not produce its stated value; corrected choice or note.
- `q-physics-kinematics-0007` (CORRECTED): Original wrong-choice note named arithmetic that did not produce its stated value; corrected choice or note.
- `q-physics-kinematics-0012` (CORRECTED): Original wrong-choice note named arithmetic that did not produce its stated value; corrected choice or note.
- `q-physics-light-and-optics-0004` (CORRECTED): Original lens rule omitted refractive index relative to surroundings; now specifies ordinary glass in air.
- `q-physics-light-and-optics-0006` (CORRECTED): Original lens rule omitted refractive index relative to surroundings; now specifies ordinary glass in air.
- `q-physics-light-and-optics-0012` (CORRECTED): Original lens rule omitted refractive index relative to surroundings; now specifies ordinary glass in air.
- `q-physics-momentum-and-impulse-0002` (CORRECTED): Original note claimed 5 times 0.2 produces 2; corrected to 1.
- `q-physics-momentum-and-impulse-0003` (CORRECTED): Original note claimed division by stationary mass produces 1; replaced with mass-unweighted average.
- `q-physics-momentum-and-impulse-0006` (CORRECTED): Original used a closed-system claim without requiring negligible external impulse.
- `q-physics-momentum-and-impulse-0008` (CORRECTED): Original presented J=Ft without qualifying constant or average force.
- `q-physics-momentum-and-impulse-0010` (CORRECTED): Original vector-momentum comparison lacked directions; now asks for magnitudes.
- `q-physics-momentum-and-impulse-0013` (CORRECTED): Original unsigned sum gives 4.4, not the listed 2.2; corrected distractor.
- `q-physics-scalars-and-vectors-0001` (CORRECTED): Original classified the quantity by presence or absence of a direction word; now names path length or displacement.
- `q-physics-scalars-and-vectors-0002` (CORRECTED): Original classified the quantity by presence or absence of a direction word; now names path length or displacement.
- `q-physics-thermodynamics-0007` (CORRECTED): Original gave a broad entropy limit without the pure, perfect-crystal condition.
- `q-physics-thermodynamics-0012` (CORRECTED): Original compared heating rates without controlling mass and heat input.
- `q-physics-thermodynamics-0015` (CORRECTED): Original omitted equal masses and initial temperatures, so the hotter sample was not determined.
- `q-physics-two-dimensional-motion-0002` (CORRECTED): Original 0.882 note incorrectly named missing time square; replaced repeated setup with a two-step height problem.
- `q-physics-two-dimensional-motion-0013` (CORRECTED): Original nonzero horizontal claim did not explicitly exclude a vertical launch; now states a nonzero horizontal component.
- `q-physics-units-and-measurements-0007` (CORRECTED): Original note claimed 90 times 3.6 gives 32.4; corrected the computed distractor.
- `q-physics-units-and-measurements-0011` (CORRECTED): Original wrongly claimed kilometers divided by seconds is inherently meaningless; now corrects mislabeled output.
- `q-physics-waves-and-sound-0007` (CORRECTED): Mechanical wave was also a defensible choice and the explanation described light as moving medium particles.
- `q-physics-waves-and-sound-0008` (CORRECTED): Standing-wave option could also describe a longitudinal disturbance; now asks only orientation.
- `q-physics-waves-and-sound-0012` (CORRECTED): Original generalized air’s longitudinal sound to all media; solids can support transverse modes.
- `q-physics-work-energy-power-0004` (CORRECTED): Original notes named arithmetic that did not produce 19.6 or 3.13; corrected distractors.
- `q-physics-work-energy-power-0011` (CORRECTED): Kinetic energy determines speed, not velocity direction; changed requested quantity and incorrect arithmetic note.
- `q-physics-work-energy-power-0014` (CORRECTED): Original assumed zero potential energy at the bottom without specifying that reference.

## Every NEEDS AEDWON item

- `q-biology-characteristics-of-life-0013` (HIGH): Lesson does not teach this distinction; preserved keyed choice incorrectly requires two parents and remains longest. Explanation now qualifies self-fertilization; false sexual-bacterial claim removed from notes.
- `q-biology-genetics-and-heredity-0008` (MEDIUM): Lesson does not teach the RNA base alphabet or T/U distinction. Stem, choices, and key preserved; explanation and notes now follow the required shape.
- `q-biology-genetics-and-heredity-0013` (MEDIUM): Lesson does not teach the RNA base alphabet or T/U distinction. Stem, choices, and key preserved; explanation and notes now follow the required shape.
- `q-biology-human-anatomy-physiology-0008` (MEDIUM): Lesson names urea but does not teach its protein-breakdown origin. Stem, choices, and key preserved; explanation and notes corrected.
- `q-biology-human-anatomy-physiology-0015` (MEDIUM): Lesson names heart chambers but does not teach receiving versus pumping roles. Stem, choices, and key preserved; explanation and notes reshaped.
- `q-earth-science-astronomy-earths-motions-0012` (MEDIUM): Lesson does not name Polaris. Stem, choices, key, and longest-answer cue preserved; explanation/notes corrected. Source: https://science.nasa.gov/solar-system/what-is-the-north-star-and-how-do-you-find-it/
- `q-earth-science-astronomy-fossils-and-geologic-time-0002` (HIGH): Lesson does not teach fossil preservation by rock-formation conditions. Stem/choices/key preserved; original explanation wrongly excluded every metamorphosed fossil.
- `q-earth-science-astronomy-fossils-and-geologic-time-0003` (MEDIUM): Lesson title names stratigraphy but the teaching text does not define the discipline; stem/choices/key preserved, including weak Paleontology dating label.
- `q-earth-science-astronomy-fossils-and-geologic-time-0014` (MEDIUM): Lesson does not teach the complete eon-era-period-epoch hierarchy; stem/choices/key preserved.
- `q-earth-science-astronomy-fossils-and-geologic-time-0016` (MEDIUM): Lesson does not teach Paleozoic first-fish, land-plant, or reptile history; stem/choices/key and length cue preserved.
- `q-earth-science-astronomy-fossils-and-geologic-time-0018` (MEDIUM): Lesson does not teach the human-evolution/current-era part of this item; stem/choices/key preserved.
- `q-earth-science-astronomy-fossils-and-geologic-time-0021` (HIGH): Lesson lacks early-fish/Paleozoic teaching; isotope clock unspecified and not necessarily layer-deposition age. Stem/choices/key and longest cue preserved.
- `q-earth-science-astronomy-heavenly-bodies-0015` (MEDIUM): Halley's period is accurate per NASA but absent from the lesson; stem, choices, key preserved.
- `q-earth-science-astronomy-layers-of-the-earth-0006` (MEDIUM): Magnetic field generation is not taught; stem, choices, key preserved; overlaps item 0014.
- `q-earth-science-astronomy-layers-of-the-earth-0014` (MEDIUM): Global field generation absent from lesson; stem, choices, key preserved; duplicate of 0006 and longest-answer cue retained.
- `q-earth-science-astronomy-minerals-and-rocks-0003` (MEDIUM): Mohs scale is not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0004` (MEDIUM): Scratch hardness tests are not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0005` (MEDIUM): Streak is not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0006` (MEDIUM): Pyrite/streak tests are not taught; stem, choices, key preserved, including longest-answer cue.
- `q-earth-science-astronomy-minerals-and-rocks-0007` (MEDIUM): Luster is not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0008` (MEDIUM): Cleavage/fracture are not taught; stem, choices, key preserved.
- `q-earth-science-astronomy-minerals-and-rocks-0018` (HIGH): Hardness/streak absent from lesson; equal nominal reference hardness makes scratch bounds inconsistent; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0002` (HIGH): History is untaught; 1927 expanding-universe work is conflated with 1931 primeval-atom proposal; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0003` (MEDIUM): Named historical discovery is untaught; stem, choices, key preserved.
- `q-earth-science-astronomy-origin-of-the-universe-0007` (HIGH): History is untaught; retained key conflates 1927 expansion work with later Big Bang origin proposal; overlaps 0002.
- `q-earth-science-astronomy-plate-tectonics-0003` (HIGH): Named/date history untaught; 1959 date is unsupported by checked USGS chronology (model 1960, publication 1962); stem, choices, key preserved.
- `q-earth-science-astronomy-plate-tectonics-0012` (MEDIUM): Arrival order appears in lesson figure, but solid/liquid transmission is untaught; stem, choices, key preserved.
- `q-earth-science-astronomy-plate-tectonics-0013` (MEDIUM): Solid/liquid transmission is untaught; stem, choices, key preserved.
- `q-earth-science-astronomy-plate-tectonics-0014` (MEDIUM): Wave-transmission properties untaught; stem, choices, key preserved; overlap with 0012/0013 and answer-length cue retained.
- `q-earth-science-astronomy-plate-tectonics-0017` (MEDIUM): Hotspot volcanism is untaught; stem, choices, key preserved, including longest-answer cue.
- `q-earth-science-astronomy-plate-tectonics-0018` (MEDIUM): Density contrast as a subduction cause is untaught; stem, choices, key preserved, including answer-length cue.
- `q-earth-science-astronomy-plate-tectonics-0019` (MEDIUM): Core-state seismology is untaught; stem, choices, key preserved; duplicates layer lesson and retains answer-length cue.
- `q-earth-science-astronomy-plate-tectonics-0020` (MEDIUM): Hotspots and collision landforms are not fully taught; stem, choices, key preserved, including answer-length cue.

## Verification evidence

Commands ran locally in the assigned worktree. The full-bank importer ran after each resumed lesson correction. Its output was redirected to avoid printing the converted bank. The final importer run also parsed emitted JSON in memory to verify actual `isActive` values.

Command:

```sh
dart run tools/import_questions/import_questions.dart --root content/questions > /dev/null
```

Final command output and checks:

```text
full-bank importer exit: 0
Running build hooks...Running build hooks...
science checks: lessons=51 questions=1023 active=1023 complete_ledgers=51 issues=0
active range: 20 to 22
ids/approvals/pending stems and keys: preserved
audit baseline: 1f79d880264e9c80c7507c95a365126d251c3837
status counts: {'VERIFIED': 107, 'CORRECTED': 637, 'NEW': 246, 'NEEDS AEDWON': 33}
severity counts: {'NONE': 348, 'HIGH': 204, 'LOW': 82, 'MEDIUM': 389}
high pending: 7
```

The supplemental checks compared YAML IDs with every ledger row, required valid ledger values and notes for non-NONE severities, checked every choice note, checked math delimiters and forbidden formatting, searched for position-dependent choices and duplicate exact stems, and compared existing IDs, approval values, and protected question text against the audit baseline. All 51 ledgers passed.

Command:

```sh
dart run tool/check_no_ai_attribution.dart
```

Actual output:

```text
Running build hooks...Running build hooks...
check_no_ai_attribution: OK
```

`git diff --check` exited 0 with no output.

## Files changed and remaining limits

Only science question YAML, corresponding science ledgers, and this summary were changed. No application code, tools, tests, lessons, seeds, or other subject files were changed.

No Part 6 stop condition remains. No missing science blueprint or unsupported figure kind blocked completion. Lesson-content gaps are listed individually under NEEDS AEDWON. The full-bank importer reported no error in another subject.

This is implementor completion. The approved 1 October decision waives a separate review of Codex's output. Combined acceptance, integration, protected-package rebuilding and signing, and publication belong to the orchestrator. This worker did not push or merge.

No application test suite, analyzer run, seed rebuild, phone check, emulator check, Question Studio approval, or visual acceptance was performed in this content-only assignment. The new questions remain unapproved as explicitly required. The seven protected HIGH findings still need a content decision; this summary does not certify those retained statements as correct.
