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

## Consistency pass (Nov 23)

Canvas versions after this pass: Pantas Web version 175, Pantas Redesign version 483. A new page named Superseded holds every outdated board, with one sticky note on each canvas that lists old board, current board and why. No board file was deleted. Each moved board has its title set to "SUPERSEDED: see <current board>".

Counts: superseded 15 (phone 8, web 7); QS_Figure links restored (4); duplicates removed 0; caret added 2 mock bars (MK_PauseWarn, MK_Paper); ST_AccountPro backup row edited 1.

### Step 1 and 3: superseded boards

| Canvas | Old board | Current board | Why |
|---|---|---|---|
| Pantas Redesign (phone) | O_Age | O_AgeFinal | Birth-year wheel replaced by the age stepper (approved; build already matches, phone-pass.md row O_Age BUILD BETTER) |
| Pantas Redesign (phone) | O_DateKnown | O_DateFinal | Approved exam date option A |
| Pantas Redesign (phone) | O_DateChange | O_DateFinal | Same |
| Pantas Redesign (phone) | O_DateToday | O_DateFinal | Same |
| Pantas Redesign (phone) | ST_ExamDate | O_DateFinal | Both phone callers use the same picker (LOG:2951); listed stale in the folds record |
| Pantas Redesign (phone) | ST_ExamMonth | O_DateFinal | Same |
| Pantas Redesign (phone) | ST_ExamUnknown | O_DateFinal | Same |
| Pantas Redesign (phone) | ST_LargeText | ST_LargeTextA | Approved Text size A |
| Pantas Web (wide) | OB_Age | OB_AgeFinal | Birth-year field replaced by the age stepper |
| Pantas Web (wide) | OB_AgeBlocked | OB_AgeFinal | Under 13 is now the guardian flow (U13_ChildNotice on the phone canvas); OB_AgeFinal has no blocked state |
| Pantas Web (wide) | ST_AccountOut | ST_AccountOutA | Approved Staging A; the pane boards replace the page board |
| Pantas Web (wide) | ST_LargeText | ST_LargeTextA | Approved Text size A |
| Pantas Web (wide) | OB_CustomCover | CX_TierCover | Subjects step with the tier on the tile. CX_TierCover leaves out the app frame, so the sticky says to keep Back, top bar and steps list from the old board |
| Pantas Web (wide) | HM_NoDate | QA_Home | QA pick b D (buttons below the text, right). QA_HomeDLight is the light version. The two differ in notice layout and sample data |
| Pantas Web (wide) | OB_Welcome | QA_SplashBLight | QA pick e B: Welcome takes the app background (old board is white) |

QA Polish Picks comparison, board by board:

| Pick | Winner boards | Existing board | Result |
|---|---|---|---|
| a C | QA_StudyCDark, QA_StudyCLight, QA_StudyCNoBm | W_Study | Differs, but W_Study draws "the map and an open topic side by side", a state QA_Study does not draw. Kept both, not marked. See Uncertain |
| b D | QA_Home, QA_HomeDLight | HM_NoDate | Differs. HM_NoDate marked superseded |
| c C | QA_Tend, QA_TendCLight (phone) | none on the phone canvas | No duplicate. Web MY_Tend* boards left as they are |
| d A | QA_Paused, QA_PausedALight | MK_Paused | Different state (one-block mock versus a mock with four parts). Kept both. See Uncertain |
| e B | QA_Splash, QA_SplashBLight | OB_Welcome | Differs. OB_Welcome marked superseded |
| f A | QA_PickADark, QA_PickALight (phone) | O_Picker | O_Picker holds three states (cannot load, loading, list); QA_Picker draws the list only. Kept both. See Uncertain |
| g | QA_MockWideDark, QA_MockWideLight, QA_MockPhoneDark, QA_MockPhoneLight | W_QuizTab, QZ_Tab | Different state (new student on Free versus a normal Pro day). Kept both |

No QA winner was identical to an existing board, so no board was removed.

### Step 2: QS_Figure links

Source: the earlier QS_Figure from the Nov 22 handoff export in Downloads (not version history; the Artifact tool cannot read an older version). Links restored on the replaced board by turning the same elements into links, no other change.

| Board | Element | Links to |
|---|---|---|
| QS_Figure | Leave button (X) | QS_Leave |
| QS_Figure | "4 of 10" count | QS_Grid |
| QS_Figure | Flag button | QS_Flag |
| QS_Figure | Check button (stays drawn disabled, aria-disabled) | W_QRight |

QV_Figure (phone) had no links in the earlier version that this pass could read; none added.

### Step 4: N of Y caret

| Board | Change |
|---|---|
| MK_PauseWarn | Grid icon removed, caret added beside "14 of 60", same markup and colors as the 10 other mock bars |
| MK_Paper | Same. The count here cross-fades between "12 of 60" and "13 of 60", so the caret sits beside that stack. Same element, different wrapper; flagged in Uncertain |

### Step 6: build better rows

| Board | Change |
|---|---|
| O_Age | Covered by step 1 (superseded by O_AgeFinal, the big-numeral age stepper) |
| ST_AccountPro (phone) | Backup row now reads "Saved today, 7:12 PM" (phone-pass.md:243, backup_page.dart); the redundant "Last backed up" row removed. Nothing else on the board changed |

### Step 5: not touched (listed only)

- Custom Exam Pro page boards: SetProB, SetProBOwned, SetPhProB, SetPhProBOwned (not on the canvases; waiting for Aedwon's call on the new Pro page board)
- Checkout and paywall boards: ST_Paywall, ST_ProCSE, ST_ProCSEPass, ST_ProLET, ST_ProNCE, ST_ProNCENoDate, ST_ProPMA, ST_ProPMAPass (web); CB_Wide, CB_Ph, CB_PhDark (Guardian canvas); S4P_T_*, S4W_T_*, S4P_G_*, S4W_G_* (CSE Release Picks)
- CSE Release Picks content: not touched

### Uncertain

- O_Custom (phone) is a multi-state custom exam flow. CX_TierCover and CX_TierDialog replace only its subjects step and raise-tier dialog, so O_Custom was not moved. Needs a call.
- W_Study (web): QA_StudyCLight is the approved head layout, but W_Study draws an open topic that QA does not. Not moved.
- MK_Paused (web) and QA_Paused: different states, both kept. O_Picker (phone) and QA_PickALight: O_Picker keeps its can't-load and loading states, so it was not moved, though its list differs from pick f A.
- Five-day week strip: no standalone seven-day strip board exists. The strip sits inside full Home boards (HP_*, HE_*), so nothing was marked. HP_WeekStrip's "Current phone" frame is the only drawn seven-day version.
- Old exam-tier boards: no old board draws a tier, so there is no old tier board to mark; the new tier boards are additions.
- MK_Paper counter wrapper differs (animated), caret placed beside it.
- QS_Figure Check: link kept on a disabled-looking button. Old board linked the same pill the same way.
- Web wide exam date boards (OB_Date*) and web ST_Exam* are not superseded: wide stays as is (LOG:2951).
- Moved boards leave gaps on their old pages; other boards were not shifted.
- canvas.json was rewritten without indentation (same content).

## UX council fold (Nov 23)

Folded the council-approved UX boards into both reference canvases, ahead of the build, so reviewers compare the build with the approved target. Source canvases: Lesson Reader Full Screen (https://claude.ai/artifact/Sb3f8m64ZpouMDBKjTE14K, only the "4 Held" boards) and Core Loops Best in Class (https://claude.ai/artifact/1tyuTs3m832KjUtgZdvzXZ, the B1 to B5 "After" and motion boards; the Before boards are not copied). Hand-off list: docs/superpowers/plans/2026-11-23-ux-ambition-handoff.md, "Reference boards to update after the build". Directions 1 to 3 (Margin, Pinned, Column) were rejected and are not copied. Checkout, paywall and Pro boards were not touched.

Final versions: Pantas Web version 177, Pantas Redesign version 484. Source canvases were not changed. No board file was deleted.

Rulings: lesson reader at docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md:468; core loops at docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md:487. Specs: docs/superpowers/specs/2026-11-23-lesson-reader-full-screen-design.md (motion values in "Motion values") and docs/superpowers/specs/2026-11-23-core-loops-polish-design.md.

### Counts

- Replaced: 3 (W_Reader, W_MockResults on Pantas Web; MK_Results on Pantas Redesign)
- Edited in place with the approved change: 9 (web W_Question, W_QRight, W_QMiss, W_SessionEnd, MK_ReviewWrong; phone QV_Answer, QV_EndPro, QV_EndLastToday, MK_ReviewWrong)
- Added: 21 (web 16 including the shared part RD_HeldPart; phone 5 including QZ_TabMotion)
- Superseded: 3 on Pantas Web (W_ReaderDark, W_ReaderPart, RD_Focus)
- Uncertain: see below

### Method notes

- Source .dc.html files were copied byte for byte. Only these changed: dc-import name R to RD_HeldPart, stylesheet paths (held/fs.css, loops/core.css, loops/mkweb.css, loops/phone.css, so no name clashes), board links (Main to W_QuizTab or W_Reader where the source canvas used Main for the Quiz tab, B4 review boards to MK_ReviewSubject).
- Stylesheets were copied server side. reader.css was already identical on Pantas Web (same sha256).
- Motion values are untouched in every copied motion board (QT_CardMotion, QZ_TabMotion, QS_EndMotion, QS_WrongMotion, RD_HeldMotion), and phone is the motion reference.
- Where a source board is a static snapshot of an existing animated reference board (B5 After boards, which drop the entrance animation), the reference board was edited with the same approved change instead of replaced, so its motion stays. The same rule applies to the interactive web question boards.
- Edits copy the source values: the answer track (10 x 4 px marks, phone 8 x 4, radius 99, 3 px gap, unanswered #D1D1D6, current #1D1D1F, teal #0B7A68, red #D70015, 200 ms color change), the notes prompt "Note why you missed each one." with its 12 px card padding, and for web W_Question the B3 timing (shake .42 s, then at 540 ms the right row rings teal, the others dim to 42% and the panel slides in .5 s; Enter or Next inside 540 ms completes the reveal).

### Changes

One row per change. Ruling line: R = docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md.

| Reference canvas | Board | Change | Source canvas / board | Ruling |
|---|---|---|---|---|
| Pantas Web | W_Reader | replaced | Lesson Reader Full Screen / W4_Held | R:468 |
| Pantas Web | W_ReaderHeldDark | added | Lesson Reader Full Screen / K1 | R:468 |
| Pantas Web | RD_HeldReading | added | Lesson Reader Full Screen / V4 | R:468 |
| Pantas Web | RD_HeldPush | added | Lesson Reader Full Screen / V4b | R:468 |
| Pantas Web | RD_HeldLinked | added | Lesson Reader Full Screen / H4 | R:468 |
| Pantas Web | RD_Held1100 | added | Lesson Reader Full Screen / M1100 | R:468 |
| Pantas Web | RD_HeldMotion | added | Lesson Reader Full Screen / MO | R:468 |
| Pantas Web | RD_HeldPart | added (part) | Lesson Reader Full Screen / R | R:468 |
| Pantas Web | W_ReaderDark | superseded, see W_ReaderHeldDark | Lesson Reader Full Screen / K1 | R:468 |
| Pantas Web | W_ReaderPart | superseded, see RD_HeldPart | Lesson Reader Full Screen / R | R:468 |
| Pantas Web | RD_Focus | superseded, see W_Reader | Lesson Reader Full Screen / W4_Held | R:468 |
| Pantas Web | W_Question | edited (no bar hint, answer track, B3 timing) | Core Loops Best in Class / B5_PickAfter, B2_WideBar, B3_Motion | R:487 |
| Pantas Web | W_QRight | edited (answer track) | Core Loops Best in Class / B2_WideBar | R:487 |
| Pantas Web | W_QMiss | edited (answer track) | Core Loops Best in Class / B3_WideWrong | R:487 |
| Pantas Web | W_SessionEnd | edited (notes prompt text) | Core Loops Best in Class / B5_EndAfter | R:487 |
| Pantas Web | W_MockResults | replaced | Core Loops Best in Class / B4_WideResults | R:487 |
| Pantas Web | MK_ReviewWrong | edited (notes prompt text) | Core Loops Best in Class / B5_ReviewAfter | R:487 |
| Pantas Web | MK_ReviewSubject | added | Core Loops Best in Class / B4_WideReview | R:487 |
| Pantas Web | QT_CardMotion | added | Core Loops Best in Class / B1_WideMotion | R:487 |
| Pantas Web | QS_BarTrack | added | Core Loops Best in Class / B2_WideBar | R:487 |
| Pantas Web | QS_EndMotion | added | Core Loops Best in Class / B2_WideEnd | R:487 |
| Pantas Web | QS_PickNoHint | added | Core Loops Best in Class / B5_PickAfter | R:487 |
| Pantas Web | QS_PickedNoHint | added | Core Loops Best in Class / B5_PickedAfter | R:487 |
| Pantas Web | QS_WrongMid | added | Core Loops Best in Class / B3_WideMid | R:487 |
| Pantas Web | QS_WrongSettled | added | Core Loops Best in Class / B3_WideWrong | R:487 |
| Pantas Web | QS_WrongMotion | added | Core Loops Best in Class / B3_Motion | R:487 |
| Pantas Redesign | MK_Results | replaced | Core Loops Best in Class / B4_PhoneResults | R:487 |
| Pantas Redesign | MK_ReviewSubject | added | Core Loops Best in Class / B4_PhoneReview | R:487 |
| Pantas Redesign | MK_ReviewWrong | edited (notes prompt text) | Core Loops Best in Class / B5_PhoneReviewAfter | R:487 |
| Pantas Redesign | QV_Answer | edited (answer track above the count) | Core Loops Best in Class / B2_PhoneBar | R:487 |
| Pantas Redesign | QV_EndPro | edited (notes prompt text) | Core Loops Best in Class / B5_PhoneEndAfter | R:487 |
| Pantas Redesign | QV_EndLastToday | edited (notes prompt text) | Core Loops Best in Class / B5_PhoneEndAfter | R:487 |
| Pantas Redesign | QZ_TabMotion | added | Core Loops Best in Class / B1_PhoneMotion | R:487 |
| Pantas Redesign | QV_BarTrack | added | Core Loops Best in Class / B2_PhoneBar | R:487 |
| Pantas Redesign | QV_BarTrackLong | added | Core Loops Best in Class / B2_PhoneLong | R:487 |
| Pantas Redesign | QV_WrongSettled | added | Core Loops Best in Class / B3_PhoneWrong | R:487 |

### Not folded

- Phone reader boards P_Light and P_Dark: the spec says the phone reader is unchanged (RD_Real stays).
- Rejected directions: Main, W2_Pinned, W3_Column, V1 to V3, K2, K3 on the reader canvas.
- Before boards on the core loops canvas: Main, B1_PhoneBefore, B5_*Before. The B5 After boards for the end screens and the mock review were applied as edits (see Method notes), not copied.
- W_QuizTab and QZ_Tab: their rest state does not change. The transition is drawn in QT_CardMotion and QZ_TabMotion.

### Uncertain

- RD_FocusOpen (lesson list) and RD_Figure (lightbox) still draw the old left outline behind the popover and the lightbox. No approved board draws those two states over the 4 Held layout, so none was invented. A sticky on the study page says so. RD_FocusMotion also still draws the outline rail and its dot in its four scenes; its bar timing stays binding and RD_HeldMotion draws the section line and the held figure.
- W_ReaderHeldDark shows the top of the lesson only (K1). The full-length dark reader (W_ReaderDark) was superseded, so there is no full-length dark 4 Held board.
- QV_Last (phone) and QV_EndFree, QV_EndLastToday track and marks: the source canvas draws no phone board with the track on question 10 or the marks flying into the row on phone, so QV_Last has no track yet and the phone end boards show no marks motion. QV_EndFree has no notes prompt, so it did not change.
- B3 timing is drawn only on wide (QS_WrongMotion and W_Question). The source has no phone motion board for it, so QV_Answer and QV_Last motion are unchanged.
- W_SessionEnd keeps its older pop-in entrance and static 7; the approved entrance with the count-up is QS_EndMotion beside it. QS_EndMotion draws the top of the screen only (no mistakes list).
- W_Question edits are logic and CSS written to match the B3 values; they were not run. The track marks for questions 1 to 3 and the pre-question-5 marks on W_QMiss repeat the pattern of the source boards (questions 2 and 5 wrong).
- QS_PickedNoHint and QS_BarTrack draw the same state (both are council boards).

## Derived states (Nov 23)

Five states had no drawn board. Each is derived from approved boards and spec values only. Final versions: Pantas Web version 180, Pantas Redesign version 487. Board titles carry " (derived, Fable-checked)". Fable 5.2 reviewed once, found defects, fixes were published, and the re-check passed (one caption sentence on RD_FocusMotion was fixed after it, with no further check).

| Board | Canvas | Source | Values used | Fable verdict |
|---|---|---|---|---|
| RD_FocusOpen | Web | old board (lesson list, content), W_Reader and held/fs.css (layout) | 1,096 px page, 640 text, 56 gap, 400 figure column, plate #FAFAF7, figure top = anchor + 6, section line under the bar, row min-height so the plate fits | Pass after fix (Reading label, pill colors, popover motion, hover) |
| RD_Figure | Web | old board (lightbox), same page as RD_FocusOpen | lightbox unchanged, page height 900 | Pass after fix (page height, scrim fade) |
| RD_FocusMotion | Web | old board (bar timing), RD_HeldMotion | bar scroll timing unchanged; plates #FAFAF7 as MO; sticky line 92 to 32 px scaled by 44/60 (mini bar 44 px) = 67.5 to 23.5; held, then pushed away at the passage end, scroll-linked | Pass after fix (keyframe name clash, caption) |
| W_ReaderHeldDarkFull | Web | K1 and RD_HeldPart (v=4, dark) | same tokens, plates stay light, 1440 x 3612 | Pass |
| QV_Last | Phone | QV_Answer track | track 8 x 4, radius 99, gap 3, above the count; marks 2, 5, 8 and 10 wrong (wide data pattern, question 10 wrong as the board shows) | Pass |
| QV_EndPro, QV_EndFree, QV_EndLastToday | Phone | wide QS_EndMotion | 7 s loop; question screen 1.0 s, 180 ms fade; marks 360 ms (.32,.72,0,1), 20 ms stagger; ring and count 1.4 s (.2,.9,.3,1) from 1.70 s; title and ring fade 23.3 to 25 %, "in 9 minutes" and Done 24.6 to 28.6 %; marks start at measured track positions and land on measured slots | Pass |
| QV_Answer | Phone | wide W_Question and QS_WrongMotion | right-answer run kept (11 s), loop now 22 s; wrong run: shake .42 s, reveal 540 ms after the check, ring .7 s ease-out, others dim to 42 %, panel slide .5 s (.2,.9,.3,1) 28 px, track mark red 200 ms | Pass after fix (reduced motion badge and fades) |

Missing values, nearest approved used:
- Phone sizes kept (marks 8 x 4 landing in 28 px circles, wrong tint #FDECEE on end boards and #FDE8EA on the wrong row) instead of wide 10 x 4 and 30 px.
- Phone ring and count move from the old 1.2 s to 1.4 s (spec: 1.4 s as approved). The other end-screen blocks keep their approved fade-ups, shifted 1.3 s later.
- End boards: the question screen before Finish shows QV_Last's question answered right (question 10 right), so the marks follow the row data (wrong 1, 3 and 9).
- Reveal dim 42 % (spec) while static QV_WrongSettled draws .45.
- RD_FocusMotion: equal section lengths in the 8-segment line (real lengths unknown); reading line 104 px decides when a section becomes current; content positions moved (Crust heading 444) so the figure is still held when the bar hides; a second figure in Crust shows the bar's return (32 to 92 px). Earth Science lesson content kept from the old boards.
- RD_FocusOpen and RD_Figure: first section segment filled 32 % and 64 % (old bar 4 % and 8 % of the lesson, times 8).
- QV_Answer: the track data of the "before pick" and "after check" bar variants was swapped on the old board; fixed.
- Reduced motion variants added on QV_Answer; the end boards show the final state at once.

## T15 ruling changes (Nov 24)

Source: "Nov 24, T15 reader undrawn states" in `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md` (origin/main 3931abc60), rulings 1, 3 and 6. Final versions: Lesson Reader Full Screen version 9, Pantas Web version 182.

| Board | Canvas | Change | Note |
|---|---|---|---|
| M1100 | Lesson Reader Full Screen | Ruling 1: reading block centered at 1100, 76 px each side | Board file unchanged; the mid-width rule in `fs.css` now sets a 948 px block (600 + 48 + 300), centered, side margins at least 40 px |
| RD_Held1100 | Pantas Web | Same | Same rule in `held/fs.css` |
| fs.css, held/fs.css | Both | Ruling 3: expand button radius 9 to 8 | Reaches every held board |
| H4 | Lesson Reader Full Screen | Ruling 6: pointer on `AB` in the first solution line | Scroll 1900 to 1800 so the line is in view; pointer moved to the word |
| R | Lesson Reader Full Screen | Ruling 6: "hypotenuse" in step 1 no longer linked | `AB` in the first solution line was already linked |
| MO (scene 3) | Lesson Reader Full Screen | Ruling 6: linked-word example moved to `AB` in a first solution line | Card now shows the problem line, the solution line, then step 1; pointer retargeted |
| RD_HeldLinked | Pantas Web | Copy of H4 | Same change |
| RD_HeldPart | Pantas Web | Copy of R | Same change |
| RD_HeldMotion | Pantas Web | Copy of MO | Same change |
| R, MO (scene 3) | Lesson Reader Full Screen | Ruling 6 follow-up: problem line links only `BC`; the `AB` and `AC` links are removed | Version 10. `BC` is already linked in R; MO draws no `BC` link and the second pointer stop still lights the AC label in the figure |
| RD_HeldPart, RD_HeldMotion | Pantas Web | Same follow-up | Version 183 |
| H4 | Lesson Reader Full Screen | Retitled: "4 Held, pointing at AB in the first solution line: side AB lights in the figure" | Version 10 |
| RD_HeldLinked | Pantas Web | Retitled to match, keeping "(H4)" | Version 183 |

Final versions after the follow-up: Lesson Reader Full Screen version 10, Pantas Web version 183.

Not changed: the M1100 and RD_Held1100 board titles. Pointer positions were set from a headless Chrome measure with a fallback font (Geist was not available), so the owner should check them on the canvas.

## T16 B2 phone bar states (Nov 24)

Source: "Nov 24, T16 B2 phone bar states" in `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md` (origin/main 2e07fc7d7), rulings 1 to 6. Final version: Pantas Redesign version 491. One Fable 5.2 check of the four boards: three passed, QV_GridBack failed on invented mark states and label; fixed (marks red, teal, red, dark, then six gray; label "Question 4 of 10. Question 2 right, questions 1 and 3 wrong."), not re-checked.

| Board | Canvas | Change | Source and values | Fable verdict |
|---|---|---|---|---|
| QV_BarTrackTwoRows | Pantas Redesign | New derived board: 20 questions, track in two rows of ten, 3 px apart | QV_BarTrack (from B2_PhoneBar); marks 8 x 4, gap 3, track 107 px; marks 1 to 4 as the base board, the rest empty | Pass |
| QV_BarTrack320 | Pantas Redesign | New derived board at 320 wide, 20 questions | QV_BarTrack; marks 6 x 4, gap 2, rows 2 px apart, track 78 px, count padding 4 | Pass |
| QV_Flag | Pantas Redesign | Track added above the count | Same structure and marks as QV_Answer (4 of 10: right, wrong, right, current) | Pass |
| QV_GridBack | Pantas Redesign | Track added above the count; flag stays in the bar | Marks from the board's own grid (1 and 3 wrong, 2 right), current mark on question 4, as the build draws it | Fail, fixed |

Notes:
- D71 header flag rule: not found on the Pantas Redesign canvas (index, Z_Decisions, the QV boards and phone.css were searched), so nothing was marked retired there. The rule lives in the Pantas Design System canvas, the handoff `bundle.css` and `design-system-4/map.md`, which the ruling lists for retirement and this pass did not touch.
- Board titles carry " (derived, Fable-checked)" on all four.
- The other QV boards with a session bar (QV_Leave, QV_Long, QV_MissFree, QV_MissPro, QV_Grid) still draw no track. Not asked for.
- QV_GridBack shows "2 of 10" with a label that names question 4; this follows the build, and the ruling keeps the label.
- Both new boards draw "4 of 20" with the base board's three results, to avoid inventing answers for later questions.

## T16 B2 consistency pass (Nov 24)

Follow-up to the T16 B2 section above. Final versions: Pantas Redesign version 493, Pantas Design System version 12. One Fable 5.2 re-check of QV_GridBack and the five new tracks: all six passed, no fixes.

| Board | Canvas | Change | Mark data | Fable verdict |
|---|---|---|---|---|
| QV_GridBack | Pantas Redesign | Re-check of the corrected marks | Red, teal, red, dark, six gray; label names question 4 as the build does | Pass |
| QV_Leave | Pantas Redesign | Track added above the count (QV_Answer layout) | Right, wrong, right, question 4 current | Pass |
| QV_Long | Pantas Redesign | Same | Right, wrong, right, wrong, wrong, question 6 current | Pass |
| QV_MissFree, QV_MissPro | Pantas Redesign | Same | Right, wrong, right, wrong, wrong (question 5 is the shown miss, red) | Pass |
| QV_Grid | Pantas Redesign | Same, on both bars (4 of 10, then 2 of 10) | Red, teal, red, dark, from the board's own grid, as QV_GridBack | Pass |
| R320_D71QuizFlag | Pantas Design System | Retitled "RETIRED Nov 24 (T16 B2 ruling, 2e07fc7d7): ..."; sticky note added below it; board kept | n/a | n/a |

Repo: `docs/superpowers/plans/design-system-4/map.md` item 8 now says D71 is retired by the Nov 24 T16 B2 ruling (2e07fc7d7): the flag sits in the session bar. Nothing deleted.

Left alone, for the T16 B2 build: `design/system/tokens.json` (`bp-phone-narrow`, which feeds generated Dart and token files), `design/system/components/bundle.css` (`.fbar__flag-alt`), the FloatingBar and PageHeader READMEs, and the handoff copies of these. The ruling's new phone breakpoint is 360 px.

Assumptions named by Fable, not defects:
- QV_Grid and QV_GridBack draw question 4's history as wrong, right, wrong; QV_Answer, QV_Flag and QV_Leave draw right, wrong, right. The grid boards predate this change.
- The miss and long boards follow QV_Answer's wrong-pick loop (question 4 wrong).
- Mark 5 on the miss boards is drawn red at rest; QV_Answer animates dark to red.

## Website footer: seller details and BIR badge (Nov 24)

Source: D3 (website footer line, seller-line template on `origin/legal/public-launch-r1`) and ruling C9 rulings 4 to 11. Pantas Website version 75. One Fable 5.2 check: Fail on two points, both fixed as the check prescribed and not re-checked.

| Board | Canvas | Source and values | Fable verdict |
|---|---|---|---|
| Footer_Wide | Pantas Website | Home board footer (`pn-founder`: tokens, Inter, row gap 28, 40 rem column); D3 line unchanged; badge 480 x 166 left-aligned under the line; white plate, 1 px `--rule` ring, radius 12 (site card radius); one link, new tab, `noopener noreferrer`, ruling 8 name; no copy beside it | Pass, one fix: hover color rule (fixed) |
| Footer_Phone | Pantas Website | Same; badge full width. The site gutter is 20 px, so the badge is widened 4 px each side to match the ruled 358 x 124 at 390; at 360 the QR side is 71 px (floor 70); hidden under a 328 px viewport (hard floor 64 px QR) | Fail at 360 and 320, fixed |

Notes:
- The badge image is a labeled placeholder. The BIR PDF and the registration id are not used; the link omits the id.
- Invented, named: classes `pn-f-sell` and `pn-bir`; the placeholder label (board-only); the orange draft note.
- Whether to show the badge while the BIR display rule is suspended stays with Aedwon (ruling C9).
- Build note: on the real page, put the ruling 8 string on the image `alt` and drop the `aria-label`.
- The private business facts file was read for the seller line only. Its other contents (TIN, certificate numbers) are not in the repo or on the board.
