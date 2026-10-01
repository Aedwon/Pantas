# Language Proficiency — Question Blueprint

> **Explanations and wrong-choice notes follow `../question-style-guide.md` (1 October 2026).**
> The explanation gives only why the correct answer is correct, with the solution when there is
> working. Every wrong choice carries a `rationale` note: the mistake, why it looks right, one
> check. The examples below omit the notes for brevity and predate this rule; where an example
> explanation discusses a wrong choice or names a choice by position, the style guide wins.


Applies to standalone Grammar & Structure, Vocabulary, and Language
Application items only — no passages, no cloze. Follow
[question-style-guide.md](../question-style-guide.md) for format and voice.
Cloze/passage-based items are out of scope for this pipeline (deferred with
Reading Comprehension).

## Difficulty ramp

single-rule → competing-rules → idiomatic/exception. Start with a question
testing one clear rule; end with one where two plausible rules compete or an
exception applies (the kind that trips up strong students).

## Grammar & Structure archetypes

### `error-identification`
Pick the part of a sentence that contains an error.

```yaml
stem: |
  Identify the part of the sentence that contains an error.
  "Neither of the students (A) have finished (B) their (C) assignment (D)."
choices:
  - text: A
  - text: B
    correct: true
  - text: C
  - text: D
explanation: |
  "Neither" is singular, so the verb must be singular too: "has finished,"
  not "have finished."
```

### `correct-usage`
Pick the sentence (or blank-fill) that uses the rule correctly.

```yaml
stem: |
  Choose the correctly punctuated sentence.
choices:
  - text: "Please bring the following: pen, paper, and a ruler."
    correct: true
  - text: "Please bring the following pen, paper, and a ruler."
  - text: "Please bring the following; pen, paper, and a ruler."
  - text: "Please bring the following pen paper and a ruler."
explanation: |
  A colon introduces a list after a complete sentence. Only the first
  choice punctuates the list correctly.
```

### `subject-verb-agreement`
Pick the verb form that agrees with its subject.

```yaml
stem: |
  Each of the boxes ___ carefully labeled.
choices:
  - text: is
    correct: true
  - text: are
  - text: were
  - text: have been
explanation: |
  "Each" is singular, even though it is followed by "of the boxes." The
  verb must match "each," so it takes "is."
```

### `tense`
Pick the verb tense that correctly fits the time clues in the sentence.

```yaml
stem: |
  By the time the rain started, we ___ the tent.
choices:
  - text: had already set up
    correct: true
  - text: set up
  - text: are setting up
  - text: will set up
explanation: |
  One past action (setting up the tent) finished before another past
  action (the rain starting). That needs the past perfect: "had already
  set up."
```

### `punctuation`
Pick the correctly punctuated version of a sentence.

```yaml
stem: |
  Choose the correctly punctuated sentence.
choices:
  - text: "Wait she said I forgot my bag."
  - text: "\"Wait,\" she said, \"I forgot my bag.\""
    correct: true
  - text: "\"Wait she said, I forgot my bag\"."
  - text: "Wait, she said. I forgot my bag."
explanation: |
  Quoted speech needs quotation marks around exactly what was said, with a
  comma separating it from "she said."
```

### `pronoun-reference`
Pick the sentence with clear, correctly-matched pronoun reference.

```yaml
stem: |
  Choose the sentence with the clearest pronoun use.
choices:
  - text: "Ana told her sister that she had won the contest."
  - text: "Ana told her sister that Ana had won the contest."
    correct: true
  - text: "Ana told her sister that they had won the contest."
  - text: "Ana told her sister she she had won the contest."
explanation: |
  In the first choice, "she" could mean Ana or her sister — it is unclear.
  Naming "Ana" directly removes the confusion.
```

### `parts-of-speech-identification`
Identify the part of speech of a specific (usually underlined/bolded) word
as it functions in the sentence.

```yaml
stem: |
  In the sentence "The runner sprinted quickly toward the finish line,"
  what part of speech is the word QUICKLY?
choices:
  - text: Adverb
    correct: true
  - text: Adjective
  - text: Preposition
  - text: Noun
explanation: |
  Quickly describes how the runner sprinted — it modifies a verb (sprinted).
  A word that modifies a verb is an adverb.
```

### `phrase-clause-identification`
Classify an underlined group of words as a phrase, an independent clause, or
a dependent clause.

```yaml
stem: |
  In the sentence "Because it was raining, we stayed inside," what kind of
  group of words is "Because it was raining"?
choices:
  - text: Dependent clause
    correct: true
  - text: Independent clause
  - text: Prepositional phrase
  - text: Noun phrase
explanation: |
  "Because it was raining" has a subject (it) and a verb (was raining), but
  it cannot stand alone as a complete sentence — that makes it a dependent
  clause.
```

### `sentence-structure-classification`
Classify a sentence as simple, compound, complex, or compound-complex.

```yaml
stem: |
  What type of sentence is "Marco studied all night, and he still felt
  nervous because the exam covered so much material"?
choices:
  - text: Compound-complex
    correct: true
  - text: Simple
  - text: Compound
  - text: Complex
explanation: |
  The sentence joins two independent clauses ("Marco studied all night" and
  "he still felt nervous") with "and," plus a dependent clause ("because the
  exam covered so much material"). Two independent clauses plus a dependent
  clause make it compound-complex.
```

### `modifier-placement`
Pick the sentence that correctly places a modifier (fixes a misplaced or
dangling modifier).

```yaml
stem: |
  Choose the sentence with no misplaced or dangling modifier.
choices:
  - text: "Walking to school, the rain soaked Jenna's shoes."
  - text: "Walking to school, Jenna got her shoes soaked by the rain."
    correct: true
  - text: "Jenna's shoes, walking to school, got soaked by the rain."
  - text: "The rain, walking to school, soaked Jenna's shoes."
explanation: |
  "Walking to school" describes a person, so it must sit next to the person
  doing the walking. Only the second choice puts "Jenna" right after that
  phrase.
```

### `parallelism-correction`
Pick the sentence with correct parallel structure.

```yaml
stem: |
  Choose the sentence with correct parallel structure.
choices:
  - text: "The coach told the team to run faster, to pass accurately, and to defend well."
    correct: true
  - text: "The coach told the team to run faster, passing accurately, and to defend well."
  - text: "The coach told the team running faster, to pass accurately, and defending well."
  - text: "The coach told the team to run faster, accurate passing, and defend well."
explanation: |
  A list joined by "and" should use the same grammatical form throughout.
  Only the first choice uses "to run," "to pass," and "to defend" — all
  matching infinitives.
```

### `redundancy-identification`
Pick the sentence free of redundancy or a double negative.

```yaml
stem: |
  Choose the sentence with no redundancy or double negative.
choices:
  - text: "She doesn't have any money left."
    correct: true
  - text: "She doesn't have no money left."
  - text: "She returned back home again."
  - text: "The reason why is because she was tired."
explanation: |
  "Doesn't have any" is a single, clear negative. "Doesn't have no" is a
  double negative; "returned back... again" repeats the same idea twice;
  "the reason why is because" says "reason" three different ways.
```

## Vocabulary archetypes

### `synonym`
Pick the word closest in meaning to the given word.

```yaml
stem: |
  Choose the word closest in meaning to ABUNDANT.
choices:
  - text: Plentiful
    correct: true
  - text: Scarce
  - text: Fragile
  - text: Ordinary
explanation: |
  Abundant means "existing in large amounts." Plentiful means the same
  thing. Scarce is its opposite.
```

### `antonym`
Pick the word most nearly opposite to the given word.

```yaml
stem: |
  Choose the word most opposite in meaning to CONCEAL.
choices:
  - text: Reveal
    correct: true
  - text: Hide
  - text: Cover
  - text: Protect
explanation: |
  Conceal means "to hide." Reveal means "to show" or "to make known" — the
  opposite of hiding.
```

### `word-in-context`
Pick the meaning of a word as it is used in a given sentence.

```yaml
stem: |
  "The negotiations reached a critical point." In this sentence, CRITICAL
  means
choices:
  - text: extremely important
    correct: true
  - text: full of criticism
  - text: dangerous
  - text: uncertain
explanation: |
  Here "critical" describes a decisive, important moment — not
  criticism or danger.
```

### `confusing-words`
Pick the correct word from a commonly-confused pair, in context.

```yaml
stem: |
  Choose the word that correctly completes the sentence:
  "The company's new policy will ___ everyone in the department."
choices:
  - text: affect
    correct: true
  - text: effect
  - text: affective
  - text: effective
explanation: |
  "Affect" is usually the verb meaning "to influence." "Effect" is usually
  the noun meaning "the result." This sentence needs a verb, so "affect"
  is correct.
```

### `word-analogy`
Complete a word-relationship pair (meaning-based, distinct from Reasoning's
broader `analogy` archetype by focusing on vocabulary precision).

```yaml
stem: |
  Frugal is to Wasteful as Timid is to ___.
choices:
  - text: Bold
    correct: true
  - text: Shy
  - text: Quiet
  - text: Careful
explanation: |
  Frugal and wasteful are opposites. Timid (shy, fearful) and bold
  (confident, daring) are opposites in the same way.
```

### `idiom-meaning`
Pick the correct meaning of an idiom or figure of speech (English or its
named Filipino counterpart, e.g. sawikain) as used in a sentence.

```yaml
stem: |
  "After losing the championship game, the team decided to bite the bullet
  and start training twice as hard." What does BITE THE BULLET mean here?
choices:
  - text: To accept something difficult and get on with it
    correct: true
  - text: To complain loudly about a problem
  - text: To give up entirely
  - text: To celebrate a small victory
explanation: |
  "Bite the bullet" means to face something hard without complaining. The
  team accepted the loss and pushed forward with harder training.
```

### `root-word-affix-analysis`
Use knowledge of a root word, prefix, or suffix to determine an unfamiliar
word's meaning.

```yaml
stem: |
  The word "BENEVOLENT" contains the root "bene," which means "good" or
  "well." Based on this, BENEVOLENT most likely means
choices:
  - text: kind and generous
    correct: true
  - text: angry and harsh
  - text: confused and lost
  - text: quiet and shy
explanation: |
  "Bene-" means "good," and "-volent" relates to wishing or willing.
  Together they describe someone who wishes others well — kind and
  generous.
```

### `spelling-correction`
Pick the correctly spelled word, or the sentence with no spelling errors.

```yaml
stem: |
  Choose the correctly spelled word.
choices:
  - text: Definitely
    correct: true
  - text: Definately
  - text: Definitly
  - text: Deffinitely
explanation: |
  The correct spelling is "definitely" — it comes from "definite" plus
  "-ly," with no extra letters swapped in.
```

## Language Application archetypes (standalone only)

Each Language Application lesson corresponds closely to one archetype below;
vary the content domain and difficulty across a lesson's questions rather
than mixing archetypes within it.

### `error-identification` (Application level)
Same shape as Grammar's `error-identification` archetype (see above), but
draws on any grammar rule rather than one specific lesson — used for the
**Error Identification / Sentence Correction** lesson. See that archetype's
example above; vary which rule is broken (agreement, tense, punctuation,
modifiers, parallelism, etc.) across questions.

### `fill-in-the-blank`
Pick the word or phrase that correctly completes a single free-standing
sentence — used for the **Sentence Completion** lesson.

```yaml
stem: |
  Despite the heavy rain, the volunteers ___ committed to finishing the
  cleanup drive.
choices:
  - text: remained
    correct: true
  - text: remains
  - text: remaining
  - text: to remain
explanation: |
  The sentence needs a main verb that agrees with the plural subject "the
  volunteers" and fits the past context set up by "despite the heavy rain."
  "Remained" is the correct past-tense verb form.
```

### `sentence-ordering`
Given 4–5 sentences, pick the option that puts them in the most logical
order — used for the **Paragraph Organization** lesson. Keep each item
self-contained (no shared passage across questions).

```yaml
stem: |
  Choose the most logical order for these sentences.
  1. Finally, let it cool for ten minutes before serving.
  2. First, preheat the oven to 180°C.
  3. Then, mix the batter and pour it into the pan.
  4. Bake the pan for thirty minutes.
choices:
  - text: 2, 3, 4, 1
    correct: true
  - text: 1, 2, 3, 4
  - text: 3, 2, 4, 1
  - text: 2, 4, 3, 1
explanation: |
  A recipe goes: heat the oven, prepare the batter, bake it, then let it
  cool. "First," "Then," "Finally" are the clue words that reveal this
  order.
```

### `sentence-construction`
Pick the sentence that is grammatically correct and clearly constructed
(no cloze passage — a single free-standing sentence). A general-purpose
archetype usable as extra variety within any Language Application lesson.

```yaml
stem: |
  Choose the most clearly constructed sentence.
choices:
  - text: "Having finished the report, Marco submitted it before the deadline."
    correct: true
  - text: "Having finished the report, the deadline was met by Marco."
  - text: "Marco, the report having finished, submitted before the deadline."
  - text: "Before the deadline, the report having been finished by Marco."
explanation: |
  Only the first sentence makes clear who finished the report — Marco.
  The others attach the opening phrase to the wrong subject.
```
