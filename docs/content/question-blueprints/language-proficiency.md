# Language Proficiency — Question Blueprint

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

## Language Application archetypes (standalone only)

### `sentence-construction`
Pick the sentence that is grammatically correct and clearly constructed
(no cloze passage — a single free-standing sentence).

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
