# Reading Comprehension — Question Blueprint

> **Explanations and wrong-choice notes follow `../question-style-guide.md` (1 October 2026).**
> The explanation gives only why the correct answer is correct, with the solution when there is
> working. Every wrong choice carries a `rationale` note: the mistake, why it looks right, one
> check. The examples below omit the notes for brevity and predate this rule; where an example
> explanation discusses a wrong choice or names a choice by position, the style guide wins.


Applies to Comprehension Skills and Text Types. Follow
[question-style-guide.md](../question-style-guide.md) for format and voice.

**Written 3 August 2026.** This is the only subject whose questions share a text. Read
`docs/superpowers/specs/2026-08-03-passage-based-questions-design.md` before authoring, and
do not begin until `plans/2026-08-03-passage-pipeline.md` has landed: the validator cannot
accept a `passages:` block before then.

## The passage

**150 to 400 words. 4 to 8 questions each. The validator enforces both.**

**Write the passage first, then the questions.** Questions written first produce a passage
bent to fit them, and it reads like one.

**A passage is a real piece of writing, not a container.** It has a point, and a reader who
finished it should be able to say what that point was. A paragraph assembled to hold four
answers is the single most obvious tell of generated content.

### Where passages come from

**Write them.** They are original prose on subjects a Filipino senior high school student has
a reason to care about: a barangay dispute over a basketball court, the economics of a
sari-sari store, why the Pasig River cleanup stalled and restarted, a lola's remittance
letter, a jeepney driver's day under a modernization program.

**Never copy a published text.** Not a news article, not a textbook paragraph, not a poem.
The copyright stack on this project is settled and it does not cover borrowed prose.

**Vary the register deliberately**, because Text Types tests exactly that: a news report reads
nothing like an editorial, and an editorial reads nothing like a short story.

### What a passage must not do

- **No em dashes.** This applies to the passage body as much as to a stem.
- **No shouty caps**, no "delve", no "it is important to note". `tools/audit/sweep_ai_tells.py`
  hunts these in lessons and the same phrases give away a passage.
- **No footnotes, no citations, no bracketed asides.** A phone renders none of them well.
- **No dialogue that runs longer than three exchanges.** It eats the word budget.

---

## Comprehension Skills archetypes

### `main-idea`
The whole point, not a detail that happens to be true.

```yaml
stem: |
  What is the main idea of the passage?
choices:
  - text: The cleanup worked because residents, not the city, ran it.
    correct: true
  - text: The Pasig River was declared biologically dead in 1990.
  - text: Volunteers collected more than two tonnes of plastic.
  - text: The city government funded three collection barges.
explanation: |
  The passage returns to resident-led work in almost every paragraph. The
  other three are true, but each is one fact inside that larger point.
```

**The best distractors are true statements from the passage that are too small.** A student
who read carelessly picks the most memorable fact. That is the mistake being tested.

### `noting-specific-details`
One fact, stated plainly in the text.

**The answer must be findable, not inferrable.** If a student has to reason to get it, the
archetype is `inferencing-and-conclusions` instead.

### `inferencing-and-conclusions`
What follows, though the passage never says it.

```yaml
stem: |
  The passage suggests that the barangay captain expected the project to fail.
  Which detail best supports this?
choices:
  - text: He approved a budget for one month and asked for a report after two weeks.
    correct: true
  - text: He attended the opening ceremony.
  - text: He had served three terms.
  - text: He praised the volunteers in his speech.
explanation: |
  A one-month budget with a report due at two weeks is a person planning for
  an early stop. Nothing in the passage says he doubted it, so this is the
  detail that shows it.
```

**Every inference item must be answerable from the text alone.** If outside knowledge helps,
the item is broken.

### `authors-purpose-tone-pov`
Why it was written, how it sounds, who is speaking.

**Tone words must be distinguishable.** "Critical", "neutral", "admiring", "alarmed" is a real
set. "Negative", "bad", "unhappy", "sad" is one answer written four ways.

### `context-clues-in-passages`
A word's meaning **as used here**.

**Choose a word whose ordinary meaning differs from its meaning in the passage**, or the item
tests vocabulary rather than comprehension.

### `fact-vs-opinion`
Which statement can be checked.

**Opinions that sound factual are the point.** "The cleanup was the most successful in the
region" contains a superlative nobody measured.

### `sequencing-of-events`
Order, where the passage tells it out of order.

**Only worth asking when the text is not chronological.** A passage that narrates in order
makes this a reading-speed test.

### `choosing-a-title`
The title that fits the whole, not the opening line.

**Distractors: too narrow, too broad, and one that names something the passage mentions
once.**

---

## Text Types archetypes

Text Types tests recognition of **form**. The passage is the specimen.

### `identify-text-type`
Which kind of writing this is, and how you can tell.

**The explanation must name the evidence**, not just the label: a dateline and an inverted
pyramid make it a news report, a call to action makes it an editorial.

### `feature-of-form`
Which feature belongs to this form.

Applies to `essays-editorials-articles`, `speeches`, `poetry`,
`short-stories-and-novels`, `visual-media`.

### `purpose-of-device`
Why the writer used a device here: a repeated line in a speech, a stanza break in a poem, a
caption on an infographic.

**Poetry passages run short**, 40 to 120 words, and the 150-word floor does not apply to them.
Say so in the manifest row.

**`visual-media` describes the visual in prose** until hand illustration exists. A described
infographic is answerable; a missing image is not. **Never generate an image.**

---

## Distractor sources, ranked

1. **A true detail from the passage that is too small to be the answer.** The most productive
   source in the subject.
2. **A statement true in the world but absent from the passage.** Tests reading rather than
   knowing.
3. **A near-miss on scope**: right idea, wrong paragraph.
4. **The opposite of the correct answer**, phrased confidently.
5. **The passage's own words, rearranged into a claim it never makes.**

**Never make the correct answer the longest choice.** It is the oldest tell there is and
test-wise students hunt for it.
