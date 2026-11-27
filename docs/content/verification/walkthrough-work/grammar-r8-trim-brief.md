# Grammar round 8 trim brief (session 5, Nov 27, E-198)

You are a content worker (trimmer) for the Claude lesson lead. Policy read by the lead: `origin/main` `3fd9fdf0e`. Read first and follow: `docs/content/verification/walkthrough-work/worker-rules.md` (hard limits bind you: Edit tool only, Bash read-only, no redirection, no scripts, no git writes, no subagents, run no checks).

Why: the round 8 fixes added a few words to lessons that must stay at or under their pre-tap word count before the round 5 sweep (`git show 518404ccd^:<path>`). Aedwon's rule (Nov 26): "connect things better, not explain with more words". Pre-tap words are words outside the front matter, `:::answer`, `:::why` blocks and HTML comments.

For each lesson in your task, the lead gives the current count and the budget. Cut at least the difference, plus 2 words of margin:
- Cut only words a reader would not miss: a repeated clause, a filler phrase ("in this sentence", "notice that"), a second example of the same point in teaching prose, a restated rule in a lead-in.
- NEVER cut: a `**Check:**` line, the lead-in of a worked example, the finished sentence at the end of a chain, a scope word ("usually", "here", "such as"), a pair's Right or Wrong line, a checklist line, or anything a round 8 fix added to close a finding (`git diff ec681506e~1 ec681506e -- <path>` shows those changes; leave them whole).
- Do not change meaning, examples, answers or any check or try. Do not touch `<!-- FIGURE WANTED:` lines.
- Prefer cutting inside `## Core Concept` prose.

Report (short): per lesson, the words cut (old text and new text, one line each) and your estimate of the new count. Files touched.
