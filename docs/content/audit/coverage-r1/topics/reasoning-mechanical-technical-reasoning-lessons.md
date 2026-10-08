# Mechanical and Technical Reasoning structure audit

Status: COMPLETE author reading/findings, pending fresh independent review and lead acceptance. Level 3 only; no content changes.

## Identity and read log

Current main policy `1aaebad9814ba7bd9404d8b43fc010281abb97cf` matched live/cache. Audit live/local `9f181056ee680069b5ebcc44d3a77632a4159c4e`; pinned corpus `content/question-qa-r2` at `765c5dc0fa5586281047bf4f7b30d09ab3707887`, clean/read-only. Retrieved nine current policy/startup/standard blobs; they match prior full reads. Full approved spec/plan, ORCHESTRATOR, October 4/5/8 decisions, illustration log, original brief and reader contract control; unchanged identities were checked. Accepted nine-exam requirements/overlap notes retain their verified full-read identities.

Startup DRAFT preceded owned-body reading. Saved after each of the five full reads, then after facet and source batches. No unchanged body reading is counted twice.

- `lesson-mechanical-technical-reasoning-fluid-pressure`: `content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md`, full read lines 1-112, SHA256 in JSON.
- `lesson-mechanical-technical-reasoning-gear-rotations`: `content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md`, full read lines 1-95, SHA256 in JSON.
- `lesson-mechanical-technical-reasoning-pulleys-and-levers`: `content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md`, full read lines 1-127, SHA256 in JSON.
- `lesson-mechanical-technical-reasoning-springs-and-weights`: `content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md`, full read lines 1-112, SHA256 in JSON.
- `lesson-mechanical-technical-reasoning-structural-stability`: `content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md`, full read lines 1-92, SHA256 in JSON.

Narrowly read two existing Physics bodies in full for reuse/dependency comparison, without grading their topic coverage:

- `content/lessons/science/physics/fluid-mechanics.md`, 1-142, SHA256 `29446c078d4024ca5fc7ebeb6ee1e77e627c3cc96f5a61e44a55bf5e03fde54e`.
- `content/lessons/science/physics/work-energy-power.md`, 1-182, SHA256 `7ccf85aaf50d3657eeb27b94f9255c278c9802a78b215f571651288414b9fb60`.

## Findings and useful structure

B03/L01/L17/L19 are used only for required-skill scope, coherent goal and actual instruction/example evidence. No full Level 4 compliance verdict, language/style sweep or Level 5 question/practice audit.

- Fluid Pressure has a model-based split candidate: static depth/connected-surface equilibrium at14-26 versus moving-flow continuity/Bernoulli at30-44. Each solves a different comparison under different assumptions. Separate coherent static and steady-flow cores where that improves model selection, without labeling unknown exam depth excess content. Benefit: prevent applying a depth or speed shortcut outside its conditions. Cost: later ID/routing and example regrouping/review.
- Verified Physics overlap supports shared hydrostatic/Bernoulli teaching rather than parallel whole lessons. Mechanical Fluid16-22/40-44/81-85 repeats Physics Fluid16-28/42-46/88-100. Keep communicating-vessel and continuity applications as mechanical additions; Physics buoyancy/airfoil material is distinct. Shared definitions/core do not make the entire Physics lesson a strict prerequisite.
- Pulleys and Levers has a second split candidate: supporting-rope/tension/travel method14-24 versus pivot/perpendicular-moment-arm method28-40. Keep a shared ideal work/force-distance introduction, then separate the applications. Benefit: keep support counting and lever-arm reasoning distinct. Cost: later regrouping, ID preservation and review. Physics Work12-18/40-48 can provide optional fuller work/loss explanation, while current machine effort/travel methods are supplied locally.
- Gear Rotations12-33/39-68 has one coherent connection task: direction, parity and inverse tooth ratio. Internal and same-shaft exceptions are defined, but no worked applications use them. Do not split by every connection category or treat the single accepted DOST tag as exam exclusivity.
- Springs12-35/42-83 has one linear/static model goal. Ratios, equal-force stiffness and a spring-constant calculation are developed locally. The [publisher reference](https://openstax.org/books/university-physics-volume-1/pages/12-4-elasticity-and-plasticity) distinguishes elastic return from linear proportionality. Qualify “elastic limit/range” as the linear/Hooke-law range where appropriate, and distinguish unstretched length from loaded equilibrium. Worked examples already assume linear/Hooke-law behavior; this wording concern is not a whole-Physics dependency.
- Structural Stability12-28/34-65 has one qualitative support/center-of-gravity goal with a dynamic-limit example. Current static projection, same-vehicle lower-cargo and wider-stance comparisons are stated locally. Retain the dynamic case as a bounded caution, not a separately developed rollover model or a mandatory Dynamics lesson.
- Current examples supply gear contacts, tooth counts, support count, moment arms, depth and stability conditions in prose. They do not model extracting unknown inputs from an unfamiliar diagram. This is a teaching/application limit, not an illustration-need/quality finding. No arbitrary required example count is inferred.

Corresponding source paths are in the read log; detailed skill evidence appears once in the JSON appendix. Other current goals are not sufficiently crammed to justify splitting merely from length or concept count.

## Scope and partial reuse

Fifty distinct facets account for all twelve immutable packet rows, with additional accepted force/work and scope leads checked from the whole map. Accounting is not coverage. Liquid depth/flow is not gas pressure-volume-temperature instruction or hydraulic-piston force calculation. Simple ideal machines do not close machine efficiency, general motion/graphs, Newtonian dynamics, electrical behavior/safety, light/sound, thermodynamics or the broader Chemistry/Biology/Earth compound rows.

The [accepted DOST packet](../requirements/dost-sei.md), official2026 primerp6 `dost-sei-L048`, names mechanical/electrical relationships and forces. It does not establish exact gear, spring, pulley, stability or fluid families, figure formats, frequency or quantitative depth;2027 continuity remains unknown. Opening “often/common/most” format claims therefore remain unconfirmed fine-scope claims. Curriculum supports preparation with the exact strengthened/STEM cohort, completion and version limits; weak UPCAT leads remain weak. No organizer silence proves exclusion or unnecessary content.

CSE Professional's [English Analytical scope](../requirements/cse-professional.md) includes named symbolic/abstract reasoning. It does not automatically confirm a Mechanical topic. Subprofessional's separate [Clerical/common-core scope](../requirements/cse-subprofessional.md) is not an inherited Professional Mechanical blueprint. ACET/USTET/SM current mechanical inclusion/depth remains unknown in the accepted records. No new whole-topic tags or Mechanical subtests are created.

English is the actual teaching language of all five bodies. Exact item-language allocations remain governed by accepted organizer evidence or unknown, not by this corpus placement.

## Prerequisites and figure dependencies

Necessary existing-ID prerequisite edges: none. Explicit checked no-prerequisite list:

- `lesson-mechanical-technical-reasoning-fluid-pressure`
- `lesson-mechanical-technical-reasoning-gear-rotations`
- `lesson-mechanical-technical-reasoning-pulleys-and-levers`
- `lesson-mechanical-technical-reasoning-springs-and-weights`
- `lesson-mechanical-technical-reasoning-structural-stability`

Operative methods are supplied locally: fluid depth/flow equations and conditions; gear mesh/ratio rules; pulley supports, weight conversion and perpendicular lever balance; spring proportionality; support projection and static/dynamic limits. Ordinary arithmetic/vocabulary is assumed. Angled torque uses an undeveloped sine formula, but every current lever example supplies perpendicular moment arms; a future angled application cannot justify a strict trigonometry edge now. The current qualitative stability cases likewise require no deeper torque calculation.

Verified richer Physics pressure/density and work definitions are optional preparation/common-core reuse. Missing hydraulic, nonlinear/preloaded spring, diagram-input extraction or broader force concepts are local facet gaps, not asserted absent-corpus foundations or new prerequisite chains. No self-links, authored-order or future-content edges.

No load-bearing figure dependency encountered in these current prose-specified tasks. Authoring notes alone do not prove runtime figures; no illustration sufficiency, decoration, priority, quality, count or production assessment occurred. Runtime availability remains unknown; practice deferred Level 5.

## Source concerns and actual verification

Ten ledger entries record exact encountered claims, dispositions, URLs/sections and pinned identity/access date. Publisher/university sources support conditional fluid models, ordinary gear rules, pulley support/lever arms and the static model. [NHTSA](https://www.nhtsa.gov/ratings) corroborates combining static top-heaviness and dynamic rollover assessment; no actual vehicle outcome/rating is certified. Selected arithmetic supports teaching claims under supplied ideal assumptions, without certifying real measured givens or a full correctness/standards pass. Spring linearity/reference qualification and official fine exam formats remain explicit limits.

Dart attribution scanner remains unverified after the lead's nonreturning run was canceled with exit130. No inherited pass, SDK repair or global content scan. Supplemental scoped document checks do not replace it. All sixteen prior completed topic outputs remain immutable; fresh review accepts this author output separately.

Scoped inline Python checked the actual saved artifact, immutable topic packet/map/manifest, broader accepted preparation/scope leads, five owned source hashes/full ranges, two comparison sources and sixteen prior frozen topic hashes. Exit0:

```text
{
  "assignedIDs": 5,
  "lessonRecords": 5,
  "fullReadHashesAndRanges": 5,
  "narrowComparisonReads": 2,
  "skills": 26,
  "facets": 50,
  "packetRequirementRefs": 12,
  "unaccountedPacketRefs": [],
  "extraAcceptedRefsBeyondPacket": [
    "acet-L159",
    "cse-professional-L035",
    "cse-professional-L091",
    "cse-subprofessional-L048",
    "dcat-L080",
    "pupcet-L118",
    "sm-foundation-L112",
    "sm-foundation-L127",
    "upcat-L149",
    "ustet-L117",
    "ustet-L154"
  ],
  "uniqueRefs": 23,
  "referenceOccurrences": 292,
  "evidenceRangesChecked": 168,
  "strictEdges": 0,
  "selfLinks": 0,
  "cycles": 0,
  "bothEndEdgesToCheck": 0,
  "explicitNoPrerequisiteIDs": 5,
  "loadBearingFigureDependencies": 0,
  "splitCandidates": 2,
  "ledgerEntries": 10,
  "corpusHEAD": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "corpusDirty": false,
  "frozenPriorTopicHashesChecked": 16,
  "priorArtifactsChanged": [],
  "ComprehensionSHA256": "f28d15431cfaa9ffce6c2c976955587d8f1740cbeabc4c9733d11e60c49f2f85",
  "emDashes": 0,
  "trailingWhitespaceLines": 0,
  "scopedCreditMarkers": [],
  "errors": []
}
```

Shared supporting validator, `python3 docs/content/audit/coverage-r1/check_level3_outputs.py`, exit0. Snapshot records combined author accounting; it does not accept this topic or the Level3 gate:

```text
{
  "level": 3,
  "completeTopics": 19,
  "expectedTopics": 25,
  "completeLessons": 143,
  "expectedLessons": 158,
  "complete": [
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
    "reasoning-logical-verbal-reasoning",
    "reasoning-mechanical-technical-reasoning",
    "reasoning-spatial-abstract-reasoning",
    "science-biology",
    "science-chemistry",
    "science-earth-science-astronomy",
    "science-physics"
  ],
  "pending": [
    "general-information-code-of-conduct-ra-6713:NOT_STARTED",
    "general-information-environment-management:NOT_STARTED",
    "general-information-peace-and-human-rights:NOT_STARTED",
    "general-information-philippine-constitution:NOT_STARTED",
    "reasoning-clerical-ability:DRAFT",
    "reasoning-verbal-logic:NOT_STARTED"
  ],
  "errors": [],
  "mechanicalAccountingReady": false,
  "gateReady": false
}
```

`git diff --check -- docs/content/audit/coverage-r1/topics/reasoning-mechanical-technical-reasoning-lessons.md` returned exit0 with no output. Direct text check found no trailing whitespace, including untracked content. Read-only corpus ls-remote also matched765c5dc0fa5586281047bf4f7b30d09ab3707887. Scoped credit-marker checks are supplemental, not a pass of the unverified canonical Dart scanner. Final parse confirms COMPLETE, all five assigned records, fifty facets and exactly one JSON appendix. Fresh independent review and lead acceptance remain pending.


## JSON appendix

```json
{
  "level": 3,
  "status": "COMPLETE",
  "subject": "reasoning",
  "topic": "mechanical-technical-reasoning",
  "policyCommit": "1aaebad9814ba7bd9404d8b43fc010281abb97cf",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "id": "lesson-mechanical-technical-reasoning-fluid-pressure",
      "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
      "sha256": "d904040e9f5f8b52b26033211caf6197daa71449bd7d2f51b43565bab36611d7",
      "readLines": [
        1,
        112
      ],
      "goal": "Compare hydrostatic depth/surface levels and steady ideal pipe speed/pressure while checking the assumptions that make each comparison valid.",
      "skills": [
        {
          "name": "Compare hydrostatic pressure at equal fluid/surface conditions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                16,
                22
              ],
              "note": "P=P0+rho gh; depth and reference surface defined"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                50,
                54
              ],
              "note": "B deeper than A has greater pressure"
            }
          ],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L048",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": [
            "Physical pressure/density meanings and units not developed; comparative example, no numerical pressure calculation."
          ]
        },
        {
          "name": "Predict connected open-liquid levels at equilibrium",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                24,
                26
              ],
              "note": "Same liquid/atmosphere equilibrium and exceptions"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                59,
                63
              ],
              "note": "Wide and narrow arms have equal free-surface elevation"
            }
          ],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L048",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": [
            "No sealed/different-liquid or capillary worked comparison; not a hydraulic-force calculation."
          ]
        },
        {
          "name": "Apply continuity to average speed in an unbranched pipe",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                32,
                36
              ],
              "note": "Steady incompressible A1v1=A2v2 relationship"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                68,
                76
              ],
              "note": "Narrower section faster under same-path assumptions"
            }
          ],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L048",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": [
            "No numerical area/speed ratio, branch/leak/compressibility example or derivation."
          ]
        },
        {
          "name": "Compare static pressure and speed at equal height using ideal Bernoulli",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                40,
                44
              ],
              "note": "Pressure+kinetic+gravitational terms; same-streamline assumptions and exceptions"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                81,
                85
              ],
              "note": "Faster narrower section lower pressure at same height"
            }
          ],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L048",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": [
            "No numerical Bernoulli calculation, elevation-change, pump or dissipative-loss application."
          ]
        },
        {
          "name": "Separate fluid-rest, flow and equality-of-surface-pressure assumptions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                90,
                112
              ],
              "note": "Each shortcut requires its own physical conditions"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
              "lines": [
                50,
                85
              ],
              "note": "Examples all ideal cases; exceptions described rather than worked"
            }
          ],
          "requirementRefs": [
            "upcat-L150",
            "dcat-L083",
            "ustet-L124",
            "dost-sei-L048",
            "dost-sei-L058",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "limitations": [
            "Compressibility/gas pressure-volume-temperature laws, chemical bonding/biomolecules and wider motion/electrical/light/sound/science domains not taught."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L079",
            "dcat-L083"
          ],
          "sharedCore": "Conditional liquid hydrostatic and ideal pipe-flow comparisons.",
          "partialLimits": "No gas P-V-T law, hydraulic piston force, broad mechanical/electrical domain or whole compound Physics/Chemistry/Science row. Numerical extended flow depth and exact mechanical exam forms unverified.",
          "depth": "unknown: curriculum/weak preparation; strengthened/STEM cohort/completion/version limits remain",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain actual liquid/flow preparation; narrow gas-law and broad applied-science candidates to demonstrated facets."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L048",
            "dost-sei-L054",
            "dost-sei-L058",
            "dost-sei-L099",
            "dost-sei-L107",
            "dost-sei-L108"
          ],
          "sharedCore": "Conditional liquid hydrostatic and ideal pipe-flow comparisons.",
          "partialLimits": "No gas P-V-T law, hydraulic piston force, broad mechanical/electrical domain or whole compound Physics/Chemistry/Science row. Numerical extended flow depth and exact mechanical exam forms unverified.",
          "depth": "unknown: 2026 Mechanical domain official;2027 continuity and specific fluid subfamilies/quantitative depth unknown",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain actual liquid/flow preparation; narrow gas-law and broad applied-science candidates to demonstrated facets."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L150"
          ],
          "sharedCore": "Conditional liquid hydrostatic and ideal pipe-flow comparisons.",
          "partialLimits": "No gas P-V-T law, hydraulic piston force, broad mechanical/electrical domain or whole compound Physics/Chemistry/Science row. Numerical extended flow depth and exact mechanical exam forms unverified.",
          "depth": "unknown: curriculum/weak preparation; strengthened/STEM cohort/completion/version limits remain",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain actual liquid/flow preparation; narrow gas-law and broad applied-science candidates to demonstrated facets."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L124"
          ],
          "sharedCore": "Conditional liquid hydrostatic and ideal pipe-flow comparisons.",
          "partialLimits": "No gas P-V-T law, hydraulic piston force, broad mechanical/electrical domain or whole compound Physics/Chemistry/Science row. Numerical extended flow depth and exact mechanical exam forms unverified.",
          "depth": "unknown: curriculum/weak preparation; strengthened/STEM cohort/completion/version limits remain",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain actual liquid/flow preparation; narrow gas-law and broad applied-science candidates to demonstrated facets."
        }
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "Static depth/surface equilibrium and moving-fluid continuity/energy require different assumptions and solve distinct comparisons; separating the two coherent goals can reduce switching between rest and flow shortcuts. Existing Physics independently repeats hydrostatic and same-height Bernoulli core, so share those explanations instead of maintaining parallel whole lessons.",
        "evidence": [
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
            "lines": [
              14,
              26
            ],
            "note": "Static depth/equilibrium core"
          },
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
            "lines": [
              30,
              44
            ],
            "note": "Moving-fluid continuity/Bernoulli core"
          },
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
            "lines": [
              90,
              112
            ],
            "note": "Separate applicability conditions"
          },
          {
            "path": "content/lessons/science/physics/fluid-mechanics.md",
            "lines": [
              16,
              28
            ],
            "note": "Existing density/pressure and hydrostatic core"
          },
          {
            "path": "content/lessons/science/physics/fluid-mechanics.md",
            "lines": [
              42,
              46
            ],
            "note": "Existing same-height ideal Bernoulli assumptions"
          },
          {
            "path": "content/lessons/science/physics/fluid-mechanics.md",
            "lines": [
              88,
              100
            ],
            "note": "Same wider/slower versus faster/narrower pressure application"
          }
        ],
        "proposal": "Share verified Physics density/pressure, hydrostatic and ideal Bernoulli core. Keep communicating-vessel and continuity applications as mechanical additions; keep Physics buoyancy/airfoil material distinct. Within common structure, separate static equilibrium from steady flow where that improves model selection; no entire Physics prerequisite.",
        "cost": "Later ID/routing and example regrouping, shared-core integration and review; preserve all assumptions. No content edits now."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-mechanical-technical-reasoning-gear-rotations",
      "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
      "sha256": "dcb596c614480c76ec1a538861177a5c227bc4c0c5aab7e04b0fdda1572dc3f1",
      "readLines": [
        1,
        95
      ],
      "goal": "Predict rotation direction and tooth-count speed ratio for specified external gear arrangements, while recognizing internal and same-shaft exceptions.",
      "skills": [
        {
          "name": "Reverse direction at each ordinary external mesh",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                12,
                15
              ],
              "note": "External outside-edge teeth and alternating-chain rule"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                39,
                48
              ],
              "note": "Three/five gear chains follow given input direction"
            }
          ],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Direction requires a consistent viewing convention; actual gear inclusion/item type not confirmed by broad Mechanical scope."
          ]
        },
        {
          "name": "Use mesh-count parity in an external chain",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                15,
                15
              ],
              "note": "Odd/even gear position rule from alternation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                48,
                48
              ],
              "note": "Five gears/four reversals preserve input direction"
            }
          ],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "No loop/compound-carrier or unfamiliar topology application."
          ]
        },
        {
          "name": "Apply inverse tooth-count angular-speed ratio",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                20,
                26
              ],
              "note": "Matched tangential speeds and omega/tooth ratio; speed versus direction separated"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                53,
                63
              ],
              "note": "10teeth*6 turns=30teeth*n; n2 and opposite direction"
            }
          ],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Basic arithmetic assumed; local tooth-engagement equation supplies the procedure. No torque/power/loss calculation."
          ]
        },
        {
          "name": "Recognize internal mesh and rigid same-shaft exceptions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                28,
                33
              ],
              "note": "Internal same direction; fixed same shaft angular velocity/direction"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Exceptions defined, not worked in a compound/internal gear calculation or tracing example."
          ]
        },
        {
          "name": "Trace each separate hub mesh rather than a straight-chain shortcut",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                73,
                95
              ],
              "note": "Identify connection and actual mesh paths"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
              "lines": [
                66,
                68
              ],
              "note": "Three noncontacting outer gears each oppose center"
            }
          ],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Topology is fully specified in prose; no diagram-only unlabeled connection task."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "sharedCore": "External gear direction, mesh parity, simple tooth ratio and exception recognition.",
          "partialLimits": "No whole Mechanical/electrical/force domain, motion graphs, work/energy/charge instruction; exact gear forms and tested quantitative depth unknown.",
          "depth": "unknown: DOST2026 Mechanical domain official, specific gear taxonomy/item formats and2027 continuity unconfirmed",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain bounded gear preparation, not complete mechanical scope or exclusive DOST relevance."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Direction and tooth ratio are complementary outputs of one gear-connection analysis; exception definitions prevent an overbroad rule.",
        "evidence": [
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
            "lines": [
              12,
              33
            ],
            "note": "Mesh/direction/speed model"
          },
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
            "lines": [
              39,
              68
            ],
            "note": "Chains, pair ratio and hub topology"
          }
        ],
        "proposal": "Retain one gear goal; later add internal/same-shaft applications if appropriate depth is established, without interpreting broad organizer wording as a specific format mandate.",
        "cost": "Later targeted examples/source review; no current split, whole-Physics recap or corpus change."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-mechanical-technical-reasoning-pulleys-and-levers",
      "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
      "sha256": "fc79f371d955ec72c4255d551a3289c74dddc9c890d16820c70cbacb329509e4",
      "readLines": [
        1,
        127
      ],
      "goal": "Determine ideal pulley effort and rope travel from supporting segments, and perpendicular lever effort from static torque balance.",
      "skills": [
        {
          "name": "Distinguish ideal force-distance tradeoff from real losses",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                12,
                24
              ],
              "note": "Work conserved ideally; friction/components alter real requirements; count supporting segments"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                59,
                72
              ],
              "note": "Two support segments halve effort and double effort travel"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dcat-L083",
            "dost-sei-L048",
            "dost-sei-L054",
            "dost-sei-L058"
          ],
          "limitations": [
            "No work/efficiency calculation or actual loss model; unknown exact real-machine exam depth."
          ]
        },
        {
          "name": "Predict fixed-pulley direction change without force gain",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                16,
                16
              ],
              "note": "Fixed pulley ideal mechanical advantage1"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                46,
                54
              ],
              "note": "490N load requires490N pull"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dcat-L083",
            "dost-sei-L048",
            "dost-sei-L054",
            "dost-sei-L058"
          ],
          "limitations": [
            "Prose specifies ideal setup; no unseen routing/topology interpretation."
          ]
        },
        {
          "name": "Calculate movable-pulley force and rope distance from supports",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                18,
                24
              ],
              "note": "Equal tension one rope; n support rule and distance tradeoff"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                59,
                72
              ],
              "note": "60kg converted via supplied g;588N/2=294N,2m load travel requires4m rope"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dcat-L083",
            "dost-sei-L048",
            "dost-sei-L054",
            "dost-sei-L058"
          ],
          "limitations": [
            "Supporting count supplied explicitly; no example derives it from an unfamiliar arrangement."
          ]
        },
        {
          "name": "Distinguish mass from weight and convert with W=mg",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                103,
                119
              ],
              "note": "kg versus N; W=mg supplied"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                64,
                66
              ],
              "note": "60*9.8=588N load weight"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dcat-L083",
            "dost-sei-L048",
            "dost-sei-L054",
            "dost-sei-L058"
          ],
          "limitations": [
            "No strict Dynamics/gravity edge: operative conversion is supplied locally. General gravitational law/force systems not taught."
          ]
        },
        {
          "name": "Balance a horizontal lever using perpendicular moment arms",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                30,
                40
              ],
              "note": "Fulcrum/torque/moment-arm relation and perpendicular static force balance"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                77,
                96
              ],
              "note": "980N at2m with5m effort needs392N; load at1m needs196N"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dcat-L083",
            "dost-sei-L048",
            "dost-sei-L054",
            "dost-sei-L058"
          ],
          "limitations": [
            "No lever-class classification or multi-force equilibrium example."
          ]
        },
        {
          "name": "Recognize angled torque versus ordinary lever distance",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
              "lines": [
                30,
                34
              ],
              "note": "rFsin(theta)=F*dperp; perpendicular arm defined"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L162",
            "dcat-L083",
            "dost-sei-L048",
            "dost-sei-L054",
            "dost-sei-L058"
          ],
          "limitations": [
            "Angle theta and sine evaluation not developed; current worked examples all perpendicular and use supplied moment arms. No strict trig dependency justified by an unused extension formula."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L083"
          ],
          "sharedCore": "Ideal pulley support-count force/distance and perpendicular lever torque balance.",
          "partialLimits": "No complete machine-efficiency/linear-rotational/electrical/light-sound/work-energy curriculum row; routing count explicitly supplied; angled torque and real losses not worked.",
          "depth": "unknown: UPCAT curriculum and DCAT strengthened-SHS preparation retain exam/cohort/completion limits",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain demonstrated simple-machine preparation, not full named domain or universal mechanical exam format."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L048",
            "dost-sei-L054",
            "dost-sei-L058"
          ],
          "sharedCore": "Ideal pulley support-count force/distance and perpendicular lever torque balance.",
          "partialLimits": "No complete machine-efficiency/linear-rotational/electrical/light-sound/work-energy curriculum row; routing count explicitly supplied; angled torque and real losses not worked.",
          "depth": "unknown:2026 Mechanical domain official; exact simple-machine task family/depth and2027 continuity unknown",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain demonstrated simple-machine preparation, not full named domain or universal mechanical exam format."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L162"
          ],
          "sharedCore": "Ideal pulley support-count force/distance and perpendicular lever torque balance.",
          "partialLimits": "No complete machine-efficiency/linear-rotational/electrical/light-sound/work-energy curriculum row; routing count explicitly supplied; angled torque and real losses not worked.",
          "depth": "unknown: UPCAT curriculum and DCAT strengthened-SHS preparation retain exam/cohort/completion limits",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain demonstrated simple-machine preparation, not full named domain or universal mechanical exam format."
        }
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "Pulley routing/support-tension and lever pivot/moment-arm analysis have different model-selection tasks; separate coherent application modules can prevent one shortcut being applied to the other.",
        "evidence": [
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
            "lines": [
              14,
              24
            ],
            "note": "Rope-support/tension model"
          },
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
            "lines": [
              28,
              40
            ],
            "note": "Pivot/torque model"
          },
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
            "lines": [
              101,
              123
            ],
            "note": "Separate support counting and moment-arm checks"
          },
          {
            "path": "content/lessons/science/physics/work-energy-power.md",
            "lines": [
              12,
              18
            ],
            "note": "Optional existing work definition/calculation core"
          },
          {
            "path": "content/lessons/science/physics/work-energy-power.md",
            "lines": [
              40,
              48
            ],
            "note": "Optional existing energy versus mechanical-energy/loss qualification"
          }
        ],
        "proposal": "Share a short ideal work/force-distance introduction, then separate pulley support/rope-travel and lever torque-balance applications. Do not turn angle formulas or richer Physics content into prerequisites for current perpendicular cases. Existing Physics work/energy core can be reused as optional explanation of force-distance/loss bookkeeping; current effort/distance equations are supplied locally.",
        "cost": "Later example regrouping, ID/routing preservation and independent review; no current content edits. Actual split decision may coordinate with Physics common-core reuse."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-mechanical-technical-reasoning-springs-and-weights",
      "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
      "sha256": "b367a57b7146e942b584dee9ea7afe202491a111157b3d38173fcf26706fd1a3",
      "readLines": [
        1,
        112
      ],
      "goal": "Use an ideal linear spring's force-extension relationship to scale loads/extensions and compare or calculate stiffness, distinguishing mass and weight.",
      "skills": [
        {
          "name": "Interpret restoring direction versus magnitude in Hooke's law",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                12,
                26
              ],
              "note": "Fs=-kx, F=kx and inverse stiffness relation; units N/m"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                69,
                83
              ],
              "note": "Examples use magnitudes rather than force-direction selection"
            }
          ],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Natural/unstretched versus loaded equilibrium origin needs clarification; current examples treat extension from unstretched length."
          ]
        },
        {
          "name": "Scale extension with mass for one spring under same gravity",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                28,
                35
              ],
              "note": "x=mg/k; kg versus N; fixed g and k conditions"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                42,
                51
              ],
              "note": "6/2=3 load factor;4cm*3=12cm"
            }
          ],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Only linear range and unchanged gravity; no numerical weight conversion with an independently evaluated g."
          ]
        },
        {
          "name": "Infer mass from extension ratio",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                24,
                32
              ],
              "note": "Same stiffness/gravity proportional load relation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                56,
                64
              ],
              "note": "15cm/3cm=5; same spring mass5kg"
            }
          ],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Arithmetic is local in example; no ratio/proportion whole-lesson edge justified."
          ]
        },
        {
          "name": "Compare stiffness under equal force and compute k",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                24,
                26
              ],
              "note": "Larger k means smaller extension for equal force"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                69,
                83
              ],
              "note": "A2cm versusB5cm;10N/.050m=200N/m"
            }
          ],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "No combined-series/parallel springs, preload, energy, dynamics or force-graph interpretation."
          ]
        },
        {
          "name": "Apply linear-model range and mass/weight cautions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
              "lines": [
                88,
                112
              ],
              "note": "Do not invert relation or call kilograms force; limited applicability"
            }
          ],
          "exampleVerdict": "not-required",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Elastic reversibility does not by itself guarantee a linear force-extension relation; distinguish proportional/Hooke range from elastic range during later content review."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "sharedCore": "Ideal linear force-extension, stiffness and static mass/weight comparisons.",
          "partialLimits": "Broad mechanical/electrical/force domain not completed; Hooke subfamilies, force graphs, spring combinations, dynamics and elasticity-versus-linearity depth unconfirmed.",
          "depth": "unknown: DOST2026 Mechanical domain named, exact spring taxonomy/depth and2027 continuity unknown",
          "tagRecommendation": "revise-candidate",
          "reason": "Bound spring preparation to actual linear/static methods; do not infer exclusive DOST relevance or a general Physics prerequisite."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Direction, mass/weight, proportional extension and stiffness all interpret one spring model; keeping the assumptions with the calculations prevents invalid scaling.",
        "evidence": [
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
            "lines": [
              12,
              35
            ],
            "note": "One force-extension model"
          },
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
            "lines": [
              42,
              83
            ],
            "note": "Scaling/inverse/stiffness applications"
          }
        ],
        "proposal": "Retain one linear/static spring goal; clarify origin and linear-range terminology later rather than split off assumed stiffness/weight basics.",
        "cost": "Focused wording/source review later; no current content change or extra lessons justified."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-mechanical-technical-reasoning-structural-stability",
      "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
      "sha256": "def98d8b2801b499e1d33f294bb42769acd1a5121f65127527482a5c3f56bd39",
      "readLines": [
        1,
        92
      ],
      "goal": "Assess qualitative static tipping from center-of-gravity projection and support geometry, and recognize why an accelerating vehicle needs a dynamic explanation.",
      "skills": [
        {
          "name": "Identify center of gravity and base of support",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                12,
                14
              ],
              "note": "Gravitational resultant point, distribution/symmetry limits and contact support region"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                34,
                38
              ],
              "note": "Uniform comparable objects; no irregular distribution calculation"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "No center-of-mass calculation, weighted combinations or locating CG from a diagram-only arrangement."
          ]
        },
        {
          "name": "Use weight projection relative to support edge for quasi-static tipping",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                20,
                26
              ],
              "note": "Inside, threshold at edge, outside gravity rotation; lower/wider usual tilt margin"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                43,
                47
              ],
              "note": "Box tips after CG weight line crosses pivot/support boundary"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Condition reasoning, not a numerical critical angle or multi-force equilibrium problem; torque word is explained as tendency to rotate, no strict torque-calculation foundation required."
          ]
        },
        {
          "name": "Compare height and support width under comparable conditions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                26,
                28
              ],
              "note": "Lower/wider and static/dynamic qualification"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                34,
                38
              ],
              "note": "Short wide versus tall narrow uniform comparable objects"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "No conflicting geometry tradeoff requiring numerical angle evaluation."
          ]
        },
        {
          "name": "Distinguish dynamic rollover from a static gravity-line test",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                28,
                28
              ],
              "note": "Acceleration/load transfer matters; lower CG improves usual resistance"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                52,
                56
              ],
              "note": "Same truck/cargo mass; secured lower cargo reduces overturning tendency"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "Qualitative dynamic case only; no turning-speed, inertial-force, suspension or friction calculation, and no vehicle safety rating/instruction."
          ]
        },
        {
          "name": "Apply support-width and mass-alone cautions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                70,
                92
              ],
              "note": "Weight line, compare both factors, static versus accelerating; mass-alone not deciding"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
              "lines": [
                61,
                65
              ],
              "note": "Wider feet stance increases sideways quasi-static support margin"
            }
          ],
          "requirementRefs": [
            "upcat-L162",
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "limitations": [
            "No structural-member/truss stress, materials, buckling or broader work/energy/graphs/electrical domain."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L048",
            "dost-sei-L054"
          ],
          "sharedCore": "Qualitative center/support/tipping comparisons and a bounded dynamic caution.",
          "partialLimits": "No whole force/work/energy/motion/electrical curriculum, structural engineering design, center calculation, critical-angle or rollover-model analysis.",
          "depth": "unknown:2026 Mechanical domain official; exact stability forms and2027 continuity unknown",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain actual balance/stability facet, distinguish local qualitative teaching from broad Mechanics scope."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L162"
          ],
          "sharedCore": "Qualitative center/support/tipping comparisons and a bounded dynamic caution.",
          "partialLimits": "No whole force/work/energy/motion/electrical curriculum, structural engineering design, center calculation, critical-angle or rollover-model analysis.",
          "depth": "unknown: UPCAT curriculum balance/stability supports preparation, not full specific exam mechanics blueprint",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain actual balance/stability facet, distinguish local qualitative teaching from broad Mechanics scope."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Center/support geometry, tipping criterion and accelerating-case caution all prevent misuse of the same stability heuristic; current dynamic example is a bounded contrast, not an independently developed mechanics lesson.",
        "evidence": [
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
            "lines": [
              12,
              28
            ],
            "note": "Static model and its limit"
          },
          {
            "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
            "lines": [
              34,
              65
            ],
            "note": "Comparable geometry, threshold, dynamic caution and stance"
          }
        ],
        "proposal": "Retain qualitative stability core; label dynamic truck example as a limit/extension. Deeper torque/rollover/structural design remains optional and does not create a current prerequisite.",
        "cost": "Later targeted physical-model/source qualification if expanded; no current split or corpus edit."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    }
  ],
  "requirementFacets": [
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L048",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Compare hydrostatic pressure at equal fluid/surface conditions",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            16,
            22
          ],
          "note": "P=P0+rho gh; depth and reference surface defined"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            50,
            54
          ],
          "note": "B deeper than A has greater pressure"
        }
      ],
      "missingIdeas": [
        "Physical pressure/density meanings and units not developed; comparative example, no numerical pressure calculation."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: B deeper than A has greater pressure",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L048",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Predict connected open-liquid levels at equilibrium",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            24,
            26
          ],
          "note": "Same liquid/atmosphere equilibrium and exceptions"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            59,
            63
          ],
          "note": "Wide and narrow arms have equal free-surface elevation"
        }
      ],
      "missingIdeas": [
        "No sealed/different-liquid or capillary worked comparison; not a hydraulic-force calculation."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Wide and narrow arms have equal free-surface elevation",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L048",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Apply continuity to average speed in an unbranched pipe",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            32,
            36
          ],
          "note": "Steady incompressible A1v1=A2v2 relationship"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            68,
            76
          ],
          "note": "Narrower section faster under same-path assumptions"
        }
      ],
      "missingIdeas": [
        "No numerical area/speed ratio, branch/leak/compressibility example or derivation."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Narrower section faster under same-path assumptions",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L048",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Compare static pressure and speed at equal height using ideal Bernoulli",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            40,
            44
          ],
          "note": "Pressure+kinetic+gravitational terms; same-streamline assumptions and exceptions"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            81,
            85
          ],
          "note": "Faster narrower section lower pressure at same height"
        }
      ],
      "missingIdeas": [
        "No numerical Bernoulli calculation, elevation-change, pump or dissipative-loss application."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Faster narrower section lower pressure at same height",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L048",
        "dost-sei-L058",
        "dost-sei-L107",
        "dost-sei-L108"
      ],
      "facet": "Separate fluid-rest, flow and equality-of-surface-pressure assumptions",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            90,
            112
          ],
          "note": "Each shortcut requires its own physical conditions"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            50,
            85
          ],
          "note": "Examples all ideal cases; exceptions described rather than worked"
        }
      ],
      "missingIdeas": [
        "Compressibility/gas pressure-volume-temperature laws, chemical bonding/biomolecules and wider motion/electrical/light/sound/science domains not taught."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "thin: Examples all ideal cases; exceptions described rather than worked",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Reverse direction at each ordinary external mesh",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-gear-rotations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            12,
            15
          ],
          "note": "External outside-edge teeth and alternating-chain rule"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            39,
            48
          ],
          "note": "Three/five gear chains follow given input direction"
        }
      ],
      "missingIdeas": [
        "Direction requires a consistent viewing convention; actual gear inclusion/item type not confirmed by broad Mechanical scope."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Three/five gear chains follow given input direction",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Use mesh-count parity in an external chain",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-gear-rotations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            15,
            15
          ],
          "note": "Odd/even gear position rule from alternation"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            48,
            48
          ],
          "note": "Five gears/four reversals preserve input direction"
        }
      ],
      "missingIdeas": [
        "No loop/compound-carrier or unfamiliar topology application."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Five gears/four reversals preserve input direction",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Apply inverse tooth-count angular-speed ratio",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-gear-rotations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            20,
            26
          ],
          "note": "Matched tangential speeds and omega/tooth ratio; speed versus direction separated"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            53,
            63
          ],
          "note": "10teeth*6 turns=30teeth*n; n2 and opposite direction"
        }
      ],
      "missingIdeas": [
        "Basic arithmetic assumed; local tooth-engagement equation supplies the procedure. No torque/power/loss calculation."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: 10teeth*6 turns=30teeth*n; n2 and opposite direction",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Recognize internal mesh and rigid same-shaft exceptions",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-gear-rotations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            28,
            33
          ],
          "note": "Internal same direction; fixed same shaft angular velocity/direction"
        }
      ],
      "missingIdeas": [
        "Exceptions defined, not worked in a compound/internal gear calculation or tracing example."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "none: ",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Trace each separate hub mesh rather than a straight-chain shortcut",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-gear-rotations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            73,
            95
          ],
          "note": "Identify connection and actual mesh paths"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            66,
            68
          ],
          "note": "Three noncontacting outer gears each oppose center"
        }
      ],
      "missingIdeas": [
        "Topology is fully specified in prose; no diagram-only unlabeled connection task."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Three noncontacting outer gears each oppose center",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dcat-L083",
        "dost-sei-L048",
        "dost-sei-L054",
        "dost-sei-L058"
      ],
      "facet": "Distinguish ideal force-distance tradeoff from real losses",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            12,
            24
          ],
          "note": "Work conserved ideally; friction/components alter real requirements; count supporting segments"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            59,
            72
          ],
          "note": "Two support segments halve effort and double effort travel"
        }
      ],
      "missingIdeas": [
        "No work/efficiency calculation or actual loss model; unknown exact real-machine exam depth."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Two support segments halve effort and double effort travel",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dcat-L083",
        "dost-sei-L048",
        "dost-sei-L054",
        "dost-sei-L058"
      ],
      "facet": "Predict fixed-pulley direction change without force gain",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            16,
            16
          ],
          "note": "Fixed pulley ideal mechanical advantage1"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            46,
            54
          ],
          "note": "490N load requires490N pull"
        }
      ],
      "missingIdeas": [
        "Prose specifies ideal setup; no unseen routing/topology interpretation."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: 490N load requires490N pull",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dcat-L083",
        "dost-sei-L048",
        "dost-sei-L054",
        "dost-sei-L058"
      ],
      "facet": "Calculate movable-pulley force and rope distance from supports",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            18,
            24
          ],
          "note": "Equal tension one rope; n support rule and distance tradeoff"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            59,
            72
          ],
          "note": "60kg converted via supplied g;588N/2=294N,2m load travel requires4m rope"
        }
      ],
      "missingIdeas": [
        "Supporting count supplied explicitly; no example derives it from an unfamiliar arrangement."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: 60kg converted via supplied g;588N/2=294N,2m load travel requires4m rope",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dcat-L083",
        "dost-sei-L048",
        "dost-sei-L054",
        "dost-sei-L058"
      ],
      "facet": "Distinguish mass from weight and convert with W=mg",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            103,
            119
          ],
          "note": "kg versus N; W=mg supplied"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            64,
            66
          ],
          "note": "60*9.8=588N load weight"
        }
      ],
      "missingIdeas": [
        "No strict Dynamics/gravity edge: operative conversion is supplied locally. General gravitational law/force systems not taught."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: 60*9.8=588N load weight",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dcat-L083",
        "dost-sei-L048",
        "dost-sei-L054",
        "dost-sei-L058"
      ],
      "facet": "Balance a horizontal lever using perpendicular moment arms",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            30,
            40
          ],
          "note": "Fulcrum/torque/moment-arm relation and perpendicular static force balance"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            77,
            96
          ],
          "note": "980N at2m with5m effort needs392N; load at1m needs196N"
        }
      ],
      "missingIdeas": [
        "No lever-class classification or multi-force equilibrium example."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: 980N at2m with5m effort needs392N; load at1m needs196N",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dcat-L083",
        "dost-sei-L048",
        "dost-sei-L054",
        "dost-sei-L058"
      ],
      "facet": "Recognize angled torque versus ordinary lever distance",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            30,
            34
          ],
          "note": "rFsin(theta)=F*dperp; perpendicular arm defined"
        }
      ],
      "missingIdeas": [
        "Angle theta and sine evaluation not developed; current worked examples all perpendicular and use supplied moment arms. No strict trig dependency justified by an unused extension formula."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "none: ",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Interpret restoring direction versus magnitude in Hooke's law",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-springs-and-weights"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            12,
            26
          ],
          "note": "Fs=-kx, F=kx and inverse stiffness relation; units N/m"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            69,
            83
          ],
          "note": "Examples use magnitudes rather than force-direction selection"
        }
      ],
      "missingIdeas": [
        "Natural/unstretched versus loaded equilibrium origin needs clarification; current examples treat extension from unstretched length."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "thin: Examples use magnitudes rather than force-direction selection",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Scale extension with mass for one spring under same gravity",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-springs-and-weights"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            28,
            35
          ],
          "note": "x=mg/k; kg versus N; fixed g and k conditions"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            42,
            51
          ],
          "note": "6/2=3 load factor;4cm*3=12cm"
        }
      ],
      "missingIdeas": [
        "Only linear range and unchanged gravity; no numerical weight conversion with an independently evaluated g."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: 6/2=3 load factor;4cm*3=12cm",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Infer mass from extension ratio",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-springs-and-weights"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            24,
            32
          ],
          "note": "Same stiffness/gravity proportional load relation"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            56,
            64
          ],
          "note": "15cm/3cm=5; same spring mass5kg"
        }
      ],
      "missingIdeas": [
        "Arithmetic is local in example; no ratio/proportion whole-lesson edge justified."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: 15cm/3cm=5; same spring mass5kg",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Compare stiffness under equal force and compute k",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-springs-and-weights"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            24,
            26
          ],
          "note": "Larger k means smaller extension for equal force"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            69,
            83
          ],
          "note": "A2cm versusB5cm;10N/.050m=200N/m"
        }
      ],
      "missingIdeas": [
        "No combined-series/parallel springs, preload, energy, dynamics or force-graph interpretation."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: A2cm versusB5cm;10N/.050m=200N/m",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Apply linear-model range and mass/weight cautions",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-springs-and-weights"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            88,
            112
          ],
          "note": "Do not invert relation or call kilograms force; limited applicability"
        }
      ],
      "missingIdeas": [
        "Elastic reversibility does not by itself guarantee a linear force-extension relation; distinguish proportional/Hooke range from elastic range during later content review."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "not-required: ",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Identify center of gravity and base of support",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            12,
            14
          ],
          "note": "Gravitational resultant point, distribution/symmetry limits and contact support region"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            34,
            38
          ],
          "note": "Uniform comparable objects; no irregular distribution calculation"
        }
      ],
      "missingIdeas": [
        "No center-of-mass calculation, weighted combinations or locating CG from a diagram-only arrangement."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "thin: Uniform comparable objects; no irregular distribution calculation",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Use weight projection relative to support edge for quasi-static tipping",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            20,
            26
          ],
          "note": "Inside, threshold at edge, outside gravity rotation; lower/wider usual tilt margin"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            43,
            47
          ],
          "note": "Box tips after CG weight line crosses pivot/support boundary"
        }
      ],
      "missingIdeas": [
        "Condition reasoning, not a numerical critical angle or multi-force equilibrium problem; torque word is explained as tendency to rotate, no strict torque-calculation foundation required."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Box tips after CG weight line crosses pivot/support boundary",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Compare height and support width under comparable conditions",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            26,
            28
          ],
          "note": "Lower/wider and static/dynamic qualification"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            34,
            38
          ],
          "note": "Short wide versus tall narrow uniform comparable objects"
        }
      ],
      "missingIdeas": [
        "No conflicting geometry tradeoff requiring numerical angle evaluation."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Short wide versus tall narrow uniform comparable objects",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Distinguish dynamic rollover from a static gravity-line test",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            28,
            28
          ],
          "note": "Acceleration/load transfer matters; lower CG improves usual resistance"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            52,
            56
          ],
          "note": "Same truck/cargo mass; secured lower cargo reduces overturning tendency"
        }
      ],
      "missingIdeas": [
        "Qualitative dynamic case only; no turning-speed, inertial-force, suspension or friction calculation, and no vehicle safety rating/instruction."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Same truck/cargo mass; secured lower cargo reduces overturning tendency",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162",
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Apply support-width and mass-alone cautions",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            70,
            92
          ],
          "note": "Weight line, compare both factors, static versus accelerating; mass-alone not deciding"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            61,
            65
          ],
          "note": "Wider feet stance increases sideways quasi-static support margin"
        }
      ],
      "missingIdeas": [
        "No structural-member/truss stress, materials, buckling or broader work/energy/graphs/electrical domain."
      ],
      "priorKnowledge": "Ordinary arithmetic/reading and physical vocabulary assumed; operative comparisons/equations are supplied locally. Richer Physics, trigonometry or generic model recaps are optional, not strict current dependencies.",
      "workedExamples": "worked: Wider feet stance increases sideways quasi-static support margin",
      "scopeLimit": "Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L150",
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058",
        "dost-sei-L107"
      ],
      "facet": "Fluid core reuse with verified Physics: hydrostatic and ideal Bernoulli models",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            16,
            22
          ],
          "note": "Locally taught hydrostatic pressure relation"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            40,
            44
          ],
          "note": "Locally taught same-height Bernoulli"
        },
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            16,
            28
          ],
          "note": "Verified Physics density/pressure definitions and same hydrostatic core"
        },
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            42,
            46
          ],
          "note": "Verified Physics same ideal Bernoulli core"
        },
        {
          "path": "content/lessons/science/physics/fluid-mechanics.md",
          "lines": [
            88,
            100
          ],
          "note": "Same horizontal wider/slower versus narrower/faster pressure comparison"
        }
      ],
      "missingIdeas": [
        "Communicating-vessel and continuity applications remain Mechanical additions; buoyancy/airfoil additions in Physics are not automatically shared."
      ],
      "priorKnowledge": "Physics defines pressure/density more deeply, but consumer already supplies operative depth/flow comparisons. Shared core is reuse, not an indispensable whole-lesson prerequisite.",
      "workedExamples": "Mechanical qualitative depth/flow comparisons and duplicate Physics horizontal-pipe application.",
      "scopeLimit": "No coverage verdict for the two narrowly read Physics bodies; cross-evidence supports bounded sharing only. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L054",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118"
      ],
      "facet": "Ideal work/energy bookkeeping versus complete work-energy preparation",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            12,
            22
          ],
          "note": "Force-distance tradeoff and ideal work/loss statement"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            59,
            72
          ],
          "note": "Half effort/double travel"
        },
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            12,
            18
          ],
          "note": "Verified optional formal work definition/units"
        },
        {
          "path": "content/lessons/science/physics/work-energy-power.md",
          "lines": [
            40,
            48
          ],
          "note": "Verified optional total/mechanical energy and nonconservative-work distinction"
        }
      ],
      "missingIdeas": [
        "No work/energy/power calculation, net work theorem or full energy-transfer/conservation methods in owned bodies."
      ],
      "priorKnowledge": "Verified Physics core can supply optional fuller work meaning; current force/distance method is locally explained and does not require another whole lesson.",
      "workedExamples": "Pulley effort/travel; no energy-value or power example.",
      "scopeLimit": "Unassigned-to-this-topic curriculum leads dcat-L080/ustet-L117/pupcet-L118 justify a narrow preparation connection, not a Mechanical subtest claim. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054",
        "dost-sei-L058",
        "dcat-L083",
        "ustet-L124"
      ],
      "facet": "Read an unfamiliar mechanical arrangement to derive the model inputs",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure",
        "lesson-mechanical-technical-reasoning-gear-rotations",
        "lesson-mechanical-technical-reasoning-pulleys-and-levers",
        "lesson-mechanical-technical-reasoning-springs-and-weights",
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            39,
            68
          ],
          "note": "Connections and tooth data supplied explicitly"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            59,
            59
          ],
          "note": "Support-segment count supplied explicitly"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            34,
            65
          ],
          "note": "Comparative shapes/conditions and threshold question described"
        }
      ],
      "missingIdeas": [
        "No worked diagram-only extraction of gear contacts, rope support count, force line/moment arm or center/support geometry."
      ],
      "priorKnowledge": "Local rules are supplied, but unfamiliar configuration interpretation is an application gap, not an existing-ID dependency inferred from historical figure-driven guidance.",
      "workedExamples": "Current examples calculate/compare from stated configurations, not unseen graphical data.",
      "scopeLimit": "Current source families/formats unknown. All existing worked answers are determined by the prose givens; no load-bearing figure dependency asserted or illustration quality/need judged. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Internal/compound gear applications beyond definition reminders",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-gear-rotations"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            28,
            33
          ],
          "note": "Exceptions defined"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            39,
            68
          ],
          "note": "Only external worked cases"
        }
      ],
      "missingIdeas": [
        "Worked internal gear direction/ratio, same-shaft compound train, loops or carrier movement."
      ],
      "priorKnowledge": "Exceptions defined locally, so no strict richer gear/Physics lesson edge.",
      "workedExamples": "No internal/compound application; external hub is explicitly connected.",
      "scopeLimit": "Exact advanced gear inclusion/depth unknown; no arbitrary additional-example minimum. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058",
        "dost-sei-L108"
      ],
      "facet": "Hydraulic systems: pressure transmission and piston force-area applications",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "Pascal pressure transmission, differing piston areas and force/displacement calculations."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Liquid depth/continuity/Bernoulli is not a hydraulic-piston method; no absent-corpus foundation claim. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dcat-L079",
        "dost-sei-L099",
        "dost-sei-L107"
      ],
      "facet": "Gases: pressure-volume-temperature/ideal-gas relationships",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "Gas-law thermal/compressible model and P-V-T calculations."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Do not count liquid hydrostatics/steady incompressible pipe flow as chemistry gas-law or ideal-gas teaching. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dcat-L079"
      ],
      "facet": "Chemical bonding and biomolecules/material-property relationships",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No bonding/biomolecule/material-property methods."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "DCAT chemistry compound row is only a provisional pressure-name lead; its chemical components are not taught here. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L099"
      ],
      "facet": "Chemistry: mixtures/substances, particle models, atomic rearrangements and reaction conditions",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No chemistry classification/atomic/reaction methods in owned fluid lesson."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Other science teaching is outside this local verdict. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058"
      ],
      "facet": "General translational/rotational motion and Newtonian force analysis",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-gear-rotations",
        "lesson-mechanical-technical-reasoning-pulleys-and-levers",
        "lesson-mechanical-technical-reasoning-springs-and-weights",
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            10,
            95
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            10,
            127
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            10,
            92
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No full motion equations/graphs, Newton-law system analysis, momentum or rotational dynamics calculation."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Gear angular direction/speed, static lever balance, spring extension and tipping are narrower applications, not complete applied-physics motion preparation. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L054",
        "upcat-L162",
        "dcat-L080",
        "ustet-L117",
        "pupcet-L118",
        "dost-sei-L107"
      ],
      "facet": "Interpret motion graphs/equations and momentum/gravity dynamics",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers",
        "lesson-mechanical-technical-reasoning-springs-and-weights",
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            10,
            127
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            10,
            92
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "Motion graphs, momentum/impulse, acceleration dynamics and general gravitational law."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Locally provided W=mg/static spring and lever formulas do not close the rest of these compound mechanics rows. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124"
      ],
      "facet": "Electrical safety and energy-efficiency relationships",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure",
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            10,
            127
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "Electrical current/circuit behavior, safety and electrical-efficiency methods."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Mechanical energy-loss reminders are not electrical safety instruction. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Mechanical/electrical domain: charging and circuit behavior",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure",
        "lesson-mechanical-technical-reasoning-gear-rotations",
        "lesson-mechanical-technical-reasoning-pulleys-and-levers",
        "lesson-mechanical-technical-reasoning-springs-and-weights",
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            10,
            95
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            10,
            127
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            10,
            92
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No charge/circuit/electrical relation instruction."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "DOST official Mechanical wording includes electrical relationships; the five current mechanical models do not close that part. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124"
      ],
      "facet": "Light and sound properties/applied wave behavior",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure",
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            10,
            127
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No optics/acoustics methods."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Machine/fluid examples do not close conditional applied-physics light/sound components. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dcat-L083",
        "ustet-L124",
        "dost-sei-L058",
        "upcat-L149"
      ],
      "facet": "Simple/compound machines and actual mechanical efficiency",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-pulleys-and-levers"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            12,
            24
          ],
          "note": "Ideal pulley work/travel and real loss reminders"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            30,
            40
          ],
          "note": "Ideal lever force balance"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            125,
            127
          ],
          "note": "Real friction/component-weight caution"
        }
      ],
      "missingIdeas": [
        "Efficiency definition/calculation, losses and other simple/compound machine families not developed."
      ],
      "priorKnowledge": "Current ideal formulas supplied locally; extended efficiency instruction optional for broader curriculum goal.",
      "workedExamples": "Ideal force and distance cases, not measured real-machine efficiency.",
      "scopeLimit": "Do not infer whole strengthened-SHS machine efficiency from ideal support/lever methods. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L150"
      ],
      "facet": "Other weak UPCAT facets: scalars/vectors, relative motion, magnetism and relativity",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No scalar/vector definitions, relative-motion, magnetic or relativistic methods."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "A weak broad fluid row does not demonstrate its other domains or confirm current organizer scope. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "upcat-L162"
      ],
      "facet": "Other Physics facets: heat transfer and energy through media",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure",
        "lesson-mechanical-technical-reasoning-pulleys-and-levers",
        "lesson-mechanical-technical-reasoning-springs-and-weights",
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/pulleys-and-levers.md",
          "lines": [
            10,
            127
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            10,
            92
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "Heat-transfer and broader wave/media energy methods not taught."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Only balance/stability and limited ideal machine-force/energy preparation are supported here. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L107"
      ],
      "facet": "STEM Physics: thermodynamics and full ideal-gas/gravity/momentum methods",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "Thermal-process and general advanced models beyond ideal liquid comparison."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "STEM Grade12 scheduling/completion remains conditional; no whole STEM course inferred. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L108"
      ],
      "facet": "Other strengthened General Science facets: household chemicals/reactions/solutions",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No household chemical, reaction or solution methods."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Broad curriculum row's fluid/machine facet is partial; other topics may teach these. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L108"
      ],
      "facet": "Other strengthened General Science facets: cellular energy and organ systems",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No biological cellular-energy or organ-system methods."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Owned mechanical topic absence only. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L108"
      ],
      "facet": "Other strengthened General Science facets: ecology",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No ecosystem/ecological methods."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Owned mechanical topic absence only. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L108"
      ],
      "facet": "Other strengthened General Science facets: Earth materials and geological/hydrometeorological hazards",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            10,
            112
          ],
          "note": "Full owned-body check: distinct component not taught/exemplified."
        }
      ],
      "missingIdeas": [
        "No Earth-material/hazard methods."
      ],
      "priorKnowledge": "Not indispensable to current demonstrated applications; a future expansion cannot justify a current strict edge.",
      "workedExamples": "None for this component.",
      "scopeLimit": "Owned mechanical topic absence only; no attempt to close Space Science from this guide. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "dost-sei-L054"
      ],
      "facet": "Spring model meaning: linearity versus reversible elasticity and displacement reference",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-springs-and-weights"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            12,
            35
          ],
          "note": "Elastic-limit/equilibrium terminology with linear Hooke model"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/springs-and-weights.md",
          "lines": [
            42,
            83
          ],
          "note": "Examples expressly assume linear/Hooke-law behavior"
        }
      ],
      "missingIdeas": [
        "Explicit distinction of linear proportional range from elastic reversibility; unforced/natural length versus loaded equilibrium origin."
      ],
      "priorKnowledge": "Local linear formulas and solved ratios supply the operative method; this precision gap is not a reason for a whole Physics prerequisite.",
      "workedExamples": "Ratios and k calculation within given linear model; no nonlinear/preloaded example.",
      "scopeLimit": "Physical source qualification does not establish that an exam requires nonlinear elasticity or oscillation depth. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L048",
        "upcat-L162"
      ],
      "facet": "Stability: static support test versus dynamic rollover model",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            20,
            28
          ],
          "note": "Projection and dynamic limit"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/structural-stability.md",
          "lines": [
            43,
            56
          ],
          "note": "Box threshold versus lower truck cargo"
        }
      ],
      "missingIdeas": [
        "Numerical critical angle, acceleration/load-transfer calculations and irregular center-location methods absent."
      ],
      "priorKnowledge": "Current qualitative rules supplied locally; no mandatory torque/trig/Dynamics chain.",
      "workedExamples": "Qualitative box, truck and stance examples.",
      "scopeLimit": "Does not teach vehicle-specific safety ratings, engineering design, truss forces, materials or buckling. Exact exam form/depth unknown. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    },
    {
      "requirementRefs": [
        "dost-sei-L036",
        "dost-sei-L048",
        "acet-L159",
        "ustet-L154",
        "sm-foundation-L112",
        "sm-foundation-L127",
        "cse-professional-L035",
        "cse-professional-L091",
        "cse-subprofessional-L048"
      ],
      "facet": "Actual exam placement, current mechanical inclusion and finer task families",
      "lessonIds": [
        "lesson-mechanical-technical-reasoning-fluid-pressure",
        "lesson-mechanical-technical-reasoning-gear-rotations",
        "lesson-mechanical-technical-reasoning-pulleys-and-levers",
        "lesson-mechanical-technical-reasoning-springs-and-weights",
        "lesson-mechanical-technical-reasoning-structural-stability"
      ],
      "verdict": "unknown",
      "evidence": [
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/fluid-pressure.md",
          "lines": [
            12,
            12
          ],
          "note": "Often mechanical-fluid claim not an official frequency"
        },
        {
          "path": "content/lessons/reasoning/mechanical-technical-reasoning/gear-rotations.md",
          "lines": [
            12,
            33
          ],
          "note": "Common/most gear-format claims not organizer frequencies"
        }
      ],
      "missingIdeas": [
        "Specific current task families, language/difficulty, diagram formats and official mechanical inclusion for ACET/USTET/SM/CSE remain unconfirmed."
      ],
      "priorKnowledge": "A broad Analytical, Mental Ability or Science label cannot create current prerequisites or a Mechanical area.",
      "workedExamples": "Local teaching only, not official item allocation.",
      "scopeLimit": "DOST2026 names Mechanical relationships/forces; exact families and2027 continuity unknown. CSE Professional names English Analytical symbolic logic/abstract reasoning, while Subprofessional names Clerical. Neither label automatically verifies this Mechanical topic or excludes incidental word-problem content. Owned five-body finding only; no corpus-wide absence/exam exclusion. DOST2026 Mechanical relationships/forces is official, but specific gear/pulley/spring/stability/fluid families, task formats and quantitative depth remain unknown;2027 continuity unconfirmed. Curriculum and weak leads are preparation, not current blueprints. Strengthened/STEM cohort, pre-exam completion and prior-version limits remain. Runtime unknown; practice deferred Level5."
    }
  ],
  "sourceLedger": [
    {
      "item": "lesson-mechanical-technical-reasoning-fluid-pressure",
      "issue": "Encountered depth/surface-pressure conditions at16-26",
      "originalContent": "Constant-density hydrostatic P=P0+rho gh; same static connected liquid/equal atmospheric boundary gives equal free-surface levels.",
      "disposition": "CONFIRMED within stated ideal assumptions",
      "source": "OpenStax College Physics2e, Variation of Pressure with Depth",
      "sourceUrl": "https://openstax.org/books/college-physics-2e/pages/11-4-variation-of-pressure-with-depth-in-a-fluid",
      "page": "11.4 equations11.17 and total surface-plus-fluid pressure discussion",
      "verificationNote": "Opened publisher section. It derives fluid-weight pressure from depth and density, treats small density variation appropriately, and adds atmospheric surface pressure. Equal-level statement follows static same-fluid/equal-boundary-pressure comparison; capillary/unequal-pressure exceptions stay explicit. No unconditional all-vessel claim.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-mechanical-technical-reasoning-fluid-pressure",
      "issue": "Encountered ideal steady-flow relations at32-44",
      "originalContent": "A1v1=A2v2; higher speed/lower pressure at equal height along ideal steady streamline.",
      "disposition": "CONFIRMED conditional model",
      "source": "OpenStax University Physics1, Fluid Dynamics and Bernoulli Equation",
      "sourceUrl": "https://openstax.org/books/university-physics-volume-1/pages/14-6-bernoullis-equation",
      "page": "14.5 continuity;14.6 equation14.16 and equal-height discussion",
      "verificationNote": "Publisher section states incompressible/no-viscous-force along-streamline energy relation. Continuity belongs to steady incompressible flow/one path. Named pressure-speed shortcut is conditional, not a universal flow law. No fluid numerical-output or pump-loss calculation certified. Continuity source URL: https://openstax.org/books/university-physics-volume-1/pages/14-5-fluid-dynamics, equation14.14.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-mechanical-technical-reasoning-gear-rotations",
      "issue": "Encountered direction, tooth ratio and same-shaft rules at12-33",
      "originalContent": "External meshes reverse, gear speeds inversely follow compatible tooth counts; internal contact may preserve direction and rigid same-shaft gears share velocity.",
      "disposition": "CONFIRMED for stated ordinary fixed-axis connections",
      "source": "Carnegie Mellon Introduction to Mechanisms, Chapters7 and2",
      "sourceUrl": "https://www.cs.cmu.edu/~rapidproto/mechanisms/chpt7.html",
      "page": "7.6 Ordinary Gear Trains; Chapter2 same-shaft example",
      "verificationNote": "University source states inverse tooth ratio, direction sign from external-mesh count, and no reversal for internal contact in ordinary trains. Chapter2 (https://www.cs.cmu.edu/~rapidproto/mechanisms/chpt2.html) explains keyed gears share speed. It warns broader spatial/planetary arrangements need other analysis. This verifies model conventions, not an exam-frequency claim.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-mechanical-technical-reasoning-pulleys-and-levers",
      "issue": "Encountered pulley support and lever-moment-arm methods at18-40",
      "originalContent": "Ideal supporting rope-segment count gives force gain; lever force ratio depends on perpendicular moment arms.",
      "disposition": "CONFIRMED ideal model",
      "source": "OpenStax College Physics2e, Simple Machines",
      "sourceUrl": "https://openstax.org/books/college-physics-2e/pages/9-5-simple-machines",
      "page": "9.5 equation9.31/9.32 and Figure9.24 accompanying text",
      "verificationNote": "Publisher explains perpendicular input/output lever arms and frictionless tension multiples from cables supporting a load. This supports count-supports rather than count-pulleys and the current perpendicular lever cases. Unfamiliar routing derivation/angled examples remain teaching gaps.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-mechanical-technical-reasoning-springs-and-weights",
      "issue": "Elastic/linear range terminology at12/35/110-112",
      "originalContent": "Hooke's law is described as applying within elastic limit/range.",
      "disposition": "QUALIFY: elastic reversibility and linear proportionality differ",
      "source": "OpenStax University Physics1, Elasticity and Plasticity",
      "sourceUrl": "https://openstax.org/books/university-physics-volume-1/pages/12-4-elasticity-and-plasticity",
      "page": "12.4 linearity/proportionality limit versus elastic limit",
      "verificationNote": "Opened publisher section explicitly distinguishes proportional behavior from elastic return: deformation can remain reversible beyond the proportional limit while becoming nonlinear. Later content should say linear/Hooke-law range rather than equating all elasticity with linearity. Worked examples already assume ideal/linear/Hooke-law range, so this does not create a richer Physics prerequisite.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-mechanical-technical-reasoning-springs-and-weights",
      "issue": "Displacement reference at12/19/22/28-30",
      "originalContent": "Restoring spring force versus displacement from equilibrium; hanging extension mg/k.",
      "disposition": "QUALIFY natural/unloaded versus loaded equilibrium origin",
      "source": "OpenStax College Physics2e, Elasticity Stress and Strain",
      "sourceUrl": "https://openstax.org/books/college-physics-2e/pages/5-3-elasticity-stress-and-strain",
      "page": "5.3 deformation DeltaL and Hooke relation",
      "verificationNote": "Publisher describes change in length/deformation for Hooke force. The current hanging extension should reference the spring's unstretched length; a loaded equilibrium reference instead describes displacement around force balance. Recommend explicit origin during later content work; no oscillation method or full correctness sweep asserted.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-mechanical-technical-reasoning-structural-stability",
      "issue": "Encountered support/CG tipping rule at12-28/43-47/61-65",
      "originalContent": "Weight line crossing support edge causes gravity-driven tipping; lower CG/wider base improves usual static margin.",
      "disposition": "CONFIRMED within stated comparable quasi-static model",
      "source": "OpenStax College Physics2e, Stability",
      "sourceUrl": "https://openstax.org/books/college-physics-2e/pages/9-3-stability",
      "page": "9.3 center of gravity, support base and restoring/overturning comparison",
      "verificationNote": "Publisher relates center relative to support base to restoring/overturning tendency and describes lower CG/wider support increasing stability. Current examples give comparable conditions; no critical-angle, force-system or vehicle-specific safety claim is certified.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "lesson-mechanical-technical-reasoning-structural-stability",
      "issue": "Static versus dynamic qualification at28/52-56",
      "originalContent": "Turning vehicle requires acceleration/load-transfer consideration beyond vertical gravity projection.",
      "disposition": "CONFIRMED model boundary; exact vehicle outcome not verified",
      "source": "NHTSA current Car Safety Ratings description",
      "sourceUrl": "https://www.nhtsa.gov/ratings",
      "page": "Rollover Resistance Test Scenario / Static Stability Factor",
      "verificationNote": "Opened primary current page. It combines an at-rest top-heaviness measurement with a dynamic driving maneuver rather than treating static measurement as the entire prediction. This corroborates the lesson's boundary; no actual truck outcome, safety rating or driving instruction is inferred.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "selected mechanical worked examples",
      "issue": "Arithmetic reconstructed for teaching/evidence only",
      "originalContent": "Gear10*6/30; pulley60*9.8/2 and rope travel; perpendicular lever balance; spring ratios and stiffness.",
      "disposition": "CONFIRMED selected named-model arithmetic; givens are illustrative",
      "source": "Pinned owned sources and named ideal equations",
      "sourceUrl": "https://github.com/Aedwon/Pantas/tree/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/reasoning/mechanical-technical-reasoning",
      "page": "gear53-63;pulley59-96;spring42-83",
      "verificationNote": "Selected calculations:2gear turns;294N effort/4m rope;392N and196N lever effort;12cm extension,5kg mass,200N/m stiffness. These follow provided ideal/linear assumptions and supplied parameters. No actual measured gear/spring/machine or published example-given provenance is established; no new input numbers, full standards pass or Level5 blind solve performed.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    },
    {
      "item": "Mechanical topic exam scope",
      "issue": "Encountered common/often/most format statements atfluid12 andgear12/33",
      "originalContent": "Mechanical fluid setups often idealized; common/most figure questions external spur gears.",
      "disposition": "UNKNOWN official fine taxonomy/frequency; narrow to preparation",
      "source": "Accepted DOST2026 requirement source and overlap packets",
      "sourceUrl": "https://science-scholarships.ph/pdf/2026_DOST-SEI_UG_Primer.pdf",
      "page": "accepted dost-sei-L048, primerp6; cohort-qualified curriculum rows",
      "verificationNote": "Accepted packet names mechanical/electrical relationships and forces for2026; it does not establish exact gear/pulley/spring/stability/fluid formats or a public frequency ranking.2027 continuity remains unknown. URL/page provenance is reused accepted research, not a fresh organizer retrieval. Other current Mechanical domains remain unknown; CSE Analytical label alone is no endorsement.",
      "branch": "content/question-qa-r2",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "accessDate": "2026-10-08"
    }
  ]
}
```
