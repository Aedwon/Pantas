# Fable audit, Language Application, round 1

Auditor: Claude Fable 5.2, read-only. Target: `content/lesson-walkthrough-cse-r1` at e2e1e1c6b. Topic: the 24 active Language Application lessons with `:::` blocks (retired parents skipped).

Read: brief, worker-rules, pattern-checklist, spec Part B, approved sample, AGENTS.md (origin/main 5810f9bd6) in full; the Filipino section of the lesson style guide; the four earlier verifier reports; all three question files; the Language Application block of `content/walkthrough-trap-evidence.json`. WORKFLOW.md and process-improvement.md: headings and the walk-through entries only, not in full.

Not run: dart, flutter, the parser, word counts (the lead's results are taken as given). The report was saved in two batches, not after every lesson.

Paths are under `content/lessons/language-proficiency/language-application/`.

## Earlier findings still open

- la-16-reverify (noted there as optional) | openings-and-reference-links.md:61, :95, :114; time-and-step-order.md:31, :59, :93, :112 | Worked chains end at a letter string, not the ordered text. Counted below.
- la-8 Minor | pronoun-reference-checks.md:88-99 | Example 2 keeps quiz 0015's choice pattern (*have*, *has* plus participle, *has* plus base verb). Not counted again: no student harm.
- la-8 Minor | word-meaning-checks.md:71 | Example 1 keeps quiz 0030's stem frame. Not counted again: no student harm.
- la-en11 cross-cutting Minor | cause-and-effect-order.md:116-119, openings-and-reference-links.md:130-132, time-and-step-order.md:128-130, transition-links.md:135-138 | Step 1 of each three-sentence try places one sentence, so two remain. The reverify left this as accepted. Not counted again.
- la-16-reverify Major on completion-word-forms (*decide*, *avoid*): closed by the lead's ruling. I found no student harm the ruling misses, so it is not re-raised.

Every other finding in the four earlier reports is closed at e2e1e1c6b.

## Citations

59 pairs in 24 lessons. Every pair has an entry in `content/walkthrough-trap-evidence.json`. For every entry: the wrong choice text exists exactly in the cited question, the choice is not the correct one, the question's `lesson:` is the lesson, and the pair's Wrong line shows that mistake. pronoun-reference-checks `object-after-preposition` now cites quiz 0013 "No error" (the la-8 failure is fixed). No citation finding.

## Findings

### Majors (3)

- Major | modifiers-and-matching-forms.md:42 | "Use *that of* with one item and *those of* with several" is not the rule. *That* and *those* match the noun they replace, not the number of owners: "The tires of this truck are wider than those of that car" has one item and takes *those*. A student who learns the line as written picks *that of* there | "Use *that of* for a singular noun (the rating) and *those of* for a plural noun (the ratings)." The check at :61-65 still holds.
- Major | kayarian-at-sugnay.md:58-62 | The worked sentence "Kapag umulan, hindi natuloy ang laro." is not standard Filipino. *Kapag* takes a condition or a repeated event; a finished past event takes *nang* or *noong* (Schachter and Otanes). A grammar lesson models a faulty sentence. Confidence high, not checked against a printed copy in this run | "Kapag umulan, hindi matutuloy ang laro." The count stays 1 and 1, so the chain needs only "hindi matutuloy ang laro" at :61.
- Major | openings-and-reference-links.md:72, :134 (also :43) | The "Put in order" check and the try end at a letter string. The ordered paragraph is never shown, and the try's Check says "Read the order aloud" with nothing to read. The sister lessons (time-and-step-order, transition-links, cause-and-effect-order) show the text | End each answer with the sentences in order, as time-and-step-order.md:42 does. These words sit behind the tap, so the pre-tap count does not grow.

### Minors (35)

clause-punctuation-checks.md
- Minor | :86-87 | The first option "(a)" has no blank line after the stem line, so it joins the stem while (b) sits on its own row | Add a blank line before "(a)".
- Minor | :52 | "transition adverbs, not coordinating conjunctions" brings in two new terms; :22 called them "coordinating joining word" | "are transition words, not joining words like *and* or *but*".

modal-meaning-checks.md
- Minor | :38 | *must* is also defensible (a requirement after months of practice) | Add a clue that only ability fits, for example "Ben *(can / must)* now play the whole song easily".
- Minor | :105, :107 | The try's finished sentence drops "if they wish", the clue that decides the answer | End at "Residents may park here after six if they wish."
- Minor | :47 | "Core modals (*can, may, must, might, could, should*)" reads as the full list; *will*, *would* and *shall* are missing | "Core modals such as".

modifiers-and-matching-forms.md
- Minor | :22 | "Place a *that*-clause right after the noun it describes" has no sentence under it in the core; the first instance is Example 1 | Add one short instance, or cut the line and let Example 1 teach it.
- Minor | :120 | "a correct version says 'a second time' only once" is hard to follow | "*Again* repeats what *repeat* already says, so drop one of them."

past-time-checks.md
- Minor | :20 | "past participle" is used here and explained only at :50 | Explain it at :20, or say "the *-ed* form".

phrases-and-sentence-types.md
- Minor | :80-81, :97-98 | First option "(a)" joins the stem line | Add a blank line.
- Minor | :36 | "no subordinating word" is a new term; the lesson says "joining word like *because*" | Use the lesson's term.

pronoun-reference-checks.md
- Minor | :34 | "drop the first word" is not the move shown; the move is to drop *you and* | "drop the other person (*you and*) and test the pronoun alone".
- Minor | :74 | Stem says "Identify the error" but the sentence has two | "Find the two errors".
- Minor | :88-89 | First option "(A)" joins the stem line | Add a blank line.

subject-and-verb-checks.md
- Minor | :124 | The try answer ends at the second clause only, not the whole finished sentence | Add the full sentence with *needs* and *knows*.

word-meaning-checks.md
- Minor | :84-85 | First option "(A)" joins the stem line | Add a blank line.
- Minor | :126 | "Homophones" is not taught; :29 says "words that sound alike" | Use the same words.

kayarian-at-sugnay.md
- Minor | :82-85 | The check's answer (*langkapan*) is the label of the worked chain and the pair right above it | Use a sentence with a different answer, for example a hugnayan with two actions in one clause.

wastong-gamit-at-panahon.md
- Minor | :84 | Punctuation `niya.", mga pagpipilian:` reads badly | Put the options in a sentence of their own: "Pagpipilian: *tumawag*, *tumatawag*, *tatawag*."

completion-articles-and-lists.md
- Minor | :25 | "fill the blanks" but the sentence has one blank | "fill the blank".
- Minor | :63 | The check tests *proud of*, a partner the lesson never names. Under the lead's word-forms ruling a word-by-word fact should be named | Add *proud of* to the "such as" list at :47, or rule that fixed phrases are exempt.

completion-natural-phrases.md
- Minor | :35, :110-128 | Same class: the check (*pay attention*) and the try (*reach an agreement*) test partners the lesson never names | Name them in the :19 list, or rule that word partners are exempt.

completion-past-time.md
- Minor | :151 | "Use the strongest clue first." does not say what a strong clue is | "Find the time clue first, then check whether the action was finished or still going on." or cut the section.
- Minor | :158 | The cue "One time word:" is unclear | "A sentence with two past events:".

completion-word-forms.md
- Minor | :72 | "Learn these patterns with the first verb." is unclear | "Learn each verb together with its pattern."

pagkumpleto-ng-pangungusap.md
- Minor | :76 | Same punctuation as wastong-gamit :84 (`ng ______.", mga pagpipilian:`) | Same fix.

cause-and-effect-order.md
- Minor | :108-121 | In the try, (B) has no word that points back to (C), so the C, B order rests on what the reader knows about refrigeration, not on a taught clue | Give (B) a pointer: "Without it, the temperature inside the warehouse rose above the safe level."

openings-and-reference-links.md
- Minor | :85, :91 | Opening sentence (C) starts with "The groups", a *the* plus noun that :48 says can point back, yet step 1 says it needs no earlier sentence | "Several groups settled near a river for water and fertile soil."
- Minor | :130-131 | No blank line between step 1 and `:::try` | Add a blank line.
- Minor | :61, :95, :114 | Worked chains end at "The order is B, A, C", not the ordered text (still open from la-16-reverify) | Lead's call: add the text only if it fits the word cap.

time-and-step-order.md
- Minor | :128-129 | No blank line between step 1 and `:::try` | Add a blank line.
- Minor | :31, :59, :93, :112 | Worked chains end at a letter string (still open from la-16-reverify) | Same lead's call.

transition-links.md
- Minor | :46, :105 | Worked chains end at a letter string; :80 in the same lesson shows the text | Same lead's call.

pagkakasunod-at-sanhi.md
- Minor | :74 | *pang-ugnay* has no first-use gloss in this lesson | "pang-ugnay (connector)".
- Minor | :58, :115 | Worked chains end at "Ang ayos ay B, A, C" with no ordered text | Same lead's call.

Cross-cutting, Filipino lessons
- Minor | kayarian-at-sugnay.md:70-79; wastong-gamit-at-panahon.md:27-36; pagkumpleto-ng-pangungusap.md:26-36, :53-64; pagkakasunod-at-sanhi.md:76-86 | Each pair repeats the sentence the chain just above finished, so the reader reads the same right sentence twice | Give the pair its own sentence, as the English lessons do, or drop the "Buong pangungusap" line above the pair.

## Lessons with no finding

completion-meaning-clues, details-and-supported-inferences, main-ideas-and-details, paksa-at-balangkas.

## Checks that passed in all 24

- No em or en dash, no trailing double spaces, American spelling.
- 2 or 3 pairs and 2 or 3 checklist items per lesson; every checklist slug matches a pair id or a `###` heading.
- Every try's `**Check:**` is inside its `:::answer`.
- Every check and try uses a sentence not worked earlier in its lesson. No heading names the answer to the try under it.
- Filipino lessons: simple Filipino, no Taglish, glosses at first use in teaching prose only (one missing, listed above).
- No Blocker: no false answer, no answer given away by a visible step.

## Totals

Blockers 0. Majors 3. Minors 35.

Most common classes:
1. An answer or chain ends at a letter string, not the ordered text (1 Major, 4 Minors, 4 lessons).
2. Layout joins: the first option joined to its stem, no blank line before `:::try`, option list punctuation (8 Minors).
3. Rule or term wording: an inexact rule, a list that reads as complete, or a term used before it is taught (1 Major, 7 Minors).

VERDICT: FAIL (0 Blockers, 3 Majors, 35 Minors)

STAGE-DONE
