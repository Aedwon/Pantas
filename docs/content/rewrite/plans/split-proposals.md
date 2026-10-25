# Split proposals for the 6 oversized lessons (plan task P0.6)

Policy commit: `d1943470` (origin/main). Documents only. No lesson, outline, tag or question file was touched.
Inputs: the briefs for the 6 lessons, `cse-teaching-gaps.jsonl`, the 6 current lesson files, the 6 question files, `lesson-exam-tags.json`, and the CSE and exam requirement records.

## Summary

| Lesson | Added parts | Now (words) | If not split (words) | Recommendation | Result |
|---|---|---|---|---|---|
| `philippine-constitution-bill-of-rights` | 39 | 661 | about 3,600 | Split into 4 | keep id plus 3 new |
| `environment-management-environmental-concepts` | 27 | 481 | about 2,500 | Split into 4 | keep id plus 3 new |
| `environment-management-the-environmental-laws` | 17 | 613 | about 1,900 | Split by moving parts (no new id) | keeps id; 12 parts leave, 3 arrive; about 1,200 |
| `philippine-constitution-the-articles-in-outline` | 18 | 443 | about 1,400 | Keep (borderline) | one lesson, with a tripwire |
| `code-of-conduct-ra-6713-duties-and-prohibited-acts` | 16 | 898 | about 2,100 | Split into 2 | keep id plus 1 new |
| `grammar-and-structure-tenses-and-voice` | 14 | 909 | about 2,000 | Split into 2 | keep id plus 1 new |

Net: 5 of 6 recommended for splitting, 8 new lesson ids (3 + 3 + 0 + 1 + 1), 1 kept whole.

## How the estimates were made

- Yardstick: all 158 current lessons run 372 to 1,685 words, median 796, estimatedMinutes 8 to 15, about 77 words per minute. The style guide asks for 8 to 15 minutes. I treat about 1,400 words as the comfortable ceiling for one lesson and 1,700 as the hard one (the longest lesson today is 1,685).
- Cost per added part: about 75 words (a rule with its condition, about 40 words, plus a share of one worked example, about 35 words). Parts that share one example cost less. Filipino parts cost about 85. These are planning figures from judgment, not measurements. The pilot should measure real words per part and correct them.
- Each new lesson also needs its own Traps section (about 100 words). That is why split totals exceed the unsplit total by 10 to 15 percent.
- The brief counts of "added parts" are the counts in the task: 39, 27, 18, 17, 16, 14.

## Rules for every split

- The first part keeps the original id, file name and question file. New parts get new ids.
- No question id is renumbered or reused. Existing ids keep their text and their `q-<topic>-<original slug>-NNNN` form.
- Open question A: may an existing question record move to a new part's file with its id unchanged (only `meta.subtopic` and file location change)? The tables below assume yes. If no, all 20 stay in the original file and every new part gets all-new questions. Either way the original lesson ends with fewer than 20 questions that fit it, so new questions are needed.
- Each part needs at least 20 active questions (plan P4 shortfall rule). The "shortfall" columns show how many new questions each part needs after the move.
- Question assignment below is from each stem's wording. The question check must confirm it.
- Fix rows: the brief builder writes one brief per lesson id. Each brief fix row quotes a passage; it follows that passage to the part that holds it. The lead must either re-run the brief builder after the split ids exist or hand-split the briefs. Open question B.
- Tags: unless stated, every part keeps the original lesson's exam tags.
- A prerequisite link is proposed only where the later part uses a meaning taught in the earlier part. The lead owns the final links.

---

## 1. Bill of Rights (39 added parts)

Current: 3 examples, no Traps section, 661 words. Gap parts: `general-information-philippine-constitution#18` to `#50`, `#53` to `#58`. (#51 and #52 are not in this lesson's list.)
Unsplit estimate: 661 + 39 × 75 = about 3,600 words, about 47 minutes at the median rate. Far over any single-lesson size.
Recommendation: split into 4 lessons by section ranges of Article III. Each part is 650 to 1,100 words.

| Part | Id | Title (proposed) | Sections | Gap parts | Parts | Est. words |
|---|---|---|---|---|---|---|
| 1 (keeps id) | `lesson-philippine-constitution-bill-of-rights` | Article III, Part 1: Due Process, Searches, and Basic Freedoms | Sec. 1 to 8 | #18 to #30: due process, equal protection, searches and seizures, privacy of communication, speech, press, assembly, petition, religion, abode, travel, public-concern information, association | 13 | 1,100 |
| 2 | `lesson-philippine-constitution-bill-of-rights-property-courts-and-custody` | Article III, Part 2: Property, Court Access, and Persons in Custody | Sec. 9 to 13 | #31 to #37: just compensation, contracts, court access, legal assistance, right to silence, counsel in custody, bail | 7 | 700 |
| 3 | `lesson-philippine-constitution-bill-of-rights-the-accused-and-the-trial` | Article III, Part 3: Rights of the Accused | Sec. 14 to 17 | #38 to #46: presumption of innocence, be heard with counsel, know the accusation, speedy impartial public trial, confront witnesses, compulsory process, habeas corpus limits, speedy disposition, self-incrimination | 9 | 850 |
| 4 | `lesson-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws` | Article III, Part 4: Detention, Punishment, and Limits on Laws | Sec. 18 to 22 | #47 to #50 (political-belief detention, involuntary servitude, excessive fines, cruel punishment), #53 to #55 (double jeopardy, ex post facto laws, bills of attainder), #56 to #58 (analyze violations, effects of violations, protection methods) | 10 | 900 |

Slugs for files: `bill-of-rights`, `bill-of-rights-property-courts-and-custody`, `bill-of-rights-the-accused-and-the-trial`, `bill-of-rights-punishment-detention-and-limits-on-laws`. Topic `philippine-constitution`. Question files follow the slug.

Where the existing content goes:
- Core Concept paragraph on "22 sections" and the Sec. 1 to 11 list: Part 1 (Sec. 1 to 8) and Part 2 (Sec. 9 to 11 of the old list). The old list of "Sections 12 to 22" splits across Parts 2, 3 and 4 by section number.
- Example 1 (count of sections) and Example 2 (section-range lookup): Part 1. Each later part opens with its own location example.
- Example 3 (no imprisonment solely for debt, Sec. 20): Part 4.
- Brief fix rows by passage: B03 (add Traps) applies to all 4 parts; L25 and L26 definitions move by term (ex post facto, bill of attainder, double jeopardy to Part 4; habeas corpus to Part 3; quasi-judicial to Parts 2 and 3); L27 habeas-corpus conditions (invasion or rebellion, public safety) to Part 3; L05 and L19 apply to Parts 1 and 4 (the old Examples 1 to 3); B08 applies everywhere; L02 simplification applies to every part.
- Parts 2 to 4 each define their own legal terms at first use. Do not rely on Part 1 for definitions; the style guide's reuse rule needs a prerequisite link for that.

Existing questions (20) by wording:

| Part | Existing question ids | Count | New questions needed |
|---|---|---|---|
| 1 | 0001 (section count), 0002 (due process), 0003 (speech and press), 0014 (search warrant condition), 0018 (association) | 5 | 15 |
| 2 | 0004 (just compensation), 0005 (contracts), 0012 (custodial right to silence), 0016 (bail), 0017 (poverty and court access) | 5 | 15 |
| 3 | 0006 (habeas corpus), 0007 (presumption of innocence), 0015 (self-incrimination), 0019 (speedy disposition) | 4 | 16 |
| 4 | 0008 (double jeopardy), 0009 (ex post facto), 0010 (bill of attainder), 0011 (imprisonment for debt), 0013 (prohibited punishment), 0020 (political belief and servitude) | 6 | 14 |

Prerequisites: Parts 2 and 3 need no earlier part. Part 4's three analysis parts (#56 to #58, analyze violations, effects, protection methods) need Parts 1 to 3: it applies the rights taught there. Proposed link: Part 4 requires Parts 1, 2 and 3 (reason: the analysis cases draw on liberties, custody rights and trial rights).
Tags: all parts cse-professional, cse-subprofessional, pupcet (same evidence rows as today).
Other lessons to relink: `the-articles-in-outline` Article III pointer should name Part 1.

---

## 2. Environmental concepts (27 added parts)

Current: 3 examples, no Traps section, 481 words. Gap parts: `general-information-environment-management#2` to `#7`, `#9` to `#11`, `#15` to `#32` (27 in all).
Unsplit estimate: 481 + 27 × 75 = about 2,500 words.
Recommendation: split. The 27 parts fall into six topics that do not depend on one another. This proposal works together with row 4 (laws). The laws lesson's DRRM, conservation, climate and local-response parts duplicate these topics (see "Overlaps" below), so teaching each topic once in a topic lesson avoids teaching DRRM twice.

Proposed result (the concepts lesson keeps its id and becomes the solid-waste lesson):

| Part | Id | Title (proposed) | Gap parts | Parts | Est. words |
|---|---|---|---|---|---|
| 1 (keeps id) | `lesson-environment-management-environmental-concepts` | Solid Waste: Segregation and Diversion | #2 to #7 (recycling, reuse, four waste categories), #9 to #11 (reduction, reuse, recycling as diversion) | 9 | 1,000 |
| 2 | `lesson-environment-management-disaster-risk-reduction-and-management` | Disaster Risk Reduction and Management (RA 10121) | #18 to #22 (prevention and mitigation, preparedness, response, rehabilitation and recovery, broader than response alone); plus laws #47 to #50 moved in | 5 + 4 | 900 |
| 3 | `lesson-environment-management-environmental-problems-and-climate-change` | Environmental Problems and Climate Change | #23 and #24 (local problems, government response), #25 to #28 (climate effects: general, political, economic, social); plus laws #44 and #63 moved in | 6 + 2 | 900 |
| 4 | `lesson-environment-management-species-resources-and-environmental-decisions` | Protecting Species and Resources, and Choosing Among Options | #29 (decisions and alternatives), #30 (human impact on ecosystems), #31 and #32 (species and resource conservation actions); plus laws #53, #54, #56, #64, #65, #66 moved in | 4 + 6 | 1,050 |

The 3 remaining gap parts of this lesson, #15 to #17 (Environmentally Critical Project, Environmentally Critical Area, PD 1586 and the EIS system), move to the laws lesson (row 4), where PD 1586 is already taught as a law. The ECC example moves with them.

Where the existing content goes:
- Core Concept bullets: segregation and diversion stay in Part 1. The ECC bullet moves to the laws lesson. The DRRM bullet moves to Part 2.
- Example 1 (segregation) and Example 2 (diversion): Part 1. Example 3 (ECC): laws lesson.
- Brief fix rows by passage: B03 (Traps) applies to every part; L18 and L26 apply where the quoted passage lands; the two L25 rows (undefined terms) follow their terms; L02 and B08 apply everywhere.

Existing questions (20 in the file: ids 0001 to 0004 and 0007 to 0022; 0005 and 0006 are not in the file) by wording:

| Part | Existing question ids | Count | New questions needed |
|---|---|---|---|
| 1 solid waste | 0001, 0002, 0008, 0009, 0010, 0011, 0012, 0013, 0019, 0020, 0021 | 11 | 9 |
| 2 DRRM | 0004, 0007, 0016, 0017, 0018, 0022 | 6 | 14 |
| laws lesson (ECC) | 0003, 0014, 0015 | 3 | see row 4 |
| 3 problems and climate | none | 0 | 20 |
| 4 species and decisions | none | 0 | 20 |

Overlaps found in the gap rows (for the lead): laws #47 to #50 repeat concepts #18 to #21 (DRRM domains); laws #64 and #65 repeat #30 to #32; laws #63 repeats #24; laws #66 repeats #29; laws #67 to #70 are already marked as duplicates of #25 to #28. Taught once in a topic lesson, the 44 parts reduce to about 36 distinct teaching units.

Prerequisites: Part 1 none. Part 2 none. Part 3 none. Part 4 uses climate and local-problem ideas lightly; proposed link: Part 4 after Part 3 (reason: the decision cases weigh climate and local-problem effects). Laws lesson links forward to Parts 1 to 4 for detail (not a prerequisite).
Tags: Parts 1, 2 and the laws lesson keep cse-professional and cse-subprofessional. Parts 3 and 4 carry curriculum-tier rows (`cse-professional-L055`, `L107`, AP10 competencies): tag cse-professional and cse-subprofessional like the original, but record in the ledger that these two parts rest on curriculum evidence.

---

## 3. Articles in outline (18 added parts)

Current: 3 examples, no Traps section, 443 words. Gap parts: `general-information-philippine-constitution#63` to `#78` (16 article-location parts), `#81` (Preamble purpose), `#83` (apply state principles and policies, absent).
Unsplit estimate: about 1,400 words.
- Existing: 443.
- Sixteen location parts: 10 articles get a one-line statement of what they cover (about 28 words each) and 6 point to the new lessons or to the Bill of Rights lessons (about 20 words each, for Articles III, IV, V, VI, VII, VIII and XVII): about 400.
- Preamble purpose (#81): about 70.
- Article II state principles (#83): about 160 for the main principles in plain words.
- Three new examples (Preamble purpose, apply one state policy, locate a topic by its question): about 210.
- Two new traps: about 100.

Recommendation: keep as one lesson. It stays a locator lesson with one line per article.
Tripwire: if the first draft passes 1,550 words, move #83 to a new lesson `lesson-philippine-constitution-article-ii-principles-and-state-policies` (title "Article II: Declaration of Principles and State Policies", about 700 words). Applying state principles is the only part here that needs real teaching; the other 17 are one-liners.
Note: #66, #67, #68 to #70 and #77 locate Articles IV, V, VI, VII, VIII and XVII, which the 3 new Constitution lessons teach. The lines here should link to them and not repeat rules.
Existing questions: all 20 stay (they test article locations and the outline). No move.
Prerequisites: none. This lesson is the map; the new lessons point back to it as useful context.

---

## 4. The environmental laws (17 added parts)

Current: 3 examples, no Traps section, 613 words. Gap parts: `general-information-environment-management#35`, `#38`, `#40`, `#41`, `#44`, `#47` to `#50`, `#53`, `#54`, `#56`, `#57`, `#63` to `#66` (17 in all).
Unsplit estimate: 613 + 17 × 75 = about 1,900 words.
Recommendation: split by moving parts into the topic lessons proposed in row 2. This creates no new id. The lesson keeps its id and becomes the "which law, which agency" lesson. It ends at about 1,200 words.

| Destination | Gap parts | Count |
|---|---|---|
| Stay in the laws lesson | #35 (RA 9003 segregation and diversion lookup), #38 (RA 8749 toxic-fume incineration condition), #40 (Water Quality Management Areas), #41 (wastewater-discharge regulation), #57 (DENR governance) | 5 |
| Arrive from the concepts lesson | #15, #16, #17 (ECP, ECA, PD 1586 and the EIS system, with the ECC example) | 3 |
| Move to DRRM lesson (row 2, Part 2) | #47, #48, #49, #50 | 4 |
| Move to problems and climate lesson (row 2, Part 3) | #44 (National Strategic Framework on Climate Change), #63 (government responses to local problems) | 2 |
| Move to species and decisions lesson (row 2, Part 4) | #53, #54 (RA 9147), #56 (protected areas), #64, #65, #66 | 6 |

Net: 17 − 12 + 3 = 8 parts, 613 + 8 × 75 = about 1,200 words.
The law bullets stay in the Core Concept as identification (law number, short title, one line). The topic lessons teach how each law works.

Existing questions: all 20 stay in this lesson plus the 3 ECC questions from the concepts file (0003, 0014, 0015 of that file), 23 in total. They test law and agency identification, which is what this lesson keeps. Optional reassignments, if the lead wants each topic lesson to start with some questions: 0005 (RA 10121) to the DRRM lesson; 0004, 0010, 0018 (climate law items) to the problems and climate lesson; 0007, 0008, 0013, 0019 (wildlife and protected areas) to the species lesson. Recommended: leave them here.
Prerequisites: none needed. Forward links only.
Tags: unchanged.
Fix rows: the 11 rows (B01 fact check, B03, L18, B08, L02, three L19, L25, L26, L27) follow their passages. B01 (fact check on a quoted passage) stays with the laws lesson unless the quoted text moves.
If the lead rejects the row 2 split: split this lesson alone into `the-environmental-laws` (pollution and compliance: #35, #38, #40, #41, #57, with PD 1586 added) and a new `lesson-environment-management-wildlife-climate-and-disaster-laws` (the other 12), which duplicates DRRM teaching with the concepts lesson. Not recommended.

---

## 5. Duties and prohibited acts (16 added parts)

Current: 3 examples, no Traps section, 898 words. Gap parts: `general-information-code-of-conduct-ra-6713#2`, `#6`, `#8`, `#9`, `#11`, `#19` to `#28`, `#33`.
Unsplit estimate: 898 + 16 × 75 = about 2,100 words. The gift exceptions alone (#19 to #27) are 9 parts.
Recommendation: split into 2 lessons: duties (Sec. 5) and prohibited acts with gift rules (Sec. 7). One lesson cannot hold the 8 gift exceptions with conditions and a worked classification case.

| Part | Id | Title (proposed) | Gap parts | Parts | Est. words |
|---|---|---|---|---|---|
| 1 (keeps id) | `lesson-code-of-conduct-ra-6713-duties-and-prohibited-acts` | Duties of Public Officials under RA 6713 (Section 5) | #2 (failure to respond as administrative ground), #6 (reasonable time), #8 (attend promptly), #9 (public-document access), #33 (who is covered: public official, employee, volunteer; Code coverage versus separate SALN exemptions) | 5 | 750 |
| 2 | `lesson-code-of-conduct-ra-6713-prohibited-acts-and-gift-rules` | Prohibited Acts and Gift Rules under RA 6713 (Section 7) | #11 (outside roles in regulated enterprises), #19 to #26 (eight gift exceptions), #27 (apply exceptions to a scenario), #28 (post-service continuation of other outside-employment limits) | 11 | 1,270 |

Where the existing content goes: "Duties and Response Deadlines" and Examples 1 and 3 (15 working days, three signatories): Part 1. "Prohibited Acts and Transactions", "Exceptions to the Gift Rule", Example 2 (1-year restriction): Part 2. Brief fix rows by passage: the large L18 row (examples do not cover every case) is split between the parts; L25, L26, L27 follow their passages; B03 (Traps) applies to both.
If Part 2 passes 1,450 words in draft, move the gift material (#19 to #27) to a third lesson `lesson-code-of-conduct-ra-6713-gifts-and-their-exceptions` (about 900 words), leaving prohibited acts at about 660.

Existing questions (20) by wording:

| Part | Existing question ids | Count | New questions needed |
|---|---|---|---|
| 1 duties | 0001 (15 days), 0002 (signatories), 0003 (45 working days), 0006 (failure to respond), 0009 (document access), 0012 (reply content), 0017 (absent signatory) | 7 | 13 |
| 2 prohibited acts and gifts | 0004, 0005, 0007, 0008, 0010, 0011, 0013, 0014, 0015, 0016, 0018, 0019, 0020 | 13 | 7 |

Prerequisites: Part 2 requires Part 1 (reason: who is covered by the Code, taught in Part 1 as #33, and the Section 5 duties it contrasts with). Both are used by the new corruption lesson (outlined in the other file) and by `penalties-and-enforcement`.
Tags: unchanged for both (cse-professional, cse-subprofessional).
The corruption gap parts (#29 to #32) already left this lesson for the new corruption lesson, so they do not count in the 16.

---

## 6. Tenses and voice (14 added parts)

Current: 4 examples, 5 traps, 909 words. Gap parts: `language-proficiency-grammar-and-structure#77`, `#79`, `#84` (English), `#88` to `#93` and `#104` (Filipino), `#94` to `#97` (English modals).
Unsplit estimate: 909 + 14 × 80 = about 2,000 words.
Recommendation: split into 2 lessons, English and Filipino. The reason is more than length. The Filipino parts are evidenced only by the CSE files (`cse-professional-L034`, `cse-subprofessional-L046`, `L096`). The English lesson today carries 9 exam tags. UPCAT, ACET, DCAT, USTET, DOST-SEI and SM Foundation do not evidence Filipino verb aspect, and PUPCET only weakly (`pupcet-L081`, general Filipino grammar preparation). A separate Filipino lesson can carry the narrower tags.

| Part | Id | Title (proposed) | Gap parts | Parts | Est. words |
|---|---|---|---|---|---|
| 1 (keeps id) | `lesson-grammar-and-structure-tenses-and-voice` | Tenses, Aspect, and Voice of Verbs (Active vs. Passive) | #77 (future *will*), #79 (present perfect and its link to the present), #84 (get-passive), #94 to #97 (modals: ability, permission, obligation, possibility) | 7 | 1,400 |
| 2 | `lesson-grammar-and-structure-filipino-verb-aspect-and-focus` | Verb Aspect and Focus in Filipino / Aspekto at Pokus ng Pandiwa | #88 (completed), #89 (ongoing), #90 (contemplated), #91 (recently completed), #92 (form variation), #93 (voice and focus relations), #104 (time adverbs and phrases) | 7 | 800 |

Where the existing content goes: "Sa Filipino: Aspekto at Voice/Focus" section (about 105 words), Trap 5 (Filipino aspect is not English tense) and the question on *kumain/kumakain/kakain*: Part 2. All other sections and Examples 1 to 4: Part 1. Part 2 is written in simple Filipino (style guide, Filipino-language section); any Filipino spelling a model cannot confirm against the KWF goes to Aedwon's list (plan rule).
Tripwire: if Part 1 passes 1,500 words in draft, move the four modals (#94 to #97) to `lesson-grammar-and-structure-modal-verbs` (about 450 words).

Existing questions (20) by wording:

| Part | Existing question ids | Count | New questions needed |
|---|---|---|---|
| 1 English | 0001 to 0007, 0012 to 0020 | 16 | 4 |
| 2 Filipino | 0008 (perfective *kain*), 0009 (imperfective), 0010 (contemplated), 0011 (focus of *Kinain ng bata ang mangga*) | 4 | 16 |

Prerequisites: Part 2 has no English prerequisite. Part 1 has none. The existing `pronoun-antecedent-agreement` lesson holds the Filipino pronoun parts; no link needed.
Tags: Part 1 keeps all 9 current tags. Part 2: cse-professional and cse-subprofessional; add pupcet only if the lead accepts weak evidence (`pupcet-L081`). The question files must keep their own `meta.exams` in line with the lesson tags (Part 2 questions: `cse-pro`, `cse-sub`).

---

## Open questions for the lead

A. May an existing question move to a new part's file with its id unchanged? This decides whether the mapping tables above hold or all new parts start with all-new questions.
B. Briefs are per lesson id. Should the brief builder be rerun after the new ids exist, or should the lead hand-split the briefs for the 6 lessons?
C. Titles: the first part keeps its id, but its title changes in every split (for example "Part 1" labels). Is a title change acceptable under "keeps the original id"?
D. Environment: approve the joint layout (4 topic lessons plus the laws lesson), or keep the two lessons separate and accept duplicated DRRM and conservation teaching?
E. Bill of Rights: 4 parts (recommended) or 3 parts (merge Parts 2 and 3 into one lesson of about 1,550 words, over the comfortable ceiling)?
F. Tenses: confirm that the Filipino lesson takes narrower exam tags than the English lesson.
G. Estimates use 75 words per part. The pilot should replace this with a measured number; if the real figure is higher, the articles-in-outline lesson (borderline) will need its tripwire split.

## Lead decisions, October 25

1. An existing question may move to a new part's question file with its id unchanged. The
   importer takes the lesson link from the file's `meta.subtopic` and does not check the id
   prefix, and student history is keyed by id, so history is kept.
2. The three branches lesson stays one lesson, with the same 1,550-word tripwire as the articles
   lesson.
3. The corruption lesson is tagged CSE Professional and Subprofessional: the organizer names
   R.A. 6713 for both, and the lesson supports that area.
4. New lessons and split parts get `outline.json` entries.
5. Briefs are rebuilt after the split ids exist.
6. Splits wait for Aedwon's go-ahead: they add lessons and new questions (each new lesson needs
   20 active questions).
