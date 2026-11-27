# Language Application pre-check fix brief (session 5, Nov 27, E-198)

You are a fixer for the Claude lesson lead. Policy read by the lead: `origin/main` `0234382b8`. Read in full and follow, in order:
1. `docs/content/verification/walkthrough-work/worker-rules.md` (standard and hard limits: Edit tool only, Bash read-only, no redirection, no scripts, no git writes, no subagents, run no checks).
2. `docs/content/verification/walkthrough-work/pattern-checklist.md` (P1 to P5).
3. `docs/content/verification/walkthrough-work/la-precheck-findings.md`: every row (12 Blockers, 11 Majors).
4. This file.

Required step from main (process-improvement entry "Grammar walk-through lessons fail every Codex audit round (Nov 27)"): for each flagged item, rewrite the WHOLE Quick Check or try, not only the flagged words: a fresh sentence or passage, and choices that all fit the visible text, so that no choice can be found by copying. Keep each try's `**Check:**` inside its `:::answer`, and make the Check confirm the answer a different way (never repeat the step above).

## Lead ruling on word-specific facts (replaces session 3 ruling 2, Nov 27)

Session 3 ruled that a word partner a check tests (*proud of*, *pay attention*, *reach an agreement*, *decide*, *avoid*) must be named in the lesson. Printing it in the lead-in right above the check made it copyable: half of these Blockers come from that ruling. The new rule:
1. **Where a rule covers a class of words, test an unlisted member the rule predicts.** Teach the class with a short scope word and 2 or 3 examples ("Verbs about a plan or a choice, such as *hope* and *decide*, usually take *to* + base verb"), then check with a member the cue covers but the text does not print (*plan*, *refuse*; *finish* for the *-ing* class; a suffix such as *-ful* or *-ish* only if the lesson teaches it as a rule). Name the class cue in the answer.
2. **Where no rule exists (pure fixed phrases):** the tested pair must not be printed in the same `###` section as the check, nor in the check itself. It may be taught in an earlier section of the lesson (retrieval across sections is allowed), and the choices must all be taught partners, so the reader must recall which one goes with the noun. If a fixed phrase cannot be placed that way, test a different taught phrase.
2a. **Amendment (lead, Nov 27, about 3:10 PM), after the fixer showed rules 2 and 5a conflict in a lesson's first fixed-phrase section:** for a pure fixed phrase, the taught thing is the method ("read the word before the blank and use its usual partner", with 2 or 3 example pairs), not one pair. A Quick Check there may test a common, exam-level pair the lesson does not print, as long as the method was taught and the pair is not printed anywhere above. This is the only case where a check may use an item the lesson did not show. `completion-articles-and-lists` Check 2 (*proud of*) and `completion-natural-phrases` Check 1 (*pay attention*) follow this.
3. **Frames:** a check must not copy the frame of the worked demo or pair directly above it with only a word or two swapped (the "By the time ..., ___ had" and "Some of the ... in these ... is" cases). Change the structure, not only the nouns.
4. **Markers and signal words:** when the lesson lists signal words (*therefore*, *for example*, *afterward*, *this/that*, *una, pagkatapos, sa wakas*), the check uses a signal the list does not print but the rule covers, or no signal word, so the reader must use meaning.
5. **Main idea items:** the wrong choices are also lines or ideas from the passage (a detail, a too-narrow point), never invented claims; the main idea is not always the first sentence and not copied word for word when the item asks for it in other words.

## Scope and limits

- Edit only the 18 flagged lessons in `content/lessons/language-proficiency/language-application/`. Change only the flagged items, plus every line that names the old instance (steps, answer, Check, pair, checklist) and every restatement of a rule you change (P5).
- If you change a lead-in list, make sure no other item in the lesson still depends on what you removed.
- Do not touch `:::pair` Right/Wrong lines unless a row requires it; if you do, the cited mistake in `content/walkthrough-trap-evidence.json` must still fit.
- Word budget: no lesson above its current pre-tap count by more than 10 words; cut a line a reader would not miss to offset. Never cut a required Check, a lead-in, or a finished sentence.
- Do not touch `<!-- FIGURE WANTED:` lines.

Report under 600 words: per row, fixed how (one line); any row you think is wrong, with a reason; words added and cut per lesson; files touched.
