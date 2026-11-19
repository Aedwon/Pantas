# CET algebra audit

**FAIL.** Read 43 active parts in full and independently solved and checked all 218 questions tagged to them. Every checked key was correct. The pre-solution figure markers and available figures did not reveal a worked answer.
Source `69d8f39b6`. Main workflow policy `71d58f260`. The 10 retired originals establish the scope through their `replacedBy` lists.

| Retired lesson | Questions checked in active part order |
|---|---|
| Algebraic Expressions | 7, 4, 12 |
| Exponents and Logarithms | 9, 4, 5, 4 |
| Functions and Relations | 7, 7, 5 |
| Linear Equations and Inequalities | 7, 5, 5, 3, 3 |
| Polynomials | 2, 6, 5, 4, 3, 2, 2, 4, 2 |
| Quadratic Equations | 6, 10 |
| Radicals and Rationalization | 10, 7, 3 |
| Sets and Set Notation | 6, 7 |
| Systems of Equations | 11, 4, 3, 2 |
| Types of Functions | 4, 3, 4, 3, 4, 4, 4, 6 |

## Blockers

Lesson filenames below are under `content/lessons/mathematics/algebra/`. YAML filenames are under `content/questions/mathematics/algebra/`.

- **Blocker** · `systems-substitution-and-word-problems.md:19,25` and `systems-graphs-and-solution-counts.md:18`. “The solution is the exact spot where the roads cross.” “The solution is the point where the lines cross.” Parallel lines share no points. Coincident lines share infinitely many. Say every common point is a solution. Also qualify “If a problem gives you two facts about two unknown things, it is a system in disguise.” Each fact used must give an equation.
- **Blocker** · `rationalizing-square-root-denominators.md:19,29` and `cube-root-denominators-and-nested-radicals.md:35`. “**Rationalizing a denominator** means rewriting an equivalent fraction so its denominator is rational.” The variable examples allow irrational inputs. Taking $x=\sqrt2$ leaves irrational denominators $x$ in both worked answers. State that in these variable examples the aim is to remove the radical from the denominator, or require rational $x$.
- **Blocker** · `translating-algebraic-phrases.md:27`. “The phrase "less than" reverses the written order.” The lesson's own comparison “$5$ is less than $x$” keeps that order. Limit the rule to subtraction phrases of the form “$a$ less than $b$.”
- **Blocker** · `simplifying-and-evaluating-expressions.md:95`. “A minus sign before parentheses changes every sign inside the group.” For $-(x-(y-z))$, the outer minus makes $-x+(y-z)$, leaving the signs inside the inner group unchanged at that step. Say it changes the sign of each term at the outer level.
- **Blocker** · `polynomial-terms-and-degree.md:18`. “An **exponent** tells how many times a base is used as a factor.” This description does not cover the negative and fractional exponents used in the same part. Start with “A positive whole-number exponent.”

## Majors

- **Major** · `algebraic-expressions.yaml:300` (0013). “Translate "50% of a number $n$" into an algebraic expression.” The part teaches multiplying by a fraction and points to Decimal and Percent Conversions. Its prerequisite list is empty. Add that link or show one percent conversion locally.
- **Major** · `rates-and-consecutive-integers.md:23,52`. “3. Combine like terms.” The example depends on a skill deferred to Part 3. Part 3 already requires Part 2. Show locally that $x+x+x=3x$ and $2+4=6$ so the example works without a circular prerequisite.
- **Major** · `algebraic-expressions.yaml:490` (0021). “At the same rate, how many pages will it produce in $3h$ hours?” The part teaches finding a rate by dividing. It points to Motion Problems for the tested step of multiplying rate by time. Add the one-line rate-times-time rule after the rate example.
- **Major** · `exponents-and-logarithms.yaml:404,427` (0018, 0019). “A culture doubles once per hour” asks for a repeated-growth model in the exponent-laws part. “Which interval contains $50^{1/3}$?” asks for a cube-root bound in the fractional-powers part, which shows exact roots only. Add a doubling example and show how consecutive cubes bound a cube root. Alternatively move 0018 to the exponential-growth part and teach there how to include the starting amount.
- **Major** · `functions-domain-and-range.md:13,27` and `functions-and-relations.yaml:352` (0016). “Find domain restrictions and the range of a function.” The part defines range but works only function identification and domain. Use an existing set of pairs to show how to collect the distinct second coordinates.
- **Major** · `functions-and-relations.yaml:37` (0002). “For $f(x)=3x+2$, what is $f(x+2)-f(x)$?” The tagged part substitutes given numbers. This item also needs symbolic substitution, distribution, and subtraction of a group. Add Simplifying and Evaluating Expressions as a prerequisite and show a symbolic input.
- **Major** · `polynomial-terms-and-degree.md:28` and `polynomials.yaml:654` (0029). “Part 2, Polynomials (Operations), shows how to subtract a polynomial and combine like terms before finding the degree.” This Part 1 quiz requires those steps when the leading terms cancel. Add a worked degree example with cancellation in Part 1.
- **Major** · `polynomial-operations.md:37`. “two binomials” appears before Part 3 defines binomial. Gloss it as two polynomials with two terms each.
- **Major** · `quadratic-methods-and-root-properties.md:28,46`. “to create a perfect-square trinomial.” The part stops before showing how to write it as a square. “there are two non-real complex-conjugate roots” also uses an unexplained term. Show $(x+p/2)^2$ and finish one worked equation. Gloss complex conjugates or keep the rule to the count of real roots.
- **Major** · `cube-root-denominators-and-nested-radicals.md:27`. “Factor it as $(L-5)(L+4)=0$.” The method jumps straight to the factors. The listed prerequisites cover radicals. Name Factoring Quadratic Equations as a prerequisite or show how $-5$ and $4$ give product $-20$ and sum $-1$.
- **Major** · `systems-of-equations.yaml:263,286,355,424` (0011, 0012, 0015, 0018). “Subtract the equations to get $x-y=0$” is one of four explanations that introduce elimination in the substitution quiz. Solve by isolating and substituting a variable in each. In 0012, the notes at lines 278 and 281 cite $y=9-x$ and $y=2x-9$. Used with the second equation these give $0$ and $9/5$, while the choices are $6$ and $-3$. Specify the error occurs when back-substituting $x=3$, or use mistakes that produce the choices on their own.
- **Major** · `systems-lines-and-parabolas.md:20,39` and `content/lesson-prerequisites.json:3213`. “3. Factor the quadratic.” The part points to Factoring Quadratic Equations in the prose but the required links omit it. Add that prerequisite. It also teaches how to keep the zero root tested in systems question 0017.
- **Major** · `types-of-functions.yaml:681` (0030). “Which value of $x$ gives a vertical asymptote of $f(x)=\dfrac{x^2-9}{x^2-x-6}$?” The denominator requires monic trinomial factoring. The tagged part teaches difference of squares, and its links omit the trinomial lesson. Add Factoring Quadratics as a prerequisite or show one partial-cancellation example with a trinomial.
- **Major** · `types-of-functions.yaml:520` (0023). “What is its $y$-intercept?” The part checks a known coefficient from the choices. The item requires solving for that coefficient and knowing to set $x=0$. Add both steps to the existing graph-matching example.
- **Major** · `absolute-value-transformations.md:12` and `types-of-functions.yaml:214,559` (0010, 0025). “Find the vertex and range after shifts.” Both examples stop at vertex and direction. State that for all real inputs the upward V has range $y\ge k$ and the downward V has range $y\le k$. Apply that rule to one existing example.

- **Major** · `types-of-functions.yaml:267` (0012). “Solve for $x$ in the equation $\log_2(x + 3) = 4$.” The tagged part evaluates a logarithm with a known argument. Its equations example solves only an exponential equation. Add a worked logarithm equation with an unknown argument and a domain check, or link Logarithm Meaning and Equations.

## Minors

- **Minor** · `systems-substitution-and-word-problems.md:21` and `systems-graphs-and-solution-counts.md:30`. “There are three main ways to solve a system.” “Another quick check:” Both lead-ins carry over from the unsplit text. Introduce substitution directly and start the graph shortcut with “Compare the equations.”
- **Minor** · `polynomial-special-products.md:35` and `factoring-quadratic-equations.md:37–39`. “Measurement shows how to find the area of a square from its side length.” “For a rectangle, both dimensions must be positive”. These notes preface bare algebra examples with no dimensions. Put the square-area rule beside its application in polynomial question 0013, and remove the rectangle notes from the bare equation example.
- **Minor** · `polynomials.yaml:721` (0031). “use $9x^2-6x+4$” gives the needed factor with no derivation. Show how $3x$ and $2$ give the three terms using the sum-of-cubes rule.
- **Minor** · `quadratic-equations.yaml:373` (0016). “Their sum is $-5$ and product is $6$.” The explanation finds the roots first and lists the values without showing how the tagged method determines signs. After confirming real roots, say the positive product gives matching signs and the negative sum makes both negative.
- **Minor** · `linear-equations-inequalities.yaml:315,405` (0013, 0017). “Use $y=2x+b$.” This works, but the item's key point is point-slope form. Start with $y-3=2(x-1)$. “hourly earnings” refers to the rental charge after the booking fee, which is an amount in pesos. Use that name.
- **Minor** · `set-membership-and-operations.md:4`. “Use subsets, unions, intersections, and complements to describe set membership.” The part defines subsets but the subset notation and exercises moved to a standalone lesson. Match the summary to the operations and De Morgan's laws taught here.

**NO FINDINGS** in the other parts or their checked questions.
