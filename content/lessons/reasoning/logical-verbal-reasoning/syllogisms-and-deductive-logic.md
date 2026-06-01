---
_id: "lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic"
title: "Syllogisms and Deductive Logic"
summary: "Learn how to evaluate syllogisms and use deductive reasoning to determine whether a conclusion must be true."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
estimatedMinutes: 11
isActive: true
---
## Core Concept

**Deductive reasoning** starts with general statements assumed to be TRUE, and reaches a specific conclusion that MUST also be true if the starting statements are true. Unlike an inference (which is a reasonable guess), a valid deductive conclusion is GUARANTEED true, given true premises and correct logical structure.

A **syllogism** is a specific deductive argument form with two statements (**premises**) and a **conclusion**:

- **Major premise**: a general statement. "All birds have feathers."
- **Minor premise**: a more specific statement connecting to the major premise. "A sparrow is a bird."
- **Conclusion**: what must logically follow. "Therefore, a sparrow has feathers."

A syllogism is **valid** when the conclusion CORRECTLY follows from the premises, based purely on LOGICAL STRUCTURE, regardless of whether the premises happen to be true in the real world. A syllogism is **sound** when it is BOTH valid AND its premises are actually true.

<!-- ILLUSTRATION: two overlapping circles diagram (a simple Venn-style illustration) showing "birds" as a larger circle and "sparrows" as a smaller circle fully contained inside it, illustrating how "all sparrows are birds" logically guarantees sparrows share bird properties -->

Two classic INVALID patterns to watch for:

- **Affirming the consequent**: "If it rains, the ground gets wet. The ground is wet. Therefore, it rained." This is INVALID — the ground could be wet for many other reasons (a sprinkler, a spilled drink), so the conclusion does not necessarily follow.
- **Denying the antecedent**: "If it rains, the ground gets wet. It did not rain. Therefore, the ground is not wet." Also INVALID — the ground could still be wet from another cause.

The only guaranteed-valid direct pattern is: "If A, then B. A is true. Therefore, B is true" (called *modus ponens*), or its logical twin: "If A, then B. B is false. Therefore, A is false" (called *modus tollens*).

## Examples

### #1: Evaluating a Valid Syllogism

Evaluate: "All mammals are warm-blooded. A whale is a mammal. Therefore, a whale is warm-blooded." Is this valid?

**Solution:**
1. The major premise states all mammals share a trait (warm-blooded).
2. The minor premise places "whale" inside the category "mammal."
3. Since whales are mammals, and all mammals are warm-blooded, the conclusion that whales are warm-blooded MUST follow. This is a VALID syllogism.

### #2: Spotting an Invalid Syllogism (Affirming the Consequent)

Evaluate: "If a student studies hard, they will pass the exam. Maria passed the exam. Therefore, Maria studied hard." Is this valid?

**Solution:**
1. The premise only guarantees that studying hard LEADS TO passing; it does not say passing can ONLY happen by studying hard.
2. Maria could have passed for other reasons (an easy exam, prior knowledge, luck).
3. This conclusion does NOT necessarily follow — it is INVALID (this is the "affirming the consequent" pattern).

### #3: Using Modus Tollens Correctly

Evaluate: "If the alarm is working, it will ring during a fire. The alarm did not ring during the fire. Therefore, the alarm was not working." Is this valid?

**Solution:**
1. This matches the pattern "If A, then B. B is false. Therefore, A is false" — modus tollens.
2. Since a working alarm GUARANTEES ringing during a fire, and it did NOT ring, the only logical explanation (given the premise) is that the alarm was not working.
3. This is a VALID syllogism.

### #4: A Syllogism with a False (but Logically Valid) Premise

Evaluate: "All birds can fly. A penguin is a bird. Therefore, a penguin can fly." Is this syllogism valid? Is it sound?

**Solution:**
1. Structurally, this follows the exact same valid pattern as Example 1 (all X have trait Y, Z is an X, therefore Z has trait Y).
2. The LOGICAL STRUCTURE is VALID.
3. However, the major premise ("All birds can fly") is actually FALSE in the real world (penguins cannot fly), so this syllogism is NOT sound, even though it is logically valid.
4. This distinguishes VALIDITY (structure) from SOUNDNESS (structure AND true premises).

## Speed Tricks & Shortcuts

**Check the STRUCTURE first, separately from whether you believe the premises are true.** A syllogism can have a perfectly valid logical form even with a false premise (making it valid but not sound) — exam questions often specifically test this distinction.

**Watch for the two classic invalid patterns by name.** "Affirming the consequent" and "denying the antecedent" are the most commonly tested logical fallacies; memorizing their pattern shapes helps you spot them instantly.

**Draw a simple circle diagram for category-based syllogisms** ("all A are B," "some A are B") to visually confirm whether the conclusion logically must follow.

## Traps to Watch For

### #1: Assuming a True Conclusion Means the Argument Was Valid

> An argument's VALIDITY depends on its LOGICAL STRUCTURE, not on whether the conclusion happens to be true in reality.

"Maria passed the exam" being true does not automatically make "therefore she studied hard" a VALID deduction — the argument's structure itself (affirming the consequent) is flawed, regardless of whether Maria actually did study.

### #2: Confusing "If A, then B" with "If B, then A"

> "If it rains, the ground gets wet" does NOT mean "if the ground is wet, it rained." These are different statements, and assuming they are interchangeable causes the affirming-the-consequent error.

Only the ORIGINAL direction of the conditional statement (A leads to B) is guaranteed; its reverse is not automatically true unless separately established.

### #3: Confusing Validity with Soundness

> A VALID argument has correct logical structure. A SOUND argument is valid AND has premises that are actually TRUE.

The "all birds can fly, therefore penguins can fly" example is logically valid in structure, but not sound, since its major premise is factually false. Exam questions may ask specifically about one or the other — read carefully which one is being asked.
