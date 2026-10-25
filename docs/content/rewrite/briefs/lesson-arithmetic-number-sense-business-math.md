# Brief: Business Math

Lesson id: `lesson-arithmetic-number-sense-business-math`
Lesson path: `content/lessons/mathematics/arithmetic-number-sense/business-math.md`

Tagged exams: acet, cse-professional, dcat, dost-sei, pupcet, sm-foundation, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-arithmetic-number-sense-business-math|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> For **compound growth**, the **Rule of 72** gives a rough doubling-time estimate: divide $72$ by the annual percentage rate.
- Problem: The number 72 in the prose name "Rule of 72" is outside inline math. Under the rule, that prose number must be wrapped in $...$.
- Triage reason: The number 72 in Rule of 72 sits outside inline math.

### 2. `lesson-arithmetic-number-sense-business-math|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> How many years will it take for an investment of Php $15,000$ to earn Php $4,500$ in simple interest at $6\%$ per annum?
- Problem: The term "per annum" is needed to interpret the rate as annual in Example #4, but the lesson does not explain that term before or during the example and gives no prerequisite reminder for it.
- Triage reason: Per annum is used in Example 4 but never explained.

## CSE teaching to add

### 1. `mathematics-arithmetic-number-sense#10`
- Facet: Commission
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Develop Commission or its distinct application before complete local facet teaching is claimed.

### 2. `mathematics-arithmetic-number-sense#11`
- Facet: Sales tax
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Develop Sales tax or its distinct application before complete local facet teaching is claimed.

## Optional, fix only if editing that passage anyway

None.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
