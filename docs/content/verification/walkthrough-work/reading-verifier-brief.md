# Reading Comprehension verifier brief (session 5, Nov 27, E-198)

Lead: Claude lesson lead. Policy read: `origin/main` `3fd9fdf0e`. Read in full and follow, in order:
1. `docs/content/verification/walkthrough-work/verifier-brief.md` (method, hard limits: READ-ONLY, no scripts, no redirection, no subagents; report format).
2. `docs/content/verification/walkthrough-work/reading-writer-brief.md` (what the writers had to do; audit against all of it).
3. `docs/content/verification/walkthrough-work/pattern-checklist.md` (P1 to P5).
4. `docs/content/verification/walkthrough-work/codex-grammar-r8-full.md`: the kinds of finding the full Codex read makes. Look for each kind in your lessons; that read decides PASS, so find them first.

Also check, in every lesson:
- Each `:::pair` shows the mistake on the passage the lesson is working at that step. A Wrong line copied from a quiz passage the student has not seen, or in the other language, is a Major. Its mistake must still match a cited choice in `content/walkthrough-trap-evidence.json`.
- Every check, try and example has its own original passage, not a quiz passage and not one used earlier in the lesson.
- Every multiple-choice item has exactly one defensible answer, and no choice can be eliminated by surface form alone (only one is a full sentence, only one repeats a stem phrase).
- Every `**Solution:**` opens with one short lead-in naming what we find and in which passage. Every chain ends at the finished answer as a full statement, never a letter alone.
- Every `**Check:**` confirms the answer a different way; it never repeats the step above it or the answer's reason.
- Pronouns: no *he* or *she* for a person the passage does not gender, including in English glosses of Filipino *siya*.
- Size: pre-tap words (outside `:::answer`, `:::why`, comments, front matter) at most 900. Where a lesson is over, name the lines a reader would not miss.
- A lesson with an `<!-- ILLUSTRATION: ... -->` marker: open its SVG in `content/illustrations/reading-comprehension/comprehension-skills/<lesson>/` and check that the text around it uses the figure's data.

Report under 800 words: verdict, one line per lesson, findings as `Severity | file:line | problem | fix`. Write the same findings to the scratch file your task names, with the Write tool.
