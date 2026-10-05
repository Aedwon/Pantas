# Chemistry lesson structure audit

Status: COMPLETE. Findings and recommendations only. Independent review pending; no Level 3 acceptance claimed.

## Identity and read log

Original author policy: main `cb48097bedf15bec2cfbe4fb3aa7e957753b1727`, live remote and cached policy matched October 5, 2026. Corpus: `765c5dc0fa5586281047bf4f7b30d09ab3707887`, clean pinned worktree. Audit branch: docs/content-coverage-audit-r1; startup HEAD 7d5f2ed6a6d6f30e35d1b3f64467f31e7d122112. Other authors' dirty outputs preserved. Watcher owns Git mutations.

Read main AGENTS, WORKFLOW, SUBAGENTS, startup, source policy, checklist and lesson guide; audit reader contract, approved spec/plan, orchestrator, October 4 and latest Level 3 decisions, illustration decision; accepted UPCAT/DCAT/ACET/USTET/PUPCET/DOST/SM requirements and Level 2 overlap/scope notes. Historical pending labels in requirement files do not override accepted Level 1 gate. Inventory supplies search leads only.

All evidence paths below are relative to the pinned corpus, with inclusive 1-based lines. Full-read SHA256 and ranges are in the appendix. B03/L01/L17/L19 references describe structural teaching findings only, not a Level 4 standards pass. Questions, answer keys, embedded quizzes, illustration assessment and runtime were not examined.

## Exam scope and shared teaching

Teach each chemistry core once. UPCAT and USTET officially name broad Science; their finer chemistry skills/depth remain unknown. DOST names Chemistry only in the historical 2026 primer; current 2027 continuity is unknown. DCAT/PUPCET Science rosters are weak, and SM separate Science remains unknown. ACET science is conditional background with no confirmed Science component. Curriculum preparation is inferred, never a uniform exam blueprint. JHS matter, particles, equations and simple mole/gas relationships form shared preparation. SHS polarity, yield, equilibrium and household chemistry retain track/cohort/completion limits. Lesson bodies are English; exam Science languages remain unknown where organizers do not publish them. No exam-specific excess or exclusion follows from silence. Availability is unknown, practice is deferred Level 5.

## Main recommendations and unresolved gaps

- Retain shared introductory chemistry once; no supported exam-specific deletion or excess verdict follows from current unknown depth.
- Split candidate: separate composition-to-formula inference from reaction quantities in stoichiometry. This improves goal focus and a basic-to-extended preparation route, at the cost of a new approved lesson identity, moved examples/traps, and later linked-practice review.
- Reorder candidate: teach Lewis construction before deriving VSEPR groups. Definitions alone cannot supply this foundation (L01/L17/L19). No full Lewis, formal-charge or resonance procedure appears in the 17 chemistry bodies.
- Local gaps: dilution, dynamic chemical equilibrium, Kinetic Molecular Theory, molecular dipole cancellation/intermolecular reasoning, and experimental variable/data interpretation. Their source tiers and exam-depth uncertainties remain explicit.
- Thin applications: branched organic naming, concrete functional-group/property comparisons, simple reaction product mole/mass chains, theoretical yield derived from reactants, and concentration-to-pH use. Periodic-table named families are not explained despite the outline facet (B03/L01 structural use).
- Biomolecule/safety coverage is absent locally. Whole inventory identifies biology and other safety/background search leads; the lead must reconcile other topic findings before any corpus-wide gap claim.
- No load-bearing figure dependencies encountered: all chemistry example prompts supply enough textual givens to be attempted. This is neither an illustration-sufficiency verdict nor runtime verification.
- Prerequisites use existing IDs and both-end evidence only. Missing Lewis/equilibrium foundations have no invented lesson targets. Intralesson ordering is separate. Basic mathematical literacy is assumed; no unsupported arithmetic roadmap edge is asserted.
- Required depth, Science language, cohort exposure, current cycle continuity, student availability and practice remain unresolved. Source checks here are bounded encountered facts, not a Level 4 correctness sweep.

Accepted source packets: [UPCAT](../requirements/upcat.md), [DCAT](../requirements/dcat.md), [ACET](../requirements/acet.md), [USTET](../requirements/ustet.md), [PUPCET](../requirements/pupcet.md), [DOST-SEI](../requirements/dost-sei.md), [SM Foundation](../requirements/sm-foundation.md). Each cited requirement ID corresponds to its packet line; its source tier, page/section and limitations govern. Source scope: [DepEd JHS Science](https://www.deped.gov.ph/wp-content/uploads/2019/01/Science-CG_with-tagged-sci-equipment_revised.pdf), pp. 7-10, 163, 196; [Physical Science listing](https://lrmds.deped.gov.ph/detail/14519), competencies; [STEM Chemistry listing](https://lrmds.deped.gov.ph/detail/14411), competencies; [Strengthened General Science](https://www.deped.gov.ph/wp-content/uploads/GENERAL-SCIENCE-1.pdf), pp. 4-5. Historical domain: [DOST 2026 primer](https://science-scholarships.ph/pdf/2026_DOST-SEI_UG_Primer.pdf), p. 12. These accepted-source links are traceability, not new live source checks or an official detailed blueprint.

## Lesson findings

### lesson-chemistry-acids-bases-ph

Goal: Distinguish introductory acid/base models, interpret pH and strength, and explain simple neutralization. This supports weak UPCAT and specialized DOST preparation, not a current depth claim.

- Arrhenius and proton-transfer definitions: explained; examples thin. content/lessons/science/chemistry/acids-bases-ph.md:12-18 (Arrhenius and proton-transfer definitions teaching); content/lessons/science/chemistry/acids-bases-ph.md:94-105 (Arrhenius and proton-transfer definitions example). Limits: No worked donor/acceptor identification in a non-hydroxide reaction. Requirement refs: upcat-L145, dost-sei-L106.
- pH classification and logarithmic activity comparison: explained; examples worked. content/lessons/science/chemistry/acids-bases-ph.md:20-40 (pH classification and logarithmic activity comparison teaching); content/lessons/science/chemistry/acids-bases-ph.md:64-83 (pH classification and logarithmic activity comparison example). Limits: No direct concentration-to-pH worked example; acid-base equilibrium solving not taught. Requirement refs: upcat-L145, dost-sei-L106.
- Strong versus weak and concentration distinction: explained; examples worked. content/lessons/science/chemistry/acids-bases-ph.md:42-46 (Strong versus weak and concentration distinction teaching); content/lessons/science/chemistry/acids-bases-ph.md:85-92 (Strong versus weak and concentration distinction example). Requirement refs: upcat-L145, dost-sei-L106.
- Neutralization and spectator ions: explained; examples worked. content/lessons/science/chemistry/acids-bases-ph.md:48-60 (Neutralization and spectator ions teaching); content/lessons/science/chemistry/acids-bases-ph.md:94-105 (Neutralization and spectator ions example). Limits: No titration or quantitative neutralization calculation; required depth unknown. Requirement refs: upcat-L145, dost-sei-L106.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/acids-bases-ph.md:10-141.

Prerequisites: none-found. No strictly necessary existing-lesson link found; any intralesson ordering is separate.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-atomic-structure

Goal: Use proton, neutron and electron counts to distinguish elements, isotopes and monatomic ions for shared introductory chemistry preparation.

- Particle location and charge: explained; examples worked. content/lessons/science/chemistry/atomic-structure.md:12-20 (Particle location and charge teaching); content/lessons/science/chemistry/atomic-structure.md:58-67 (Particle location and charge example). Requirement refs: upcat-L161, ustet-L114, pupcet-L114, dost-sei-L099, sm-foundation-L137.
- Atomic number and mass number: explained; examples worked. content/lessons/science/chemistry/atomic-structure.md:24-38 (Atomic number and mass number teaching); content/lessons/science/chemistry/atomic-structure.md:58-67 (Atomic number and mass number example). Requirement refs: upcat-L144, ustet-L114, pupcet-L114, dost-sei-L106.
- Isotopes versus isotope-weighted atomic mass: explained; examples worked. content/lessons/science/chemistry/atomic-structure.md:40-44 (Isotopes versus isotope-weighted atomic mass teaching); content/lessons/science/chemistry/atomic-structure.md:69-76 (Isotopes versus isotope-weighted atomic mass example). Limits: Weighted atomic mass calculation not demonstrated; exact needed depth unknown. Requirement refs: upcat-L144, pupcet-L114, dost-sei-L106.
- Ion charge and electron counts: explained; examples worked. content/lessons/science/chemistry/atomic-structure.md:46-54 (Ion charge and electron counts teaching); content/lessons/science/chemistry/atomic-structure.md:78-95 (Ion charge and electron counts example). Requirement refs: upcat-L161, ustet-L114, pupcet-L114, dost-sei-L106.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/atomic-structure.md:10-129.

Prerequisites: none-found. No strictly necessary existing-lesson link found; any intralesson ordering is separate.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-basic-organic-chemistry

Goal: Classify hydrocarbons, identify common functional-group families and interpret simple naming limits for carbon-compound preparation.

- Organic scope and carbon frameworks: explained; examples not-required. content/lessons/science/chemistry/basic-organic-chemistry.md:12-14 (Organic scope and carbon frameworks teaching). Requirement refs: upcat-L146, upcat-L161, pupcet-L115.
- Hydrocarbon families and ring saturation: explained; examples worked. content/lessons/science/chemistry/basic-organic-chemistry.md:16-32 (Hydrocarbon families and ring saturation teaching); content/lessons/science/chemistry/basic-organic-chemistry.md:67-94 (Hydrocarbon families and ring saturation example). Requirement refs: upcat-L146, upcat-L161, pupcet-L115.
- Functional groups and structure-property reasoning: thin; examples thin. content/lessons/science/chemistry/basic-organic-chemistry.md:34-45 (L01 structural teaching assessment: Functional groups and structure-property reasoning); content/lessons/science/chemistry/basic-organic-chemistry.md:96-104 (Functional groups and structure-property reasoning example). Limits: Aldehyde versus ketone environments not defined; no concrete structures or property comparison derived from a named pair. Requirement refs: upcat-L146, upcat-L161, dcat-L079.
- Simple IUPAC parent selection and substituent naming: thin; examples thin. content/lessons/science/chemistry/basic-organic-chemistry.md:47-63 (L01 structural teaching assessment: Simple IUPAC parent selection and substituent naming); content/lessons/science/chemistry/basic-organic-chemistry.md:81-86 (Simple IUPAC parent selection and substituent naming example). Limits: No branched structure, numbering decision, substituent locants or complete worked branched name. Requirement refs: upcat-L146.
- Carbon compounds and biomolecule relationships: absent; examples none. content/lessons/science/chemistry/basic-organic-chemistry.md:12-63 (L01 structural teaching assessment: Carbon compounds and biomolecule relationships). Limits: Biomolecule classes and structure-function relationships are not taught in this chemistry lesson; biology overlap needs lead reconciliation. Requirement refs: upcat-L161, pupcet-L115, dcat-L079.

Structure: retain. Families and naming form a coherent introductory organic goal, but naming is only partly taught (L01/L19). Proposal: Retain shared overview and deepen the concrete naming/property reasoning before considering a naming extension. Cost: Requires added teaching and examples under later approval; separating current thin material alone would not fix it.

Evidence: content/lessons/science/chemistry/basic-organic-chemistry.md:34-112.

Prerequisites: none-found. No strictly necessary existing-lesson link found; any intralesson ordering is separate.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-chemical-bonding

Goal: Classify bonding models and predict basic electron-group and molecular geometries while distinguishing bond polarity from deeper molecular properties.

- Ionic covalent and metallic bonding: explained; examples worked. content/lessons/science/chemistry/chemical-bonding.md:12-20 (Ionic covalent and metallic bonding teaching); content/lessons/science/chemistry/chemical-bonding.md:68-76 (Ionic covalent and metallic bonding example). Requirement refs: upcat-L144, upcat-L161, dcat-L079, ustet-L114, pupcet-L114, dost-sei-L104, dost-sei-L106.
- Octet guideline and exceptions: explained; examples not-required. content/lessons/science/chemistry/chemical-bonding.md:24-36 (Octet guideline and exceptions teaching). Requirement refs: upcat-L144, dost-sei-L106.
- Bond polarity and electronegativity: explained; examples worked. content/lessons/science/chemistry/chemical-bonding.md:38-44 (Bond polarity and electronegativity teaching); content/lessons/science/chemistry/chemical-bonding.md:78-86 (Bond polarity and electronegativity example). Limits: Electronegativity term not defined locally; periodic-table teaching supplies it. Requirement refs: upcat-L144, dcat-L082, dost-sei-L104.
- Lewis structures formal charge and resonance: named-only; examples none. content/lessons/science/chemistry/chemical-bonding.md:46-50 (L01 structural teaching assessment: Lewis structures formal charge and resonance). Limits: No valence-electron counting procedure, actual Lewis construction, formal-charge formula or resonance worked structure. Requirement refs: upcat-L144, dost-sei-L106.
- VSEPR geometry from supplied electron groups: explained; examples worked. content/lessons/science/chemistry/chemical-bonding.md:52-64 (VSEPR geometry from supplied electron groups teaching); content/lessons/science/chemistry/chemical-bonding.md:88-107 (VSEPR geometry from supplied electron groups example). Limits: Examples supply groups; learner cannot derive groups from a formula without Lewis construction. Requirement refs: upcat-L144, dcat-L082, dost-sei-L104.
- Molecular polarity from bond dipoles and geometry: absent; examples none. content/lessons/science/chemistry/chemical-bonding.md:38-64 (L01 structural teaching assessment: Molecular polarity from bond dipoles and geometry). Limits: Bond polarity and geometry are taught separately; their combined molecular-polarity decision is absent. Requirement refs: dcat-L079, dcat-L082, ustet-L123, pupcet-L123, dost-sei-L104, sm-foundation-L141.
- Intermolecular forces and hydrogen bonding: absent; examples none. content/lessons/science/chemistry/chemical-bonding.md:12-64 (L01 structural teaching assessment: Intermolecular forces and hydrogen bonding). Limits: No force-type or hydrogen-bond explanation connects molecular structure to physical properties. Requirement refs: dcat-L079, dcat-L082, ustet-L123, pupcet-L123, dost-sei-L104, sm-foundation-L141.
- Bonding model to material properties: thin; examples none. content/lessons/science/chemistry/chemical-bonding.md:14-20 (L01 structural teaching assessment: Bonding model to material properties). Limits: Metallic conductivity and malleability are linked; no worked structure-to-solubility or boiling-point comparison. Requirement refs: dcat-L079, dcat-L082, ustet-L123, pupcet-L123, dost-sei-L104, sm-foundation-L141.

Structure: reorder. Bond models are coherent, but geometry assumes Lewis-building knowledge that the lesson only names (L01/L17/L19). Proposal: Teach valence-count and Lewis construction before VSEPR; keep the shared core together. Consider a separate molecular-properties extension only after defining its teaching. Cost: Add procedural teaching and revise geometry examples; a new unit would need separate approval and shared-core routing.

Evidence: content/lessons/science/chemistry/chemical-bonding.md:46-107.

Prerequisites: links-found. lesson-chemistry-atomic-structure because Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity. Consumer: content/lessons/science/chemistry/chemical-bonding.md:12-18; foundation: content/lessons/science/chemistry/atomic-structure.md:12-18. Missing foundations: Lewis-structure construction and formal-charge procedure must precede deriving geometry; this is a missing local foundation, not an existing prerequisite link.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-chemical-nomenclature

Goal: Name simple ionic and binary molecular compounds, infer variable ion charges and write charge-balanced formulas for specialized chemistry preparation.

- Ionic and Stock naming: explained; examples worked. content/lessons/science/chemistry/chemical-nomenclature.md:14-27 (Ionic and Stock naming teaching); content/lessons/science/chemistry/chemical-nomenclature.md:69-87 (Ionic and Stock naming example). Requirement refs: dost-sei-L106.
- Polyatomic ions and related oxyanion names: explained; examples worked. content/lessons/science/chemistry/chemical-nomenclature.md:25-31 (Polyatomic ions and related oxyanion names teaching); content/lessons/science/chemistry/chemical-nomenclature.md:99-107 (Polyatomic ions and related oxyanion names example). Requirement refs: dost-sei-L106.
- Binary molecular prefixes and names: explained; examples worked. content/lessons/science/chemistry/chemical-nomenclature.md:33-49 (Binary molecular prefixes and names teaching); content/lessons/science/chemistry/chemical-nomenclature.md:89-97 (Binary molecular prefixes and names example). Requirement refs: dost-sei-L106.
- Charge-balanced simplest ionic formulas: explained; examples worked. content/lessons/science/chemistry/chemical-nomenclature.md:51-65 (Charge-balanced simplest ionic formulas teaching); content/lessons/science/chemistry/chemical-nomenclature.md:99-118 (Charge-balanced simplest ionic formulas example). Requirement refs: dost-sei-L106.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/chemical-nomenclature.md:10-152.

Prerequisites: links-found. lesson-chemistry-atomic-structure because Naming assumes cation/anion and signed ion charge rather than introducing them. Consumer: content/lessons/science/chemistry/chemical-nomenclature.md:16-29; foundation: content/lessons/science/chemistry/atomic-structure.md:46-54.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-chemical-reactions

Goal: Balance simple equations by atom conservation and classify common reaction patterns without treating labels as exclusive.

- Atom conservation and coefficient balancing: explained; examples worked. content/lessons/science/chemistry/chemical-reactions.md:12-18 (Atom conservation and coefficient balancing teaching); content/lessons/science/chemistry/chemical-reactions.md:56-91 (Atom conservation and coefficient balancing example). Requirement refs: upcat-L161, dcat-L085, ustet-L114, pupcet-L115, dost-sei-L104.
- Combination decomposition and single displacement: explained; examples worked. content/lessons/science/chemistry/chemical-reactions.md:20-26 (Combination decomposition and single displacement teaching); content/lessons/science/chemistry/chemical-reactions.md:40-54 (Combination decomposition and single displacement example). Requirement refs: upcat-L143, ustet-L125, pupcet-L123, sm-foundation-L137.
- Double displacement and driving-force reasoning: explained; examples thin. content/lessons/science/chemistry/chemical-reactions.md:27-27 (Double displacement and driving-force reasoning teaching); content/lessons/science/chemistry/chemical-reactions.md:93-99 (Double displacement and driving-force reasoning example). Limits: No concrete precipitation or net-ionic derivation; solubility rules not supplied. Requirement refs: upcat-L143, ustet-L125, dost-sei-L104.
- Complete and incomplete combustion: explained; examples worked. content/lessons/science/chemistry/chemical-reactions.md:28-36 (Complete and incomplete combustion teaching); content/lessons/science/chemistry/chemical-reactions.md:69-81 (Complete and incomplete combustion example). Requirement refs: upcat-L143, ustet-L125, pupcet-L115.
- Redox and oxidation-state reasoning: named-only; examples none. content/lessons/science/chemistry/chemical-reactions.md:22-28 (L01 structural teaching assessment: Redox and oxidation-state reasoning). Limits: Examples label redox without defining electron transfer or showing oxidation-state changes; charge in nomenclature does not teach general redox. Requirement refs: upcat-L145.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/chemical-reactions.md:10-133.

Prerequisites: none-found. No strictly necessary existing-lesson link found; any intralesson ordering is separate.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-gas-laws

Goal: Choose an ideal gas relationship from fixed quantities, use absolute temperature, and solve pressure-volume-temperature or amount problems.

- Gas-law conditions and fixed quantities: explained; examples worked. content/lessons/science/chemistry/gas-laws.md:12-58 (Gas-law conditions and fixed quantities teaching); content/lessons/science/chemistry/gas-laws.md:62-106 (Gas-law conditions and fixed quantities example). Requirement refs: upcat-L161, dcat-L079, ustet-L114, pupcet-L115, dost-sei-L099.
- Kelvin conversion and absolute-temperature reasoning: explained; examples none. content/lessons/science/chemistry/gas-laws.md:14-16 (Kelvin conversion and absolute-temperature reasoning teaching). Limits: Examples already supply kelvin; conversion application is not worked. Requirement refs: upcat-L161, dcat-L079, dost-sei-L099.
- Boyle inverse pressure-volume relationship: explained; examples worked. content/lessons/science/chemistry/gas-laws.md:18-22 (L01 local facet: Boyle inverse pressure-volume relationship); content/lessons/science/chemistry/gas-laws.md:62-72 (L19 worked local facet: Boyle inverse pressure-volume relationship). Requirement refs: upcat-L145, upcat-L161, dcat-L079, ustet-L114, dost-sei-L099.
- Charles direct volume-temperature relationship: explained; examples worked. content/lessons/science/chemistry/gas-laws.md:24-28 (L01 local facet: Charles direct volume-temperature relationship); content/lessons/science/chemistry/gas-laws.md:74-82 (L19 worked local facet: Charles direct volume-temperature relationship). Requirement refs: upcat-L145, upcat-L161, dcat-L079, ustet-L114, dost-sei-L099.
- Amontons/Gay-Lussac pressure-temperature relationship: explained; examples none. content/lessons/science/chemistry/gas-laws.md:30-36 (L01 local facet: Amontons/Gay-Lussac pressure-temperature relationship). Limits: No worked pressure-temperature problem. Requirement refs: upcat-L161, dcat-L079, dost-sei-L099.
- Avogadro volume-amount relationship: explained; examples none. content/lessons/science/chemistry/gas-laws.md:38-44 (L01 local facet: Avogadro volume-amount relationship). Limits: No worked volume-amount problem. Requirement refs: upcat-L161, dcat-L079, dost-sei-L099.
- Combined fixed-amount gas-state calculation: explained; examples worked. content/lessons/science/chemistry/gas-laws.md:48-52 (L01 local facet: Combined fixed-amount gas-state calculation); content/lessons/science/chemistry/gas-laws.md:84-94 (L19 worked local facet: Combined fixed-amount gas-state calculation). Requirement refs: upcat-L145, dcat-L085, ustet-L114, dost-sei-L107.
- Ideal gas amount calculation and units: explained; examples worked. content/lessons/science/chemistry/gas-laws.md:54-58 (L01 local facet: Ideal gas amount calculation and units); content/lessons/science/chemistry/gas-laws.md:96-106 (L19 worked local facet: Ideal gas amount calculation and units). Requirement refs: upcat-L145, dcat-L085, ustet-L114, dost-sei-L107.
- Kinetic Molecular Theory explanation of gas relationships: absent; examples none. content/lessons/science/chemistry/gas-laws.md:12-58 (L01 structural teaching assessment: Kinetic Molecular Theory explanation of gas relationships). Limits: No collision-based pressure, random particle motion or kinetic-energy model connects the equations to mechanism. Requirement refs: upcat-L161.
- Recognizing controlled quantities in gas comparisons: thin; examples thin. content/lessons/science/chemistry/gas-laws.md:18-44 (L01 structural teaching assessment: Recognizing controlled quantities in gas comparisons); content/lessons/science/chemistry/gas-laws.md:62-94 (Recognizing controlled quantities in gas comparisons example). Limits: Fixed variables are identified for formulas, not taught as independent/dependent/control variables in investigations. Requirement refs: dcat-L077, ustet-L113, acet-L126.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/gas-laws.md:10-140.

Prerequisites: links-found. lesson-chemistry-mole-concept because Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning. Consumer: content/lessons/science/chemistry/gas-laws.md:54-58, content/lessons/science/chemistry/gas-laws.md:96-104; foundation: content/lessons/science/chemistry/mole-concept.md:12-24.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-history-of-the-atom

Goal: Connect major atomic models to the observations they explained and identify the limits of historical models.

- Historical model changes and limits: explained; examples worked. content/lessons/science/chemistry/history-of-the-atom.md:12-53 (Historical model changes and limits teaching); content/lessons/science/chemistry/history-of-the-atom.md:57-69 (Historical model changes and limits example). Limits: History is supportive particle-model teaching, not proof chronology is tested. Requirement refs: upcat-L144, pupcet-L114, dost-sei-L099, sm-foundation-L137.
- Evidence-to-conclusion reasoning from scattering: explained; examples worked. content/lessons/science/chemistry/history-of-the-atom.md:30-39 (Evidence-to-conclusion reasoning from scattering teaching); content/lessons/science/chemistry/history-of-the-atom.md:71-80 (Evidence-to-conclusion reasoning from scattering example). Limits: Observation and inference are concrete; learner does not design controls or interpret a numeric data set. Requirement refs: dcat-L077, ustet-L113, acet-L126.
- Quantized versus modern probability models: explained; examples worked. content/lessons/science/chemistry/history-of-the-atom.md:41-53 (Quantized versus modern probability models teaching); content/lessons/science/chemistry/history-of-the-atom.md:82-90 (Quantized versus modern probability models example). Requirement refs: upcat-L144, dost-sei-L106.
- Isotopes challenge historical identical-mass claim: explained; examples worked. content/lessons/science/chemistry/history-of-the-atom.md:14-20 (Isotopes challenge historical identical-mass claim teaching); content/lessons/science/chemistry/history-of-the-atom.md:92-98 (Isotopes challenge historical identical-mass claim example). Requirement refs: upcat-L144, pupcet-L114.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/history-of-the-atom.md:10-136.

Prerequisites: none-found. No strictly necessary existing-lesson link found; any intralesson ordering is separate.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-matter

Goal: Classify matter and distinguish properties, physical/chemical changes and phase changes for shared introductory preparation.

- Element compound and mixture classification: explained; examples worked. content/lessons/science/chemistry/matter.md:14-21 (Element compound and mixture classification teaching); content/lessons/science/chemistry/matter.md:58-66 (Element compound and mixture classification example). Requirement refs: upcat-L143, upcat-L161, acet-L127, ustet-L114, pupcet-L114, dost-sei-L099, sm-foundation-L137.
- Bulk states and particle-state explanation: thin; examples none. content/lessons/science/chemistry/matter.md:23-33 (L01 structural teaching assessment: Bulk states and particle-state explanation). Limits: Bulk behavior is explained; particle spacing, movement and attractions largely reside in a figure marker or a crystal trap, not a causal particle account. Requirement refs: upcat-L161, ustet-L114, pupcet-L114, dost-sei-L099, sm-foundation-L137.
- Phase changes and energy direction: explained; examples worked. content/lessons/science/chemistry/matter.md:35-46 (Phase changes and energy direction teaching); content/lessons/science/chemistry/matter.md:68-75 (Phase changes and energy direction example). Requirement refs: upcat-L143, pupcet-L114.
- Physical versus chemical properties and changes: explained; examples worked. content/lessons/science/chemistry/matter.md:48-54 (Physical versus chemical properties and changes teaching); content/lessons/science/chemistry/matter.md:77-86 (Physical versus chemical properties and changes example). Requirement refs: upcat-L143, ustet-L114, pupcet-L114, sm-foundation-L137.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/matter.md:10-118.

Prerequisites: none-found. No strictly necessary existing-lesson link found; any intralesson ordering is separate.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-mixtures-and-separation

Goal: Choose a physical separation method from mixture type and component properties, recognizing ordinary method limits.

- Homogeneous heterogeneous and chemical identity: explained; examples worked. content/lessons/science/chemistry/mixtures-and-separation.md:12-16 (Homogeneous heterogeneous and chemical identity teaching); content/lessons/science/chemistry/mixtures-and-separation.md:54-62 (Homogeneous heterogeneous and chemical identity example). Requirement refs: upcat-L161, ustet-L114, pupcet-L114, dost-sei-L099, sm-foundation-L137.
- Filtration of suspended versus dissolved solids: explained; examples worked. content/lessons/science/chemistry/mixtures-and-separation.md:18-24 (Filtration of suspended versus dissolved solids teaching); content/lessons/science/chemistry/mixtures-and-separation.md:64-72 (Filtration of suspended versus dissolved solids example). Requirement refs: upcat-L161, ustet-L114, pupcet-L114, dost-sei-L099.
- Distillation volatility and separation limits: explained; examples worked. content/lessons/science/chemistry/mixtures-and-separation.md:26-34 (Distillation volatility and separation limits teaching); content/lessons/science/chemistry/mixtures-and-separation.md:74-82 (Distillation volatility and separation limits example). Limits: Vapor-liquid equilibrium is qualitative; quantitative mixtures or purity depth unknown. Requirement refs: upcat-L161, ustet-L114, dost-sei-L099.
- Chromatography phases and observation inference: explained; examples worked. content/lessons/science/chemistry/mixtures-and-separation.md:38-44 (Chromatography phases and observation inference teaching); content/lessons/science/chemistry/mixtures-and-separation.md:84-92 (Chromatography phases and observation inference example). Limits: Example infers multiple components but does not interpret measured chromatogram positions or experimental controls. Requirement refs: upcat-L161, ustet-L114, dcat-L077, ustet-L113, acet-L126.
- Evaporation versus crystallization: explained; examples worked. content/lessons/science/chemistry/mixtures-and-separation.md:46-50 (Evaporation versus crystallization teaching); content/lessons/science/chemistry/mixtures-and-separation.md:74-82 (Evaporation versus crystallization example). Requirement refs: upcat-L161, ustet-L114, pupcet-L114.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/mixtures-and-separation.md:10-139.

Prerequisites: none-found. No strictly necessary existing-lesson link found; any intralesson ordering is separate.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-mole-concept

Goal: Convert among mass, moles and specified entities, and derive molar mass from chemical composition for simple chemical-amount preparation.

- Mole and specified entity: explained; examples worked. content/lessons/science/chemistry/mole-concept.md:12-24 (Mole and specified entity teaching); content/lessons/science/chemistry/mole-concept.md:62-70 (Mole and specified entity example). Requirement refs: upcat-L161, dcat-L085, ustet-L114, pupcet-L115.
- Molar mass from formula: explained; examples worked. content/lessons/science/chemistry/mole-concept.md:26-32 (Molar mass from formula teaching); content/lessons/science/chemistry/mole-concept.md:48-54 (Molar mass from formula example). Requirement refs: upcat-L161, dcat-L085, ustet-L114, pupcet-L115.
- Mass-to-moles conversion: explained; examples worked. content/lessons/science/chemistry/mole-concept.md:34-38 (Mass-to-moles conversion teaching); content/lessons/science/chemistry/mole-concept.md:56-60 (Mass-to-moles conversion example). Requirement refs: upcat-L143, upcat-L161, dcat-L085, ustet-L114, pupcet-L115.
- Moles-to-entities and combined mass-to-entities: explained; examples worked. content/lessons/science/chemistry/mole-concept.md:40-44 (Moles-to-entities and combined mass-to-entities teaching); content/lessons/science/chemistry/mole-concept.md:62-78 (Moles-to-entities and combined mass-to-entities example). Requirement refs: upcat-L143, dcat-L085, ustet-L114, pupcet-L115.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/mole-concept.md:10-112.

Prerequisites: none-found. No strictly necessary existing-lesson link found; any intralesson ordering is separate.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-nuclear-chemistry

Goal: Track atomic/mass-number changes for common decay modes and distinguish fission from fusion under weak nuclear-preparation scope.

- Alpha and beta-minus daughter bookkeeping: explained; examples worked. content/lessons/science/chemistry/nuclear-chemistry.md:14-28 (Alpha and beta-minus daughter bookkeeping teaching); content/lessons/science/chemistry/nuclear-chemistry.md:65-81 (Alpha and beta-minus daughter bookkeeping example). Requirement refs: upcat-L146.
- Positron electron capture and gamma changes: explained; examples worked. content/lessons/science/chemistry/nuclear-chemistry.md:30-45 (Positron electron capture and gamma changes teaching); content/lessons/science/chemistry/nuclear-chemistry.md:83-92 (Positron electron capture and gamma changes example). Limits: Gamma has no separate applied example; no half-life calculation taught, and required nuclear depth unknown. Requirement refs: upcat-L146.
- Fission fusion and comparison basis: explained; examples worked. content/lessons/science/chemistry/nuclear-chemistry.md:49-61 (Fission fusion and comparison basis teaching); content/lessons/science/chemistry/nuclear-chemistry.md:94-102 (Fission fusion and comparison basis example). Requirement refs: upcat-L146.
- Radiation penetration versus hazard: explained; examples not-required. content/lessons/science/chemistry/nuclear-chemistry.md:21-45 (Radiation penetration versus hazard teaching). Requirement refs: upcat-L146.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/nuclear-chemistry.md:10-139.

Prerequisites: links-found. lesson-chemistry-atomic-structure because Decay updates A and Z and identifies new elements, relying on proton/neutron identity not introduced here. Consumer: content/lessons/science/chemistry/nuclear-chemistry.md:16-26; foundation: content/lessons/science/chemistry/atomic-structure.md:24-42.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-periodic-table

Goal: Use groups, periods and qualified periodic trends to compare elements for weak finer UPCAT preparation.

- Table groups periods and atomic-number ordering: explained; examples worked. content/lessons/science/chemistry/periodic-table.md:12-20 (Table groups periods and atomic-number ordering teaching); content/lessons/science/chemistry/periodic-table.md:40-48 (Table groups periods and atomic-number ordering example). Limits: Named families such as alkali metals, alkaline-earth metals, halogens and noble gases are not taught despite outline Families and Groups (B03 outline facet; L01 structural use only). Requirement refs: upcat-L144.
- Atomic-radius trends: explained; examples worked. content/lessons/science/chemistry/periodic-table.md:26-28 (Atomic-radius trends teaching); content/lessons/science/chemistry/periodic-table.md:50-58 (Atomic-radius trends example). Limits: Effective nuclear charge is invoked but shielding mechanism not explained. Requirement refs: upcat-L144.
- First ionization energy trends: explained; examples worked. content/lessons/science/chemistry/periodic-table.md:30-30 (First ionization energy trends teaching); content/lessons/science/chemistry/periodic-table.md:60-68 (First ionization energy trends example). Requirement refs: upcat-L144.
- Electronegativity meaning and trends: explained; examples none. content/lessons/science/chemistry/periodic-table.md:32-32 (Electronegativity meaning and trends teaching). Limits: No worked electronegativity comparison. Requirement refs: upcat-L144.
- Electron-affinity meaning sign and exceptions: explained; examples worked. content/lessons/science/chemistry/periodic-table.md:34-36 (Electron-affinity meaning sign and exceptions teaching); content/lessons/science/chemistry/periodic-table.md:70-78 (Electron-affinity meaning sign and exceptions example). Requirement refs: upcat-L144.
- Recognize named periodic-table families: absent; examples none. content/lessons/science/chemistry/periodic-table.md:14-20 (B03 outline Families and Groups facet; group positions covered, named families not taught). Limits: Alkali metals, alkaline-earth metals, halogens and noble-gas family identities/properties not taught; exact exam demand unknown. Requirement refs: local foundation, no specific accepted edge.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/periodic-table.md:10-114.

Prerequisites: links-found. lesson-chemistry-atomic-structure because Table ordering and electron-removal/addition trends rely on atomic number and electron/nuclear identity. Consumer: content/lessons/science/chemistry/periodic-table.md:12-34; foundation: content/lessons/science/chemistry/atomic-structure.md:12-26.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-quantum-numbers-electron-configuration

Goal: Read introductory configurations and quantum labels, distinguish orbital/subshell capacities, and find main-group valence counts. Exact exam demand is unconfirmed.

- Quantum number ranges and Pauli uniqueness: explained; examples worked. content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:14-27 (Quantum number ranges and Pauli uniqueness teaching); content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:78-85 (Quantum number ranges and Pauli uniqueness example). Limits: No specific accepted quantum-number requirement; atomic-structure background connection only. Requirement refs: local foundation, no specific accepted edge.
- Orbital versus subshell capacities: explained; examples worked. content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:29-40 (Orbital versus subshell capacities teaching); content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:70-76 (Orbital versus subshell capacities example). Requirement refs: local foundation, no specific accepted edge.
- Aufbau Hund and Pauli filling: explained; examples thin. content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:44-56 (Aufbau Hund and Pauli filling teaching); content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:70-76 (Aufbau Hund and Pauli filling example). Limits: Nitrogen configuration is supplied rather than built stepwise; no paired versus unpaired orbital sequence. Requirement refs: local foundation, no specific accepted edge.
- Configuration reading electron and valence counts: explained; examples worked. content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:58-66 (Configuration reading electron and valence counts teaching); content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:87-95 (Configuration reading electron and valence counts example). Requirement refs: local foundation, no specific accepted edge.
- Filling versus ionization order limits: explained; examples not-required. content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:97-103 (Filling versus ionization order limits teaching). Limits: Chromium/copper exceptions named but not constructed; no ionic configuration worked. Requirement refs: local foundation, no specific accepted edge.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:10-145.

Prerequisites: links-found. lesson-chemistry-atomic-structure because Configuration-to-element identification uses neutrality, Z and electron count. Consumer: content/lessons/science/chemistry/quantum-numbers-electron-configuration.md:87-95; foundation: content/lessons/science/chemistry/atomic-structure.md:24-38.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-solutions

Goal: Distinguish solution components and solubility states, and calculate concentration with the correct denominator.

- Solvent solute and saturation states: explained; examples none. content/lessons/science/chemistry/solutions.md:12-22 (Solvent solute and saturation states teaching). Limits: No applied saturation example or solubility data/curve interpretation. Requirement refs: upcat-L145, ustet-L125, pupcet-L114, dost-sei-L108.
- Molarity: explained; examples worked. content/lessons/science/chemistry/solutions.md:26-28 (L01 local facet: Molarity); content/lessons/science/chemistry/solutions.md:49-53 (L19 worked local facet: Molarity). Requirement refs: upcat-L145, pupcet-L114.
- Molality: explained; examples worked. content/lessons/science/chemistry/solutions.md:30-34 (L01 local facet: Molality); content/lessons/science/chemistry/solutions.md:55-59 (L19 worked local facet: Molality). Requirement refs: upcat-L145, pupcet-L114.
- Mass percent: explained; examples worked. content/lessons/science/chemistry/solutions.md:36-38 (L01 local facet: Mass percent); content/lessons/science/chemistry/solutions.md:61-68 (L19 worked local facet: Mass percent). Requirement refs: upcat-L145, pupcet-L114.
- Volume percent: explained; examples none. content/lessons/science/chemistry/solutions.md:40-44 (L01 local facet: Volume percent). Limits: No worked volume-percent computation. Requirement refs: upcat-L145, pupcet-L114.
- Temperature and concentration denominators: explained; examples worked. content/lessons/science/chemistry/solutions.md:34-44 (Temperature and concentration denominators teaching); content/lessons/science/chemistry/solutions.md:70-79 (Temperature and concentration denominators example). Requirement refs: upcat-L145, ustet-L125.
- Dilution amount conservation: absent; examples none. content/lessons/science/chemistry/solutions.md:24-44 (L01 structural teaching assessment: Dilution amount conservation). Limits: No dilution relation or reasoning from conserved solute amount. Requirement refs: upcat-L145.
- Product-composition and safe household-chemical application: absent; examples none. content/lessons/science/chemistry/solutions.md:12-44 (L01 structural teaching assessment: Product-composition and safe household-chemical application). Limits: No product-label interpretation, safe storage/mixing/disposal or household safety procedure; another topic may teach safety. Requirement refs: ustet-L125, dost-sei-L108.

Structure: retain. The core and examples support one coherent lesson goal. Proposal: Keep one shared lesson; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance.

Evidence: content/lessons/science/chemistry/solutions.md:10-113.

Prerequisites: links-found. lesson-chemistry-mole-concept because Concentration teaching and worked examples use moles without defining amount or a mole. Consumer: content/lessons/science/chemistry/solutions.md:26-32; foundation: content/lessons/science/chemistry/mole-concept.md:12-24.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-stoichiometry

Goal: Use balanced reaction ratios for limiting/yield reasoning and use composition ratios to derive empirical and molecular formulas.

- Balanced-equation mole-to-mole product relationships: thin; examples thin. content/lessons/science/chemistry/stoichiometry.md:12-18 (L01 local facet: Balanced-equation mole-to-mole product relationships); content/lessons/science/chemistry/stoichiometry.md:46-60 (L19 worked local facet: Balanced-equation mole-to-mole product relationships). Limits: Limiting example infers reactant demand; no explicit calculation of product moles. Requirement refs: upcat-L161, ustet-L114, pupcet-L115, dcat-L085, dost-sei-L104.
- Balanced-equation mole-to-mass product relationships: absent; examples none. content/lessons/science/chemistry/stoichiometry.md:12-18 (L01 local facet: Balanced-equation mole-to-mass product relationships). Limits: No reaction-ratio-to-product-mass procedure or worked chain. Requirement refs: upcat-L161, ustet-L114, pupcet-L115, dcat-L085, dost-sei-L104.
- Balanced-equation mass-to-mass product relationships: absent; examples none. content/lessons/science/chemistry/stoichiometry.md:12-18 (L01 local facet: Balanced-equation mass-to-mass product relationships). Limits: No reactant-mass to moles to reaction-ratio to product-mass worked chain. Requirement refs: upcat-L161, ustet-L114, pupcet-L115, dcat-L085, dost-sei-L104.
- Limiting and excess reactant decisions: explained; examples worked. content/lessons/science/chemistry/stoichiometry.md:14-18 (Limiting and excess reactant decisions teaching); content/lessons/science/chemistry/stoichiometry.md:46-60 (Limiting and excess reactant decisions example). Limits: No theoretical product quantity or remaining excess calculation. Requirement refs: upcat-L144, dcat-L082, ustet-L123, dost-sei-L104.
- Theoretical yield from reactant data: thin; examples none. content/lessons/science/chemistry/stoichiometry.md:20-28 (L01 local facet: Theoretical yield from reactant data). Limits: Definition given; theoretical yield supplied rather than derived from limiting-reactant data. Requirement refs: dcat-L082, ustet-L123, dost-sei-L104.
- Percent yield from actual and theoretical amounts: explained; examples worked. content/lessons/science/chemistry/stoichiometry.md:20-28 (L01 local facet: Percent yield from actual and theoretical amounts); content/lessons/science/chemistry/stoichiometry.md:62-66 (L19 worked local facet: Percent yield from actual and theoretical amounts). Requirement refs: dcat-L082, ustet-L123, dost-sei-L104.
- Empirical formulas from mole ratios: explained; examples worked. content/lessons/science/chemistry/stoichiometry.md:30-42 (Empirical formulas from mole ratios teaching); content/lessons/science/chemistry/stoichiometry.md:68-86 (Empirical formulas from mole ratios example). Limits: Composition-to-moles from mass/percent composition not worked; empirical-formula depth not specifically confirmed by broad refs. Requirement refs: local foundation, no specific accepted edge.
- Molecular formula multiplier from molar masses: thin; examples worked. content/lessons/science/chemistry/stoichiometry.md:30-36 (L01 structural teaching assessment: Molecular formula multiplier from molar masses); content/lessons/science/chemistry/stoichiometry.md:88-96 (Molecular formula multiplier from molar masses example). Limits: Multiplier relation appears first in example and later shortcut, not Core Concept (structural L17); no specific current depth established. Requirement refs: local foundation, no specific accepted edge.

Structure: split-candidate. Reaction amounts and composition-to-formula inference have distinct goals and do not require each other. The base reaction-quantity route is currently thin (L01/L17/L19). Proposal: Keep one shared reaction-quantity core with simple mole/mass chains, then limiting/yield extensions. Move empirical/molecular formula inference into a separate composition lesson without duplicating mole conversion. Cost: Requires new approved lesson identity/routing, moving examples and traps, adding missing reaction-quantity examples and composition teaching, plus later linked-practice review.

Evidence: content/lessons/science/chemistry/stoichiometry.md:12-96.

Prerequisites: links-found. lesson-chemistry-mole-concept because Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Consumer: content/lessons/science/chemistry/stoichiometry.md:46-60; foundation: content/lessons/science/chemistry/mole-concept.md:12-38.

Optional preparation: chemical-reactions.md:12-18 and56-91 teaches constructing balanced coefficients. It is not required by this current consumer: stoichiometry.md:12 explains coefficients as amount ratios,48-60 supplies the balanced equation, and62-96 uses given yields or composition ratios. No current example asks the learner to balance an equation. A future expanded lesson cannot justify a strict edge now.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

### lesson-chemistry-thermodynamics-and-kinetics

Goal: Distinguish heat direction from reaction speed, explain catalysts and basic rate factors, and use a supplied simple rate-law condition.

- Heat direction and enthalpy sign: explained; examples worked. content/lessons/science/chemistry/thermodynamics-and-kinetics.md:19-28 (Heat direction and enthalpy sign teaching); content/lessons/science/chemistry/thermodynamics-and-kinetics.md:63-70 (Heat direction and enthalpy sign example). Requirement refs: upcat-L146, ustet-L123, pupcet-L123.
- Activation barrier collision conditions and catalyst pathway: explained; examples worked. content/lessons/science/chemistry/thermodynamics-and-kinetics.md:32-50 (Activation barrier collision conditions and catalyst pathway teaching); content/lessons/science/chemistry/thermodynamics-and-kinetics.md:93-102 (Activation barrier collision conditions and catalyst pathway example). Limits: Arrhenius relation introduced but no numerical application; exact needed depth unknown. Requirement refs: upcat-L146, upcat-L161, ustet-L123, dost-sei-L104, dost-sei-L106.
- Surface area temperature and concentration rate factors: explained; examples worked. content/lessons/science/chemistry/thermodynamics-and-kinetics.md:52-59 (Surface area temperature and concentration rate factors teaching); content/lessons/science/chemistry/thermodynamics-and-kinetics.md:83-91 (Surface area temperature and concentration rate factors example). Limits: No worked temperature comparison. Requirement refs: upcat-L161, ustet-L123, pupcet-L123, dost-sei-L099, sm-foundation-L137.
- Rate-law order reasoning: thin; examples worked. content/lessons/science/chemistry/thermodynamics-and-kinetics.md:56-57 (L01 structural teaching assessment: Rate-law order reasoning); content/lessons/science/chemistry/thermodynamics-and-kinetics.md:104-114 (Rate-law order reasoning example). Limits: Rate-law notation and exponent/order meaning not introduced before the worked zero-order example (structural L17/L19). Requirement refs: upcat-L146, dost-sei-L106.
- Chemical equilibrium foundation: named-only; examples thin. content/lessons/science/chemistry/thermodynamics-and-kinetics.md:14-17 (L01 structural teaching assessment: Chemical equilibrium foundation); content/lessons/science/chemistry/thermodynamics-and-kinetics.md:72-81 (Chemical equilibrium foundation example). Limits: No dynamic forward/reverse rate balance, equilibrium constant construction, or response-to-condition change; catalyst effect is not full equilibrium teaching. Requirement refs: upcat-L146, dost-sei-L106.
- Scientific comparison and controls: thin; examples thin. content/lessons/science/chemistry/thermodynamics-and-kinetics.md:74-91 (L01 structural teaching assessment: Scientific comparison and controls); content/lessons/science/chemistry/thermodynamics-and-kinetics.md:104-114 (Scientific comparison and controls example). Limits: All-else-fixed comparisons apply control logic without teaching experimental variable/control identification. Requirement refs: dcat-L077, ustet-L113, acet-L126.

Structure: retain. Comparing thermochemistry and rate directly prevents conflating energy release with speed; the paired goal benefits from one lesson. Proposal: Retain comparison core. Add equilibrium foundation and rate-law notation before their use; isolate quantitative equilibrium/kinetics extensions only if later scoped. Cost: Requires targeted teaching and example revision; premature splitting would duplicate the contrast and preserve missing foundations.

Evidence: content/lessons/science/chemistry/thermodynamics-and-kinetics.md:12-114.

Prerequisites: missing-foundation. No strictly necessary existing-lesson link found; any intralesson ordering is separate. Missing foundations: Dynamic-equilibrium meaning is missing locally before the catalyst equilibrium example; no verified existing chemistry lesson teaches it fully.

Load-bearing figures: none encountered. Placeholder presence does not establish rendered availability.

## Explicit no-prerequisite accounting

lesson-chemistry-acids-bases-ph, lesson-chemistry-atomic-structure, lesson-chemistry-basic-organic-chemistry, lesson-chemistry-chemical-reactions, lesson-chemistry-history-of-the-atom, lesson-chemistry-matter, lesson-chemistry-mixtures-and-separation, lesson-chemistry-mole-concept, lesson-chemistry-thermodynamics-and-kinetics.

## Historical author self-check before C1 correction

Command: focused Python accounting/hash/evidence/reference/dependency check against the saved appendix, assigned packet, accepted requirement map, inventory and pinned corpus. Actual original output for pre-correction SHA256 e3c4cda4f8d98ffa9c834ce0956672abf95922cde6ee86bd4c835b1e8dac2245; these nine-edge checks are historical and do not verify the amended artifact:

PASS assigned IDs: 17 exactly once
PASS full reads: 17 SHA256/range/path matches
PASS JSON appendices: 1 valid
PASS evidence ranges: 375 valid
PASS requirement refs: 39 valid accepted IDs
PASS prerequisite edges: 9 existing targets, both-end paths/lines, no self-links, acyclic
PASS no-existing-prerequisite links: 9 explicit statuses
PASS corpus: pinned HEAD, clean worktree
PASS em dashes: 0
PASS scope declarations: availability unknown/practice deferred; no content/app/importer/schema changes or later-level work
Independent semantic review: pending.

Shared checker actual result: completeTopics 3; expectedTopics 25; completeLessons 40; expectedLessons 158; complete [science-biology, science-chemistry, science-physics]; errors []; gateReady false. Exit 0. Other topics pending; scoped chemistry completion is not the combined gate.

## Encountered source ledger

Access date October 5, 2026; audit branch docs/content-coverage-audit-r1; corpus base 765c5dc0fa5586281047bf4f7b30d09ab3707887. This is a bounded encountered-fact check, not a correctness sweep.

- lesson-chemistry-mole-concept: Exact SI mole value encountered. Original claim: The Avogadro constant is exactly 6.02214076 x 10^23 mol^-1. CONFIRMED. [BIPM SI base unit mole, definition paragraphs](https://www.bipm.org/en/si-base-units/mole). Live publisher text confirms the exact constant and specified-entity basis; this confirms one encountered fact only.
- lesson-chemistry-chemical-bonding: HF exception to electronegativity cutoffs encountered. Original claim: HF has a difference about 1.9 and remains described as polar covalent. CONFIRMED. [OpenStax Chemistry 2e, Electronegativity and Bond Type](https://openstax.org/books/chemistry-2e/pages/7-2-covalent-bonding). Live publisher section gives this exception; the lesson warning against rigid cutoffs matches. No full numerical trend sweep performed.
- lesson-chemistry-chemical-bonding: Definition mistaken for instruction risk. Original claim: Lewis structures represent valence electrons and bonding; construction is not demonstrated. LESSON GAP. [OpenStax Chemistry 2e, Lewis Symbols and Structures, objectives and definitions](https://openstax.org/books/chemistry-2e/pages/7-3-lewis-symbols-and-structures). Publisher distinguishes depicting/building structures from naming the representation. Local gap rests on full lesson reading, not a new exam requirement.
- lesson-chemistry-thermodynamics-and-kinetics: Dynamic equilibrium foundation absent before catalyst example. Original claim: A catalyst speeds arrival at equilibrium without changing equilibrium composition. LESSON GAP. [OpenStax Chemistry 2e, Chemical Equilibria, initial definition and dynamic nature](https://openstax.org/books/chemistry-2e/pages/13-1-chemical-equilibria). Live publisher defines equilibrium by equal forward/reverse rates with stable concentrations. The consumer example assumes that foundational meaning without teaching it.
- chemistry-topic: Optional higher-priority glossary access limitation. Original claim: IUPAC glossary routes attempted for encountered term checks. UNKNOWN. [Attempted glossary route; body not verified](https://goldbook.iupac.org/terms/view/E02177). Web returned HTTP 403 for this and L03508. No content conclusion relies on either unread body; OpenStax publisher sections supplied bounded foundation checks.

## C1 correction, October 6, 2026

Current correction policy: main `e8d5f0f958e38c1648046a93747437687ba08334`, verified against live remote and cached origin/main. Pinned corpus remains clean at `765c5dc0fa5586281047bf4f7b30d09ab3707887`. Original author full-read hashes, findings and source ledger remain historical and unchanged. This correction reread full stoichiometry1-134, chemical-reactions1-133 and mole-concept1-112; current read hashes appear in correctionHistory. Biology and Earth outputs were not changed.

The independent reviewer recorded C1 in [topic-samples](../review/topic-samples.md), against original target SHA256 `e3c4cda4f8d98ffa9c834ce0956672abf95922cde6ee86bd4c835b1e8dac2245`. That review history is preserved. The source check supports removal: the consumer defines coefficient ratios and provides its balanced equation; no indispensable balancing convention absent locally was found. Optional preparation is separate from strict roadmap links. The mole-concept edge remains unchanged, with both-end evidence.

| Consumer | Existing prerequisite | Reason | Scope | Consumer evidence | Foundation evidence |
|---|---|---|---|---|---|
| lesson-chemistry-stoichiometry | lesson-chemistry-mole-concept | Mole and molar-mass meanings are assumed rather than taught locally. | within-topic | content/lessons/science/chemistry/stoichiometry.md:46-60 | content/lessons/science/chemistry/mole-concept.md:12-38 |

Changed only the stoichiometry prerequisite prose/table, its strict JSON prerequisites, eight related facet priorKnowledge entries, current policy identity, and this correction/check history. Teaching verdicts, examples, exam scope/tags, source claims and all other links remain unchanged. Remaining strict edges: eight. Fresh narrow C1 review remains pending; self-check does not accept the artifact.

Correction verification commands: focused Python assigned-ID/hash/read-range/field/reference/evidence/dependency check, followed by `python3 docs/content/audit/coverage-r1/check_level3_outputs.py`. Both returned exit0. Actual focused output:

    chemistry_C1_check: assigned=17/17 unique=17 hashes_ranges_paths=17/17 json_appendices=1 fields=PASS evidence_ranges=373 accepted_refs=39 remaining_edges=8 both_end_paths_lines=PASS targets_existing=PASS self_links=0 cycles=0 optional_balancing_facets=8 mole_edge_retained=PASS corpus_clean=true biology_hash_unchanged=true emdash=0 errors=[]

Shared validator actual result fields: `completeTopics: 3`, `expectedTopics: 25`, `completeLessons: 40`, `expectedLessons: 158`, `complete: [science-biology, science-chemistry, science-physics]`, `errors: []`, `mechanicalAccountingReady: false`, `gateReady: false`. Its22pending topics include arithmetic-number-sense and Earth as DRAFT, with20others NOT_STARTED. This supporting result does not accept C1 or the combined Level3 gate.

Fresh narrow C1 independent review remains pending; current self-check does not claim acceptance. Original nine-edge evidence above remains historical. No unrelated target was written.

## Machine-readable appendix

```json
{
  "level": 3,
  "status": "COMPLETE",
  "subject": "science",
  "topic": "chemistry",
  "policyCommit": "e8d5f0f958e38c1648046a93747437687ba08334",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "id": "lesson-chemistry-acids-bases-ph",
      "path": "content/lessons/science/chemistry/acids-bases-ph.md",
      "sha256": "ed190e57bf75a07efeb68051b55f10ebed11fe7dc2fd22d569afcb441887f8c4",
      "readLines": [
        1,
        141
      ],
      "goal": "Distinguish introductory acid/base models, interpret pH and strength, and explain simple neutralization. This supports weak UPCAT and specialized DOST preparation, not a current depth claim.",
      "skills": [
        {
          "name": "Arrhenius and proton-transfer definitions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/acids-bases-ph.md",
              "lines": [
                12,
                18
              ],
              "note": "Arrhenius and proton-transfer definitions teaching"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/acids-bases-ph.md",
              "lines": [
                94,
                105
              ],
              "note": "Arrhenius and proton-transfer definitions example"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "dost-sei-L106"
          ],
          "limitations": [
            "No worked donor/acceptor identification in a non-hydroxide reaction"
          ]
        },
        {
          "name": "pH classification and logarithmic activity comparison",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/acids-bases-ph.md",
              "lines": [
                20,
                40
              ],
              "note": "pH classification and logarithmic activity comparison teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/acids-bases-ph.md",
              "lines": [
                64,
                83
              ],
              "note": "pH classification and logarithmic activity comparison example"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "dost-sei-L106"
          ],
          "limitations": [
            "No direct concentration-to-pH worked example; acid-base equilibrium solving not taught"
          ]
        },
        {
          "name": "Strong versus weak and concentration distinction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/acids-bases-ph.md",
              "lines": [
                42,
                46
              ],
              "note": "Strong versus weak and concentration distinction teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/acids-bases-ph.md",
              "lines": [
                85,
                92
              ],
              "note": "Strong versus weak and concentration distinction example"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "dost-sei-L106"
          ],
          "limitations": []
        },
        {
          "name": "Neutralization and spectator ions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/acids-bases-ph.md",
              "lines": [
                48,
                60
              ],
              "note": "Neutralization and spectator ions teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/acids-bases-ph.md",
              "lines": [
                94,
                105
              ],
              "note": "Neutralization and spectator ions example"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "dost-sei-L106"
          ],
          "limitations": [
            "No titration or quantitative neutralization calculation; required depth unknown"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L106"
          ],
          "sharedCore": "Arrhenius and proton-transfer definitions; pH classification and logarithmic activity comparison; Strong versus weak and concentration distinction; Neutralization and spectator ions",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L145"
          ],
          "sharedCore": "Arrhenius and proton-transfer definitions; pH classification and logarithmic activity comparison; Strong versus weak and concentration distinction; Neutralization and spectator ions",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/acids-bases-ph.md",
            "lines": [
              10,
              141
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-atomic-structure",
      "path": "content/lessons/science/chemistry/atomic-structure.md",
      "sha256": "45e49608a875c73b0f58970619443f349f79175e819bcd2499ab0ebcee64fe04",
      "readLines": [
        1,
        129
      ],
      "goal": "Use proton, neutron and electron counts to distinguish elements, isotopes and monatomic ions for shared introductory chemistry preparation.",
      "skills": [
        {
          "name": "Particle location and charge",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                12,
                20
              ],
              "note": "Particle location and charge teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                58,
                67
              ],
              "note": "Particle location and charge example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L114",
            "dost-sei-L099",
            "sm-foundation-L137"
          ],
          "limitations": []
        },
        {
          "name": "Atomic number and mass number",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                24,
                38
              ],
              "note": "Atomic number and mass number teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                58,
                67
              ],
              "note": "Atomic number and mass number example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "ustet-L114",
            "pupcet-L114",
            "dost-sei-L106"
          ],
          "limitations": []
        },
        {
          "name": "Isotopes versus isotope-weighted atomic mass",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                40,
                44
              ],
              "note": "Isotopes versus isotope-weighted atomic mass teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                69,
                76
              ],
              "note": "Isotopes versus isotope-weighted atomic mass example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "pupcet-L114",
            "dost-sei-L106"
          ],
          "limitations": [
            "Weighted atomic mass calculation not demonstrated; exact needed depth unknown"
          ]
        },
        {
          "name": "Ion charge and electron counts",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                46,
                54
              ],
              "note": "Ion charge and electron counts teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                78,
                95
              ],
              "note": "Ion charge and electron counts example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L114",
            "dost-sei-L106"
          ],
          "limitations": []
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L099",
            "dost-sei-L104",
            "dost-sei-L106"
          ],
          "sharedCore": "Particle location and charge; Atomic number and mass number; Isotopes versus isotope-weighted atomic mass; Ion charge and electron counts",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L114",
            "pupcet-L128"
          ],
          "sharedCore": "Particle location and charge; Atomic number and mass number; Isotopes versus isotope-weighted atomic mass; Ion charge and electron counts",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L048",
            "sm-foundation-L137",
            "sm-foundation-L141"
          ],
          "sharedCore": "Particle location and charge; Atomic number and mass number; Isotopes versus isotope-weighted atomic mass; Ion charge and electron counts",
          "partialLimits": "Only local facets; advanced detail is not established as required. Science inclusion unconfirmed; background only. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L144",
            "upcat-L161"
          ],
          "sharedCore": "Particle location and charge; Atomic number and mass number; Isotopes versus isotope-weighted atomic mass; Ion charge and electron counts",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114",
            "ustet-L123"
          ],
          "sharedCore": "Particle location and charge; Atomic number and mass number; Isotopes versus isotope-weighted atomic mass; Ion charge and electron counts",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/atomic-structure.md",
            "lines": [
              10,
              129
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-basic-organic-chemistry",
      "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
      "sha256": "234da9df778ebb40c6c3bc1127aa7d8f6c4ca1b5ed9315cea2a4e6efa5bdc46a",
      "readLines": [
        1,
        146
      ],
      "goal": "Classify hydrocarbons, identify common functional-group families and interpret simple naming limits for carbon-compound preparation.",
      "skills": [
        {
          "name": "Organic scope and carbon frameworks",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
              "lines": [
                12,
                14
              ],
              "note": "Organic scope and carbon frameworks teaching"
            }
          ],
          "exampleVerdict": "not-required",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L146",
            "upcat-L161",
            "pupcet-L115"
          ],
          "limitations": []
        },
        {
          "name": "Hydrocarbon families and ring saturation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
              "lines": [
                16,
                32
              ],
              "note": "Hydrocarbon families and ring saturation teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
              "lines": [
                67,
                94
              ],
              "note": "Hydrocarbon families and ring saturation example"
            }
          ],
          "requirementRefs": [
            "upcat-L146",
            "upcat-L161",
            "pupcet-L115"
          ],
          "limitations": []
        },
        {
          "name": "Functional groups and structure-property reasoning",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
              "lines": [
                34,
                45
              ],
              "note": "L01 structural teaching assessment: Functional groups and structure-property reasoning"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
              "lines": [
                96,
                104
              ],
              "note": "Functional groups and structure-property reasoning example"
            }
          ],
          "requirementRefs": [
            "upcat-L146",
            "upcat-L161",
            "dcat-L079"
          ],
          "limitations": [
            "Aldehyde versus ketone environments not defined; no concrete structures or property comparison derived from a named pair"
          ]
        },
        {
          "name": "Simple IUPAC parent selection and substituent naming",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
              "lines": [
                47,
                63
              ],
              "note": "L01 structural teaching assessment: Simple IUPAC parent selection and substituent naming"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
              "lines": [
                81,
                86
              ],
              "note": "Simple IUPAC parent selection and substituent naming example"
            }
          ],
          "requirementRefs": [
            "upcat-L146"
          ],
          "limitations": [
            "No branched structure, numbering decision, substituent locants or complete worked branched name"
          ]
        },
        {
          "name": "Carbon compounds and biomolecule relationships",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
              "lines": [
                12,
                63
              ],
              "note": "L01 structural teaching assessment: Carbon compounds and biomolecule relationships"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L161",
            "pupcet-L115",
            "dcat-L079"
          ],
          "limitations": [
            "Biomolecule classes and structure-function relationships are not taught in this chemistry lesson; biology overlap needs lead reconciliation"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L037",
            "dcat-L079"
          ],
          "sharedCore": "Carbon-compound structure/property background only.",
          "partialLimits": "DCAT curriculum row connects bonding and biomolecules to properties, not a specified hydrocarbon/IUPAC naming syllabus. Concrete property reasoning is thin; biomolecules are absent locally.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L115",
            "pupcet-L128"
          ],
          "sharedCore": "Organic scope and carbon frameworks; Hydrocarbon families and ring saturation",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L141",
            "upcat-L142",
            "upcat-L146",
            "upcat-L160",
            "upcat-L161"
          ],
          "sharedCore": "Organic scope and carbon frameworks; Hydrocarbon families and ring saturation",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Families and naming form a coherent introductory organic goal, but naming is only partly taught (L01/L19).",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
            "lines": [
              34,
              112
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Retain shared overview and deepen the concrete naming/property reasoning before considering a naming extension.",
        "cost": "Requires added teaching and examples under later approval; separating current thin material alone would not fix it."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-chemical-bonding",
      "path": "content/lessons/science/chemistry/chemical-bonding.md",
      "sha256": "042231ade259c1c28fa6e46f596b9518d25a8d272436620e0dfec0a20406a9de",
      "readLines": [
        1,
        141
      ],
      "goal": "Classify bonding models and predict basic electron-group and molecular geometries while distinguishing bond polarity from deeper molecular properties.",
      "skills": [
        {
          "name": "Ionic covalent and metallic bonding",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                12,
                20
              ],
              "note": "Ionic covalent and metallic bonding teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                68,
                76
              ],
              "note": "Ionic covalent and metallic bonding example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "upcat-L161",
            "dcat-L079",
            "ustet-L114",
            "pupcet-L114",
            "dost-sei-L104",
            "dost-sei-L106"
          ],
          "limitations": []
        },
        {
          "name": "Octet guideline and exceptions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                24,
                36
              ],
              "note": "Octet guideline and exceptions teaching"
            }
          ],
          "exampleVerdict": "not-required",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L144",
            "dost-sei-L106"
          ],
          "limitations": []
        },
        {
          "name": "Bond polarity and electronegativity",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                38,
                44
              ],
              "note": "Bond polarity and electronegativity teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                78,
                86
              ],
              "note": "Bond polarity and electronegativity example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "dcat-L082",
            "dost-sei-L104"
          ],
          "limitations": [
            "Electronegativity term not defined locally; periodic-table teaching supplies it"
          ]
        },
        {
          "name": "Lewis structures formal charge and resonance",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                46,
                50
              ],
              "note": "L01 structural teaching assessment: Lewis structures formal charge and resonance"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L144",
            "dost-sei-L106"
          ],
          "limitations": [
            "No valence-electron counting procedure, actual Lewis construction, formal-charge formula or resonance worked structure"
          ]
        },
        {
          "name": "VSEPR geometry from supplied electron groups",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                52,
                64
              ],
              "note": "VSEPR geometry from supplied electron groups teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                88,
                107
              ],
              "note": "VSEPR geometry from supplied electron groups example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "dcat-L082",
            "dost-sei-L104"
          ],
          "limitations": [
            "Examples supply groups; learner cannot derive groups from a formula without Lewis construction"
          ]
        },
        {
          "name": "Molecular polarity from bond dipoles and geometry",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                38,
                64
              ],
              "note": "L01 structural teaching assessment: Molecular polarity from bond dipoles and geometry"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L079",
            "dcat-L082",
            "ustet-L123",
            "pupcet-L123",
            "dost-sei-L104",
            "sm-foundation-L141"
          ],
          "limitations": [
            "Bond polarity and geometry are taught separately; their combined molecular-polarity decision is absent"
          ]
        },
        {
          "name": "Intermolecular forces and hydrogen bonding",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                12,
                64
              ],
              "note": "L01 structural teaching assessment: Intermolecular forces and hydrogen bonding"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L079",
            "dcat-L082",
            "ustet-L123",
            "pupcet-L123",
            "dost-sei-L104",
            "sm-foundation-L141"
          ],
          "limitations": [
            "No force-type or hydrogen-bond explanation connects molecular structure to physical properties"
          ]
        },
        {
          "name": "Bonding model to material properties",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                14,
                20
              ],
              "note": "L01 structural teaching assessment: Bonding model to material properties"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L079",
            "dcat-L082",
            "ustet-L123",
            "pupcet-L123",
            "dost-sei-L104",
            "sm-foundation-L141"
          ],
          "limitations": [
            "Metallic conductivity and malleability are linked; no worked structure-to-solubility or boiling-point comparison"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L037",
            "dcat-L079",
            "dcat-L082"
          ],
          "sharedCore": "Ionic covalent and metallic bonding; Octet guideline and exceptions; Bond polarity and electronegativity; VSEPR geometry from supplied electron groups",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L104",
            "dost-sei-L106"
          ],
          "sharedCore": "Ionic covalent and metallic bonding; Octet guideline and exceptions; Bond polarity and electronegativity; VSEPR geometry from supplied electron groups",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L114",
            "pupcet-L123",
            "pupcet-L128"
          ],
          "sharedCore": "Ionic covalent and metallic bonding; Octet guideline and exceptions; Bond polarity and electronegativity; VSEPR geometry from supplied electron groups",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L048",
            "sm-foundation-L141"
          ],
          "sharedCore": "Ionic covalent and metallic bonding; Octet guideline and exceptions; Bond polarity and electronegativity; VSEPR geometry from supplied electron groups",
          "partialLimits": "Only local facets; advanced detail is not established as required. Science inclusion unconfirmed; background only. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L144"
          ],
          "sharedCore": "Ionic covalent and metallic bonding; Octet guideline and exceptions; Bond polarity and electronegativity; VSEPR geometry from supplied electron groups",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114",
            "ustet-L123"
          ],
          "sharedCore": "Ionic covalent and metallic bonding; Octet guideline and exceptions; Bond polarity and electronegativity; VSEPR geometry from supplied electron groups",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "reorder",
        "reason": "Bond models are coherent, but geometry assumes Lewis-building knowledge that the lesson only names (L01/L17/L19).",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/chemical-bonding.md",
            "lines": [
              46,
              107
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Teach valence-count and Lewis construction before VSEPR; keep the shared core together. Consider a separate molecular-properties extension only after defining its teaching.",
        "cost": "Add procedural teaching and revise geometry examples; a new unit would need separate approval and shared-core routing."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-chemistry-atomic-structure",
          "reason": "Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-bonding.md",
              "lines": [
                12,
                18
              ],
              "note": "consumer uses foundation"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                12,
                18
              ],
              "note": "foundation taught"
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [
        "Lewis-structure construction and formal-charge procedure must precede deriving geometry; this is a missing local foundation, not an existing prerequisite link"
      ],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-chemical-nomenclature",
      "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
      "sha256": "decd964ba3162bb7b59472e145d2f0be2a98c08eb3e5aedded98195ca644a7a9",
      "readLines": [
        1,
        152
      ],
      "goal": "Name simple ionic and binary molecular compounds, infer variable ion charges and write charge-balanced formulas for specialized chemistry preparation.",
      "skills": [
        {
          "name": "Ionic and Stock naming",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                14,
                27
              ],
              "note": "Ionic and Stock naming teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                69,
                87
              ],
              "note": "Ionic and Stock naming example"
            }
          ],
          "requirementRefs": [
            "dost-sei-L106"
          ],
          "limitations": []
        },
        {
          "name": "Polyatomic ions and related oxyanion names",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                25,
                31
              ],
              "note": "Polyatomic ions and related oxyanion names teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                99,
                107
              ],
              "note": "Polyatomic ions and related oxyanion names example"
            }
          ],
          "requirementRefs": [
            "dost-sei-L106"
          ],
          "limitations": []
        },
        {
          "name": "Binary molecular prefixes and names",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                33,
                49
              ],
              "note": "Binary molecular prefixes and names teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                89,
                97
              ],
              "note": "Binary molecular prefixes and names example"
            }
          ],
          "requirementRefs": [
            "dost-sei-L106"
          ],
          "limitations": []
        },
        {
          "name": "Charge-balanced simplest ionic formulas",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                51,
                65
              ],
              "note": "Charge-balanced simplest ionic formulas teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                99,
                118
              ],
              "note": "Charge-balanced simplest ionic formulas example"
            }
          ],
          "requirementRefs": [
            "dost-sei-L106"
          ],
          "limitations": []
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L106"
          ],
          "sharedCore": "Ionic and Stock naming; Polyatomic ions and related oxyanion names; Binary molecular prefixes and names; Charge-balanced simplest ionic formulas",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
            "lines": [
              10,
              152
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-chemistry-atomic-structure",
          "reason": "Naming assumes cation/anion and signed ion charge rather than introducing them.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
              "lines": [
                16,
                29
              ],
              "note": "consumer uses foundation"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                46,
                54
              ],
              "note": "foundation taught"
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-chemical-reactions",
      "path": "content/lessons/science/chemistry/chemical-reactions.md",
      "sha256": "c341c6ac97c05c858e10b99c50e5ae2ab090fce440d49849e20e2c4a35d528f7",
      "readLines": [
        1,
        133
      ],
      "goal": "Balance simple equations by atom conservation and classify common reaction patterns without treating labels as exclusive.",
      "skills": [
        {
          "name": "Atom conservation and coefficient balancing",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                12,
                18
              ],
              "note": "Atom conservation and coefficient balancing teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                56,
                91
              ],
              "note": "Atom conservation and coefficient balancing example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "dcat-L085",
            "ustet-L114",
            "pupcet-L115",
            "dost-sei-L104"
          ],
          "limitations": []
        },
        {
          "name": "Combination decomposition and single displacement",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                20,
                26
              ],
              "note": "Combination decomposition and single displacement teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                40,
                54
              ],
              "note": "Combination decomposition and single displacement example"
            }
          ],
          "requirementRefs": [
            "upcat-L143",
            "ustet-L125",
            "pupcet-L123",
            "sm-foundation-L137"
          ],
          "limitations": []
        },
        {
          "name": "Double displacement and driving-force reasoning",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                27,
                27
              ],
              "note": "Double displacement and driving-force reasoning teaching"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                93,
                99
              ],
              "note": "Double displacement and driving-force reasoning example"
            }
          ],
          "requirementRefs": [
            "upcat-L143",
            "ustet-L125",
            "dost-sei-L104"
          ],
          "limitations": [
            "No concrete precipitation or net-ionic derivation; solubility rules not supplied"
          ]
        },
        {
          "name": "Complete and incomplete combustion",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                28,
                36
              ],
              "note": "Complete and incomplete combustion teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                69,
                81
              ],
              "note": "Complete and incomplete combustion example"
            }
          ],
          "requirementRefs": [
            "upcat-L143",
            "ustet-L125",
            "pupcet-L115"
          ],
          "limitations": []
        },
        {
          "name": "Redox and oxidation-state reasoning",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/chemical-reactions.md",
              "lines": [
                22,
                28
              ],
              "note": "L01 structural teaching assessment: Redox and oxidation-state reasoning"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L145"
          ],
          "limitations": [
            "Examples label redox without defining electron transfer or showing oxidation-state changes; charge in nomenclature does not teach general redox"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L037",
            "dcat-L082"
          ],
          "sharedCore": "Atom conservation and coefficient balancing; Combination decomposition and single displacement; Double displacement and driving-force reasoning; Complete and incomplete combustion",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L104"
          ],
          "sharedCore": "Atom conservation and coefficient balancing; Combination decomposition and single displacement; Double displacement and driving-force reasoning; Complete and incomplete combustion",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L115",
            "pupcet-L123",
            "pupcet-L128"
          ],
          "sharedCore": "Atom conservation and coefficient balancing; Combination decomposition and single displacement; Double displacement and driving-force reasoning; Complete and incomplete combustion",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L048",
            "sm-foundation-L137"
          ],
          "sharedCore": "Atom conservation and coefficient balancing; Combination decomposition and single displacement; Double displacement and driving-force reasoning; Complete and incomplete combustion",
          "partialLimits": "Only local facets; advanced detail is not established as required. Science inclusion unconfirmed; background only. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L143",
            "upcat-L144",
            "upcat-L145",
            "upcat-L161"
          ],
          "sharedCore": "Atom conservation and coefficient balancing; Combination decomposition and single displacement; Double displacement and driving-force reasoning; Complete and incomplete combustion",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114",
            "ustet-L123",
            "ustet-L125"
          ],
          "sharedCore": "Atom conservation and coefficient balancing; Combination decomposition and single displacement; Double displacement and driving-force reasoning; Complete and incomplete combustion",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/chemical-reactions.md",
            "lines": [
              10,
              133
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-gas-laws",
      "path": "content/lessons/science/chemistry/gas-laws.md",
      "sha256": "514bfc655c0fb14fa0e8d8eb6a0161e38652c8ceec305f56cf75b424debc0eca",
      "readLines": [
        1,
        140
      ],
      "goal": "Choose an ideal gas relationship from fixed quantities, use absolute temperature, and solve pressure-volume-temperature or amount problems.",
      "skills": [
        {
          "name": "Gas-law conditions and fixed quantities",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                12,
                58
              ],
              "note": "Gas-law conditions and fixed quantities teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                62,
                106
              ],
              "note": "Gas-law conditions and fixed quantities example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "dcat-L079",
            "ustet-L114",
            "pupcet-L115",
            "dost-sei-L099"
          ],
          "limitations": []
        },
        {
          "name": "Kelvin conversion and absolute-temperature reasoning",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                14,
                16
              ],
              "note": "Kelvin conversion and absolute-temperature reasoning teaching"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L161",
            "dcat-L079",
            "dost-sei-L099"
          ],
          "limitations": [
            "Examples already supply kelvin; conversion application is not worked"
          ]
        },
        {
          "name": "Boyle inverse pressure-volume relationship",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                18,
                22
              ],
              "note": "L01 local facet: Boyle inverse pressure-volume relationship"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                62,
                72
              ],
              "note": "L19 worked local facet: Boyle inverse pressure-volume relationship"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "upcat-L161",
            "dcat-L079",
            "ustet-L114",
            "dost-sei-L099"
          ],
          "limitations": []
        },
        {
          "name": "Charles direct volume-temperature relationship",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                24,
                28
              ],
              "note": "L01 local facet: Charles direct volume-temperature relationship"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                74,
                82
              ],
              "note": "L19 worked local facet: Charles direct volume-temperature relationship"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "upcat-L161",
            "dcat-L079",
            "ustet-L114",
            "dost-sei-L099"
          ],
          "limitations": []
        },
        {
          "name": "Amontons/Gay-Lussac pressure-temperature relationship",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                30,
                36
              ],
              "note": "L01 local facet: Amontons/Gay-Lussac pressure-temperature relationship"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L161",
            "dcat-L079",
            "dost-sei-L099"
          ],
          "limitations": [
            "No worked pressure-temperature problem"
          ]
        },
        {
          "name": "Avogadro volume-amount relationship",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                38,
                44
              ],
              "note": "L01 local facet: Avogadro volume-amount relationship"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L161",
            "dcat-L079",
            "dost-sei-L099"
          ],
          "limitations": [
            "No worked volume-amount problem"
          ]
        },
        {
          "name": "Combined fixed-amount gas-state calculation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                48,
                52
              ],
              "note": "L01 local facet: Combined fixed-amount gas-state calculation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                84,
                94
              ],
              "note": "L19 worked local facet: Combined fixed-amount gas-state calculation"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "dcat-L085",
            "ustet-L114",
            "dost-sei-L107"
          ],
          "limitations": []
        },
        {
          "name": "Ideal gas amount calculation and units",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                54,
                58
              ],
              "note": "L01 local facet: Ideal gas amount calculation and units"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                96,
                106
              ],
              "note": "L19 worked local facet: Ideal gas amount calculation and units"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "dcat-L085",
            "ustet-L114",
            "dost-sei-L107"
          ],
          "limitations": []
        },
        {
          "name": "Kinetic Molecular Theory explanation of gas relationships",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                12,
                58
              ],
              "note": "L01 structural teaching assessment: Kinetic Molecular Theory explanation of gas relationships"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L161"
          ],
          "limitations": [
            "No collision-based pressure, random particle motion or kinetic-energy model connects the equations to mechanism"
          ]
        },
        {
          "name": "Recognizing controlled quantities in gas comparisons",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                18,
                44
              ],
              "note": "L01 structural teaching assessment: Recognizing controlled quantities in gas comparisons"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                62,
                94
              ],
              "note": "Recognizing controlled quantities in gas comparisons example"
            }
          ],
          "requirementRefs": [
            "dcat-L077",
            "ustet-L113",
            "acet-L126"
          ],
          "limitations": [
            "Fixed variables are identified for formulas, not taught as independent/dependent/control variables in investigations"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L037",
            "dcat-L079",
            "dcat-L085"
          ],
          "sharedCore": "Gas-law conditions and fixed quantities; Kelvin conversion and absolute-temperature reasoning; Boyle inverse pressure-volume relationship; Charles direct volume-temperature relationship; Amontons/Gay-Lussac pressure-temperature relationship; Avogadro volume-amount relationship; Combined fixed-amount gas-state calculation; Ideal gas amount calculation and units",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L099",
            "dost-sei-L107"
          ],
          "sharedCore": "Gas-law conditions and fixed quantities; Kelvin conversion and absolute-temperature reasoning; Boyle inverse pressure-volume relationship; Charles direct volume-temperature relationship; Amontons/Gay-Lussac pressure-temperature relationship; Avogadro volume-amount relationship; Combined fixed-amount gas-state calculation; Ideal gas amount calculation and units",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L115",
            "pupcet-L128"
          ],
          "sharedCore": "Gas-law conditions and fixed quantities; Kelvin conversion and absolute-temperature reasoning; Boyle inverse pressure-volume relationship; Charles direct volume-temperature relationship; Amontons/Gay-Lussac pressure-temperature relationship; Avogadro volume-amount relationship; Combined fixed-amount gas-state calculation; Ideal gas amount calculation and units",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L145",
            "upcat-L161"
          ],
          "sharedCore": "Gas-law conditions and fixed quantities; Kelvin conversion and absolute-temperature reasoning; Boyle inverse pressure-volume relationship; Charles direct volume-temperature relationship; Amontons/Gay-Lussac pressure-temperature relationship; Avogadro volume-amount relationship; Combined fixed-amount gas-state calculation; Ideal gas amount calculation and units",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114"
          ],
          "sharedCore": "Gas-law conditions and fixed quantities; Kelvin conversion and absolute-temperature reasoning; Boyle inverse pressure-volume relationship; Charles direct volume-temperature relationship; Amontons/Gay-Lussac pressure-temperature relationship; Avogadro volume-amount relationship; Combined fixed-amount gas-state calculation; Ideal gas amount calculation and units",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/gas-laws.md",
            "lines": [
              10,
              140
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-chemistry-mole-concept",
          "reason": "Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                54,
                58
              ],
              "note": "n in ideal gas relation"
            },
            {
              "path": "content/lessons/science/chemistry/gas-laws.md",
              "lines": [
                96,
                104
              ],
              "note": "calculate moles"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                12,
                24
              ],
              "note": "mole and amount meaning"
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-history-of-the-atom",
      "path": "content/lessons/science/chemistry/history-of-the-atom.md",
      "sha256": "a996cb5fc57e7b888cc074afc6ee413aa5874e743d64b31cde0a71493d712aec",
      "readLines": [
        1,
        136
      ],
      "goal": "Connect major atomic models to the observations they explained and identify the limits of historical models.",
      "skills": [
        {
          "name": "Historical model changes and limits",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/history-of-the-atom.md",
              "lines": [
                12,
                53
              ],
              "note": "Historical model changes and limits teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/history-of-the-atom.md",
              "lines": [
                57,
                69
              ],
              "note": "Historical model changes and limits example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "pupcet-L114",
            "dost-sei-L099",
            "sm-foundation-L137"
          ],
          "limitations": [
            "History is supportive particle-model teaching, not proof chronology is tested"
          ]
        },
        {
          "name": "Evidence-to-conclusion reasoning from scattering",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/history-of-the-atom.md",
              "lines": [
                30,
                39
              ],
              "note": "Evidence-to-conclusion reasoning from scattering teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/history-of-the-atom.md",
              "lines": [
                71,
                80
              ],
              "note": "Evidence-to-conclusion reasoning from scattering example"
            }
          ],
          "requirementRefs": [
            "dcat-L077",
            "ustet-L113",
            "acet-L126"
          ],
          "limitations": [
            "Observation and inference are concrete; learner does not design controls or interpret a numeric data set"
          ]
        },
        {
          "name": "Quantized versus modern probability models",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/history-of-the-atom.md",
              "lines": [
                41,
                53
              ],
              "note": "Quantized versus modern probability models teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/history-of-the-atom.md",
              "lines": [
                82,
                90
              ],
              "note": "Quantized versus modern probability models example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "dost-sei-L106"
          ],
          "limitations": []
        },
        {
          "name": "Isotopes challenge historical identical-mass claim",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/history-of-the-atom.md",
              "lines": [
                14,
                20
              ],
              "note": "Isotopes challenge historical identical-mass claim teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/history-of-the-atom.md",
              "lines": [
                92,
                98
              ],
              "note": "Isotopes challenge historical identical-mass claim example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "pupcet-L114"
          ],
          "limitations": []
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L099",
            "dost-sei-L104",
            "dost-sei-L106"
          ],
          "sharedCore": "Historical model changes and limits; Evidence-to-conclusion reasoning from scattering; Quantized versus modern probability models; Isotopes challenge historical identical-mass claim",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L114",
            "pupcet-L128"
          ],
          "sharedCore": "Historical model changes and limits; Evidence-to-conclusion reasoning from scattering; Quantized versus modern probability models; Isotopes challenge historical identical-mass claim",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L048",
            "sm-foundation-L137",
            "sm-foundation-L141"
          ],
          "sharedCore": "Historical model changes and limits; Evidence-to-conclusion reasoning from scattering; Quantized versus modern probability models; Isotopes challenge historical identical-mass claim",
          "partialLimits": "Only local facets; advanced detail is not established as required. Science inclusion unconfirmed; background only. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L144",
            "upcat-L161"
          ],
          "sharedCore": "Historical model changes and limits; Evidence-to-conclusion reasoning from scattering; Quantized versus modern probability models; Isotopes challenge historical identical-mass claim",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114",
            "ustet-L123"
          ],
          "sharedCore": "Historical model changes and limits; Evidence-to-conclusion reasoning from scattering; Quantized versus modern probability models; Isotopes challenge historical identical-mass claim",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/history-of-the-atom.md",
            "lines": [
              10,
              136
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-matter",
      "path": "content/lessons/science/chemistry/matter.md",
      "sha256": "c30169e7a90819270667224b8201abdf090b129f7ec1d72e454a564f79b0aa2f",
      "readLines": [
        1,
        118
      ],
      "goal": "Classify matter and distinguish properties, physical/chemical changes and phase changes for shared introductory preparation.",
      "skills": [
        {
          "name": "Element compound and mixture classification",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/matter.md",
              "lines": [
                14,
                21
              ],
              "note": "Element compound and mixture classification teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/matter.md",
              "lines": [
                58,
                66
              ],
              "note": "Element compound and mixture classification example"
            }
          ],
          "requirementRefs": [
            "upcat-L143",
            "upcat-L161",
            "acet-L127",
            "ustet-L114",
            "pupcet-L114",
            "dost-sei-L099",
            "sm-foundation-L137"
          ],
          "limitations": []
        },
        {
          "name": "Bulk states and particle-state explanation",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/matter.md",
              "lines": [
                23,
                33
              ],
              "note": "L01 structural teaching assessment: Bulk states and particle-state explanation"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L114",
            "dost-sei-L099",
            "sm-foundation-L137"
          ],
          "limitations": [
            "Bulk behavior is explained; particle spacing, movement and attractions largely reside in a figure marker or a crystal trap, not a causal particle account"
          ]
        },
        {
          "name": "Phase changes and energy direction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/matter.md",
              "lines": [
                35,
                46
              ],
              "note": "Phase changes and energy direction teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/matter.md",
              "lines": [
                68,
                75
              ],
              "note": "Phase changes and energy direction example"
            }
          ],
          "requirementRefs": [
            "upcat-L143",
            "pupcet-L114"
          ],
          "limitations": []
        },
        {
          "name": "Physical versus chemical properties and changes",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/matter.md",
              "lines": [
                48,
                54
              ],
              "note": "Physical versus chemical properties and changes teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/matter.md",
              "lines": [
                77,
                86
              ],
              "note": "Physical versus chemical properties and changes example"
            }
          ],
          "requirementRefs": [
            "upcat-L143",
            "ustet-L114",
            "pupcet-L114",
            "sm-foundation-L137"
          ],
          "limitations": []
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L040",
            "acet-L127"
          ],
          "sharedCore": "Element compound and mixture classification; Phase changes and energy direction; Physical versus chemical properties and changes",
          "partialLimits": "Only local facets; advanced detail is not established as required. Science inclusion unconfirmed; background only. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L099",
            "dost-sei-L104",
            "dost-sei-L106"
          ],
          "sharedCore": "Element compound and mixture classification; Phase changes and energy direction; Physical versus chemical properties and changes",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L114",
            "pupcet-L117",
            "pupcet-L128"
          ],
          "sharedCore": "Element compound and mixture classification; Phase changes and energy direction; Physical versus chemical properties and changes",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L048",
            "sm-foundation-L137",
            "sm-foundation-L141"
          ],
          "sharedCore": "Element compound and mixture classification; Phase changes and energy direction; Physical versus chemical properties and changes",
          "partialLimits": "Only local facets; advanced detail is not established as required. Science inclusion unconfirmed; background only. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L143",
            "upcat-L144",
            "upcat-L161"
          ],
          "sharedCore": "Element compound and mixture classification; Phase changes and energy direction; Physical versus chemical properties and changes",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114",
            "ustet-L123"
          ],
          "sharedCore": "Element compound and mixture classification; Phase changes and energy direction; Physical versus chemical properties and changes",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/matter.md",
            "lines": [
              10,
              118
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-mixtures-and-separation",
      "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
      "sha256": "fe384ae5a486e1782779aa3a79ddffbb603e8e67969aa16ebfaa71b1d05da80e",
      "readLines": [
        1,
        139
      ],
      "goal": "Choose a physical separation method from mixture type and component properties, recognizing ordinary method limits.",
      "skills": [
        {
          "name": "Homogeneous heterogeneous and chemical identity",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                12,
                16
              ],
              "note": "Homogeneous heterogeneous and chemical identity teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                54,
                62
              ],
              "note": "Homogeneous heterogeneous and chemical identity example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L114",
            "dost-sei-L099",
            "sm-foundation-L137"
          ],
          "limitations": []
        },
        {
          "name": "Filtration of suspended versus dissolved solids",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                18,
                24
              ],
              "note": "Filtration of suspended versus dissolved solids teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                64,
                72
              ],
              "note": "Filtration of suspended versus dissolved solids example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L114",
            "dost-sei-L099"
          ],
          "limitations": []
        },
        {
          "name": "Distillation volatility and separation limits",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                26,
                34
              ],
              "note": "Distillation volatility and separation limits teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                74,
                82
              ],
              "note": "Distillation volatility and separation limits example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "dost-sei-L099"
          ],
          "limitations": [
            "Vapor-liquid equilibrium is qualitative; quantitative mixtures or purity depth unknown"
          ]
        },
        {
          "name": "Chromatography phases and observation inference",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                38,
                44
              ],
              "note": "Chromatography phases and observation inference teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                84,
                92
              ],
              "note": "Chromatography phases and observation inference example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "dcat-L077",
            "ustet-L113",
            "acet-L126"
          ],
          "limitations": [
            "Example infers multiple components but does not interpret measured chromatogram positions or experimental controls"
          ]
        },
        {
          "name": "Evaporation versus crystallization",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                46,
                50
              ],
              "note": "Evaporation versus crystallization teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
              "lines": [
                74,
                82
              ],
              "note": "Evaporation versus crystallization example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L114"
          ],
          "limitations": []
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L099"
          ],
          "sharedCore": "Homogeneous heterogeneous and chemical identity; Filtration of suspended versus dissolved solids; Distillation volatility and separation limits; Chromatography phases and observation inference; Evaporation versus crystallization",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L114",
            "pupcet-L128"
          ],
          "sharedCore": "Homogeneous heterogeneous and chemical identity; Filtration of suspended versus dissolved solids; Distillation volatility and separation limits; Chromatography phases and observation inference; Evaporation versus crystallization",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L048",
            "sm-foundation-L137"
          ],
          "sharedCore": "Homogeneous heterogeneous and chemical identity; Filtration of suspended versus dissolved solids; Distillation volatility and separation limits; Chromatography phases and observation inference; Evaporation versus crystallization",
          "partialLimits": "Only local facets; advanced detail is not established as required. Science inclusion unconfirmed; background only. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L161"
          ],
          "sharedCore": "Homogeneous heterogeneous and chemical identity; Filtration of suspended versus dissolved solids; Distillation volatility and separation limits; Chromatography phases and observation inference; Evaporation versus crystallization",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114"
          ],
          "sharedCore": "Homogeneous heterogeneous and chemical identity; Filtration of suspended versus dissolved solids; Distillation volatility and separation limits; Chromatography phases and observation inference; Evaporation versus crystallization",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
            "lines": [
              10,
              139
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-mole-concept",
      "path": "content/lessons/science/chemistry/mole-concept.md",
      "sha256": "7ced9877db7997594d74ac27a553aad3dcf39e3f06dca7ee4644670485bdee12",
      "readLines": [
        1,
        112
      ],
      "goal": "Convert among mass, moles and specified entities, and derive molar mass from chemical composition for simple chemical-amount preparation.",
      "skills": [
        {
          "name": "Mole and specified entity",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                12,
                24
              ],
              "note": "Mole and specified entity teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                62,
                70
              ],
              "note": "Mole and specified entity example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "dcat-L085",
            "ustet-L114",
            "pupcet-L115"
          ],
          "limitations": []
        },
        {
          "name": "Molar mass from formula",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                26,
                32
              ],
              "note": "Molar mass from formula teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                48,
                54
              ],
              "note": "Molar mass from formula example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "dcat-L085",
            "ustet-L114",
            "pupcet-L115"
          ],
          "limitations": []
        },
        {
          "name": "Mass-to-moles conversion",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                34,
                38
              ],
              "note": "Mass-to-moles conversion teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                56,
                60
              ],
              "note": "Mass-to-moles conversion example"
            }
          ],
          "requirementRefs": [
            "upcat-L143",
            "upcat-L161",
            "dcat-L085",
            "ustet-L114",
            "pupcet-L115"
          ],
          "limitations": []
        },
        {
          "name": "Moles-to-entities and combined mass-to-entities",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                40,
                44
              ],
              "note": "Moles-to-entities and combined mass-to-entities teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                62,
                78
              ],
              "note": "Moles-to-entities and combined mass-to-entities example"
            }
          ],
          "requirementRefs": [
            "upcat-L143",
            "dcat-L085",
            "ustet-L114",
            "pupcet-L115"
          ],
          "limitations": []
        }
      ],
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L037",
            "dcat-L085"
          ],
          "sharedCore": "Mole and specified entity; Molar mass from formula; Mass-to-moles conversion; Moles-to-entities and combined mass-to-entities",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L115",
            "pupcet-L128"
          ],
          "sharedCore": "Mole and specified entity; Molar mass from formula; Mass-to-moles conversion; Moles-to-entities and combined mass-to-entities",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L143",
            "upcat-L161"
          ],
          "sharedCore": "Mole and specified entity; Molar mass from formula; Mass-to-moles conversion; Moles-to-entities and combined mass-to-entities",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114"
          ],
          "sharedCore": "Mole and specified entity; Molar mass from formula; Mass-to-moles conversion; Moles-to-entities and combined mass-to-entities",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/mole-concept.md",
            "lines": [
              10,
              112
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-nuclear-chemistry",
      "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
      "sha256": "2033a4cf11cd038a5e5a8c893cf4c8970abb04c064e2f314f9554e2bd118300d",
      "readLines": [
        1,
        139
      ],
      "goal": "Track atomic/mass-number changes for common decay modes and distinguish fission from fusion under weak nuclear-preparation scope.",
      "skills": [
        {
          "name": "Alpha and beta-minus daughter bookkeeping",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
              "lines": [
                14,
                28
              ],
              "note": "Alpha and beta-minus daughter bookkeeping teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
              "lines": [
                65,
                81
              ],
              "note": "Alpha and beta-minus daughter bookkeeping example"
            }
          ],
          "requirementRefs": [
            "upcat-L146"
          ],
          "limitations": []
        },
        {
          "name": "Positron electron capture and gamma changes",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
              "lines": [
                30,
                45
              ],
              "note": "Positron electron capture and gamma changes teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
              "lines": [
                83,
                92
              ],
              "note": "Positron electron capture and gamma changes example"
            }
          ],
          "requirementRefs": [
            "upcat-L146"
          ],
          "limitations": [
            "Gamma has no separate applied example; no half-life calculation taught, and required nuclear depth unknown"
          ]
        },
        {
          "name": "Fission fusion and comparison basis",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
              "lines": [
                49,
                61
              ],
              "note": "Fission fusion and comparison basis teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
              "lines": [
                94,
                102
              ],
              "note": "Fission fusion and comparison basis example"
            }
          ],
          "requirementRefs": [
            "upcat-L146"
          ],
          "limitations": []
        },
        {
          "name": "Radiation penetration versus hazard",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
              "lines": [
                21,
                45
              ],
              "note": "Radiation penetration versus hazard teaching"
            }
          ],
          "exampleVerdict": "not-required",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L146"
          ],
          "limitations": []
        }
      ],
      "examApplicability": [
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L146"
          ],
          "sharedCore": "Alpha and beta-minus daughter bookkeeping; Positron electron capture and gamma changes; Fission fusion and comparison basis; Radiation penetration versus hazard",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
            "lines": [
              10,
              139
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-chemistry-atomic-structure",
          "reason": "Decay updates A and Z and identifies new elements, relying on proton/neutron identity not introduced here.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
              "lines": [
                16,
                26
              ],
              "note": "consumer uses foundation"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                24,
                42
              ],
              "note": "foundation taught"
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-periodic-table",
      "path": "content/lessons/science/chemistry/periodic-table.md",
      "sha256": "362c3336845a093254e97ef23c0f8db62bdea8018589e1ad3b6bc8aecb87d68d",
      "readLines": [
        1,
        114
      ],
      "goal": "Use groups, periods and qualified periodic trends to compare elements for weak finer UPCAT preparation.",
      "skills": [
        {
          "name": "Table groups periods and atomic-number ordering",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                12,
                20
              ],
              "note": "Table groups periods and atomic-number ordering teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                40,
                48
              ],
              "note": "Table groups periods and atomic-number ordering example"
            }
          ],
          "requirementRefs": [
            "upcat-L144"
          ],
          "limitations": [
            "Named families such as alkali metals, alkaline-earth metals, halogens and noble gases are not taught despite outline Families and Groups (B03 outline facet; L01 structural use only)"
          ]
        },
        {
          "name": "Atomic-radius trends",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                26,
                28
              ],
              "note": "Atomic-radius trends teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                50,
                58
              ],
              "note": "Atomic-radius trends example"
            }
          ],
          "requirementRefs": [
            "upcat-L144"
          ],
          "limitations": [
            "Effective nuclear charge is invoked but shielding mechanism not explained"
          ]
        },
        {
          "name": "First ionization energy trends",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                30,
                30
              ],
              "note": "First ionization energy trends teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                60,
                68
              ],
              "note": "First ionization energy trends example"
            }
          ],
          "requirementRefs": [
            "upcat-L144"
          ],
          "limitations": []
        },
        {
          "name": "Electronegativity meaning and trends",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                32,
                32
              ],
              "note": "Electronegativity meaning and trends teaching"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L144"
          ],
          "limitations": [
            "No worked electronegativity comparison"
          ]
        },
        {
          "name": "Electron-affinity meaning sign and exceptions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                34,
                36
              ],
              "note": "Electron-affinity meaning sign and exceptions teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                70,
                78
              ],
              "note": "Electron-affinity meaning sign and exceptions example"
            }
          ],
          "requirementRefs": [
            "upcat-L144"
          ],
          "limitations": []
        },
        {
          "name": "Recognize named periodic-table families",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                14,
                20
              ],
              "note": "B03 outline Families and Groups facet; group positions covered, named families not taught"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [],
          "limitations": [
            "Alkali metals, alkaline-earth metals, halogens and noble-gas family identities/properties not taught; exact exam demand unknown"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L144"
          ],
          "sharedCore": "Table groups periods and atomic-number ordering; Atomic-radius trends; First ionization energy trends; Electronegativity meaning and trends; Electron-affinity meaning sign and exceptions",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/periodic-table.md",
            "lines": [
              10,
              114
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-chemistry-atomic-structure",
          "reason": "Table ordering and electron-removal/addition trends rely on atomic number and electron/nuclear identity.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/chemistry/periodic-table.md",
              "lines": [
                12,
                34
              ],
              "note": "consumer uses foundation"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                12,
                26
              ],
              "note": "foundation taught"
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-quantum-numbers-electron-configuration",
      "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
      "sha256": "dbf0b6f78d23d3f6600a9546bcc98ed51052f2495670a036346a858fee8f06d6",
      "readLines": [
        1,
        145
      ],
      "goal": "Read introductory configurations and quantum labels, distinguish orbital/subshell capacities, and find main-group valence counts. Exact exam demand is unconfirmed.",
      "skills": [
        {
          "name": "Quantum number ranges and Pauli uniqueness",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                14,
                27
              ],
              "note": "Quantum number ranges and Pauli uniqueness teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                78,
                85
              ],
              "note": "Quantum number ranges and Pauli uniqueness example"
            }
          ],
          "requirementRefs": [],
          "limitations": [
            "No specific accepted quantum-number requirement; atomic-structure background connection only"
          ]
        },
        {
          "name": "Orbital versus subshell capacities",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                29,
                40
              ],
              "note": "Orbital versus subshell capacities teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                70,
                76
              ],
              "note": "Orbital versus subshell capacities example"
            }
          ],
          "requirementRefs": [],
          "limitations": []
        },
        {
          "name": "Aufbau Hund and Pauli filling",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                44,
                56
              ],
              "note": "Aufbau Hund and Pauli filling teaching"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                70,
                76
              ],
              "note": "Aufbau Hund and Pauli filling example"
            }
          ],
          "requirementRefs": [],
          "limitations": [
            "Nitrogen configuration is supplied rather than built stepwise; no paired versus unpaired orbital sequence"
          ]
        },
        {
          "name": "Configuration reading electron and valence counts",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                58,
                66
              ],
              "note": "Configuration reading electron and valence counts teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                87,
                95
              ],
              "note": "Configuration reading electron and valence counts example"
            }
          ],
          "requirementRefs": [],
          "limitations": []
        },
        {
          "name": "Filling versus ionization order limits",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                97,
                103
              ],
              "note": "Filling versus ionization order limits teaching"
            }
          ],
          "exampleVerdict": "not-required",
          "exampleEvidence": [],
          "requirementRefs": [],
          "limitations": [
            "Chromium/copper exceptions named but not constructed; no ionic configuration worked"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L106"
          ],
          "sharedCore": "Electron configuration supports the broader atomic-structure preparation facet.",
          "partialLimits": "Added local foundation connection beyond the original empty name packet; quantum-number/configuration depth itself not established by the broad curriculum row.",
          "depth": "unknown: specialized preparation does not establish exact quantum-number demand",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
            "lines": [
              10,
              145
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-chemistry-atomic-structure",
          "reason": "Configuration-to-element identification uses neutrality, Z and electron count.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
              "lines": [
                87,
                95
              ],
              "note": "consumer uses foundation"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/chemistry/atomic-structure.md",
              "lines": [
                24,
                38
              ],
              "note": "foundation taught"
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-solutions",
      "path": "content/lessons/science/chemistry/solutions.md",
      "sha256": "d30469a2a90bd0b8453d0d4364caa038dcffe9148885b3721971cb2cc5c27800",
      "readLines": [
        1,
        113
      ],
      "goal": "Distinguish solution components and solubility states, and calculate concentration with the correct denominator.",
      "skills": [
        {
          "name": "Solvent solute and saturation states",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                12,
                22
              ],
              "note": "Solvent solute and saturation states teaching"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L145",
            "ustet-L125",
            "pupcet-L114",
            "dost-sei-L108"
          ],
          "limitations": [
            "No applied saturation example or solubility data/curve interpretation"
          ]
        },
        {
          "name": "Molarity",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                26,
                28
              ],
              "note": "L01 local facet: Molarity"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                49,
                53
              ],
              "note": "L19 worked local facet: Molarity"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "pupcet-L114"
          ],
          "limitations": []
        },
        {
          "name": "Molality",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                30,
                34
              ],
              "note": "L01 local facet: Molality"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                55,
                59
              ],
              "note": "L19 worked local facet: Molality"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "pupcet-L114"
          ],
          "limitations": []
        },
        {
          "name": "Mass percent",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                36,
                38
              ],
              "note": "L01 local facet: Mass percent"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                61,
                68
              ],
              "note": "L19 worked local facet: Mass percent"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "pupcet-L114"
          ],
          "limitations": []
        },
        {
          "name": "Volume percent",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                40,
                44
              ],
              "note": "L01 local facet: Volume percent"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L145",
            "pupcet-L114"
          ],
          "limitations": [
            "No worked volume-percent computation"
          ]
        },
        {
          "name": "Temperature and concentration denominators",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                34,
                44
              ],
              "note": "Temperature and concentration denominators teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                70,
                79
              ],
              "note": "Temperature and concentration denominators example"
            }
          ],
          "requirementRefs": [
            "upcat-L145",
            "ustet-L125"
          ],
          "limitations": []
        },
        {
          "name": "Dilution amount conservation",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                24,
                44
              ],
              "note": "L01 structural teaching assessment: Dilution amount conservation"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L145"
          ],
          "limitations": [
            "No dilution relation or reasoning from conserved solute amount"
          ]
        },
        {
          "name": "Product-composition and safe household-chemical application",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                12,
                44
              ],
              "note": "L01 structural teaching assessment: Product-composition and safe household-chemical application"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "ustet-L125",
            "dost-sei-L108"
          ],
          "limitations": [
            "No product-label interpretation, safe storage/mixing/disposal or household safety procedure; another topic may teach safety"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L108"
          ],
          "sharedCore": "Solvent solute and saturation states; Molarity; Molality; Mass percent; Volume percent; Temperature and concentration denominators",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L114",
            "pupcet-L128"
          ],
          "sharedCore": "Solvent solute and saturation states; Molarity; Molality; Mass percent; Volume percent; Temperature and concentration denominators",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L145"
          ],
          "sharedCore": "Solvent solute and saturation states; Molarity; Molality; Mass percent; Volume percent; Temperature and concentration denominators",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L125"
          ],
          "sharedCore": "Solvent solute and saturation states; Molarity; Molality; Mass percent; Volume percent; Temperature and concentration denominators",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The core and examples support one coherent lesson goal.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/solutions.md",
            "lines": [
              10,
              113
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared lesson; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-chemistry-mole-concept",
          "reason": "Concentration teaching and worked examples use moles without defining amount or a mole.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/chemistry/solutions.md",
              "lines": [
                26,
                32
              ],
              "note": "consumer uses foundation"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                12,
                24
              ],
              "note": "foundation taught"
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-stoichiometry",
      "path": "content/lessons/science/chemistry/stoichiometry.md",
      "sha256": "bd0c4c00ccae1105da06a54b02a15aaa0eecbf7906a5ea179c6828cd3d7b173a",
      "readLines": [
        1,
        134
      ],
      "goal": "Use balanced reaction ratios for limiting/yield reasoning and use composition ratios to derive empirical and molecular formulas.",
      "skills": [
        {
          "name": "Balanced-equation mole-to-mole product relationships",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                12,
                18
              ],
              "note": "L01 local facet: Balanced-equation mole-to-mole product relationships"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                46,
                60
              ],
              "note": "L19 worked local facet: Balanced-equation mole-to-mole product relationships"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L115",
            "dcat-L085",
            "dost-sei-L104"
          ],
          "limitations": [
            "Limiting example infers reactant demand; no explicit calculation of product moles"
          ]
        },
        {
          "name": "Balanced-equation mole-to-mass product relationships",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                12,
                18
              ],
              "note": "L01 local facet: Balanced-equation mole-to-mass product relationships"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L115",
            "dcat-L085",
            "dost-sei-L104"
          ],
          "limitations": [
            "No reaction-ratio-to-product-mass procedure or worked chain"
          ]
        },
        {
          "name": "Balanced-equation mass-to-mass product relationships",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                12,
                18
              ],
              "note": "L01 local facet: Balanced-equation mass-to-mass product relationships"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L114",
            "pupcet-L115",
            "dcat-L085",
            "dost-sei-L104"
          ],
          "limitations": [
            "No reactant-mass to moles to reaction-ratio to product-mass worked chain"
          ]
        },
        {
          "name": "Limiting and excess reactant decisions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                14,
                18
              ],
              "note": "Limiting and excess reactant decisions teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                46,
                60
              ],
              "note": "Limiting and excess reactant decisions example"
            }
          ],
          "requirementRefs": [
            "upcat-L144",
            "dcat-L082",
            "ustet-L123",
            "dost-sei-L104"
          ],
          "limitations": [
            "No theoretical product quantity or remaining excess calculation"
          ]
        },
        {
          "name": "Theoretical yield from reactant data",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                20,
                28
              ],
              "note": "L01 local facet: Theoretical yield from reactant data"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L082",
            "ustet-L123",
            "dost-sei-L104"
          ],
          "limitations": [
            "Definition given; theoretical yield supplied rather than derived from limiting-reactant data"
          ]
        },
        {
          "name": "Percent yield from actual and theoretical amounts",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                20,
                28
              ],
              "note": "L01 local facet: Percent yield from actual and theoretical amounts"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                62,
                66
              ],
              "note": "L19 worked local facet: Percent yield from actual and theoretical amounts"
            }
          ],
          "requirementRefs": [
            "dcat-L082",
            "ustet-L123",
            "dost-sei-L104"
          ],
          "limitations": []
        },
        {
          "name": "Empirical formulas from mole ratios",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                30,
                42
              ],
              "note": "Empirical formulas from mole ratios teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                68,
                86
              ],
              "note": "Empirical formulas from mole ratios example"
            }
          ],
          "requirementRefs": [],
          "limitations": [
            "Composition-to-moles from mass/percent composition not worked; empirical-formula depth not specifically confirmed by broad refs"
          ]
        },
        {
          "name": "Molecular formula multiplier from molar masses",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                30,
                36
              ],
              "note": "L01 structural teaching assessment: Molecular formula multiplier from molar masses"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                88,
                96
              ],
              "note": "Molecular formula multiplier from molar masses example"
            }
          ],
          "requirementRefs": [],
          "limitations": [
            "Multiplier relation appears first in example and later shortcut, not Core Concept (structural L17); no specific current depth established"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L037",
            "dcat-L082",
            "dcat-L085"
          ],
          "sharedCore": "Balanced-equation reaction-amount preparation; taught limiting-reactant and yield facets are separate from the thin simple mole/mass route.",
          "partialLimits": "JHS simple mole/mass preparation is narrower than conditional SHS limiting/yield work. Empirical/molecular formula demand is not specified by these mapped rows; depth remains unknown.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L104"
          ],
          "sharedCore": "Balanced-equation reaction-amount preparation; taught limiting-reactant and yield facets are separate from the thin simple mole/mass route.",
          "partialLimits": "JHS simple mole/mass preparation is narrower than conditional SHS limiting/yield work. Empirical/molecular formula demand is not specified by these mapped rows; depth remains unknown.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L115",
            "pupcet-L123",
            "pupcet-L128"
          ],
          "sharedCore": "Balanced-equation reaction-amount preparation; taught limiting-reactant and yield facets are separate from the thin simple mole/mass route.",
          "partialLimits": "JHS simple mole/mass preparation is narrower than conditional SHS limiting/yield work. Empirical/molecular formula demand is not specified by these mapped rows; depth remains unknown.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L143",
            "upcat-L144",
            "upcat-L161"
          ],
          "sharedCore": "Balanced-equation reaction-amount preparation; taught limiting-reactant and yield facets are separate from the thin simple mole/mass route.",
          "partialLimits": "JHS simple mole/mass preparation is narrower than conditional SHS limiting/yield work. Empirical/molecular formula demand is not specified by these mapped rows; depth remains unknown.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L114",
            "ustet-L123"
          ],
          "sharedCore": "Balanced-equation reaction-amount preparation; taught limiting-reactant and yield facets are separate from the thin simple mole/mass route.",
          "partialLimits": "JHS simple mole/mass preparation is narrower than conditional SHS limiting/yield work. Empirical/molecular formula demand is not specified by these mapped rows; depth remains unknown.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "Reaction amounts and composition-to-formula inference have distinct goals and do not require each other. The base reaction-quantity route is currently thin (L01/L17/L19).",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/stoichiometry.md",
            "lines": [
              12,
              96
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Keep one shared reaction-quantity core with simple mole/mass chains, then limiting/yield extensions. Move empirical/molecular formula inference into a separate composition lesson without duplicating mole conversion.",
        "cost": "Requires new approved lesson identity/routing, moving examples and traps, adding missing reaction-quantity examples and composition teaching, plus later linked-practice review."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-chemistry-mole-concept",
          "reason": "Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/chemistry/stoichiometry.md",
              "lines": [
                46,
                60
              ],
              "note": "consumer uses foundation"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/chemistry/mole-concept.md",
              "lines": [
                12,
                38
              ],
              "note": "foundation taught"
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-chemistry-thermodynamics-and-kinetics",
      "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
      "sha256": "e6716a70db409220611ee4f71d4e010673e236fed16a51b33130bf4fb03fac34",
      "readLines": [
        1,
        154
      ],
      "goal": "Distinguish heat direction from reaction speed, explain catalysts and basic rate factors, and use a supplied simple rate-law condition.",
      "skills": [
        {
          "name": "Heat direction and enthalpy sign",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                19,
                28
              ],
              "note": "Heat direction and enthalpy sign teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                63,
                70
              ],
              "note": "Heat direction and enthalpy sign example"
            }
          ],
          "requirementRefs": [
            "upcat-L146",
            "ustet-L123",
            "pupcet-L123"
          ],
          "limitations": []
        },
        {
          "name": "Activation barrier collision conditions and catalyst pathway",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                32,
                50
              ],
              "note": "Activation barrier collision conditions and catalyst pathway teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                93,
                102
              ],
              "note": "Activation barrier collision conditions and catalyst pathway example"
            }
          ],
          "requirementRefs": [
            "upcat-L146",
            "upcat-L161",
            "ustet-L123",
            "dost-sei-L104",
            "dost-sei-L106"
          ],
          "limitations": [
            "Arrhenius relation introduced but no numerical application; exact needed depth unknown"
          ]
        },
        {
          "name": "Surface area temperature and concentration rate factors",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                52,
                59
              ],
              "note": "Surface area temperature and concentration rate factors teaching"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                83,
                91
              ],
              "note": "Surface area temperature and concentration rate factors example"
            }
          ],
          "requirementRefs": [
            "upcat-L161",
            "ustet-L123",
            "pupcet-L123",
            "dost-sei-L099",
            "sm-foundation-L137"
          ],
          "limitations": [
            "No worked temperature comparison"
          ]
        },
        {
          "name": "Rate-law order reasoning",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                56,
                57
              ],
              "note": "L01 structural teaching assessment: Rate-law order reasoning"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                104,
                114
              ],
              "note": "Rate-law order reasoning example"
            }
          ],
          "requirementRefs": [
            "upcat-L146",
            "dost-sei-L106"
          ],
          "limitations": [
            "Rate-law notation and exponent/order meaning not introduced before the worked zero-order example (structural L17/L19)"
          ]
        },
        {
          "name": "Chemical equilibrium foundation",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                14,
                17
              ],
              "note": "L01 structural teaching assessment: Chemical equilibrium foundation"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                72,
                81
              ],
              "note": "Chemical equilibrium foundation example"
            }
          ],
          "requirementRefs": [
            "upcat-L146",
            "dost-sei-L106"
          ],
          "limitations": [
            "No dynamic forward/reverse rate balance, equilibrium constant construction, or response-to-condition change; catalyst effect is not full equilibrium teaching"
          ]
        },
        {
          "name": "Scientific comparison and controls",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                74,
                91
              ],
              "note": "L01 structural teaching assessment: Scientific comparison and controls"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
              "lines": [
                104,
                114
              ],
              "note": "Scientific comparison and controls example"
            }
          ],
          "requirementRefs": [
            "dcat-L077",
            "ustet-L113",
            "acet-L126"
          ],
          "limitations": [
            "All-else-fixed comparisons apply control logic without teaching experimental variable/control identification"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L094",
            "dost-sei-L099",
            "dost-sei-L104"
          ],
          "sharedCore": "Heat direction and enthalpy sign; Activation barrier collision conditions and catalyst pathway; Surface area temperature and concentration rate factors",
          "partialLimits": "Only local facets; advanced detail is not established as required. 2026 official Chemistry domain; 2027 continuity unknown. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L123",
            "pupcet-L128"
          ],
          "sharedCore": "Heat direction and enthalpy sign; Activation barrier collision conditions and catalyst pathway; Surface area temperature and concentration rate factors",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L048",
            "sm-foundation-L137"
          ],
          "sharedCore": "Heat direction and enthalpy sign; Activation barrier collision conditions and catalyst pathway; Surface area temperature and concentration rate factors",
          "partialLimits": "Only local facets; advanced detail is not established as required. Science inclusion unconfirmed; background only. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L035",
            "upcat-L122",
            "upcat-L142",
            "upcat-L146",
            "upcat-L161"
          ],
          "sharedCore": "Heat direction and enthalpy sign; Activation barrier collision conditions and catalyst pathway; Surface area temperature and concentration rate factors",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L040",
            "ustet-L109",
            "ustet-L123"
          ],
          "sharedCore": "Heat direction and enthalpy sign; Activation barrier collision conditions and catalyst pathway; Surface area temperature and concentration rate factors",
          "partialLimits": "Only local facets; advanced detail is not established as required. Apply topic scope limits.",
          "depth": "unknown: no current detailed organizer depth established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports this preparation candidate; source confidence and topic scope limits remain."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Comparing thermochemistry and rate directly prevents conflating energy release with speed; the paired goal benefits from one lesson.",
        "evidence": [
          {
            "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
            "lines": [
              12,
              114
            ],
            "note": "structure basis"
          }
        ],
        "proposal": "Retain comparison core. Add equilibrium foundation and rate-law notation before their use; isolate quantitative equilibrium/kinetics extensions only if later scoped.",
        "cost": "Requires targeted teaching and example revision; premature splitting would duplicate the contrast and preserve missing foundations."
      },
      "prerequisites": [],
      "prerequisiteStatus": "missing-foundation",
      "missingFoundations": [
        "Dynamic-equilibrium meaning is missing locally before the catalyst equilibrium example; no verified existing chemistry lesson teaches it fully"
      ],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    }
  ],
  "requirementFacets": [
    {
      "requirementRefs": [
        "dcat-L077",
        "ustet-L113",
        "acet-L126"
      ],
      "facet": "Identify independent dependent and controlled variables in a chemical investigation",
      "lessonIds": [
        "lesson-chemistry-gas-laws",
        "lesson-chemistry-thermodynamics-and-kinetics"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            18,
            44
          ],
          "note": "Conditions for gas formulas, not experimental-variable identification"
        },
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            74,
            114
          ],
          "note": "Controlled comparisons, no variable-role teaching"
        }
      ],
      "missingIdeas": [
        "Explicit independent/dependent/control roles and how to isolate a chemical effect"
      ],
      "priorKnowledge": "Topic explains chemical relationships; designing or diagnosing a fair test is distinct.",
      "workedExamples": "none for variable-role identification",
      "scopeLimit": "Absent within all 17 full-read chemistry lessons only. Curriculum-inferred preparation; ACET science inclusion unknown. Other topic teaching not judged absent."
    },
    {
      "requirementRefs": [
        "dcat-L077",
        "ustet-L113"
      ],
      "facet": "Interpret measured chemical-investigation data and representations",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            71,
            80
          ],
          "note": "Qualitative scattering observations"
        },
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            84,
            100
          ],
          "note": "Qualitative chromatogram/distillation observations"
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            62,
            106
          ],
          "note": "Given quantities in calculation examples, no measured investigation data interpretation"
        }
      ],
      "missingIdeas": [
        "Use a measured chemical data table/graph to identify a trend, compare results or support a conclusion"
      ],
      "priorKnowledge": "Basic data reading is a cross-topic search lead for lead reconciliation; no prerequisite edge asserted.",
      "workedExamples": "none for a measured chemical investigation representation",
      "scopeLimit": "Absent within full-read chemistry topic, not a corpus-wide absence. Required current exam depth remains unknown."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "dost-sei-L106"
      ],
      "facet": "Arrhenius and proton-transfer definitions",
      "lessonIds": [
        "lesson-chemistry-acids-bases-ph"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/acids-bases-ph.md",
          "lines": [
            12,
            18
          ],
          "note": "Arrhenius and proton-transfer definitions teaching"
        },
        {
          "path": "content/lessons/science/chemistry/acids-bases-ph.md",
          "lines": [
            94,
            105
          ],
          "note": "Arrhenius and proton-transfer definitions example"
        }
      ],
      "missingIdeas": [
        "No worked donor/acceptor identification in a non-hydroxide reaction"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "dost-sei-L106"
      ],
      "facet": "pH classification and logarithmic activity comparison",
      "lessonIds": [
        "lesson-chemistry-acids-bases-ph"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/acids-bases-ph.md",
          "lines": [
            20,
            40
          ],
          "note": "pH classification and logarithmic activity comparison teaching"
        },
        {
          "path": "content/lessons/science/chemistry/acids-bases-ph.md",
          "lines": [
            64,
            83
          ],
          "note": "pH classification and logarithmic activity comparison example"
        }
      ],
      "missingIdeas": [
        "No direct concentration-to-pH worked example; acid-base equilibrium solving not taught"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "dost-sei-L106"
      ],
      "facet": "Strong versus weak and concentration distinction",
      "lessonIds": [
        "lesson-chemistry-acids-bases-ph"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/acids-bases-ph.md",
          "lines": [
            42,
            46
          ],
          "note": "Strong versus weak and concentration distinction teaching"
        },
        {
          "path": "content/lessons/science/chemistry/acids-bases-ph.md",
          "lines": [
            85,
            92
          ],
          "note": "Strong versus weak and concentration distinction example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "dost-sei-L106"
      ],
      "facet": "Neutralization and spectator ions",
      "lessonIds": [
        "lesson-chemistry-acids-bases-ph"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/acids-bases-ph.md",
          "lines": [
            48,
            60
          ],
          "note": "Neutralization and spectator ions teaching"
        },
        {
          "path": "content/lessons/science/chemistry/acids-bases-ph.md",
          "lines": [
            94,
            105
          ],
          "note": "Neutralization and spectator ions example"
        }
      ],
      "missingIdeas": [
        "No titration or quantitative neutralization calculation; required depth unknown"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L114",
        "dost-sei-L099",
        "sm-foundation-L137"
      ],
      "facet": "Particle location and charge",
      "lessonIds": [
        "lesson-chemistry-atomic-structure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/atomic-structure.md",
          "lines": [
            12,
            20
          ],
          "note": "Particle location and charge teaching"
        },
        {
          "path": "content/lessons/science/chemistry/atomic-structure.md",
          "lines": [
            58,
            67
          ],
          "note": "Particle location and charge example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "ustet-L114",
        "pupcet-L114",
        "dost-sei-L106"
      ],
      "facet": "Atomic number and mass number",
      "lessonIds": [
        "lesson-chemistry-atomic-structure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/atomic-structure.md",
          "lines": [
            24,
            38
          ],
          "note": "Atomic number and mass number teaching"
        },
        {
          "path": "content/lessons/science/chemistry/atomic-structure.md",
          "lines": [
            58,
            67
          ],
          "note": "Atomic number and mass number example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "pupcet-L114",
        "dost-sei-L106"
      ],
      "facet": "Isotopes versus isotope-weighted atomic mass",
      "lessonIds": [
        "lesson-chemistry-atomic-structure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/atomic-structure.md",
          "lines": [
            40,
            44
          ],
          "note": "Isotopes versus isotope-weighted atomic mass teaching"
        },
        {
          "path": "content/lessons/science/chemistry/atomic-structure.md",
          "lines": [
            69,
            76
          ],
          "note": "Isotopes versus isotope-weighted atomic mass example"
        }
      ],
      "missingIdeas": [
        "Weighted atomic mass calculation not demonstrated; exact needed depth unknown"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L114",
        "dost-sei-L106"
      ],
      "facet": "Ion charge and electron counts",
      "lessonIds": [
        "lesson-chemistry-atomic-structure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/atomic-structure.md",
          "lines": [
            46,
            54
          ],
          "note": "Ion charge and electron counts teaching"
        },
        {
          "path": "content/lessons/science/chemistry/atomic-structure.md",
          "lines": [
            78,
            95
          ],
          "note": "Ion charge and electron counts example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146",
        "upcat-L161",
        "pupcet-L115"
      ],
      "facet": "Organic scope and carbon frameworks",
      "lessonIds": [
        "lesson-chemistry-basic-organic-chemistry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
          "lines": [
            12,
            14
          ],
          "note": "Organic scope and carbon frameworks teaching"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "not-required",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146",
        "upcat-L161",
        "pupcet-L115"
      ],
      "facet": "Hydrocarbon families and ring saturation",
      "lessonIds": [
        "lesson-chemistry-basic-organic-chemistry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
          "lines": [
            16,
            32
          ],
          "note": "Hydrocarbon families and ring saturation teaching"
        },
        {
          "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
          "lines": [
            67,
            94
          ],
          "note": "Hydrocarbon families and ring saturation example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146",
        "upcat-L161",
        "dcat-L079"
      ],
      "facet": "Functional groups and structure-property reasoning",
      "lessonIds": [
        "lesson-chemistry-basic-organic-chemistry"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
          "lines": [
            34,
            45
          ],
          "note": "L01 structural teaching assessment: Functional groups and structure-property reasoning"
        },
        {
          "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
          "lines": [
            96,
            104
          ],
          "note": "Functional groups and structure-property reasoning example"
        }
      ],
      "missingIdeas": [
        "Aldehyde versus ketone environments not defined; no concrete structures or property comparison derived from a named pair"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146"
      ],
      "facet": "Simple IUPAC parent selection and substituent naming",
      "lessonIds": [
        "lesson-chemistry-basic-organic-chemistry"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
          "lines": [
            47,
            63
          ],
          "note": "L01 structural teaching assessment: Simple IUPAC parent selection and substituent naming"
        },
        {
          "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
          "lines": [
            81,
            86
          ],
          "note": "Simple IUPAC parent selection and substituent naming example"
        }
      ],
      "missingIdeas": [
        "No branched structure, numbering decision, substituent locants or complete worked branched name"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "pupcet-L115",
        "dcat-L079"
      ],
      "facet": "Carbon compounds and biomolecule relationships",
      "lessonIds": [
        "lesson-chemistry-basic-organic-chemistry"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/basic-organic-chemistry.md",
          "lines": [
            12,
            63
          ],
          "note": "L01 structural teaching assessment: Carbon compounds and biomolecule relationships"
        }
      ],
      "missingIdeas": [
        "Biomolecule classes and structure-function relationships are not taught in this chemistry lesson; biology overlap needs lead reconciliation"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "upcat-L161",
        "dcat-L079",
        "ustet-L114",
        "pupcet-L114",
        "dost-sei-L104",
        "dost-sei-L106"
      ],
      "facet": "Ionic covalent and metallic bonding",
      "lessonIds": [
        "lesson-chemistry-chemical-bonding"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            12,
            20
          ],
          "note": "Ionic covalent and metallic bonding teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            68,
            76
          ],
          "note": "Ionic covalent and metallic bonding example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "dost-sei-L106"
      ],
      "facet": "Octet guideline and exceptions",
      "lessonIds": [
        "lesson-chemistry-chemical-bonding"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            24,
            36
          ],
          "note": "Octet guideline and exceptions teaching"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
      "workedExamples": "not-required",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "dcat-L082",
        "dost-sei-L104"
      ],
      "facet": "Bond polarity and electronegativity",
      "lessonIds": [
        "lesson-chemistry-chemical-bonding"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            38,
            44
          ],
          "note": "Bond polarity and electronegativity teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            78,
            86
          ],
          "note": "Bond polarity and electronegativity example"
        }
      ],
      "missingIdeas": [
        "Electronegativity term not defined locally; periodic-table teaching supplies it"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "dost-sei-L106"
      ],
      "facet": "Lewis structures formal charge and resonance",
      "lessonIds": [
        "lesson-chemistry-chemical-bonding"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            46,
            50
          ],
          "note": "L01 structural teaching assessment: Lewis structures formal charge and resonance"
        }
      ],
      "missingIdeas": [
        "No valence-electron counting procedure, actual Lewis construction, formal-charge formula or resonance worked structure"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "dcat-L082",
        "dost-sei-L104"
      ],
      "facet": "VSEPR geometry from supplied electron groups",
      "lessonIds": [
        "lesson-chemistry-chemical-bonding"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            52,
            64
          ],
          "note": "VSEPR geometry from supplied electron groups teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            88,
            107
          ],
          "note": "VSEPR geometry from supplied electron groups example"
        }
      ],
      "missingIdeas": [
        "Examples supply groups; learner cannot derive groups from a formula without Lewis construction"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L079",
        "dcat-L082",
        "ustet-L123",
        "pupcet-L123",
        "dost-sei-L104",
        "sm-foundation-L141"
      ],
      "facet": "Molecular polarity from bond dipoles and geometry",
      "lessonIds": [
        "lesson-chemistry-chemical-bonding"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            38,
            64
          ],
          "note": "L01 structural teaching assessment: Molecular polarity from bond dipoles and geometry"
        }
      ],
      "missingIdeas": [
        "Bond polarity and geometry are taught separately; their combined molecular-polarity decision is absent"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L079",
        "dcat-L082",
        "ustet-L123",
        "pupcet-L123",
        "dost-sei-L104",
        "sm-foundation-L141"
      ],
      "facet": "Intermolecular forces and hydrogen bonding",
      "lessonIds": [
        "lesson-chemistry-chemical-bonding"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            12,
            64
          ],
          "note": "L01 structural teaching assessment: Intermolecular forces and hydrogen bonding"
        }
      ],
      "missingIdeas": [
        "No force-type or hydrogen-bond explanation connects molecular structure to physical properties"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L079",
        "dcat-L082",
        "ustet-L123",
        "pupcet-L123",
        "dost-sei-L104",
        "sm-foundation-L141"
      ],
      "facet": "Bonding model to material properties",
      "lessonIds": [
        "lesson-chemistry-chemical-bonding"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            14,
            20
          ],
          "note": "L01 structural teaching assessment: Bonding model to material properties"
        }
      ],
      "missingIdeas": [
        "Metallic conductivity and malleability are linked; no worked structure-to-solubility or boiling-point comparison"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Ionic and covalent descriptions require electrons, nuclei and ions; the consumer does not teach their identity.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L106"
      ],
      "facet": "Ionic and Stock naming",
      "lessonIds": [
        "lesson-chemistry-chemical-nomenclature"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
          "lines": [
            14,
            27
          ],
          "note": "Ionic and Stock naming teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
          "lines": [
            69,
            87
          ],
          "note": "Ionic and Stock naming example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Naming assumes cation/anion and signed ion charge rather than introducing them.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L106"
      ],
      "facet": "Polyatomic ions and related oxyanion names",
      "lessonIds": [
        "lesson-chemistry-chemical-nomenclature"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
          "lines": [
            25,
            31
          ],
          "note": "Polyatomic ions and related oxyanion names teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
          "lines": [
            99,
            107
          ],
          "note": "Polyatomic ions and related oxyanion names example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Naming assumes cation/anion and signed ion charge rather than introducing them.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L106"
      ],
      "facet": "Binary molecular prefixes and names",
      "lessonIds": [
        "lesson-chemistry-chemical-nomenclature"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
          "lines": [
            33,
            49
          ],
          "note": "Binary molecular prefixes and names teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
          "lines": [
            89,
            97
          ],
          "note": "Binary molecular prefixes and names example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Naming assumes cation/anion and signed ion charge rather than introducing them.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L106"
      ],
      "facet": "Charge-balanced simplest ionic formulas",
      "lessonIds": [
        "lesson-chemistry-chemical-nomenclature"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
          "lines": [
            51,
            65
          ],
          "note": "Charge-balanced simplest ionic formulas teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-nomenclature.md",
          "lines": [
            99,
            118
          ],
          "note": "Charge-balanced simplest ionic formulas example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Naming assumes cation/anion and signed ion charge rather than introducing them.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "dcat-L085",
        "ustet-L114",
        "pupcet-L115",
        "dost-sei-L104"
      ],
      "facet": "Atom conservation and coefficient balancing",
      "lessonIds": [
        "lesson-chemistry-chemical-reactions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            12,
            18
          ],
          "note": "Atom conservation and coefficient balancing teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            56,
            91
          ],
          "note": "Atom conservation and coefficient balancing example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L143",
        "ustet-L125",
        "pupcet-L123",
        "sm-foundation-L137"
      ],
      "facet": "Combination decomposition and single displacement",
      "lessonIds": [
        "lesson-chemistry-chemical-reactions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            20,
            26
          ],
          "note": "Combination decomposition and single displacement teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            40,
            54
          ],
          "note": "Combination decomposition and single displacement example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L143",
        "ustet-L125",
        "dost-sei-L104"
      ],
      "facet": "Double displacement and driving-force reasoning",
      "lessonIds": [
        "lesson-chemistry-chemical-reactions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            27,
            27
          ],
          "note": "Double displacement and driving-force reasoning teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            93,
            99
          ],
          "note": "Double displacement and driving-force reasoning example"
        }
      ],
      "missingIdeas": [
        "No concrete precipitation or net-ionic derivation; solubility rules not supplied"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L143",
        "ustet-L125",
        "pupcet-L115"
      ],
      "facet": "Complete and incomplete combustion",
      "lessonIds": [
        "lesson-chemistry-chemical-reactions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            28,
            36
          ],
          "note": "Complete and incomplete combustion teaching"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            69,
            81
          ],
          "note": "Complete and incomplete combustion example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145"
      ],
      "facet": "Redox and oxidation-state reasoning",
      "lessonIds": [
        "lesson-chemistry-chemical-reactions"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "lines": [
            22,
            28
          ],
          "note": "L01 structural teaching assessment: Redox and oxidation-state reasoning"
        }
      ],
      "missingIdeas": [
        "Examples label redox without defining electron transfer or showing oxidation-state changes; charge in nomenclature does not teach general redox"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "dcat-L079",
        "ustet-L114",
        "pupcet-L115",
        "dost-sei-L099"
      ],
      "facet": "Gas-law conditions and fixed quantities",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            12,
            58
          ],
          "note": "Gas-law conditions and fixed quantities teaching"
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            62,
            106
          ],
          "note": "Gas-law conditions and fixed quantities example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "dcat-L079",
        "dost-sei-L099"
      ],
      "facet": "Kelvin conversion and absolute-temperature reasoning",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            14,
            16
          ],
          "note": "Kelvin conversion and absolute-temperature reasoning teaching"
        }
      ],
      "missingIdeas": [
        "Examples already supply kelvin; conversion application is not worked"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "upcat-L161",
        "dcat-L079",
        "ustet-L114",
        "dost-sei-L099"
      ],
      "facet": "Boyle inverse pressure-volume relationship",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            18,
            22
          ],
          "note": "L01 local facet: Boyle inverse pressure-volume relationship"
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            62,
            72
          ],
          "note": "L19 worked local facet: Boyle inverse pressure-volume relationship"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "upcat-L161",
        "dcat-L079",
        "ustet-L114",
        "dost-sei-L099"
      ],
      "facet": "Charles direct volume-temperature relationship",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            24,
            28
          ],
          "note": "L01 local facet: Charles direct volume-temperature relationship"
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            74,
            82
          ],
          "note": "L19 worked local facet: Charles direct volume-temperature relationship"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "dcat-L079",
        "dost-sei-L099"
      ],
      "facet": "Amontons/Gay-Lussac pressure-temperature relationship",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            30,
            36
          ],
          "note": "L01 local facet: Amontons/Gay-Lussac pressure-temperature relationship"
        }
      ],
      "missingIdeas": [
        "No worked pressure-temperature problem"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "dcat-L079",
        "dost-sei-L099"
      ],
      "facet": "Avogadro volume-amount relationship",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            38,
            44
          ],
          "note": "L01 local facet: Avogadro volume-amount relationship"
        }
      ],
      "missingIdeas": [
        "No worked volume-amount problem"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "dcat-L085",
        "ustet-L114",
        "dost-sei-L107"
      ],
      "facet": "Combined fixed-amount gas-state calculation",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            48,
            52
          ],
          "note": "L01 local facet: Combined fixed-amount gas-state calculation"
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            84,
            94
          ],
          "note": "L19 worked local facet: Combined fixed-amount gas-state calculation"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "dcat-L085",
        "ustet-L114",
        "dost-sei-L107"
      ],
      "facet": "Ideal gas amount calculation and units",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            54,
            58
          ],
          "note": "L01 local facet: Ideal gas amount calculation and units"
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            96,
            106
          ],
          "note": "L19 worked local facet: Ideal gas amount calculation and units"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161"
      ],
      "facet": "Kinetic Molecular Theory explanation of gas relationships",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            12,
            58
          ],
          "note": "L01 structural teaching assessment: Kinetic Molecular Theory explanation of gas relationships"
        }
      ],
      "missingIdeas": [
        "No collision-based pressure, random particle motion or kinetic-energy model connects the equations to mechanism"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L077",
        "ustet-L113",
        "acet-L126"
      ],
      "facet": "Recognizing controlled quantities in gas comparisons",
      "lessonIds": [
        "lesson-chemistry-gas-laws"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            18,
            44
          ],
          "note": "L01 structural teaching assessment: Recognizing controlled quantities in gas comparisons"
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            62,
            94
          ],
          "note": "Recognizing controlled quantities in gas comparisons example"
        }
      ],
      "missingIdeas": [
        "Fixed variables are identified for formulas, not taught as independent/dependent/control variables in investigations"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Ideal gas examples ask for moles and use amount n without defining the mole entity-to-amount meaning.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "pupcet-L114",
        "dost-sei-L099",
        "sm-foundation-L137"
      ],
      "facet": "Historical model changes and limits",
      "lessonIds": [
        "lesson-chemistry-history-of-the-atom"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            12,
            53
          ],
          "note": "Historical model changes and limits teaching"
        },
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            57,
            69
          ],
          "note": "Historical model changes and limits example"
        }
      ],
      "missingIdeas": [
        "History is supportive particle-model teaching, not proof chronology is tested"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L077",
        "ustet-L113",
        "acet-L126"
      ],
      "facet": "Evidence-to-conclusion reasoning from scattering",
      "lessonIds": [
        "lesson-chemistry-history-of-the-atom"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            30,
            39
          ],
          "note": "Evidence-to-conclusion reasoning from scattering teaching"
        },
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            71,
            80
          ],
          "note": "Evidence-to-conclusion reasoning from scattering example"
        }
      ],
      "missingIdeas": [
        "Observation and inference are concrete; learner does not design controls or interpret a numeric data set"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "dost-sei-L106"
      ],
      "facet": "Quantized versus modern probability models",
      "lessonIds": [
        "lesson-chemistry-history-of-the-atom"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            41,
            53
          ],
          "note": "Quantized versus modern probability models teaching"
        },
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            82,
            90
          ],
          "note": "Quantized versus modern probability models example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "pupcet-L114"
      ],
      "facet": "Isotopes challenge historical identical-mass claim",
      "lessonIds": [
        "lesson-chemistry-history-of-the-atom"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            14,
            20
          ],
          "note": "Isotopes challenge historical identical-mass claim teaching"
        },
        {
          "path": "content/lessons/science/chemistry/history-of-the-atom.md",
          "lines": [
            92,
            98
          ],
          "note": "Isotopes challenge historical identical-mass claim example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L143",
        "upcat-L161",
        "acet-L127",
        "ustet-L114",
        "pupcet-L114",
        "dost-sei-L099",
        "sm-foundation-L137"
      ],
      "facet": "Element compound and mixture classification",
      "lessonIds": [
        "lesson-chemistry-matter"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/matter.md",
          "lines": [
            14,
            21
          ],
          "note": "Element compound and mixture classification teaching"
        },
        {
          "path": "content/lessons/science/chemistry/matter.md",
          "lines": [
            58,
            66
          ],
          "note": "Element compound and mixture classification example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L114",
        "dost-sei-L099",
        "sm-foundation-L137"
      ],
      "facet": "Bulk states and particle-state explanation",
      "lessonIds": [
        "lesson-chemistry-matter"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/matter.md",
          "lines": [
            23,
            33
          ],
          "note": "L01 structural teaching assessment: Bulk states and particle-state explanation"
        }
      ],
      "missingIdeas": [
        "Bulk behavior is explained; particle spacing, movement and attractions largely reside in a figure marker or a crystal trap, not a causal particle account"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L143",
        "pupcet-L114"
      ],
      "facet": "Phase changes and energy direction",
      "lessonIds": [
        "lesson-chemistry-matter"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/matter.md",
          "lines": [
            35,
            46
          ],
          "note": "Phase changes and energy direction teaching"
        },
        {
          "path": "content/lessons/science/chemistry/matter.md",
          "lines": [
            68,
            75
          ],
          "note": "Phase changes and energy direction example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L143",
        "ustet-L114",
        "pupcet-L114",
        "sm-foundation-L137"
      ],
      "facet": "Physical versus chemical properties and changes",
      "lessonIds": [
        "lesson-chemistry-matter"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/matter.md",
          "lines": [
            48,
            54
          ],
          "note": "Physical versus chemical properties and changes teaching"
        },
        {
          "path": "content/lessons/science/chemistry/matter.md",
          "lines": [
            77,
            86
          ],
          "note": "Physical versus chemical properties and changes example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L114",
        "dost-sei-L099",
        "sm-foundation-L137"
      ],
      "facet": "Homogeneous heterogeneous and chemical identity",
      "lessonIds": [
        "lesson-chemistry-mixtures-and-separation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            12,
            16
          ],
          "note": "Homogeneous heterogeneous and chemical identity teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            54,
            62
          ],
          "note": "Homogeneous heterogeneous and chemical identity example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L114",
        "dost-sei-L099"
      ],
      "facet": "Filtration of suspended versus dissolved solids",
      "lessonIds": [
        "lesson-chemistry-mixtures-and-separation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            18,
            24
          ],
          "note": "Filtration of suspended versus dissolved solids teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            64,
            72
          ],
          "note": "Filtration of suspended versus dissolved solids example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "dost-sei-L099"
      ],
      "facet": "Distillation volatility and separation limits",
      "lessonIds": [
        "lesson-chemistry-mixtures-and-separation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            26,
            34
          ],
          "note": "Distillation volatility and separation limits teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            74,
            82
          ],
          "note": "Distillation volatility and separation limits example"
        }
      ],
      "missingIdeas": [
        "Vapor-liquid equilibrium is qualitative; quantitative mixtures or purity depth unknown"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "dcat-L077",
        "ustet-L113",
        "acet-L126"
      ],
      "facet": "Chromatography phases and observation inference",
      "lessonIds": [
        "lesson-chemistry-mixtures-and-separation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            38,
            44
          ],
          "note": "Chromatography phases and observation inference teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            84,
            92
          ],
          "note": "Chromatography phases and observation inference example"
        }
      ],
      "missingIdeas": [
        "Example infers multiple components but does not interpret measured chromatogram positions or experimental controls"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L114"
      ],
      "facet": "Evaporation versus crystallization",
      "lessonIds": [
        "lesson-chemistry-mixtures-and-separation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            46,
            50
          ],
          "note": "Evaporation versus crystallization teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mixtures-and-separation.md",
          "lines": [
            74,
            82
          ],
          "note": "Evaporation versus crystallization example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "dcat-L085",
        "ustet-L114",
        "pupcet-L115"
      ],
      "facet": "Mole and specified entity",
      "lessonIds": [
        "lesson-chemistry-mole-concept"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            12,
            24
          ],
          "note": "Mole and specified entity teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            62,
            70
          ],
          "note": "Mole and specified entity example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "dcat-L085",
        "ustet-L114",
        "pupcet-L115"
      ],
      "facet": "Molar mass from formula",
      "lessonIds": [
        "lesson-chemistry-mole-concept"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            26,
            32
          ],
          "note": "Molar mass from formula teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            48,
            54
          ],
          "note": "Molar mass from formula example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L143",
        "upcat-L161",
        "dcat-L085",
        "ustet-L114",
        "pupcet-L115"
      ],
      "facet": "Mass-to-moles conversion",
      "lessonIds": [
        "lesson-chemistry-mole-concept"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            34,
            38
          ],
          "note": "Mass-to-moles conversion teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            56,
            60
          ],
          "note": "Mass-to-moles conversion example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L143",
        "dcat-L085",
        "ustet-L114",
        "pupcet-L115"
      ],
      "facet": "Moles-to-entities and combined mass-to-entities",
      "lessonIds": [
        "lesson-chemistry-mole-concept"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            40,
            44
          ],
          "note": "Moles-to-entities and combined mass-to-entities teaching"
        },
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            62,
            78
          ],
          "note": "Moles-to-entities and combined mass-to-entities example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146"
      ],
      "facet": "Alpha and beta-minus daughter bookkeeping",
      "lessonIds": [
        "lesson-chemistry-nuclear-chemistry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
          "lines": [
            14,
            28
          ],
          "note": "Alpha and beta-minus daughter bookkeeping teaching"
        },
        {
          "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
          "lines": [
            65,
            81
          ],
          "note": "Alpha and beta-minus daughter bookkeeping example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Decay updates A and Z and identifies new elements, relying on proton/neutron identity not introduced here.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146"
      ],
      "facet": "Positron electron capture and gamma changes",
      "lessonIds": [
        "lesson-chemistry-nuclear-chemistry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
          "lines": [
            30,
            45
          ],
          "note": "Positron electron capture and gamma changes teaching"
        },
        {
          "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
          "lines": [
            83,
            92
          ],
          "note": "Positron electron capture and gamma changes example"
        }
      ],
      "missingIdeas": [
        "Gamma has no separate applied example; no half-life calculation taught, and required nuclear depth unknown"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Decay updates A and Z and identifies new elements, relying on proton/neutron identity not introduced here.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146"
      ],
      "facet": "Fission fusion and comparison basis",
      "lessonIds": [
        "lesson-chemistry-nuclear-chemistry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
          "lines": [
            49,
            61
          ],
          "note": "Fission fusion and comparison basis teaching"
        },
        {
          "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
          "lines": [
            94,
            102
          ],
          "note": "Fission fusion and comparison basis example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Decay updates A and Z and identifies new elements, relying on proton/neutron identity not introduced here.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146"
      ],
      "facet": "Radiation penetration versus hazard",
      "lessonIds": [
        "lesson-chemistry-nuclear-chemistry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/nuclear-chemistry.md",
          "lines": [
            21,
            45
          ],
          "note": "Radiation penetration versus hazard teaching"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Decay updates A and Z and identifies new elements, relying on proton/neutron identity not introduced here.",
      "workedExamples": "not-required",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144"
      ],
      "facet": "Table groups periods and atomic-number ordering",
      "lessonIds": [
        "lesson-chemistry-periodic-table"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            12,
            20
          ],
          "note": "Table groups periods and atomic-number ordering teaching"
        },
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            40,
            48
          ],
          "note": "Table groups periods and atomic-number ordering example"
        }
      ],
      "missingIdeas": [
        "Named families such as alkali metals, alkaline-earth metals, halogens and noble gases are not taught despite outline Families and Groups (B03 outline facet; L01 structural use only)"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Table ordering and electron-removal/addition trends rely on atomic number and electron/nuclear identity.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144"
      ],
      "facet": "Atomic-radius trends",
      "lessonIds": [
        "lesson-chemistry-periodic-table"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            26,
            28
          ],
          "note": "Atomic-radius trends teaching"
        },
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            50,
            58
          ],
          "note": "Atomic-radius trends example"
        }
      ],
      "missingIdeas": [
        "Effective nuclear charge is invoked but shielding mechanism not explained"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Table ordering and electron-removal/addition trends rely on atomic number and electron/nuclear identity.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144"
      ],
      "facet": "First ionization energy trends",
      "lessonIds": [
        "lesson-chemistry-periodic-table"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            30,
            30
          ],
          "note": "First ionization energy trends teaching"
        },
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            60,
            68
          ],
          "note": "First ionization energy trends example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Table ordering and electron-removal/addition trends rely on atomic number and electron/nuclear identity.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144"
      ],
      "facet": "Electronegativity meaning and trends",
      "lessonIds": [
        "lesson-chemistry-periodic-table"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            32,
            32
          ],
          "note": "Electronegativity meaning and trends teaching"
        }
      ],
      "missingIdeas": [
        "No worked electronegativity comparison"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Table ordering and electron-removal/addition trends rely on atomic number and electron/nuclear identity.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144"
      ],
      "facet": "Electron-affinity meaning sign and exceptions",
      "lessonIds": [
        "lesson-chemistry-periodic-table"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            34,
            36
          ],
          "note": "Electron-affinity meaning sign and exceptions teaching"
        },
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            70,
            78
          ],
          "note": "Electron-affinity meaning sign and exceptions example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Table ordering and electron-removal/addition trends rely on atomic number and electron/nuclear identity.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [],
      "facet": "Recognize named periodic-table families",
      "lessonIds": [
        "lesson-chemistry-periodic-table"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/periodic-table.md",
          "lines": [
            14,
            20
          ],
          "note": "B03 outline Families and Groups facet; group positions covered, named families not taught"
        }
      ],
      "missingIdeas": [
        "Alkali metals, alkaline-earth metals, halogens and noble-gas family identities/properties not taught; exact exam demand unknown"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Table ordering and electron-removal/addition trends rely on atomic number and electron/nuclear identity.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [],
      "facet": "Quantum number ranges and Pauli uniqueness",
      "lessonIds": [
        "lesson-chemistry-quantum-numbers-electron-configuration"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            14,
            27
          ],
          "note": "Quantum number ranges and Pauli uniqueness teaching"
        },
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            78,
            85
          ],
          "note": "Quantum number ranges and Pauli uniqueness example"
        }
      ],
      "missingIdeas": [
        "No specific accepted quantum-number requirement; atomic-structure background connection only"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Configuration-to-element identification uses neutrality, Z and electron count.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [],
      "facet": "Orbital versus subshell capacities",
      "lessonIds": [
        "lesson-chemistry-quantum-numbers-electron-configuration"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            29,
            40
          ],
          "note": "Orbital versus subshell capacities teaching"
        },
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            70,
            76
          ],
          "note": "Orbital versus subshell capacities example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Configuration-to-element identification uses neutrality, Z and electron count.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [],
      "facet": "Aufbau Hund and Pauli filling",
      "lessonIds": [
        "lesson-chemistry-quantum-numbers-electron-configuration"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            44,
            56
          ],
          "note": "Aufbau Hund and Pauli filling teaching"
        },
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            70,
            76
          ],
          "note": "Aufbau Hund and Pauli filling example"
        }
      ],
      "missingIdeas": [
        "Nitrogen configuration is supplied rather than built stepwise; no paired versus unpaired orbital sequence"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Configuration-to-element identification uses neutrality, Z and electron count.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [],
      "facet": "Configuration reading electron and valence counts",
      "lessonIds": [
        "lesson-chemistry-quantum-numbers-electron-configuration"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            58,
            66
          ],
          "note": "Configuration reading electron and valence counts teaching"
        },
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            87,
            95
          ],
          "note": "Configuration reading electron and valence counts example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Configuration-to-element identification uses neutrality, Z and electron count.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [],
      "facet": "Filling versus ionization order limits",
      "lessonIds": [
        "lesson-chemistry-quantum-numbers-electron-configuration"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/quantum-numbers-electron-configuration.md",
          "lines": [
            97,
            103
          ],
          "note": "Filling versus ionization order limits teaching"
        }
      ],
      "missingIdeas": [
        "Chromium/copper exceptions named but not constructed; no ionic configuration worked"
      ],
      "priorKnowledge": "lesson-chemistry-atomic-structure: Configuration-to-element identification uses neutrality, Z and electron count.",
      "workedExamples": "not-required",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "ustet-L125",
        "pupcet-L114",
        "dost-sei-L108"
      ],
      "facet": "Solvent solute and saturation states",
      "lessonIds": [
        "lesson-chemistry-solutions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            12,
            22
          ],
          "note": "Solvent solute and saturation states teaching"
        }
      ],
      "missingIdeas": [
        "No applied saturation example or solubility data/curve interpretation"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Concentration teaching and worked examples use moles without defining amount or a mole.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "pupcet-L114"
      ],
      "facet": "Molarity",
      "lessonIds": [
        "lesson-chemistry-solutions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            26,
            28
          ],
          "note": "L01 local facet: Molarity"
        },
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            49,
            53
          ],
          "note": "L19 worked local facet: Molarity"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Concentration teaching and worked examples use moles without defining amount or a mole.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "pupcet-L114"
      ],
      "facet": "Molality",
      "lessonIds": [
        "lesson-chemistry-solutions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            30,
            34
          ],
          "note": "L01 local facet: Molality"
        },
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            55,
            59
          ],
          "note": "L19 worked local facet: Molality"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Concentration teaching and worked examples use moles without defining amount or a mole.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "pupcet-L114"
      ],
      "facet": "Mass percent",
      "lessonIds": [
        "lesson-chemistry-solutions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            36,
            38
          ],
          "note": "L01 local facet: Mass percent"
        },
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            61,
            68
          ],
          "note": "L19 worked local facet: Mass percent"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Concentration teaching and worked examples use moles without defining amount or a mole.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "pupcet-L114"
      ],
      "facet": "Volume percent",
      "lessonIds": [
        "lesson-chemistry-solutions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            40,
            44
          ],
          "note": "L01 local facet: Volume percent"
        }
      ],
      "missingIdeas": [
        "No worked volume-percent computation"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Concentration teaching and worked examples use moles without defining amount or a mole.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145",
        "ustet-L125"
      ],
      "facet": "Temperature and concentration denominators",
      "lessonIds": [
        "lesson-chemistry-solutions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            34,
            44
          ],
          "note": "Temperature and concentration denominators teaching"
        },
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            70,
            79
          ],
          "note": "Temperature and concentration denominators example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Concentration teaching and worked examples use moles without defining amount or a mole.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L145"
      ],
      "facet": "Dilution amount conservation",
      "lessonIds": [
        "lesson-chemistry-solutions"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            24,
            44
          ],
          "note": "L01 structural teaching assessment: Dilution amount conservation"
        }
      ],
      "missingIdeas": [
        "No dilution relation or reasoning from conserved solute amount"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Concentration teaching and worked examples use moles without defining amount or a mole.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "ustet-L125",
        "dost-sei-L108"
      ],
      "facet": "Product-composition and safe household-chemical application",
      "lessonIds": [
        "lesson-chemistry-solutions"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/solutions.md",
          "lines": [
            12,
            44
          ],
          "note": "L01 structural teaching assessment: Product-composition and safe household-chemical application"
        }
      ],
      "missingIdeas": [
        "No product-label interpretation, safe storage/mixing/disposal or household safety procedure; another topic may teach safety"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Concentration teaching and worked examples use moles without defining amount or a mole.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L115",
        "dcat-L085",
        "dost-sei-L104"
      ],
      "facet": "Balanced-equation mole-to-mole product relationships",
      "lessonIds": [
        "lesson-chemistry-stoichiometry"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            12,
            18
          ],
          "note": "L01 local facet: Balanced-equation mole-to-mole product relationships"
        },
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            46,
            60
          ],
          "note": "L19 worked local facet: Balanced-equation mole-to-mole product relationships"
        }
      ],
      "missingIdeas": [
        "Limiting example infers reactant demand; no explicit calculation of product moles"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Balancing in lesson-chemistry-chemical-reactions is optional reaction preparation, not a strict prerequisite: stoichiometry defines coefficient ratios locally and supplies its balanced reaction. Composition-formula facets do not require balancing.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L115",
        "dcat-L085",
        "dost-sei-L104"
      ],
      "facet": "Balanced-equation mole-to-mass product relationships",
      "lessonIds": [
        "lesson-chemistry-stoichiometry"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            12,
            18
          ],
          "note": "L01 local facet: Balanced-equation mole-to-mass product relationships"
        }
      ],
      "missingIdeas": [
        "No reaction-ratio-to-product-mass procedure or worked chain"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Balancing in lesson-chemistry-chemical-reactions is optional reaction preparation, not a strict prerequisite: stoichiometry defines coefficient ratios locally and supplies its balanced reaction. Composition-formula facets do not require balancing.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L114",
        "pupcet-L115",
        "dcat-L085",
        "dost-sei-L104"
      ],
      "facet": "Balanced-equation mass-to-mass product relationships",
      "lessonIds": [
        "lesson-chemistry-stoichiometry"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            12,
            18
          ],
          "note": "L01 local facet: Balanced-equation mass-to-mass product relationships"
        }
      ],
      "missingIdeas": [
        "No reactant-mass to moles to reaction-ratio to product-mass worked chain"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Balancing in lesson-chemistry-chemical-reactions is optional reaction preparation, not a strict prerequisite: stoichiometry defines coefficient ratios locally and supplies its balanced reaction. Composition-formula facets do not require balancing.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L144",
        "dcat-L082",
        "ustet-L123",
        "dost-sei-L104"
      ],
      "facet": "Limiting and excess reactant decisions",
      "lessonIds": [
        "lesson-chemistry-stoichiometry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            14,
            18
          ],
          "note": "Limiting and excess reactant decisions teaching"
        },
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            46,
            60
          ],
          "note": "Limiting and excess reactant decisions example"
        }
      ],
      "missingIdeas": [
        "No theoretical product quantity or remaining excess calculation"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Balancing in lesson-chemistry-chemical-reactions is optional reaction preparation, not a strict prerequisite: stoichiometry defines coefficient ratios locally and supplies its balanced reaction. Composition-formula facets do not require balancing.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L082",
        "ustet-L123",
        "dost-sei-L104"
      ],
      "facet": "Theoretical yield from reactant data",
      "lessonIds": [
        "lesson-chemistry-stoichiometry"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            20,
            28
          ],
          "note": "L01 local facet: Theoretical yield from reactant data"
        }
      ],
      "missingIdeas": [
        "Definition given; theoretical yield supplied rather than derived from limiting-reactant data"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Balancing in lesson-chemistry-chemical-reactions is optional reaction preparation, not a strict prerequisite: stoichiometry defines coefficient ratios locally and supplies its balanced reaction. Composition-formula facets do not require balancing.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L082",
        "ustet-L123",
        "dost-sei-L104"
      ],
      "facet": "Percent yield from actual and theoretical amounts",
      "lessonIds": [
        "lesson-chemistry-stoichiometry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            20,
            28
          ],
          "note": "L01 local facet: Percent yield from actual and theoretical amounts"
        },
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            62,
            66
          ],
          "note": "L19 worked local facet: Percent yield from actual and theoretical amounts"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-chemistry-mole-concept: Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Balancing in lesson-chemistry-chemical-reactions is optional reaction preparation, not a strict prerequisite: stoichiometry defines coefficient ratios locally and supplies its balanced reaction. Composition-formula facets do not require balancing.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [],
      "facet": "Empirical formulas from mole ratios",
      "lessonIds": [
        "lesson-chemistry-stoichiometry"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            30,
            42
          ],
          "note": "Empirical formulas from mole ratios teaching"
        },
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            68,
            86
          ],
          "note": "Empirical formulas from mole ratios example"
        }
      ],
      "missingIdeas": [
        "Composition-to-moles from mass/percent composition not worked; empirical-formula depth not specifically confirmed by broad refs"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Balancing in lesson-chemistry-chemical-reactions is optional reaction preparation, not a strict prerequisite: stoichiometry defines coefficient ratios locally and supplies its balanced reaction. Composition-formula facets do not require balancing.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [],
      "facet": "Molecular formula multiplier from molar masses",
      "lessonIds": [
        "lesson-chemistry-stoichiometry"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            30,
            36
          ],
          "note": "L01 structural teaching assessment: Molecular formula multiplier from molar masses"
        },
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "lines": [
            88,
            96
          ],
          "note": "Molecular formula multiplier from molar masses example"
        }
      ],
      "missingIdeas": [
        "Multiplier relation appears first in example and later shortcut, not Core Concept (structural L17); no specific current depth established"
      ],
      "priorKnowledge": "lesson-chemistry-mole-concept: Reactant amounts and empirical/molecular molar masses assume mole and molar-mass meaning. Balancing in lesson-chemistry-chemical-reactions is optional reaction preparation, not a strict prerequisite: stoichiometry defines coefficient ratios locally and supplies its balanced reaction. Composition-formula facets do not require balancing.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146",
        "ustet-L123",
        "pupcet-L123"
      ],
      "facet": "Heat direction and enthalpy sign",
      "lessonIds": [
        "lesson-chemistry-thermodynamics-and-kinetics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            19,
            28
          ],
          "note": "Heat direction and enthalpy sign teaching"
        },
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            63,
            70
          ],
          "note": "Heat direction and enthalpy sign example"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146",
        "upcat-L161",
        "ustet-L123",
        "dost-sei-L104",
        "dost-sei-L106"
      ],
      "facet": "Activation barrier collision conditions and catalyst pathway",
      "lessonIds": [
        "lesson-chemistry-thermodynamics-and-kinetics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            32,
            50
          ],
          "note": "Activation barrier collision conditions and catalyst pathway teaching"
        },
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            93,
            102
          ],
          "note": "Activation barrier collision conditions and catalyst pathway example"
        }
      ],
      "missingIdeas": [
        "Arrhenius relation introduced but no numerical application; exact needed depth unknown"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L161",
        "ustet-L123",
        "pupcet-L123",
        "dost-sei-L099",
        "sm-foundation-L137"
      ],
      "facet": "Surface area temperature and concentration rate factors",
      "lessonIds": [
        "lesson-chemistry-thermodynamics-and-kinetics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            52,
            59
          ],
          "note": "Surface area temperature and concentration rate factors teaching"
        },
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            83,
            91
          ],
          "note": "Surface area temperature and concentration rate factors example"
        }
      ],
      "missingIdeas": [
        "No worked temperature comparison"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146",
        "dost-sei-L106"
      ],
      "facet": "Rate-law order reasoning",
      "lessonIds": [
        "lesson-chemistry-thermodynamics-and-kinetics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            56,
            57
          ],
          "note": "L01 structural teaching assessment: Rate-law order reasoning"
        },
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            104,
            114
          ],
          "note": "Rate-law order reasoning example"
        }
      ],
      "missingIdeas": [
        "Rate-law notation and exponent/order meaning not introduced before the worked zero-order example (structural L17/L19)"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L146",
        "dost-sei-L106"
      ],
      "facet": "Chemical equilibrium foundation",
      "lessonIds": [
        "lesson-chemistry-thermodynamics-and-kinetics"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            14,
            17
          ],
          "note": "L01 structural teaching assessment: Chemical equilibrium foundation"
        },
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            72,
            81
          ],
          "note": "Chemical equilibrium foundation example"
        }
      ],
      "missingIdeas": [
        "No dynamic forward/reverse rate balance, equilibrium constant construction, or response-to-condition change; catalyst effect is not full equilibrium teaching"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L077",
        "ustet-L113",
        "acet-L126"
      ],
      "facet": "Scientific comparison and controls",
      "lessonIds": [
        "lesson-chemistry-thermodynamics-and-kinetics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            74,
            91
          ],
          "note": "L01 structural teaching assessment: Scientific comparison and controls"
        },
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            104,
            114
          ],
          "note": "Scientific comparison and controls example"
        }
      ],
      "missingIdeas": [
        "All-else-fixed comparisons apply control logic without teaching experimental variable/control identification"
      ],
      "priorKnowledge": "Local introductory context; basic mathematical literacy remains assumed where used.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic exam/source/cycle/language/depth limits."
    }
  ],
  "sourceLedger": [
    {
      "accessDate": "2026-10-05",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-chemistry-mole-concept",
      "issue": "Exact SI mole value encountered",
      "originalClaim": "The Avogadro constant is exactly 6.02214076 x 10^23 mol^-1",
      "disposition": "CONFIRMED",
      "sourceUrl": "https://www.bipm.org/en/si-base-units/mole",
      "sourceLocator": "BIPM SI base unit mole, definition paragraphs",
      "verificationNote": "Live publisher text confirms the exact constant and specified-entity basis; this confirms one encountered fact only.",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "lines": [
            16,
            24
          ],
          "note": "Exact definition"
        }
      ]
    },
    {
      "accessDate": "2026-10-05",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-chemistry-chemical-bonding",
      "issue": "HF exception to electronegativity cutoffs encountered",
      "originalClaim": "HF has a difference about 1.9 and remains described as polar covalent",
      "disposition": "CONFIRMED",
      "sourceUrl": "https://openstax.org/books/chemistry-2e/pages/7-2-covalent-bonding",
      "sourceLocator": "OpenStax Chemistry 2e, Electronegativity and Bond Type",
      "verificationNote": "Live publisher section gives this exception; the lesson warning against rigid cutoffs matches. No full numerical trend sweep performed.",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            38,
            44
          ],
          "note": "HF exception"
        }
      ]
    },
    {
      "accessDate": "2026-10-05",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-chemistry-chemical-bonding",
      "issue": "Definition mistaken for instruction risk",
      "originalClaim": "Lewis structures represent valence electrons and bonding; construction is not demonstrated",
      "disposition": "LESSON GAP",
      "sourceUrl": "https://openstax.org/books/chemistry-2e/pages/7-3-lewis-symbols-and-structures",
      "sourceLocator": "OpenStax Chemistry 2e, Lewis Symbols and Structures, objectives and definitions",
      "verificationNote": "Publisher distinguishes depicting/building structures from naming the representation. Local gap rests on full lesson reading, not a new exam requirement.",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            46,
            50
          ],
          "note": "Definition only"
        },
        {
          "path": "content/lessons/science/chemistry/chemical-bonding.md",
          "lines": [
            115,
            115
          ],
          "note": "Counting reminder only"
        }
      ]
    },
    {
      "accessDate": "2026-10-05",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-chemistry-thermodynamics-and-kinetics",
      "issue": "Dynamic equilibrium foundation absent before catalyst example",
      "originalClaim": "A catalyst speeds arrival at equilibrium without changing equilibrium composition",
      "disposition": "LESSON GAP",
      "sourceUrl": "https://openstax.org/books/chemistry-2e/pages/13-1-chemical-equilibria",
      "sourceLocator": "OpenStax Chemistry 2e, Chemical Equilibria, initial definition and dynamic nature",
      "verificationNote": "Live publisher defines equilibrium by equal forward/reverse rates with stable concentrations. The consumer example assumes that foundational meaning without teaching it.",
      "evidence": [
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            48,
            50
          ],
          "note": "Assumed equilibrium"
        },
        {
          "path": "content/lessons/science/chemistry/thermodynamics-and-kinetics.md",
          "lines": [
            72,
            81
          ],
          "note": "Consumer example"
        }
      ]
    },
    {
      "accessDate": "2026-10-05",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "chemistry-topic",
      "issue": "Optional higher-priority glossary access limitation",
      "originalClaim": "IUPAC glossary routes attempted for encountered term checks",
      "disposition": "UNKNOWN",
      "sourceUrl": "https://goldbook.iupac.org/terms/view/E02177",
      "sourceLocator": "Attempted glossary route; body not verified",
      "verificationNote": "Web returned HTTP 403 for this and L03508. No content conclusion relies on either unread body; OpenStax publisher sections supplied bounded foundation checks.",
      "evidence": []
    }
  ],
  "summary": "- Retain shared introductory chemistry once; no supported exam-specific deletion or excess verdict follows from current unknown depth.\n- Split candidate: separate composition-to-formula inference from reaction quantities in stoichiometry. This improves goal focus and a basic-to-extended preparation route, at the cost of a new approved lesson identity, moved examples/traps, and later linked-practice review.\n- Reorder candidate: teach Lewis construction before deriving VSEPR groups. Definitions alone cannot supply this foundation (L01/L17/L19). No full Lewis, formal-charge or resonance procedure appears in the 17 chemistry bodies.\n- Local gaps: dilution, dynamic chemical equilibrium, Kinetic Molecular Theory, molecular dipole cancellation/intermolecular reasoning, and experimental variable/data interpretation. Their source tiers and exam-depth uncertainties remain explicit.\n- Thin applications: branched organic naming, concrete functional-group/property comparisons, simple reaction product mole/mass chains, theoretical yield derived from reactants, and concentration-to-pH use. Periodic-table named families are not explained despite the outline facet (B03/L01 structural use).\n- Biomolecule/safety coverage is absent locally. Whole inventory identifies biology and other safety/background search leads; the lead must reconcile other topic findings before any corpus-wide gap claim.\n- No load-bearing figure dependencies encountered: all chemistry example prompts supply enough textual givens to be attempted. This is neither an illustration-sufficiency verdict nor runtime verification.\n- Prerequisites use existing IDs and both-end evidence only. Missing Lewis/equilibrium foundations have no invented lesson targets. Intralesson ordering is separate. Basic mathematical literacy is assumed; no unsupported arithmetic roadmap edge is asserted.\n- Required depth, Science language, cohort exposure, current cycle continuity, student availability and practice remain unresolved. Source checks here are bounded encountered facts, not a Level 4 correctness sweep.\n\nAccepted source packets: [UPCAT](../requirements/upcat.md), [DCAT](../requirements/dcat.md), [ACET](../requirements/acet.md), [USTET](../requirements/ustet.md), [PUPCET](../requirements/pupcet.md), [DOST-SEI](../requirements/dost-sei.md), [SM Foundation](../requirements/sm-foundation.md). Each cited requirement ID corresponds to its packet line; its source tier, page/section and limitations govern. Source scope: [DepEd JHS Science](https://www.deped.gov.ph/wp-content/uploads/2019/01/Science-CG_with-tagged-sci-equipment_revised.pdf), pp. 7-10, 163, 196; [Physical Science listing](https://lrmds.deped.gov.ph/detail/14519), competencies; [STEM Chemistry listing](https://lrmds.deped.gov.ph/detail/14411), competencies; [Strengthened General Science](https://www.deped.gov.ph/wp-content/uploads/GENERAL-SCIENCE-1.pdf), pp. 4-5. Historical domain: [DOST 2026 primer](https://science-scholarships.ph/pdf/2026_DOST-SEI_UG_Primer.pdf), p. 12. These accepted-source links are traceability, not new live source checks or an official detailed blueprint.",
  "selfCheck": "Command: focused Python accounting/hash/evidence/reference/dependency check against the saved appendix, assigned packet, accepted requirement map, inventory and pinned corpus. Actual final output:\n\nPASS assigned IDs: 17 exactly once\nPASS full reads: 17 SHA256/range/path matches\nPASS JSON appendices: 1 valid\nPASS evidence ranges: 375 valid\nPASS requirement refs: 39 valid accepted IDs\nPASS prerequisite edges: 9 existing targets, both-end paths/lines, no self-links, acyclic\nPASS no-existing-prerequisite links: 9 explicit statuses\nPASS corpus: pinned HEAD, clean worktree\nPASS em dashes: 0\nPASS scope declarations: availability unknown/practice deferred; no content/app/importer/schema changes or later-level work\nIndependent semantic review: pending.\n\nShared checker actual result: completeTopics 3; expectedTopics 25; completeLessons 40; expectedLessons 158; complete [science-biology, science-chemistry, science-physics]; errors []; gateReady false. Exit 0. Other topics pending; scoped chemistry completion is not the combined gate.",
  "correctionHistory": [
    {
      "finding": "C1",
      "date": "2026-10-06",
      "policyCommit": "e8d5f0f958e38c1648046a93747437687ba08334",
      "originalPolicyCommit": "cb48097bedf15bec2cfbe4fb3aa7e957753b1727",
      "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "targetBeforeSha256": "e3c4cda4f8d98ffa9c834ce0956672abf95922cde6ee86bd4c835b1e8dac2245",
      "disposition": "Strict chemical-reactions edge removed; balancing retained as optional preparation. Mole-concept edge unchanged. Fresh narrow reviewer acceptance pending.",
      "sourceReads": [
        {
          "path": "content/lessons/science/chemistry/stoichiometry.md",
          "sha256": "bd0c4c00ccae1105da06a54b02a15aaa0eecbf7906a5ea179c6828cd3d7b173a",
          "readLines": [
            1,
            134
          ]
        },
        {
          "path": "content/lessons/science/chemistry/chemical-reactions.md",
          "sha256": "c341c6ac97c05c858e10b99c50e5ae2ab090fce440d49849e20e2c4a35d528f7",
          "readLines": [
            1,
            133
          ]
        },
        {
          "path": "content/lessons/science/chemistry/mole-concept.md",
          "sha256": "7ced9877db7997594d74ac27a553aad3dcf39e3f06dca7ee4644670485bdee12",
          "readLines": [
            1,
            112
          ]
        }
      ]
    }
  ]
}
```
