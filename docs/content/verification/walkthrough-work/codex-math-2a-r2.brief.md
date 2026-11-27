# Math batch 2a, Codex full read 2 of 2, the LAST read (Codex GPT 6.2 Sol high, read-only)

Follow `codex-math-2a-r1.brief.md` in this folder in full (and the pilot brief it points to), with these changes:

- Target: the commit named in the run prompt. Write findings to `batch-2a-r2.md` in your working directory, appending after
  each lesson. End with `BATCH VERDICT: PASS` (0 Blockers) or `BATCH VERDICT: FAIL (N Blockers, M Majors, K Minors)`,
  then `STAGE-DONE`.
- Read 1 and its fixes: read 1 (`codex-math-2a-r1.md` in this folder) found 3 Blockers (one in a question file), 19 Majors
  and 17 Minors. Every lesson Blocker and Major row was fixed by pattern. Read every lesson and every picture fully again,
  as a student. Report every Blocker. Report Majors and Minors too; they are fixed once after this read.
- Lead rulings: "For later" Minors were left unchanged. Display math stays in double dollars (the project lesson style guide
  uses them for display lines); do not flag fences. The question-file Blocker (`ratio-and-proportion.yaml` 0020) is with
  the release lead; do not repeat it. The mixture picture's input containers are drawn without waterlines and the 20 L
  mixture is drawn larger, because the two input volumes are the unknowns.
- Lead's checks at the target (do not rerun): parser 13 of 13 (12 lessons plus mixture); `lesson_checks.dart` reports
  nothing for them; every lesson at or under 900 words before a tap; SVG preflight 0 failures.
