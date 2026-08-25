# Lesson Content QA R1

**Status:** In progress  
**Base SHA:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**QA branch:** `web/content-qa-lessons-r1`  
**Corpus:** `content/lessons/**.md`  
**Web-source access date:** 2026-08-25

This ledger records the source-referenced QA pass over the complete student-facing lesson corpus. It does not authorize question-bank, illustration, application-code, Sanity, or `main` changes.

## Method and disposition

Every lesson receives an explicit factual, wording/tone, pedagogy, source, edit, and unresolved-issue disposition. Numerical examples are independently re-derived. Scientific simplifications are retained only when they remain materially correct at the lesson's level.

- `VERIFIED` — checked against appropriate sources and examples; no content change required.
- `CORRECTED` — a factual, mathematical, scientific, terminology, scope, or pedagogical defect was edited.
- `CLARIFIED` — wording was edited to remove a misleading implication or unsupported absolute without changing the core taught result.
- `NEEDS PRODUCT DECISION` — would require curriculum/product judgment rather than an evidence-determined repair.
- `SOURCE INSUFFICIENT` — authoritative support could not be established.

## Durable source bibliography

| Code | Organization | Source/document | URL | Used for |
|---|---|---|---|---|
| PH-RA6713 | Republic of the Philippines / Lawphil | Republic Act No. 6713 | https://lawphil.net/statutes/repacts/ra1989/ra_6713_1989.html | Conduct, duties, prohibited acts, SALN, divestment, penalties |
| PH-CONST | Republic of the Philippines / Lawphil | 1987 Philippine Constitution | https://lawphil.net/consti/cons1987.html | Bill of Rights, commissions, impeachment/accountability, article structure |
| PH-CSC-2026 | Civil Service Commission | Examination Announcement No. 03, s. 2026 — 09 August 2026 CSE-PPT | https://csc.gov.ph/examination-advisories/examination-announcement-no-03-s-2026-conduct-of-career-service-examination-pen-and-paper-test-cse-ppt-for-professional-and-subprofessional-levels-09-august-2026 | Current public CSE scope; prevents invented lesson-frequency claims |
| ICRC-IHL | International Committee of the Red Cross | IHL and international human-rights-law references | https://www.icrc.org/en/document/ihl-human-rights-law | IHL/HRL scope and overlap |
| OX-PREALG | OpenStax | Prealgebra 2e | https://openstax.org/details/books/prealgebra-2e | Arithmetic, factors, fractions, percent, number properties |
| OX-ALG | OpenStax | College Algebra 2e / Algebra and Trigonometry | https://openstax.org/details/books/college-algebra-2e | Algebra, functions, quadratics, logs, rational functions, sequences |
| OX-PRECALC | OpenStax | Precalculus 2e | https://openstax.org/details/books/precalculus-2e | Trigonometry, inverse trig, conics, function conditions |
| OX-CALC | OpenStax | Calculus Volume 1 | https://openstax.org/details/books/calculus-volume-1 | Limits, derivatives, integrals, FTC conditions |
| OX-STATS | OpenStax | Introductory Statistics 2e | https://openstax.org/details/books/introductory-statistics-2e | Probability, variability, center, graph interpretation, combinatorics |
| OX-BIO | OpenStax | Biology 2e | https://openstax.org/details/books/biology-2e | Cells, metabolism, meiosis, genetics, ecology, evolution, plant biology, taxonomy |
| OX-A&P | OpenStax | Anatomy and Physiology 2e | https://openstax.org/details/books/anatomy-and-physiology-2e | Human systems, endocrine, urinary, immune, digestive physiology |
| OX-CHEM | OpenStax | Chemistry 2e | https://openstax.org/details/books/chemistry-2e | Matter, mole, stoichiometry, pH, bonding, atomic structure, kinetics, nomenclature |
| OX-PHYS1 | OpenStax | University Physics Volume 1 | https://openstax.org/details/books/university-physics-volume-1 | Mechanics, fluids, gravity, waves, work/energy |
| OX-PHYS2 | OpenStax | University Physics Volume 2 | https://openstax.org/details/books/university-physics-volume-2 | Thermodynamics, electricity, circuits, magnetism, induction |
| OX-PHYS3 | OpenStax | University Physics Volume 3 | https://openstax.org/details/books/university-physics-volume-3 | Geometric optics, refraction, lenses, total internal reflection |
| USGS-DYNAMIC | U.S. Geological Survey | This Dynamic Earth | https://pubs.usgs.gov/gip/dynamic/understanding.html | Plate tectonics, seafloor spreading, subduction |
| USGS-WATER | U.S. Geological Survey | Water Science School / water cycle | https://www.usgs.gov/special-topics/water-science-school/science/water-cycle | Earth water reservoirs and cycle |
| NPS-FOSSILS | U.S. National Park Service | What Is a Fossil? | https://www.nps.gov/subjects/fossils/what-is-a-fossil.htm | Fossils, preservation, geologic interpretation |
| NASA-BIGBANG | NASA | Webb Big Bang Q&A | https://science.nasa.gov/mission/webb/big-bang-q-and-a/ | Expansion/hot dense early universe; avoids explosion-in-space model |
| NASA-METEORS | NASA | Meteors & Meteorites Facts | https://science.nasa.gov/solar-system/meteors-meteorites/facts/ | Meteoroid/meteor/meteorite terminology |
| NASA-SOLAR | NASA | Solar System formation resources | https://science.nasa.gov/solar-system/ | Solar-system formation and astronomical terminology |
| NASA-CLIMATE | NASA | Climate / greenhouse-effect evidence | https://science.nasa.gov/climate-change/ | Greenhouse effect and climate-change mechanisms |
| PAGASA-CLIMATE | DOST-PAGASA | Climate advisories and Philippine climate information | https://www.pagasa.dost.gov.ph/climate/climate-advisories | Amihan/Habagat and Philippine climate framing |

## Substantive correction ledger

The rows below document every lesson edited through the current 109-lesson checkpoint. Each row records the material issue addressed; minor grammar cleanup inside the same file is not separately itemized.

### General Information

| Lesson | Issue corrected | Result | Source(s) | Disposition |
|---|---|---|---|---|
| `general-information/code-of-conduct-ra-6713/duties-and-prohibited-acts.md` | Annual-report, 15-working-day response, signatory, and public-document duties were overgeneralized. | Duties now follow RA 6713 §5's actual actors, timing, and qualifications. | PH-RA6713 | CORRECTED |
| `general-information/code-of-conduct-ra-6713/penalties-and-enforcement.md` | The up-to-₱25,000 provision was presented as a generic official penalty. | It is tied to the specific §11(d) civil action for prohibited use of filed statements. | PH-RA6713 | CORRECTED |
| `general-information/code-of-conduct-ra-6713/statements-of-assets-and-divestment.md` | SALN filing offices, inspection/copy timing, and divestment triggers were simplified incorrectly. | Filing, inspection, reproduction, and divestment rules now track §§8-9. | PH-RA6713 | CORRECTED |
| `general-information/environment-management/environmental-concepts.md` | ECC scope implied a general approval for any major development. | ECC discussion is tied to the Philippine EIS/covered-project framework. | DENR/EMB framework reviewed during pass | CLARIFIED |
| `general-information/environment-management/the-environmental-laws.md` | Statutes were framed as guaranteed CSC item content; NIPAS/incineration details needed updating. | Statutes remain preparation examples within the official broad environment scope, with current legal qualifications. | PH-CSC-2026; Philippine statutes | CLARIFIED |
| `general-information/peace-and-human-rights/humanitarian-law-and-human-rights-law.md` | IHL and HRL were treated as mutually exclusive by peacetime/war. | IHL applies in armed conflict while HRL can continue to apply subject to its own rules. | ICRC-IHL | CORRECTED |
| `general-information/philippine-constitution/bill-of-rights.md` | §§12-22 were grouped simply as rights of an accused; just-compensation coverage was incomplete. | Provisions are framed as criminal-process and related protections with broader applications preserved. | PH-CONST | CLARIFIED |
| `general-information/philippine-constitution/the-articles-in-outline.md` | Memorizing the article map was called a fundamental CSC requirement. | The map is useful preparation without inventing confidential test specifications. | PH-CONST; PH-CSC-2026 | CLARIFIED |

### Mathematics

| Lesson | Issue corrected | Result | Source(s) | Disposition |
|---|---|---|---|---|
| `mathematics/arithmetic-number-sense/business-math.md` | Rule of 72 was placed under simple interest; markup was equated with profit. | Rule of 72 is limited to approximate compound/exponential growth; simple-interest doubling and markup/profit distinctions are correct. | OX-ALG | CORRECTED |
| `mathematics/arithmetic-number-sense/divisibility-rules.md` | Zero/divisor wording omitted the nonzero-divisor restriction; rule-of-7 explanation was incomplete. | Divisibility language and rule conditions are explicit. | OX-PREALG | CORRECTED |
| `mathematics/arithmetic-number-sense/fractions-decimals-percentages.md` | Exact fractions and rounded decimal/percent approximations were blurred. | Exact versus approximate representations are distinguished. | OX-PREALG | CLARIFIED |
| `mathematics/arithmetic-number-sense/order-of-operations.md` | Mnemonic wording risked permitting invalid regrouping. | Equal-precedence operations remain left-to-right; unary negatives are distinguished from exponentiation. | OX-PREALG | CLARIFIED |
| `mathematics/arithmetic-number-sense/prime-factorization-gcf-lcm.md` | Multi-number continuous-division shortcut could overcount LCM; remainder example's claimed minimum was false. | Highest-prime-power LCM method is used and the example excludes the trivial smaller solution. | OX-PREALG | CORRECTED |
| `mathematics/arithmetic-number-sense/properties-of-real-numbers.md` | Multiplicative inverse omitted `a != 0`. | Reciprocal/inverse statements carry the required restriction. | OX-PREALG | CORRECTED |
| `mathematics/arithmetic-number-sense/ratio-and-proportion.md` | Direct/inverse proportion were defined by arithmetic tricks instead of constant ratio/product. | Uses `y=kx` and `xy=k` with model assumptions stated. | OX-ALG | CORRECTED |
| `mathematics/arithmetic-number-sense/real-imaginary-numbers.md` | `bi` was called the imaginary part; one natural-number convention was treated as universal. | Imaginary part is coefficient `b`; zero-in-natural-number convention is stated rather than universalized. | OX-ALG | CORRECTED |
| `mathematics/arithmetic-number-sense/sequences-and-series.md` | Infinite-geometric convergence and divergent “sum” language were wrong. | Finite infinite sum requires `|r|<1`; otherwise the series diverges. | OX-ALG | CORRECTED |
| `mathematics/algebra/exponents-and-logarithms.md` | Log/exponent identities lacked base, argument, and domain conditions. | Real-log restrictions are explicit. | OX-ALG | CORRECTED |
| `mathematics/algebra/functions-and-relations.md` | Domain restrictions were reduced to denominator/even-root cases; inverse functions omitted one-to-one condition. | Domain and invertibility conditions are complete for the taught level. | OX-ALG | CORRECTED |
| `mathematics/algebra/linear-equations-inequalities.md` | Linear-definition and slope/perpendicular shortcuts omitted edge cases. | One/two-variable distinctions, `B != 0`, and vertical/horizontal cases are explicit. | OX-ALG | CORRECTED |
| `mathematics/algebra/polynomials.md` | Polynomial exponent and synthetic-division wording was imprecise. | Nonnegative integer exponents and standard `x-c` synthetic division are taught. | OX-ALG | CLARIFIED |
| `mathematics/algebra/quadratic-equations.md` | Completing-square procedure assumed monic form; negative discriminant was called “imaginary”; sign shortcut ignored `a`. | Procedure divides by `a` when needed; roots and `c/a` conditions are correct. | OX-ALG | CORRECTED |
| `mathematics/algebra/radicals-and-rationalization.md` | `sqrt(x^2)=x` and radical shortcuts omitted domain/absolute-value conditions. | Uses `sqrt(x^2)=|x|` and states real-domain conditions. | OX-ALG | CORRECTED |
| `mathematics/algebra/sets-and-set-notation.md` | Two-set inclusion-exclusion was labeled the total universe. | Formula is correctly identified as `|A∪B|`; “neither” can lie outside the union. | OX-ALG | CORRECTED |
| `mathematics/algebra/types-of-functions.md` | Rational-function definition and “asymptotes are never crossed” claim were false. | Rational functions are polynomial quotients; horizontal/oblique asymptotes can be crossed. | OX-ALG | CORRECTED |
| `mathematics/geometry/basic-geometric-concepts.md` | Distinct-point and angle-definition conditions were omitted. | Standard Euclidean definitions are explicit. | OX-ALG / geometry reference used in pass | CORRECTED |
| `mathematics/geometry/coordinate-geometry.md` | Negative-reciprocal/product-`-1` rule ignored undefined slopes. | Vertical/horizontal perpendicular case is explicit. | OX-PRECALC | CORRECTED |
| `mathematics/geometry/quadrilaterals-and-polygons.md` | Exclusive trapezoid definition was presented as universal. | The lesson declares its convention and notes the inclusive alternative. | OX-ALG / geometry reference used in pass | CLARIFIED |
| `mathematics/trigonometry/inverse-trigonometric-functions.md` | Principal ranges/endpoints were described too loosely. | Standard principal domains/ranges, including boundary values, are explicit. | OX-PRECALC | CORRECTED |
| `mathematics/trigonometry/solving-right-triangles.md` | Shortcut wording treated special cases too broadly. | Trig ratios and special-case shortcuts are limited to their valid triangle/angle conditions. | OX-PRECALC | CORRECTED |
| `mathematics/trigonometry/trigonometric-identities.md` | Algebraic identity simplifications ignored points where denominators make expressions undefined. | Identity use preserves the common domain of both expressions. | OX-PRECALC | CORRECTED |
| `mathematics/trigonometry/unit-circle.md` | Special-angle/quadrant wording blurred axis endpoints and principal-angle conventions. | Unit-circle coordinates and boundary-angle handling are explicit. | OX-PRECALC | CORRECTED |
| `mathematics/statistics-and-probability/basic-probability.md` | Independence/mutual-exclusivity and conditional rules were overgeneralized. | Addition/multiplication rules now state their required conditions. | OX-STATS | CORRECTED |
| `mathematics/statistics-and-probability/combinatorics.md` | Counting/permutation/combination shortcuts omitted repetition/order conditions. | Method selection is tied to whether order matters and whether repetition is permitted. | OX-STATS | CORRECTED |
| `mathematics/statistics-and-probability/data-analysis-graphs.md` | Correlation language could imply causation or only linear association. | Correlation is separated from causation and graph interpretation considers nonlinear patterns. | OX-STATS | CORRECTED |
| `mathematics/statistics-and-probability/measures-of-central-tendency.md` | Mean/median/mode robustness and applicability were stated too absolutely. | Center measures are compared with distribution/outlier context. | OX-STATS | CORRECTED |
| `mathematics/statistics-and-probability/measures-of-variability.md` | Sample/population variance denominators, SD scaling, and probability claims from mean/SD alone were wrong or incomplete. | `n-1` vs `N`, `|a|` scaling, and distribution assumptions are explicit. | OX-STATS | CORRECTED |
| `mathematics/precalculus-basic-calculus/basic-derivatives.md` | Power/quotient/chain-rule examples omitted differentiability/domain restrictions. | Derivative rules are stated on valid domains. | OX-CALC | CORRECTED |
| `mathematics/precalculus-basic-calculus/basic-integrals.md` | Definite-integral “area” language ignored sign; FTC use omitted continuity conditions. | Definite integral is signed accumulation; FTC conditions are explicit. | OX-CALC | CORRECTED |
| `mathematics/precalculus-basic-calculus/conic-sections.md` | Standard forms and center/vertex/focus cues were overgeneralized. | Circle/parabola/ellipse/hyperbola forms are tied to their actual parameters and orientation. | OX-PRECALC | CORRECTED |
| `mathematics/precalculus-basic-calculus/limits-and-continuity.md` | Direct substitution and infinity/degree shortcuts were treated as universal. | Continuity, one-sided behavior, and finite-vs-unbounded limits are distinguished. | OX-CALC | CORRECTED |
| `mathematics/data-interpretation/rates-ratios-and-percentages-in-context.md` | Percentage change omitted zero-baseline restriction and ratio wording allowed unlike quantities without unit handling. | Percent change requires a nonzero reference value; rate/ratio units are made explicit. | OX-PREALG / OX-STATS | CORRECTED |

### Science — Earth Science and Astronomy

| Lesson | Issue corrected | Result | Source(s) | Disposition |
|---|---|---|---|---|
| `science/earth-science-astronomy/earths-motions.md` | Gregorian leap-year exceptions, solar/sidereal day distinctions, and seasonal causes were simplified. | Calendar rule and Earth-motion terminology are correct; seasons are tied to axial tilt. | NASA-SOLAR | CORRECTED |
| `science/earth-science-astronomy/earths-subsystems.md` | Atmosphere/hydrosphere/geosphere/biosphere were treated as mutually exclusive containers. | Spheres are interacting Earth-system categories whose boundaries can overlap. | USGS-WATER / NASA Earth-system references reviewed | CORRECTED |
| `science/earth-science-astronomy/fossils-and-geologic-time.md` | Radioactive decay was said to always produce a stable daughter; Earth age/geologic-time wording and fossil interpretation needed qualification. | Decay chains, ~4.54-billion-year Earth age, Precambrian umbrella use, and fossil reworking are represented correctly. | NPS-FOSSILS; USGS geologic-time references | CORRECTED |
| `science/earth-science-astronomy/heavenly-bodies.md` | Meteor was defined as the physical chunk; comet/meteor terminology was blurred. | Meteoroid is the space object, meteor the atmospheric luminous phenomenon, meteorite material that reaches the ground. | NASA-METEORS | CORRECTED |
| `science/earth-science-astronomy/layers-of-the-earth.md` | Continental crust thickness was presented near its maximum as typical; direct drilling was overstated. | Average crust scales and seismic evidence for deep Earth are distinguished. | USGS-DYNAMIC / USGS crust references reviewed | CORRECTED |
| `science/earth-science-astronomy/minerals-and-rocks.md` | Mineral definition omitted inorganic; granite→limestone→marble path was geologically invalid as written. | Standard mineral criteria and a valid granite-derived sediment→sandstone→quartzite path are used. | USGS geology references reviewed | CORRECTED |
| `science/earth-science-astronomy/origin-of-the-universe.md` | Big Bang was depicted like an explosion from a central point into pre-existing space and blended with Solar-System formation. | Hot dense early-universe expansion is separated from later solar-nebula formation. | NASA-BIGBANG; NASA-SOLAR | CORRECTED |
| `science/earth-science-astronomy/plate-tectonics.md` | Seafloor spreading was called the single plate-driving force; subduction volcanism was explained as the slab simply melting. | Plate motion uses multiple mantle/lithosphere forces; slab-released volatiles promote mantle-wedge melting. | USGS-DYNAMIC | CORRECTED |
| `science/earth-science-astronomy/weather-and-climate.md` | Monsoon timing/coverage, tropical-cyclone relation, and greenhouse-effect mechanism were overgeneralized. | PAGASA framing is used for Amihan/Habagat; greenhouse effect uses outgoing infrared absorption/re-emission. | PAGASA-CLIMATE; NASA-CLIMATE | CORRECTED |

### Science — Biology

| Lesson | Issue corrected | Result | Source(s) | Disposition |
|---|---|---|---|---|
| `science/biology/botany.md` | Xylem/phloem cell composition and one-way phloem transport were overgeneralized; pollen was equated with male sex cells. | Conducting-cell distinctions, source-to-sink phloem transport, and pollen/sperm roles are accurate. | OX-BIO | CORRECTED |
| `science/biology/cell-biology.md` | “Plant-only” organelles, osmosis, tonicity, and active transport were stated too absolutely. | Plant/animal comparisons and membrane-transport conditions are qualified. | OX-BIO | CORRECTED |
| `science/biology/cellular-metabolism.md` | Cellular respiration was made synonymous with oxygen-dependent mitochondrial respiration. | Glycolysis location and aerobic/anaerobic pathways are distinguished. | OX-BIO | CORRECTED |
| `science/biology/cellular-reproduction.md` | Meiosis was said to always yield four equivalent sex cells. | Ploidy reduction, genetic variation, spermatogenesis, and the asymmetric products of human oogenesis are distinguished. | OX-BIO | CORRECTED |
| `science/biology/characteristics-of-life.md` | Life/virus checklist language was too categorical. | Characteristics are presented as biological criteria with viruses treated as a boundary case, not a scorecard. | OX-BIO | CORRECTED |
| `science/biology/ecology.md` | “10% rule” was treated as exact; nitrogen fixation and nitrification were conflated; trophic/symbiosis categories were rigid. | Ecological efficiency is approximate and nitrogen-cycle steps are distinct. | OX-BIO | CORRECTED |
| `science/biology/evolution.md` | Natural selection was presented as the sole evolutionary mechanism; geographic isolation as the definition of speciation; Wallace omitted. | Selection is one mechanism among mutation/drift/gene flow; multiple speciation routes and Wallace/Darwin history are represented. | OX-BIO | CORRECTED |
| `science/biology/genetics-and-heredity.md` | Independent assortment ignored linkage; Punnett ratios were treated as guarantees; codon wording was imprecise. | Linkage/recombination and probability interpretation are explicit; codons are three-base mRNA units. | OX-BIO | CORRECTED |
| `science/biology/human-anatomy-physiology.md` | Urinary system was equated with all excretion; “master gland” hierarchy, bile, immunity, and organ-system exclusivity were oversimplified. | Endocrine control, bile emulsification, urinary role, immune cells, and multi-system organs are accurate. | OX-A&P | CORRECTED |
| `science/biology/taxonomy-and-classification.md` | `Protista` was presented as a settled modern kingdom and the second binomial word as the species name by itself. | Phylogenetic classification and the genus + specific-epithet convention are used. | OX-BIO | CORRECTED |

### Science — Chemistry

| Lesson | Issue corrected | Result | Source(s) | Disposition |
|---|---|---|---|---|
| `science/chemistry/matter.md` | State/plasma and phase-change descriptions used overbroad particle/temperature wording. | States and phase changes are framed as models with pressure/condition dependence. | OX-CHEM | CORRECTED |
| `science/chemistry/gas-laws.md` | Ideal gas laws were taught without idealization limits; Celsius→Kelvin shortcut/absolute-zero explanation was imprecise. | Gas-law assumptions and exact `T(K)=T(°C)+273.15` are stated. | OX-CHEM | CORRECTED |
| `science/chemistry/solutions.md` | Solid solubility was said to increase with temperature as a rule; liquid volumes were implicitly additive. | Solubility temperature dependence is substance-specific; concentration definitions use final solution quantities. | OX-CHEM | CORRECTED |
| `science/chemistry/mole-concept.md` | Avogadro's number was described only as an approximation defining a mole. | The mole uses the exact SI-defined Avogadro constant `6.02214076×10^23 mol^-1`; rounded values are calculation approximations. | OX-CHEM / SI definition cross-check | CORRECTED |
| `science/chemistry/stoichiometry.md` | Empirical-formula method said dividing by the smallest amount always produces whole numbers; percent yield over 100% was treated as impossible. | Fractional ratios may need further multiplication; apparent >100% yield can signal impurities/measurement problems. | OX-CHEM | CORRECTED |
| `science/chemistry/acids-bases-ph.md` | pH was fixed to 0–14 with neutral always 7; Brønsted acid-base reactions were all reduced to salt + water. | pH can lie outside 0–14; neutral pH depends on temperature; broader proton-transfer reactions are distinguished. | OX-CHEM | CORRECTED |
| `science/chemistry/periodic-table.md` | Same-group valence-electron and electron-affinity arrow rules were made universal. | Representative-element group trends are separated from transition-element exceptions; electron affinity is not taught as one clean universal arrow. | OX-CHEM | CORRECTED |
| `science/chemistry/atomic-structure.md` | Electrons were depicted as particles orbiting the nucleus on paths. | Modern electron probability/orbital language replaces the planetary-path implication. | OX-CHEM | CORRECTED |
| `science/chemistry/nuclear-chemistry.md` | “Beta decay” meant only beta-minus; gamma shielding and fusion-vs-fission energy claims were absolute. | `β−`, `β+`, electron capture, attenuation, and reaction-specific energy release are distinguished. | OX-CHEM | CORRECTED |
| `science/chemistry/chemical-bonding.md` | Octet rule, metal/nonmetal bond shortcut, and electronegativity cutoffs were presented as universal boundaries. | They are useful introductory heuristics with known exceptions and continuous polarity behavior. | OX-CHEM | CORRECTED |
| `science/chemistry/chemical-reactions.md` | Five reaction “types” were presented as exhaustive/disjoint; oxygen + hydrocarbon implied complete combustion; double replacement lacked a driving-force condition. | Classification is a classroom scheme with overlap; complete combustion and precipitation/gas/weak-electrolyte drivers are distinguished. | OX-CHEM | CORRECTED |
| `science/chemistry/history-of-the-atom.md` | Rutherford/Schrödinger were credited as isolated discoverers and Bohr's model was generalized beyond its successful scope. | Geiger-Marsden/Rutherford and collaborative quantum-history context is restored; Bohr scope is hydrogen-like spectra. | OX-CHEM | CORRECTED |
| `science/chemistry/chemical-nomenclature.md` | Ionic naming was reduced to metal + nonmetal; criss-cross was taught without reducing subscripts; prefix scope was too broad. | Polyatomic/ammonium compounds, Stock notation, lowest whole-number ratios, and binary molecular naming scope are explicit. | OX-CHEM | CORRECTED |
| `science/chemistry/mixtures-and-separation.md` | Distillation was described as lower-boiling component simply evaporating first; chromatography/filtration rules were too absolute. | Vapor-liquid equilibrium, fractional separation limits, phase interactions, and method conditions are stated. | OX-CHEM | CORRECTED |
| `science/chemistry/basic-organic-chemistry.md` | “Saturated = every bonding spot filled with hydrogen” and “longest chain always parent” were overgeneralized. | Saturation refers to C-C multiple bonds in the taught hydrocarbon context; IUPAC parent selection accounts for principal groups/multiple bonds. | OX-CHEM | CORRECTED |
| `science/chemistry/thermodynamics-and-kinetics.md` | Higher activation energy was directly equated with slower rate; catalyst was said never to affect final product amount; concentration/surface-area effects were universalized. | Rate depends on kinetics/rate law; catalyst changes approach to equilibrium but not equilibrium constant/composition; rate-factor claims are conditional. | OX-CHEM | CORRECTED |
| `science/chemistry/quantum-numbers-electron-configuration.md` | `s,p,d,f` subshells were called orbitals that hold 2/6/10/14 e−; title promised quantum numbers but omitted them. | One orbital holds at most 2 e−; subshell capacities and all four quantum numbers are taught. | OX-CHEM | CORRECTED |

### Science — Physics

| Lesson | Issue corrected | Result | Source(s) | Disposition |
|---|---|---|---|---|
| `science/physics/scalars-and-vectors.md` | “Direction word means vector” shortcut confused quantity type with wording; component formulas lacked angle-reference conditions. | Scalar/vector classification is based on the physical quantity; components follow the actual reference angle. | OX-PHYS1 | CORRECTED |
| `science/physics/kinematics.md` | Constant-acceleration equations and displacement/distance language lacked conditions; squared-velocity equation hid direction ambiguity. | Formula domain, sign conventions, and displacement are explicit. | OX-PHYS1 | CORRECTED |
| `science/physics/two-dimensional-motion.md` | Projectile peak and centripetal-force explanations encouraged zero-acceleration/new-force misconceptions. | Peak has zero vertical velocity but downward acceleration; centripetal force is the net inward component of real forces. | OX-PHYS1 | CORRECTED |
| `science/physics/dynamics.md` | Friction model was universalized and third-law book/table pair was described via weight “transmission.” | Dry-friction coefficients are empirical models; third-law contact forces are distinguished from weight/normal equilibrium. | OX-PHYS1 | CORRECTED |
| `science/physics/momentum-and-impulse.md` | `J=Ft` was presented as universal rather than constant/average-force form. | Impulse is `∫F dt = Δp`; average force × interval is the simplified form. | OX-PHYS1 | CORRECTED |
| `science/physics/work-energy-power.md` | `W=Fd` and `mgh` were universalized; frictional mechanical-energy loss was described as energy loss. | Uses `Fd cosθ`, near-Earth `mgh`, and nonconservative-work mechanical-energy accounting. | OX-PHYS1 | CORRECTED |
| `science/physics/gravity-and-keplers-laws.md` | Kepler example incorrectly said a 4× period implies >4× orbital distance; used vague average distance. | Uses semimajor axis and obtains `a_A/a_B=16^(1/3)≈2.52`. | OX-PHYS1 | CORRECTED |
| `science/physics/fluid-mechanics.md` | Bernoulli's “faster = lower pressure” and equal-transit-time curved-wing story were presented as universal. | Bernoulli assumptions and full pressure-speed-height relation are stated; lift uses pressure distribution/momentum deflection without equal-transit myth. | OX-PHYS1 | CORRECTED |
| `science/physics/thermodynamics.md` | Heat was treated as stored substance; first/second/third laws and `Q=mcΔT` conditions were incomplete; oil/water example failed to control mass. | Heat is transfer, first-law sign convention is explicit, entropy/third-law wording is qualified, phase changes and equal-mass comparison are handled. | OX-PHYS2 | CORRECTED |
| `science/physics/waves-and-sound.md` | Transverse-wave explanation treated light as medium particles oscillating; amplitude/energy and sound speed/Doppler statements were overbroad. | EM fields, amplitude-squared scaling, medium-dependent sound speed, and source/observer Doppler distinctions are explicit. | OX-PHYS1 | CORRECTED |
| `science/physics/light-and-optics.md` | Lens shape was treated as universally determining convergence; Snell/index conditions were omitted. | Snell's law, frequency/wavelength behavior, critical angle, geometric-optics scope, and relative-index lens condition are taught. | OX-PHYS3 | CORRECTED |
| `science/physics/electricity-and-magnetism.md` | Ohm's law was universalized; changing magnetic field was said to directly create current; Lenz/magnet analogies were overbroad. | Ohmic-component scope, resistor-network assumptions, Faraday emf, Lenz opposition to flux change, and closed-path requirement are explicit. | OX-PHYS2 | CORRECTED |

## Per-lesson inventory through 109 / 158

All rows below received a complete factual/example, tone/wording, pedagogy, and source pass. `Edited=no` means the lesson was checked and retained as-is.

| Domain | Lesson | Source status | Edited | Unresolved | Status |
|---|---|---|---|---|---|
| General Information | `code-of-conduct-ra-6713/duties-and-prohibited-acts` | primary statute | yes | none | CORRECTED |
| General Information | `code-of-conduct-ra-6713/norms-of-conduct` | primary statute | no | none | VERIFIED |
| General Information | `code-of-conduct-ra-6713/penalties-and-enforcement` | primary statute | yes | none | CORRECTED |
| General Information | `code-of-conduct-ra-6713/statements-of-assets-and-divestment` | primary statute | yes | none | CORRECTED |
| General Information | `environment-management/environmental-concepts` | official/primary Philippine sources | yes | none | CLARIFIED |
| General Information | `environment-management/the-environmental-laws` | official/primary Philippine sources | yes | none | CLARIFIED |
| General Information | `peace-and-human-rights/human-rights-fundamentals` | primary/ICRC | no | none | VERIFIED |
| General Information | `peace-and-human-rights/humanitarian-law-and-human-rights-law` | ICRC | yes | none | CORRECTED |
| General Information | `philippine-constitution/accountability-and-impeachment` | primary Constitution | no | none | VERIFIED |
| General Information | `philippine-constitution/bill-of-rights` | primary Constitution | yes | none | CLARIFIED |
| General Information | `philippine-constitution/the-articles-in-outline` | Constitution + CSC | yes | none | CLARIFIED |
| General Information | `philippine-constitution/the-civil-service-commission` | primary Constitution | no | none | VERIFIED |
| Mathematics / Arithmetic | `business-math` | OpenStax/standard math | yes | none | CORRECTED |
| Mathematics / Arithmetic | `divisibility-rules` | OpenStax/standard math | yes | none | CORRECTED |
| Mathematics / Arithmetic | `fractions-decimals-percentages` | OpenStax/standard math | yes | none | CLARIFIED |
| Mathematics / Arithmetic | `order-of-operations` | standard convention | yes | none | CLARIFIED |
| Mathematics / Arithmetic | `prime-factorization-gcf-lcm` | OpenStax | yes | none | CORRECTED |
| Mathematics / Arithmetic | `properties-of-real-numbers` | OpenStax/standard math | yes | none | CORRECTED |
| Mathematics / Arithmetic | `ratio-and-proportion` | OpenStax | yes | none | CORRECTED |
| Mathematics / Arithmetic | `real-imaginary-numbers` | OpenStax | yes | none | CORRECTED |
| Mathematics / Arithmetic | `sequences-and-series` | OpenStax | yes | none | CORRECTED |
| Mathematics / Algebra | `algebraic-expressions` | OpenStax/standard math | no | none | VERIFIED |
| Mathematics / Algebra | `exponents-and-logarithms` | OpenStax | yes | none | CORRECTED |
| Mathematics / Algebra | `functions-and-relations` | OpenStax | yes | none | CORRECTED |
| Mathematics / Algebra | `linear-equations-inequalities` | OpenStax | yes | none | CORRECTED |
| Mathematics / Algebra | `polynomials` | OpenStax | yes | none | CLARIFIED |
| Mathematics / Algebra | `quadratic-equations` | OpenStax | yes | none | CORRECTED |
| Mathematics / Algebra | `radicals-and-rationalization` | OpenStax | yes | none | CORRECTED |
| Mathematics / Algebra | `sets-and-set-notation` | standard math | yes | none | CORRECTED |
| Mathematics / Algebra | `systems-of-equations` | OpenStax/standard math | no | none | VERIFIED |
| Mathematics / Algebra | `types-of-functions` | OpenStax | yes | none | CORRECTED |
| Mathematics / Algebra | `word-problems` | OpenStax/standard math | no | none | VERIFIED |
| Mathematics / Geometry | `basic-geometric-concepts` | OpenStax/standard geometry | yes | none | CORRECTED |
| Mathematics / Geometry | `circles` | OpenStax/standard geometry | no | none | VERIFIED |
| Mathematics / Geometry | `coordinate-geometry` | OpenStax | yes | none | CORRECTED |
| Mathematics / Geometry | `logic-and-reasoning` | standard propositional logic | no | none | VERIFIED |
| Mathematics / Geometry | `measurement` | OpenStax/standard geometry | no | none | VERIFIED |
| Mathematics / Geometry | `parallel-perpendicular-lines` | OpenStax/standard geometry | no | none | VERIFIED |
| Mathematics / Geometry | `quadrilaterals-and-polygons` | OpenStax/standard geometry | yes | none | CLARIFIED |
| Mathematics / Geometry | `triangles` | OpenStax/standard geometry | no | none | VERIFIED |
| Mathematics / Trigonometry | `angles-and-radian-measure` | OX-PRECALC | no | none | VERIFIED |
| Mathematics / Trigonometry | `basic-trigonometric-ratios` | OX-PRECALC | no | none | VERIFIED |
| Mathematics / Trigonometry | `inverse-trigonometric-functions` | OX-PRECALC | yes | none | CORRECTED |
| Mathematics / Trigonometry | `laws-of-sines-and-cosines` | OX-PRECALC | no | none | VERIFIED |
| Mathematics / Trigonometry | `solving-right-triangles` | OX-PRECALC | yes | none | CORRECTED |
| Mathematics / Trigonometry | `trigonometric-identities` | OX-PRECALC | yes | none | CORRECTED |
| Mathematics / Trigonometry | `unit-circle` | OX-PRECALC | yes | none | CORRECTED |
| Mathematics / Statistics | `basic-probability` | OX-STATS | yes | none | CORRECTED |
| Mathematics / Statistics | `combinatorics` | OX-STATS | yes | none | CORRECTED |
| Mathematics / Statistics | `data-analysis-graphs` | OX-STATS | yes | none | CORRECTED |
| Mathematics / Statistics | `measures-of-central-tendency` | OX-STATS | yes | none | CORRECTED |
| Mathematics / Statistics | `measures-of-variability` | OX-STATS | yes | none | CORRECTED |
| Mathematics / Precalculus & Calculus | `basic-derivatives` | OX-CALC | yes | none | CORRECTED |
| Mathematics / Precalculus & Calculus | `basic-integrals` | OX-CALC | yes | none | CORRECTED |
| Mathematics / Precalculus & Calculus | `conic-sections` | OX-PRECALC | yes | none | CORRECTED |
| Mathematics / Precalculus & Calculus | `limits-and-continuity` | OX-CALC | yes | none | CORRECTED |
| Mathematics / Data Interpretation | `rates-ratios-and-percentages-in-context` | OpenStax | yes | none | CORRECTED |
| Mathematics / Data Interpretation | `tables-and-charts` | OX-STATS/standard interpretation | no | none | VERIFIED |
| Science / Earth Science & Astronomy | `earths-motions` | NASA/authoritative Earth science | yes | none | CORRECTED |
| Science / Earth Science & Astronomy | `earths-subsystems` | USGS/NASA | yes | none | CORRECTED |
| Science / Earth Science & Astronomy | `eclipses-and-moon-phases` | NASA | no | none | VERIFIED |
| Science / Earth Science & Astronomy | `fossils-and-geologic-time` | USGS/NPS | yes | none | CORRECTED |
| Science / Earth Science & Astronomy | `heavenly-bodies` | NASA | yes | none | CORRECTED |
| Science / Earth Science & Astronomy | `layers-of-the-earth` | USGS | yes | none | CORRECTED |
| Science / Earth Science & Astronomy | `minerals-and-rocks` | USGS | yes | none | CORRECTED |
| Science / Earth Science & Astronomy | `origin-of-the-universe` | NASA | yes | none | CORRECTED |
| Science / Earth Science & Astronomy | `plate-tectonics` | USGS | yes | none | CORRECTED |
| Science / Earth Science & Astronomy | `water-cycle-oceanography` | USGS | no | none | VERIFIED |
| Science / Earth Science & Astronomy | `weather-and-climate` | PAGASA/NASA | yes | none | CORRECTED |
| Science / Biology | `botany` | OX-BIO | yes | none | CORRECTED |
| Science / Biology | `cell-biology` | OX-BIO | yes | none | CORRECTED |
| Science / Biology | `cellular-metabolism` | OX-BIO | yes | none | CORRECTED |
| Science / Biology | `cellular-reproduction` | OX-BIO | yes | none | CORRECTED |
| Science / Biology | `characteristics-of-life` | OX-BIO | yes | none | CORRECTED |
| Science / Biology | `ecology` | OX-BIO | yes | none | CORRECTED |
| Science / Biology | `evolution` | OX-BIO | yes | none | CORRECTED |
| Science / Biology | `genetics-and-heredity` | OX-BIO | yes | none | CORRECTED |
| Science / Biology | `human-anatomy-physiology` | OX-A&P | yes | none | CORRECTED |
| Science / Biology | `taxonomy-and-classification` | OX-BIO | yes | none | CORRECTED |
| Science / Chemistry | `acids-bases-ph` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `atomic-structure` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `basic-organic-chemistry` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `chemical-bonding` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `chemical-nomenclature` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `chemical-reactions` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `gas-laws` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `history-of-the-atom` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `matter` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `mixtures-and-separation` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `mole-concept` | OX-CHEM/SI | yes | none | CORRECTED |
| Science / Chemistry | `nuclear-chemistry` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `periodic-table` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `quantum-numbers-electron-configuration` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `solutions` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `stoichiometry` | OX-CHEM | yes | none | CORRECTED |
| Science / Chemistry | `thermodynamics-and-kinetics` | OX-CHEM | yes | none | CORRECTED |
| Science / Physics | `dynamics` | OX-PHYS1 | yes | none | CORRECTED |
| Science / Physics | `electricity-and-magnetism` | OX-PHYS2 | yes | none | CORRECTED |
| Science / Physics | `fluid-mechanics` | OX-PHYS1 | yes | none | CORRECTED |
| Science / Physics | `gravity-and-keplers-laws` | OX-PHYS1 | yes | none | CORRECTED |
| Science / Physics | `kinematics` | OX-PHYS1 | yes | none | CORRECTED |
| Science / Physics | `light-and-optics` | OX-PHYS3 | yes | none | CORRECTED |
| Science / Physics | `momentum-and-impulse` | OX-PHYS1 | yes | none | CORRECTED |
| Science / Physics | `scalars-and-vectors` | OX-PHYS1 | yes | none | CORRECTED |
| Science / Physics | `thermodynamics` | OX-PHYS2 | yes | none | CORRECTED |
| Science / Physics | `two-dimensional-motion` | OX-PHYS1 | yes | none | CORRECTED |
| Science / Physics | `units-and-measurements` | SI/OpenStax | no | none | VERIFIED |
| Science / Physics | `waves-and-sound` | OX-PHYS1 | yes | none | CORRECTED |
| Science / Physics | `work-energy-power` | OX-PHYS1 | yes | none | CORRECTED |

## Progress at this checkpoint

- **Audited:** 109 / 158
- **Edited:** 90
- **Verified without content change:** 19
- **Needs product decision:** 0 among audited lessons
- **Source insufficient:** 0 among audited lessons

Completed domains:

- General Information — 12 / 12
- Mathematics — 46 / 46
- Science — 51 / 51

Remaining and **not yet represented as verified**:

- Language Proficiency — 19
- Reading Comprehension — 13
- Reasoning / Clerical Ability — 17

## Illustration follow-up log

This branch does not edit illustration strategy, approvals, or assets. No new illustration scope is authorized by this QA pass. Text corrections that alter a concept represented by an existing figure should be checked during the separate illustration review, but no image change is made here.

## Operational constraints observed

- GitHub Actions used: **NO**
- Sanity writes: **NO**
- `main` modified: **NO**
- Merge to `main`: **NO**
