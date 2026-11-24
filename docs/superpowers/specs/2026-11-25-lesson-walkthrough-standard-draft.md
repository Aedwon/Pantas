# Lesson walk-through standard (draft, not approved)

Date: November 25, 2026. Lane: lesson walk-through lead (E-156), board only. Policy read: `Aedwon/Pantas` main
54b550f48. Status: **draft for Aedwon's approval. Not added to `docs/content/lesson-style-guide.md` until he
approves Part A.** Nothing is built in the app and nothing ships.

Samples: `docs/content/walkthrough-samples/` (four lessons). Board: "Lesson Walk-Through Samples",
https://claude.ai/artifact/7hd4pLNonSKfmrbs9kyePu.

His words (Nov 25, about 4:45 to 5:00 AM Manila), in order:
1. "i found some lessons could use more detail, or a sort of 'walk you through it' type of teaching ... for example in this lesson, can you tell me which parts could use that? and inline here in chat, tell me how you would have rewritten it"
2. "close, but not as detailed as I'd like. you are allowed to have numbers in core concept"
3. "get Neon Xhigh's opinion on this, and what it would do to massively improve the lesson content for self-taught readers/users. you are also okay in the clear to add illustrations as necessary"
4. "okay! idea sounds good. i need a rewrite of sample lessons please, and show me claude design screens for your ideas with the rewritten lesson and UI or whatever additions you recommend"

---

## Part A: for Aedwon (plain words)

### What changes

Every lesson walks the reader through each rule, the way a tutor would at a table.

1. **Numbers in Core Concept.** Each rule comes with its own worked numbers right under it, not only in Examples.
2. **One move per line.** Each sign change, each multiplication and each "put it back" is its own line. Nothing is done in the head.
3. **Say why.** A rule that can feel like magic gets a short reason behind a "Why?" button.
4. **Right next to wrong.** Where a learner usually slips, the lesson shows the right line and the wrong line side by side, and says what went wrong.
5. **Try it.** Each rule ends with a one-question Quick Check. The answer stays hidden until the reader taps.
6. **Check the answer.** Each worked example ends with a "Check" line: a second way to get the answer, or the wrong answer a common slip gives.
7. **Long examples go one step at a time.** An example with four or more steps shows one step per tap ("Next step"), with "Show all steps" beside it.
8. **The last example's last step is left for the reader**, revealed on tap.
9. **Pictures where they explain.** A number line, a bar, or a marked-up sentence where it shows the idea better than words. No decoration.
10. **Grammar and other non-math lessons follow the same rules**, with sentences instead of numbers (the grammar sample shows it).

### What the samples show

- "Signed Integers and Substitution" becomes two lessons: "Signed Integer Operations" and "Substituting Negative Numbers". Its topic group goes from 3 parts to 4.
- "Discounted Prices" and "Finding Subjects and Matching Verbs" are rewritten in place.
- Every number and step was recomputed by a separate checker.

### Decisions for you

1. **Length.** The new depth makes lessons about twice as long. Today's bite-sized rule caps a math part at 550 words. The rewrites show 515 to 875 words before any tap, plus 88 to 200 words behind taps (the live lessons are 249 to 345 words, counted the same way).
   Phone screens at 390 width and default text size (844 px screens, measured on the board render; "at rest" = nothing tapped, "opened" = every answer, Why? and step shown): Signed Integers live 2.9; Signed Integer Operations 8.3 at rest, 10.6 opened; Substituting Negative Numbers 4.7 at rest, 6.9 opened; Discounted Prices live 3.0, rewrite 6.4 at rest, 7.1 opened; Finding Subjects live 2.9, rewrite 6.2 at rest, 7.0 opened.
   - a. (Recommended) Count only the words visible before any tap, and raise the cap to 900 for every subject (a suggested number, not from a source). The Next step button keeps each long example to one step on screen. Cost: one change to the size check.
   - b. Keep the caps and split further. "Signed Integer Operations" would become two lessons (adding and subtracting; multiplying and dividing), and most lessons would gain a part. Cost: more, shorter lessons; the number of extra parts across the bank is not measured yet.
2. **Quick Check style** (on the board, page "One choice for you").
   - A. (Recommended) Tap "Show answer". The reader answers in their head first. Smallest build.
   - B. Type the answer and the app checks it. Stronger practice, but needs an answer checker for numbers and words. Larger build.

Everything else on the board is either your own request, Neon's idea that you approved ("okay! idea sounds good"), or a lead decision that is labeled as such.

### How we will know it worked

- You read a sample and it feels like being walked through it.
- The independent checker finds no wrong number or false rule.
- After launch to more lessons, the in-lesson quiz accuracy for rewritten lessons is compared with before (measured, not estimated).

---

## Part B: for agents

### Standards applied

- [Instructional design](~/Documents/Projects/agent-standards/instructional-design.md): ID-WORKED (worked example, then practice, then fade: the faded last step), ID-RETRIEVE (Quick Check after each rule), ID-TRY (the answer hidden until a try), ID-EXPLAIN (Why?), ID-ERR-FIX (right and wrong pair), ID-SEGMENT (Next step; one rule per `###`), ID-SIGNAL (headings, numbered moves, "first", "then"), ID-COHERE (one model per idea; no decorative pictures; no second metaphor), ID-MEDIA and ID-SPATIAL (figure at the rule it explains), ID-PRETRAIN (terms defined before use), ID-FB-ELAB and ID-FB-CHUNK (each answer says why, in one or two sentences), ID-FB-TASK (no praise or judgment in reveals).
- [Long-form reading](~/Documents/Projects/agent-standards/long-form-reading.md): READ-REFLOW (320 px, no sideways scroll; display math narrow), READ-FIG-NEAR, READ-FIG-SIZE.
- [Web interface design](~/Documents/Projects/agent-standards/web-interface-design.md): WEB-C1 and WEB-C2 (contrast of text, icons, figures in both themes), WEB-C6 (light and dark), WEB-M1 and WEB-M9 (short reveal motion with a purpose), WEB-M6 (Reduce Motion: reveals appear at once), WEB-I10 (44 px targets), WEB-A1 (focus order, visible focus), WEB-A3 (figures carry text alternatives; figure text is real text).
- Project: `AGENTS.md` Voice and Maths in content; `docs/content/lesson-style-guide.md`; `docs/content/question-style-guide.md` (Example stems at exam level); `design/system/patterns.md` (button placement and spacing); figure style D with theme colors (launch log, Oct 25 and Oct 29).

Evidence strength (from Neon's review and the sheet): worked examples and fading, retrieval practice, self-explanation, segmenting and coherence are strong; erroneous examples moderate to strong; concreteness fading moderate to strong. Lab effect sizes come mostly from short lessons; treat the direction as reliable and the size as approximate.

### Authoring rules (to add to the lesson style guide on approval)

Core Concept:
- One `###` per rule. Under each: the rule in plain words, then at least one worked number set right under it, one move per display line, then the result.
- Concrete model first, then the rule: one model per idea (the number line for signs; a bar for percents; the marked-up sentence for grammar). Do not mix metaphors in a lesson.
- Use exact comparisons for signed numbers: "farther from $0$", "closer to $0$", "larger", "smaller". Never call a negative number "bigger".
- `:::why` after any move that a reader could accept without understanding (sign rules, subtracting a negative, exponent scope, why both discount methods agree). One to three sentences. A pattern argument is preferred to an appeal to authority.
- `:::pair` where a known slip exists. "Right:" line, "Wrong:" line, then one sentence naming the slip. At most two pairs per lesson.
- `:::check` ends each rule that has a computable answer. One question, answer of one to two sentences that gives the result and the one-line reason. At most one per `###`.
- Gloss an exam instruction word the first time it appears ("Evaluate" means find the final number answer.).

Examples:
- Stems stay at real exam wording and difficulty, with no method hints (question style guide).
- One move per numbered step. Every product, quotient and power gets its own line with the sign reason. Put results back "keeping every sign between the parts". Fix each double sign on its own line. Then left to right.
- Every example ends with `**Check:**`: a second method, a reasonableness test, or the wrong answer a named slip gives.
- The last example's final step is a `:::try` block.
- The app reveals solutions of 4 or more steps one step per tap (no markup needed).

Traps: at most 3, as today. A trap may reuse a figure or a pair from Core Concept.

Figures: `<!-- ILLUSTRATION: ... -->` placeholders as today, drawn in style D with theme colors, real text, `role="img"` and an alt text. Only where the figure shows a relation the words alone carry poorly.

Non-math subjects: the same rules with sentences: the rule, worked sentences under it, `:::why`, `:::pair` (right and wrong sentence), `:::check` (choose the form), examples in exam form ending with a Check (read the head and the verb alone, swap in a pronoun, and so on).

### New markup (proposal; the renderer does not support it yet)

```
:::check
Question text.
:::answer
Answer text.
:::

:::try
Finish the last step: ...
:::answer
Answer text.
:::

:::why
Reason text.
:::

:::pair
Right: ...
Wrong: ...
One-sentence note.
:::
```

Blocks hold ordinary lesson Markdown and inline math. They do not nest. A build spec (separate, after approval) covers the renderer, the importer, the lesson checks (structure audit learns the blocks; the AI-tell sweep ignores them), size-check changes (decision 1), and saving whether a Quick Check was opened (not graded unless option B).

### UI (board, labeled by source)

- Quick Check card: rest, tapped, revealed; "Show answer" is the card's button (wide: right end, natural width, 44 px; phone: full width inside the card), patterns.md. Source: Neon.
- Why?: small teal tertiary button under its rule; opens an inset panel in place; becomes "Hide". Source: Neon.
- Right and wrong pair: side by side on wide, stacked on phone; neutral cross for Wrong, no red fill. Source: Neon.
- Next step: inside the example card; "Show all steps" beside it; threshold 4 steps. Source: Neon idea, lead decision on threshold and Show all.
- Try the last step: the Quick Check card inside the solution. Source: Neon.
- Figures: number line with absolute value, the jump for $(-7)+4$, exponent scope (Neon); discount bar and sentence head figure (lead decision).
- Motion: reveals open with the reader's motion tokens; with Reduce Motion they appear at once (WEB-M6).

### Content notes on the samples (lead decisions)

- Signed Integers split: part 2 "Signed Integer Operations" (number line, absolute value, adding, subtracting, multiplying and dividing; Example 1 is the live example; Example 2 is new), part 3 "Substituting Negative Numbers" (parentheses, exponent scope, powers of negatives; Example 1 is the live Example 2; Example 2 is new). "Grouping and Fraction Bars" moves from part 3 to part 4. New `_id`s; the old `_id` retires. Questions tagged with the old lesson need their `keyPoint` remapped in a later build task. Live trap "Negative Bases and Exponents" is kept in part 3; two new traps are added.
- Discounted Prices: the live "Mnemonics & Memory Aids" section was not a mnemonic (it was the "percent you still pay" method), so it moved into Core Concept as Way 2. The heading "Discounts and Markups" lost "Markups" (markups are the next part). Both live examples, the speed trick and the trap are kept; one trap is added.
- Finding Subjects and Matching Verbs: all live teaching, examples, shortcut and trap are kept; added the four-move head finder, a Why?, a pair, two Quick Checks, a figure and Check lines.

### Open

- Aedwon's decisions 1 and 2 (Part A).
- After approval: add the authoring rules to `docs/content/lesson-style-guide.md`, then a build spec for the renderer and checks, then a rollout plan (which lessons first).
