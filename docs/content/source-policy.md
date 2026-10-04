# Source Policy

Applies to every lesson and question, in English and Filipino. Companion to
[lesson-style-guide.md](lesson-style-guide.md),
[question-style-guide.md](question-style-guide.md), and
[content-checklist.md](content-checklist.md).

## What needs a source

Mathematics you verify by solving. Every other fact that is easy to
misremember must be checked against a source before it is written:

- scientific constants, values, and units;
- taxonomy, anatomy, and other naming details;
- dates, names, and historical claims;
- laws, statutes, and government rules (Civil Service General Information);
- Filipino grammar, usage, and spelling rules and their examples;
- any claim about an exam's coverage, format, or rules.

If a fact cannot be confirmed, leave it out. Do not approximate it or replace
it with a plausible version.

## Which source wins

When sources disagree, the higher one wins. Record the conflict in the ledger.

1. **The exam organizer.** What an exam tests and how its items look: the
   organizer's own publications, such as UP, DOST-SEI, or the Civil Service
   Commission.
2. **The Philippine curriculum.** DepEd curriculum guides and learning
   competencies, for what students have already met and the terms they know.
3. **Standard references for the subject.** Primary law texts (Official
   Gazette, LawPhil), IUPAC for chemical naming, CODATA for physical
   constants, and Komisyon sa Wikang Filipino publications, including the
   Ortograpiyang Pambansa, for Filipino spelling and usage.
4. **Other reputable sources.** University, government, and established
   reference publishers. Unofficial reviewers, forums, and document-sharing
   uploads are weak evidence. Never use them alone for a fact a student will
   be scored on.

This order is standard practice, not the result of a study. It may be refined
when an audit finds a better source for a subject.

## How sources are recorded

Sources go in the audit records, not in the lesson or question text. Use the
source ledger table already used by question QA (see
`audit/question-qa-r1-source-ledger.md`):

| Item | Issue | Original content / claim | Disposition | Source | Verification note |
|---|---|---|---|---|---|

- **Item:** lesson id or question id. Question ledgers may title it Question.
- **Disposition:** for example CONFIRMED, CORRECTED, RETIRE, LESSON GAP.
- **Source:** name and URL, plus section or page where one exists.
- **Verification note:** what the source says and how the content now matches.

Each ledger states its branch, base commit, and access date at the top. Keep
one ledger per audit round and subject under `docs/content/audit/`.

## Learning goals

Each lesson has a learning goal in the same audit round's records, keyed by
lesson id. It has one or two sentences: what a student can do after the lesson,
and which exam requirement that serves. Students do not see it. It is not a
frontmatter field.
