# Counting check (Task 4 pilot)

## Check 1: Science inventory and provisional tags

**PASS.** The Science section contains 51 lesson slugs. The outline says, “All 51 Science lessons: `upcat` (provisional).” This covers every inventory slug by its universal tag statement.

## Check 2: Outline lesson slugs exist in the Science inventory

**PASS.** Every lesson slug named in the outline comparison table exists in the inventory's Science section. Missing slugs: none.

## Check 3: Curriculum or weak Science lines have mapping rows

**PASS.** Every Science topic or skill line labeled `curriculum` or `weak` in the requirements has a corresponding row in the outline mapping table. No such line is missing a row.

The mapping findings do not consistently use the required status terms `matched`, `partial`, or `gap`. Exact findings needing normalization:

- “**Apparent gap**: no lesson mentions biomolecules or carbohydrates”
- “**Apparent gap**, low priority until relevance is confirmed”
- “**Apparent gap**, minor; may not suit a reviewer app”
- “Mentioned; depth unknown”
- “Weak-evidence topic with no lesson; report, do not treat as a confirmed gap”
- “**Apparent gap**. A Reasoning lesson covers structural stability and center of gravity; Task 5 checks whether it teaches the physics”
- “Weak-evidence topic with no lesson; report only”
- “**Apparent gap or partial**”
- “Monsoons found; ITCZ and breezes not found”
- “**Apparent gap**, partial at most”
- “Climate change found; El Nino not found”

## Check 4: Matched rows name a lesson

**PASS.** No row says “Matched” while naming no lesson. Rows with “none found” are labeled as apparent gaps or weak-evidence topics without lessons, not as matched.

RESULT: FLAGS 1


Lead resolution, October 4, 2026: status terms normalized in `outline-comparison.md` to Matched, Partial, Gap (apparent), or Gap, weak evidence. Counting gate: passed.
