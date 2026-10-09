# Physics lesson structure audit

Status: COMPLETE author output for Level 3, October 5, 2026. Fresh independent review and lead acceptance remain pending. Findings and recommendations only.

## Identity, scope and read log

Original author policy main: cb48097bedf15bec2cfbe4fb3aa7e957753b1727, matched live GitHub main through read-only ls-remote and cached origin/main. Audit startup HEAD: 7d5f2ed6a6d6f30e35d1b3f64467f31e7d122112. Corpus: /Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2, pinned 765c5dc0fa5586281047bf4f7b30d09ab3707887, confirmed clean before reading. Other agents' dirty audit outputs were preserved. No Git metadata mutation occurred.

Read current main AGENTS.md, WORKFLOW.md, SUBAGENTS.md, startup, source policy, checklist and lesson guide; current spec/plan, orchestrator, October 4 and latest Level 3 decisions, illustration decision, the full reader contract, all seven relevant accepted requirement packets, overlap.md and CET/scholarship scope notes. Research-era packet headers do not override later Levels 1/2 acceptance. Inventory and exact packet edges served as leads, never proof of teaching. No new human gate was introduced. DRAFT saved after startup, then incrementally as each lesson read was recorded.

Only assigned physics receives teaching/structure verdicts. B03/L01/L17/L19 identify structural presence, goal fit, formula readiness and worked application. This is not a Level 4 checklist pass, Level 5 practice/answer audit, or complete factual-correctness review. No question sources or embedded quiz blocks were evaluated. Runtime access is unknown. Current/voltage/flux source checks support foundation findings only. The two initially attempted high-school OpenStax current/Ohm URLs were inaccessible; no claim uses them. Successful University Physics sources are recorded below.

The prerequisites refer to existing IDs and necessary taught uses, not suggested authored order. Formula-specific dependencies do not mean every conceptual paragraph requires that prerequisite. No self-links or local cycles are proposed. Where content already defines the needed idea, no duplicate lesson dependency is added.

| Owned lesson ID | Pinned corpus-relative path | Full lines read | SHA256 |
|---|---|---|---|
| lesson-physics-dynamics | content/lessons/science/physics/dynamics.md | 1-142 | 5b3e6bbf7b9ef37561b9c92abdb8b231151dac11388ca175120e6f2b64d78143 |
| lesson-physics-electricity-and-magnetism | content/lessons/science/physics/electricity-and-magnetism.md | 1-162 | b4159dcc37ba0372ec43fae26008b1dc09c13342db47f3861b2d1f3ac31875fa |
| lesson-physics-fluid-mechanics | content/lessons/science/physics/fluid-mechanics.md | 1-142 | 29446c078d4024ca5fc7ebeb6ee1e77e627c3cc96f5a61e44a55bf5e03fde54e |
| lesson-physics-gravity-and-keplers-laws | content/lessons/science/physics/gravity-and-keplers-laws.md | 1-144 | ed80b8265783868e3c102c30a29eebd98ad1c661f9306f5cae9e52214420f0fd |
| lesson-physics-kinematics | content/lessons/science/physics/kinematics.md | 1-135 | d361b219e492dab5c2091eedb687ccc9db77fd6840d7ebca21c56edfadd761c0 |
| lesson-physics-light-and-optics | content/lessons/science/physics/light-and-optics.md | 1-146 | 68b0ccd8ad91f138dad702578182cacd69c4dc0b6c941f012cf1a92480abee21 |
| lesson-physics-momentum-and-impulse | content/lessons/science/physics/momentum-and-impulse.md | 1-131 | 9963b76459d08bb8c2a9475e2b088c9752c0ce075a4ef9feccc545d85b08de7b |
| lesson-physics-scalars-and-vectors | content/lessons/science/physics/scalars-and-vectors.md | 1-130 | a60360ce8730c373c2a4b566ab69b6442a29a66af2b464f1e0a8220e923a9ac0 |
| lesson-physics-thermodynamics | content/lessons/science/physics/thermodynamics.md | 1-136 | 2d386721a484964d7970488be939ceec003b6dac3a2d2a1bc95d6c1e86e2919c |
| lesson-physics-two-dimensional-motion | content/lessons/science/physics/two-dimensional-motion.md | 1-141 | de82fab38cfee42169aa60c0c2358f845b2e3c654c1418b75bd875c3413115df |
| lesson-physics-units-and-measurements | content/lessons/science/physics/units-and-measurements.md | 1-125 | 44f728ab41f7de68e1003b70273341b239b245b15bfa0ba7b54d936c454d89cc |
| lesson-physics-waves-and-sound | content/lessons/science/physics/waves-and-sound.md | 1-132 | 247aacf5ee3245aba46104dbd0f39895cff78827aec8f7de34c019232eeb3bdd |
| lesson-physics-work-energy-power | content/lessons/science/physics/work-energy-power.md | 1-182 | 7ccf85aaf50d3657eeb27b94f9255c278c9802a78b215f571651288414b9fb60 |

Narrow cross-topic source reads verified prerequisite teaching, existing foundations, or scope limits. They receive no topic coverage verdict.

- content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md: full lines 1-194, SHA256 536c2fcee4e48cc0b7c690b3b2bba2e1c29b2b9dfeaf40b7de32be188ee25ab3.
- content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md: full lines 1-112, SHA256 d904040e9f5f8b52b26033211caf6197daa71449bd7d2f51b43565bab36611d7.
- content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md: full lines 1-127, SHA256 fc79f371d955ec72c4255d551a3289c74dddc9c890d16820c70cbacb329509e4.
- content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md: full lines 1-95, SHA256 dcb596c614480c76ec1a538861177a5c227bc4c0c5aab7e04b0fdda1572dc3f1.
- content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md: full lines 1-92, SHA256 def98d8b2801b499e1d33f294bb42769acd1a5121f65127527482a5c3f56bd39.
- content/lessons/science/chemistry/gas-laws.md: full lines 1-140, SHA256 514bfc655c0fb14fa0e8d8eb6a0161e38652c8ceec305f56cf75b424debc0eca.
- content/lessons/science/chemistry/thermodynamics-and-kinetics.md: full lines 1-154, SHA256 e6716a70db409220611ee4f71d4e010673e236fed16a51b33130bf4fb03fac34.

## Findings and structure recommendations

Actual bodies support shared preparation in force balance, signed motion, energy, momentum, fluids, wave types and basic optics. They do not establish equal exam demand or full lesson sharing. UPCAT/USTET confirm broad Science; DOST detailed domains are official only for its 2026 primer. DCAT/PUPCET/SM current scope remains unconfirmed; ACET physics remains background without confirmed Science inclusion. All item-language, finer-depth, cohort/track/completion and runtime limits remain in each applicability record. No content is labeled unnecessary or excluded because an organizer is silent.

Three coherent split candidates improve foundation placement rather than create one lesson per concept:

- Electricity: separate electrostatics, DC circuits and induction. Develop current/voltage first, then flux before induction. Benefit: each application has the concepts it actually uses. Cost: relocate examples, keep shared electrical foundations once, and develop network applications. Existing Kirchhoff references do not teach network solving.
- Thermodynamics: separate thermal transfer/calorimetry from system-work and thermodynamic-law reasoning. Benefit: common transfer/temperature work does not require unexplained entropy/law extensions. Cost: move law content and add a first-law sign/work application. Unknown exam depth does not establish the extension is excess.
- Two-dimensional motion: separate projectile kinematics from force-based circular motion. Benefit: component motion follows kinematics; radial-force identification follows dynamics. Cost: relocate circular material and add a quantitative radial-force application. Define angular speed locally if its formula remains.

Motion graphs need an explanation and application before shortcut use. Circuit equivalent resistances have no numerical network example; image formation is largely device classification. Work-energy/net-work and nonconservative accounting have no worked application. These are L01/L17/L19 structural findings, not standards severity judgments.

Do not duplicate existing teaching for tags: spectrum order is developed in optics; fluid pressure/Bernoulli also appears in mechanical reasoning; simple machines/torque, stability and ideal-gas relationships have existing sources. Coordinate their partial scope. Hydraulic Pascal systems, energy-efficiency calculations, charging mechanisms, optical instruments, generator/motor mechanisms and interference/diffraction are absent from the local physics bodies. Their current exam demand remains as qualified in the accepted preparation records. Relativity is a weak extension, not an established addition requirement.

Scientific inquiry remains a distinct preparation facet: equal mass/heat is held fixed in one thermal comparison, but variables/controls and measured-evidence investigation methods are not developed. Graph/data reading is thin. Do not infer full inquiry coverage from substitution exercises or subject labels. Whole lesson-inventory leads and targeted corpus searches were used; global gap reconciliation belongs to the lead.

## Per-lesson teaching and focus

### lesson-physics-dynamics

Goal: Distinguish force balance from interaction pairs and use a force model to explain or calculate motion.

- Newton first law and inertia: explained, examples thin. content/lessons/science/physics/dynamics.md:14-16; example 66-84. Requirement facets: upcat-L149, upcat-L162, dcat-L080, ustet-L117, pupcet-L118, dost-sei-L054, dost-sei-L100, sm-foundation-L139.
- Newton second law: explained, examples worked. content/lessons/science/physics/dynamics.md:18-22; example 60-64. Requirement facets: upcat-L149, upcat-L162, dcat-L080, ustet-L117, pupcet-L118, dost-sei-L054, dost-sei-L100, sm-foundation-L139.
- Newton third law and interaction pairs: explained, examples worked. content/lessons/science/physics/dynamics.md:24-24; example 66-84. Requirement facets: upcat-L149, upcat-L162, dcat-L080, ustet-L117, pupcet-L118, dost-sei-L054, dost-sei-L100, sm-foundation-L139.
- Weight: explained, examples worked. content/lessons/science/physics/dynamics.md:30-34; example 97-107. Requirement facets: upcat-L149, upcat-L162, dcat-L080, ustet-L117, pupcet-L118, dost-sei-L054, dost-sei-L100, sm-foundation-L139.
- Normal force and balance: explained, examples worked. content/lessons/science/physics/dynamics.md:36-36; example 97-107. Requirement facets: upcat-L149, upcat-L162, dcat-L080, ustet-L117, pupcet-L118, dost-sei-L054, dost-sei-L100, sm-foundation-L139.
- Ideal rope tension: explained, examples none. content/lessons/science/physics/dynamics.md:38-38; no matching worked example recorded. Requirement facets: upcat-L149, upcat-L162, dcat-L080, ustet-L117, pupcet-L118, dost-sei-L054, dost-sei-L100, sm-foundation-L139.
- Static and kinetic friction: explained, examples worked. content/lessons/science/physics/dynamics.md:40-52; example 86-95. Requirement facets: upcat-L149, upcat-L162, dcat-L080, ustet-L117, pupcet-L118, dost-sei-L054, dost-sei-L100, sm-foundation-L139.
- Build and use a free-body diagram: thin, examples thin. content/lessons/science/physics/dynamics.md:54-56; example 97-109. Requirement facets: upcat-L149, upcat-L162, dcat-L080, ustet-L117, pupcet-L118, dost-sei-L054, dost-sei-L100, sm-foundation-L139.

Structure: retain. Force identification, Newton laws and friction support one force-balance goal. Tension has no applied example; diagram-building is only defined before verbal table examples. Proposal: Keep shared force teaching together; add an explicit isolated-object force construction with components before combined force use. Cost: One instructional sequence and worked setup; no new lesson required. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-electricity-and-magnetism

Goal: Distinguish electrical forces, circuit relationships and magnetic induction; apply the relevant model.

- Electric charge foundation: thin, examples thin. content/lessons/science/physics/electricity-and-magnetism.md:14-18; example 70-78. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Current physical meaning: named-only, examples none. content/lessons/science/physics/electricity-and-magnetism.md:28-34; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Voltage physical meaning: named-only, examples none. content/lessons/science/physics/electricity-and-magnetism.md:28-34; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Coulomb force: explained, examples worked. content/lessons/science/physics/electricity-and-magnetism.md:14-18; example 70-78. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Electric field: explained, examples none. content/lessons/science/physics/electricity-and-magnetism.md:20-24; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Ohm law: explained, examples worked. content/lessons/science/physics/electricity-and-magnetism.md:28-36; example 80-88. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Series equivalent resistance: explained, examples none. content/lessons/science/physics/electricity-and-magnetism.md:40-44; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Parallel equivalent resistance: explained, examples none. content/lessons/science/physics/electricity-and-magnetism.md:46-50; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Circuit open-path behavior: explained, examples worked. content/lessons/science/physics/electricity-and-magnetism.md:54-54; example 90-99. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Kirchhoff junction/loop use: named-only, examples none. content/lessons/science/physics/electricity-and-magnetism.md:50-50; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Magnetic poles: explained, examples not-required. content/lessons/science/physics/electricity-and-magnetism.md:58-58; no numerical worked solution required. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Wire field and right-hand rule: explained, examples worked. content/lessons/science/physics/electricity-and-magnetism.md:60-60; example 101-109. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Flux and Faraday induction: thin, examples thin. content/lessons/science/physics/electricity-and-magnetism.md:62-66; example 111-120. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Lenz direction: explained, examples thin. content/lessons/science/physics/electricity-and-magnetism.md:66-66; example 111-120. Requirement facets: upcat-L148, upcat-L149, upcat-L150, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L054, dost-sei-L100.
- Electrical safety/energy efficiency: absent, examples none. content/lessons/science/physics/electricity-and-magnetism.md:10-66; no matching worked example recorded. Requirement facets: dcat-L083, ustet-L124.
- Generators and motors: absent, examples none. content/lessons/science/physics/electricity-and-magnetism.md:56-66; no matching worked example recorded. Requirement facets: pupcet-L119.
- Charging mechanisms: absent, examples none. content/lessons/science/physics/electricity-and-magnetism.md:12-24; no matching worked example recorded. Requirement facets: dost-sei-L054.

Structure: split-candidate. Electrostatic force, circuit calculations and induction are distinct tasks. Current/voltage are only symbols; magnetic flux appears without meaning or a non-calculus relationship. Proposal: Separate electrostatics, DC circuits, and magnetism/induction; keep shared charge/current foundations once and link them. Explain flux before induction; move Kirchhoff to a worked network extension. Cost: Reassign examples and dependencies across three focused units; add current/voltage/flux foundations and network computations. Exact exam need for additions remains unknown. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.

Missing foundation: Physical meanings of current and potential difference. Circuit equal-current/equal-voltage statements need meanings beyond substituting numbers. Teach charge flow and voltage energy-per-charge before Ohm/circuit rules. Search: Whole content/lessons search: current/charge-flow/potential-difference leads only to this lesson or base-unit names; no existing teaching target verified.

Missing foundation: Magnetic flux. The central induction variable is undefined; no existing prerequisite lesson supplies it. Teach field-through-area meaning before induction, using accessible change-over-time reasoning. Search: Whole lesson corpus magnetic-flux search returned only this lesson.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-fluid-mechanics

Goal: Use density and displaced-fluid weight to predict buoyancy; compare pressure in hydrostatic and ideal-flow models.

- Density: explained, examples worked. content/lessons/science/physics/fluid-mechanics.md:14-18; example 52-58. Requirement facets: upcat-L150, dcat-L083, ustet-L124, dost-sei-L058, dost-sei-L107, dost-sei-L108.
- Pressure and depth: explained, examples none. content/lessons/science/physics/fluid-mechanics.md:20-28; no matching worked example recorded. Requirement facets: upcat-L150, dcat-L083, ustet-L124, dost-sei-L058, dost-sei-L107, dost-sei-L108.
- Buoyancy and force balance: explained, examples worked. content/lessons/science/physics/fluid-mechanics.md:30-36; example 60-84. Requirement facets: upcat-L150, dcat-L083, ustet-L124, dost-sei-L058, dost-sei-L107, dost-sei-L108.
- Bernoulli assumptions and comparison: explained, examples worked. content/lessons/science/physics/fluid-mechanics.md:40-48; example 86-100. Requirement facets: upcat-L150, dcat-L083, ustet-L124, dost-sei-L058, dost-sei-L107, dost-sei-L108.
- Pascal hydraulic systems: absent, examples none. content/lessons/science/physics/fluid-mechanics.md:10-48; no matching worked example recorded. Requirement facets: dcat-L083, ustet-L124, dost-sei-L058.

Structure: retain. Density, pressure and buoyancy are a coherent fluid core. The ideal-flow extension is brief and clearly separated, not inherently crammed. Proposal: Retain pressure/buoyancy/ideal flow; add pressure/depth use. Mechanical fluid-pressure repeats hydrostatic/Bernoulli core and adds continuity, but neither develops Pascal hydraulic systems. Cost: One pressure application and a verified cross-topic connection; no split justified by unknown exam depth. Rules: B03/L01/L17/L19, structural use only.

Readiness and optional preparation: Mass, volume, force and area vocabulary; density/pressure definitions and buoyancy force balance are supplied locally. The current buoyant-force example shows 300 g = 0.3 kg and the mg/newton calculation. General SI, dimensional checks and prefix interpretation are useful optional preparation, not a strict existing-lesson dependency for these supplied tasks.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-gravity-and-keplers-laws

Goal: Predict gravitational-force changes and orbital speed/size relationships using Newton gravity and Kepler laws.

- Universal gravity and inverse square: explained, examples worked. content/lessons/science/physics/gravity-and-keplers-laws.md:12-18; example 45-56. Requirement facets: dost-sei-L107, sm-foundation-L141.
- Kepler elliptical orbit and focus: explained, examples worked. content/lessons/science/physics/gravity-and-keplers-laws.md:24-26; example 94-102. Requirement facets: dost-sei-L107, sm-foundation-L141.
- Kepler equal areas and speed: explained, examples worked. content/lessons/science/physics/gravity-and-keplers-laws.md:28-28; example 58-68. Requirement facets: dost-sei-L107, sm-foundation-L141.
- Period and semimajor axis: explained, examples worked. content/lessons/science/physics/gravity-and-keplers-laws.md:30-40; example 71-92. Requirement facets: dost-sei-L107, sm-foundation-L141.

Structure: retain. Gravity and orbital patterns form a single explanatory goal with distinct examples. Historical context is short. Proposal: Retain; explain equal-area geometry in words before the speed deduction. Cost: Small local explanation; no new unit. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Ratios, inverse square, cube root; ellipse geometry/area reasoning. Semimajor axis and perihelion/aphelion are defined locally.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-kinematics

Goal: Describe signed one-dimensional motion and choose an appropriate constant-acceleration or free-fall equation.

- Position and displacement versus distance: explained, examples thin. content/lessons/science/physics/kinematics.md:16-20; example 71-77. Requirement facets: upcat-L148, upcat-L162, dcat-L080, dcat-L082, acet-L127, ustet-L117, ustet-L123, pupcet-L118, pupcet-L123, dost-sei-L054, dost-sei-L100, dost-sei-L107, sm-foundation-L139, sm-foundation-L141.
- Velocity versus speed: explained, examples thin. content/lessons/science/physics/kinematics.md:22-26; example 71-77. Requirement facets: upcat-L148, upcat-L162, dcat-L080, dcat-L082, acet-L127, ustet-L117, ustet-L123, pupcet-L118, pupcet-L123, dost-sei-L054, dost-sei-L100, dost-sei-L107, sm-foundation-L139, sm-foundation-L141.
- Acceleration as velocity change: explained, examples worked. content/lessons/science/physics/kinematics.md:28-32; example 65-69. Requirement facets: upcat-L148, upcat-L162, dcat-L080, dcat-L082, acet-L127, ustet-L117, ustet-L123, pupcet-L118, pupcet-L123, dost-sei-L054, dost-sei-L100, dost-sei-L107, sm-foundation-L139, sm-foundation-L141.
- Constant-acceleration equation selection: explained, examples worked. content/lessons/science/physics/kinematics.md:35-49; example 65-99. Requirement facets: upcat-L148, upcat-L162, dcat-L080, dcat-L082, acet-L127, ustet-L117, ustet-L123, pupcet-L118, pupcet-L123, dost-sei-L054, dost-sei-L100, dost-sei-L107, sm-foundation-L139, sm-foundation-L141.
- Signed ideal free fall: explained, examples worked. content/lessons/science/physics/kinematics.md:51-61; example 79-87. Requirement facets: upcat-L148, upcat-L162, dcat-L080, dcat-L082, acet-L127, ustet-L117, ustet-L123, pupcet-L118, pupcet-L123, dost-sei-L054, dost-sei-L100, dost-sei-L107, sm-foundation-L139, sm-foundation-L141.
- Motion graph slope/area interpretation: thin, examples none. content/lessons/science/physics/kinematics.md:109-109; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L162, dcat-L080, dcat-L082, acet-L127, ustet-L117, ustet-L123, pupcet-L118, pupcet-L123, dost-sei-L054, dost-sei-L100, dost-sei-L107, sm-foundation-L139, sm-foundation-L141.

Structure: reorder. Graph interpretation is a curriculum-supported preparation facet but appears only as a shortcut after exclusively numerical equations. Proposal: Move graph meaning into core teaching; show slope/area interpretation and a reversal before graph-dependent use elsewhere. Cost: Add one coherent graph-reading sequence and worked application; keep one-dimensional motion together. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Arithmetic, substitution and roots; origin/sign convention taught locally.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-light-and-optics

Goal: Explain reflection and refraction; classify optical devices and compare electromagnetic wavelengths.

- Reflection and normal angles: explained, examples worked. content/lessons/science/physics/light-and-optics.md:14-18; example 68-76. Requirement facets: upcat-L149, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, pupcet-L123, dost-sei-L104.
- Refraction and Snell law: explained, examples thin. content/lessons/science/physics/light-and-optics.md:22-32; example 96-104. Requirement facets: upcat-L149, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, pupcet-L123, dost-sei-L104.
- Critical angle and total internal reflection: thin, examples none. content/lessons/science/physics/light-and-optics.md:34-34; no matching worked example recorded. Requirement facets: upcat-L149, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, pupcet-L123, dost-sei-L104.
- Mirror/lens image formation: thin, examples thin. content/lessons/science/physics/light-and-optics.md:36-56; example 78-86. Requirement facets: upcat-L149, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, pupcet-L123, dost-sei-L104.
- Electromagnetic spectrum: explained, examples worked. content/lessons/science/physics/light-and-optics.md:58-64; example 88-94. Requirement facets: upcat-L149, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, pupcet-L123, dost-sei-L104.
- Optical instruments: absent, examples none. content/lessons/science/physics/light-and-optics.md:36-56; no matching worked example recorded. Requirement facets: upcat-L149, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, pupcet-L123, dost-sei-L104.

Structure: retain. Reflection/refraction and optical device behavior are coherent, but classification is substituted for constructing or predicting images. Proposal: Retain optics; develop image formation with object-position reasoning. Share wavelength/spectrum teaching with waves instead of maintaining two identical lists. Cost: Develop one image-formation sequence and relocate or cross-link duplicated spectrum core; exact quantitative depth remains unknown. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Normal/perpendicular geometry, sine for Snell law; wave speed/frequency/wavelength meanings.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-momentum-and-impulse

Goal: Use signed momentum and impulse, choose a system, and distinguish collision energy models.

- Signed momentum: explained, examples worked. content/lessons/science/physics/momentum-and-impulse.md:12-16; example 59-65. Requirement facets: upcat-L149, upcat-L162, dcat-L082, ustet-L117, pupcet-L118, pupcet-L123, dost-sei-L100, dost-sei-L107, sm-foundation-L139.
- Impulse and average force: explained, examples worked. content/lessons/science/physics/momentum-and-impulse.md:18-32; example 67-75. Requirement facets: upcat-L149, upcat-L162, dcat-L082, ustet-L117, pupcet-L118, pupcet-L123, dost-sei-L100, dost-sei-L107, sm-foundation-L139.
- Conservation and system boundary: explained, examples worked. content/lessons/science/physics/momentum-and-impulse.md:35-43; example 77-97. Requirement facets: upcat-L149, upcat-L162, dcat-L082, ustet-L117, pupcet-L118, pupcet-L123, dost-sei-L100, dost-sei-L107, sm-foundation-L139.
- Elastic/inelastic energy distinction: explained, examples thin. content/lessons/science/physics/momentum-and-impulse.md:45-55; example 85-89. Requirement facets: upcat-L149, upcat-L162, dcat-L082, ustet-L117, pupcet-L118, pupcet-L123, dost-sei-L100, dost-sei-L107, sm-foundation-L139.
- Variable-force graph impulse: thin, examples none. content/lessons/science/physics/momentum-and-impulse.md:24-30; no matching worked example recorded. Requirement facets: upcat-L149, upcat-L162, dcat-L082, ustet-L117, pupcet-L118, pupcet-L123, dost-sei-L100, dost-sei-L107, sm-foundation-L139.

Structure: retain. Impulse, system conservation and collision classification fit one goal. General integral notation lacks an area demonstration but does not warrant a separate lesson. Proposal: Retain; introduce graphical impulse before the integral and show kinetic-energy comparison once. Cost: Two targeted teaching/example additions; retain shared collision instruction. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Signed velocity, kinetic versus total energy, chosen system boundary. Integral is not needed for its constant/average-force examples.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-scalars-and-vectors

Goal: Distinguish scalars/vectors and combine signed or perpendicular components to describe physical quantities.

- Scalar/vector distinction: explained, examples worked. content/lessons/science/physics/scalars-and-vectors.md:12-20; example 53-67. Requirement facets: upcat-L150.
- Signed/perpendicular vector addition: explained, examples worked. content/lessons/science/physics/scalars-and-vectors.md:23-35; example 69-75. Requirement facets: upcat-L150.
- Component resolution and reconstruction: explained, examples worked. content/lessons/science/physics/scalars-and-vectors.md:37-49; example 78-95. Requirement facets: upcat-L150.
- General resultant direction and quadrant: thin, examples none. content/lessons/science/physics/scalars-and-vectors.md:49-49; no matching worked example recorded. Requirement facets: upcat-L150.

Structure: retain. Classification, addition and resolution form one foundational sequence. The general tip-to-tail/direction method is stated but not demonstrated. Proposal: Keep a reusable foundation; add one multi-vector quadrant/direction construction rather than a separate vector unit. Cost: One applied reconstruction example; verification of math foundations required. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Right-triangle sine/cosine and Pythagorean magnitude; general quadrant direction needs more than the displayed acute-angle example.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-thermodynamics

Goal: Distinguish heat-transfer mechanisms, apply sensible-heat relationships and interpret thermodynamic law statements.

- Heat versus internal energy: explained, examples thin. content/lessons/science/physics/thermodynamics.md:12-14; example 108-112. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Conduction: explained, examples worked. content/lessons/science/physics/thermodynamics.md:20-20; example 54-64. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Convection: explained, examples worked. content/lessons/science/physics/thermodynamics.md:22-22; example 54-64. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Radiation: explained, examples worked. content/lessons/science/physics/thermodynamics.md:24-24; example 54-64. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Zeroth law and thermal equilibrium: thin, examples thin. content/lessons/science/physics/thermodynamics.md:30-30; example 66-74. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- First law and work convention: explained, examples none. content/lessons/science/physics/thermodynamics.md:32-36; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Second law direction: explained, examples worked. content/lessons/science/physics/thermodynamics.md:38-38; example 66-74. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Third law/entropy: thin, examples none. content/lessons/science/physics/thermodynamics.md:40-40; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Specific heat calculation: explained, examples worked. content/lessons/science/physics/thermodynamics.md:42-48; example 76-96. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Latent heat: named-only, examples none. content/lessons/science/physics/thermodynamics.md:50-50; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L162, dcat-L085, ustet-L117, pupcet-L119, dost-sei-L100, dost-sei-L107.
- Controlled-variable comparison: thin, examples thin. content/lessons/science/physics/thermodynamics.md:84-96; example 84-96. Requirement facets: dcat-L077, acet-L126, ustet-L113.

Structure: split-candidate. Heat-transfer and calorimetry share direct applications; four-law/entropy statements add a different system-level task with only a second-law example. Proposal: Keep thermal transfer and calorimetry as common preparation; make first-law system work and thermodynamic-law reasoning an extension after energy/work foundations. Cost: Move law content and examples, add first-law work/sign example and latent-heat teaching if retained; exact required law depth is unknown. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Energy transfer, work, mass and temperature change.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-two-dimensional-motion

Goal: Solve ideal projectile components and explain how real forces maintain uniform circular motion.

- Projectile components and shared time: explained, examples worked. content/lessons/science/physics/two-dimensional-motion.md:12-36; example 55-87. Requirement facets: upcat-L148, dcat-L083, ustet-L124, pupcet-L118, dost-sei-L100, dost-sei-L107.
- Circular acceleration and radial force: explained, examples thin. content/lessons/science/physics/two-dimensional-motion.md:39-51; example 89-107. Requirement facets: upcat-L148, dcat-L083, ustet-L124, pupcet-L118, dost-sei-L100, dost-sei-L107.
- Angular speed: named-only, examples none. content/lessons/science/physics/two-dimensional-motion.md:43-43; no matching worked example recorded. Requirement facets: upcat-L148, dcat-L083, ustet-L124, pupcet-L118, dost-sei-L100, dost-sei-L107.
- Rotational motion: absent, examples none. content/lessons/science/physics/two-dimensional-motion.md:39-51; no matching worked example recorded. Requirement facets: dcat-L083, ustet-L124, dost-sei-L058.

Structure: split-candidate. Projectile calculations use signed kinematics and components; circular-force reasoning needs Newton force identification. The second task is currently qualitative despite formulas. Proposal: Keep projectile motion as kinematics application; make circular motion a force-based application after dynamics. Define angular speed if retaining it. Cost: Move circular core/examples and add one radial-force computation; avoid duplicating component teaching. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Constant acceleration/free fall, real-force identification, and sine/cosine ratio meaning and 30-degree values for the angled-launch application. Component axes, launch-angle convention and equations are already local.

Optional preparation: scalars-and-vectors.md:37-43 repeats the locally supplied component convention. Vector addition, resultant reconstruction and quadrant work are useful broader preparation, but this current consumer does not require them. The direct trigonometric foundation covers only the acute-angle ratio/value need; it is not a mathematical-topic coverage verdict.

Missing foundation: Angular speed. The omega-squared radius alternative cannot be understood from the local definitions. Define angular speed locally if this formula is retained. Search: Whole lesson search also found gear-rotations lines 18-26 and 51-63; full read teaches tooth-count ratios, not angular displacement per time, units, or v=omega r. No foundation target verified.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-units-and-measurements

Goal: Identify SI base units, cancel conversion factors and check the dimensions of a physics expression.

- SI base and derived units: explained, examples worked. content/lessons/science/physics/units-and-measurements.md:14-36; example 84-97. Requirement facets: upcat-L190, acet-L081, ustet-L083, ustet-L095, pupcet-L091, dost-sei-L126, dost-sei-L136, sm-foundation-L097.
- Simple/compound conversion: explained, examples worked. content/lessons/science/physics/units-and-measurements.md:38-42; example 46-82. Requirement facets: upcat-L190, acet-L081, ustet-L083, ustet-L095, pupcet-L091, dost-sei-L126, dost-sei-L136, sm-foundation-L097.
- Squared/cubed unit conversion: explained, examples thin. content/lessons/science/physics/units-and-measurements.md:121-125; example 125-125. Requirement facets: upcat-L190, acet-L081, ustet-L083, ustet-L095, pupcet-L091, dost-sei-L126, dost-sei-L136, sm-foundation-L097.
- Measurement uncertainty: absent, examples none. content/lessons/science/physics/units-and-measurements.md:10-42; no matching worked example recorded. Requirement facets: upcat-L190, acet-L081, ustet-L083, ustet-L095, pupcet-L091, dost-sei-L126, dost-sei-L136, sm-foundation-L097.

Structure: retain. Units, conversion and dimensional checks are one coherent foundation. Area/volume conversion is taught late as a trap instead of before use. Proposal: Retain a shared physics/math conversion foundation; move powered-unit conversion to core and demonstrate a volume conversion where needed. Cost: Small reordering and one applied powered-unit example; do not infer measurement uncertainty demand from title alone. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Fractions, decimal division and exponents; factor cancellation is taught locally.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-waves-and-sound

Goal: Relate wave speed, frequency and wavelength; classify wave types and explain moving-source Doppler pitch changes.

- Wave properties and speed relation: explained, examples worked. content/lessons/science/physics/waves-and-sound.md:12-26; example 52-70. Requirement facets: upcat-L149, upcat-L162, dcat-L080, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, dost-sei-L104, sm-foundation-L139, sm-foundation-L141.
- Mechanical versus electromagnetic waves: explained, examples worked. content/lessons/science/physics/waves-and-sound.md:30-34; example 72-79. Requirement facets: upcat-L149, upcat-L162, dcat-L080, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, dost-sei-L104, sm-foundation-L139, sm-foundation-L141.
- Transverse versus longitudinal waves: explained, examples none. content/lessons/science/physics/waves-and-sound.md:36-36; no matching worked example recorded. Requirement facets: upcat-L149, upcat-L162, dcat-L080, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, dost-sei-L104, sm-foundation-L139, sm-foundation-L141.
- Sound speed, pitch and intensity: explained, examples thin. content/lessons/science/physics/waves-and-sound.md:38-42; example 62-70. Requirement facets: upcat-L149, upcat-L162, dcat-L080, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, dost-sei-L104, sm-foundation-L139, sm-foundation-L141.
- Moving-source Doppler effect: explained, examples worked. content/lessons/science/physics/waves-and-sound.md:44-48; example 81-92. Requirement facets: upcat-L149, upcat-L162, dcat-L080, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, dost-sei-L104, sm-foundation-L139, sm-foundation-L141.
- Interference/diffraction: absent, examples none. content/lessons/science/physics/waves-and-sound.md:10-48; no matching worked example recorded. Requirement facets: upcat-L149, upcat-L162, dcat-L080, dcat-L082, dcat-L083, ustet-L117, ustet-L123, ustet-L124, pupcet-L119, dost-sei-L104, sm-foundation-L139, sm-foundation-L141.
- Electromagnetic wavelength ordering: named-only, examples none. content/lessons/science/physics/waves-and-sound.md:34-34; no matching worked example recorded. Requirement facets: sm-foundation-L139.

Structure: retain. Wave properties, sound and source-motion Doppler share one propagation goal. Spectrum ordering is taught in optics, so this lesson alone cannot claim that facet. Proposal: Retain; connect the existing spectrum order, and add wave-behavior teaching only where the conditional light-wave preparation requires it. Cost: A narrow existing-content connection; new interference/diffraction teaching would be extra authoring, not a cosmetic split. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Ratio arithmetic; oscillation/cycle and medium distinctions developed locally.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

### lesson-physics-work-energy-power

Goal: Calculate kinetic/potential energy and power; distinguish mechanical energy conservation from total energy conservation.

- Constant-force work: explained, examples none. content/lessons/science/physics/work-energy-power.md:12-18; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L162, dcat-L080, dcat-L083, acet-L127, ustet-L117, ustet-L124, pupcet-L118, pupcet-L119, dost-sei-L054, dost-sei-L100, dost-sei-L108, sm-foundation-L139.
- Work-energy theorem: explained, examples none. content/lessons/science/physics/work-energy-power.md:32-36; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L162, dcat-L080, dcat-L083, acet-L127, ustet-L117, ustet-L124, pupcet-L118, pupcet-L119, dost-sei-L054, dost-sei-L100, dost-sei-L108, sm-foundation-L139.
- Kinetic energy: explained, examples worked. content/lessons/science/physics/work-energy-power.md:22-24; example 62-79. Requirement facets: upcat-L148, upcat-L149, upcat-L162, dcat-L080, dcat-L083, acet-L127, ustet-L117, ustet-L124, pupcet-L118, pupcet-L119, dost-sei-L054, dost-sei-L100, dost-sei-L108, sm-foundation-L139.
- Near-Earth potential energy: explained, examples worked. content/lessons/science/physics/work-energy-power.md:26-30; example 81-94. Requirement facets: upcat-L148, upcat-L149, upcat-L162, dcat-L080, dcat-L083, acet-L127, ustet-L117, ustet-L124, pupcet-L118, pupcet-L119, dost-sei-L054, dost-sei-L100, dost-sei-L108, sm-foundation-L139.
- Mechanical energy conservation: explained, examples worked. content/lessons/science/physics/work-energy-power.md:38-42; example 96-125. Requirement facets: upcat-L148, upcat-L149, upcat-L162, dcat-L080, dcat-L083, acet-L127, ustet-L117, ustet-L124, pupcet-L118, pupcet-L119, dost-sei-L054, dost-sei-L100, dost-sei-L108, sm-foundation-L139.
- Nonconservative work accounting: explained, examples none. content/lessons/science/physics/work-energy-power.md:44-48; no matching worked example recorded. Requirement facets: upcat-L148, upcat-L149, upcat-L162, dcat-L080, dcat-L083, acet-L127, ustet-L117, ustet-L124, pupcet-L118, pupcet-L119, dost-sei-L054, dost-sei-L100, dost-sei-L108, sm-foundation-L139.
- Average power: explained, examples worked. content/lessons/science/physics/work-energy-power.md:52-58; example 127-140. Requirement facets: upcat-L148, upcat-L149, upcat-L162, dcat-L080, dcat-L083, acet-L127, ustet-L117, ustet-L124, pupcet-L118, pupcet-L119, dost-sei-L054, dost-sei-L100, dost-sei-L108, sm-foundation-L139.
- Machine efficiency: absent, examples none. content/lessons/science/physics/work-energy-power.md:52-58; no matching worked example recorded. Requirement facets: dcat-L083, ustet-L124.

Structure: retain. Work, mechanical energy and power share a transfer/accounting goal. Named work-energy and friction accounting have no worked application. Proposal: Retain; add angle/net-work and nonconservative-work application. Pulleys-and-levers develops ideal mechanical advantage, but not a quantitative efficiency relationship; share that foundation before any new efficiency teaching. Cost: Two distinct applications plus existing-content connection; no split solely for example breadth. Rules: B03/L01/L17/L19, structural use only.

Necessary prior knowledge: Displacement versus path length, speed, cosine projection and algebraic rearrangement.

Availability: unknown, corpus-bound runtime not verified. Practice: deferred Level 5.

## Necessary prerequisite links

| Consumer | Existing prerequisite | Scope | Necessary use | Consumer evidence | Foundation evidence |
|---|---|---|---|---|---|
| lesson-physics-dynamics | lesson-physics-kinematics | within-topic | Newton laws use velocity and acceleration; kinematics defines how those quantities differ. | content/lessons/science/physics/dynamics.md:16-22 | content/lessons/science/physics/kinematics.md:22-32 |
| lesson-physics-dynamics | lesson-physics-scalars-and-vectors | within-topic | Component-wise net-force equations require vector addition and resolution. | content/lessons/science/physics/dynamics.md:20-22 | content/lessons/science/physics/scalars-and-vectors.md:23-43 |
| lesson-physics-light-and-optics | lesson-physics-waves-and-sound | within-topic | Speed, frequency and wavelength changes at a boundary require the wave quantities and their relationship. | content/lessons/science/physics/light-and-optics.md:26-32 | content/lessons/science/physics/waves-and-sound.md:14-26 |
| lesson-physics-light-and-optics | lesson-trigonometry-basic-trigonometric-ratios | across-topics | Snell law uses sine of a normal angle without defining sine. | content/lessons/science/physics/light-and-optics.md:28-30 | content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md:12-34 |
| lesson-physics-momentum-and-impulse | lesson-physics-kinematics | within-topic | Momentum-change calculations use signed initial/final velocity, not path speed. | content/lessons/science/physics/momentum-and-impulse.md:12-30 | content/lessons/science/physics/kinematics.md:20-32 |
| lesson-physics-momentum-and-impulse | lesson-physics-work-energy-power | within-topic | Elastic versus inelastic distinction assumes the meaning of kinetic energy and its difference from total energy. | content/lessons/science/physics/momentum-and-impulse.md:45-53 | content/lessons/science/physics/work-energy-power.md:20-40 |
| lesson-physics-scalars-and-vectors | lesson-trigonometry-basic-trigonometric-ratios | across-topics | Component resolution uses sine and cosine without defining those ratios. | content/lessons/science/physics/scalars-and-vectors.md:39-43 | content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md:12-34 |
| lesson-physics-thermodynamics | lesson-physics-work-energy-power | within-topic | First-law work accounting assumes the physical meaning of work as energy transfer. | content/lessons/science/physics/thermodynamics.md:32-36 | content/lessons/science/physics/work-energy-power.md:12-18 |
| lesson-physics-two-dimensional-motion | lesson-physics-kinematics | within-topic | Projectile equations extend constant acceleration/free fall in each signed axis. | content/lessons/science/physics/two-dimensional-motion.md:16-28 | content/lessons/science/physics/kinematics.md:35-59 |
| lesson-physics-two-dimensional-motion | lesson-trigonometry-basic-trigonometric-ratios | across-topics | Angled-launch evaluation assumes sine/cosine meaning and 30-degree values; the axes and component equations are local. | content/lessons/science/physics/two-dimensional-motion.md:30-32,70-76 | content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md:12-34,94-116 |
| lesson-physics-two-dimensional-motion | lesson-physics-dynamics | within-topic | Circular motion distinguishes real forces and their net radial component; dynamics identifies those forces. | content/lessons/science/physics/two-dimensional-motion.md:45-51 | content/lessons/science/physics/dynamics.md:28-56 |
| lesson-physics-work-energy-power | lesson-physics-kinematics | within-topic | Work uses displacement and kinetic energy uses speed; these quantities must be distinguished from path distance and signed velocity. | content/lessons/science/physics/work-energy-power.md:12-24 | content/lessons/science/physics/kinematics.md:14-26 |
| lesson-physics-work-energy-power | lesson-trigonometry-basic-trigonometric-ratios | across-topics | Angled-force work uses cosine without defining the projection ratio. | content/lessons/science/physics/work-energy-power.md:14-16 | content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md:12-34 |

No necessary existing prerequisite link found: lesson-physics-electricity-and-magnetism, lesson-physics-fluid-mechanics, lesson-physics-gravity-and-keplers-laws, lesson-physics-kinematics, lesson-physics-units-and-measurements, lesson-physics-waves-and-sound. Electricity remains missing-foundation rather than unchecked; all others here explain their necessary physical quantities locally. Arithmetic/algebra fluency remains explicit prior knowledge, not automatic topic-order edges.

Intralesson ordering: graph explanation before graph shortcuts; powered-unit conversion before its trap; flux meaning before induction; angle conventions before resolution; machine advantage before efficiency additions. These are not self-links.

## Load-bearing figure dependencies

None identified in these 13 text-defined examples. The appendix retains an explicit empty list per lesson. Authored figure comments do not establish display or runtime availability. No need, sufficiency, quality, decoration, production method or illustration count was assessed.

## Source ledger

Access date: October 5, 2026. Branch/base and corpus are recorded above and in each row. No content disposition was implemented.

| Item | Issue | Original content/claim | Disposition | Source URL/page | Verification note |
|---|---|---|---|---|---|
| lesson-physics-electricity-and-magnetism | Missing physical meaning of current | Lines 28-36 label I as current; line 60 uses conventional current, without charge-flow meaning. | LESSON GAP: foundation definition confirmed, content unchanged | https://openstax.org/books/university-physics-volume-2/pages/9-1-electrical-current, Defining Current and the Ampere | Source defines current as net charge passing per time and conventional current by positive charge direction. This supports the foundation-gap finding, not an exam scope claim. |
| lesson-physics-electricity-and-magnetism | Missing voltage meaning | Line 34 labels V as potential difference without energy-per-charge meaning. | LESSON GAP: physical meaning confirmed, content unchanged | https://openstax.org/books/university-physics-volume-2/pages/7-2-electric-potential-and-potential-difference, Electric Potential Difference | Source defines potential difference as potential-energy change divided by charge. Bare symbol labeling does not develop that idea. |
| lesson-physics-electricity-and-magnetism | Undefined flux is central to induction | Lines 62-66 use changing magnetic flux and Faraday/Lenz; lines 113-120 repeat that relationship. | CONFIRMED relationship; LESSON GAP in flux foundation, content unchanged | https://openstax.org/books/university-physics-volume-2/pages/13-1-faradays-law, Faraday Law, equations 13.1-13.3 | Source relates induction to changing magnetic field through a surface and its orientation/area. Existing lesson does not develop the flux quantity. No complete fact or answer review claimed. |

## Historical self-check before P1 correction

Original author self-check executed against pre-correction SHA256 88d7e88c8b2d0adceeecb0d0a81853573b40163f669dc0c1edc0d41b45885b98 on October 5, 2026. This 14-edge evidence is historical and does not verify the amended edge set. The scoped Python assertions checked assigned IDs, hashes/full ranges, every required field, requirement references, all evidence bounds, both-end prerequisite paths and lines, local graph cycles, pinned corpus cleanliness, and scope markers. Actual output:

```text
physics scoped self-check: PASS
assigned IDs: 13 expected / 13 unique / 0 missing / 0 extra
full-read hashes/ranges: 13 matched; pinned corpus HEAD clean
JSON: 1 valid appendix; required lesson/skill/structure fields present
local facets: 97; requirement refs: 35 distinct / 0 unknown
evidence: 368 objects / 0 invalid paths or line bounds
prerequisites: 14 existing targets / both-end paths and lines / 0 self-links / 0 local cycles
no-link lessons: 5 explicit; missing foundations: 2 lessons; source ledger: 3 rows
em dashes: 0; attribution markers: 0; load-bearing figure dependencies: 0 recorded
scope: Level 3 only; no content changes; runtime unknown; practice deferred Level 5
```

The shared read-only validator, python3 docs/content/audit/coverage-r1/check_level3_outputs.py, returned exit 0: completeTopics 3, completeLessons 40, errors [], gateReady false. It counted biology, chemistry and physics complete; 22 other topics remained pending. That combined snapshot does not accept physics semantically or authorize Level 4. Fresh independent review and the combined graph/gate remain the lead responsibility. No content/app/importer/schema changes, Git mutations, Google writes, computer control, subagent dispatch, standards pass, blind solves or illustration production occurred. Exact current exam depth, languages, topic exclusivity, candidate coverage beyond the local facet, practice, mastery and runtime access remain unknown or deferred.

## P1 correction, October 6, 2026

Current correction policy: main `e8d5f0f958e38c1648046a93747437687ba08334`, verified against live remote and cached origin/main. Corpus remains clean/pinned at `765c5dc0fa5586281047bf4f7b30d09ab3707887`. Original author full-read hashes, findings and source ledger are preserved. This correction reread full two-dimensional-motion 1-141, scalars-and-vectors 1-130 and basic-trigonometric-ratios 1-194; correctionHistory records current read hashes. Biology, Chemistry and other outputs were not written.

P1 in [topic-samples](../review/topic-samples.md) records the original challenged vector edge and target hash. That review history remains unchanged. The consumer teaches horizontal/upward axes at 16, shared time at 20, launch-angle convention at 30 and component equations at 32; its 70-76 example applies that convention. Scalars-and-vectors 37-43 duplicates the component method, so it is optional preparation rather than a strict prerequisite.

The distinct absent idea is sine/cosine side-ratio meaning and the 30-degree values used at74-76. Basic-trigonometric-ratios 12-34 defines those ratios and values;94-116 works the matching opposite-side calculation. The replacement link points directly to that existing foundation, bounded to this acute-angle application. It does not require the full vector lesson, reciprocal ratios, general quadrants, or a future expanded consumer. Kinematics and dynamics links remain unchanged. Four affected lesson-facet priorKnowledge notes and the projectile facet's local limit now distinguish local component teaching from its mathematical foundation. All other teaching verdicts, exam scope/tags, figures, source claims and links are unchanged.

Current strict edge count remains 14 because one edge was removed and one directly evidenced edge added. Equality with the historical count does not establish identical graph inputs. Fresh narrow P1 review is pending; author checks cannot accept the amended artifact.

Completion resume identity: live/cached main `6d0bb7318ad396abe62c6c59b6d437f758ed65c4`; live/local audit HEAD `25ebd755560a38d4a21323424fee63ece8171930`. Saved correction SHA256 `81c04729b09b6fe798430651d7739a7568223dd84d95fb2e5817d5a285580954` matched before editing. Current mandatory policy/standard/startup contents were retrieved and independently compared with the fully read e8d5 revision, with nine identical results; current spec/plan/decisions/orchestrator were also verified unchanged. The saved source read evidence is preserved and its pinned hashes are rechecked below. No unchanged full source reading was repeated.

P1 verification commands: focused Python assigned-ID/hash/full-read-range/field/evidence/reference/prerequisite/graph checks, including comparison with the exact original target at audit commit401968b6326c509dd58699d3b7e836ce19781d62; then `python3 docs/content/audit/coverage-r1/check_level3_outputs.py`. Both returned exit0. The original target hash was independently matched before comparing allowed JSON changes. Actual focused output:

    physics_P1_check: assigned=13/13 unique=13 hashes_ranges_paths=13/13 json_appendices=1 fields=PASS facets=97 evidence_ranges=370 accepted_refs=35 edges=14 both_end_paths_lines=PASS targets_existing=PASS self_links=0 cycles=0 direct_trig_edge=PASS vector_edge_removed=PASS kinematics_dynamics_unchanged=PASS unrelated_JSON_unchanged=PASS preserved_source_reads=3/3 corpus_clean=true biology_chemistry_unchanged=true emdash=0 errors=[]

Shared validator actual result fields: `completeTopics: 5`, `expectedTopics: 25`, `completeLessons: 60`, `expectedLessons: 158`, `complete: [mathematics-arithmetic-number-sense, science-biology, science-chemistry, science-earth-science-astronomy, science-physics]`, `errors: []`, `mechanicalAccountingReady: false`, `gateReady: false`. Its20pending topics include Algebra as DRAFT and19others NOT_STARTED. This supporting snapshot does not accept P1 or the combined Level3 gate. Earlier14-edge counts are historical; the current proof checks the amended direct-trigonometry edge set.

Fresh narrow P1 review remains pending. No unresolved mechanical issue was found. All author checks remain separate from semantic acceptance.

## P2 correction, October 9, 2026

Correction policy main `1aaebad9814ba7bd9404d8b43fc010281abb97cf` matched live/cached main; audit live/local `9331dbe0852bfffc8a73d320dcb1413870a8ed41`; read-only corpus remains clean/pinned at `765c5dc0fa5586281047bf4f7b30d09ab3707887`. All required current policy/context was retrieved and matched prior full reads, with the latest October 9 continuation and full P2 brief/reader contract read. Previous target SHA256 `20d984df846d1abff9ae506e16618b5cc0603c24eef062e632b4097b7f863905` matched before editing. Original thirteen complete read identities remain preserved; only Fluid Mechanics and Units were reopened in full for this correction.

Focused reads: `content/lessons/science/physics/fluid-mechanics.md` lines 1-142, SHA256 `29446c078d4024ca5fc7ebeb6ee1e77e627c3cc96f5a61e44a55bf5e03fde54e`; `content/lessons/science/physics/units-and-measurements.md` lines 1-125, SHA256 `44f728ab41f7de68e1003b70273341b239b245b15bfa0ba7b54d936c454d89cc`.

The [fresh P2 finding](../review/topic-samples.md#targeted-whole-graph-necessity-challenge-physics-p2-flags) challenges only Fluid Mechanics -> Units and Measurements. Fluid lines 16-36 supplies density, pressure and displaced-fluid weight/force balance; lines 72-84 explicitly performs 300 g = 0.3 kg and the mg/newton calculation. The present tasks do not require deriving a conversion factor, proving newton base units or independently screening an expanded mixed-unit problem. Remove that strict edge and mark Fluid Mechanics checked `none-found`. General SI meaning, dimensional checks and prefix interpretation remain useful optional preparation from Units lines 19/26/40-42/86-97/103.

The original both-end comparison, consumer lines 72-82 and Units lines 38-42, is preserved here as optional context rather than proof of necessity. The five corresponding facet priorKnowledge notes and consumer prose now distinguish supplied local methods from optional unit background. Pressure/depth's missing application, absent Pascal hydraulic systems, other genuine local gaps, all teaching/examples/goals/tags, source ledger and source read evidence remain unchanged. No replacement edge, future-content edge or broad SI prerequisite was invented.

Current Physics strict edge count is 13, and six consumers have explicit no-existing-link dispositions. Earlier fourteen-edge author/P1 checks remain dated historical evidence, not verification of this amended object. P1's direct basic-trigonometric-ratios link and all other prerequisite records remain unchanged. All other topic outputs remain immutable. Fresh independent focused P2 recheck at the new artifact hash is required; this author correction does not accept it.

Completion resumption: current main `1aaebad9814ba7bd9404d8b43fc010281abb97cf` and audit live/local `c8983d6d7f36a87f618f0654321cb84a030f57c5` matched. Saved corrected checkpoint SHA256 `7f3d3d27dbfb026463964eb1e306ee31a303ca71f0cadb72229565ed03ef38df` matched before finishing. Current mandatory policy/context was retrieved and checked unchanged; the matching source reads and completed correction were preserved rather than repeated.

Preserved guard history: the first scoped execution returned exit1 only for an unrelated-document preservation guard. Audit9331 held Verbal Logic DRAFT SHA256 `71bac92b64f1907f6f54efae780709a1037af181924de72fb57c05b67ac51a48`, while the authorized current COMPLETE/PASS release was `52b8bc5c810e723c5c2539b8d28709a9612c8ac5d649a7c9ed25484fb19b67b0`. The actual current file matched that accepted release; no Verbal write occurred. The guard was corrected to use the authorized current baseline and returned exit0. This resumption independently checks all twenty-four current completed documents against auditc898, with zero changes. The initial failure is historical baseline evidence, not an unresolved Physics failure or permission to overwrite another document.

Current scoped command: inline Python against the actual saved target, immutable original Physics object at audit9331, current baselinec898, packet/map/manifest, all thirteen read hashes/ranges, evidence/reference bounds, remaining prerequisite targets/both ends, graph and prose/JSON parity. Exit0, actual output:

```text
{
  "physicsP2": "current scoped author check",
  "policyCommit": "1aaebad9814ba7bd9404d8b43fc010281abb97cf",
  "auditBaseline": "c8983d6d7f36a87f618f0654321cb84a030f57c5",
  "savedCheckpointSHA256": "7f3d3d27dbfb026463964eb1e306ee31a303ca71f0cadb72229565ed03ef38df",
  "originalSHA256": "20d984df846d1abff9ae506e16618b5cc0603c24eef062e632b4097b7f863905",
  "changedJSONPaths": [
    "/lessons/2/prerequisiteStatus",
    "/lessons/2/prerequisites",
    "/requirementFacets/16/priorKnowledge",
    "/requirementFacets/17/priorKnowledge",
    "/requirementFacets/18/priorKnowledge",
    "/requirementFacets/19/priorKnowledge",
    "/requirementFacets/20/priorKnowledge"
  ],
  "changesConfinedToConsumerAndFivePriorNotes": true,
  "assignedIDs": 13,
  "uniqueOwnedIDs": 13,
  "readHashesRangesPathsMatched": 13,
  "facets": 97,
  "acceptedUniqueRefs": 35,
  "referenceOccurrences": 1526,
  "evidenceRangesChecked": 368,
  "oldStrictEdges": 14,
  "currentStrictEdges": 13,
  "existingTargetsBothEndPathsLines": "PASS",
  "selfLinks": 0,
  "cycles": [],
  "noStrictLinkConsumers": 6,
  "proseJSONParity": true,
  "P1ConsumerAndDirectTrigUnchanged": true,
  "otherLessonsUnchanged": true,
  "sourceLedgerAndCorrectionHistoryUnchanged": true,
  "allSourceReadIdentitiesUnchanged": true,
  "existingProseOnlyThreeIntendedChanges": true,
  "otherCurrentCompletedDocumentsChecked": 24,
  "otherCurrentDocumentsChanged": [],
  "corpusHEAD": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "corpusDirty": false,
  "jsonAppendices": 1,
  "emDashes": 0,
  "errors": []
}
```

Supporting command: `python3 docs/content/audit/coverage-r1/check_level3_outputs.py`. Exit0, actual output:

```text
{
  "level": 3,
  "completeTopics": 25,
  "expectedTopics": 25,
  "completeLessons": 158,
  "expectedLessons": 158,
  "complete": [
    "general-information-code-of-conduct-ra-6713",
    "general-information-environment-management",
    "general-information-peace-and-human-rights",
    "general-information-philippine-constitution",
    "language-proficiency-grammar-and-structure",
    "language-proficiency-language-application",
    "language-proficiency-vocabulary",
    "mathematics-algebra",
    "mathematics-arithmetic-number-sense",
    "mathematics-data-interpretation",
    "mathematics-geometry",
    "mathematics-precalculus-basic-calculus",
    "mathematics-statistics-and-probability",
    "mathematics-trigonometry",
    "reading-comprehension-comprehension-skills",
    "reading-comprehension-text-types",
    "reasoning-clerical-ability",
    "reasoning-logical-verbal-reasoning",
    "reasoning-mechanical-technical-reasoning",
    "reasoning-spatial-abstract-reasoning",
    "reasoning-verbal-logic",
    "science-biology",
    "science-chemistry",
    "science-earth-science-astronomy",
    "science-physics"
  ],
  "pending": [],
  "errors": [],
  "mechanicalAccountingReady": true,
  "gateReady": false
}
```

`git diff --check -- docs/content/audit/coverage-r1/topics/science-physics-lessons.md` returned exit0 with no output. Final parse/JSON identity is checked after inserting this record. Only the Physics output was written. All seven allowed JSON changes, original read evidence, P1 correction, unrelated teaching/source fields and twenty-four other document identities remain as verified above.

Unverified limits: canonical Dart attribution remains unverified after the previous hang/cancel exit130; no pass is inherited or SDK repaired. Runtime/practice, finer exam depth/languages/cycles, complete correctness/standards and later levels remain unchanged unknown/deferred. P2 requires fresh independent recheck of this final artifact hash before acceptance. No Level4/5, content/app/roadmap/importer/schema/figure, Google or Git mutation, additional agent or new usage-limit error occurred during this completion.


## Machine-readable appendix

```json
{
  "level": 3,
  "status": "COMPLETE",
  "subject": "science",
  "topic": "physics",
  "policyCommit": "6d0bb7318ad396abe62c6c59b6d437f758ed65c4",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "goal": "Distinguish force balance from interaction pairs and use a force model to explain or calculate motion.",
      "skills": [
        {
          "name": "Newton first law and inertia",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                14,
                16
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                66,
                84
              ],
              "note": "Distinct example evidence, thin as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "ustet-L117",
            "pupcet-L118",
            "dost-sei-L054",
            "dost-sei-L100",
            "sm-foundation-L139"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Newton second law",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                18,
                22
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                60,
                64
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "ustet-L117",
            "pupcet-L118",
            "dost-sei-L054",
            "dost-sei-L100",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Newton third law and interaction pairs",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                24,
                24
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                66,
                84
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "ustet-L117",
            "pupcet-L118",
            "dost-sei-L054",
            "dost-sei-L100",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Weight",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                30,
                34
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                97,
                107
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "ustet-L117",
            "pupcet-L118",
            "dost-sei-L054",
            "dost-sei-L100",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Normal force and balance",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                36,
                36
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                97,
                107
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "ustet-L117",
            "pupcet-L118",
            "dost-sei-L054",
            "dost-sei-L100",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Ideal rope tension",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                38,
                38
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "ustet-L117",
            "pupcet-L118",
            "dost-sei-L054",
            "dost-sei-L100",
            "sm-foundation-L139"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Static and kinetic friction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                40,
                52
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                86,
                95
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "ustet-L117",
            "pupcet-L118",
            "dost-sei-L054",
            "dost-sei-L100",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Build and use a free-body diagram",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                54,
                56
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                97,
                109
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "ustet-L117",
            "pupcet-L118",
            "dost-sei-L054",
            "dost-sei-L100",
            "sm-foundation-L139"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Force identification, Newton laws and friction support one force-balance goal. Tension has no applied example; diagram-building is only defined before verbal table examples.",
        "proposal": "Keep shared force teaching together; add an explicit isolated-object force construction with components before combined force use.",
        "cost": "One instructional sequence and worked setup; no new lesson required.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/dynamics.md",
            "lines": [
              10,
              56
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/dynamics.md",
            "lines": [
              60,
              109
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-physics-kinematics",
          "reason": "Newton laws use velocity and acceleration; kinematics defines how those quantities differ.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                16,
                22
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                22,
                32
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        },
        {
          "lessonId": "lesson-physics-scalars-and-vectors",
          "reason": "Component-wise net-force equations require vector addition and resolution.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                20,
                22
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                23,
                43
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-dynamics",
      "path": "content/lessons/science/physics/dynamics.md",
      "sha256": "5b3e6bbf7b9ef37561b9c92abdb8b231151dac11388ca175120e6f2b64d78143",
      "readLines": [
        1,
        142
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L080"
          ],
          "sharedCore": "Newton laws and force balance, Weight, normal force and tension, Static and kinetic friction",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Build and use a free-body diagram."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "sharedCore": "Newton laws and force balance, Weight, normal force and tension, Static and kinetic friction",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Build and use a free-body diagram."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L118"
          ],
          "sharedCore": "Newton laws and force balance, Weight, normal force and tension, Static and kinetic friction",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Build and use a free-body diagram."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L139"
          ],
          "sharedCore": "Newton laws and force balance, Weight, normal force and tension, Static and kinetic friction",
          "partialLimits": [
            "Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Build and use a free-body diagram."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162"
          ],
          "sharedCore": "Newton laws and force balance, Weight, normal force and tension, Static and kinetic friction",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Build and use a free-body diagram."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L117"
          ],
          "sharedCore": "Newton laws and force balance, Weight, normal force and tension, Static and kinetic friction",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Build and use a free-body diagram."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Distinguish electrical forces, circuit relationships and magnetic induction; apply the relevant model.",
      "skills": [
        {
          "name": "Electric charge foundation",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                14,
                18
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                70,
                78
              ],
              "note": "Distinct example evidence, thin as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Current physical meaning",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                28,
                34
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Voltage physical meaning",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                28,
                34
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Coulomb force",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                14,
                18
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                70,
                78
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": []
        },
        {
          "name": "Electric field",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                20,
                24
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        },
        {
          "name": "Ohm law",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                28,
                36
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                80,
                88
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": []
        },
        {
          "name": "Series equivalent resistance",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                40,
                44
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        },
        {
          "name": "Parallel equivalent resistance",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                46,
                50
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        },
        {
          "name": "Circuit open-path behavior",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                54,
                54
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                90,
                99
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": []
        },
        {
          "name": "Kirchhoff junction/loop use",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                50,
                50
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "No developed matching worked application"
          ]
        },
        {
          "name": "Magnetic poles",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                58,
                58
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "not-required",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": []
        },
        {
          "name": "Wire field and right-hand rule",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                60,
                60
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                101,
                109
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": []
        },
        {
          "name": "Flux and Faraday induction",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                62,
                66
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                111,
                120
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "Lenz direction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                66,
                66
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                111,
                120
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "Electrical safety/energy efficiency",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                10,
                66
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L083",
            "ustet-L124"
          ],
          "limitations": [
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        },
        {
          "name": "Generators and motors",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                56,
                66
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "pupcet-L119"
          ],
          "limitations": [
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        },
        {
          "name": "Charging mechanisms",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                12,
                24
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L054"
          ],
          "limitations": [
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "Electrostatic force, circuit calculations and induction are distinct tasks. Current/voltage are only symbols; magnetic flux appears without meaning or a non-calculus relationship.",
        "proposal": "Separate electrostatics, DC circuits, and magnetism/induction; keep shared charge/current foundations once and link them. Explain flux before induction; move Kirchhoff to a worked network extension.",
        "cost": "Reassign examples and dependencies across three focused units; add current/voltage/flux foundations and network computations. Exact exam need for additions remains unknown.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/electricity-and-magnetism.md",
            "lines": [
              10,
              66
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/electricity-and-magnetism.md",
            "lines": [
              58,
              128
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [],
      "prerequisiteStatus": "missing-foundation",
      "missingFoundations": [
        {
          "name": "Physical meanings of current and potential difference",
          "evidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                28,
                36
              ],
              "note": "Symbols are labeled with quantity names, but flow rate and energy per charge are not explained."
            }
          ],
          "corpusSearch": "Whole content/lessons search: current/charge-flow/potential-difference leads only to this lesson or base-unit names; no existing teaching target verified.",
          "reason": "Circuit equal-current/equal-voltage statements need meanings beyond substituting numbers.",
          "proposal": "Teach charge flow and voltage energy-per-charge before Ohm/circuit rules."
        },
        {
          "name": "Magnetic flux",
          "evidence": [
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                62,
                66
              ],
              "note": "Flux and its rate of change appear without physical meaning."
            },
            {
              "path": "content/lessons/science/physics/electricity-and-magnetism.md",
              "lines": [
                113,
                120
              ],
              "note": "Example repeats changing flux rather than developing it."
            }
          ],
          "corpusSearch": "Whole lesson corpus magnetic-flux search returned only this lesson.",
          "reason": "The central induction variable is undefined; no existing prerequisite lesson supplies it.",
          "proposal": "Teach field-through-area meaning before induction, using accessible change-over-time reasoning."
        }
      ],
      "figureDependencies": [],
      "id": "lesson-physics-electricity-and-magnetism",
      "path": "content/lessons/science/physics/electricity-and-magnetism.md",
      "sha256": "b4159dcc37ba0372ec43fae26008b1dc09c13342db47f3861b2d1f3ac31875fa",
      "readLines": [
        1,
        162
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L085"
          ],
          "sharedCore": "Coulomb force, Electric field, Ohm law, Series equivalent resistance, Parallel equivalent resistance, Circuit open-path behavior, Magnetic poles, Wire field and right-hand rule, Lenz direction",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Electric charge/current/voltage foundations, Kirchhoff junction/loop use, Flux and Faraday induction, Electrical safety/energy efficiency, Generators and motors, Charging mechanisms."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L054",
            "dost-sei-L100"
          ],
          "sharedCore": "Coulomb force, Electric field, Ohm law, Series equivalent resistance, Parallel equivalent resistance, Circuit open-path behavior, Magnetic poles, Wire field and right-hand rule, Lenz direction",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Electric charge/current/voltage foundations, Kirchhoff junction/loop use, Flux and Faraday induction, Electrical safety/energy efficiency, Generators and motors, Charging mechanisms."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L119"
          ],
          "sharedCore": "Coulomb force, Electric field, Ohm law, Series equivalent resistance, Parallel equivalent resistance, Circuit open-path behavior, Magnetic poles, Wire field and right-hand rule, Lenz direction",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Electric charge/current/voltage foundations, Kirchhoff junction/loop use, Flux and Faraday induction, Electrical safety/energy efficiency, Generators and motors, Charging mechanisms."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L150"
          ],
          "sharedCore": "Coulomb force, Electric field, Ohm law, Series equivalent resistance, Parallel equivalent resistance, Circuit open-path behavior, Magnetic poles, Wire field and right-hand rule, Lenz direction",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Electric charge/current/voltage foundations, Kirchhoff junction/loop use, Flux and Faraday induction, Electrical safety/energy efficiency, Generators and motors, Charging mechanisms."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L117"
          ],
          "sharedCore": "Coulomb force, Electric field, Ohm law, Series equivalent resistance, Parallel equivalent resistance, Circuit open-path behavior, Magnetic poles, Wire field and right-hand rule, Lenz direction",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Electric charge/current/voltage foundations, Kirchhoff junction/loop use, Flux and Faraday induction, Electrical safety/energy efficiency, Generators and motors, Charging mechanisms."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Use density and displaced-fluid weight to predict buoyancy; compare pressure in hydrostatic and ideal-flow models.",
      "skills": [
        {
          "name": "Density",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/fluid-mechanics.md",
              "lines": [
                14,
                18
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/fluid-mechanics.md",
              "lines": [
                52,
                58
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": []
        },
        {
          "name": "Pressure and depth",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/fluid-mechanics.md",
              "lines": [
                20,
                28
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        },
        {
          "name": "Buoyancy and force balance",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/fluid-mechanics.md",
              "lines": [
                30,
                36
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/fluid-mechanics.md",
              "lines": [
                60,
                84
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": []
        },
        {
          "name": "Bernoulli assumptions and comparison",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/fluid-mechanics.md",
              "lines": [
                40,
                48
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/fluid-mechanics.md",
              "lines": [
                86,
                100
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": []
        },
        {
          "name": "Pascal hydraulic systems",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/fluid-mechanics.md",
              "lines": [
                10,
                48
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L058"
          ],
          "limitations": [
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Density, pressure and buoyancy are a coherent fluid core. The ideal-flow extension is brief and clearly separated, not inherently crammed.",
        "proposal": "Retain pressure/buoyancy/ideal flow; add pressure/depth use. Mechanical fluid-pressure repeats hydrostatic/Bernoulli core and adds continuity, but neither develops Pascal hydraulic systems.",
        "cost": "One pressure application and a verified cross-topic connection; no split justified by unknown exam depth.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/fluid-mechanics.md",
            "lines": [
              10,
              48
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/fluid-mechanics.md",
            "lines": [
              50,
              142
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-fluid-mechanics",
      "path": "content/lessons/science/physics/fluid-mechanics.md",
      "sha256": "29446c078d4024ca5fc7ebeb6ee1e77e627c3cc96f5a61e44a55bf5e03fde54e",
      "readLines": [
        1,
        142
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L083"
          ],
          "sharedCore": "Density, Pressure and depth, Buoyancy and force balance, Bernoulli assumptions and comparison",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Pascal hydraulic systems."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "sharedCore": "Density, Pressure and depth, Buoyancy and force balance, Bernoulli assumptions and comparison",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Pascal hydraulic systems."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L150"
          ],
          "sharedCore": "Density, Pressure and depth, Buoyancy and force balance, Bernoulli assumptions and comparison",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Pascal hydraulic systems."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L124"
          ],
          "sharedCore": "Density, Pressure and depth, Buoyancy and force balance, Bernoulli assumptions and comparison",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Pascal hydraulic systems."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Predict gravitational-force changes and orbital speed/size relationships using Newton gravity and Kepler laws.",
      "skills": [
        {
          "name": "Universal gravity and inverse square",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
              "lines": [
                12,
                18
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
              "lines": [
                45,
                56
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "dost-sei-L107",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Kepler elliptical orbit and focus",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
              "lines": [
                24,
                26
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
              "lines": [
                94,
                102
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "dost-sei-L107",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Kepler equal areas and speed",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
              "lines": [
                28,
                28
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
              "lines": [
                58,
                68
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "dost-sei-L107",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Period and semimajor axis",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
              "lines": [
                30,
                40
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
              "lines": [
                71,
                92
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "dost-sei-L107",
            "sm-foundation-L141"
          ],
          "limitations": []
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Gravity and orbital patterns form a single explanatory goal with distinct examples. Historical context is short.",
        "proposal": "Retain; explain equal-area geometry in words before the speed deduction.",
        "cost": "Small local explanation; no new unit.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
            "lines": [
              10,
              40
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
            "lines": [
              45,
              92
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-gravity-and-keplers-laws",
      "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
      "sha256": "ed80b8265783868e3c102c30a29eebd98ad1c661f9306f5cae9e52214420f0fd",
      "readLines": [
        1,
        144
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L107"
          ],
          "sharedCore": "Universal gravity and inverse square, Elliptical orbits and equal areas, Period and semimajor axis",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L141"
          ],
          "sharedCore": "Universal gravity and inverse square, Elliptical orbits and equal areas, Period and semimajor axis",
          "partialLimits": [
            "Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope.",
            "Shared core can be reused as preparation; whole-lesson demand is not established."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope."
        }
      ]
    },
    {
      "goal": "Describe signed one-dimensional motion and choose an appropriate constant-acceleration or free-fall equation.",
      "skills": [
        {
          "name": "Position and displacement versus distance",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                16,
                20
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                71,
                77
              ],
              "note": "Distinct example evidence, thin as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "acet-L127",
            "ustet-L117",
            "ustet-L123",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Velocity versus speed",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                22,
                26
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                71,
                77
              ],
              "note": "Distinct example evidence, thin as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "acet-L127",
            "ustet-L117",
            "ustet-L123",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Acceleration as velocity change",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                28,
                32
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                65,
                69
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "acet-L127",
            "ustet-L117",
            "ustet-L123",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Constant-acceleration equation selection",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                35,
                49
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                65,
                99
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "acet-L127",
            "ustet-L117",
            "ustet-L123",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Signed ideal free fall",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                51,
                61
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                79,
                87
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "acet-L127",
            "ustet-L117",
            "ustet-L123",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Motion graph slope/area interpretation",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                109,
                109
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "acet-L127",
            "ustet-L117",
            "ustet-L123",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "reorder",
        "reason": "Graph interpretation is a curriculum-supported preparation facet but appears only as a shortcut after exclusively numerical equations.",
        "proposal": "Move graph meaning into core teaching; show slope/area interpretation and a reversal before graph-dependent use elsewhere.",
        "cost": "Add one coherent graph-reading sequence and worked application; keep one-dimensional motion together.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/kinematics.md",
            "lines": [
              10,
              109
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/kinematics.md",
            "lines": [
              63,
              99
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-kinematics",
      "path": "content/lessons/science/physics/kinematics.md",
      "sha256": "d361b219e492dab5c2091eedb687ccc9db77fd6840d7ebca21c56edfadd761c0",
      "readLines": [
        1,
        135
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L127"
          ],
          "sharedCore": "Position, displacement, speed/velocity and acceleration, Constant acceleration and free fall",
          "partialLimits": [
            "Science inclusion and General Knowledge meaning unconfirmed. Physics is background preparation, not a confirmed ACET Science component.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Motion graph slope/area interpretation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "uncertain",
          "reason": "Actual body supports the stated preparation facet. Science inclusion and General Knowledge meaning unconfirmed. Physics is background preparation, not a confirmed ACET Science component."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L080",
            "dcat-L082"
          ],
          "sharedCore": "Position, displacement, speed/velocity and acceleration, Constant acceleration and free fall",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Motion graph slope/area interpretation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "sharedCore": "Position, displacement, speed/velocity and acceleration, Constant acceleration and free fall",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Motion graph slope/area interpretation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L118",
            "pupcet-L123"
          ],
          "sharedCore": "Position, displacement, speed/velocity and acceleration, Constant acceleration and free fall",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Motion graph slope/area interpretation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "sharedCore": "Position, displacement, speed/velocity and acceleration, Constant acceleration and free fall",
          "partialLimits": [
            "Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Motion graph slope/area interpretation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162"
          ],
          "sharedCore": "Position, displacement, speed/velocity and acceleration, Constant acceleration and free fall",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Motion graph slope/area interpretation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L117",
            "ustet-L123"
          ],
          "sharedCore": "Position, displacement, speed/velocity and acceleration, Constant acceleration and free fall",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Motion graph slope/area interpretation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Explain reflection and refraction; classify optical devices and compare electromagnetic wavelengths.",
      "skills": [
        {
          "name": "Reflection and normal angles",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                14,
                18
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                68,
                76
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "pupcet-L123",
            "dost-sei-L104"
          ],
          "limitations": []
        },
        {
          "name": "Refraction and Snell law",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                22,
                32
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                96,
                104
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "pupcet-L123",
            "dost-sei-L104"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "Critical angle and total internal reflection",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                34,
                34
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L149",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "pupcet-L123",
            "dost-sei-L104"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "No developed matching worked application"
          ]
        },
        {
          "name": "Mirror/lens image formation",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                36,
                56
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                78,
                86
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "pupcet-L123",
            "dost-sei-L104"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "Electromagnetic spectrum",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                58,
                64
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                88,
                94
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "pupcet-L123",
            "dost-sei-L104"
          ],
          "limitations": []
        },
        {
          "name": "Optical instruments",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                36,
                56
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L149",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "pupcet-L123",
            "dost-sei-L104"
          ],
          "limitations": [
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Reflection/refraction and optical device behavior are coherent, but classification is substituted for constructing or predicting images.",
        "proposal": "Retain optics; develop image formation with object-position reasoning. Share wavelength/spectrum teaching with waves instead of maintaining two identical lists.",
        "cost": "Develop one image-formation sequence and relocate or cross-link duplicated spectrum core; exact quantitative depth remains unknown.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/light-and-optics.md",
            "lines": [
              10,
              64
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/light-and-optics.md",
            "lines": [
              66,
              104
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-physics-waves-and-sound",
          "reason": "Speed, frequency and wavelength changes at a boundary require the wave quantities and their relationship.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                26,
                32
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                14,
                26
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        },
        {
          "lessonId": "lesson-trigonometry-basic-trigonometric-ratios",
          "reason": "Snell law uses sine of a normal angle without defining sine.",
          "scope": "across-topics",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/light-and-optics.md",
              "lines": [
                28,
                30
              ],
              "note": "Trigonometric ratio enters the taught relationship."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
              "lines": [
                12,
                34
              ],
              "note": "Defines sine/cosine and special acute-angle values."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-light-and-optics",
      "path": "content/lessons/science/physics/light-and-optics.md",
      "sha256": "68b0ccd8ad91f138dad702578182cacd69c4dc0b6c941f012cf1a92480abee21",
      "readLines": [
        1,
        146
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L082",
            "dcat-L083"
          ],
          "sharedCore": "Reflection and normal angles, Refraction and Snell law, Electromagnetic spectrum",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Critical angle and total internal reflection, Mirror/lens image formation, Optical instruments."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L104"
          ],
          "sharedCore": "Reflection and normal angles, Refraction and Snell law, Electromagnetic spectrum",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Critical angle and total internal reflection, Mirror/lens image formation, Optical instruments."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L119",
            "pupcet-L123"
          ],
          "sharedCore": "Reflection and normal angles, Refraction and Snell law, Electromagnetic spectrum",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Critical angle and total internal reflection, Mirror/lens image formation, Optical instruments."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L149"
          ],
          "sharedCore": "Reflection and normal angles, Refraction and Snell law, Electromagnetic spectrum",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Critical angle and total internal reflection, Mirror/lens image formation, Optical instruments."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L117",
            "ustet-L123",
            "ustet-L124"
          ],
          "sharedCore": "Reflection and normal angles, Refraction and Snell law, Electromagnetic spectrum",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Critical angle and total internal reflection, Mirror/lens image formation, Optical instruments."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Use signed momentum and impulse, choose a system, and distinguish collision energy models.",
      "skills": [
        {
          "name": "Signed momentum",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                12,
                16
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                59,
                65
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L082",
            "ustet-L117",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Impulse and average force",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                18,
                32
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                67,
                75
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L082",
            "ustet-L117",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Conservation and system boundary",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                35,
                43
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                77,
                97
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L082",
            "ustet-L117",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Elastic/inelastic energy distinction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                45,
                55
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                85,
                89
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L082",
            "ustet-L117",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "Variable-force graph impulse",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                24,
                30
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L082",
            "ustet-L117",
            "pupcet-L118",
            "pupcet-L123",
            "dost-sei-L100",
            "dost-sei-L107",
            "sm-foundation-L139"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Impulse, system conservation and collision classification fit one goal. General integral notation lacks an area demonstration but does not warrant a separate lesson.",
        "proposal": "Retain; introduce graphical impulse before the integral and show kinetic-energy comparison once.",
        "cost": "Two targeted teaching/example additions; retain shared collision instruction.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/momentum-and-impulse.md",
            "lines": [
              10,
              55
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/momentum-and-impulse.md",
            "lines": [
              59,
              105
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-physics-kinematics",
          "reason": "Momentum-change calculations use signed initial/final velocity, not path speed.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                12,
                30
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                20,
                32
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        },
        {
          "lessonId": "lesson-physics-work-energy-power",
          "reason": "Elastic versus inelastic distinction assumes the meaning of kinetic energy and its difference from total energy.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/momentum-and-impulse.md",
              "lines": [
                45,
                53
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                20,
                40
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-momentum-and-impulse",
      "path": "content/lessons/science/physics/momentum-and-impulse.md",
      "sha256": "9963b76459d08bb8c2a9475e2b088c9752c0ce075a4ef9feccc545d85b08de7b",
      "readLines": [
        1,
        131
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "sharedCore": "Momentum and impulse, Conservation and system boundary, Elastic/inelastic energy distinction",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Variable-force graph impulse."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L118",
            "pupcet-L123"
          ],
          "sharedCore": "Momentum and impulse, Conservation and system boundary, Elastic/inelastic energy distinction",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Variable-force graph impulse."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L139"
          ],
          "sharedCore": "Momentum and impulse, Conservation and system boundary, Elastic/inelastic energy distinction",
          "partialLimits": [
            "Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Variable-force graph impulse."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162"
          ],
          "sharedCore": "Momentum and impulse, Conservation and system boundary, Elastic/inelastic energy distinction",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Variable-force graph impulse."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L117"
          ],
          "sharedCore": "Momentum and impulse, Conservation and system boundary, Elastic/inelastic energy distinction",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Variable-force graph impulse."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Distinguish scalars/vectors and combine signed or perpendicular components to describe physical quantities.",
      "skills": [
        {
          "name": "Scalar/vector distinction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                12,
                20
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                53,
                67
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L150"
          ],
          "limitations": []
        },
        {
          "name": "Signed/perpendicular vector addition",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                23,
                35
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                69,
                75
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L150"
          ],
          "limitations": []
        },
        {
          "name": "Component resolution and reconstruction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                37,
                49
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                78,
                95
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L150"
          ],
          "limitations": []
        },
        {
          "name": "General resultant direction and quadrant",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                49,
                49
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L150"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Classification, addition and resolution form one foundational sequence. The general tip-to-tail/direction method is stated but not demonstrated.",
        "proposal": "Keep a reusable foundation; add one multi-vector quadrant/direction construction rather than a separate vector unit.",
        "cost": "One applied reconstruction example; verification of math foundations required.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/scalars-and-vectors.md",
            "lines": [
              10,
              49
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/scalars-and-vectors.md",
            "lines": [
              51,
              97
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-trigonometry-basic-trigonometric-ratios",
          "reason": "Component resolution uses sine and cosine without defining those ratios.",
          "scope": "across-topics",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/scalars-and-vectors.md",
              "lines": [
                39,
                43
              ],
              "note": "Trigonometric ratio enters the taught relationship."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
              "lines": [
                12,
                34
              ],
              "note": "Defines sine/cosine and special acute-angle values."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-scalars-and-vectors",
      "path": "content/lessons/science/physics/scalars-and-vectors.md",
      "sha256": "a60360ce8730c373c2a4b566ab69b6442a29a66af2b464f1e0a8220e923a9ac0",
      "readLines": [
        1,
        130
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L150"
          ],
          "sharedCore": "Scalar/vector distinction, Signed/perpendicular vector addition, Component resolution and reconstruction",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: General resultant direction and quadrant."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        }
      ]
    },
    {
      "goal": "Distinguish heat-transfer mechanisms, apply sensible-heat relationships and interpret thermodynamic law statements.",
      "skills": [
        {
          "name": "Heat versus internal energy",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                12,
                14
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                108,
                112
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "Conduction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                20,
                20
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                54,
                64
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": []
        },
        {
          "name": "Convection",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                22,
                22
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                54,
                64
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": []
        },
        {
          "name": "Radiation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                24,
                24
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                54,
                64
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": []
        },
        {
          "name": "Zeroth law and thermal equilibrium",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                30,
                30
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                66,
                74
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "First law and work convention",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                32,
                36
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        },
        {
          "name": "Second law direction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                38,
                38
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                66,
                74
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": []
        },
        {
          "name": "Third law/entropy",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                40,
                40
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "No developed matching worked application"
          ]
        },
        {
          "name": "Specific heat calculation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                42,
                48
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                76,
                96
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": []
        },
        {
          "name": "Latent heat",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                50,
                50
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162",
            "dcat-L085",
            "ustet-L117",
            "pupcet-L119",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "No developed matching worked application"
          ]
        },
        {
          "name": "Controlled-variable comparison",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                84,
                96
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                84,
                96
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "dcat-L077",
            "acet-L126",
            "ustet-L113"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        }
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "Heat-transfer and calorimetry share direct applications; four-law/entropy statements add a different system-level task with only a second-law example.",
        "proposal": "Keep thermal transfer and calorimetry as common preparation; make first-law system work and thermodynamic-law reasoning an extension after energy/work foundations.",
        "cost": "Move law content and examples, add first-law work/sign example and latent-heat teaching if retained; exact required law depth is unknown.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/thermodynamics.md",
            "lines": [
              10,
              96
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/thermodynamics.md",
            "lines": [
              52,
              124
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-physics-work-energy-power",
          "reason": "First-law work accounting assumes the physical meaning of work as energy transfer.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/thermodynamics.md",
              "lines": [
                32,
                36
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                12,
                18
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-thermodynamics",
      "path": "content/lessons/science/physics/thermodynamics.md",
      "sha256": "2d386721a484964d7970488be939ceec003b6dac3a2d2a1bc95d6c1e86e2919c",
      "readLines": [
        1,
        136
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L085"
          ],
          "sharedCore": "Heat versus internal energy, Conduction, Convection, Radiation, First law and work convention, Second law direction, Specific heat calculation",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Zeroth law and thermal equilibrium, Third law/entropy, Latent heat, Controlled-variable comparison."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "sharedCore": "Heat versus internal energy, Conduction, Convection, Radiation, First law and work convention, Second law direction, Specific heat calculation",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Zeroth law and thermal equilibrium, Third law/entropy, Latent heat, Controlled-variable comparison."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L119"
          ],
          "sharedCore": "Heat versus internal energy, Conduction, Convection, Radiation, First law and work convention, Second law direction, Specific heat calculation",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Zeroth law and thermal equilibrium, Third law/entropy, Latent heat, Controlled-variable comparison."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L148",
            "upcat-L162"
          ],
          "sharedCore": "Heat versus internal energy, Conduction, Convection, Radiation, First law and work convention, Second law direction, Specific heat calculation",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Zeroth law and thermal equilibrium, Third law/entropy, Latent heat, Controlled-variable comparison."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L117"
          ],
          "sharedCore": "Heat versus internal energy, Conduction, Convection, Radiation, First law and work convention, Second law direction, Specific heat calculation",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Zeroth law and thermal equilibrium, Third law/entropy, Latent heat, Controlled-variable comparison."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Solve ideal projectile components and explain how real forces maintain uniform circular motion.",
      "skills": [
        {
          "name": "Projectile components and shared time",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                12,
                36
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                55,
                87
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "dcat-L083",
            "ustet-L124",
            "pupcet-L118",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": [
            "Launch axes and component equations are local. Sine/cosine meaning and 30-degree values are assumed, supplied by the direct trigonometric-ratios foundation. The wider vector lesson is optional preparation; this acute-angle link does not require full vector addition or quadrant reconstruction."
          ]
        },
        {
          "name": "Circular acceleration and radial force",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                39,
                51
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                89,
                107
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "dcat-L083",
            "ustet-L124",
            "pupcet-L118",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "Angular speed",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                43,
                43
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "dcat-L083",
            "ustet-L124",
            "pupcet-L118",
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "No developed matching worked application"
          ]
        },
        {
          "name": "Rotational motion",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                39,
                51
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L058"
          ],
          "limitations": [
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "Projectile calculations use signed kinematics and components; circular-force reasoning needs Newton force identification. The second task is currently qualitative despite formulas.",
        "proposal": "Keep projectile motion as kinematics application; make circular motion a force-based application after dynamics. Define angular speed if retaining it.",
        "cost": "Move circular core/examples and add one radial-force computation; avoid duplicating component teaching.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/two-dimensional-motion.md",
            "lines": [
              10,
              51
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/two-dimensional-motion.md",
            "lines": [
              53,
              107
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-physics-kinematics",
          "reason": "Projectile equations extend constant acceleration/free fall in each signed axis.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                16,
                28
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                35,
                59
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        },
        {
          "lessonId": "lesson-trigonometry-basic-trigonometric-ratios",
          "reason": "The angled-launch example evaluates sine/cosine of 30 degrees without defining those ratios or supplying their values. Basic trigonometric ratios teaches side-ratio meaning and the required special-angle values; the launch axes and component equations are already taught locally.",
          "scope": "across-topics",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                30,
                32
              ],
              "note": "Locally supplied component equations consume undefined sine/cosine functions."
            },
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                70,
                76
              ],
              "note": "Worked 30-degree launch uses unsupplied sine/cosine values to calculate components."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
              "lines": [
                12,
                34
              ],
              "note": "Defines side-relative sine/cosine ratios and gives30-degree values."
            },
            {
              "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
              "lines": [
                94,
                116
              ],
              "note": "Applies the 30-degree sine ratio to obtain a component-like opposite side from a hypotenuse."
            }
          ]
        },
        {
          "lessonId": "lesson-physics-dynamics",
          "reason": "Circular motion distinguishes real forces and their net radial component; dynamics identifies those forces.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                45,
                51
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/dynamics.md",
              "lines": [
                28,
                56
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [
        {
          "name": "Angular speed",
          "evidence": [
            {
              "path": "content/lessons/science/physics/two-dimensional-motion.md",
              "lines": [
                43,
                43
              ],
              "note": "Omega enters a circular acceleration formula without meaning, units or relationship."
            }
          ],
          "corpusSearch": "Whole lesson search also found gear-rotations lines 18-26 and 51-63; full read teaches tooth-count ratios, not angular displacement per time, units, or v=omega r. No foundation target verified.",
          "reason": "The omega-squared radius alternative cannot be understood from the local definitions.",
          "proposal": "Define angular speed locally if this formula is retained."
        }
      ],
      "figureDependencies": [],
      "id": "lesson-physics-two-dimensional-motion",
      "path": "content/lessons/science/physics/two-dimensional-motion.md",
      "sha256": "de82fab38cfee42169aa60c0c2358f845b2e3c654c1418b75bd875c3413115df",
      "readLines": [
        1,
        141
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L083"
          ],
          "sharedCore": "Projectile components and shared time, Circular acceleration and radial force",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Angular speed, Rotational motion."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L100",
            "dost-sei-L107"
          ],
          "sharedCore": "Projectile components and shared time, Circular acceleration and radial force",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Angular speed, Rotational motion."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L118"
          ],
          "sharedCore": "Projectile components and shared time, Circular acceleration and radial force",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Angular speed, Rotational motion."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L124"
          ],
          "sharedCore": "Projectile components and shared time, Circular acceleration and radial force",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Angular speed, Rotational motion."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "revise-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Identify SI base units, cancel conversion factors and check the dimensions of a physics expression.",
      "skills": [
        {
          "name": "SI base and derived units",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/units-and-measurements.md",
              "lines": [
                14,
                36
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/units-and-measurements.md",
              "lines": [
                84,
                97
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L190",
            "acet-L081",
            "ustet-L083",
            "ustet-L095",
            "pupcet-L091",
            "dost-sei-L126",
            "dost-sei-L136",
            "sm-foundation-L097"
          ],
          "limitations": []
        },
        {
          "name": "Simple/compound conversion",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/units-and-measurements.md",
              "lines": [
                38,
                42
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/units-and-measurements.md",
              "lines": [
                46,
                82
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L190",
            "acet-L081",
            "ustet-L083",
            "ustet-L095",
            "pupcet-L091",
            "dost-sei-L126",
            "dost-sei-L136",
            "sm-foundation-L097"
          ],
          "limitations": []
        },
        {
          "name": "Squared/cubed unit conversion",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/units-and-measurements.md",
              "lines": [
                121,
                125
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/units-and-measurements.md",
              "lines": [
                125,
                125
              ],
              "note": "Worked application evidence; limited as stated"
            }
          ],
          "requirementRefs": [
            "upcat-L190",
            "acet-L081",
            "ustet-L083",
            "ustet-L095",
            "pupcet-L091",
            "dost-sei-L126",
            "dost-sei-L136",
            "sm-foundation-L097"
          ],
          "limitations": [
            "Example only classifies, states a result, or omits the distinct application method; this is a structural L19 limit, not a standards pass."
          ]
        },
        {
          "name": "Measurement uncertainty",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/units-and-measurements.md",
              "lines": [
                10,
                42
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L190",
            "acet-L081",
            "ustet-L083",
            "ustet-L095",
            "pupcet-L091",
            "dost-sei-L126",
            "dost-sei-L136",
            "sm-foundation-L097"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Units, conversion and dimensional checks are one coherent foundation. Area/volume conversion is taught late as a trap instead of before use.",
        "proposal": "Retain a shared physics/math conversion foundation; move powered-unit conversion to core and demonstrate a volume conversion where needed.",
        "cost": "Small reordering and one applied powered-unit example; do not infer measurement uncertainty demand from title alone.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/units-and-measurements.md",
            "lines": [
              10,
              125
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/units-and-measurements.md",
            "lines": [
              44,
              125
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-units-and-measurements",
      "path": "content/lessons/science/physics/units-and-measurements.md",
      "sha256": "44f728ab41f7de68e1003b70273341b239b245b15bfa0ba7b54d936c454d89cc",
      "readLines": [
        1,
        125
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L081"
          ],
          "sharedCore": "SI base and derived units, Simple/compound conversion, Squared/cubed unit conversion",
          "partialLimits": [
            "Science inclusion and General Knowledge meaning unconfirmed. Physics is background preparation, not a confirmed ACET Science component.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Measurement uncertainty.",
            "Physical unit conversion is only a facet of broad measurement/solid-geometry/inquiry rows; SI names do not teach geometry or investigation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "uncertain",
          "reason": "Actual body supports the stated preparation facet. Science inclusion and General Knowledge meaning unconfirmed. Physics is background preparation, not a confirmed ACET Science component."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L037",
            "dcat-L077",
            "dcat-L080",
            "dcat-L085"
          ],
          "sharedCore": "SI base and derived units, Simple/compound conversion, Squared/cubed unit conversion",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Measurement uncertainty.",
            "Physical unit conversion is only a facet of broad measurement/solid-geometry/inquiry rows; SI names do not teach geometry or investigation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "uncertain",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L126",
            "dost-sei-L136"
          ],
          "sharedCore": "SI base and derived units, Simple/compound conversion, Squared/cubed unit conversion",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Measurement uncertainty.",
            "Physical unit conversion is only a facet of broad measurement/solid-geometry/inquiry rows; SI names do not teach geometry or investigation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L091"
          ],
          "sharedCore": "SI base and derived units, Simple/compound conversion, Squared/cubed unit conversion",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Measurement uncertainty.",
            "Physical unit conversion is only a facet of broad measurement/solid-geometry/inquiry rows; SI names do not teach geometry or investigation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L097"
          ],
          "sharedCore": "SI base and derived units, Simple/compound conversion, Squared/cubed unit conversion",
          "partialLimits": [
            "Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Measurement uncertainty.",
            "Physical unit conversion is only a facet of broad measurement/solid-geometry/inquiry rows; SI names do not teach geometry or investigation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L190"
          ],
          "sharedCore": "SI base and derived units, Simple/compound conversion, Squared/cubed unit conversion",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Measurement uncertainty.",
            "Physical unit conversion is only a facet of broad measurement/solid-geometry/inquiry rows; SI names do not teach geometry or investigation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L083",
            "ustet-L095"
          ],
          "sharedCore": "SI base and derived units, Simple/compound conversion, Squared/cubed unit conversion",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Measurement uncertainty.",
            "Physical unit conversion is only a facet of broad measurement/solid-geometry/inquiry rows; SI names do not teach geometry or investigation."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Relate wave speed, frequency and wavelength; classify wave types and explain moving-source Doppler pitch changes.",
      "skills": [
        {
          "name": "Wave properties and speed relation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                12,
                26
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                52,
                70
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "dost-sei-L104",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Mechanical versus electromagnetic waves",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                30,
                34
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                72,
                79
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "dost-sei-L104",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Transverse versus longitudinal waves",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                36,
                36
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "dost-sei-L104",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Sound speed, pitch and intensity",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                38,
                42
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                62,
                70
              ],
              "note": "Distinct example evidence, thin as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "dost-sei-L104",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": [
            "Physical meaning or distinct application is incomplete as indicated; no full standards judgment."
          ]
        },
        {
          "name": "Moving-source Doppler effect",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                44,
                48
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                81,
                92
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "dost-sei-L104",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": []
        },
        {
          "name": "Interference/diffraction",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                10,
                48
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L082",
            "dcat-L083",
            "ustet-L117",
            "ustet-L123",
            "ustet-L124",
            "pupcet-L119",
            "dost-sei-L104",
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "limitations": [
            "Local authored facet or extension; exact exam method/depth is unknown. A broad source row does not explicitly require this particular method.",
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        },
        {
          "name": "Electromagnetic wavelength ordering",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/waves-and-sound.md",
              "lines": [
                34,
                34
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "sm-foundation-L139"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Wave properties, sound and source-motion Doppler share one propagation goal. Spectrum ordering is taught in optics, so this lesson alone cannot claim that facet.",
        "proposal": "Retain; connect the existing spectrum order, and add wave-behavior teaching only where the conditional light-wave preparation requires it.",
        "cost": "A narrow existing-content connection; new interference/diffraction teaching would be extra authoring, not a cosmetic split.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/waves-and-sound.md",
            "lines": [
              10,
              48
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/waves-and-sound.md",
            "lines": [
              50,
              92
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-waves-and-sound",
      "path": "content/lessons/science/physics/waves-and-sound.md",
      "sha256": "247aacf5ee3245aba46104dbd0f39895cff78827aec8f7de34c019232eeb3bdd",
      "readLines": [
        1,
        132
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L080",
            "dcat-L082",
            "dcat-L083"
          ],
          "sharedCore": "Wave properties and speed relation, Mechanical/EM and transverse/longitudinal distinction, Sound and Doppler effect",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Interference/diffraction, Electromagnetic wavelength ordering."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L119"
          ],
          "sharedCore": "Wave properties and speed relation, Mechanical/EM and transverse/longitudinal distinction, Sound and Doppler effect",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Interference/diffraction, Electromagnetic wavelength ordering."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L139",
            "sm-foundation-L141"
          ],
          "sharedCore": "Wave properties and speed relation, Mechanical/EM and transverse/longitudinal distinction, Sound and Doppler effect",
          "partialLimits": [
            "Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Interference/diffraction, Electromagnetic wavelength ordering."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L149",
            "upcat-L162"
          ],
          "sharedCore": "Wave properties and speed relation, Mechanical/EM and transverse/longitudinal distinction, Sound and Doppler effect",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Interference/diffraction, Electromagnetic wavelength ordering."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L117",
            "ustet-L123",
            "ustet-L124"
          ],
          "sharedCore": "Wave properties and speed relation, Mechanical/EM and transverse/longitudinal distinction, Sound and Doppler effect",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Interference/diffraction, Electromagnetic wavelength ordering."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    },
    {
      "goal": "Calculate kinetic/potential energy and power; distinguish mechanical energy conservation from total energy conservation.",
      "skills": [
        {
          "name": "Constant-force work",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                12,
                18
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L083",
            "acet-L127",
            "ustet-L117",
            "ustet-L124",
            "pupcet-L118",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L108",
            "sm-foundation-L139"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        },
        {
          "name": "Work-energy theorem",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                32,
                36
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L083",
            "acet-L127",
            "ustet-L117",
            "ustet-L124",
            "pupcet-L118",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L108",
            "sm-foundation-L139"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        },
        {
          "name": "Kinetic energy",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                22,
                24
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                62,
                79
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L083",
            "acet-L127",
            "ustet-L117",
            "ustet-L124",
            "pupcet-L118",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L108",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Near-Earth potential energy",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                26,
                30
              ],
              "note": "Distinct local teaching facet; see structural limitations."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                81,
                94
              ],
              "note": "Distinct example evidence, worked as qualified."
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L083",
            "acet-L127",
            "ustet-L117",
            "ustet-L124",
            "pupcet-L118",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L108",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Mechanical energy conservation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                38,
                42
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                96,
                125
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L083",
            "acet-L127",
            "ustet-L117",
            "ustet-L124",
            "pupcet-L118",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L108",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Nonconservative work accounting",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                44,
                48
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L083",
            "acet-L127",
            "ustet-L117",
            "ustet-L124",
            "pupcet-L118",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L108",
            "sm-foundation-L139"
          ],
          "limitations": [
            "No developed matching worked application"
          ]
        },
        {
          "name": "Average power",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                52,
                58
              ],
              "note": "Local explanation supporting the stated teaching verdict."
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                127,
                140
              ],
              "note": "Worked application evidence; solving or explanatory steps shown"
            }
          ],
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L162",
            "dcat-L080",
            "dcat-L083",
            "acet-L127",
            "ustet-L117",
            "ustet-L124",
            "pupcet-L118",
            "pupcet-L119",
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L108",
            "sm-foundation-L139"
          ],
          "limitations": []
        },
        {
          "name": "Machine efficiency",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                52,
                58
              ],
              "note": "Full local core/example search supports absence for this named facet."
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L083",
            "ustet-L124"
          ],
          "limitations": [
            "Absent in this physics lesson full body; see scoped search/cross-topic notes before treating it as a corpus gap.",
            "No developed matching worked application"
          ]
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Work, mechanical energy and power share a transfer/accounting goal. Named work-energy and friction accounting have no worked application.",
        "proposal": "Retain; add angle/net-work and nonconservative-work application. Pulleys-and-levers develops ideal mechanical advantage, but not a quantitative efficiency relationship; share that foundation before any new efficiency teaching.",
        "cost": "Two distinct applications plus existing-content connection; no split solely for example breadth.",
        "evidence": [
          {
            "path": "content/lessons/science/physics/work-energy-power.md",
            "lines": [
              10,
              58
            ],
            "note": "Core concepts and foundations used for focus/split finding."
          },
          {
            "path": "content/lessons/science/physics/work-energy-power.md",
            "lines": [
              60,
              140
            ],
            "note": "Applications supporting the teaching/structure finding."
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-physics-kinematics",
          "reason": "Work uses displacement and kinetic energy uses speed; these quantities must be distinguished from path distance and signed velocity.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                12,
                24
              ],
              "note": "Consumer uses this foundation without developing it."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/science/physics/kinematics.md",
              "lines": [
                14,
                26
              ],
              "note": "Foundation explains the quantity or method used."
            }
          ]
        },
        {
          "lessonId": "lesson-trigonometry-basic-trigonometric-ratios",
          "reason": "Angled-force work uses cosine without defining the projection ratio.",
          "scope": "across-topics",
          "consumerEvidence": [
            {
              "path": "content/lessons/science/physics/work-energy-power.md",
              "lines": [
                14,
                16
              ],
              "note": "Trigonometric ratio enters the taught relationship."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
              "lines": [
                12,
                34
              ],
              "note": "Defines sine/cosine and special acute-angle values."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-physics-work-energy-power",
      "path": "content/lessons/science/physics/work-energy-power.md",
      "sha256": "7ccf85aaf50d3657eeb27b94f9255c278c9802a78b215f571651288414b9fb60",
      "readLines": [
        1,
        182
      ],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5",
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L127"
          ],
          "sharedCore": "Constant-force work, Work-energy theorem, Kinetic and potential energy, Mechanical energy conservation, Nonconservative work accounting, Average power",
          "partialLimits": [
            "Science inclusion and General Knowledge meaning unconfirmed. Physics is background preparation, not a confirmed ACET Science component.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Machine efficiency.",
            "Biological cellular/ecosystem/geothermal energy rows do not establish those topics from generic mechanical-energy teaching; do not count those original broad candidate edges as supplied physics coverage."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "uncertain",
          "reason": "Actual body supports the stated preparation facet. Science inclusion and General Knowledge meaning unconfirmed. Physics is background preparation, not a confirmed ACET Science component."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L080",
            "dcat-L083"
          ],
          "sharedCore": "Constant-force work, Work-energy theorem, Kinetic and potential energy, Mechanical energy conservation, Nonconservative work accounting, Average power",
          "partialLimits": [
            "Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Machine efficiency.",
            "Biological cellular/ecosystem/geothermal energy rows do not establish those topics from generic mechanical-energy teaching; do not count those original broad candidate edges as supplied physics coverage."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster/languages unknown; 2025 recollections weak. JHS/legacy SHS/strengthened-SHS records remain conditional preparation."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L054",
            "dost-sei-L100",
            "dost-sei-L108"
          ],
          "sharedCore": "Constant-force work, Work-energy theorem, Kinetic and potential energy, Mechanical energy conservation, Nonconservative work accounting, Average power",
          "partialLimits": [
            "Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Machine efficiency.",
            "Biological cellular/ecosystem/geothermal energy rows do not establish those topics from generic mechanical-energy teaching; do not count those original broad candidate edges as supplied physics coverage."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Physics/mechanical domains are official for the 2026 primer; 2027 continuity and method depth unknown. STEM Physics and strengthened-SHS preparation are cohort/completion conditional."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L118",
            "pupcet-L119"
          ],
          "sharedCore": "Constant-force work, Work-energy theorem, Kinetic and potential energy, Mechanical energy conservation, Nonconservative work accounting, Average power",
          "partialLimits": [
            "Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Machine efficiency.",
            "Biological cellular/ecosystem/geothermal energy rows do not establish those topics from generic mechanical-energy teaching; do not count those original broad candidate edges as supplied physics coverage."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current named academic roster/depth/languages unconfirmed; curriculum preparation does not become a PUPCET blueprint."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L139"
          ],
          "sharedCore": "Constant-force work, Work-energy theorem, Kinetic and potential energy, Mechanical energy conservation, Nonconservative work accounting, Average power",
          "partialLimits": [
            "Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Machine efficiency.",
            "Biological cellular/ecosystem/geothermal energy rows do not establish those topics from generic mechanical-energy teaching; do not count those original broad candidate edges as supplied physics coverage."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current academic roster, standalone Science, languages and depth unknown; curriculum/weak historical/advice leads do not confirm SM scope."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L148",
            "upcat-L149",
            "upcat-L162"
          ],
          "sharedCore": "Constant-force work, Work-energy theorem, Kinetic and potential energy, Mechanical energy conservation, Nonconservative work accounting, Average power",
          "partialLimits": [
            "Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Machine efficiency.",
            "Biological cellular/ecosystem/geothermal energy rows do not establish those topics from generic mechanical-energy teaching; do not count those original broad candidate edges as supplied physics coverage."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Official current broad Science/Mathematics only; local physics details use curriculum preparation or weak reviewer leads. Science/Math item languages and quantitative depth unknown."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L117",
            "ustet-L124"
          ],
          "sharedCore": "Constant-force work, Work-energy theorem, Kinetic and potential energy, Mechanical energy conservation, Nonconservative work accounting, Average power",
          "partialLimits": [
            "Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain.",
            "Shared core can be reused as preparation; whole-lesson demand is not established.",
            "Incomplete or absent local facets: Machine efficiency.",
            "Biological cellular/ecosystem/geothermal energy rows do not establish those topics from generic mechanical-energy teaching; do not count those original broad candidate edges as supplied physics coverage."
          ],
          "depth": "unknown: exact current tested method/quantitative depth is unverified",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual body supports the stated preparation facet. Current broad Science confirmed, detailed depth/item languages unknown. SHS track/completion and strengthened pilot-version conditions remain."
        }
      ]
    }
  ],
  "requirementFacets": [
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L054",
        "dost-sei-L100",
        "sm-foundation-L139"
      ],
      "facet": "Static and kinetic friction",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            40,
            52
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            86,
            95
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L054",
        "dost-sei-L100",
        "sm-foundation-L139"
      ],
      "facet": "Build and use a free-body diagram",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            54,
            56
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            97,
            109
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "Build and use a free-body diagram needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Coulomb force",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            14,
            18
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            70,
            78
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Electric field",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            20,
            24
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Ohm law",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            28,
            36
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            80,
            88
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Series equivalent resistance",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            40,
            44
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Parallel equivalent resistance",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            46,
            50
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Circuit open-path behavior",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            54,
            54
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            90,
            99
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Kirchhoff junction/loop use",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            50,
            50
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "Kirchhoff junction/loop use needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Magnetic poles",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            58,
            58
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "not-required",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Wire field and right-hand rule",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            60,
            60
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            101,
            109
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Flux and Faraday induction",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            62,
            66
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            111,
            120
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "Flux and Faraday induction needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Lenz direction",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            66,
            66
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            111,
            120
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124"
      ],
      "facet": "Electrical safety/energy efficiency",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            10,
            66
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Electrical safety/energy efficiency needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "pupcet-L119"
      ],
      "facet": "Generators and motors",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            56,
            66
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Generators and motors needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dost-sei-L054"
      ],
      "facet": "Charging mechanisms",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            12,
            24
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Charging mechanisms needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Density",
      "lessonIds": [
        "lesson-physics-fluid-mechanics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            14,
            18
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            52,
            58
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Mass, volume, force and area vocabulary; density/pressure definitions and buoyancy force balance are supplied locally. The current buoyant-force example shows 300 g = 0.3 kg and the mg/newton calculation. General SI, dimensional checks and prefix interpretation are useful optional preparation, not a strict existing-lesson dependency for these supplied tasks.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Pressure and depth",
      "lessonIds": [
        "lesson-physics-fluid-mechanics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            20,
            28
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Mass, volume, force and area vocabulary; density/pressure definitions and buoyancy force balance are supplied locally. The current buoyant-force example shows 300 g = 0.3 kg and the mg/newton calculation. General SI, dimensional checks and prefix interpretation are useful optional preparation, not a strict existing-lesson dependency for these supplied tasks.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Buoyancy and force balance",
      "lessonIds": [
        "lesson-physics-fluid-mechanics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            30,
            36
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            60,
            84
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Mass, volume, force and area vocabulary; density/pressure definitions and buoyancy force balance are supplied locally. The current buoyant-force example shows 300 g = 0.3 kg and the mg/newton calculation. General SI, dimensional checks and prefix interpretation are useful optional preparation, not a strict existing-lesson dependency for these supplied tasks.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Bernoulli assumptions and comparison",
      "lessonIds": [
        "lesson-physics-fluid-mechanics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            40,
            48
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            86,
            100
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Mass, volume, force and area vocabulary; density/pressure definitions and buoyancy force balance are supplied locally. The current buoyant-force example shows 300 g = 0.3 kg and the mg/newton calculation. General SI, dimensional checks and prefix interpretation are useful optional preparation, not a strict existing-lesson dependency for these supplied tasks.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058"
      ],
      "facet": "Pascal hydraulic systems",
      "lessonIds": [
        "lesson-physics-fluid-mechanics"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            10,
            48
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Pascal hydraulic systems needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Mass, volume, force and area vocabulary; density/pressure definitions and buoyancy force balance are supplied locally. The current buoyant-force example shows 300 g = 0.3 kg and the mg/newton calculation. General SI, dimensional checks and prefix interpretation are useful optional preparation, not a strict existing-lesson dependency for these supplied tasks.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dost-sei-L107",
        "sm-foundation-L141"
      ],
      "facet": "Universal gravity and inverse square",
      "lessonIds": [
        "lesson-physics-gravity-and-keplers-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
          "lines": [
            12,
            18
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
          "lines": [
            45,
            56
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Ratios, inverse square, cube root; ellipse geometry/area reasoning. Semimajor axis and perihelion/aphelion are defined locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dost-sei-L107",
        "sm-foundation-L141"
      ],
      "facet": "Period and semimajor axis",
      "lessonIds": [
        "lesson-physics-gravity-and-keplers-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
          "lines": [
            30,
            40
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
          "lines": [
            71,
            92
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Ratios, inverse square, cube root; ellipse geometry/area reasoning. Semimajor axis and perihelion/aphelion are defined locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "acet-L127",
        "ustet-L117",
        "ustet-L123",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Motion graph slope/area interpretation",
      "lessonIds": [
        "lesson-physics-kinematics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            109,
            109
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "Motion graph slope/area interpretation needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Arithmetic, substitution and roots; origin/sign convention taught locally.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "pupcet-L123",
        "dost-sei-L104"
      ],
      "facet": "Reflection and normal angles",
      "lessonIds": [
        "lesson-physics-light-and-optics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            14,
            18
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            68,
            76
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Normal/perpendicular geometry, sine for Snell law; wave speed/frequency/wavelength meanings.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "pupcet-L123",
        "dost-sei-L104"
      ],
      "facet": "Refraction and Snell law",
      "lessonIds": [
        "lesson-physics-light-and-optics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            22,
            32
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            96,
            104
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Normal/perpendicular geometry, sine for Snell law; wave speed/frequency/wavelength meanings.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "pupcet-L123",
        "dost-sei-L104"
      ],
      "facet": "Critical angle and total internal reflection",
      "lessonIds": [
        "lesson-physics-light-and-optics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            34,
            34
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "Critical angle and total internal reflection needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Normal/perpendicular geometry, sine for Snell law; wave speed/frequency/wavelength meanings.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "pupcet-L123",
        "dost-sei-L104"
      ],
      "facet": "Mirror/lens image formation",
      "lessonIds": [
        "lesson-physics-light-and-optics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            36,
            56
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            78,
            86
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "Mirror/lens image formation needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Normal/perpendicular geometry, sine for Snell law; wave speed/frequency/wavelength meanings.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "pupcet-L123",
        "dost-sei-L104"
      ],
      "facet": "Electromagnetic spectrum",
      "lessonIds": [
        "lesson-physics-light-and-optics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            58,
            64
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            88,
            94
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Normal/perpendicular geometry, sine for Snell law; wave speed/frequency/wavelength meanings.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "pupcet-L123",
        "dost-sei-L104"
      ],
      "facet": "Optical instruments",
      "lessonIds": [
        "lesson-physics-light-and-optics"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/light-and-optics.md",
          "lines": [
            36,
            56
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Optical instruments needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Normal/perpendicular geometry, sine for Snell law; wave speed/frequency/wavelength meanings.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L082",
        "ustet-L117",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139"
      ],
      "facet": "Conservation and system boundary",
      "lessonIds": [
        "lesson-physics-momentum-and-impulse"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            35,
            43
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            77,
            97
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Signed velocity, kinetic versus total energy, chosen system boundary. Integral is not needed for its constant/average-force examples.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L082",
        "ustet-L117",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139"
      ],
      "facet": "Elastic/inelastic energy distinction",
      "lessonIds": [
        "lesson-physics-momentum-and-impulse"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            45,
            55
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            85,
            89
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Signed velocity, kinetic versus total energy, chosen system boundary. Integral is not needed for its constant/average-force examples.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L082",
        "ustet-L117",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139"
      ],
      "facet": "Variable-force graph impulse",
      "lessonIds": [
        "lesson-physics-momentum-and-impulse"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            24,
            30
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "Variable-force graph impulse needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Signed velocity, kinetic versus total energy, chosen system boundary. Integral is not needed for its constant/average-force examples.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150"
      ],
      "facet": "Scalar/vector distinction",
      "lessonIds": [
        "lesson-physics-scalars-and-vectors"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/scalars-and-vectors.md",
          "lines": [
            12,
            20
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/scalars-and-vectors.md",
          "lines": [
            53,
            67
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Right-triangle sine/cosine and Pythagorean magnitude; general quadrant direction needs more than the displayed acute-angle example.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150"
      ],
      "facet": "Signed/perpendicular vector addition",
      "lessonIds": [
        "lesson-physics-scalars-and-vectors"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/scalars-and-vectors.md",
          "lines": [
            23,
            35
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/scalars-and-vectors.md",
          "lines": [
            69,
            75
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Right-triangle sine/cosine and Pythagorean magnitude; general quadrant direction needs more than the displayed acute-angle example.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150"
      ],
      "facet": "Component resolution and reconstruction",
      "lessonIds": [
        "lesson-physics-scalars-and-vectors"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/scalars-and-vectors.md",
          "lines": [
            37,
            49
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/scalars-and-vectors.md",
          "lines": [
            78,
            95
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Right-triangle sine/cosine and Pythagorean magnitude; general quadrant direction needs more than the displayed acute-angle example.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150"
      ],
      "facet": "General resultant direction and quadrant",
      "lessonIds": [
        "lesson-physics-scalars-and-vectors"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/scalars-and-vectors.md",
          "lines": [
            49,
            49
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "General resultant direction and quadrant needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Right-triangle sine/cosine and Pythagorean magnitude; general quadrant direction needs more than the displayed acute-angle example.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Heat versus internal energy",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            12,
            14
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            108,
            112
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Conduction",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            20,
            20
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            54,
            64
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Convection",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            22,
            22
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            54,
            64
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Radiation",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            24,
            24
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            54,
            64
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Zeroth law and thermal equilibrium",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            30,
            30
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            66,
            74
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "Zeroth law and thermal equilibrium needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "First law and work convention",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            32,
            36
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Second law direction",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            38,
            38
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            66,
            74
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Third law/entropy",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            40,
            40
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "Third law/entropy needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Specific heat calculation",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            42,
            48
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            76,
            96
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Latent heat",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            50,
            50
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "Latent heat needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dcat-L077",
        "acet-L126",
        "ustet-L113"
      ],
      "facet": "Controlled-variable comparison",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            84,
            96
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            84,
            96
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "Controlled-variable comparison needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Energy transfer, work, mass and temperature change.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "dcat-L083",
        "ustet-L124",
        "pupcet-L118",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Projectile components and shared time",
      "lessonIds": [
        "lesson-physics-two-dimensional-motion"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/two-dimensional-motion.md",
          "lines": [
            12,
            36
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/two-dimensional-motion.md",
          "lines": [
            55,
            87
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [
        "Launch axes and component equations are local. Sine/cosine meaning and 30-degree values are assumed, supplied by the direct trigonometric-ratios foundation. The wider vector lesson is optional preparation; this acute-angle link does not require full vector addition or quadrant reconstruction."
      ],
      "priorKnowledge": "Constant acceleration/free fall and real-force identification remain supported lesson prerequisites. Angled-launch sine/cosine meaning and 30-degree values require direct basic-trigonometric-ratios teaching; axes and launch-component equations are local. The vector lesson is optional preparation, not a strict prerequisite. The direct trigonometric foundation applies to the angled-launch facet only.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "dcat-L083",
        "ustet-L124",
        "pupcet-L118",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Circular acceleration and radial force",
      "lessonIds": [
        "lesson-physics-two-dimensional-motion"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/two-dimensional-motion.md",
          "lines": [
            39,
            51
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/two-dimensional-motion.md",
          "lines": [
            89,
            107
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Constant acceleration/free fall and real-force identification remain supported lesson prerequisites. Angled-launch sine/cosine meaning and 30-degree values require direct basic-trigonometric-ratios teaching; axes and launch-component equations are local. The vector lesson is optional preparation, not a strict prerequisite. The direct trigonometric foundation applies to the angled-launch facet only.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "dcat-L083",
        "ustet-L124",
        "pupcet-L118",
        "dost-sei-L100",
        "dost-sei-L107"
      ],
      "facet": "Angular speed",
      "lessonIds": [
        "lesson-physics-two-dimensional-motion"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/physics/two-dimensional-motion.md",
          "lines": [
            43,
            43
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "Angular speed needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Constant acceleration/free fall and real-force identification remain supported lesson prerequisites. Angled-launch sine/cosine meaning and 30-degree values require direct basic-trigonometric-ratios teaching; axes and launch-component equations are local. The vector lesson is optional preparation, not a strict prerequisite. The direct trigonometric foundation applies to the angled-launch facet only.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058"
      ],
      "facet": "Rotational motion",
      "lessonIds": [
        "lesson-physics-two-dimensional-motion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/two-dimensional-motion.md",
          "lines": [
            39,
            51
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Rotational motion needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Constant acceleration/free fall and real-force identification remain supported lesson prerequisites. Angled-launch sine/cosine meaning and 30-degree values require direct basic-trigonometric-ratios teaching; axes and launch-component equations are local. The vector lesson is optional preparation, not a strict prerequisite. The direct trigonometric foundation applies to the angled-launch facet only.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L190",
        "acet-L081",
        "ustet-L083",
        "ustet-L095",
        "pupcet-L091",
        "dost-sei-L126",
        "dost-sei-L136",
        "sm-foundation-L097"
      ],
      "facet": "SI base and derived units",
      "lessonIds": [
        "lesson-physics-units-and-measurements"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/units-and-measurements.md",
          "lines": [
            14,
            36
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/units-and-measurements.md",
          "lines": [
            84,
            97
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Fractions, decimal division and exponents; factor cancellation is taught locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L190",
        "acet-L081",
        "ustet-L083",
        "ustet-L095",
        "pupcet-L091",
        "dost-sei-L126",
        "dost-sei-L136",
        "sm-foundation-L097"
      ],
      "facet": "Simple/compound conversion",
      "lessonIds": [
        "lesson-physics-units-and-measurements"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/units-and-measurements.md",
          "lines": [
            38,
            42
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/units-and-measurements.md",
          "lines": [
            46,
            82
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Fractions, decimal division and exponents; factor cancellation is taught locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L190",
        "acet-L081",
        "ustet-L083",
        "ustet-L095",
        "pupcet-L091",
        "dost-sei-L126",
        "dost-sei-L136",
        "sm-foundation-L097"
      ],
      "facet": "Squared/cubed unit conversion",
      "lessonIds": [
        "lesson-physics-units-and-measurements"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/units-and-measurements.md",
          "lines": [
            121,
            125
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/units-and-measurements.md",
          "lines": [
            125,
            125
          ],
          "note": "Worked application evidence; limited as stated"
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Fractions, decimal division and exponents; factor cancellation is taught locally.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L190",
        "acet-L081",
        "ustet-L083",
        "ustet-L095",
        "pupcet-L091",
        "dost-sei-L126",
        "dost-sei-L136",
        "sm-foundation-L097"
      ],
      "facet": "Measurement uncertainty",
      "lessonIds": [
        "lesson-physics-units-and-measurements"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/units-and-measurements.md",
          "lines": [
            10,
            42
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Measurement uncertainty needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Fractions, decimal division and exponents; factor cancellation is taught locally.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "dost-sei-L104",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Wave properties and speed relation",
      "lessonIds": [
        "lesson-physics-waves-and-sound"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            12,
            26
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            52,
            70
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Ratio arithmetic; oscillation/cycle and medium distinctions developed locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "dost-sei-L104",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Interference/diffraction",
      "lessonIds": [
        "lesson-physics-waves-and-sound"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            10,
            48
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Interference/diffraction needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Ratio arithmetic; oscillation/cycle and medium distinctions developed locally.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Authored extension, exact required depth unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "sm-foundation-L139"
      ],
      "facet": "Electromagnetic wavelength ordering",
      "lessonIds": [
        "lesson-physics-waves-and-sound"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            34,
            34
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "Electromagnetic wavelength ordering needs local development before full facet teaching can be claimed.",
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Ratio arithmetic; oscillation/cycle and medium distinctions developed locally.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L083",
        "acet-L127",
        "ustet-L117",
        "ustet-L124",
        "pupcet-L118",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L108",
        "sm-foundation-L139"
      ],
      "facet": "Constant-force work",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            12,
            18
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Displacement versus path length, speed, cosine projection and algebraic rearrangement.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L083",
        "acet-L127",
        "ustet-L117",
        "ustet-L124",
        "pupcet-L118",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L108",
        "sm-foundation-L139"
      ],
      "facet": "Work-energy theorem",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            32,
            36
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Displacement versus path length, speed, cosine projection and algebraic rearrangement.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L083",
        "acet-L127",
        "ustet-L117",
        "ustet-L124",
        "pupcet-L118",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L108",
        "sm-foundation-L139"
      ],
      "facet": "Mechanical energy conservation",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            38,
            42
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            96,
            125
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Displacement versus path length, speed, cosine projection and algebraic rearrangement.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L083",
        "acet-L127",
        "ustet-L117",
        "ustet-L124",
        "pupcet-L118",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L108",
        "sm-foundation-L139"
      ],
      "facet": "Nonconservative work accounting",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            44,
            48
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        }
      ],
      "missingIdeas": [
        "The distinct application needs a worked demonstration where solving is required."
      ],
      "priorKnowledge": "Displacement versus path length, speed, cosine projection and algebraic rearrangement.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L083",
        "acet-L127",
        "ustet-L117",
        "ustet-L124",
        "pupcet-L118",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L108",
        "sm-foundation-L139"
      ],
      "facet": "Average power",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            52,
            58
          ],
          "note": "Local explanation supporting the stated teaching verdict."
        },
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            127,
            140
          ],
          "note": "Worked application evidence; solving or explanatory steps shown"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Displacement versus path length, speed, cosine projection and algebraic rearrangement.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124"
      ],
      "facet": "Machine efficiency",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            52,
            58
          ],
          "note": "Full local core/example search supports absence for this named facet."
        }
      ],
      "missingIdeas": [
        "Machine efficiency needs local development before full facet teaching can be claimed."
      ],
      "priorKnowledge": "Displacement versus path length, speed, cosine projection and algebraic rearrangement.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dcat-L077",
        "acet-L126",
        "ustet-L113"
      ],
      "facet": "Identify investigative variables and controls",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            84,
            96
          ],
          "note": "Equal Q/m are held fixed, but independent/dependent/controlled variables and experimental controls are not taught."
        }
      ],
      "missingIdeas": [
        "No investigation-design teaching in the 13 full physics bodies. A controlled comparison is not a variables/controls method."
      ],
      "priorKnowledge": "Relevant model meanings; no authored-order assumption.",
      "workedExamples": "thin or none as noted in evidence",
      "scopeLimit": "Local physics absence; whole-corpus search found no explicit variable-type teaching, but lead must reconcile other topic reads. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dcat-L077",
        "acet-L126",
        "ustet-L113"
      ],
      "facet": "Draw evidence-based scientific conclusions",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            84,
            96
          ],
          "note": "A model-based equal-mass/heat comparison derives a conclusion, without measured observations, competing claims or evidence-quality analysis."
        }
      ],
      "missingIdeas": [
        "Develop a scientific evidence-to-conclusion investigation example."
      ],
      "priorKnowledge": "Relevant model meanings; no authored-order assumption.",
      "workedExamples": "thin or none as noted in evidence",
      "scopeLimit": "Local inference is present, investigation reasoning remains thin; curriculum-supported preparation, current exam demand unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "ustet-L113",
        "upcat-L162",
        "dcat-L082",
        "pupcet-L118",
        "dost-sei-L107",
        "sm-foundation-L139"
      ],
      "facet": "Read data and representations in scientific inquiry",
      "lessonIds": [
        "lesson-physics-kinematics",
        "lesson-physics-units-and-measurements"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            109,
            109
          ],
          "note": "Motion slope/area facts stated only as a shortcut; no plotted measured-data interpretation."
        },
        {
          "path": "content/lessons/science/physics/units-and-measurements.md",
          "lines": [
            84,
            97
          ],
          "note": "Dimensions of a given model are checked, not observational data."
        }
      ],
      "missingIdeas": [
        "Teach and apply graph slope/area before interpreting motion data."
      ],
      "priorKnowledge": "Relevant model meanings; no authored-order assumption.",
      "workedExamples": "thin or none as noted in evidence",
      "scopeLimit": "Physics graph facet only, not full investigation or all non-linear representations. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150"
      ],
      "facet": "Relative motion/reference frames beyond Doppler",
      "lessonIds": [
        "lesson-physics-dynamics",
        "lesson-physics-waves-and-sound"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            12,
            12
          ],
          "note": "Inertial reference frames named without a taught comparison."
        },
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            44,
            48
          ],
          "note": "Relative source/observer motion appears for sound only."
        }
      ],
      "missingIdeas": [
        "No relative-velocity frame transformation application in the 13 full physics bodies."
      ],
      "priorKnowledge": "Relevant model meanings; no authored-order assumption.",
      "workedExamples": "thin or none as noted in evidence",
      "scopeLimit": "Weak UPCAT reviewer lead; Doppler is only a partial relative-motion use, exact test demand unknown. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L150"
      ],
      "facet": "Introductory relativity",
      "lessonIds": [
        "lesson-physics-dynamics",
        "lesson-physics-two-dimensional-motion"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            10,
            56
          ],
          "note": "Full local mechanics core uses Newtonian forces; relativity absent."
        },
        {
          "path": "content/lessons/science/physics/two-dimensional-motion.md",
          "lines": [
            10,
            51
          ],
          "note": "Projectile/circular introductory core has no relativity teaching."
        }
      ],
      "missingIdeas": [
        "No relativity teaching found in full physics read or whole-lesson keyword search."
      ],
      "priorKnowledge": "Relevant model meanings; no authored-order assumption.",
      "workedExamples": "thin or none as noted in evidence",
      "scopeLimit": "Weak reviewer extension only; do not recommend mandatory new content from this alone. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L162"
      ],
      "facet": "Balance and stability",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            97,
            107
          ],
          "note": "Local force balance is translational, no tipping or center-of-gravity method."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            12,
            28
          ],
          "note": "Narrow source check found an existing center-of-gravity/tipping model; coordinate this existing source rather than declare a global gap."
        }
      ],
      "missingIdeas": [
        "Connect the existing stability unit where the requirement needs tipping rather than duplicating it."
      ],
      "priorKnowledge": "Relevant model meanings; no authored-order assumption.",
      "workedExamples": "thin or none as noted in evidence",
      "scopeLimit": "Absent locally, existing cross-topic candidate verified by full read; no coverage verdict issued for that topic. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dost-sei-L107"
      ],
      "facet": "Ideal gases within STEM Physics preparation",
      "lessonIds": [
        "lesson-physics-thermodynamics"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/science/physics/thermodynamics.md",
          "lines": [
            10,
            50
          ],
          "note": "Thermal core lacks PV=nRT."
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            48,
            58
          ],
          "note": "Existing chemistry source states ideal-gas relation and unit conditions."
        },
        {
          "path": "content/lessons/science/chemistry/gas-laws.md",
          "lines": [
            96,
            106
          ],
          "note": "Narrow source check found an ideal-gas worked mole calculation."
        }
      ],
      "missingIdeas": [
        "Connect existing chemistry ideal-gas teaching; no duplicate physics lesson solely for tagging."
      ],
      "priorKnowledge": "Relevant model meanings; no authored-order assumption.",
      "workedExamples": "thin or none as noted in evidence",
      "scopeLimit": "Absent in physics bodies; existing cross-topic source checked narrowly, no chemistry topic verdict. STEM/completion conditional. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058"
      ],
      "facet": "Simple/compound machines versus efficiency",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            127,
            140
          ],
          "note": "Local example computes output power, not mechanical advantage or efficiency."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            12,
            40
          ],
          "note": "Existing source teaches ideal work tradeoff and pulley/lever advantage."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            57,
            83
          ],
          "note": "Narrow read found pulley effort/distance and lever balance applications, but no input/output efficiency calculation."
        }
      ],
      "missingIdeas": [
        "Share existing machine foundation; distinguish mechanical advantage from energy efficiency."
      ],
      "priorKnowledge": "Relevant model meanings; no authored-order assumption.",
      "workedExamples": "thin or none as noted in evidence",
      "scopeLimit": "Local physics partiality; narrowly verified overlap source, no other-topic verdict. Strengthened-SHS preparation only. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L054",
        "dost-sei-L100",
        "sm-foundation-L139"
      ],
      "facet": "Newton first law and inertia",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            14,
            16
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            66,
            84
          ],
          "note": "Distinct example evidence, thin as qualified."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L054",
        "dost-sei-L100",
        "sm-foundation-L139"
      ],
      "facet": "Newton second law",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            18,
            22
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            60,
            64
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L054",
        "dost-sei-L100",
        "sm-foundation-L139"
      ],
      "facet": "Newton third law and interaction pairs",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            24,
            24
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            66,
            84
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L054",
        "dost-sei-L100",
        "sm-foundation-L139"
      ],
      "facet": "Weight",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            30,
            34
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            97,
            107
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L054",
        "dost-sei-L100",
        "sm-foundation-L139"
      ],
      "facet": "Normal force and balance",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            36,
            36
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            97,
            107
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L054",
        "dost-sei-L100",
        "sm-foundation-L139"
      ],
      "facet": "Ideal rope tension",
      "lessonIds": [
        "lesson-physics-dynamics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/dynamics.md",
          "lines": [
            38,
            38
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Velocity and acceleration; vector signs/components. Inertial frame is named, not developed; no separate existing frame lesson verified.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Electric charge foundation",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            14,
            18
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            70,
            78
          ],
          "note": "Distinct example evidence, thin as qualified."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Current physical meaning",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            28,
            34
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L150",
        "dcat-L085",
        "ustet-L117",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100"
      ],
      "facet": "Voltage physical meaning",
      "lessonIds": [
        "lesson-physics-electricity-and-magnetism"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/science/physics/electricity-and-magnetism.md",
          "lines": [
            28,
            34
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Charge, current, voltage and magnetic flux physical meanings; simple algebra. Current/voltage/flux foundation gaps are recorded separately.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dost-sei-L107",
        "sm-foundation-L141"
      ],
      "facet": "Kepler elliptical orbit and focus",
      "lessonIds": [
        "lesson-physics-gravity-and-keplers-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
          "lines": [
            24,
            26
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
          "lines": [
            94,
            102
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Ratios, inverse square, cube root; ellipse geometry/area reasoning. Semimajor axis and perihelion/aphelion are defined locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "dost-sei-L107",
        "sm-foundation-L141"
      ],
      "facet": "Kepler equal areas and speed",
      "lessonIds": [
        "lesson-physics-gravity-and-keplers-laws"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
          "lines": [
            28,
            28
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/gravity-and-keplers-laws.md",
          "lines": [
            58,
            68
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Ratios, inverse square, cube root; ellipse geometry/area reasoning. Semimajor axis and perihelion/aphelion are defined locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "acet-L127",
        "ustet-L117",
        "ustet-L123",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Position and displacement versus distance",
      "lessonIds": [
        "lesson-physics-kinematics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            16,
            20
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            71,
            77
          ],
          "note": "Distinct example evidence, thin as qualified."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Arithmetic, substitution and roots; origin/sign convention taught locally.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "acet-L127",
        "ustet-L117",
        "ustet-L123",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Velocity versus speed",
      "lessonIds": [
        "lesson-physics-kinematics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            22,
            26
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            71,
            77
          ],
          "note": "Distinct example evidence, thin as qualified."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Arithmetic, substitution and roots; origin/sign convention taught locally.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "acet-L127",
        "ustet-L117",
        "ustet-L123",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Acceleration as velocity change",
      "lessonIds": [
        "lesson-physics-kinematics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            28,
            32
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            65,
            69
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Arithmetic, substitution and roots; origin/sign convention taught locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "acet-L127",
        "ustet-L117",
        "ustet-L123",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Constant-acceleration equation selection",
      "lessonIds": [
        "lesson-physics-kinematics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            35,
            49
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            65,
            99
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Arithmetic, substitution and roots; origin/sign convention taught locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "acet-L127",
        "ustet-L117",
        "ustet-L123",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Signed ideal free fall",
      "lessonIds": [
        "lesson-physics-kinematics"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            51,
            61
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/kinematics.md",
          "lines": [
            79,
            87
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Arithmetic, substitution and roots; origin/sign convention taught locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L082",
        "ustet-L117",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139"
      ],
      "facet": "Signed momentum",
      "lessonIds": [
        "lesson-physics-momentum-and-impulse"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            12,
            16
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            59,
            65
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Signed velocity, kinetic versus total energy, chosen system boundary. Integral is not needed for its constant/average-force examples.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L082",
        "ustet-L117",
        "pupcet-L118",
        "pupcet-L123",
        "dost-sei-L100",
        "dost-sei-L107",
        "sm-foundation-L139"
      ],
      "facet": "Impulse and average force",
      "lessonIds": [
        "lesson-physics-momentum-and-impulse"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            18,
            32
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/momentum-and-impulse.md",
          "lines": [
            67,
            75
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Signed velocity, kinetic versus total energy, chosen system boundary. Integral is not needed for its constant/average-force examples.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "dost-sei-L104",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Mechanical versus electromagnetic waves",
      "lessonIds": [
        "lesson-physics-waves-and-sound"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            30,
            34
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            72,
            79
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Ratio arithmetic; oscillation/cycle and medium distinctions developed locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "dost-sei-L104",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Transverse versus longitudinal waves",
      "lessonIds": [
        "lesson-physics-waves-and-sound"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            36,
            36
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Ratio arithmetic; oscillation/cycle and medium distinctions developed locally.",
      "workedExamples": "none",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "dost-sei-L104",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Sound speed, pitch and intensity",
      "lessonIds": [
        "lesson-physics-waves-and-sound"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            38,
            42
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            62,
            70
          ],
          "note": "Distinct example evidence, thin as qualified."
        }
      ],
      "missingIdeas": [
        "Develop this distinct local teaching or worked application before full facet coverage is claimed."
      ],
      "priorKnowledge": "Ratio arithmetic; oscillation/cycle and medium distinctions developed locally.",
      "workedExamples": "thin",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L082",
        "dcat-L083",
        "ustet-L117",
        "ustet-L123",
        "ustet-L124",
        "pupcet-L119",
        "dost-sei-L104",
        "sm-foundation-L139",
        "sm-foundation-L141"
      ],
      "facet": "Moving-source Doppler effect",
      "lessonIds": [
        "lesson-physics-waves-and-sound"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            44,
            48
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/waves-and-sound.md",
          "lines": [
            81,
            92
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Ratio arithmetic; oscillation/cycle and medium distinctions developed locally.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L083",
        "acet-L127",
        "ustet-L117",
        "ustet-L124",
        "pupcet-L118",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L108",
        "sm-foundation-L139"
      ],
      "facet": "Kinetic energy",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            22,
            24
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            62,
            79
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Displacement versus path length, speed, cosine projection and algebraic rearrangement.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    },
    {
      "requirementRefs": [
        "upcat-L148",
        "upcat-L149",
        "upcat-L162",
        "dcat-L080",
        "dcat-L083",
        "acet-L127",
        "ustet-L117",
        "ustet-L124",
        "pupcet-L118",
        "pupcet-L119",
        "dost-sei-L054",
        "dost-sei-L100",
        "dost-sei-L108",
        "sm-foundation-L139"
      ],
      "facet": "Near-Earth potential energy",
      "lessonIds": [
        "lesson-physics-work-energy-power"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            26,
            30
          ],
          "note": "Distinct local teaching facet; see structural limitations."
        },
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            81,
            94
          ],
          "note": "Distinct example evidence, worked as qualified."
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Displacement versus path length, speed, cosine projection and algebraic rearrangement.",
      "workedExamples": "worked",
      "scopeLimit": "Only this local skill, not the entire compound requirement or a current detailed exam blueprint. Practice deferred Level5; runtime unknown."
    }
  ],
  "sourceLedger": [
    {
      "Item": "lesson-physics-electricity-and-magnetism",
      "Issue": "Missing physical meaning of current",
      "Original content/claim": "Lines 28-36 label I as current; line 60 uses conventional current, without charge-flow meaning.",
      "Disposition": "LESSON GAP: foundation definition confirmed, content unchanged",
      "Source URL/page": "https://openstax.org/books/university-physics-volume-2/pages/9-1-electrical-current, Defining Current and the Ampere",
      "Verification note": "Source defines current as net charge passing per time and conventional current by positive charge direction. This supports the foundation-gap finding, not an exam scope claim.",
      "accessDate": "2026-10-05",
      "branch/base": "docs/content-coverage-audit-r1 / 7d5f2ed6a6d6f30e35d1b3f64467f31e7d122112; corpus 765c5dc0fa5586281047bf4f7b30d09ab3707887"
    },
    {
      "Item": "lesson-physics-electricity-and-magnetism",
      "Issue": "Missing voltage meaning",
      "Original content/claim": "Line 34 labels V as potential difference without energy-per-charge meaning.",
      "Disposition": "LESSON GAP: physical meaning confirmed, content unchanged",
      "Source URL/page": "https://openstax.org/books/university-physics-volume-2/pages/7-2-electric-potential-and-potential-difference, Electric Potential Difference",
      "Verification note": "Source defines potential difference as potential-energy change divided by charge. Bare symbol labeling does not develop that idea.",
      "accessDate": "2026-10-05",
      "branch/base": "docs/content-coverage-audit-r1 / 7d5f2ed6a6d6f30e35d1b3f64467f31e7d122112; corpus 765c5dc0fa5586281047bf4f7b30d09ab3707887"
    },
    {
      "Item": "lesson-physics-electricity-and-magnetism",
      "Issue": "Undefined flux is central to induction",
      "Original content/claim": "Lines 62-66 use changing magnetic flux and Faraday/Lenz; lines 113-120 repeat that relationship.",
      "Disposition": "CONFIRMED relationship; LESSON GAP in flux foundation, content unchanged",
      "Source URL/page": "https://openstax.org/books/university-physics-volume-2/pages/13-1-faradays-law, Faraday Law, equations 13.1-13.3",
      "Verification note": "Source relates induction to changing magnetic field through a surface and its orientation/area. Existing lesson does not develop the flux quantity. No complete fact or answer review claimed.",
      "accessDate": "2026-10-05",
      "branch/base": "docs/content-coverage-audit-r1 / 7d5f2ed6a6d6f30e35d1b3f64467f31e7d122112; corpus 765c5dc0fa5586281047bf4f7b30d09ab3707887"
    }
  ],
  "correctionHistory": [
    {
      "finding": "P1",
      "date": "2026-10-06",
      "policyCommit": "e8d5f0f958e38c1648046a93747437687ba08334",
      "originalPolicyCommit": "cb48097bedf15bec2cfbe4fb3aa7e957753b1727",
      "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "targetBeforeSha256": "88d7e88c8b2d0adceeecb0d0a81853573b40163f669dc0c1edc0d41b45885b98",
      "disposition": "Duplicate vector prerequisite removed; direct acute-angle sine/cosine foundation substituted with both-end evidence. Kinematics/dynamics links unchanged. Fresh narrow review pending.",
      "sourceReads": [
        {
          "path": "content/lessons/science/physics/two-dimensional-motion.md",
          "sha256": "de82fab38cfee42169aa60c0c2358f845b2e3c654c1418b75bd875c3413115df",
          "readLines": [
            1,
            141
          ]
        },
        {
          "path": "content/lessons/science/physics/scalars-and-vectors.md",
          "sha256": "a60360ce8730c373c2a4b566ab69b6442a29a66af2b464f1e0a8220e923a9ac0",
          "readLines": [
            1,
            130
          ]
        },
        {
          "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
          "sha256": "536c2fcee4e48cc0b7c690b3b2bba2e1c29b2b9dfeaf40b7de32be188ee25ab3",
          "readLines": [
            1,
            194
          ]
        }
      ]
    },
    {
      "finding": "P1 completion",
      "date": "2026-10-06",
      "policyCommit": "6d0bb7318ad396abe62c6c59b6d437f758ed65c4",
      "resumeInputSha256": "81c04729b09b6fe798430651d7739a7568223dd84d95fb2e5817d5a285580954",
      "policyRefresh": "Nine current main policy/standard/startup contents retrieved and independently byte-compared against fully read e8d5 policy; all identical. Current spec/plan/decisions/orchestrator also unchanged.",
      "readEvidence": "Preserved full source reads and hashes verified against pinned corpus; no unchanged full reads repeated.",
      "disposition": "Finish saved direct trigonometric-ratios correction; fresh narrow review remains required."
    }
  ]
}
```
