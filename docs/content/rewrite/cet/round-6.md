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

### Chemistry (November 9)

- Fixer (Sonnet) skipped the required reads of AGENTS.md, WORKFLOW.md, SUBAGENTS.md, the style guide and the checklist, and said so. The edits were one or two sentences per lesson; the lead checked each changed sentence and found no error, so they were kept.
- chemical-bonding: minor. Both round-5 Blockers fixed (solubility condition now "about as strong as, or stronger than"; the false resonance converse removed). Open Minor: one paragraph has four sentences.
- chemical-reactions: minor. Neutralization now scoped to an acid and a hydroxide base, consistent with the acids-bases-ph lesson's NH3 + HCl case. Open Minor: title differs from the outline. 3,308 words, split candidate.
- history-of-the-atom: minor. Ion now "an atom or group of atoms with an electric charge"; "neutral" defined. Open Minor: long paragraphs.
- Lead quote check: every round-6 quote found in its lesson; every verdict matches its findings.

### Biology (November 9)

- Fixer (Sonnet) read every required file this time.
- characteristics-of-life: clean. Virus now "must get its genetic material into a host cell"; dormancy scoped to "a seed that is dry or resting"; Example 1 uses only the stem's "grows".
- evolution: clean. The allele-pair rule is scoped to "a diploid organism made by sexual reproduction"; Example 1 takes the 100 copies from the stem; the acquired-trait sentence now says "a body change gained by use".
- meiosis-and-genetic-variation: clean. The allele-count rule again requires genes on different pairs, and each heterozygous gene "doubles the number of choices".
- Lead quote check: verdicts match their findings.

### Physics and mechanical (November 9)

- Fixer (Sonnet) read the policy files and the round-5 reads but not the style guide, checklist or writer rules in full (output truncated), and said so. The lead checked each changed sentence.
- work-energy-power: minor. Static friction now does zero work "if" the gripping surface is at rest (a sufficient condition, no "only if"); the speed-drop sentence is scoped to a throw straight up; "smooth" is defined in Example 4. Open Minor: long paragraphs.
- pulleys-and-levers: clean. MA as a distance ratio now measures each distance along its force, and the arm ratio is stated for forces at right angles to the bar; Examples 6 and 9 state a horizontal lever and a straight-down load.
- structural-stability: minor. Even spreading is "one case" that puts the center of gravity at the middle, with the dumbbell as another; the heavier-object rule carries "if the mass is spread the same way"; the lever arm is in meters and torque in newton-meters; weight is defined as a force in newtons; the Example 9 trucks now share one base width. Open Minors: four-sentence paragraphs; the reader noted that "The unit m/s^2 means ..." describes the value of g, not the unit (sent to the next fixer as a one-sentence fix). 3,205 words, split candidate.

### Mathematics and earth science (November 9)

- Fixer (Sonnet) read every required file. The lead sent back two points in earths-motions: a duplicate ILLUSTRATION marker, and "do not follow this rule" (unlimited; from the equator a near-pole constellation does follow it), now "can break this rule".
- triangles: clean. Triples shortcut now requires the sides to match the triple in their roles; Example 5 asks for "all possible measures" and its figure, like Example 7's, now sits after the solution; the proof states the four triangles are congruent by SAS.
- functions-and-relations: clean. Range of a parabola on all real numbers taught by the sign of $a$, with a worked line; Example 7 names the Polynomials and Quadratic Equations lessons.
- earths-motions: minor. The six-months rule is scoped to constellations near the Sun's yearly path; both celestial poles are named. The FIGURE marker whose renderer prints "a few extra degrees" was removed; the existing ILLUSTRATION marker beside it ("about 1 degree") now describes the figure alone. Open Minor: a four-sentence paragraph. 3,014 words, split candidate.
- structural-stability: one sentence changed after its read, at the reader's note: "The value $g = 9.8$ m/s$^2$ means ...". Lead-checked, no further read.

### Figure phase follow-up

Removing the earths-motions sidereal-day FIGURE takes away a drawn figure that was approved on August 25 (`docs/content/illustrations/review.json`, `earths-motions#4`). The renderer requires the label "a few extra degrees", and changing it is app code. Until the figure phase redraws it, the lesson shows no drawing there. The illustration check (`check_lesson_illustrations.py --phase review-ready`) already failed on the branch before round 6 (323 errors, from the rewrite's new markers); round 6 adds one ("expected 4 code FIGURE markers, found 3").

### Round 6 result

All 12 open lessons closed: 6 clean (characteristics-of-life, evolution, meiosis-and-genetic-variation, pulleys-and-levers, triangles, functions-and-relations) and 6 minor. Counts: 77 lessons, 17 clean, 60 minor, 0 open. 12 reads, 4 fixer runs, one subagent at a time.
