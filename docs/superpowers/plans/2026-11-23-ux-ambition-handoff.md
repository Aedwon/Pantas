# UX ambition round 1: hand-off to the CSE release lead

Date: November 23, 2026. From: UX design lead. To: CSE release lead (owns the build and the single Flutter slot); copy: operations manager.

Policy revision read: main `b2110fb7a` (AGENTS.md, WORKFLOW.md, SUBAGENTS.md, process-improvement.md rules 1 to 9 and the Nov 23 entries).

## What to build

| Change | Spec | Canvas | Council | Priority |
|---|---|---|---|---|
| Lesson reader full screen, "4 Held" | `docs/superpowers/specs/2026-11-23-lesson-reader-full-screen-design.md` | https://claude.ai/artifact/Sb3f8m64ZpouMDBKjTE14K | 4 rounds plus a 5-run real-lesson check | 1 |
| B2 Answer track into the results | `docs/superpowers/specs/2026-11-23-core-loops-polish-design.md` | https://claude.ai/artifact/1tyuTs3m832KjUtgZdvzXZ | 3 rounds | 2 |
| B4 Mock breakdown rows open the subject | same | same | same | 3 |
| B3 Wrong answer leads the eye | same | same | same | 4 |
| B5 Fewer words in the loop | same | same | same | 5 |
| B1 Start a session from the card | same | same | same | 6 |

Rulings: `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, sections "Nov 23, lesson reader full screen" and "Nov 23, core loops polish". Each spec carries boards, motion values and acceptance checks. Build 1:1 to the boards; the specs' rules govern positions the boards draw at rest.

Constraints: phone is the motion reference (rule 1); approved motion is kept except where a spec changes it (rule 2); prefers-reduced-motion per spec; no content or schema change; no prod change without the usual "ship it".

## Reference boards to update after the build (operations manager list)

Pantas Web (https://claude.ai/artifact/4mUpC5apRsMhtQDg5VVjx8):
- RD_Focus, RD_FocusOpen, RD_Figure, W_Reader (now Polish C): replace the left "In this lesson" outline with the 4 Held layout and the section line.
- RD_FocusMotion: scene 1's outline dot becomes the section line filling; add the held figure and the sticky line moving 92 to 32 px with the bar.
- W_Question, W_QRight, W_QMiss: the answer track in the bar, no bar hints (B2, B5), B3 reveal timing.
- W_SessionEnd: marks into the results row and the score count-up (B2). Today the web board shows a static score while the phone (QV_EndPro) counts up, which breaks rule 1; B2 closes that gap. The notes prompt text (B5) applies only where the board shows it.
- W_MockResults and the wide All questions review: breakdown chevrons and the subject filter chip (B4).
- W_QuizTab: the card-to-session transition (B1).

Pantas Redesign, phone (https://claude.ai/artifact/M1hptDwMLUcuGxSAGescHi):
- QV_Answer, QV_Last: the track in the bar, no hints, B3 timing.
- QV_EndPro, QV_EndFree, QV_EndLastToday: marks into the row (B2); QV_EndPro prompt text (B5).
- MK_Results: breakdown chevrons (B4). MK_ReviewWrong, MK_ReviewAll: the filter chip (B4); MK_ReviewWrong prompt text (B5).
- QZ_Tab: the card-to-session transition (B1).
- RD_* phone boards: no change.

Superseded boards on the new canvases: on "Lesson Reader Full Screen", directions 1, 2 and 3 (`Main`, `W2_Pinned`, `W3_Column` and their V and K boards) are rejected options kept for the record; only 4 Held boards are approved.
