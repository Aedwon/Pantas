# Mathematics — Audit Findings

Lessons read: 44 across arithmetic-number-sense (9), algebra (11),
geometry (8), trigonometry (7), statistics-and-probability (5),
precalculus-basic-calculus (4). Sweep lines for the subject curated below;
every FORMULA/DEVICE line is either promoted to a finding or dismissed.

Correctness note: worked answers were re-derived by sampling across every
topic (e.g. prime factorization of $360 = 2^3\cdot3^2\cdot5$ ✓; arithmetic
$a_{25}=4+24\cdot3=76$ ✓; quadratic roots in `quadratic-equations.md` ✓).
No computational error surfaced in the sample. A full line-by-line
re-derivation of all ~250 examples is a focused follow-up if you want that
guarantee.

## arithmetic-number-sense

### MATH-ARI-001 ~~[blocker]~~ **RESOLVED, verified 13 August 2026.** Four choices are listed under the stem, and the correct one is $2^3 \times 3^2 \times 5$.

Original finding: prime-factorization-gcf-lcm.md — question lists no answer choices
Evidence: `arithmetic-number-sense/prime-factorization-gcf-lcm.md:38` —
"Which of the following represents the prime factorization of $360$?" with
no options A–D beneath it.
Fix: add four choices (e.g. $2^3\cdot3^2\cdot5$ plus three plausible
distractors like $2^2\cdot3^2\cdot5$), or reword to "Write the prime
factorization of $360$."

### MATH-ARI-002 [important] sequences-and-series.md — all sequence formulas taught only inside examples
Evidence: `arithmetic-number-sense/sequences-and-series.md:10-24` Core
Concept defines terms but states no formula; the arithmetic term formula
$a_n=a_1+(n-1)d$ first appears at line 34 inside Example #1's solution.
The arithmetic-sum, geometric-term, geometric-sum, and infinite-geometric
formulas are likewise introduced only in later solutions.
Fix: add a Core Concept subsection listing all five formulas
($a_n=a_1+(n-1)d$; $S_n=\tfrac{n}{2}(a_1+a_n)$;
$a_n=a_1 r^{n-1}$; $S_n=\tfrac{a_1(1-r^n)}{1-r}$;
$S_\infty=\tfrac{a_1}{1-r}$ for $|r|<1$) before the Examples section.
This is the exact "formula used but never taught" issue.

### MATH-ARI-003 [important] business-math.md — compound interest formula taught only inside an example
Evidence: `arithmetic-number-sense/business-math.md` Core Concept gives
simple interest $I=PRT$ but describes compound interest in prose only;
Example #5 (line 138) uses $A=P(1+r)^t$, which never appears in Core
Concept.
Fix: add the compound interest formula $A=P(1+r)^t$ (and note $n$
compounding periods if you want completeness) to the Core Concept interest
subsection.

### MATH-ARI-004 [polish] prime-factorization-gcf-lcm.md — extra section "When to List Multiples"
Evidence: sweep STRUCT line. This is a legitimate topical section the style
guide permits; keep. Logged so the sweep line is accounted for.

## algebra
No formula gaps. The FORMULA sweep lines for `algebraic-expressions.md:107`
($S,x$), `word-problems.md:126,151` ($x,y,u$), `systems-of-equations.md:131`
($a,c$), `linear-equations-inequalities.md` ($m,x,s$),
`functions-and-relations.md:129` ($x,y$), and `polynomials.md:186` ($a,b$)
are dismissed: each variable is defined inline in the word-problem setup or
is a standard slope-intercept/inverse-function variable already used in the
lesson's Core Concept. See Dismissed list.

## geometry

### MATH-GEO-001 ~~[blocker]~~ **RESOLVED, verified 13 August 2026.** Example #4 lists four choices under the stem and the solution points at one of them.

Original finding: logic-and-reasoning.md — "pick the equivalent statement" with choices only described in prose
Evidence: `geometry/logic-and-reasoning.md:84` Example #4 asks the student
to pick the equivalent statement, but the options are narrated inside the
solution ("The converse … is among the choices") rather than listed as
A–D in the question.
Fix: present the answer choices explicitly under the question stem.

## trigonometry
No formula gaps. The `solving-right-triangles.md:113` FORMULA line ($h,x$)
is dismissed: it applies the tangent ratio, which is taught in the sibling
lesson `basic-trigonometric-ratios.md` (SOH-CAH-TOA) and referenced in this
lesson's Core Concept. Consider a one-line reminder of the tangent ratio in
this lesson for self-containment (polish, folded into template note).

## statistics-and-probability
No blocking or formula findings. Illustration gaps only (see below).

## precalculus-basic-calculus
No formula gaps. All six `basic-derivatives.md` FORMULA lines (variable
$f$) are dismissed: the power, product, quotient, and chain rules are all
stated in Core Concept using $u,v,g$; the sweep only flagged $f$ because
examples switch to $f'(x)$ notation. Recommend Core Concept note that
$f'(x)$ and $\tfrac{d}{dx}$ mean the same thing (polish).

## Illustration gaps (74 sweep lines)
Concentrated in geometry (38) and trigonometry (23), then statistics (5),
precalculus (4), algebra (4). Most are legitimate: figure-dependent
examples (triangles, trapezoids, unit-circle quadrants, scatter plots)
that carry no placeholder in their block. Recommend adding one
`<!-- ILLUSTRATION: … -->` per flagged example during the illustration
phase. A minority are false positives where a shape is only named in a word
problem (e.g. "circular garden"); those are dismissed per-line at fix time.

## Template fit — proposal for Mathematics
The five-section template fits Mathematics well (it was derived here). Two
small adjustments surfaced:
- Several lessons teach formulas ad hoc in examples. Recommend the style
  guide explicitly require a **formulas-stated-in-Core-Concept** rule
  (drives MATH-ARI-002/003 and prevents recurrence).
- Trig/geometry lessons lean on sibling-lesson formulas; a one-line
  "Prerequisite" pointer at the top would aid self-teaching without a new
  section.

## Dismissed sweep lines
- `FORMULA … algebraic-expressions.md:107 [S,x]` — variables defined in the word-problem stem.
- `FORMULA … word-problems.md:126 [x,y]`, `:151 [u]` — coin/digit variables defined inline.
- `FORMULA … systems-of-equations.md:131 [a,c]` — apples/cost defined inline.
- `FORMULA … linear-equations-inequalities.md:101 [m,x]`, `:142 [x]`, `:178 [s]` — slope-intercept vars taught in Core Concept; word-problem var inline.
- `FORMULA … functions-and-relations.md:129 [x,y]` — inverse via swapping $x,y$, taught in Core Concept.
- `FORMULA … polynomials.md:186 [a,b]` — unknown coefficients defined by the problem.
- `FORMULA … properties-of-real-numbers.md:93 [x,y]` — distributive property variables, taught in Core Concept.
- `FORMULA … basic-derivatives.md:40–124 [f]` — rules taught with $u,v,g$; $f'$ is the same notation.
- `FORMULA … solving-right-triangles.md:113 [h,x]` — tangent ratio taught in sibling lesson.
- `STRUCT … prime-factorization-gcf-lcm.md:1` — permitted topical section (see MATH-ARI-004).
