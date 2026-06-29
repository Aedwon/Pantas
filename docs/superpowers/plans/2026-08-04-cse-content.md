# CSE content: the tagging pass, then the missing subjects

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**This plan is model-agnostic.** Read `AGENTS.md` and `SUBAGENTS.md` before writing a line. Its
spec is `docs/superpowers/specs/2026-08-04-cse-content-coverage-design.md`.

**Goal:** Take the CSE from 2 questions to a real track, by tagging the content that already
covers its scope and writing the parts that only the CSE has.

**Architecture:** Task 1 is a tagging pass with **no authoring at all**. Tasks 2 to 5 are
content generation against reference files. Nothing here touches `lib/`.

**Tech Stack:** YAML content, the existing import and seed tooling. No code changes.

---

## The rule that governs this whole plan

**Every question about a law, the Constitution, or a testing body's published rules is written
against a file in `content/reference/`, and against nothing else.**

| Area | Reference file |
|---|---|
| Code of conduct | `content/reference/cse/ra-6713-code-of-conduct.md` |
| Constitution | `content/reference/cse/1987-constitution.md` |
| Peace and human rights | `content/reference/cse/peace-and-human-rights.md` |
| Environment | `content/reference/cse/environment-management.md` |

**Read the reference file before writing a single question in its area, and read
`content/reference/README.md` first.**

**If a fact is not in the reference file, do not write the question.** The files mark exactly
where a confident wrong answer is most likely. Either fetch the source and **add it to the
reference file first**, or write a different question. **Never fill the gap from memory.**

**This is not the never-invent-a-figure rule, it is worse than it.** A wrong figure is
embarrassing. **A wrong statement about what the law requires of a public official is being told
to someone studying to become one.**

---

## Global Constraints

- **No code changes.** This plan writes `content/` only. It touches no file under `lib/`,
  `test/` or `tools/`.
- **Never tag Science into the CSE.** Science is not on the CSE paper. This is the single
  easiest way to ruin the track.
- **No em dashes. American spelling.** No AI attribution in commit messages.
- **`approved:` stays unset.** Approval is Aedwon's, in Question Studio.
- **The validator prints 2.8 MB across the corpus.** Redirect stdout to `/dev/null`, read the
  exit code, and scope `--root` to the directory you wrote. The tool is at
  `tools/import_questions/`, not `tool/`.
- **Do not write anything in Filipino.** The CSE examines verbal ability in English and
  Filipino, the pipeline cannot represent Filipino today, and whether it ships is undecided.
  Section 6 of the spec covers it. **Out of scope here.**

### The exam codes

`cse-pro` and `cse-sub`, matching the existing short-code convention in the `exams:` list of
every question file. **Confirm against a file that already carries codes before writing any**,
and if the convention differs, follow the tree rather than this plan.

### Gate command

```bash
dart run tools/import_questions/import_questions.dart --root content/questions/<path> > /dev/null; echo $?
```

Expected: `0`.

---

### Task 1: The tagging pass, which needs no authoring

**This is the highest-value task in the plan and it writes no new content.** It turns 2 CSE
questions into most of the verbal, analytical and numerical paper.

**Add `cse-pro` and, where marked, `cse-sub` to the `exams:` list of these existing files.**

| Path | cse-pro | cse-sub | CSE area it covers |
|---|---|---|---|
| `language-proficiency/vocabulary/` all six | yes | yes | Vocabulary: word meaning |
| `language-proficiency/language-application/sentence-completion` | yes | yes | Vocabulary: sentence completion |
| `language-proficiency/language-application/error-identification` | yes | yes | Grammar: error recognition |
| `language-proficiency/grammar-and-structure/` all ten | yes | yes | Grammar: sentence structure |
| `language-proficiency/language-application/paragraph-organization` | yes | yes | Paragraph organization |
| `reasoning/word-analogies` | yes | no | Analytical: word analogy |
| `reasoning/syllogisms-and-deductive-logic` | yes | no | Analytical: symbolic logic |
| `reasoning/truth-tables-propositional-logic` | yes | no | Analytical: symbolic logic |
| the five `reasoning` figure subtopics | yes | no | Analytical: abstract reasoning |
| `reasoning/number-and-letter-sequences` | yes | yes | Numerical: number sequence |
| `mathematics/arithmetic-number-sense/` all nine | yes | yes | Numerical: basic operations |
| every `word-problems` subtopic under `mathematics` | yes | yes | Numerical: word problems |

**`vocabulary/spelling-rules` gets `cse-sub` as well**, because spelling is part of the
Sub-professional clerical subtest.

**Nothing under `content/questions/science/` is tagged. Not one file.**

- [ ] **Step 1: Confirm the code convention**

```bash
head -6 content/questions/mathematics/arithmetic-number-sense/business-math.yaml
```

Read the `exams:` line and match its style exactly. **If the codes are not bare slugs like
`upcat`, follow the tree and say so in your report.**

- [ ] **Step 2: Tag one file and validate it**

Add the codes to a single file first, then:

```bash
dart run tools/import_questions/import_questions.dart --root content/questions/mathematics/arithmetic-number-sense > /dev/null; echo $?
```

Expected: `0`. **If it is not 0, stop.** A convention error caught on one file is cheap; caught
on ninety it is not.

- [ ] **Step 3: Tag the rest, directory by directory, validating each**

- [ ] **Step 4: Verify the count**

```bash
grep -rl "cse-pro" content/questions | wc -l
grep -rl "cse-pro" content/questions/science | wc -l
```

Expected: a large number, and **zero** for Science.

- [ ] **Step 5: Commit**

```bash
git add content/questions
git commit -m "content(cse): tag the questions that already cover the CSE scope"
```

---

### Task 2: General Information, the Code of Conduct

**Start here among the writing tasks**, because its reference file is the most complete and the
area is the most distinctively CSE.

**Create** `content/lessons/general-information/code-of-conduct-ra-6713/` and the matching
`content/questions/` path, with these subtopics:

```
norms-of-conduct
duties-and-prohibited-acts
statements-of-assets-and-divestment
penalties-and-enforcement
```

- [ ] **Step 1: Read `content/reference/cse/ra-6713-code-of-conduct.md` in full.**

- [ ] **Step 2: Write the lesson, then the questions, one subtopic at a time**

Follow `SUBAGENTS.md` Part 4 and the per-row procedure the existing question generation plans
use. **12 to 20 questions per subtopic**, ids ascending with no gaps.

**Both `cse-pro` and `cse-sub` on every file.** General Information is on both papers.

**What is safe to examine here**, and it is a lot: the eight norms by name, their count and
order; the 15-day and 45-day deadlines; the three asset-statement occasions and the 30 day and
30 April deadlines; the fourth civil degree; where each kind of official files; the 10 working
days and 10 years of public access; the 30 and 60 day divestment rules; the penalty bands; and
the gift rule with its listed exceptions.

**What must not be examined:** the exact statutory phrasing of a norm's description, and
anything about who currently holds an office.

- [ ] **Step 3: Validate, then commit per subtopic**

---

### Task 3: General Information, the Constitution

**Subtopics**, under `general-information/philippine-constitution/`:

```
the-articles-in-outline
bill-of-rights
the-civil-service-commission
accountability-and-impeachment
```

- [ ] **Step 1: Read `content/reference/cse/1987-constitution.md` in full.**

**Note what it says is missing.** Citizenship, suffrage, the three branches and local government
are in scope for the exam and **are not yet in the file**.

- [ ] **Step 2: Write only the four subtopics above**

**They are the four the reference file can support.** The article outline, the Bill of Rights at
the level of what it protects, the Civil Service Commission's composition and terms, and the two
closed lists on impeachment.

**Do not write a question that turns on which numbered section of Article III carries a right**
unless you have fetched and verified that number. The file says this explicitly and it is the
easiest error in the whole plan.

- [ ] **Step 3: Report the gap rather than filling it**

**When the four are done, stop.** In your report, name the areas the reference file lists as
still needing fetching. **Do not write those subtopics from memory.** Extending the reference
file is a separate, deliberate act.

---

### Task 4: General Information, peace and human rights, and environment

**These two are grouped because both reference files are deliberately thin, and the honest
output is fewer questions rather than invented ones.**

`general-information/peace-and-human-rights/`:

```
human-rights-fundamentals
humanitarian-law-and-human-rights-law
```

`general-information/environment-management/`:

```
the-environmental-laws
environmental-concepts
```

- [ ] **Step 1: Read both reference files in full.**

- [ ] **Step 2: Write to the settled core only**

**For environment, the backbone is matching a law to what it governs**, which the reference
table supports directly. **Write those first and write them well.**

**For peace and human rights, the most examinable concept is the distinction** between human
rights law and humanitarian law. Build around it.

- [ ] **Step 3: Where the floor cannot be met, say so**

**If a subtopic cannot reach 12 questions without inventing a threshold, a date or a penalty,
write fewer and report it.** A short subtopic is a known gap. **A subtopic padded with invented
law is a liability**, and it is the exact failure this plan's opening rule exists to prevent.

---

### Task 5: The three small analytical and clerical gaps

| Path | Tracks | Note |
|---|---|---|
| `reasoning/verbal-logic/assumptions-and-conclusions` | `cse-pro` | Analytical Ability |
| `mathematics/data-interpretation/tables-and-charts` | `cse-pro` | Reading quantities out of a table or chart |
| `mathematics/data-interpretation/rates-ratios-and-percentages-in-context` | `cse-pro` | As above |
| `reasoning/clerical-ability/alphabetic-filing-rules` | `cse-sub` | Sub-professional only |
| `reasoning/clerical-ability/numeric-and-chronological-filing` | `cse-sub` | Sub-professional only |

**Data interpretation needs a table or chart in the stem.** If the question format cannot carry
one, **stop and say so** rather than writing a data interpretation question with no data. That
is a real constraint of the pipeline and it is better surfaced than worked around.

**Filing questions test the rule, not a specific office's practice.** Alphabetic filing has
conventions about surnames, prefixes and identical names; those are the examinable content.

---

## What this plan deliberately does not do

- **Nothing in Filipino.** Undecided, and structurally impossible today. Spec Section 6.
- **No reading comprehension.** It is blocked on the passage pipeline, and when that lands it
  serves the CETs and the CSE at once.
- **It does not activate the Sub-professional track.** That track stays inactive until it has
  content for all four of its subtests, which this plan does not complete.
- **It does not extend the reference files.** Where a file is thin, this plan writes less and
  reports it. Extending a reference file is a deliberate act with its own sourcing.

## Verification for the whole plan

```bash
grep -rl "cse-pro" content/questions/science | wc -l
```

Expected: **0**. Science is not on the CSE paper.

```bash
dart run tools/import_questions/import_questions.dart --root content/questions > /dev/null; echo $?
```

Expected: `0`.

- Every General Information question is answerable from a file in `content/reference/`.
- No question states a threshold, deadline, penalty or section number that does not appear in a
  reference file.
- No question names a current officeholder.
- `general-information` appears in no CET's exam list.
- Nothing under `lib/`, `test/` or `tools/` was modified.
