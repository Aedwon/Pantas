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
