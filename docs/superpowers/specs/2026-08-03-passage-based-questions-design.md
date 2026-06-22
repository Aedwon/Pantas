# Passage-based questions: what changes when several questions share one text

**Date:** 3 August 2026
**Status:** Written on Aedwon's instruction of 3 August: **v1 ships with reading
comprehension.**
**Why it exists:** nothing in this project models a passage. The importer accepts a stem, four
choices, an explanation and an optional figure, and nothing else. The language proficiency
blueprint bans shared passages by name, and the language content plan defers reading
comprehension "out of scope entirely, own future plan". This is that plan's spec.

This spec describes the destination. It assumes nothing in the tree survives.

---

## Section 1: What is actually missing

Verified against the tree on 3 August.

| Layer | State today |
|---|---|
| `content/questions/**.yaml` | No passage key. Every question is free-standing. |
| `tools/import_questions/converter.dart` | Parses `id`, `type`, `difficulty`, `stem`, `choices`, `explanation`, `figure`. |
| `Questions` drift table | `id`, `version`, `examIdsJson`, `topicId`, `lessonId`, `language`, `stem`, `choicesJson`, `explanation`, `shortLabel`. No passage. |
| `assets/seed/v1.json` | `exams`, `topics`, `lessons`, `questions`. No passages. |
| The question viewer | Renders one stem. |
| The session builder, the mock sampler | Treat every question as independent. |

**Thirteen lessons already exist** under `content/lessons/reading-comprehension/`, eight for
Comprehension Skills and five for Text Types. The teaching is written. Only the questions and
the machinery under them are missing.

## Section 2: The passage is its own thing, not a longer stem

**Rejected: putting the passage in the stem of every question.** It is the cheapest change and
it is wrong three times over.

1. **A 300-word passage repeated across six questions is 1,800 words in the seed** where 300
   would do, and the seed already ships in the app bundle.
2. **The student would re-read it six times**, or the app would render it six times and the
   student would scroll past it five.
3. **The review screen would show it six times.** So would the debrief.

**A passage is a content entity with its own id**, and a question names the passage it belongs
to. That is the whole design decision and everything below follows from it.

```
Passage: id, title, body, wordCount, topicId, language
Question: ... plus passageId, nullable
```

**`passageId` is nullable and most questions will never have one.** Nothing outside reading
comprehension changes shape.

## Section 3: Questions that share a passage travel together

**A passage question is never served alone.**

This is the rule that ripples furthest, and it is not negotiable: a comprehension question
without its passage is unanswerable, so any surface that can select a single question must
either take the whole set or take none of it.

| Surface | What it must do |
|---|---|
| A practice session | Take **all** of a passage's questions, or none. They appear consecutively. |
| A mock section | The same. A passage set is one unit for sampling. |
| A drill | The same. |
| The scheduler | May schedule a passage's questions individually for **review**, but serving one pulls its passage in with it. |
| The reveal | Passage stays on screen. |
| The review screen | The passage renders **once**, above its questions, not per question. |

**The count a student is shown is still the question count, not the passage count.** "10
questions" means ten questions, some of which happen to share a text. Saying "3 passages"
would be a figure this project invented to describe its own storage.

## Section 4: What a passage set costs a session

**A passage set is indivisible, so it can overshoot a session's size.** A session asking for
10 questions that picks a 6-question passage set and then an 8-question one has 14.

**The rule: never exceed the requested size by taking a set that does not fit.** Fill with a
passage set only while the remaining room is at least the set's size. Then fill the rest with
free-standing questions.

**A session smaller than the smallest available passage set contains no passage questions at
all**, and that is correct rather than a failure. A 5-question quick session is not the place
for a 6-question passage.

## Section 5: The reading experience

**The passage renders above the question, in the reader's typography, not the question's.**
It is prose to be read, and Ink and Rule already has a reading surface: the lesson reader.
Reuse its measure, its line height and its serif.

**A rule separates the passage from the question.** Hairline, full measure, the same device
the reader uses between a lesson's sections.

**The passage scrolls with the question and does not lock.** A sticky passage pane splits a
phone screen into two cramped halves and neither is readable. The student scrolls up to
re-read, which is what they do on paper.

**Between questions on the same passage, the passage does not re-animate.** Moving from
question 3 to question 4 of the same set changes the question and leaves the text still. A
passage that fades in six times is the app drawing attention to its own machinery.

**A long passage gets a "back to the question" affordance**, and only when the passage is
taller than the viewport. Never otherwise.

## Section 6: Length, and what the exams actually use

**Passages run 150 to 400 words, with 4 to 8 questions each.** That is the range the local
exams use and it is what the content plan authors against.

**Never write a passage longer than 400 words.** A student on a 5-inch phone reading 600 words
before the first question will abandon the session, and the item is not testing comprehension
at that point, it is testing patience.

## Section 7: Evidentiary tier

| Figure | Tier |
|---|---|
| Question count in a session containing a passage set | **Measured.** It is the count of questions. |
| Passage word count | **Measured**, and internal. Never shown to a student. |
| "Reading time" for a passage | **Inference. Never shown.** It would be a word count multiplied by an assumed reading speed, which is a measurement combined with an assumption, and Section 1 of the Progress spec bans exactly that. |

## Section 8: What this does not change

Stated so the blast radius is honest.

- **Free-standing questions are untouched.** `passageId` is null and every existing surface
  behaves as it does today.
- **No existing YAML file changes.** The key is additive.
- **The mock blueprint format is unchanged.** A section still asks for N questions from a
  topic; the sampler decides how to fill it.
- **FSRS is unchanged.** A passage question is scheduled like any other. The passage comes
  along when it is served.

## Deferred, with reasons

- **A passage library the student can browse.** Comprehension practice is not a reading app.
- **Highlighting or annotating the passage.** Real, and a whole feature. Revisit after launch.
- **Audio passages.** Out of scope for every exam in the roster.
- **Cross-passage questions**, comparing two texts. NMAT does this; the entrance exams do not.
  Revisit if NMAT becomes a priority.
