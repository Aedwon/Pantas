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

**Deductive reasoning** checks whether a conclusion must be true if the starting statements, called **premises**, are true.

A **categorical syllogism** is an argument about groups, using *all*, *no*, *some*, or *some ... are not*. This lesson tests such arguments with circles:

- **All $A$ are $B$**: circle $A$ sits inside circle $B$.
- **No $A$ are $B$**: circles $A$ and $B$ sit completely apart.
- **Some $A$ are $B$**: circles $A$ and $B$ overlap with a mark in the overlap. It says nothing about the rest of $A$.
- **Some $A$ are not $B$**: circle $A$ has a mark sitting outside circle $B$.

<!-- ILLUSTRATION: three circle diagrams side by side: "All A are B" (circle A inside circle B), "No A are B" (separate circles A and B), and "Some A are B" (overlapping circles A and B with an X mark in the overlap) -->

A conclusion is forced only if every circle picture that fits the premises also fits that conclusion.

Find what follows from these premises: "All approved reports are signed. Some submitted reports are approved."

- Premise $1$: Put *Approved* inside *Signed*.
- Premise $2$: Mark the overlap of *Submitted* and *Approved*.
- Because *Approved* sits inside *Signed*, that mark sits inside *Signed*.
- Forced conclusion: **Some submitted reports are signed.** The premises do not tell us whether *all* submitted reports are signed.

:::pair #reverse-all-group
Right: from "All squares are rectangles," draw *Squares* inside *Rectangles*
Wrong: conclude "All rectangles are squares"
"All $A$ are $B$" means $A$ has no members outside $B$, but $B$ can have members outside $A$. A $2 \times 5$ rectangle fits the premise and breaks "all rectangles are squares."
:::

:::check
No reptiles have fur. All snakes are reptiles. What must be true?
:::answer
The answer is **No snakes have fur.** *Snakes* sits inside *Reptiles*, and *Reptiles* sits completely apart from *Fur*.
:::

### Valid vs. Sound Arguments

**Evaluate** means judge whether an argument is valid or sound from its premises.

- **Valid**: the conclusion must be true whenever the premises are true.
- **Sound**: valid **and** every premise is true in real life.

Decide whether this argument is valid: "All dogs are animals. All mammals are animals. Therefore, all dogs are mammals."

- Premise $1$: Draw *Dogs* inside *Animals*.
- Premise $2$: Draw *Mammals* inside *Animals*.
- Counter-picture: put *Dogs* and *Mammals* side by side inside *Animals*. Both premises still hold, but *Dogs* is not inside *Mammals*, so the premises do not force the conclusion.
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
Right: "All fruits are sweet; a lemon is a fruit; therefore a lemon is sweet" is **valid, unsound**
Wrong: call it **valid, sound** by ignoring the false premise, or **invalid, unsound** by letting the false premise change the validity verdict
Validity checks only the link from premises to conclusion. Soundness checks both that link and whether every premise is true.
:::

## Examples

### #1: Valid and Sound Argument

Decide whether this argument is valid and sound: "All mammals are warm-blooded. A whale is a mammal. Therefore, a whale is warm-blooded."

<!-- ILLUSTRATION: nested circles with Mammals inside Warm-blooded, and a point labeled whale inside Mammals -->

**Solution:**

1. Premise $1$: draw *Mammals* inside *Warm-blooded*.
2. Premise $2$: place *whale* inside *Mammals*.
3. Because *Mammals* sits inside *Warm-blooded*, *whale* sits inside *Warm-blooded*. The argument is **valid**.
4. Both premises are true in real life, so the argument is **sound**.

### #2: Valid but Unsound Argument

Decide whether this argument is valid and sound: "All birds can fly. A penguin is a bird. Therefore, a penguin can fly."

<!-- ILLUSTRATION: a circle labeled Birds inside a larger circle labeled Can fly as the first premise assumes, with a point labeled penguin inside Birds -->

**Solution:**

1. Assume Premise $1$ is true: draw *Birds* inside *Can fly*.
2. Assume Premise $2$ is true: place *penguin* inside *Birds*.
3. That picture forces *penguin* inside *Can fly*, so the form is **valid**.
4. The first premise ("All birds can fly") is false in real life.
5. A false premise makes the argument **unsound**.

### #3: "Some" and "All" Together

Find what must follow from these premises: "All licensed drivers have passed a driving test. Some permit holders have not passed that test."

**Solution:**

1. Premise $1$: draw *Licensed drivers* inside *Passed the test*.
2. Premise $2$: place a mark for those permit holders outside *Passed the test*.

:::try
Finish the last step: what must follow about those permit holders and *Licensed drivers*?
:::answer
The answer is **Some permit holders are not licensed drivers.** Anything outside *Passed the test* sits outside *Licensed drivers*. The premises do not say that *no* permit holders are licensed.
:::

## Speed Tricks & Shortcuts

**Test with a counter-picture.** Draw circles for *all*, *no*, and *some*. If any picture obeys every premise yet breaks the conclusion, the argument is invalid.

## Traps to Watch For

:::checklist
- "All $A$ are $B$": draw $A$ inside $B$, never "all $B$ are $A$." {#reverse-all-group}
- True conclusion: test whether the premises force it before calling it valid. {#true-conclusion-valid}
- False premise in a valid form: valid but unsound. {#valid-not-sound}
:::
