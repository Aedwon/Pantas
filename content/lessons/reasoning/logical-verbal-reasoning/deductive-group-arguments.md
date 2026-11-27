---
_id: "lesson-logical-verbal-reasoning-deductive-group-arguments"
title: "Deductive Group Arguments"
summary: "Test group conclusions with circles."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
isActive: true
part: 1
partCount: 3
ordering: 1
keyPoints:
  - "Test group conclusions with circles."
  - "Distinguish valid reasoning from sound reasoning."
---

## Core Concept

### Drawing Group Statements with Circles

**Deductive reasoning** checks whether a conclusion must be true if the starting statements, called **premises**, are true. Deduction can use broad or specific statements. What matters is whether the premises force the conclusion.

A **categorical syllogism** is an argument about groups using *all*, *no*, or *some*. Picture each premise with circles:

- **All $A$ are $B$**: circle $A$ sits inside circle $B$.
- **No $A$ are $B$**: circles $A$ and $B$ sit completely apart.
- **Some $A$ are $B$**: circles $A$ and $B$ overlap with a mark in the overlap.
- **Some $A$ are not $B$**: circle $A$ has a mark sitting outside circle $B$.

<!-- FIGURE WANTED: three side-by-side circle diagrams: "All A are B" (circle A inside circle B), "No A are B" (separate circles A and B), and "Some A are B" (overlapping circles A and B with an X mark in the overlap) -->

A conclusion is forced only if every circle picture that fits the premises also fits that conclusion.

Find what follows: "All approved reports are signed. Some submitted reports are approved."

- Premise $1$: Put *Approved* inside *Signed*.
- Premise $2$: Mark the overlap of *Submitted* and *Approved*.
- Because *Approved* sits inside *Signed*, that mark sits inside *Signed*.
- Forced conclusion: **Some submitted reports are signed.** (Not *all*.)

:::pair #reverse-all-group
Right: from "All squares are rectangles," draw *Squares* inside *Rectangles*
Wrong: conclude "All rectangles are squares"
"All $A$ are $B$" only means $A$ has no members outside $B$; $B$ can still have members outside $A$ (or equal $A$, or even be empty). Test the reverse with a rectangle outside *Squares* (like a $2 \times 5$ rectangle): it satisfies the premise while breaking "all $B$ are $A$."
:::

:::check
All insects have six legs. A beetle is an insect. What must be true?
:::answer
The answer is **A beetle has six legs.** *Insects* sits inside *Six-legged animals*, and *beetle* sits inside *Insects*.
:::

### Valid vs. Sound Arguments

**Evaluate** means judge whether an argument is valid or sound from its premises.

- **Valid**: if the premises were true, the conclusion would have to be true.
- **Sound**: valid **and** every premise is true in real life.

Check validity: "All dogs are animals. All mammals are animals. Therefore, all dogs are mammals."

- Premise $1$: Draw *Dogs* inside *Animals*.
- Premise $2$: Draw *Mammals* inside *Animals*.
- Check: both circles sit inside *Animals*, so the premises do not force *Dogs* inside *Mammals*.
- Verdict: **invalid**, even though "all dogs are mammals" is true in real life.

:::why
Why test validity before real-world truth? An invalid link can never be sound, even with true sentences. Checking the link first stops familiar facts from hiding bad logic.
:::

:::pair #true-conclusion-valid
Right: "All dogs are animals; all mammals are animals; therefore all dogs are mammals" is **invalid, true conclusion**
Wrong: call it **valid, true conclusion** because dogs really are mammals
A true fact can still come from bad logic. Check whether the premises force the conclusion, not whether the conclusion is true on its own.
:::

:::pair #valid-not-sound
Right: "All birds can fly; a penguin is a bird; therefore a penguin can fly" is **valid, unsound**
Wrong: call it **valid, sound**, or **invalid, unsound** because a premise is false
Validity checks only the link from premises to conclusion. Soundness checks both that link and whether every premise is true.
:::

:::check
Evaluate: "Some students play chess. Some chess players are teachers. Therefore, some students are teachers." Assume both premises are true. Is it valid? Is it sound?
:::answer
The answer is **invalid, so unsound**. The two overlaps can sit apart: the chess players who are students need not be the ones who are teachers. A sound argument must be valid first.
:::

## Examples

### #1: Valid and Sound Argument

All mammals are warm-blooded. A whale is a mammal. Therefore, a whale is warm-blooded. Evaluate whether the argument is valid and sound.

<!-- ILLUSTRATION: nested circles with Mammals inside Warm-blooded, and a point labeled whale inside Mammals -->

**Solution:**

1. Premise $1$: draw *Mammals* inside *Warm-blooded*.
2. Premise $2$: place *whale* inside *Mammals*.
3. Because *Mammals* sits inside *Warm-blooded*, *whale* sits inside *Warm-blooded*. The argument is **valid**.
4. Both premises are true in real life, so the argument is **sound**.

**Check:** No picture can put *whale* inside *Mammals* and outside *Warm-blooded* without breaking Premise $1$ (valid), and in real life every mammal is warm-blooded and a whale is a mammal (sound).

### #2: Valid but Unsound Argument

All birds can fly. A penguin is a bird. Therefore, a penguin can fly. Is this syllogism valid? Is it sound?

<!-- ILLUSTRATION: a circle labeled Birds inside a larger circle labeled Can fly as the first premise assumes, with a point labeled penguin inside Birds -->

**Solution:**

1. Assume Premise $1$ is true: draw *Birds* inside *Can fly*.
2. Assume Premise $2$ is true: place *penguin* inside *Birds*.
3. That picture forces *penguin* inside *Can fly*, so the form is **valid**.
4. The first premise ("All birds can fly") is false in real life.
5. A false premise makes the argument **unsound**.

**Check:** Validity tests the link (yes); soundness adds truth of every premise (no).

### #3: "Some" and "All" Together

All licensed drivers have passed a driving test. Some permit holders have not passed that test. What must follow?

**Solution:**

1. Premise $1$: draw *Licensed drivers* inside *Passed the test*.
2. Premise $2$: place a mark for those permit holders outside *Passed the test*.

:::try
Finish the last step: where does that mark sit relative to *Licensed drivers*, and what must follow?
:::answer
The answer is **Some permit holders are not licensed drivers.** Since *Licensed drivers* sits inside *Passed the test*, anything outside *Passed the test* sits outside *Licensed drivers*.

**Check:** The marked permit holder sits outside *Passed the test*, which keeps it outside *Licensed drivers* (inside *Passed the test*). Because the premise names only *some* permit holders, you cannot conclude that *no* permit holders are licensed.
:::

## Speed Tricks & Shortcuts

**Test with a counter-picture.** Draw circles for *all*, *no*, and *some*. If any picture obeys every premise yet breaks the conclusion, the argument is invalid.

## Traps to Watch For

:::checklist
- "All $A$ are $B$": circle $A$ sits inside $B$; never reverse it to "all $B$ are $A$." {#reverse-all-group}
- True conclusion on an exam question: verify the premises force it before calling it valid. {#true-conclusion-valid}
- False premise in a neat chain: the form can still be valid, even though it is unsound. {#valid-not-sound}
:::
