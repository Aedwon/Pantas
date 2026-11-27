# Math pilot, Codex full read 2 of 2, the LAST read (Codex GPT 6.2 Sol high, read-only)

Follow `codex-math-pilot-r1.brief.md` in this folder in full (startup, hard rules, the 10 lessons, the format, the audit
standard, severities, format), with these changes:

- Target commit: the head of `content/lesson-walkthrough-cse-r1` named in the run prompt. Write findings to `pilot-r2.md`
  in this folder, appending after each lesson. End with `PILOT VERDICT: PASS` (0 Blockers) or
  `PILOT VERDICT: FAIL (N Blockers, M Majors, K Minors)`, then `STAGE-DONE`.
- Read 1 and its fixes: read 1 (`docs/content/verification/walkthrough-work/codex-math-pilot-r1.md` in the worktree) found 1
  lesson Blocker, 44 Majors and 12 Minors. Every Blocker and Major row was fixed by pattern, except the rulings below. Read
  every lesson fully again, as a student. Report every Blocker. Report Majors and Minors too; they are fixed once after
  this read.
- Lead ruling, accepted by the manager (spec revision point 3): a pair may show the cited wrong choice's mistake with other
  numbers. Do not flag a pair because its values differ from the cited choice, and do not ask for a note to the student about
  the quiz. Do flag a pair whose Wrong line shows a different mistake from the cited choice.
- Manager ruling: this pilot proves the format, not new teaching. A skill that a linked quiz question asks but the lesson's
  key points do not cover is listed as a Minor marked "for later", not a Major. A short rule added for such a skill is
  audited like any other line.
- Question files: the two read-1 question Blockers (`content/questions/mathematics/algebra/word-problems.yaml` lines 221 and
  359) are with the release lead. Do not repeat them.
- Lead's checks at the target (do not rerun): parser 10/10; `lesson_checks.dart` from `tools/walkthrough-checks-r1`
  `9cd88773b` reports nothing for the 10 lessons; every lesson at or under 900 words before a tap.
