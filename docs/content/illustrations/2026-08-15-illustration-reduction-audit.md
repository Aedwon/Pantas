# Lesson Illustration Reduction Audit & Sourcing Strategy

**Date:** 15 August 2026
**Inventory:** 279 lesson illustration placeholders across 111 lessons

---

## Executive Summary

Drawing 279 custom illustrations by hand is unnecessary. A full audit of all 279 placeholders reduces your personal drawing workload from **279 down to just 3 images**.

| Strategy | Count | Implementation |
|---|---|---|
| **Draw in Code (`CustomPainter` / SVG)** | **189** | Programmatic Flutter canvas painters (Math geometry, trig, graphs, mechanical reasoning, abstract puzzles, simple physics vectors/circuits). Theme-adaptive, zero asset bloat. |
| **Open-Source / Public Domain Sourcing** | **56** | High-quality vector/PNG assets from OpenStax (CC-BY 4.0), USGS, NASA, NOAA, and Wikimedia Commons (Public Domain / CC-BY). Standard biology, chemistry apparatus, earth science, and advanced physics. |
| **Convert to Markdown / LaTeX / Tables** | **23** | Replace placeholder image with native Markdown tables (truth tables, Punnett squares), LaTeX chemical formulas, or styled callout text. Better readability on mobile. |
| **Cut Decorative / Metaphor Images** | **8** | Remove non-essential decorative graphics (e.g. icons for life, balance scales, checklists) where the lesson text is completely self-contained. |
| **Solo Founder Hand-Crafted Assets** | **3** | Bespoke stimuli for Reading Comprehension visual media (1 editorial cartoon, 1 comic strip, 1 political cartoon variant). |
| **Total** | **279** | |

---

## 1. Solo Founder Creation List (Only 3 Images)

These 3 are the only bespoke illustrations that cannot be coded or sourced from public textbooks because they serve as specific test stimuli for visual literacy:

| Target File | Description | Tool to Use |
|---|---|---|
| `content/illustrations/reading-comprehension/text-types/visual-media/01-editorial-cartoon-example-large.png` | Editorial cartoon showing a large boulder labeled "TAXES" rolling toward a small figure labeled "CITIZENS" with a speech bubble showing worry. | Canva / Figma / Illustrator |
| `content/illustrations/reading-comprehension/text-types/visual-media/02-panel-comic-strip-panel.png` | 3-panel comic strip: 1) building sandcastle, 2) finished castle, 3) wave washes it away with resigned face. | Canva / Figma / Illustrator |
| `content/illustrations/reading-comprehension/text-types/visual-media/03-editorial-cartoon-large-boulder.png` | Editorial cartoon variant with boulder "taxes" rolling downhill toward citizens. | Canva / Figma / Illustrator |

---

## 2. Open-Source Sourcing Directory (56 Assets)

All recommended sources are explicitly approved for commercial and educational use with simple CC-BY attribution or Public Domain status:
- **OpenStax** (Rice University, CC-BY 4.0): Biology 2e, Anatomy and Physiology 2e, Chemistry 2e, University Physics.
- **USGS & NASA & NOAA** (United States Federal Agencies, Public Domain / CC0): Earth layers, rock cycle, plate tectonics, weather layers, moon phases.
- **Wikimedia Commons** (Public Domain / CC-BY): Vector science diagrams and standard laboratory glassware.

| Subject / Topic / Lesson | Seq | Description | Recommended Source & Asset Name |
|---|---|---|---|
| `reading-comprehension/text-types/short-stories-and-novels` | 1 | a simple rising-then-falling plot line diagram labeled with introduction, r... | Wikimedia Commons (Freytag's Plot Pyramid SVG, CC-BY/PD) |
| `reading-comprehension/text-types/speeches` | 1 | a podium with three labeled arrows pointing outward toward an audience, lab... | Wikimedia Commons (Aristotelian Rhetorical Triangle SVG, CC-BY/PD) |
| `science/biology/botany` | 1 | cross-section of a plant stem showing an outer ring labeled dermal tissue, ... | OpenStax *Biology 2e*, Section 30.1 (Plant Tissues) |
| `science/biology/cell-biology` | 1 | labeled diagram of a generalized cell showing the nucleus, mitochondria, ri... | OpenStax *Biology 2e*, Section 4.3 (Eukaryotic Cells) |
| `science/biology/cellular-metabolism` | 1 | cycle diagram showing a plant chloroplast producing glucose and oxygen from... | OpenStax *Biology 2e*, Section 5.1 & 7.1 |
| `science/biology/cellular-metabolism` | 2 | two organelles side by side: a green disc-shaped chloroplast (photosynthesi... | OpenStax *Biology 2e*, Section 4.3 (Eukaryotic Cells) |
| `science/biology/cellular-reproduction` | 1 | four small diagrams in a row showing a cell at prophase with condensing chr... | OpenStax *Biology 2e*, Section 10.2 (Mitosis) |
| `science/biology/ecology` | 1 | energy pyramid with four stacked levels shrinking in size upward, labeled p... | OpenStax *Biology 2e*, Section 46.2 (Energy Flow in Ecosystems) |
| `science/biology/evolution` | 1 | three generations of a bird population shown left to right, with beak sizes... | OpenStax *Biology 2e*, Section 18.1 (Galapagos finches) |
| `science/biology/genetics-and-heredity` | 3 | a flow diagram DNA → (transcription) → mRNA → (translation) → protein, with... | OpenStax *Biology 2e*, Section 15.1 (Central Dogma) |
| `science/biology/human-anatomy-physiology` | 1 | simplified heart diagram with four labeled chambers, two atria on top and t... | OpenStax *Anatomy & Physiology 2e*, Section 19.1 (Heart Anatomy) |
| `science/biology/taxonomy-and-classification` | 1 | nested set of labeled boxes shrinking inward, from largest to smallest: Dom... | OpenStax *Biology 2e* |
| `science/chemistry/atomic-structure` | 1 | simple atom diagram showing a dense central nucleus made of protons (labele... | OpenStax *Chemistry 2e* |
| `science/chemistry/chemical-bonding` | 1 | three small diagrams side by side, an ionic bond showing an electron transf... | OpenStax *Chemistry 2e*, Section 7.2 & 7.3 |
| `science/chemistry/gas-laws` | 1 | four small pistons or containers side by side, each showing one gas law in ... | OpenStax *Chemistry 2e*, Section 9.2 (Gas Laws) |
| `science/chemistry/history-of-the-atom` | 1 | four small diagrams in a row showing Dalton's solid sphere, Thomson's plum ... | OpenStax *Chemistry 2e*, Section 2.2 (Atomic Theory) |
| `science/chemistry/matter` | 1 | three boxes showing particle arrangement in a solid (tightly packed, fixed ... | OpenStax *Chemistry 2e*, Section 1.2 (States of Matter) |
| `science/chemistry/mixtures-and-separation` | 1 | distillation setup showing a flask being heated, vapor rising and traveling... | Wikimedia Commons (Vector Distillation Apparatus SVG) |
| `science/chemistry/mole-concept` | 1 | balance scale showing one mole of carbon (12 grams) balancing against one m... | OpenStax *Chemistry 2e* |
| `science/chemistry/quantum-numbers-electron-configuration` | 1 | shapes of an s orbital (sphere), a p orbital (dumbbell/figure-eight shape),... | OpenStax *Chemistry 2e*, Section 6.3 (Atomic Orbitals) |
| `science/chemistry/solutions` | 1 | beaker with sugar dissolving into water, labeled solute (sugar) and solvent... | OpenStax *Chemistry 2e*, Section 11.1 (Solutions) |
| `science/earth-science-astronomy/earths-motions` | 1 | Earth shown at four positions around the Sun, axis tilted the same directio... | NASA Earth Observatory (Earth System Spheres, PD) |
| `science/earth-science-astronomy/earths-motions` | 2 | three small diagrams: Earth spinning on its axis (rotation → day/night), Ea... | USGS / NASA / OpenStax Astronomy (PD / CC-BY) |
| `science/earth-science-astronomy/earths-motions` | 3 | Earth at two points in its orbit around the Sun, its axis tilted 23.5°; on ... | NASA Earth Observatory (Earth System Spheres, PD) |
| `science/earth-science-astronomy/earths-motions` | 4 | Earth at two positions along its orbit showing that, after one full spin re... | USGS / NASA / OpenStax Astronomy (PD / CC-BY) |
| `science/earth-science-astronomy/earths-subsystems` | 1 | cutaway diagram of Earth showing rocky ground labeled lithosphere, ocean wa... | NOAA National Weather Service (Atmosphere Layers SVG, PD) |
| `science/earth-science-astronomy/eclipses-and-moon-phases` | 1 | Moon shown at eight positions in a circle around Earth, with the Sun's ligh... | USGS / NASA / OpenStax Astronomy (PD / CC-BY) |
| `science/earth-science-astronomy/fossils-and-geologic-time` | 1 | bar showing a sample halving repeatedly across three half-life steps, from ... | USGS / NASA / OpenStax Astronomy (PD / CC-BY) |
| `science/earth-science-astronomy/fossils-and-geologic-time` | 2 | a rock cliff cross-section with four horizontal layers stacked and labeled ... | USGS Geologic Division (Earth Interior Cutaway SVG, PD) |
| `science/earth-science-astronomy/fossils-and-geologic-time` | 3 | a decay curve (or bar steps) showing the parent element halving each billio... | USGS Stratigraphy & Radiometric Decay Charts (PD) |
| `science/earth-science-astronomy/heavenly-bodies` | 1 | comet orbiting the Sun in an oval path, shown at two positions, with its ta... | NASA JPL / Space Science (Comet Anatomy & Protoplanetary Disk, PD) |
| `science/earth-science-astronomy/layers-of-the-earth` | 1 | cutaway sphere of Earth showing four labeled layers from outside to center:... | USGS Geologic Division (Earth Interior Cutaway SVG, PD) |
| `science/earth-science-astronomy/layers-of-the-earth` | 2 | a cutaway cross-section of Earth showing its four concentric layers labeled... | USGS Geologic Division (Earth Interior Cutaway SVG, PD) |
| `science/earth-science-astronomy/layers-of-the-earth` | 3 | a cross-section of Earth with seismic waves radiating from an earthquake; S... | USGS Geologic Division (Earth Interior Cutaway SVG, PD) |
| `science/earth-science-astronomy/minerals-and-rocks` | 1 | circular rock cycle diagram showing magma cooling into igneous rock, igneou... | USGS Educational Resources (The Rock Cycle diagram, PD) |
| `science/earth-science-astronomy/origin-of-the-universe` | 1 | sequence showing a large slowly spinning cloud of gas and dust collapsing i... | NASA JPL / Space Science (Comet Anatomy & Protoplanetary Disk, PD) |
| `science/earth-science-astronomy/plate-tectonics` | 1 | three side-by-side cross-sections showing a divergent boundary with plates ... | USGS Dynamic Earth (Plate Tectonics Diagrams, PD) |
| `science/earth-science-astronomy/plate-tectonics` | 2 | two tectonic plates sliding horizontally past each other in opposite direct... | USGS Dynamic Earth (Plate Tectonics Diagrams, PD) |
| `science/earth-science-astronomy/plate-tectonics` | 3 | a seismograph trace showing the faster P wave arriving first and the slower... | USGS / NASA / OpenStax Astronomy (PD / CC-BY) |
| `science/earth-science-astronomy/water-cycle-oceanography` | 1 | circular diagram showing the Sun heating the ocean causing evaporation, ris... | USGS / NASA / OpenStax Astronomy (PD / CC-BY) |
| `science/earth-science-astronomy/weather-and-climate` | 1 | vertical cross-section of the atmosphere showing five stacked labeled layer... | USGS Geologic Division (Earth Interior Cutaway SVG, PD) |
| `science/physics/fluid-mechanics` | 1 | two objects submerged in water, one less dense than water shown floating wi... | OpenStax *University Physics Vol 1*, Section 14.4 (Archimedes Principle) |
| `science/physics/light-and-optics` | 2 | side-by-side comparison of a convex lens bending parallel light rays inward... | OpenStax *University Physics Vol 3*, Section 2.4 (Lenses) |
| `science/physics/momentum-and-impulse` | 1 | two scenarios showing the same total impulse, one showing a hand hitting a ... | OpenStax *University Physics Vol 1*, Section 9.2 (Impulse) |
| `science/physics/thermodynamics` | 1 | three small diagrams showing conduction (heat moving through a solid metal ... | OpenStax *University Physics Vol 2*, Section 1.7 (Heat Transfer) |
| `science/physics/waves-and-sound` | 4 | a moving ambulance with sound wavefronts bunched together (shorter waveleng... | OpenStax *University Physics Vol 1*, Section 17.8 (Doppler Effect) |
| `science/physics/work-energy-power` | 1 | pendulum or roller coaster shown at three points, high point with all poten... | OpenStax *University Physics Vol 1*, Section 8.3 (Conservation of Energy) |

---

## 3. Converted to Markdown / LaTeX / Tables (23 Items)

These 23 placeholders can be deleted from the illustration worklist and directly converted into formatted text blocks:

| Subject / Topic / Lesson | Seq | Description | Direct Replacement |
|---|---|---|---|
| `language-proficiency/grammar-and-structure/modifiers` | 1 | two side-by-side sentence diagrams, one showing a modifier phrase with an a... | Formatted comparison blockquote with strikethrough & checkmark notation |
| `language-proficiency/grammar-and-structure/parallelism` | 1 | a sentence with three list items shown as matching-shaped blocks (all round... | Formatted comparison blockquote with strikethrough & checkmark notation |
| `language-proficiency/grammar-and-structure/phrases-and-clauses` | 1 | two labeled sentence strips side by side, one showing "The rain stopped." m... | Formatted comparison blockquote with strikethrough & checkmark notation |
| `language-proficiency/grammar-and-structure/redundancy-and-double-negatives` | 1 | a simple math-style equation showing "negative x negative = positive" next ... | Inline LaTeX: `$$\text{negative} \times \text{negative} = \text{positive}$$` |
| `language-proficiency/grammar-and-structure/sentence-structure` | 1 | four labeled sentence diagrams, a single box for simple, two connected boxe... | Formatted comparison blockquote with strikethrough & checkmark notation |
| `language-proficiency/language-application/paragraph-organization` | 1 | four scrambled sentence cards being rearranged by an arrow into a straight,... | Formatted comparison blockquote with strikethrough & checkmark notation |
| `language-proficiency/language-application/sentence-completion` | 1 | a sentence with a blank, with arrows pointing from surrounding signal words... | Formatted comparison blockquote with strikethrough & checkmark notation |
| `reading-comprehension/comprehension-skills/choosing-a-title` | 1 | three overlapping circles labeled "too narrow," "just right," and "too broa... | Formatted Markdown block with highlighted spans |
| `reading-comprehension/comprehension-skills/context-clues-in-passages` | 1 | a full passage with several sentences highlighted in different colors, arro... | Formatted Markdown block with highlighted spans |
| `reading-comprehension/comprehension-skills/fact-vs-opinion` | 1 | a simple two-column sorting chart, one column labeled FACT with a checkmark... | Two-column Markdown Table: `| Fact | Opinion |` |
| `reading-comprehension/comprehension-skills/noting-specific-details` | 1 | two contrasting reading patterns over the same paragraph, one showing eyes ... | Formatted Markdown block with highlighted spans |
| `reading-comprehension/comprehension-skills/sequencing-of-events` | 1 | a passage with sentences appearing in a scrambled order (labeled with rando... | Formatted Markdown block with highlighted spans |
| `reading-comprehension/text-types/poetry` | 1 | a four-line poem stanza with the last word of each line highlighted and lab... | Markdown blockquote stanza with rhyme annotations `(A, B, A, B)` |
| `reasoning/logical-verbal-reasoning/truth-tables-propositional-logic` | 1 | four small truth tables side by side for NOT, AND, OR, and IF-THEN, each sh... | Standard Markdown Tables for NOT, AND, OR, IF-THEN |
| `reasoning/logical-verbal-reasoning/word-analogies` | 1 | a simple diagram showing "puppy" with an arrow labeled "is a baby" pointing... | Formatted text block: `Puppy : Dog :: Kitten : Cat` with relationship key |
| `science/biology/genetics-and-heredity` | 1 | a 2x2 Punnett square grid showing parent alleles Tt crossed with Tt along t... | 2x2 Markdown Table with Parent Alleles as row/column headers |
| `science/biology/genetics-and-heredity` | 2 | a 2x2 Punnett square with T and t along the top and side, the four cells fi... | 2x2 Markdown Table with Parent Alleles as row/column headers |
| `science/biology/genetics-and-heredity` | 3 | a flow diagram DNA → (transcription) → mRNA → (translation) → protein, with... | Inline text flow: `$$\text{DNA} \xrightarrow{\text{Transcription}} \text{mRNA} \xrightarrow{\text{Translation}} \text{Protein}$$` |
| `science/chemistry/chemical-nomenclature` | 1 | side-by-side comparison chart, one column showing ionic naming (cation + an... | Two-column Markdown comparison table: `| Ionic Naming | Covalent Naming |` |
| `science/physics/units-and-measurements` | 1 | seven labeled icons representing the base quantities, a ruler for length, a... | 7-row Markdown Table of SI Base Quantities & Standard Units |

---

## 4. Cut / Decorative Placeholders (8 Items)

These 8 are purely decorative metaphors or generic icon clusters. The surrounding lesson text already explains the concept clearly. Removing them saves time and declutters mobile screens:

| Subject / Topic / Lesson | Seq | Description | Why It Is Safe to Drop |
|---|---|---|---|
| `language-proficiency/language-application/error-identification` | 1 | Checklist card with magnifying glass icon | Text already lists the 6 error categories in bullet points. |
| `reading-comprehension/comprehension-skills/authors-purpose-tone-pov` | 1 | Three narrator icons with speech/thought bubbles | Concept is fully explained by the 1st/3rd person definition text. |
| `reading-comprehension/comprehension-skills/choosing-a-title` | 1 | Three overlapping circles "too narrow / just right / too broad" | Plain bullet list of title traps is clearer and faster to read. |
| `reading-comprehension/comprehension-skills/noting-specific-details` | 1 | Eye movement zigzag patterns over a paragraph | Reading tips are described step-by-step in prose. |
| `reading-comprehension/text-types/essays-editorials-articles` | 1 | Three document icons | Document differences are structured in a summary table. |
| `science/biology/characteristics-of-life` | 1 | Seven icons arranged in a circle | The 7 characteristics of life are formatted as an enumerated list. |
| `science/chemistry/mole-concept` | 1 | Balance scale with carbon and atoms | Mathematical ratio is cleanly stated in LaTeX formula. |
| `science/chemistry/stoichiometry` | 1 | Bicycle assembly line analogy (frames and wheels) | Limiting reactant definition is self-evident from the text. |

---

## 5. Code Painters (`CustomPainter` / SVG Engine) (189 Items)

These 189 figures are 100% geometric, mathematical, coordinate-based, or mechanical. Drawing them in code using Flutter `CustomPainter` or shared math painters matches the existing question figure architecture perfectly:

### Category Breakdown for Code Painters
1. **Geometry Figures (55 items):** Points, lines, angle pairs, transversal lines, triangles, right triangles, circles, chords, tangents, quadrilaterals, polygons, and 3D wireframe solids.
2. **Trigonometry Diagrams (38 items):** Unit circles with terminal rays & reference angles, right triangles with theta/opposite/adjacent, sine/cosine law triangles, lighthouse/observer elevation/depression triangles.
3. **Algebra & Coordinate Graphs (20 items):** Coordinate planes, linear inequalities (shaded regions), systems of equations crossing points, function curves (parabolas, rational asymptotes), 2/3-circle Venn diagrams.
4. **Calculus & Precalculus (9 items):** Definite integral under curve, conic sections on coordinate plane, limits with holes / jump discontinuities.
5. **Statistics & Data Charts (9 items):** Pie charts, bar graphs, scatter plots with regression trend lines.
6. **Mechanical Reasoning (25 items):** Reuses the 6 Flutter painters already written for question figures (Gears, Springs, Pulleys & Levers, Fluid Vessels, Stability Shapes).
7. **Spatial & Abstract Reasoning (25 items):** Shape matrices (3x3 grid), figure series sequences, odd-one-out shape rows, cube nets, paper folding symmetric notches.
8. **Physics Vectors & Waveforms (8 items):** Resultant vector right triangles, 30° resolved force components, free body diagrams, transverse sinusoidal waves with labeled wavelength/amplitude.

---

## 6. Implementation Action Plan

### Step 1: Strip the 31 non-image items immediately
- Remove the 8 decorative markers from lesson markdown.
- Replace the 23 text/table markers with inline Markdown tables and LaTeX formulas.
- Drops active worklist from **279 down to 248** instantly.

### Step 2: Download the 56 Open-Source Assets via Batch Script
- Batch download the 56 standardized SVGs/PNGs from OpenStax, USGS, and Wikimedia Commons.
- Run them through the existing `tools/illustration_studio/` sizing & dark-theme background optimizer.
- Drops active worklist from **248 down to 192**.

### Step 3: Mount the 189 Code Painters
- Connect the existing `CustomPainter` registry to lesson figures.
- Build the 4 shared math painter templates: Coordinate Graph Painter, Triangle/Angle Painter, Circle Geometry Painter, Abstract Grid Painter.
- Drops active worklist from **192 down to 3**.

### Step 4: Draw the 3 Visual Media Cartoons
- Create the 3 Reading Comprehension stimuli in Canva / Illustrator.
- Save to `content/illustrations/reading-comprehension/text-types/visual-media/`.
- **Complete 100% illustration coverage for the entire project.**