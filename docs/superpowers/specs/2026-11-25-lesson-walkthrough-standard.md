# Lesson walk-through standard

Date: November 25, 2026. Lane: lesson walk-through lead (E-156, E-157). Policy read: `Aedwon/Pantas` main 54b550f48.
Status: **spec, waiting for Aedwon's approval of Part A. Parked: he asked to release with current content first.**
Nothing is built in the app and nothing ships. The rules below are not in `docs/content/lesson-style-guide.md`
until he approves Part A.

Samples: `docs/content/walkthrough-samples/` (four lessons, current with this spec). Board: "Lesson Walk-Through
Samples", https://claude.ai/artifact/7hd4pLNonSKfmrbs9kyePu (private until he shares it; see "Board status" for what
is out of date).

His words (Nov 25, Manila time), in order:
1. "i found some lessons could use more detail, or a sort of 'walk you through it' type of teaching ... for example in this lesson, can you tell me which parts could use that? and inline here in chat, tell me how you would have rewritten it"
2. "close, but not as detailed as I'd like. you are allowed to have numbers in core concept"
3. "get Neon Xhigh's opinion on this, and what it would do to massively improve the lesson content for self-taught readers/users. you are also okay in the clear to add illustrations as necessary"
4. "okay! idea sounds good. i need a rewrite of sample lessons please, and show me claude design screens for your ideas with the rewritten lesson and UI or whatever additions you recommend"
5. On the right-and-wrong pair: "what's the rationale of this? just to show what's right and wrong right?", then "so, traps to watch for which is at the end of the lesson"
6. On the manager's recommendation to move traps inline: "okay your reco sounds good. what does neon think of this?"
7. After Neon's refinement: "cool, sounds very good to me. let's spec this first. i don't think i have the proper usage to do these changes. let's prioritize release with current content first"

---

## Part A: for Aedwon (plain words)

### What changes

Every lesson walks the reader through each rule, the way a tutor would at a table.

1. **Numbers in Core Concept.** Each rule has its own worked numbers right under it, not only in Examples.
2. **One move per line.** Each sign change, each multiplication and each "put it back" is its own line.
3. **Say why.** A rule that can feel like magic gets a short reason behind a "Why?" button. "Why?" is only for this extra reasoning.
4. **Traps sit at their step.** Where learners really slip, the lesson shows the right line first and the wrong line under it, quieter, and says what went wrong. These pairs are always open. Each lesson has 2 or 3, and only for mistakes that match real wrong choices in the quiz bank.
5. **The end section is a checklist.** "Traps to Watch For" becomes 2 or 3 short lines. Each line gives a cue and the right move, for example "No parentheses on −3²: square 3 first, then keep the minus (−9)." Tapping a line goes back to its step.
6. **Try it.** Each rule ends with a one-question Quick Check. The answer stays hidden until the reader taps.
7. **Check the answer.** Each worked example ends with a "Check" line: a second way to the answer, or a sense check.
8. **Long examples go one step at a time.** An example with four or more steps shows one step per tap ("Next step"), with "Show all steps" beside it.
9. **The last example's last step is left for the reader**, revealed on tap.
10. **Pictures where they explain.** A number line, a bar, or a marked-up sentence where it shows the idea better than words. No decoration.
11. **Long lessons split.** A lesson that becomes too long at this depth splits into smaller lessons, as "Signed Integers and Substitution" does.
12. **Grammar and other non-math lessons follow the same rules**, with sentences instead of numbers.

### What the samples show

- "Signed Integers and Substitution" becomes "Signed Integer Operations" and "Substituting Negative Numbers".
- "Discounted Prices" and "Finding Subjects and Matching Verbs" are rewritten in place.
- Each sample has 2 traps at their steps, and each one matches a real wrong choice in the quiz.
- A separate checker recomputed every number in the first rewrite.

### Picks for you

1. **Length.** The rewrites are about twice as long. Today's bite-sized rule caps a math part at 550 words.
   - The rewrites show 505 to 857 words before any tap. The live lessons have 249 to 345.
   - On a phone (390 wide, default text), a live lesson is about 3 screens. A rewrite is 4.7 to 8.3 screens before any tap, and 6.9 to 10.6 with everything opened. These screen counts were measured before the traps moved inline, which changed lengths by a few lines.
   - **a. (Recommended)** Count only the words shown before any tap, and raise the cap to 900. Next step keeps long examples short on screen. Cost: one change to the size check.
   - **b.** Keep the caps and split further. Most lessons would gain a part. Cost: more, shorter lessons.
2. **Quick Check style.**
   - **A. (Recommended)** Tap "Show answer". The reader answers in their head first. Smallest build.
   - **B.** Type the answer and the app checks it. Stronger practice, but needs an answer checker for numbers and words. Larger build.

### How we will know it worked

- You read a sample and it feels like being walked through it.
- An independent checker finds no wrong number or false rule in any rewritten lesson.
- After rollout, in-lesson quiz accuracy for rewritten lessons is compared with before, from real use.

### Revision, November 27, 2026 (approved: "okay go ahead with your reco")

The rewrite of every CSE lesson looped through rewrites and re-audits (process-improvement entry "Walk-through lessons loop through rewrites and re-audits", Nov 27). Most audit findings sat in the practice parts this format adds, from Gemini and Claude writers alike. This revision replaces "every lesson" (What changes, first line, and rule 12).

1. **Scope.** The format applies only where students solve problems in steps: Math for every exam (CSE, college entrance tests, PSHS-NCE); then physics and chemistry calculation lessons; then step-based reasoning (series, analogies, logic, clerical). Spatial, abstract and mechanical reasoning wait until figures can be drawn. Grammar, vocabulary, language application, reading comprehension, General Information, and the fact-based parts of biology and earth science keep their current lessons. Their walk-through drafts stay on their branches, unused.
2. **Slimmer format.** Rule 7 (a "Check" line on every worked example) is dropped. Rule 6 becomes one Quick Check per lesson, not one per rule. Rules 1 to 5 and 8 to 11 stay.
3. **Practice in math.** A Quick Check or try may be the same kind of problem as the example with new numbers or a new context. This is the worked-example-then-practice pairing with strong evidence. It still may not print its answer above it or leave only one possible choice.
4. **Order and caps.** A pilot of about 10 CSE Math lessons comes first, with automatic checks for the recurring mistakes built before writing. Each batch gets at most 2 Codex full reads. Blockers (a wrong answer, a false rule, an answer that can be copied) must be 0. Majors are fixed once after the last read and checked by the lead, with no further read for Majors alone. If the pilot does not pass within 2 reads, work stops and the manager brings him options. Otherwise the rest of Math follows, then physics and chemistry, then step-based reasoning.

---

## Part B: for agents

### Standards applied

- [Instructional design](~/Documents/Projects/agent-standards/instructional-design.md): ID-WORKED (worked example, practice, fade: the faded last step), ID-RETRIEVE (Quick Check after each rule), ID-TRY (answer hidden until a try), ID-EXPLAIN (Why?), ID-ERR-FIX (right and wrong pair at the step), ID-SEGMENT (Next step; one rule per `###`; lesson splits), ID-SIGNAL (headings, numbered moves), ID-COHERE (one model per idea; no decorative pictures), ID-MEDIA and ID-SPATIAL (figure at its rule), ID-PRETRAIN (terms before use), ID-FB-ELAB and ID-FB-CHUNK (answers say why, briefly), ID-FB-TASK (no praise or judgment).
- [Long-form reading](~/Documents/Projects/agent-standards/long-form-reading.md): READ-REFLOW, READ-FIG-NEAR, READ-FIG-SIZE.
- [Web interface design](~/Documents/Projects/agent-standards/web-interface-design.md): WEB-C1, WEB-C2, WEB-C6, WEB-M1, WEB-M6, WEB-M9, WEB-I10, WEB-A1, WEB-A3.
- Project: `AGENTS.md` Voice and Maths in content; `docs/content/lesson-style-guide.md`; `docs/content/question-style-guide.md`; `docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md` (size rules, part labels); `design/system/patterns.md`; figure style D with theme colors (launch log, Oct 25 and Oct 29).

Evidence strength (Neon's review and the sheet): worked examples and fading, retrieval practice, self-explanation, segmenting and coherence are strong; erroneous examples moderate to strong; concreteness fading moderate to strong. Effect sizes come mostly from short lab lessons: the direction is reliable, the size approximate.

### Neon's ranked ideas and where each landed

1. Quick Check after each rule, revealed on tap, and fading of the last example's final step: `:::check`, `:::try`.
2. A "Why?" tap at tricky moves, plus right and wrong steps side by side: `:::why`; the pair became the inline trap (below).
3. One concrete model, the number line, faded to symbol rules; the four-case sign table becomes two lines: Core Concept rules below.
4. Phone chunking, one move per step, a "Next step" tap on long examples: Examples rules below.
5. Three illustrations: number line with absolute value, the jump for $(-7)+4$, exponent scope in $(-3)^2$ versus $-3^2$: in the samples. Lead added two: the discount bar and the sentence-head figure.
6. Split "Signed Integers and Substitution" into two lessons: done in the samples.
Neon's slip, fixed: write "farther from $0$", never "bigger", for a negative number.

Round 2 (Neon's refinement of the manager's recommendation, approved by him): traps move inline as pairs, RIGHT first and WRONG quieter, open by default, 2 or 3 per lesson backed by real wrong quiz choices; the end section becomes a checklist of cue plus right move that links back.

### Authoring rules (added to the lesson style guide on approval)

Core Concept:
- One `###` per rule. Under each: the rule in plain words, at least one worked number set right under it, one move per display line, then the result.
- Concrete model first, then the rule: one model per idea (number line for signs, a bar for percents, the marked-up sentence for grammar). One metaphor per lesson at most.
- Signed numbers: "farther from $0$", "closer to $0$", "larger", "smaller". Never call a negative number "bigger".
- `:::why` for extra reasoning only (why a rule works), one to three sentences, a pattern argument preferred. Never put a pair behind Why?.
- `:::check` ends each rule that has a computable answer. One question. The answer starts with the result ("The answer is $-6$.") and gives a one-line reason. At most one per `###`.
- Gloss an exam instruction word the first time it appears ("Evaluate" means find the final number answer.).

Traps at their step:
- `:::pair #slug` sits at the step where the slip happens, in Core Concept or between Example steps. Lines: "Right:", "Wrong:", then one or two sentences naming the slip. Always open.
- 2 or 3 pairs per lesson. Each must match a real wrong choice in the quiz bank for that lesson; record the question id and wrong choice in the audit record. A slip with no matching wrong choice gets no pair, only a checklist line if it matters.
- Every former trap moves to its step as a pair or a checklist line. None is dropped.
- "Traps to Watch For" keeps its title and holds only a `:::checklist` of 2 or 3 lines. Each line is "Cue: right move", with the right result where there is one, ending `{#slug}` for the pair id or the `###` heading slug (lowercase, words joined by hyphens). Never the wrong form alone.

Examples:
- Stems at real exam wording and difficulty, no method hints.
- One move per numbered step. Every product, quotient and power on its own line with the sign reason. Put results back "keeping every sign between the parts". Fix each double sign on its own line. Then left to right.
- Every example ends with `**Check:**`: a second method or a sense check. In a `:::try` example the Check goes inside the hidden answer, so nothing below the closed card gives the answer away.
- The last example's final step is a `:::try` block.
- The app reveals solutions of 4 or more steps one step per tap (no markup).

Length and splits: split by idea when a lesson passes the cap (decision 1). Content is moved, not cut. Splits get new `_id`s and part numbers; questions linked to the old lesson get their `lesson` and `keyPoint` remapped in the build.

Figures: `<!-- ILLUSTRATION: ... -->` at the exact spot, drawn in style D with theme colors, real text, `role="img"` and alt text, only where the figure shows a relation words carry poorly.

Non-math subjects: the same rules with sentences (worked sentences under each rule, pairs of right and wrong sentences, Quick Checks that choose a form, Check lines such as "read the head and the verb alone").

Every number and step in a rewritten lesson is recomputed by an independent worker before the lesson is accepted.

### Markup (proposal; the renderer does not support it yet)

```
:::check
Question text.
:::answer
The answer is ... . Reason.
:::

:::try
Finish the last step: ...
:::answer
The answer is ... . Reason.

**Check:** ...
:::

:::why
Reason text.
:::

:::pair #slug
Right: ...
Wrong: ...
One- or two-sentence note.
:::

:::checklist
- Cue: right move (result). {#slug}
:::
```

Blocks hold ordinary lesson Markdown and inline math. Only `:::try` and `:::check` contain `:::answer`; nothing else nests.

### UI

- Quick Check card: rest, tapped, revealed; "Show answer" is the card's button (wide: right end, natural width, 44 px; phone: full width inside the card). The revealed answer's first sentence is bold. Source: Neon.
- Why?: small teal tertiary button under its rule; opens an inset panel (the Solution inset look, no left rule); becomes "Hide". Source: Neon.
- Right and wrong pair: open. RIGHT first and stronger (teal check, card). WRONG under it and quieter (no card or border, secondary text color, one size smaller, neutral cross, never red). Note under both. Source: his approval of the manager's recommendation, refined by Neon.
- Trap checklist: rows at least 44 px, cue semibold, right move after it, a small up-arrow at the right end. A tap scrolls to the pair or step; the pair gets a teal tint that fades over 1.2 s. Reduce Motion: instant jump and a static teal outline. If the target sits in a hidden Next-step group, the tap opens all steps first. Source: same.
- Next step: inside the example card, "Show all steps" beside it, threshold 4 steps. Source: Neon idea; threshold and Show all are lead decisions.
- Try the last step: the Quick Check card inside the solution. Source: Neon.
- Reader meta shows the part ("Part 2 of 4"), no minutes (figure rule and the bite-sized label ruling).
- Motion: reveals open over 240 ms height and 180 ms fade with the house curve; Reduce Motion shows the end state at once (WEB-M6). Lead decision.

### Content notes on the samples (lead decisions)

- Signed Integers split: part 2 "Signed Integer Operations" (number line, absolute value, adding, subtracting, multiplying and dividing; live Example 1 plus a new Example 2), part 3 "Substituting Negative Numbers" (parentheses, exponent scope, powers of negatives; live Example 2 plus a new Example 2). "Grouping and Fraction Bars" moves from part 3 to part 4. The old `_id` retires.
- Discounted Prices: the live "Mnemonics & Memory Aids" section was a method, not a mnemonic, so it became Way 2 in Core Concept. "Discounts and Markups" lost "Markups" (the next part covers markups).
- Finding Subjects and Matching Verbs: all live teaching kept; added the four-move head finder, the do/does forms, an exam-style third example, and the some/most/half exception.

Quiz evidence for each pair (prod content `content/cet-bite-r1`, questions linked to the live lessons; wrong choices recomputed by the lead):
- Signed Integer Operations: subtracting a negative, order-of-operations 0021, wrong $-25$; quotient sign, 0021, wrong $13$.
- Substituting Negative Numbers: exponent scope, 0003 (wrong $25$), 0013 (wrong $3$), 0008 (wrong $19$); minus before a negative product, 0008, wrong $-1$.
- Discounted Prices: successive discounts added, business-math 0009 (wrong Php $4,250$), 0019 (wrong $30\%$); answering with the discount, 0004 (wrong Php $120$), 0009 (wrong Php $725$).
- Finding Subjects: missing -s, subject-verb-agreement 0001 (wrong "Bark"); nearest noun, 0003 (wrong "Are"), 0004 (wrong "Is").
- "Choosing the sign by size" has no matching wrong choice: a checklist line that returns to its rule, not a pair.

Verification: the first rewrite was recomputed by an independent Sonnet checker (all numbers matched; wording findings fixed). The round-2 changes (inline pairs, checklists, quiz evidence) were recomputed by the lead only; an independent recompute is still due before acceptance.

### Board status (as published, version 5)

The board shows the round-1 layout and was rendered, reviewed and fixed at that point. It does not show round 2:
- The 16 rewrite lesson frames (Signed A and B, Discounted Prices, Finding Subjects; phone and wide; light and dark) still show one pair per lesson with Wrong in its own card, and the old numbered "Traps to Watch For" boxes at the end.
- The 4 "Right and wrong pair" state frames on the "New parts" page show the old pair look.
- No frame shows the trap checklist or its tap-back states.
- Live frames show the live lessons as they are, which is intended.
Round-2 board files were generated in the lead's scratchpad but never rendered, reviewed or published; the parts generator still fails on a heading lookup. Treat them as disposable; rebuild from the samples when the lane resumes.

### Open

- His picks 1 and 2 (Part A), and approval of Part A.
- On resume: independent recompute of round-2 content; board round 2 (render, fresh reviewer, publish); then add the authoring rules to the lesson style guide; a build spec for the renderer, importer and checks (structure audit learns the blocks, size check per pick 1, a check that each pair names a quiz wrong choice); then a rollout plan.
