# Figure Grouping (Identifying the Odd-One-Out)

Lesson: `lesson-spatial-abstract-reasoning-figure-grouping`. Lesson version: `2c220182a907`. Standards: `710d7062b594`.

## Findings from the chat read

- **B01** (Blocker; one read, paste run)
  - Quote: "The fourth figure's lines do not pass through the center, creating an uneven split (an odd number of regions, $3$), breaking the "lines through center create even regions" pattern."
  - Problem: This states a false causal rule. Two lines that miss the center do not necessarily create an odd number of regions; two off-center chords can intersect and create four regions. The specific prompt gives three regions, but being off-center alone does not imply that result.
- **L02** (Major; one read, paste run)
  - Quote: "Since the rule is not stated, approach this systematically by checking figures against a checklist of common shared-feature categories:"
  - Problem: The sentence uses abstract wording such as "systematically" and "shared-feature categories" that is harder than the required Grade 5 teaching voice.
- **L17** (Major; one read, paste run)
  - Quote: "**Run through the checklist categories systematically** (side count, symmetry, enclosed regions, curve vs. straight, shading) rather than staring at the figures hoping a rule jumps out: a checklist approach finds subtle rules faster than random guessing."
  - Problem: This reasoning lesson includes a Speed Tricks & Shortcuts section, but the subject-fit rule requires the reduced Reasoning layout of Core Concept, Examples, and Traps to Watch For, dropping Speed Tricks.
- **L18** (Major; one read, paste run)
  - Quote: "**Curved vs. straight lines**: are most figures made entirely of straight lines (or entirely of curves), while one mixes both or uses the opposite type?"
  - Problem: Curve-versus-straight grouping is taught as a common shared-feature category but has no worked example, so a distinct exam-relevant scenario named by the lesson is uncovered.
- **L18** (Major; one read, paste run)
  - Quote: "A figure that looks unusual in size or orientation might still share the true underlying rule (like side count or symmetry) with the rest of the group, while a more "normal-looking" figure actually breaks the rule."
  - Problem: The lesson warns about misleading size or orientation but gives no worked example where visual salience conflicts with the real grouping rule, leaving this stated edge case unpracticed.
- **L18** (Major; one read, paste run)
  - Quote: "**Confirm your rule against all the "belonging" figures before finalizing your answer**, not just two or three of them: a rule that fits three figures but fails on the supposed fourth "correct" one is not the actual rule."
  - Problem: The examples only confirm rules that work immediately. None shows a candidate rule failing and being revised, or two plausible all-member rules competing, so validation is not practiced at target difficulty.
- **L22a** (Minor; one read, paste run)
  - Quote: "**Figure grouping** questions present several figures and ask you to identify the one that does not belong with the others. The figures that do belong together share some common rule or feature; your job is to discover that shared rule, then find which figure breaks it."
  - Problem: This paragraph uses two long, clause-heavy sentences instead of the required short teaching sentences, making it denser than the formatting rule allows.
- **L23** (Major; one read, paste run)
  - Quote: "<!-- FIGURE: {"kind": "shape-row", "shapes": [{"form": "circle"}, {"form": "square"}, {"form": "triangle"}, {"form": "blob"}], "semanticsLabel": "A row of four shapes: a circle, a square, a triangle, and an irregular blob."} -->"
  - Problem: The figure specification is not specific enough for the symmetry question: it does not require an equilateral triangle or a blob with no reflection axis, so an artist or renderer could draw a figure that does not support the intended answer.
- **L25** (Major; one read, paste run)
  - Quote: "A figure that looks unusual in size or orientation might still share the true underlying rule (like side count or symmetry) with the rest of the group, while a more "normal-looking" figure actually breaks the rule."
  - Problem: The term "orientation" is needed to understand this trap but is never explained, and there is no prerequisite lesson that supplies its meaning.
- **L27** (Major; one read, paste run)
  - Quote: "The correct approach is to find the rule that makes four (or however many) figures belong to one consistent group, leaving exactly one figure that clearly does not fit that same rule."
  - Problem: The lesson presents the method as if one clear rule will always isolate one figure, but it never explains the limitation that more than one plausible grouping rule can fit the same set or make a question underdetermined.
- **L27** (Major; one read, paste run)
  - Quote: "The fourth figure's lines do not pass through the center, creating an uneven split (an odd number of regions, $3$), breaking the "lines through center create even regions" pattern."
  - Problem: The explanation omits the condition that the exact arrangement of the off-center lines matters; missing the center by itself does not guarantee three or any odd number of regions.

## Findings from the script

None.

## Illustration review

- insufficient, high priority, exact_exam_figure, code. At: "Four figures are shown: a perfect circle, a square, an equilateral triangle, and an irregular, lopsided blob shape with no matching sides. Which one does not belong?". Draw: Draw a perfect circle, a square, an equilateral triangle, and a clearly asymmetric lopsided blob with no reflection axis.. Why: The current figure specification only says triangle and blob, so the exact symmetry properties needed to verify the answer are not guaranteed visually.

## Accuracy concerns

- "The fourth figure's lines do not pass through the center, creating an uneven split (an odd number of regions, $3$), breaking the "lines through center create even regions" pattern.": Not passing through the center does not itself force two lines to create three or an odd number of regions; off-center chords can intersect and create four regions.
