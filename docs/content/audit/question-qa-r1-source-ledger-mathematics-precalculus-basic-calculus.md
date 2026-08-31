# Question QA R1 source ledger — Mathematics / Precalculus & Basic Calculus

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Reviewed:** 25 August 2026

This supplemental ledger records substantive corrections from the Precalculus & Basic Calculus question pass. All 56 authored items were independently recomputed or re-derived from their stated expressions and conditions. The four matching repository lessons were reviewed completely. No external factual source was required because the findings are deterministic mathematical-domain or definition issues.

## Corrected questions

| Question | Finding | Disposition | Evidence |
|---|---|---|---|
| `q-precalculus-basic-calculus-basic-derivatives-0006` | The original item asked for the derivative of `sqrt(x)` without stating the domain on which `1/(2 sqrt(x))` is the derivative. The function is defined at `x=0`, but its ordinary derivative is not finite there. | CORRECTED | Stem now specifies `x>0`; explanation explicitly excludes `x=0`. The keyed formula is unchanged. |
| `q-precalculus-basic-calculus-basic-derivatives-0009` | The original item gave the derivative of `cuberoot(x)` as `1/(3 cuberoot(x^2))` without noting that the ordinary derivative is undefined at `x=0`, even though the original function is defined there. | CORRECTED | Stem now specifies `x!=0`; explanation notes the unbounded difference quotient at zero. The keyed formula is unchanged. |
| `q-precalculus-basic-calculus-conic-sections-0010` | Opposite signs on the squared coefficients identify the hyperbola sign pattern, but do not by themselves guarantee a nondegenerate hyperbola. For example, `x^2-y^2=0` is a pair of intersecting lines. | CORRECTED | Stem now explicitly assumes a nondegenerate real conic. Under that assumption and with no `xy` term, `AC<0` identifies a hyperbola. |
| `q-precalculus-basic-calculus-limits-and-continuity-0005` | The keyed answer `0/0` was correct, but the explanation described `5/0` as `undefined / infinite`, conflating literal division by zero with possible limit behavior near a zero denominator. | CORRECTED | Explanation now states that literal `5/0` is undefined and that a nonzero-over-zero substitution requires one-sided analysis to decide `+infinity`, `-infinity`, or failure of the two-sided limit. |

## Lesson conformity and lesson gaps

The matching lessons reviewed were:

- `content/lessons/mathematics/precalculus-basic-calculus/basic-derivatives.md`
- `content/lessons/mathematics/precalculus-basic-calculus/basic-integrals.md`
- `content/lessons/mathematics/precalculus-basic-calculus/conic-sections.md`
- `content/lessons/mathematics/precalculus-basic-calculus/limits-and-continuity.md`

Three lesson precision gaps were intentionally not copied into the repaired questions:

1. **Basic Derivatives:** the lesson gives `d/dx sqrt(x) = 1/(2 sqrt(x))` without explicitly stating `x>0` or explaining the derivative failure at `x=0`.
2. **Conic Sections:** the lesson's fast-identification rule says opposite signs mean hyperbola without stating a nondegeneracy assumption. Degenerate second-degree equations can instead represent intersecting lines.
3. **Limits and Continuity:** the lesson says a nonzero-over-zero substitution means "the limit blows up." The sign and existence of a two-sided limit depend on one-sided behavior; literal division by zero itself is undefined.

`basic-integrals.md` introduced no item-level conflict in the reviewed bank.

These lesson files were not modified in this question-QA branch because the current scope is authored/static-question remediation plus durable recording of lesson conflicts/gaps.

## Visual classification

No reviewed Precalculus & Basic Calculus question requires an external figure. Tangent-line, definite-integral, conic, and piecewise-limit items are diagram-friendly and are marked `TEXT SUFFICIENT; VISUAL BENEFICIAL` where appropriate, but every active item states enough information to solve from text alone.
