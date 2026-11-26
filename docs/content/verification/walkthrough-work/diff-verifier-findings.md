# Diff verification of the verifier-round fixes (Nov 26, session 2)

Targets: Grammar `git diff 02cd4a42f f91a0cc55`, Vocabulary `git diff 4fb962f80 f91a0cc55`. Two Sonnet verifiers, read-only. Both FAIL.

## Grammar

Blocker | pang-ukol-pangatnig-at-pandamdam.md:68-70 | Answer says "Pangatnig ang *dahil* at pang-ukol ang *sa*" for "dahil sa hangin"; *dahil sa* works as one pang-ukol ("because of"), and the lesson treats *mula sa*, *para sa* as one unit. | Use a stem without *dahil sa* (for example "Hala! Nahulog ang baso sa sahig") and name only *sa*.
Blocker | past-perfect-earlier-completion.md:81-93 | Try "it ___ at six" with *closed* / *had closed*: both acceptable since "at 6:30" and "at six" fix the order; the answer's "No word like *before* shows the order" and the Check's "plain *closed* would read as if both events happened together" are false. | Rewrite so only past perfect fits (an earlier action with no clock times or order word, for example "When we got to the station, the train ___ (leave)" meaning it was already gone), or test "past perfect is optional when the order is clear". Remove the false claims.
Blocker | mga-pahiwatig-ng-oras.md:51-53 | Check "Magpupulong ... tuwing Lunes simula sa susunod na buwan" nearly copies the taught "Magpupulong kami tuwing Biyernes simula sa susunod na linggo"; two options; the taught cue gives it away. | New sentence without the taught cue phrase; options that differ in meaning, not one cue.
Major | hugnayan-langkapan-at-ayos-ng-salaysay.md:77-79 | Answer says *naghugas ulit* "ay kabilang sa simula": unsupported; check tests story logic, not the markers taught. | One clearly defensible middle step; drop that justification; test the marker.
Major | hugnayan-langkapan-at-ayos-ng-salaysay.md:~96-98 | The #2 fix removed "Gawing dahilan ng pag-aaral ang pagsusulit"; solution step 1 ("Iugnay ang dahilan gamit ang *dahil*") has no source; blank line before **Solution:** gone. | Restore the blank line; put the *dahil* link back into the prompt, short.
Major | removing-needless-repeated-meaning.md:42-44 | "Please repeat the instructions again" tests *again*, which the core does not teach here, and the sister lesson says *again* can add meaning. | Use a taught pattern (redundant *back* or *together*) with a fresh verb.
Major | finding-subjects-and-matching-verbs.md:~136-138 | Blank line before `## Traps to Watch For` removed; "Exceptions such as ...:" is a fragment; "otherwise cover it" awkward. | Restore the blank line; full sentence ("Some words are exceptions: ..."); drop "otherwise".
Minor | mga-pahiwatig-ng-oras.md:~51 | Two-way stem with no distinguishing cue after the fix. | Covered by the Blocker fix.
Minor | hugnayan-langkapan-at-ayos-ng-salaysay.md:63 | "panandang pangkasunod" is not a KWF or Schachter and Otanes term. | *pananda* with the gloss "(sequence marker)", or a plain description.
Minor | modals-requirements-and-possibility.md:122 | Check says *has to be closed* "would state a rule"; *have to* can also express deduction. | "usually states a rule".
Minor | finite-verbs-and-ing-groups.md:98 | Lead-in "use *the coordinator* as the subject" hands over half the answer. | Put the subject in the source sentence, or accept any subject.
Minor | joining-words-phrases-and-clauses.md:~46 | "Some grammars also count *before leaving* ... this lesson does not" is narration and understates it. | "*Before leaving* is a non-finite clause; this lesson groups it with phrases."
Minor | clear-pronoun-reference-and-singular-they.md:81 | "Repeat the name in ..." gives away the method. | Open "Rewrite clearly" wording, keeping the "Sam alone passed" fact.

## Vocabulary

Blocker | affect-and-effect.md:79 | "The gap follows *will*" but the sentence is "will severely ______". | "The sentence has *will*, so the gap needs a base-form verb."
Major | opposite-roles.md:41-43 | "If Carlo teaches a lesson to Mia, what does Mia do?" has several defensible answers; *teach/learn* never taught (the lesson teaches buy/sell, borrow/lend). | Fresh instance of a taught pair with a closed choice (for example "If Dina lends a pen to Leo, which verb names Leo's role: borrows or lends?").
Major | comparisons-and-human-actions.md:48-49 | Blank line before "Now we test a line that has a human action." deleted; the lead-in merges into the Hyperbole bullet. | Restore the blank line.
Major | comparisons-and-human-actions.md:40-42 | Check "He ran as fast as he could" contains *as*, the taught marker; answer rests on "compares him with himself", arguable. | A clearer non-simile with no marker (for example a metaphor "The sky is a blue blanket" if the lesson teaches metaphor), or quote the core rule in the answer.
Minor | affect-and-effect.md:81-82, 105 | Blank line before `### #2` deleted; "*on attendance* names what the result reached" vague. | Restore; "*effect on* is the noun pattern".
Minor | paghahambing-pagbibigay-katauhan-at-pagmamalabis.md:46 | "Kung sobrang pagsobra ang pangunahing punto" redundant. | "Kung matinding paglalabis ang pangunahing punto ng linya, pagmamalabis ang sagot."
Minor | feeling-strength-and-formality.md:68-69 | Blank line between the Register definition and "First ask who..." removed. | Restore.
Minor | definitions-examples-and-synonyms.md:~95; similar-and-opposite-meanings.md:~99; word-partners-feeling-and-grammar.md (before `## Traps`) | Blank lines before the next heading deleted. | Restore.
Minor | silent-e-with-suffixes.md (checklist, truly line) | "Some consonant suffixes: drop the *e* in *truly* and *argument*" not actionable. | "A few exceptions: drop the *e* in *truly* and *argument*."
Minor | similar-and-opposite-meanings.md:25 | *Audacious* never taught; "daring" stands out. | Teach in a few words or swap.
Minor | sila-at-sina.md:80 | "Tingnan ang kasunod." too terse. | "Tingnan kung pangalan ang kasunod agad."
Minor | sound-and-opposing-words.md:~34 | *Bees* repeats the core's "busy bees buzzed". | Another subject.
