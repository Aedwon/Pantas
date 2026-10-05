# Algebra lesson structure audit

Status: DRAFT. Author findings only; independent semantic review pending.

## Identity and scope

Policy: current main `6d0bb7318ad396abe62c6c59b6d437f758ed65c4`, live/cached match October 6, 2026. Corpus `765c5dc0fa5586281047bf4f7b30d09ab3707887`, pinned clean worktree. Algebra startup audit HEAD 25ebd755560a38d4a21323424fee63ece8171930. Watcher owns Git mutations. Sole output ownership; other authors and frozen application code preserved. Completed science outputs are outside this assignment ownership.

Current main AGENTS, WORKFLOW, SUBAGENTS, startup and three content policies retrieved/read; full spec, plan, orchestrator, October 4 and latest Level 3 decisions and illustration decision read. Relevant accepted requirements, inventory, overlap and scope notes read. Policy blobs are unchanged from the earlier read revision, verified at current main. Historical pending headers do not override accepted Levels 1/2.

Evidence paths are pinned corpus-relative; lines are 1-based inclusive. Full-read hashes/ranges are in the appendix. B03/L01/L17/L19 references support structural teaching findings only. Level 4 standards, Level 5 questions/practice/blind solves and illustration assessment remain deferred. Runtime availability is unknown.

## Recommendations and limits

Teach shared algebra once, preserving separate local facets. UPCAT/USTET officially name Mathematics; their finer depth is unpublished in the accepted records. DOST names Algebra in the historical 2026 primer, with 2027 continuity unknown. Most CET/SM finer methods are curriculum or weak preparation candidates, with SHS track/cohort/completion limits. CSE 2026 PPT officially names English word problems; additional algebra is largely weak reviewer preparation. No single roster establishes equal whole-lesson scope, current item language, runtime availability or full exam coverage. Practice and later standards remain deferred.

- Split candidates: exponent manipulation versus logarithm teaching; one-variable linear solving versus coordinate line/half-plane reasoning. These separate reusable foundations from different method goals and conditional scope. Costs: approved new identities/routing, moved examples/traps, missing-method additions and later practice review. Evidence: exponents-and-logarithms lines 12-44, 60-157; linear-equations-inequalities lines 12-35, 75-118 (L01/L17/L19 structural use).
- Retain polynomial operations, quadratic solving, simultaneous-equation methods and the six-scenario modeling lesson as coherent shared goals. Thin division/root-search labels need actual teaching before a further split can improve learning. Reorder the function-family overview so necessary meanings precede applications; do not create one unit per family.
- Important local gaps: polynomial division and Rational Root Theorem; general polynomial-factor rational operations, rational equations/inequalities; quadratic/exponential/logarithmic inequalities; explicit variation models and higher-degree polynomial graph interpretation. Monomial power quotients, radical rationalization, motion/work patterns and quadratic vertices are present, so these gaps are deliberately narrower. Other-topic reconciliation remains with the lead.
- Completing the square, formula solving, range derivation, constrained composition/inverse branches and some graph methods have missing or thin worked applications. No arbitrary example minimum is used. Detailed facet evidence occurs once in the appendix.
- Two narrow prerequisite edges are proposed: function-family teaching needs the definition/inverse pairing in Functions and Relations; current line-plotting instructions need coordinate address/axis meanings. Existing repeated procedures, supplied balanced/factored expressions, converted percentages and supplied roots do not justify extra edges. Both ends are cited below.
- All owned prompts supply the deciding formulas, pairs, region facts or counts in text. No load-bearing figure dependency was found, including the shaded-region and Venn examples. Markers do not prove runtime display or illustration sufficiency.
- Encountered concerns: single-input verification is insufficient; the power-of-power rule needs precise domain restrictions; generic system graphing must allow nonlinear curves. Universal CET choice-tactic claims remain unverified. Only bounded algebraic checks were performed, with no question-bank/blind-solve or full correctness claim.

Accepted source packets: [UPCAT](../requirements/upcat.md), [DCAT](../requirements/dcat.md), [ACET](../requirements/acet.md), [USTET](../requirements/ustet.md), [PUPCET](../requirements/pupcet.md), [DOST-SEI](../requirements/dost-sei.md), [SM Foundation](../requirements/sm-foundation.md), [CSE Professional](../requirements/cse-professional.md), [CSE Subprofessional](../requirements/cse-subprofessional.md). Requirement IDs carry exact source/page/confidence. Common preparation source: [DepEd Grades 1-10 Mathematics](https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf), Grade 7-10 standards and cited competencies. Conditional SHS source: [General Mathematics listing](https://lrmds.deped.gov.ph/detail/14511), competencies, and its packet-linked PDF. Historical DOST named domain: [2026 primer](https://science-scholarships.ph/pdf/2026_DOST-SEI_UG_Primer.pdf), p. 13. These links trace accepted evidence; they are not a new external requirement pass.

## Lesson findings

### lesson-algebra-algebraic-expressions

Goal: Translate verbal relationships, distribute/combine like terms and evaluate expressions; model a simple consecutive-integer relationship.

Teaching covers Variables and translating expressions, Distribution and combining like terms, Substitution and signed exponent evaluation, Consecutive-even-integer symbolic model. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Teaching and examples support a coherent local goal. Proposal: Keep one shared core; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance. Evidence: content/lessons/mathematics/algebra/algebraic-expressions.md:10-169.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-exponents-and-logarithms

Goal: Simplify defined powers, use logarithms as inverse exponentials and combine log expressions under valid base/argument conditions.

Teaching covers Positive-integer power meaning, Same-base product quotient and power rules, Negative exponent reciprocal, Fractional exponents and roots, Log definition evaluation and domains, Log product quotient and power laws, Logarithms in terms of supplied log values, Common-base exponential equations. Detailed skill verdicts and evidence occur once in the appendix.


Structure: split-candidate. Exponent manipulation is a reusable algebra foundation; logarithm definition/laws form a distinct inverse-function objective and conditional SHS preparation extension. Proposal: Separate exponent core from logarithm teaching while retaining exponent foundations once. Keep valid-domain conditions with each rule; future splits do not create current prerequisite edges. Cost: Requires approved new identity/routing, moved log examples/traps and later practice alignment; existing source depth remains qualified. Evidence: content/lessons/mathematics/algebra/exponents-and-logarithms.md:12-157.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-functions-and-relations

Goal: Distinguish functions from relations, determine allowable inputs, evaluate/compose functions and find an affine inverse.

Teaching covers Relation versus function and input uniqueness, Domain restrictions for rational and root rules, Function evaluation, Composition order and numerical outputs, Composition domain restrictions, Inverse meaning one-to-one condition and affine inversion, Verifying an inverse by both compositions. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Teaching and examples support a coherent local goal. Proposal: Keep one shared core; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance. Evidence: content/lessons/mathematics/algebra/functions-and-relations.md:10-187.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-linear-equations-inequalities

Goal: Solve one-variable linear relations, use slope/intercept/boundary information, and interpret a two-variable linear-inequality region.

Teaching covers One-variable linear equations with fractional coefficients, One-variable inequalities and negative reversal, Slope-intercept line graphing, Perpendicular line through a point, Read a two-variable inequality from boundary and region, Vertical/horizontal and intercept edge cases, Linear-system quantity/revenue modeling and substitution. Detailed skill verdicts and evidence occur once in the appendix.


Structure: split-candidate. One-variable isolation and coordinate line/half-plane reasoning require different procedures. The graph strand introduces several formulas inside examples and contains little direct construction teaching (L01/L17/L19). Proposal: Keep shared one-variable equation/inequality core; separate line/half-plane graph reasoning into a focused unit after its coordinate foundation. Coordinate and system examples should be reconciled with their existing units, without duplicating the core. Cost: Requires approved new lesson identity/routing, moved graph examples/traps, added graph construction and later practice alignment. No graph production included. Evidence: content/lessons/mathematics/algebra/linear-equations-inequalities.md:12-140.

Prerequisites: links-found. lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas. Consumer content/lessons/mathematics/algebra/linear-equations-inequalities.md:20-28; foundation content/lessons/mathematics/geometry/coordinate-geometry.md:12-12. 

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-polynomials

Goal: Classify polynomial terms, combine/expand expressions, factor quadratic patterns and use remainder/factor constraints.

Teaching covers Polynomial definition and allowed powers, Polynomial addition subtraction and scalar multiplication, General polynomial multiplication by distribution, Quadratic monic and nonmonic factoring, Remainder theorem evaluation, Factor theorem parameter and multi-factor constraints. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Polynomial operations and factoring/theorem relationships form one coherent algebraic-object goal. Division and root-search methods are mainly labels, not a developed second unit. Proposal: Keep the shared manipulation core. Add actual division/root-search teaching before deciding whether a later methods extension needs its own lesson; a split alone would preserve the missing teaching. Cost: Targeted procedural additions require approval. A later methods unit would need new identity/routing and practice review. Evidence: content/lessons/mathematics/algebra/polynomials.md:12-142.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-quadratic-equations

Goal: Solve convenient quadratics by factoring, classify root nature with the discriminant and use relationships between roots and coefficients.

Teaching covers Quadratic form and root meaning, Monic factoring root method, Nonmonic splitting and grouping, Quadratic formula application, Discriminant and repeated-root parameter, Vieta root sum product and reciprocal combination, Square-root sign and variable-division restrictions. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Teaching and examples support a coherent local goal. Proposal: Keep one shared core; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance. Evidence: content/lessons/mathematics/algebra/quadratic-equations.md:10-162.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-radicals-and-rationalization

Goal: Simplify/combine radicals and rationalize square-root, conjugate and cube-root denominators while preserving real domains.

Teaching covers Root notation and real even/odd domains, Extract perfect-square factors with variable signs, Combine like radical terms, Simple square-root denominator rationalization, Conjugate denominator rationalization, Cube-root denominator rationalization. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Teaching and examples support a coherent local goal. Proposal: Keep one shared core; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance. Evidence: content/lessons/mathematics/algebra/radicals-and-rationalization.md:10-160.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-sets-and-set-notation

Goal: Use membership relationships and complements to solve finite-set overlap problems without double counting.

Teaching covers Set element and universal-set meaning, Subset relationship, Union intersection and complement, Two-set only/both/neither counts, Three-set disjoint-region counts. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Teaching and examples support a coherent local goal. Proposal: Keep one shared core; do not infer exam excess from unknown depth. Cost: No reorganization cost beyond later authorized maintenance. Evidence: content/lessons/mathematics/algebra/sets-and-set-notation.md:10-138.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-systems-of-equations

Goal: Solve simultaneous relationships by substitution or elimination and interpret linear/nonlinear solution sets.

Teaching covers Shared variables and simultaneous-solution meaning, Linear substitution, Elimination by addition, Elimination with scaling and subtraction, Linear one/no/infinite solution distinctions, Two-quantity count/revenue model, Line-parabola nonlinear substitution, Solve for a requested linear combination directly. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. Substitution/elimination and simultaneous truth form a coherent shared goal; the nonlinear example applies the same substitution idea. Proposal: Keep shared methods once. Coordinate graph construction remains thin and should be reconciled with focused line-graph teaching; do not split merely because one nonlinear example appears. Cost: Graph-method expansion/reconciliation requires later approval and practice review; no new unit justified from the existing example count. Evidence: content/lessons/mathematics/algebra/systems-of-equations.md:12-187.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-types-of-functions

Goal: Recognize common function families, use basic quadratic/rational graph features and evaluate absolute-value/exponential/piecewise examples.

Teaching covers Linear polynomial-power and exponential family recognition, Quadratic opening vertex and extremum, Rational function definition and original-domain exclusions, Absolute-value equation branches, Exponential growth versus decay, Elementary same-base exponent equation and log evaluation, Piecewise evaluation at included boundaries. Detailed skill verdicts and evidence occur once in the appendix.


Structure: reorder. The family overview is useful shared teaching, but rational asymptote and absolute-value procedures rely on meanings stated only loosely or after their use (L01/L19). Proposal: Keep one compact family overview. Explain function/inverse, absolute-value and asymptotic meanings before method applications; reconcile duplicated exponent/log solving with existing method teaching rather than making one lesson per family. Cost: Targeted explanatory/ordering changes and later practice alignment; no new family-by-family unit system proposed. Evidence: content/lessons/mathematics/algebra/types-of-functions.md:12-123.

Prerequisites: links-found. lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation. Consumer content/lessons/mathematics/algebra/types-of-functions.md:12-14, content/lessons/mathematics/algebra/types-of-functions.md:30-30; foundation content/lessons/mathematics/algebra/functions-and-relations.md:12-16, content/lessons/mathematics/algebra/functions-and-relations.md:41-43. 

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

### lesson-algebra-word-problems

Goal: Translate age, motion, work, mixture, coin and digit relationships into equations and answer the requested quantity.

Teaching covers General unknown/fact/equation modeling process, Age change for both people, Motion separation with constant rates, Additive constant work rates, Conserved-mixture concentration model, Coin count and value constraints, Digit place value and reversed-number equations, Requested quantity and reasonableness checks. Detailed skill verdicts and evidence occur once in the appendix.


Structure: retain. The shared modeling process ties the different scenarios together, and each example teaches its needed algebraic steps locally. Proposal: Retain one modeling lesson instead of splitting each story type. State model assumptions and qualify unverified exam-specific tactics; reconcile count/value examples with systems teaching without duplication. Cost: Targeted clarification and later practice alignment, not a new unit per scenario. Evidence: content/lessons/mathematics/algebra/word-problems.md:12-181.

Prerequisites: none-found. No necessary existing-lesson link found.

Load-bearing figure dependencies: none encountered. Markers do not establish rendered availability.

## Explicit no-existing-prerequisite list

lesson-algebra-algebraic-expressions, lesson-algebra-exponents-and-logarithms, lesson-algebra-functions-and-relations, lesson-algebra-polynomials, lesson-algebra-quadratic-equations, lesson-algebra-radicals-and-rationalization, lesson-algebra-sets-and-set-notation, lesson-algebra-systems-of-equations, lesson-algebra-word-problems. Missing-foundation statuses remain separate from verified links.

## Encountered source ledger

Access date October 6, 2026; audit branch docs/content-coverage-audit-r1; corpus base 765c5dc0fa5586281047bf4f7b30d09ab3707887. Bounded encountered claims only, not a fact sweep.

- lesson-algebra-algebraic-expressions: One test input cannot prove the translation correct. ACCURACY CONCERN. [Pinned lesson lines 153-155; independent algebraic reasoning](https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/algebraic-expressions.md#L153). Details and evidence are in the appendix.
- lesson-algebra-exponents-and-logarithms: Power-of-power domain condition needs precision. DOMAIN QUALIFICATION CONCERN. [Pinned lesson lines 20-34; independent algebraic reasoning](https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/exponents-and-logarithms.md#L20). Details and evidence are in the appendix.
- lesson-algebra-polynomials: Multiple-factor parameter example used in teaching assessment. CONFIRMED CALCULATION. [Pinned lesson lines 110-142; independent algebraic reasoning](https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/polynomials.md#L110). Details and evidence are in the appendix.
- lesson-algebra-word-problems: Universal exam-tactic claim is not sourced. UNKNOWN. [Pinned lesson lines 203-207; independent algebraic reasoning](https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/word-problems.md#L203). Details and evidence are in the appendix.
- lesson-algebra-systems-of-equations: Graphing definition scope. SCOPE CLARIFICATION. [Pinned lesson lines 16-32; independent algebraic reasoning](https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/systems-of-equations.md#L16). Details and evidence are in the appendix.

## Machine-readable appendix

```json
{
  "level": 3,
  "status": "DRAFT",
  "subject": "mathematics",
  "topic": "algebra",
  "policyCommit": "6d0bb7318ad396abe62c6c59b6d437f758ed65c4",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "id": "lesson-algebra-algebraic-expressions",
      "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
      "sha256": "f7b19fb9eb88b49fe77ab620e28994231d4a2f2890a9a245c3121c1ae03de522",
      "readLines": [
        1,
        169
      ],
      "goal": "Translate verbal relationships, distribute/combine like terms and evaluate expressions; model a simple consecutive-integer relationship.",
      "skills": [
        {
          "name": "Variables and translating expressions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                12,
                30
              ],
              "note": "L01 local teaching: Variables and translating expressions"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                38,
                48
              ],
              "note": "L19 example: Variables and translating expressions"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L085",
            "ustet-L084",
            "pupcet-L092",
            "dost-sei-L127",
            "sm-foundation-L091",
            "cse-professional-L118",
            "cse-subprofessional-L127"
          ],
          "limitations": []
        },
        {
          "name": "Distribution and combining like terms",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                18,
                18
              ],
              "note": "L01 local teaching: Distribution and combining like terms"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                50,
                77
              ],
              "note": "L19 example: Distribution and combining like terms"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L066",
            "ustet-L084",
            "pupcet-L093",
            "dost-sei-L127",
            "sm-foundation-L091"
          ],
          "limitations": [
            "Distribution/like-term procedure is taught inside the example rather than Core Concept; no external prerequisite follows from that local teaching"
          ]
        },
        {
          "name": "Substitution and signed exponent evaluation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                20,
                34
              ],
              "note": "L01 local teaching: Substitution and signed exponent evaluation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                79,
                105
              ],
              "note": "L19 example: Substitution and signed exponent evaluation"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "dost-sei-L127",
            "ustet-L084"
          ],
          "limitations": []
        },
        {
          "name": "Consecutive-even-integer symbolic model",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                16,
                20
              ],
              "note": "L01 local teaching: Consecutive-even-integer symbolic model"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                107,
                147
              ],
              "note": "L19 example: Consecutive-even-integer symbolic model"
            }
          ],
          "requirementRefs": [
            "upcat-L207",
            "acet-L067",
            "cse-professional-L110",
            "cse-subprofessional-L076"
          ],
          "limitations": [
            "Specific word-problem family is weak/unknown exam scope; equation-solving steps are supplied locally"
          ]
        },
        {
          "name": "Testing a translated form by substitution",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
              "lines": [
                153,
                155
              ],
              "note": "L01 local teaching: Testing a translated form by substitution"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L185",
            "acet-L085"
          ],
          "limitations": [
            "A single test value cannot prove a translation uniquely correct; coinciding candidate expressions give a counterexample"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L066",
            "acet-L085"
          ],
          "sharedCore": "Variables and translating expressions; Distribution and combining like terms; Substitution and signed exponent evaluation; Consecutive-even-integer symbolic model",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L036",
            "cse-professional-L118"
          ],
          "sharedCore": "Variables and translating expressions; Distribution and combining like terms; Substitution and signed exponent evaluation; Consecutive-even-integer symbolic model",
          "partialLimits": "Numerical Ability preparation only; fine algebra depth remains unconfirmed. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L047",
            "cse-subprofessional-L127"
          ],
          "sharedCore": "Variables and translating expressions; Distribution and combining like terms; Substitution and signed exponent evaluation; Consecutive-even-integer symbolic model",
          "partialLimits": "Numerical Ability preparation only; fine algebra depth remains unconfirmed. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L127"
          ],
          "sharedCore": "Variables and translating expressions; Distribution and combining like terms; Substitution and signed exponent evaluation; Consecutive-even-integer symbolic model",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L093"
          ],
          "sharedCore": "Variables and translating expressions; Distribution and combining like terms; Substitution and signed exponent evaluation; Consecutive-even-integer symbolic model",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L046",
            "sm-foundation-L091"
          ],
          "sharedCore": "Variables and translating expressions; Distribution and combining like terms; Substitution and signed exponent evaluation; Consecutive-even-integer symbolic model",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L185",
            "upcat-L187",
            "upcat-L207"
          ],
          "sharedCore": "Variables and translating expressions; Distribution and combining like terms; Substitution and signed exponent evaluation; Consecutive-even-integer symbolic model",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L084"
          ],
          "sharedCore": "Variables and translating expressions; Distribution and combining like terms; Substitution and signed exponent evaluation; Consecutive-even-integer symbolic model",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Teaching and examples support a coherent local goal.",
        "proposal": "Keep one shared core; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
            "lines": [
              10,
              169
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
      "id": "lesson-algebra-exponents-and-logarithms",
      "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
      "sha256": "1d3cbe111aa3cbf7581ee324b70c6f2771ae0e725f476b2e2f1f16295588d263",
      "readLines": [
        1,
        199
      ],
      "goal": "Simplify defined powers, use logarithms as inverse exponentials and combine log expressions under valid base/argument conditions.",
      "skills": [
        {
          "name": "Positive-integer power meaning",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                12,
                12
              ],
              "note": "L01 local teaching: Positive-integer power meaning"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                96,
                108
              ],
              "note": "L19 example: Positive-integer power meaning"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "ustet-L084",
            "dost-sei-L127",
            "cse-professional-L118",
            "cse-subprofessional-L127"
          ],
          "limitations": []
        },
        {
          "name": "Same-base product quotient and power rules",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                20,
                28
              ],
              "note": "L01 local teaching: Same-base product quotient and power rules"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                60,
                76
              ],
              "note": "L19 example: Same-base product quotient and power rules"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": [
            "Power-of-power domain qualification is incomplete for some negative bases with fractional outer exponents; encountered counterexample recorded separately"
          ]
        },
        {
          "name": "Negative exponent reciprocal",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                30,
                30
              ],
              "note": "L01 local teaching: Negative exponent reciprocal"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                78,
                94
              ],
              "note": "L19 example: Negative exponent reciprocal"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Fractional exponents and roots",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                32,
                34
              ],
              "note": "L01 local teaching: Fractional exponents and roots"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                78,
                94
              ],
              "note": "L19 example: Fractional exponents and roots"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L069",
            "ustet-L085",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Zero exponent law",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                20,
                26
              ],
              "note": "Quotient law supplies an implicit equal-exponent route, not an explicit zero-power explanation"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L185",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": [
            "The quotient law supports deriving the nonzero-base zero-exponent identity, but that identity is not explicitly explained or applied."
          ]
        },
        {
          "name": "Log definition evaluation and domains",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                14,
                18
              ],
              "note": "L01 local teaching: Log definition evaluation and domains"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                96,
                108
              ],
              "note": "L19 example: Log definition evaluation and domains"
            }
          ],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "pupcet-L098",
            "dost-sei-L131",
            "sm-foundation-L094"
          ],
          "limitations": []
        },
        {
          "name": "Log product quotient and power laws",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                36,
                44
              ],
              "note": "L01 local teaching: Log product quotient and power laws"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                110,
                122
              ],
              "note": "L19 example: Log product quotient and power laws"
            }
          ],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": []
        },
        {
          "name": "Logarithms in terms of supplied log values",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                36,
                44
              ],
              "note": "L01 local teaching: Logarithms in terms of supplied log values"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                144,
                157
              ],
              "note": "L19 example: Logarithms in terms of supplied log values"
            }
          ],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": []
        },
        {
          "name": "Common-base exponential equations",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                24,
                28
              ],
              "note": "L01 local teaching: Common-base exponential equations"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                124,
                142
              ],
              "note": "L19 example: Common-base exponential equations"
            }
          ],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": [
            "Linear equation isolation at the end is omitted; verify the existing linear-solving foundation before proposing a strict link"
          ]
        },
        {
          "name": "Logarithmic equations with an unknown argument",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
              "lines": [
                14,
                44
              ],
              "note": "L01 local teaching: Logarithmic equations with an unknown argument"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": [
            "Inverse relation/laws present, but isolating an unknown argument and checking proposed roots are not demonstrated"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L069",
            "acet-L078"
          ],
          "sharedCore": "Positive-integer power meaning; Same-base product quotient and power rules; Negative exponent reciprocal; Fractional exponents and roots; Log definition evaluation and domains; Log product quotient and power laws; Logarithms in terms of supplied log values; Common-base exponential equations",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L036",
            "cse-professional-L118"
          ],
          "sharedCore": "Elementary power manipulation at weak reviewer preparation level.",
          "partialLimits": "CSE source row names exponents, not logarithm laws or logarithmic functions. Finer inclusion/depth unknown; no exclusion claim.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain only an explicitly partial preparation candidate; the mapped weak row does not justify the whole combined body."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L047",
            "cse-subprofessional-L127"
          ],
          "sharedCore": "Elementary power manipulation at weak reviewer preparation level.",
          "partialLimits": "CSE source row names exponents, not logarithm laws or logarithmic functions. Finer inclusion/depth unknown; no exclusion claim.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain only an explicitly partial preparation candidate; the mapped weak row does not justify the whole combined body."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L035",
            "dcat-L056"
          ],
          "sharedCore": "Positive-integer power meaning; Same-base product quotient and power rules; Negative exponent reciprocal; Fractional exponents and roots; Log definition evaluation and domains; Log product quotient and power laws; Logarithms in terms of supplied log values; Common-base exponential equations",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L131"
          ],
          "sharedCore": "Positive-integer power meaning; Same-base product quotient and power rules; Negative exponent reciprocal; Fractional exponents and roots; Log definition evaluation and domains; Log product quotient and power laws; Logarithms in terms of supplied log values; Common-base exponential equations",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L098"
          ],
          "sharedCore": "Positive-integer power meaning; Same-base product quotient and power rules; Negative exponent reciprocal; Fractional exponents and roots; Log definition evaluation and domains; Log product quotient and power laws; Logarithms in terms of supplied log values; Common-base exponential equations",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L046",
            "sm-foundation-L094"
          ],
          "sharedCore": "Positive-integer power meaning; Same-base product quotient and power rules; Negative exponent reciprocal; Fractional exponents and roots; Log definition evaluation and domains; Log product quotient and power laws; Logarithms in terms of supplied log values; Common-base exponential equations",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L185",
            "upcat-L189"
          ],
          "sharedCore": "Positive-integer power meaning; Same-base product quotient and power rules; Negative exponent reciprocal; Fractional exponents and roots; Log definition evaluation and domains; Log product quotient and power laws; Logarithms in terms of supplied log values; Common-base exponential equations",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L091"
          ],
          "sharedCore": "Positive-integer power meaning; Same-base product quotient and power rules; Negative exponent reciprocal; Fractional exponents and roots; Log definition evaluation and domains; Log product quotient and power laws; Logarithms in terms of supplied log values; Common-base exponential equations",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "Exponent manipulation is a reusable algebra foundation; logarithm definition/laws form a distinct inverse-function objective and conditional SHS preparation extension.",
        "proposal": "Separate exponent core from logarithm teaching while retaining exponent foundations once. Keep valid-domain conditions with each rule; future splits do not create current prerequisite edges.",
        "cost": "Requires approved new identity/routing, moved log examples/traps and later practice alignment; existing source depth remains qualified.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
            "lines": [
              12,
              157
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
      "id": "lesson-algebra-functions-and-relations",
      "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
      "sha256": "70831709ec12b95c55ffa4dabe636c25ed12776a48df97b16735cf40d7b58a1e",
      "readLines": [
        1,
        187
      ],
      "goal": "Distinguish functions from relations, determine allowable inputs, evaluate/compose functions and find an affine inverse.",
      "skills": [
        {
          "name": "Relation versus function and input uniqueness",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                12,
                16
              ],
              "note": "L01 local teaching: Relation versus function and input uniqueness"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                49,
                61
              ],
              "note": "L19 example: Relation versus function and input uniqueness"
            }
          ],
          "requirementRefs": [
            "upcat-L188",
            "dcat-L056",
            "acet-L067",
            "acet-L078",
            "ustet-L091",
            "pupcet-L098",
            "dost-sei-L131",
            "sm-foundation-L094"
          ],
          "limitations": []
        },
        {
          "name": "Domain restrictions for rational and root rules",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                20,
                31
              ],
              "note": "L01 local teaching: Domain restrictions for rational and root rules"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                63,
                83
              ],
              "note": "L19 example: Domain restrictions for rational and root rules"
            }
          ],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "pupcet-L098",
            "dost-sei-L131"
          ],
          "limitations": []
        },
        {
          "name": "Find range from a rule and stated input domain",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                22,
                31
              ],
              "note": "L01 local teaching: Find range from a rule and stated input domain"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "pupcet-L098",
            "dost-sei-L131"
          ],
          "limitations": [
            "Range is defined, but deriving attained outputs under a rule/restricted domain is not demonstrated"
          ]
        },
        {
          "name": "Function evaluation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                33,
                35
              ],
              "note": "L01 local teaching: Function evaluation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                85,
                93
              ],
              "note": "L19 example: Function evaluation"
            }
          ],
          "requirementRefs": [
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "pupcet-L098",
            "dost-sei-L131"
          ],
          "limitations": []
        },
        {
          "name": "Composition order and numerical outputs",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                37,
                37
              ],
              "note": "L01 local teaching: Composition order and numerical outputs"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                95,
                117
              ],
              "note": "L19 example: Composition order and numerical outputs"
            }
          ],
          "requirementRefs": [
            "dcat-L056",
            "acet-L078",
            "pupcet-L098",
            "dost-sei-L131"
          ],
          "limitations": []
        },
        {
          "name": "Composition domain restrictions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                37,
                37
              ],
              "note": "L01 local teaching: Composition domain restrictions"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L056",
            "acet-L078",
            "dost-sei-L131"
          ],
          "limitations": [
            "Numerical compositions have unrestricted polynomial components; no constrained composition domain is worked"
          ]
        },
        {
          "name": "Function addition and joint domain",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                33,
                37
              ],
              "note": "L01 missing local Function addition and joint domain"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L078",
            "dost-sei-L131"
          ],
          "limitations": [
            "This operation is not taught; composition is a different operation."
          ]
        },
        {
          "name": "Function subtraction and joint domain",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                33,
                37
              ],
              "note": "L01 missing local Function subtraction and joint domain"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L078",
            "dost-sei-L131"
          ],
          "limitations": [
            "This operation is not taught; composition is a different operation."
          ]
        },
        {
          "name": "Function multiplication and joint domain",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                33,
                37
              ],
              "note": "L01 missing local Function multiplication and joint domain"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L078",
            "dost-sei-L131"
          ],
          "limitations": [
            "This operation is not taught; composition is a different operation."
          ]
        },
        {
          "name": "Function division and denominator restrictions",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                33,
                37
              ],
              "note": "L01 missing local Function division and denominator restrictions"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L078",
            "dost-sei-L131"
          ],
          "limitations": [
            "This operation is not taught; composition is a different operation."
          ]
        },
        {
          "name": "Inverse meaning one-to-one condition and affine inversion",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                39,
                45
              ],
              "note": "L01 local teaching: Inverse meaning one-to-one condition and affine inversion"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                119,
                141
              ],
              "note": "L19 example: Inverse meaning one-to-one condition and affine inversion"
            }
          ],
          "requirementRefs": [
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "pupcet-L098",
            "dost-sei-L131"
          ],
          "limitations": []
        },
        {
          "name": "Restricting a domain to produce an inverse",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                43,
                45
              ],
              "note": "L01 local teaching: Restricting a domain to produce an inverse"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": [
            "Possible restriction is stated without a branch-choice procedure or nonlinear example"
          ]
        },
        {
          "name": "Verifying an inverse by both compositions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                145,
                151
              ],
              "note": "L01 local teaching: Verifying an inverse by both compositions"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L056",
            "acet-L078",
            "dost-sei-L131"
          ],
          "limitations": [
            "One numerical check appears; neither general composition verification is worked"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L067",
            "acet-L078",
            "acet-L081"
          ],
          "sharedCore": "Relation versus function and input uniqueness; Domain restrictions for rational and root rules; Function evaluation; Composition order and numerical outputs; Composition domain restrictions; Inverse meaning one-to-one condition and affine inversion; Verifying an inverse by both compositions",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L035",
            "dcat-L051",
            "dcat-L053",
            "dcat-L056"
          ],
          "sharedCore": "Relation versus function and input uniqueness; Domain restrictions for rational and root rules; Function evaluation; Composition order and numerical outputs; Composition domain restrictions; Inverse meaning one-to-one condition and affine inversion; Verifying an inverse by both compositions",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L127",
            "dost-sei-L129",
            "dost-sei-L131",
            "dost-sei-L134"
          ],
          "sharedCore": "Relation versus function and input uniqueness; Domain restrictions for rational and root rules; Function evaluation; Composition order and numerical outputs; Composition domain restrictions; Inverse meaning one-to-one condition and affine inversion; Verifying an inverse by both compositions",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L094",
            "pupcet-L095",
            "pupcet-L098"
          ],
          "sharedCore": "Relation versus function and input uniqueness; Domain restrictions for rational and root rules; Function evaluation; Composition order and numerical outputs; Composition domain restrictions; Inverse meaning one-to-one condition and affine inversion; Verifying an inverse by both compositions",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L046",
            "sm-foundation-L094"
          ],
          "sharedCore": "Relation versus function and input uniqueness; Domain restrictions for rational and root rules; Function evaluation; Composition order and numerical outputs; Composition domain restrictions; Inverse meaning one-to-one condition and affine inversion; Verifying an inverse by both compositions",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L188",
            "upcat-L189"
          ],
          "sharedCore": "Relation versus function and input uniqueness; Domain restrictions for rational and root rules; Function evaluation; Composition order and numerical outputs; Composition domain restrictions; Inverse meaning one-to-one condition and affine inversion; Verifying an inverse by both compositions",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L085",
            "ustet-L091",
            "ustet-L095"
          ],
          "sharedCore": "Relation versus function and input uniqueness; Domain restrictions for rational and root rules; Function evaluation; Composition order and numerical outputs; Composition domain restrictions; Inverse meaning one-to-one condition and affine inversion; Verifying an inverse by both compositions",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Teaching and examples support a coherent local goal.",
        "proposal": "Keep one shared core; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
            "lines": [
              10,
              187
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
      "id": "lesson-algebra-linear-equations-inequalities",
      "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
      "sha256": "adf727715070361c4e5ba22d208edff80f9aceee28452ebe81beda47db1e774e",
      "readLines": [
        1,
        168
      ],
      "goal": "Solve one-variable linear relations, use slope/intercept/boundary information, and interpret a two-variable linear-inequality region.",
      "skills": [
        {
          "name": "One-variable linear equations with fractional coefficients",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                12,
                16
              ],
              "note": "L01 local teaching: One-variable linear equations with fractional coefficients"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                39,
                55
              ],
              "note": "L19 example: One-variable linear equations with fractional coefficients"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "dcat-L051",
            "acet-L067",
            "ustet-L084",
            "pupcet-L092",
            "dost-sei-L127",
            "sm-foundation-L091",
            "cse-professional-L118",
            "cse-subprofessional-L127"
          ],
          "limitations": [
            "The equality-preserving same-operation rule is not stated; examples show collection/division rather than explaining that invariant"
          ]
        },
        {
          "name": "One-variable inequalities and negative reversal",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                18,
                35
              ],
              "note": "L01 local teaching: One-variable inequalities and negative reversal"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                57,
                73
              ],
              "note": "L19 example: One-variable inequalities and negative reversal"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "dcat-L051",
            "acet-L067",
            "ustet-L084",
            "pupcet-L092",
            "dost-sei-L127",
            "sm-foundation-L091"
          ],
          "limitations": []
        },
        {
          "name": "Number-line graph of a one-variable inequality",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                18,
                18
              ],
              "note": "L01 local teaching: Number-line graph of a one-variable inequality"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L186",
            "dcat-L051",
            "acet-L067",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": [
            "No open/closed endpoint or direction procedure is taught"
          ]
        },
        {
          "name": "Slope-intercept line graphing",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                20,
                28
              ],
              "note": "L01 local teaching: Slope-intercept line graphing"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L067",
            "upcat-L188",
            "ustet-L091"
          ],
          "limitations": [
            "A procedure is stated, but no construction of a graph from a rule is worked"
          ]
        },
        {
          "name": "Perpendicular line through a point",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                20,
                24
              ],
              "note": "L01 local teaching: Perpendicular line through a point"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                75,
                97
              ],
              "note": "L19 example: Perpendicular line through a point"
            }
          ],
          "requirementRefs": [
            "acet-L067",
            "ustet-L086",
            "dost-sei-L128"
          ],
          "limitations": [
            "Slope from standard form, perpendicular relation and point-slope form are introduced in the example, not Core Concept (L17 structural sequencing)"
          ]
        },
        {
          "name": "Read a two-variable inequality from boundary and region",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                30,
                35
              ],
              "note": "L01 local teaching: Read a two-variable inequality from boundary and region"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                99,
                118
              ],
              "note": "L19 example: Read a two-variable inequality from boundary and region"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": [
            "All determining geometric facts are supplied in words; no load-bearing graph required for this example"
          ]
        },
        {
          "name": "Vertical/horizontal and intercept edge cases",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                144,
                164
              ],
              "note": "L01 local teaching: Vertical/horizontal and intercept edge cases"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L067",
            "upcat-L188",
            "ustet-L091"
          ],
          "limitations": []
        },
        {
          "name": "Linear-system quantity/revenue modeling and substitution",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                12,
                16
              ],
              "note": "L01 local teaching: Linear-system quantity/revenue modeling and substitution"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                120,
                140
              ],
              "note": "L19 example: Linear-system quantity/revenue modeling and substitution"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "ustet-L084",
            "pupcet-L093",
            "dost-sei-L127"
          ],
          "limitations": [
            "Worked system belongs to a method also taught elsewhere; repetition does not create a prerequisite"
          ]
        },
        {
          "name": "Two-variable systems of linear inequalities",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                18,
                35
              ],
              "note": "L01 local teaching: Two-variable systems of linear inequalities"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L186"
          ],
          "limitations": [
            "No intersection of two half-planes or feasible-region method in this lesson"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L067"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L036",
            "cse-professional-L118"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Numerical Ability preparation only; fine algebra depth remains unconfirmed. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L047",
            "cse-subprofessional-L127"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Numerical Ability preparation only; fine algebra depth remains unconfirmed. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L035",
            "dcat-L051"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L127",
            "dost-sei-L128",
            "dost-sei-L131"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L092",
            "pupcet-L093",
            "pupcet-L094",
            "pupcet-L098"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L046",
            "sm-foundation-L091"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L186",
            "upcat-L189"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L084",
            "ustet-L086"
          ],
          "sharedCore": "One-variable linear equations with fractional coefficients; One-variable inequalities and negative reversal; Slope-intercept line graphing; Perpendicular line through a point; Read a two-variable inequality from boundary and region; Vertical/horizontal and intercept edge cases; Linear-system quantity/revenue modeling and substitution",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "One-variable isolation and coordinate line/half-plane reasoning require different procedures. The graph strand introduces several formulas inside examples and contains little direct construction teaching (L01/L17/L19).",
        "proposal": "Keep shared one-variable equation/inequality core; separate line/half-plane graph reasoning into a focused unit after its coordinate foundation. Coordinate and system examples should be reconciled with their existing units, without duplicating the core.",
        "cost": "Requires approved new lesson identity/routing, moved graph examples/traps, added graph construction and later practice alignment. No graph production included.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
            "lines": [
              12,
              140
            ],
            "note": "structure basis"
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-geometry-coordinate-geometry",
          "reason": "The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
          "scope": "across-topics",
          "consumerEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
              "lines": [
                20,
                28
              ],
              "note": "Current line-plotting instruction uses unintroduced coordinate locations/axis directions"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/geometry/coordinate-geometry.md",
              "lines": [
                12,
                12
              ],
              "note": "Ordered pair is horizontal steps then vertical steps"
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
      "id": "lesson-algebra-polynomials",
      "path": "content/lessons/mathematics/algebra/polynomials.md",
      "sha256": "569fc5f0e8e9a420ef0a8e7bd71209f9b785ac12269db0232b6dfcb3aa95af9b",
      "readLines": [
        1,
        164
      ],
      "goal": "Classify polynomial terms, combine/expand expressions, factor quadratic patterns and use remainder/factor constraints.",
      "skills": [
        {
          "name": "Polynomial definition and allowed powers",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                12,
                12
              ],
              "note": "L01 local teaching: Polynomial definition and allowed powers"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L185",
            "dcat-L053",
            "acet-L066",
            "ustet-L084",
            "pupcet-L093",
            "dost-sei-L127",
            "sm-foundation-L091"
          ],
          "limitations": [
            "No applied polynomial-versus-nonpolynomial classification"
          ]
        },
        {
          "name": "Polynomial addition subtraction and scalar multiplication",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                14,
                16
              ],
              "note": "L01 local teaching: Polynomial addition subtraction and scalar multiplication"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                42,
                54
              ],
              "note": "L19 example: Polynomial addition subtraction and scalar multiplication"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L066",
            "ustet-L084",
            "pupcet-L093",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "General polynomial multiplication by distribution",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                16,
                16
              ],
              "note": "L01 local teaching: General polynomial multiplication by distribution"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                56,
                66
              ],
              "note": "L19 example: General polynomial multiplication by distribution"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L066",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": [
            "Product example bypasses term-by-term expansion through a special identity"
          ]
        },
        {
          "name": "Difference-of-squares and square identities",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                18,
                20
              ],
              "note": "L01 local teaching: Difference-of-squares and square identities"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                56,
                66
              ],
              "note": "L19 example: Difference-of-squares and square identities"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L066",
            "ustet-L084",
            "pupcet-L093",
            "dost-sei-L127"
          ],
          "limitations": [
            "Core names identities without their formulas; the difference-of-squares pattern is introduced in examples (L17 structural sequencing)"
          ]
        },
        {
          "name": "Greatest-common-factor factoring",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                20,
                20
              ],
              "note": "L01 local teaching: Greatest-common-factor factoring"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                74,
                82
              ],
              "note": "L19 example: Greatest-common-factor factoring"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L066",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": [
            "Grouped terms show common-factor extraction; no standalone first-GCF factoring procedure"
          ]
        },
        {
          "name": "Quadratic monic and nonmonic factoring",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                22,
                22
              ],
              "note": "L01 local teaching: Quadratic monic and nonmonic factoring"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                68,
                82
              ],
              "note": "L19 example: Quadratic monic and nonmonic factoring"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L066",
            "acet-L068",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Sum and difference of cubes",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                38,
                38
              ],
              "note": "L01 local teaching: Sum and difference of cubes"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L185",
            "acet-L066"
          ],
          "limitations": [
            "SOAP mnemonic appears without cube identities or worked use"
          ]
        },
        {
          "name": "Polynomial long division",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                24,
                26
              ],
              "note": "L01 local teaching: Polynomial long division"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L070",
            "dcat-L053"
          ],
          "limitations": [
            "No division algorithm or worked quotient/remainder"
          ]
        },
        {
          "name": "Synthetic division",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                26,
                26
              ],
              "note": "L01 local teaching: Synthetic division"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L070"
          ],
          "limitations": [
            "Divisor-form and sign reminders only; no synthetic computation"
          ]
        },
        {
          "name": "Remainder theorem evaluation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                28,
                30
              ],
              "note": "L01 local teaching: Remainder theorem evaluation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                84,
                94
              ],
              "note": "L19 example: Remainder theorem evaluation"
            }
          ],
          "requirementRefs": [
            "acet-L070",
            "dcat-L053",
            "pupcet-L095",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Factor theorem parameter and multi-factor constraints",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                28,
                30
              ],
              "note": "L01 local teaching: Factor theorem parameter and multi-factor constraints"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                96,
                142
              ],
              "note": "L19 example: Factor theorem parameter and multi-factor constraints"
            }
          ],
          "requirementRefs": [
            "acet-L070",
            "dcat-L053",
            "dost-sei-L127"
          ],
          "limitations": [
            "The final example locally shows adding equations; a deeper systems lesson is optional rather than a strict dependency"
          ]
        },
        {
          "name": "Rational Root Theorem candidate generation",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                24,
                30
              ],
              "note": "L01 local teaching: Rational Root Theorem candidate generation"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L070"
          ],
          "limitations": [
            "No rational-root candidate p/q rule or worked root search"
          ]
        },
        {
          "name": "Solve higher-degree polynomial equations",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/polynomials.md",
              "lines": [
                28,
                30
              ],
              "note": "L01 local teaching: Solve higher-degree polynomial equations"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "dcat-L053",
            "acet-L070"
          ],
          "limitations": [
            "Factor theorem supplied-root constraints exist, but no general polynomial-equation root-finding application"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L066",
            "acet-L068",
            "acet-L070"
          ],
          "sharedCore": "Polynomial definition and allowed powers; Polynomial addition subtraction and scalar multiplication; General polynomial multiplication by distribution; Quadratic monic and nonmonic factoring; Remainder theorem evaluation; Factor theorem parameter and multi-factor constraints",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L036",
            "cse-professional-L118"
          ],
          "sharedCore": "Basic expression manipulation and factoring at weak reviewer preparation level.",
          "partialLimits": "Division, remainder/factor-theorem and root-search depth is not established by basic reviewer factoring.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain only an explicitly partial preparation candidate; the mapped weak row does not justify the whole combined body."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L047",
            "cse-subprofessional-L127"
          ],
          "sharedCore": "Basic expression manipulation and factoring at weak reviewer preparation level.",
          "partialLimits": "Division, remainder/factor-theorem and root-search depth is not established by basic reviewer factoring.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain only an explicitly partial preparation candidate; the mapped weak row does not justify the whole combined body."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L035",
            "dcat-L053"
          ],
          "sharedCore": "Polynomial definition and allowed powers; Polynomial addition subtraction and scalar multiplication; General polynomial multiplication by distribution; Quadratic monic and nonmonic factoring; Remainder theorem evaluation; Factor theorem parameter and multi-factor constraints",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L127"
          ],
          "sharedCore": "Polynomial definition and allowed powers; Polynomial addition subtraction and scalar multiplication; General polynomial multiplication by distribution; Quadratic monic and nonmonic factoring; Remainder theorem evaluation; Factor theorem parameter and multi-factor constraints",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L093",
            "pupcet-L095"
          ],
          "sharedCore": "Polynomial definition and allowed powers; Polynomial addition subtraction and scalar multiplication; General polynomial multiplication by distribution; Quadratic monic and nonmonic factoring; Remainder theorem evaluation; Factor theorem parameter and multi-factor constraints",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L046",
            "sm-foundation-L091",
            "sm-foundation-L102"
          ],
          "sharedCore": "Polynomial definition and allowed powers; Polynomial addition subtraction and scalar multiplication; General polynomial multiplication by distribution; Quadratic monic and nonmonic factoring; Remainder theorem evaluation; Factor theorem parameter and multi-factor constraints",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L182",
            "upcat-L184",
            "upcat-L185",
            "upcat-L187"
          ],
          "sharedCore": "Polynomial definition and allowed powers; Polynomial addition subtraction and scalar multiplication; General polynomial multiplication by distribution; Quadratic monic and nonmonic factoring; Remainder theorem evaluation; Factor theorem parameter and multi-factor constraints",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L084",
            "ustet-L085"
          ],
          "sharedCore": "Polynomial definition and allowed powers; Polynomial addition subtraction and scalar multiplication; General polynomial multiplication by distribution; Quadratic monic and nonmonic factoring; Remainder theorem evaluation; Factor theorem parameter and multi-factor constraints",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Polynomial operations and factoring/theorem relationships form one coherent algebraic-object goal. Division and root-search methods are mainly labels, not a developed second unit.",
        "proposal": "Keep the shared manipulation core. Add actual division/root-search teaching before deciding whether a later methods extension needs its own lesson; a split alone would preserve the missing teaching.",
        "cost": "Targeted procedural additions require approval. A later methods unit would need new identity/routing and practice review.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/polynomials.md",
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
    },
    {
      "id": "lesson-algebra-quadratic-equations",
      "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
      "sha256": "ddba9cbe19166408b2304f980e515b3c3eb3b27f1532b77e1a6f8af981ac61da",
      "readLines": [
        1,
        162
      ],
      "goal": "Solve convenient quadratics by factoring, classify root nature with the discriminant and use relationships between roots and coefficients.",
      "skills": [
        {
          "name": "Quadratic form and root meaning",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                12,
                16
              ],
              "note": "L01 local teaching: Quadratic form and root meaning"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                60,
                73
              ],
              "note": "L19 example: Quadratic form and root meaning"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "dcat-L051",
            "acet-L068",
            "ustet-L084",
            "pupcet-L094",
            "dost-sei-L127",
            "sm-foundation-L091"
          ],
          "limitations": []
        },
        {
          "name": "Monic factoring root method",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                18,
                20
              ],
              "note": "L01 local teaching: Monic factoring root method"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                60,
                73
              ],
              "note": "L19 example: Monic factoring root method"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L068",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": [
            "Zero-product property is named and applied in the example without an explicit general statement"
          ]
        },
        {
          "name": "Nonmonic splitting and grouping",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                20,
                20
              ],
              "note": "L01 local teaching: Nonmonic splitting and grouping"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                75,
                94
              ],
              "note": "L19 example: Nonmonic splitting and grouping"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L068",
            "ustet-L084",
            "pupcet-L094",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Completing the square",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                22,
                32
              ],
              "note": "L01 local teaching: Completing the square"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L068",
            "upcat-L186",
            "ustet-L084"
          ],
          "limitations": [
            "Half-coefficient-square step explained; no completed square equation, square-root step or full solution worked"
          ]
        },
        {
          "name": "Quadratic formula application",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                34,
                38
              ],
              "note": "L01 local teaching: Quadratic formula application"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L068",
            "upcat-L186",
            "ustet-L084"
          ],
          "limitations": [
            "No worked formula substitution/root simplification despite this named solution method"
          ]
        },
        {
          "name": "Discriminant and repeated-root parameter",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                40,
                48
              ],
              "note": "L01 local teaching: Discriminant and repeated-root parameter"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                96,
                108
              ],
              "note": "L19 example: Discriminant and repeated-root parameter"
            }
          ],
          "requirementRefs": [
            "acet-L068",
            "upcat-L186",
            "ustet-L084"
          ],
          "limitations": []
        },
        {
          "name": "Vieta root sum product and reciprocal combination",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                130,
                136
              ],
              "note": "L01 local teaching: Vieta root sum product and reciprocal combination"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                110,
                126
              ],
              "note": "L19 example: Vieta root sum product and reciprocal combination"
            }
          ],
          "requirementRefs": [
            "acet-L068"
          ],
          "limitations": [
            "Vieta formulas first appear in the example and later shortcut rather than Core Concept (L17 structural sequencing)"
          ]
        },
        {
          "name": "Square-root sign and variable-division restrictions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                144,
                162
              ],
              "note": "L01 local teaching: Square-root sign and variable-division restrictions"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                152,
                162
              ],
              "note": "L19 example: Square-root sign and variable-division restrictions"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L068",
            "ustet-L084"
          ],
          "limitations": []
        },
        {
          "name": "Quadratic inequalities and sign intervals",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
              "lines": [
                12,
                48
              ],
              "note": "L01 local teaching: Quadratic inequalities and sign intervals"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L186",
            "ustet-L084",
            "pupcet-L094",
            "sm-foundation-L091"
          ],
          "limitations": [
            "No interval sign analysis or quadratic-inequality solution procedure"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L068"
          ],
          "sharedCore": "Quadratic form and root meaning; Monic factoring root method; Nonmonic splitting and grouping; Quadratic formula application; Discriminant and repeated-root parameter; Vieta root sum product and reciprocal combination; Square-root sign and variable-division restrictions",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L035",
            "dcat-L051"
          ],
          "sharedCore": "Quadratic form and root meaning; Monic factoring root method; Nonmonic splitting and grouping; Quadratic formula application; Discriminant and repeated-root parameter; Vieta root sum product and reciprocal combination; Square-root sign and variable-division restrictions",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L127"
          ],
          "sharedCore": "Quadratic form and root meaning; Monic factoring root method; Nonmonic splitting and grouping; Quadratic formula application; Discriminant and repeated-root parameter; Vieta root sum product and reciprocal combination; Square-root sign and variable-division restrictions",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L094"
          ],
          "sharedCore": "Quadratic form and root meaning; Monic factoring root method; Nonmonic splitting and grouping; Quadratic formula application; Discriminant and repeated-root parameter; Vieta root sum product and reciprocal combination; Square-root sign and variable-division restrictions",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L046",
            "sm-foundation-L091"
          ],
          "sharedCore": "Quadratic form and root meaning; Monic factoring root method; Nonmonic splitting and grouping; Quadratic formula application; Discriminant and repeated-root parameter; Vieta root sum product and reciprocal combination; Square-root sign and variable-division restrictions",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L186"
          ],
          "sharedCore": "Quadratic form and root meaning; Monic factoring root method; Nonmonic splitting and grouping; Quadratic formula application; Discriminant and repeated-root parameter; Vieta root sum product and reciprocal combination; Square-root sign and variable-division restrictions",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L084",
            "ustet-L085"
          ],
          "sharedCore": "Quadratic form and root meaning; Monic factoring root method; Nonmonic splitting and grouping; Quadratic formula application; Discriminant and repeated-root parameter; Vieta root sum product and reciprocal combination; Square-root sign and variable-division restrictions",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Teaching and examples support a coherent local goal.",
        "proposal": "Keep one shared core; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
            "lines": [
              10,
              162
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
      "id": "lesson-algebra-radicals-and-rationalization",
      "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
      "sha256": "9440f5a48bb9991d2ab973d0536efdbe0566bdea70f32dfc8d670692d0df597d",
      "readLines": [
        1,
        160
      ],
      "goal": "Simplify/combine radicals and rationalize square-root, conjugate and cube-root denominators while preserving real domains.",
      "skills": [
        {
          "name": "Root notation and real even/odd domains",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                12,
                20
              ],
              "note": "L01 local teaching: Root notation and real even/odd domains"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                34,
                52
              ],
              "note": "L19 example: Root notation and real even/odd domains"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L069",
            "ustet-L085",
            "pupcet-L094",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Extract perfect-square factors with variable signs",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                16,
                20
              ],
              "note": "L01 local teaching: Extract perfect-square factors with variable signs"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                34,
                52
              ],
              "note": "L19 example: Extract perfect-square factors with variable signs"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L069",
            "ustet-L085",
            "dost-sei-L127"
          ],
          "limitations": [
            "Examples assume nonnegative variables; absolute-value meaning is not defined locally before the unrestricted identity"
          ]
        },
        {
          "name": "Combine like radical terms",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                138,
                144
              ],
              "note": "L01 local teaching: Combine like radical terms"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                54,
                66
              ],
              "note": "L19 example: Combine like radical terms"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L069",
            "ustet-L085",
            "dost-sei-L127"
          ],
          "limitations": [
            "The example teaches the common-radicand combination; Core Concept does not state it beforehand"
          ]
        },
        {
          "name": "Simple square-root denominator rationalization",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                22,
                22
              ],
              "note": "L01 local teaching: Simple square-root denominator rationalization"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                68,
                76
              ],
              "note": "L19 example: Simple square-root denominator rationalization"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L069",
            "ustet-L085"
          ],
          "limitations": []
        },
        {
          "name": "Conjugate denominator rationalization",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                30,
                30
              ],
              "note": "L01 local teaching: Conjugate denominator rationalization"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                78,
                94
              ],
              "note": "L19 example: Conjugate denominator rationalization"
            }
          ],
          "requirementRefs": [
            "upcat-L185",
            "acet-L069",
            "ustet-L085"
          ],
          "limitations": [
            "General difference-of-squares identity appears later in traps; conjugate procedure and specific cancellation are supplied locally, so deeper factoring is optional"
          ]
        },
        {
          "name": "Cube-root denominator rationalization",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                158,
                160
              ],
              "note": "L01 local teaching: Cube-root denominator rationalization"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                96,
                112
              ],
              "note": "L19 example: Cube-root denominator rationalization"
            }
          ],
          "requirementRefs": [
            "acet-L069",
            "upcat-L185"
          ],
          "limitations": [
            "Exponent-completion method is taught in example, not Core Concept"
          ]
        },
        {
          "name": "Nested radical fixed-point equation",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                124,
                134
              ],
              "note": "L01 local teaching: Nested radical fixed-point equation"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                124,
                134
              ],
              "note": "L19 example: Nested radical fixed-point equation"
            }
          ],
          "requirementRefs": [
            "acet-L069"
          ],
          "limitations": [
            "Convergence is expressly assumed/established; quadratic candidates are supplied rather than derived, so they do not justify a current quadratic prerequisite"
          ]
        },
        {
          "name": "Finite radical equations and extraneous-root checking",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                124,
                134
              ],
              "note": "Nested-limit shortcut produces a finite fixed-point radical equation and sign filtering"
            }
          ],
          "exampleVerdict": "thin",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
              "lines": [
                124,
                134
              ],
              "note": "Squaring and rejecting a negative candidate in the conditional nested case"
            }
          ],
          "requirementRefs": [
            "acet-L069",
            "ustet-L085",
            "pupcet-L094",
            "dost-sei-L127"
          ],
          "limitations": [
            "A conditional nested-radical shortcut supplies a finite equation, squaring and nonnegative sign check. No standalone general radical-equation procedure or direct substitution check is demonstrated."
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L069"
          ],
          "sharedCore": "Root notation and real even/odd domains; Extract perfect-square factors with variable signs; Combine like radical terms; Simple square-root denominator rationalization; Conjugate denominator rationalization; Cube-root denominator rationalization",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L127"
          ],
          "sharedCore": "Root notation and real even/odd domains; Extract perfect-square factors with variable signs; Combine like radical terms; Simple square-root denominator rationalization; Conjugate denominator rationalization; Cube-root denominator rationalization",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L094"
          ],
          "sharedCore": "Root notation and real even/odd domains; Extract perfect-square factors with variable signs; Combine like radical terms; Simple square-root denominator rationalization; Conjugate denominator rationalization; Cube-root denominator rationalization",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L185"
          ],
          "sharedCore": "Root notation and real even/odd domains; Extract perfect-square factors with variable signs; Combine like radical terms; Simple square-root denominator rationalization; Conjugate denominator rationalization; Cube-root denominator rationalization",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L085"
          ],
          "sharedCore": "Root notation and real even/odd domains; Extract perfect-square factors with variable signs; Combine like radical terms; Simple square-root denominator rationalization; Conjugate denominator rationalization; Cube-root denominator rationalization",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Teaching and examples support a coherent local goal.",
        "proposal": "Keep one shared core; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
            "lines": [
              10,
              160
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
      "id": "lesson-algebra-sets-and-set-notation",
      "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
      "sha256": "1e97c34edee6bac6b3aca3d9cd7d474e8383aeae3f19349339f45651093ec710",
      "readLines": [
        1,
        138
      ],
      "goal": "Use membership relationships and complements to solve finite-set overlap problems without double counting.",
      "skills": [
        {
          "name": "Set element and universal-set meaning",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                12,
                16
              ],
              "note": "L01 local teaching: Set element and universal-set meaning"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                42,
                52
              ],
              "note": "L19 example: Set element and universal-set meaning"
            }
          ],
          "requirementRefs": [
            "upcat-L183",
            "acet-L065",
            "ustet-L083",
            "pupcet-L092",
            "dost-sei-L126"
          ],
          "limitations": []
        },
        {
          "name": "Subset relationship",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                16,
                16
              ],
              "note": "L01 local teaching: Subset relationship"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L065",
            "upcat-L183"
          ],
          "limitations": [
            "No worked subset test or subset notation used"
          ]
        },
        {
          "name": "Union intersection and complement",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                18,
                28
              ],
              "note": "L01 local teaching: Union intersection and complement"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                32,
                52
              ],
              "note": "L19 example: Union intersection and complement"
            }
          ],
          "requirementRefs": [
            "acet-L065",
            "upcat-L183",
            "ustet-L083",
            "dost-sei-L126"
          ],
          "limitations": []
        },
        {
          "name": "Cardinality notation and counting sets",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                112,
                116
              ],
              "note": "L01 local teaching: Cardinality notation and counting sets"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                54,
                76
              ],
              "note": "L19 example: Cardinality notation and counting sets"
            }
          ],
          "requirementRefs": [
            "acet-L065"
          ],
          "limitations": [
            "Counting is demonstrated; vertical-bar cardinality notation is introduced without an explicit symbol definition"
          ]
        },
        {
          "name": "Set difference",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                18,
                28
              ],
              "note": "L01 local teaching: Set difference"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L065"
          ],
          "limitations": [
            "Difference operation and notation are not explicitly taught; complement alone does not cover this separate facet"
          ]
        },
        {
          "name": "Two-set only/both/neither counts",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                112,
                122
              ],
              "note": "L01 local teaching: Two-set only/both/neither counts"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                54,
                76
              ],
              "note": "L19 example: Two-set only/both/neither counts"
            }
          ],
          "requirementRefs": [
            "acet-L065",
            "upcat-L183"
          ],
          "limitations": [
            "Inclusion-exclusion formula comes after the example; the example itself supplies disjoint-region arithmetic"
          ]
        },
        {
          "name": "Three-set disjoint-region counts",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                124,
                124
              ],
              "note": "L01 local teaching: Three-set disjoint-region counts"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                78,
                108
              ],
              "note": "L19 example: Three-set disjoint-region counts"
            }
          ],
          "requirementRefs": [
            "acet-L065",
            "upcat-L183"
          ],
          "limitations": [
            "Center-first procedure is taught in the worked example, rather than Core Concept"
          ]
        },
        {
          "name": "Membership and empty-set symbols",
          "teachingVerdict": "absent",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
              "lines": [
                12,
                28
              ],
              "note": "L01 local teaching: Membership and empty-set symbols"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L183",
            "acet-L065"
          ],
          "limitations": [
            "Element membership/nonmembership and empty-set notation are not taught; exact symbol roster expected by an exam remains unknown"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L065"
          ],
          "sharedCore": "Set element and universal-set meaning; Subset relationship; Union intersection and complement; Two-set only/both/neither counts; Three-set disjoint-region counts",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L126"
          ],
          "sharedCore": "Set element and universal-set meaning; Subset relationship; Union intersection and complement; Two-set only/both/neither counts; Three-set disjoint-region counts",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L092"
          ],
          "sharedCore": "Set element and universal-set meaning; Subset relationship; Union intersection and complement; Two-set only/both/neither counts; Three-set disjoint-region counts",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L183",
            "upcat-L184"
          ],
          "sharedCore": "Set element and universal-set meaning; Subset relationship; Union intersection and complement; Two-set only/both/neither counts; Three-set disjoint-region counts",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L083"
          ],
          "sharedCore": "Set element and universal-set meaning; Subset relationship; Union intersection and complement; Two-set only/both/neither counts; Three-set disjoint-region counts",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Teaching and examples support a coherent local goal.",
        "proposal": "Keep one shared core; do not infer exam excess from unknown depth.",
        "cost": "No reorganization cost beyond later authorized maintenance.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
            "lines": [
              10,
              138
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
      "id": "lesson-algebra-systems-of-equations",
      "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
      "sha256": "00537781800080970713da3b8a830f47975d3ce6cc823e6a6e6cc03201c54107",
      "readLines": [
        1,
        231
      ],
      "goal": "Solve simultaneous relationships by substitution or elimination and interpret linear/nonlinear solution sets.",
      "skills": [
        {
          "name": "Shared variables and simultaneous-solution meaning",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                12,
                32
              ],
              "note": "L01 local teaching: Shared variables and simultaneous-solution meaning"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                38,
                63
              ],
              "note": "L19 example: Shared variables and simultaneous-solution meaning"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "ustet-L084",
            "pupcet-L093",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Linear substitution",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                18,
                18
              ],
              "note": "L01 local teaching: Linear substitution"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                38,
                63
              ],
              "note": "L19 example: Linear substitution"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": [
            "Simple linear isolation is explicitly supplied locally; no prerequisite for repeating it elsewhere"
          ]
        },
        {
          "name": "Elimination by addition",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                20,
                20
              ],
              "note": "L01 local teaching: Elimination by addition"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                65,
                94
              ],
              "note": "L19 example: Elimination by addition"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Elimination with scaling and subtraction",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                20,
                20
              ],
              "note": "L01 local teaching: Elimination with scaling and subtraction"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                96,
                129
              ],
              "note": "L19 example: Elimination with scaling and subtraction"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "ustet-L084",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Graphing a system to locate intersection",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                22,
                30
              ],
              "note": "L01 local teaching: Graphing a system to locate intersection"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L067",
            "upcat-L188"
          ],
          "limitations": [
            "Intersection meaning explained; no procedure to construct both graphs and read a solution. Generic lines wording is too narrow for nonlinear systems"
          ]
        },
        {
          "name": "Linear one/no/infinite solution distinctions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                26,
                30
              ],
              "note": "L01 local teaching: Linear one/no/infinite solution distinctions"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                221,
                225
              ],
              "note": "L19 example: Linear one/no/infinite solution distinctions"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "ustet-L084"
          ],
          "limitations": []
        },
        {
          "name": "Two-quantity count/revenue model",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                12,
                20
              ],
              "note": "L01 local teaching: Two-quantity count/revenue model"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                131,
                160
              ],
              "note": "L19 example: Two-quantity count/revenue model"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "pupcet-L093",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Line-parabola nonlinear substitution",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                32,
                32
              ],
              "note": "L01 local teaching: Line-parabola nonlinear substitution"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                162,
                187
              ],
              "note": "L19 example: Line-parabola nonlinear substitution"
            }
          ],
          "requirementRefs": [
            "dost-sei-L134"
          ],
          "limitations": [
            "Factorization and roots are supplied; general factor-generation is not taught locally, but those provided quantities do not justify a strict quadratic prerequisite"
          ]
        },
        {
          "name": "Solve for a requested linear combination directly",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                193,
                203
              ],
              "note": "L01 local teaching: Solve for a requested linear combination directly"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
              "lines": [
                193,
                201
              ],
              "note": "L19 example: Solve for a requested linear combination directly"
            }
          ],
          "requirementRefs": [
            "upcat-L186",
            "acet-L067",
            "ustet-L084"
          ],
          "limitations": []
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L067"
          ],
          "sharedCore": "Shared variables and simultaneous-solution meaning; Linear substitution; Elimination by addition; Elimination with scaling and subtraction; Linear one/no/infinite solution distinctions; Two-quantity count/revenue model; Line-parabola nonlinear substitution; Solve for a requested linear combination directly",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L127",
            "dost-sei-L134"
          ],
          "sharedCore": "Shared variables and simultaneous-solution meaning; Linear substitution; Elimination by addition; Elimination with scaling and subtraction; Linear one/no/infinite solution distinctions; Two-quantity count/revenue model; Line-parabola nonlinear substitution; Solve for a requested linear combination directly",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L092",
            "pupcet-L093"
          ],
          "sharedCore": "Shared variables and simultaneous-solution meaning; Linear substitution; Elimination by addition; Elimination with scaling and subtraction; Linear one/no/infinite solution distinctions; Two-quantity count/revenue model; Line-parabola nonlinear substitution; Solve for a requested linear combination directly",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L186"
          ],
          "sharedCore": "Shared variables and simultaneous-solution meaning; Linear substitution; Elimination by addition; Elimination with scaling and subtraction; Linear one/no/infinite solution distinctions; Two-quantity count/revenue model; Line-parabola nonlinear substitution; Solve for a requested linear combination directly",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L084"
          ],
          "sharedCore": "Shared variables and simultaneous-solution meaning; Linear substitution; Elimination by addition; Elimination with scaling and subtraction; Linear one/no/infinite solution distinctions; Two-quantity count/revenue model; Line-parabola nonlinear substitution; Solve for a requested linear combination directly",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "Substitution/elimination and simultaneous truth form a coherent shared goal; the nonlinear example applies the same substitution idea.",
        "proposal": "Keep shared methods once. Coordinate graph construction remains thin and should be reconciled with focused line-graph teaching; do not split merely because one nonlinear example appears.",
        "cost": "Graph-method expansion/reconciliation requires later approval and practice review; no new unit justified from the existing example count.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
            "lines": [
              12,
              187
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
      "id": "lesson-algebra-types-of-functions",
      "path": "content/lessons/mathematics/algebra/types-of-functions.md",
      "sha256": "62e0e563e022868ca9a4abbfc92069250973de432ff9830bd7836cafdb98ad77",
      "readLines": [
        1,
        149
      ],
      "goal": "Recognize common function families, use basic quadratic/rational graph features and evaluate absolute-value/exponential/piecewise examples.",
      "skills": [
        {
          "name": "Linear polynomial-power and exponential family recognition",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                12,
                30
              ],
              "note": "L01 local teaching: Linear polynomial-power and exponential family recognition"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                38,
                46
              ],
              "note": "L19 example: Linear polynomial-power and exponential family recognition"
            }
          ],
          "requirementRefs": [
            "upcat-L188",
            "dcat-L053",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "pupcet-L095",
            "dost-sei-L131",
            "sm-foundation-L094"
          ],
          "limitations": []
        },
        {
          "name": "Quadratic opening vertex and extremum",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                16,
                18
              ],
              "note": "L01 local teaching: Quadratic opening vertex and extremum"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                48,
                60
              ],
              "note": "L19 example: Quadratic opening vertex and extremum"
            }
          ],
          "requirementRefs": [
            "dcat-L051",
            "acet-L078",
            "ustet-L085",
            "pupcet-L094",
            "dost-sei-L127"
          ],
          "limitations": []
        },
        {
          "name": "Rational function definition and original-domain exclusions",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                20,
                24
              ],
              "note": "L01 local teaching: Rational function definition and original-domain exclusions"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                62,
                71
              ],
              "note": "L19 example: Rational function definition and original-domain exclusions"
            }
          ],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "pupcet-L098",
            "dost-sei-L131"
          ],
          "limitations": []
        },
        {
          "name": "Rational vertical and same-degree horizontal asymptotes",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                24,
                24
              ],
              "note": "L01 local teaching: Rational vertical and same-degree horizontal asymptotes"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                62,
                75
              ],
              "note": "L19 example: Rational vertical and same-degree horizontal asymptotes"
            }
          ],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": [
            "Rules for one uncanceled pole and equal-degree ratio are taught in example; approach/limit meaning and other degree cases not explained"
          ]
        },
        {
          "name": "Slant asymptotes and removable discontinuities",
          "teachingVerdict": "named-only",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                24,
                24
              ],
              "note": "L01 local teaching: Slant asymptotes and removable discontinuities"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L078",
            "upcat-L189"
          ],
          "limitations": [
            "No division-based slant method, cancellation/hole distinction or applied graph case"
          ]
        },
        {
          "name": "Absolute-value meaning graph and transformations",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                26,
                26
              ],
              "note": "L01 local teaching: Absolute-value meaning graph and transformations"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L078",
            "ustet-L091"
          ],
          "limitations": [
            "Nonnegative outputs and V shape stated; magnitude/distance and shift/stretch/reflect rules not defined"
          ]
        },
        {
          "name": "Absolute-value equation branches",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                137,
                137
              ],
              "note": "L01 local teaching: Absolute-value equation branches"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                77,
                89
              ],
              "note": "L19 example: Absolute-value equation branches"
            }
          ],
          "requirementRefs": [
            "acet-L078"
          ],
          "limitations": [
            "Positive-output two-case method taught by example; meaning of |u| not defined locally beforehand"
          ]
        },
        {
          "name": "Exponential growth versus decay",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                28,
                28
              ],
              "note": "L01 local teaching: Exponential growth versus decay"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": [
            "No numerical growth/decay model or graph interpretation"
          ]
        },
        {
          "name": "Elementary same-base exponent equation and log evaluation",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                28,
                30
              ],
              "note": "L01 local teaching: Elementary same-base exponent equation and log evaluation"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                91,
                105
              ],
              "note": "L19 example: Elementary same-base exponent equation and log evaluation"
            }
          ],
          "requirementRefs": [
            "upcat-L189",
            "dcat-L056",
            "acet-L078",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": [
            "Log evaluation is not an unknown-argument logarithmic equation"
          ]
        },
        {
          "name": "Piecewise evaluation at included boundaries",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                32,
                32
              ],
              "note": "L01 local teaching: Piecewise evaluation at included boundaries"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                107,
                123
              ],
              "note": "L19 example: Piecewise evaluation at included boundaries"
            }
          ],
          "requirementRefs": [
            "acet-L078",
            "ustet-L091",
            "dost-sei-L131"
          ],
          "limitations": [
            "No piecewise graph construction or applied model"
          ]
        },
        {
          "name": "Function intercept and range interpretation across families",
          "teachingVerdict": "thin",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                14,
                32
              ],
              "note": "L01 local teaching: Function intercept and range interpretation across families"
            }
          ],
          "exampleVerdict": "none",
          "exampleEvidence": [],
          "requirementRefs": [
            "acet-L078",
            "upcat-L189",
            "dcat-L056",
            "ustet-L091"
          ],
          "limitations": [
            "Some output/opening/domain facts stated; no general intercept/range derivation or graph-based family comparison"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L067",
            "acet-L068",
            "acet-L069",
            "acet-L078",
            "acet-L081"
          ],
          "sharedCore": "Linear polynomial-power and exponential family recognition; Quadratic opening vertex and extremum; Rational function definition and original-domain exclusions; Absolute-value equation branches; Exponential growth versus decay; Elementary same-base exponent equation and log evaluation; Piecewise evaluation at included boundaries",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L036",
            "cse-professional-L118"
          ],
          "sharedCore": "Possible linear/elementary-power form preparation only.",
          "partialLimits": "A general function-family roster, rational asymptote analysis, piecewise/absolute-value methods and logarithms are not established by the mapped CSE row.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain only an explicitly partial preparation candidate; the mapped weak row does not justify the whole combined body."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L047",
            "cse-subprofessional-L127"
          ],
          "sharedCore": "Possible linear/elementary-power form preparation only.",
          "partialLimits": "A general function-family roster, rational asymptote analysis, piecewise/absolute-value methods and logarithms are not established by the mapped CSE row.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "revise-candidate",
          "reason": "Retain only an explicitly partial preparation candidate; the mapped weak row does not justify the whole combined body."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L035",
            "dcat-L051",
            "dcat-L053",
            "dcat-L056"
          ],
          "sharedCore": "Linear polynomial-power and exponential family recognition; Quadratic opening vertex and extremum; Rational function definition and original-domain exclusions; Absolute-value equation branches; Exponential growth versus decay; Elementary same-base exponent equation and log evaluation; Piecewise evaluation at included boundaries",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "dost-sei",
          "requirementRefs": [
            "dost-sei-L036",
            "dost-sei-L122",
            "dost-sei-L127",
            "dost-sei-L129",
            "dost-sei-L131",
            "dost-sei-L134"
          ],
          "sharedCore": "Linear polynomial-power and exponential family recognition; Quadratic opening vertex and extremum; Rational function definition and original-domain exclusions; Absolute-value equation branches; Exponential growth versus decay; Elementary same-base exponent equation and log evaluation; Piecewise evaluation at included boundaries",
          "partialLimits": "Official named Algebra is historical 2026; 2027 continuity unknown. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L094",
            "pupcet-L095",
            "pupcet-L098"
          ],
          "sharedCore": "Linear polynomial-power and exponential family recognition; Quadratic opening vertex and extremum; Rational function definition and original-domain exclusions; Absolute-value equation branches; Exponential growth versus decay; Elementary same-base exponent equation and log evaluation; Piecewise evaluation at included boundaries",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "sm-foundation",
          "requirementRefs": [
            "sm-foundation-L046",
            "sm-foundation-L091",
            "sm-foundation-L094"
          ],
          "sharedCore": "Linear polynomial-power and exponential family recognition; Quadratic opening vertex and extremum; Rational function definition and original-domain exclusions; Absolute-value equation branches; Exponential growth versus decay; Elementary same-base exponent equation and log evaluation; Piecewise evaluation at included boundaries",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L185",
            "upcat-L186",
            "upcat-L188",
            "upcat-L189"
          ],
          "sharedCore": "Linear polynomial-power and exponential family recognition; Quadratic opening vertex and extremum; Rational function definition and original-domain exclusions; Absolute-value equation branches; Exponential growth versus decay; Elementary same-base exponent equation and log evaluation; Piecewise evaluation at included boundaries",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "ustet",
          "requirementRefs": [
            "ustet-L039",
            "ustet-L079",
            "ustet-L084",
            "ustet-L085",
            "ustet-L091",
            "ustet-L095"
          ],
          "sharedCore": "Linear polynomial-power and exponential family recognition; Quadratic opening vertex and extremum; Rational function definition and original-domain exclusions; Absolute-value equation branches; Exponential growth versus decay; Elementary same-base exponent equation and log evaluation; Piecewise evaluation at included boundaries",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "reorder",
        "reason": "The family overview is useful shared teaching, but rational asymptote and absolute-value procedures rely on meanings stated only loosely or after their use (L01/L19).",
        "proposal": "Keep one compact family overview. Explain function/inverse, absolute-value and asymptotic meanings before method applications; reconcile duplicated exponent/log solving with existing method teaching rather than making one lesson per family.",
        "cost": "Targeted explanatory/ordering changes and later practice alignment; no new family-by-family unit system proposed.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/types-of-functions.md",
            "lines": [
              12,
              123
            ],
            "note": "structure basis"
          }
        ]
      },
      "prerequisites": [
        {
          "lessonId": "lesson-algebra-functions-and-relations",
          "reason": "The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
          "scope": "within-topic",
          "consumerEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                12,
                14
              ],
              "note": "Function versus vertical linear relation is invoked"
            },
            {
              "path": "content/lessons/mathematics/algebra/types-of-functions.md",
              "lines": [
                30,
                30
              ],
              "note": "Inverse function relation is invoked"
            }
          ],
          "foundationEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                12,
                16
              ],
              "note": "Input uniqueness and function relation distinction"
            },
            {
              "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
              "lines": [
                41,
                43
              ],
              "note": "Inverse input/output pairing and invertibility"
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
      "id": "lesson-algebra-word-problems",
      "path": "content/lessons/mathematics/algebra/word-problems.md",
      "sha256": "1035dfab36a970f460b8f58c208561843d2215b724facc78aa44a2870fb3440b",
      "readLines": [
        1,
        219
      ],
      "goal": "Translate age, motion, work, mixture, coin and digit relationships into equations and answer the requested quantity.",
      "skills": [
        {
          "name": "General unknown/fact/equation modeling process",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                12,
                17
              ],
              "note": "L01 local teaching: General unknown/fact/equation modeling process"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                39,
                59
              ],
              "note": "L19 example: General unknown/fact/equation modeling process"
            }
          ],
          "requirementRefs": [
            "upcat-L207",
            "dcat-L061",
            "acet-L085",
            "cse-professional-L110",
            "cse-subprofessional-L076"
          ],
          "limitations": [
            "Named word-problem scope is official for CSE; these exact families/depth remain unknown or weak elsewhere"
          ]
        },
        {
          "name": "Age change for both people",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                21,
                21
              ],
              "note": "L01 local teaching: Age change for both people"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                39,
                59
              ],
              "note": "L19 example: Age change for both people"
            }
          ],
          "requirementRefs": [
            "upcat-L207",
            "cse-professional-L110",
            "cse-subprofessional-L076"
          ],
          "limitations": []
        },
        {
          "name": "Motion separation with constant rates",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                23,
                25
              ],
              "note": "L01 local teaching: Motion separation with constant rates"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                61,
                80
              ],
              "note": "L19 example: Motion separation with constant rates"
            }
          ],
          "requirementRefs": [
            "upcat-L207",
            "acet-L064",
            "cse-professional-L115",
            "cse-subprofessional-L076"
          ],
          "limitations": [
            "Only opposite-direction separation is worked; chase/toward motion appears as an unworked shortcut, not a completeness claim"
          ]
        },
        {
          "name": "Additive constant work rates",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                27,
                27
              ],
              "note": "L01 local teaching: Additive constant work rates"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                82,
                98
              ],
              "note": "L19 example: Additive constant work rates"
            }
          ],
          "requirementRefs": [
            "upcat-L207",
            "acet-L064",
            "cse-professional-L110",
            "cse-subprofessional-L076"
          ],
          "limitations": [
            "Assumes fixed additive contributions to the same job; other work/delayed/negative-rate variants not verified as required"
          ]
        },
        {
          "name": "Conserved-mixture concentration model",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                29,
                29
              ],
              "note": "L01 local teaching: Conserved-mixture concentration model"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                100,
                124
              ],
              "note": "L19 example: Conserved-mixture concentration model"
            }
          ],
          "requirementRefs": [
            "upcat-L207",
            "cse-professional-L110",
            "cse-subprofessional-L076"
          ],
          "limitations": [
            "Percent-to-decimal conversion is used but not defined locally; ideal volume additivity is assumed in the arithmetic model"
          ]
        },
        {
          "name": "Coin count and value constraints",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                31,
                31
              ],
              "note": "L01 local teaching: Coin count and value constraints"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                126,
                149
              ],
              "note": "L19 example: Coin count and value constraints"
            }
          ],
          "requirementRefs": [
            "cse-professional-L110",
            "cse-subprofessional-L076"
          ],
          "limitations": [
            "Elimination is supplied locally, so a more detailed systems lesson is optional"
          ]
        },
        {
          "name": "Digit place value and reversed-number equations",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                33,
                33
              ],
              "note": "L01 local teaching: Digit place value and reversed-number equations"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                151,
                181
              ],
              "note": "L19 example: Digit place value and reversed-number equations"
            }
          ],
          "requirementRefs": [
            "cse-professional-L110",
            "cse-subprofessional-L076"
          ],
          "limitations": []
        },
        {
          "name": "Requested quantity and reasonableness checks",
          "teachingVerdict": "explained",
          "teachingEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                17,
                17
              ],
              "note": "L01 local teaching: Requested quantity and reasonableness checks"
            }
          ],
          "exampleVerdict": "worked",
          "exampleEvidence": [
            {
              "path": "content/lessons/mathematics/algebra/word-problems.md",
              "lines": [
                39,
                59
              ],
              "note": "L19 example: Requested quantity and reasonableness checks"
            }
          ],
          "requirementRefs": [
            "cse-professional-L110",
            "cse-subprofessional-L076"
          ],
          "limitations": [
            "Universal claims that the unasked answer always appears in choices are not verified exam facts"
          ]
        }
      ],
      "examApplicability": [
        {
          "exam": "acet",
          "requirementRefs": [
            "acet-L038",
            "acet-L064"
          ],
          "sharedCore": "General unknown/fact/equation modeling process; Age change for both people; Motion separation with constant rates; Additive constant work rates; Conserved-mixture concentration model; Coin count and value constraints; Digit place value and reversed-number equations; Requested quantity and reasonableness checks",
          "partialLimits": "Current official academic scope unconfirmed; preparation candidate only. Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "uncertain",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "cse-professional",
          "requirementRefs": [
            "cse-professional-L036",
            "cse-professional-L110",
            "cse-professional-L115"
          ],
          "sharedCore": "Modeling and solving verbal numerical relationships.",
          "partialLimits": "Organizer names word problems for 2026 PPT in English; exact families and difficulty remain unknown. Do not infer that every six-family variant is required.",
          "depth": "known: word-problem domain for 2026 PPT; finer family/depth and computer variants unknown",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual worked modeling serves the named task domain, with finer limits retained."
        },
        {
          "exam": "cse-subprofessional",
          "requirementRefs": [
            "cse-subprofessional-L047",
            "cse-subprofessional-L076"
          ],
          "sharedCore": "Modeling and solving verbal numerical relationships.",
          "partialLimits": "Organizer names word problems for 2026 PPT in English; exact families and difficulty remain unknown. Do not infer that every six-family variant is required.",
          "depth": "known: word-problem domain for 2026 PPT; finer family/depth and computer variants unknown",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual worked modeling serves the named task domain, with finer limits retained."
        },
        {
          "exam": "dcat",
          "requirementRefs": [
            "dcat-L035",
            "dcat-L061",
            "dcat-L102"
          ],
          "sharedCore": "General unknown/fact/equation modeling process; Age change for both people; Motion separation with constant rates; Additive constant work rates; Conserved-mixture concentration model; Coin count and value constraints; Digit place value and reversed-number equations; Requested quantity and reasonableness checks",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "pupcet",
          "requirementRefs": [
            "pupcet-L104"
          ],
          "sharedCore": "General unknown/fact/equation modeling process; Age change for both people; Motion separation with constant rates; Additive constant work rates; Conserved-mixture concentration model; Coin count and value constraints; Digit place value and reversed-number equations; Requested quantity and reasonableness checks",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        },
        {
          "exam": "upcat",
          "requirementRefs": [
            "upcat-L036",
            "upcat-L171",
            "upcat-L184",
            "upcat-L207"
          ],
          "sharedCore": "General unknown/fact/equation modeling process; Age change for both people; Motion separation with constant rates; Additive constant work rates; Conserved-mixture concentration model; Coin count and value constraints; Digit place value and reversed-number equations; Requested quantity and reasonableness checks",
          "partialLimits": "Only cited local facets; apply topic scope and cohort limits.",
          "depth": "unknown: detailed current organizer depth not established",
          "tagRecommendation": "retain-candidate",
          "reason": "Actual teaching supports preparation; no broad-row or complete-lesson coverage inference."
        }
      ],
      "structure": {
        "verdict": "retain",
        "reason": "The shared modeling process ties the different scenarios together, and each example teaches its needed algebraic steps locally.",
        "proposal": "Retain one modeling lesson instead of splitting each story type. State model assumptions and qualify unverified exam-specific tactics; reconcile count/value examples with systems teaching without duplication.",
        "cost": "Targeted clarification and later practice alignment, not a new unit per scenario.",
        "evidence": [
          {
            "path": "content/lessons/mathematics/algebra/word-problems.md",
            "lines": [
              12,
              181
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
        "upcat-L185",
        "acet-L085",
        "ustet-L084",
        "pupcet-L092",
        "dost-sei-L127",
        "sm-foundation-L091",
        "cse-professional-L118",
        "cse-subprofessional-L127"
      ],
      "facet": "Variables and translating expressions",
      "lessonIds": [
        "lesson-algebra-algebraic-expressions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            12,
            30
          ],
          "note": "L01 local teaching: Variables and translating expressions"
        },
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            38,
            48
          ],
          "note": "L19 example: Variables and translating expressions"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L066",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127",
        "sm-foundation-L091"
      ],
      "facet": "Distribution and combining like terms",
      "lessonIds": [
        "lesson-algebra-algebraic-expressions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            18,
            18
          ],
          "note": "L01 local teaching: Distribution and combining like terms"
        },
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            50,
            77
          ],
          "note": "L19 example: Distribution and combining like terms"
        }
      ],
      "missingIdeas": [
        "Distribution/like-term procedure is taught inside the example rather than Core Concept; no external prerequisite follows from that local teaching"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "dost-sei-L127",
        "ustet-L084"
      ],
      "facet": "Substitution and signed exponent evaluation",
      "lessonIds": [
        "lesson-algebra-algebraic-expressions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            20,
            34
          ],
          "note": "L01 local teaching: Substitution and signed exponent evaluation"
        },
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            79,
            105
          ],
          "note": "L19 example: Substitution and signed exponent evaluation"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L207",
        "acet-L067",
        "cse-professional-L110",
        "cse-subprofessional-L076"
      ],
      "facet": "Consecutive-even-integer symbolic model",
      "lessonIds": [
        "lesson-algebra-algebraic-expressions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            16,
            20
          ],
          "note": "L01 local teaching: Consecutive-even-integer symbolic model"
        },
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            107,
            147
          ],
          "note": "L19 example: Consecutive-even-integer symbolic model"
        }
      ],
      "missingIdeas": [
        "Specific word-problem family is weak/unknown exam scope; equation-solving steps are supplied locally"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L085"
      ],
      "facet": "Testing a translated form by substitution",
      "lessonIds": [
        "lesson-algebra-algebraic-expressions"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            153,
            155
          ],
          "note": "L01 local teaching: Testing a translated form by substitution"
        }
      ],
      "missingIdeas": [
        "A single test value cannot prove a translation uniquely correct; coinciding candidate expressions give a counterexample"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "ustet-L084",
        "dost-sei-L127",
        "cse-professional-L118",
        "cse-subprofessional-L127"
      ],
      "facet": "Positive-integer power meaning",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            12,
            12
          ],
          "note": "L01 local teaching: Positive-integer power meaning"
        },
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            96,
            108
          ],
          "note": "L19 example: Positive-integer power meaning"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Same-base product quotient and power rules",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            20,
            28
          ],
          "note": "L01 local teaching: Same-base product quotient and power rules"
        },
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            60,
            76
          ],
          "note": "L19 example: Same-base product quotient and power rules"
        }
      ],
      "missingIdeas": [
        "Power-of-power domain qualification is incomplete for some negative bases with fractional outer exponents; encountered counterexample recorded separately"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Negative exponent reciprocal",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            30,
            30
          ],
          "note": "L01 local teaching: Negative exponent reciprocal"
        },
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            78,
            94
          ],
          "note": "L19 example: Negative exponent reciprocal"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L069",
        "ustet-L085",
        "dost-sei-L127"
      ],
      "facet": "Fractional exponents and roots",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            32,
            34
          ],
          "note": "L01 local teaching: Fractional exponents and roots"
        },
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            78,
            94
          ],
          "note": "L19 example: Fractional exponents and roots"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Zero exponent law",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            20,
            26
          ],
          "note": "Quotient law supplies an implicit equal-exponent route, not an explicit zero-power explanation"
        }
      ],
      "missingIdeas": [
        "The quotient law supports deriving the nonzero-base zero-exponent identity, but that identity is not explicitly explained or applied."
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131",
        "sm-foundation-L094"
      ],
      "facet": "Log definition evaluation and domains",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            14,
            18
          ],
          "note": "L01 local teaching: Log definition evaluation and domains"
        },
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            96,
            108
          ],
          "note": "L19 example: Log definition evaluation and domains"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Log product quotient and power laws",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            36,
            44
          ],
          "note": "L01 local teaching: Log product quotient and power laws"
        },
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            110,
            122
          ],
          "note": "L19 example: Log product quotient and power laws"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Logarithms in terms of supplied log values",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            36,
            44
          ],
          "note": "L01 local teaching: Logarithms in terms of supplied log values"
        },
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            144,
            157
          ],
          "note": "L19 example: Logarithms in terms of supplied log values"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Common-base exponential equations",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            24,
            28
          ],
          "note": "L01 local teaching: Common-base exponential equations"
        },
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            124,
            142
          ],
          "note": "L19 example: Common-base exponential equations"
        }
      ],
      "missingIdeas": [
        "Linear equation isolation at the end is omitted; verify the existing linear-solving foundation before proposing a strict link"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Logarithmic equations with an unknown argument",
      "lessonIds": [
        "lesson-algebra-exponents-and-logarithms"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            14,
            44
          ],
          "note": "L01 local teaching: Logarithmic equations with an unknown argument"
        }
      ],
      "missingIdeas": [
        "Inverse relation/laws present, but isolating an unknown argument and checking proposed roots are not demonstrated"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L188",
        "dcat-L056",
        "acet-L067",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131",
        "sm-foundation-L094"
      ],
      "facet": "Relation versus function and input uniqueness",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            12,
            16
          ],
          "note": "L01 local teaching: Relation versus function and input uniqueness"
        },
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            49,
            61
          ],
          "note": "L19 example: Relation versus function and input uniqueness"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Domain restrictions for rational and root rules",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            20,
            31
          ],
          "note": "L01 local teaching: Domain restrictions for rational and root rules"
        },
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            63,
            83
          ],
          "note": "L19 example: Domain restrictions for rational and root rules"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Find range from a rule and stated input domain",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            22,
            31
          ],
          "note": "L01 local teaching: Find range from a rule and stated input domain"
        }
      ],
      "missingIdeas": [
        "Range is defined, but deriving attained outputs under a rule/restricted domain is not demonstrated"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Function evaluation",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            33,
            35
          ],
          "note": "L01 local teaching: Function evaluation"
        },
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            85,
            93
          ],
          "note": "L19 example: Function evaluation"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L056",
        "acet-L078",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Composition order and numerical outputs",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            37,
            37
          ],
          "note": "L01 local teaching: Composition order and numerical outputs"
        },
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            95,
            117
          ],
          "note": "L19 example: Composition order and numerical outputs"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L056",
        "acet-L078",
        "dost-sei-L131"
      ],
      "facet": "Composition domain restrictions",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            37,
            37
          ],
          "note": "L01 local teaching: Composition domain restrictions"
        }
      ],
      "missingIdeas": [
        "Numerical compositions have unrestricted polynomial components; no constrained composition domain is worked"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078",
        "dost-sei-L131"
      ],
      "facet": "Function addition and joint domain",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            33,
            37
          ],
          "note": "L01 missing local Function addition and joint domain"
        }
      ],
      "missingIdeas": [
        "This operation is not taught; composition is a different operation."
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078",
        "dost-sei-L131"
      ],
      "facet": "Function subtraction and joint domain",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            33,
            37
          ],
          "note": "L01 missing local Function subtraction and joint domain"
        }
      ],
      "missingIdeas": [
        "This operation is not taught; composition is a different operation."
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078",
        "dost-sei-L131"
      ],
      "facet": "Function multiplication and joint domain",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            33,
            37
          ],
          "note": "L01 missing local Function multiplication and joint domain"
        }
      ],
      "missingIdeas": [
        "This operation is not taught; composition is a different operation."
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078",
        "dost-sei-L131"
      ],
      "facet": "Function division and denominator restrictions",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            33,
            37
          ],
          "note": "L01 missing local Function division and denominator restrictions"
        }
      ],
      "missingIdeas": [
        "This operation is not taught; composition is a different operation."
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Inverse meaning one-to-one condition and affine inversion",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            39,
            45
          ],
          "note": "L01 local teaching: Inverse meaning one-to-one condition and affine inversion"
        },
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            119,
            141
          ],
          "note": "L19 example: Inverse meaning one-to-one condition and affine inversion"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Restricting a domain to produce an inverse",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            43,
            45
          ],
          "note": "L01 local teaching: Restricting a domain to produce an inverse"
        }
      ],
      "missingIdeas": [
        "Possible restriction is stated without a branch-choice procedure or nonlinear example"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L056",
        "acet-L078",
        "dost-sei-L131"
      ],
      "facet": "Verifying an inverse by both compositions",
      "lessonIds": [
        "lesson-algebra-functions-and-relations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/functions-and-relations.md",
          "lines": [
            145,
            151
          ],
          "note": "L01 local teaching: Verifying an inverse by both compositions"
        }
      ],
      "missingIdeas": [
        "One numerical check appears; neither general composition verification is worked"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "dcat-L051",
        "acet-L067",
        "ustet-L084",
        "pupcet-L092",
        "dost-sei-L127",
        "sm-foundation-L091",
        "cse-professional-L118",
        "cse-subprofessional-L127"
      ],
      "facet": "One-variable linear equations with fractional coefficients",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            12,
            16
          ],
          "note": "L01 local teaching: One-variable linear equations with fractional coefficients"
        },
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            39,
            55
          ],
          "note": "L19 example: One-variable linear equations with fractional coefficients"
        }
      ],
      "missingIdeas": [
        "The equality-preserving same-operation rule is not stated; examples show collection/division rather than explaining that invariant"
      ],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "dcat-L051",
        "acet-L067",
        "ustet-L084",
        "pupcet-L092",
        "dost-sei-L127",
        "sm-foundation-L091"
      ],
      "facet": "One-variable inequalities and negative reversal",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            18,
            35
          ],
          "note": "L01 local teaching: One-variable inequalities and negative reversal"
        },
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            57,
            73
          ],
          "note": "L19 example: One-variable inequalities and negative reversal"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "dcat-L051",
        "acet-L067",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Number-line graph of a one-variable inequality",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            18,
            18
          ],
          "note": "L01 local teaching: Number-line graph of a one-variable inequality"
        }
      ],
      "missingIdeas": [
        "No open/closed endpoint or direction procedure is taught"
      ],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L067",
        "upcat-L188",
        "ustet-L091"
      ],
      "facet": "Slope-intercept line graphing",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            20,
            28
          ],
          "note": "L01 local teaching: Slope-intercept line graphing"
        }
      ],
      "missingIdeas": [
        "A procedure is stated, but no construction of a graph from a rule is worked"
      ],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L067",
        "ustet-L086",
        "dost-sei-L128"
      ],
      "facet": "Perpendicular line through a point",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            20,
            24
          ],
          "note": "L01 local teaching: Perpendicular line through a point"
        },
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            75,
            97
          ],
          "note": "L19 example: Perpendicular line through a point"
        }
      ],
      "missingIdeas": [
        "Slope from standard form, perpendicular relation and point-slope form are introduced in the example, not Core Concept (L17 structural sequencing)"
      ],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Read a two-variable inequality from boundary and region",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            30,
            35
          ],
          "note": "L01 local teaching: Read a two-variable inequality from boundary and region"
        },
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            99,
            118
          ],
          "note": "L19 example: Read a two-variable inequality from boundary and region"
        }
      ],
      "missingIdeas": [
        "All determining geometric facts are supplied in words; no load-bearing graph required for this example"
      ],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L067",
        "upcat-L188",
        "ustet-L091"
      ],
      "facet": "Vertical/horizontal and intercept edge cases",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            144,
            164
          ],
          "note": "L01 local teaching: Vertical/horizontal and intercept edge cases"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127"
      ],
      "facet": "Linear-system quantity/revenue modeling and substitution",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            12,
            16
          ],
          "note": "L01 local teaching: Linear-system quantity/revenue modeling and substitution"
        },
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            120,
            140
          ],
          "note": "L19 example: Linear-system quantity/revenue modeling and substitution"
        }
      ],
      "missingIdeas": [
        "Worked system belongs to a method also taught elsewhere; repetition does not create a prerequisite"
      ],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186"
      ],
      "facet": "Two-variable systems of linear inequalities",
      "lessonIds": [
        "lesson-algebra-linear-equations-inequalities"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            18,
            35
          ],
          "note": "L01 local teaching: Two-variable systems of linear inequalities"
        }
      ],
      "missingIdeas": [
        "No intersection of two half-planes or feasible-region method in this lesson"
      ],
      "priorKnowledge": "lesson-geometry-coordinate-geometry: The current Core instructs plotting a y-intercept and rise/run, but does not define ordered-pair coordinates or axis directions. The foundation supplies that address/axis meaning, not merely a deeper repetition of line formulas.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "dcat-L053",
        "acet-L066",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127",
        "sm-foundation-L091"
      ],
      "facet": "Polynomial definition and allowed powers",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            12,
            12
          ],
          "note": "L01 local teaching: Polynomial definition and allowed powers"
        }
      ],
      "missingIdeas": [
        "No applied polynomial-versus-nonpolynomial classification"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L066",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127"
      ],
      "facet": "Polynomial addition subtraction and scalar multiplication",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            14,
            16
          ],
          "note": "L01 local teaching: Polynomial addition subtraction and scalar multiplication"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            42,
            54
          ],
          "note": "L19 example: Polynomial addition subtraction and scalar multiplication"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L066",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "General polynomial multiplication by distribution",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            16,
            16
          ],
          "note": "L01 local teaching: General polynomial multiplication by distribution"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            56,
            66
          ],
          "note": "L19 example: General polynomial multiplication by distribution"
        }
      ],
      "missingIdeas": [
        "Product example bypasses term-by-term expansion through a special identity"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L066",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127"
      ],
      "facet": "Difference-of-squares and square identities",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            18,
            20
          ],
          "note": "L01 local teaching: Difference-of-squares and square identities"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            56,
            66
          ],
          "note": "L19 example: Difference-of-squares and square identities"
        }
      ],
      "missingIdeas": [
        "Core names identities without their formulas; the difference-of-squares pattern is introduced in examples (L17 structural sequencing)"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L066",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Greatest-common-factor factoring",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            20,
            20
          ],
          "note": "L01 local teaching: Greatest-common-factor factoring"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            74,
            82
          ],
          "note": "L19 example: Greatest-common-factor factoring"
        }
      ],
      "missingIdeas": [
        "Grouped terms show common-factor extraction; no standalone first-GCF factoring procedure"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L066",
        "acet-L068",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Quadratic monic and nonmonic factoring",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            22,
            22
          ],
          "note": "L01 local teaching: Quadratic monic and nonmonic factoring"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            68,
            82
          ],
          "note": "L19 example: Quadratic monic and nonmonic factoring"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L066"
      ],
      "facet": "Sum and difference of cubes",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            38,
            38
          ],
          "note": "L01 local teaching: Sum and difference of cubes"
        }
      ],
      "missingIdeas": [
        "SOAP mnemonic appears without cube identities or worked use"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L070",
        "dcat-L053"
      ],
      "facet": "Polynomial long division",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            24,
            26
          ],
          "note": "L01 local teaching: Polynomial long division"
        }
      ],
      "missingIdeas": [
        "No division algorithm or worked quotient/remainder"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L070"
      ],
      "facet": "Synthetic division",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            26,
            26
          ],
          "note": "L01 local teaching: Synthetic division"
        }
      ],
      "missingIdeas": [
        "Divisor-form and sign reminders only; no synthetic computation"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L070",
        "dcat-L053",
        "pupcet-L095",
        "dost-sei-L127"
      ],
      "facet": "Remainder theorem evaluation",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            28,
            30
          ],
          "note": "L01 local teaching: Remainder theorem evaluation"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            84,
            94
          ],
          "note": "L19 example: Remainder theorem evaluation"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L070",
        "dcat-L053",
        "dost-sei-L127"
      ],
      "facet": "Factor theorem parameter and multi-factor constraints",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            28,
            30
          ],
          "note": "L01 local teaching: Factor theorem parameter and multi-factor constraints"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            96,
            142
          ],
          "note": "L19 example: Factor theorem parameter and multi-factor constraints"
        }
      ],
      "missingIdeas": [
        "The final example locally shows adding equations; a deeper systems lesson is optional rather than a strict dependency"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L070"
      ],
      "facet": "Rational Root Theorem candidate generation",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            24,
            30
          ],
          "note": "L01 local teaching: Rational Root Theorem candidate generation"
        }
      ],
      "missingIdeas": [
        "No rational-root candidate p/q rule or worked root search"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L053",
        "acet-L070"
      ],
      "facet": "Solve higher-degree polynomial equations",
      "lessonIds": [
        "lesson-algebra-polynomials"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            28,
            30
          ],
          "note": "L01 local teaching: Solve higher-degree polynomial equations"
        }
      ],
      "missingIdeas": [
        "Factor theorem supplied-root constraints exist, but no general polynomial-equation root-finding application"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "dcat-L051",
        "acet-L068",
        "ustet-L084",
        "pupcet-L094",
        "dost-sei-L127",
        "sm-foundation-L091"
      ],
      "facet": "Quadratic form and root meaning",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            12,
            16
          ],
          "note": "L01 local teaching: Quadratic form and root meaning"
        },
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            60,
            73
          ],
          "note": "L19 example: Quadratic form and root meaning"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L068",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Monic factoring root method",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            18,
            20
          ],
          "note": "L01 local teaching: Monic factoring root method"
        },
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            60,
            73
          ],
          "note": "L19 example: Monic factoring root method"
        }
      ],
      "missingIdeas": [
        "Zero-product property is named and applied in the example without an explicit general statement"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L068",
        "ustet-L084",
        "pupcet-L094",
        "dost-sei-L127"
      ],
      "facet": "Nonmonic splitting and grouping",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            20,
            20
          ],
          "note": "L01 local teaching: Nonmonic splitting and grouping"
        },
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            75,
            94
          ],
          "note": "L19 example: Nonmonic splitting and grouping"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L068",
        "upcat-L186",
        "ustet-L084"
      ],
      "facet": "Completing the square",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            22,
            32
          ],
          "note": "L01 local teaching: Completing the square"
        }
      ],
      "missingIdeas": [
        "Half-coefficient-square step explained; no completed square equation, square-root step or full solution worked"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L068",
        "upcat-L186",
        "ustet-L084"
      ],
      "facet": "Quadratic formula application",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            34,
            38
          ],
          "note": "L01 local teaching: Quadratic formula application"
        }
      ],
      "missingIdeas": [
        "No worked formula substitution/root simplification despite this named solution method"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L068",
        "upcat-L186",
        "ustet-L084"
      ],
      "facet": "Discriminant and repeated-root parameter",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            40,
            48
          ],
          "note": "L01 local teaching: Discriminant and repeated-root parameter"
        },
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            96,
            108
          ],
          "note": "L19 example: Discriminant and repeated-root parameter"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L068"
      ],
      "facet": "Vieta root sum product and reciprocal combination",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            130,
            136
          ],
          "note": "L01 local teaching: Vieta root sum product and reciprocal combination"
        },
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            110,
            126
          ],
          "note": "L19 example: Vieta root sum product and reciprocal combination"
        }
      ],
      "missingIdeas": [
        "Vieta formulas first appear in the example and later shortcut rather than Core Concept (L17 structural sequencing)"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L068",
        "ustet-L084"
      ],
      "facet": "Square-root sign and variable-division restrictions",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            144,
            162
          ],
          "note": "L01 local teaching: Square-root sign and variable-division restrictions"
        },
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            152,
            162
          ],
          "note": "L19 example: Square-root sign and variable-division restrictions"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "ustet-L084",
        "pupcet-L094",
        "sm-foundation-L091"
      ],
      "facet": "Quadratic inequalities and sign intervals",
      "lessonIds": [
        "lesson-algebra-quadratic-equations"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/quadratic-equations.md",
          "lines": [
            12,
            48
          ],
          "note": "L01 local teaching: Quadratic inequalities and sign intervals"
        }
      ],
      "missingIdeas": [
        "No interval sign analysis or quadratic-inequality solution procedure"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L069",
        "ustet-L085",
        "pupcet-L094",
        "dost-sei-L127"
      ],
      "facet": "Root notation and real even/odd domains",
      "lessonIds": [
        "lesson-algebra-radicals-and-rationalization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            12,
            20
          ],
          "note": "L01 local teaching: Root notation and real even/odd domains"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            34,
            52
          ],
          "note": "L19 example: Root notation and real even/odd domains"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L069",
        "ustet-L085",
        "dost-sei-L127"
      ],
      "facet": "Extract perfect-square factors with variable signs",
      "lessonIds": [
        "lesson-algebra-radicals-and-rationalization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            16,
            20
          ],
          "note": "L01 local teaching: Extract perfect-square factors with variable signs"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            34,
            52
          ],
          "note": "L19 example: Extract perfect-square factors with variable signs"
        }
      ],
      "missingIdeas": [
        "Examples assume nonnegative variables; absolute-value meaning is not defined locally before the unrestricted identity"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L069",
        "ustet-L085",
        "dost-sei-L127"
      ],
      "facet": "Combine like radical terms",
      "lessonIds": [
        "lesson-algebra-radicals-and-rationalization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            138,
            144
          ],
          "note": "L01 local teaching: Combine like radical terms"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            54,
            66
          ],
          "note": "L19 example: Combine like radical terms"
        }
      ],
      "missingIdeas": [
        "The example teaches the common-radicand combination; Core Concept does not state it beforehand"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L069",
        "ustet-L085"
      ],
      "facet": "Simple square-root denominator rationalization",
      "lessonIds": [
        "lesson-algebra-radicals-and-rationalization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            22,
            22
          ],
          "note": "L01 local teaching: Simple square-root denominator rationalization"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            68,
            76
          ],
          "note": "L19 example: Simple square-root denominator rationalization"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L185",
        "acet-L069",
        "ustet-L085"
      ],
      "facet": "Conjugate denominator rationalization",
      "lessonIds": [
        "lesson-algebra-radicals-and-rationalization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            30,
            30
          ],
          "note": "L01 local teaching: Conjugate denominator rationalization"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            78,
            94
          ],
          "note": "L19 example: Conjugate denominator rationalization"
        }
      ],
      "missingIdeas": [
        "General difference-of-squares identity appears later in traps; conjugate procedure and specific cancellation are supplied locally, so deeper factoring is optional"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L069",
        "upcat-L185"
      ],
      "facet": "Cube-root denominator rationalization",
      "lessonIds": [
        "lesson-algebra-radicals-and-rationalization"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            158,
            160
          ],
          "note": "L01 local teaching: Cube-root denominator rationalization"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            96,
            112
          ],
          "note": "L19 example: Cube-root denominator rationalization"
        }
      ],
      "missingIdeas": [
        "Exponent-completion method is taught in example, not Core Concept"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L069"
      ],
      "facet": "Nested radical fixed-point equation",
      "lessonIds": [
        "lesson-algebra-radicals-and-rationalization"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            124,
            134
          ],
          "note": "L01 local teaching: Nested radical fixed-point equation"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            124,
            134
          ],
          "note": "L19 example: Nested radical fixed-point equation"
        }
      ],
      "missingIdeas": [
        "Convergence is expressly assumed/established; quadratic candidates are supplied rather than derived, so they do not justify a current quadratic prerequisite"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L069",
        "ustet-L085",
        "pupcet-L094",
        "dost-sei-L127"
      ],
      "facet": "Finite radical equations and extraneous-root checking",
      "lessonIds": [
        "lesson-algebra-radicals-and-rationalization"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            124,
            134
          ],
          "note": "Nested-limit shortcut produces a finite fixed-point radical equation and sign filtering"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            124,
            134
          ],
          "note": "Squaring and rejecting a negative candidate in the conditional nested case"
        }
      ],
      "missingIdeas": [
        "A conditional nested-radical shortcut supplies a finite equation, squaring and nonnegative sign check. No standalone general radical-equation procedure or direct substitution check is demonstrated."
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "thin",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L183",
        "acet-L065",
        "ustet-L083",
        "pupcet-L092",
        "dost-sei-L126"
      ],
      "facet": "Set element and universal-set meaning",
      "lessonIds": [
        "lesson-algebra-sets-and-set-notation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            12,
            16
          ],
          "note": "L01 local teaching: Set element and universal-set meaning"
        },
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            42,
            52
          ],
          "note": "L19 example: Set element and universal-set meaning"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L065",
        "upcat-L183"
      ],
      "facet": "Subset relationship",
      "lessonIds": [
        "lesson-algebra-sets-and-set-notation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            16,
            16
          ],
          "note": "L01 local teaching: Subset relationship"
        }
      ],
      "missingIdeas": [
        "No worked subset test or subset notation used"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L065",
        "upcat-L183",
        "ustet-L083",
        "dost-sei-L126"
      ],
      "facet": "Union intersection and complement",
      "lessonIds": [
        "lesson-algebra-sets-and-set-notation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            18,
            28
          ],
          "note": "L01 local teaching: Union intersection and complement"
        },
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            32,
            52
          ],
          "note": "L19 example: Union intersection and complement"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L065"
      ],
      "facet": "Cardinality notation and counting sets",
      "lessonIds": [
        "lesson-algebra-sets-and-set-notation"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            112,
            116
          ],
          "note": "L01 local teaching: Cardinality notation and counting sets"
        },
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            54,
            76
          ],
          "note": "L19 example: Cardinality notation and counting sets"
        }
      ],
      "missingIdeas": [
        "Counting is demonstrated; vertical-bar cardinality notation is introduced without an explicit symbol definition"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L065"
      ],
      "facet": "Set difference",
      "lessonIds": [
        "lesson-algebra-sets-and-set-notation"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            18,
            28
          ],
          "note": "L01 local teaching: Set difference"
        }
      ],
      "missingIdeas": [
        "Difference operation and notation are not explicitly taught; complement alone does not cover this separate facet"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L065",
        "upcat-L183"
      ],
      "facet": "Two-set only/both/neither counts",
      "lessonIds": [
        "lesson-algebra-sets-and-set-notation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            112,
            122
          ],
          "note": "L01 local teaching: Two-set only/both/neither counts"
        },
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            54,
            76
          ],
          "note": "L19 example: Two-set only/both/neither counts"
        }
      ],
      "missingIdeas": [
        "Inclusion-exclusion formula comes after the example; the example itself supplies disjoint-region arithmetic"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L065",
        "upcat-L183"
      ],
      "facet": "Three-set disjoint-region counts",
      "lessonIds": [
        "lesson-algebra-sets-and-set-notation"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            124,
            124
          ],
          "note": "L01 local teaching: Three-set disjoint-region counts"
        },
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            78,
            108
          ],
          "note": "L19 example: Three-set disjoint-region counts"
        }
      ],
      "missingIdeas": [
        "Center-first procedure is taught in the worked example, rather than Core Concept"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L183",
        "acet-L065"
      ],
      "facet": "Membership and empty-set symbols",
      "lessonIds": [
        "lesson-algebra-sets-and-set-notation"
      ],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/sets-and-set-notation.md",
          "lines": [
            12,
            28
          ],
          "note": "L01 local teaching: Membership and empty-set symbols"
        }
      ],
      "missingIdeas": [
        "Element membership/nonmembership and empty-set notation are not taught; exact symbol roster expected by an exam remains unknown"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127"
      ],
      "facet": "Shared variables and simultaneous-solution meaning",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            12,
            32
          ],
          "note": "L01 local teaching: Shared variables and simultaneous-solution meaning"
        },
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            38,
            63
          ],
          "note": "L19 example: Shared variables and simultaneous-solution meaning"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Linear substitution",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            18,
            18
          ],
          "note": "L01 local teaching: Linear substitution"
        },
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            38,
            63
          ],
          "note": "L19 example: Linear substitution"
        }
      ],
      "missingIdeas": [
        "Simple linear isolation is explicitly supplied locally; no prerequisite for repeating it elsewhere"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Elimination by addition",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            20,
            20
          ],
          "note": "L01 local teaching: Elimination by addition"
        },
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            65,
            94
          ],
          "note": "L19 example: Elimination by addition"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "ustet-L084",
        "dost-sei-L127"
      ],
      "facet": "Elimination with scaling and subtraction",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            20,
            20
          ],
          "note": "L01 local teaching: Elimination with scaling and subtraction"
        },
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            96,
            129
          ],
          "note": "L19 example: Elimination with scaling and subtraction"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L067",
        "upcat-L188"
      ],
      "facet": "Graphing a system to locate intersection",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            22,
            30
          ],
          "note": "L01 local teaching: Graphing a system to locate intersection"
        }
      ],
      "missingIdeas": [
        "Intersection meaning explained; no procedure to construct both graphs and read a solution. Generic lines wording is too narrow for nonlinear systems"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "ustet-L084"
      ],
      "facet": "Linear one/no/infinite solution distinctions",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            26,
            30
          ],
          "note": "L01 local teaching: Linear one/no/infinite solution distinctions"
        },
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            221,
            225
          ],
          "note": "L19 example: Linear one/no/infinite solution distinctions"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "pupcet-L093",
        "dost-sei-L127"
      ],
      "facet": "Two-quantity count/revenue model",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            12,
            20
          ],
          "note": "L01 local teaching: Two-quantity count/revenue model"
        },
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            131,
            160
          ],
          "note": "L19 example: Two-quantity count/revenue model"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dost-sei-L134"
      ],
      "facet": "Line-parabola nonlinear substitution",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            32,
            32
          ],
          "note": "L01 local teaching: Line-parabola nonlinear substitution"
        },
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            162,
            187
          ],
          "note": "L19 example: Line-parabola nonlinear substitution"
        }
      ],
      "missingIdeas": [
        "Factorization and roots are supplied; general factor-generation is not taught locally, but those provided quantities do not justify a strict quadratic prerequisite"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L186",
        "acet-L067",
        "ustet-L084"
      ],
      "facet": "Solve for a requested linear combination directly",
      "lessonIds": [
        "lesson-algebra-systems-of-equations"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            193,
            203
          ],
          "note": "L01 local teaching: Solve for a requested linear combination directly"
        },
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            193,
            201
          ],
          "note": "L19 example: Solve for a requested linear combination directly"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L188",
        "dcat-L053",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L095",
        "dost-sei-L131",
        "sm-foundation-L094"
      ],
      "facet": "Linear polynomial-power and exponential family recognition",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            12,
            30
          ],
          "note": "L01 local teaching: Linear polynomial-power and exponential family recognition"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            38,
            46
          ],
          "note": "L19 example: Linear polynomial-power and exponential family recognition"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "dcat-L051",
        "acet-L078",
        "ustet-L085",
        "pupcet-L094",
        "dost-sei-L127"
      ],
      "facet": "Quadratic opening vertex and extremum",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            16,
            18
          ],
          "note": "L01 local teaching: Quadratic opening vertex and extremum"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            48,
            60
          ],
          "note": "L19 example: Quadratic opening vertex and extremum"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Rational function definition and original-domain exclusions",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            20,
            24
          ],
          "note": "L01 local teaching: Rational function definition and original-domain exclusions"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            62,
            71
          ],
          "note": "L19 example: Rational function definition and original-domain exclusions"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Rational vertical and same-degree horizontal asymptotes",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            24,
            24
          ],
          "note": "L01 local teaching: Rational vertical and same-degree horizontal asymptotes"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            62,
            75
          ],
          "note": "L19 example: Rational vertical and same-degree horizontal asymptotes"
        }
      ],
      "missingIdeas": [
        "Rules for one uncanceled pole and equal-degree ratio are taught in example; approach/limit meaning and other degree cases not explained"
      ],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078",
        "upcat-L189"
      ],
      "facet": "Slant asymptotes and removable discontinuities",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "named-only",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            24,
            24
          ],
          "note": "L01 local teaching: Slant asymptotes and removable discontinuities"
        }
      ],
      "missingIdeas": [
        "No division-based slant method, cancellation/hole distinction or applied graph case"
      ],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078",
        "ustet-L091"
      ],
      "facet": "Absolute-value meaning graph and transformations",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            26,
            26
          ],
          "note": "L01 local teaching: Absolute-value meaning graph and transformations"
        }
      ],
      "missingIdeas": [
        "Nonnegative outputs and V shape stated; magnitude/distance and shift/stretch/reflect rules not defined"
      ],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078"
      ],
      "facet": "Absolute-value equation branches",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            137,
            137
          ],
          "note": "L01 local teaching: Absolute-value equation branches"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            77,
            89
          ],
          "note": "L19 example: Absolute-value equation branches"
        }
      ],
      "missingIdeas": [
        "Positive-output two-case method taught by example; meaning of |u| not defined locally beforehand"
      ],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Exponential growth versus decay",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            28,
            28
          ],
          "note": "L01 local teaching: Exponential growth versus decay"
        }
      ],
      "missingIdeas": [
        "No numerical growth/decay model or graph interpretation"
      ],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Elementary same-base exponent equation and log evaluation",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            28,
            30
          ],
          "note": "L01 local teaching: Elementary same-base exponent equation and log evaluation"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            91,
            105
          ],
          "note": "L19 example: Elementary same-base exponent equation and log evaluation"
        }
      ],
      "missingIdeas": [
        "Log evaluation is not an unknown-argument logarithmic equation"
      ],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078",
        "ustet-L091",
        "dost-sei-L131"
      ],
      "facet": "Piecewise evaluation at included boundaries",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            32,
            32
          ],
          "note": "L01 local teaching: Piecewise evaluation at included boundaries"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            107,
            123
          ],
          "note": "L19 example: Piecewise evaluation at included boundaries"
        }
      ],
      "missingIdeas": [
        "No piecewise graph construction or applied model"
      ],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "acet-L078",
        "upcat-L189",
        "dcat-L056",
        "ustet-L091"
      ],
      "facet": "Function intercept and range interpretation across families",
      "lessonIds": [
        "lesson-algebra-types-of-functions"
      ],
      "verdict": "thin",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            14,
            32
          ],
          "note": "L01 local teaching: Function intercept and range interpretation across families"
        }
      ],
      "missingIdeas": [
        "Some output/opening/domain facts stated; no general intercept/range derivation or graph-based family comparison"
      ],
      "priorKnowledge": "lesson-algebra-functions-and-relations: The consumer excludes vertical relations from functions and calls logarithms inverse functions without defining input-output uniqueness or inverse pairing; those indispensable meanings are taught in the foundation.",
      "workedExamples": "none",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L207",
        "dcat-L061",
        "acet-L085",
        "cse-professional-L110",
        "cse-subprofessional-L076"
      ],
      "facet": "General unknown/fact/equation modeling process",
      "lessonIds": [
        "lesson-algebra-word-problems"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            12,
            17
          ],
          "note": "L01 local teaching: General unknown/fact/equation modeling process"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            39,
            59
          ],
          "note": "L19 example: General unknown/fact/equation modeling process"
        }
      ],
      "missingIdeas": [
        "Named word-problem scope is official for CSE; these exact families/depth remain unknown or weak elsewhere"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L207",
        "cse-professional-L110",
        "cse-subprofessional-L076"
      ],
      "facet": "Age change for both people",
      "lessonIds": [
        "lesson-algebra-word-problems"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            21,
            21
          ],
          "note": "L01 local teaching: Age change for both people"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            39,
            59
          ],
          "note": "L19 example: Age change for both people"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L207",
        "acet-L064",
        "cse-professional-L115",
        "cse-subprofessional-L076"
      ],
      "facet": "Motion separation with constant rates",
      "lessonIds": [
        "lesson-algebra-word-problems"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            23,
            25
          ],
          "note": "L01 local teaching: Motion separation with constant rates"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            61,
            80
          ],
          "note": "L19 example: Motion separation with constant rates"
        }
      ],
      "missingIdeas": [
        "Only opposite-direction separation is worked; chase/toward motion appears as an unworked shortcut, not a completeness claim"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L207",
        "acet-L064",
        "cse-professional-L110",
        "cse-subprofessional-L076"
      ],
      "facet": "Additive constant work rates",
      "lessonIds": [
        "lesson-algebra-word-problems"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            27,
            27
          ],
          "note": "L01 local teaching: Additive constant work rates"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            82,
            98
          ],
          "note": "L19 example: Additive constant work rates"
        }
      ],
      "missingIdeas": [
        "Assumes fixed additive contributions to the same job; other work/delayed/negative-rate variants not verified as required"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L207",
        "cse-professional-L110",
        "cse-subprofessional-L076"
      ],
      "facet": "Conserved-mixture concentration model",
      "lessonIds": [
        "lesson-algebra-word-problems"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            29,
            29
          ],
          "note": "L01 local teaching: Conserved-mixture concentration model"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            100,
            124
          ],
          "note": "L19 example: Conserved-mixture concentration model"
        }
      ],
      "missingIdeas": [
        "Percent-to-decimal conversion is used but not defined locally; ideal volume additivity is assumed in the arithmetic model"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "cse-professional-L110",
        "cse-subprofessional-L076"
      ],
      "facet": "Coin count and value constraints",
      "lessonIds": [
        "lesson-algebra-word-problems"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            31,
            31
          ],
          "note": "L01 local teaching: Coin count and value constraints"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            126,
            149
          ],
          "note": "L19 example: Coin count and value constraints"
        }
      ],
      "missingIdeas": [
        "Elimination is supplied locally, so a more detailed systems lesson is optional"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "cse-professional-L110",
        "cse-subprofessional-L076"
      ],
      "facet": "Digit place value and reversed-number equations",
      "lessonIds": [
        "lesson-algebra-word-problems"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            33,
            33
          ],
          "note": "L01 local teaching: Digit place value and reversed-number equations"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            151,
            181
          ],
          "note": "L19 example: Digit place value and reversed-number equations"
        }
      ],
      "missingIdeas": [],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "cse-professional-L110",
        "cse-subprofessional-L076"
      ],
      "facet": "Requested quantity and reasonableness checks",
      "lessonIds": [
        "lesson-algebra-word-problems"
      ],
      "verdict": "explained",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            17,
            17
          ],
          "note": "L01 local teaching: Requested quantity and reasonableness checks"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            39,
            59
          ],
          "note": "L19 example: Requested quantity and reasonableness checks"
        }
      ],
      "missingIdeas": [
        "Universal claims that the unasked answer always appears in choices are not verified exam facts"
      ],
      "priorKnowledge": "Locally supplied definitions/procedures/data; no indispensable existing-lesson edge found.",
      "workedExamples": "worked",
      "scopeLimit": "Local facet only; apply common source/exam/cohort/depth limits."
    },
    {
      "requirementRefs": [
        "upcat-L187",
        "acet-L066",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127",
        "sm-foundation-L091"
      ],
      "facet": "Simplify polynomial-factor rational expressions with original-domain restrictions",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            60,
            76
          ],
          "note": "Monomial power quotient only"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            20,
            24
          ],
          "note": "Quotient/domain definition without factor cancellation"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            24,
            30
          ],
          "note": "Division names/theorems, not rational-expression simplification"
        }
      ],
      "missingIdeas": [
        "No polynomial-factor cancellation retaining excluded inputs; monomial power quotients and radical rationalization do not establish this broader facet"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "upcat-L187",
        "acet-L066",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127"
      ],
      "facet": "Add and subtract variable-denominator rational expressions",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            82,
            98
          ],
          "note": "Constant-denominator work-rate sum"
        },
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            14,
            30
          ],
          "note": "Polynomial operations, not rational common-denominator operations"
        }
      ],
      "missingIdeas": [
        "No least-common polynomial denominator, algebraic numerator combination or domain-preserving simplification"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L094",
        "pupcet-L098",
        "dost-sei-L131",
        "sm-foundation-L091"
      ],
      "facet": "Rational equations with unknown denominators",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            39,
            55
          ],
          "note": "Denominators are constant 2 and 3"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            62,
            75
          ],
          "note": "Asymptote example is not an equation solve"
        }
      ],
      "missingIdeas": [
        "No variable-denominator equation, clearing with original restrictions or invalid-root check"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Rational inequalities and sign intervals",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/linear-equations-inequalities.md",
          "lines": [
            57,
            73
          ],
          "note": "Linear inequality only"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            20,
            24
          ],
          "note": "Rational definition only"
        }
      ],
      "missingIdeas": [
        "No numerator/denominator critical values, sign chart or excluded boundary handling"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Exponential inequalities",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            124,
            142
          ],
          "note": "Exponential equality only"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            28,
            30
          ],
          "note": "Growth/decay fact without inequality-solving method"
        }
      ],
      "missingIdeas": [
        "No inequality preservation/reversal by increasing/decreasing exponential base"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "upcat-L189",
        "dcat-L056",
        "acet-L078",
        "ustet-L091",
        "pupcet-L098",
        "dost-sei-L131"
      ],
      "facet": "Logarithmic inequalities",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            36,
            44
          ],
          "note": "Log expression laws, not inequality method"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            91,
            105
          ],
          "note": "Log evaluation only"
        }
      ],
      "missingIdeas": [
        "No log-inequality transformation, base monotonicity or simultaneous domain restrictions"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "dcat-L053",
        "pupcet-L095"
      ],
      "facet": "Higher-degree polynomial graph interpretation",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            28,
            30
          ],
          "note": "Factor/zero criterion without graph interpretation"
        },
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            38,
            60
          ],
          "note": "Power-family label and quadratic vertex only"
        }
      ],
      "missingIdeas": [
        "No higher-degree end behavior, zero crossing/tangency, multiplicity or graph-to-rule interpretation; quadratic cases remain separate"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "acet-L069",
        "ustet-L085",
        "pupcet-L094",
        "dost-sei-L127"
      ],
      "facet": "Direct variation modeling",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            14,
            32
          ],
          "note": "Family list without variation constants/models"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            23,
            27
          ],
          "note": "Specific d=rt and reciprocal work-rate patterns"
        }
      ],
      "missingIdeas": [
        "No explicit direct variation modeling identification, constant estimation or prediction procedure in Algebra. Specific d=rt/reciprocal-rate patterns remain present; arithmetic ratio/proportion is an unverified cross-topic search lead."
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "acet-L069",
        "ustet-L085",
        "pupcet-L094",
        "dost-sei-L127"
      ],
      "facet": "Inverse variation modeling",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            14,
            32
          ],
          "note": "Family list without variation constants/models"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            23,
            27
          ],
          "note": "Specific d=rt and reciprocal work-rate patterns"
        }
      ],
      "missingIdeas": [
        "No explicit inverse variation modeling identification, constant estimation or prediction procedure in Algebra. Specific d=rt/reciprocal-rate patterns remain present; arithmetic ratio/proportion is an unverified cross-topic search lead."
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "acet-L069",
        "ustet-L085",
        "pupcet-L094",
        "dost-sei-L127"
      ],
      "facet": "Joint variation modeling",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            14,
            32
          ],
          "note": "Family list without variation constants/models"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            23,
            27
          ],
          "note": "Specific d=rt and reciprocal work-rate patterns"
        }
      ],
      "missingIdeas": [
        "No explicit joint variation modeling identification, constant estimation or prediction procedure in Algebra. Specific d=rt/reciprocal-rate patterns remain present; arithmetic ratio/proportion is an unverified cross-topic search lead."
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "acet-L069",
        "ustet-L085",
        "pupcet-L094",
        "dost-sei-L127"
      ],
      "facet": "Combined variation modeling",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/types-of-functions.md",
          "lines": [
            14,
            32
          ],
          "note": "Family list without variation constants/models"
        },
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            23,
            27
          ],
          "note": "Specific d=rt and reciprocal work-rate patterns"
        }
      ],
      "missingIdeas": [
        "No explicit combined variation modeling identification, constant estimation or prediction procedure in Algebra. Specific d=rt/reciprocal-rate patterns remain present; arithmetic ratio/proportion is an unverified cross-topic search lead."
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "upcat-L187",
        "acet-L066",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127"
      ],
      "facet": "Multiply polynomial-factor rational expressions",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            60,
            76
          ],
          "note": "Restricted monomial special case"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            68,
            112
          ],
          "note": "Radical denominators, not polynomial-factor quotients"
        }
      ],
      "missingIdeas": [
        "No reciprocal/product cancellation procedure with excluded-domain accounting for general polynomial quotients"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    },
    {
      "requirementRefs": [
        "upcat-L187",
        "acet-L066",
        "ustet-L084",
        "pupcet-L093",
        "dost-sei-L127"
      ],
      "facet": "Divide polynomial-factor rational expressions",
      "lessonIds": [],
      "verdict": "absent",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            60,
            76
          ],
          "note": "Restricted monomial special case"
        },
        {
          "path": "content/lessons/mathematics/algebra/radicals-and-rationalization.md",
          "lines": [
            68,
            112
          ],
          "note": "Radical denominators, not polynomial-factor quotients"
        }
      ],
      "missingIdeas": [
        "No reciprocal/product cancellation procedure with excluded-domain accounting for general polynomial quotients"
      ],
      "priorKnowledge": "Full Algebra topic read; other-topic inventory supplies search leads only.",
      "workedExamples": "none for the general missing facet; cited special cases remain present",
      "scopeLimit": "Local Algebra only. Preserve curriculum/SHS cohort and unknown current exam depth; no corpus-wide absence claim."
    }
  ],
  "sourceLedger": [
    {
      "accessDate": "2026-10-06",
      "accessTimezone": "Asia/Manila",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-algebra-algebraic-expressions",
      "issue": "One test input cannot prove the translation correct",
      "originalClaim": "A matching result for a single simple input identifies the correct choice",
      "disposition": "ACCURACY CONCERN",
      "sourceUrl": "https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/algebraic-expressions.md#L153",
      "sourceLocator": "Pinned lesson lines 153-155; independent algebraic reasoning",
      "verificationNote": "Independent counterexample: 2x and x+2 both equal 4 at x=2, but equal 6 and 5 at x=3. One agreement cannot uniquely establish the expression; use the symbolic relationship or a discriminating check. No question-bank items were inspected.",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/algebraic-expressions.md",
          "lines": [
            153,
            155
          ],
          "note": "One test input cannot prove the translation correct"
        }
      ]
    },
    {
      "accessDate": "2026-10-06",
      "accessTimezone": "Asia/Manila",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-algebra-exponents-and-logarithms",
      "issue": "Power-of-power domain condition needs precision",
      "originalClaim": "The power-of-power rule applies wherever the indicated powers are defined",
      "disposition": "DOMAIN QUALIFICATION CONCERN",
      "sourceUrl": "https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/exponents-and-logarithms.md#L20",
      "sourceLocator": "Pinned lesson lines 20-34; independent algebraic reasoning",
      "verificationNote": "For a=-1, m=2, n=1/2, sqrt((-1)^2)=1 while (-1)^(2*1/2)=-1; both sides are real and defined. The rule needs appropriate exponent/base restrictions. Current integer/positive-base examples do not settle the broader wording.",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/exponents-and-logarithms.md",
          "lines": [
            20,
            34
          ],
          "note": "Power-of-power domain condition needs precision"
        }
      ]
    },
    {
      "accessDate": "2026-10-06",
      "accessTimezone": "Asia/Manila",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-algebra-polynomials",
      "issue": "Multiple-factor parameter example used in teaching assessment",
      "originalClaim": "The constraints give a=1, b=-7 and a+b=-6",
      "disposition": "CONFIRMED CALCULATION",
      "sourceUrl": "https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/polynomials.md#L110",
      "sourceLocator": "Pinned lesson lines 110-142; independent algebraic reasoning",
      "verificationNote": "Re-derived P(2)=0 -> 2a+b=-5 and P(-1)=0 -> a-b=8, giving a=1 and b=-7. Multiplication of (x^2-x-2)(2x+3) recovers 2x^3+x^2-7x-6. This verifies this encountered calculation only.",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/polynomials.md",
          "lines": [
            110,
            142
          ],
          "note": "Multiple-factor parameter example used in teaching assessment"
        }
      ]
    },
    {
      "accessDate": "2026-10-06",
      "accessTimezone": "Asia/Manila",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-algebra-word-problems",
      "issue": "Universal exam-tactic claim is not sourced",
      "originalClaim": "The unasked value is always present in answer choices",
      "disposition": "UNKNOWN",
      "sourceUrl": "https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/word-problems.md#L203",
      "sourceLocator": "Pinned lesson lines 203-207; independent algebraic reasoning",
      "verificationNote": "Accepted packets confirm broad word-problem or preparation domains but do not establish this universal item-writing pattern. No new current organizer-style verification was performed; absence of verified support is not proof of exam exclusion.",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/word-problems.md",
          "lines": [
            203,
            207
          ],
          "note": "Universal exam-tactic claim is not sourced"
        }
      ]
    },
    {
      "accessDate": "2026-10-06",
      "accessTimezone": "Asia/Manila",
      "branch": "docs/content-coverage-audit-r1",
      "baseCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
      "item": "lesson-algebra-systems-of-equations",
      "issue": "Graphing definition scope",
      "originalClaim": "Graphing means drawing both equations as lines",
      "disposition": "SCOPE CLARIFICATION",
      "sourceUrl": "https://github.com/Aedwon/Pantas/blob/765c5dc0fa5586281047bf4f7b30d09ab3707887/content/lessons/mathematics/algebra/systems-of-equations.md#L16",
      "sourceLocator": "Pinned lesson lines 16-32; independent algebraic reasoning",
      "verificationNote": "The statement fits linear systems but the lesson also includes a parabola. Its nonlinear example explicitly uses a line and parabola, so the general description should distinguish graphing curves from graphing two lines. No illustration assessment was performed.",
      "evidence": [
        {
          "path": "content/lessons/mathematics/algebra/systems-of-equations.md",
          "lines": [
            16,
            32
          ],
          "note": "Graphing definition scope"
        }
      ]
    }
  ],
  "foundationReads": [
    {
      "path": "content/lessons/mathematics/geometry/coordinate-geometry.md",
      "sha256": "f2b8a049ca59e633c41ec3bbde03b7ffc207da00bab33ebe5d46355232c27bc5",
      "readLines": [
        1,
        216
      ],
      "purpose": "Full narrow read for coordinate-address prerequisite, lines 12 only used as the indispensable foundation."
    },
    {
      "path": "content/lessons/mathematics/arithmetic-number-sense/fractions-decimals-percentages.md",
      "sha256": "5c2f5a66c7be71ea28805836a119f66a70945e75797939d497e7663d5126bbb0",
      "readLines": [
        1,
        149
      ],
      "purpose": "Full narrow necessity check. Conversion definition is at lines 14-16, but the current mixture example supplies 0.20/0.50/0.30 values; deeper conversion preparation is optional, not a strict edge."
    }
  ],
  "summary": "Teach shared algebra once, preserving separate local facets. UPCAT/USTET officially name Mathematics; their finer depth is unpublished in the accepted records. DOST names Algebra in the historical 2026 primer, with 2027 continuity unknown. Most CET/SM finer methods are curriculum or weak preparation candidates, with SHS track/cohort/completion limits. CSE 2026 PPT officially names English word problems; additional algebra is largely weak reviewer preparation. No single roster establishes equal whole-lesson scope, current item language, runtime availability or full exam coverage. Practice and later standards remain deferred.\n\n- Split candidates: exponent manipulation versus logarithm teaching; one-variable linear solving versus coordinate line/half-plane reasoning. These separate reusable foundations from different method goals and conditional scope. Costs: approved new identities/routing, moved examples/traps, missing-method additions and later practice review. Evidence: exponents-and-logarithms lines 12-44, 60-157; linear-equations-inequalities lines 12-35, 75-118 (L01/L17/L19 structural use).\n- Retain polynomial operations, quadratic solving, simultaneous-equation methods and the six-scenario modeling lesson as coherent shared goals. Thin division/root-search labels need actual teaching before a further split can improve learning. Reorder the function-family overview so necessary meanings precede applications; do not create one unit per family.\n- Important local gaps: polynomial division and Rational Root Theorem; general polynomial-factor rational operations, rational equations/inequalities; quadratic/exponential/logarithmic inequalities; explicit variation models and higher-degree polynomial graph interpretation. Monomial power quotients, radical rationalization, motion/work patterns and quadratic vertices are present, so these gaps are deliberately narrower. Other-topic reconciliation remains with the lead.\n- Completing the square, formula solving, range derivation, constrained composition/inverse branches and some graph methods have missing or thin worked applications. No arbitrary example minimum is used. Detailed facet evidence occurs once in the appendix.\n- Two narrow prerequisite edges are proposed: function-family teaching needs the definition/inverse pairing in Functions and Relations; current line-plotting instructions need coordinate address/axis meanings. Existing repeated procedures, supplied balanced/factored expressions, converted percentages and supplied roots do not justify extra edges. Both ends are cited below.\n- All owned prompts supply the deciding formulas, pairs, region facts or counts in text. No load-bearing figure dependency was found, including the shaded-region and Venn examples. Markers do not prove runtime display or illustration sufficiency.\n- Encountered concerns: single-input verification is insufficient; the power-of-power rule needs precise domain restrictions; generic system graphing must allow nonlinear curves. Universal CET choice-tactic claims remain unverified. Only bounded algebraic checks were performed, with no question-bank/blind-solve or full correctness claim.\n\nAccepted source packets: [UPCAT](../requirements/upcat.md), [DCAT](../requirements/dcat.md), [ACET](../requirements/acet.md), [USTET](../requirements/ustet.md), [PUPCET](../requirements/pupcet.md), [DOST-SEI](../requirements/dost-sei.md), [SM Foundation](../requirements/sm-foundation.md), [CSE Professional](../requirements/cse-professional.md), [CSE Subprofessional](../requirements/cse-subprofessional.md). Requirement IDs carry exact source/page/confidence. Common preparation source: [DepEd Grades 1-10 Mathematics](https://www.deped.gov.ph/wp-content/uploads/2019/01/Math-CG_with-tagged-math-equipment.pdf), Grade 7-10 standards and cited competencies. Conditional SHS source: [General Mathematics listing](https://lrmds.deped.gov.ph/detail/14511), competencies, and its packet-linked PDF. Historical DOST named domain: [2026 primer](https://science-scholarships.ph/pdf/2026_DOST-SEI_UG_Primer.pdf), p. 13. These links trace accepted evidence; they are not a new external requirement pass."
}
```
