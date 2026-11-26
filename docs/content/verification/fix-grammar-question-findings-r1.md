# Verification Record: Grammar question-file findings (12 rows)

- Date: November 27, 2026 (Manila)
- Author: CSE release lead r9b (Opus 5.5). Policy: `Aedwon/Pantas` main 6a2b2ec97.
- Source: `docs/content/verification/walkthrough-work/question-file-findings.md` on `content/lesson-walkthrough-cse-r1` 461a24ae0 (Codex Grammar round 6 audit at 81f4db5bc).
- Branch: `content/cse-question-fixes-r1`, based on the content root `content/cse-key-fixes-r1` 7dcc42ad6 (the tree staging serves). Main's question files are older (for example tenses-and-voice is 413 lines on main, 592 on the root, and filipino-verb-aspect-and-focus does not exist on main), so the audit's line numbers and the served questions exist only on the root.
- Rules checked: `docs/content/question-style-guide.md` and `docs/content/lesson-style-guide.md` (main), the walk-through lessons each question cites (on `content/lesson-walkthrough-cse-r1`), and the KWF Filipino rules the lesson guide names.
- Constraint kept: every wrong-choice text cited in `content/walkthrough-trap-evidence.json` on the walk-through branch is byte-identical. Only stems, explanations and notes changed.

## Classification

| # | Question | Verdict | Change or reason |
|---|---|---|---|
| 1 | tenses-and-voice-0032 | Real defect | "sorted" can state a past regular duty. The stem now says the officer still performs the duty, as the lesson's pair says ("Here the duty continues now"). Note and explanation follow. |
| 2 | modifiers-0010, 0019 | Real defect | The lesson says "almost" before a verb can mean either a near action or a mostly done action, so the before-verb choices are unclear, not plainly wrong. Stems now ask which sentence states the meaning most clearly; notes say the before-verb reading is unclear. |
| 3 | sentence-structure-0015 | Real defect (explanation only; key right) | The explanation split the "if" clause. It now says the "when" clause sits inside the "if" clause, as the lesson brackets it. |
| 4 | parts-of-speech-0019, 0020 | Real defect (explanation only; keys right) | The explanations named "we finished dinner" and "the bell rang" as the subordinate clauses; the lesson names "before we finished dinner". They now include "before". No student could be marked wrong here: both keys were already correct. |
| 5 | parallelism-0012 | No change | The stem asks for "correct parallel structure", which is matching forms. The distractors are grammatical but not parallel by design; this is the standard item. |
| 6 | parts-of-speech-0023 | No change | The stem asks for the group that names the place of the checking, which fixes the adverb reading. The walk-through lesson's pair uses the same sentence and reading. No other choice is a place. |
| 7 | parallelism-0015 | No change | The stem says "parallelism errors". "How to manage a team" in a list of noun topics is the standard parallelism error. |
| 8 | sentence-structure-0002, 0006 | Real defect (minor) | The explanations now state the lesson's convention: a clause needs its own subject and a verb with tense, so "to travel abroad" and "to play" are phrases. |
| 9 | pronoun-antecedent-agreement-0013 | Real defect (minor) | English "set" in a Filipino stem; now "pangkat ng". |
| 10 | parts-of-speech-0024 | No change | The lesson guide prescribes "the word in bold" for target words. "Nakadiin" would collide with "diin" (word stress), a Filipino grammar topic. The corpus uses "nasa bold" 29 times; changing one item adds inconsistency. |
| 11 | pronoun-antecedent-agreement-0011 | Real defect | The style guide requires simple Filipino in notes and explanations of Filipino items. All three notes and the explanation are now in Filipino. |
| 12 | tenses-and-voice-0011 (in filipino-verb-aspect-and-focus.yaml) | Real defect (minor) | Dropped the "(focus)" gloss from the stem; glosses belong in lessons, not exam stems. |

## Independent blind solve (key, explanation and notes hidden; choices reordered)

One Sonnet 5.5 solver, given only stems and shuffled choices (`blind-solve.md` in the r9b scratchpad).

| Question | Blind solve | Key | Verdict |
|---|---|---|---|
| tenses-and-voice-0032 | sorts | sorts | AGREE |
| modifiers-0010 | The cyclists rode to school almost every day. | same | AGREE |
| modifiers-0019 | The curator displayed almost all the vases. | same | AGREE |
| sentence-structure-0015 | Complex | Complex | AGREE |
| sentence-structure-0002 | Compound | Compound | AGREE |
| sentence-structure-0006 | Compound | Compound | AGREE |
| parts-of-speech-0019 | Subordinating conjunction | same | AGREE |
| parts-of-speech-0020 | (1) Adverb, (2) Adjective, (3) Adverb, (4) Conjunction | same | AGREE |
| pronoun-antecedent-agreement-0013 | Siya | Siya | AGREE |
| pronoun-antecedent-agreement-0011 | Hindi nagsasaad ng kasarian | same | AGREE |
| tenses-and-voice-0011 | Pokus sa bagay (ang mangga) | same | AGREE |

The solver flagged a second defensible answer on two items and refuted both in its own line ("niya" is ng-group; "ng bata" is not the focus). No second defensible answer.

## Independent review

Codex GPT 6.2 Sol, high effort, through `codex-pick` (account b), read-only, input closed. It re-solved the changed items and agreed with all 12 classifications. All cited wrong-choice texts stayed byte-identical. It found three new wording defects, all fixed before approval:

- tenses-and-voice-0032 "sorted" note implied the past tense means the duty ended. Now it only says the form puts the duty in past time and points to the stem's "still performs".
- sentence-structure-0002 and 0006 stated the clause convention as universal. Stems and explanations now say "In traditional school grammar", as the lesson and parts-of-speech-0019 do.
- pronoun-antecedent-agreement-0011 third note said "siya" is for people; the walk-through lesson also allows pets. Now "karaniwang para sa tao".

Its other note, kept as is: in parts-of-speech-0019 the key "Subordinating conjunction" is one letter longer than "Coordinating conjunction". This was already so, and it is inherent to the term.

The stem changes to 0002 and 0006 add only the convention clause; the blind-solve keys still hold.
