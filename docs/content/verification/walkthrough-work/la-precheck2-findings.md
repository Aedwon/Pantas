# Language Application blind giveaway pre-check, round 2 (E-198)

Policy commit read in full (AGENTS.md, WORKFLOW.md, SUBAGENTS.md): `origin/main` `0234382b8efce98ade5f4a209a645fed76866cee`. Lessons read from the on-disk text (HEAD `a13f85ccd`, a brief-only commit after `3fdf1487a`; no lesson file differs). Paths are relative to `content/lessons/language-proficiency/language-application/`. Read-only.

Scope: 24 lessons with `:::` blocks (the other 3 have none). Every check and try was read fresh, not only the 18 fixed ones. Judged against the pre-check brief and the fix brief's ruling (rules 1 to 5, including 2a). I did not flag a check only because it applies the printed rule to new words; I flagged only where copying a printed form, frame or marker gives the key, or where the key is ambiguous.

Severity | file:line | item | how it is given away or why the key is wrong | fix

Blocker | time-and-step-order.md:132 | Ex 3 try, (A) "The cook cleaned the empty pot." (B) "Before lunch, ... boiled soup" (C) "At noon, ... serving" | Key B, C, A rests on "the pot is empty only after the soup is served". That is false: the pot is also empty before cooking. A, B, C ("clean the empty pot, then boil, then serve") is equally defensible, and (A) has no time word. Two valid orders. | Give (A) a clue that fixes its place, such as "After the meal, the cook washed the pot", and rewrite the answer and Check.
Major | past-time-checks.md:28 | Check 1 "forms (were mailed / are being mailed) ... last Monday" | The pair directly above prints the same two forms with the same marker: "were delivered ... yesterday" (Right) and "are being delivered ... yesterday" (Wrong). Only the verb and the day changed, so copying the printed Right form gives the key. | Change the frame: use a different tense contrast or a different passive pair, with a time clue not printed in the pair.
Major | subject-and-verb-checks.md:36 | Check 1 "Each of the new reports (was / were)" | The pair directly above is "Every one of the new laptops has / have". Same frame ("[singular head] of the new [plural]"), singular head, same verb choice; only the words changed. | Change the structure, for example a head with a describing phrase ("The list of names on the door ___") not "X of the new Ys".
Major | pagkakasunod-at-sanhi.md:88 | Check 3 "Pagsamahin gamit ang *dahil*: Nabasag ang baso kaya nagwalis si Ana." | The demo right above does the same job with the same instruction and the same sentence shape ("Naubos ang gasolina ..., kaya huminto si Mang Lito ..." to "Huminto ... dahil naubos ..."). The student copies the demo's move (swap *kaya* for *dahil*, flip the halves) without asking "Bakit?". | Test a different move: give a *dahil* sentence and ask for the same idea with *kaya*, or give two bare sentences and ask which is the sanhi.
Major | transition-links.md:28 | Check 1 "The trail was steep. ___, we rested often. (however / therefore)" | The demo above is "The road was flooded. Therefore, the bus took the hill route." Same frame ("The X was Y. ___, [result]"). Both choices are the two words the lead-in lists with their jobs, so the student copies *therefore* from the demo (fix brief rule 4: use an unlisted signal or none). | Use choices not printed in the lead-in (for example *as a result / on the other hand*) in a different frame.
Major | completion-natural-phrases.md:112 | Ex 3 try "partner of *agreement*" (do / reach / hold / say) | *Reach an agreement* is printed word for word in the first sentence of the lesson. *Reach* is the only choice ever taught with *agreement*; *hold* and *say* are never taught anywhere. Rule 2 asks that all choices be taught partners; here the student can find the key by recalling one printed phrase. | Test an unprinted common pair under rule 2a (for example *take a break*), or make every choice a taught partner of some noun.

Judged OK, noted so the lead can overrule:
- completion-word-forms.md:74 Check 3 (*plans* + *to*): the class scope phrase ("verbs about a plan or a choice") contains the word *plan*. This is the lead's own rule 1 example, so I did not flag it.
- completion-articles-and-lists.md:62 Check 2 (*proud of*): the other two choices (*at*, *in*) are the two prepositions printed with other words. Rule 2a allows an unprinted common pair, so not flagged.
- main-ideas-and-details.md:125 Ex 3 try: (B) is still the only choice that combines both detail groups. Rule 5 forbids a wrong choice that invents a claim, so a both-details distractor is not allowed. Not flagged.
- subject-and-verb-checks.md:77 Check 3 and Ex 3 try (*either ... or*): they mirror the two printed *neither ... nor* examples. They test the same rule, not the pair directly above. Not flagged.
- past-time-checks.md:40 Check 2 and completion-past-time.md:45 Check 2: the stems restate the meaning ("was still on the last stack", "had to stop halfway"). This is a context clue, not a copyable word. Not flagged.
- word-meaning-checks.md:59 Check 2 (*careless*): *-less* is not printed anywhere now. The lesson only says some suffixes show lack. The key is clear from "a careless mistake". Not flagged.
- Fix regressions: none found. No later line, checklist item, step or Check still names an old instance in the 18 fixed lessons. Every try keeps its `**Check:**` inside its `:::answer`.
- Keys: one wrong or ambiguous key found (the Blocker above). Every other key I solved blind matches.

Per lesson:

- cause-and-effect-order.md: OK
- clause-punctuation-checks.md: OK
- completion-articles-and-lists.md: OK
- completion-meaning-clues.md: OK
- completion-natural-phrases.md: 1 flagged (1 Major)
- completion-past-time.md: OK
- completion-word-forms.md: OK
- details-and-supported-inferences.md: OK
- kayarian-at-sugnay.md: OK
- main-ideas-and-details.md: OK
- modal-meaning-checks.md: OK
- modifiers-and-matching-forms.md: OK
- openings-and-reference-links.md: OK
- pagkumpleto-ng-pangungusap.md: OK
- pagkakasunod-at-sanhi.md: 1 flagged (1 Major)
- paksa-at-balangkas.md: OK
- past-time-checks.md: 1 flagged (1 Major)
- phrases-and-sentence-types.md: OK
- pronoun-reference-checks.md: OK
- time-and-step-order.md: 1 flagged (1 Blocker)
- subject-and-verb-checks.md: 1 flagged (1 Major)
- transition-links.md: 1 flagged (1 Major)
- wastong-gamit-at-panahon.md: OK
- word-meaning-checks.md: OK

PRECHECK VERDICT: FAIL (1 Blocker, 5 Majors)
