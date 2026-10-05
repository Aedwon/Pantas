# Trigonometry structure audit

Status: DRAFT, Level 3 only. Policy main6d0bb7318ad396abe62c6c59b6d437f758ed65c4 matched live/cached; audit local/live25ebd755560a38d4a21323424fee63ece8171930; corpus765c5dc0fa5586281047bf4f7b30d09ab3707887 confirmed clean. Current policies/standards retrieved; approved spec/plan, orchestrator, latest decisions and complete updated contract read. Accepted requirements and overlap notes were read in this continuing audit; unchanged input manifests verified. No physics or arithmetic edits. Runtime unknown; practice deferred Level5.

## Machine-readable appendix

```json
{
  "level": 3,
  "status": "DRAFT",
  "subject": "mathematics",
  "topic": "trigonometry",
  "policyCommit": "6d0bb7318ad396abe62c6c59b6d437f758ed65c4",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "slug": "angles-and-radian-measure",
      "goal": "Explain radians, convert angle units, find coterminal angles and calculate arc length with a radian central angle.",
      "skills": [
        [
          "Degree convention",
          "explained",
          12,
          14,
          "worked",
          39,
          54
        ],
        [
          "Radian arc/radius meaning",
          "explained",
          16,
          22,
          "worked",
          111,
          133
        ],
        [
          "Degree-to-radian conversion",
          "explained",
          24,
          27,
          "worked",
          39,
          54
        ],
        [
          "Radian-to-degree conversion",
          "explained",
          24,
          27,
          "worked",
          56,
          71
        ],
        [
          "Signed standard-position angles",
          "explained",
          29,
          29,
          "worked",
          73,
          109
        ],
        [
          "Coterminal angles",
          "explained",
          29,
          29,
          "worked",
          90,
          109
        ],
        [
          "Radian quadrant placement",
          "thin",
          139,
          139,
          "thin",
          73,
          88
        ],
        [
          "Arc length in radians",
          "explained",
          31,
          33,
          "worked",
          111,
          133
        ]
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Angle meaning, units, full turns and arc length share one coherent measure goal. Quadrant labeling is less developed than conversions; no split justified.",
        "proposal": "Retain as an existing foundation for radian-based circle/inverse work; clarify quadrant ranges locally rather than force a circular dependency.",
        "cost": "One concise quadrant explanation; no new unit."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-trigonometry-angles-and-radian-measure",
      "path": "content/lessons/mathematics/trigonometry/angles-and-radian-measure.md",
      "sha256": "20a59f4fdf82eed1a0df1dd43f803bec7834e6cc9297cbe10cb114ccc2af0fdd",
      "readLines": [
        1,
        161
      ]
    },
    {
      "slug": "basic-trigonometric-ratios",
      "goal": "Read acute right-triangle ratios, use reciprocal ratios and find missing sides or other ratios.",
      "skills": [
        [
          "Side names relative to an acute angle",
          "explained",
          12,
          16,
          "worked",
          48,
          68
        ],
        [
          "Acute sine ratio",
          "explained",
          22,
          22,
          "worked",
          48,
          60
        ],
        [
          "Acute cosine ratio",
          "explained",
          24,
          24,
          "worked",
          48,
          64
        ],
        [
          "Acute tangent ratio",
          "explained",
          26,
          26,
          "worked",
          48,
          68
        ],
        [
          "Acute cosecant reciprocal",
          "explained",
          28,
          30,
          "worked",
          118,
          130
        ],
        [
          "Acute secant reciprocal",
          "explained",
          28,
          30,
          "worked",
          118,
          134
        ],
        [
          "Acute cotangent reciprocal",
          "explained",
          28,
          30,
          "worked",
          118,
          138
        ],
        [
          "Scale invariance of ratios",
          "explained",
          32,
          32,
          "worked",
          140,
          160
        ],
        [
          "Standard acute-angle values",
          "explained",
          34,
          34,
          "worked",
          94,
          116
        ],
        [
          "Recover remaining sides/ratios",
          "explained",
          70,
          92,
          "worked",
          70,
          92
        ],
        [
          "Complementary-angle relation",
          "explained",
          166,
          166,
          "worked",
          166,
          166
        ]
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Acute ratios, reciprocals and side reconstruction share one foundation. The side-finding example already teaches equation selection; broader general-angle methods are a separate scope.",
        "proposal": "Retain; make the similar-triangle/scale interpretation explicit before ratio-to-length applications. Coordinate shared ratio teaching with solving-right-triangles rather than duplicate it.",
        "cost": "Small local clarification and shared-core coordination; no split per ratio."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-trigonometry-basic-trigonometric-ratios",
      "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
      "sha256": "536c2fcee4e48cc0b7c690b3b2bba2e1c29b2b9dfeaf40b7de32be188ee25ab3",
      "readLines": [
        1,
        194
      ]
    },
    {
      "slug": "inverse-trigonometric-functions",
      "goal": "Return principal inverse-trig angles, respect allowed inputs and simplify compositions with range care.",
      "skills": [
        [
          "Inverse meaning versus reciprocal",
          "explained",
          12,
          16,
          "worked",
          30,
          48
        ],
        [
          "Arcsine principal range",
          "explained",
          16,
          18,
          "worked",
          30,
          42
        ],
        [
          "Arccosine principal range",
          "explained",
          16,
          19,
          "worked",
          50,
          69
        ],
        [
          "Arctangent principal range",
          "explained",
          16,
          20,
          "worked",
          71,
          86
        ],
        [
          "Arcsine/arccosine input domains",
          "explained",
          24,
          24,
          "thin",
          158,
          162
        ],
        [
          "Arctangent real-input domain",
          "explained",
          24,
          24,
          "not-required",
          24,
          24
        ],
        [
          "Exact positive inverse values",
          "explained",
          12,
          14,
          "worked",
          30,
          48
        ],
        [
          "Negative inverse principal values",
          "explained",
          22,
          22,
          "worked",
          50,
          86
        ],
        [
          "Mixed-function triangle compositions",
          "explained",
          26,
          26,
          "worked",
          88,
          134
        ],
        [
          "Same-function and reverse compositions",
          "explained",
          140,
          140,
          "none",
          28,
          134
        ],
        [
          "Endpoint axes cases",
          "explained",
          164,
          168,
          "thin",
          168,
          168
        ]
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Principal range, input domain and composition checks all serve one inverse-function goal. The triangle compositions already explain their local side-ratio procedure.",
        "proposal": "Retain; add an off-principal-range reverse-composition application and an endpoint decision before relying on sign reminders.",
        "cost": "Two focused applications or expanded explanations; no split per inverse function."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-trigonometry-inverse-trigonometric-functions",
      "path": "content/lessons/mathematics/trigonometry/inverse-trigonometric-functions.md",
      "sha256": "eb0aef55a11aa8300729393b0c0ce192a6dcc57f16460a4b3a843d66cf474c22",
      "readLines": [
        1,
        168
      ]
    },
    {
      "slug": "laws-of-sines-and-cosines",
      "goal": "Choose a triangle law from given data, match opposite pairs and solve oblique side/angle problems while checking ambiguity.",
      "skills": [
        [
          "Opposite-side labeling",
          "explained",
          12,
          12,
          "worked",
          35,
          57
        ],
        [
          "Law of Sines ASA/AAS",
          "explained",
          14,
          16,
          "worked",
          35,
          57
        ],
        [
          "Triangle angle sum/side order check",
          "explained",
          59,
          74,
          "worked",
          59,
          74
        ],
        [
          "Law of Cosines SAS",
          "explained",
          18,
          22,
          "worked",
          76,
          100
        ],
        [
          "Law of Cosines SSS angle",
          "explained",
          28,
          29,
          "worked",
          102,
          134
        ],
        [
          "Choose law from given data",
          "explained",
          24,
          31,
          "worked",
          35,
          57
        ],
        [
          "SSA ambiguous cases",
          "thin",
          188,
          192,
          "none",
          33,
          164
        ],
        [
          "Oblique contextual triangle setup",
          "explained",
          136,
          164,
          "worked",
          136,
          164
        ]
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Sines/cosines belong together for choosing a method from triangle data. SSA is stated as a distinct branch but has no worked existence/count application.",
        "proposal": "Retain both laws in one solver lesson; explain and work the zero/one/two-triangle SSA checks before relying on a matched-pair shortcut.",
        "cost": "One complete ambiguity method/application sequence; no split solely because two laws exist."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-trigonometry-basic-trigonometric-ratios",
          "reason": "Indispensable missing idea: sine/cosine denote angle-dependent ratios, not side lengths or angle measures. The law lesson introduces those function symbols and uses exact acute values but does not define what the ratios represent.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/laws-of-sines-and-cosines.md",
              "lines": [
                12,
                20
              ],
              "note": "Law formulas use sine/cosine after defining only side/angle labels."
            },
            {
              "path": "content/lessons/mathematics/trigonometry/laws-of-sines-and-cosines.md",
              "lines": [
                45,
                55
              ],
              "note": "An acute-angle sine value is used in the side proportion; lookup values alone do not define the quantity."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
              "lines": [
                12,
                26
              ],
              "note": "Defines the acute triangle side labels and sine/cosine as side ratios."
            },
            {
              "path": "content/lessons/mathematics/trigonometry/basic-trigonometric-ratios.md",
              "lines": [
                32,
                34
              ],
              "note": "Explains angle-based scale invariance and exact acute values."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-trigonometry-laws-of-sines-and-cosines",
      "path": "content/lessons/mathematics/trigonometry/laws-of-sines-and-cosines.md",
      "sha256": "7d15fc76eb24f86368920ec2a05f031c56f699780fa8b2b7162317fb756e6a78",
      "readLines": [
        1,
        198
      ]
    },
    {
      "slug": "solving-right-triangles",
      "goal": "Model elevation/depression and solve right-triangle sides or angles, including two observations and observer-height adjustments.",
      "skills": [
        [
          "Right-triangle acute-angle sum",
          "explained",
          12,
          12,
          "worked",
          97,
          107
        ],
        [
          "Elevation/depression meanings",
          "explained",
          14,
          22,
          "worked",
          31,
          95
        ],
        [
          "Choose and use a side ratio",
          "explained",
          24,
          27,
          "worked",
          31,
          73
        ],
        [
          "Exact angle from side ratio",
          "explained",
          55,
          73,
          "worked",
          55,
          73
        ],
        [
          "Whole-triangle nonstandard-angle setup",
          "explained",
          97,
          117,
          "worked",
          97,
          117
        ],
        [
          "Two-observation height model",
          "explained",
          119,
          153,
          "worked",
          119,
          153
        ],
        [
          "Observer-height adjustment",
          "explained",
          181,
          185,
          "none",
          29,
          153
        ]
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The applications share one triangle-modeling goal, and local examples already set up the needed ratios. Observer-height correction is explained only as a trap, without application.",
        "proposal": "Retain; demonstrate one nonzero eye-height setup and place that geometric condition before complex applications. Coordinate duplicate acute-ratio teaching with the basic-ratios unit without adding a redundant strict edge.",
        "cost": "One focused setup/example and small reordering; no new application lesson."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-trigonometry-solving-right-triangles",
      "path": "content/lessons/mathematics/trigonometry/solving-right-triangles.md",
      "sha256": "db3a216d0803d37f3b61cef350fba0c47f2d861a0dc25b00489b41e1faa43ebd",
      "readLines": [
        1,
        191
      ]
    },
    {
      "slug": "trigonometric-identities",
      "goal": "Rewrite equivalent trig expressions, recover missing values and preserve the original domain and sign conditions.",
      "skills": [
        [
          "Identity meaning and shared domain",
          "explained",
          12,
          12,
          "worked",
          66,
          81
        ],
        [
          "General cosecant reciprocal identity",
          "explained",
          16,
          18,
          "none",
          38,
          149
        ],
        [
          "General secant reciprocal identity",
          "explained",
          16,
          18,
          "worked",
          100,
          123
        ],
        [
          "General cotangent reciprocal identity",
          "explained",
          16,
          18,
          "none",
          38,
          149
        ],
        [
          "Quotient identities",
          "explained",
          20,
          24,
          "worked",
          66,
          81
        ],
        [
          "Sine/cosine Pythagorean identity",
          "explained",
          26,
          34,
          "worked",
          40,
          64
        ],
        [
          "Tangent/secant Pythagorean identity",
          "explained",
          30,
          32,
          "worked",
          125,
          149
        ],
        [
          "Cotangent/cosecant Pythagorean identity",
          "explained",
          30,
          32,
          "none",
          38,
          149
        ],
        [
          "Factor/cancel with original-domain care",
          "explained",
          36,
          36,
          "worked",
          100,
          123
        ],
        [
          "Select square-root sign",
          "explained",
          175,
          179,
          "worked",
          40,
          64
        ],
        [
          "Trig power notation",
          "explained",
          181,
          185,
          "worked",
          181,
          185
        ],
        [
          "Sum/difference and double-angle identities",
          "absent",
          10,
          36,
          "none",
          38,
          149
        ]
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Reciprocal, quotient and Pythagorean identities serve one equivalent-expression goal. Local examples teach factor cancellation and range/domain checks, so deeper algebra or circle lessons are not automatic strict prerequisites.",
        "proposal": "Retain the three-family foundation; add an application for the cotangent/cosecant branch if that branch remains in the learning goal. Keep any later identity extensions separately bounded by supported scope.",
        "cost": "One targeted application; broader identity families would require new authoring, not a cosmetic split."
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-trigonometry-trigonometric-identities",
      "path": "content/lessons/mathematics/trigonometry/trigonometric-identities.md",
      "sha256": "40b3c720fbdb33f55a9cd2622e7f8242a8e5198c9d98a2cf778fd20b702d29f9",
      "readLines": [
        1,
        191
      ]
    },
    {
      "slug": "unit-circle",
      "goal": "Define general-angle sine/cosine as coordinates and use reference angles and quadrant signs to obtain exact trig values.",
      "skills": [
        [
          "General-angle coordinate definition",
          "explained",
          12,
          20,
          "worked",
          103,
          123
        ],
        [
          "Standard special-angle values",
          "explained",
          24,
          28,
          "worked",
          50,
          101
        ],
        [
          "Reference-angle method",
          "explained",
          30,
          34,
          "worked",
          50,
          101
        ],
        [
          "Quadrant sign method",
          "explained",
          34,
          34,
          "worked",
          50,
          101
        ],
        [
          "Negative/coterminal and axis values",
          "explained",
          103,
          123,
          "worked",
          103,
          123
        ],
        [
          "Combine exact values",
          "explained",
          125,
          143,
          "worked",
          125,
          143
        ],
        [
          "Radian placement",
          "thin",
          147,
          147,
          "none",
          48,
          143
        ],
        [
          "Tangent undefined/zero axis cases",
          "explained",
          173,
          177,
          "thin",
          173,
          177
        ],
        [
          "Polar/rectangular conversion beyond radius1",
          "absent",
          10,
          34,
          "none",
          48,
          143
        ],
        [
          "Circular-function graph features",
          "absent",
          10,
          34,
          "none",
          48,
          143
        ]
      ],
      "structure": {
        "verdict": "retain",
        "reason": "General-angle coordinates, reference angles, signs and exact values form one coherent extension beyond acute ratios. Radians are used only as a shortcut without local unit meaning.",
        "proposal": "Retain; connect actual radian use to the existing measure foundation and clarify which broader circular-function methods remain outside this exact-values goal.",
        "cost": "A narrow foundation connection and local scope clarification; broader graphs/polar methods would need new teaching if supported."
      },
      "prerequisites": [
        {
          "lessonId": "lesson-trigonometry-angles-and-radian-measure",
          "reason": "Indispensable missing idea for the current radian shortcut: what radian measure means and why pi/2, pi and3pi/2 denote quadrant boundaries. Unit-circle does not define radian units locally.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/unit-circle.md",
              "lines": [
                147,
                147
              ],
              "note": "Current radian placement shortcut consumes radian measures without local unit definition; degree procedures elsewhere are self-contained."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/angles-and-radian-measure.md",
              "lines": [
                14,
                27
              ],
              "note": "Defines degree/radian correspondence and both conversion rules."
            },
            {
              "path": "content/lessons/mathematics/trigonometry/angles-and-radian-measure.md",
              "lines": [
                137,
                139
              ],
              "note": "Supplies radian boundary anchors and a quadrant comparison."
            }
          ]
        },
        {
          "lessonId": "lesson-geometry-coordinate-geometry",
          "reason": "Indispensable missing idea for the current coordinate definition: ordered coordinates describe signed horizontal then vertical positions. Unit-circle labels cosine as x and sine as y but does not define what those positions measure.",
          "scope": "across-topics",
          "consumerEvidence": [
            {
              "path": "content/lessons/mathematics/trigonometry/unit-circle.md",
              "lines": [
                12,
                18
              ],
              "note": "The main general-angle definition depends on point coordinates and origin."
            },
            {
              "path": "content/lessons/mathematics/trigonometry/unit-circle.md",
              "lines": [
                117,
                123
              ],
              "note": "Axis values are read from signed ordered pairs."
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/geometry/coordinate-geometry.md",
              "lines": [
                12,
                20
              ],
              "note": "Defines x/y positions as horizontal then vertical steps and relates coordinate changes to geometric distance."
            }
          ]
        }
      ],
      "prerequisiteStatus": "links-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "id": "lesson-trigonometry-unit-circle",
      "path": "content/lessons/mathematics/trigonometry/unit-circle.md",
      "sha256": "4bb846e0bf16d292a79c1aff057db76c27efc4528b1f587eed48f4ad09f4a9c7",
      "readLines": [
        1,
        177
      ]
    }
  ],
  "requirementFacets": [],
  "sourceLedger": []
}
```
