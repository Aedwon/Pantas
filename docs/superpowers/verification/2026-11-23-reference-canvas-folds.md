# Reference canvas folds, 23 November 2026

Folded the approved later boards into the two reference canvases: Pantas Web (https://claude.ai/artifact/4mUpC5apRsMhtQDg5VVjx8) and Pantas Redesign (https://claude.ai/artifact/M1hptDwMLUcuGxSAGescHi). Each source board was copied byte for byte. Only file names, dc-import names and stylesheet paths changed where a name would clash or a source file had to move with it. Nothing was restyled.

Final versions: Pantas Web version 173, Pantas Redesign version 481. Source canvases were not changed or deleted.

## Counts

- Replaced: 4 (W_Reader, RD_Real, QV_Figure, QS_Figure)
- Added: 140 (33 part boards included; parts hold files that other added boards import)
- Edited in place: 21 boards (the N of Y caret, phone only)
- Skipped: see Skipped
- Uncertain: see Uncertain

## Method notes

- Frames that grew were resized and their neighbours moved down so no frames overlap: web overview rows below W_Reader moved +3040; phone study rows from y 7860 moved +3082.
- The Pantas design system files (ds/pantas tokens and bundle, identical across the source canvases by sha256) were installed in both canvases, and a designSystems record added, because the added boards link to them.
- Support stylesheets were copied server side from their source canvases: reader.css, cx/pantas.css, cx/cx.css, sf.css, ts.css, qa/pantas.css.
- Splash boards used the Pantas shared stylesheet. The source blob 58d0218b... has the same sha256 as the web reference stylesheet (blob 9c74f4aa...), so the web boards were repointed to it. The phone canvas had none, so the file was uploaded there (/_blob/d8aa5746...).
- Part labels: no reference board draws "Part X of Y · N questions" (checked the local export, both canvas.json files and every board added here). CX_Paper holds the mock paper header "Part 2 of 3 · Reasoning", which is the by-part paper header, not the removed lesson label.

## Changes

One row per change. Source board names are from the source canvas. Each area lists its approval quote with file and line.

### 1. Lesson Reader Polish

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2494, "C looks good to me. but remove the N of M eyebrows"; spacing 104 px wide and 72 px phone at docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2496

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Web (wide) | W_Reader | replaced | Lesson Reader Polish / WideLightC |
| Pantas Web (wide) | W_ReaderDark | added | Lesson Reader Polish / WideDarkC |
| Pantas Web (wide) | W_ReaderPart | added (part) | Lesson Reader Polish / Reader (component, default set to C) |
| Pantas Redesign (phone) | RD_Real | replaced | Lesson Reader Polish / PhoneLightC |
| Pantas Redesign (phone) | RD_RealDark | added | Lesson Reader Polish / PhoneDarkC |
| Pantas Redesign (phone) | RD_ReaderPart | added (part) | Lesson Reader Polish / Reader (component, default set to C) |

### 2. Phone Exam Date Picker

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2927, "go with A for exam date picker" (docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2927); "okay i've chosen, please start the integrations" (docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2951); age stepper "A" (docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2953)

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Redesign (phone) | O_DateFinal | added | Phone Exam Date Picker / Exam_Final_DS4 |
| Pantas Redesign (phone) | O_AgeFinal | added | Phone Exam Date Picker / Birth_Final_DS4 |
| Pantas Web (wide) | OB_AgeFinal | added | Phone Exam Date Picker / Birth_Final_DS4 |

### 3. Under 13 Accounts Screens

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:4010, "1A 2A 3A 4B 6B 7A ... 8A"; "Keep 9A" at docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:4013

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Redesign (phone) | U13_Guardian | added | Under 13 Accounts Screens / Main |
| Pantas Redesign (phone) | U13_SignIn | added | Under 13 Accounts Screens / S2S |
| Pantas Redesign (phone) | U13_Setup | added | Under 13 Accounts Screens / S2A |
| Pantas Redesign (phone) | U13_SetupUsed | added | Under 13 Accounts Screens / S2AE |
| Pantas Redesign (phone) | U13_ChildNotice | added | Under 13 Accounts Screens / N2C |
| Pantas Redesign (phone) | U13_AdultAsk | added | Under 13 Accounts Screens / Q3A |
| Pantas Redesign (phone) | U13_ExamPick | added | Under 13 Accounts Screens / EX5 |
| Pantas Redesign (phone) | U13_SettingsRoot | added | Under 13 Accounts Screens / ST4B |
| Pantas Redesign (phone) | U13_ForParents | added | Under 13 Accounts Screens / ST4B2 |
| Pantas Redesign (phone) | U13_Withdraw | added | Under 13 Accounts Screens / D4W |
| Pantas Redesign (phone) | U13_Delete | added | Under 13 Accounts Screens / D4D |
| Pantas Redesign (phone) | U13_WithdrawLast | added | Under 13 Accounts Screens / D4LW |
| Pantas Redesign (phone) | U13_DeleteLast | added | Under 13 Accounts Screens / D4L |
| Pantas Redesign (phone) | U13_SwitchChild | added | Under 13 Accounts Screens / S6B |
| Pantas Redesign (phone) | U13_AddChild | added | Under 13 Accounts Screens / S7S |
| Pantas Redesign (phone) | U13_AddNickname | added | Under 13 Accounts Screens / S7N |
| Pantas Redesign (phone) | U13_AddLimit | added | Under 13 Accounts Screens / S7A |
| Pantas Redesign (phone) | U13_CodeGate | added | Under 13 Accounts Screens / C8AD |
| Pantas Redesign (phone) | U13_CodeWrong | added | Under 13 Accounts Screens / C8AW |
| Pantas Redesign (phone) | U13_CodeResent | added | Under 13 Accounts Screens / C8AR |
| Pantas Redesign (phone) | U13_Sibling | added | Under 13 Accounts Screens / S9A |
| Pantas Redesign (phone) | U13_SiblingNotice | added | Under 13 Accounts Screens / S9AN |
| Pantas Redesign (phone) | U13_SiblingOn | added | Under 13 Accounts Screens / S9AO |

### 4. Custom Exam Screens

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2534, "Custom Exam Screens / 1 B / ... 5 B / 6 A / 7 as is / 8 B for all except choose A Later parts as faded grids, wide"; binding list at docs/superpowers/specs/2026-11-04-custom-exams-on-web-design.md:767-781

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Web (wide) | CX_PickOb | added | Custom Exam Screens / PickOb |
| Pantas Web (wide) | CX_PickObBDark | added | Custom Exam Screens / PickObBDark |
| Pantas Web (wide) | CX_SetPickB | added | Custom Exam Screens / SetPickB |
| Pantas Web (wide) | CX_SetPickBDark | added | Custom Exam Screens / SetPickBDark |
| Pantas Web (wide) | CX_WarnA | added | Custom Exam Screens / WarnA |
| Pantas Web (wide) | CX_Settings | added (part) | Custom Exam Screens / Settings |
| Pantas Web (wide) | CX_Setup | added | Custom Exam Screens / Setup |
| Pantas Web (wide) | CX_SetupBDark | added | Custom Exam Screens / SetupBDark |
| Pantas Web (wide) | CX_LimitB300 | added | Custom Exam Screens / LimitB300 |
| Pantas Web (wide) | CX_LimitBSec | added | Custom Exam Screens / LimitBSec |
| Pantas Web (wide) | CX_MockSetup | added | Custom Exam Screens / MockSetup |
| Pantas Web (wide) | CX_MockSetupDark | added | Custom Exam Screens / MockSetupDark |
| Pantas Web (wide) | CX_MockSetupStrict | added | Custom Exam Screens / MockSetupStrict |
| Pantas Web (wide) | CX_PaperA | added | Custom Exam Screens / PaperA |
| Pantas Web (wide) | CX_Paper | added (part) | Custom Exam Screens / Paper |
| Pantas Web (wide) | CX_StrictB | added | Custom Exam Screens / StrictB |
| Pantas Web (wide) | CX_StrictBDark | added | Custom Exam Screens / StrictBDark |
| Pantas Web (wide) | CX_OutB | added | Custom Exam Screens / OutB |
| Pantas Web (wide) | CX_OutBDark | added | Custom Exam Screens / OutBDark |
| Pantas Web (wide) | CX_BetweenWide | added | Custom Exam Screens / BetweenWide |
| Pantas Web (wide) | CX_BetweenWideDark | added | Custom Exam Screens / BetweenWideDark |
| Pantas Web (wide) | CX_PauseWide | added | Custom Exam Screens / PauseWide |
| Pantas Web (wide) | CX_PauseWideDark | added | Custom Exam Screens / PauseWideDark |
| Pantas Redesign (phone) | CX_PickPh | added | Custom Exam Screens / PickPh |
| Pantas Redesign (phone) | CX_PickPhBDark | added | Custom Exam Screens / PickPhBDark |
| Pantas Redesign (phone) | CX_SetPhPickB | added | Custom Exam Screens / SetPhPickB |
| Pantas Redesign (phone) | CX_SetPhPickBDark | added | Custom Exam Screens / SetPhPickBDark |
| Pantas Redesign (phone) | CX_WarnPhA | added | Custom Exam Screens / WarnPhA |
| Pantas Redesign (phone) | CX_SettingsPh | added (part) | Custom Exam Screens / SettingsPh |
| Pantas Redesign (phone) | CX_SetupPh | added | Custom Exam Screens / SetupPh |
| Pantas Redesign (phone) | CX_SetupPhBDark | added | Custom Exam Screens / SetupPhBDark |
| Pantas Redesign (phone) | CX_LimitPhB300 | added | Custom Exam Screens / LimitPhB300 |
| Pantas Redesign (phone) | CX_LimitPhBSec | added | Custom Exam Screens / LimitPhBSec |
| Pantas Redesign (phone) | CX_MockSetupPh | added | Custom Exam Screens / MockSetupPh |
| Pantas Redesign (phone) | CX_MockSetupPhDark | added | Custom Exam Screens / MockSetupPhDark |
| Pantas Redesign (phone) | CX_PaperPh | added | Custom Exam Screens / PaperPh |
| Pantas Redesign (phone) | CX_PaperPhBDark | added | Custom Exam Screens / PaperPhBDark |
| Pantas Redesign (phone) | CX_StrictPhB | added | Custom Exam Screens / StrictPhB |
| Pantas Redesign (phone) | CX_StrictPhBDark | added | Custom Exam Screens / StrictPhBDark |
| Pantas Redesign (phone) | CX_OutPhB | added | Custom Exam Screens / OutPhB |
| Pantas Redesign (phone) | CX_OutPhBDark | added | Custom Exam Screens / OutPhBDark |
| Pantas Redesign (phone) | CX_BetweenPh | added | Custom Exam Screens / BetweenPh |
| Pantas Redesign (phone) | CX_BetweenPhDark | added | Custom Exam Screens / BetweenPhDark |
| Pantas Redesign (phone) | CX_PausePh | added | Custom Exam Screens / PausePh |
| Pantas Redesign (phone) | CX_PausePhDark | added | Custom Exam Screens / PausePhDark |

### 5. Custom Exam Tier Picks

Approval: docs/superpowers/specs/2026-11-09-custom-exam-tiers-amendment.md:91, "3B chosen ... Placement 2 chosen ... okay mark 1" (subjects step); the dialog was settled under D191 per the board note

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Web (wide) | CX_TierCover | added | Custom Exam Tier Picks / M1Wide |
| Pantas Web (wide) | CX_TierDialog | added | Custom Exam Tier Picks / DlgWide |
| Pantas Redesign (phone) | CX_TierCover | added | Custom Exam Tier Picks / M1Ph |
| Pantas Redesign (phone) | CX_TierCoverDark | added | Custom Exam Tier Picks / M1PhDark |
| Pantas Redesign (phone) | CX_TierDialog | added | Custom Exam Tier Picks / DlgPh |
| Pantas Redesign (phone) | CX_TierDialogDark | added | Custom Exam Tier Picks / DlgPhDark |

### 6. Figure Answer Choices

Approval: docs/superpowers/decisions/2026-11-17-figure-answer-choices-log.md:67, "i pick option 2 2x2 tiles"

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Redesign (phone) | QV_Figure | replaced | Figure Answer Choices / O2_Phone |
| Pantas Redesign (phone) | QV_FigureDark | added | Figure Answer Choices / O2_Dark |
| Pantas Redesign (phone) | QV_FigureOdd | added | Figure Answer Choices / O2_OddOneOut_Phone |
| Pantas Redesign (phone) | QV_FigureStates | added | Figure Answer Choices / O2_States |
| Pantas Web (wide) | QS_Figure | replaced | Figure Answer Choices / O2_Wide |
| Pantas Web (wide) | QS_FigureOdd | added | Figure Answer Choices / O2_OddOneOut_Wide |
| Pantas Web (wide) | QS_FigureStates | added | Figure Answer Choices / O2_States |

### 7. N of Y Tap Cue Ideas

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2906, "up-down caret"; built form (grid icon gone, caret on the phone mock count, caret in place of the quiz chevron) at docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2911

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Redesign (phone) | DK_Miss | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_Answer | edited (caret, 3 bars) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_Flag | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_Grid | edited (caret, 2 bars) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_GridBack | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_GridMock | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_Last | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_Leave | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_Long | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_MissFree | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | QV_MissPro | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_LastQ | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_PauseFlow | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_FiveMin | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_LastQStrict | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_SheetCSE | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_SubmitCSE | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_EndEarly | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_LastMinute | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_Sheet | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |
| Pantas Redesign (phone) | MK_Proctor | edited (caret, 1 bar) | N of Y Tap Cue Ideas / NF_Text idea 3, NF_Mock, NF_Quiz |

### 8. Staging Check Fixes

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2897, "Staging: A ... B but make it 5, try to compress the space in between days more"; D196 at docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2900

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Web (wide) | ST_AccountOutA | added | Staging Check Fixes / S1_Account option A (S1_Frame opt=a) |
| Pantas Web (wide) | ST_AccountOutADark | added | Staging Check Fixes / S1_Account option A (S1_Frame opt=a) |
| Pantas Web (wide) | ST_AccountOutA1024 | added | Staging Check Fixes / S1_Account option A (S1_Frame opt=a) |
| Pantas Web (wide) | ST_AccountOutPart | added (part) | Staging Check Fixes / S1_Frame (default option set to A) |
| Pantas Redesign (phone) | HP_WeekStrip | added | Staging Check Fixes / S3B5 |
| Pantas Redesign (phone) | HP_WeekStripLarge | added | Staging Check Fixes / S3B5_Large |
| Pantas Redesign (phone) | HP_WeekFrame | added (part) | Staging Check Fixes / S3B5_Frame |

### 9. Text Size Preview Options

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2846, "A"

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Web (wide) | ST_LargeTextA | added | Text Size Preview Options / TS_A |
| Pantas Web (wide) | ST_LargeTextFrame | added (part) | Text Size Preview Options / TS_Frame |
| Pantas Web (wide) | ST_LargeTextSample | added (part) | Text Size Preview Options / TS_Sample |
| Pantas Web (wide) | ST_LargeTextSlider | added (part) | Text Size Preview Options / TS_Slider |
| Pantas Redesign (phone) | ST_LargeTextA | added | Text Size Preview Options / TS_A |
| Pantas Redesign (phone) | ST_LargeTextFrame | added (part) | Text Size Preview Options / TS_Frame |
| Pantas Redesign (phone) | ST_LargeTextSample | added (part) | Text Size Preview Options / TS_Sample |
| Pantas Redesign (phone) | ST_LargeTextSlider | added (part) | Text Size Preview Options / TS_Slider |

### 10. QA Polish Picks

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2534, "QA Polish Picks / a C / b D / c C / d A / e B / f A"; mock card approved at docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2542

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Web (wide) | QA_StudyCDark | added | QA Polish Picks / StudyCDark |
| Pantas Web (wide) | QA_StudyCLight | added | QA Polish Picks / StudyCLight |
| Pantas Web (wide) | QA_StudyCNoBm | added | QA Polish Picks / StudyCNoBm |
| Pantas Web (wide) | QA_Study | added (part) | QA Polish Picks / Study |
| Pantas Web (wide) | QA_Home | added | QA Polish Picks / Home |
| Pantas Web (wide) | QA_HomeDLight | added | QA Polish Picks / HomeDLight |
| Pantas Web (wide) | QA_Paused | added | QA Polish Picks / Paused |
| Pantas Web (wide) | QA_PausedALight | added | QA Polish Picks / PausedALight |
| Pantas Web (wide) | QA_Splash | added | QA Polish Picks / Splash |
| Pantas Web (wide) | QA_SplashBLight | added | QA Polish Picks / SplashBLight |
| Pantas Web (wide) | QA_MockWideDark | added | QA Polish Picks / MockWideDark |
| Pantas Web (wide) | QA_MockWideLight | added | QA Polish Picks / MockWideLight |
| Pantas Web (wide) | QA_QuizMock | added (part) | QA Polish Picks / QuizMock |
| Pantas Redesign (phone) | QA_Tend | added | QA Polish Picks / Tend |
| Pantas Redesign (phone) | QA_TendCLight | added | QA Polish Picks / TendCLight |
| Pantas Redesign (phone) | QA_PickADark | added | QA Polish Picks / PickADark |
| Pantas Redesign (phone) | QA_PickALight | added | QA Polish Picks / PickALight |
| Pantas Redesign (phone) | QA_Picker | added (part) | QA Polish Picks / Picker |
| Pantas Redesign (phone) | QA_MockPhoneDark | added | QA Polish Picks / MockPhoneDark |
| Pantas Redesign (phone) | QA_MockPhoneLight | added | QA Polish Picks / MockPhoneLight |
| Pantas Redesign (phone) | QA_QuizMock | added (part) | QA Polish Picks / QuizMock |

### 11. Splash Hand-off

Approval: docs/superpowers/decisions/2026-10-19-pwa-launch-log.md:2619, "Smoothest" (boards Web_B_Still and Phone_B_Fade)

| Reference canvas | Board | Change | Source canvas / board |
|---|---|---|---|
| Pantas Redesign (phone) | SP_PhoneBFade | added | Splash Hand-off / Phone_B_Fade |
| Pantas Redesign (phone) | SP_Flow | added (part) | Splash Hand-off / Flow |
| Pantas Redesign (phone) | SP_Splash | added (part) | Splash Hand-off / Splash |
| Pantas Redesign (phone) | SP_L_PlanSlow | added (part) | Splash Hand-off / L_PlanSlow |
| Pantas Redesign (phone) | SP_HM_DayStart | added (part) | Splash Hand-off / HM_DayStart |
| Pantas Redesign (phone) | SP_HM_DayStart_Still | added (part) | Splash Hand-off / HM_DayStart_Still |
| Pantas Redesign (phone) | SP_X_Side | added (part) | Splash Hand-off / X_Side |
| Pantas Redesign (phone) | SP_M_PlanSkel | added (part) | Splash Hand-off / M_PlanSkel |
| Pantas Redesign (phone) | SP_M_PlanLoaded | added (part) | Splash Hand-off / M_PlanLoaded |
| Pantas Web (wide) | SP_WebBStill | added | Splash Hand-off / Web_B_Still |
| Pantas Web (wide) | SP_Flow | added (part) | Splash Hand-off / Flow |
| Pantas Web (wide) | SP_Splash | added (part) | Splash Hand-off / Splash |
| Pantas Web (wide) | SP_L_PlanSlow | added (part) | Splash Hand-off / L_PlanSlow |
| Pantas Web (wide) | SP_HM_DayStart | added (part) | Splash Hand-off / HM_DayStart |
| Pantas Web (wide) | SP_HM_DayStart_Still | added (part) | Splash Hand-off / HM_DayStart_Still |
| Pantas Web (wide) | SP_X_Side | added (part) | Splash Hand-off / X_Side |
| Pantas Web (wide) | SP_M_PlanSkel | added (part) | Splash Hand-off / M_PlanSkel |
| Pantas Web (wide) | SP_M_PlanLoaded | added (part) | Splash Hand-off / M_PlanLoaded |

Item 12, Guardian Manage and Minor Checkout (https://claude.ai/artifact/VhNW1aCxSs5sF48XMQZLAQ), stays a separate spec canvas. Nothing from it was folded.

## Skipped

- CSE Release Picks checkout boards and the checkout tick (S4P_T_*, S4W_T_*, S4P_G_*, S4W_G_*): the legal wording and seller line are not final (PLAN2 T10, FABLE:279-280, 298). Not folded. CSE Release Picks boards for the label-free rows (S1 A) and Backup paused 0 (S5) were not part of this pass and are also not folded.
- Eight web Pro and paywall stale boards: ST_Paywall, ST_ProCSE, ST_ProCSEPass, ST_ProLET, ST_ProNCE, ST_ProNCENoDate, ST_ProPMA, ST_ProPMAPass. Waits on the D2 and D3 legal wording.
- Guardian canvas checkout boards CB_Wide, CB_Ph, CB_PhDark: wording is stale against D2. The canvas stays a separate spec canvas.
- Custom Exam Screens Pro page boards SetProB, SetProBOwned, SetPhProB, SetPhProBOwned: the Nov 9 tier amendment removes the free card they draw and adds a tier line (docs/superpowers/specs/2026-11-09-custom-exam-tiers-amendment.md:50). Not folded. Needs Aedwon's call on the new Pro page board.
- Custom Exam Screens options not picked (A options, Now boards, steps as now): no new boards, as the spec says.
- Bite-sized Lesson Labels: not folded. The label was removed from the UI (LOG:4137), so no reference board draws it.

## Uncertain

- Reader: the approved C reader replaced W_Reader (web) and RD_Real (phone) only. Web RD_Real, web RD_RealScroll and phone RD_RealScroll still show the old reader and its scroll behaviors (title in the strip, rail follows). C has no scroll chrome to copy, so they were left. Also unverified: whether C has shipped.
- Exam date and age: O_DateFinal and O_AgeFinal (phone) and OB_AgeFinal (web) were added. The old boards O_Age, O_DateKnown, O_DateChange, O_DateToday, ST_ExamDate, ST_ExamMonth, ST_ExamUnknown (phone) and OB_Age (web) are stale but were not removed. Wide exam date stays as it is (LOG:2951).
- Under 13: S7P (the Add a child first screen) and the other shared frames are not in the picked list, so they were not folded.
- Custom exam tier: CX_TierCover and CX_TierDialog were added beside, not over, OB_CustomCover and O_Custom, because the tier boards leave out the app frame (Back, top bar, steps list).
- Figure choices: QS_Figure and QV_Figure were replaced by O2_Wide and O2_Phone. The old QS_Figure had prototype links (QS_Leave, QS_Grid, W_QRight) that are gone. W_Question, W_QRight, W_QMiss, QV_Answer were not redrawn with tiles. O2_Phone still draws the old chevron on its count, because it is approved 1:1.
- N of Y caret: edited the quiz counters on 11 phone boards (DK_Miss, QV_Answer, QV_Flag, QV_Grid, QV_GridBack, QV_GridMock, QV_Last, QV_Leave, QV_Long, QV_MissFree, QV_MissPro) and removed the grid icon and added the caret on 10 phone mock bars (MK_LastQ, MK_PauseFlow, MK_FiveMin, MK_LastQStrict, MK_SheetCSE, MK_SubmitCSE, MK_EndEarly, MK_LastMinute, MK_Sheet, MK_Proctor). Not changed because their structure did not match: MK_PauseWarn and MK_Paper. The caret colors use the app secondary text color (light #6E6E73, dark #A3A3A3) read from the shipped tokens. Wide bars are unchanged, as built (LOG:2911). The flag stays in the mock bar; the idea 3 frames draw no flag.
- Staging: S1_Account A is drawn as a pane, not a full page, so it was added as ST_AccountOutA, ST_AccountOutADark and ST_AccountOutA1024 and ST_AccountOut was left. The five-day week strip (S3B5, S3B5_Large) was added as sheets HP_WeekStrip and HP_WeekStripLarge. Existing HP_* and HE_* boards that draw the old seven-day strip were not edited; which of them need the five-day strip is not decided.
- Text size: ST_LargeTextA (sheet with the chosen A frames) was added on both canvases. ST_LargeText on both canvases still shows the old card.
- QA Polish Picks: winners were added as QA_* boards without a board by board check of which already match the references (for example HM_NoDate against pick b D, W_Study, MK_Paused, OB_Welcome, O_Picker, MY tendencies).
- Splash hand-off: added as a record of the motion. The part boards use the source frame component, whose defaults are option C.
- Part boards (CX_Settings, CX_SettingsPh, CX_Paper, QA_Study, QA_Picker, ST_LargeTextFrame and others) draw an unpicked default option, because every dc.html file shows on the canvas. Their titles say so.
- Not in this pass and still possibly stale (from the inventory): hand-typed lesson minutes boards, DS4 value changes shipped Nov 11 on DK_Home, HM_BeforeAssessment, DK_Settings, ST_SignOut, QV_Flag, QV_Answer, MK_PauseA, QV_EndFree, L_ChangeExam2, BM_One, phone tab bar boards, O_Picker, HP_Free.
