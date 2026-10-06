# Precalculus and basic calculus lesson structure audit

Status: DRAFT. Author findings only; independent semantic review pending.

## Identity and scope

Policy: current main `cd66ea22d197acbd5af6ae2185138ffa5d14d595`, live/cached match October 6, 2026. Corpus `765c5dc0fa5586281047bf4f7b30d09ab3707887`, pinned clean worktree. Precalculus startup audit HEAD ee456e03ffb33d0138d69665aa65d1edadd75d5b. Watcher owns Git mutations. Sole output ownership; other authors and frozen application code preserved. Completed science outputs are outside this assignment ownership.

Current main AGENTS, WORKFLOW, SUBAGENTS, startup, source policy and applicable content standards retrieved/read; full spec, plan, orchestrator, October 4 and latest Level 3 decisions and illustration decision read. Relevant accepted requirements, inventory, overlap and scope notes read. Policy blobs are unchanged from the earlier read revision, verified at current main. Historical pending headers do not override accepted Levels 1/2.

Evidence paths are pinned corpus-relative; lines are 1-based inclusive. Full-read hashes/ranges are in the appendix. B03/L01/L17/L19 references support structural teaching findings only. Level 4 standards, Level 5 questions/practice/blind solves and illustration assessment remain deferred. Runtime availability is unknown.

## Recommendations and limits

Startup checkpoint only; four lesson bodies remain unread. DOST historical2026 Calculus is distinct from unknown2027 continuity and conditional STEM-specific fine methods. SM has a conditional conic preparation lead, not a calculus trio inclusion. Other exams current calculus inclusion remains unresolved, not excluded.

## Lesson findings

### lesson-precalculus-basic-calculus-basic-derivatives

Goal: Differentiate algebraic power expressions and products/quotients/compositions, then interpret computed tangent slopes.

Teaching covers Positive-integer power differentiation, Negative-power differentiation, Fractional-power differentiation, Constant derivative, Constant multiples, Sum and difference differentiation, Product rule, Quotient rule, Power-composition chain rule, Derivative domain restrictions, Tangent slope at a point, Horizontal tangent location. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Power/product/quotient/chain methods serve one coherent differentiation goal (L01/L17/L19). Application and first-principles gaps do not create a developed second lesson. Proposal: Keep the shared basic differentiation core. Explain the conceptual rate foundation and add source-bounded applications before evaluating an applications split. Cost: Targeted explanatory/examples additions and later practice alignment require approval; no new identity or arbitrary example quota proposed. Evidence: content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md:12-166.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-precalculus-basic-calculus-basic-integrals

Goal: Find elementary power antiderivatives and evaluate continuous polynomial definite integrals, distinguishing signed and ordinary areas.

Teaching covers Antiderivative reverses differentiation, Constant of integration, Integral power rule for nonnegative integer powers, Integral power rule for fractional powers, Integral power rule for negative powers other than minus one, Integral of reciprocal x and interval restriction, Integrate sums and differences, Integrate constant multiples, Definite integral as net signed area, Ordinary area from a nonnegative integrand, Fundamental Theorem endpoint evaluation, Constant cancellation in definite integrals, Geometric evaluation of a linear nonnegative integral. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Antiderivative rules and definite endpoint evaluation support one coherent introductory integration goal (L01/L17/L19). Riemann sums and signed-region applications are undeveloped, not an already taught second unit. Proposal: Retain basic integral core; place area/accumulation meaning before using the endpoint theorem. Add explicit Riemann-sum and sign-changing-area teaching as source-bounded gaps; reconsider an applications split only after teaching exists. Cost: Targeted conceptual/examples additions and later practice review require approval. No automatic split or illustration production. Evidence: content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md:12-142.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

## Explicit no-existing-prerequisite list

lesson-precalculus-basic-calculus-basic-derivatives, lesson-precalculus-basic-calculus-basic-integrals. Missing-foundation statuses remain separate from verified links.

## Machine-readable appendix

```json
{
  "level": 3,
  "status": "DRAFT",
  "subject": "mathematics",
  "topic": "precalculus-basic-calculus",
  "policyCommit": "cd66ea22d197acbd5af6ae2185138ffa5d14d595",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "id": "lesson-precalculus-basic-calculus-basic-derivatives",
      "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
      "sha256": "49e744658ea460a801c6043f828639881aae2f5abbdde0a9dc004ce240f302db",
      "readLines": [
        1,
        166
      ],
      "goal": "Differentiate algebraic power expressions and products/quotients/compositions, then interpret computed tangent slopes.",
      "skills": [
        {
          "name": "Derivative as instantaneous rate and tangent slope",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                12,
                12
              ],
              "note": "L01 local teaching: Derivative as instantaneous rate and tangent slope"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                109,
                126
              ],
              "note": "L19 example: Derivative as instantaneous rate and tangent slope"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Meaning is stated; no limiting secant/rate construction or non-graph rate model. Tangent slope is calculated, not explained from first principles."
          ]
        },
        {
          "name": "Positive-integer power differentiation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                14,
                20
              ],
              "note": "L01 local teaching: Positive-integer power differentiation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                44,
                51
              ],
              "note": "L19 example: Positive-integer power differentiation"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Negative-power differentiation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                16,
                20
              ],
              "note": "L01 local teaching: Negative-power differentiation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                64,
                66
              ],
              "note": "L19 example: Negative-power differentiation"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Fractional-power differentiation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                16,
                20
              ],
              "note": "L01 local teaching: Fractional-power differentiation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                55,
                62
              ],
              "note": "L19 example: Fractional-power differentiation"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Constant derivative",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                20,
                20
              ],
              "note": "L01 local teaching: Constant derivative"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                46,
                51
              ],
              "note": "L19 example: Constant derivative"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Constant multiples",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                20,
                20
              ],
              "note": "L01 local teaching: Constant multiples"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                46,
                51
              ],
              "note": "L19 example: Constant multiples"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Sum and difference differentiation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                20,
                20
              ],
              "note": "L01 local teaching: Sum and difference differentiation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                46,
                51
              ],
              "note": "L19 example: Sum and difference differentiation"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Product rule",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                22,
                26
              ],
              "note": "L01 local teaching: Product rule"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                68,
                77
              ],
              "note": "L19 example: Product rule"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Quotient rule",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                28,
                32
              ],
              "note": "L01 local teaching: Quotient rule"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                79,
                94
              ],
              "note": "L19 example: Quotient rule"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Power-composition chain rule",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                34,
                40
              ],
              "note": "L01 local teaching: Power-composition chain rule"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                96,
                107
              ],
              "note": "L19 example: Power-composition chain rule"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Worked application is power of a polynomial; wider compositions need their own outer derivative rules."
          ]
        },
        {
          "name": "Derivative domain restrictions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                16,
                20
              ],
              "note": "L01 local teaching: Derivative domain restrictions"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                55,
                66
              ],
              "note": "L19 example: Derivative domain restrictions"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Function domain and derivative domain are distinguished; finite endpoint derivative exclusion is supplied rather than derived."
          ]
        },
        {
          "name": "Tangent slope at a point",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                12,
                12
              ],
              "note": "L01 local teaching: Tangent slope at a point"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                109,
                120
              ],
              "note": "L19 example: Tangent slope at a point"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Horizontal tangent location",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                122,
                124
              ],
              "note": "L01 local teaching: Horizontal tangent location"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                122,
                126
              ],
              "note": "L19 example: Horizontal tangent location"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Tangent-line equation",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                132,
                132
              ],
              "note": "L01 local teaching: Tangent-line equation"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Point and slope recipe is stated; equation construction is absent locally."
          ]
        },
        {
          "name": "Derivative from a difference-quotient limit",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                10,
                166
              ],
              "note": "L01 local teaching: Derivative from a difference-quotient limit"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "No difference quotient or secant-to-tangent limit. Broad curriculum derivative label does not establish this exact exam demand."
          ]
        },
        {
          "name": "Differentiability meaning and continuity relationship",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                12,
                40
              ],
              "note": "L01 local teaching: Differentiability meaning and continuity relationship"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Differentiability is assumed, not defined; corners/discontinuity relationship not taught."
          ]
        },
        {
          "name": "Exponential-function derivatives",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                162,
                166
              ],
              "note": "L01 local teaching: Exponential-function derivatives"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Trap names the need for a different rule but gives no rule/procedure. Current fine exam inclusion unknown."
          ]
        },
        {
          "name": "Logarithmic-function derivatives",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                10,
                166
              ],
              "note": "L01 local teaching: Logarithmic-function derivatives"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "No local rule or procedure; conditional extension, not an established specific exam requirement."
          ]
        },
        {
          "name": "Trigonometric-function derivatives",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                10,
                166
              ],
              "note": "L01 local teaching: Trigonometric-function derivatives"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "No local rule or procedure; conditional extension, not an established specific exam requirement."
          ]
        },
        {
          "name": "Derivative-based optimization applications",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                10,
                166
              ],
              "note": "L01 local teaching: Derivative-based optimization applications"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Horizontal tangent location is present; no optimization model, candidate comparison or extremum justification."
          ]
        },
        {
          "name": "Derivative-based motion or other rate applications",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
              "lines": [
                10,
                166
              ],
              "note": "L01 local teaching: Derivative-based motion or other rate applications"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Instantaneous rate is named, but no applied rate model or units reasoning."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "sharedCore": "Positive-integer power differentiation; Negative-power differentiation; Fractional-power differentiation; Constant derivative; Constant multiples; Sum and difference differentiation; Product rule; Quotient rule; Power-composition chain rule; Derivative domain restrictions; Tangent slope at a point; Horizontal tangent location",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Power/product/quotient/chain methods serve one coherent differentiation goal (L01/L17/L19). Application and first-principles gaps do not create a developed second lesson.",
        "proposal": "Keep the shared basic differentiation core. Explain the conceptual rate foundation and add source-bounded applications before evaluating an applications split.",
        "cost": "Targeted explanatory/examples additions and later practice alignment require approval; no new identity or arbitrary example quota proposed.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
            "lines": [
              12,
              166
            ],
            "note": "structure basis"
          }
        ]
      },
      "prerequisites": [],
      "prerequisiteStatus": "none-found",
      "missingFoundations": [],
      "figureDependencies": [],
      "availability": "unknown: corpus-bound runtime not verified",
      "practice": "deferred Level5"
    },
    {
      "id": "lesson-precalculus-basic-calculus-basic-integrals",
      "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
      "sha256": "d1a50b2a2aee5a4001c399d446487a1de18d8def06352ce189733c9a770db15b",
      "readLines": [
        1,
        142
      ],
      "goal": "Find elementary power antiderivatives and evaluate continuous polynomial definite integrals, distinguishing signed and ordinary areas.",
      "skills": [
        {
          "name": "Antiderivative reverses differentiation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                12,
                18
              ],
              "note": "L01 local teaching: Antiderivative reverses differentiation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                12,
                16
              ],
              "note": "L19 example: Antiderivative reverses differentiation"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "A local derivative-antiderivative pair supplies the meaning; no general differentiation-rule dependency inferred for the integration procedure."
          ]
        },
        {
          "name": "Constant of integration",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                14,
                18
              ],
              "note": "L01 local teaching: Constant of integration"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                48,
                66
              ],
              "note": "L19 example: Constant of integration"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Integral power rule for nonnegative integer powers",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                20,
                24
              ],
              "note": "L01 local teaching: Integral power rule for nonnegative integer powers"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                48,
                66
              ],
              "note": "L19 example: Integral power rule for nonnegative integer powers"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Integral power rule for fractional powers",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                20,
                24
              ],
              "note": "L01 local teaching: Integral power rule for fractional powers"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                68,
                75
              ],
              "note": "L19 example: Integral power rule for fractional powers"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Endpoint differentiability of the antiderivative is not separately developed; ordinary-domain statement is retained."
          ]
        },
        {
          "name": "Integral power rule for negative powers other than minus one",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                20,
                24
              ],
              "note": "L01 local teaching: Integral power rule for negative powers other than minus one"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Valid-domain rule is supplied; reciprocal-power application is only advised, not worked."
          ]
        },
        {
          "name": "Integral of reciprocal x and interval restriction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                26,
                30
              ],
              "note": "L01 local teaching: Integral of reciprocal x and interval restriction"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Logarithm form and zero exclusion supplied; no explicit evaluated example or derivation."
          ]
        },
        {
          "name": "Integrate sums and differences",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                32,
                32
              ],
              "note": "L01 local teaching: Integrate sums and differences"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                59,
                66
              ],
              "note": "L19 example: Integrate sums and differences"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Integrate constant multiples",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                32,
                32
              ],
              "note": "L01 local teaching: Integrate constant multiples"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                59,
                66
              ],
              "note": "L19 example: Integrate constant multiples"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Definite integral as net signed area",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                34,
                36
              ],
              "note": "L01 local teaching: Definite integral as net signed area"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                77,
                100
              ],
              "note": "L19 example: Definite integral as net signed area"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Both examples are nonnegative. No worked negative or mixed-sign region is supplied."
          ]
        },
        {
          "name": "Ordinary area from a nonnegative integrand",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                36,
                36
              ],
              "note": "L01 local teaching: Ordinary area from a nonnegative integrand"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                77,
                100
              ],
              "note": "L19 example: Ordinary area from a nonnegative integrand"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Fundamental Theorem endpoint evaluation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                38,
                42
              ],
              "note": "L01 local teaching: Fundamental Theorem endpoint evaluation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                79,
                96
              ],
              "note": "L19 example: Fundamental Theorem endpoint evaluation"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Continuity is a stated condition; applicability beyond the supplied polynomial cases not checked."
          ]
        },
        {
          "name": "Constant cancellation in definite integrals",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                42,
                42
              ],
              "note": "L01 local teaching: Constant cancellation in definite integrals"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                112,
                116
              ],
              "note": "L19 example: Constant cancellation in definite integrals"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Cancellation is explained in words, without showing two endpoint constants algebraically."
          ]
        },
        {
          "name": "Check an antiderivative by differentiating",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                104,
                104
              ],
              "note": "L01 local teaching: Check an antiderivative by differentiating"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                55,
                57
              ],
              "note": "L19 example: Check an antiderivative by differentiating"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "One derivative result is supplied; general derivative procedure is not taught here. This is an optional verification tactic rather than a necessary dependency of locally taught integration."
          ]
        },
        {
          "name": "Geometric evaluation of a linear nonnegative integral",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                108,
                108
              ],
              "note": "L01 local teaching: Geometric evaluation of a linear nonnegative integral"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                90,
                100
              ],
              "note": "L19 example: Geometric evaluation of a linear nonnegative integral"
            }
          ],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": []
        },
        {
          "name": "Total geometric area across sign changes",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                132,
                136
              ],
              "note": "L01 local teaching: Total geometric area across sign changes"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Split at zeros and absolute areas advised; finding cuts and signed interval calculations not worked."
          ]
        },
        {
          "name": "Riemann-sum area approximation",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                10,
                142
              ],
              "note": "L01 local teaching: Riemann-sum area approximation"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Explicit curriculum preparation facet dost-sei-L135 names Riemann sums; no partition/rectangle/sample-point sum locally."
          ]
        },
        {
          "name": "Definite integral as a limit of sums",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                10,
                142
              ],
              "note": "L01 local teaching: Definite integral as a limit of sums"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "Area is stated but not built from limiting sums; exact exam depth unconfirmed."
          ]
        },
        {
          "name": "Integration as accumulated change application",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                10,
                142
              ],
              "note": "L01 local teaching: Integration as accumulated change application"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "No motion or other accumulation model; antiderivative reversal and geometric areas are present."
          ]
        },
        {
          "name": "Substitution integration method",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                10,
                142
              ],
              "note": "L01 local teaching: Substitution integration method"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "No substitution method; broader integration label alone does not establish this particular exam demand."
          ]
        },
        {
          "name": "Exponential integrals",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                10,
                142
              ],
              "note": "L01 local teaching: Exponential integrals"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "No local formula/application; fine method inclusion remains unknown."
          ]
        },
        {
          "name": "Trigonometric integrals",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
              "lines": [
                10,
                142
              ],
              "note": "L01 local teaching: Trigonometric integrals"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "limitations": [
            "No local formula/application; fine method inclusion remains unknown."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L135"
          ],
          "sharedCore": "Antiderivative reverses differentiation; Constant of integration; Integral power rule for nonnegative integer powers; Integral power rule for fractional powers; Integral power rule for negative powers other than minus one; Integral of reciprocal x and interval restriction; Integrate sums and differences; Integrate constant multiples; Definite integral as net signed area; Ordinary area from a nonnegative integrand; Fundamental Theorem endpoint evaluation; Constant cancellation in definite integrals; Geometric evaluation of a linear nonnegative integral",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Antiderivative rules and definite endpoint evaluation support one coherent introductory integration goal (L01/L17/L19). Riemann sums and signed-region applications are undeveloped, not an already taught second unit.",
        "proposal": "Retain basic integral core; place area/accumulation meaning before using the endpoint theorem. Add explicit Riemann-sum and sign-changing-area teaching as source-bounded gaps; reconsider an applications split only after teaching exists.",
        "cost": "Targeted conceptual/examples additions and later practice review require approval. No automatic split or illustration production.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
            "lines": [
              12,
              142
            ],
            "note": "structure basis"
          }
        ]
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
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Derivative as instantaneous rate and tangent slope",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            12,
            12
          ],
          "note": "L01 local teaching: Derivative as instantaneous rate and tangent slope"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            109,
            126
          ],
          "note": "L19 example: Derivative as instantaneous rate and tangent slope"
        }
      ],
      "missingIdeas": [
        "Meaning is stated; no limiting secant/rate construction or non-graph rate model. Tangent slope is calculated, not explained from first principles."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Positive-integer power differentiation",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            14,
            20
          ],
          "note": "L01 local teaching: Positive-integer power differentiation"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            44,
            51
          ],
          "note": "L19 example: Positive-integer power differentiation"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Negative-power differentiation",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            16,
            20
          ],
          "note": "L01 local teaching: Negative-power differentiation"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            64,
            66
          ],
          "note": "L19 example: Negative-power differentiation"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Fractional-power differentiation",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            16,
            20
          ],
          "note": "L01 local teaching: Fractional-power differentiation"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            55,
            62
          ],
          "note": "L19 example: Fractional-power differentiation"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Constant derivative",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            20,
            20
          ],
          "note": "L01 local teaching: Constant derivative"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            46,
            51
          ],
          "note": "L19 example: Constant derivative"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Constant multiples",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            20,
            20
          ],
          "note": "L01 local teaching: Constant multiples"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            46,
            51
          ],
          "note": "L19 example: Constant multiples"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Sum and difference differentiation",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            20,
            20
          ],
          "note": "L01 local teaching: Sum and difference differentiation"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            46,
            51
          ],
          "note": "L19 example: Sum and difference differentiation"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Product rule",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            22,
            26
          ],
          "note": "L01 local teaching: Product rule"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            68,
            77
          ],
          "note": "L19 example: Product rule"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Quotient rule",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            28,
            32
          ],
          "note": "L01 local teaching: Quotient rule"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            79,
            94
          ],
          "note": "L19 example: Quotient rule"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Power-composition chain rule",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            34,
            40
          ],
          "note": "L01 local teaching: Power-composition chain rule"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            96,
            107
          ],
          "note": "L19 example: Power-composition chain rule"
        }
      ],
      "missingIdeas": [
        "Worked application is power of a polynomial; wider compositions need their own outer derivative rules."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Derivative domain restrictions",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            16,
            20
          ],
          "note": "L01 local teaching: Derivative domain restrictions"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            55,
            66
          ],
          "note": "L19 example: Derivative domain restrictions"
        }
      ],
      "missingIdeas": [
        "Function domain and derivative domain are distinguished; finite endpoint derivative exclusion is supplied rather than derived."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Tangent slope at a point",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            12,
            12
          ],
          "note": "L01 local teaching: Tangent slope at a point"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            109,
            120
          ],
          "note": "L19 example: Tangent slope at a point"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Horizontal tangent location",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            122,
            124
          ],
          "note": "L01 local teaching: Horizontal tangent location"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            122,
            126
          ],
          "note": "L19 example: Horizontal tangent location"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Tangent-line equation",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            132,
            132
          ],
          "note": "L01 local teaching: Tangent-line equation"
        }
      ],
      "missingIdeas": [
        "Point and slope recipe is stated; equation construction is absent locally."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Derivative from a difference-quotient limit",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            10,
            166
          ],
          "note": "L01 local teaching: Derivative from a difference-quotient limit"
        }
      ],
      "missingIdeas": [
        "No difference quotient or secant-to-tangent limit. Broad curriculum derivative label does not establish this exact exam demand."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Differentiability meaning and continuity relationship",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            12,
            40
          ],
          "note": "L01 local teaching: Differentiability meaning and continuity relationship"
        }
      ],
      "missingIdeas": [
        "Differentiability is assumed, not defined; corners/discontinuity relationship not taught."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Exponential-function derivatives",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            162,
            166
          ],
          "note": "L01 local teaching: Exponential-function derivatives"
        }
      ],
      "missingIdeas": [
        "Trap names the need for a different rule but gives no rule/procedure. Current fine exam inclusion unknown."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Logarithmic-function derivatives",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            10,
            166
          ],
          "note": "L01 local teaching: Logarithmic-function derivatives"
        }
      ],
      "missingIdeas": [
        "No local rule or procedure; conditional extension, not an established specific exam requirement."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Trigonometric-function derivatives",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            10,
            166
          ],
          "note": "L01 local teaching: Trigonometric-function derivatives"
        }
      ],
      "missingIdeas": [
        "No local rule or procedure; conditional extension, not an established specific exam requirement."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Derivative-based optimization applications",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            10,
            166
          ],
          "note": "L01 local teaching: Derivative-based optimization applications"
        }
      ],
      "missingIdeas": [
        "Horizontal tangent location is present; no optimization model, candidate comparison or extremum justification."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Derivative-based motion or other rate applications",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-derivatives"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md",
          "lines": [
            10,
            166
          ],
          "note": "L01 local teaching: Derivative-based motion or other rate applications"
        }
      ],
      "missingIdeas": [
        "Instantaneous rate is named, but no applied rate model or units reasoning."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Antiderivative reverses differentiation",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            12,
            18
          ],
          "note": "L01 local teaching: Antiderivative reverses differentiation"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            12,
            16
          ],
          "note": "L19 example: Antiderivative reverses differentiation"
        }
      ],
      "missingIdeas": [
        "A local derivative-antiderivative pair supplies the meaning; no general differentiation-rule dependency inferred for the integration procedure."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Constant of integration",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            14,
            18
          ],
          "note": "L01 local teaching: Constant of integration"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            48,
            66
          ],
          "note": "L19 example: Constant of integration"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Integral power rule for nonnegative integer powers",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            20,
            24
          ],
          "note": "L01 local teaching: Integral power rule for nonnegative integer powers"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            48,
            66
          ],
          "note": "L19 example: Integral power rule for nonnegative integer powers"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Integral power rule for fractional powers",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            20,
            24
          ],
          "note": "L01 local teaching: Integral power rule for fractional powers"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            68,
            75
          ],
          "note": "L19 example: Integral power rule for fractional powers"
        }
      ],
      "missingIdeas": [
        "Endpoint differentiability of the antiderivative is not separately developed; ordinary-domain statement is retained."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Integral power rule for negative powers other than minus one",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            20,
            24
          ],
          "note": "L01 local teaching: Integral power rule for negative powers other than minus one"
        }
      ],
      "missingIdeas": [
        "Valid-domain rule is supplied; reciprocal-power application is only advised, not worked."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Integral of reciprocal x and interval restriction",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            26,
            30
          ],
          "note": "L01 local teaching: Integral of reciprocal x and interval restriction"
        }
      ],
      "missingIdeas": [
        "Logarithm form and zero exclusion supplied; no explicit evaluated example or derivation."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Integrate sums and differences",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            32,
            32
          ],
          "note": "L01 local teaching: Integrate sums and differences"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            59,
            66
          ],
          "note": "L19 example: Integrate sums and differences"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Integrate constant multiples",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            32,
            32
          ],
          "note": "L01 local teaching: Integrate constant multiples"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            59,
            66
          ],
          "note": "L19 example: Integrate constant multiples"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Definite integral as net signed area",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            34,
            36
          ],
          "note": "L01 local teaching: Definite integral as net signed area"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            77,
            100
          ],
          "note": "L19 example: Definite integral as net signed area"
        }
      ],
      "missingIdeas": [
        "Both examples are nonnegative. No worked negative or mixed-sign region is supplied."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Ordinary area from a nonnegative integrand",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            36,
            36
          ],
          "note": "L01 local teaching: Ordinary area from a nonnegative integrand"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            77,
            100
          ],
          "note": "L19 example: Ordinary area from a nonnegative integrand"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Fundamental Theorem endpoint evaluation",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            38,
            42
          ],
          "note": "L01 local teaching: Fundamental Theorem endpoint evaluation"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            79,
            96
          ],
          "note": "L19 example: Fundamental Theorem endpoint evaluation"
        }
      ],
      "missingIdeas": [
        "Continuity is a stated condition; applicability beyond the supplied polynomial cases not checked."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Constant cancellation in definite integrals",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            42,
            42
          ],
          "note": "L01 local teaching: Constant cancellation in definite integrals"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            112,
            116
          ],
          "note": "L19 example: Constant cancellation in definite integrals"
        }
      ],
      "missingIdeas": [
        "Cancellation is explained in words, without showing two endpoint constants algebraically."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Check an antiderivative by differentiating",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            104,
            104
          ],
          "note": "L01 local teaching: Check an antiderivative by differentiating"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            55,
            57
          ],
          "note": "L19 example: Check an antiderivative by differentiating"
        }
      ],
      "missingIdeas": [
        "One derivative result is supplied; general derivative procedure is not taught here. This is an optional verification tactic rather than a necessary dependency of locally taught integration."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Geometric evaluation of a linear nonnegative integral",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            108,
            108
          ],
          "note": "L01 local teaching: Geometric evaluation of a linear nonnegative integral"
        },
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            90,
            100
          ],
          "note": "L19 example: Geometric evaluation of a linear nonnegative integral"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Total geometric area across sign changes",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            132,
            136
          ],
          "note": "L01 local teaching: Total geometric area across sign changes"
        }
      ],
      "missingIdeas": [
        "Split at zeros and absolute areas advised; finding cuts and signed interval calculations not worked."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Riemann-sum area approximation",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            10,
            142
          ],
          "note": "L01 local teaching: Riemann-sum area approximation"
        }
      ],
      "missingIdeas": [
        "Explicit curriculum preparation facet dost-sei-L135 names Riemann sums; no partition/rectangle/sample-point sum locally."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Definite integral as a limit of sums",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            10,
            142
          ],
          "note": "L01 local teaching: Definite integral as a limit of sums"
        }
      ],
      "missingIdeas": [
        "Area is stated but not built from limiting sums; exact exam depth unconfirmed."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Integration as accumulated change application",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            10,
            142
          ],
          "note": "L01 local teaching: Integration as accumulated change application"
        }
      ],
      "missingIdeas": [
        "No motion or other accumulation model; antiderivative reversal and geometric areas are present."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Substitution integration method",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            10,
            142
          ],
          "note": "L01 local teaching: Substitution integration method"
        }
      ],
      "missingIdeas": [
        "No substitution method; broader integration label alone does not establish this particular exam demand."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Exponential integrals",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            10,
            142
          ],
          "note": "L01 local teaching: Exponential integrals"
        }
      ],
      "missingIdeas": [
        "No local formula/application; fine method inclusion remains unknown."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L122",
        "dost-sei-L135"
      ],
      "facet": "Trigonometric integrals",
      "lessonIds": [
        "lesson-precalculus-basic-calculus-basic-integrals"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md",
          "lines": [
            10,
            142
          ],
          "note": "L01 local teaching: Trigonometric integrals"
        }
      ],
      "missingIdeas": [
        "No local formula/application; fine method inclusion remains unknown."
      ],
      "priorKnowledge": "Local core supplies context; no essential existing-lesson link found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply topic source/cycle/depth/language/cohort limits."
    }
  ],
  "sourceLedger": [],
  "foundationReads": [],
  "summary": "Startup checkpoint only; four lesson bodies remain unread. DOST historical2026 Calculus is distinct from unknown2027 continuity and conditional STEM-specific fine methods. SM has a conditional conic preparation lead, not a calculus trio inclusion. Other exams current calculus inclusion remains unresolved, not excluded."
}
```
