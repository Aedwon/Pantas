# Wide button placement scan, code only (E-158, Nov 25)

Sonnet worker scan of lib/ at main d7ccfed7c, read-only, no screenshots. The lead reviewed every VIOLATION in the code. Lead verdicts that differ from this table are in the rulings file, section "Nov 25, UX design lead: wide button placement, code only (E-158)": W14 and W24 kept (board A, his pick); W11, W25, W26, W30, W31, W32 ruled compliant; F1 kept (board A); F2 to F4, F6, F7 listed for the manager, not fixed. Fixed on ux/button-placement-r1: W9, W12, W13, W15, W18/F5, W19, W20, W21, W23, W28, W29.

Facts that decide many rows (checked in code):
- `PantasButton` on wide delegates to `WebButton` at natural width (pantas_button.dart:244). A `PantasButton` in a wide column is NOT full width. Only `WebButton(expand: true)` is.
- `WebButton` without `expand` is natural width, left-aligned in its box (web_components.dart:268).
- `ButtonPair` is always equal halves (Expanded) or a stretched column. It has no wide mode (button_pair.dart). Its callers all sit in phone-only branches, so it is not on any wide screen today.
- `CenteredDialog`, `NoticeStrip` (wide branch), `CardFooter` are compliant by construction. Call sites inherit that.

## 1. Wide button groups

| id | Screen or component | file:line | Buttons in visual order | Verdict | Rule | Evidence |
|---|---|---|---|---|---|---|
| W1 | NoticeStrip wide branch (no product caller; Home uses HomeWebNotice, see W21; gallery only) | core/ui/components/notice_strip.dart:204 | secondary/tertiary, then main | OK | none | `Wrap(alignment: end, spacing: 8)`, secondary first |
| W2 | CenteredDialog wide branch (all confirm dialogs: sign out, delete mock, switch exam, withdraw, assessment leave, mock dialogs via WebMockDialog) | core/ui/components/centered_dialog.dart:145 | tertiary (safe), then primary or danger | OK | none | `Wrap(alignment: end, spacing: 8)`; destructive gives danger last. Call sites pass sensible labels (checked 8 callers) |
| W3 | CardFooter | core/ui/components/card_footer.dart:79 | caption left, one action right | OK | none | `Row [Expanded caption, action]`; stacked fallback right-aligns |
| W4 | ButtonPair (shared widget, no wide caller) | core/ui/components/button_pair.dart:26 | secondary, main as equal halves | UNSURE | R3, R4 latent | `Expanded` halves, gap 10 default. Safe today only because every caller is phone-only. A future wide caller would break R3 |
| W5 | Report-a-question panel, wide | core/ui/components/report_form.dart:427 | Cancel (tertiary), Send | OK | none | `Wrap(alignment: end)` with 8 px spacer |
| W6 | Quiz "Leave this session?" dialog, wide hand-built | features/quiz/presentation/quiz_page.dart:1747 | Leave (tertiary), Keep Going (main) | OK | none | `Row(end)`, 8 px gap |
| W7 | Delete account card, wide | features/settings/presentation/pages/delete_account_page.dart:193 | Keep My Account/Cancel (tertiary), Delete My Data (danger) | OK | none | `Wrap(alignment: end, spacing: 8)` |
| W8 | Carry-over "Count Them" animated page, wide | features/settings/presentation/carry_over_prompt.dart:433 | Start My Numbers Fresh (tertiary), Count Them | OK | centered case | `Wrap(alignment: center, spacing: 8)`, secondary first |
| W9 | Account page sign-in card footer, wide | features/settings/presentation/pages/account_page.dart:170 | Continue with Email (secondary), Continue with Google (white) | VIOLATION | R4 | `spacing: PantasSpace.s12` and `runSpacing: s12`; end-aligned and ordered correctly |
| W10 | Account page Sign Out + Delete Account row, wide | features/settings/presentation/pages/account_page.dart:283 | Sign Out (ghost), Delete Account (ghost, red text) | OK | Settings action row | left `Wrap(spacing: 8)`, destructive last |
| W11 | Pantas Pro page bottom bar, wide | features/settings/presentation/pages/pro_page.dart:960-1010 | Restore Purchases or Switch on Free (tertiary) at far left; buy button (large) at far right | UNSURE | R1 | Secondary is pinned left with `Row[WebButton, Expanded(Column crossAxisAlignment.end)]`, main far right. Comment cites board ST_Pro, which the rules file lists as a pair that must be secondary then main |
| W12 | Settings "You're now studying for ..." confirmation, wide | features/settings/presentation/pages/exam_page.dart:237-251 | Change Exam Date (main), Done (tertiary) stacked, centered | VIOLATION | stacked phone pair, R2 reversed, R4 | two `Center(PantasButton)` in a column with a 6 px gap (`s6`), main first |
| W13 | Quiz session results (end of session), wide | features/quiz/presentation/web_session_results.dart:228-255 | Done (white, large, inside a 192 box with `expand: true`), Start Session N (main) | VIOLATION | R4 | `SizedBox(width: s12)` between; centered row; order is correct. Done is stretched to a fixed 192 box (minor R3 flavor) |
| W14 | Quiz tab paused-session foot, wide | features/quiz/presentation/quiz_tab_screen.dart:709-722 | Discard this session (ghost), Resume (main) | VIOLATION | R4 | `Wrap(alignment: end, spacing: PantasSpace.s16)`; comment says "16 apart" from board A. Code is 16, rule is 8 |
| W15 | Quiz mistake-note editor, wide | features/quiz/presentation/quiz_note_editor.dart:210-226 | Remove (red ghost, far left); then Cancel/Not Now (ghost), Add Note/Update (main) at right | VIOLATION | R4 | `SizedBox(width: PantasSpace.s4)` between Cancel and Update; Remove is split to the left via `Spacer` |
| W16 | Mock review, "Save flagged questions" card, wide | features/mock_exam/presentation/pages/mock_review_page.dart:562-568 | No Thanks (tertiary), Save All N | OK | none | right end of card, 8 px gap |
| W17 | Mock review, note-why-missed panel, wide | features/mock_exam/presentation/pages/mock_review_page.dart:1641-1647 | Not Now (tertiary), Add Note | OK | none | `Row(end)`, 8 px gap |
| W18 | Mock tab Mock Exam card, wide | features/mock_exam/presentation/widgets/mock_card.dart:267-278 | Take the Exam / Resume / View Last Results (full-width, `expand: true`, lg), then Change the Setup (tertiary, left, below) | VIOLATION | R1, R2, R3 | `_MockActionButton` has `expand: true` (line 391); the secondary sits under the main and is left-aligned. Only the customReady state has two buttons; the full-width main is in every state (also listed in section 2) |
| W19 | Paused mock page, wide | features/mock_exam/presentation/pause_page.dart:441-459 | Discard This Mock (red ghost), Resume (large) | VIOLATION | R4 | `Wrap(spacing: 12, runSpacing: 12)`; end-aligned (center when single part). Order and style fit the "Discard This Mock" rule |
| W20 | Home "Today" state card, exam passed, wide | features/home/presentation/widgets/home_state_card.dart:134-150 | Switch Exams (white), main action (secondary variant) | VIOLATION | R4 | `Wrap(alignment: end, spacing: 12)`; comment says P2 |
| W21 | Home notice, wide (own implementation, used instead of NoticeStrip) | features/home/presentation/widgets/home_web_layout.dart:565-590 | secondary/tertiary, then primary | VIOLATION | R4 | `Wrap(spacing: 12, alignment: end)`, comment "the quiet one first" |
| W22 | Home exam-date dialog, wide | features/home/presentation/widgets/home_exam_date_sheet.dart:169-181 | Cancel (tertiary), Save | OK | none | end of row, 8 px gap (a text block sits at the left) |
| W23 | Home "Keep Pantas one click away" install card, wide (container 560 and up) | core/ui/components/install_card.dart:87-89 | Not Now (tertiary), Install Pantas / Show Me How | VIOLATION | R4 | `SizedBox(width: PantasSpace.s10)` between. Order and right end correct. Below 560 (line 118-126) the card stacks the pair as `[primary, notNow]` left-aligned with spacing 10, main first, which is also wrong if a wide pane ever hits it |
| W24 | Today / Reviews / New questions / Quiz right drawer foot, wide | core/ui/web/web_side_overlay.dart:458-475 | Start or Resume (large, `expand: true`, full width), then Discard this session (ghost, centered under it) | VIOLATION | R1, R2 reversed, R3, drawer rule | Full-width main on top, secondary below. Comment: "board A, his pick Nov 25". Used from home_today_screen.dart:969,1112 and quiz_tab_screen.dart:876,902. Single Start (no Discard) is the same full-width problem (section 2) |
| W25 | Onboarding "Study days" step, wide | features/onboarding/presentation/onboarding_study_days_step.dart:164-175 via onboarding_web_page.dart:260-300 | Every Day (ghost, pulled to far left), Continue (far right) | UNSURE | R1 | `OnboardingActions` puts secondary left with `Spacer`, main right. Back/Skip rule says main stays bottom right but does not say where the secondary sits |
| W26 | Onboarding "Exam date" step with no known date, wide | features/onboarding/presentation/onboarding_exam_date_step.dart:176-191 | I don't know (ghost, far left), Continue (far right) | UNSURE | R1 | same `OnboardingActions` split |
| W27 | Onboarding "Exam date" step with a known date, wide | features/onboarding/presentation/onboarding_exam_date_step.dart:176-191 | Different Date (white), That's Right (main) after a left question | OK | none | `leading` set, secondary then 8 px then main, right end |
| W28 | Guardian "Confirm your child's account", wide | features/guardian/presentation/guardian_confirm_page.dart:236-246 via guardian_screen.dart:66-72 | Confirm (main), I Don't Agree (red ghost), stacked, centered | VIOLATION | stacked phone pair (named case), R2 reversed, R4 | `GuardianScreen` stacks actions with `SizedBox(height: s4)` and centers each; main first |
| W29 | Guardian "Waiting for your parent or guardian", wide | features/guardian/presentation/guardian_waiting_page.dart:167-185 via guardian_screen.dart:66-72 | Check Again, Resend Email, Change Email, stacked, centered | VIOLATION | stacked phone pair, R4 | same shared stack, 4 px gaps, three buttons in a column |
| W30 | Bookmarks drawer foot, wide | features/lesson/presentation/widgets/bookmarks_sheet.dart:817-860 | Select All (accent ghost, far left), "N selected" caption centered, Remove (danger, far right) | UNSURE | R1 | `Row(spaceBetween)`. Reads like a footer with caption between; no rule covers a selection foot |
| W31 | Sign-in email step, wide | app/sign_in/email_sign_in_page.dart:774-800 | Continue (main, with Enter hint), Use Google Instead (text) stacked, centered | UNSURE | stacked pair | Natural width, centered (`SignInButton` wide takes `Center`). Main above secondary. A form with an alternate sign-in link, drawn from the laptop boards |
| W32 | Sign-in code step, wide | app/sign_in/email_sign_in_page.dart:822-900 | Continue or Send a New Code (main), Use a Different Email (text) stacked, centered | UNSURE | stacked pair | same as W31 |

Not counted as groups (one action only, compliant or out of scope): Flag/Pause top bar buttons, WebBottomBar actions (counter plus one action), explanation drawer foot (counter left, Next right, web_question.dart:652), Done on results top right (mock_results_page.dart:386), WebFullNotice (centered single), Pro card "Unlock with Pro" singles, Retry singles, "See more", InstallSheet "Got It" (right), Guardian Withdraw (left Settings-style ghost).

## 2. Wide full-width or stretched single buttons (R3)

| id | Screen | file:line | Evidence |
|---|---|---|---|
| F1 | Today / Quiz right drawer Start or Resume (also W24) | core/ui/web/web_side_overlay.dart:458 | `WebButton(large: true, expand: true)` in the drawer foot |
| F2 | Mock setup page, "Start the Mock Exam" | features/mock_exam/presentation/pages/mock_setup_page.dart:349-355 | `expand: true`; comment says board MK_SetupCSE fills the right column |
| F3 | Practice picker web panel, "Start" | features/quiz/presentation/practice_picker_screen.dart:960-966 | `large: true, expand: true` |
| F4 | Mock paper side panel, "Submit the Exam" | features/mock_exam/presentation/pages/mock_session_page.dart:867-871 | `SizedBox(width: double.infinity)` plus `expand: true`; comment says board MK_SubmitCSE |
| F5 | Mock tab card main action (also W18) | features/mock_exam/presentation/widgets/mock_card.dart:386-391 | `expand: true` |
| F6 | Onboarding welcome (after Back), "Get Started" | features/onboarding/presentation/onboarding_welcome_step.dart:96-101 | `expand: true` inside a fixed 260 px box (stretched to that box, not the page). Borderline |
| F7 | Session results Done (also W13) | features/quiz/presentation/web_session_results.dart:234-238 | `expand: true` in a 192 px box. Borderline |

No wide screen uses `PantasButton(fullWidth: true)`. Check of `expand: true` elsewhere: pro_page.dart:1101 and account_page.dart:405 are phone-only; web_custom_mock_setup.dart:530 is a value field in a fixed-width cell, not an action.

## 3. Minimal fix for each VIOLATION and UNSURE, and the covering test

| id | Minimal fix | Existing test that covers it |
|---|---|---|
| W4 | Add a wide mode (natural-width right-aligned row, 8 px gap) or assert `!context.wideWeb`. No call site needs a change | test/core/ui/components/pantas_button_test.dart, structure_completion_test.dart |
| W9 | Change spacing and runSpacing from `PantasSpace.s12` to `PantasSpace.s8` | test/features/settings/presentation/account_signed_out_wide_test.dart, w4f_account_test.dart |
| W11 | Decide the rule first. If it must be a right-aligned pair: move the Restore/Switch button next to the buy button, secondary first, 8 px gap, drop the left pin | test/app/settings_pane_motion_test.dart, test/features/settings/presentation/settings_account_card_test.dart (no explicit placement test found) |
| W12 | Replace the two centered stacked buttons with one centered `Wrap`/`Row` of Done (tertiary) then Change Exam Date (main), 8 px gap | test/features/settings/presentation/exam_page_test.dart, w4f_exam_test.dart |
| W13 | Change `SizedBox(width: s12)` to `s8`. Optionally drop `expand: true` on Done so it is natural width | test/features/quiz/presentation/web_quiz_screens_test.dart |
| W14 | `spacing: PantasSpace.s16` to `PantasSpace.s8`. Update the comment (board A drew 16) | test/features/quiz/presentation/web_quiz_screens_test.dart, quiz_tab_paused_spacing_test.dart, quiz_tab_screen_test.dart |
| W15 | `SizedBox(width: s4)` to `s8`. Leave Remove where it is, or move it to the left of Cancel with a left-aligned pair (decide) | test/features/quiz/presentation/quiz_note_editor_test.dart |
| W18 | Remove `expand: true` in `_MockActionButton`. Put Change the Setup first then the main in a right-aligned `Wrap` (spacing 8) in the card footer | test/features/mock_exam/presentation/mock_card_test.dart, web_mock_layout_test.dart |
| W19 | `spacing: 12` and `runSpacing: 12` to 8 | test/features/mock_exam/presentation/pause_page_test.dart, web_pause_motion_test.dart, web_mock_dialog_keys_test.dart |
| W20 | `spacing: 12` to `8` | test/features/home/presentation/widgets/home_state_card_test.dart, web/home_wide_test.dart, web/home_quiet_states_test.dart |
| W21 | `spacing: 12` to `8` (or make HomeWebNotice reuse NoticeStrip's wide branch) | test/features/home/presentation/web/home_notice_polish_test.dart, widgets/home_notice_strip_test.dart |
| W23 | `SizedBox(width: s10)` to `s8`. For the narrow branch, reorder to `[notNow, primary]` and align right | test/core/ui/components/install_card_test.dart, install_ds_test.dart |
| W24 | In the drawer foot, replace the full-width Start plus centered Discard with one right-aligned row `[Discard (ghost), Start/Resume (main)]`, natural width, 8 px gap. Single Start: `Align(centerRight)`, no `expand` | test/core/ui/web/home_questions_sheet_footer_test.dart, web_overlays_ds_test.dart, features/home/presentation/web/home_wide_test.dart |
| W25, W26 | Decide where a secondary sits in the onboarding footer. If beside the main: in `OnboardingActions`, drop the `Spacer` and the -16 translate so the order is secondary, 8 px, main at the right | test/features/onboarding/presentation/onboarding_study_days_step_test.dart, onboarding_exam_date_step_test.dart, web_onboarding_batch2_test.dart |
| W28, W29 | In `GuardianScreen` on wide, lay actions in one centered `Wrap` (spacing 8) ordered secondary then main, instead of the stacked column. Waiting page main is Check Again | test/features/guardian/guardian_confirm_page_test.dart, guardian_waiting_page_test.dart, balanced_text_test.dart |
| W30 | Decide first. Minimal: group Select All next to Remove at the right (Select All first), caption left | test/features/lesson/presentation/web_bookmarks_test.dart |
| W31, W32 | Decide first. If stacking is wrong: a centered row, text button then Continue. Likely left as a form pattern | test/app/sign_in_test.dart, email_sign_in_redirect_test.dart |
| F1-F4 | Remove `expand: true`. Place at the right end of the panel (`Align(centerRight)`) | F1: see W24. F2: test/features/mock_exam/presentation/pages/mock_setup_page_test.dart. F3: test/features/quiz/presentation/web_quiz_motion_test.dart. F4: test/features/mock_exam/presentation/end_part_early_test.dart, task4_grid_submit_test.dart |
| F6, F7 | Drop `expand: true` and the fixed box if full width is read as 260 px and 192 px, or keep as borderline | onboarding: test/features/onboarding/presentation/web_onboarding_states_test.dart. F7: see W13 |

## 4. Files and spots not fully decided (false-negative risk)

- Sign-in (W31, W32): left as UNSURE because the stacked text-link layout looks deliberate. No second pair was checked in sign_in_parts.dart beyond the two forms.
- Phone-only paths I treated as not wide without opening every caller (they have no `wideWeb` branch and do not reach wide): session_end_screen.dart, today_questions.dart, practice_picker_screen.dart:1080 and :1184, quiz_tab_screen.dart:1099-1224, home_state_card.dart:257-307, home_today_checklist.dart:218-253, mock_review_page.dart:790-850 and :1471, mock_results_page.dart:102 and :717, pause_page.dart:613-621, mock_setup_page.dart:252, part_transition_page.dart:403, pro_page.dart:1101-1182 (phone bar), account_page.dart:405-411, carry_over_prompt.dart:791-800, exam_picker_screen.dart:1220. A route that renders its phone branch on a wide window would have been missed.
- mock_start_preparation_page.dart:120 ("Start the Paper") has no wide branch. It uses `PantasButton`, which is natural width on wide, so it is not a violation, but I did not confirm this page is reachable on wide.
- permission_rationale_page.dart (Sounds good, Not right now, stacked): not referenced by any route, so not counted. It would be a stacked pair if wired up on wide.
- component_gallery_page.dart (dev gallery) was skipped. It shows ButtonPair and NoticeStrip.
- web_study_layout.dart:242-260 can show up to three stacked retry buttons ("Try Saving Again", "Try Again", "Try Loading Your Plan Again") in the page column. They are separate recoveries, not a pair, so I did not count them.
- Buttons whose main/secondary choice is a judgment: W13 "Done" is white and "Start Session" is main; W20 uses the secondary variant as the main.
- Left-aligned single main buttons exist (for example mock_card.dart:654 Create Free Account, reader_gap.dart:137 quiz button). They are not R3 and not a group, so they are not listed. The rule says to put card buttons at the right end, so say if you want them listed.
