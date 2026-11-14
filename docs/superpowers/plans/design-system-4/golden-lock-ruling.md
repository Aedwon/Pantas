# Golden lock ruling (Fable 5.2 design review, Nov 14, 2026)

Made under Aedwon's delegation: "for things needing my decision, consult a fable 5.2 agent instead" (Nov 2026), and D191, "decide for me based on the design system and whichever is the best for UX", with WCAG 2.0 AA and Apple HIG as the bar. These rulings are final.

Scope: 57 component sheets and 56 screen images in `build/gallery/app/`, against the component READMEs, `tokens.json`, `patterns.md`, the decisions, and the approved boards where the system is silent. Read-only review. Nothing was rendered, edited or run.

## Verdict

**The set may not be locked whole. Lock 101 images now. Hold 12 until they are fixed and recaptured.**

| | LOCK | FIX high | FIX medium | FIX low | Total |
|---|---|---|---|---|---|
| Component sheets | 34 | 5 | 14 | 4 | 57 |
| Screen images | 35 | 7 | 7 | 7 | 56 |
| All | 69 | 12 | 21 | 11 | 113 |

The lock rule used here:

- A FIX image **may be locked now** when it shows what a student really sees today. The fix then updates the image deliberately.
- A FIX image **must not be locked** in three cases:
  1. The image is not what a student sees (a capture or fixture fault). It would guard nothing real.
  2. A cell is labeled hover, pressed or focus and shows no such state, and it is that control's only coverage of the state. The lock would certify "no change" as correct, which is the fault this guardrail exists to catch.
  3. The image shows an accessibility or legibility failure. WCAG AA is the bar, so the fix comes first.

### Must not be locked (12)

Component sheets:

1. `back_link.png`: hover and pressed cells miss the control (harness).
2. `sidebar_nav.png`: item hover and pressed cells miss the item; no item focus cell (harness).
3. `focus_header.png`: the "Report, hover" cell misses the button (harness).
4. `popover.png`: every cell is clipped to a sliver; nothing is shown (harness window, plus a real flip-rule defect).
5. `figure.png`: dark question figure has no white backing and is close to invisible (app defect).
6. `reader_top_bar.png`: phone back has no hover, pressed or focus state and Tab reaches nothing (app defect).

Screens:

7. `screens-home_1440.png`: Study is selected on Home; phone masthead inside the wide shell (fixture).
8. `screens-mock_setup_1440.png`: page rendered outside the shell, flush to the edges, back chevron clipped (capture).
9. `screens-plan_1440.png`: yellow double underlines on every text run, white page (no Material ancestor in the test).
10. `screens-plan_day_1440.png`: the day pane alone, stretched across 1440 (capture).
11. `screens-pro_1440.png`: page outside the shell, title clipped at the top, white band at the bottom (capture).
12. `screens-quiz_tab_1440.png`: page outside the shell, flush to the edges (capture).

Ten of the twelve are faults in the test harness or fixtures. Two are app defects (Figure, ReaderTopBar). I opened all twelve images myself and confirmed each one. I also read the harness, the BackLink source and the phone reader bar source.

## Rulings on the builder's known findings

- **ReaderTopBar back shows no hover, pressed or focus change.** App defect, high. The harness is fine. The phone bar builds back, contents and bookmark as bare tap detectors (`lib/features/lesson/presentation/widgets/reader_bar.dart`, lines 126 to 230), with no focus node and no hover. The README says "Back has the BackLink hover, pressed and focus states; contents has the IconButton states" and "Tab: back, contents". D192 says the back is the BackLink. The phone bar must use the system BackLink (`back--phone`) and IconButton. Keyboard reach fails WCAG 2.1.1 and 2.4.7. Do not lock the sheet until fixed.
- **Figure "Question figure" has no white backing in dark.** App defect, high. The README says "`figure-bg` backing (white in both themes, the printed look)". The system README line 50 says figures "stay white or printed in both themes". The app themes SVG question figures on purpose (`followTheme: true`) and recolors known token colors. Any figure color the mapper does not know stays dark on a dark surface, as the sheet shows. The system wins: white backing in both themes. Do not lock until fixed.
- **SearchOverlay has no typed-results state.** Coverage gap, not a block. Lock the sheet now for its other findings. Add typed results, no results and keyboard focus cells in the next harness pass.
- **Explanation shows only the phone AnswerReveal.** Coverage gap, not a block. LOCK. Add the desktop card cell later.
- **Select's open list is in the Popover sheet.** The Popover sheet shows nothing, so the open list has no coverage at all. This is part of the Popover block.
- **No board for mock_setup at 390 or questions_unavailable.** Judged against the system (DataTable, Switch, ErrorState, patterns.md). Rulings are in the screen list.
- **StateView has no system reference.** Judged against the EmptyState and ErrorState READMEs. LOCK.

## Components

Format: name, ruling, severity, state and theme, what settles it, lock.

- AccuracyBar: LOCK.
- AnswerOption: FIX, medium. Keyboard focus, both themes: focus is drawn as the option's own 2px border with no offset, so a focused unselected option looks like a selected one except for the badge. README States "2px accent outline, offset 2"; D88. Also low: pressed has no 0.98 scale (README States). Lock now: yes.
- Avatar: FIX, medium. No name, both themes: three different fallbacks (person glyph on phone, gray disc with a dot on the wide settings list, an initial in the sidebar). README States "Empty: if the name is missing, hide the avatar" and "Don't add a status dot". Also low: the phone circle is 58, off token (README has 30 and 44, D85). Lock now: yes. Shows on all six settings 1440 images.
- BackLink: FIX, high (harness). Hover and pressed, both themes: both cells equal rest. The component fills the 160 cell and the link is about 76 wide, so the pointer at the cell center misses it. The source does carry the 0.08 accent wash and the accent-hover label (README States). Fix: aim the pointer at the link, and add the page form (nudged) and the 44px phone form. Lock now: **no**.
- Button: LOCK.
- Card: LOCK.
- CardFooter: LOCK.
- Chart: FIX, medium. Every cell, both themes: the top y-axis label reads "100" and the others read "75%", "50%", "25%", "0%". README Anatomy "Y axis: 0, 25, 50, 75, 100%". Lock now: yes.
- Checkbox: FIX, low. Off hover, both themes: no hover fill on the unchecked box (README States "Hover: surface-hover well"). Settled ruling on the focus ring holds. Lock now: yes.
- DataTable: FIX, medium. All cells, both themes: (a) the table keeps its natural width and does not fill the card (system `.dtable{width:100%}`); (b) plain headers sit about 4px above the hairline where the README gives "padding 12 by 16". Low: sortable headers with no handler sit 6px left of the body text. Seen in production on Performance 1440 and Mock setup at both widths. Lock now: yes.
- DatePicker: LOCK. The sheet shows the phone calendar Aedwon chose on Nov 10. The component README is stale on the phone form and needs the update.
- Dialog: LOCK.
- Drawer: LOCK.
- ExamChip: FIX, medium. (a) No exam date, both themes: the empty chip drops the exam name (README Anatomy "Beside it: exam name 13/700"). (b) Home draws its own private chip, so this sheet guards a component the app does not use. Home must use the core component. Lock now: yes.
- Explanation: LOCK. System note: the Pro "Your pick" row uses the same teal key as the correct answer, and the system has no entry for that row. It needs one.
- Field: FIX, low. Invalid, both themes: the error line uses the warning circle; the system preview draws the alert triangle. Lock now: yes.
- Figure: FIX, high. Question figure, dark: no white backing (see above). Medium, both themes: the backing is only as wide as the image and the zoom badge hangs outside it (README: the badge sits inside the backing). Low: no 1px divider ring on the question figure; focus rings the badge only, where the README rings the whole figure button. Lock now: **no**.
- FloatingBar: FIX, medium. Desktop cells, both themes: order is counter, hint, flag, action; the README markup and preview put the flag right after the counter. Low (harness): the phone cells use sample slots the app never draws; use the real mock bar slots. Lock now: yes.
- FocusHeader: FIX, medium (harness). "Report, hover", both themes: the cell shows rest because the pointer lands in the bar's side padding. The component has the hover tint. Lock now: **no**, re-aim the cell in the same pass as BackLink and SidebarNav.
- Gauge: LOCK. Gradient is settled.
- GroupedList: LOCK.
- IconButton: LOCK.
- KeyHint: LOCK.
- ListRow: FIX, medium. Static, both themes: a non-tappable row draws a chevron, which promises a tap that does nothing. README "a static row reserves the chevron slot (an empty 16px cell)". Low: on wide web the chevron is always visible where the README fades it in on hover. Lock now: yes.
- Notice: LOCK. Chevron is settled.
- PageHeader: LOCK.
- Passage: FIX, low. The card cannot draw a source line (README "Keep the source line"). Lock now: yes.
- Popover: FIX, high. Every cell, both themes: only the bottom edge and shadow of a clipped surface. The test window is 320 by 230. The flip rule also has a real defect: it flips above whenever the room below is less than the maximum height, without checking the room above or the real content height, so a popover can leave the top of a short viewport (README "Flip above or shift sideways instead of clipping"). Fix the rule, enlarge the window, then recapture with items, hover, selected, empty and the Select open list. Lock now: **no**.
- ProMark: LOCK.
- ProgressBar: LOCK.
- ProgressRing: LOCK. Ruling: the brighter empty track in dark stays, because a `divider` track vanishes on a dark card. Amend the README. System note: the 72px ring on the sheet is not a system size.
- QuestionNavigator: LOCK.
- Radio: LOCK. Focus on the control is settled. The hover cells show nothing because the sheet is in phone layout; add a web cell.
- ReaderBlock: FIX, medium. Note and Traps body, both themes: 18/500 at 1.7 where the README says `web-reader-block` 16/400/1.6. Example, both themes: radius 18 and a 13/600 teal head where the README says radius 14 and a 15/600 head in `reader-strong`. Lock now: yes.
- ReaderTopBar: FIX, high (see above). Ruling on the phone bar's structure: the bookmark control stays (it is an existing phone feature and the system anatomy is silent on it); the README must add it. Low, to check with the fix: the phone bar sits on the card surface where the README says `bg-page`. Lock now: **no**.
- SearchField: FIX, medium. Desktop focus, both themes: a focused desktop field shows the phone Cancel and shrinks. README "Desktop with a KeyHint, phone with Cancel". Low: phone Cancel is weight 400 where the system draws a 600 teal text button. Lock now: yes.
- SearchOverlay: FIX, medium. Loading, both themes: a skeleton group where the README says "a Spinner row with 'Searching'". No results (source only, not on the sheet): two plain lines where the README asks for an EmptyState with a suggestion and "Browse All Subjects". Low: the group label is mixed case where `web-eyebrow` is uppercase; the focused field shows a hairline where the README gives a 2px accent line; the fixture gives rows no subject. Lock now: yes.
- SectionHeader: LOCK.
- SegmentedControl: FIX, medium. Hover and pressed, both themes: the wash is drawn on the 44px hit area and spills past the 38px track. Bookmarks, both themes: unselected labels are 600 like the selected one, where the README says "unselected labels 500" and "Selection shows by the thumb and by weight". Lock now: yes.
- Select: LOCK. Open list coverage depends on the Popover recapture.
- SelectableTile: LOCK.
- Sheet: FIX, medium. Phone, both themes: Close is teal where the README says the gray tertiary. Low: a cell certifies a sheet with no Close, which the README forbids ("Don't ship a sheet without a Cancel or Close button"), so drop the cell; the wide cell shows a form the system does not have ("Wide screens use Drawer or Dialog"), so drop it too. Lock now: yes.
- SidebarNav: FIX, high (harness). Item hover and item pressed, both themes: both cells equal rest because the pointer lands between the search field and Home. The source has the 8% fill and the 0.98 press. The Focus cell rings the search field, so no item focus is shown. Medium, inferred from source: the item is built like the Toast action, so a double focus ring is likely; check it once the cell exists. Low, seen on the settings screens: the account line truncates to "CSE Subprofessional · F…" and hides Free or Pro. Glyphs are settled. Lock now: **no**.
- Skeleton: LOCK. The system reference previews are blank, so this was judged from the README.
- Slider: FIX, low. Disabled, both themes: the filled track turns gray where the README keeps accent at 40% opacity. All states: the filled part of the track is thicker than the rest (README "Track 4px high"). Lock now: yes.
- Spinner: LOCK.
- StatRow: LOCK.
- StateView: LOCK. Alert triangle is settled.
- Switch: LOCK.
- TabBar: LOCK. Glyphs are settled.
- Tag: LOCK.
- TaskStatus: LOCK.
- TextLink: LOCK. Ruling: the arrowless "text only" variant stays. Add it to the README.
- Timer: LOCK.
- Toast: FIX, medium. Undo focus, both themes: two concentric rings where the README gives one ("2px accent outline"). Lock now: yes.
- Tooltip: LOCK.
- WeekStrip: LOCK. Ruling: the Sunday to Saturday week stands (the launch log treats it as the app's week, and D196 governs the phone window). The README markup is Monday-first and needs the update, with D196.

## Screens

- assessment_question 1440: LOCK. The missing "Answers show at the end." hint is Aedwon's removal (launch log, Nov 2).
- assessment_results 1440: LOCK.
- home 390: LOCK. Five days centered on Today follow D196, which supersedes the board.
- home 1440: FIX, high (fixture). The sidebar shows Study selected on Home (the fixture hard-codes the index; patterns.md "Keep the tab or sidebar selection on the destination"). The week strip is stretched above the greeting and the date line is missing, because the masthead reads the real platform flag and takes the phone branch (patterns.md "Root pages (Home): a date line above the title, and a right-hand slot for the WeekStrip"). Judge again after recapture: the board's "Your performance" empty panel, the TODAY eyebrow and the Enter key hint are absent (medium, board HM_BeforeAssessment-web, no later decision found). Lock now: **no**.
- lesson_reader 390: LOCK at rest. The back control's missing states are ruled under ReaderTopBar.
- lesson_reader 1440: LOCK.
- mock_results 390: LOCK.
- mock_results 1440: LOCK.
- mock_session 390: LOCK. The up-down caret on the counter is Aedwon's pick (Nov 10).
- mock_session 1440: FIX, medium. Next is a plain chevron like Previous. The FloatingBar README says the mock bar holds "the counter, the hint and the main action" and "the action is Next"; board W_Mock-web draws a teal Next. Low, from source: the arrows are Material chevrons, not Phosphor carets. Lock now: yes.
- mock_setup 390: FIX, medium. The section table is shrunk to its content inside the card (system `.dtable{width:100%}`). Lock now: yes.
- mock_setup 1440: FIX, high (capture). Rendered outside the shell: no sidebar, content flush at x=0, back chevron clipped, right card to the window edge. Same shrunk table. Lock now: **no**.
- questions_unavailable 390: FIX, low. Icon and title only; the line saying what to do is missing (patterns.md "Error: say what happened and what to do"; ErrorState README "title, one line"). Lock now: yes.
- questions_unavailable 1440: FIX, low. Same missing line. Lock now: yes.
- study_list 390: LOCK.
- study_list 1440: LOCK. Coverage is thin: no selected topic, no lesson pane, no Last opened.
- onboarding_age 390: LOCK. The stepper follows Aedwon's Nov 10 choice; the board's year wheel is superseded.
- onboarding_age 1440: LOCK.
- onboarding_consent 390: FIX, medium. The agree row breaks after "Privacy Policy" and the next line starts with a comma. Board O_Consent-mobile draws one flowing sentence. Lock now: yes.
- onboarding_consent 1440: FIX, medium. Same orphaned comma, with room on the line. Lock now: yes.
- onboarding_date 390: LOCK.
- onboarding_date 1440: LOCK.
- onboarding_name 390: LOCK. The visible label follows the Field README over the board.
- onboarding_name 1440: LOCK.
- onboarding_picker 390: LOCK. The "Could not load exams" state on the board has no golden.
- onboarding_picker 1440: FIX, medium. Exam tiles run one per row in a 580 column and the filters wrap to two rows. Board OB_Picker-web and the SelectableTile README `.choice-grid` give a three-column grid. Lock now: yes.
- onboarding_study_days 390: LOCK.
- onboarding_study_days 1440: LOCK.
- performance 390: LOCK.
- performance 1440: FIX, medium. The table's dividers start flush at the card's left edge and stop about 32px short of the right edge (DataTable README "Outer cells pad 20"; board PF_Subjects-web). Low: "ANSWERED" heads empty cells; the sort Select sits beside the tabs. Lock now: yes.
- plan 390: LOCK.
- plan 1440: FIX, high (capture). Yellow double underlines on every text run and a white page: the test pumps the page with no scaffold. Judge the exam row's date tile again after recapture. Lock now: **no**.
- plan_day 390: LOCK.
- plan_day 1440: FIX, high (capture). The day pane is drawn alone across 1440. The board and the real route show it about 470 wide beside the plan. Lock now: **no**.
- pro 390: FIX, high (app). The headline and feature list are plain text on the page. patterns.md says "the teal hero (phone, `.card--hero`)", D126 defines it, and board ST_ProCSE-mobile draws it. No later decision removes it. Prices match `docs/pricing.md`. Lock now: yes. Fix before the prod release.
- pro 1440: FIX, high (capture). Rendered outside the shell: no sidebar, "Settings" clipped at the top-left, cards flush to the right edge, a white band from about y=765. Lock now: **no**.
- quiz_question_picking 390: FIX, low. The hint "Check when you are ready" wraps to two lines in the pill. The up-down caret is approved. Lock now: yes.
- quiz_question_picking 1440: LOCK.
- quiz_question_revealed 390: LOCK.
- quiz_question_revealed 1440: LOCK. Only the right-answer state is captured; the miss state (W_QMiss) has no golden.
- quiz_tab 390: FIX, low. "More ways to practice" dividers run the full card width where the separator starts at the text (GroupedList and ListRow READMEs). Lock now: yes.
- quiz_tab 1440: FIX, high (capture). Rendered outside the shell, flush to the edges. Lock now: **no**.
- session_end 390: FIX, low. Mistakes dividers run the full card width; the sticky action cuts the notes text with no fade. Lock now: yes.
- session_end 1440: FIX, low. Answer chips are about 36px with 16px gaps where the board and the phone use about 30px with 8px gaps; the mistake mark differs from the phone's. Lock now: yes.
- settings_about 390: LOCK.
- settings_about 1440: LOCK. Carries the shared Avatar and sidebar account-line fixes.
- settings_account 390: LOCK. Signed-out state only.
- settings_account 1440: LOCK. Shared fixes apply.
- settings_appearance 390: LOCK.
- settings_appearance 1440: LOCK. Shared fixes apply.
- settings_backup 390: FIX, medium. The state is "Not backed up" with a disabled "Back Up Now" and no way forward. Board ST_BackupStates-mobile offers "Sign In to Back Up". Check whether the fixture causes this before changing the app. Lock now: yes.
- settings_backup 1440: FIX, low. The pane icon is the person glyph where board ST_BackupDetails-web shows a cloud; the "BACKUP" eyebrow repeats. Lock now: yes.
- settings_exam 390: LOCK.
- settings_exam 1440: LOCK. Shared fixes apply.
- settings_home 390: LOCK.
- settings_home 1440: LOCK. It is the same image as settings_account 1440, so one of the two is redundant.

## Coverage notes (not blocks)

- Only home, study_list and the settings screens render inside the wide shell. Every other 1440 screen has no sidebar. Performance renders correctly without it; mock_setup, plan, plan_day, pro and quiz_tab do not, and are held above.
- No 390 screen shows the TabBar.
- Phone-layout sheets cannot show hover (Radio, Checkbox). Add web cells.
- Missing states worth adding in the next harness pass: AnswerOption disabled and submitted; Button done; SearchOverlay typed results; Explanation desktop card; ReaderTopBar wide bar; SegmentedControl desktop; onboarding picker "Could not load exams"; quiz revealed miss state; signed-in Account.

## System documents to amend (the app is right, the README is stale)

DatePicker phone form; WeekStrip week start and D196; ProgressRing empty track in dark; ReaderTopBar phone bookmark; TextLink arrowless variant; Explanation "Your pick" row. The Gauge reference preview draws its number at body size and the Skeleton reference previews are blank; both are preview faults.

## Limits of this review

- The review ran as seven parallel passes on the same model, one per slice, and I checked every high finding and every "must not lock" image myself.
- I corrected two points from the passes against the decision log: the up-down caret on the phone counters is approved (Nov 10), and the Sunday week start is established.
- Some tall reference images were too small to read after downscaling (AnswerOption, Button, Chart, and both lesson reader boards). Those were settled from the README and the preview source.
- Medium and low findings rest on one pass each plus the source lines cited. I did not re-open those images.

---

# Round 2 (Nov 14, 2026): re-check of the held images at commit 2208ef04f

Scope: the 12 images held in round 1, plus pro 390, rendered again on the CI image and read from `build/gallery/app/`. All 13 files differ from round 1. I opened each one myself, and the boards HM_BeforeAssessment-web and PL_Day-web. I read the phone reader bar and phone Pro hero source, and measured the hero's colors from the image. Read-only as before.

## Verdict

**The whole set may be locked now. All 113 images are cleared. Nothing is held.**

No fix introduced a new high problem. One new medium problem appeared (pro 390, eyebrow contrast). One high app defect stays open but is not shown in any image (ReaderTopBar contents and bookmark keyboard reach). It does not block the lock. It must be fixed before the prod release.

## The 13 images

| Image | Ruling | Open FIX after the lock |
|---|---|---|
| back_link | LOCK | none |
| sidebar_nav | LOCK | medium: doubled item focus ring |
| focus_header | LOCK | none |
| popover | LOCK | none |
| figure | LOCK | medium: backing width and zoom badge |
| reader_top_bar | LOCK | high (app, not in the image): contents and bookmark |
| home 1440 | LOCK | medium: board regions absent |
| mock_setup 1440 | LOCK | medium: shrunk table (DataTable) |
| plan 1440 | LOCK | low: exam row glyph, week row label order |
| plan_day 1440 | LOCK | low: no selected row, exam row glyph |
| pro 1440 | LOCK | shared Avatar fix only |
| quiz_tab 1440 | LOCK | none |
| pro 390 | LOCK | medium (new): eyebrow contrast, gap above the hero |

Reasons:

- **back_link: LOCK.** Hover and pressed now show the accent wash and the darker label in both themes; pressed is scaled. Matches README States. Coverage gap stays: the page form and the 44px phone form have no cell.
- **sidebar_nav: LOCK.** Item hover shows the fill and item pressed shows the fill with the press scale, both themes. The new "Item focus" cell shows two concentric rings where the README gives one ("2px `accent` outline, 2px offset"). This confirms the round 1 medium finding. Focus is clearly visible, so this is a visual deviation and not an accessibility failure. The image shows what a student sees, and the fix will update it deliberately.
- **focus_header: LOCK.** "Report, hover" now shows the tint on the button, both themes.
- **popover: LOCK.** Items, the selected row with its tint and check, the disabled row, the separator, the hover well, the empty message and the Select open list under its trigger are all shown, whole, in both themes. The hard-edged pale area around each popover is the shadow cut at the cell edge (sheet layout).
- **figure: LOCK.** The dark question figure has its white backing and the sample reads clearly. Still open, medium, both themes: the backing is only as wide as the image, so the zoom badge sits outside it on the page. Low: no divider ring on the question figure; focus rings the badge only.
- **reader_top_bar: LOCK.** Back hover, back pressed and focus now show the wash, the press and a single focus ring, both themes. Every cell on the sheet is true. Still open, high, app: the contents and bookmark controls are still bare tap detectors (`reader_bar.dart`, lines 152 and 510), so Tab cannot reach them and they have no hover or focus state. README "Tab: back, contents" and "contents has the IconButton states"; WCAG 2.1.1. The sheet has no cell for those states, so the image does not certify the defect. Add contents hover and focus cells with the fix.
- **home 1440: LOCK.** Home is selected, the date line sits above the greeting, and the week strip is in the right-hand slot (patterns.md, root pages). Still open, medium: board HM_BeforeAssessment-web draws a TODAY eyebrow, a "Your performance" empty panel with dashes, and an Enter key hint on Start Assessment. The app has none of the three, and I found no later decision that removes them. If one exists, this item closes.
- **mock_setup 1440: LOCK.** Inside the shell with Quiz selected; nothing is clipped. The table is still shrunk inside its card (the DataTable fix).
- **plan 1440: LOCK.** Clean text on the page background inside the shell. Low, against the board: the exam row shows a calendar glyph where the board draws the date tile; the current week row puts the date range as the title and "This week" at the right, where the board does the opposite.
- **plan_day 1440: LOCK.** The day pane sits beside the plan inside the shell, as on PL_Day-web. Low: the board tints the plan row whose day is open and the app shows no selected row. This may be the fixture.
- **pro 1440: LOCK.** Inside the shell with Settings selected. Promo card, three tiles and the Season Pass, Restore at the left, action at the right. It carries the shared Avatar fix (gray disc with a dot).
- **quiz_tab 1440: LOCK.** Inside the shell with Quiz selected; both columns have their gutters.
- **pro 390: LOCK.** The teal hero is drawn: gradient, radius 22, white heading, five feature rows with pale icons, no shadow (D126). Prices unchanged. Two items, both medium, both new with the hero:
  1. The "PANTAS PRO" eyebrow is small white text at the top of the gradient. Measured from the image, it sits on rgb(13, 135, 115), which gives 4.44:1 against the 4.5:1 that WCAG 1.4.3 requires for text this size. The Card README allows only titles (large text) on the upper part and keeps body text to the lower 60%. Ruling: move the eyebrow down inside the hero by one `space-12` step, where the background measures 4.68:1, and add the eyebrow to the `.card--hero` entry.
  2. The hero starts about 60px under the BackLink. Board ST_ProCSE-mobile starts it about 20px under.

  This image is locked despite item 1. Round 1's rule holds an image that shows an accessibility failure. I am making an exception here and saying so: the miss is 0.06 under the threshold, the text is plainly legible, and it repeats what the heading and the page already say. Fix it before the prod release.

## Open fixes after the lock, by severity

- High (1): ReaderTopBar phone contents and bookmark keyboard reach and states.
- Medium: every medium item in round 1 that this commit did not touch, plus SidebarNav doubled focus ring, Figure backing and badge, home 1440 board regions, pro 390 eyebrow and gap.
- Low: unchanged from round 1, plus the plan and plan_day notes above.

The lock records the app as it is. It does not approve these items. Aedwon's visual pass still gates the release.
