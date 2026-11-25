# Paused session fold into the reference canvases, 25 November 2026

Built look: branch `ux/paused-review-a-r1` at 3869ece63. His picks: paused option A, and "1 of 11 is redundant, maybe remove the overall so only the rows have one" (launch log, "Nov 25, about 4:06 AM Manila").

## Hold

The manager put the Quiz tab paused card (phone and wide) on hold while Aedwon asks about its Discard spacing. This fold changes the Home Reviews sheet boards only. `QZ_Resume`, `QZ_Tab` and `W_QuizTab` are not changed and still draw board spacing.

## Boards changed

Pantas Redesign, https://claude.ai/artifact/M1hptDwMLUcuGxSAGescHi: version 1795552317-f92b (497) to version 498 (id 1795553888-1f89).

| Board | Change |
|---|---|
| HE_ManyLessons | Reviews sheet header shows only "Reviews". The Home row count and the Lessons and New questions sheets are untouched. |
| HE_ReviewsPaused (new) | Paused board option A, phone sheet: no sentence, one Resume, centered "Discard this session", session row "1 of 11", no header count. |
| HE_ReviewsOther (new) | Another quiz is paused: Start dims under "Finish or discard your paused quiz first." |
| HE_ReviewsPart (new, part) | Byte copy of the paused board's P_Sheet, with the header count div removed. The two boards above import it. |

Pantas Web, https://claude.ai/artifact/4mUpC5apRsMhtQDg5VVjx8: version 187 to version 188 (id 1795549453-8386 to 1795553874-3fb1).

| Board | Change |
|---|---|
| HM_ReviewsPanel | Header shows only "Reviews" (count removed, Close kept). |
| HM_ReviewsPaused (new) | Same panel with option A: session row "1 of 11" with its ring, full width Resume, centered "Discard this session". Placed right of HM_LongTitle at x 12160. |

Phone boards sit right of HE_Everything on the Home page (x 1880, 2350, 2820, y 7632). Source: paused board https://claude.ai/artifact/9MLsiFtEwsdLodfe8eHZig (P_Sheet, W_Home option A), version 1795550246-3f3e.

## Notes

- Edits were made by text replacement on the read copies. No restyling.
- Built Home sheet differs from the board in one place: the build keeps the Close button off the phone sheet (already so on the boards) and shows Resume only when the paused session is this sheet's own.
- Old version numbers for Web (187) and Redesign (497) are the publish counter minus one; the version ids are exact.

## Quiz tab card (released Nov 25)

The hold above is lifted. His approval (Nov 25): "yes A lgtm, go ahead with it". Source look: option A on the paused board, https://claude.ai/artifact/9MLsiFtEwsdLodfe8eHZig (P_Quiz and W_Quiz, v=A). Built version: branch `ux/paused-card-r2`; goldens `quiz_tab_paused_390.png` and `quiz_tab_paused_1440.png`.

Pantas Redesign, https://claude.ai/artifact/M1hptDwMLUcuGxSAGescHi: version 1795558163-cf47 to version 501 (id 1795558523-e8c7).

| Board | Change |
|---|---|
| QZ_Resume | The "You paused. Every answer was saved." line is removed. Resume stays. "Discard this session" stays centered, now 20 px under Resume and 24 px above the card bottom, measured to the text (his call from using the app; board A draws 12 and 16). |
| QZ_ResumeNamed (new) | Same card with one line, "Paused: Algebra practice", 14 px above Resume, secondary text. For a paused quiz that is not Reviews or New questions. Placed right of QZ_Picker at x 2820, y 260. |

Pantas Web, https://claude.ai/artifact/4mUpC5apRsMhtQDg5VVjx8: version 1795558524-25db to version 192 (id 1795558552-d27b).

| Board | Change |
|---|---|
| QZ_Resume | The sentence is removed. The foot is the board A foot: Discard this session and Resume, right aligned, wrapping. The foot markup is a byte copy of the W_Quiz v=A foot with the Discard label unchanged. |
| QZ_ResumeNamed (new) | Same foot with "Paused: Algebra practice" as a full-width secondary line, 12 px above the buttons (foot gap 16 with a margin of -4). Placed right of QZ_Resume at x 6080, y 0. |

Not byte copies:
- Phone: the Discard padding (14 above, 24 below) and the named line are written to the build's measured spacing, not copied from the board.
- Phone and wide: both QZ_Resume boards keep their own rows and counts ("Session 1 of 2", "6 of 10", "0 of 7") and the UPCAT mock card; the built golden shows other fixture numbers.
- `Z_Decisions` on Redesign still quotes the old sentence in its Quiz tab state text. It is prose, not a board, and was not changed.
- Old version numbers are the ids read at the start of this fold; the publish counter for Web (192) is exact, Redesign 501 follows the previous 500.
