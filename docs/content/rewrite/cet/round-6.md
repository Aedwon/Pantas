# Round 6: closing the 12 open lessons

November 9, 2026. Policy read from origin/main eea141566. Branch `content/cet-finish-r1` from `content/cet-rewrite-r1` at 29fae75fd.

Aedwon, through the manager thread: "for the rest of items, please finish them". Usage limits from Aedwon: "please don't parallelize so much because you have limited usage"; one careful read per lesson, one at a time.

## Why a narrower round

Rounds 1 to 5 were full reads. Each one found one or two new narrow exceptions, and in about half the open lessons the fix's own new wording caused one. A sixth full rework would likely repeat that. So this round changes as little text as possible and checks every changed sentence hard.

## Steps per lesson

1. **Fix (Sonnet 5.5).** Fix every round-5 Blocker and Major for the lesson (`reads/round-5/<id>.json`; meiosis: `reads/split/round-5/`), except those `final-run-rulings.md` downgrades or rejects. Fix a round-5 Minor too when it is one sentence. Change only the sentences a finding names, plus a sentence that must change to stay consistent with them. Do not reword anything else and do not sweep the lesson.
2. **Every new or changed sentence** is tested before it is kept:
   - Prefer a stated scope ("For a diploid organism, ...", "When both forces are at right angles to the bar, ...") over a new absolute. Do not add "only", "always", "never", "every", "all", "must", "cannot" unless you have tested the claim.
   - Test it against the round-5 finding's counterexamples, against the lesson's own other sections and examples, and against one more known exception you look for.
   - Check it against a source (OpenStax, IUPAC, BIPM, or a standard text). Record the source in the report.
3. **Lead check.** The lead reads the diff and boundary-tests each changed sentence. Errors go back to the fixer.
4. **Read, round 6 (fresh Opus 5.5).** One lesson per reader, one at a time. Scope:
   - Confirm each round-5 Blocker and Major is fixed, wrong, or still open.
   - Boundary-test every sentence changed since round 5 (`git diff 29fae75fd -- <lesson>`). A Blocker or Major in changed text is reported.
   - Read the whole lesson. Report any Blocker anywhere (a wrong fact or a wrong worked answer). Outside changed text, report a Major only if it is a wrong or answer-revealing worked step; five full reads have already judged the rest.
5. **After round 6.** Clean or minor closes the lesson. A Blocker or Major in round 6 gets one more Sonnet fix and a lead check, with no further read; it goes to the Astra audit, which covers every Blocker fix, and to Aedwon's final list.

## Figure markers

The fixer may edit label text, move a marker unchanged to after the solution, or replace a FIGURE marker whose renderer draws the answer, a wrong shape or a false label with an ILLUSTRATION marker that names only the givens and the correct labels (precedent: quadrilaterals, round 3). No app code changes.

## Bases for the check

`python3 -I tools/content_rewrite/check_cet_lesson.py <lesson>`; meiosis uses `--base 1fef92406`.

## Limits

One subagent at a time. The fixer changes only its lesson files. No question files, tags or app code. The lead commits. No AI attribution in commits.

## Order

1. Chemistry: chemical-bonding, chemical-reactions, history-of-the-atom.
2. Biology: characteristics-of-life, evolution, meiosis-and-genetic-variation.
3. Physics and mechanical: work-energy-power, pulleys-and-levers, structural-stability.
4. Mathematics and earth science: triangles, functions-and-relations, earths-motions.

## Results

(Appended as each lesson finishes.)
