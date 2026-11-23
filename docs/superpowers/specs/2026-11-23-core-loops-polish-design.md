# Core loops polish (B1 to B5): build spec

Date: November 23, 2026. Design: UX design lead (operations manager brief; Aedwon away, decisions delegated). Build: CSE release lead. Status: council-approved (Gemini 4 Neon High and Claude Fable 5.2 high). Ruling: `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, section "Nov 23, core loops polish".

Canvas (source of truth, build 1:1): "Core Loops Best in Class", https://claude.ai/artifact/1tyuTs3m832KjUtgZdvzXZ

Shared values: ease `cubic-bezier(.32,.72,0,1)` ("shared"); right answer = approved ring pulse (.7 s ease-out) and check; wrong = approved shake (.42 s `cubic-bezier(.36,.07,.19,.97)`); explanation panel = approved slide-in (.5 s `cubic-bezier(.2,.9,.3,1)`, 28 px). Reduced motion everywhere: no travel, scale or shake; state changes become fades of at most 200 ms or happen at once. Phone is the motion reference: each change ships on phone and wide web together.

Priority (council rank, by impact): B2, B4, B3, B5, B1.

## B1. Start a session from the card itself

Plain language: pressing Start on the Quiz tab's card grows that card into the session screen; leaving folds it back into the card.

- Where: Quiz tab, the card that starts today's questions, and the mock card (QZ_Tab phone, W_QuizTab wide).
- Motion (380 ms, shared ease): the card's surface expands from the card's rect to the full screen. It keeps the card's corner radius and reaches 0 only in the last 100 ms. Its color blends from #FFFFFF to #F5F5F7. The card's text fades out in the first 40 ms, before the surface passes a third of the screen. The first question fades in over the last 200 ms.
- Back (Esc, X, system back): the reverse, 300 ms. The session content fades out in the first 80 ms; the card's text fades in over the last 100 ms.
- This replaces the default page transition for this one route only (the Nov 4 wide page transition stays everywhere else).
- Reduced motion: 200 ms crossfade.
- Boards: `Main` (wide before), `B1_WideMotion`, `B1_PhoneBefore`, `B1_PhoneMotion`.
- Content: none new.

## B2. Answer track in the session bar, carried into the results

Plain language: a row of small marks in the session bar fills teal or red as you check each answer; at the end those same marks fly up and become the results row, and the score counts up.

- Track: one mark per question, 10 x 4 px (phone 8 x 4), radius 99, 3 px gap, between the count ("4 of 10") and the flag. Unanswered #D1D1D6; current solid #1D1D1F; checked teal #0B7A68 or red #D70015, color change 200 ms. Over 20 questions: one thin continuous line that fills in proportion, no marks.
- The bar hints are gone (B5), so the track takes their place; the bar does not change width between pick and check.
- End: on the last Finish, the question screen fades out (180 ms). The marks then fly from the bar to the results row and grow into the approved 30 px numbered circles (360 ms each, shared ease, 20 ms stagger) across an empty screen. The approved ring fill and the score count-up (1.4 s as approved; the phone's QV_EndPro already counts 0 to 7) start as the last two marks land. "in 9 minutes" and Done fade in after the marks land. The marks have landed within about 0.75 s of Finish; the total stagger is capped at 180 ms, so 11 to 20 marks still land by about 0.75 s. Done is pressable as soon as it appears; the count-up runs on. Over 20 questions there are no marks to fly: the results row fades in with the ring.
- Reduced motion: the marks do not travel; the results row fades in with the ring.
- Boards: `B2_WideBar`, `B2_WideEnd` (motion), `B2_PhoneBar`, `B2_PhoneLong`.

## B3. Wrong answer: lead the eye to the right one

Plain language: after a wrong check, the screen first shows your mistake, then a moment later shows the right answer.

- Check, wrong: the picked row turns red and its badge turns red at once, then shakes (approved .42 s). 120 ms after the shake ends, the right row turns teal with the ring pulse, the other wrong rows dim to 42% at the same moment, and the explanation panel slides in. Total about 540 ms to the reveal.
- An Enter or Next press during the shake or the pause completes the reveal at once; it does not advance. The next press advances.
- Right answer: unchanged.
- Reduced motion: no shake or ring; colors change together.
- Boards: `B3_WideMid`, `B3_WideWrong`, `B3_PhoneWrong`, `B3_Motion`.
- Split in the council: Gemini wanted the reveal at 300 ms with no pause; Fable kept the pause. Fable's call is final (Nov 23 process: Fable decides a split).

## B4. Mock breakdown rows open that subject's questions

Plain language: on mock results, tapping a subject in the breakdown opens the review of that subject's questions, mistakes first.

- Each breakdown row becomes a button with the approved row chevron (#B8B8BD) and the row press (background #F7F7F9, 150 ms).
- It opens the approved All questions review on the Wrong tab, filtered to the subject, with a removable chip under the tabs (subject name and an x). Tab counts follow the filter. If the subject has no wrong answers, it opens on All. The subject's section header hides while the filter is on.
- Uses existing data only: every question has a subject.
- Boards: `B4_WideResults`, `B4_WideReview`, `B4_PhoneResults`, `B4_PhoneReview`.

## B5. Fewer words in the loop

| Where | Before | After |
|---|---|---|
| Session bar, before a pick | "Pick with A, B, C or D" | removed (the letters are on the choices) |
| Session bar, after a pick | "Change your pick any time before you check" | removed |
| Session end, notes prompt | "Tell Pantas why you got each one wrong. The better your notes, the more every review helps." | "Note why you missed each one." |
| Mock review, notes prompt | the same two sentences | "Note why you missed each one." |

The button stays "Finish the Notes" (chosen July 27). Boards: `B5_*Before` and `B5_*After` pairs. Copy settled by the lead under D191; voice rules in `AGENTS.md`.

## Acceptance checks

1. Side by side with every board at 1440 and 390, light and dark: layout, spacing, type, color and copy match. Differences classed per the Nov 23 process entry.
2. Motion recorded on phone and wide, compared with the motion boards for timing and easing; reduced motion checked on both.
3. B2: a 10-question, a 20-question and a 25-question session; the bar width does not change from pick to check; at 25 the row fades in with the ring; the marks land within 0.75 s of Finish, then the ring and count-up run their approved 1.4 s.
4. B3: Enter pressed 100 ms after a wrong Check completes the reveal and does not advance.
5. B4: a subject with wrong answers opens on Wrong with matching counts; a subject with none opens on All; removing the chip shows the full review.
6. No new string outside the B5 table.

## Standards applied

- Instructional design (`~/Documents/Projects/agent-standards/instructional-design.md`): ID-FB-ELAB, ID-FB-TIME, ID-ERR-FIX, ID-GOAL, ID-FB-RELESSON.
- Web interface design: WEB-M1 to WEB-M6, WEB-M8 (B3's Enter completes, never blocks), WEB-M10, WEB-M11, WEB-M13, WEB-I6, WEB-I10.
- UX writing: UXW-CONCISE, UXW-LEAVE, UXW-FRONT.

## Dropped (schema check, manager, Nov 23)

- Try-first choices in lesson examples: 38 of 629 examples list choices, none has a structured correct answer, and only 15 state the letter in parseable text.
- Linked words in question figures: 193 questions have a figureSpec and none has text labels.
- A lesson sheet from "From the lesson": he left that link out on Nov 5.
