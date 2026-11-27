# Question-file findings for the question owner (from the lesson lane's Codex audits)

Manager ruling (Nov 27, about 2 AM Manila): the lesson lane does not edit question files. Rows are listed here for the owner. Source: Grammar round 6 Codex audit at `81f4db5bc` (`codex-grammar-r6.md`, line numbers in that report). Vocabulary round 2 and Grammar round 5 had no question-file rows. All files are under `content/questions/language-proficiency/grammar-and-structure/`.

| # | Severity | File:line (question) | Finding | Codex's suggested fix |
|---|---|---|---|---|
| 1 | Blocker | tenses-and-voice.yaml:548 (q 0032) | Asks only for a regular duty; both *sorts* and *sorted* express a regular duty on different timelines. | Say the officer still does it on every working day and key *sorts*. |
| 2 | Blocker | modifiers.yaml:212, 410 (q 0010, 0019) | Ask which wording preserves near-frequency or near-quantity, and mark preverbal *almost* wrong, though the lesson recognizes that reading as possible. | Ask which wording makes the meaning clearest, or replace the ambiguous distractors. |
| 3 | Major | sentence-structure.yaml:322 (q 0015) | Lists *if the rain stops* and *when the guests arrive* as separate dependent groups; the full *if* clause contains the *when* clause. | Use nested brackets as the lesson does. |
| 4 | Major | parts-of-speech.yaml:410, 432 (q 0019, 0020) | Label *we finished dinner* and *the bell rang* as the subordinate clause without the connector. | Include *before* in each full subordinate clause. |
| 5 | Major | parallelism.yaml:256 (q 0012) | Can be read as rejecting grammatical lists because one topic is a *how to* clause; the tested requirement is matching forms. | Ask which option names all three topics with noun phrases. |
| 6 | Major | parts-of-speech.yaml:501 (q 0023) | Assumes *sa bodega* modifies *sinuri*; it can also identify which boxes. | Supply the fact in the stem or move *sa bodega* to the front. |
| 7 | Major | parallelism.yaml:322 (q 0015) | Calls *how to manage a team* an error without saying the task requires matching forms. | Specify three noun phrases in the second list. |
| 8 | Major | sentence-structure.yaml:36, 124 (q 0002, 0006) | Say there are no dependent clauses without the finite-clause convention the lesson uses. | State the finite-clause convention in the stems or explanations. |
| 9 | Minor | pronoun-antecedent-agreement.yaml:278 (q 0013) | English label *set* in a Filipino stem. | Use *pangkat ng ang*, as the explanation does. |
| 10 | Minor | parts-of-speech.yaml:524 (q 0024) | *nasa bold* in a Filipino stem. | Use *salitang nakadiin*. |
| 11 | Minor | pronoun-antecedent-agreement.yaml:234 (q 0011) | Explanation of a Filipino item entirely in English. | Write it in simple Filipino. |
| 12 | Minor | filipino-verb-aspect-and-focus.yaml:77 (q 0011) | Glosses *pokus* as *focus* in a quiz stem. | Use *pokus* alone. |

## Status: all 12 rows closed (Nov 27)

Settled by the release lead on branch `content/cse-question-fixes-r1`, commit `22b8ccc2f` (based on the content root; on staging; prod after the opening). Record: `docs/content/verification/fix-grammar-question-findings-r1.md` on that branch. Per the commit message: rows 1, 2, 3, 4, 8, 9, 11 and 12 fixed in stems, explanations and notes only (11 questions); rows 5, 6, 7 and 10 need no change. No answer key changed, and every trap choice these lessons cite is unchanged. (The manager's note said 9 real and 3 no change; the commit lists 8 and 4. The commit is the record.)

When these lessons move to the content root, take the root's copies of those 11 questions, never this branch's.

Lead's note: rows 1, 2 and 4 matter most, since a student who learns the lesson's rule could be marked wrong. Each needs the question process (blind solve, `approve.dart`) in its own commit.

## Round 8 full read (Nov 27, session 5): one new row, open

| # | Severity | File:line | Problem | Fix |
|---|---|---|---|---|
| 13 | Blocker | pronoun-antecedent-agreement.yaml:108 (q 0005) | The stem says "Choose the pronoun referring to its policy", which prints the keyed form *its* before the student answers. Still present at `22b8ccc2f`. | Say "referring to the company's policy." |

Sent to the manager for the release lead (question owner). This lane does not edit it.
