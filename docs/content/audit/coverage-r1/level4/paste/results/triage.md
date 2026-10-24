# Level 4 CSE findings triage

Date: October 25, 2026. Input: the 947 chat findings (866 from the first 71 lessons; 81 from 7 lessons added the same day) in `findings/` and `data/` (one ChatGPT read
per lesson, decision D4). Policy read from main `c40dcd61`.

## Method

- The 52 Blocker findings were ruled by the lead, reading each quote in its lesson and checking
  the style guide.
- The 814 Major and Minor findings were ruled by nine Claude Sonnet 5.5 second reads, one subject
  batch each, reading every lesson in full against the lesson style guide. The lead reviewed a
  random sample of each verdict and every reject, and overrode where the sample showed a pattern.
- Verdicts: `real` (a rewrite fixes it), `judgment` (defensible either way; rewrite may skip),
  `reject` (the finding is wrong), `ruling` (the finding follows the guide literally, but the
  pattern covers a whole subject and needs Aedwon's standards ruling), `illustration` (belongs to
  E6, not a rewrite).
- Every row, with its reason, is in `triage.jsonl`. Five problems found during triage and missed
  by the audit are added as `lead-added` rows.

## Totals

Verdicts: real 656, judgment 271, reject 19, illustration 7.

Real findings by fix size: small 497, medium 151, large 8. Real findings by subject: mathematics 169, language-proficiency 157, general-information 150, reasoning 78, reading-comprehension 76, science 26.
Every one of the 78 lessons has at least one real finding.

Most common real rules: L02 94, L25 89, L18 85, B08 81, L26 54, L19 50, L05 45, L27 29. In plain terms: hard words and terms used
before they are explained (L02, L25), taught cases with no worked example (L18), numbers outside
math notation (B08), solutions not written as numbered steps (L19), concepts named but not
explained (L26).

Lessons with the most real findings: code-of-conduct-ra-6713-statements-of-assets-and-divestment 31, vocabulary-synonyms-and-antonyms 22, algebra-polynomials 17, peace-and-human-rights-human-rights-fundamentals 14, philippine-constitution-the-civil-service-commission 14, vocabulary-root-words-prefixes-suffixes 14, algebra-types-of-functions 13, arithmetic-number-sense-fractions-decimals-percentages 13.

## Blockers

Of the 58 Blocker findings: real 43, judgment 7, illustration 7, reject 1.

Real errors a student would learn wrong (fix first):
- Wrong or incomplete worked answers: SALN deadline never given as a date; the janitor
  counterexample changes floor to ground; two keyed answers are not unique (sentence completion
  #3, double analogy #4); Civil Service Commission stem omits "immediately preceding"; the
  assumptions example keys a restatement of the premise; two grammar stems give no task.
- Wrong or loose facts: RA 6713 norms "at all times"; RA 10121 "established" the NDRRMC (it
  renamed the NDCC); Law of Detachment stated too loosely; "always whole minus hole"; "enjoys to
  swim" used as a parallelism example; one test value can match two choices.
- Unconfirmed absolute claims about exams: "every exam", "always among the choices", claims about
  UPCAT, DOST-SEI and CET content.
- Missing content: the earth science weather lesson lacks monsoon mechanism, cyclone formation,
  climate change effects and responses, and breezes and the ITCZ; two Mathematics lessons lack
  Speed Tricks or Traps.

Judgment calls (6): the "is means equals" line (a trap already states its limit), the exponent rule for negative bases, percent-change sign for negative starting
values, the bridge passage that copies Golden Gate figures with a wrong year, the "since"
shortcut caveat, and a Filipino clause example that needs a source check.

## Rulings (approved by Aedwon, October 25)

Both recommendations below were approved and are now in the lesson style guide. The 25 `ruling`
rows were converted: 12 General Information rows are real (add Traps), 7 Reasoning Speed Tricks
rows are judgment, 5 syllogism figure rows are illustration (Venn diagrams), and 1 number-sequence
row is reject.

1. **General Information layout (12 findings).** All 12 CSE General Information lessons have only
   Core Concept and Examples. The guide has no exception for this subject, so the audit failed
   all 12 for missing Speed Tricks and Traps. Options: add both sections to all 12 (12 large
   rewrites); or add a General Information exception that requires Traps to Watch For and makes
   Speed Tricks optional (12 medium rewrites). Recommendation: the exception. Traps help here (for
   example, who can be impeached); speed tricks rarely apply to law.
2. **Reasoning layout and figures (13 findings).** The guide says Reasoning drops Speed Tricks and
   every example is figure-driven. All 7 Reasoning lessons keep a Speed Tricks section, and the
   verbal logic and sequence lessons have no figures. Recommendation: allow Speed Tricks when it
   holds a real shortcut, and require figures only where they help (Venn diagrams for syllogisms,
   figure series). Number sequences and verbal arguments need none.

## For the rewrite (E4)

- Rewrite `real` rows. Skip `judgment` rows unless the fix is free while editing that passage.
  Ignore `reject` rows. `illustration` rows go to E6.
- The 497 small fixes are sentence-level; the 151 medium fixes are mostly one new worked example
  or one rewritten solution; the 8 large fixes are new sections or new teaching blocks.

## Added the same day: 7 lessons

Five Spatial and Abstract Reasoning lessons and two Reading lessons were added to the CSE scope
and read. The lead ruled their 6 Blockers (5 real: a fact-versus-opinion rule that mixes claim type
with evidence, a false region rule, three unsourced claims about how common item types are; 1
judgment). A Sonnet second read ruled the other 75 (41 real, 30 judgment, 4 reject) and found one
non-determinate matrix example, added as a lead-added row.
