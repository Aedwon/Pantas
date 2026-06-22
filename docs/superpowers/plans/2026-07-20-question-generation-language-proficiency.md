# Language Proficiency Question Generation — Content Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to work this plan subtopic-by-subtopic. Each manifest row below is one unit of work with its own test cycle (validate → review → approve → commit); treat each as a step.

**Goal:** Author, validate, review, and commit the question YAML for every remaining standalone Language Proficiency subtopic (19 files across Vocabulary, Grammar & Structure, and Language Application), using the already-built static question pipeline.

**Architecture:** No code changes. Content-production run against the existing, tested pipeline: `tools/import_questions/` (validates + converts YAML → Sanity docs) and `tools/question_studio/` (review/approve UI). One YAML file per subtopic, ~12–20 questions each, following the Language Proficiency blueprint's archetypes.

**Tech Stack:** YAML content files; Dart CLI for validation; Node review tool. No Flutter/Dart code is written in this plan.

## Global Constraints

- Scope is **standalone Language Proficiency only**: Vocabulary, Grammar & Structure, and Language Application. **Do not** author anything for Reading Comprehension or any cloze/passage-based item — those need a passage doctype and quiz-session grouping that don't exist yet (deferred, separate future work). If a lesson's natural question style would require a shared passage read by multiple questions, skip it and note it in this plan's "Deferred items" section at the bottom rather than forcing a workaround.
- Do not touch Science, Reasoning, Mathematics, or Reading Comprehension — those are separate plans/out of scope.
- Do not modify `tools/import_questions/` or `tools/question_studio/` code. If you find a genuine bug, stop, write a regression test reproducing it (mirror `test/tool/import_questions/cli_test.dart`), fix it minimally, then continue.
- One YAML file per subtopic at `content/questions/language-proficiency/<topic>/<subtopic>.yaml`. Never combine or split subtopics across files.
- Exactly one choice per question has `correct: true`. 4 choices by default (the `confusing-words` archetype may legitimately use 2–4 when the confused pair genuinely has only 2 natural options — see the blueprint's own example).
- `stem` and `explanation` are YAML block scalars (`|`).
- **Two-level voice:** `stem` at authentic UPCAT/DOST-SEI/USTET exam difficulty and wording — including, where the outline names a Filipino counterpart (e.g. "Bahagi ng Pananalita," "Sawikain at Tayutay," "Nang vs. Ng," "Sila vs. Sina"), write **some** questions in Filipino or about Filipino-specific usage, not only English, since UPCAT and USTET test Language Proficiency in Filipino too. `explanation` drops to simple Grade 4–6 English regardless of the stem's language (explain the Filipino rule in simple English, the way the lessons already do).
- **`difficulty` is authoring-only** (`easy | medium | hard | exam`) — never written to the Sanity doc, no schema field for it.
- **`id` pattern:** `q-<topicSlug>-<subtopicSlug>-NNNN`, unique across the whole bank, ascending with difficulty.
- **Figures:** this subject is entirely figure-free per the content audit — never add a `figure:` field here.
- **Ground every question in the existing lesson content** at `content/lessons/language-proficiency/<topic>/<subtopic>.md` — reuse its terminology, its worked examples, and its "Traps to Watch For" section as distractor material. Do not invent grammar/vocabulary rules not supportable by the lesson or standard English/Filipino usage.
- Coverage per subtopic: every archetype that fits × 2–3 variants, ramped single-rule → competing-rules → idiomatic/exception, landing around **12–20 questions**. No near-duplicates (don't just swap one noun for another in an otherwise identical sentence).
- **Quote any choice `text` that is bare `True`, `False`, `Yes`, `No`, `On`, or `Off`** (any casing) — e.g. `text: "True"`, not `text: True`. Unquoted, YAML parses these as booleans, not strings, and the importer rejects the question with "choice N has empty text" (found authoring Reasoning's Truth Tables subtopic). Also quote any choice `text` that is purely digits (e.g. `text: "18"`) for the same reason (integer, not string).
- No AI/Claude attribution in any commit message.

## Required reading (read once, before starting row 1)

- `docs/content/question-style-guide.md` — full YAML field rules.
- `docs/content/question-authoring-runbook.md` — process + topic→exam tag table (already applied below).
- `docs/content/question-blueprints/language-proficiency.md` — the full archetype set (Grammar & Structure: error-identification, correct-usage, subject-verb-agreement, tense, punctuation, pronoun-reference, parts-of-speech-identification, phrase-clause-identification, sentence-structure-classification, modifier-placement, parallelism-correction, redundancy-identification; Vocabulary: synonym, antonym, word-in-context, confusing-words, word-analogy, idiom-meaning, root-word-affix-analysis, spelling-correction; Language Application: error-identification (application level), fill-in-the-blank, sentence-ordering, sentence-construction) with a worked example each. Reuse these archetype names in each question's `type:` field.
- `content/questions/science/biology/cell-biology.yaml` — a complete, already-approved reference example of the target shape and quality bar.

## The Generation Procedure (apply to every row in the manifest below)

- [ ] **Step 1: Read the source lesson**

Open `content/lessons/language-proficiency/<topic>/<subtopic>.md` (path given in the manifest row). Note its worked examples, any Filipino-language terms/rules it covers, and its "Traps to Watch For" section.

- [ ] **Step 2: Pick archetypes and plan the question list**

Each manifest row lists its **primary archetype** (the one matching the lesson's actual skill — most Grammar & Structure and Vocabulary lessons map 1:1 to one archetype). Vary content domain, sentence topic, and difficulty across the 12–20 questions rather than forcing in unrelated archetypes. Where a secondary archetype genuinely adds coverage (e.g. a `parts-of-speech` lesson could include a couple of `sentence-structure-classification`-style items for variety), it's fine to mix in 1–2, but the primary archetype should dominate. For Language Application, follow the specific note in that section below — each of its 3 lessons maps to a specific archetype, not a free choice.

- [ ] **Step 3: Write the YAML file**

Create `content/questions/language-proficiency/<topic>/<subtopic>.yaml` (exact path in the manifest):

```yaml
meta:
  subject: language-proficiency
  topic: <topic slug>
  subtopic: <subtopic slug>
  exams: [upcat, acet, dlsucet, ustet, dost-sei]
questions:
  - id: q-<topic slug>-<subtopic slug>-0001
    type: <archetype name>
    difficulty: easy
    stem: |
      ...
    choices:
      - text: ...
        correct: true
      - text: ...
      - text: ...
      - text: ...
    explanation: |
      ...
  # ... more questions, ids ascending, difficulty ramping
```

Leave `approved:` unset — Question Studio sets it.

- [ ] **Step 4: Validate**

Run: `dart run tools/import_questions/import_questions.dart --root content/questions >/dev/null 2>&1`

Expected: exit code 0. Fix any named file/question id and rerun before moving on.

**Always redirect the validator's output.** It prints the full converted JSON of every
question under `--root`, which is **2.8 MB** across the whole corpus. Ingesting that on every
run is the single largest avoidable cost in a content dispatch. Check the exit code, not the
dump, and scope `--root` to your own subject directory:

```bash
dart run tools/import_questions/import_questions.dart \
  --root content/questions/<your subject dir> >/dev/null 2>&1; echo "exit: $?"
```

**Read the output only when the exit code is non-zero**, and then drop the redirect so the
error message is visible.


- [ ] **Step 5: Review and approve in Question Studio**

Run: `node tools/question_studio/server.mjs` (or `tools/question_studio/Start Question Studio.command`), open http://localhost:4323, find `language-proficiency / <topic> / <subtopic>`. Confirm no validator errors, no duplicate-stem warnings, correct choice matches intent. Fix inline, approve every question, Save, stop the server.

- [ ] **Step 6: Re-validate**

Run Step 4's command again: exit code 0.

- [ ] **Step 7: Commit**

```bash
git add content/questions/language-proficiency/<topic>/<subtopic>.yaml
git commit -m "content: <Subtopic Title> questions"
```

- [ ] **Step 8: Check off the row**

Mark the manifest row below `- [x]` and move to the next row.

## Definition of Done (per subtopic)

- [ ] File exists at the exact manifest path.
- [ ] 12–20 questions.
- [ ] `dart run tools/import_questions/import_questions.dart --root content/questions >/dev/null 2>&1` exits 0.
- [ ] Question Studio shows zero validator errors and zero duplicate-stem flags.
- [ ] Every question's `approved: true`.
- [ ] Committed; working tree clean except the next subtopic in progress.

## Manifest — Vocabulary (topic slug: `vocabulary`)

Exams for all rows: `[upcat, acet, dlsucet, ustet, dost-sei]`.

| Done | Subtopic slug | Title | Primary archetype | File path |
|---|---|---|---|---|
| [x] | `context-clues` | Word Meanings through Context Clues | `word-in-context` | `content/questions/language-proficiency/vocabulary/context-clues.yaml` |
| [x] | `synonyms-and-antonyms` | Synonyms and Antonyms | `synonym` + `antonym` (mix both, roughly half each) | `content/questions/language-proficiency/vocabulary/synonyms-and-antonyms.yaml` |
| [x] | `idioms-and-figures-of-speech` | Idioms and Figures of Speech / Sawikain at Tayutay | `idiom-meaning` | `content/questions/language-proficiency/vocabulary/idioms-and-figures-of-speech.yaml` |
| [x] | `root-words-prefixes-suffixes` | Root Words, Prefixes, and Suffixes | `root-word-affix-analysis` | `content/questions/language-proficiency/vocabulary/root-words-prefixes-suffixes.yaml` |
| [x] | `confusing-words` | Confusing Words (Affect vs. Effect, Its vs. It's, Nang vs. Ng, Sila vs. Sina) | `confusing-words` | `content/questions/language-proficiency/vocabulary/confusing-words.yaml` |
| [x] | `spelling-rules` | Spelling Rules | `spelling-correction` | `content/questions/language-proficiency/vocabulary/spelling-rules.yaml` |

Note on `confusing-words`: this lesson explicitly names two Filipino pairs (Nang vs. Ng, Sila vs. Sina) alongside two English pairs (Affect vs. Effect, Its vs. It's) — cover all four pairs, not just the English ones.

## Manifest — Grammar and Structure (topic slug: `grammar-and-structure`)

Exams for all rows: `[upcat, acet, dlsucet, ustet, dost-sei]`.

| Done | Subtopic slug | Title | Primary archetype | File path |
|---|---|---|---|---|
| [x] | `parts-of-speech` | Parts of Speech / Bahagi ng Pananalita | `parts-of-speech-identification` | `content/questions/language-proficiency/grammar-and-structure/parts-of-speech.yaml` |
| [x] | `subject-verb-agreement` | Subject-Verb Agreement / Wastong Gamit ng Salita | `subject-verb-agreement` | `content/questions/language-proficiency/grammar-and-structure/subject-verb-agreement.yaml` |
| [x] | `pronoun-antecedent-agreement` | Pronoun-Antecedent Agreement | `pronoun-reference` | `content/questions/language-proficiency/grammar-and-structure/pronoun-antecedent-agreement.yaml` |
| [x] | `tenses-and-voice` | Tenses and Voice of Verbs (Active vs. Passive) | `tense` (add a few items on active/passive voice specifically, same archetype style) | `content/questions/language-proficiency/grammar-and-structure/tenses-and-voice.yaml` |
| [x] | `phrases-and-clauses` | Phrases and Clauses (Independent vs. Dependent) | `phrase-clause-identification` | `content/questions/language-proficiency/grammar-and-structure/phrases-and-clauses.yaml` |
| [x] | `sentence-structure` | Sentence Structure (Simple, Compound, Complex, Compound-Complex) | `sentence-structure-classification` | `content/questions/language-proficiency/grammar-and-structure/sentence-structure.yaml` |
| [x] | `modifiers` | Modifiers (Identifying Misplaced and Dangling Modifiers) | `modifier-placement` | `content/questions/language-proficiency/grammar-and-structure/modifiers.yaml` |
| [x] | `parallelism` | Parallelism / Parallel Structure | `parallelism-correction` | `content/questions/language-proficiency/grammar-and-structure/parallelism.yaml` |
| [x] | `punctuation-and-capitalization` | Punctuation and Capitalization Rules | `punctuation` (add a few items specifically on capitalization rules, same archetype style) | `content/questions/language-proficiency/grammar-and-structure/punctuation-and-capitalization.yaml` |
| [x] | `redundancy-and-double-negatives` | Redundancy and Double Negatives | `redundancy-identification` | `content/questions/language-proficiency/grammar-and-structure/redundancy-and-double-negatives.yaml` |

Note on `parts-of-speech` and `subject-verb-agreement`: both name a Filipino counterpart in their title ("Bahagi ng Pananalita," "Wastong Gamit ng Salita") — include some Filipino-language items, mirroring how the lesson itself teaches both languages.

## Manifest — Application (topic slug: `language-application`)

Exams for all rows: `[upcat, acet, dlsucet, ustet, dost-sei]`. Each lesson maps to a specific archetype from the blueprint's "Language Application archetypes" section — do not substitute a different archetype for these three.

| Done | Subtopic slug | Title | Archetype | File path |
|---|---|---|---|---|
| [ ] | `error-identification` | Error Identification / Sentence Correction | `error-identification` (Application level — mix grammar rules across items, don't repeat one rule) | `content/questions/language-proficiency/language-application/error-identification.yaml` |
| [ ] | `sentence-completion` | Sentence Completion / Fill-in-the-Blanks | `fill-in-the-blank` | `content/questions/language-proficiency/language-application/sentence-completion.yaml` |
| [ ] | `paragraph-organization` | Paragraph Organization (Logical Ordering of Sentences) | `sentence-ordering` — **keep each question self-contained** (its own 4–5 sentences), never a passage shared across multiple questions | `content/questions/language-proficiency/language-application/paragraph-organization.yaml` |

## Deferred items (do not author — log here if you find more)

- Reading Comprehension and Text Types (separate subject, passage-based) — out of scope entirely, own future plan.
- Any cloze exercise built around a shared paragraph read by several questions — out of scope; a single-sentence fill-in-the-blank (as in `sentence-completion` above) is fine, a multi-question shared passage is not.

## Suggested order

Start with **Vocabulary** (smallest, most self-contained, good pipeline warm-up), then **Grammar and Structure** (largest, most archetype variety), then **Application** (smallest, but each lesson needs its specific archetype — do it last so the archetype vocabulary from the other two topics is fresh). Commit after every subtopic; do not batch commits.

## Self-Review

**Spec coverage:** all 19 remaining standalone Language Proficiency lessons from `tools/lesson_author/outline.json` have a manifest row with an exact path; Reading Comprehension/cloze exclusions are explicit. ✓
**Placeholder scan:** no TBD/TODO; exact commands throughout. ✓
**Consistency:** exam tags match the runbook table; archetype names match the now-complete language-proficiency blueprint, including the new archetypes added for previously-uncovered lessons (parts-of-speech-identification, phrase-clause-identification, sentence-structure-classification, modifier-placement, parallelism-correction, redundancy-identification, idiom-meaning, root-word-affix-analysis, spelling-correction, fill-in-the-blank, sentence-ordering). ✓
