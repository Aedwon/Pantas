# First run guided taste board (E-165), Nov 25

UX design lead, board only. Policy read from main at fc8f45f26; estimate 805d23aeb; rulings 5b4bf7528. Nothing built or shipped.

## What he asked

His words and the lead rulings are in `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`,
"Nov 25, UX design lead: first run guided taste board (E-165)". In short: a guided try of studying then quizzing
before the long assessment; the assessment stays required for the accurate score; a trial score may show. Before
the board he decided: the taste has a Skip, and after it (finished or skipped) Home opens as now with the
"take the assessment" card.

## Board

Claude Design canvas "First Run Guided Taste": https://claude.ai/artifact/D3JLTrRGiN8vjnfLrbhoMN (private until
he shares it). Pages: Flow (phone light and dark, wide light and dark) and Choices. Built by two Sonnet workers from
the exported approved boards in `web-design/pantas-handoff/`; one fresh Sonnet reviewer rendered it once headless
(no unstyled or clipped frames, no must-fix item); the lead removed a duplicate Skip on the phone intro.

Flow: setup end (O_Days) -> "Try Pantas first" (Start, Skip) -> one short lesson (Fractions, Decimals, and
Percentages: Core Concept, the D-to-P aid, Example 1) -> 3 questions with the explanation after each -> "Taste
finished." with "2 /3 correct" (session-end board form, no percent, no ring) and one line saying the assessment
gives the accurate score -> Home exactly as now -> assessment, results, Home with the score (unchanged boards).
Reduce Motion frame for the end screen.

## His open choices (on the Choices page)

1. Which lesson the taste uses: A, one fixed starter lesson per exam (recommended, no extra screen); B, the learner
   picks a subject first.
2. Leaving the assessment loses every answer (code: answers stay in memory until the last question; leaving,
   browser Back, a reload or closing the app loses them). A, keep as now; B, save answers on the device as they go
   and offer Continue on Home's card (recommended).

## Lead rulings (rule 4, recorded)

Taste answers do not count toward the assessment (they follow a lesson on the same topic, so they show
short-term recall); the assessment keeps its length and leaves out the 3 taste questions. Trial score shows only on
the taste end screen. Taste answers enter no score or Accuracy figure; the lesson counts as read.

## Known gaps

- Sample exam is the boards' UPCAT so the unchanged frames match; the CSE launch uses the same layout.
- The lesson's example solution is shown open, not behind "Show solution".
- Wide end screen: Done sits right of a centered title, not at the content column's right edge (minor, reviewer).
- Phone and wide end screens name the one mistake with different short titles (minor).

## Next

His picks on choices 1 and 2. Then a spec and plan under WORKFLOW.md, with a build estimate; the build needs the
assessment selector to exclude taste questions and, if he picks 2B, on-device saving of assessment answers.
Canvas source files: lead scratchpad `canvas/project/` (disposable; the canvas holds every file).

## Revision, Nov 25 (E-176)

His comments and picks are in the rulings file, "Nov 25, UX design lead: first-run board revision (E-176)". The canvas is now "First Run" (version 1795614653-2f1d): the Choices page is gone, his picks (one fixed lesson; assessment answers saved as you go with Continue on Home) are on the Flow page as frames 8b and 8c, "Try Pantas first" shows three steps with previews, and the copy is tightened. Next: a spec and plan under WORKFLOW.md with a build estimate, when the manager asks for the build.
