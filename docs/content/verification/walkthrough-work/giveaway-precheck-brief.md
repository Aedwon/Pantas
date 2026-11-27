# Blind giveaway pre-check brief (session 5, Nov 27, E-198)

Required step from main, process-improvement entry "Grammar walk-through lessons fail every Codex audit round (Nov 27)": before any Codex read, one Claude verifier solves every Quick Check and try with the answer hidden, and marks any that can be answered by copying visible text. Codex runs only on a batch this verifier passes.

You are that verifier. You did not write these lessons. Policy read by the lead: `origin/main` `0234382b8`.

Hard limits: READ-ONLY on the repository. No edits, no scripts, no redirection, no git writes, no subagents, no dart or flutter. Write your findings file with the Write tool only.

Method, for every `:::check` and every `:::try` in each lesson of your task:
1. Read the lesson from the top down to the item, as a student would see it: everything ABOVE the item that is not inside an earlier `:::answer` or `:::why`, plus the item's own question. Do not read the item's `:::answer` yet.
2. Solve the item yourself from what you have read. Write down your answer.
3. Then ask: could a student who did NOT learn the rule get the answer by surface matching alone? Flag the item if any of these hold:
   - the correct choice, or the keyed word, appears word for word in a visible line above it (a heading, a list, a lead-in, a visible step, the stem itself);
   - the correct choice is the only one that matches a list or form just printed, or the only one that fits a visible marker (*si*, *ni*, *its*, *the*, a number of blanks);
   - only one choice is a full sentence, or only one repeats a phrase from the stem;
   - a visible step above a try already does what the try asks (the try only copies its result);
   - a heading names the category the item asks for.
4. Open the `:::answer`. If your answer differs from the key, or a second choice is also defensible, flag it as a Blocker too (wrong or ambiguous key).
5. Also check every worked example's last visible step does not already state the result its `:::try` asks for.

Severity: Blocker for a giveaway or a wrong or ambiguous key; Major for a partial cue that narrows to one choice without the rule.

Output, written with the Write tool to the findings file your task names:
`Severity | file:line | item | how it is given away or why the key is wrong | fix (one line)`
then one line per lesson: `OK` or the number of flagged items. End with `PRECHECK VERDICT: PASS` (0 flagged) or `PRECHECK VERDICT: FAIL (N Blockers, M Majors)`.

Report (short): verdict, counts per lesson, the findings file path.
