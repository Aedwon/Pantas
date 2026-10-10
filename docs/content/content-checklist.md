# Content Checklist

One line per rule, for authors before submitting and for reviewers and judges
afterward. Each line cites the section that states the rule; the wording there
governs. Subject blueprints in `question-blueprints/` add subject rules on top.

## Severity and the pass rule

- **Blocker:** a wrong fact, a wrong or ambiguous answer, a broken student
  history, or required content missing.
- **Major:** breaks a rule in a way that hurts learning or breaks the import.
- **Minor:** style or formatting.

Content passes only with **no blocker and no major**. New or edited content
must also fix every minor finding. Existing content fixes minor findings when
the item is edited for another reason. Every finding names the rule id and the
evidence: the text at fault and, for facts, the source.

Ids: `B` applies to lessons and questions, `L` to lessons, `Q` to questions.
Guide names: LSG is [lesson-style-guide.md](lesson-style-guide.md), QSG is
[question-style-guide.md](question-style-guide.md), SP is
[source-policy.md](source-policy.md), EFP is
[exam-format-profiles.md](exam-format-profiles.md).

## Both

| Id | Rule | Severity | How to check | Source |
|---|---|---|---|---|
| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| B02 | Every worked answer, example answer, and key is correct | Blocker | Solve it yourself from the question alone | LSG: Examples section; QSG: Blind solve |
| B03 | Required content is present: outline sections, required figures | Blocker | Compare with the outline entry and figure needs | LSG: Section structure, Illustration placeholders |
| B04 | Each checked fact has a source ledger entry, in a ledger that states its branch, base commit, and access date | Major | Find the item id in the round's ledger | SP: How sources are recorded |
| B05 | The higher source wins, the conflict is recorded, and weak sources are never used alone | Major | Compare the cited source with the hierarchy | SP: Which source wins |
| B06 | No em dashes | Minor | Search for the character | LSG: Emphasis and de-AI rules; `AGENTS.md` |
| B07 | American spelling in English text | Minor | Look for British forms such as "colour", "practise" | `AGENTS.md`: Voice |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| B09 | "points" not "marks", "questions" not "cards" | Minor | Search the text | `AGENTS.md`: Voice |
| B10 | No FSRS, stability, retention, retrievability, or algorithm in student text | Major | Search the text | `AGENTS.md`: Voice |

## Lessons

L25 to L27 follow the shared explanation-reuse rule in the lesson guide's
Teaching completeness section. Check actual prerequisite teaching or the
clearly identified later explanation, not a prior mention alone. Confirm that
students have the meaning needed for the intervening teaching and that the
current lesson still teaches its own learning goal.

| Id | Rule | Severity | How to check | Source |
|---|---|---|---|---|
| L01 | A learning goal is recorded and the lesson serves it | Major | Find the goal in the audit records; compare with the content | LSG: Learning goal |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam verbs are explained in one line on first use | Minor | Find the first use of each exam verb | LSG: Voice |
| L04 | At most one analogy, in Core Concept | Minor | Count analogies | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L06 | In-lesson quiz items meet every Q rule | Per Q rule | Run the question checks | LSG: Voice |
| L07 | Mentions of exams vary and motivate | Minor | Look for repeated openers | LSG: Voice |
| L08 | Filipino lessons teach in simple Filipino at the Grade 5 standard | Major | Read as a Grade 5 student | LSG: Filipino-language lessons |
| L09 | A hard Filipino grammar term gets a short English gloss on first use only | Minor | Find first uses | LSG: Filipino-language lessons |
| L10 | Filipino lessons' examples and quiz items are in Filipino | Major | Check each example and item | LSG: Filipino-language lessons |
| L11 | Filipino spelling and usage follow the Komisyon sa Wikang Filipino | Major | Check contested forms against the source | LSG: Filipino-language lessons |
| L12 | No Taglish in Filipino teaching prose | Minor | Flag English words that are not the common term | LSG: Filipino-language lessons |
| L13 | No ALL-CAPS emphasis; bold for first definitions; italics rare | Minor | Scan for capitals and emphasis | LSG: Emphasis and de-AI rules |
| L14 | Target words are bold and the prompt says "the word in bold" | Major | Check prompts that refer to a word | LSG: Emphasis and de-AI rules |
| L15 | No stock AI phrasing; varied sentence openings; a plainly varied summary | Minor | Search for the listed phrases; read openings | LSG: Emphasis and de-AI rules |
| L16 | Section titles are exact; mnemonics only when genuine; extra sections sparing | Minor | Compare headings with the guide | LSG: Section structure |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions show every step as a numbered list with display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L20 | Example and trap headings use `### #N: Title`; traps have a one-line warning and a short explanation | Minor | Compare with the format | LSG: Examples section, Traps section |
| L21 | Display equations fit a phone screen | Minor | Look for long display lines | LSG: Examples section |
| L22 | Only allowed formatting: no tables, links, code blocks, or horizontal rules | Major | Search for the banned syntax | LSG: Formatting rules |
| L22a | Paragraphs are one to three short sentences; bullet lists are sparing | Minor | Scan paragraphs | LSG: Formatting rules |
| L23 | Each placeholder is one specific line an artist could draw from; the prose teaches without the image except where the figure is the question (missing required figures fall under B03) | Major | Read each placeholder | LSG: Illustration placeholders |
| L24 | Frontmatter has the exact shape and outline slugs | Major | Compare with the template and the outline | LSG: Frontmatter |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |

## Questions

| Id | Rule | Severity | How to check | Source |
|---|---|---|---|---|
| Q01 | The blind solver's answer matches the key | Blocker | A non-author answers without the key, explanation, or notes | QSG: Blind solve |
| Q02 | Exactly one correct choice, and no wrong choice is also defensible | Blocker | Argue for each wrong choice; check the key flag | QSG: Field rules, Coverage discipline |
| Q03 | An existing id is never renumbered or reused; new questions take the next unused number | Blocker | Compare ids with the previous version | QSG: Field rules |
| Q03a | In a new file, id numbers rise with difficulty | Minor | Compare id order with difficulty | QSG: Field rules |
| Q04 | File path and `meta` match the outline lesson | Major | Compare with the outline | QSG: File layout, Document shape |
| Q05 | `meta.exams` follows the current exam tags | Major | Compare with the runbook table or the audit's tags | Question runbook: Topic → exam table |
| Q06 | No choice depends on position or letter ("all of the above", "both A and B") | Blocker | Search choice text | QSG: Field rules |
| Q06a | "None of these" or "All of these" only when the exam's profile shows that style | Major | Compare with the profile | QSG: Field rules; EFP |
| Q07 | Choice text that YAML would misread is quoted correctly | Major | Run the importer | QSG: Field rules |
| Q08 | `difficulty` stays authoring-only; `figure`, `passage`, and `approved` follow their rules | Major | Compare fields with the guide | QSG: Field rules |
| Q09 | `type` is an archetype from the subject blueprint | Minor | Compare with the blueprint list | QSG: Field rules |
| Q10 | `stem` and `explanation` are block scalars | Minor | Check the YAML | QSG: Field rules |
| Q11 | Stem and choices use authentic target-exam wording and difficulty, ramping easy to exam level | Major | Compare with the exam's profile and the set's ramp | QSG: Two-level voice; EFP |
| Q12 | Format matches the exam's profile; unknown entries follow DepEd conventions and are reported as gaps | Major | Compare choice count, item type, and style with the profile | QSG: Exam format profiles |
| Q13 | Negative stems only where the profile shows them, with the negative word in bold | Minor | Search for NOT and EXCEPT | QSG: Exam format profiles |
| Q14 | Wrong choices are plausible and based on a real mistake or misconception | Major | Name the mistake behind each wrong choice | QSG: Two-level voice, Coverage discipline |
| Q15 | No answer-giving clues: length, grammar, form, repeated words, or one item answering another | Major | Try to answer without the content knowledge | QSG: No answer-giving clues |
| Q16 | The explanation says only why the correct answer is correct, in simple language, with steps when solving is involved | Major | Check for mentions of wrong choices and skipped steps | QSG: Two-level voice |
| Q17 | Every wrong choice has a note of two or three short sentences: the mistake, why it looks right, one check; it describes the choice, not the student, and does not restate the solution | Major | Check each note's three parts | QSG: Two-level voice |
| Q18 | Filipino-language items are in Filipino, with simple Filipino explanations and notes, and spelling per the Komisyon sa Wikang Filipino | Major | Check stem, choices, explanation, and notes | QSG: Filipino-language items |
| Q19 | Each archetype has two or three genuinely different variants, at least 20 active questions per lesson, no near-duplicates | Major | Count active items; compare scenarios | QSG: Coverage discipline |
| Q20 | Questions supply necessary problem-specific information and referenced material without supplying formulas, definitions, or methods students are expected to know or select | Blocker if the answer is indeterminate, otherwise Major | Solve from the supplied material and expected knowledge; check needed units, rounding, and any recorded formula exception | QSG: Problem information and expected knowledge |
