# CSE content: what is missing, and how it is classified

**Date:** 4 August 2026
**Status:** Written in response to a direct question from Aedwon about whether content is
complete, and what the CSE needs.
**Scope:** The Civil Service Examination, both levels. It also records the CET coverage audit
that prompted it.

---

## Section 1: The CET audit, which is the good news

**CET content is complete except for one subject, and that subject is already unblocked.**

| Check | Result |
|---|---|
| Lessons on disk | **141** |
| Question sets on disk | **128** |
| Question sets with no lesson | **0** |
| Lessons with no question set | **13, and all 13 are Reading comprehension** |

**The 13 are exactly the Reading comprehension subtopics**: eight under Comprehension Skills and
five under Text Types. Their lessons are written. They have no questions because **nothing in
the app modelled a passage**, which is what the passage pipeline now in flight exists to fix.

**No other gap exists.** Every other lesson has its questions and every question set has its
lesson.

---

## Section 2: The CSE, which is the bad news

**The app ships two CSE tracks and has almost no CSE content.**

| Exam | Questions in the seed | Active |
|---|---|---|
| USTET | 1,838 | yes |
| UPCAT | 1,774 | yes |
| DLSU-CET | 1,774 | yes |
| DOST-SEI | 1,160 | yes |
| ACET | 1,061 | yes |
| PUPCET | 678 | yes |
| **CSE Professional** | **2** | **yes** |
| **CSE Sub-professional** | **0** | no, and it has no subjects at all |

**CSE Professional is live and selectable with two questions.** A student who picks it gets an
empty app. **This is the app's original audience**: the project was called CSE/CET Reviewer, and
the CSE is now the emptiest track in it.

---

## Section 3: The official scope, which is the authority here

**Taken from the Civil Service Commission's published scope of examination**, not from anyone's
recollection. Both levels are examined **in English and Filipino** on the verbal subtest.

### Professional

| Subtest | Areas |
|---|---|
| **Verbal Ability** (English **and Filipino**) | Vocabulary: word meaning, sentence completion. Grammar: error recognition, sentence structure. Reasoning: paragraph organization, reading comprehension |
| **Analytical Ability** (English) | Word analogy. Symbolic logic and abstract reasoning. Identifying assumptions and drawing conclusions. Data interpretation |
| **Numerical Ability** (English) | Basic operations. Number sequence. Word problems |
| **General Information** | Philippine Constitution. Code of Conduct and Ethical Standards for Public Officials and Employees, RA 6713. Peace and Human Rights issues and concepts. Environment Management and Protection |

### Sub-professional

Verbal, Numerical and General Information as above. **Analytical Ability is replaced by Clerical
Ability: filing, and spelling.**

**Item counts and time limits are not published in the scope document**, so none is stated here.
The mock's blueprint already carries 170 items in 3 hours 10 for the Professional level from a
separate source.

---

## Section 4: What the app already has, mapped area by area

**Most of the CSE's verbal, analytical and numerical scope is already written**, because it
overlaps with the CETs. **The classification does not need inventing: the existing
subject, topic and lesson tree already holds it.**

| CSE area | Existing content | Verdict |
|---|---|---|
| Vocabulary: word meaning | `language-proficiency/vocabulary/` six subtopics | **Tag it** |
| Vocabulary: sentence completion | `language-application/sentence-completion` | **Tag it** |
| Grammar: error recognition | `language-application/error-identification` | **Tag it** |
| Grammar: sentence structure | `grammar-and-structure/` ten subtopics | **Tag it** |
| Paragraph organization | `language-application/paragraph-organization` | **Tag it** |
| Reading comprehension | 13 lessons, no questions yet | **Blocked on the passage pipeline** |
| Word analogy | `reasoning/word-analogies` | **Tag it** |
| Symbolic logic, abstract reasoning | `reasoning/syllogisms-and-deductive-logic`, `truth-tables-propositional-logic`, and the five figure subtopics | **Tag it** |
| Numerical: basic operations | `mathematics/arithmetic-number-sense/` | **Tag it** |
| Numerical: number sequence | `reasoning/number-and-letter-sequences` | **Tag it** |
| Numerical: word problems | the `word-problems` subtopics across Mathematics | **Tag it** |
| Spelling, for Sub-professional clerical | `vocabulary/spelling-rules` | **Tag it** |
| **Identifying assumptions and drawing conclusions** | nothing | **Write it** |
| **Data interpretation** | nothing | **Write it** |
| **Clerical: filing** | nothing | **Write it**, Sub-professional only |
| **General Information**, all four areas | nothing | **Write it**, and it is CSE only |
| **Anything in Filipino** | nothing, and the pipeline hardcodes English | **Section 6** |

**Science has no place in the CSE** and must not be tagged into it. It is CET only.

---

## Section 5: The classification, which reuses the existing tree

**Two new topics, both under existing or new subjects, following the same
subject / topic / subtopic shape as everything else.** No new concepts are introduced.

### New: `general-information`, a subject of its own

**It is CSE only and belongs to no CET**, which is why it is a subject rather than a topic under
an existing one.

```
content/{lessons,questions}/general-information/
  philippine-constitution/
    the-1987-constitution-in-outline
    bill-of-rights
    the-three-branches
    citizenship-suffrage-and-elections
    local-government-and-accountability
  code-of-conduct-ra-6713/
    norms-of-conduct
    duties-and-prohibited-acts
    statements-of-assets-and-divestment
    penalties-and-enforcement
  peace-and-human-rights/
    human-rights-fundamentals
    international-humanitarian-law
    the-philippine-peace-process
  environment-management/
    environmental-laws-and-agencies
    solid-waste-and-clean-air-water
    climate-and-disaster-risk-reduction
```

### New: `clerical-ability`, a topic under `reasoning`

**Sub-professional only.** Filing is a sorting and sequencing skill, which is why it sits beside
the other sequencing work rather than under Language.

```
content/{lessons,questions}/reasoning/clerical-ability/
  alphabetic-filing-rules
  numeric-and-chronological-filing
```

**Spelling is not repeated here.** `vocabulary/spelling-rules` already exists and is tagged.

### New subtopics under existing topics

```
content/{lessons,questions}/reasoning/verbal-logic/
  assumptions-and-conclusions
content/{lessons,questions}/mathematics/data-interpretation/
  tables-and-charts
  rates-ratios-and-percentages-in-context
```

**Data interpretation goes under Mathematics, not Reasoning**, because the CSC lists it under
Analytical Ability but the skill it tests is reading quantities out of a table or chart.

---

## Section 6: Filipino, which is the one structural problem

**The CSE examines verbal ability in English and Filipino. The app has no Filipino content and
cannot currently hold any.**

**This is not only a content gap.** The seed builder writes `'language': 'en'` as a constant for
every subject, topic and question. **A Filipino question cannot be represented today**, so this
is a pipeline change before it is an authoring job.

**Three things follow, and they should be decided rather than assumed:**

1. **Is Filipino in v1 at all?** Skipping it means the CSE track is honest but incomplete, and
   the setup screen should say which parts are covered rather than presenting a partial paper as
   the whole thing, which is the rule the mock spec already sets for ACET and DCAT.
2. **If it ships, the language field becomes real** and every surface that filters or displays
   content has to carry it.
3. **Authoring Filipino grammar and vocabulary items is not a translation job.** Filipino verbal
   items test Filipino usage, not the English items rendered in Filipino, and generating them
   needs a different prompt and a reviewer who reads Filipino.

**This spec does not decide it. It records that it must be decided**, because a CSE track that
silently omits half of one subtest is the kind of thing a student discovers on exam day.

---

## Section 7: What this is worth, in order

1. **The tagging pass.** It costs no authoring and it turns two CSE questions into most of the
   verbal, analytical and numerical scope.
2. **General Information.** Four areas, entirely absent, and the most distinctively CSE part of
   the paper.
3. **Reading comprehension**, which the passage pipeline unblocks for the CETs and the CSE at
   once.
4. **Assumptions and conclusions, and data interpretation.** Two small gaps in analytical.
5. **Clerical filing**, Sub-professional only, and that level is currently inactive.
6. **Filipino**, once Section 6 is decided.

---

## Verification

- No question set names a CSE track unless its content is in the CSC's published scope.
- **No Science question is ever tagged CSE.**
- `general-information` appears in no CET's question set.
- The Sub-professional track stays inactive until it has content for all four of its subtests.
- Item counts and time limits are not invented anywhere in this spec.

**Sources for Section 3:**
- [CSE-PPT scope of examination, cse.ph](https://cse.ph/scope-of-exam/march-2026-career-service-exam-pen-and-paper-test-cse-ppt/)
- [Civil service exam coverage, professional and sub-professional](https://governmentph.com/civil-service-exam-coverage-pro-subpro/)
