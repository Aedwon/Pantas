# CET algebra audit fix
PASS. Main policy `71d58f260`. All 27 findings verified and fixed.

- B1 fixed. Every shared graph point solves the system. Each fact used to build a system must give an equation.
- B2 fixed. The square-root example requires positive rational input. The cube-root example and trap require nonzero rational input.
- B3 fixed. The word-order rule now applies to subtraction phrases.
- B4 fixed. Negate the terms in the outer group and keep nested groups together at that step.
- B5 fixed. The repeated-factor definition applies to positive whole-number exponents.
- M1 fixed. Linked Decimal and Percent Conversions for 0013.
- M2 fixed. The example adds the three copies of $x$ and adds $2+4$.
- M3 fixed. At a steady rate, multiply rate by time.
- M4 fixed. Added a doubling model and showed how consecutive cubes bound a cube root.
- M5 fixed. Read the distinct outputs of an existing set of ordered pairs.
- M6 fixed. Linked Simplifying and Evaluating Expressions and showed how to substitute and subtract groups.
- M7 fixed. Worked a degree example where the highest power cancels.
- M8 fixed. Defined binomials where FOIL first uses the term.
- M9 fixed. Showed the completed square and used it to finish the existing repeated-root example. The discriminant rule counts real roots.
- M10 fixed. Showed the product and sum used to factor the nested-radical equation.
- M11 fixed. Used substitution for 0011, 0012, 0015, and 0018. The notes for 0012 now say when the back-substitution errors occur.
- M12 fixed. Linked Factoring Quadratic Equations for factoring and keeping zero roots.
- M13 fixed. Linked Polynomials (Factoring Quadratics) for the denominator of 0030.
- M14 fixed. Solved for the coefficient and checked the intercept at $x=0$ in the graph example.
- M15 fixed. Stated both V-shaped ranges for all real inputs and applied the rule to the downward example.
- M16 fixed. Linked Logarithm Meaning and Equations for solving and checking the argument.
- m1 fixed. Removed the three-method lead-in and started the graph shortcut by comparing the equations.
- m2 fixed. Moved the square-area rule to 0013 and removed the rectangle notes from the bare equation.
- m3 fixed. Derived all three terms of the second factor in 0031.
- m4 fixed. Used the discriminant, product, and sum to determine both signs in 0016.
- m5 fixed. Used point-slope form in 0013 and named the rental charge in 0017.
- m6 fixed. Updated the set lesson summary to match the operations and De Morgan's laws.

## CHANGED-QUESTIONS
q-algebra-linear-equations-inequalities-0013
q-algebra-linear-equations-inequalities-0017
q-algebra-polynomials-0013
q-algebra-polynomials-0031
q-algebra-quadratic-equations-0016
q-algebra-systems-of-equations-0011
q-algebra-systems-of-equations-0012
q-algebra-systems-of-equations-0015
q-algebra-systems-of-equations-0018

All nine keys matched two solves each. All nine approval flags are false. IDs and tags stayed the same.
Checker from `cet-finish-443d02` with this worktree's content root. `dart run` hit a sandbox lock in the root project's build hooks. Direct Dart execution with the existing package config ran the same checker and exited 1.
Checker output totals: 0 size, nothing-dropped, or part violations. 16 expected lines: 5 factoring-cubes pool shortfalls, 5 parallel-and-perpendicular-lines pool shortfalls and 5 missing shipping questions for key point 2, and 1 areas-on-a-grid pool shortfall. `git diff --check` passed.
Files touched in `content/lessons/mathematics/algebra/` (all `.md`): absolute-value-equations-and-graph-matching, absolute-value-transformations, algebraic-expressions, cube-root-denominators-and-nested-radicals, evaluating-and-composing-functions, exponent-laws-and-zero-powers, exponents-and-logarithms, factoring-quadratic-equations, fractional-powers-and-exponent-equations, functions-and-relations, functions-domain-and-range, polynomial-operations, polynomial-special-products, polynomial-terms-and-degree, polynomials, quadratic-equations, quadratic-methods-and-root-properties, radicals-and-rationalization, rates-and-consecutive-integers, rationalizing-square-root-denominators, set-membership-and-operations, simplifying-and-evaluating-expressions, systems-graphs-and-solution-counts, systems-of-equations, systems-substitution-and-word-problems, translating-algebraic-phrases, types-of-functions.
Files touched in `content/questions/mathematics/algebra/` (all `.yaml`): linear-equations-inequalities, polynomials, quadratic-equations, systems-of-equations.
Other files touched: `content/lesson-prerequisites.json` and this report. Nothing staged or committed.
