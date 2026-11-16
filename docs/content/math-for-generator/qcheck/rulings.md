# CET math question check: lead rulings

November 16, 2026 (UTC). Codex GPT 6.1 Sol (medium, read-only) read 14 files, 311 questions, each against its current lesson: the 11 Algebra files against the live parts their questions point to, and the 3 geometry files whose lessons changed in the audit fixes. Every question was solved before its key was read. Results: `results/`.

32 findings, all Major. No Blocker: no wrong or ambiguous key was found.

## Rulings

1. **Rejected, no change (1):** types-of-functions-0001, "the correct answer is first in all 31 questions". The app orders a question's choices from its id, so authored position never reaches a student (SUBAGENTS.md Part 4, on main). The style guide line saying YAML order is display order is older than that change.
2. **Wrong rationale (1), fix:** algebraic-expressions-0017. Rewrite that one rationale so it names the real mistake.
3. **Wrong lesson pointer (fix the question's `lesson:` field to the part that teaches its main skill), when such a part exists:** exponents-and-logarithms-0006 (a logarithm part), polynomials-0023 (the rational-expressions part that teaches cancelling and holes, if its skill matches), radicals-and-rationalization-0002 if a part teaches bounding a root, systems-of-equations-0018 if a rates part fits. Keep `keyPoint` valid for the new part or drop it.
4. **Skill taught elsewhere in the app but not named (the rest of the prerequisite findings):** add one sentence to the assigned lesson, near the related example, naming where it is taught ("Part N, <title>, shows how to ..." for Algebra parts; the lesson title for other topics). Search the app's math lessons to find it. Applies to percent to decimal, rate times time, unit conversion of rates, translating statements into equations, square and rectangle area, triangle and parallelogram area, triangle angle sum, 30-60-90 triangles, solving two linear equations, inequality intervals.
5. **Skill taught nowhere in the app's active math lessons:** add one to three plain sentences that teach it, with the rule stated correctly and its condition, in the assigned lesson next to the related content. For the sets part, reuse the wording of the CET-rewritten parent `content/lessons/mathematics/algebra/sets-and-set-notation.md` (the symbols, the empty set, the 2^n count of subsets, set-builder notation, De Morgan's laws), since that text passed six reads. For circles: inscribed quadrilateral opposite angles, angle between two chords, angle outside the circle between secants, an inscribed square's diagonal. For coordinate geometry 0015: rewrite the explanation with a method the lesson teaches if one works; otherwise teach the point-to-line distance idea in one or two sentences.
6. No key changes. No question set inactive.

Fix: Codex GPT 6.1 Sol, one job (`fix-brief.md`). Check: Astra, read-only.
