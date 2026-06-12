# Science Question Generation — Content Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to work this plan subtopic-by-subtopic. Each manifest row below is one unit of work with its own test cycle (validate → review → approve → commit); treat each as a step.

**Goal:** Author, validate, review, and commit the question YAML for every remaining Science subtopic (50 files across Biology, Chemistry, Physics, Earth Science & Astronomy), using the already-built static question pipeline.

**Architecture:** No code changes. This is a content-production run against an existing, tested pipeline: `tools/import_questions/` (validates + converts YAML → Sanity docs) and `tools/question_studio/` (review/approve UI). One YAML file per subtopic, ~12–20 questions each, following the Science blueprint's archetypes.

**Tech Stack:** YAML content files; Dart CLI for validation; Node review tool. No Flutter/Dart code is written in this plan.

## Global Constraints

- Scope is **Science only** (Biology, Chemistry, Physics, Earth Science & Astronomy). Do not touch Mathematics, Reasoning, Language Proficiency, or Reading Comprehension in this plan — those are separate plans/out of scope.
- Do not modify `tools/import_questions/` or `tools/question_studio/` code. If you find a genuine bug in them, stop, write a regression test reproducing it (mirror the pattern in `test/tool/import_questions/cli_test.dart`), fix it minimally, and only then continue content work.
- One YAML file per subtopic at `content/questions/science/<topic>/<subtopic>.yaml`. Never combine two subtopics in one file, never split one subtopic across two files.
- Exactly one choice per question has `correct: true`. 4 choices by default (fewer only if the question genuinely has fewer valid options — rare in Science).
- **Quote any choice `text` that is purely digits** — e.g. `text: "18"`, not `text: 18`. Unquoted, YAML parses it as an integer and the importer rejects the question with "choice N has empty text." This bites constantly in `simple-quantitative` questions (Physics, and Chemistry's mole-concept/stoichiometry/gas-laws/solutions). Values with any non-digit character (`3-`, `2, 3, 1`, `18 neutrons`) are already safe.
- `stem` and `explanation` are YAML block scalars (`|`), preserving LaTeX (`\dfrac{1}{2}`, `$F=ma$`, etc.) verbatim.
- **Two-level voice:** `stem` stays at authentic UPCAT/DOST-SEI exam difficulty and wording. `explanation` drops to simple Grade 4–6 English — state why the correct answer is right and briefly why the main distractor is wrong.
- **`difficulty` is authoring-only** (`easy | medium | hard | exam`). It orders the question's numeric id suffix; it is never written to the Sanity doc, and no schema field for it should ever be added.
- **`id` pattern:** `q-<topicSlug>-<subtopicSlug>-NNNN`, unique across the whole bank, ascending with difficulty (easiest = lowest number).
- **Figures:** default to figure-free. Only add `figure: <kebab-case-slug>` when a question is genuinely unanswerable without seeing a diagram (see the per-topic notes in the manifest below). A figure-pending question still gets full stem/choices/explanation text now — never skip writing it. Every `figure:` slug must also get a row in `docs/content/question-figures/worklist.tsv`.
- **Ground every question in the existing lesson content** at `content/lessons/science/<topic>/<subtopic>.md` — use its terminology, its "Traps to Watch For" section (if present) as distractor material, and its worked examples as a style reference. Do not invent facts, units, or values not supportable by that lesson or basic accurate science.
- Coverage per subtopic: every blueprint archetype that genuinely fits × 2–3 differently-phrased variants, ramped easy → exam-level, landing around **12–20 questions**. No near-duplicate questions (same scenario with only a number swapped is a near-duplicate — vary the scenario or framing instead).
- No AI/Claude attribution in any commit message.

## Required reading (read once, before starting row 1)

- `docs/content/question-style-guide.md` — full YAML field rules.
- `docs/content/question-authoring-runbook.md` — process + the topic→exam tag table (already applied in the manifest below, but useful if a question needs a fifth exam tag you're unsure about).
- `docs/content/question-blueprints/science.md` — the 8 archetypes (identify-organelle/identify, structure-function, cause-effect, classify, predict-outcome, compare-contrast, process-ordering, simple-quantitative) with one worked example each. Reuse these archetype names in each question's `type:` field; only invent a new archetype name if none of the 8 genuinely fits, and if you do, add a worked example to that blueprint file so future subtopics can reuse it.
- The pilot file `content/questions/science/biology/cell-biology.yaml` — a complete, already-approved reference example of the target shape and quality bar (16 questions, all archetypes, zero validator errors).

## The Generation Procedure (apply to every row in the manifest below)

- [ ] **Step 1: Read the source lesson**

Open `content/lessons/science/<topic>/<subtopic>.md` (path given in the manifest row). Note its core concept terms, its worked examples, and especially its "Traps to Watch For" section — these traps make excellent distractor material because they mirror real student mistakes.

- [ ] **Step 2: Pick archetypes and plan the question list**

From `question-blueprints/science.md`, list which of the 8 archetypes genuinely fit this subtopic's content (skip ones that don't — e.g. `simple-quantitative` rarely fits a purely descriptive topic). Plan 2–3 variants per archetype used, ramped easy → exam-level, targeting 12–20 questions total.

- [ ] **Step 3: Write the YAML file**

Create `content/questions/science/<topic>/<subtopic>.yaml` (exact path in the manifest) with:

```yaml
meta:
  subject: science
  topic: <topic slug>
  subtopic: <subtopic slug>
  exams: [upcat, dlsucet, ustet, dost-sei]
questions:
  - id: q-<topic slug>-<subtopic slug>-0001
    type: <archetype name>
    difficulty: easy
    stem: |
      ...
    choices:
      - text: ...
        correct: true
      - text: ...
      - text: ...
      - text: ...
    explanation: |
      ...
  # ... 11–19 more questions, ids ascending, difficulty ramping
```

Add `figure: <slug>` to any question that is genuinely unanswerable without a diagram (see the manifest's per-topic figure guidance). Leave `approved:` unset — Question Studio sets it.

- [ ] **Step 4: Validate**

Run: `dart run tools/import_questions/import_questions.dart --root content/questions`

Expected: exit code 0. If it fails, it names the exact file and question id — fix and rerun before moving on. (Do not batch multiple subtopics before validating; validate after every file so mistakes are caught immediately.)

- [ ] **Step 5: Review and approve in Question Studio**

Run: `node tools/question_studio/server.mjs` (or double-click `tools/question_studio/Start Question Studio.command`), open http://localhost:4323, find `science / <topic> / <subtopic>` in the tree. Confirm: no validator errors on any question, no duplicate-stem warning, the correct choice highlighted matches your intent. Fix inline in the tool (writes back to the YAML), then check every question's "approved" box and click Save. Stop the server (Ctrl+C) when done.

- [ ] **Step 6: Re-validate after approval**

Run Step 4's command again to confirm the studio's write-back didn't break anything: exit code 0.

- [ ] **Step 7: Commit**

```bash
git add content/questions/science/<topic>/<subtopic>.yaml
# if any figures were added:
git add docs/content/question-figures/worklist.tsv
git commit -m "content: <Subtopic Title> questions"
```

- [ ] **Step 8: Check off the row**

Mark the manifest row below `- [x]` and move to the next row.

## Definition of Done (per subtopic)

- [ ] File exists at the exact manifest path.
- [ ] 12–20 questions, covering every archetype that fits (per Step 2's plan).
- [ ] `dart run tools/import_questions/import_questions.dart --root content/questions` exits 0.
- [ ] Question Studio shows zero validator errors and zero duplicate-stem flags for this subtopic.
- [ ] Every question's `approved: true`.
- [ ] Committed with a descriptive message; working tree clean except the next subtopic in progress.

## Manifest — Biology (topic slug: `biology`)

Exams for all rows: `[upcat, dlsucet, ustet, dost-sei]`. Figure guidance: mostly figure-free; `genetics-and-heredity` (Punnett squares/pedigree charts) and `human-anatomy-physiology` (organ-system diagrams) are the topics most likely to need an occasional `figure:` — judge per question, most items in both can still be phrased figure-free (e.g. a Punnett-square cross can be described in prose: "Parent A is Bb, Parent B is bb..."). `cell-biology` is done (pilot).

| Done | Subtopic slug | Title | File path |
|---|---|---|---|
| [x] | `cell-biology` | Cell Biology | `content/questions/science/biology/cell-biology.yaml` (pilot, already committed) |
| [x] | `characteristics-of-life` | Characteristics of Life | `content/questions/science/biology/characteristics-of-life.yaml` |
| [x] | `cellular-reproduction` | Cellular Reproduction (Cell Cycle, Mitosis, Meiosis) | `content/questions/science/biology/cellular-reproduction.yaml` |
| [x] | `cellular-metabolism` | Cellular Metabolism (Photosynthesis, Cellular Respiration) | `content/questions/science/biology/cellular-metabolism.yaml` |
| [x] | `genetics-and-heredity` | Genetics and Heredity | `content/questions/science/biology/genetics-and-heredity.yaml` |
| [x] | `human-anatomy-physiology` | Human Anatomy and Physiology | `content/questions/science/biology/human-anatomy-physiology.yaml` |
| [x] | `taxonomy-and-classification` | Taxonomy and Classification (Domains, Kingdoms, Binomial Nomenclature) | `content/questions/science/biology/taxonomy-and-classification.yaml` |
| [x] | `evolution` | Evolution (Theories of Evolution, Natural Selection, Speciation) | `content/questions/science/biology/evolution.yaml` |
| [x] | `ecology` | Ecology | `content/questions/science/biology/ecology.yaml` |
| [x] | `botany` | Botany (Plant Tissue, Tropisms, Plant Reproduction) | `content/questions/science/biology/botany.yaml` |

## Manifest — Chemistry (topic slug: `chemistry`)

Exams for all rows: `[upcat, dlsucet, ustet, dost-sei]`. Figure guidance: the content audit found **no** illustration gaps in Chemistry — author entirely figure-free.

| Done | Subtopic slug | Title | File path |
|---|---|---|---|
| [x] | `matter` | Matter (Classification, States, Properties, Phase Changes) | `content/questions/science/chemistry/matter.yaml` |
| [x] | `mixtures-and-separation` | Mixtures and Separation Techniques (Filtration, Distillation, Chromatography) | `content/questions/science/chemistry/mixtures-and-separation.yaml` |
| [x] | `history-of-the-atom` | History of the Atom and Atomic Models | `content/questions/science/chemistry/history-of-the-atom.yaml` |
| [x] | `atomic-structure` | Atomic Structure and Subatomic Particles (Protons, Neutrons, Electrons, Isotopes, Ions) | `content/questions/science/chemistry/atomic-structure.yaml` |
| [x] | `quantum-numbers-electron-configuration` | Quantum Numbers and Electron Configuration | `content/questions/science/chemistry/quantum-numbers-electron-configuration.yaml` |
| [x] | `periodic-table` | The Periodic Table | `content/questions/science/chemistry/periodic-table.yaml` |
| [x] | `chemical-bonding` | Chemical Bonding (Ionic, Covalent, Metallic, Lewis Structures, VSEPR Theory) | `content/questions/science/chemistry/chemical-bonding.yaml` |
| [x] | `chemical-nomenclature` | Chemical Nomenclature (Naming Compounds and Writing Formulas) | `content/questions/science/chemistry/chemical-nomenclature.yaml` |
| [x] | `mole-concept` | The Mole Concept, Molar Mass, and Avogadro's Number | `content/questions/science/chemistry/mole-concept.yaml` |
| [x] | `chemical-reactions` | Chemical Reactions (Types of Reactions, Balancing Equations) | `content/questions/science/chemistry/chemical-reactions.yaml` |
| [x] | `stoichiometry` | Stoichiometry (Limiting/Excess Reactants, Percent Yield, Empirical/Molecular Formulas) | `content/questions/science/chemistry/stoichiometry.yaml` |
| [x] | `gas-laws` | Gas Laws (Boyle's, Charles's, Gay-Lussac's, Combined, Avogadro's, Ideal Gas Law) | `content/questions/science/chemistry/gas-laws.yaml` |
| [x] | `solutions` | Solutions (Solubility, Molarity, Molality, Percent by Mass/Volume) | `content/questions/science/chemistry/solutions.yaml` |
| [x] | `acids-bases-ph` | Acids, Bases, and pH Scale | `content/questions/science/chemistry/acids-bases-ph.yaml` |
| [x] | `thermodynamics-and-kinetics` | Thermodynamics and Kinetics (Endothermic vs. Exothermic Reactions, Catalysts) | `content/questions/science/chemistry/thermodynamics-and-kinetics.yaml` |
| [x] | `basic-organic-chemistry` | Basic Organic Chemistry (Hydrocarbons, Functional Groups, Naming Conventions) | `content/questions/science/chemistry/basic-organic-chemistry.yaml` |
| [x] | `nuclear-chemistry` | Nuclear Chemistry (Alpha, Beta, Gamma Decay, Fission vs. Fusion) | `content/questions/science/chemistry/nuclear-chemistry.yaml` |

Note: `mole-concept`, `stoichiometry`, `gas-laws`, and `solutions` lean heavily on the `simple-quantitative` archetype (real calculations) — verify every numeric answer by actually doing the arithmetic before finalizing; a wrong "correct" choice in a quantitative question is a severe quality defect.

## Manifest — Physics (topic slug: `physics`)

Exams for all rows: `[upcat, dlsucet, ustet, dost-sei]`. Figure guidance: the audit flagged genuine figure-dependent *examples* (not whole lessons) in `dynamics`, `two-dimensional-motion`, `scalars-and-vectors`, `electricity-and-magnetism`, `fluid-mechanics`, and possibly others — free-body diagrams, projectile trajectories, vector-resolution setups, and circuit diagrams. Default to figure-free phrasing (most physics questions can state the setup in words, e.g. "A 5 kg block sits on a frictionless surface..."); mark `figure:` only for the specific questions where a diagram is truly load-bearing (e.g., "read the circuit diagram to find total resistance").

| Done | Subtopic slug | Title | File path |
|---|---|---|---|
| [x] | `units-and-measurements` | Units, Measurements, and Conversions (Dimensional Analysis) | `content/questions/science/physics/units-and-measurements.yaml` |
| [x] | `scalars-and-vectors` | Scalars and Vectors (Vector Addition and Resolution) | `content/questions/science/physics/scalars-and-vectors.yaml` |
| [x] | `kinematics` | Kinematics | `content/questions/science/physics/kinematics.yaml` |
| [x] | `two-dimensional-motion` | Two-Dimensional Motion (Projectile Motion, Uniform Circular Motion) | `content/questions/science/physics/two-dimensional-motion.yaml` |
| [x] | `dynamics` | Dynamics | `content/questions/science/physics/dynamics.yaml` |
| [x] | `work-energy-power` | Work, Energy, and Power (Kinetic and Potential Energy, Conservation of Energy) | `content/questions/science/physics/work-energy-power.yaml` |
| [x] | `momentum-and-impulse` | Momentum and Impulse (Conservation of Momentum, Elastic vs. Inelastic Collisions) | `content/questions/science/physics/momentum-and-impulse.yaml` |
| [x] | `gravity-and-keplers-laws` | Gravity and Kepler's Laws of Planetary Motion | `content/questions/science/physics/gravity-and-keplers-laws.yaml` |
| [x] | `fluid-mechanics` | Fluid Mechanics (Density, Pressure, Buoyancy, Archimedes' Principle, Bernoulli's Principle) | `content/questions/science/physics/fluid-mechanics.yaml` |
| [x] | `thermodynamics` | Thermodynamics (Heat Transfer Mechanisms, Laws of Thermodynamics, Specific Heat Capacity) | `content/questions/science/physics/thermodynamics.yaml` |
| [x] | `waves-and-sound` | Waves and Sound (Wave Properties, Mechanical vs. Electromagnetic Waves, Doppler Effect) | `content/questions/science/physics/waves-and-sound.yaml` |
| [x] | `light-and-optics` | Light and Optics (Reflection, Refraction, Mirrors, Lenses, Electromagnetic Spectrum) | `content/questions/science/physics/light-and-optics.yaml` |
| [x] | `electricity-and-magnetism` | Electricity and Magnetism | `content/questions/science/physics/electricity-and-magnetism.yaml` |

Note: nearly every Physics subtopic uses `simple-quantitative` heavily (F=ma, kinematics equations, Ohm's law, etc.) — always verify the arithmetic by hand before finalizing a "correct" choice.

## Manifest — Earth Science & Astronomy (topic slug: `earth-science-astronomy`)

Exams for all rows: `[upcat, dlsucet, ustet, dost-sei]`. Figure guidance: the audit flagged eclipse geometry, moon phases, the rock cycle, and Earth's internal layers as needing diagrams for full clarity. Many individual questions can still be phrased figure-free (e.g. "which phase of the moon occurs when it is between the Earth and the Sun?" needs no image); reserve `figure:` for questions that ask the reader to read a diagram (e.g. "which layer is labeled X in the cross-section?").

| Done | Subtopic slug | Title | File path |
|---|---|---|---|
| [x] | `origin-of-the-universe` | Origin of the Universe and Solar System (Big Bang Theory, Nebular Hypothesis) | `content/questions/science/earth-science-astronomy/origin-of-the-universe.yaml` |
| [x] | `heavenly-bodies` | Heavenly Bodies (Stars, Galaxies, Comets, Asteroids, Meteors) | `content/questions/science/earth-science-astronomy/heavenly-bodies.yaml` |
| [x] | `earths-motions` | Earth's Motions (Rotation, Revolution, Precession) | `content/questions/science/earth-science-astronomy/earths-motions.yaml` |
| [x] | `eclipses-and-moon-phases` | Lunar and Solar Eclipses, Phases of the Moon | `content/questions/science/earth-science-astronomy/eclipses-and-moon-phases.yaml` |
| [x] | `earths-subsystems` | The Earth's Subsystems (Lithosphere, Hydrosphere, Atmosphere, Biosphere) | `content/questions/science/earth-science-astronomy/earths-subsystems.yaml` |
| [x] | `layers-of-the-earth` | Layers of the Earth and Composition | `content/questions/science/earth-science-astronomy/layers-of-the-earth.yaml` |
| [x] | `minerals-and-rocks` | Minerals and Rocks (Igneous, Sedimentary, Metamorphic, Rock Cycle) | `content/questions/science/earth-science-astronomy/minerals-and-rocks.yaml` |
| [x] | `plate-tectonics` | Plate Tectonics | `content/questions/science/earth-science-astronomy/plate-tectonics.yaml` |
| [ ] | `weather-and-climate` | Weather and Climate | `content/questions/science/earth-science-astronomy/weather-and-climate.yaml` |
| [ ] | `water-cycle-oceanography` | The Water Cycle and Basic Oceanography | `content/questions/science/earth-science-astronomy/water-cycle-oceanography.yaml` |
| [ ] | `fossils-and-geologic-time` | Fossils, Stratigraphy, and Geologic Time Scale | `content/questions/science/earth-science-astronomy/fossils-and-geologic-time.yaml` |

## Suggested order

Process one topic at a time in this order — Chemistry first (largest, figure-free, lowest ambiguity), then Physics, then Earth Science & Astronomy, then finish Biology. Within a topic, go top-to-bottom through its manifest table. Commit after every subtopic (Step 7); do not batch commits across subtopics.

## Self-Review

**Spec coverage:** every remaining Science lesson from `tools/lesson_author/outline.json` (51 total, 1 done) has a manifest row with an exact path — none omitted. ✓
**Placeholder scan:** no TBD/TODO; the Generation Procedure gives exact commands, not descriptions of commands. ✓
**Consistency:** exam tags, file paths, and the archetype list all match `docs/content/question-authoring-runbook.md` and `docs/content/question-blueprints/science.md` exactly. ✓
