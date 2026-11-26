# Walk-through connection pass (math), Claude lane

Rule source: Nov 26 entry "Walk-through examples still show math without saying where it comes from" in `docs/workflow/process-improvement.md`. Each example gets one short lead-in naming what we do and to what, and each chain runs from its expression to its value. No added narration.

Scope: committed lessons in `content/lessons/mathematics/` (algebra, arithmetic-number-sense, data-interpretation). Every value touched was recomputed.

## Finished (edited)

- arithmetic-number-sense/substituting-negative-numbers (approved target: "Let's substitute x = -2 into 3x, x^2 and 12/x", every chain ends at its value; x^2 now ends at 4)
- algebra/evaluating-and-composing-functions and algebra/functions-and-relations (f(-2) example: lead-in added, chain now ends at 15 in one line)
- algebra/radicals-and-rationalization and algebra/rationalizing-square-root-denominators (speed trick: "With x=10 and y=2", chain shows the middle step)
- algebra/word-problems (speed trick: "With a=6 and b=3", chain ends at 2)
- algebra/radicals-and-rationalization and algebra/simplifying-and-combining-radicals (example #2: lead-in before the first display)
- algebra/set-membership-and-operations and algebra/sets-and-set-notation (example #2: lead-in before the first display)
- algebra/polynomials, algebra/polynomial-terms-and-degree, algebra/polynomial-long-division (split chains joined into one, same words)
- arithmetic-number-sense/geometric-sequence-terms, harmonic-sequence-terms, prime-factorization-gcf-lcm (split chains joined into one, same words)

## Read and left alone (already connected)

- All of data-interpretation (9 lessons): every example already opens each display with a step sentence and ends at its value.
- arithmetic-number-sense/signed-integers-and-substitution.

## Not reached (as of the first commit)

- A line-by-line read of the remaining algebra and arithmetic-number-sense lessons. They were screened with pattern scans only (bare lead-ins, display directly after a heading or "Solution:", chains split across displays, chains ending before a numeric value). A scan can miss an example whose lead-in exists but is vague, so a full read of those lessons is still open.

## Second pass (Nov 26, 12:20 to 12:50 PM Manila, temporary Claude lesson lead)

### Kept from the stopped workers (36 files, lead reviewed every diff)

- Chains now start from their expression: algebraic-expressions, simplifying-and-evaluating-expressions, exponent-laws-and-zero-powers, exponents-and-logarithms, factoring-cubes, factoring-quadratic-equations, factoring-quadratics, polynomial-special-products, quadratic-equations, quadratic-inequalities-outside-the-roots, quadratic-inequalities-with-two-roots, ranges-on-restricted-domains, remainder-and-factor-theorems, exponential-growth-and-function-families, types-of-functions, line-slopes-and-intercepts, linear-equations-inequalities, systems-elimination, systems-of-equations, coin-and-digit-problems, word-problems, age-word-problems (algebra).
- Lead-ins added: cube-root-denominators-and-nested-radicals; counting-venn-diagram-regions and three-set-inclusion-exclusion (worker's lead-in trimmed by the lead to "Subtract the 5 who chose all three from each pairwise count:" because it had grown wordy).
- arithmetic-number-sense: identities-and-like-terms, imaginary-unit-and-powers, inverse-proportion-and-remaining-work, making-differences-with-given-digits, making-sums-with-given-digits, multiplying-and-dividing-decimals, operation-priority-and-left-to-right, order-of-operations, partitive-proportion-and-differences and percentage-base-and-fraction-division (pair lines now name their givens), prime-factors-and-powers.
- Restored from HEAD: none. No diff broke the rule or changed a value.

### Finished in this pass (two Sonnet workers, lead reviewed every diff)

- algebra: arithmetic-with-functions, classifying-linear-systems-by-slope, graphing-linear-systems (lead rewrote the check as "Substitute x = 2 and y = 3 into both equations" with each chain from its expression), linear-and-quadratic-functions, logarithm-product-quotient-and-power-laws, polynomial-operations, polynomial-multiple-factors, quadratic-equations-from-roots, quadratic-formula-and-irrational-roots, quadratic-inequalities-with-fewer-roots, quadratic-methods-and-root-properties, quadratic-rectangle-area, rates-and-consecutive-integers, rational-domains-and-holes, systems-lines-and-parabolas, systems-substitution-and-word-problems, work-rate-problems.
- arithmetic-number-sense: adding-and-multiplying-fractions, additive-and-multiplicative-inverses (lead replaced the worker's "For example:" with lead-ins that name the numbers, and wrote the reciprocal as 1 divided by -5/8), business-math, commutative-and-associative-properties, complex-products-and-quotients, decimal-and-percent-conversions, direct-proportion-and-travel, distribution-and-common-factors, fibonacci-type-sequence-terms, fractions-decimals-percentages, grouping-and-fraction-bars, growing-square-borders, properties-of-real-numbers, ratio-and-proportion, real-imaginary-numbers, sequences-and-series, signed-integer-operations, signed-integers-and-substitution (earlier listed as left alone; its chains now start from their expressions), simple-interest.
- Parent lessons brought in line with their child lessons by the lead: algebra/polynomials (examples #3, #5, #7, #8, #9 now start from their expression, as in polynomial-operations, polynomial-special-products, factoring-quadratics and factoring-cubes) and algebra/exponents-and-logarithms (example #6, as in logarithm-product-quotient-and-power-laws).
- Every touched value was recomputed. No wrong value was found in the originals.

### Read by a worker and left alone

- The other algebra and arithmetic-number-sense lessons on the worker lists (about 30 algebra, about 29 arithmetic). The workers read them fast (about 2.5 minutes per list), and the lead reviewed only the diffs. A slower student read of the unedited files is still worth doing.
- Mixture lesson: a five-step equation-solving sequence was left as separate displays, since joining equations with "=" would be wrong.

### Not reached

- geometry, precalculus-basic-calculus, statistics-and-probability, trigonometry (outside this lane's CSE scope).

## Vocabulary (Claude)

Nov 26, 12:44 to 1:02 PM Manila. Full walk-through rewrite plus the connection rule, in `content/lessons/language-proficiency/vocabulary/`. Sonnet workers wrote; the lead reviewed.

Lead review on every lesson listed below: each `:::pair` Wrong line was checked against the quiz bank and matches a real non-correct choice of the cited question (63 citations, 0 misses, 0 that hit a correct choice). Frontmatter and keyPoints are byte-identical to HEAD. No em or en dashes and no backticks. Every checklist `{#id}` matches a pair in the same lesson; the lead removed one dangling id in affect-and-effect. No `## Examples` example was dropped; the old `### #` trap headings became one `:::checklist`. Question files were not edited. Trap citations are recorded here only, because `content/walkthrough-trap-evidence.json` holds another lane's uncommitted work.

The lead read affect-and-effect, its-and-it-is-or-it-has, suffixes-for-qualities-and-absence and word-partners-feeling-and-grammar in full or in part. The rest passed the checks above but were not read line by line by the lead.

### Finished and reviewed (22, English)

| Lesson | Pair: question, wrong choice |
|---|---|
| affect-and-effect | influence-verb: confusing-words-0001 "Effect"; base-form: 0001 "Affects"; bring-about: 0013 "Affected" |
| its-and-it-is-or-it-has | owner-apostrophe: confusing-words-0002 "It's"; extra-apostrophe: 0002 "Its'"; has-not-owner: 0015 "Its, its" |
| doubling-final-consonants | begin-stress: spelling-rules-0003 "Begining"; refer-stress: 0015 "Refered"; visit-stress: 0020 "Visitting, beginning" |
| silent-e-with-suffixes | truly: spelling-rules-0019 "Truely" (other bank wrong choices are real words, so no second pair) |
| prefix-clues-in-context | prefix-meaning: synonyms-and-antonyms-0027 "not finished"; real-prefix: 0028 "Every initial un means not." |
| opposite-roles | same-exchange: synonyms-and-antonyms-0024 "The supplier bought the printer."; borrow-lend: 0020 "Return" |
| checking-longer-spellings | known-base: spelling-rules-0009 "Definate"; doubled-pairs: 0005 "Acommodate" and 0007 "Comittee" |
| comparisons-and-human-actions | metaphor-or-simile: idioms-and-figures-of-speech-0005 "Simile"; as-if-personification: 0003 "An explicit comparison" |
| contrast-and-inference-clues | contrast-target: context-clues-0004 "Talkative"; contrast-other-side: 0014 "Wasteful" |
| definitions-examples-and-synonyms | restatement-not-reaction: context-clues-0011 "Rude"; sentence-meaning: 0008 "Punishment" |
| english-word-elements | mal-versus-bene: root-words-prefixes-suffixes-0002 "Benevolent"; omni-all-what: 0007 "All-powerful" |
| feeling-strength-and-formality | approving-tone: synonyms-and-antonyms-0019 "Stingy" |
| idioms-and-literal-meanings | start-over: idioms-and-figures-of-speech-0001 "To abandon the attempt"; naghigpit-ng-sinturon: 0019 "Naghanda sa paglalakbay" |
| letters-sounds-and-vowel-order | belief-order: spelling-rules-0001 "Beleif"; seize-exception: 0017 "Sieze" |
| meaning-and-grammar-in-context | fast-meaning: synonyms-and-antonyms-0012 "To finish a task quickly"; decide-grammar: 0023 "decision" |
| opposites-with-levels-and-two-states | two-labels: synonyms-and-antonyms-0025 "partially available"; not-hot: 0026 "It must be cold." |
| roots-bases-and-valid-splits | stem-before-suffix: root-words-prefixes-suffixes-0021 "-ness"; inflammable: 0014 "Protected from fire" |
| similar-and-opposite-meanings | heavy-rain: synonyms-and-antonyms-0029 "powerful rain"; mitigate-opposite: 0002 "Alleviate" |
| sound-and-opposing-words | repeated-sound: idioms-and-figures-of-speech-0007 "Onomatopoeia"; opposing-words: 0009 "Hyperbole" |
| suffixes-and-word-jobs | ly-adverb: root-words-prefixes-suffixes-0022 "Which officer was present"; friendly-adjective: 0023 "Adverb of manner" |
| suffixes-for-qualities-and-absence | ful-less: root-words-prefixes-suffixes-0024 "without; full of"; ness-noun: 0025 "Describes a kind person" |
| word-partners-feeling-and-grammar | charged-partner: context-clues-0016 "Accused"; furnish-grammar: 0021 "furniture"; qualified-meaning: 0019 "Certified" |

### Finished, committed as WIP, not yet reviewed (7, Filipino)

These passed the same mechanical checks, and all 16 pair citations match real wrong choices. The lead did not read them for Filipino wording or Grade 5 level, so a Filipino-language review is still open.

- ng-at-nang (pagmamay-ari: confusing-words-0014 "Nang"; dami: 0016 "Nang"; noong: 0012 "Ng")
- sila-at-sina (bago-ang-pangalan: confusing-words-0004 "Sila"; pamalit: 0009 "Sina")
- kasingkahulugan-at-kasalungat (kasingkahulugan: synonyms-and-antonyms-0003 "Natupad"; kasalungat: 0004 "Mahirap"; a Traps section was added)
- baybay-ng-hiram-na-salita (isingit-ang-w: spelling-rules-0012 "kuento")
- ugat-unlapi-gitlapi-at-hulapi (ugat-hindi-panlapi: root-words-prefixes-suffixes-0003 "Pinag"; ugat-hindi-buo: 0010 "Ginawa")
- panlaping-kabilaan-at-laguhan (kabilaan-ka-an: root-words-prefixes-suffixes-0011 "Pag- at -an"; laguhan-hindi-kabilaan: 0004 "Kabilaan")
- paghahambing-pagbibigay-katauhan-at-pagmamalabis (labis-hindi-tulad: idioms-and-figures-of-speech-0011 "Pagtutulad"; tulad-hindi-wangis: 0012 "Pagwawangis"; wangis-hindi-tulad: 0013 "Pagtutulad"; katauhan-hindi-hambing: 0014 "Tahasang paghahambing")

Open content question (existed before this pass): the lesson baybay-ng-hiram-na-salita teaches *kuwento* over *kwento*, but question spelling-rules-0012 uses "Kwento / kuwento" as its correct choice. The new pair avoids that conflict. The question bank owner should check it.

### Not reached

- None of the active lessons. The six retired lessons (confusing-words, context-clues, synonyms-and-antonyms, spelling-rules, idioms-and-figures-of-speech, root-words-prefixes-suffixes) were left unchanged on purpose.
