# Paused review session board (E-146), Nov 24

UX design lead, board only. Policy read from main at ec3211c1a. Nothing built or shipped.

## What he asked

"this too. this could be more elegantly designed", with two dark phone screenshots: the Home Reviews sheet while a quiz is paused, and the Quiz tab's paused card.

## What the search found

Searched: Pantas Redesign and Pantas Web exports (`web-design/pantas-handoff/mobile` and `web`, all titles and text for paused, resume, discard, review, sheet), `docs/design/DECISIONS.md`, the Quiz tab spec and decision log, the CSE QA findings, and the live widget on main.

- Quiz tab paused card: drawn on approved `QZ_Resume` (phone and wide, D-159, approved Oct 2). The live card matches it except "Discard this session" sits left of center (the release lead is centering it). He is now asking for a redesign of an approved look, so it is on the board as his lived-experience call, not a build fix.
- Home Reviews sheet while a quiz is paused: no board draws it. The approved sheet (`HE_ManyLessons`, wide `HM_ReviewsPanel`) has one green "Start Reviews" and no Close button. The live sheet adds a sentence, Resume, Discard, keeps Start Reviews, and adds Close.
- Build defect in his screenshot, whatever he picks: the paused quiz is this same review session (Quiz tab shows 1 of 11), but the sheet shows "0 of 11", an empty ring and the generic "You paused a quiz" notice. The sheet should treat it as the session in progress.

## What was made

Claude Design canvas "Paused Review Session": https://claude.ai/artifact/9MLsiFtEwsdLodfe8eHZig (private until he shares it; page Options). Rows:

- Live tonight: phone sheet dark, phone Quiz tab dark, wide Home panel light.
- A, Resume takes the button: no sentence; the session row shows its progress; one green Resume; centered borderless "Discard this session". Recommended.
- B, Discard and Resume side by side: no sentence; one row with borderless "Discard" and green Resume.
- C, approved line kept, centered: "You paused. Every answer was saved." centered, Resume, centered Discard.
- Any option, another quiz is paused (lead decision, undrawn state): the sheet dims Start Reviews and shows the approved line "Finish or discard your paused quiz first." with no other actions, matching how the Quiz tab already dims Customize your own and the mock.

Each option row: phone sheet light and dark, phone Quiz tab light and dark, wide Home panel light, wide Quiz tab dark. Frames reuse the approved board markup and the Pantas Web stylesheet (copied as an asset). Worker-chosen details to check on his pass: dark sheet color #1F1F1F (no approved dark sheet exists), dark grabber and empty ring #4A4A4A, wide dark nav inlined from `DK_Quiz`. On wide Quiz, A and B differ only in the Discard label. The lead did not render the board; he does the visual check.

## Open

- His pick of A, B or C. Until then nothing reaches prod (Nov 24 rule).
- After the pick: a build task for both surfaces, including the sheet defect above and removing the sheet's Close button.
